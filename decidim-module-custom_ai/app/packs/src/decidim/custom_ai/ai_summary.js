$(document).ready(function () {
  const $input = $("#summary-input");

  $input.on("keydown", function (e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();

      $(".generate-with-ai-js").click();
    }
  });

  $(".generate-with-ai-js").on("click", function (e) {
    e.preventDefault();

    const endpoint = window.Decidim.config.get("processAiEndpoint");
    const component_id = window.Decidim.config.get("componentId");

    if (!endpoint) {
      console.error("AI endpoint is not configured");
      return;
    }

    if ($(this).is(":disabled")) {
      return;
    }

    const prompt = $input.val();

    const $textarea = $("#summary-output");
    const answer_body = $textarea.val();

    const $copyButton = $(".copy-output-js");

    $(this).attr("disabled", "disabled");

    const $iconIdle = $(this).find(".icon-idle-js");
    const $iconLoading = $(this).find(".icon-loading-js");

    $iconIdle.addClass("hidden");
    $iconLoading.removeClass("hidden");

    fetch(`${endpoint}?name=send_prompt`, {
      method: "POST",
      body: JSON.stringify({
        prompt,
        component_id,
      }),
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((response) => response.json())
      .then(({ content }) => {
        $textarea.val(content);

        $copyButton.on("click", function () {
          const $iconIdle = $(this).find(".icon-idle-js");
          const $iconSuccess = $(this).find(".icon-success-js");

          navigator.clipboard.writeText($textarea.val()).then(() => {
            $iconIdle.addClass("hidden");
            $iconSuccess.removeClass("hidden");

            setTimeout(() => {
              $iconSuccess.addClass("hidden");
              $iconIdle.removeClass("hidden");
            }, 2000);
          });
        });
      })
      .finally(() => {
        $textarea.removeAttr("disabled");
        $(this).removeAttr("disabled");
        $copyButton.removeAttr("disabled");

        $iconIdle.removeClass("hidden");
        $iconLoading.addClass("hidden");
      });
  });
});
