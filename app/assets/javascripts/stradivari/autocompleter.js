StradivariAutocompleter = function() {
  var autoCompleteField = $("input.autocomplete")
  var bloodhounds = prepareTheBloodhounds($("[data-autocomplete]"));
  var datasets = prepareTheDatasets();

  initializeTheBloodhounds(true);

  autoCompleteField.typeahead({highlight: true}, datasets);

  attachSelectEvent();

  function prepareTheBloodhounds(labels) {
    var bloodHoundsPack = [];

    $.each(labels, function(_, label) {
      var dataset_name = $(label).attr("for").replace("q_", "");
      var bloodhound = new Bloodhound({
          datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
          queryTokenizer: Bloodhound.tokenizers.whitespace,
          local: filterForm.getOptions(dataset_name)
        })
      bloodhound.dataset_name = dataset_name;
      bloodhound.label = $(label).find(".text").html();
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
      if(clear_cache){
        bloodhound.clearPrefetchCache();
        }
      bloodhound.initialize();
    })
  }

  function attachSelectEvent(){
    autoCompleteField.on("typeahead:selected", function(e, selected, dataset){
    $("#q_" + dataset + "_" + selected.id.toLowerCase()).prop('checked', true);
    this.value = '';
    filterForm.form.submit();
    })
  }

}

$(function() {
  new StradivariAutocompleter();
})





