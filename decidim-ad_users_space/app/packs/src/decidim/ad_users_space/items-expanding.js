$(document).ready(function () {
  $(".article .card__title").click(function () {
    if (!$(this).parent().hasClass("article--expanded"))
      history.pushState(null, null, `#${$(this).data("url")}`);

    $(this).parent().toggleClass("article--expanded");
    $(this).attr("aria-expanded", (_, attr) =>
      attr == "true" ? "false" : "true",
    );
  });

  if (window.location.hash) {
    var $target = $(window.location.hash);
    if ($target.length && !$target.parent().hasClass("article--expanded")) {
      $target.parent().addClass("article--expanded");
      $target.attr("aria-expanded", "true");
    }
  }
});
