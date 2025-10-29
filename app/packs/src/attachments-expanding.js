$(document).ready(function () {
  $(".attachment-collection .card__title").click(function () {
    $(this).parent().toggleClass("attachment-collection--expanded");
    $(this).attr("aria-expanded", (_, attr) =>
      attr == "true" ? "false" : "true"
    );
  });
});
