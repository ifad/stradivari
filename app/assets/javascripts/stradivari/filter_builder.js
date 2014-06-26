$(function() {

  $('form.form-detached').
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
      processFilterForm($(this).parents('form'), {submit: true});
    }).
    on('submit', function(event) {
      processFilterForm($(this), {submit: false});
    }).
    on('click', '.clear', function(event) {
      event.preventDefault();

      // Delete all parameters starting with q[
      _TABLE_.filterURLParameters(function(param) {
        return param.indexOf('q[') != 0;
      });
    }).
    on('change', '.number_field select', function(event) {
      event.preventDefault();
      $(this).parents('fieldset').find('input').attr('name', 'q[' + this.value + ']');
    });

  function processDetachedForm(detached) {
    var form = $('#' + detached.data('link'));
    mergeForms(form, detached);
    form.submit();
  }

  function processFilterForm(form, options) {
    var detached = $('#' + form.data('link'));
    mergeForms(form, detached);

    if (options.submit)
      form.submit();
  }

  function mergeForms(form, detached) {
    if (!form.data('merged')) {
      form.data('merged', true);
      detached.find(':input:not(:submit,:button)').clone().hide().appendTo(form);

      fieldOverrideSorting(form);
    }
  }

  function fieldOverrideSorting(form) {
    var field_sorting   = form.find('[data-sort]:first');
    var current_sorting = form.find('[name=sort]');

    if (field_sorting.val() && !current_sorting.val()) {
      current_sorting.val(field_sorting.data('sort'));
    }
  }
});
