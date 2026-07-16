import fs from "node:fs";

const input = process.argv[2];
const limit = Number(process.argv[3] || 0.25);
if (!input || !Number.isFinite(limit) || limit <= 0 || limit >= 1) {
  throw new Error("Usage: check-visual-quality.mjs <screenshot.bmp> [max-high-saturation-ratio]");
}

const buffer = fs.readFileSync(input);
if (buffer.toString("ascii", 0, 2) !== "BM" || buffer.length < 54) {
  throw new Error("Visual quality check requires a Windows BMP produced by sips.");
}

const pixelOffset = buffer.readUInt32LE(10);
const width = buffer.readInt32LE(18);
const signedHeight = buffer.readInt32LE(22);
const height = Math.abs(signedHeight);
const bitsPerPixel = buffer.readUInt16LE(28);
const compression = buffer.readUInt32LE(30);
if (width < 1 || height < 1 || ![24, 32].includes(bitsPerPixel) || compression !== 0) {
  throw new Error("Unsupported BMP layout for visual quality check.");
}

const bytesPerPixel = bitsPerPixel / 8;
const rowSize = Math.floor((bitsPerPixel * width + 31) / 32) * 4;
if (pixelOffset + rowSize * height > buffer.length) throw new Error("Truncated BMP pixel data.");

const x0 = Math.max(0, Math.floor(width * 0.33));
const x1 = Math.min(width, Math.max(x0 + 1, Math.ceil(width * 0.83)));
const y0 = Math.max(0, Math.floor(height * 0.06));
const y1 = Math.min(height, Math.max(y0 + 1, Math.ceil(height * 0.80)));
let sampled = 0;
let highSaturation = 0;

for (let y = y0; y < y1; y += 1) {
  const sourceY = signedHeight < 0 ? y : height - y - 1;
  const row = pixelOffset + sourceY * rowSize;
  for (let x = x0; x < x1; x += 1) {
    const at = row + x * bytesPerPixel;
    const b = buffer[at] / 255;
    const g = buffer[at + 1] / 255;
    const r = buffer[at + 2] / 255;
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    const saturation = max === 0 ? 0 : (max - min) / max;
    if (saturation > 0.35 && max > 0.32) highSaturation += 1;
    sampled += 1;
  }
}

const ratio = sampled ? highSaturation / sampled : 1;
const pass = ratio <= limit;
console.log(JSON.stringify({
  pass,
  taskContentHighSaturationRatio: Number(ratio.toFixed(3)),
  limit,
  crop: { x0, y0, x1, y1 },
}));
if (!pass) process.exitCode = 2;
