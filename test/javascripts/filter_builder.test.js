import { describe, expect, it } from "vitest";
import { openPage } from "./support/open_page.js";

// Markup as rendered by Stradivari::Filter::Generator, trimmed to what the
// scripts read. base.js binds the forms, so it loads after filter_builder.js.
const scripts = ["filter_builder", "base"];

const filterForm = (fields, { sort = "" } = {}) => `
  <form id="filter-form" data-link="filter-form_detached"
    data-stradivari-filter-form="main"
    data-stradivari-filter-context="context"
    data-stradivari-filter-namespace="q">
    <input type="hidden" name="sort" value="${sort}">
    <input type="hidden" name="direction" value="">
    ${fields}
    <ul class="stradivari-filter__actions">
      <li class="stradivari-filter__action-item">
        <button type="submit" data-stradivari-filter-action="search">Search</button>
        <button type="button" data-stradivari-filter-action="clear">Clear</button>
      </li>
    </ul>
  </form>
`;

const detachedForm = (fields) => `
  <form id="filter-form_detached" data-link="filter-form"
    data-stradivari-filter-form="detached" data-detached="true">
    ${fields}
    <button type="button" data-stradivari-filter-action="search">Search</button>
  </form>
`;

// Two text fields, so a browser submits on Enter only through a submit button.
const searchFields = `
  <input type="text" name="q[name_cont]" value="pear">
  <input type="text" name="q[city_cont]" value="">
`;

const detachedFields = `
  <input type="text" name="q[code_cont]" value="">
  <input type="hidden" name="q[tags_in][]" value="">
  <label><input type="checkbox" name="q[tags_in][]" value="red"> Red</label>
  <label><input type="checkbox" name="q[tags_in][]" value="blue"> Blue</label>
  <select name="q[state_eq]">
    <option value="">Any</option>
    <option value="open">Open</option>
    <option value="closed">Closed</option>
  </select>
`;

const fillDetachedForm = (window) => {
  const form = window.document.getElementById("filter-form_detached");

  form.elements["q[code_cont]"].value = "AB-12";
  form.querySelector('[value="red"]').checked = true;
  form.elements["q[state_eq]"].value = "closed";
};

// Runs after the scripts' form listeners; stops jsdom submitting.
const recordSubmissions = (window) => {
  const submissions = [];

  window.document.addEventListener("submit", (event) => {
    event.preventDefault();
    submissions.push({
      form: event.target.id,
      fields: Array.from(new window.FormData(event.target)),
    });
  });

  return submissions;
};

const actionIn = (window, formId, action) =>
  window.document.querySelector(
    `#${formId} [data-stradivari-filter-action="${action}"]`,
  );

// jsdom has no implicit submission, so do what a browser does on Enter in a
// text field: click the form's default button unless a key handler objects.
const pressEnter = (window, field) => {
  const keydown = new window.KeyboardEvent("keydown", {
    key: "Enter",
    bubbles: true,
    cancelable: true,
  });

  if (field.dispatchEvent(keydown)) {
    Array.from(field.form.elements)
      .find((element) => element.type === "submit")
      ?.click();
  }
};

describe("filter forms", () => {
  it.each([
    [
      "Search in the filter",
      (window) => actionIn(window, "filter-form", "search").click(),
    ],
    [
      "Enter in a filter field",
      (window) =>
        pressEnter(
          window,
          window.document.querySelector('[name="q[city_cont]"]'),
        ),
    ],
    [
      "Search in the detached form",
      (window) => actionIn(window, "filter-form_detached", "search").click(),
    ],
    [
      "Enter in the detached form",
      (window) =>
        pressEnter(
          window,
          window.document.querySelector('[name="q[code_cont]"]'),
        ),
    ],
  ])("%s submits the filter once with the detached fields", (_, submit) => {
    const window = openPage(
      filterForm(searchFields) + detachedForm(detachedFields),
      scripts,
    );
    const submissions = recordSubmissions(window);
    fillDetachedForm(window);

    submit(window);

    expect(submissions).toEqual([
      {
        form: "filter-form",
        fields: [
          ["sort", ""],
          ["direction", ""],
          ["q[name_cont]", "pear"],
          ["q[city_cont]", ""],
          ["q[code_cont]", "AB-12"],
          ["q[tags_in][]", ""],
          ["q[tags_in][]", "red"],
          ["q[state_eq]", "closed"],
        ],
      },
    ]);

    const copies = window.document.querySelectorAll(
      '#filter-form [name="q[code_cont]"], #filter-form [name="q[tags_in][]"], #filter-form [name="q[state_eq]"]',
    );

    expect(
      Array.from(copies, (copy) => window.getComputedStyle(copy).display),
    ).toEqual(["none", "none", "none", "none", "none"]);
  });

  it.each([
    ["", "relevance"],
    ["name", "name"],
  ])(
    "sorts by the detached search field when the sort is %j",
    (sort, expected) => {
      const window = openPage(
        filterForm(searchFields, { sort }) +
          detachedForm(
            '<input type="text" name="q[code_cont]" value="AB-12" data-sort="relevance">',
          ),
        scripts,
      );
      const submissions = recordSubmissions(window);

      actionIn(window, "filter-form", "search").click();

      expect(submissions[0].fields[0]).toEqual(["sort", expected]);
    },
  );

  it("Clear drops the filter parameters from the URL and submits nothing", () => {
    const window = openPage(filterForm(searchFields), scripts);
    const submissions = recordSubmissions(window);
    let kept;
    // jsdom cannot navigate, so record which parameters Clear keeps.
    window._TABLE_.filterURLParameters = (keep) => {
      kept = [
        "q[name_cont]=pear",
        "context[view]=list",
        "quantity=3",
        "page=2",
      ].filter(keep);
    };

    actionIn(window, "filter-form", "clear").click();

    expect(kept).toEqual(["quantity=3", "page=2"]);
    expect(submissions).toEqual([]);
  });

  // The stylesheet rule that hides collapsed controls.
  const collapsedStyle = `
    <style>
      .stradivari-filter__control--closed,
      .stradivari-filter__collapsed { display: none; }
    </style>
  `;

  it.each([
    [
      "a low-priority control",
      "Expand",
      "Close",
      `<div class="stradivari-filter__control stradivari-filter__control--closed"
         data-stradivari-filter-collapsible="true">
         <input type="text" name="q[price_gteq]">
       </div>`,
    ],
    [
      "the unchecked choices of an active list",
      "Add More",
      "Narrow",
      `<div class="stradivari-filter__control stradivari-filter__choice-list">
         <label><input type="checkbox" name="q[tags_in][]" value="red" checked> Red</label>
         <div class="stradivari-filter__collapsed" data-stradivari-filter-collapsible="true">
           <hr>
           <label><input type="checkbox" name="q[tags_in][]" value="blue"> Blue</label>
         </div>
       </div>`,
    ],
  ])(
    "expands and collapses %s",
    (_, collapsedTitle, expandedTitle, control) => {
      const window = openPage(
        collapsedStyle +
          filterForm(`
          <div data-stradivari-filter-field-wrapper="true">
            <label><span data-stradivari-filter-toggle="true">${collapsedTitle}</span></label>
            ${control}
          </div>
        `),
        scripts,
      );
      const toggle = window.document.querySelector(
        "[data-stradivari-filter-toggle]",
      );
      const collapsible = window.document.querySelector(
        "[data-stradivari-filter-collapsible]",
      );
      const state = () => ({
        title: toggle.textContent,
        hidingClass: collapsible.matches(
          ".stradivari-filter__control--closed, .stradivari-filter__collapsed",
        ),
        inlineDisplay: collapsible.style.display,
        display: window.getComputedStyle(collapsible).display,
      });

      expect(state()).toEqual({
        title: collapsedTitle,
        hidingClass: true,
        inlineDisplay: "",
        display: "none",
      });

      toggle.click();

      expect(state()).toEqual({
        title: expandedTitle,
        hidingClass: false,
        inlineDisplay: "",
        display: "block",
      });

      toggle.click();

      expect(state()).toEqual({
        title: collapsedTitle,
        hidingClass: false,
        inlineDisplay: "none",
        display: "none",
      });
    },
  );
});
