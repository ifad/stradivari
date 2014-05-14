$(function() {
  var filter_form_id = "#filter-form";

  $('table.table').on('click', '.sortable', function(event) {
    event.preventDefault();
    var $this = $(this);

    var parameters = getURLParameters();
    parameters.direction = $this.data('direction');
    parameters.sort = $this.data('sort');

    window.location.href = '?' + $.param(parameters);
  });

  $('form.detached-form').on('click', 'a.detached-search', function(event) {
    event.preventDefault();

    processDetachedForm($(this).parents('form'));

  }).on('submit', function(event) {
    event.preventDefault();

    processDetachedForm($(this));
  });

  $('#filter-form').on('click', 'button.search', function(event) {
    event.preventDefault();
    var $this = $(this);

    window.location.href = '?' + $.param(processFilterFields());
  });

  $(filter_form_id).on('click', 'button.clear', function(event) {
    event.preventDefault();
    var $this = $(this);

    var params = getURLParameters();
    var keys = Object.keys(params);
    $.each(keys, function() {
      if (this.indexOf('search_fields') == 0) {
        delete params[this];
      }
    });

    window.location.href = '?' + $.param(params);
  });

  $('#filter-form').on('change', '.number_field select', function(event) {
    event.preventDefault();
    var new_name;

    $(this).parents('fieldset').find('input').attr('name', 'search_fields[' + this.value + ']');

  });

  function processFilterFields() {
    $form = $(filter_form_id);
    formID = '#' + $form.data('form');
    detachedForm = 'form.detached-form.' + $form.data('form');
    $(detachedForm).find(':input').not(':submit').clone().hide().appendTo(formID);
    data = $form.serializeObject();

    return data;
  }

  function processDetachedForm(form) {
    formID = '#' + form.data('form');
    form.find(':input').not(':submit').clone().hide().appendTo(formID);
    $(formID).submit();
  }

});

function getURLParameters() {
  var parameters = {},
      hash;

  var href = window.location.href;
  if (href.indexOf('?') != -1) {
    var decoded_params = decodeURIComponent(href);
    var hashes = decoded_params.slice(decoded_params.indexOf('?') + 1).split('&');

    for (var i = hashes.length - 1; i >= 0; i--) {
      hash = hashes[i].split('=');
      // parameters.push(hash[0]);
      parameters[hash[0]] = hash[1];
    }
  }
  return parameters;
}


$.fn.serializeObject = function() {
  var o = {};
  var a = this.serializeArray();
  $.each(a, function() {
    if (o[this.name] !== undefined) {
      if (!o[this.name].push) {
        o[this.name] = [o[this.name]];
      }
      o[this.name].push(this.value || "");
    } else {
      o[this.name] = this.value || '';
    }
  });

  return o;
};
