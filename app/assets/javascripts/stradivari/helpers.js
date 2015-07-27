window._TABLE_ = (function() {

  // Returns the URL parameters as an array.
  //
  var query = function () {
    return window.decodeURI(
      window.location.search.substring(1) // Remove the '?'
    ).split('&');
  };

  // Navigates to the current page setting the given
  // parameters array.
  //
  var navigate = function(params) {
    return window.location.assign(params.length > 0 ?
      '?'.concat(params.join('&'))                  :
      window.location.pathname
    );
  };
  
  var decodeURIComponentAndSpaces = function(str) {
    str = str.replace(/\+/g, ' ');
    return window.decodeURIComponent(str);
  };

  // API
  return {
    // Removes the parameter according to the given callback
    // and navigates.
    filterURLParameters: function(callback) {
      return navigate(
        query().filter(callback)
      );
    },

    // Merges the current URL parameters with the given array,
    // taking care of removing ones already set.
    mergeURLParameters: function(params) {
      return navigate(query().
        filter(function(p) {
          return !params.some(function(param) {
            return p.split('=')[0] == param.split('=')[0]; // Clunky.
          })
        }).
        concat(params)
      );

    },

    // example
    // in: http://mysite.com?stradi_tabs[]=bar&stradi_tabs[]=baz&foo=bar
    // out: {stradi_tabs: ['bar', 'baz'], foo: "bar"}
    parseURLParameters: function(uri) {
      var re     = /([^&=]+)=?([^&]*)/g;
      var query  = uri.split('?')[1]
      var params = {};

      if (query) {
        var e;
        
        while (e = re.exec(query)) {
          var k = decodeURIComponentAndSpaces(e[1]),
              v = decodeURIComponentAndSpaces(e[2]);

          if (k.substring(k.length - 2) === '[]') {
            k = k.substring(0, k.length - 2);
            (params[k] || (params[k] = [])).push(v);
          }
          else params[k] = v;
        }
      }
      return params;
    }

  }
})();
