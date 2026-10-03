// Customer side: asks /api/tracking for the latest status and position every 10 seconds
// and updates the badge, timeline, location card and route map. Nothing is guessed:
// without a position from the server the page keeps saying the location is not available yet.
(function () {
    const root = document.getElementById('tracking');
    if (!root) return;
    const bookingId = root.dataset.bookingId;
    const map = document.getElementById('trackMap');
    const PICKED_UP_ORDER = 6;
    const TONES = ['pending', 'matched', 'confirmed', 'transit', 'success', 'danger'];

    function text(id, value) {
        const el = document.getElementById(id);
        if (el) el.textContent = value;
    }

    function stageOf(status) {
        const stages = {
            REQUESTED: ['Pending', 'pending'], SEARCHING: ['Pending', 'pending'], MATCHED: ['Matched', 'matched'],
            PARTNER_ACCEPTED: ['Confirmed', 'confirmed'], PARTNER_ARRIVING: ['Confirmed', 'confirmed'],
            ARRIVED_AT_PICKUP: ['Confirmed', 'confirmed'], PICKED_UP: ['In Transit', 'transit'],
            IN_TRANSIT: ['In Transit', 'transit'], ARRIVED_AT_DESTINATION: ['In Transit', 'transit'],
            DELIVERED: ['Delivered', 'success'], COMPLETED: ['Completed', 'success'], CANCELLED: ['Cancelled', 'danger']
        };
        return stages[status] || [status, 'neutral'];
    }

    function update(data) {
        const stage = stageOf(data.status);
        const badge = document.getElementById('statusBadge');
        if (badge) {
            badge.textContent = stage[0];
            TONES.forEach(function (t) { badge.classList.remove('tone-' + t); });
            badge.classList.add('tone-' + stage[1]);
            badge.title = data.statusLabel;
        }

        const hasLocation = data.latitude !== null && data.longitude !== null;
        document.getElementById('noLocation').hidden = hasLocation;
        document.getElementById('locationData').hidden = !hasLocation;
        const finished = data.status === 'COMPLETED' || data.status === 'CANCELLED';
        document.getElementById('liveTag').hidden = !hasLocation || finished;
        const note = document.getElementById('refreshNote');
        if (note && finished) note.hidden = true;
        if (hasLocation) {
            text('position', data.latitude + ', ' + data.longitude);
            const link = document.getElementById('mapLink');
            link.href = 'https://www.openstreetmap.org/?mlat=' + data.latitude + '&mlon=' + data.longitude
                + '#map=15/' + data.latitude + '/' + data.longitude;
            link.hidden = false;
            text('lastUpdated', data.lastUpdated ? formatTime(data.lastUpdated) : 'Last known vehicle position');
        }
        if (data.distanceToPickupKm !== null) {
            text('toPickup', data.distanceToPickupKm + ' km');
            text('toDestination', data.distanceToDestinationKm + ' km');
        }

        // Re-colour the timeline
        const current = document.querySelector('#timeline li[data-status="' + data.status + '"]');
        const currentOrder = current ? parseInt(current.dataset.order, 10) : -1;
        document.querySelectorAll('#timeline li').forEach(function (li) {
            const order = parseInt(li.dataset.order, 10);
            const done = order < currentOrder || data.status === 'COMPLETED';
            li.className = done ? 'done' : (order === currentOrder ? 'current' : '');
        });

        if (map && window.EM && window.EM.drawRouteMap) {
            map.dataset.vehicle = hasLocation ? data.latitude + ',' + data.longitude : '';
            map.dataset.vehicleToPickup = String(currentOrder >= 0 && currentOrder < PICKED_UP_ORDER);
            window.EM.drawRouteMap(map);
        }
    }

    // "2026-10-03 10:15:02" -> "03 Oct 2026, 10:15 AM"
    function formatTime(value) {
        const d = new Date(value.replace(' ', 'T'));
        if (isNaN(d)) return value;
        return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })
            + ', ' + d.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    }

    let timer = null;
    function poll() {
        fetch(window.APP_CONTEXT + '/api/tracking?bookingId=' + bookingId, { cache: 'no-store' })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.error) update(data);
                if (data.status === 'COMPLETED' || data.status === 'CANCELLED') clearInterval(timer);
            })
            .catch(function () { /* try again next time */ });
    }

    timer = setInterval(poll, 10000);
    poll();
})();
