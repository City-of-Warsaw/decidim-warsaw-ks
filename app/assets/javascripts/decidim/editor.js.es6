// = require quill.min
// = require_self

// overwritten Decidim configuration editor.js.es6

((exports) => {
  const quillFormats = [
    "bold",
    "italic",
    "link",
    "underline",
    "header",
    "list",
    "video",
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
      ["link", "video", "clean"],
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
        ["link", "image", "repository-image", "video"],
        ["clean"],
        ["divider"],
      ];
    } else if (toolbar === "basic") {
      quillToolbar = [...quillToolbar, ["video"]];
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
                          <line x1="0" y1="9" x2="18" y2="9" stroke="black" />
                        </svg>`;

    registerQuillStyleToolbarTool();

    Quill.register({
      "formats/extended-image": ExtendedImage,
      "formats/extended-video": ExtendedVideo,
      "formats/divider": Divider,
    });

    const $input = $(container).siblings('input[type="hidden"]');
    container.innerHTML = $input.val() || "";

    const quill = new Quill(container, {
      modules: {
        history: {
          userOnly: true,
        },
        // linebreak: {},
        toolbar: {
          container: quillToolbar,
          handlers: {
            // "linebreak": exports.Decidim.Editor.lineBreakButtonHandler

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
          },
        },
      },
      // formats: quillFormats,
      theme: "snow",
    });

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

      // Triggers CustomEvent with the cursor position
      // It is required in input_mentions.js
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
