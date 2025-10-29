import { getDictionary } from "src/decidim/i18n";
import InputDialog from "src/decidim/editor/common/input_dialog";
import { Extension } from "@tiptap/core";

import beautify from "js-beautify";

export default Extension.create({
  name: "html",

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
