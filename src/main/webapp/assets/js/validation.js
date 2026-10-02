// Client-side form checks. The server checks everything again; this only gives faster feedback.
(function () {
    function showError(input, message) {
        input.classList.add('invalid');
        let span = input.parentElement.querySelector('.field-error');
        if (!span) {
            span = document.createElement('span');
            span.className = 'field-error';
            input.parentElement.appendChild(span);
        }
        span.textContent = message;
    }

    function clearError(input) {
        input.classList.remove('invalid');
        const span = input.parentElement.querySelector('.field-error');
        if (span) span.remove();
    }

    document.querySelectorAll('form.validate').forEach(function (form) {
        form.addEventListener('submit', function (event) {
            let ok = true;
            form.querySelectorAll('input, select').forEach(function (input) {
                clearError(input);
                if (input.type === 'hidden' || input.type === 'radio') return;
                if (input.required && !input.value.trim()) {
                    showError(input, 'This field is required');
                    ok = false;
                } else if (!input.checkValidity()) {
                    showError(input, input.validationMessage);
                    ok = false;
                }
                // Confirm password must match the field named in data-match
                if (input.dataset.match) {
                    const other = form.querySelector('[name="' + input.dataset.match + '"]');
                    if (other && other.value !== input.value) {
                        showError(input, 'Passwords do not match');
                        ok = false;
                    }
                }
            });
            if (!ok) event.preventDefault();
        });
    });

    // Vehicle form: suggest a typical capacity when the type changes
    const type = document.getElementById('vehicleType');
    const capacity = document.getElementById('totalCapacity');
    if (type && capacity) {
        type.addEventListener('change', function () {
            capacity.value = type.options[type.selectedIndex].dataset.capacity;
        });
    }
})();
