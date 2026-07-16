import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, "..");
const [mode, ...args] = process.argv.slice(2);

function valueFor(name, fallback = "") {
  const index = args.indexOf(`--${name}`);
  if (index < 0) return fallback;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) throw new Error(`Missing value for --${name}`);
  return value;
}

function validateHex(value, name) {
  if (!/^#[0-9a-f]{6}$/i.test(value)) throw new Error(`${name} must be a six-digit hex color.`);
  return value.toLowerCase();
}

function parsePalette(value) {
  try {
    const parsed = JSON.parse(value || "{}");
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) throw new Error();
    return parsed;
  } catch {
    throw new Error("palette-json must be a JSON object produced by analyze-image.mjs.");
  }
}

function hexToRgba(hex, alpha) {
  const value = Number.parseInt(hex.slice(1), 16);
  return `rgba(${value >> 16}, ${(value >> 8) & 255}, ${value & 255}, ${alpha})`;
}

async function atomicWrite(file, value) {
  await fs.mkdir(path.dirname(file), { recursive: true, mode: 0o700 });
  const temporary = `${file}.${process.pid}.tmp`;
  try {
    await fs.writeFile(temporary, value, { mode: 0o600 });
    await fs.rename(temporary, file);
    await fs.chmod(file, 0o600);
  } finally {
    await fs.rm(temporary, { force: true }).catch(() => {});
  }
}

const outputDir = path.resolve(valueFor("output-dir", path.join(root, "assets")));
const themePath = path.join(outputDir, "theme.json");

if (mode === "reset-demo") {
  if (outputDir === path.join(root, "assets")) {
    throw new Error("Refusing to delete the bundled demo assets; pass a user --output-dir.");
  }
  await fs.rm(outputDir, { recursive: true, force: true });
  console.log("Restored the bundled abstract demo preset.");
  process.exit(0);
}

if (mode !== "custom") {
  throw new Error("Usage: write-theme.mjs custom [options] | reset-demo --output-dir <dir>");
}

const image = path.basename(valueFor("image", "background.jpg"));
if (!/\.(?:png|jpe?g|webp)$/i.test(image)) throw new Error("image must be a PNG, JPEG, or WebP filename.");
const imagePath = path.join(outputDir, image);
const imageStat = await fs.stat(imagePath);
if (!imageStat.isFile() || imageStat.size < 1 || imageStat.size > 16 * 1024 * 1024) {
  throw new Error("The prepared theme image must be non-empty and no larger than 16 MB.");
}

const name = valueFor("name", "我的 Codex Dream Skin").trim().slice(0, 80);
const tagline = valueFor("tagline", "把喜欢的画面变成可交互的 Codex 工作台。").trim().slice(0, 160);
const quote = valueFor("quote", "MAKE SOMETHING WONDERFUL").trim().slice(0, 80);
const palette = parsePalette(valueFor("palette-json", "{}"));
const preset = valueFor("preset", palette.preset || "portal").trim();
if (!/^[a-z0-9-]{1,32}$/.test(preset)) throw new Error("preset must use lowercase letters, digits, or hyphens.");
const artPosition = valueFor("art-position", palette.artPosition || "50% center").trim();
if (!/^(?:100|[1-9]?\d)% (?:center|(?:100|[1-9]?\d)%)$/.test(artPosition)) {
  throw new Error("art-position must look like '50% center'.");
}
const parsedAspectRatio = Number(valueFor("source-aspect-ratio", String(palette.aspectRatio || 1)));
const sourceAspectRatio = Number.isFinite(parsedAspectRatio) && parsedAspectRatio > 0 && parsedAspectRatio <= 20
  ? Number(parsedAspectRatio.toFixed(3)) : 1;
const background = validateHex(valueFor("background", palette.background || "#071116"), "background");
const panel = validateHex(valueFor("panel", palette.panel || "#0b1a20"), "panel");
const panelAlt = validateHex(valueFor("panel-alt", palette.panelAlt || "#10272c"), "panel-alt");
const accent = validateHex(valueFor("accent", palette.accent || "#7cff46"), "accent");
const accentAlt = validateHex(valueFor("accent-alt", palette.accentAlt || accent), "accent-alt");
const secondary = validateHex(valueFor("secondary", palette.secondary || "#36d7e8"), "secondary");
const highlight = validateHex(valueFor("highlight", palette.highlight || "#642a8c"), "highlight");
const text = validateHex(valueFor("text", palette.text || "#f2fff7"), "text");
const muted = validateHex(valueFor("muted", palette.muted || "#a7c2ba"), "muted");

const custom = {
  schemaVersion: 1,
  id: `custom-${Date.now()}`,
  preset,
  name: name || "我的 Codex Dream Skin",
  brandSubtitle: "CODEX DREAM SKIN",
  tagline: tagline || "把喜欢的画面变成可交互的 Codex 工作台。",
  projectPrefix: "选择项目 · ",
  projectLabel: "◉  选择项目",
  statusText: "DREAM SKIN ONLINE",
  quote: quote || "MAKE SOMETHING WONDERFUL",
  image,
  artPosition,
  sourceAspectRatio,
  colors: {
    background,
    panel,
    panelAlt,
    accent,
    accentAlt,
    secondary,
    highlight,
    text,
    muted,
    line: hexToRgba(accent, 0.32),
  },
};

await atomicWrite(themePath, `${JSON.stringify(custom, null, 2)}\n`);
console.log(`Saved custom theme “${custom.name}”.`);
