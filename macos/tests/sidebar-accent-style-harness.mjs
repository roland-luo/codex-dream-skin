#!/usr/bin/env node

// The native account-row update badge ships with a fixed charts-blue token.
// Ensure Dream Skin keeps the control but repaints every visible state with
// the active theme variables.

import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const css = await fs.readFile(path.join(root, "assets", "dream-skin.css"), "utf8");
const selector = 'aside.app-shell-left-panel button[class~="bg-token-charts-blue"]';

if (!css.includes(selector)) {
  throw new Error("sidebar update badge has no theme-linked selector");
}

for (const [needle, label] of [
  ["color: var(--ds-green) !important", "theme accent foreground"],
  ["var(--ds-green) 14%, var(--ds-panel)", "theme-tinted resting surface"],
  ["border: 1px solid color-mix", "theme-tinted border"],
  [":hover", "hover state"],
  ["background: var(--ds-green) !important", "theme accent hover surface"],
  ["color: var(--ds-panel) !important", "contrasting hover foreground"],
]) {
  if (!css.includes(needle)) throw new Error(`sidebar update badge lost ${label}`);
}

process.stdout.write("sidebar update badge: theme-linked states\n");
