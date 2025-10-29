document.addEventListener("DOMContentLoaded", () => {
  const master = document.querySelector(".js-check-all");
  const checkboxes = document.querySelectorAll(".js-study-note-checkbox");
  const exportDropdownBtn = document.querySelector("[data-toggle='export-selected-dropdown']");

  const toggleExportDropdown = () => {
    if (!exportDropdownBtn) return;
    const anyChecked = Array.from(checkboxes).some(c => c.checked);
    exportDropdownBtn.style.display = anyChecked ? "inline-block" : "none";
  };

  if (master) {
    master.addEventListener("change", e => {
      checkboxes.forEach(c => {
        c.checked = e.target.checked;
      });
      toggleExportDropdown();
    });
  }

  checkboxes.forEach(cb => cb.addEventListener("change", toggleExportDropdown));

  toggleExportDropdown();

  document.querySelectorAll(".js-export-selected").forEach(link => {
    link.addEventListener("click", e => {
      e.preventDefault();
      const ids = Array.from(document.querySelectorAll(".js-study-note-checkbox:checked")).map(c => c.value);
      if (!ids.length) { alert("Nie zaznaczono żadnych uwag."); return; }

      const basePath = window.location.pathname.split("/study_notes")[0];
      const params = new URLSearchParams();
      ids.forEach(id => params.append("ids[]", id));
      if (link.dataset.anonymized) params.append("anonymized", "true");
      if (link.dataset.with_attachments) params.append("with_attachments", "true");
      if (link.dataset.normalized) params.append("normalized", "true");

      const format = link.dataset.format;
      const url =
          format === "xlsx"
              ? `${basePath}/study_notes/export_selected.xlsx?${params}`
              : `${basePath}/study_notes/export_zip_selected?${params}`;

      window.open(url, "_blank");
    });
  });
});