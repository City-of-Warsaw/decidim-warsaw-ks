$(document).ready(function () {
  $("[data-href]").click(function (e) {
    const href = $(this).data("href");

    window.location.href = href;
  });

  $(".address").each(function () {
    const locationDiv = $(this).find(".address__location");

    if (
      locationDiv.length > 0 &&
      locationDiv.text().trim() === "" &&
      locationDiv.children().length === 0
    ) {
      $(this)
        .children()
        .each(function () {
          if ($(this).text().trim() === "" && $(this).children().length === 0) {
            $(this).remove();
          }
        });
    }
  });
});
