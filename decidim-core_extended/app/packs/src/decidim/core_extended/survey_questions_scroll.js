$(document).ready(function () {
  function scrollToMenuBar() {
    const $menuBar = $("#menu-bar-container");
    if ($menuBar.length) {
      $("html, body").animate(
        {
          scrollTop: $menuBar.offset().top,
        },
        400
      );
    } else {
      $("html, body").animate({ scrollTop: 0 }, 400);
    }
  }

  $(document).on(
    "click",
    ".answer-questionnaire__footer [data-toggle]",
    function () {
      setTimeout(scrollToMenuBar, 100);
    }
  );
});
