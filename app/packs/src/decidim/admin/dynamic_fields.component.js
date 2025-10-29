/**
 * File overwritten to add the ability to duplicate questions
 */
/* eslint-disable require-jsdoc */
class DynamicFieldsComponent {
  constructor(options = {}) {
    this.wrapperSelector = options.wrapperSelector;
    this.containerSelector = options.containerSelector;
    this.fieldSelector = options.fieldSelector;
    this.addFieldButtonSelector = options.addFieldButtonSelector;
    this.addSeparatorButtonSelector = options.addSeparatorButtonSelector;
    this.addTitleAndDescriptionButtonSelector =
      options.addTitleAndDescriptionButtonSelector;
    this.fieldTemplateSelector = options.fieldTemplateSelector;
    this.separatorTemplateSelector = options.separatorTemplateSelector;
    this.TitleAndDescriptionTemplateSelector =
      options.TitleAndDescriptionTemplateSelector;
    this.removeFieldButtonSelector = options.removeFieldButtonSelector;
    this.moveUpFieldButtonSelector = options.moveUpFieldButtonSelector;
    this.moveDownFieldButtonSelector = options.moveDownFieldButtonSelector;
    this.duplicateQuestionButtonSelector =
      options.duplicateQuestionButtonSelector; // custom
    this.onAddField = options.onAddField;
    this.onRemoveField = options.onRemoveField;
    this.onMoveUpField = options.onMoveUpField;
    this.onMoveDownField = options.onMoveDownField;
    this.placeholderId = options.placeholderId;
    this.elementCounter = 0;
    this._enableInterpolation();
    this._activateFields();
    this._bindEvents();
  }

  _enableInterpolation() {
    $.fn.replaceAttribute = function (attribute, placeholder, value) {
      $(this)
        .find(`[${attribute}*=${placeholder}]`)
        .addBack(`[${attribute}*=${placeholder}]`)
        .each((index, element) => {
          $(element).attr(
            attribute,
            $(element).attr(attribute).replace(placeholder, value)
          );
        });

      return this;
    };

    $.fn.template = function (placeholder, value) {
      // See the comment below in the `_addField()` method regarding the
      // `<template>` tag support in IE11.
      const $subtemplate = $(this).find("template, .decidim-template");

      if ($subtemplate.length > 0) {
        $subtemplate.html(
          (index, oldHtml) =>
            $(oldHtml).template(placeholder, value)[0].outerHTML
        );
      }

      // Handle those subtemplates that are mapped with the `data-template`
      // attribute. This is also because of the IE11 support.
      const $subtemplateParents = $(this).find("[data-template]");

      if ($subtemplateParents.length > 0) {
        $subtemplateParents.each((_i, elem) => {
          const $self = $(elem);
          const $tpl = $($self.data("template"));

          // Duplicate the sub-template with a unique ID as there may be
          // multiple parent templates referring to the same sub-template.
          const $subtpl = $($tpl[0].outerHTML);
          const subtemplateId = `${$tpl.attr("id")}-${value}`;
          const subtemplateSelector = `#${subtemplateId}`;
          $subtpl.attr("id", subtemplateId);
          $self
            .attr("data-template", subtemplateSelector)
            .data("template", subtemplateSelector);
          $tpl.after($subtpl);

          $subtpl.html(
            (index, oldHtml) =>
              $(oldHtml).template(placeholder, value)[0].outerHTML
          );
        });
      }

      $(this).replaceAttribute("id", placeholder, value);
      $(this).replaceAttribute("name", placeholder, value);
      $(this).replaceAttribute("data-tabs-content", placeholder, value);
      $(this).replaceAttribute("for", placeholder, value);
      $(this).replaceAttribute("tabs_id", placeholder, value);
      $(this).replaceAttribute("href", placeholder, value);
      $(this).replaceAttribute("value", placeholder, value);

      return this;
    };
  }

  _bindEvents() {
    $(this.wrapperSelector).on("click", this.addFieldButtonSelector, (event) =>
      this._bindSafeEvent(event, () =>
        this._addField(this.fieldTemplateSelector)
      )
    );

    if (this.addSeparatorButtonSelector) {
      $(this.wrapperSelector).on(
        "click",
        this.addSeparatorButtonSelector,
        (event) =>
          this._bindSafeEvent(event, () =>
            this._addField(this.separatorTemplateSelector)
          )
      );
    }

    if (this.addTitleAndDescriptionButtonSelector) {
      $(this.wrapperSelector).on(
        "click",
        this.addTitleAndDescriptionButtonSelector,
        (event) =>
          this._bindSafeEvent(event, () =>
            this._addField(this.TitleAndDescriptionTemplateSelector)
          )
      );
    }

    // CUSTOM: add event handler for duplicating questions
    if (this.duplicateQuestionButtonSelector) {
      $(this.wrapperSelector).on(
        "click",
        this.duplicateQuestionButtonSelector,
        (event) =>
          this._bindSafeEvent(event, (target) =>
            this._addFieldAfter(target, this.fieldTemplateSelector)
          )
      );
    }

    $(this.wrapperSelector).on(
      "click",
      this.removeFieldButtonSelector,
      (event) =>
        this._bindSafeEvent(event, (target) => this._removeField(target))
    );

    if (this.moveUpFieldButtonSelector) {
      $(this.wrapperSelector).on(
        "click",
        this.moveUpFieldButtonSelector,
        (event) =>
          this._bindSafeEvent(event, (target) => this._moveUpField(target))
      );
    }

    if (this.moveDownFieldButtonSelector) {
      $(this.wrapperSelector).on(
        "click",
        this.moveDownFieldButtonSelector,
        (event) =>
          this._bindSafeEvent(event, (target) => this._moveDownField(target))
      );
    }
  }

  _bindSafeEvent(event, cb) {
    event.preventDefault();
    event.stopPropagation();

    try {
      return cb(event.target);
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
      return error;
    }
  }

  // Adds a field.
  //
  // template - A String matching the type of the template. Expected to be
  //  either ".decidim-question-template" or ".decidim-separator-template".
  _addField(templateClass = ".decidim-template") {
    const $wrapper = $(this.wrapperSelector);
    const $container = $wrapper.find(this.containerSelector);

    // Allow defining the template using a `data-template` attribute on the
    // wrapper element. This is to allow child templates which would otherwise
    // be impossible using `<script type="text/template">`. See the comment
    // below regarding the `<template>` tag and IE11.
    const templateSelector = $wrapper.data("template");
    let $template = null;
    if (templateSelector) {
      $template = $(templateSelector);
    }
    if ($template === null || $template.length < 1) {
      // To preserve IE11 backwards compatibility, the views are using
      // `<script type="text/template">` with a given `class` instead of
      // `<template>`. The `<template> tags are parsed in IE11 along with the
      // DOM which may cause the form elements inside them to break the forms
      // as they are submitted with them.
      $template = $wrapper.children(`template, ${templateClass}`);
    }

    const $newField = $($template.html()).template(
      this.placeholderId,
      this._getUID()
    );

    $newField.find("ul.tabs").attr("data-tabs", true);

    const $lastQuestion = $container.find(this.fieldSelector).last();
    if ($lastQuestion.length > 0) {
      $lastQuestion.after($newField);
    } else {
      $newField.appendTo($container);
    }

    $newField.foundation();

    if (this.onAddField) {
      this.onAddField($newField);
    }
  }

  /**
   * CUSTOM: add method for duplicating questions with value copying
   * Creates a new question field directly after the selected question and copies all its values
   */
  _addFieldAfter(target, templateClass = ".decidim-template") {
    const $wrapper = $(this.wrapperSelector);
    const $targetField = $(target).closest(this.fieldSelector);

    const templateSelector = $wrapper.data("template");
    let $template = null;
    if (templateSelector) {
      $template = $(templateSelector);
    }
    if ($template === null || $template.length < 1) {
      $template = $wrapper.children(`template, ${templateClass}`);
    }

    const $newField = $($template.html()).template(
      this.placeholderId,
      this._getUID()
    );

    $newField.find("ul.tabs").attr("data-tabs", true);

    // Insert the new field right after the target field
    $targetField.after($newField);

    $newField.foundation();

    // Copy values from the source field to the new field
    this._copyFieldValues($targetField, $newField);

    if (this.onAddField) {
      this.onAddField($newField);
    }
  }

  _removeField(target) {
    const $target = $(target);
    const $removedField = $target.parents(this.fieldSelector);
    const idInput = $removedField
      .find("input")
      .filter((idx, input) => input.name.match(/id/));

    if (idInput.length > 0) {
      const deletedInput = $removedField
        .find("input")
        .filter((idx, input) => input.name.match(/delete/));

      if (deletedInput.length > 0) {
        $(deletedInput[0]).val(true);
      }

      $removedField.addClass("hidden");
      $removedField.hide();
    } else {
      $removedField.remove();
    }

    if (this.onRemoveField) {
      this.onRemoveField($removedField);
    }
  }

  _moveUpField(target) {
    const $target = $(target);
    const $movedUpField = $target.parents(this.fieldSelector);

    $movedUpField.prev().before($movedUpField);

    if (this.onMoveUpField) {
      this.onMoveUpField($movedUpField);
    }
  }

  _moveDownField(target) {
    const $target = $(target);
    const $movedDownField = $target.parents(this.fieldSelector);

    $movedDownField.next().after($movedDownField);

    if (this.onMoveDownField) {
      this.onMoveDownField($movedDownField);
    }
  }

  _activateFields() {
    // Move the `<script type="text/template">` elements to the bottom of the
    // list container so that they will not cause the question moving
    // functionality to break since it assumes that all children elements are
    // the dynamic field list child items.
    const $wrapper = $(this.wrapperSelector);
    const $container = $wrapper.find(this.containerSelector);
    $container.append($container.find("script"));

    $(this.fieldSelector).each((idx, el) => {
      $(el).template(this.placeholderId, this._getUID());

      $(el).find("ul.tabs").attr("data-tabs", true);
    });
  }

  _getUID() {
    this.elementCounter += 1;

    return new Date().getTime() + this.elementCounter;
  }

  /**
   * CUSTOM: add method for copying all values from source field to target field
   */
  _copyFieldValues(sourceField, targetField) {
    const basicFields = [
      'input[type="text"]',
      'input[type="number"]',
      'input[type="hidden"]:not([name$="[id]"]):not([name$="[position]"])',
      "textarea",
      "select",
    ];

    const nestedFieldPatterns = [
      "[answer_options]",
      "[matrix_rows]",
      "[display_conditions]",
    ];

    const getFieldKey = (fieldName) => {
      const match = fieldName.match(/\[([^\]]+)\]$/);
      return match ? match[1] : null;
    };

    basicFields.forEach((fieldType) => {
      sourceField.find(fieldType).each((index, sourceElement) => {
        const $sourceElement = $(sourceElement);
        const fieldName = $sourceElement.attr("name");

        if (!fieldName) return;

        if (
          nestedFieldPatterns.some((pattern) => fieldName.includes(pattern))
        ) {
          return;
        }

        const fieldKey = getFieldKey(fieldName);
        if (!fieldKey || fieldKey === "max_choices") return;

        if (sourceElement.type === "hidden") {
          const hasCorrespondingCheckbox =
            sourceField.find(`input[type="checkbox"][name$="[${fieldKey}]"]`)
              .length > 0;
          if (hasCorrespondingCheckbox) return;
        }

        const targetSelector = `${fieldType}[name$="[${fieldKey}]"]`;
        const $targetElement = targetField.find(targetSelector);

        if ($targetElement.length > 0) {
          if ($sourceElement.type === "checkbox") {
            $targetElement.prop("checked", $sourceElement.checked);
          } else if ($sourceElement[0].tagName === "SELECT") {
            $targetElement.val($sourceElement.val()).trigger("change");
          } else {
            $targetElement.val($sourceElement.val());
          }
        }
      });
    });

    sourceField.find('input[type="checkbox"]').each((index, sourceElement) => {
      const $sourceElement = $(sourceElement);
      const fieldName = $sourceElement.attr("name");

      if (!fieldName) return;

      const fieldKey = getFieldKey(fieldName);
      if (!fieldKey) return;

      const $targetElement = targetField.find(
        `input[type="checkbox"][name$="[${fieldKey}]"]`
      );

      if ($targetElement.length > 0) {
        $targetElement.prop("checked", $sourceElement.prop("checked"));
        $targetElement.trigger("change");
      }
    });

    const sourceAnswerOptions = sourceField.find(
      ".questionnaire-question-answer-options-list > div"
    );
    const targetAnswerOptionsContainer = targetField.find(
      ".questionnaire-question-answer-options-list"
    );

    if (sourceAnswerOptions.length > 0) {
      targetAnswerOptionsContainer.children("div").remove();

      sourceAnswerOptions.each((index, sourceOption) => {
        const $clonedOption = $(sourceOption).clone();
        this._updateFieldNames($clonedOption, targetField);
        targetAnswerOptionsContainer.append($clonedOption);
      });
    }

    const sourceMatrixRows = sourceField.find(
      ".questionnaire-question-matrix-rows-list > div"
    );
    const targetMatrixRowsContainer = targetField.find(
      ".questionnaire-question-matrix-rows-list"
    );

    if (sourceMatrixRows.length > 0) {
      targetMatrixRowsContainer.children("div").remove();

      sourceMatrixRows.each((index, sourceRow) => {
        const $clonedRow = $(sourceRow).clone();
        this._updateFieldNames($clonedRow, targetField);
        targetMatrixRowsContainer.append($clonedRow);
      });
    }

    const sourceDisplayConditions = sourceField.find(
      ".questionnaire-question-display-conditions-list > div"
    );
    const targetDisplayConditionsContainer = targetField.find(
      ".questionnaire-question-display-conditions-list"
    );

    if (sourceDisplayConditions.length > 0) {
      targetDisplayConditionsContainer.children("div").remove();

      sourceDisplayConditions.each((index, sourceCondition) => {
        const $clonedCondition = $(sourceCondition).clone();
        this._updateFieldNames($clonedCondition, targetField);
        targetDisplayConditionsContainer.append($clonedCondition);
      });
    }

    this._regenerateMaxChoicesOptions(targetField);

    this._copyMaxChoicesValue(sourceField, targetField);

    this._copyDisplayConditionValues(sourceField, targetField);
  }

  /**
   * CUSTOM: Helper function for regenerating max_choices options
   */
  _regenerateMaxChoicesOptions(targetField) {
    const answerOptionsCount = targetField.find(
      ".questionnaire-question-answer-option:not(.hidden)"
    ).length;

    const targetMaxChoicesSelect = targetField.find(
      'select[name$="[max_choices]"]'
    );

    if (targetMaxChoicesSelect.length > 0 && answerOptionsCount > 1) {
      const firstOption = targetMaxChoicesSelect.find("option:first");
      targetMaxChoicesSelect.empty().append(firstOption);

      for (let i = 2; i <= answerOptionsCount; i++) {
        targetMaxChoicesSelect.append(`<option value="${i}">${i}</option>`);
      }
    }
  }

  /**
   * CUSTOM: Helper function for copying max_choices values
   */
  _copyMaxChoicesValue(sourceField, targetField) {
    const sourceMaxChoicesSelect = sourceField.find(
      'select[name$="[max_choices]"]'
    );

    if (sourceMaxChoicesSelect.length > 0) {
      const selectedValue = sourceMaxChoicesSelect.val();
      const targetMaxChoicesSelect = targetField.find(
        'select[name$="[max_choices]"]'
      );

      if (targetMaxChoicesSelect.length > 0) {
        const targetOption = targetMaxChoicesSelect.find(
          `option[value="${selectedValue}"]`
        );
        if (targetOption.length > 0) {
          targetMaxChoicesSelect.val(selectedValue).trigger("change");
        }
      }
    }
  }

  /**
   * CUSTOM: Helper function to copy select values in display conditions
   */
  _copyDisplayConditionValues(sourceField, targetField) {
    const sourceConditions = sourceField.find(
      ".questionnaire-question-display-conditions-list > div"
    );
    const targetConditions = targetField.find(
      ".questionnaire-question-display-conditions-list > div"
    );

    sourceConditions.each((index, sourceCondition) => {
      const $sourceCondition = $(sourceCondition);
      const $targetCondition = $(targetConditions[index]);

      if (!$targetCondition || $targetCondition.length === 0) return;

      const sourceQuestionSelect = $sourceCondition.find(
        'select[name$="[decidim_condition_question_id]"]'
      );
      const targetQuestionSelect = $targetCondition.find(
        'select[name$="[decidim_condition_question_id]"]'
      );

      if (sourceQuestionSelect.length > 0 && targetQuestionSelect.length > 0) {
        const selectedValue = sourceQuestionSelect.val();
        if (
          selectedValue &&
          targetQuestionSelect.find(`option[value="${selectedValue}"]`).length >
            0
        ) {
          targetQuestionSelect.val(selectedValue).trigger("change");
        }
      }

      const sourceTypeSelect = $sourceCondition.find(
        'select[name$="[condition_type]"]'
      );
      const targetTypeSelect = $targetCondition.find(
        'select[name$="[condition_type]"]'
      );

      if (sourceTypeSelect.length > 0 && targetTypeSelect.length > 0) {
        const selectedValue = sourceTypeSelect.val();
        if (
          selectedValue &&
          targetTypeSelect.find(`option[value="${selectedValue}"]`).length > 0
        ) {
          targetTypeSelect.val(selectedValue).trigger("change");
        }
      }

      const sourceTextInputs = $sourceCondition.find(
        'input[type="text"], textarea'
      );
      sourceTextInputs.each((idx, input) => {
        const $sourceInput = $(input);
        const inputName = $sourceInput.attr("name");
        if (!inputName) return;

        const fieldKey = inputName.match(/\[([^\]]+)\]$/);
        if (fieldKey) {
          const $targetInput = $targetCondition.find(
            `input[name$="[${fieldKey[1]}]"], textarea[name$="[${fieldKey[1]}]"]`
          );
          if ($targetInput.length > 0) {
            $targetInput.val($sourceInput.val());
          }
        }
      });
    });
  }

  /**
   * CUSTOM: add helper method for updating field names in cloned elements
   * Updates field names, IDs and other attributes to match the new question
   */
  _updateFieldNames(clonedElement, targetField) {
    const sampleInput = targetField.find("input").first();
    if (!sampleInput.length) return;

    const sampleName = sampleInput.attr("name");
    if (!sampleName) return;

    const questionIdMatch = sampleName.match(/\[questions\]\[([^\]]+)\]/);
    if (!questionIdMatch) return;

    const newQuestionId = questionIdMatch[1];

    clonedElement.find("[name]").each((index, element) => {
      const $element = $(element);
      const oldName = $element.attr("name");

      if (oldName) {
        const newName = oldName.replace(
          /\[questions\]\[[^\]]+\]/,
          `[questions][${newQuestionId}]`
        );
        $element.attr("name", newName);
      }
    });

    clonedElement
      .find("[id], [for], [data-tabs-content]")
      .each((index, element) => {
        const $element = $(element);

        ["id", "for", "data-tabs-content"].forEach((attr) => {
          const oldValue = $element.attr(attr);
          if (oldValue && oldValue.includes("-")) {
            const newValue = oldValue.replace(/-\d+-/, `-${newQuestionId}-`);
            $element.attr(attr, newValue);
          }
        });
      });
  }
}

export default function createDynamicFields(options) {
  return new DynamicFieldsComponent(options);
}
