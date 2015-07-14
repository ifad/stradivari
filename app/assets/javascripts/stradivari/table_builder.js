$(function() {
  $('table.table').on('click', 'th.sortable', function(event) {
    event.preventDefault();

    with($(this).data()) {
      _TABLE_.mergeURLParameters([
        'direction='.concat(direction),
        'sort='     .concat(sort)
      ]);
    }

  });

  $('table.table').on('click', '.downloadable_event', function(event) {
    event.preventDefault();
    var $form = $(this).parents('table.table');

    $form.trigger('stradivari:download', {element: this});
  });
});
