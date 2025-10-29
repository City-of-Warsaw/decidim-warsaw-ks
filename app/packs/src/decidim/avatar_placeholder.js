/**
 * Fix for Decidim 0.29 bug where avatar placeholder disappears when saving upload modal without selecting a file.
 */

document.addEventListener("DOMContentLoaded", function () {
  const containerStates = new Map();

  const checkAndRestoreAvatar = () => {
    const avatarContainers = document.querySelectorAll(
      ".upload-container-for-avatar"
    );

    avatarContainers.forEach((container) => {
      const avatarButton = container.querySelector('[data-upload*="avatar"]');
      if (!avatarButton) return;

      const dialogId = avatarButton.dataset.dialogOpen;
      if (!dialogId) return;

      const expectedId = `default-active-${dialogId}`;
      const existingDefaultElement = container.querySelector(`#${expectedId}`);
      const activeUploadsElement = container.querySelector(
        `[data-active-uploads="${dialogId}"]`
      );

      let hasSelectedFiles = false;
      if (activeUploadsElement) {
        const filesWithData = activeUploadsElement.querySelectorAll(
          "[data-hidden-field]"
        );
        hasSelectedFiles = filesWithData.length > 0;
      }

      const buttonText = avatarButton.textContent.trim();
      const hasExistingImage = buttonText.includes("Podmień");

      if (!containerStates.has(dialogId)) {
        containerStates.set(dialogId, {
          hadePlaceholder: !!existingDefaultElement,
          hadFiles: hasSelectedFiles,
          hadExistingImage: hasExistingImage,
        });
      }

      const state = containerStates.get(dialogId);

      const shouldHavePlaceholder = !hasSelectedFiles && !hasExistingImage;
      const needsPlaceholder = shouldHavePlaceholder && !existingDefaultElement;

      if (needsPlaceholder && (state.hadFiles || state.hadExistingImage)) {
        if (activeUploadsElement) {
          const missingElement = document.createElement("div");
          missingElement.id = expectedId;
          missingElement.className = "upload-modal__files";
          missingElement.innerHTML = `
                <div class="attachment-details">
                  <div>
                    <img alt="avatar" src="/decidim-packs/media/images/default-avatar-aaa9e55bac5d7159b847.svg">
                  </div>
                </div>
              `;

          activeUploadsElement.parentNode.insertBefore(
            missingElement,
            activeUploadsElement
          );
        }
      } else if (needsPlaceholder) {
        if (activeUploadsElement) {
          const missingElement = document.createElement("div");
          missingElement.id = expectedId;
          missingElement.className = "upload-modal__files";
          missingElement.innerHTML = `
                <div class="attachment-details">
                  <div>
                    <img alt="avatar" src="/decidim-packs/media/images/default-avatar-aaa9e55bac5d7159b847.svg">
                  </div>
                </div>
              `;

          activeUploadsElement.parentNode.insertBefore(
            missingElement,
            activeUploadsElement
          );
        }
      } else if (
        existingDefaultElement &&
        (hasSelectedFiles || hasExistingImage)
      ) {
        existingDefaultElement.remove();
      }

      state.hadePlaceholder = !!container.querySelector(`#${expectedId}`);
      state.hadFiles = hasSelectedFiles;
      state.hadExistingImage = hasExistingImage;
    });
  };

  setTimeout(checkAndRestoreAvatar, 50);
  setTimeout(checkAndRestoreAvatar, 100);
  setTimeout(checkAndRestoreAvatar, 200);

  setInterval(checkAndRestoreAvatar, 200);

  const observer = new MutationObserver(function (mutations) {
    let shouldCheckImmediately = false;

    mutations.forEach(function (mutation) {
      if (mutation.type === "childList") {
        const target = mutation.target;

        if (target.closest && target.closest(".upload-container-for-avatar")) {
          if (mutation.removedNodes.length > 0) {
            shouldCheckImmediately = true;
          }
        }

        if (target.matches && target.matches("[data-active-uploads]")) {
          shouldCheckImmediately = true;
        }
      }
    });

    if (shouldCheckImmediately) {
      checkAndRestoreAvatar();
      setTimeout(checkAndRestoreAvatar, 10);
    }
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true,
  });
});
