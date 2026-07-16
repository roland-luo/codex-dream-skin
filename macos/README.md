# Codex Dream Skin Studio

Unofficial macOS theme studio for the **official Codex Desktop** app.

Turn an image you like into a Codex theme: a dedicated home banner, a low-noise task background, and frosted content layers — while **keeping native sidebar, suggestion cards, project picker, task content, menus, and composer** fully interactive.

This project injects through **local loopback CDP**. It does **not** modify the official `.app`, `app.asar`, or code signature.

> Not affiliated with OpenAI. Codex is a trademark of its respective owners.

## Requirements

- macOS
- Official Codex Desktop installed and launched at least once (`~/.codex/config.toml` exists)
- No global Node.js install required (uses Codex’s signed bundled Node after validation)

## One-click generation (from this repo or Skill)

```bash
./scripts/generate-dream-skin-macos.sh \
  --image "/path/to/image.png" \
  --name "My theme"
```

That single command installs or updates the stable engine, prepares the image, derives matching accent colors and a focal position, selects a curated `rose` or `portal` design profile when the artwork fits (with `adaptive` as the fallback), applies it, and verifies the live native UI. When an AI runs the Skill, it also inspects the saved screenshot against the initial-design target before approving the result. Task pages keep the artwork deliberately subdued so code and long-form text remain readable. Omit the options to choose an image and name interactively, or double-click `Generate Codex Dream Skin.command`.

If Codex is already running without the verified skin CDP endpoint, macOS asks once before restarting it. The installer also creates Desktop launchers for generate, customize, start, verify, and restore.

Optional menu bar controls: double-click `Install Menu Bar.command`, then look for 🎨 Skin in the top-right menu bar.

Install location after step 2:

| Item | Path |
| --- | --- |
| Engine | `~/.codex/codex-dream-skin-studio` |
| State / logs / user images | `~/Library/Application Support/CodexDreamSkinStudio` |
| Theme backup | under Application Support (`theme-backup.json`) |

## Customer ZIP (optional packaging)

To build the “double-click install” folder layout for non-git users:

```bash
./scripts/build-client-release.sh "$HOME/Desktop/Codex 主题编辑器.zip"
```

That ZIP contains a visible installer plus a hidden `.codex-dream-skin-studio` engine. Do not ship only CSS/images.

## How it works (security boundary)

1. Discover `com.openai.codex` and validate signature / Team ID / arch / bundled Node.
2. Start Codex via user `launchd` with CDP bound to `127.0.0.1` only.
3. Accept the debug port only when it belongs to Codex (or a legitimate child).
4. Inject only into expected `app://` renderer targets.
5. Keep a small injector alive across reloads and route changes.
6. Restore stops the injector only when PID, path, and start time match the recorded job.

CDP is powerful and unauthenticated on loopback. Prefer Restore when you are done theming.

## Image guidelines

- PNG / JPEG / HEIC / TIFF / WebP (macOS readable)
- Source ≤ 50 MB; prepared file ≤ 16 MB
- 16:9 wide images work best (width ≥ 2000 px recommended); square and portrait images receive stronger task-page quieting
- Keep the left third relatively calm for native home titles and put the main subject near the center-right
- Avoid text, logos, watermarks, fake UI, and screenshots of application chrome
- Image is banner + background only — never a full-window fake UI overlay

Advanced CLI example:

```bash
~/.codex/codex-dream-skin-studio/scripts/generate-dream-skin-macos.sh \
  --image "/path/to/image.png" \
  --name "My theme" \
  --preset "rose" \
  --art-position "58% center" \
  --accent "#7cff46" \
  --secondary "#36d7e8" \
  --highlight "#642a8c"
```

Reset to the bundled abstract demo:

```bash
~/.codex/codex-dream-skin-studio/scripts/generate-dream-skin-macos.sh --reset-demo
```

## License

MIT — see `LICENSE`. Additional notices in `NOTICE.md` (trademarks, demo asset, runtime Node).

## Sponsors

Thanks to **[passion8.cc](https://passion8.cc/register?aff=TuPe)** for sponsoring this project.

<p align="center">
  <a href="https://passion8.cc/register?aff=TuPe">
    <img src="../docs/images/sponsor-passion8.png" alt="Passion8" height="96">
  </a>
</p>

<p align="center">
  <a href="https://passion8.cc/register?aff=TuPe"><strong>Passion8｜感谢 passion8.cc 赞助本项目</strong></a><br>
  AI API 中转站，支持 Codex / Claude Code / Grok 等工具接入。主题与 API 配置互相独立。
</p>

## What this is not

- Not an OpenAI product and not a fork of Codex source
- Not a way to patch or rebrand the official binary
- Not a Windows build (see `../windows/`)
- Not an API proxy: theming does not change model providers or API keys

If you use a third-party API relay, configure it separately — keep theme install and API config as two explicit steps.
