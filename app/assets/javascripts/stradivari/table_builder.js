Stradivari.ready(() => {
  Stradivari.delegate(document, 'click', '[data-stradivari-table] [data-stradivari-table-sort]', (event, header) => {
    event.preventDefault();

    _TABLE_.mergeURLParameters([`direction=${header.dataset.direction}`, `sort=${header.dataset.sort}`]);
  });

  Stradivari.delegate(document, 'click', '[data-stradivari-table] [data-stradivari-table-download="event"]', (event, link) => {
    event.preventDefault();

    Stradivari.emit(link.closest('[data-stradivari-table]'), 'stradivari:download', { element: link });
  });
});