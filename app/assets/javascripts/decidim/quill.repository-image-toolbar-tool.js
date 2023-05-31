function createRepositoryImageToolbarToolHandler(options) {
  const DEFAULT_OPTIONS = {
    iframeSourceUrl: "",
    iframeHeight: 500,
  };

  options = { ...DEFAULT_OPTIONS, ...options };

  let quill;

  const modalRoot = document.createElement("div");
  modalRoot.id = "ql-repository-image-modal-root";

  const modal = document.createElement("div");
  modal.id = "ql-repository-image-modal";

  const modalCloseButton = document.createElement("button");
  modalCloseButton.id = "ql-repository-image-modal-close-button";
  modalCloseButton.innerHTML = "&times;";
  modalCloseButton.addEventListener("click", () => {
    modalRoot.style.display = "none";
  });

  const iframe = document.createElement("iframe");
  iframe.src = options.iframeSourceUrl;
  iframe.width = "100%";
  iframe.height = options.iframeHeight;

  modal.appendChild(modalCloseButton);
  modal.appendChild(iframe);
  modalRoot.appendChild(modal);
  modalRoot.addEventListener("click", (event) => {
    if (!modal.contains(event.target)) {
      modalRoot.style.display = "none";
    }
  });
  document.body.appendChild(modalRoot);

  function insertImage(quill, imageData) {
    const range = quill.getSelection();

    quill.insertEmbed(range.index, "extended-image", imageData);
    quill.setSelection(range.index + 1);
  }

  function insertVideo(quill, videoData) {
    const range = quill.getSelection();

    quill.insertEmbed(range.index, "extended-video", videoData);
    quill.setSelection(range.index + 1);
  }

  function handleMessage(event) {
    switch (event.data.type) {
      case "image":
        insertImage(quill, { ...event.data });
        break;

      case "video":
        insertVideo(quill, { ...event.data });
        break;
    }

    modalRoot.style.display = "none";
  }

  return function () {
    quill = this.quill;
    modalRoot.style.display = "block";

    window.removeEventListener("message", handleMessage, false);
    window.addEventListener("message", handleMessage, false);
  };
}
