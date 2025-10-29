$(document).ready(function () {
  $(".ssb-icon").removeAttr("onclick");
  $(".ssb-icon").click((event) => SocialShareButton.share(event.currentTarget));

  $(document).ready(function () {
    function focusShareWhenModalClose() {
      $(".share-link.button.text-center").focus();
    }

    $(".close-button[data-close]").on("click", function () {
      focusShareWhenModalClose();
      $(".copy-area__feedback").hide();
    });

    $(document).on("closed.zf.reveal", "#urlShare", function () {
      $(".copy-area__feedback").hide();
    });

    $(".copy-area__input").attr("title", "Skopiuj link");
    $(".ssb-twitter").attr("title", "Udostępnij na X");

    $(".copy-area__input").on("click", function () {
      const feedback = $(this).next(".copy-area__feedback");
      feedback.hide();
      $(this).select();
      document.execCommand("copy");
      feedback.show();
    });
  });
});
