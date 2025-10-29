import { mergeAttributes } from "@tiptap/core";
import Image from "@tiptap/extension-image";
import { Plugin } from "prosemirror-state";

import { getDictionary } from "src/decidim/i18n";
import { fileNameToTitle } from "src/decidim/editor/utilities/file";
import createNodeView from "src/decidim/editor/extensions/image_repository/node_view";
import IframeDialog from "src/decidim/editor/common/iframe_dialog";

/**
 * Handles the image uploads through ActiveStorage when they are dropped or
 * pasted to the editor.
 *
 * Paste and drop handling based on:
 * https://gist.github.com/slava-vishnyakov/16076dff1a77ddaca93c4bccd4ec4521
 */
export default Image.extend({
  addOptions() {
    return {
      ...this.parent?.(),
      iframeSourceUrl: "",
    };
  },

  addCommands() {
    return {
      ...this.parent?.(),

      imageRepositoryDialog: () => async () => {
        const { iframeSourceUrl } = this.options;

        const imageRepositoryDialog = new IframeDialog(this.editor, {
          iframeSourceUrl,
          onMessage: (event) => {
            if (!event.data || !event.data.type) {
              return;
            }

            const { type, url, alt, mimetype } = event.data;

            if (type === "image") {
              this.editor
                .chain()
                .focus()
                .setImage({
                  src: url,
                  alt: alt || fileNameToTitle(url),
                  width: null,
                })
                .run();

              return "save";
            } else if (type === "video") {
              this.editor
                .chain()
                .focus()
                .insertContent({
                  type: "video",
                  attrs: {
                    src: url,
                    mimetype: mimetype || "video/mp4",
                  },
                })
                .run();

              return "save";
            }

            return null;
          },
        });

        const dialogState = await imageRepositoryDialog.toggle();

        if (dialogState !== "save") {
          this.editor.chain().focus(null, { scrollIntoView: false }).run();
          return false;
        }

        return true;
      },
    };
  },

  addNodeView() {
    return createNodeView(this);
  },

  parseHTML() {
    return [{ tag: "div[data-image-repository] img[src]:not([src^='data:'])" }];
  },

  renderHTML({ HTMLAttributes }) {
    return [
      "div",
      { class: "editor-content-image-repository", "data-image-repository": "" },
      ["img", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes)],
    ];
  },
});
