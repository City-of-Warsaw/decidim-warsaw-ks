// = require ./quill
// = require_self
// overwritten Decidim configuration editor.js.es6
// overwritten Quill editor initialization to prevent automatic insertion of empty paragraphs before headings

((exports) => {
  const quillFormats = [
    "bold",
    "italic",
    "link",
    "underline",
    "header",
    "list",
    "extended-video",
    "image",
    "alt",
    "break",
  ];

  const createQuillEditor = (container) => {
    const toolbar = $(container).data("toolbar");
    const disabled = $(container).data("disabled");

    const styles = {
      // Custom Classes
      // Label => Custom Class without prefix
      "Wyróżniony śródtytuł": "area-color-headline",
      "Podstawa prawna": "legal-basis",
    };

    let quillToolbar = [
      ["bold", "italic", "underline", "linebreak"],
      ["undo", "redo"],
      [{ list: "ordered" }, { list: "bullet" }],
      ["link", "button", "extended-video", "clean"],
    ];

    if (toolbar === "full") {
      quillToolbar = [
        [{ header: [2, 3, 4, 5, 6, false] }],
        ["bold", "italic", "underline", "strike"],
        ["undo", "redo"],
        ["style"],
        [{ align: [] }],
        [{ list: "ordered" }, { list: "bullet" }],
        [{ script: "sub" }, { script: "super" }],
        [{ indent: "-1" }, { indent: "+1" }],
        [{ direction: "rtl" }],
        ["blockquote"],
        ["link", "button", "image", "repository-image", "extended-video"],
        ["clean"],
        ["divider"],
      ];
    } else if (toolbar === "basic") {
      quillToolbar = [...quillToolbar, ["extended-video"]];
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

    icons["extended-video"] = icons["video"];

    icons[
      "button"
    ] = `<svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 32 32"><g><g><path d="M28.8,0H3.2A3.2,3.2,0,0,0,0,3.2V28.8A3.2,3.2,0,0,0,3.2,32H28.8A3.2,3.2,0,0,0,32,28.8V3.2A3.2,3.2,0,0,0,28.8,0Zm-.64,28.16H3.84V3.84H28.16Z"/><path d="M11.16,8.72h4.37a9,9,0,0,1,4.24.79,2.88,2.88,0,0,1,1.44,2.77,3.49,3.49,0,0,1-.56,2,2.3,2.3,0,0,1-1.6,1v.1a4.26,4.26,0,0,1,1.27.5,2.36,2.36,0,0,1,.91,1,3.9,3.9,0,0,1,.34,1.77,3.56,3.56,0,0,1-1.39,3,5.91,5.91,0,0,1-3.77,1.09H11.16Zm3,5.57h1.73a2.94,2.94,0,0,0,1.8-.41,1.44,1.44,0,0,0,.5-1.21,1.25,1.25,0,0,0-.59-1.16,3.8,3.8,0,0,0-1.86-.35H14.13Zm0,2.36v3.66h1.95A2.7,2.7,0,0,0,18,19.79a1.88,1.88,0,0,0,.53-1.39,1.61,1.61,0,0,0-.54-1.27,3,3,0,0,0-2-.48Z"/></g></g></svg>`;

    registerQuillStyleToolbarTool();

    Quill.register({
      "formats/extended-image": ExtendedImage,
      "formats/extended-video": ExtendedVideo,
      "formats/divider": Divider,
      "formats/link": Link,
      "modules/htmlEditButton": HtmlEditButton,
      "formats/button": Button,
    });

    const $input = $(container).siblings('input[type="hidden"]');
    const originalHTML = $input.val() || "";
    container.innerHTML = originalHTML;

    const quill = new Quill(container, {
      modules: {
        history: {
          userOnly: true,
        },
        htmlEditButton: {},
        toolbar: {
          container: quillToolbar,
          handlers: {
            image: createImageToolbarToolHandler({
              uploadEndpointUrl:
                //"https://ks.beta-um.warszawa.pl/admin/files",
                "//" + location.host + "/admin/files",
            }),

            "repository-image": createRepositoryImageToolbarToolHandler({
              iframeSourceUrl: "/admin/files/editor_images",
            }),

            divider: function () {
              var range = quill.getSelection();
              if (range) {
                quill.insertEmbed(range.index, "divider", "null");
              }
            },

            "extended-video": function () {
              const range = quill.getSelection();
              const url = prompt("Podaj URL do wideo:");
              if (url) {
                quill.insertEmbed(range.index, "extended-video", {
                  url: url,
                  mimetype: "video/mp4",
                });
              }
            },
          },
        },
      },
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

    $(".ql-undo").on("click", function (e) {
      quill.history.undo();
    });

    $(".ql-redo").on("click", function (e) {
      quill.history.redo();
    });

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

    return quill;
  };

  const quillEditor = () => {
    $(".editor-container").each((_idx, container) => {
      createQuillEditor(container);
    });
  };

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.quillEditor = quillEditor;
  exports.Decidim.createQuillEditor = createQuillEditor;
})(window);
