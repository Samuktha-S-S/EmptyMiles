// Client-side form checks. The server checks everything again; this only gives faster feedback.
(function () {
    // Errors go at the end of the input's .field wrapper (or its parent when there is none)
    function holder(input) {
        return input.closest('.field') || input.parentElement;
    }

    function showError(input, message) {
        input.classList.add('invalid');
        let span = holder(input).querySelector('.field-error');
        if (!span) {
            span = document.createElement('span');
            span.className = 'field-error';
            holder(input).appendChild(span);
        }
        span.textContent = message;
    }

    function clearError(input) {
        input.classList.remove('invalid');
        const span = holder(input).querySelector('.field-error');
        if (span) span.remove();
    }

    // Shared with shipment-wizard.js, which checks one step at a time
    window.EM = window.EM || {};
    window.EM.validateFields = function (fields) {
        let ok = true;
        fields.forEach(function (input) {
            clearError(input);
            if (input.type === 'hidden' || input.type === 'radio' || input.disabled) return;
            if (input.required && !input.value.trim()) {
                showError(input, 'This field is required');
                ok = false;
            } else if (!input.checkValidity()) {
                showError(input, input.validationMessage);
                ok = false;
            }
        });
        return ok;
    };

    document.querySelectorAll('form.validate').forEach(function (form) {
        form.addEventListener('submit', function (event) {
            let ok = true;
            form.querySelectorAll('input, select, textarea').forEach(function (input) {
                clearError(input);
                if (input.type === 'hidden' || input.type === 'radio' || input.disabled) return;
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
