/* eslint-disable require-jsdoc */

import lineBreakButtonHandler from "src/decidim/editor/linebreak_module";
import { HtmlEditButton } from "../../../assets/javascripts/decidim/quill.html-custom";
import { ExtendedImage } from "../../../assets/javascripts/decidim/quill.extended-image-embed";
import { Divider } from "../../../assets/javascripts/decidim/quill.divider-embed";
import { Button } from "../../../assets/javascripts/decidim/quill.button";
import { initializeQuillStyleToolbarTool } from "../../../assets/javascripts/decidim/quill.style-toolbar-tool";
import { createRepositoryImageToolbarToolHandler } from "../../../assets/javascripts/decidim/quill.repository-image-toolbar-tool";
import { createImageToolbarToolHandler } from "../../../assets/javascripts/decidim/quill.image-toolbar-tool";
import { registerQuillStyleToolbarTool } from "../../../assets/javascripts/decidim/quill.style-toolbar-tool";
import "src/decidim/editor/clipboard_override";
import "src/decidim/vendor/image-resize.min";
import "src/decidim/vendor/image-upload.min";

const quillFormats = [
  "bold",
  "italic",
  "link",
  "underline",
  "header",
  "list",
  "alt",
  "break",
  "width",
  "style",
  "code",
  "divider",
  "button",
  "class",
  "align",
  "extended-image",
  "strike",
  "sub",
  "script",
];

Quill.register(ExtendedImage, true);
Quill.register(Divider);
Quill.register({ "formats/button": Button });

export default function createQuillEditor(container) {
  const toolbar = $(container).data("toolbar");
  const disabled = $(container).data("disabled");

  const styles = {
    // Custom Classes
    // Label => Custom Class without prefix
    "Wyróżniony śródtytuł": "area-color-headline",
    "Podstawa prawna": "legal-basis",
    "Otoczenie grafiki tekstem": "image-float",
  };

  const allowedEmptyContentSelector = "iframe";
  let quillToolbar = [
    ["bold", "italic", "underline", "strike"],
    ["undo", "redo"],
    ["style"],
    [{ align: [] }],
    [{ list: "ordered" }, { list: "bullet" }],
    [{ script: "sub" }, { script: "super" }],
    [{ indent: "-1" }, { indent: "+1" }],
    [{ direction: "rtl" }],
    ["blockquote"],
    ["link", "button", "extended-image", "repository-image", "video"],
    ["clean"],
    ["divider"],
  ];

  let addImage = false;
  let addVideo = false;

  /**
   * - basic = only basic controls without titles
   * - content = basic + headings
   * - full = basic + headings + image + video
   */
  if (toolbar === "content") {
    quillToolbar = [[{ header: [2, 3, 4, 5, 6, false] }], ...quillToolbar];
  } else if (toolbar === "full") {
    addImage = true;
    addVideo = true;
    quillToolbar = [[{ header: [2, 3, 4, 5, 6, false] }], ...quillToolbar];
  }

  let modules = {
    linebreak: {},
    toolbar: {
      container: quillToolbar,
      handlers: {
        linebreak: lineBreakButtonHandler,
        divider: function () {
          var range = quill.getSelection();
          if (range) {
            quill.insertEmbed(range.index, "divider", "null");
          }
        },
        "repository-image": createRepositoryImageToolbarToolHandler({
          iframeSourceUrl: "/admin/files/editor_images",
        }),
        button: function () {
          const range = quill.getSelection();
          if (range) {
            const url = prompt("Wprowadź adres URL dla przycisku:");
            if (url) {
              quill.format("button", url);
            }
          }
        },
        "extended-image": createImageToolbarToolHandler({
          uploadEndpointUrl: "//" + location.host + "/admin/files",
        }),
      },
    },
  };
  const $input = $(container).siblings('input[type="hidden"]');
  container.innerHTML = $input.val() || "";
  const token = $('meta[name="csrf-token"]').attr("content");

  if (addVideo) {
    quillFormats.push("video");
  }

  if (addImage) {
    // Attempt to allow images only if the image support is enabled at editor support.
    // see: https://github.com/quilljs/quill/issues/1108
    quillFormats.push("image");

    modules.imageUpload = {
      url: $(container).data("uploadImagesPath"),
      method: "POST",
      name: "image",
      withCredentials: false,
      headers: { "X-CSRF-Token": token },
      callbackOK: (serverResponse, next) => {
        $("div.ql-toolbar").last().removeClass("editor-loading");
        const range = quill.getSelection();
        if (range) {
          quill.insertEmbed(range.index, "extended-image", {
            url: serverResponse.url,
            alt: "",
          });
          quill.setSelection(range.index + 1);
        } else {
          next(serverResponse.url);
        }
      },
      callbackKO: (serverError) => {
        $("div.ql-toolbar").last().removeClass("editor-loading");
        console.log(`Image upload error: ${serverError.message}`);
      },
      checkBeforeSend: (file, next) => {
        $("div.ql-toolbar").last().addClass("editor-loading");
        next(file);
      },
    };

    const text = $(container).data("dragAndDropHelpText");
    $(container).after(
      `<p class="help-text" style="margin-top:-1.5rem;">${text}</p>`
    );
  }

  var icons = Quill.import("ui/icons");

  icons["undo"] = `<svg viewbox="0 0 18 18">
                      <polygon class="ql-fill ql-stroke" points="6 10 4 12 2 10 6 10"></polygon>
                      <path class="ql-stroke" d="M8.09,13.91A4.6,4.6,0,0,0,9,14,5,5,0,1,0,4,9"></path>
                    </svg>`;

  icons["redo"] = `<svg viewbox="0 0 18 18">
                      <polygon class="ql-fill ql-stroke" points="12 10 14 12 16 10 12 10"></polygon>
                      <path class="ql-stroke" d="M9.91,13.91A4.6,4.6,0,0,1,9,14a5,5,0,1,1,5-5"></path>
                    </svg>`;

  icons["divider"] = `<svg viewbox="0 0 18 18">
                          <line x1="0" y1="9" x2="18" y2="9" stroke="currentColor" />
                        </svg>`;

  icons[
    "button"
  ] = `<svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 32 32"><g><g><path d="M28.8,0H3.2A3.2,3.2,0,0,0,0,3.2V28.8A3.2,3.2,0,0,0,3.2,32H28.8A3.2,3.2,0,0,0,32,28.8V3.2A3.2,3.2,0,0,0,28.8,0Zm-.64,28.16H3.84V3.84H28.16Z"/><path d="M11.16,8.72h4.37a9,9,0,0,1,4.24.79,2.88,2.88,0,0,1,1.44,2.77,3.49,3.49,0,0,1-.56,2,2.3,2.3,0,0,1-1.6,1v.1a4.26,4.26,0,0,1,1.27.5,2.36,2.36,0,0,1,.91,1,3.9,3.9,0,0,1,.34,1.77,3.56,3.56,0,0,1-1.39,3,5.91,5.91,0,0,1-3.77,1.09H11.16Zm3,5.57h1.73a2.94,2.94,0,0,0,1.8-.41,1.44,1.44,0,0,0,.5-1.21,1.25,1.25,0,0,0-.59-1.16,3.8,3.8,0,0,0-1.86-.35H14.13Zm0,2.36v3.66h1.95A2.7,2.7,0,0,0,18,19.79a1.88,1.88,0,0,0,.53-1.39,1.61,1.61,0,0,0-.54-1.27,3,3,0,0,0-2-.48Z"/></g></g></svg>`;

  icons["extended-image"] = `<svg viewbox="0 0 18 18">
                    <rect class="ql-stroke" height="10" width="12" x="3" y="4"></rect>
                    <circle class="ql-fill" cx="6" cy="7" r="1"></circle>
                    <polyline class="ql-stroke" points="5 12 5 11 7 9 8 10 11 7 13 9 13 12 5 12"></polyline>
                  </svg>`;

  const input = $(container).siblings('input[type="hidden"]');
  const originalHTML = $input.val() || "";
  container.innerHTML = originalHTML;

  const quill = new Quill(container, {
    modules: modules,
    formats: quillFormats,
    theme: "snow",
  });

  setTimeout(() => {
    let changed = false;

    quill.root.querySelectorAll("h2, h3, h4").forEach((heading) => {
      const prevElement = heading.previousElementSibling;

      if (
        prevElement &&
        prevElement.tagName === "P" &&
        prevElement.innerHTML === "<br>"
      ) {
        prevElement.parentNode.removeChild(prevElement);
        changed = true;
      }
    });

    if (changed) {
      const selection = quill.getSelection();
      quill.update();

      if (selection) quill.setSelection(selection);
    }
  }, 0);

  initializeQuillStyleToolbarTool(quill, styles);
  new HtmlEditButton(quill);
  registerQuillStyleToolbarTool();

  if (disabled) {
    quill.disable();
  }

  quill.on("text-change", () => {
    const text = quill.getText();

    let event = new CustomEvent("quill-position", {
      detail: quill.getSelection(),
    });
    container.dispatchEvent(event);

    $input.val(quill.root.innerHTML.replace(/(<p><br><\/p>)+$/, ""));
  });

  const length = quill.getLength();
  const text = quill.getText(length - 1, 1);

  // Remove extraneous new lines
  if (text === "\n\n") {
    quill.deleteText(quill.getLength() - 1, 1);
  }

  $(".ql-undo").on("click", function (e) {
    quill.history.undo();
  });

  $(".ql-redo").on("click", function (e) {
    quill.history.redo();
  });

  if (addImage === false) {
    // Firefox natively implements image drop in contenteditable which is why we need to disable that
    quill.root.addEventListener("drop", (ev) => ev.preventDefault());
  }

  if (disabled) {
    quill.disable();
  }

  quill.on("text-change", () => {
    const text = quill.getText();

    // Triggers CustomEvent with the cursor position
    // It is required in input_mentions.js
    let event = new CustomEvent("quill-position", {
      detail: quill.getSelection(),
    });
    container.dispatchEvent(event);

    if (
      (text === "\n" || text === "\n\n") &&
      quill.root.querySelectorAll(allowedEmptyContentSelector).length === 0
    ) {
      $input.val("");
    } else {
      const emptyParagraph = "<p><br></p>";
      const cleanHTML = quill.root.innerHTML.replace(
        new RegExp(`^${emptyParagraph}|${emptyParagraph}$`, "g"),
        ""
      );
      $input.val(cleanHTML);
    }
  });
  // After editor is ready, linebreak_module deletes two extraneous new lines
  quill.emitter.emit("editor-ready");

  return quill;
}
