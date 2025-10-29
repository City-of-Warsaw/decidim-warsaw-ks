import { getDictionary } from "src/decidim/i18n";
import html from "src/decidim/editor/utilities/html";

import iconsUrl from "images/decidim/remixicon.symbol.svg";

const createIcon = (iconName) => {
  return `<svg class="editor-toolbar-icon" role="img" aria-hidden="true">
    <use href="${iconsUrl}#ri-${iconName}" />
  </svg>`;
};

const createEditorToolbarGroup = (editor, secondary = false) => {
  return html("div").dom((el) => {
    el.classList.add("editor-toolbar-group");

    if (secondary) {
      el.classList.add("editor-toolbar-group--secondary");
    }
  });
};

const createEditorToolbarToggle = (
  editor,
  { type, label, icon, action, activatable = true }
) => {
  return html("button").dom((ctrl) => {
    ctrl.classList.add("editor-toolbar-control");
    ctrl.dataset.editorType = type;
    if (activatable) {
      ctrl.dataset.editorSelectionType = type;
    }
    ctrl.type = "button";
    ctrl.ariaLabel = label;
    ctrl.title = label;
    ctrl.innerHTML = createIcon(icon);
    ctrl.addEventListener("click", (ev) => {
      ev.preventDefault();
      editor.commands.focus();
      action();
    });
  });
};

const createEditorToolbarSelect = (
  editor,
  { type, label, options, action, activatable = true }
) => {
  return html("select").dom((ctrl) => {
    ctrl.classList.add("editor-toolbar-control", "!pr-8");
    ctrl.dataset.editorType = type;
    if (activatable) {
      ctrl.dataset.editorSelectionType = type;
    }
    ctrl.ariaLabel = label;
    ctrl.title = label;
    options.forEach(({ label: optionLabel, value }) => {
      const option = document.createElement("option");
      option.setAttribute("value", value);
      option.textContent = optionLabel;
      if (value === null) {
        option.disabled = true;
        option.selected = true;
      }
      ctrl.appendChild(option);
    });
    ctrl.addEventListener("focus", () => {
      ctrl.selectedIndex = 0;
    });
    ctrl.addEventListener("change", () => {
      editor.commands.focus();
      action(ctrl.value);
    });
  });
};

/**
 * Creates the editor toolbar for the given editor instance.
 *
 * @param {Editor} editor An instance of the rich text editor.
 * @returns {HTMLElement} The toolbar element
 */
export default function createEditorToolbar(editor) {
  const i18n = getDictionary("editor.toolbar");

  const supported = { nodes: [], marks: [], extensions: [] };
  editor.extensionManager.extensions.forEach((ext) => {
    if (ext.type === "node") {
      supported.nodes.push(ext.name);
    } else if (ext.type === "mark") {
      supported.marks.push(ext.name);
    } else if (ext.type === "extension") {
      supported.extensions.push(ext.name);
    }
  });

  // Create the toolbar element
  const toolbar = html("div")
    .dom((el) => el.classList.add("editor-toolbar"))
    .append(
      // Text style controls
      createEditorToolbarGroup(editor).append(
        createEditorToolbarSelect(editor, {
          type: "heading",
          label: i18n["control.heading"],
          options: [
            { value: "normal", label: i18n["textStyle.normal"] },
            {
              value: 1,
              label: i18n["textStyle.heading"].replace("%level%", 1),
            },
            {
              value: 2,
              label: i18n["textStyle.heading"].replace("%level%", 2),
            },
            {
              value: 3,
              label: i18n["textStyle.heading"].replace("%level%", 3),
            },
            {
              value: 4,
              label: i18n["textStyle.heading"].replace("%level%", 4),
            },
            {
              value: 5,
              label: i18n["textStyle.heading"].replace("%level%", 5),
            },
            {
              value: 6,
              label: i18n["textStyle.heading"].replace("%level%", 6),
            },
          ],
          action: (value) => {
            if (value === "normal") {
              editor.commands.setParagraph();
            } else {
              editor.commands.toggleHeading({ level: parseInt(value, 10) });
            }
          },
        }).render(supported.nodes.includes("heading")),
        createEditorToolbarSelect(editor, {
          type: "customStyle",
          label: i18n["control.customStyle.name"],
          options: [
            { value: null, label: i18n["control.customStyle.default"] },
            {
              value: "area-color-headline",
              label: i18n["control.customStyle.areaHeadline"],
            },
            {
              value: "custom-legal-basis",
              label: i18n["control.customStyle.legalBasis"],
            },
            {
              value: "custom-text-wrap-image",
              label: i18n["control.customStyle.textWrapImage"],
            },
          ],
          action: (value) => editor.commands.toggleClassName(value),
        }).render(supported.nodes.includes("paragraph"))
      )
    )
    .append(
      // Basic styling controls
      createEditorToolbarGroup(editor).append(
        createEditorToolbarToggle(editor, {
          type: "bold",
          icon: "bold",
          label: i18n["control.bold"],
          action: () => editor.commands.toggleBold(),
        }).render(supported.marks.includes("bold")),
        createEditorToolbarToggle(editor, {
          type: "italic",
          icon: "italic",
          label: i18n["control.italic"],
          action: () => editor.commands.toggleItalic(),
        }).render(supported.marks.includes("italic")),
        createEditorToolbarToggle(editor, {
          type: "underline",
          icon: "underline",
          label: i18n["control.underline"],
          action: () => editor.commands.toggleUnderline(),
        }).render(supported.marks.includes("underline")),
        createEditorToolbarToggle(editor, {
          type: "strike",
          icon: "strikethrough",
          label: i18n["control.strike"],
          action: () => editor.commands.toggleStrike(),
        }).render(supported.marks.includes("strike")),
        createEditorToolbarToggle(editor, {
          type: "subscript",
          icon: "subscript-2",
          label: i18n["control.subscript"],
          action: () => editor.commands.toggleSubscript(),
        }).render(supported.marks.includes("subscript")),
        createEditorToolbarToggle(editor, {
          type: "superscript",
          icon: "superscript-2",
          label: i18n["control.superscript"],
          action: () => editor.commands.toggleSuperscript(),
        }).render(supported.marks.includes("superscript")),
        createEditorToolbarToggle(editor, {
          type: "hardBreak",
          icon: "text-wrap",
          label: i18n["control.hardBreak"],
          activatable: false,
          action: () => editor.commands.setHardBreak(),
        }).render(supported.nodes.includes("hardBreak"))
      )
    )
    .append(
      // Text alignment controls
      createEditorToolbarGroup(editor).append(
        createEditorToolbarToggle(editor, {
          type: "textAlignLeft",
          icon: "align-left",
          label: i18n["control.textAlignLeft"],
          action: () => editor.commands.setTextAlign("left"),
        }),
        createEditorToolbarToggle(editor, {
          type: "textAlignCenter",
          icon: "align-center",
          label: i18n["control.textAlignCenter"],
          action: () => editor.commands.setTextAlign("center"),
        }),
        createEditorToolbarToggle(editor, {
          type: "textAlignRight",
          icon: "align-right",
          label: i18n["control.textAlignRight"],
          action: () => editor.commands.setTextAlign("right"),
        }),
        createEditorToolbarToggle(editor, {
          type: "textAlignJustify",
          icon: "align-justify",
          label: i18n["control.textAlignJustify"],
          action: () => editor.commands.setTextAlign("justify"),
        })
      )
    )
    .append(
      // List controls
      createEditorToolbarGroup(editor).append(
        createEditorToolbarToggle(editor, {
          type: "orderedList",
          icon: "list-ordered",
          label: i18n["control.orderedList"],
          action: () => editor.commands.toggleOrderedList(),
        }).render(supported.nodes.includes("orderedList")),
        createEditorToolbarToggle(editor, {
          type: "bulletList",
          icon: "list-unordered",
          label: i18n["control.bulletList"],
          action: () => editor.commands.toggleBulletList(),
        }).render(supported.nodes.includes("bulletList"))
      )
    )
    .append(
      // Link and erase styles
      createEditorToolbarGroup(editor).append(
        createEditorToolbarToggle(editor, {
          type: "link",
          icon: "link",
          label: i18n["control.link"],
          action: () => editor.commands.linkDialog(),
        }).render(supported.marks.includes("link")),
        createEditorToolbarToggle(editor, {
          type: "button",
          icon: "button",
          label: i18n["control.button"],
          action: () => editor.commands.buttonDialog(),
        }).render(supported.marks.includes("link")),
        createEditorToolbarToggle(editor, {
          type: "common:eraseStyles",
          icon: "eraser-line",
          label: i18n["control.common.eraseStyles"],
          activatable: false,
          action: () => {
            if (editor.isActive("link") && editor.view.state.selection.empty) {
              const originalPos = editor.view.state.selection.anchor;
              editor
                .chain()
                .focus()
                .extendMarkRange("link")
                .unsetLink()
                .setTextSelection(originalPos)
                .run();
            } else {
              editor.chain().focus().clearNodes().unsetAllMarks().run();
            }
          },
        }).render(
          supported.nodes.includes("heading") ||
            supported.marks.includes("bold") ||
            supported.marks.includes("italic") ||
            supported.marks.includes("underline") ||
            supported.nodes.includes("hardBreak") ||
            supported.nodes.includes("orderedList") ||
            supported.nodes.includes("bulletList") ||
            supported.marks.includes("link")
        )
      )
    )
    .append(
      // Undo and redo
      createEditorToolbarGroup(editor).append(
        createEditorToolbarToggle(editor, {
          type: "undo",
          icon: "arrow-go-back-line",
          label: i18n["control.undo"],
          action: () => editor.commands.undo(),
        }),
        createEditorToolbarToggle(editor, {
          type: "redo",
          icon: "arrow-go-forward-line",
          label: i18n["control.redo"],
          action: () => editor.commands.redo(),
        })
      )
    )
    .append(
      // Block styling
      createEditorToolbarGroup(editor).append(
        createEditorToolbarToggle(editor, {
          type: "codeBlock",
          icon: "code-line",
          label: i18n["control.codeBlock"],
          action: () => editor.commands.toggleCodeBlock(),
        }).render(supported.nodes.includes("codeBlock")),
        createEditorToolbarToggle(editor, {
          type: "blockquote",
          icon: "double-quotes-l",
          label: i18n["control.blockquote"],
          action: () => editor.commands.toggleBlockquote(),
        }).render(supported.nodes.includes("blockquote"))
      )
    )
    .append(
      // Indent and outdent
      createEditorToolbarGroup(editor).append(
        createEditorToolbarToggle(editor, {
          type: "indent:indent",
          icon: "indent-increase",
          label: i18n["control.indent.indent"],
          activatable: false,
          action: () => editor.commands.indent(),
        }).render(supported.extensions.includes("indent")),
        createEditorToolbarToggle(editor, {
          type: "indent:outdent",
          icon: "indent-decrease",
          label: i18n["control.indent.outdent"],
          activatable: false,
          action: () => editor.commands.outdent(),
        }).render(supported.extensions.includes("indent"))
      )
    )
    .append(
      // Multimedia
      createEditorToolbarGroup(editor).append(
        createEditorToolbarToggle(editor, {
          type: "videoEmbed",
          icon: "video-add-line",
          label: i18n["control.videoEmbed"],
          action: () => editor.commands.videoEmbedDialog(),
        }).render(supported.nodes.includes("videoEmbed")),
        createEditorToolbarToggle(editor, {
          type: "video",
          icon: "video-line",
          label: i18n["control.video"],
          action: () => editor.commands.videoDialog(),
        }).render(supported.nodes.includes("video")),
        createEditorToolbarToggle(editor, {
          type: "image",
          icon: "image-line",
          label: i18n["control.image"],
          action: () => editor.commands.imageDialog(),
        }).render(supported.nodes.includes("image")),
        createEditorToolbarToggle(editor, {
          type: "imageRepository",
          icon: "folder-image-line",
          label: i18n["control.imageRepository"],
          action: () => editor.commands.imageRepositoryDialog(),
        })
      )
    )
    .append(
      // Other
      createEditorToolbarGroup(editor).append(
        createEditorToolbarToggle(editor, {
          type: "horizontalRule",
          icon: "horizontal-rule",
          label: i18n["control.horizontalRule"],
          action: () => editor.commands.setHorizontalRule(),
        }).render(supported.nodes.includes("horizontalRule"))
      )
    )
    .append(
      // Table actions
      createEditorToolbarGroup(editor, true).append(
        createEditorToolbarToggle(editor, {
          type: "table",
          icon: "table",
          label: i18n["control.table"],
          action: () =>
            editor.commands.insertTable({
              rows: 3,
              cols: 3,
              withHeaderRow: true,
            }),
        }).render(supported.nodes.includes("table")),
        createEditorToolbarToggle(editor, {
          type: "tableAddColumnBefore",
          icon: "insert-column-left",
          label: i18n["control.tableAddColumnBefore"],
          action: () => editor.commands.addColumnBefore(),
        }).render(supported.nodes.includes("table")),
        createEditorToolbarToggle(editor, {
          type: "tableAddColumnAfter",
          icon: "insert-column-right",
          label: i18n["control.tableAddColumnAfter"],
          action: () => editor.commands.addColumnAfter(),
        }).render(supported.nodes.includes("table")),
        createEditorToolbarToggle(editor, {
          type: "tableAddRowBefore",
          icon: "insert-row-top",
          label: i18n["control.tableAddRowBefore"],
          action: () => editor.commands.addRowBefore(),
        }).render(supported.nodes.includes("table")),
        createEditorToolbarToggle(editor, {
          type: "tableAddRowAfter",
          icon: "insert-row-bottom",
          label: i18n["control.tableAddRowAfter"],
          action: () => editor.commands.addRowAfter(),
        }).render(supported.nodes.includes("table")),
        createEditorToolbarToggle(editor, {
          type: "tableDeleteColumn",
          icon: "delete-column",
          label: i18n["control.tableDeleteColumn"],
          action: () => editor.commands.deleteColumn(),
        }).render(supported.nodes.includes("table")),
        createEditorToolbarToggle(editor, {
          type: "tableDeleteRow",
          icon: "delete-row",
          label: i18n["control.tableDeleteRow"],
          action: () => editor.commands.deleteRow(),
        }).render(supported.nodes.includes("table")),
        createEditorToolbarToggle(editor, {
          type: "tableDeleteTable",
          icon: "delete-bin-5-line",
          label: i18n["control.tableDeleteTable"],
          action: () => editor.commands.deleteTable(),
        }).render(supported.nodes.includes("table")),
        createEditorToolbarToggle(editor, {
          type: "tableMergeCells",
          icon: "merge-cells-horizontal",
          label: i18n["control.tableMergeCells"],
          action: () => editor.commands.mergeCells(),
        }).render(supported.nodes.includes("table")),
        createEditorToolbarToggle(editor, {
          type: "tableSplitCell",
          icon: "split-cells-horizontal",
          label: i18n["control.tableSplitCell"],
          action: () => editor.commands.splitCell(),
        }).render(supported.nodes.includes("table"))
      )
    )
    .append(
      // HTML
      createEditorToolbarGroup(editor).append(
        createEditorToolbarToggle(editor, {
          type: "html",
          icon: "code-box-line",
          label: i18n["control.html"],
          action: () => editor.commands.htmlDialog(),
        })
      )
    )
    .render();
  const selectionControls = toolbar.querySelectorAll(
    ".editor-toolbar-control[data-editor-selection-type]"
  );
  const headingSelect = toolbar.querySelector(
    ".editor-toolbar-control[data-editor-type='heading']"
  );
  const customStyleSelect = toolbar.querySelector(
    ".editor-toolbar-control[data-editor-type='customStyle']"
  );
  const selectionUpdated = () => {
    if (editor.isActive("heading")) {
      const { level } = editor.getAttributes("heading");
      headingSelect.value = `${level}`;
    } else if (headingSelect) {
      headingSelect.value = "normal";
    }

    if (customStyleSelect) {
      const currentNodeAttrs = editor.isActive("heading")
        ? editor.getAttributes("heading")
        : editor.getAttributes("paragraph");

      const className = currentNodeAttrs?.class;
      if (className) {
        customStyleSelect.value = className;
      } else {
        customStyleSelect.value = null;
      }
    }

    selectionControls.forEach((ctrl) => {
      if (editor.isActive(ctrl.dataset.editorSelectionType)) {
        ctrl.classList.add("active");
      } else {
        ctrl.classList.remove("active");
      }
    });
  };
  editor.on("update", selectionUpdated);
  editor.on("selectionUpdate", selectionUpdated);

  return toolbar;
}
