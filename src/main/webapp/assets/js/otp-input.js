// Delivery verification: one box per OTP digit. Typing moves to the next box, Backspace goes back,
// pasting a whole code fills every box. The digits are joined into the hidden "otp" field.
(function () {
    const form = document.getElementById('otpForm');
    if (!form) return;
    const boxes = Array.from(form.querySelectorAll('#otpBoxes input'));
    const hidden = document.getElementById('otpValue');
    const submit = document.getElementById('otpSubmit');

    function sync() {
        const code = boxes.map(function (b) { return b.value; }).join('');
        hidden.value = code;
        submit.disabled = code.length !== boxes.length;
        form.querySelector('#otpBoxes').classList.remove('has-error', 'shake');
    }

    boxes.forEach(function (box, i) {
        box.addEventListener('input', function () {
            box.value = box.value.replace(/\D/g, '').slice(-1);
            if (box.value && i < boxes.length - 1) boxes[i + 1].focus();
            sync();
        });
        box.addEventListener('keydown', function (e) {
            if (e.key === 'Backspace' && !box.value && i > 0) {
                boxes[i - 1].focus();
                boxes[i - 1].value = '';
                sync();
                e.preventDefault();
            } else if (e.key === 'ArrowLeft' && i > 0) {
                boxes[i - 1].focus();
            } else if (e.key === 'ArrowRight' && i < boxes.length - 1) {
                boxes[i + 1].focus();
            }
        });
        box.addEventListener('focus', function () { box.select(); });
        box.addEventListener('paste', function (e) {
            const digits = (e.clipboardData.getData('text') || '').replace(/\D/g, '').slice(0, boxes.length);
            if (!digits) return;
            e.preventDefault();
            digits.split('').forEach(function (d, j) { boxes[j].value = d; });
            boxes[Math.min(digits.length, boxes.length) - 1].focus();
            sync();
        });
    });
    sync();
})();
