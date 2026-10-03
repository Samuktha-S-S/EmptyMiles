// Partner side: sends the browser's GPS position to /api/location every few seconds
// while a delivery is active, so it is stored in vehicle_locations.
(function () {
    const box = document.getElementById('location-sharing');
    if (!box) return;

    const vehicleId = box.dataset.vehicleId;
    const bookingId = box.dataset.bookingId;
    const intervalMs = parseInt(box.dataset.interval, 10) * 1000;
    const statusEl = document.getElementById('shareStatus');
    const toggle = document.getElementById('shareToggle');
    const live = document.getElementById('shareLive');
    let timer = null;

    function send() {
        if (!navigator.geolocation) {
            statusEl.textContent = 'This browser does not support location.';
            return;
        }
        navigator.geolocation.getCurrentPosition(function (pos) {
            const body = new URLSearchParams({
                vehicleId: vehicleId,
                bookingId: bookingId,
                latitude: pos.coords.latitude.toFixed(6),
                longitude: pos.coords.longitude.toFixed(6)
            });
            fetch(window.APP_CONTEXT + '/api/location', { method: 'POST', body: body })
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    statusEl.textContent = data.ok
                        ? 'Sent ' + body.get('latitude') + ', ' + body.get('longitude') + ' at ' + new Date().toLocaleTimeString()
                        : 'Error: ' + data.error;
                })
                .catch(function () { statusEl.textContent = 'Could not reach the server, will retry.'; });
        }, function (err) {
            statusEl.textContent = 'Location blocked: ' + err.message + '. Allow location access for this site.';
        }, { enableHighAccuracy: true, timeout: 10000 });
    }

    function start() {
        send();
        timer = setInterval(send, intervalMs);
        toggle.textContent = 'Pause sharing';
        if (live) live.hidden = false;
    }

    function stop() {
        clearInterval(timer);
        timer = null;
        statusEl.textContent = 'Paused';
        toggle.textContent = 'Resume sharing';
        if (live) live.hidden = true;
    }

    toggle.addEventListener('click', function () {
        if (timer) stop(); else start();
    });
    start();
})();
