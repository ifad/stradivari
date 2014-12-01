window.Stradivari = (typeof Stradivari != "undefined") ? Stradivari : {};

Stradivari.init = function() {
  /* Initialize forms */
  if (Stradivari.DetachedForm.form()) {
    Stradivari.detachedForm = new Stradivari.DetachedForm();
  }

  if (Stradivari.FilterForm.form()) {
    // we need filterForum instance for the autocomplete function
    Stradivari.filterForm = new Stradivari.FilterForm();
    new Stradivari.FoldableForm(Stradivari.filterForm.form);
  }

  /* Initialize autocompleter */
  Stradivari.autocompleter = new Stradivari.Autocompleter();

  // all this to give focus to the input.focus element, positioning
  // the cursor after the last character
  setTimeout(function() {
    var focusField = $('input.focus:not([readonly])')
    focusField.focus();
    focusField[0].setSelectionRange(focusField.val().length, focusField.val().length);
  });
}

$(function() {
  Stradivari.init();
})
