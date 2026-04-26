Stradivari.Form = class {
  mergeForms(form, detached) {
    if (!form || !detached || form.dataset.merged === 'true') {
      return;
    }

    form.dataset.merged = 'true';

    detached.querySelectorAll('input:not([type="submit"]):not([type="button"]), select, textarea').forEach((input) => {
      const clone = input.cloneNode(true);
      clone.value = input.value;
      clone.checked = input.checked;
      clone.hidden = true;
      clone.style.display = 'none';
      form.appendChild(clone);
    });

    this.fieldOverrideSorting(form);
  }

  fieldOverrideSorting(form) {
    const fieldSorting = form.querySelector('[data-sort]');
    const currentSorting = form.querySelector('[name="sort"]');

    if (fieldSorting && currentSorting && fieldSorting.value && !currentSorting.value) {
      currentSorting.value = fieldSorting.dataset.sort;
    }
  }
};

Stradivari.FilterForm = class extends Stradivari.Form {
  constructor() {
    super();
    this.form = Stradivari.FilterForm.form();

    if (this.form) {
      this.bind();
    }
  }

  static form() {
    return document.querySelector('form[data-stradivari-filter-form="main"]');
  }

  bind() {
    this.form.addEventListener('click', (event) => {
      const action = event.target.closest('[data-stradivari-filter-action]');

      if (!action || !this.form.contains(action)) {
        return;
      }

      event.preventDefault();

      if (action.dataset.stradivariFilterAction === 'search') {
        this.process({ submit: true });
      } else if (action.dataset.stradivariFilterAction === 'clear') {
        _TABLE_.filterURLParameters((param) => {
          return !param.startsWith(`${Stradivari.filterNamespace}[`) && !param.startsWith(`${Stradivari.filterContext}[`);
        });
      }
    });

    this.form.addEventListener('submit', () => {
      this.process({ submit: false });
    });

    this.form.addEventListener('change', (event) => {
      const select = event.target.closest('[data-stradivari-filter-field="number"] select');

      if (!select || !this.form.contains(select)) {
        return;
      }

      const input = select.closest('fieldset').querySelector('input');

      if (input) {
        input.name = `${Stradivari.filterNamespace}[${select.value}]`;
      }
    });
  }

  process(options) {
    const detached = document.getElementById(this.form.dataset.link);
    this.mergeForms(this.form, detached);

    if (options.submit) {
      this.form.submit();
    }
  }

  getOptions(optionName) {
    return Stradivari.all(`[name*="[${optionName}]"]`, this.form).map((element) => ({
      id: element.value,
      name: element.parentElement.textContent.trim(),
      dataset: optionName
    }));
  }
};

Stradivari.DetachedForm = class extends Stradivari.Form {
  constructor() {
    super();
    this.form = Stradivari.DetachedForm.form();

    if (this.form) {
      this.bind();
    }
  }

  static form() {
    return document.querySelector('form[data-stradivari-filter-form="detached"]');
  }

  bind() {
    this.form.addEventListener('click', (event) => {
      const action = event.target.closest('[data-stradivari-filter-action="search"]');

      if (!action || !this.form.contains(action)) {
        return;
      }

      event.preventDefault();
      this.process();
    });

    this.form.addEventListener('submit', (event) => {
      event.preventDefault();
      this.process();
    });

    this.form.addEventListener('keydown', (event) => {
      if (event.key === 'Enter') {
        event.preventDefault();
        this.process();
      }
    });
  }

  process() {
    const form = document.getElementById(this.form.dataset.link);
    this.mergeForms(form, this.form);
    form.submit();
  }
};

Stradivari.FoldableForm = class {
  constructor(form) {
    this.form = form;

    if (this.form) {
      this.bind();
    }
  }

  bind() {
    this.form.addEventListener('click', (event) => {
      const toggle = event.target.closest('[data-stradivari-filter-toggle]');

      if (!toggle || !this.form.contains(toggle)) {
        return;
      }

      event.preventDefault();
      this.updateToggleTitle(toggle);

      const formGroup = toggle.closest('[data-stradivari-filter-field-wrapper]');
      const closedContainer = formGroup.querySelector('[data-stradivari-filter-collapsible]');

      if (closedContainer) {
        this.toggleElement(closedContainer);
      } else {
        this.toggleRadioChoices(formGroup);
      }
    });
  }

  toggleElement(element) {
    const hidden = element.style.display === 'none' || window.getComputedStyle(element).display === 'none';
    element.style.display = hidden ? 'block' : 'none';
  }

  toggleRadioChoices(formGroup) {
    const selected = Stradivari.all('[data-stradivari-filter-choice][data-stradivari-state~="checked"]', formGroup);
    const radioSelection = Stradivari.all('[data-stradivari-filter-choice]', formGroup);

    if (selected.length > 0) {
      selected.forEach((choice) => {
        choice.classList.remove('stradivari-filter__choice--checked');
        choice.removeAttribute('data-stradivari-state');
      });
      radioSelection.forEach((choice) => {
        choice.style.display = 'inline-block';
      });
    } else {
      radioSelection.forEach((choice) => {
        choice.style.display = 'none';
      });

      Stradivari.all('[data-stradivari-filter-choice] label input[type="radio"]:checked', formGroup).forEach((input) => {
        const choice = input.closest('[data-stradivari-filter-choice]');
        choice.classList.add('stradivari-filter__choice--checked');
        choice.dataset.stradivariState = 'checked';
        choice.style.display = 'inline-block';
      });
    }
  }

  updateToggleTitle(toggle) {
    const titles = {
      'Add More': 'Narrow',
      Close: 'Expand',
      Expand: 'Close',
      Narrow: 'Add More'
    };

    toggle.textContent = titles[toggle.textContent] || toggle.textContent;
  }
};