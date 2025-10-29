export class Link extends Quill.import("formats/link") {
  static blotName = 'link';
  static tagName = 'A';
  static SANITIZED_URL = 'about:blank';
  static PROTOCOL_WHITELIST = ['http', 'https', 'mailto', 'tel', 'sms'];

  static create(value) {
    const node = super.create(value);
    node.setAttribute('href', this.sanitize(value));
    node.setAttribute('rel', 'noopener noreferrer');

    if (!value.startsWith(window.location.origin)) {
      node.setAttribute('target', '_blank');
    } else {
      node.removeAttribute('target');
    }

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
      // @ts-expect-error
      this.domNode.setAttribute('href', this.constructor.sanitize(value));
    }
  }
}

function sanitize(url, protocols) {
  const anchor = document.createElement('a');
  anchor.href = url;
  const protocol = anchor.href.slice(0, anchor.href.indexOf(':'));
  return protocols.indexOf(protocol) > -1;
}

Link.blotName = "link";
Link.tagName = "A";
