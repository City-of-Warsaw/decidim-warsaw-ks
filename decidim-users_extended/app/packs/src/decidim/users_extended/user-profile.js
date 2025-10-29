$(document).ready(function () {
  var originalAvatarButton = $("#user_avatar_button");
  var customAvatarButton = $("#custom_user_avatar_button");

  if (originalAvatarButton.length && customAvatarButton.length) {
    customAvatarButton.on("click", function (e) {
      e.preventDefault();
      originalAvatarButton.click();
    });
  }

  $(".change-password[tabindex=0]").on("keydown", function (event) {
    if (event.which == 32) {
      event.preventDefault();
      $(`#${$(this).data("toggle")}`).foundation("toggle");
    }
  });

  $("#user_zip_code").mask("00-000");
});
