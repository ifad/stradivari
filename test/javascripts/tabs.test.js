import { describe, expect, it, vi } from "vitest";
import { openPage } from "./support/open_page.js";

// Markup as rendered by Stradivari::Tabs::Generator.
const tabSet = (panes) => `
  <ul class="stradivari-tabs__nav stradivari-tabs__nav--tabs">
    ${panes
      .map(
        ({ id: paneId, active, url }) => `
      <li class="stradivari-tabs__item${active ? " stradivari-tabs__item--active" : ""}">
        <a href="#${paneId}" class="stradivari-tabs__link" data-stradivari-tab="true"${url ? ` data-url="${url}"` : ""}>${paneId}</a>
      </li>`,
      )
      .join("")}
  </ul>
  <div class="stradivari-tabs__content">
    ${panes
      .map(
        ({
          id: paneId,
          active,
          content = '<div class="loading">Loading...</div>',
        }) => `
      <div class="stradivari-tabs__pane${active ? " stradivari-tabs__pane--active" : ""}" id="${paneId}">
        ${content}
      </div>`,
      )
      .join("")}
  </div>
`;

const activeItems = (window) =>
  Array.from(
    window.document.querySelectorAll(".stradivari-tabs__item--active a"),
    (link) => link.getAttribute("href"),
  );

const activePanes = (window) =>
  Array.from(
    window.document.querySelectorAll(".stradivari-tabs__pane--active"),
    (pane) => pane.id,
  );

const clickTab = (window, paneId) => {
  const click = new window.MouseEvent("click", {
    bubbles: true,
    cancelable: true,
  });
  window.document.querySelector(`[href="#${paneId}"]`).dispatchEvent(click);
  return click;
};

const recordTabEvents = (window) => {
  const events = [];

  for (const type of ["loading", "loaded", "failed"]) {
    window.document.addEventListener(`stradivari:tab:${type}`, (event) => {
      events.push({ type, target: event.target });
    });
  }

  return events;
};

const nextTabEvent = (window, type) =>
  new Promise((resolve) => {
    window.document.addEventListener(`stradivari:tab:${type}`, resolve, {
      once: true,
    });
  });

describe("tabs", () => {
  it("activates the clicked tab and its pane only", () => {
    const window = openPage(
      tabSet([{ id: "first", active: true }, { id: "second" }]),
      ["tabs"],
    );

    expect(clickTab(window, "second").defaultPrevented).toBe(true);
    expect(activeItems(window)).toEqual(["#second"]);
    expect(activePanes(window)).toEqual(["second"]);
  });

  it("keeps the active pane of nested tabs when switching the outer tabs", () => {
    const window = openPage(
      tabSet([
        {
          id: "outer-a",
          active: true,
          content: tabSet([{ id: "inner-a", active: true }, { id: "inner-b" }]),
        },
        { id: "outer-b" },
      ]),
      ["tabs"],
    );

    clickTab(window, "outer-b");
    clickTab(window, "outer-a");

    expect(activeItems(window)).toEqual(["#outer-a", "#inner-a"]);
    expect(activePanes(window)).toEqual(["outer-a", "inner-a"]);
  });

  it("opens the tabs listed in stradi_tabs[] at load, skipping unknown ids", () => {
    const window = openPage(
      tabSet([{ id: "a", active: true }, { id: "b" }]) +
        tabSet([{ id: "one", active: true }, { id: "two" }]),
      ["tabs"],
      {
        url: "https://example.test/items?stradi_tabs[]=b&stradi_tabs[]=two&stradi_tabs[]=missing",
      },
    );

    expect(activeItems(window)).toEqual(["#b", "#two"]);
    expect(activePanes(window)).toEqual(["b", "two"]);
  });

  describe("with a remote URL", () => {
    const remotePage = () => {
      const window = openPage(
        tabSet([
          { id: "local", active: true },
          { id: "remote", url: "/items/remote" },
        ]),
        ["tabs"],
      );

      window.alert = vi.fn();
      window.fetch = vi.fn();

      return window;
    };

    it("loads the pane once, emitting loading then loaded on the link", async () => {
      const window = remotePage();
      const link = window.document.querySelector('[href="#remote"]');
      const events = recordTabEvents(window);
      window.fetch.mockImplementation(async () => {
        events.push({ type: "fetch" });
        return new Response("<p>Remote rows</p>");
      });

      const loaded = nextTabEvent(window, "loaded");
      clickTab(window, "remote");
      clickTab(window, "remote");
      await loaded;

      expect(window.fetch).toHaveBeenCalledTimes(1);
      expect(window.fetch).toHaveBeenCalledWith("/items/remote", {
        credentials: "same-origin",
        headers: { "X-Requested-With": "XMLHttpRequest" },
      });
      expect(events).toEqual([
        { type: "loading", target: link },
        { type: "fetch" },
        { type: "loaded", target: link },
      ]);
      expect(window.document.getElementById("remote").innerHTML).toBe(
        "<p>Remote rows</p>",
      );
      expect(link.dataset.loaded).toBe("true");
      expect(activePanes(window)).toEqual(["remote"]);

      clickTab(window, "local");
      clickTab(window, "remote");

      expect(window.fetch).toHaveBeenCalledTimes(1);
    });

    it.each([
      ["responds with an error", async () => new Response("", { status: 500 })],
      [
        "cannot be reached",
        async () => {
          throw new TypeError("Failed to fetch");
        },
      ],
    ])(
      "emits failed and allows a retry when the server %s",
      async (_, failure) => {
        const window = remotePage();
        const link = window.document.querySelector('[href="#remote"]');
        const pane = window.document.getElementById("remote");
        const events = recordTabEvents(window);
        window.fetch.mockImplementationOnce(failure);

        const failed = nextTabEvent(window, "failed");
        clickTab(window, "remote");
        await failed;

        expect(events).toEqual([
          { type: "loading", target: link },
          { type: "failed", target: link },
        ]);
        expect(window.alert).toHaveBeenCalledWith(
          "Aw, snap! Something went wrong",
        );
        expect(pane.innerHTML).toBe("");

        window.fetch.mockResolvedValueOnce(new Response("<p>Retried</p>"));
        const loaded = nextTabEvent(window, "loaded");
        clickTab(window, "remote");
        await loaded;

        expect(window.fetch).toHaveBeenCalledTimes(2);
        expect(pane.innerHTML).toBe("<p>Retried</p>");
      },
    );
  });
});
