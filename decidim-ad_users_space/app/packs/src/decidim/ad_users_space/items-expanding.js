$(document).ready(function () {
  $(".article .card__title").click(function () {
    if (!$(this).parent().hasClass("article--expanded"))
      history.pushState(null, null, `#${$(this).data("url")}`);

    $(this).parent().toggleClass("article--expanded");
    $(this).attr("aria-expanded", (_, attr) =>
      attr == "true" ? "false" : "true"
    );
  });

  if (window.location.hash) {
    $(window.location.hash).parent().toggleClass("article--expanded");
    $(window.location.hash).attr("aria-expanded", true);
  }
});
