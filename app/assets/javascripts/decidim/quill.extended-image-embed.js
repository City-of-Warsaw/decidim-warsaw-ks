const ATTRIBUTES = ["alt", "height", "width"];

function sanitize(url, protocols) {
  const anchor = document.createElement("a");
  anchor.href = url;
  const protocol = anchor.href.slice(0, anchor.href.indexOf(":"));
  return protocols.indexOf(protocol) > -1;
}

class ExtendedImage extends Quill.import("blots/block/embed") {
  static create(value) {
    let node = super.create(value);
    if (typeof value === "object") {
      node.setAttribute("src", this.sanitize(value.url));
      if (value.alt) {
        node.setAttribute("alt", value.alt);
      }
    }
    return node;
  }

  static formats(domNode) {
    return ATTRIBUTES.reduce(function (formats, attribute) {
      if (domNode.hasAttribute(attribute)) {
        formats[attribute] = domNode.getAttribute(attribute);
      }
      return formats;
    }, {});
  }

  static match(url) {
    return /\.(jpe?g|gif|png)$/.test(url) || /^data:image\/.+;base64/.test(url);
  }

  static sanitize(url) {
    return sanitize(url, ["http", "https", "data"]) ? url : "//:0";
  }

  static value(domNode) {
    return {
      url: domNode.getAttribute("src"),
      alt: domNode.getAttribute("alt"),
    };
  }

  format(name, value) {
    if (ATTRIBUTES.indexOf(name) > -1) {
      if (value) {
        this.domNode.setAttribute(name, value);
      } else {
        this.domNode.removeAttribute(name);
      }
    } else {
      super.format(name, value);
    }
  }
}
ExtendedImage.blotName = "extended-image";
ExtendedImage.tagName = "IMG";
