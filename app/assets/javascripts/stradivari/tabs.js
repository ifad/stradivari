/**
 * Lazy-loaded tabs
 */
jQuery(function() {
  $('.nav.nav-tabs').on('click', '[data-url]', function(event) {
    var loader = $(this);

    if (loader.data('loaded'))
      return;

    var target = $(loader.attr('href')); // It's an #anchor

    $.ajax({ url: loader.data('url') })
      .done(function(html) {
        loader.data('loaded', true);
        target.html(html);
      })
      .fail(function() {
        alert('Aw, snap! Something went wrong');
        target.html('');
      });
  })
});
