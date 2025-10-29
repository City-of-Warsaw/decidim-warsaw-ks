import { Node } from "@tiptap/core";

export default Node.create({
  name: "section",
  group: "block",
  content: "block+",

  addAttributes() {
    return {
      id: {
        default: null,
        parseHTML: (element) => element.getAttribute("id"),
        renderHTML: (attributes) => ({ id: attributes.id }),
      },
    };
  },

  parseHTML() {
    return [{ tag: "section" }];
  },

  renderHTML({ HTMLAttributes }) {
    return ["section", HTMLAttributes, 0];
  },
});
