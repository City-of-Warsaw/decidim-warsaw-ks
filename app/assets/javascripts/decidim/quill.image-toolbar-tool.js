export function createImageToolbarToolHandler(options) {
  const DEFAULT_OPTIONS = {
    uploadEndpointUrl: "",
    acceptMimeTypes: "image/png, image/gif, image/jpeg",
  };

  options = { ...DEFAULT_OPTIONS, ...options };

  let quill;

  const popup = document.createElement("div");
  popup.id = "ql-image-toolbar-popup";
  popup.style.display = "none";
  popup.style.position = "fixed";
  popup.style.zIndex = "1000";
  popup.style.backgroundColor = "white";
  popup.style.border = "1px solid #ccc";
  popup.style.padding = "10px";
  popup.style.flexDirection = "column";
  popup.style.boxShadow = "0 2px 8px rgba(0,0,0,0.2)";
  popup.style.top = "50%";
  popup.style.left = "50%";
  popup.style.transform = "translate(-50%, -50%)";

  const popupCloseButton = document.createElement("button");
  popupCloseButton.id = "ql-image-toolbar-popup-close-button";
  popupCloseButton.innerHTML = "&times;";
  popupCloseButton.style.alignSelf = "flex-end";
  popupCloseButton.style.border = "none";
  popupCloseButton.style.background = "none";
  popupCloseButton.style.fontSize = "20px";
  popupCloseButton.style.cursor = "pointer";
  popupCloseButton.addEventListener("click", () => {
    popup.style.display = "none";
  });

  popup.appendChild(popupCloseButton);

  const popupForm = document.createElement("form");
  popupForm.setAttribute("method", "post");
  popupForm.setAttribute("enctype", "multipart/form-data");
  popupForm.setAttribute("action", options.uploadEndpointUrl);
  popupForm.style.display = "flex";
  popupForm.style.flexDirection = "column";
  popupForm.style.gap = "10px";
  popupForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    const formData = new FormData(event.currentTarget);
    const file = formData.get("file[file_input]");
    const alt = formData.get("file[alt]");

    if (!file || file.size === 0) {
      alert("Nie wybrano pliku");
      return false;
    }

    const imageUrl = await uploadFile(file, alt);

    if (imageUrl) {
      insertImage(quill, imageUrl, alt);
    }

    popup.style.display = "none";
    popupForm.reset();
  });

  const popupFileField = document.createElement("div");
  popupFileField.className = "ql-image-toolbar-popup-field";
  const popupFileFieldLabel = document.createElement("div");
  popupFileFieldLabel.innerText = "Plik:";
  popupFileFieldLabel.style.marginBottom = "5px";

  const popupFileFieldInput = document.createElement("input");
  popupFileFieldInput.style.width = "100%";
  popupFileFieldInput.setAttribute("type", "file");
  popupFileFieldInput.setAttribute("accept", options.acceptMimeTypes);
  popupFileFieldInput.name = "file[file_input]";

  popupFileField.appendChild(popupFileFieldLabel);
  popupFileField.appendChild(popupFileFieldInput);

  popupForm.appendChild(popupFileField);

  const popupAltField = document.createElement("div");
  popupAltField.className = "ql-image-toolbar-popup-field";
  const popupAltFieldLabel = document.createElement("div");
  popupAltFieldLabel.innerText = "Opis alternatywny:";
  popupAltFieldLabel.style.marginBottom = "5px";

  const popupAltFieldInput = document.createElement("input");
  popupAltFieldInput.setAttribute("type", "text");
  popupAltFieldInput.style.width = "100%";
  popupAltFieldInput.name = "file[alt]";

  popupAltField.appendChild(popupAltFieldLabel);
  popupAltField.appendChild(popupAltFieldInput);

  popupForm.appendChild(popupAltField);

  const popupSubmitButton = document.createElement("button");
  popupSubmitButton.className = "ql-image-toolbar-popup-button";
  popupSubmitButton.innerText = "Dodaj";
  popupSubmitButton.style.alignSelf = "flex-end";
  popupSubmitButton.style.padding = "6px 12px";
  popupSubmitButton.style.cursor = "pointer";
  popupSubmitButton.type = "submit";

  popupForm.appendChild(popupSubmitButton);

  popup.appendChild(popupForm);

  document.body.appendChild(popup);

  async function uploadFile(file, alt) {
    const data = new FormData();
    data.append("file[name]", file.name);
    data.append("file[file_input]", file);
    data.append("file[alt]", alt);
    data.append(
      "authenticity_token",
      document.querySelector('meta[name="csrf-token"]').content
    );

    try {
      const response = await fetch(options.uploadEndpointUrl, {
        method: "POST",
        body: data,
        headers: {
          Accept: "application/json",
        },
        credentials: "include",
      });

      if (!response.ok) {
        alert("Wystąpił błąd podczas wysyłania pliku.");
        return null;
      }

      const json = await response.json();

      if (json["file_url"]) {
        return json["file_url"];
      } else {
        alert(
          `Wystąpiły następujące błędy podczas przetwarzania pliku:\n${json[
            "errors"
          ].join("\n")}`
        );
        return null;
      }
    } catch (error) {
      console.error(error);
      alert("Wystąpił błąd podczas wysyłania pliku.");
      return null;
    }
  }

  function insertImage(quill, url, alt) {
    const range = quill.getSelection(true);
    quill.insertEmbed(range.index, "extended-image", { url, alt });
    quill.setSelection(range.index + 1);
  }

  return function () {
    quill = this.quill;

    const toolbarElement = this.container;
    const imageButton = toolbarElement.querySelector(".ql-extended-image");

    if (popup.style.display === "flex") {
      popup.style.display = "none";
    } else {
      popup.style.display = "flex";
    }
  };
}
