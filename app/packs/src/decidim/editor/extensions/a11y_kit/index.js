import { Extension, Mark, Node, mergeAttributes } from "@tiptap/core";

import CoreParagraph from "@tiptap/extension-paragraph";

const Span = Mark.create({
  name: "span",

  addAttributes() {
    return {
      id: {
        default: null,
        parseHTML: (element) => element.getAttribute("id"),
        renderHTML: (attributes) => ({ id: attributes.id }),
      },
      class: {
        default: null,
        parseHTML: (element) => element.getAttribute("class"),
        renderHTML: (attributes) => ({ class: attributes.class }),
      },
    };
  },

  parseHTML() {
    return [{ tag: "span" }];
  },

  renderHTML({ HTMLAttributes }) {
    return ["span", HTMLAttributes, 0];
  },
});

const Time = Mark.create({
  name: "time",

  addAttributes() {
    return {
      id: {
        default: null,
        parseHTML: (element) => element.getAttribute("id"),
        renderHTML: (attributes) => ({ id: attributes.id }),
      },
      datetime: {
        default: null,
        parseHTML: (element) => element.getAttribute("datetime"),
        renderHTML: (attributes) => ({ datetime: attributes.datetime }),
      },
    };
  },

  parseHTML() {
    return [{ tag: "time" }];
  },

  renderHTML({ HTMLAttributes }) {
    return ["time", HTMLAttributes, 0];
  },
});

const Address = Node.create({
  name: "address",
  group: "block",
  content: "block+",

  parseHTML() {
    return [{ tag: "address" }];
  },

  renderHTML({ HTMLAttributes }) {
    return ["address", HTMLAttributes, 0];
  },
});

const Paragraph = CoreParagraph.extend({
  addAttributes() {
    return {
      id: {
        default: null,
        parseHTML: (element) => element.getAttribute("id"),
        renderHTML: (attributes) => ({ id: attributes.id }),
      },
    };
  },
});

export default Extension.create({
  name: "a11yKit",

  addExtensions() {
    return [Span, Time, Address, Paragraph];
  },
});
