# QA inventory

## Required user-visible behavior

1. Home route shows one independent image banner, live native heading, two to four native suggestion cards, the real project selector, and native composer.
2. Normal tasks show the selected image behind restrained gradients and translucent live content surfaces.
3. Sidebar, navigation, messages, approvals, project selector, attachments, composer, menus, hover, focus, and keyboard input remain native and interactive.
4. Decorative layers have `pointer-events: none`; no screenshot or raster UI is used as an overlay.
5. Route changes, renderer reloads, and ordinary refreshes reapply the current theme while the verified injector runs.
6. Official application signature and `app.asar` remain unchanged.
7. Restore removes live DOM/CSS, restores the two saved base-theme values, closes the CDP session after restart, and supports later reinstallation.

## Automated checks

- Shell and JavaScript syntax checks.
- Payload construction with bundled demo and an isolated custom theme.
- Warm/cool image palette extraction, curated `rose` / `portal` profile routing, adaptive fallback generation, focal-position metadata, and explicit color override safety.
- Task screenshot quality gate rejects a bright high-saturation reading region above the `0.25` ratio limit.
- Reject unsupported theme config, unsafe image paths, invalid colors, oversized images, non-loopback WebSocket URLs, and unrecognized renderer targets.
- Exact install/restore round trip for the two TOML settings while preserving unrelated values.
- Empty `HOME` recovery.
- Official app and internal Node signature, Team ID, architecture, and version validation.
- Port collision selection and saved-port reuse.
- PID reuse protection through PID, start time, executable, script path, and command-line matching.
- Live verification after `Page.reload` returns the current `SKIN_VERSION` and `pass: true`.
- Strict home verification requires a visible banner of at least 320×160, two to four visible native cards, visible project button, composer, sidebar, non-interactive decoration, and no horizontal overflow.
- Home verification also requires a bounded brand thumbnail and real click hit-testing for every visible suggestion card.

## Visual checks

- Inspect the source image before generation, choose an explicit design profile, and compare the live screenshot beside the closest initial-design reference; palette and DOM checks alone cannot approve a skin.
- Reject a technically valid result when it reads as a generic wallpaper rather than the selected profile's complete hierarchy, surfaces, and composition.
- Home at normal desktop size: banner crop is readable, text remains live, cards are not clipped, and composer does not overlap content.
- Narrower window: quote/orbit decoration hides before covering essential controls.
- Task route: background remains atmospheric, messages and output panels keep high contrast, and the composer remains reachable.
- Task route: central reading-region bright high-saturation ratio stays at or below `0.25` in the generated verification screenshot.
- Selected image contains no fake interface controls or raster text intended to impersonate Codex.
- Inspect sidebar selection, header, banner edges, cards, project label, composer buttons, scrollbars, focus outlines, dialogs, and menus.

## Release signoff

- Run `tests/run-tests.sh` successfully.
- Install from a clean extracted copy with no global Node.js.
- Complete install → live verify → reload verify → restore → reinstall.
- Capture a real CDP screenshot and retain the verifier JSON.
- Confirm `codesign --verify --deep --strict` still succeeds for the official Codex app.
- Build ZIP and record SHA-256.
