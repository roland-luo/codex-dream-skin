import fs from "node:fs";

const input = process.argv[2];
if (!input) throw new Error("Usage: analyze-image.mjs <small-uncompressed.bmp>");

const buffer = fs.readFileSync(input);
if (buffer.toString("ascii", 0, 2) !== "BM" || buffer.length < 54) {
  throw new Error("Image analysis requires a Windows BMP produced by sips.");
}

const pixelOffset = buffer.readUInt32LE(10);
const width = buffer.readInt32LE(18);
const signedHeight = buffer.readInt32LE(22);
const height = Math.abs(signedHeight);
const bitsPerPixel = buffer.readUInt16LE(28);
const compression = buffer.readUInt32LE(30);
if (width < 1 || height < 1 || width > 512 || height > 512 ||
    ![24, 32].includes(bitsPerPixel) || compression !== 0) {
  throw new Error("Unsupported BMP layout for image analysis.");
}

const bytesPerPixel = bitsPerPixel / 8;
const rowSize = Math.floor((bitsPerPixel * width + 31) / 32) * 4;
if (pixelOffset + rowSize * height > buffer.length) throw new Error("Truncated BMP pixel data.");

function rgbToHsv(r, g, b) {
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const delta = max - min;
  let hue = 0;
  if (delta > 0) {
    if (max === r) hue = 60 * (((g - b) / delta) % 6);
    else if (max === g) hue = 60 * ((b - r) / delta + 2);
    else hue = 60 * ((r - g) / delta + 4);
  }
  if (hue < 0) hue += 360;
  return { h: hue, s: max === 0 ? 0 : delta / max, v: max };
}

function hslToHex(hue, saturation, lightness) {
  const h = ((hue % 360) + 360) % 360 / 360;
  const s = Math.max(0, Math.min(1, saturation));
  const l = Math.max(0, Math.min(1, lightness));
  const channel = (p, q, raw) => {
    let t = raw;
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  };
  let values;
  if (s === 0) values = [l, l, l];
  else {
    const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    const p = 2 * l - q;
    values = [channel(p, q, h + 1 / 3), channel(p, q, h), channel(p, q, h - 1 / 3)];
  }
  return `#${values.map((value) => Math.round(value * 255).toString(16).padStart(2, "0")).join("")}`;
}

const pixels = [];
const buckets = Array.from({ length: 24 }, () => ({ weight: 0, x: 0, y: 0 }));
let meanValue = 0;
for (let y = 0; y < height; y += 1) {
  const sourceY = signedHeight < 0 ? y : height - y - 1;
  const row = pixelOffset + sourceY * rowSize;
  for (let x = 0; x < width; x += 1) {
    const at = row + x * bytesPerPixel;
    const b = buffer[at] / 255;
    const g = buffer[at + 1] / 255;
    const r = buffer[at + 2] / 255;
    const hsv = rgbToHsv(r, g, b);
    const weight = Math.max(0.015, hsv.s ** 1.45) * (0.35 + 0.65 * hsv.v);
    const bucket = buckets[Math.floor(hsv.h / 15) % buckets.length];
    bucket.weight += weight;
    bucket.x += Math.cos(hsv.h * Math.PI / 180) * weight;
    bucket.y += Math.sin(hsv.h * Math.PI / 180) * weight;
    pixels.push({ x, s: hsv.s, v: hsv.v });
    meanValue += hsv.v;
  }
}
meanValue /= pixels.length;

const dominant = buckets.reduce((best, bucket) => bucket.weight > best.weight ? bucket : best, buckets[0]);
let hue = Math.atan2(dominant.y, dominant.x) * 180 / Math.PI;
if (!Number.isFinite(hue) || dominant.weight < pixels.length * 0.025) hue = 210;
if (hue < 0) hue += 360;

let focusWeight = 0;
let focusX = 0;
for (const pixel of pixels) {
  const weight = 0.08 + pixel.s * (0.18 + Math.abs(pixel.v - meanValue) * 1.8);
  focusWeight += weight;
  focusX += pixel.x * weight;
}
const focusPercent = Math.round(Math.max(25, Math.min(75, (focusX / focusWeight) / Math.max(1, width - 1) * 100)));
const temperature = hue <= 82 || hue >= 330 ? "warm" : "cool";
const accent = hslToHex(hue, 0.68, hue >= 42 && hue <= 72 ? 0.40 : 0.47);
const aspectRatio = width / height;

// Curated presets carry the composition and surface treatment that made the
// original themes feel designed. Adaptive remains the conservative fallback.
let preset = "adaptive";
if (aspectRatio >= 1.65 && meanValue >= 0.82 && temperature === "warm") {
  preset = "rose";
} else if (aspectRatio >= 1.45 && meanValue <= 0.62) {
  preset = "portal";
}

const result = {
  preset,
  temperature,
  dominantHue: Math.round(hue),
  averageBrightness: Number(meanValue.toFixed(3)),
  aspectRatio: Number(aspectRatio.toFixed(3)),
  artPosition: `${focusPercent}% center`,
  background: hslToHex(hue, 0.34, 0.07),
  panel: hslToHex(hue, 0.27, 0.11),
  panelAlt: hslToHex(hue + 10, 0.24, 0.15),
  accent,
  accentAlt: hslToHex(hue, 0.72, 0.62),
  secondary: hslToHex(hue + (temperature === "warm" ? 28 : 36), 0.58, 0.66),
  highlight: hslToHex(hue - 18, 0.62, 0.38),
  text: hslToHex(hue, 0.10, 0.94),
  muted: hslToHex(hue, 0.13, 0.70),
};

console.log(JSON.stringify(result));
