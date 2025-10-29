import Link from "@tiptap/extension-link";
import { Plugin } from "prosemirror-state";

import { getDictionary } from "src/decidim/i18n";
import InputDialog from "src/decidim/editor/common/input_dialog";
import createBubbleMenu from "src/decidim/editor/extensions/button/bubble_menu";

export default Link.extend({
  name: "button",

  addStorage() {
    return { bubbleMenu: null };
  },

  onCreate() {
    this.parent?.();

    this.storage.bubbleMenu = createBubbleMenu(this.editor);
  },

  onDestroy() {
    this.parent?.();

    this.storage.bubbleMenu.destroy();
    this.storage.bubbleMenu = null;
  },

  addOptions() {
    return {
      ...this.parent?.(),
      allowTargetControl: false,
      linkOnPaste: false,
      autolink: false,
      HTMLAttributes: {
        target: "_blank",
        class: "custom-button",
      },
    };
  },

  addCommands() {
    const i18n = getDictionary("editor.extensions.button");

    return {
      setButton:
        (attributes) =>
        ({ chain }) => {
          return chain()
            .setMark(this.name, attributes)
            .setMeta("preventAutolink", true)
            .run();
        },

      toggleButton:
        (attributes) =>
        ({ chain }) => {
          return chain()
            .toggleMark(this.name, attributes, { extendEmptyMarkRange: true })
            .setMeta("preventAutolink", true)
            .run();
        },

      unsetButton:
        () =>
        ({ chain }) => {
          return chain()
            .unsetMark(this.name, { extendEmptyMarkRange: true })
            .setMeta("preventAutolink", true)
            .run();
        },

      toggleButtonBubble:
        () =>
        ({ dispatch }) => {
          if (dispatch) {
            if (this.editor.isActive("button")) {
              this.storage.bubbleMenu.show();
              return true;
            }

            this.storage.bubbleMenu.hide();
            return false;
          }
          return this.editor.isActive("button");
        },

      buttonDialog:
        () =>
        async ({ dispatch, commands }) => {
          if (dispatch) {
            // If the cursor is within the button but the button is not selected, the
            // button would not be correctly updated. Also if only a part of the
            // button is selected, the button would be split to separate buttons, only
            // the current selection getting the updated button URL.
            commands.extendMarkRange("button");

            this.storage.bubbleMenu.hide();

            const { allowTargetControl } = this.options;

            let { href, target } = this.editor.getAttributes("button");

            const inputs = { href: { type: "text", label: i18n.hrefLabel } };
            if (allowTargetControl) {
              inputs.target = {
                type: "select",
                label: i18n.targetLabel,
                options: [
                  { value: "", label: i18n["targets.default"] },
                  { value: "_blank", label: i18n["targets.blank"] },
                ],
              };
            }

            const buttonDialog = new InputDialog(this.editor, { inputs });
            const dialogState = await buttonDialog.toggle({ href, target });
            href = buttonDialog.getValue("href");
            target = buttonDialog.getValue("target");
            if (!allowTargetControl) {
              target = "_blank";
            } else if (!target || target.length < 1) {
              target = null;
            }

            if (dialogState !== "save") {
              this.editor
                .chain()
                .focus(null, { scrollIntoView: false })
                .toggleButtonBubble()
                .run();
              return false;
            }

            if (!href || href.trim().length < 1) {
              return this.editor
                .chain()
                .focus(null, { scrollIntoView: false })
                .unsetButton()
                .run();
            }

            return this.editor
              .chain()
              .focus(null, { scrollIntoView: false })
              .setButton({ href, target })
              .toggleButtonBubble()
              .run();
          }

          return true;
        },
    };
  },

  addProseMirrorPlugins() {
    const editor = this.editor;

    return [
      ...(this.parent?.() || {}),
      new Plugin({
        props: {
          handleDoubleClick() {
            if (!editor.isActive("button")) {
              return false;
            }

            editor.chain().focus().buttonDialog().run();
            return true;
          },
        },
      }),
    ];
  },

  addPasteRules() {
    return [];
  },

  parseHTML() {
    return [
      {
        tag: "a.custom-button",
      },
    ];
  },
});
