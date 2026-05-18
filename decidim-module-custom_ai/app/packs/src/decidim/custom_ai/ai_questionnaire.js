$(document).ready(function () {
  const $form = $("form.answer-questionnaire");
  const $modal = $("#aiProcessingModal");

  function removeAiSubmitButton() {
    $form.find(".validate-with-ai-js").remove();
    $form.find("button[type='submit']").removeClass("hidden");
  }

  $(".validate-with-ai-js").on("click", function (e) {
    e.preventDefault();
    window.Decidim.currentDialogs.aiProcessingModal.open();

    const endpoint = window.Decidim.config.get("processAiEndpoint");

    if (!endpoint) {
      console.error("AI endpoint is not configured");
      return;
    }

    const controller = new AbortController();
    const signal = controller.signal;

    const $longAnswers = $form.find("textarea[data-validate-with-ai='true']");
    const $longAnswersWithContent = $longAnswers.filter(
      (index, element) => $(element).val().length > 0
    );

    const component_id = $form.data("component-id");

    fetch(`${endpoint}/verify_answer_question`, {
      method: "POST",
      body: JSON.stringify([
        ...$longAnswersWithContent.map((index, element) => {
          const question_id = $(element).data("question-id");
          const question_body = $(element).data("question-body");
          const answer_body = $(element).val();

          return {
            answer_body,
            question_body,
            question_id,
            component_id,
          };
        }),
      ]),
      signal,
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((response) => response.json())
      .then((data) => {
        $longAnswersWithContent.each((index, element) => {
          const aiResult = data[index];
          const $aiResultContainer = $(element)
            .parents("div")
            .first()
            .find("[data-ai-decision]");

          const $aiSuggestion = $aiResultContainer.find(
            "[data-ai-decision-text]"
          );

          if (aiResult.suggestion_body.length > 0) {
            $aiResultContainer.removeClass("hidden");
            $aiSuggestion.html(aiResult.suggestion_body);

            $(element).addClass("!border-warning !bg-warning/5");
            $(element).on("input", function () {
              $(this).removeClass("!border-warning !bg-warning/5");
            });
          }
        });

        $modal.find("h3").text("Analiza zakończona");
        $modal.find(".icon-loading-js").addClass("hidden");
        $modal.find(".icon-finished-js").removeClass("hidden");

        if (data.some((result) => result.suggestion_body.length > 0)) {
          $modal
            .find("p")
            .text(
              "Znaleziono sugestie dotyczące odpowiedzi. Możesz je przejrzeć i dostosować swoje odpowiedzi."
            );
          $modal
            .find("button[data-action='review-ai-suggestions']")
            .removeClass("hidden");
        } else {
          $modal
            .find("p")
            .text(
              "Nie znaleziono sugestii dotyczących odpowiedzi. Możesz wysłać formularz bez zmian."
            );
          $modal
            .find("button[data-action='submit-form']")
            .removeClass("hidden");
        }

        $modal
          .find("button[data-action='abort-and-submit-form']")
          .addClass("hidden");

        const $stepToDisplay = $form
          .find(
            ".answer-questionnaire__step[hidden]:has([data-ai-decision]:not(.hidden))"
          )
          .first();

        if ($stepToDisplay.length) {
          $form
            .find(".answer-questionnaire__step:not([hidden])")
            .each(function () {
              $(this).attr("hidden", true);
              $(this).attr("aria-expanded", "false");
            });

          $stepToDisplay.removeAttr("hidden");
          $stepToDisplay.attr("aria-expanded", "true");
        }

        removeAiSubmitButton();
      })
      .catch((error) => {
        console.error("Error during AI analysis:", error);
        $modal.find("h3").text("Wystąpił błąd podczas analizy");
        $modal
          .find("p")
          .text(
            "Spróbuj ponownie później lub skontaktuj się z administratorem. Możesz wysłać formularz bez analizy AI."
          );

        $modal.find(".icon-loading-js").addClass("hidden");
        $modal.find(".icon-finished-js").removeClass("hidden");

        $modal
          .find("button[data-action='review-ai-suggestions']")
          .addClass("hidden");
        $modal
          .find("button[data-action='abort-and-submit-form']")
          .addClass("hidden");

        $modal.find("button[data-action='submit-form']").removeClass("hidden");

        removeAiSubmitButton();
      });

    $modal.find("button:not([data-action])").on("click", function () {
      $modal.find("h3").text("Trwa analiza");
      $modal.find(".icon-loading-js").removeClass("hidden");
      $modal.find(".icon-finished-js").addClass("hidden");

      $modal
        .find("button[data-action='review-ai-suggestions']")
        .addClass("hidden");
      $modal.find("button[data-action='submit-form']").addClass("hidden");

      $modal
        .find("button[data-action='abort-and-submit-form']")
        .removeClass("hidden");

      controller.abort();
      removeAiSubmitButton();
    });

    $modal.find("button[data-action$='submit-form']").on("click", function () {
      $form.submit();
      controller.abort();
    });
  });
});
