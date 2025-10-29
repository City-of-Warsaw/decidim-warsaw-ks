// overwritten file
// custom comment form state and behavior management for both logged-in and anonymous users

const FormStates = {
  INITIAL: "initial",
  DETAIL: "detail",
  THANK_YOU: "thank_you",
};

class CommentFormManager {
  constructor($form) {
    this.$form = $form;
    this.$commentWrapper = this.$form.find(".comment-wrapper");
    this.$detailInfo = this.$form.find(".detail-info-container");
    this.$firstButton = this.$commentWrapper.find(
      "button.button.button__sm.button__secondary"
    );
    this.$secondButton = this.$detailInfo.find(
      "button.button.button__sm.button__secondary"
    );
    this.userLoggedIn = this.$commentWrapper.data("user-logged-in");

    this.initializeEventListeners();
    this.setState(FormStates.INITIAL);
    this.initializeMultiFilePlugin();
    this.initializeCustomFileInput();
  }

  setState(newState) {
    this.currentState = newState;
    this.updateFormUI();
  }

  updateFormUI() {
    switch (this.currentState) {
      case FormStates.INITIAL:
        this.showInitialState();
        break;
      case FormStates.DETAIL:
        this.showDetailState();
        break;
      case FormStates.THANK_YOU:
        this.showThankYouState();
        break;
    }
  }

  resetForm() {
    this.$form.find("input[type=text], textarea").val("");
    this.$form.find(".is-invalid-input").removeClass("is-invalid-input");
    this.$form.find(".form-error.is-visible").removeClass("is-visible");

    this.$firstButton.attr("type", "button").prop("disabled", false);
    this.$secondButton.attr("type", "button").prop("disabled", false);

    const $fileInputs = this.$form.find(".multifile");
    $fileInputs.each(function () {
      $(this).MultiFile("reset");
    });

    this.$form.find(".MultiFile-list").empty();
    this.$form.find(".custom-file-info").text("");
  }

  showInitialState() {
    this.$commentWrapper.show();
    this.$detailInfo.hide();
  }

  showDetailState() {
    this.$commentWrapper.hide();
    this.$detailInfo.css("display", "flex");
    const $customFormWrapper = this.$detailInfo.find(".custom-form-wrapper");
    const $submitCustom = this.$detailInfo.find(".comment__form-submit-custom");
    const $bottom = this.$detailInfo.find(".bottom");

    $customFormWrapper.show();
    $submitCustom.show();
    $bottom.show();
  }

  showThankYouState() {
    this.$commentWrapper.hide();
    this.$detailInfo.css("display", "flex");
    const $customFormWrapper = this.$detailInfo.find(".custom-form-wrapper");
    const $submitCustom = this.$detailInfo.find(".comment__form-submit-custom");
    const $sectionHeadingNote = this.$detailInfo.find(".section-heading-note");
    const $commentSectionHeading = this.$detailInfo.find(
      ".comment-section-heading"
    );
    const $bottom = this.$detailInfo.find(".bottom");

    $customFormWrapper.hide();
    $sectionHeadingNote.css("text-align", "center");
    $commentSectionHeading.css("text-align", "center").show();
    $submitCustom.hide();
    $bottom.hide();
  }

  initializeEventListeners() {
    this.$firstButton.on("click", (e) => this.handleFirstButtonClick(e));
    this.$secondButton.on("click", (e) => this.handleSecondButtonClick(e));
    this.$detailInfo
      .find(".close-icon")
      .on("click", () => this.handleCloseClick());

    this.$form.on("submit", (e) => {
      const step = this.$form.data("step");

      if (!this.userLoggedIn && !step) {
        this.$form.data("step", "first");
      }
    });
  }

  initializeCustomFileInput() {
    const $wrapper = this.$form.find(".custom-file-wrapper");
    const $input = $wrapper.find(".custom-file-input");
    const $info = $wrapper.find(".custom-file-info");

    $input.on("change", () => {
      const count = $input[0].files.length;
      if (count > 0) {
        $info.text(`Liczba załączników: ${count}`);
      } else {
        return;
      }
    });
  }

  handleFirstButtonClick(e) {
    if (this.userLoggedIn) {
      this.$firstButton.attr("type", "submit").prop("disabled", false);
      this.$form.data("step", "logged_in");
      return;
    }
    this.$form.data("step", "first");
    this.$firstButton.attr("type", "submit").prop("disabled", false);
    this.$secondButton.attr("type", "submit").prop("disabled", false);
  }

  initializeMultiFilePlugin() {
    this.$form
      .find("input.multifile")
      .not(".MultiFile-applied")
      .each(function () {
        $(this).MultiFile();
      });
  }

  handleSecondButtonClick(e) {
    e.preventDefault();
    this.$form.data("step", "second");
    this.$secondButton.prop("disabled", false);
    this.setState(FormStates.THANK_YOU);
  }

  handleCloseClick() {
    if (this.currentState === FormStates.DETAIL) {
      this.setState(FormStates.THANK_YOU);
    } else if (this.currentState === FormStates.THANK_YOU) {
      this.resetForm();

      let $panelReply = this.$currentPanelReply;
      if (!$panelReply || !$panelReply.length) {
        $panelReply = this.$form.closest('[id^="panel-comment"]');
      }

      if ($panelReply.length) {
        $panelReply.attr("aria-hidden", "true").css("display", "none");
        this.$currentPanelReply = null;

        this.$commentWrapper
          .parents(".commentable-root")
          .find('.comment__actions .button[data-controls^="panel-comment"]')
          .first()
          .each(function () {
            const $button = $(this);

            $button.attr("aria-expanded", "false");
            $button.find("svg:last").hide();
            $button.find("span:last").hide();
            $button.find("svg:first").show();
            $button.find("span:first").show();
          });
      } else {
        this.setState(FormStates.INITIAL);
      }
    }
  }

  handleAjaxSuccess(data) {
    const step = this.$form.data("step");

    if (this.userLoggedIn || step === "logged_in") {
      this.setState(FormStates.THANK_YOU);

      // const $panelReply = this.$form.closest('[id^="panel-comment"]');
      this.$currentPanelReply = this.$form.closest('[id^="panel-comment"]');
      // if ($panelReply.length) {
      //   $panelReply.attr("aria-hidden", "true").css("display", "none");
      // }
    } else {
      if (step === "first") {
        this.setState(FormStates.DETAIL);
      } else if (step === "second") {
        this.setState(FormStates.THANK_YOU);
      }
    }

    this.$form.removeData("step");
    this.$firstButton.prop("disabled", false);
    this.$secondButton.prop("disabled", false);
  }
}

function initCommentForms() {
  $(".comment-form").each(function () {
    const manager = new CommentFormManager($(this));
    $(this).data("formManager", manager);
  });
}

$(document).ready(function () {
  initCommentForms();
});

$(document).on("click", '[id$="-reply-trigger"]', function () {
  const $trigger = $(this);
  const $panelReply = $("#" + $trigger.attr("data-controls"));
  const isOpen = $panelReply.attr("aria-hidden") === "false";

  if (isOpen) {
    $panelReply.attr("aria-hidden", "true").css("display", "none");
    $trigger.attr("aria-expanded", "false");
  } else {
    $panelReply.attr("aria-hidden", "false").css("display", "block");
    $trigger.attr("aria-expanded", "true");

    const $form = $panelReply.find("form.comment-form");
    if ($form.length) {
      let manager = $form.data("formManager");
      if (!manager) {
        manager = new CommentFormManager($form);
        $form.data("formManager", manager);
      }
      if ($panelReply.attr("aria-hidden") === "false") {
        manager.setState(FormStates.INITIAL);
      }
    }
  }
});

$(document).on("ajax:success", "form.comment-form", function (event) {
  const [data] = event.detail;
  const formManager = $(this).data("formManager");
  if (formManager) {
    formManager.handleAjaxSuccess(data);
  } else {
    const newManager = new CommentFormManager($(this));
    $(this).data("formManager", newManager);
    newManager.handleAjaxSuccess(data);
  }
});

$(document).on("click", ".remove-file-btn", function (e) {
  e.preventDefault();

  const $li = $(this).closest("li");

  const $checkbox = $li.find(".remove-file-checkbox");
  $checkbox.prop("checked", true);

  $li.hide();
});

$(document).on(
  "click",
  ".attachment-button-js:not(.AttachmentButton-applied)",
  function (e) {
    const $btn = $(this);

    if ($btn.closest(".add-comment").length > 0) {
      return;
    }

    e.preventDefault();

    const targetSelector = $btn.data("target");
    const $wrapper = $(targetSelector);

    const $fileInput = $wrapper.is('input[type="file"]')
      ? $wrapper
      : $wrapper.find('input[type="file"]');

    console.log("Target:", targetSelector);
    console.log("Wrapper:", $wrapper);
    console.log("Input:", $fileInput);

    if ($fileInput.length) {
      $fileInput.trigger("click");
    }
  }
);

$(document).on("click", "[data-dialog-open]", function () {
  const modalId = $(this).data("dialog-open");
  const $modal = $("#" + modalId);

  if ($modal.length) {
    const $fileInput = $modal.find("input.multifile");
    if ($fileInput.length && !$fileInput.hasClass("MultiFile-applied")) {
      $fileInput.MultiFile();
    }
  }
});

document.addEventListener("ajax:loaded", ({ detail }) => initCommentForms());
