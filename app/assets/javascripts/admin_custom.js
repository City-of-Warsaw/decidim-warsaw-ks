//= require "locations-map/autocomplete.min.js"
//= require "locations-map/leaflet-src.1.8.0.modCS.js"
//= require "locations-map/leaflet-gesture-handling.min.js"
//= require "locations-map/polyfill.js"
//= require "area-map/leaflet-area-selection.js"
//= require jquery-ui/widgets/sortable
//= require decidim/quill.dynamic-tools
//= require decidim/quill.style-toolbar-tool
//= require decidim/quill.image-toolbar-tool
//= require decidim/quill.repository-image-toolbar-tool
//= require decidim/quill.extended-image-embed
//= require decidim/quill.extended-video-embed
//= require decidim/quill.divider-embed
//= require "select2/select2.min"
//= require "select2/pl"

$(document).ready(function() {
  // $(window).keydown(function(event){
  $('input#search').keydown(function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });


  // only when form validation failed
  $('form[data-abide=true]').on("forminvalid.zf.abide", function(ev,el) {
    let options = {
      behavior: "smooth",
      block: "center"
    }
    $(".is-invalid-label")[0].scrollIntoView(options);
  });

  /* IMAGE PREVIEW */
  const SUPPORTED_IMAGE_FIELDS = ["organization_highlighted_content_banner_image", "organization_favicon","organization_logo","content_block_images_background_image", "participatory_process_hero_image", "newsletter_images_main_image"];
  const fileInputs = document.querySelectorAll('input[type=file]'); 

  fileInputs.forEach((fileInput) => { 
    if (!SUPPORTED_IMAGE_FIELDS.includes(fileInput.id)) return false;

    let imagePreview = document.createElement("img");
    let imagePreviewLabel = document.createElement("label");

    imagePreviewLabel.innerHTML = "Podgląd nowego obrazu";
    imagePreviewLabel.style.display = "none";
    imagePreview.style.display = "none";

    fileInput.after(imagePreviewLabel, imagePreview);

    fileInput.addEventListener('change', (event) =>{
      const file = event.target.files[0]; 

      let fileReader = new FileReader();
      fileReader.readAsDataURL(file);
      fileReader.onload = function (){
        imagePreview.style.display = "block";
        imagePreview.style.height = "auto";
        imagePreview.style.width = "fit-content";
        imagePreviewLabel.style.display = "block";
        imagePreviewLabel.style.marginTop = "0px";
        imagePreview.setAttribute('class', "image-preview mb-xs mt-xs");
        imagePreview.setAttribute('src', fileReader.result); 
        $(imagePreview).nextAll().hide();
      }
    })
  })

});
