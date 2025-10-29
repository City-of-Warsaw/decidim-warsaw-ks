$(document).ready(function () {
  const $button = $("#toggle-button");
  const $textContent = $("#textContent");
  const $arrowIcon = $(".arrow-icon");

  $button.on("click", function () {
    $textContent.toggleClass("collapse");
    $button.toggleClass("rotate-arrow");
    $arrowIcon.toggleClass("rotate-arrow");

    if ($textContent.hasClass("collapse")) {
      $button.text("Rozwiń");
      $button.append($arrowIcon);
    } else {
      $button.text("Zwiń");
      $button.append($arrowIcon);
    }
  });
});

$(document).ready(function () {
  const $submitBtn = $(".submit-btn").first();
  const $errorText = $(".form-error-custom");
  $errorText.hide();

  $submitBtn.on("click", function () {
    const $input = $("#hero_section_banner_img_validation");

    if ($input.is("[data-invalid]")) {
      $errorText.show();
    } else {
      $errorText.hide();
    }
  });
});
