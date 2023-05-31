let isCorrectPassword = false,
  isSamePasswordEntered = false;

function checkPasswordStrength() {
  // TODO: usunąć on key up
  var password = $(".password-field-js");
  var text = $(".password-field-js").val();

  if (text.length === 0) return false;

  var length = document.getElementById("length");
  var lowercase = document.getElementById("lowercase");
  var uppercase = document.getElementById("uppercase");
  var number = document.getElementById("number");
  var special = document.getElementById("special");

  var ruleSuccessClass = "password-rule-success";
  var ruleErrorClass = "password-rule-error";

  function setSuccessForRule(ruleElement) {
    ruleElement.classList.add(ruleSuccessClass);
    ruleElement.classList.remove(ruleErrorClass);

    ruleElement.querySelector(".password-rule-result-text").innerHTML = " poprawnie";
  }

  function setErrorForRule(ruleElement) {
    ruleElement.classList.remove(ruleSuccessClass);
    ruleElement.classList.add(ruleErrorClass);

    ruleElement.querySelector(".password-rule-result-text").innerHTML = " niepoprawnie";
  }

  checkIfTenChar(text)
    ? setSuccessForRule(length)
    : setErrorForRule(length);

  checkIfOneLowercase(text)
    ? setSuccessForRule(lowercase)
    : setErrorForRule(lowercase);

  checkIfOneUppercase(text)
    ? setSuccessForRule(uppercase)
    : setErrorForRule(uppercase);
  checkIfOneDigit(text)
    ? setSuccessForRule(number)
    : setErrorForRule(number);
  checkIfOneSpecialChar(text)
    ? setSuccessForRule(special)
    : setErrorForRule(special);
 
  var final_score =
    checkIfTenChar(text) &&
    checkIfOneLowercase(text) &&
    checkIfOneUppercase(text) &&
    checkIfOneDigit(text) &&
    checkIfOneSpecialChar(text);
  if (final_score) {
    isCorrectPassword = true;
    $("#registration_user_password").removeClass("is-invalid-input");
  } else {
    isCorrectPassword = false;
    $("#registration_user_password").addClass("is-invalid-input");
  }

  checkPasswordConfirmation();

  if (isCorrectPassword && isSamePasswordEntered) {
    $(password.parents("form")[0])
      .find(".button-next-step-js")
      .removeAttr("disabled");
  } else {
    $(password.parents("form")[0])
      .find(".button-next-step-js")
      .attr("disabled", "true");
  }
}

function checkIfTenChar(text) {
  return text.length >= 10;
}

function checkIfOneLowercase(text) {
  return /[a-z]/.test(text);
}

function checkIfOneUppercase(text) {
  return /[A-Z]/.test(text);
}

function checkIfOneDigit(text) {
  return /[0-9]/.test(text);
}

function checkIfOneSpecialChar(text) {
  return /[~`!#$%\^&*+=\-\[\]\\';,/{}|\\":<>\?]/g.test(text);
}

function checkPasswordConfirmation() {
  var password = $(".password-field-js");
  var passwordConfirmation = $(".password-confirmation-field-js");
  $(".passwordConfirmationMsg").remove();

  var msg = $("<span></span>").addClass("passwordConfirmationMsg");

  if (
    passwordConfirmation.val() === password.val() &&
    password.val().length > 0
  ) {
    msg.html("Hasła zgadzają się").removeClass("form-error");
    isSamePasswordEntered = true;
  } else if (
    password.val().length > 0 &&
    passwordConfirmation.val().length > 0
  ) {
    msg.html("Hasła w obu polach muszą być identyczne").addClass("form-error");
    isSamePasswordEntered = false;
  }

  passwordConfirmation.parent().append(msg);

  if (isCorrectPassword && isSamePasswordEntered) {
    $(password.parents("form")[0])
      .find(".button-next-step-js")
      .removeAttr("disabled");
  } else {
    $(password.parents("form")[0])
      .find(".button-next-step-js")
      .attr("disabled", "true");
  }
}
