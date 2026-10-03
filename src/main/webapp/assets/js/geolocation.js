// Fills latitude/longitude fields without any paid map API.
//  - data-geolocate="latId,lngId"        -> browser GPS (navigator.geolocation)
//  - data-lookup="addressId,latId,lngId" -> free OpenStreetMap Nominatim address search
// Messages appear under the button row instead of browser pop-ups.
(function () {
    function note(button, text, isError) {
        const row = button.closest('.button-row') || button.parentElement;
        let el = row.nextElementSibling;
        if (!el || !el.classList.contains('geo-note')) {
            el = document.createElement('p');
            el.className = 'geo-note small';
            el.style.margin = '-8px 0 14px';
            row.after(el);
        }
        el.style.color = isError ? 'var(--red-700)' : 'var(--green-700)';
        el.textContent = text;
    }

    function fill(id, value) {
        const input = document.getElementById(id);
        input.value = value;
        input.dispatchEvent(new Event('input', { bubbles: true }));
    }

    function busy(button, on) {
        button.disabled = on;
        button.classList.toggle('is-loading', on);
    }

    document.querySelectorAll('[data-geolocate]').forEach(function (button) {
        button.addEventListener('click', function () {
            const ids = button.dataset.geolocate.split(',');
            if (!navigator.geolocation) {
                note(button, 'Your browser does not support location. Type the coordinates instead.', true);
                return;
            }
            busy(button, true);
            navigator.geolocation.getCurrentPosition(function (pos) {
                fill(ids[0], pos.coords.latitude.toFixed(6));
                fill(ids[1], pos.coords.longitude.toFixed(6));
                note(button, 'Location filled in from your device.', false);
                busy(button, false);
            }, function (err) {
                note(button, 'Could not get your location (' + err.message + '). Allow location access or type the coordinates.', true);
                busy(button, false);
            }, { enableHighAccuracy: true, timeout: 15000 });
        });
    });

    document.querySelectorAll('[data-lookup]').forEach(function (button) {
        button.addEventListener('click', function () {
            const ids = button.dataset.lookup.split(',');
            const address = document.getElementById(ids[0]).value.trim();
            if (!address) {
                note(button, 'Type an address first.', true);
                return;
            }
            busy(button, true);
            fetch('https://nominatim.openstreetmap.org/search?format=json&limit=1&q=' + encodeURIComponent(address))
                .then(function (r) { return r.json(); })
                .then(function (results) {
                    if (results.length === 0) {
                        note(button, 'Address not found. Try adding the city name, or enter the coordinates yourself.', true);
                        return;
                    }
                    fill(ids[1], parseFloat(results[0].lat).toFixed(6));
                    fill(ids[2], parseFloat(results[0].lon).toFixed(6));
                    note(button, 'Found: ' + results[0].display_name, false);
                })
                .catch(function () {
                    note(button, 'Address search is not reachable right now. Enter the coordinates yourself.', true);
                })
                .finally(function () { busy(button, false); });
        });
    });
})();
