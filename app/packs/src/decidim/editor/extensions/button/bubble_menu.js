import { PluginKey } from "prosemirror-state";

import { getDictionary } from "src/decidim/i18n";
import BubbleMenu from "src/decidim/editor/common/bubble_menu";

class ButtonBubbleMenu extends BubbleMenu {
  shouldDisplay() {
    return this.editor.isActive("button");
  }

  display() {
    const { href } = this.editor.getAttributes("button");
    this.element.querySelector("[data-buttonbubble-value]").textContent = href;
  }

  handleAction(action) {
    if (action === "remove") {
      this.editor
        .chain()
        .focus(null, { scrollIntoView: false })
        .unsetButton()
        .run();
    } else {
      this.editor.commands.buttonDialog();
    }
  }
}

const createElement = () => {
  const i18n = getDictionary("editor.extensions.button.bubbleMenu");

  const element = document.createElement("div");
  element.dataset.buttonbubble = "";
  element.innerHTML = `
    <span data-buttonbubble-content>
      ${i18n.url}:
      <span data-buttonbubble-value></span>
    </span>
    <span data-buttonbubble-actions>
      <button type="button" data-action="edit">${i18n.edit}</button>
      <button type="button" data-action="remove">${i18n.remove}</button>
    </span>
  `;

  return element;
};

export default (editor) => {
  return new ButtonBubbleMenu({
    editor,
    element: createElement(),
    pluginKey: new PluginKey("ButtonBubble"),
  });
};
