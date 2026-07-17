#!/usr/bin/env node

// Regression seam for the four curated non-rose home layouts. These themes
// intentionally share the rose preset's desktop rhythm while keeping their
// own palette, typography, radii, shadows, and artwork.

import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const showcaseThemes = ["mecha-forge", "green-focus", "cyber-grid", "obsidian-zero"];
const [css, rose, ...themes] = await Promise.all([
  fs.readFile(path.join(root, "assets", "dream-skin.css"), "utf8"),
  fs.readFile(path.join(root, "themes", "rose-editorial", "theme.json"), "utf8").then(JSON.parse),
  ...showcaseThemes.map((id) =>
    fs.readFile(path.join(root, "themes", id, "theme.json"), "utf8").then(JSON.parse)),
]);

if (rose.homeLayout !== "editorial") {
  throw new Error("rose theme no longer owns the editorial reference layout");
}
for (const theme of themes) {
  if (theme.homeLayout !== "showcase") {
    throw new Error(`${theme.id}: expected the curated showcase layout`);
  }
  if (!css.includes(`[data-dream-theme="${theme.id}"]`)) {
    throw new Error(`${theme.id}: has no theme-specific material styling`);
  }
}

const requiredRules = [
  ['data-dream-layout="showcase"', "showcase layout selector"],
  ["flex: 0 0 535px", "desktop vertical rhythm"],
  ["height: 400px", "desktop hero height"],
  ["transform: translate(-54px, 0)", "desktop composer alignment"],
  ["left: 42px", "desktop brand alignment"],
  ["width: 38px", "desktop brand artwork size"],
  ['data-dream-shell="light"', "light-shell theme surface"],
  ["group\\/project-selector > button", "theme-linked project selector"],
  ["@media (max-width: 1120px)", "compact desktop breakpoint"],
  ["@media (max-width: 900px)", "narrow layout breakpoint"],
];
for (const [needle, label] of requiredRules) {
  if (!css.includes(needle)) throw new Error(`showcase CSS lost ${label}`);
}

process.stdout.write("showcase layouts: rose rhythm and four theme materials linked\n");
