/**
 * Lazy-loaded tabs
 */
jQuery(function () {
  $(document).on('click', '.nav.nav-tabs [data-url], .nav.nav-pills [data-url], .nav.nav-stacked [data-url]', function (event) {
    var loader = $(this)

    if (loader.data().hasOwnProperty('loaded')) { return }

    var target = $(loader.attr('href')) // It's an #anchor

    $.ajax({
      url: loader.data('url'),
      beforeSend: function () {
        loader.data('loaded', false)
        loader.trigger('stradivari:tab:loading')
      }
    })
      .done(function (html) {
        loader.data('loaded', true)
        target.html(html)
        loader.trigger('stradivari:tab:loaded')
      })
      .fail(function () {
        loader.removeData('loaded')
        alert('Aw, snap! Something went wrong')
        target.html('')
        loader.trigger('stradivari:tab:failed')
      })
  })

  // activate tab if tab id is specified in the url stradi_tabs[] parameter
  // clicking the tab link works even with ajax tabs
  var stradivari_tabs = _TABLE_.parseURLParameters(location.href).stradi_tabs
  if (stradivari_tabs != undefined) {
    $.each(stradivari_tabs, function (i, tab_id) {
      var tab = $("[data-toggle='tab'][href='#" + tab_id + "']").first()
      if (tab != undefined) tab.click()
    })
  }
})
