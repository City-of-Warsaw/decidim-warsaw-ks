export class HtmlEditButton {
  constructor(quill, optionsInput) {
    const options = optionsInput || {};
    const debug = !!(options && options.debug);
    Logger.setDebug(debug);
    Logger.log("logging enabled");

    // Add button to all quill toolbar instances
    const toolbarModule = quill.getModule("toolbar");
    if (!toolbarModule) {
      throw new Error(
        'quill.htmlEditButton requires the "toolbar" module to be included too'
      );
    }

    let toolbarEl = toolbarModule.container;
    const buttonContainer = $create("span");
    $setAttr(buttonContainer, "class", "ql-formats");

    const button = $create("button");
    button.innerHTML = options.buttonHTML || "&lt;&gt;";
    button.title = options.buttonTitle || "Dodaj kod HTML";
    button.type = "button";

    const onSave = (html) => {
      quill.clipboard.dangerouslyPasteHTML(html);
    };

    button.onclick = function (e) {
      e.preventDefault();
      launchPopupEditor(quill, options, onSave);
    };

    buttonContainer.appendChild(button);
    toolbarEl.appendChild(buttonContainer);
  }
}

function FormatHTMLStringIndentation(code, logger) {
  "use strict";
  let stripWhiteSpaces = true;
  let stripEmptyLines = true;
  const whitespace = " ".repeat(2); // Default indenting 4 whitespaces
  let currentIndent = 0;
  const newlineChar = "\n";
  let prevChar = null;
  let char = null;
  let nextChar = null;

  let result = "";
  for (let pos = 0; pos <= code.length; pos++) {
    prevChar = char;
    char = code.substr(pos, 1);
    nextChar = code.substr(pos + 1, 1);

    const isBrTag = code.substr(pos, 4) === "<br>";
    const isOpeningTag = char === "<" && nextChar !== "/" && !isBrTag;
    const isClosingTag = char === "<" && nextChar === "/" && !isBrTag;
    const isTagEnd = prevChar === ">" && char !== "<" && currentIndent > 0;
    const isTagNext =
      !isBrTag &&
      !isOpeningTag &&
      !isClosingTag &&
      isTagEnd &&
      code.substr(pos, code.substr(pos).indexOf("<")).trim() === "";
    if (isBrTag) {
      // If opening tag, add newline character and indention
      result += newlineChar;
      currentIndent--;
      pos += 4;
    }
    if (isOpeningTag) {
      // If opening tag, add newline character and indention
      result += newlineChar + whitespace.repeat(currentIndent);
      currentIndent++;
    }
    // if Closing tag, add newline and indention
    else if (isClosingTag) {
      // If there're more closing tags than opening
      if (--currentIndent < 0) currentIndent = 0;
      result += newlineChar + whitespace.repeat(currentIndent);
    }
    // remove multiple whitespaces
    else if (stripWhiteSpaces === true && char === " " && nextChar === " ")
      char = "";
    // remove empty lines
    else if (stripEmptyLines === true && char === newlineChar) {
      if (code.substr(pos, code.substr(pos).indexOf("<")).trim() === "")
        char = "";
    }
    if (isTagEnd && !isTagNext) {
      result += newlineChar + whitespace.repeat(currentIndent);
    }

    result += char;
  }
  logger.log("formatHTML", {
    before: code,
    after: result,
  });
  return result;
}

function OutputHTMLParser(inputHtmlFromQuillPopup) {
  return Compose(
    [
      ConvertMultipleSpacesToSingle,
      FixTagSpaceOpenTag,
      FixTagSpaceCloseTag,
      PreserveNewlinesBr,
      PreserveNewlinesPTags,
    ],
    inputHtmlFromQuillPopup
  );
}

function ConvertMultipleSpacesToSingle(input) {
  return input.replace(/\s+/g, " ").trim();
}

function PreserveNewlinesBr(input) {
  return input.replace(/<br([\s]*[\/]?>)/g, "<p> </p>");
}

function PreserveNewlinesPTags(input) {
  return input.replace(/<p><\/p>/g, "<p> </p>");
}

function FixTagSpaceOpenTag(input) {
  return input.replace(/(<(?!\/)[\w=\."'\s]*>) /g, "$1");
}

function FixTagSpaceCloseTag(input) {
  return input.replace(/ (<\/[\w]+>)/g, "$1");
}

function Compose(functions, input) {
  return functions.reduce((acc, cur) => cur(acc), input);
}
class QuillHtmlLogger {
  constructor() {
    this.debug = false;
  }

  setDebug(debug) {
    this.debug = debug;
  }

  prefixString() {
    return `</> quill-html-edit-button: `;
  }

  get log() {
    if (!this.debug) {
      return (...args) => {};
    }
    const boundLogFn = console.log.bind(console, this.prefixString());
    return boundLogFn;
  }
}

function $create(elName) {
  return document.createElement(elName);
}

function $setAttr(el, key, value) {
  return el.setAttribute(key, value);
}

const Logger = new QuillHtmlLogger();

function launchPopupEditor(quill, options, saveCallback) {
  const htmlFromEditor = quill.container.querySelector(".ql-editor").innerHTML;
  const popupContainer = $create("div");
  const overlayContainer = $create("div");
  const msg = options.msg || "";
  const cancelText = options.cancelText || "Anuluj";
  const okText = options.okText || "Zapisz";
  const closeOnClickOverlay = options.closeOnClickOverlay !== false;

  $setAttr(overlayContainer, "class", "ql-html-overlayContainer");
  $setAttr(popupContainer, "class", "ql-html-popupContainer");
  const popupTitle = $create("span");
  $setAttr(popupTitle, "class", "ql-html-popupTitle");
  popupTitle.innerText = msg;
  const textContainer = $create("div");
  textContainer.appendChild(popupTitle);
  $setAttr(textContainer, "class", "ql-html-textContainer");
  const codeBlock = $create("pre");
  $setAttr(codeBlock, "data-language", "xml");
  codeBlock.innerText = FormatHTMLStringIndentation(htmlFromEditor, Logger);
  const htmlEditor = $create("div");
  $setAttr(htmlEditor, "class", "ql-html-textArea");
  const buttonCancel = $create("button");
  buttonCancel.innerHTML = cancelText;
  $setAttr(buttonCancel, "class", "button muted");
  const buttonOk = $create("button");
  buttonOk.innerHTML = okText;
  $setAttr(buttonOk, "class", "button");
  const buttonGroup = $create("div");
  $setAttr(buttonGroup, "class", "ql-html-buttonGroup");
  const prependSelector = document.querySelector(options.prependSelector);

  buttonGroup.appendChild(buttonCancel);
  buttonGroup.appendChild(buttonOk);
  htmlEditor.appendChild(codeBlock);
  textContainer.appendChild(htmlEditor);
  textContainer.appendChild(buttonGroup);
  popupContainer.appendChild(textContainer);
  overlayContainer.appendChild(popupContainer);

  if (prependSelector) {
    prependSelector.prepend(overlayContainer);
  } else {
    document.body.appendChild(overlayContainer);
  }

  const modules = options && options.editorModules;
  const hasModules = !!modules && !!Object.keys(modules).length;
  const modulesSafe = hasModules ? modules : {};

  const editor = new Quill(htmlEditor, {
    modules: {
      syntax: options.syntax,
      ...modulesSafe,
    },
  });

  buttonCancel.onclick = function () {
    if (prependSelector) {
      prependSelector.removeChild(overlayContainer);
    } else {
      document.body.removeChild(overlayContainer);
    }
  };

  if (closeOnClickOverlay) {
    overlayContainer.onclick = buttonCancel.onclick;
  }

  popupContainer.onclick = function (e) {
    e.preventDefault();
    e.stopPropagation();
  };
  buttonOk.onclick = function () {
    const container = editor.container;
    const qlElement = container.querySelector(".ql-editor");
    const htmlInputFromPopup = qlElement.innerText;
    const htmlOutputFormatted = OutputHTMLParser(htmlInputFromPopup);
    Logger.log("OutputHTMLParser", { htmlInputFromPopup, htmlOutputFormatted });
    saveCallback(htmlOutputFormatted);
    if (prependSelector) {
      prependSelector.removeChild(overlayContainer);
    } else {
      document.body.removeChild(overlayContainer);
    }
  };
}
