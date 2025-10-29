// modified version of https://github.com/sereneinserenade/tiptap-extension-video/blob/main/src/extensions/video.ts

import { Node, nodeInputRule } from "@tiptap/core";

import { getDictionary } from "src/decidim/i18n";
import InputDialog from "src/decidim/editor/common/input_dialog";

const VIDEO_INPUT_REGEX = /!\[(.+|:?)]\((\S+)(?:(?:\s+)["'](\S+)["'])?\)/;

export default Node.create({
  name: "video",

  group: "block",

  addAttributes() {
    return {
      src: {
        default: null,
        parseHTML: (el) => el.getAttribute("src"),
        renderHTML: (attrs) => ({ src: attrs.src }),
      },
    };
  },

  parseHTML() {
    return [
      {
        tag: "video",
        getAttrs: (el) => ({ src: el.getAttribute("src") }),
      },
    ];
  },

  renderHTML({ HTMLAttributes }) {
    return [
      "video",
      { controls: "true", style: "width: 100%", ...HTMLAttributes },
      ["source", HTMLAttributes],
    ];
  },

  addCommands() {
    const i18n = getDictionary("editor.extensions.video");

    return {
      setVideoBlock:
        (src) =>
        ({ commands }) =>
          commands.insertContent(
            `<video controls="true" style="width: 100%" src="${src}" />`
          ),

      toggleVideo:
        () =>
        ({ commands }) =>
          commands.toggleNode(this.name, "paragraph"),

      videoDialog:
        () =>
        async ({ dispatch }) => {
          if (dispatch) {
            const videoDialog = new InputDialog(this.editor, {
              inputs: {
                src: { type: "text", label: i18n.urlLabel },
              },
            });
            let { src } = this.editor.getAttributes("video");

            const dialogState = await videoDialog.toggle({ src });
            if (dialogState !== "save") {
              return false;
            }

            src = videoDialog.getValue("src");
            if (!src || src.length < 1) {
              this.editor.commands.focus(null, { scrollIntoView: false });
              return false;
            }

            return this.editor
              .chain()
              .setVideoBlock(src)
              .focus(null, { scrollIntoView: false })
              .run();
          }

          return true;
        },
    };
  },

  addInputRules() {
    return [
      nodeInputRule({
        find: VIDEO_INPUT_REGEX,
        type: this.type,
        getAttributes: (match) => {
          const [, , src] = match;

          return { src };
        },
      }),
    ];
  },
});
