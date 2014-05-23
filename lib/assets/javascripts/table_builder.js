$(function() {
  $('table.table').on('click', '.sortable', function(event) {
    event.preventDefault();

    with($(this).data()) {
      _TABLE_.mergeURLParameters([
        'direction='.concat(direction),
        'sort='     .concat(sort)
      ]);
    }

  });
});
