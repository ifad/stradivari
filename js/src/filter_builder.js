Stradivari.Form = function () {
  mergeForms = function (form, detached) {
    if (!form.data('merged')) {
      form.data('merged', true)
      detached.find(':input:not(:submit,:button)').each(function () {
        // We do this because on IE input.clone() does not preserve
        // the val() not even on text inputs.
        var input = $(this)
        var clone = input.clone()
        clone
          .val(input.val())
          .hide()
          .appendTo(form)
      })
      fieldOverrideSorting(form)
    }
  }

  var fieldOverrideSorting = function (form) {
    var fieldSorting = form.find('[data-sort]:first')
    var currentSorting = form.find('[name=sort]')

    if (fieldSorting.val() && !currentSorting.val()) {
      currentSorting.val(fieldSorting.data('sort'))
    }
  }
}

Stradivari.FilterForm = function () {
  Stradivari.Form.call(this)

  this.form = Stradivari.FilterForm.form()

  this.form
    .on('click', '.btn--stradivari-search', function (event) {
      event.preventDefault()
      processFilterForm($(this.form), {
        submit: true
      })
    })
    .on('submit', function (event) {
      processFilterForm($(this.form), {
        submit: false
      })
    })
    .on('click', '.btn--stradivari-clear', function (event) {
      event.preventDefault()
      _TABLE_.filterURLParameters(function (param) {
        return param.indexOf(Stradivari.filterNamespace + '[') !== 0 &&
          param.indexOf(Stradivari.filterContext + '[') !== 0
      })
    })
    .on('change', '.number_field select', function (event) {
      event.preventDefault()
      $(this).parents('fieldset').find('input').attr('name', Stradivari.filterNamespace + '[' + this.value + ']')
    })

  var processFilterForm = function (form, options) {
    var detached = $('#' + form.data('link'))
    mergeForms(form, detached)
    if (options.submit) { form.submit() }
  }
}

Stradivari.FilterForm.form = function () {
  return $('.stradivari-form:not(.stradivari-form--detached)')
}

Stradivari.FilterForm.prototype = {
  form: null,
  getOptions: function (optName) {
    var jsonData = []

    this.form.find($("[name*='[" + optName + "]']")).each(function () {
      var elem = $(this)
      jsonData.push({ id: elem.val(), name: elem.parent().text().trim(), dataset: optName })
    })

    return jsonData
  }
}

Stradivari.DetachedForm = function () {
  Stradivari.Form.call(this)

  this.form = Stradivari.DetachedForm.form()

  this.form
    .on('click', '.btn--stradivari-search', function (event) {
      event.preventDefault()
      processDetachedForm($(this.form))
    })
    .on('submit', function (event) {
      event.preventDefault()
      processDetachedForm($(this.form))
    })
    .on('keydown', function (event) {
      if (event.which === 13) { processDetachedForm($(this)) }
    })

  var processDetachedForm = function (detached) {
    var form = $('#' + detached.data('link'))
    mergeForms(form, detached)
    form.submit()
  }
}

Stradivari.DetachedForm.form = function () {
  return $('.stradivari-form--detached')
}

Stradivari.FoldableForm = function (form) {
  init = function () {
    form
      .on('hidden.bs.collapse', '.collapse--stradivari', function (event) {
        var $this = $(this)
        var $toggler = $this.parents('.form-group--stradivari').find('.stradivari-handle').first()
        $toggler.attr('aria-expanded', 'false')
      })
      .on('click', '.stradivari-handle', function (event) {
        event.preventDefault()
        var $this = $(this)
        var $formGroup = $this.parents('.form-group--stradivari').first()
        var $closedContainer = $formGroup.find('.collapse--stradivari').first()

        updateToggleTitle($this)

        if ($closedContainer.length !== 0) {
          $closedContainer.collapse('toggle')
        } else {
          var $selected = $formGroup.find('.radio.checked')
          var $radioSelection = $formGroup.find('.radio')

          if ($selected.length !== 0) {
            $selected.removeClass('checked')
            $radioSelection.css('display', 'inline-flex')
          } else {
            $radioSelection.hide()
            $selected = $formGroup.find('.radio input[type="radio"]:checked').parents('.radio')
            $selected.addClass('checked').css('display', 'inline-flex')
          }
        }
      })
  }

  var updateToggleTitle = function ($this) {
    switch ($this.html()) {
      case 'Expand':
        $this.html('Close')
        break
      case 'Close':
        $this.html('Expand')
        break
      case 'Add More':
        $this.html('Narrow')
        break
      case 'Narrow':
        $this.html('Add More')
        break
    }
  }
  return (init())
}
