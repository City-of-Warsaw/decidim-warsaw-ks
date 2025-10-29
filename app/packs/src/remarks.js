function initReplyPanels(context = document) {
  $(context)
    .find('.button[data-controls^="panel-comment"]')
    .each(function () {
      const $button = $(this);
      const panelId = $button.attr("data-controls");
      const $panel = $("#" + panelId);
      const $grid = $button.closest(".remarks__footer-grid");

      $button.off("click.replyToggle");

      $panel.hide();
      $button.attr("aria-expanded", "false");
      $button.find("svg:last").hide();
      $button.find("span:last").hide();

      $button.on("click.replyToggle", function () {
        const isExpanded = $button.attr("aria-expanded") === "true";

        if (isExpanded) {
          $panel.slideUp(200);
          $grid.removeClass("reply-open");
        } else {
          $panel.slideDown(200);
          $grid.addClass("reply-open");
        }

        $button.attr("aria-expanded", String(!isExpanded));

        const $icons = $button.find("svg");
        const $texts = $button.find("span");

        if (!isExpanded) {
          $icons.first().hide();
          $texts.first().hide();
          $icons.last().show();
          $texts.last().show();
        } else {
          $icons.first().show();
          $texts.first().show();
          $icons.last().hide();
          $texts.last().hide();
        }
      });
    });
}

$(document).ready(function () {
  initReplyPanels();
});

document.addEventListener("ajax:loaded", ({ detail }) =>
  initReplyPanels(detail)
);

$("[type=reset]").on("click", function () {
  const $form = $(this).closest("form");

  $form.find(".MultiFile.MultiFile-applied").remove();
  $form.find(".MultiFile-list").html(``);
});

$(document).on("click", ".remove-file-btn", function (e) {
  e.preventDefault();

  const $li = $(this).closest("li");

  const $checkbox = $li.find(".remove-file-checkbox");
  $checkbox.prop("checked", true);

  $li.hide();
});
