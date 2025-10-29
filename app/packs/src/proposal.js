$(document).ready(function () {
  $('.custom-proposal').on('click', function () {
    const $button = $(this);
    const $contentWrapper = $button.closest('.article').find('.content-wrapper');

    $contentWrapper.slideToggle(200);

    const isExpanded = $button.attr('aria-expanded') === 'true';
    $button.attr('aria-expanded', String(!isExpanded));
  });
});
