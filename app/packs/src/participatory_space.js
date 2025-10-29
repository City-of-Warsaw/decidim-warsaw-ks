$(document).ready(function () {
  $(".documents__collection-trigger").each(function () {
    const contentId = $(this).attr("aria-controls");
    const $content = $("#" + contentId);

    if ($content.length) {
      const $wrapper = $("<div>", { class: "documents__collection-wrapper" });
      $(this).before($wrapper);
      $wrapper.append($(this)).append($content);
    }
  });

  $('[id^="dropdown-documents-trigger-"]').each(function () {
    const idSuffix = this.id.replace("dropdown-documents-trigger-", "");
    const $content = $("#dropdown-menu-documents-" + idSuffix);
    const $container = $content.find(".documents__container");

    if ($container.length) {
      const count = $container.find("div[id^='attachment_']").length;
      const $labelSpan = $(this).find("span").first();
      $labelSpan.css("display", "block");
      $labelSpan.css("text-align", "left");
      let label;
      if (count === 1){
        label = "za\u0142\u0105cznik"
      } else if(count > 1 && count < 5) {
        label = "za\u0142\u0105czniki"
      } else if(count >= 5) {
        label = "za\u0142\u0105cznik\u00f3w"
      }
      const countText = `${count} ${label}`;

      if ($labelSpan.length) {
        $labelSpan.html(
          $labelSpan.html() +
            `<br><small class="count-text">${countText}</small>`
        );
      }
    }
  });

  function wrapTablesWithScrollContainer() {
    const $editorContent = $(".editor-content");

    if ($editorContent.length === 0) return;

    $editorContent.find("table").each(function () {
      const $table = $(this);

      if ($table.parent().hasClass("table-scroll-wrapper")) {
        return;
      }

      $table.wrap('<div class="table-scroll-wrapper"></div>');
    });
  }

  wrapTablesWithScrollContainer();
});
