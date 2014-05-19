$(function() {
  $('table.table').on('click', '.sortable', function(event) {
    event.preventDefault();
    var $this = $(this);

    var parameters = _TABLE_.getURLParameters();
    parameters.direction = $this.data('direction');
    parameters.sort = $this.data('sort');

    window.location.href = '?' + $.param(parameters);
  });
});
