// Fills latitude/longitude fields without any paid map API.
//  - data-geolocate="latId,lngId"        -> browser GPS (navigator.geolocation)
//  - data-lookup="addressId,latId,lngId" -> free OpenStreetMap Nominatim address search
(function () {
    document.querySelectorAll('[data-geolocate]').forEach(function (button) {
        button.addEventListener('click', function () {
            const ids = button.dataset.geolocate.split(',');
            if (!navigator.geolocation) {
                alert('Your browser does not support location.');
                return;
            }
            const label = button.textContent;
            button.disabled = true;
            button.textContent = 'Locating...';
            navigator.geolocation.getCurrentPosition(function (pos) {
                document.getElementById(ids[0]).value = pos.coords.latitude.toFixed(6);
                document.getElementById(ids[1]).value = pos.coords.longitude.toFixed(6);
                button.disabled = false;
                button.textContent = label;
            }, function (err) {
                alert('Could not get your location: ' + err.message);
                button.disabled = false;
                button.textContent = label;
            }, { enableHighAccuracy: true, timeout: 15000 });
        });
    });

    document.querySelectorAll('[data-lookup]').forEach(function (button) {
        button.addEventListener('click', function () {
            const ids = button.dataset.lookup.split(',');
            const address = document.getElementById(ids[0]).value.trim();
            if (!address) {
                alert('Type an address first.');
                return;
            }
            const label = button.textContent;
            button.disabled = true;
            button.textContent = 'Searching...';
            fetch('https://nominatim.openstreetmap.org/search?format=json&limit=1&q=' + encodeURIComponent(address))
                .then(function (r) { return r.json(); })
                .then(function (results) {
                    if (results.length === 0) {
                        alert('Address not found. Try adding the city name, or enter latitude/longitude yourself.');
                        return;
                    }
                    document.getElementById(ids[1]).value = parseFloat(results[0].lat).toFixed(6);
                    document.getElementById(ids[2]).value = parseFloat(results[0].lon).toFixed(6);
                })
                .catch(function () {
                    alert('Address search is not reachable. Enter latitude/longitude yourself.');
                })
                .finally(function () {
                    button.disabled = false;
                    button.textContent = label;
                });
        });
    });
})();
