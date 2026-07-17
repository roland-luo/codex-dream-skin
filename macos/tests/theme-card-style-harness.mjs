#!/usr/bin/env node

// Regression seam for the bottom-right artwork card. The renderer always
// creates it; this check ensures every non-rose built-in theme has a visible,
// theme-addressable home-state rule instead of inheriting display:none.

import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const [css, renderer, manifest] = await Promise.all([
  fs.readFile(path.join(root, "assets", "dream-skin.css"), "utf8"),
  fs.readFile(path.join(root, "assets", "renderer-inject.js"), "utf8"),
  fs.readFile(path.join(root, "themes", "manifest.json"), "utf8").then(JSON.parse),
]);

if (!renderer.includes('class="dream-skin-polaroid"')) {
  throw new Error("renderer no longer creates the bottom-right theme card");
}
const visibleRule = /#codex-dream-skin-chrome\.dream-skin-home-shell:not\(\[data-dream-preset="rose"\]\) \.dream-skin-polaroid\s*\{[^}]*display:\s*flex/s;
if (!visibleRule.test(css)) {
  throw new Error("non-rose home themes still hide the bottom-right card");
}
if (!renderer.includes("chrome.dataset.dreamTheme")) {
  throw new Error("renderer does not expose the active theme ID to card styles");
}

for (const themeId of manifest.themes.filter((id) => id !== "rose-editorial")) {
  if (!css.includes(`[data-dream-theme="${themeId}"] .dream-skin-polaroid`)) {
    throw new Error(`${themeId}: bottom-right card has no theme-linked style`);
  }
}
if (!css.includes("calc(100cqw - 190px)")) {
  throw new Error("non-rose home layout does not reserve a lane for the theme card");
}
if (!/@media \(max-width: 1120px\)[\s\S]*#codex-dream-skin-chrome:not\(\[data-dream-preset="rose"\]\) \.dream-skin-polaroid\s*\{[^}]*display:\s*none\s*!important/s.test(css)) {
  throw new Error("theme card does not hide before it can overlap compact layouts");
}

process.stdout.write("theme cards: visible and theme-linked\n");
