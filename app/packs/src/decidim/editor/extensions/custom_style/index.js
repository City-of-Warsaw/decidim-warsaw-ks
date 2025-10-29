import { Extension } from "@tiptap/core";

export default Extension.create({
  name: "customStyle",

  priority: 101,

  addGlobalAttributes() {
    return [
      {
        types: ["paragraph", "heading"],
        attributes: {
          class: {
            default: null,
            parseHTML: (element) => element.getAttribute("class"),
            renderHTML: (attributes) => {
              if (!attributes.class) {
                return {};
              }
              return {
                class: attributes.class,
              };
            },
          },
        },
      },
    ];
  },

  addCommands() {
    return {
      toggleClassName:
        (className) =>
        ({ commands, editor, state, dispatch, view }) => {
          const { selection } = state;
          const { $from } = selection;

          const currentNode = $from.node($from.depth);
          const currentAttrs = currentNode.attrs || {};

          const currentClass = currentAttrs.class;
          const hasClass = currentClass === className;

          let newClass = null;
          if (!hasClass && className) {
            newClass = className;
          }

          const nodeType = currentNode.type;
          return commands.updateAttributes(nodeType.name, { class: newClass });
        },
    };
  },
});
