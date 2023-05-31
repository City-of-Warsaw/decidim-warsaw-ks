// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require decidim
//= require cable
//= require jquery.multiselect.modCS
//= require "locations-map/autocomplete.min.js"
//= require "locations-map/leaflet-src.1.8.0.modCS.js"
//= require "locations-map/leaflet-gesture-handling.min.js"
//= require "locations-map/leaflet-active-area.js"
//= require "locations-map/leaflet.markercluster.js"
//= require "locations-map/polyfill.js"
//= require "galleries.js"
//= require video.min
//= require video-js-pl
//= require jquery.mask.min
//= require "select2/select2.min"
//= require "select2/pl"
//= require jquery.MultiFile

$(document).ready(function () {
  if ($(".timeline-visibility-toggle-js").length > 0) {
    $(".timeline-visibility-toggle-js").click(function () {
      if ($(this).hasClass("showed")) {
        $(this).removeClass("showed");
        $(this).text($(this).data("show"));
      } else {
        $(this).addClass("showed");
        $(this).text($(this).data("hide"));
      }

      $(this).blur();
      $(".timeline-box .hideable").each(function () {
        $(this).toggleClass("hide");
      });

      $(".timeline-box .sep-js").each(function () {
        $(this).toggleClass("sep");
      });
    });
  }

  if ($(".projects-filters").length > 0) {
    $("select.multiple").multiselect({
      columns: 1,
      search: false,
      selectAll: true,
      placeholder: "Wybierz",
      showCheckbox: false,
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
        $(this).text($(this).data("show"));
        $(this).attr("aria-expanded", "false");
      } else {
        $(this).addClass("showed");
        $(this).text($(this).data("hide"));
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

  L.Map.addInitHook(
    "addHandler",
    "gestureHandling",
    leafletGestureHandling.GestureHandling
  );

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

  var commentId = getUrlParameter("highlighted");
 
  if (commentId) {
    let commentElement = document.getElementById(`comment_${commentId}`);
    if (!commentElement) commentElement = document.getElementById(`remark_${commentId}`);

    if (commentElement) { 
      commentElement.closest(".hide")?.classList.remove("hide"); 

      commentElement.scrollIntoView({ block: "center" });
      commentElement.style.backgroundColor = "#1b7c971c";
      
      setTimeout(() => {
        commentElement.style.transition = "all 1000ms ease";
        commentElement.style.backgroundColor = "";
      }, 2000);
    }
  }

  var proposalId = getUrlParameter("proposal_id");
 
  if (proposalId) {
    let proposalElement = document.getElementById(`proposal-${proposalId}`); 

    if (proposalElement) { 
      proposalElement?.classList.remove("hide"); 

      proposalElement.scrollIntoView({ block: "top" }); 
    }
  }

  $("select:not([multiple=multiple])").select2({
    minimumResultsForSearch: Infinity,
  });

  $("input[type=file].multifile").not(".MultiFile-applied").not(".multifile--study-note-form").MultiFile({
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

  $(".attachment-button-js").not(".AttachmentButton-applied").click(function (e) {
    e.preventDefault();

    $(this).addClass("AttachmentButton-applied");

    var target_id = $(this).data("target");
    $(this).closest("div").find(target_id + " > input")
      .last()
      .click();
  });
});
