$(function() {

  /** Detached form
   */
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
    processFilterForm($(this).parents('form'), {
      submit: true
    });
  }).
  on('submit', function(event) {
    processFilterForm($(this), {
      submit: false
    });
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
      detached.find(':input:not(:submit,:button)').each(function() {
        // We do this because on IE input.clone() does not preserve
        // the val() not even on text inputs.
        var input = $(this),
          clone = input.clone();
        clone.val(input.val());
        clone.hide().appendTo(form);
      });

      fieldOverrideSorting(form);
    }
  }

  function fieldOverrideSorting(form) {
    var field_sorting = form.find('[data-sort]:first');
    var current_sorting = form.find('[name=sort]');

    if (field_sorting.val() && !current_sorting.val()) {
      current_sorting.val(field_sorting.data('sort'));
    }
  }

  /** Inputs folding
   */
  $('form.filter-form, form.form-detached').
  on('click', '.presentable', function(event) {
    event.preventDefault();
    var $this = $(this);
    var $formGroup = $this.parents('.form-group');
    var $closedContainer = $formGroup.find('.closed');

    updateToggleTitle($this);

    if ($closedContainer.length != 0) {
      $closedContainer.toggle();
    } else {
      var $selected = $formGroup.find('.radio.checked');
      var $radioSelection = $formGroup.find('.radio');

      if ($selected.length != 0) {
        $selected.removeClass('checked');
        $radioSelection.css('display', 'inline-block');
      } else {
        $radioSelection.hide();
        $selected = $formGroup.find('.radio label input[type="radio"]:checked').parents('.radio');
        $selected.addClass('checked').css('display', 'inline-block');
      }
    }
  });

  function updateToggleTitle($this) {
    switch ($this.html()) {
      case "Expand":
        $this.html("Close");
        break;
      case "Close":
        $this.html("Expand");
        break;
      case "Add More":
        $this.html("Narrow");
        break;
      case "Narrow":
        $this.html("Add More");
        break;
    }
  }
});
