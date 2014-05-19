_TABLE_.getURLParameters = function () {
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
