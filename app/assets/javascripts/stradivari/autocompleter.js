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



Stradivari.Autocompleter = function() {
  var autoCompleteField = $('input[data-stradivari="autocomplete"]')
  var bloodhounds = prepareTheBloodhounds($('label[data-stradivari="autocomplete"]'));
  var datasets = prepareTheDatasets();

  initializeTheBloodhounds(false);
  autoCompleteField.typeahead({highlight: true}, datasets);
  attachEvents();

  function prepareTheBloodhounds(labels) {
    var bloodHoundsPack = [];
    $.each(labels, function(_, label) {
      var dataset_name = $(label).attr("for").replace(Stradivari.filterNamespace + "_", "");
      var bloodhound = new Bloodhound({
          datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
          queryTokenizer: Bloodhound.tokenizers.whitespace,
          local: Stradivari.filterForm.getOptions(dataset_name)
        })
      bloodhound.dataset_name = dataset_name;
      bloodhound.label = $(label).find(".text").text();
      bloodHoundsPack.push(bloodhound);
    })
    return bloodHoundsPack;
  }

  function prepareTheDatasets() {
    var datasets = [];

    $.each(bloodhounds, function(_, bloodhound){
      datasets.push({
        name: bloodhound.dataset_name,
        displayKey: 'name',
        source: bloodhound.ttAdapter(),
        templates: {
          header: '<h5 class="dataset-name">' + bloodhound.label + '</h5>'
        }
      })
    })
    return datasets;
  }

  function initializeTheBloodhounds(clear_cache) {
    $.each(bloodhounds, function(_, bloodhound){
      if(clear_cache)
        bloodhound.clearPrefetchCache();
      bloodhound.initialize();
    })
  }

  function attachEvents(){
    autoCompleteField
      .on("typeahead:selected", function(e, selected, dataset){
        $("#" + Stradivari.filterNamespace + "_" + dataset + "_" + selected.id.toLowerCase()).prop('checked', true);
        this.value = '';
        Stradivari.filterForm.form.submit();
      })
  }
}


