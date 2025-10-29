document.addEventListener("DOMContentLoaded", () => {
  const links = document.querySelectorAll(".vertical-tab-link");
  const sections = document.querySelectorAll(".topic");

  const showSection = (targetId) => {
    sections.forEach((section) => (section.style.display = "none"));

    const targetSection = document.querySelector(
      `[data-section-id="${targetId}"]`
    );
    if (targetSection) targetSection.style.display = "block";

    links.forEach((link) => {
      link.parentElement.classList.toggle(
        "is-active",
        link.dataset.target === targetId
      );
    });
  };

  const expandArticle = (hash) => {
    if (hash) {
      const articleButton = document.querySelector(
        `.article .card__title[data-url="${hash}"]`
      );

      if (articleButton) {
        const article = articleButton.parentElement;
        article.classList.add("article--expanded");
        articleButton.setAttribute("aria-expanded", "true");

        setTimeout(() => {
          const elementTop =
            articleButton.getBoundingClientRect().top + window.pageYOffset;
          const offsetPosition = elementTop - 80;

          window.scrollTo({
            top: offsetPosition,
            behavior: "smooth",
          });
        }, 100);
      }
    }
  };

  links.forEach((link) => {
    link.addEventListener("click", (e) => {
      e.preventDefault();
      const targetId = link.dataset.target;
      history.replaceState(null, null, `#${targetId}`);
      showSection(targetId);
    });
  });

  const handleHashChange = () => {
    const hash = window.location.hash.replace("#", "");

    if (hash && document.querySelector(`[data-section-id="${hash}"]`)) {
      showSection(hash);
    } else if (hash) {
      const articleButton = document.querySelector(
        `.article .card__title[data-url="${hash}"]`
      );

      if (articleButton) {
        const article = articleButton.closest(".topic");

        if (article) {
          const sectionId = article.getAttribute("data-section-id");
          showSection(sectionId);
          expandArticle(hash);
        }
      }
    } else if (sections.length > 0) {
      const firstId = sections[0].dataset.sectionId;
      showSection(firstId);
    }
  };

  handleHashChange();

  window.addEventListener("hashchange", handleHashChange);
});
