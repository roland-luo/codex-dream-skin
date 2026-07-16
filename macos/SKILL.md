---
name: codex-dream-skin-studio
description: Art-direct, generate, install, apply, visually review, customize, repair, or restore Codex Dream Skin Studio on macOS. Use when a user wants a polished Codex skin from a local or AI-generated image, a one-invocation or double-click theme workflow, safe loopback-CDP troubleshooting, or complete rollback without modifying the official app.
---

# Codex Dream Skin Studio

Use this Skill with macOS, the official Codex Desktop app, and its signed bundled Node.js 20 or newer.

## Art-directed one-invocation workflow

1. Read `references/design-profiles.md` completely before generating anything.
2. Resolve the source image to an absolute path and inspect it visually. If the user supplied only a description, generate a 16:9 background with no text, logo, watermark, fake UI, or interface chrome; keep the left third calm for live headings and place the subject near the center-right. Inspect the generated file too.
3. Select one explicit design profile from the reference. Prefer a curated profile (`rose` or `portal`) whenever the image fits; use `adaptive` only as a deliberate fallback. Palette extraction is not art direction.
4. Tell the user that Codex may show one explicit restart confirmation when its verified loopback CDP endpoint is not already active.
5. From the directory containing this file, run:

   ```bash
   ./scripts/generate-dream-skin-macos.sh \
     --image "/absolute/path/to/background.png" \
     --name "My Codex Skin" \
     --preset "rose" \
     --screenshot "/absolute/path/to/skin-review.png"
   ```

   Omit `--image` and `--name` only when an interactive Finder picker and name dialog are appropriate. Use `--art-position "58% center"` when visual inspection shows that automatic focus would crop the subject.
6. Inspect the saved screenshot visually. Compare it beside the matching target in `references/visual-targets/` when packaged targets are present; otherwise use the source-checkout target listed in `references/design-profiles.md`. Structural verification alone is never sufficient.
7. If the result looks like a generic wallpaper, loses hierarchy, crops the subject, muddies text, or is visibly weaker than the initial-design reference, adjust the profile, focal position, or source artwork and rerun the same command. Keep the whole loop inside this one Skill execution.
8. Report success only after both strict live verification and visual comparison pass. On task pages, native text must sit on a quiet, high-contrast surface. If strict verification fails, inspect `~/Library/Application Support/CodexDreamSkinStudio/` logs before changing files.

Use `Generate Codex Dream Skin.command` for the same workflow by double-click. Use `--screenshot "/absolute/path.png"` when the user requests visual proof, and `--no-apply` only when the user explicitly wants theme files prepared without changing the live app.

Restore the official appearance with `Restore Codex Dream Skin.command`.

## Guardrails

- Never modify the official `.app`, `app.asar`, or its code signature.
- Use the official Codex app's signed Node.js runtime only after validating its signature, Team ID, architecture, and minimum version.
- Bind CDP to loopback, verify that the listener belongs to Codex, and reject non-Codex renderer targets.
- Preserve all native cards, navigation, project selectors, task content, composer controls, and keyboard focus.
- Preserve the selected profile's complete visual system; do not reduce it to extracted colors plus a full-window wallpaper.
- Keep decoration at `pointer-events: none`.
- Require explicit authorization before restarting an already-running Codex instance.
- Stop an injector only when its recorded PID, executable, command line, and start time all match.

## Key resources

- `README.md`: user installation and customization guide.
- `scripts/injector.mjs`: CDP connection, injection, removal, verification, and screenshots.
- `scripts/generate-dream-skin-macos.sh`: one-command install, generate, apply, and verify orchestration.
- `scripts/analyze-image.mjs`: deterministic BMP palette and focal-position analysis for adaptive custom themes.
- `references/design-profiles.md`: curated profile selection and visual acceptance targets.
- `assets/dream-skin.css`: live native interface styling.
- `assets/renderer-inject.js`: idempotent DOM integration and cleanup.
- `scripts/doctor-macos.sh`: signed-runtime, payload, and optional live-session self-check.
- `references/qa-inventory.md`: release and visual acceptance criteria.
