import "src/locations-map/autocomplete.min.js";
import "src/locations-map/leaflet-src.1.8.0.mod_cs.js";
import "src/locations-map/leaflet-gesture-handling.min.js";
import "src/locations-map/polyfill.js"; 
import "src/geojson-map/leaflet.draw.modCS.js";
// TODO: upgrade v025! poprawic lub usunac - przywrocic pozostale skrypty
// require jquery-ui/widgets/sortable
// require decidim/quill.dynamic-tools
// require decidim/quill.style-toolbar-tool
// require decidim/quill.image-toolbar-tool
// require decidim/quill.repository-image-toolbar-tool
// require decidim/quill.extended-image-embed
// require decidim/quill.extended-video-embed
// require decidim/quill.divider-embed
// require decidim/quill.link
// require decidim/quill.button
// require decidim/quill.html-custom

// TODO: upgrade v025! poprawic lub usunac
//   select2 zostal tymczasowo dodany z CDN
// import "src/select2/select2.min";
// import "src/select2/pl";

$(document).ready(function () {
  // $(window).keydown(function(event){
  $("input#search").keydown(function (event) {
    if (event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });

  // only when form validation failed
  $("form[data-abide=true]").on("forminvalid.zf.abide", function (ev, el) {
    let options = {
      behavior: "smooth",
      block: "center",
    };
    if ($(".is-invalid-label").length)
      $(".is-invalid-label")[0].scrollIntoView(options);
  });

  /* IMAGE PREVIEW */
  const SUPPORTED_IMAGE_FIELDS = [
    "organization_highlighted_content_banner_image",
    "organization_favicon",
    "organization_logo",
    "content_block_images_background_image",
    "participatory_process_hero_image",
    "newsletter_images_main_image",
    "hero_section_banner_img",
  ];
  const fileInputs = document.querySelectorAll("input[type=file]");

  fileInputs.forEach((fileInput) => {
    if (!SUPPORTED_IMAGE_FIELDS.includes(fileInput.id)) return false;

    let imagePreview = document.createElement("img");
    let imagePreviewLabel = document.createElement("label");

    imagePreviewLabel.innerHTML = "Podgląd nowego obrazu";
    imagePreviewLabel.style.display = "none";
    imagePreview.style.display = "none";

    fileInput.after(imagePreviewLabel, imagePreview);

    fileInput.addEventListener("change", (event) => {
      const file = event.target.files[0];

      let fileReader = new FileReader();
      fileReader.readAsDataURL(file);
      fileReader.onload = function () {
        imagePreview.style.display = "block";
        imagePreview.style.height = "auto";
        imagePreview.style.width = "fit-content";
        imagePreviewLabel.style.display = "block";
        imagePreviewLabel.style.marginTop = "0px";
        imagePreview.setAttribute("class", "image-preview mb-xs mt-xs");
        imagePreview.setAttribute("src", fileReader.result);
        $(imagePreview).nextAll().hide();
      };
    });
  });

  meetingsMapSettingsToggler();
  toggleComponentsGlobalSettingsHelpSectionVisibility();

  $(
    ".upload-modal__files-container.upload-container-for-background_image button"
  ).addClass("button button__sm button__primary !mt-2");
});

function meetingsMapSettingsToggler() {
  if (
    document.querySelectorAll(".meetings-selection-js input[type=radio]")
      .length === 0
  ) {
    return;
  }

  // Function to toggle the visibility of the fields based on the selected radio button
  function toggleMeetingsMapSettingsVisibility() {
    var radioValue = document.querySelector(
      ".meetings-selection-js input[type=radio]:checked"
    ).value;

    // Toggle visibility based on the selected radio button
    if (radioValue === "five_meetings") {
      document.querySelector(".five-meetings-selection-js").style.display =
        "block";
    } else {
      document.querySelector(".five-meetings-selection-js").style.display =
        "none";
    }
  }

  // Attach the function to the change event of the radio buttons
  var radioButtons = document.querySelectorAll(
    ".meetings-selection-js input[type=radio]"
  );

  radioButtons.forEach(function (radioButton) {
    radioButton.addEventListener("change", toggleMeetingsMapSettingsVisibility);
  });

  // Call the function initially to set the initial visibility state
  toggleMeetingsMapSettingsVisibility();
}

function applyCurrentColorToSVG(color) {
  document.querySelectorAll(".schedule__item-icon svg").forEach((svg) => {
    svg.querySelectorAll("style").forEach((el) => {
      if (el.textContent.includes("fill:")) {
        el.remove();
      }
    });

    svg.querySelectorAll("[fill]").forEach((el) => {
      el.setAttribute("fill", color);
    });
  });
}

function toggleComponentsGlobalSettingsHelpSectionVisibility() {
  var checkbox = document.querySelector(
    ".help_section_visibility_container input[type=checkbox]"
  );

  if (!checkbox) {
    return;
  }

  // Hide help section form fields initially if in present component, there is no help section visibility
  if (checkbox.checked === false) {
    document.querySelector(".help_section_title_container").style.display =
      "none";
    document.querySelector(".help_section_subtitle_container").style.display =
      "none";
    document.querySelector(
      ".help_section_description_container"
    ).style.display = "none";
  }

  checkbox.addEventListener("change", function (event) {
    if (event.target.checked === true) {
      document.querySelector(".help_section_title_container").style.display =
        "block";
      document.querySelector(".help_section_subtitle_container").style.display =
        "block";
      document.querySelector(
        ".help_section_description_container"
      ).style.display = "block";
    } else {
      document.querySelector(".help_section_title_container").style.display =
        "none";
      document.querySelector(".help_section_subtitle_container").style.display =
        "none";
      document.querySelector(
        ".help_section_description_container"
      ).style.display = "none";
    }
  });
}
