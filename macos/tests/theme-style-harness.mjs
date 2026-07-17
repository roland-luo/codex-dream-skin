#!/usr/bin/env node

// Execute the real renderer injection template against a minimal light-shell DOM
// and assert that non-rose themes do not inherit the rose surface palette.

import fs from "node:fs/promises";
import path from "node:path";
import vm from "node:vm";

const themePath = path.resolve(process.argv[2] || "");
if (!themePath) throw new Error("Usage: theme-style-harness.mjs <theme.json>");

const rootDir = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const [template, theme] = await Promise.all([
  fs.readFile(path.join(rootDir, "assets", "renderer-inject.js"), "utf8"),
  fs.readFile(themePath, "utf8").then(JSON.parse),
]);

const values = new Map();
const attributes = new Map();
const elements = new Map();
const classNames = new Set();
const root = {
  className: "light",
  style: {
    setProperty(name, value) { values.set(name, String(value)); },
    getPropertyValue(name) { return values.get(name) || ""; },
    removeProperty(name) { values.delete(name); },
  },
  classList: {
    add(...names) { names.forEach((name) => classNames.add(name)); },
    remove(...names) { names.forEach((name) => classNames.delete(name)); },
    contains(name) { return classNames.has(name); },
    toggle(name, force) {
      if (force === false) classNames.delete(name);
      else classNames.add(name);
    },
  },
  getAttribute(name) { return attributes.get(name) || null; },
  setAttribute(name, value) { attributes.set(name, String(value)); },
  removeAttribute(name) { attributes.delete(name); },
  appendChild(element) { if (element.id) elements.set(element.id, element); },
};

const document = {
  documentElement: root,
  body: null,
  head: root,
  querySelector() { return null; },
  querySelectorAll() { return []; },
  getElementById(id) { return elements.get(id) || null; },
  createElement() { return { id: "", dataset: {}, textContent: "" }; },
};
const mediaQuery = {
  matches: false,
  addEventListener() {},
  removeEventListener() {},
};
const window = {
  addEventListener() {},
  removeEventListener() {},
  matchMedia() { return mediaQuery; },
};

const payloadFor = (value) => template
  .replace("__DREAM_SKIN_CSS_JSON__", JSON.stringify(`/* ${value.id} */`))
  .replace("__DREAM_SKIN_ART_JSON__", JSON.stringify("data:image/png;base64,AA=="))
  .replace("__DREAM_SKIN_THEME_JSON__", JSON.stringify(value))
  .replace("__DREAM_SKIN_VERSION_JSON__", JSON.stringify("test"));

const context = vm.createContext({
  window,
  document,
  MutationObserver: class { observe() {} disconnect() {} },
  Blob: class {},
  URL: { createObjectURL: () => "blob:test", revokeObjectURL() {} },
  atob: (input) => Buffer.from(input, "base64").toString("binary"),
  getComputedStyle: () => ({ colorScheme: "light", backgroundColor: "transparent" }),
  setTimeout: () => 1,
  clearTimeout() {},
  setInterval: () => 1,
  clearInterval() {},
});
if (theme.preset !== "rose") {
  const rose = JSON.parse(await fs.readFile(path.join(rootDir, "themes", "rose-editorial", "theme.json"), "utf8"));
  vm.runInContext(payloadFor(rose), context);
  if (attributes.get("data-dream-preset") !== "rose") throw new Error("hot-switch setup did not apply rose");
}
vm.runInContext(payloadFor(theme), context);

const actual = {
  background: values.get("--ds-bg"),
  panel: values.get("--ds-panel"),
  panelAlt: values.get("--ds-panel-2"),
  accent: values.get("--ds-green"),
  accentAlt: values.get("--ds-lime"),
  secondary: values.get("--ds-cyan"),
  highlight: values.get("--ds-purple"),
  text: values.get("--ds-text"),
  muted: values.get("--ds-muted"),
  line: values.get("--ds-line"),
};
const expected = theme.lightColors;
if (theme.preset !== "rose" && actual.background === "#f6f2f3") {
  throw new Error(`${theme.id}: light shell still uses the rose background ${actual.background}`);
}
if (expected) {
  for (const [name, value] of Object.entries(expected)) {
    if (actual[name] !== value) {
      throw new Error(`${theme.id}: expected light ${name} ${value}, got ${actual[name]}`);
    }
  }
}
if (actual.accent !== (theme.lightColors?.accent || theme.colors.accent)) {
  throw new Error(`${theme.id}: accent is not linked to theme colors`);
}
if (attributes.get("data-dream-preset") !== theme.preset || window.__CODEX_DREAM_SKIN_STATE__?.themeId !== theme.id) {
  throw new Error(`${theme.id}: hot switch kept stale runtime theme attributes`);
}
if (elements.get("codex-dream-skin-style")?.textContent !== `/* ${theme.id} */`) {
  throw new Error(`${theme.id}: hot switch kept the previous injected stylesheet`);
}

process.stdout.write(`${JSON.stringify({ themeId: theme.id, actual })}\n`);
