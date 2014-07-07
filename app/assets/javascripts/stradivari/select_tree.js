(function() {

  window.SelectTree = function(node, parent) {
    var self       = this;
    this.node      = node;
    this.parent    = parent;
    this.children  = [ ];
    this.linked    = null;
    this.listeners = [ ];
    this.total     = 0;

    SelectTree.byParent(this.name()).each(function() {
      self.children.push(new SelectTree($(this), self));
    });

    node.on('change', function() {
      self.onChange($(this).prop('checked'));
    });
  }

  SelectTree.prototype = {
    constructor: SelectTree,

    data: function(key) {
      return this.node[0].getAttribute('data-' + SelectTree.data_prefix + '-' + key);
    },

    name: function() {
      return this.data('name');
    },

    countTotal: function() {
      return this.data('count-total');
    },

    onChange: function(bool) {
      var linked = this.findLinked();

      this.node.prop('checked', bool);

      this.eachChild(function(child) {
        child.onChange(bool);
      });

      for(var i = 0; i < linked.length; ++i) {
        if(linked[i].node.prop('checked') != bool) {
          linked[i].onChange(bool);
        }
      }

      this.fireEvent('change', self);
    },

    addListener: function(event, listener) {
      /* only the root node has listeners */
      if(this.parent) {
        this.parent.addListener(event, listener);
      }
      else {
        this.listeners.push({ event : event, callback : listener });
      }
    },

    fireEvent: function(event, data) {
      if(this.parent) {
        this.parent.fireEvent(event, data);
      }
      else {
        var self = this;

        this.eachListener(function(l) {
          if(l.event == event) {
            l.callback(self, data);
          }
        });
      }
    },

    calcTotalSelected: function() {
      var total = 0;

      if(this.node.prop('checked') && this.countTotal()) {
        total += 1;
      }

      this.eachChild(function(c) {
        total += c.calcTotalSelected();
      });

      this.total = total;

      return this.total;
    },

    eachListener: function(cb) {
      for(var i = 0; i < this.listeners.length; ++i) {
        cb(this.listeners[i]);
      }
    },

    eachChild: function(cb) {
      for(var i = 0; i < this.children.length; ++i) {
        cb(this.children[i]);
      }
    },

    /*
     * find all nodes in the tree with the
     * specified name
     */
    findNamed: function(name) {
      if(this.parent) {
        return this.parent.findNamed(name);
      }
      else {
        return this.findNamedChildren(name);
      }
    },

    /*
     * find all child nodes with the given name
     */
    findNamedChildren: function(name) {
      var nodes =[ ];

      this.eachChild(function(child) {
        if(child.name() == name) {
          nodes.push(child);
        }
        $.merge(nodes, child.findNamedChildren(name));
      });

      return nodes;
    },

    /*
     * a linked node is a node in the same
     * tree with the same name as this node
     */
    findLinked: function() {
      if(this.linked) {
        return this.linked;
      }
      else {
        this.linked = this.findNamed(this.name());
        return this.linked;
      }
    },

    /*
     * Walks the given path in child branches looking for the tree whose node
     * is the last item, and replaces it. Meant to be used with AJAX updates.
     */
    rebind: function(path) {
      for(var i = 0; i < this.children.length; ++i) {
        var child = this.children[i];
        if (path.length == 1 && path[0].getAttribute('data-select-tree-name') == child.node[0].getAttribute('data-select-tree-name')) {
          child.node = $(path[0]);
          return true;
        }
        else if (child.node[0] == path[0]) {
          path.shift();
          return child.rebind(path);
        }
      }

      return false;
    }
  }

  SelectTree.data_prefix = 'select-tree';

  var $all, $trees;

  SelectTree.all = function() {
    if (!$all)
      $all = $('input[type="checkbox"][data-bind="' + this.data_prefix + '"]');

    return $all;
  }

  SelectTree.allRoots = function() {
    return this.byParent(null);
  }

  SelectTree.byParent = function(name) {
    var self = this;
    return this.all().filter(function() {
      return (this.getAttribute('data-' + self.data_prefix + '-parent') == name);
    });
  }

  SelectTree.byName = function(name) {
    var self = this;
    return this.all().filter(function() {
      return (this.getAttribute('data-' + self.data_prefix + '-name') == name);
    });
  }

  SelectTree.buildAll = function() {
    $trees = [ ];
    $all   = null; // Refresh

    this.allRoots().each(function() {
      var tree = new SelectTree($(this));
      $trees.push(tree);
    });
  }

  /* Given a piece of updated HTML via AJAX, looks up the select-tree boxes,
   * builds a path to the root, and then calls rebind() on it */
  SelectTree.rebind = function(html) {
    var self = this;
    $(html).find('[data-bind="' + this.data_prefix + '"]').each(function() {
      // Go up to the root
      var item = this;
      var path = [ ];

      while(item != null) {
        path.unshift(item);

        item = item.getAttribute('data-' + self.data_prefix + '-parent');
        if (item)
          item = self.byName(item)[0];
      }

      var root = path.shift();
      var tree = $trees.filter(function(t) {
        return root == t.node[0];
      })[0];

      if (tree)
        tree.rebind(path);
    });
  }

  SelectTree.eachCounter = function(cb) {
    $('[data-' + this.data_prefix + '-total]').each(function() {
      cb($(this));
    });
  }

  SelectTree.setTotal = function(tree, counter) {
    var count      = (counter.data(this.data_prefix + '-total') || 0);
    var tree_total = tree.total;
    var updated    = tree.calcTotalSelected();

    if(tree_total < updated) {
      count += (updated - tree_total);
    }
    else if(tree_total > updated) {
      count += (updated - tree_total);
    }

    counter.data(this.data_prefix + '-total', count);

    var presenter = counter.val() ? counter.val : counter.text;
    presenter.call(counter, presenter.call(counter).replace(/\d+/, count));
  }

  $(function() {
    SelectTree.buildAll();

    SelectTree.eachCounter(function(c) {
      for(var i = 0; i < $trees.length; ++i) {
        $trees[i].addListener('change', function(t) {
          SelectTree.setTotal(t, c);
        });
      }
    });
  });

})();
