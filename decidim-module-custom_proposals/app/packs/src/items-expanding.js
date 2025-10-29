$(document).ready(function () {
  $(document).off("click", ".collapsable-header");

  $(document).on("click", ".collapsable-header", function (e) {
    e.stopImmediatePropagation();
    e.preventDefault();

    $(`#${$(this).attr("aria-controls")}`).toggleClass("hide");

    var newState = $(this).attr("aria-expanded") === "true" ? "false" : "true";
    $(this).attr("aria-expanded", newState);
  });
});
