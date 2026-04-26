Stradivari.Form = function () {
  mergeForms = function(form, detached) {
    if (!form.data('merged')) {
      form.data('merged', true);
      detached.find(':input:not(:submit,:button)').each(function() {
        // We do this because on IE input.clone() does not preserve
        // the val() not even on text inputs.
        var input = $(this),
            clone = input.clone();
        clone
          .val(input.val())
          .hide()
          .appendTo(form);
      });
      fieldOverrideSorting(form);
    }
  }

  var fieldOverrideSorting = function(form) {
    var field_sorting = form.find('[data-sort]:first');
    var current_sorting = form.find('[name=sort]');

    if (field_sorting.val() && !current_sorting.val()) {
      current_sorting.val(field_sorting.data('sort'));
    }
  }
};

Stradivari.FilterForm = function() {
  Stradivari.Form.call(this);

  this.form = Stradivari.FilterForm.form();

  this.form.
    on('click', '[data-stradivari-filter-action="search"]', function(event) {
      event.preventDefault();
      processFilterForm($(this.form), {
        submit: true
      });
    }).
    on('submit', function(event) {
      processFilterForm($(this.form), {
        submit: false
      });
    }).
    on('click', '[data-stradivari-filter-action="clear"]', function(event) {
      event.preventDefault();
      _TABLE_.filterURLParameters(function(param) {
        return param.indexOf(Stradivari.filterNamespace + '[') != 0 &&
          param.indexOf(Stradivari.filterContext + '[') != 0;
      });
    }).
    on('change', '[data-stradivari-filter-field="number"] select', function(event) {
      event.preventDefault();
      $(this).parents('fieldset').find('input').attr('name', Stradivari.filterNamespace + '[' + this.value + ']');
    });


  var processFilterForm = function(form, options) {
    var detached = $('#' + form.data('link'));
    mergeForms(form, detached);
    if (options.submit)
      form.submit();
  }
}

Stradivari.FilterForm.form = function(){
  return $('form[data-stradivari-filter-form="main"]');
}

Stradivari.FilterForm.prototype = {
  form: null,
  getOptions: function(opt_name) {
    var jsonData = [];

    this.form.find($("[name*='[" + opt_name + "]']")).each( function(){
      var elem = $(this);
      jsonData.push({ id: elem.val(), name: elem.parent().text().trim(), dataset: opt_name });
    });

    return jsonData;
  }
}



Stradivari.DetachedForm =function() {

  Stradivari.Form.call(this);

  var self = this;
  this.form = Stradivari.DetachedForm.form();

  this.form.
    on('click', '[data-stradivari-filter-action="search"]', function(event) {
      event.preventDefault();
      processDetachedForm($(this.form));
    }).
    on('submit', function(event) {
      event.preventDefault();
      processDetachedForm($(this.form));
    }).
    on('keydown', function(event) {
      if (event.which == 13)
        processDetachedForm($(this));
    })
    ;

  var processDetachedForm = function(detached) {
    var form = $('#' + detached.data('link'));
    mergeForms(form, detached);
    form.submit();
  }
}

Stradivari.DetachedForm.form = function(){
  return $('form[data-stradivari-filter-form="detached"]');
}

Stradivari.FoldableForm = function(form) {

  init = function(){
    form.
      on('click', '[data-stradivari-filter-toggle]', function(event) {
        event.preventDefault();
        var $this = $(this);
        var $formGroup = $this.parents('[data-stradivari-filter-field-wrapper]').first();
        var $closedContainer = $formGroup.find('[data-stradivari-filter-collapsible]').first();

        updateToggleTitle($this);

        if ($closedContainer.length != 0) {
          $closedContainer.toggle();
        } else {
          var $selected = $formGroup.find('[data-stradivari-filter-choice][data-stradivari-state~="checked"]');
          var $radioSelection = $formGroup.find('[data-stradivari-filter-choice]');

          if ($selected.length != 0) {
            $selected.removeClass('stradivari-filter__choice--checked').removeAttr('data-stradivari-state');
            $radioSelection.css('display', 'inline-block');
          } else {
            $radioSelection.hide();
            $selected = $formGroup.find('[data-stradivari-filter-choice] label input[type="radio"]:checked').parents('[data-stradivari-filter-choice]');
            $selected.addClass('stradivari-filter__choice--checked').attr('data-stradivari-state', 'checked').css('display', 'inline-block');
          }
        }
      });
  }

  var updateToggleTitle = function($this) {
    switch($this.html()) {
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
  return(init());
}

