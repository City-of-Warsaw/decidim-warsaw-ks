import "src/jquery.swipebox.js";

// Insert images from .fix-swipebox into <a> element for swipebox,
// this is fix images-base64 (from ql-editor) and for normal img elements
function fixSwipeboxGallery() {
  $(".fix-swipebox").each(function (gI) {
    $(this)
      .find("img")
      .each(function (i) {
        var outerLink = $("<a />", {
          id: "image-id-" + i,
          name: "link",
          class: "swipebox",
          rel: "gallery-id-" + gI,
          href: this.src,
          title: this.dataset.description || "",
          "data-description": this.dataset.description || "",
          html: this.outerHTML,
        });
        $(this).replaceWith(outerLink);
      });
  });
}

$(document).ready(function () {
  fixSwipeboxGallery();

  $(".swipebox").swipebox({
    useCSS: true, // false will force the use of jQuery for animations
    useSVG: false, // false to force the use of png for buttons
    afterOpen: function () {
      $("#swipebox-overlay")
        .off("click.close-overlay")
        .on("click.close-overlay", function (e) {
          var isDirectOverlayClick = e.target.id === "swipebox-overlay";
          var isSlideClick =
            $(e.target).hasClass("slide") ||
            $(e.target).closest(".slide").length > 0;
          var isImageClick = e.target.tagName === "IMG";
          var isButtonClick =
            $(e.target).closest(
              "#swipebox-prev, #swipebox-next, #swipebox-close"
            ).length > 0;

          if (
            isDirectOverlayClick ||
            (!isImageClick && !isButtonClick && isSlideClick)
          ) {
            $("#swipebox-close").trigger("click");
          }
        });
    },
    afterClose: function () {
      $(document).off("click.swipebox-overlay-backup");
    },
    // initialIndexOnArray : 0, // which image index to init when a array is passed
    // hideCloseButtonOnMobile : false, // true will hide the close button on mobile devices
    // removeBarsOnMobile : true, // false will show top bar on mobile devices
    // hideBarsDelay : 3000, // delay before hiding bars on desktop
    // videoMaxWidth : 1140, // videos max width
    // beforeOpen: function() {}, // called before opening
    // loopAtEnd: false // true will return to the first image after the last image is reached
  });
});
