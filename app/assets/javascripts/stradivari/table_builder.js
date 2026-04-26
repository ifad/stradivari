$(function() {
  $('[data-stradivari-table]').on('click', '[data-stradivari-table-sort]', function(event) {
    event.preventDefault();

    with($(this).data()) {
      _TABLE_.mergeURLParameters([
        'direction='.concat(direction),
        'sort='     .concat(sort)
      ]);
    }

  });

  $('[data-stradivari-table]').on('click', '[data-stradivari-table-download="event"]', function(event) {
    event.preventDefault();
    var $form = $(this).parents('[data-stradivari-table]');

    $form.trigger('stradivari:download', {element: this});
  });
});
