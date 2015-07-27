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

  // activate tab if tab id is specified in the url#anchor
  // no ifs required, and clicking the tab link works even with ajax tabs
  $("[data-toggle='tab'][href='" + window.location.hash + "']")
    .each( function(i, el){ el.click() } );
});
