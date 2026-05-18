// This file is compiled inside Decidim core pack. Code can be added here and will be executed
// as part of that pack

// Load images
require.context("../../images", true);

// TODO: upgrade v025! poprawic lub usunac - przywrocic pozostale z assets/javascripts/application.js
// require rails-ujs
// require activestorage
// require decidim
// require cable
import "src/multiselect/jquery.multiselect.modCS.js";
import "src/locations-map/autocomplete.min.js";
import "src/locations-map/leaflet-src.1.8.0.mod_cs.js";
import "src/locations-map/leaflet-gesture-handling.min.js";
import "src/locations-map/leaflet-active-area.js";
import "src/locations-map/leaflet.markercluster.js";
import "src/locations-map/polyfill.js";
import "src/galleries.js";
// require video.min
// require video-js-pl
import "src/jquery.mask.min.js";
// require "select2/select2.min"
// require "select2/pl"
import "src/jquery.MultiFile.js";
// require "decidim/plugins/foundation.abide.js"
import "src/locations-map/meetings-map.js";
import "src/decidim/avatar_placeholder";

$(document).ready(function () {
  if (
    $(".timeline-visibility-toggle-js, .custom-card-timeline-box").length > 0
  ) {
    $(".timeline-visibility-toggle-js, .custom-card-timeline-box").click(
      function () {
        const button = $(".timeline-visibility-toggle-js");
        const isShowed = button.hasClass("showed");

        button.toggleClass("showed").attr("aria-expanded", !isShowed);
        button
          .contents()
          .filter(function () {
            return this.nodeType === 3;
          })
          .first()
          .replaceWith(button.data(isShowed ? "show" : "hide"));
        button.blur();

        $(".custom-card-timeline-box .hideable").toggleClass("hide");
        $(".custom-card-timeline-box .sep-js").toggleClass("sep");
      },
    );
  }

  if ($(".projects-filters").length > 0) {
    $("select.multiple").multiselect({
      columns: 1,
      search: false,
      selectAll: true,
      placeholder: "Wybierz",
      showCheckbox: false,
      onLoad: function () {
        $(".multiselect-is-loading").removeClass("multiselect-is-loading");
      },
      texts: {
        search: "Szukaj",
        selectedOptions: "Wybrano",
        selectAll: "Zaznacz wszystkie",
        unselectAll: "Odznacz wszystkie",
        noneSelected: "Nie zaznaczono",
      },
    });

    $("select.multiple-only-one").multiselect({
      columns: 1,
      search: false,
      selectAll: false,
      placeholder: "Wybierz",
      showCheckbox: false,
      texts: {
        search: "Szukaj",
        selectedOptions: "Wybrano",
        selectAll: "Zaznacz wszystkie",
        unselectAll: "Odznacz wszystkie",
        noneSelected: "Nie zaznaczono",
      },
      onOptionClick: function (element, option) {
        var maxSelect = 1;

        // too many selected, deselect this option
        if ($(element).val().length > maxSelect) {
          if ($(option).is(":checked")) {
            var thisVals = $(element).val();

            thisVals.splice(thisVals.indexOf($(option).val()), 1);

            $(element).val(thisVals);

            $(option)
              .prop("checked", false)
              .closest("li")
              .toggleClass("selected");
          }
        }
        // max select reached, disable non-checked checkboxes
        else if ($(element).val().length == maxSelect) {
          $(element)
            .next(".ms-options-wrap")
            .find("li:not(.selected)")
            .addClass("disabled")
            .find('input[type="checkbox"]')
            .attr("disabled", "disabled");
        }
        // max select not reached, make sure any disabled
        // checkboxes are available
        else {
          $(element)
            .next(".ms-options-wrap")
            .find("li.disabled")
            .removeClass("disabled")
            .find('input[type="checkbox"]')
            .removeAttr("disabled");
        }
      },
    });

    $(".projects-filters .filters-visibility-toggler-js").click(function (e) {
      e.preventDefault();

      if ($(this).hasClass("showed")) {
        $(this).removeClass("showed");
        $(this).html($(this).data("show"));
        $(this).attr("aria-expanded", "false");
      } else {
        $(this).addClass("showed");
        $(this).html($(this).data("hide"));
        $(this).attr("aria-expanded", "true");
      }

      $(".select-row .hideable").each(function () {
        $(this).toggleClass("hide");
        $(".select-row").toggleClass("expanded");
      });
    });
  }

  $(".tabs-title-toggle-js").click(function (e) {
    $(".side-panel__tabs .tabs-title.is-active").siblings().toggle();
  });

  $("[data-decidim-map]").on("configure.decidim", (_ev, map, mapConfig) => {
    map.options.gestureHandlingOptions = { duration: 1000 };
    map.gestureHandling.enable();
  });

  var hash = $(location).attr("hash");
  if (hash === "subcontent") {
    let subcontentElement = document.getElementById("subcontent");
    subcontentElement && subcontentElement.scrollTo({ top: 0 });
  }

  function getUrlParameter(sParam) {
    var sPageURL = window.location.search.substring(1),
      sURLVariables = sPageURL.split("&"),
      sParameterName,
      i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split("=");

      if (sParameterName[0] === sParam) {
        return sParameterName[1] === undefined
          ? true
          : decodeURIComponent(sParameterName[1]);
      }
    }
    return false;
  }

  var proposalId = getUrlParameter("proposal_id");

  if (proposalId) {
    let proposalElement = document.getElementById(`proposal-${proposalId}`);

    if (proposalElement) {
      proposalElement?.classList.remove("hide");

      proposalElement.scrollIntoView({ block: "top" });
    }
  }

  // TODO: upgrade v025! poprawic lub usunac
  // $("select:not([multiple=multiple])").select2({
  //   minimumResultsForSearch: Infinity,
  // });

  $("input[type=file].multifile")
    .not(".MultiFile-applied")
    .not(".multifile--study-note-form")
    .not(".multifile--general-plan-request-form")
    .MultiFile({
      max: 5,
      STRING: {
        remove: "usuń",
        denied: "Ten format pliku $ext jest niedozwolony.",
        file: "$file",
        selected: "Wybrany plik: $file",
        duplicate: "Ten plik już został wybrany:\n$file",
        toomuch: "Łączny rozmiar plików przekracza limit ($size)",
        toomany: "Niedozwolona liczba plików (maks: $max)",
        toobig: "$file ma za duży rozmiar (maks: $size)",
      },
    });

  $(".attachment-button-js")
    .not(".AttachmentButton-applied")
    .each(function () {
      $(this).addClass("AttachmentButton-applied");
    })
    .click(function (e) {
      e.preventDefault();

      var target_id = $(this).data("target");
      $(this)
        .closest("div")
        .find(target_id + " > input")
        .last()
        .click();
    });

  $(document).on("formvalid.zf.abide", function (ev, frm) {
    $(frm)
      .not("#register-form")
      .find("button[type=submit]")
      .attr("disabled", "true");
  });

  $(document).on("open.zf.reveal", function (ev, el) {
    $("header, main, footer").attr("aria-hidden", "true");
  });

  $(document).on("closed.zf.reveal", function (ev, el) {
    $("header, main, footer").removeAttr("aria-hidden");
  });

  $("[data-href]").click(function (e) {
    const href = $(this).data("href");

    window.location.href = href;
  });

  $(".mobile-skip--menu").click(function (e) {
    e.preventDefault();
    $(".mobile-menu-toggle-js").focus();
  });

  $(".mobile-skip--search").click(function (e) {
    e.preventDefault();
    $("#offCanvas").foundation("toggle");
    setTimeout(() => $("#term_mobile").focus(), 500);
  });

  $(".skip").click(function () {
    const targetEl = $($(this).attr("href"));
    setTimeout(
      () =>
        targetEl
          .find(
            'button, a, input:not([type="hidden"]), select, textarea, [tabindex]:not([tabindex="-1"])',
          )
          .eq(0)
          .focus(),
      100,
    );
  });

  $(".form-tooltip__hint").on("keydown", function (e) {
    if (e.which == 27) {
      $(this).blur();
    }
  });

  $(".cookie-bar__button").on("click", function () {
    $(".logo-wrapper > a").focus();
  });

  $(".off-canvas--mobile-menu").on("closed.zf.offCanvas", function (e) {
    e.preventDefault();
    $(".mobile-menu-toggle-js").focus();
  });

  $("ul")
    .filter(function () {
      return (
        $(this).css("list-style-type") === "none" &&
        $(this).attr("role") === undefined
      );
    })
    .each(function () {
      $(this).attr("role", "list");
    });

  // initialize TipTap editor for public page
  function initializeEditors() {
    var $containers = $(".editor-container").not(":has(.ProseMirror)");

    if ($containers.length > 0 && typeof window.createEditor === "function") {
      $containers.each(function (index) {
        try {
          window.createEditor(this);
        } catch (error) {
          console.warn("Editor initialization error:", error);
        }
      });
    }
  }

  initializeEditors();
  $(document).on("turbo:load", initializeEditors);

  // initialize TipTap editor for dynamically added services in meetings
  $(".add-service").on("click", function () {
    setTimeout(function () {
      var $newContainers = $(".editor-container").not(":has(.ProseMirror)");

      if ($newContainers.length > 0) {
        $newContainers.each(function (index) {
          if (typeof window.createEditor === "function") {
            try {
              window.createEditor(this);
            } catch (error) {
              console.warn("Editor initialization error:", error);
            }
          }
        });
      }
    }, 500);
  });

  $("input[data-maxlength], textarea[data-maxlength]").each((_i, elem) => {
    const $input = $(elem);

    $input.data(
      "remaining-characters-counter",
      new window.Decidim.InputCharacterCounter($input),
    );
  });
});

// Fix broken ARIA role on dropdowns.
// The a11y-dropdown-component library incorrectly assigns role="menu" to the
// dropdown target, but these elements contain navigation links or action items
// without the required role="menuitem" children, causing a broken ARIA menu.
document.addEventListener("DOMContentLoaded", () => {
  setTimeout(() => {
    const dropdowns = document.querySelectorAll(
      "[id^='dropdown-menu-'], [id^='secondary-dropdown-menu']",
    );
    dropdowns.forEach((el) => {
      el.removeAttribute("role");
      el.removeAttribute("aria-labelledby");
    });
  }, 300);
});
