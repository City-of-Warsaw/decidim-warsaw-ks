function greaterAndLowerThan($el, required, parent) {
  if (!$el.val()) return true;

  var from = $el.attr("data-greater-than"),
    to = $el.attr("data-lower-than"),
    val = $el.val();
  return parseInt(val) > parseInt(from) && parseInt(val) <= parseInt(to);
}

function strongPassword($el) {
  if (!$el.val()) return true;

  var text = $el.val();

  return (
    text.length >= 10 &&
    /[a-z]/.test(text) &&
    /[A-Z]/.test(text) &&
    /[0-9]/.test(text) &&
    /[~`!@#$%\^&*+=\-\[\]\\';,/{}|\\":<>\?]/g.test(text)
  );
}

Foundation.Abide.defaults.validators["greater_and_lower_than"] =
  greaterAndLowerThan;
Foundation.Abide.defaults.validators["strong_password"] = strongPassword;

$("#registration_user_name").focusout(function (e) {
  let value = $(this).val();
  let href = $(this).data("href");
  let info_prefix = $(".user-nickname .prefix");
  let info_container = $(".user-nickname-usage-msg");

  if (value != "") {
    $.post(
      href,
      { _method: "get", remote: true, nickname: value },
      function (data) {
        $.globalEval(data, {
          nonce: $("meta[name=csp-nonce]").attr("content"),
        });
      },
      "text"
    );
  } else {
    info_prefix.removeClass("success").removeClass("alert");
    info_prefix.attr("title", "");
    info_container.removeClass("success").removeClass("alert");
    info_container.text("");
  }
});

$(function () {
  $("#registration_user_zip_code").mask("00-000");
  $("#registration_user_birth_year").mask("0000");

  $(".scopes-ids-select-js").multiselect({
    columns: window.innerWidth < 400 ? 1 : 3,
    search: false,
    selectAll: true,
    placeholder: "Wybierz",
    showCheckbox: false,
    texts: {
      search: "Szukaj",
      selectedOptions: " wybrano",
      selectAll: "Zaznacz wszystkie",
      unselectAll: "Odznacz wszystkie",
      noneSelected: "Nie zaznaczono",
    },
    // onControlClose: function (el) {
    //   $(el).parents('form').submit();
    // },
  });

  $(".tags-ids-select-js").multiselect({
    columns: window.innerWidth < 400 ? 1 : 3,
    search: false,
    selectAll: true,
    placeholder: "Wybierz",
    showCheckbox: false,
    texts: {
      search: "Szukaj",
      selectedOptions: " wybrano",
      selectAll: "Zaznacz wszystkie",
      unselectAll: "Odznacz wszystkie",
      noneSelected: "Nie zaznaczono",
    },
    // onControlClose: function (el) {
    //   $(el).parents('form').submit();
    // },
  });
});

$(".button-next-step-js").click(function () {
  $("#register-form").on("formvalid.zf.abide", function (ev, frm) {
    $(".step-1").hide();
    $(".step-2").show();

    $(".menu-bar")[0].scrollIntoView({
      behavior: "smooth",
      block: "start",
    });
  });

  $("#register-form").foundation("validateForm");
});

$(".button-previous-step-js").click(function () {
  $(".step-1").show();
  $(".step-2").hide();

  $(".menu-bar")[0].scrollIntoView({
    behavior: "smooth",
    block: "start",
  });
});

$(".password-field .peek-password").click(function (e) {
  const input = $(this).parent().find("input");

  $(this).toggleClass("activated");

  if (input.attr("type") === "password") {
    input.attr("type", "text");
    $(this).attr(
      "aria-label",
      `Ukryj${
        $(this).hasClass("peek-password--confirmation") ? " powtórzone" : ""
      } hasło`
    );
  } else {
    input.attr("type", "password");

    $(this).attr(
      "aria-label",
      `Pokaż${
        $(this).hasClass("peek-password--confirmation") ? " powtórzone" : ""
      } hasło`
    );
  }
});

$(document).ready(function () {
  const $link = $(".tos-agreement-disclaimer .external-link-container");
  if ($link.length) {
    $link.html($link.html().replace(/&nbsp;/g, " "));
  }
});
