import { textblockTypeInputRule } from "@tiptap/core";

import Heading from "@tiptap/extension-heading";

/**
 * Customized version of the Heading extension in order to fix compatibility
 * issue with the Hashtag extension. The default input rule of the Heading
 * extension would also match any paragraphs that have only one hashtag in them
 * and nothing else because that indicates the first level of heading.
 *
 * E.g.
 * - If you have the following paragraph: `<p>#apples</p>`
 * - This would be converted to a paragraph containing the hashtag node markup
 *   in the editor.
 * - If you come back to edit this content and try to enter a space right after
 *   the hashtag, the hashtag would disappear and the active text block would
 *   get the second heading level applied to it
 *
 ̶*̶ ̶S̶i̶n̶c̶e̶ ̶w̶e̶ ̶d̶o̶ ̶n̶o̶t̶ ̶a̶l̶l̶o̶w̶ ̶t̶h̶e̶ ̶u̶s̶e̶r̶ ̶t̶o̶ ̶e̶n̶t̶e̶r̶ ̶t̶h̶e̶ ̶f̶i̶r̶s̶t̶ ̶l̶e̶v̶e̶l̶ ̶o̶f̶ ̶h̶e̶a̶d̶i̶n̶g̶s̶ ̶t̶h̶r̶o̶u̶g̶h̶
̶ ̶*̶ ̶t̶h̶e̶ ̶e̶d̶i̶t̶o̶r̶,̶ ̶w̶e̶ ̶c̶a̶n̶ ̶f̶i̶x̶ ̶t̶h̶i̶s̶ ̶b̶y̶ ̶l̶i̶m̶i̶t̶i̶n̶g̶ ̶t̶h̶e̶ ̶m̶a̶r̶k̶d̶o̶w̶n̶ ̶s̶h̶o̶r̶t̶c̶u̶t̶ ̶t̶o̶ ̶t̶h̶e̶ ̶s̶e̶c̶o̶n̶d̶
̶ ̶*̶ ̶l̶e̶v̶e̶l̶ ̶h̶e̶a̶d̶i̶n̶g̶s̶ ̶a̶n̶d̶ ̶a̶b̶o̶v̶e̶.̶
 */
export default Heading.extend({
  addInputRules() {
    return this.options.levels.map((level) => {
      return textblockTypeInputRule({
        find: new RegExp(`^(#{1,${level}})\\s$`),
        type: this.type,
        getAttributes: { level },
      });
    });
  },
});
