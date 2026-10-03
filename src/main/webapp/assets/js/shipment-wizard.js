// Send Goods: shows the form one step at a time (Package, Route, Schedule, Review).
// Everything stays in one <form>, which is posted to the existing CreateShipmentServlet at the end.
(function () {
    const form = document.getElementById('shipmentForm');
    if (!form) return;

    const panels = Array.from(form.querySelectorAll('[data-step]'));
    const tabs = Array.from(form.querySelectorAll('[data-step-tab]'));
    const prev = form.querySelector('[data-prev]');
    const next = form.querySelector('[data-next]');
    const submit = form.querySelector('[data-submit]');
    const hint = form.querySelector('[data-step-hint]');
    const last = panels.length;
    let current = 1;
    let reached = 1;

    function field(name) { return form.elements[name]; }
    function val(name) {
        const f = field(name);
        if (!f) return '';
        if (f instanceof RadioNodeList) return f.value || '';
        return (f.value || '').trim();
    }
    function fieldsOf(panel) { return Array.from(panel.querySelectorAll('input, select, textarea')); }

    function show(step) {
        current = step;
        reached = Math.max(reached, step);
        panels.forEach(function (p) { p.classList.toggle('is-active', Number(p.dataset.step) === step); });
        tabs.forEach(function (t) {
            const n = Number(t.dataset.stepTab);
            t.classList.toggle('is-current', n === step);
            t.classList.toggle('is-done', n < step || (n <= reached && n !== step));
            t.setAttribute('aria-current', n === step ? 'step' : 'false');
        });
        prev.hidden = step === 1;
        next.hidden = step === last;
        submit.hidden = step !== last;
        hint.textContent = 'Step ' + step + ' of ' + last;
        if (step === 2) updateMaps();
        if (step === last) fillReview();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function validStep(step) {
        const panel = panels[step - 1];
        return !window.EM || !window.EM.validateFields || window.EM.validateFields(fieldsOf(panel));
    }

    next.addEventListener('click', function () {
        if (validStep(current)) show(current + 1);
    });
    prev.addEventListener('click', function () { show(current - 1); });
    tabs.forEach(function (t) {
        t.addEventListener('click', function () {
            const n = Number(t.dataset.stepTab);
            if (n < current || n <= reached) show(n);
        });
    });
    form.querySelectorAll('[data-goto]').forEach(function (b) {
        b.addEventListener('click', function () { show(Number(b.dataset.goto)); });
    });

    // Final check: if a field is wrong, jump to its step instead of submitting
    form.addEventListener('submit', function (e) {
        for (let s = 1; s <= last; s++) {
            if (!validStep(s)) {
                e.preventDefault();
                e.stopImmediatePropagation();
                show(s);
                return;
            }
        }
    }, true);

    // Enter in a text field moves to the next step rather than submitting early
    form.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' && e.target.tagName === 'INPUT' && current < last) {
            e.preventDefault();
            next.click();
        }
    });

    // ---------- Route preview ----------
    const maps = [document.getElementById('routePreview'), document.getElementById('routeReview')];
    function point(lat, lng) {
        const a = parseFloat(val(lat)), b = parseFloat(val(lng));
        return isNaN(a) || isNaN(b) ? '' : a + ',' + b;
    }
    function updateMaps() {
        maps.forEach(function (m) {
            if (!m || !window.EM || !window.EM.drawRouteMap) return;
            m.dataset.pickup = point('pickupLatitude', 'pickupLongitude');
            m.dataset.dest = point('destinationLatitude', 'destinationLongitude');
            m.dataset.pickupLabel = val('pickupAddress') || 'Pickup';
            m.dataset.destLabel = val('destinationAddress') || 'Destination';
            if (m.offsetParent !== null) window.EM.drawRouteMap(m);
        });
    }
    ['pickupAddress', 'pickupLatitude', 'pickupLongitude', 'destinationAddress', 'destinationLatitude', 'destinationLongitude']
        .forEach(function (n) {
            const f = field(n);
            if (f) { f.addEventListener('input', updateMaps); f.addEventListener('change', updateMaps); }
        });

    // ---------- Review ----------
    function fmtNum(v) { const n = parseFloat(v); return isNaN(n) ? v : String(Math.round(n * 100) / 100); }
    function setReview(key, text) { form.querySelector('[data-review="' + key + '"]').textContent = text; }
    function fillReview() {
        setReview('package', val('productName') + ' × ' + val('quantity'));
        let meta = fmtNum(val('weight')) + ' kg · ' + val('productType');
        if (val('lengthCm') && val('widthCm') && val('heightCm')) {
            meta += ' · ' + fmtNum(val('lengthCm')) + ' × ' + fmtNum(val('widthCm')) + ' × ' + fmtNum(val('heightCm')) + ' cm';
        }
        if (val('specialRequirements')) meta += ' · ' + val('specialRequirements');
        setReview('packageMeta', meta);
        setReview('pickup', val('pickupAddress'));
        setReview('destination', val('destinationAddress'));
        let date = 'Flexible';
        if (val('pickupDate')) {
            const d = new Date(val('pickupDate') + 'T00:00:00');
            date = d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
        }
        if (val('pickupTimeSlot')) date += ', ' + val('pickupTimeSlot');
        setReview('date', date);
        setReview('instructions', val('specialInstructions') || 'No special instructions');
        updateMaps();
    }

    // ---------- Small helpers ----------
    const date = document.getElementById('pickupDate');
    if (date) {
        const t = new Date();
        date.min = t.getFullYear() + '-' + String(t.getMonth() + 1).padStart(2, '0') + '-' + String(t.getDate()).padStart(2, '0');
    }
    form.querySelectorAll('[data-append-to]').forEach(function (group) {
        const input = document.getElementById(group.dataset.appendTo);
        group.querySelectorAll('.chip').forEach(function (chip) {
            chip.addEventListener('click', function () {
                const parts = input.value.split(',').map(function (s) { return s.trim(); }).filter(Boolean);
                const i = parts.indexOf(chip.textContent);
                if (i >= 0) parts.splice(i, 1); else parts.push(chip.textContent);
                input.value = parts.join(', ');
                syncChips();
            });
        });
        function syncChips() {
            const parts = input.value.split(',').map(function (s) { return s.trim(); });
            group.querySelectorAll('.chip').forEach(function (c) { c.setAttribute('aria-pressed', String(parts.indexOf(c.textContent) >= 0)); });
        }
        input.addEventListener('input', syncChips);
        syncChips();
    });

    const start = Math.min(Math.max(parseInt(form.dataset.startStep, 10) || 1, 1), last);
    reached = start;
    show(start);
})();
