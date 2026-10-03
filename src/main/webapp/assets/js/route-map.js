// Draws a simple route picture from real coordinates (no map tiles, no API key).
//   <div class="route-map" data-route-map
//        data-pickup="13.04,80.23" data-pickup-label="T. Nagar"
//        data-dest="13.00,80.25"   data-dest-label="Adyar"
//        data-vehicle="13.03,80.24" data-vehicle-label="Your parcel"></div>
// Missing points are simply left out. Other scripts redraw with EM.drawRouteMap(el, points).
(function () {
    const NS = 'http://www.w3.org/2000/svg';

    function parse(value) {
        if (!value) return null;
        const parts = value.split(',').map(Number);
        if (parts.length !== 2 || parts.some(isNaN)) return null;
        return { lat: parts[0], lng: parts[1] };
    }

    function haversineKm(a, b) {
        const R = 6371, toRad = Math.PI / 180;
        const dLat = (b.lat - a.lat) * toRad, dLng = (b.lng - a.lng) * toRad;
        const h = Math.sin(dLat / 2) ** 2 + Math.cos(a.lat * toRad) * Math.cos(b.lat * toRad) * Math.sin(dLng / 2) ** 2;
        return 2 * R * Math.asin(Math.sqrt(h));
    }

    function el(name, attrs, parent) {
        const node = document.createElementNS(NS, name);
        Object.keys(attrs).forEach(function (k) { node.setAttribute(k, attrs[k]); });
        if (parent) parent.appendChild(node);
        return node;
    }

    function label(svg, x, y, text, anchor) {
        if (!text) return;
        const t = el('text', {
            x: x, y: y, 'text-anchor': anchor, 'font-size': 12, 'font-weight': 600, fill: '#0f1b2d',
            stroke: '#eef3f8', 'stroke-width': 4, 'paint-order': 'stroke', 'font-family': 'Inter, system-ui, sans-serif'
        }, svg);
        t.textContent = text.length > 28 ? text.slice(0, 27) + '…' : text;
    }

    function draw(container, points) {
        container.querySelectorAll('svg, .route-map-empty, .map-legend, .map-distance').forEach(function (n) { n.remove(); });
        const list = ['pickup', 'dest', 'vehicle'].filter(function (k) { return points[k]; });
        if (list.length === 0) {
            const empty = document.createElement('div');
            empty.className = 'route-map-empty';
            empty.textContent = container.dataset.emptyText || 'Add pickup and delivery locations to see the route.';
            container.appendChild(empty);
            return;
        }

        const W = Math.max(container.clientWidth, 280);
        const H = Math.max(container.clientHeight, 220);
        // Room for labels above markers and for the legend along the bottom
        const padX = 56, padTop = 42, padBottom = 66;
        const innerH = H - padTop - padBottom;

        // Equirectangular projection, longitudes scaled by cos(latitude)
        const meanLat = list.reduce(function (s, k) { return s + points[k].lat; }, 0) / list.length;
        const kx = Math.cos(meanLat * Math.PI / 180);
        const xs = list.map(function (k) { return points[k].lng * kx; });
        const ys = list.map(function (k) { return points[k].lat; });
        let minX = Math.min.apply(null, xs), maxX = Math.max.apply(null, xs);
        let minY = Math.min.apply(null, ys), maxY = Math.max.apply(null, ys);
        const span = Math.max(maxX - minX, maxY - minY, 0.01);   // at least ~1 km so one point is not a zoom to infinity
        const cx = (minX + maxX) / 2, cy = (minY + maxY) / 2;
        const scale = Math.min((W - padX * 2) / Math.max(maxX - minX, span * 0.3), innerH / Math.max(maxY - minY, span * 0.3));

        function project(p) {
            return { x: W / 2 + (p.lng * kx - cx) * scale, y: padTop + innerH / 2 - (p.lat - cy) * scale };
        }

        const svg = el('svg', { viewBox: '0 0 ' + W + ' ' + H, role: 'img', 'aria-label': 'Route overview' });
        const P = points.pickup && project(points.pickup);
        const D = points.dest && project(points.dest);
        const V = points.vehicle && project(points.vehicle);

        if (P && D) {
            // Gentle curve between pickup and destination
            const mx = (P.x + D.x) / 2, my = (P.y + D.y) / 2;
            const dx = D.x - P.x, dy = D.y - P.y, len = Math.hypot(dx, dy) || 1;
            const bend = Math.min(40, len * 0.18);
            const qx = mx - dy / len * bend, qy = my + dx / len * bend;
            const d = 'M' + P.x + ' ' + P.y + ' Q' + qx + ' ' + qy + ' ' + D.x + ' ' + D.y;
            el('path', { d: d, fill: 'none', stroke: '#ffffff', 'stroke-width': 8, 'stroke-linecap': 'round' }, svg);
            el('path', { d: d, fill: 'none', stroke: '#0d9488', 'stroke-width': 4, 'stroke-linecap': 'round', 'stroke-dasharray': '1 9' }, svg);
        }
        if (V && D && !P) {   // partner's own trip: vehicle -> where it is heading
            el('line', { x1: V.x, y1: V.y, x2: D.x, y2: D.y, stroke: '#0d9488', 'stroke-width': 3, 'stroke-dasharray': '1 8', 'stroke-linecap': 'round' }, svg);
        }
        if (V && P && points.vehicleToPickup) {
            el('line', { x1: V.x, y1: V.y, x2: P.x, y2: P.y, stroke: '#f59e0b', 'stroke-width': 2, 'stroke-dasharray': '4 5' }, svg);
        }
        if (P) {
            el('circle', { cx: P.x, cy: P.y, r: 11, fill: '#fff', stroke: '#0d9488', 'stroke-width': 4 }, svg);
            label(svg, P.x, P.y - 18, container.dataset.pickupLabel || 'Pickup', 'middle');
        }
        if (D) {
            el('path', {
                d: 'M' + D.x + ' ' + (D.y + 2) + ' l-9 -13 a11 11 0 1 1 18 0 z',
                fill: '#0b2042', stroke: '#fff', 'stroke-width': 2
            }, svg);
            el('circle', { cx: D.x, cy: D.y - 17, r: 4, fill: '#fff' }, svg);
            label(svg, D.x, D.y + 18, container.dataset.destLabel || 'Destination', 'middle');
        }
        if (V) {
            el('circle', { cx: V.x, cy: V.y, r: 16, fill: 'rgba(245,158,11,.22)' }, svg);
            el('circle', { cx: V.x, cy: V.y, r: 8, fill: '#f59e0b', stroke: '#fff', 'stroke-width': 3 }, svg);
            // Next to a pickup/destination marker the label goes to the side so the two don't overlap
            const crowded = [P, D].some(function (q) { return q && Math.hypot(q.x - V.x, q.y - V.y) < 60; });
            if (crowded) label(svg, V.x + 18, V.y + 26, container.dataset.vehicleLabel || 'Vehicle', 'start');
            else label(svg, V.x, V.y - 22, container.dataset.vehicleLabel || 'Vehicle', 'middle');
        }
        container.appendChild(svg);

        const legend = document.createElement('div');
        legend.className = 'map-legend';
        legend.innerHTML = (P ? '<span><i style="background:#fff;border:3px solid #0d9488"></i>Pickup</span>' : '')
            + (D ? '<span><i style="background:#0b2042"></i>Destination</span>' : '')
            + (V ? '<span><i style="background:#f59e0b"></i>' + (container.dataset.vehicleLegend || 'Vehicle') + '</span>' : '');
        container.appendChild(legend);

        if (points.pickup && points.dest) {
            const badge = document.createElement('div');
            badge.className = 'map-distance';
            badge.textContent = haversineKm(points.pickup, points.dest).toFixed(1) + ' km straight line';
            container.appendChild(badge);
        }
    }

    function pointsFrom(container) {
        return {
            pickup: parse(container.dataset.pickup),
            dest: parse(container.dataset.dest),
            vehicle: parse(container.dataset.vehicle),
            vehicleToPickup: container.dataset.vehicleToPickup === 'true'
        };
    }

    window.EM = window.EM || {};
    window.EM.drawRouteMap = function (container, points) { draw(container, points || pointsFrom(container)); };
    window.EM.haversineKm = haversineKm;

    const maps = document.querySelectorAll('[data-route-map]');
    maps.forEach(function (m) { draw(m, pointsFrom(m)); });
    let resizeTimer = null;
    window.addEventListener('resize', function () {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function () {
            document.querySelectorAll('[data-route-map]').forEach(function (m) { draw(m, pointsFrom(m)); });
        }, 150);
    });
})();
