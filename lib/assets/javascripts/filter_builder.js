$(function() {

  $('form.detached-form').
    on('click', '.search', function(event) {
      event.preventDefault();
      processDetachedForm($(this).parents('form'));
    }).
    on('submit', function(event) {
      event.preventDefault();
      processDetachedForm($(this));
    });

  $('form.filter-form').
    on('click', '.search', function(event) {
      event.preventDefault();
      processFilterForm($(this).parents('form'));
    }).
    on('submit', function(event) {
      event.preventDefault();
      processFilterForm($(this));
    }).
    on('click', '.clear', function(event) {
      event.preventDefault();

      var params = _TABLE_.getURLParameters();
      var keys = Object.keys(params);
      $.each(keys, function() {
        if (this.indexOf('search_fields') == 0) {
          delete params[this];
        }
      });
      window.location.href = '?' + $.param(params);
    }).
    .on('change', '.number_field select', function(event) {
      event.preventDefault();
      $(this).parents('fieldset').find('input').attr('name', 'search_fields[' + this.value + ']');
    });

  function processDetachedForm(detached) {
    var form = $('#' + detached.data('link'));
    submitMergedForms(form, detached);
  }

  function processFilterForm(form) {
    var detached = $('#' + form.data('link'));
    submitMergedForms(form, detached);
  }

  function submitMergedForms(form, detached) {
    detached.find(':input:not(:submit,:button)').clone().hide().appendTo(form);
    form.submit();
  }
});
