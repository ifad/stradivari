import { readFileSync } from "node:fs";
import { join } from "node:path";
import { JSDOM } from "jsdom";

const scriptsDir = join(
  import.meta.dirname,
  "../../../app/assets/javascripts/stradivari",
);

// A fresh window per test: the scripts bind document listeners and
// SelectTree state at load, which a shared window would accumulate.
export function openPage(
  body,
  scripts,
  { url = "https://example.test/items" } = {},
) {
  const { window } = new JSDOM(`<!doctype html><body>${body}</body>`, {
    runScripts: "outside-only",
    url,
  });

  for (const name of ["helpers", ...scripts]) {
    window.eval(readFileSync(join(scriptsDir, `${name}.js`), "utf8"));
  }

  return window;
}
