import Image from "@tiptap/extension-image";

import { fileNameToTitle } from "src/decidim/editor/utilities/file";
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

            const { type, url, alt, description, mimetype } = event.data;

            if (type === "image") {
              this.editor
                .chain()
                .focus()
                .setImage({
                  src: url,
                  alt: alt || fileNameToTitle(url),
                  "data-description": description || "",
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
});
