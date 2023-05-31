Parchment = Quill.import("parchment");

const DEFAULT_LABEL = "Styl";

function registerQuillStyleToolbarTool() {
  Quill.register(
    new Parchment.Attributor.Class("class", "custom", {
      scope: Parchment.Scope.BLOCK,
    }),
    true
  );
}

function initializeQuillStyleToolbarTool(quill, styles = {}) {
  const flippedStyles = Object.fromEntries(
    Object.entries(styles).map(([k, v]) => [v, k])
  );

  const stylesDropdown = new QuillToolbarDropDown({
    label: DEFAULT_LABEL,
    rememberSelection: true,
  });

  stylesDropdown.setItems(styles);

  stylesDropdown.onSelect = function (label, value, quill) {
    var range = quill.selection.savedRange;
    var format = quill.getFormat(range);

    if (format && format["class"] !== value) {
      quill.format("class", value);
      stylesDropdown.setLabel(label);
      stylesDropdown.dropDownPickerLabelEl.classList.add("ql-active");
    } else {
      quill.removeFormat(range.index, range.index + range.length);
    }
  };

  quill.on("selection-change", (range) => {
    if (range) {
      var format = quill.getFormat(range);

      if (format["class"]) {
        stylesDropdown.setLabel(flippedStyles[format["class"]]);
        stylesDropdown.dropDownPickerLabelEl.classList.add("ql-active");
      } else {
        stylesDropdown.setLabel(DEFAULT_LABEL);
        stylesDropdown.dropDownPickerLabelEl.classList.remove("ql-active");
      }
    }
  });

  const toolbar = quill.getModule("toolbar");
  const styleButton = toolbar.container.querySelector(".ql-style");

  if (styleButton) {
    stylesDropdown.quill = quill;
    styleButton.replaceWith(stylesDropdown.qlFormatsEl);
  }
}
