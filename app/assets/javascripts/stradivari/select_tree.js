class SelectTree {
  constructor(node, parent = null) {
    this.node = node;
    this.parent = parent;
    this.children = [];
    this.linked = null;
    this.listeners = [];
    this.total = 0;

    SelectTree.byParent(this.name()).forEach((childNode) => {
      this.children.push(new SelectTree(childNode, this));
    });

    this.node.addEventListener("change", () => {
      this.onChange(this.node.checked);
    });
  }

  data(key) {
    return this.node.getAttribute(`data-${SelectTree.dataPrefix}-${key}`);
  }

  name() {
    return this.data("name");
  }

  countTotal() {
    return this.data("count-total");
  }

  onChange(checked) {
    const linked = this.findLinked();

    this.node.checked = checked;

    this.eachChild((child) => {
      child.onChange(checked);
    });

    linked.forEach((linkedNode) => {
      if (linkedNode.node.checked !== checked) {
        linkedNode.onChange(checked);
      }
    });

    this.fireEvent("change", this);
  }

  addListener(event, listener) {
    if (this.parent) {
      this.parent.addListener(event, listener);
    } else {
      this.listeners.push({ event, callback: listener });
    }
  }

  fireEvent(event, data) {
    if (this.parent) {
      this.parent.fireEvent(event, data);
      return;
    }

    this.eachListener((listener) => {
      if (listener.event === event) {
        listener.callback(this, data);
      }
    });
  }

  calcTotalSelected() {
    let total = 0;

    if (this.node.checked && this.countTotal()) {
      total += 1;
    }

    this.eachChild((child) => {
      total += child.calcTotalSelected();
    });

    this.total = total;
    return this.total;
  }

  eachListener(callback) {
    this.listeners.forEach(callback);
  }

  eachChild(callback) {
    this.children.forEach(callback);
  }

  findNamed(name) {
    return this.parent
      ? this.parent.findNamed(name)
      : this.findNamedChildren(name);
  }

  findNamedChildren(name) {
    return this.children.reduce((nodes, child) => {
      if (child.name() === name) {
        nodes.push(child);
      }

      return nodes.concat(child.findNamedChildren(name));
    }, []);
  }

  findLinked() {
    if (!this.linked) {
      this.linked = this.findNamed(this.name());
    }

    return this.linked;
  }

  rebind(path) {
    for (const child of this.children) {
      if (
        path.length === 1 &&
        path[0].getAttribute("data-select-tree-name") ===
          child.node.getAttribute("data-select-tree-name")
      ) {
        child.node = path[0];
        return true;
      }

      if (child.node === path[0]) {
        path.shift();
        return child.rebind(path);
      }
    }

    return false;
  }

  static all() {
    if (!this.cachedAll) {
      this.cachedAll = Stradivari.all(
        `input[type="checkbox"][data-bind="${this.dataPrefix}"]`,
      );
    }

    return this.cachedAll;
  }

  static allRoots() {
    return this.byParent(null);
  }

  static byParent(name) {
    return this.all().filter(
      (node) => node.getAttribute(`data-${this.dataPrefix}-parent`) === name,
    );
  }

  static byName(name) {
    return this.all().filter(
      (node) => node.getAttribute(`data-${this.dataPrefix}-name`) === name,
    );
  }

  static buildAll() {
    this.trees = [];
    this.cachedAll = null;

    this.allRoots().forEach((node) => {
      this.trees.push(new SelectTree(node));
    });
  }

  static rebind(html) {
    const root = this.fragmentFrom(html);

    Stradivari.all(`[data-bind="${this.dataPrefix}"]`, root).forEach(
      (updatedNode) => {
        let item = updatedNode;
        const path = [];

        while (item) {
          path.unshift(item);

          const parentName = item.getAttribute(
            `data-${this.dataPrefix}-parent`,
          );
          item = parentName ? this.byName(parentName)[0] : null;
        }

        const rootNode = path.shift();
        const tree = this.trees.find(
          (candidate) => candidate.node === rootNode,
        );

        if (tree) {
          tree.rebind(path);
        }
      },
    );
  }

  static fragmentFrom(html) {
    if (typeof html !== "string") {
      return html;
    }

    const template = document.createElement("template");
    template.innerHTML = html;
    return template.content;
  }

  static eachCounter(callback) {
    Stradivari.all(`[data-${this.dataPrefix}-total]`).forEach(callback);
  }

  static setTotal(tree, counter) {
    let count = Number(counter.dataset.selectTreeTotal || 0);
    const previousTotal = tree.total;
    const updatedTotal = tree.calcTotalSelected();

    count += updatedTotal - previousTotal;
    counter.dataset.selectTreeTotal = count;

    if ("value" in counter && counter.value) {
      counter.value = counter.value.replace(/\d+/, count);
    } else {
      counter.textContent = counter.textContent.replace(/\d+/, count);
    }
  }
}

SelectTree.dataPrefix = "select-tree";
SelectTree.data_prefix = SelectTree.dataPrefix;
SelectTree.cachedAll = null;
SelectTree.trees = [];

window.SelectTree = SelectTree;

Stradivari.ready(() => {
  SelectTree.buildAll();

  SelectTree.eachCounter((counter) => {
    SelectTree.trees.forEach((tree) => {
      tree.addListener("change", (changedTree) => {
        SelectTree.setTotal(changedTree, counter);
      });
    });
  });
});
