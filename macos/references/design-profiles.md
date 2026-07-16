# Design profiles and visual review

Choose the visual system before running the generator. Image statistics are a fallback signal, not a substitute for looking at the source.

## `rose` — bright editorial portrait

Use for bright, warm, romantic, pink/red, fashion, portrait, or lifestyle imagery with generous negative space. It works best with a wide banner and a subject near the center-right.

Expected result:

- A deliberate pink editorial shell, layered glass surfaces, branded home hierarchy, four native suggestion cards, and a restrained task background.
- The subject remains recognizable in the home banner; the left side stays calm enough for live native headings.
- The theme feels like the original composed skin, not a pale image placed behind Codex.

Visual target: `visual-targets/rose-home.png` in a packaged release, or `../../docs/images/gallery/skin.png` in the source checkout. Use the bundled `assets/banner-arina-hashimoto-pure-no-ui.png` as the profile's source-art example.

## `portal` — dark cinematic technology

Use for dark, cinematic, sci-fi, action, fantasy, neon, space, architecture, or high-contrast illustrated imagery.

Expected result:

- A dark portal shell with strong depth, a bounded hero banner, luminous accents, and solid readable task surfaces.
- Artwork creates atmosphere around the content instead of competing with code or long-form text.

Visual targets: `visual-targets/portal-home.png` and `visual-targets/portal-task.png` in a packaged release, or `../../docs/images/screenshot-macos-home.png` and `../../docs/images/screenshot-macos-task.png` in the source checkout. The bundled `assets/portal-hero.png` is the profile's source-art example.

## `adaptive` — conservative fallback

Use only when neither curated profile fits, such as neutral product photography, abstract palettes, or square/portrait images that need extra task-page quieting.

Adaptive must still preserve a bounded home banner, native cards, project selector, composer, and readable task surfaces. Do not accept it merely because the colors match.

## Visual review loop

1. Inspect the source image and record subject position, negative space, brightness, temperature, and visual genre.
2. Generate with an explicit profile and a saved verification screenshot.
3. Inspect the screenshot next to the closest repository target when it exists.
4. Reject generic-wallpaper results, weak hierarchy, overexposed task surfaces, muddy text, clipped cards, poor subject crops, fake raster UI, and decoration intercepting clicks.
5. Adjust `--preset`, `--art-position`, or the generated source image and repeat.
6. Finish only when the live verifier passes and the result is visually comparable to the selected profile target.

For the double-click workflow, deterministic fallback chooses `rose` for bright warm wide images, `portal` for dark wide images, and `adaptive` otherwise.
