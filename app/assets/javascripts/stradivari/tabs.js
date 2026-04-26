const activateStradivariTab = (link) => {
  const target = document.querySelector(link.getAttribute("href"));

  if (!target) {
    return null;
  }

  const nav = link.closest(".stradivari-tabs__nav");
  const item = link.closest(".stradivari-tabs__item");

  if (nav) {
    Stradivari.all(".stradivari-tabs__item", nav).forEach((navItem) => {
      navItem.classList.remove("stradivari-tabs__item--active");
    });
  }

  if (item) {
    item.classList.add("stradivari-tabs__item--active");
  }

  Stradivari.all(".stradivari-tabs__pane", target.parentElement).forEach(
    (pane) => {
      pane.classList.remove("stradivari-tabs__pane--active");
    },
  );
  target.classList.add("stradivari-tabs__pane--active");

  return target;
};

Stradivari.ready(() => {
  Stradivari.delegate(
    document,
    "click",
    "[data-stradivari-tab]",
    async (event, link) => {
      event.preventDefault();

      const target = activateStradivariTab(link);

      if (
        !target ||
        !link.dataset.url ||
        Object.prototype.hasOwnProperty.call(link.dataset, "loaded")
      ) {
        return;
      }

      link.dataset.loaded = "false";
      Stradivari.emit(link, "stradivari:tab:loading");

      try {
        const response = await fetch(link.dataset.url, {
          credentials: "same-origin",
          headers: { "X-Requested-With": "XMLHttpRequest" },
        });

        if (!response.ok) {
          throw new Error(`Tab request failed with ${response.status}`);
        }

        link.dataset.loaded = "true";
        target.innerHTML = await response.text();
        Stradivari.emit(link, "stradivari:tab:loaded");
      } catch {
        delete link.dataset.loaded;
        window.alert("Aw, snap! Something went wrong");
        target.innerHTML = "";
        Stradivari.emit(link, "stradivari:tab:failed");
      }
    },
  );

  const stradivariTabs = _TABLE_.parseURLParameters(
    window.location.href,
  ).stradi_tabs;

  if (stradivariTabs) {
    stradivariTabs.forEach((tabId) => {
      const tab = document.querySelector(
        `[data-stradivari-tab][href="#${Stradivari.selectorEscape(tabId)}"]`,
      );

      if (tab) {
        tab.click();
      }
    });
  }
});
