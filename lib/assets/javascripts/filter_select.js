/*
 * when called on a select box, populates a second, "target" select with data
 * from a "template" url, which is first passed through a "formatter" callback
 *
 * the formatter returns an map of key, value
 */
(function($) {

  function Template(string) {
    this.template = string;
  }

  Template.prototype = {
    constructor: Template,

    expand : function(map) {
      var result = this.template;
      $.each(map, function(key, value) {
        result = result.replace(new RegExp("\{" + key + "\}"), value);
      });
      return result;
    }
  };

  function FilterSelect(el, options) {
    if(el.get(0).tagName.toLowerCase() != 'select') {
      return null;
    }

    this.element   = el;
    this.template  = new Template(options.template);
    this.target    = options.target;
    this.formatter = options.formatter;

    this.bind();
  }

  FilterSelect.prototype = {
    constructor: FilterSelect,

    bind: function() {
      var self = this;
      this.element.on('change', function(e) {
        self.onChange(e);
      });
    },

    onChange: function(e) {

      var self = this;

      $.get(this.template.expand({ value: this.element.val() }), function(data) {
        self.dataReady(data);
      });
    },

    dataReady : function(data) {
      var self = this;
      this.target.html('');
      $.each(this.formatter(data), function(key, value) {
        var option = $('<option></option>');
        option.attr("value", value);
        if(self.target.data('selected') == value) {
          option.prop('selected', true);
        }
        option.text(key);
        self.target.append(option);
      });
    }
  }

  $.fn.filterSelect = function(options) {
    this.each(function() {
      new FilterSelect($(this), options);
    });
  }
})(jQuery);
