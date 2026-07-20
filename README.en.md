# Codex Dream Skin

<p align="center">
  <a href="./README.md">中文</a> · <strong>English</strong>
</p>

<p align="center">
  <strong>Give the Codex desktop app a theme you enjoy.</strong><br>
  Keep your projects, tasks, composer, and normal controls. Change only the appearance.
</p>

<p align="center">
  Unofficial and not affiliated with OpenAI. This project does not modify the official <code>.app</code>, <code>app.asar</code>, WindowsApps package, or code signature.
</p>

> **New Mac users only need this sentence:** open the official Codex app once, open the [`macos`](./macos/) folder, double-click **`Generate Codex Dream Skin.command`**, and follow the prompts to choose an image.

## What is this?

Codex Dream Skin is a theme tool for the Codex desktop app. It can:

- apply one coordinated theme to the home page, sidebar, suggestion cards, and composer;
- use any of the five built-in themes or generate a theme from your own image;
- keep the original Codex buttons, fields, and controls fully interactive;
- restore the official appearance with one double-click; and
- inject styles through a local loopback connection without modifying the official app package.

## Choose your platform

| Platform | Status | Start here |
| --- | --- | --- |
| macOS, Apple Silicon or Intel | Recommended; full feature set | [`macos/`](./macos/) |
| Windows | Experimental; not continuously tested on real Windows hardware | [`windows/`](./windows/) |

The next section covers the easiest **graphical installation on macOS**. You do not need programming experience or a separate Node.js installation.

## macOS: first-time installation

### 1. Install and open the official Codex app once

Make sure the official Codex Desktop app is installed and has opened successfully at least once. Its first launch creates the configuration file that the theme installer needs.

If you have not signed in yet, you can finish signing in before continuing.

### 2. Keep the complete project folder

If you downloaded a ZIP from GitHub:

1. Extract the ZIP.
2. Do not copy only an image, CSS file, or individual `.command` file.
3. Open the extracted `Codex-Dream-Skin` folder.
4. Open the [`macos`](./macos/) folder inside it.

The scripts, themes, and assets need to stay together. The installer may fail if part of the folder is missing.

### 3. Double-click the one-click generator

Double-click:

```text
Generate Codex Dream Skin.command
```

It installs the local engine, prepares your image, applies the theme, and verifies the result. During the process:

1. Choose an image in the Finder window.
2. Enter a name for the theme.
3. If Codex asks for permission to restart, approve the restart.
4. Wait until Terminal reports completion. Codex will open with the new theme.

If you do not want to choose your own image yet, double-click:

```text
Install Codex Dream Skin.command
```

This installs the tool and launches the bundled default theme.

### 4. How to start it later

Installation creates these launchers on your Desktop:

| Desktop file | What it does |
| --- | --- |
| `Codex Dream Skin.command` | Starts Codex with the skin |
| `Codex Dream Skin - Generate.command` | Chooses a new image and generates a theme |
| `Codex Dream Skin - Customize.command` | Customizes the current theme |
| `Codex Dream Skin - Verify.command` | Verifies the theme and saves a screenshot to the Desktop |
| `Codex Dream Skin - Restore.command` | Restores the official appearance |

For normal daily use, double-click **`Codex Dream Skin.command`** on your Desktop. If you launch Codex from its official icon, the skin may not be injected automatically.

You can also use [`Start Codex Dream Skin.command`](./macos/Start%20Codex%20Dream%20Skin.command) from the repository, but installation must be completed first.

## macOS: switch between five built-in themes

The built-in themes are:

- Pink Editorial (`rose-editorial`)
- Mecha Forge (`mecha-forge`)
- Green Focus (`green-focus`)
- Cyber Grid (`cyber-grid`)
- Obsidian Zero (`obsidian-zero`)

### Option 1: use the menu bar

In the [`macos`](./macos/) folder, double-click:

```text
Install Menu Bar.command
```

After installation, **🎨 Skin** appears in the top-right menu bar. Use it to select a theme, move to the next theme, or enable automatic rotation every 30 minutes.

The menu bar integration uses [SwiftBar](https://github.com/swiftbar/SwiftBar). If Homebrew is already installed, the script can install SwiftBar automatically. Otherwise, it will ask you to install SwiftBar manually first.

### Option 2: copy a command into Terminal

Open Terminal, paste any of these commands, and press Return:

```bash
~/.local/bin/codex-dream-skin list
~/.local/bin/codex-dream-skin use rose-editorial
~/.local/bin/codex-dream-skin use mecha-forge
~/.local/bin/codex-dream-skin use green-focus
~/.local/bin/codex-dream-skin use cyber-grid
~/.local/bin/codex-dream-skin use obsidian-zero
```

Automatic rotation:

```bash
~/.local/bin/codex-dream-skin auto on
~/.local/bin/codex-dream-skin auto off
```

Manual theme switching does not restart Codex without permission. If the current Codex session was not started through the skin launcher, the selection is saved and applied the next time you use the skin launcher.

## macOS: restore the official appearance

Double-click [`macos/Restore Codex Dream Skin.command`](./macos/Restore%20Codex%20Dream%20Skin.command), or use the Desktop launcher:

```text
Codex Dream Skin - Restore.command
```

Restore stops theme injection and automatic rotation, restores the backed-up appearance settings, and starts Codex normally. It does not delete your projects, task history, sign-in state, plugins, or Skills.

## Choosing a good image

- Supported formats: PNG, JPEG, HEIC, TIFF, and WebP.
- Keep the source image under 50 MB.
- A landscape 16:9 image works best; a width of at least 2000 pixels is recommended.
- Keep the left side relatively quiet because Codex usually places titles and controls there.
- Artwork with its main subject near the center-right usually works well.
- Avoid heavy text, watermarks, fake buttons, or screenshots of application interfaces.

Portrait and square images also work. The tool automatically quiets the artwork on task pages to keep text readable.

## Gallery

These screenshots show the five built-in visual directions. A theme changes the visual styling only; it does not copy sample text or content from the screenshot into your Codex app.

<p align="center">
  <img src="docs/images/screenshot-mac-pinkgirl.png" alt="Pink Editorial" width="900"><br>
  <sub>Pink Editorial</sub>
</p>

<p align="center">
  <img src="docs/images/screenshot-mac-mecha.png" alt="Mecha Forge" width="900"><br>
  <sub>Mecha Forge</sub>
</p>

<p align="center">
  <img src="docs/images/screenshot-mac-green.png" alt="Green Focus" width="900"><br>
  <sub>Green Focus</sub>
</p>

<p align="center">
  <img src="docs/images/screenshot-mac-cyber.png" alt="Cyber Grid" width="900"><br>
  <sub>Cyber Grid</sub>
</p>

<p align="center">
  <img src="docs/images/screenshot-mac-obsidian.png" alt="Obsidian Zero" width="900"><br>
  <sub>Obsidian Zero</sub>
</p>

## Troubleshooting

### macOS refuses to open a `.command` file

In Finder, right-click the file and choose **Open**, then choose **Open** again in the confirmation dialog. Only run project files obtained from a source you trust.

### The installer says it cannot find the Codex configuration

Open the official Codex app normally, wait for its home page to load, close Codex, and run the installer again.

### A launcher says that installation is required

Run `Generate Codex Dream Skin.command` or `Install Codex Dream Skin.command` first. After installation succeeds, you can use Start, Customize, Verify, and Restore.

### Codex is open, but the theme is missing

Codex may have been opened from the official app icon. Double-click `Codex Dream Skin.command` on your Desktop. If it asks to restart Codex, approve the restart and wait for Codex to reopen.

### The theme disappeared after a Codex update

Run `Generate Codex Dream Skin.command` or `Install Codex Dream Skin.command` again. The installer discovers the current official Codex app and updates the local theme engine.

### How do I check whether installation succeeded?

Double-click `Codex Dream Skin - Verify.command` on your Desktop. After a successful verification, this file appears on the Desktop:

```text
Codex Dream Skin Verification.png
```

### Terminal reports `permission denied`

Open Terminal in the project root and run:

```bash
chmod +x macos/*.command macos/scripts/*.sh
```

Then double-click the relevant `.command` file again.

### I still need help

Run the diagnostic script:

```bash
cd macos
./scripts/doctor-macos.sh
```

When filing an Issue, include your macOS version, Codex version, the launcher you used, and the last section of the Terminal error. Do not upload API keys, `~/.codex/auth.json`, or screenshots containing private information.

## Windows: experimental setup

> The project is not currently tested continuously on Windows hardware. The Windows scripts still provide install, launch, verification, and restore operations, but the experience differs from macOS and custom image generation is not supported yet.

Before starting, make sure you have:

- the official Codex app installed from the Microsoft Store;
- opened Codex successfully at least once; and
- installed Node.js so that `node --version` prints a version in PowerShell.

Open PowerShell in the extracted project folder, then run:

```powershell
cd .\windows
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-dream-skin.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-dream-skin.ps1 -RestartExisting
```

The installer creates a `Codex Dream Skin` shortcut on the Desktop and in the Start menu. Use that shortcut for future launches.

Restore the official appearance:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\restore-dream-skin.ps1 -RestoreBaseTheme
```

See [`windows/SKILL.md`](./windows/SKILL.md) for Windows implementation details and safety constraints.

## Safety

The theme connects to the official Codex app through Chromium DevTools Protocol (CDP):

- CDP listens on the local loopback address `127.0.0.1` only.
- The project does not modify the official app, `app.asar`, WindowsApps package, or code signature.
- It does not rewrite API keys, model providers, or the Base URL.
- It backs up and changes only the required appearance settings, which Restore can put back.
- CDP has powerful access. Avoid running untrusted local software while the skin is active, and use Restore when you do not need the skin.

## For advanced users

Generate and apply a macOS theme with one command:

```bash
cd macos
./scripts/generate-dream-skin-macos.sh \
  --image "/absolute/path/to/your-image.png" \
  --name "My theme"
```

More documentation:

- [Complete macOS guide](./macos/README.md)
- [Platform paths and feature matrix](./docs/platforms.md)
- [Project structure and maintenance notes](./docs/PROJECT.md)
- [macOS changelog](./macos/CHANGELOG.md)
- [Issue templates](./.github/ISSUE_TEMPLATE/)

## License and notices

- MIT License: [`macos/LICENSE`](./macos/LICENSE)
- Additional notices: [`macos/NOTICE.md`](./macos/NOTICE.md)
- This project is not affiliated with OpenAI. Codex and related trademarks belong to their respective owners.
- People and IP shown in preview artwork are illustrative. Confirm the necessary rights before public or commercial redistribution.

---

If this project helped you, consider giving it a Star. Then pick an image you like and make Codex feel like a place you want to open every day.
