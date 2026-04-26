const stradivariElementsFrom = (value) => {
  if (!value) {
    return [];
  }

  if (typeof value === "string") {
    return Stradivari.all(value);
  }

  if (value instanceof Element || value === document || value === window) {
    return [value];
  }

  if (typeof value.length === "number") {
    return Array.from(value).filter(Boolean);
  }

  return [];
};

class StradivariTemplate {
  constructor(template) {
    this.template = template;
  }

  expand(map) {
    return Object.entries(map).reduce((result, [key, value]) => {
      return result.replace(
        new RegExp(`\\{${key}\\}`, "g"),
        encodeURIComponent(value),
      );
    }, this.template);
  }
}

Stradivari.FilterSelect = class {
  constructor(element, options) {
    if (!(element instanceof HTMLSelectElement)) {
      return;
    }

    this.element = element;
    this.template = new StradivariTemplate(options.template);
    this.target = stradivariElementsFrom(options.target)[0];
    this.formatter = options.formatter || ((data) => data);

    if (this.target) {
      this.bind();
    }
  }

  bind() {
    this.element.addEventListener("change", () => this.onChange());
  }

  async onChange() {
    this.target.disabled = true;

    try {
      const response = await fetch(
        this.template.expand({ value: this.element.value }),
        {
          credentials: "same-origin",
          headers: {
            Accept: "application/json",
            "X-Requested-With": "XMLHttpRequest",
          },
        },
      );

      if (!response.ok) {
        throw new Error(`Filter select request failed with ${response.status}`);
      }

      this.dataReady(await response.json());
    } finally {
      this.target.disabled = false;
    }
  }

  dataReady(data) {
    this.target.replaceChildren();

    Object.entries(this.formatter(data)).forEach(([label, value]) => {
      const option = document.createElement("option");
      option.value = value;
      option.selected = this.target.dataset.selected === String(value);
      option.textContent = label;
      this.target.appendChild(option);
    });
  }
};

Stradivari.filterSelect = (selectorOrElements, options) => {
  stradivariElementsFrom(selectorOrElements).forEach((element) => {
    new Stradivari.FilterSelect(element, options);
  });
};
