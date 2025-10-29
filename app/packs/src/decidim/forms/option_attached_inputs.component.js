/*
 * File overritten to respect form disabled state for custom_body inputs on questionnaire summary screen
 */

/* eslint-disable require-jsdoc */

class OptionAttachedInputsComponent {
  constructor(options = {}) {
    this.wrapperField = options.wrapperField;
    this.controllerFieldSelector = options.controllerFieldSelector;
    this.dependentInputSelector = options.dependentInputSelector;
    this.controllerSelector = this.wrapperField.find(
      this.controllerFieldSelector
    );
    this._bindEvent();
    this._run();
  }

  _run() {
    this.controllerSelector.each((idx, el) => {
      const $field = $(el);
      const enabled = $field.is(":checked");

      // CUSTOM: Check if parent form has --disabled modifier
      // If so, keep inputs disabled regardless of checkbox/radio state
      const $parentForm = this.wrapperField.closest("form");
      const isFormDisabled = $parentForm.hasClass(
        "answer-questionnaire--disabled"
      );

      const shouldDisable = isFormDisabled ? true : !enabled;

      $field
        .parents("div.js-collection-input")
        .find(this.dependentInputSelector)
        .prop("disabled", shouldDisable);
    });
  }

  _bindEvent() {
    this.controllerSelector.on("change", () => {
      this._run();
    });
  }
}

export default function createOptionAttachedInputs(options) {
  return new OptionAttachedInputsComponent(options);
}
