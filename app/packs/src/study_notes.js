$(function () {
  function handleDetailedNotesDeleteButtonState() {
    var button = $("#detailed_notes .multiple-hash-input__delete-button-js");

    if ($("#detailed_notes .multiple-hash-input__items li").length <= 1) {
      button.prop("disabled", true);
    } else {
      button.prop("disabled", false);
    }
  }

  $(document).ready(function () {
    handleDetailedNotesDeleteButtonState();

    $(".multiple-hash-input__add-button-js").on("click", function () {
      setTimeout(handleDetailedNotesDeleteButtonState, 100);
    });

    $(document).on(
      "click",
      ".multiple-hash-input__delete-button-js",
      function () {
        setTimeout(handleDetailedNotesDeleteButtonState, 100);
      }
    );
  });
});

function valueInRange($el, required, parent) {
  if (!$el.val()) return true;

  var value = parseFloat($el.val());
  if (isNaN(value)) return false;

  var min = parseFloat($el.attr("min")),
    max = parseFloat($el.attr("max"));

  if (!isNaN(min) && value < min) return false;
  if (!isNaN(max) && value > max) return false;

  return true;
}

function fractionalPartMaxLength($el, required, parent) {
  if (!$el.val()) return true;

  var value = parseFloat($el.val());
  if (isNaN(value)) return false;

  var fractionalPart = $el.val().split(".")[1];
  if (fractionalPart && fractionalPart.length > 3) return false;

  var fractionalPart = $el.val().split(",")[1];
  if (fractionalPart && fractionalPart.length > 3) return false;

  return true;
}

function requiredIfDetailedNotes($el, required, parent) {
  if ($el.attr("type") === "radio") {
    if (
      $el.parents("form").find("input[name='" + $el.attr("name") + "']:checked")
        .length
    ) {
      return true;
    }
  } else {
    if ($el.val()) return true;
  }

  const index = $el.data("index");

  const detailedNotesInput = $el
    .parents("form")
    .find("#study_note_detailed_notes");

  if (!detailedNotesInput.val()) return true;

  const detailedNotes = JSON.parse(detailedNotesInput.val() || "[]");

  const detailedNote = detailedNotes.find(function (note) {
    return String(note.index) === String(index);
  });

  let isValid = true;

  Object.keys(detailedNote).forEach(function (key) {
    if (
      key !== "index" &&
      key !== "name" &&
      detailedNote[key] &&
      detailedNote[key].toString().length > 0
    ) {
      isValid = false;
      return false;
    }
  });

  return isValid;
}

function requiredIfNoDetailedNotes($el, required, parent) {
  if ($el.val()) return true;

  const detailedNotesInput = $el
    .parents("form")
    .find("#study_note_detailed_notes");

  if (!detailedNotesInput.val()) return false;

  const detailedNotes = JSON.parse(detailedNotesInput.val() || "[]");

  let isValid = false;

  detailedNotes.forEach(function (detailedNote) {
    Object.keys(detailedNote).forEach(function (key) {
      if (
        key !== "index" &&
        key !== "name" &&
        detailedNote[key] &&
        detailedNote[key].toString().length > 0
      ) {
        isValid = true;
        return true;
      }
    });
  });

  return isValid;
}

function requiredIfNoDetailedNotesAndRequestBody($el, required, parent) {
  if ($el.val()) return true;

  const detailedNotesInput = $el
    .parents("form")
    .find("#study_note_detailed_notes");

  const requestBodyInput = $el.parents("form").find("#study_note_request_body");

  if (!detailedNotesInput.val() && !requestBodyInput.val()) return false;

  const detailedNotes = JSON.parse(detailedNotesInput.val() || "[]");

  let isValid = false;

  detailedNotes.forEach(function (detailedNote) {
    Object.keys(detailedNote).forEach(function (key) {
      if (
        key !== "index" &&
        key !== "name" &&
        detailedNote[key] &&
        detailedNote[key].toString().length > 0
      ) {
        isValid = true;
        return true;
      }
    });
  });

  if (isValid) return true;
  if (requestBodyInput.val()) return true;

  return false;
}

function valueBelowLimit($el, required, parent) {
  if (!$el.val()) return true;

  var length = $el.val().length;
  var limit = parseFloat($el.data("maxlength"));

  if (!isNaN(limit) && length > limit) return false;

  return true;
}

Foundation.Abide.defaults.validators["value_in_range"] = valueInRange;
Foundation.Abide.defaults.validators["fractional_part_max_length"] =
  fractionalPartMaxLength;
Foundation.Abide.defaults.validators["required_if_detailed_notes"] =
  requiredIfDetailedNotes;
Foundation.Abide.defaults.validators["required_if_no_detailed_notes"] =
  requiredIfNoDetailedNotes;
Foundation.Abide.defaults.validators[
  "required_if_no_detailed_notes_and_request_body"
] = requiredIfNoDetailedNotesAndRequestBody;
Foundation.Abide.defaults.validators["value_below_limit"] = valueBelowLimit;

$(function () {
  $("input#submitter_role_person, input#submitter_role_organization").change(
    function () {
      if (this.value === "0") {
        $(".organization-form").hide();
        $(".person-form").show();

        $(".organization-form input").removeAttr("required");
        $(".organization-form input").attr("data-abide-ignore", "");
        $("#new_study_note_").foundation(
          "removeErrorClasses",
          $(".organization-form input")
        );

        $(".person-form input").attr("required", "required");
        $(".person-form input").removeAttr("data-abide-ignore");
      } else if (this.value === "1") {
        $(".person-form").hide();
        $(".organization-form").show();

        $(".person-form input").removeAttr("required");
        $(".person-form input").attr("data-abide-ignore", "");
        $("#new_study_note_").foundation(
          "removeErrorClasses",
          $(".person-form input").first()
        );
        $("#new_study_note_").foundation(
          "removeErrorClasses",
          $(".person-form input").last()
        );

        $(".organization-form input").attr("required", "required");
        $(".organization-form input").removeAttr("data-abide-ignore");
      }
    }
  );

  if ($("input#submitter_role_organization").is(":checked")) {
    $(".person-form").hide();
    $(".organization-form").show();

    $(".person-form input").removeAttr("required");
  }

  const confirmProcessPersonalData = $(
    "#study_note_confirm_process_personal_data"
  );

  $(
    "input#study_note_optional_confirmation_request_true, input#study_note_optional_confirmation_request_false"
  ).change(function () {
    if (this.value === "true") {
      $("#email_confirmation_request").show();

      confirmProcessPersonalData.attr("required", "required");
      confirmProcessPersonalData.removeAttr("disabled");
      confirmProcessPersonalData.removeAttr("data-abide-ignore");

      $("label[for=study_note_confirm_process_personal_data]").append(
        '<span class="asterisk">*</span>'
      );
      $("label[for=study_note_confirm_process_personal_data]").removeClass(
        "muted"
      );

      $(".organization-form input").removeAttr("required");
      $("#email_confirmation_request input").attr("required", "required");
    } else if (this.value === "false") {
      confirmProcessPersonalData.removeAttr("required");
      confirmProcessPersonalData.prop("checked", false);
      confirmProcessPersonalData.attr("disabled", "disabled");
      confirmProcessPersonalData.removeClass("is-invalid-input");
      confirmProcessPersonalData.attr("data-abide-ignore", "");
      $("#new_study_note_").foundation(
        "removeErrorClasses",
        confirmProcessPersonalData
      );

      $("label[for=study_note_confirm_process_personal_data]").removeClass(
        "is-invalid-label"
      );
      $("label[for=study_note_confirm_process_personal_data]")
        .find("span.asterisk")
        .remove();
      $("label[for=study_note_confirm_process_personal_data]").addClass(
        "muted"
      );

      $("#email_confirmation_request").hide();

      $("#email_confirmation_request input").removeAttr("required");
      $("#email_confirmation_request input").val("");
      $("#email_confirmation_request input").trigger("change");
      $("#new_study_note_").foundation(
        "validateInput",
        $("#email_confirmation_request")
      );
      $("label[for='study_note_email_confirmation_request']").removeClass(
        "is-invalid-label"
      );
    }
  });

  if ($("input#study_note_optional_confirmation_request_true").is(":checked")) {
    $("#email_confirmation_request").show();

    confirmProcessPersonalData.attr("required", "required");
    confirmProcessPersonalData.removeAttr("disabled");
    $("label[for=study_note_confirm_process_personal_data]").append(
      '<span class="asterisk">*</span>'
    );
    $("label[for=study_note_confirm_process_personal_data]").removeClass(
      "muted"
    );

    $(".organization-form input").removeAttr("required");
    $("#email_confirmation_request input").attr("required", "required");
  } else if (
    $("input#study_note_optional_confirmation_request_false").is(":checked")
  ) {
    $("#email_confirmation_request").hide();

    confirmProcessPersonalData.removeAttr("required");
    confirmProcessPersonalData.attr("disabled", "disabled");
    $("label[for=study_note_confirm_process_personal_data]")
      .find("span.asterisk")
      .remove();
    $("label[for=study_note_confirm_process_personal_data]").addClass("muted");
    $("#email_confirmation_request input").removeAttr("required");
  } else {
    confirmProcessPersonalData.removeAttr("required");
    confirmProcessPersonalData.attr("disabled", "disabled");
    $("label[for=study_note_confirm_process_personal_data]")
      .find("span.asterisk")
      .remove();
    $("label[for=study_note_confirm_process_personal_data]").addClass("muted");
  }

  if ($("#study_note_detailed_notes").val()) {
    $("#detailed_notes").foundation("toggle");
  }

  document.getElementById("new_study_note_").addEventListener("reset", () => {
    $("input[type=file].multifile").MultiFile("reset");

    $(".organization-form").hide();
    $(".person-form").show();

    $(".organization-form input").removeAttr("required");
    $(".person-form input").attr("required", "required");
  });

  $("input")
    .filter(function () {
      return this.id.match(/study_note_mailing_address_data_/);
    })
    .on("change blur", function (event) {
      const inputs = $("input").filter(function () {
        return this.id.match(/study_note_mailing_address_data_/);
      });
      const requiredInputs = $("input:not([type=radio])").filter(function () {
        return this.id.match(
          /study_note_mailing_address_data_(country|voivodeship|county|community|street|street_number|city|zip_code)/
        );
      });

      if (event.target.value.length > 0) {
        requiredInputs.attr("required", "required");
        requiredInputs.each(function () {
          const label = $("label[for='" + this.id + "']");
          label.find("span.asterisk").remove();
          label.find("input").before('<span class="asterisk">*</span>');
        });
      } else {
        const emptyInputs = $("input").filter(function () {
          return (
            this.id.match(/study_note_mailing_address_data_/) &&
            this.value === ""
          );
        });

        if (emptyInputs.length === inputs.length) {
          requiredInputs.removeAttr("required");
          requiredInputs.each(function () {
            $("#new_study_note_").foundation("validateInput", $(this));

            const label = $("label[for='" + this.id + "']");
            label.find("span.asterisk").remove();
          });
        }
      }
    });

  $("input")
    .filter(function () {
      return this.id.match(/study_note_attorney_data/);
    })
    .on("change blur", function (event) {
      const inputs = $("input:not([type=radio])").filter(function () {
        return this.id.match(/study_note_attorney_data/);
      });
      const requiredInputs = $("input:not([type=radio])").filter(function () {
        return this.id.match(
          /study_note_attorney_data_(first_name|last_name|country|voivodeship|county|community|street|street_number|city|zip_code)/
        );
      });

      if (event.target.value.length > 0 || event.target.checked !== false) {
        requiredInputs.attr("required", "required");
        requiredInputs.each(function () {
          const label = $("label[for='" + this.id + "']");
          label.find("span.asterisk").remove();
          $(label).find("input").before('<span class="asterisk">*</span>');

          $("input[name='study_note[attorney_data_role]']").each(function () {
            $(this).attr("required", "required");
          });
        });
      } else {
        const emptyInputs = $("input:not([type=radio])").filter(function () {
          return this.id.match(/study_note_attorney_data/) && this.value === "";
        });

        if (emptyInputs.length === inputs.length) {
          requiredInputs.removeAttr("required");
          requiredInputs.each(function () {
            $("#new_study_note_").foundation("validateInput", $(this));

            const label = $("label[for='" + this.id + "']");
            label.find("span.asterisk").remove();
          });

          $("input[name='study_note[attorney_data_role]']").each(function () {
            $(this).removeAttr("required");
          });
        }
      }
    });

  function handleRadioClick($radio) {
    if ($radio.data("waschecked") == true) {
      $radio.removeAttr("checked");
      $radio[0].checked = false;
      $radio.data("waschecked", false);
      $radio.trigger("change");
    } else {
      $radio.attr("checked", "checked");
      $radio[0].checked = true;
      $radio.data("waschecked", true);
      $radio.siblings('input[type="radio"]').data("waschecked", false);
      $radio.trigger("change");
    }
  }

  $('input[type="radio"]')
    .filter(function () {
      return this.id.match(/study_note_attorney_data/);
    })
    .click(function () {
      handleRadioClick($(this));
    });

  $("label")
    .filter(function () {
      return ($(this).attr("for") || "").match(/study_note_attorney_data_role/);
    })
    .click(function (event) {
      var $radio = $("#" + $(this).attr("for"));
      handleRadioClick($radio);
      event.preventDefault();
    });

  $("form").on("reset", function () {
    const mailingDataInputs = $("input:not([type=radio])").filter(function () {
      return this.id.match(/study_note_mailing_address_data_/);
    });
    const emptyMailingDataInputs = $("input:not([type=radio])").filter(
      function () {
        return (
          this.id.match(/study_note_mailing_address_data_/) && this.value === ""
        );
      }
    );

    const attorneyDataInputs = $("input:not([type=radio])").filter(function () {
      return this.id.match(/study_note_attorney_data/);
    });
    const emptyAttorneyDataInputs = $("input:not([type=radio])").filter(
      function () {
        return this.id.match(/study_note_attorney_data/) && this.value === "";
      }
    );

    if (emptyMailingDataInputs.length === mailingDataInputs.length) {
      mailingDataInputs.removeAttr("required");
      mailingDataInputs.each(function () {
        $("#new_study_note_").foundation("validateInput", $(this));

        const label = $("label[for='" + this.id + "']");
        label.find("span.asterisk").remove();
      });
    }

    if (emptyAttorneyDataInputs.length === attorneyDataInputs.length) {
      attorneyDataInputs.removeAttr("required");
      attorneyDataInputs.each(function () {
        $("#new_study_note_").foundation("validateInput", $(this));

        const label = $("label[for='" + this.id + "']");
        label.find("span.asterisk").remove();
      });

      $("input[name='study_note[attorney_data_role]']").each(function () {
        $(this).removeAttr("required");
      });
    }
  });

  function expandSectionsWithErrors() {
    if (
      $(".form-section").find(".is-invalid-input, .form-error.is-visible")
        .length > 0
    ) {
      $(".form-section")
        .find(".is-invalid-input")
        .parents(".form-section")
        .each(function () {
          $(this)
            .find(".form-section__content")
            .each(function () {
              if (!$(this).hasClass("form-section__content--visible")) {
                $(this).foundation("toggle");
              }
            });
        });

      $(".form-section")
        .find(".form-error.is-visible")
        .parents(".multiple-hash-input__item-content")
        .each(function () {
          if (!$(this).hasClass("multiple-hash-input__item-content--visible")) {
            $(this).foundation("toggle");
          }
        });
    }
  }

  function addMissingRadioInputErrorClasses() {
    const $form = $("#new_study_note_");
    const $radios = $('input[type="radio"].is-invalid-input').each(function () {
      const name = $(this).attr("name");
      const valid =
        $form.find('input[type="radio"][name="' + name + '"]:checked').length >
        0;
      const $group = $('input[type="radio"][name="' + name + '"]');

      $group.each(function (index, element) {
        if (!valid) {
          if ($(element).hasClass("is-invalid-input")) return;

          $form.foundation("addErrorClasses", $(element), ["required"]);
        }
      });

      if (valid) {
        $form.foundation("removeRadioErrorClasses", name);
      }
    });
  }

  $(document).on("forminvalid.zf.abide", expandSectionsWithErrors);
  $(document).on("forminvalid.zf.abide", addMissingRadioInputErrorClasses);

  expandSectionsWithErrors();
  addMissingRadioInputErrorClasses();

  $("#previewBeforeSubmitModal [data-action=submit-form]").click(function () {
    $("#previewBeforeSubmitModal [data-action=submit-form]").html('Wysyłam..')
    $("#new_study_note_")[0].submit();
  });
});
