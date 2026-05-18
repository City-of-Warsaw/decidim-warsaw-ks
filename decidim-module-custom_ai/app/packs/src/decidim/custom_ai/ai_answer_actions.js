$(document).ready(function () {
  function showAiSuggestion(field, content) {
    const $field = $(`#answer_${field}`);

    const $aiDecisionWrapper = $(`[data-ai-suggestion-for='${field}']`);
    const $aiDecisionBody = $aiDecisionWrapper.find(
      `[data-ai-suggestion-value]`
    );

    if (content.length > 0) {
      $aiDecisionWrapper.removeClass("hidden");

      if (field === "ai_decision_status") {
        const label = $field.find(`option[value='${content}']`).text();
        $aiDecisionBody.val(label);
      } else {
        $aiDecisionBody.val(content);
      }

      $aiDecisionWrapper
        .find("[data-action='apply-suggestion']")
        .on("click", function () {
          $field.val(content);
          $aiDecisionWrapper.addClass("hidden");
        });
    }
  }

  $(".correct-with-ai-js").on("click", function (e) {
    e.preventDefault();

    const endpoint = window.Decidim.config.get("processAiEndpoint");

    if (!endpoint) {
      console.error("AI endpoint is not configured");
      return;
    }

    if ($(this).is(":disabled")) {
      return;
    }

    const question_body = $("[data-question]").text();

    const $textarea = $("#answer_ai_decision_body");
    const answer_body = $textarea.val();

    $textarea.attr("disabled", "disabled");
    $(this).attr("disabled", "disabled");

    const $iconIdle = $(this).find(".icon-idle-js");
    const $iconLoading = $(this).find(".icon-loading-js");

    $iconIdle.addClass("hidden");
    $iconLoading.removeClass("hidden");

    fetch(`${endpoint}?name=verify_decision`, {
      method: "POST",
      body: JSON.stringify({
        question_body,
        answer_body,
      }),
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((response) => response.json())
      .then(({ content }) => {
        showAiSuggestion("ai_decision_body", content);
      })
      .finally(() => {
        $textarea.removeAttr("disabled");
        $(this).removeAttr("disabled");

        $iconIdle.removeClass("hidden");
        $iconLoading.addClass("hidden");
      });
  });

  $(".regenerate-with-ai-js").on("click", function (e) {
    e.preventDefault();

    const endpoint = window.Decidim.config.get("processAiEndpoint");

    if (!endpoint) {
      console.error("AI endpoint is not configured");
      return;
    }

    if ($(this).is(":disabled")) {
      return;
    }

    const question_body = $("[data-question]").text();
    const answer_body = $("[data-answer]").text();

    const answer_id = window.Decidim.config.get("answerId");
    const component_id = window.Decidim.config.get("componentId");

    const $textarea = $("#answer_ai_decision_body");
    const $select = $("#answer_ai_decision_status");

    $textarea.attr("disabled", "disabled");
    $select.attr("disabled", "disabled");
    $(this).attr("disabled", "disabled");

    const $iconIdle = $(this).find(".icon-idle-js");
    const $iconLoading = $(this).find(".icon-loading-js");

    $iconIdle.addClass("hidden");
    $iconLoading.removeClass("hidden");

    fetch(`${endpoint}?name=send_answer_body`, {
      method: "POST",
      body: JSON.stringify({
        question_body,
        answer_body,
        answer_id,
        component_id,
      }),
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((response) => response.json())
      .then(({ ai_decision_body, ai_decision_status }) => {
        showAiSuggestion("ai_decision_body", ai_decision_body);
        showAiSuggestion("ai_decision_status", ai_decision_status);
      })
      .finally(() => {
        $textarea.removeAttr("disabled");
        $select.removeAttr("disabled");
        $(this).removeAttr("disabled");

        $iconIdle.removeClass("hidden");
        $iconLoading.addClass("hidden");
      });
  });
});
