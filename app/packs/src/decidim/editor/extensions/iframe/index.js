import { Node } from "@tiptap/core";

export default Node.create({
  name: "iframe",
  group: "block",
  content: "text*",

  parseHTML() {
    return [{ tag: "iframe" }];
  },

  renderHTML({ HTMLAttributes }) {
    return ["iframe", HTMLAttributes, 0];
  },

  addAttributes() {
    return {
      src: {
        default: null,
        parseHTML: (element) => element.getAttribute("src"),
        renderHTML: (attributes) => ({ src: attributes.src }),
      },
      width: {
        default: "100%",
        parseHTML: (element) => element.getAttribute("width"),
        renderHTML: (attributes) => ({ width: attributes.width }),
      },
      height: {
        default: "500",
        parseHTML: (element) => element.getAttribute("height"),
        renderHTML: (attributes) => ({ height: attributes.height }),
      },
      frameborder: {
        default: "0",
        parseHTML: (element) => element.getAttribute("frameborder"),
        renderHTML: (attributes) => ({ frameborder: attributes.frameborder }),
      },
      allowfullscreen: {
        default: false,
        parseHTML: (element) => element.hasAttribute("allowfullscreen"),
        renderHTML: (attributes) =>
          attributes.allowfullscreen ? { allowfullscreen: "" } : {},
      },
      title: {
        default: "",
        parseHTML: (element) => element.getAttribute("title"),
        renderHTML: (attributes) =>
          attributes.title ? { title: attributes.title } : {},
      },
      allow: {
        default: "",
        parseHTML: (element) => element.getAttribute("allow"),
        renderHTML: (attributes) =>
          attributes.allow ? { allow: attributes.allow } : {},
      },
      referrerpolicy: {
        default: "",
        parseHTML: (element) => element.getAttribute("referrerpolicy"),
        renderHTML: (attributes) =>
          attributes.referrerpolicy
            ? { referrerpolicy: attributes.referrerpolicy }
            : {},
      },
    };
  },
});
