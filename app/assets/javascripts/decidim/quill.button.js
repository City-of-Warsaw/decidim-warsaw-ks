export class Button extends Quill.import("formats/link") {
  static create(value) {
    const node = super.create(value);

    if (typeof value === "string") {
      node.setAttribute("href", this.sanitize(value));
      if (!value.startsWith(window.location.origin)) {
        node.setAttribute("target", "_blank");
      } else {
        node.removeAttribute("target");
      }
    } else {
      node.setAttribute("href", this.SANITIZED_URL);
      console.warn("Button value is not a string:", value);
    }

    node.setAttribute("class", "ql-button");
    node.setAttribute("role", "button");
    node.setAttribute("rel", "noopener noreferrer");

    return node;
  }

  static formats(domNode) {
    return domNode.getAttribute('href');
  }

  static sanitize(url) {
    return sanitize(url, this.PROTOCOL_WHITELIST) ? url : this.SANITIZED_URL;
  }

  format(name, value) {
    if (name !== this.statics.blotName || !value) {
      super.format(name, value);
    } else {
      this.domNode.setAttribute('href', this.constructor.sanitize(value));
    }
  }
}
Button.blotName = "button";
Button.tagName = "A";
Button.className = "ql-button";
Button.SANITIZED_URL = "about:blank";
Button.PROTOCOL_WHITELIST = ["http", "https", "mailto", "tel", "sms"];

function sanitize(url, protocols) {
  const anchor = document.createElement("a");
  anchor.href = url;
  const protocol = anchor.href.slice(0, anchor.href.indexOf(":"));
  return protocols.indexOf(protocol) > -1;
}
