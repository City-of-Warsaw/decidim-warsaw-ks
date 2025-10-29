$(document).ready(function () {
  $(".article .card__title").click(function () {
    if (!$(this).parent().hasClass("article--expanded")) {
      history.pushState(null, null, `#${$(this).data("url")}`);
    }

    $(this).parent().toggleClass("article--expanded");
    $(this).attr("aria-expanded", (_, attr) =>
      attr == "true" ? "false" : "true"
    );
  });

  $("[data-href]").click(function (e) {
    const href = $(this).data("href");

    window.location.href = href;
  });
});
