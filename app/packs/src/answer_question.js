$(document).ready(function () {
  const $form = $("form.answer-questionnaire");
  const $steps = $form.find(".questionnaire-step");
  let currentStep = 0;

  function showStep(index) {
    $steps.each(function (i, el) {
      if (i === index) {
        $(el)
          .removeClass("hide")
          .removeAttr("hidden")
          .attr("aria-expanded", "true");
      } else {
        $(el)
          .addClass("hide")
          .attr("hidden", "true")
          .attr("aria-expanded", "false");
      }
    });
  }

  showStep(currentStep);

  $form.on("click", "#toggle-cazav7", function (e) {
    e.preventDefault();
    currentStep = 1;
    showStep(currentStep);
  });

  $form.on("click", ".primary-action", function (e) {
    e.preventDefault();
    currentStep = 1;

    if (currentStep < $steps.length - 1) {
      currentStep++;
      showStep(currentStep);
    } else {
      $form.submit();
    }
  });

  $form.on("click", ".back-action", function (e) {
    e.preventDefault();
    if (currentStep > 0) {
      currentStep--;
      showStep(currentStep);
    }
  });

  $form.on("click", ".cancel-action", function (e) {
    e.preventDefault();
    currentStep = 0;
    showStep(currentStep);
  });
});
