function checkPasswordStrength() {
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

    ruleElement.querySelector(".password-rule-result-text").innerHTML =
      " poprawnie";
  }

  function setErrorForRule(ruleElement) {
    ruleElement.classList.remove(ruleSuccessClass);
    ruleElement.classList.add(ruleErrorClass);

    ruleElement.querySelector(".password-rule-result-text").innerHTML =
      " niepoprawnie";
  }

  checkIfTenChar(text) ? setSuccessForRule(length) : setErrorForRule(length);

  checkIfOneLowercase(text)
    ? setSuccessForRule(lowercase)
    : setErrorForRule(lowercase);

  checkIfOneUppercase(text)
    ? setSuccessForRule(uppercase)
    : setErrorForRule(uppercase);
  checkIfOneDigit(text) ? setSuccessForRule(number) : setErrorForRule(number);
  checkIfOneSpecialChar(text)
    ? setSuccessForRule(special)
    : setErrorForRule(special);
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
  return /[~`!@#$%\^&*+=\-\[\]\\';,/{}|\\":<>\?]/g.test(text);
}

let passwordField = $(".password-field-js");

checkPasswordStrength();
passwordField.keyup(checkPasswordStrength);

$(".form-error.password-field-error-js").html(
  $(".form-error.password-field-js").html()
);
$(".form-error.password-field-js").html("");
