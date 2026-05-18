document.addEventListener("DOMContentLoaded", () => {
    const master = document.querySelector(".js-check-all");
    const checkboxes = document.querySelectorAll(".js-answer-checkbox");
    if (master) {
        master.addEventListener("change", e => {
            checkboxes.forEach(c => (c.checked = e.target.checked));
        });
    }

    document.querySelectorAll(".js-accept-selected").forEach(link => {
        link.addEventListener("click", async e => {
            e.preventDefault();

            const ids = Array.from(document.querySelectorAll(".js-answer-checkbox:checked")).map(c => c.value);
            const basePath = window.location.pathname
            const url = `${basePath}/mark_as_accepted`;
            const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
            const response = await fetch(url, {
                method: "PATCH",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": csrfToken
                },
                body: JSON.stringify({ ids })
            });

            if (response.ok) {
                window.location.replace(basePath);
            } else {
                alert("Błąd przy akceptacji rozstrzygnięć.");
            }
        });
    });

    document.querySelectorAll(".js-update-ai-decision-selected").forEach(link => {
        link.addEventListener("click", async e => {
            e.preventDefault();

            const ids = Array.from(document.querySelectorAll(".js-answer-checkbox:checked")).map(c => c.value);
            const basePath = window.location.pathname
            const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
            const params = new URLSearchParams();
            ids.forEach(id => params.append("ids[]", id));
            const urlWithParams = `${basePath}/init_ai_decision_form?${params}`;
            const response = await fetch(urlWithParams, {
                method: "GET",
                headers: { "X-CSRF-Token": csrfToken }
            });

            if (response.ok) {
                window.location.href = urlWithParams;
            } else {
                alert("Błąd przy akceptacji rozstrzygnięć.");
            }
        });
    });
});