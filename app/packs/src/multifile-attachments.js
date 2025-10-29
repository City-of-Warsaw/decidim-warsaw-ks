import { DirectUpload } from "@rails/activestorage";
import Dropzone from "dropzone";

document.addEventListener("DOMContentLoaded", function() {
  const previewNode = document.querySelector("#multifile-attachments_template");
  previewNode.id = "";

  const previewTemplate = previewNode.parentNode.innerHTML;
  previewNode.parentNode.removeChild(previewNode);

  const tableWrapperDiv = document.querySelector("#multifile-attachments_previews").parentNode.parentNode;
  const submitButton = document.querySelector(".edit_attachment button[type=submit]");

  Dropzone.createElement = function(string) {
    var element = $(string);
    return element[0];
  }; 

  const dropzone = new Dropzone("div.multifile-attachments__dropzone", {
    paramName: "blob",
    autoProcessQueue: false, 
    previewTemplate: previewTemplate,
    previewsContainer: "#multifile-attachments_previews",
    clickable: [
      ".multifile-attachments__dropzone",
      ".multifile-attachments__dropzone-placeholder",
    ], 
    maxFilesize: $("div.multifile-attachments__dropzone").data("max-file-size"), 
    acceptedFiles: $("div.multifile-attachments__dropzone").data("allowed-extensions"),
    url: $("div.multifile-attachments__dropzone").data("url"),
    init: function () { 
      this.on("addedfile", async (file) => {
        $(tableWrapperDiv).removeClass("hidden");
        $(submitButton).attr("disabled", "disabled");
        dropzone.emit("uploadprogress", file, 20);
        Foundation.reInit('abide');

        const upload = new DirectUpload(file, $("div.multifile-attachments__dropzone").data("url"));
       
        upload.create((error, blob) => {
          if (error) {
            console.error("Direct upload error:", error);
            dropzone.emit("error", file, "Niedozwolony plik.");
          } else { 
            const hiddenField = document.createElement("input");
            hiddenField.setAttribute("type", "hidden");
            hiddenField.setAttribute("value", blob.signed_id);
            hiddenField.setAttribute("dz-added-file", file.upload.uuid);
            hiddenField.name = "attachments[files][]";

            document.querySelector(".edit_attachment").appendChild(hiddenField);  
          }

          $(submitButton).removeAttr("disabled");
          dropzone.emit("uploadprogress", file, 100);
        });      
      });

      this.on("removedfile", (file) => {        
        const hiddenField = document.querySelector(`input[type="hidden"][dz-added-file="${file.upload.uuid}"]`);
       
        if (hiddenField) {
          hiddenField.remove(); 

          if(this.files.length === 0) {
            $(tableWrapperDiv).addClass("hidden");  
          }  
        }
        
        Foundation.reInit('abide');
      });
    },
  });
});