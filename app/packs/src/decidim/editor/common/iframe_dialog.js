import Dialog from "a11y-dialog-component";

import { getDictionary } from "src/decidim/i18n";
import { uniqueId } from "src/decidim/editor/common/helpers";

export default class IframeDialog {
  constructor(editor, { iframeSourceUrl, onMessage }) {
    this.editor = editor;
    this.onMessage = onMessage;
    const id = uniqueId("iframedialog");
    this.element = document.createElement("div");
    this.element.dataset.dialog = `${Math.random().toString(36).slice(2)}`;

    const i18n = getDictionary("editor.inputDialog");

    const uniq = this.element.dataset.dialog;
    this.element.innerHTML = `
      <div id="${uniq}-content">
        <button type="button" data-dialog-close="${uniq}" data-dialog-closable="" aria-label="${i18n.close}">&times</button>
        <div data-dialog-container>
          <div class="form-defaults form">
            <div class="form__wrapper">
              <iframe 
                id="${id}-iframe"
                src="${iframeSourceUrl}"
                frameborder="0"
                allowfullscreen
                style="width: 100%; height: 100%; min-height: 400px;"
              ></iframe>
            </div> 
          </div>
        </div>
        <div data-dialog-actions>
          <button type="button" class="button button__sm md:button__lg button__transparent-secondary" data-action="cancel">${i18n["buttons.cancel"]}</button> 
        </div>
      </div>
    `;
    document.body.appendChild(this.element);

    this.dialog = new Dialog(`[data-dialog="${uniq}"]`, {
      // openingSelector: `[data-dialog-open="${uniq}"]`,
      closingSelector: `[data-dialog-close="${uniq}"]`,
      backdropSelector: `[data-dialog="${uniq}"]`,
      enableAutoFocus: false,
      onClose: () => {
        setTimeout(() => this.handleClose(), 0);
      },
    });

    this.element.querySelectorAll("button[data-action]").forEach((button) => {
      button.addEventListener("click", (ev) => {
        ev.preventDefault();
        this.action = button.dataset.action;
        this.close();
      });
    });

    if (typeof this.onMessage === "function") {
      this.messageHandler = (event) => {
        const result = this.onMessage(event);
        if (result === "save") {
          this.action = "save";
          this.close();
        }
      };

      window.addEventListener("message", this.messageHandler);
    }
  }

  toggle() {
    return new Promise((resolve) => {
      this.callback = resolve;
      this.action = null;

      this.editor.commands.toggleDialog(true);

      this.dialog.open();
    });
  }

  close() {
    this.dialog.close();
  }

  destroy() {
    // Remove the message event listener if it was added
    if (this.messageHandler) {
      window.removeEventListener("message", this.messageHandler);
    }

    this.dialog.destroy();
    this.element.remove();
    Reflect.deleteProperty(this, "dialog");
  }

  /**
   * This is fired when the dialog is actually closed. The `close()` method only
   * initiates the closing of the dialog.
   *
   * @returns {void}
   */
  handleClose() {
    this.editor
      .chain()
      .toggleDialog(false)
      .focus(null, { scrollIntoView: false })
      .run();

    if (this.callback) {
      this.callback(this.action);
      this.callback = null;
    }
    if (this.action) {
      this.action = null;
    }

    this.destroy();
  }
}
