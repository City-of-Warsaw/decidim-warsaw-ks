//= require "jquery.swipebox.js"

// Insert images from .fix-swipebox into <a> element for swipebox,
// this is fix images-base64 (from ql-editor) and for normal img elements
function fixSwipeboxGallery() {
  $('.fix-swipebox img').each(function(i) {
    var outerLink = $("<a />", {
      id : "image-id-" + i,
      name : "link",
      class : "swipebox",
      href : this.src,
      html : this.outerHTML
    });
    $(this).replaceWith(outerLink);
  });
}

$(document).ready(function() {

  fixSwipeboxGallery();

  $('.swipebox').swipebox({
    useCSS : true, // false will force the use of jQuery for animations
    useSVG : false, // false to force the use of png for buttons
    // initialIndexOnArray : 0, // which image index to init when a array is passed
    // hideCloseButtonOnMobile : false, // true will hide the close button on mobile devices
    // removeBarsOnMobile : true, // false will show top bar on mobile devices
    // hideBarsDelay : 3000, // delay before hiding bars on desktop
    // videoMaxWidth : 1140, // videos max width
    // beforeOpen: function() {}, // called before opening
    // afterOpen: null, // called after opening
    // afterClose: function() {}, // called after closing
    // loopAtEnd: false // true will return to the first image after the last image is reached
  });
});