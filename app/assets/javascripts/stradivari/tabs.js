/**
 * Lazy-loaded tabs
 */
jQuery(function() {
  $('.nav.nav-tabs, .nav.nav-pills').on('click', '[data-url]', function(event) {
    var loader = $(this);

    if (loader.data().hasOwnProperty('loaded'))
      return;

    var target = $(loader.attr('href')); // It's an #anchor

    $.ajax({
        url: loader.data('url'),
        beforeSend: function() {
          loader.data('loaded', false);
          loader.trigger('stradivari:tab:loading');
        }
      })
      .done(function(html) {
        loader.data('loaded', true);
        target.html(html);
        loader.trigger('stradivari:tab:loaded');
      })
      .fail(function() {
        loader.removeData('loaded');
        alert('Aw, snap! Something went wrong');
        target.html('');
        loader.trigger('stradivari:tab:failed');
      });
  })
});
