$(function() {
  $('table.table').on('click', '.sortable', function(event) {
    event.preventDefault();
    var $this = $(this);

    var parameters = getURLParameters();
    parameters.direction = $this.data('direction');
    parameters.sort = $this.data('sort');

    window.location.href = '?' + $.param(parameters);
  });

  $('form.detached-form').on('click', '.search', function(event) {
    event.preventDefault();

    processDetachedForm($(this).parents('form'));

  }).on('submit', function(event) {
    event.preventDefault();

    processDetachedForm($(this));
  });

  $('#filter-form').on('click', '.search', function(event) {
    event.preventDefault();

    processFilterForm($(this).parents('form'));
  });

  $('#filter-form').on('click', '.clear', function(event) {
    event.preventDefault();

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
