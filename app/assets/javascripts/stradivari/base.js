window.Stradivari = window.Stradivari || {};

Object.assign(Stradivari, {
  configure() {
    const configElement = document.querySelector(
      '[data-stradivari-filter-form="main"]',
    );

    if (!configElement) {
      return;
    }

    this.filterContext = configElement.dataset.stradivariFilterContext;
    this.filterNamespace = configElement.dataset.stradivariFilterNamespace;
  },

  init() {
    this.configure();

    if (Stradivari.DetachedForm.form()) {
      Stradivari.detachedForm = new Stradivari.DetachedForm();
    }

    if (Stradivari.FilterForm.form()) {
      Stradivari.filterForm = new Stradivari.FilterForm();
      new Stradivari.FoldableForm(Stradivari.filterForm.form);
    }

    setTimeout(() => {
      const focusField = document.querySelector("input.focus:not([readonly])");

      if (focusField) {
        focusField.focus();

        if (focusField.setSelectionRange) {
          const cursorPosition = focusField.value.length;
          focusField.setSelectionRange(cursorPosition, cursorPosition);
        }
      }
    });
  },
});

Stradivari.ready(() => Stradivari.init());
