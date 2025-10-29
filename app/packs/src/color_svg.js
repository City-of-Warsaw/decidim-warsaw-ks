document.addEventListener("DOMContentLoaded", function () {
  function applyCurrentColorToSVG() {
    document.querySelectorAll(".svg_color svg").forEach((svg) => {
      svg.querySelectorAll("[fill]").forEach((el) => {
        el.setAttribute("fill", svg.parentNode.getAttribute("data-color"));
      });
    });
  }
  applyCurrentColorToSVG();
});