/**
*
* Stradivari Autocompleter
*
* The stradivari Autocompleter needs both the detached form and the form filters
*
* It will use the keys in the filters to generate a list of autocomplete terms
* in the detached form
*
* To enable it, put the autocomplete:true option in the detached form search field
*
*   - search :matching, title: 'Search', class: "focus", autocomplete: true
*
* The class "focus" is used to give default focus to the search field
*
* Then, on the checkbox fields in the filter, use the autocomplete: true option
* to tell to the Stradivari to grab that list and use it in the Autocompleter
*
* - checkbox :foo, collection: Foo.foos, priority: :low, title: "Foo", autocomplete: true
*
**/

Stradivari.Autocompleter = function () {
  initializeDetached()
  initializeAttached()

  function initializeDetached () {
    var form = $('form[data-detached=true]')
    var autoCompleteField = $('input[data-stradivari=autocomplete]', form)
    var bloodhounds = prepareTheBloodhounds($('label[data-stradivari=autocomplete]'))
    var datasets = prepareTheDatasets(bloodhounds)

    initializeTheBloodhounds(bloodhounds, true)

    initializeTypeahead(autoCompleteField, datasets)
    attachCallbacks(form, autoCompleteField)

    attachEvents(autoCompleteField)
  }

  function initializeAttached () {
    var form = $('form:not([data-detached=true])')
    var autoCompleteField = $('input[data-stradivari=autocomplete]', form)

    $('label[data-stradivari=autocomplete]', form).each(function (_, e) {
      var bloodhound = prepareTheBloodhounds($(e))
      var acf = $('#' + $(e).attr('for'))
      var datasets = prepareTheDatasets(bloodhound)

      initializeTheBloodhounds(bloodhound, true)

      initializeTypeahead(acf, datasets)
    })

    attachCallbacks(form, autoCompleteField)

    attachEvents(autoCompleteField)
  }

  function prepareTheBloodhounds (labels) {
    var bloodHoundsPack = []
    $.each(labels, function (_, label) {
      var element = $('#' + $(label).attr('for'))
      var remoteUrl = element.data('remote-url')
      var datasetName = $(label).attr('for').replace(Stradivari.filterNamespace + '_', '')
      var bloodhuntOpts = {
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        display: Stradivari.typeaheadDisplay
      }

      if (remoteUrl === undefined) { bloodhuntOpts.local = Stradivari.filterForm.getOptions(datasetName) } else {
        bloodhuntOpts.remote = {
          url: element.data('remote-url') + '?q=%QUERY',
          wildcard: '%QUERY'
        }
      }

      var bloodhound = new Bloodhound(bloodhuntOpts)

      if (remoteUrl === undefined) { bloodhound.datasetName = datasetName }

      bloodhound.label = $(label).find('.text').text()
      bloodHoundsPack.push(bloodhound)
    })
    return bloodHoundsPack
  }

  function prepareTheDatasets (bh) {
    var datasets = []
    $.each(bh, function (_, bloodhound) {
      datasets.push({
        name: bloodhound.datasetName,
        displayKey: Stradivari.typeaheadDisplay,
        source: bloodhound.ttAdapter(),
        templates: {
          header: '<h5 class="dataset-name">' + bloodhound.label + '</h5>'
        }
      })
    })
    return datasets
  }

  function initializeTheBloodhounds (bh, clearCache) {
    $.each(bh, function (_, bloodhound) {
      if (clearCache) { bloodhound.clearPrefetchCache() }
      bloodhound.initialize()
    })
  }

  function initializeTypeahead (field, datasets) {
    field.typeahead({ highlight: true, displayKey: Stradivari.typeaheadDisplay }, datasets)

    field.filter('[data-display][data-display!=null]').each(function (_, e) {
      $(e).val($(e).data('display'))
    })
  }

  function attachCallbacks (form, fields) {
    form
      .on('submit', function (e) {
        fields.filter('[data-display][data-display!=null]').each(function (_, e) {
          $(e).val($(e).typeahead('val'))
        })
      })
  }

  function attachEvents (fields) {
    fields
      .on('typeahead:selected typeahead:autocompleted', function (e, selected) {
        var self = $(this)

        if (selected.dataset !== undefined) {
          $('#' + Stradivari.filterNamespace + '_' + selected.dataset + '_' + selected[Stradivari.typeaheadValue].toLowerCase()).prop('checked', true)

          self.removeAttr('placeholder')
          self.val('')
        } else {
          self.val(selected[Stradivari.typeaheadValue])
        }

        Stradivari.filterForm.form.submit()
      })
  }
}
