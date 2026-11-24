import { describe, expect, it } from "vitest";
import { openPage } from "./support/open_page.js";

// Markup as rendered by Stradivari::Table::Generator with downloadable: :csv.
const tableWith = (downloadLink) => `
  <div class="stradivari-table__viewport">
    <table class="stradivari-table" data-stradivari-table="true">
      <tbody><tr><td>Row</td></tr></tbody>
      <tfoot>
        <tr>
          <td colspan="1">
            <div class="stradivari-table__download">${downloadLink}</div>
          </td>
        </tr>
      </tfoot>
    </table>
  </div>
`;

const clickLink = (window) => {
  const click = new window.MouseEvent("click", {
    bubbles: true,
    cancelable: true,
  });
  window.document.querySelector("a").dispatchEvent(click);
  return click;
};

const recordDownloads = (window) => {
  const downloads = [];

  window.document.addEventListener("stradivari:download", (event) => {
    downloads.push({ target: event.target, element: event.detail.element });
  });

  return downloads;
};

describe("table download links", () => {
  it("emits stradivari:download on the table with the clicked link", () => {
    const window = openPage(
      tableWith(`
        <a class="stradivari-table__download-link stradivari-table__download-link--event"
           href="/items.csv" data-stradivari-table-download="event">Export to CSV...</a>
      `),
      ["table_builder"],
    );
    const downloads = recordDownloads(window);

    const click = clickLink(window);

    expect(click.defaultPrevented).toBe(true);
    expect(downloads).toEqual([
      {
        target: window.document.querySelector("table"),
        element: window.document.querySelector("a"),
      },
    ]);
  });

  it("leaves other download links to the browser", () => {
    const window = openPage(
      tableWith(`
        <a class="stradivari-table__download-link" href="/items.csv">Export to CSV...</a>
      `),
      ["table_builder"],
    );
    const downloads = recordDownloads(window);
    let preventedByStradivari;
    // Runs after the script's document listener; stops jsdom navigating.
    window.document.addEventListener("click", (event) => {
      preventedByStradivari = event.defaultPrevented;
      event.preventDefault();
    });

    clickLink(window);

    expect(preventedByStradivari).toBe(false);
    expect(downloads).toEqual([]);
  });
});
