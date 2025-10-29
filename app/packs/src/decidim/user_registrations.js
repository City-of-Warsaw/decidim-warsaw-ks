// overwritten decidim original file
// clean all logic for sign-up-newsletter-modal

import PasswordToggler from "src/decidim/password_toggler";

$(() => {
  const userPassword = document.querySelector(".user-password");

  if (userPassword) {
    new PasswordToggler(userPassword).init();
  }
});
