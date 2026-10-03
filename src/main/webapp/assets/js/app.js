// Shared behaviour for every logged-in page: sidebar drawer, loading buttons,
// double-submit protection, modals, confirm dialogs, list sorting and filter tabs.
(function () {
    // ---------- Sidebar drawer (tablet / mobile) ----------
    const app = document.getElementById('app');
    const toggle = document.querySelector('[data-nav-toggle]');
    function setNav(open) {
        if (!app) return;
        app.classList.toggle('nav-open', open);
        if (toggle) toggle.setAttribute('aria-expanded', String(open));
    }
    if (toggle) toggle.addEventListener('click', function () { setNav(!app.classList.contains('nav-open')); });
    document.querySelectorAll('[data-nav-close]').forEach(function (el) {
        el.addEventListener('click', function () { setNav(false); });
    });

    // ---------- Dismissible alerts ----------
    document.querySelectorAll('[data-dismiss]').forEach(function (btn) {
        btn.addEventListener('click', function () { btn.closest('.alert').remove(); });
    });

    // ---------- Loading state + no double submit ----------
    // Runs after every other submit handler (setTimeout), so forms blocked by validation stay usable.
    document.addEventListener('submit', function (event) {
        const form = event.target;
        if (form.dataset.submitting === 'true') {
            event.preventDefault();
            return;
        }
        const submitter = event.submitter;
        setTimeout(function () {
            if (event.defaultPrevented) return;
            form.dataset.submitting = 'true';
            form.querySelectorAll('button[type=submit], button:not([type])').forEach(function (b) {
                b.disabled = true;
            });
            const shown = submitter || form.querySelector('button[type=submit], button:not([type])');
            if (shown) shown.classList.add('is-loading');
            // Buttons outside the form that submit it (modals) show the spinner too
            if (form.id) {
                document.querySelectorAll('[form="' + form.id + '"]').forEach(function (b) {
                    b.disabled = true;
                    b.classList.add('is-loading');
                });
            }
        }, 0);
    });
    // Back/forward cache: re-enable buttons when the page is shown again
    window.addEventListener('pageshow', function (e) {
        if (!e.persisted) return;
        document.querySelectorAll('form[data-submitting]').forEach(function (f) { delete f.dataset.submitting; });
        document.querySelectorAll('.is-loading').forEach(function (b) { b.classList.remove('is-loading'); b.disabled = false; });
    });

    // Links that start a slow page (e.g. running the matching engine) show a spinner
    document.querySelectorAll('a[data-loading]').forEach(function (a) {
        a.addEventListener('click', function () {
            (a.classList.contains('btn') ? a : (a.querySelector('.btn') || a)).classList.add('is-loading');
        });
    });

    // ---------- Modals ----------
    let lastFocus = null;
    function openModal(modal) {
        lastFocus = document.activeElement;
        modal.classList.add('is-open');
        document.body.classList.add('modal-open');
        const focusable = modal.querySelector('[data-autofocus]') || modal.querySelector('button, [href], input');
        if (focusable) focusable.focus();
    }
    function closeModal(modal) {
        if (modal.querySelector('.is-loading')) return;   // a request is on its way
        modal.classList.remove('is-open');
        document.body.classList.remove('modal-open');
        if (lastFocus) lastFocus.focus();
    }
    window.EM = window.EM || {};
    window.EM.openModal = openModal;
    window.EM.closeModal = closeModal;

    document.querySelectorAll('.modal').forEach(function (modal) {
        modal.addEventListener('click', function (e) {
            if (e.target === modal || e.target.closest('[data-modal-close]')) closeModal(modal);
        });
    });
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape') return;
        const open = document.querySelector('.modal.is-open');
        if (open) closeModal(open);
        else setNav(false);
    });
    document.querySelectorAll('[data-modal-open]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            const modal = document.getElementById(btn.dataset.modalOpen);
            if (modal) openModal(modal);
        });
    });

    // Generic confirm: <button data-confirm="Reject this request?" data-confirm-text="..." data-confirm-ok="Reject" data-confirm-tone="danger">
    const confirmModal = document.getElementById('confirmModal');
    let pending = null;
    document.querySelectorAll('[data-confirm]').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            if (!confirmModal) return;
            e.preventDefault();
            pending = btn;
            confirmModal.querySelector('[data-confirm-title]').textContent = btn.dataset.confirm;
            confirmModal.querySelector('[data-confirm-body]').textContent = btn.dataset.confirmText || '';
            const ok = confirmModal.querySelector('[data-confirm-ok]');
            ok.textContent = btn.dataset.confirmOk || 'Confirm';
            ok.className = 'btn ' + (btn.dataset.confirmTone === 'danger' ? 'btn-danger-solid' : 'btn-primary');
            openModal(confirmModal);
        });
    });
    if (confirmModal) {
        confirmModal.querySelector('[data-confirm-ok]').addEventListener('click', function () {
            if (!pending) return;
            const ok = this;
            ok.classList.add('is-loading');
            ok.disabled = true;
            pending.form.requestSubmit(pending);   // keeps the button's name/value (e.g. action=reject)
        });
    }

    // ---------- Sorting cards: <div data-sort-list> children with data-score/... ----------
    document.querySelectorAll('[data-sort-for]').forEach(function (group) {
        const list = document.getElementById(group.dataset.sortFor);
        group.querySelectorAll('[data-sort]').forEach(function (chip) {
            chip.addEventListener('click', function () {
                const key = chip.dataset.sort;
                const dir = chip.dataset.dir === 'asc' ? 1 : -1;
                const items = Array.from(list.children);
                items.sort(function (a, b) {
                    return dir * (parseFloat(a.dataset[key]) - parseFloat(b.dataset[key]));
                });
                items.forEach(function (el) { list.appendChild(el); });
                group.querySelectorAll('[data-sort]').forEach(function (c) { c.setAttribute('aria-pressed', String(c === chip)); });
            });
        });
    });

    // ---------- Filter tabs: <button data-filter="pending" data-filter-for="tableId"> ----------
    document.querySelectorAll('[data-filter-group]').forEach(function (group) {
        const target = document.getElementById(group.dataset.filterGroup);
        const empty = document.getElementById(group.dataset.filterGroup + 'Empty');
        group.querySelectorAll('[data-filter]').forEach(function (tab) {
            tab.addEventListener('click', function () {
                const f = tab.dataset.filter;
                let shown = 0;
                target.querySelectorAll('[data-group]').forEach(function (row) {
                    const match = f === 'all' || row.dataset.group.split(' ').indexOf(f) >= 0;
                    row.hidden = !match;
                    if (match) shown++;
                });
                if (empty) empty.hidden = shown > 0;
                group.querySelectorAll('[data-filter]').forEach(function (t) { t.classList.toggle('is-active', t === tab); });
            });
        });
    });

    // ---------- Greeting by the viewer's local time ----------
    document.querySelectorAll('[data-greeting]').forEach(function (el) {
        const h = new Date().getHours();
        el.textContent = h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
    });
})();
