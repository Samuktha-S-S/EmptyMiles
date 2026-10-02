// Customer side: asks /api/tracking for the latest status and position every 10 seconds.
(function () {
    const root = document.getElementById('tracking');
    if (!root) return;
    const bookingId = root.dataset.bookingId;

    function update(data) {
        document.getElementById('statusLabel').textContent = data.statusLabel;
        if (data.latitude !== null) {
            document.getElementById('position').textContent = data.latitude + ', ' + data.longitude;
            const link = document.getElementById('mapLink');
            link.href = 'https://www.openstreetmap.org/?mlat=' + data.latitude + '&mlon=' + data.longitude
                + '#map=15/' + data.latitude + '/' + data.longitude;
            link.hidden = false;
        }
        if (data.distanceToPickupKm !== null) {
            document.getElementById('toPickup').textContent = data.distanceToPickupKm + ' km';
            document.getElementById('toDestination').textContent = data.distanceToDestinationKm + ' km';
        }
        if (data.lastUpdated) {
            document.getElementById('lastUpdated').textContent = data.lastUpdated;
        }
        // Re-colour the status timeline
        const current = document.querySelector('#timeline li[data-status="' + data.status + '"]');
        const currentOrder = current ? parseInt(current.dataset.order, 10) : -1;
        document.querySelectorAll('#timeline li').forEach(function (li) {
            const order = parseInt(li.dataset.order, 10);
            li.className = order < currentOrder ? 'done' : (order === currentOrder ? 'current' : '');
        });
    }

    function poll() {
        fetch(window.APP_CONTEXT + '/api/tracking?bookingId=' + bookingId)
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.error) update(data);
                if (data.status === 'COMPLETED' || data.status === 'CANCELLED') clearInterval(timer);
            })
            .catch(function () { /* try again next time */ });
    }

    const timer = setInterval(poll, 10000);
    poll();
})();
