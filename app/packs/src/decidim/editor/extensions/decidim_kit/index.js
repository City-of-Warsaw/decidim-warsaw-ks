import { Extension } from "@tiptap/core";

import StarterKit from "@tiptap/starter-kit";
import CodeBlock from "@tiptap/extension-code-block";
import Underline from "@tiptap/extension-underline";
import HorizontalRule from "@tiptap/extension-horizontal-rule";
import Table from "@tiptap/extension-table";
import TableCell from "@tiptap/extension-table-cell";
import TableHeader from "@tiptap/extension-table-header";
import TableRow from "@tiptap/extension-table-row";
import TextAlign from "@tiptap/extension-text-align";
import Subscript from "@tiptap/extension-subscript";
import Superscript from "@tiptap/extension-superscript";
import Strike from "@tiptap/extension-strike";

import CharacterCount from "src/decidim/editor/extensions/character_count";
import Bold from "src/decidim/editor/extensions/bold";
import Dialog from "src/decidim/editor/extensions/dialog";
import Hashtag from "src/decidim/editor/extensions/hashtag";
import Heading from "src/decidim/editor/extensions/heading";
import OrderedList from "src/decidim/editor/extensions/ordered_list";
import Image from "src/decidim/editor/extensions/image";
import Indent from "src/decidim/editor/extensions/indent";
import Link from "src/decidim/editor/extensions/link";
import Mention from "src/decidim/editor/extensions/mention";
import VideoEmbed from "src/decidim/editor/extensions/video_embed";
import Emoji from "src/decidim/editor/extensions/emoji";

// Custom extensions for UMW
import Button from "src/decidim/editor/extensions/button";
import Html from "src/decidim/editor/extensions/html";
import CustomStyle from "src/decidim/editor/extensions/custom_style";
import ImageRepository from "src/decidim/editor/extensions/image_repository";
import Section from "src/decidim/editor/extensions/section";
import A11yKit from "src/decidim/editor/extensions/a11y_kit";
import Iframe from "src/decidim/editor/extensions/iframe";
import Video from "src/decidim/editor/extensions/video";

export default Extension.create({
  name: "decidimKit",

  addOptions() {
    return {
      characterCount: { limit: null },
      heading: { levels: [1, 2, 3, 4, 5, 6] },
      link: { allowTargetControl: true },
      videoEmbed: false,
      image: {
        uploadDialogSelector: null,
        uploadImagesPath: null,
        contentTypes: /^image\/(jpe?g|png|svg|webp)$/i,
      },
      hashtag: false,
      mention: false,
      emoji: false,
      button: { allowTargetControl: true },
    };
  },

  addExtensions() {
    const extensions = [
      StarterKit.configure({
        heading: false,
        bold: false,
        orderedList: false,
        codeBlock: false,
        paragraph: false,
      }),
      CharacterCount.configure(this.options.characterCount),
      Link.configure({ openOnClick: false, ...this.options.link }),
      Bold,
      Subscript,
      Superscript,
      Strike,
      Dialog,
      Indent,
      OrderedList,
      CodeBlock,
      Underline,
      HorizontalRule,
      Table.configure({
        resizable: true,
      }),
      TableRow,
      TableHeader,
      TableCell,
      TextAlign.configure({
        types: ["heading", "paragraph"],
      }),
      // Custom extensions for UMW
      Button.configure({ openOnClick: false, ...this.options.button }),
      Html,
      CustomStyle,
      ImageRepository.configure({
        iframeSourceUrl: "/admin/files/editor_images",
      }),
      Section,
      A11yKit,
      Iframe,
      Video,
    ];

    if (this.options.heading !== false) {
      extensions.push(Heading.configure(this.options.heading));
    }

    if (this.options.videoEmbed !== false) {
      extensions.push(VideoEmbed.configure(this.options.videoEmbed));
    }

    if (
      this.options.image !== false &&
      this.options.image.uploadDialogSelector
    ) {
      extensions.push(Image.configure(this.options.image));
    }

    if (this.options.hashtag !== false) {
      extensions.push(Hashtag.configure(this.options.hashtag));
    }

    if (this.options.mention !== false) {
      extensions.push(Mention.configure(this.options.mention));
    }

    if (this.options.emoji !== false) {
      extensions.push(Emoji.configure(this.options.emoji));
    }

    return extensions;
  },
});
