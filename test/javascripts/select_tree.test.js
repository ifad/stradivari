import { describe, expect, it } from "vitest";
import { openPage } from "./support/open_page.js";

// Data attributes as rendered by select_tree_check_box.
const checkBox = (name, { parent, countTotal } = {}) => `
  <input type="checkbox" name="tags[]" value="${name}" data-bind="select-tree"
    data-select-tree-name="${name}"
    ${parent ? `data-select-tree-parent="${parent}"` : ""}
    ${countTotal ? `data-select-tree-count-total="${countTotal}"` : ""}>
`;

// A path is "parent/name", or "name" for a root.
const checkBoxFor = (window, path) => {
  const [parent, name] = path.includes("/") ? path.split("/") : [null, path];

  return window.document.querySelector(
    parent
      ? `[data-select-tree-name="${name}"][data-select-tree-parent="${parent}"]`
      : `[data-select-tree-name="${name}"]:not([data-select-tree-parent])`,
  );
};

const checkedPaths = (window) =>
  Array.from(
    window.document.querySelectorAll('[data-bind="select-tree"]:checked'),
    (node) =>
      [node.dataset.selectTreeParent, node.dataset.selectTreeName]
        .filter(Boolean)
        .join("/"),
  );

// The tomato is listed under both fruit and veg.
const groceries = [
  checkBox("all"),
  checkBox("fruit", { parent: "all" }),
  checkBox("apple", { parent: "fruit" }),
  checkBox("tomato", { parent: "fruit" }),
  checkBox("veg", { parent: "all" }),
  checkBox("carrot", { parent: "veg" }),
  checkBox("tomato", { parent: "veg" }),
].join("");

describe("SelectTree", () => {
  it("checks and unchecks a node with its descendants and their namesakes", () => {
    const window = openPage(groceries, ["select_tree"]);

    checkBoxFor(window, "all/veg").click();

    expect(checkedPaths(window)).toEqual([
      "fruit/tomato",
      "all/veg",
      "veg/carrot",
      "veg/tomato",
    ]);

    checkBoxFor(window, "all/veg").click();

    expect(checkedPaths(window)).toEqual([]);
  });

  it("keeps nodes with the same name in sync", () => {
    const window = openPage(groceries, ["select_tree"]);

    checkBoxFor(window, "veg/tomato").click();

    expect(checkedPaths(window)).toEqual(["fruit/tomato", "veg/tomato"]);

    checkBoxFor(window, "fruit/tomato").click();

    expect(checkedPaths(window)).toEqual([]);
  });

  it.each([
    [
      "text",
      '<span data-select-tree-total="0">0 selected</span>',
      "textContent",
      ["2 selected", "3 selected", "1 selected"],
    ],
    [
      "value",
      '<input type="text" data-select-tree-total="0" value="Tags: 0">',
      "value",
      ["Tags: 2", "Tags: 3", "Tags: 1"],
    ],
  ])(
    "counts the selected countable nodes of every tree in the counter %s",
    (_, counterMarkup, property, expected) => {
      const window = openPage(
        [
          checkBox("fruit"),
          checkBox("apple", { parent: "fruit", countTotal: 1 }),
          checkBox("pear", { parent: "fruit", countTotal: 1 }),
          checkBox("veg"),
          checkBox("carrot", { parent: "veg", countTotal: 1 }),
          counterMarkup,
        ].join(""),
        ["select_tree"],
      );
      const counter = window.document.querySelector("[data-select-tree-total]");
      const shown = [];

      for (const path of ["fruit", "veg/carrot", "fruit"]) {
        checkBoxFor(window, path).click();
        shown.push(counter[property]);
      }

      expect(shown).toEqual(expected);
    },
  );

  it("updates every counter on the page", () => {
    const window = openPage(
      [
        checkBox("fruit"),
        checkBox("apple", { parent: "fruit", countTotal: 1 }),
        checkBox("pear", { parent: "fruit", countTotal: 1 }),
        '<span data-select-tree-total="0">0 selected</span>',
        '<input type="text" data-select-tree-total="0" value="Tags: 0">',
      ].join(""),
      ["select_tree"],
    );
    const [text, input] = window.document.querySelectorAll(
      "[data-select-tree-total]",
    );

    checkBoxFor(window, "fruit").click();

    expect([text.textContent, input.value]).toEqual(["2 selected", "Tags: 2"]);

    checkBoxFor(window, "fruit/pear").click();

    expect([text.textContent, input.value]).toEqual(["1 selected", "Tags: 1"]);
  });

  it("rebinds a replaced node so its parent still reaches it", () => {
    const window = openPage(
      `${checkBox("fruit")}
       <div id="apple">${checkBox("apple", { parent: "fruit" })}</div>
       ${checkBox("pear", { parent: "fruit" })}`,
      ["select_tree"],
    );
    const wrapper = window.document.getElementById("apple");

    wrapper.innerHTML = checkBox("apple", { parent: "fruit" });
    window.SelectTree.rebind(wrapper);
    checkBoxFor(window, "fruit").click();

    expect(checkedPaths(window)).toEqual([
      "fruit",
      "fruit/apple",
      "fruit/pear",
    ]);
  });

  it("cascades and counts from a replaced node when it is clicked", () => {
    const window = openPage(
      `${checkBox("all")}
       <div id="fruit">${checkBox("fruit", { parent: "all" })}</div>
       ${checkBox("apple", { parent: "fruit", countTotal: 1 })}
       <span data-select-tree-total="0">0 selected</span>`,
      ["select_tree"],
    );
    const wrapper = window.document.getElementById("fruit");
    const counter = window.document.querySelector("[data-select-tree-total]");

    wrapper.innerHTML = checkBox("fruit", { parent: "all" });
    window.SelectTree.rebind(wrapper);
    checkBoxFor(window, "all/fruit").click();

    expect(checkedPaths(window)).toEqual(["all/fruit", "fruit/apple"]);
    expect(counter.textContent).toBe("1 selected");
  });
});
