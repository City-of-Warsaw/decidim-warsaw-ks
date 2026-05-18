import { getDictionary } from "src/decidim/i18n";
import InputDialog from "src/decidim/editor/common/input_dialog";
import { Extension } from "@tiptap/core";

import beautify from "js-beautify";

export default Extension.create({
  name: "html",

  // Preserve common accessibility attributes (ARIA, role, tabindex, lang)
  // for common node types so HTML roundtrip retains a11y attributes.
  addGlobalAttributes() {
    const a11yAttributes = {
      role: {
        default: null,
        parseHTML: (el) => el.getAttribute("role"),
        renderHTML: (attrs) => (attrs.role ? { role: attrs.role } : {}),
      },
      tabindex: {
        default: null,
        parseHTML: (el) => el.getAttribute("tabindex"),
        renderHTML: (attrs) =>
          attrs.tabindex ? { tabindex: attrs.tabindex } : {},
      },
      lang: {
        default: null,
        parseHTML: (el) => el.getAttribute("lang"),
        renderHTML: (attrs) => (attrs.lang ? { lang: attrs.lang } : {}),
      },
      ariaLabel: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-label"),
        renderHTML: (attrs) =>
          attrs.ariaLabel ? { "aria-label": attrs.ariaLabel } : {},
      },
      ariaHidden: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-hidden"),
        renderHTML: (attrs) =>
          attrs.ariaHidden ? { "aria-hidden": attrs.ariaHidden } : {},
      },
      ariaDescribedby: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-describedby"),
        renderHTML: (attrs) =>
          attrs.ariaDescribedby
            ? { "aria-describedby": attrs.ariaDescribedby }
            : {},
      },
      ariaLabelledby: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-labelledby"),
        renderHTML: (attrs) =>
          attrs.ariaLabelledby
            ? { "aria-labelledby": attrs.ariaLabelledby }
            : {},
      },
      ariaControls: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-controls"),
        renderHTML: (attrs) =>
          attrs.ariaControls ? { "aria-controls": attrs.ariaControls } : {},
      },
      ariaExpanded: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-expanded"),
        renderHTML: (attrs) =>
          attrs.ariaExpanded ? { "aria-expanded": attrs.ariaExpanded } : {},
      },
      ariaLive: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-live"),
        renderHTML: (attrs) =>
          attrs.ariaLive ? { "aria-live": attrs.ariaLive } : {},
      },
      ariaPressed: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-pressed"),
        renderHTML: (attrs) =>
          attrs.ariaPressed ? { "aria-pressed": attrs.ariaPressed } : {},
      },
      ariaRoledescription: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-roledescription"),
        renderHTML: (attrs) =>
          attrs.ariaRoledescription
            ? { "aria-roledescription": attrs.ariaRoledescription }
            : {},
      },
      ariaValuemin: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-valuemin"),
        renderHTML: (attrs) =>
          attrs.ariaValuemin ? { "aria-valuemin": attrs.ariaValuemin } : {},
      },
      ariaValuemax: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-valuemax"),
        renderHTML: (attrs) =>
          attrs.ariaValuemax ? { "aria-valuemax": attrs.ariaValuemax } : {},
      },
      ariaValuenow: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-valuenow"),
        renderHTML: (attrs) =>
          attrs.ariaValuenow ? { "aria-valuenow": attrs.ariaValuenow } : {},
      },
      ariaValuetext: {
        default: null,
        parseHTML: (el) => el.getAttribute("aria-valuetext"),
        renderHTML: (attrs) =>
          attrs.ariaValuetext ? { "aria-valuetext": attrs.ariaValuetext } : {},
      },
    };

    // Apply to common block/inline node types provided by starter-kit and table extensions.
    const types = [
      "paragraph",
      "heading",
      "blockquote",
      "listItem",
      "bulletList",
      "orderedList",
      "codeBlock",
      "image",
      "table",
      "tableRow",
      "tableHeader",
      "tableCell",
      "link",
    ];

    return [
      {
        types,
        attributes: a11yAttributes,
      },
    ];
  },
  addCommands() {
    const i18n = getDictionary("editor.extensions.html");

    return {
      htmlDialog:
        () =>
        async ({ dispatch }) => {
          if (dispatch) {
            let html = beautify.html(this.editor.getHTML(), {
              indent_size: "4",
              indent_char: " ",
              max_preserve_newlines: "5",
              preserve_newlines: true,
              keep_array_indentation: false,
              break_chained_methods: false,
              indent_scripts: "normal",
              brace_style: "collapse",
              space_before_conditional: true,
              unescape_strings: false,
              jslint_happy: false,
              end_with_newline: false,
              wrap_line_length: "0",
              indent_inner_html: false,
              comma_first: false,
              e4x: false,
              indent_empty_lines: false,
            });

            const inputs = {
              html: { type: "textarea", label: i18n.htmlLabel },
            };

            const htmlDialog = new InputDialog(this.editor, { inputs });
            const dialogState = await htmlDialog.toggle({ html });
            html = htmlDialog.getValue("html");

            if (dialogState !== "save") {
              this.editor.chain().focus(null, { scrollIntoView: false }).run();
              return false;
            }

            this.editor.commands.setContent(html, true);
            this.editor.chain().focus(null, { scrollIntoView: true }).run();

            return true;
          }

          return true;
        },
    };
  },
});
