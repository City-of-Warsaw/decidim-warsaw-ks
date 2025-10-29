$(document).ready(function () {
  $("input[type=file].multifile")
    .not(".MultiFile-applied")
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

  function moveSubmitButtons() {
    if ($(window).width() <= 640) {
      $(".answer-questionnaire__submit > .button.primary-action").each(
        function (element) {
          $(this).prependTo($(this).parent());
        }
      );
    } else {
      $(".answer-questionnaire__submit > .button.primary-action").each(
        function (element) {
          $(this).appendTo($(this).parent());
        }
      );
    }
  }

  $(window).on("resize", moveSubmitButtons);
  moveSubmitButtons();

  $("[data-toggle]").on("click", function (e) {
    const targetStep = $(`#${$(this).data("toggle").split(" ")[0]}`);
    targetStep.focus();
  });

  $(".sortable-check-box-collection input[type=checkbox]").on(
    "change",
    function (e) {
      e.target.focus();
    }
  );

  $(".check-box-collection .collection-input input[type=checkbox]").on(
    "change",
    function () {
      const $textInput = $(this)
        .closest(".collection-input")
        .find("input[type=text]");

      if (!this.checked) {
        $textInput.val("");
      }

      $textInput.prop("disabled", !this.checked);
    }
  );
});
