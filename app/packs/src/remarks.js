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

function updateSingleRemarkFlashTexts(context = document) {
  $(context)
    .find('[id^="comments-for-Remark-"] > #comments')
    .each(function () {
      const $commentsRoot = $(this);

      const $flash = $commentsRoot.find(".flash").first();
      if ($flash.length) {
        $flash.css("background-color", "#F3F8FA");
      }

      const $title = $commentsRoot.find(".flash .flash__title").first();
      if ($title.length) {
        $title.text("Wyświetlasz teraz pojedynczy komentarz do uwagi");
      }

      const $message = $commentsRoot
        .find(".flash .flash__message.editor-content")
        .first();
      if ($message.length) {
        const $link = $message.find("a").first();
        if ($link.length) {
          $link.text("Zobacz wszystkie komentarze do tej uwagi");
          $link.css("color", "#020203");
        } else {
          $message.text("Zobacz wszystkie komentarze do tej uwagi");
        }
      }
    });
}

$(document).ready(function () {
  updateSingleRemarkFlashTexts();
});

document.addEventListener("ajax:loaded", ({ detail }) =>
  updateSingleRemarkFlashTexts(detail)
);
