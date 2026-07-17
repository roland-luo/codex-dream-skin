# Design QA — Cohesive five-theme home and aligned composer (1.6.0)

- Source visual truth: the live rose editorial home, captured at `/private/tmp/codex-dream-skin-final-1609-00-rose.png`
- User alignment reference: `/var/folders/9k/nc7074ws7_d_zywslx42tpxc0000gn/T/codex-clipboard-661179d5-6b39-4e28-bcaf-19d49cc1437c.png`
- Current user references: `/var/folders/9k/nc7074ws7_d_zywslx42tpxc0000gn/T/codex-clipboard-3e03bbd5-ed28-4f6d-bdf0-4eb1e5910587.png`, `/var/folders/9k/nc7074ws7_d_zywslx42tpxc0000gn/T/codex-clipboard-cbcd37ff-3919-4a62-a154-fb19bcffc7ab.png`, `/var/folders/9k/nc7074ws7_d_zywslx42tpxc0000gn/T/codex-clipboard-e1c40d05-028b-4d7b-be53-0221f9eef039.png`
- Live target screenshots: `/private/tmp/codex-dream-skin-final-1609-01-mecha.png`, `/private/tmp/codex-dream-skin-final-1609-02-green.png`, `/private/tmp/codex-dream-skin-final-1609-03-cyber.png`, `/private/tmp/codex-dream-skin-final-1609-04-obsidian.png`
- Current implementation screenshots: `/private/tmp/cyber-grid-copy-fixed-full.png`, `/private/tmp/cyber-grid-copy-fixed-focus.png`, `/private/tmp/cyber-grid-update-theme-linked.png`, `/private/tmp/cyber-grid-project-composer-equal.png`
- Comparison inputs: `/private/tmp/codex-dream-skin-final-compare-01-mecha.png`, `/private/tmp/codex-dream-skin-final-compare-02-green.png`, `/private/tmp/codex-dream-skin-final-compare-03-cyber.png`, `/private/tmp/codex-dream-skin-final-compare-04-obsidian.png`
- Viewport and state: 1609 × 888, macOS Codex 26.707.91948, light shell, New Task home, identical native sidebar/project/composer state
- Full-view comparison evidence: all three source/implementation pairs were opened together in one local-image comparison input; the full cyber home capture confirms the surrounding theme layout remains unchanged.
- Focused comparison evidence: the card lane, account-row update button, and project/composer seam were each compared at source resolution.
- Interaction evidence: all four native card labels return visible hit points, the update control remains the native enabled button, project and composer bounds both measure `x=366.5`, `width=998`, and injected chrome remains non-interactive.

## Findings fixed

- [P1] The four non-rose themes used a short 252px hero and left a large unstructured gap between the hero and composer. They now share the rose layout's 400px hero, brand scale, lower glass lane, and bottom-right artwork-card rhythm.
- [P1] Non-rose project selectors retained a dark or detached surface in the light shell. Each now uses its active theme's light surface, border, accent, and shadow tokens.
- [P2] Hero supporting copy had insufficient contrast against mecha, cyber, and obsidian artwork. It now uses a theme-tinted light foreground.
- [P2] The project-selector surface began 67px to the right of the composer on wide screens. It now aligns with the composer edge; compact screens compensate for their native 13px inset and 26px width difference.
- [P1] Suggestion labels were pushed below the hero clipping line, leaving four blank cards with icons only. Native labels now sit directly below each icon and the live verifier checks their visible hit points.
- [P2] The account-row update button retained Codex's fixed charts-blue surface. Its resting, icon, border, shadow, and hover colors now follow the active theme variables.
- [P2] The project surface ended 16px before the composer even though their left edges matched. Both desktop bounds now measure 998px, and compact widths share the same full-width rule.
- [P2] The decorative composer `◉` marker called out by the user was visually noisy. It is now removed for every theme and occupies no layout space.
- [P2] A native 58px rate-limit banner could push the composer below the viewport. The home rhythm now reserves that height only while the banner is present.

## Final fidelity check

- Fonts and typography: rose keeps its editorial serif; mecha uses a condensed industrial face, green uses a softer serif, cyber uses a spaced display face, and obsidian uses a restrained grotesk. Hero text and all four native card labels are readable.
- Spacing and layout rhythm: the five themes share the same brand, 400px hero, selector, composer, and artwork-card hierarchy; the selector and composer left and right edges match at desktop and compact widths.
- Colors and visual tokens: sidebars, surfaces, borders, buttons, status pills, text, wallpaper treatments, and the native update badge all follow the active theme rather than inheriting rose or fixed blue.
- Image quality and asset fidelity: every theme uses its real bundled 16:9 artwork for the hero, ambient background, brand crop, and bottom-right card; no placeholders or synthetic UI assets are used.
- Copy and content: native Codex suggestion prompts, projects, branch, approval mode, model selector, and editable composer remain real; only presentation changes.
- Responsiveness and accessibility: the bottom-right card hides before 1120px, selector alignment adapts at the same breakpoint, reduced-motion behavior is preserved, and the decorative chrome cannot intercept pointer events.

## Result

- No actionable P0, P1, or P2 visual findings remain in the accepted side-by-side comparisons.
- Automated regression coverage includes theme hot-switch attributes, theme-linked palettes/cards/update badge, visible suggestion copy, exact project/composer bounds, hidden ornament, compact alignment, and banner-aware vertical rhythm.

final result: passed

---

# Design QA — Non-rose bottom-right theme cards (1.5.2)

- Reported mismatch: rose displayed a bottom-right artwork card, while mecha, green, cyber, and obsidian did not
- Deterministic pre-fix evidence: `macos/tests/theme-card-style-harness.mjs` failed with `non-rose home themes still hide the bottom-right card`
- Post-fix evidence: the same harness passes renderer markup, desktop visibility, theme ID exposure, four theme-specific selectors, a reserved 190px lane, and compact-width hiding
- Card directions: angular industrial badge for mecha, soft botanical card for green, cyan/magenta neon card for cyber, and cold minimal plate for obsidian
- Responsive behavior: cards display only on home screens wider than 1120px and remain inside the non-interactive injected chrome
- Full automated evidence: `macos/tests/run-tests.sh` passes syntax, payload, custom theme, rotation, CLI, config recovery, signature, and doctor checks
- Live screenshot: unavailable because Codex and the verified loopback CDP session are currently stopped

1.5.2 result: blocked pending live screenshot

## Prior palette report (1.5.1)

# Theme-linked interface palettes

- Reported mismatch: switching away from the rose theme replaced the artwork but left the light-shell UI pink
- Deterministic renderer evidence: `macos/tests/theme-style-harness.mjs` reproduced `#f6f2f3` for all four non-rose themes before the fix
- Post-fix renderer evidence: rose, mecha, green, cyber, and obsidian each resolve distinct light background, panel, text, muted, border, and accent values
- Hot-switch evidence: the harness applies rose first, then each target theme in the same renderer context and verifies the preset attribute, runtime theme ID, stylesheet text, and root variables all refresh
- Full automated evidence: `macos/tests/run-tests.sh` passes syntax, all theme payloads, custom-theme generation, rotation, CLI switching, config recovery, signature validation, and doctor checks
- Live screenshot: unavailable because the current state reports no running Codex or verified loopback CDP session

## 1.5.1 result

- No automated palette-linkage failures remain.
- Live visual signoff is still blocked until Codex is running under the verified local CDP session.

1.5.1 result: blocked

## Prior five-theme report (1.5.0)

# Five-theme rotation and terminal switching

- Source visual truth: the five bundled `macos/themes/*/background.png` assets and their matching `theme.json` palettes
- Generated artwork inspected: mecha forge, eye-care green, cyber grid, and obsidian zero; the existing rose editorial image remains the pink theme
- Asset viewport: all four new generated backgrounds are 1672 × 941, 16:9, with a deliberately quiet left third and primary visual interest near center-right
- Live implementation screenshot: unavailable; no verified live Codex CDP renderer was running during this release check
- Automated evidence: `macos/tests/run-tests.sh` passes theme payloads, ordered rotation, CLI installation and switching, signature validation, and doctor checks

## 1.5.0 finding

- [P2] Live cross-theme layout remains visually unconfirmed.
  - Evidence: all five theme configurations pass payload construction and local asset checks, and the four generated images were individually inspected for crop safety, readability, fake UI, text, and watermark issues. A real renderer capture for each theme could not be produced without restarting Codex into a verified loopback-CDP session.
  - Impact: theme assets and switching behavior are regression-tested, but final in-app banner/composer spacing across all five palettes cannot be certified from live screenshots in this run.
  - Follow-up: capture the five home states and one representative task state from a verified live CDP session before release signoff.

## 1.5.0 checklist

- [x] Inspect every generated background at source resolution
- [x] Confirm wide composition, quiet content lane, and absence of raster UI/text
- [x] Validate five theme payloads and ordered rotation
- [x] Verify menu and terminal switching remain hot-only by default
- [ ] Capture all five themes in the live native Codex renderer

1.5.0 result: blocked

## Prior hotfix report (1.4.2)

# Rose project/composer spacing hotfix

- Source visual truth: `/var/folders/9k/nc7074ws7_d_zywslx42tpxc0000gn/T/codex-clipboard-13f185df-7857-4894-87d8-6da813b8215d.png`
- Implementation screenshot: unavailable; no verified live Codex CDP renderer was running, and the in-app Browser blocked the local focused-preview URL
- Source viewport: 943 × 187 crop
- State: macOS Codex, `rose` preset, New Task home, project selector directly above the composer
- Full-view comparison evidence: the supplied source crop was opened and inspected; a matching post-fix live capture could not be produced without restarting Codex into a verified loopback-CDP session
- Focused comparison evidence: blocked for the same reason; the affected crop is already the focused project-selector/composer region

## Current finding

- [P2] Post-fix live spacing remains visually unconfirmed.
  - Location: rose home project selector and `.composer-surface-chrome`.
  - Evidence: the source shows the composer starting at the same vertical edge as the project-button row, clipping the lower part of that row. The implementation removes the rose composer's `-14px` vertical translation while preserving its `-54px` horizontal alignment, but a rendered implementation screenshot is unavailable.
  - Impact: static and regression verification pass, but the final pixel gap and bottom viewport clearance cannot be certified from live evidence in this run.
  - Fix applied: changed `transform: translate(-54px, -14px)` to `transform: translate(-54px, 0)` and added a regression assertion to the macOS test suite.

## Current fidelity check

- Fonts and typography: unchanged by this hotfix; live post-fix rendering not recaptured.
- Spacing and layout rhythm: the known `14px` upward collision was removed; final live spacing is pending capture.
- Colors and visual tokens: unchanged.
- Image quality and asset fidelity: unchanged; no assets were added or replaced.
- Copy and content: unchanged; native project and composer content remain intact.

## Current implementation checklist

- [x] Remove the negative desktop composer Y offset
- [x] Preserve the existing horizontal alignment
- [x] Add a layout regression assertion
- [x] Bump the patch version and update the user-facing changelog
- [x] Run the full macOS regression suite
- [ ] Capture the rose home screen from a verified live CDP session

## Prior full-build report (1.4.1)

# Design QA — Rose editorial preset

- Source visual truth: `/var/folders/9k/nc7074ws7_d_zywslx42tpxc0000gn/T/codex-clipboard-3ce53fd2-d176-47cb-9ec9-6fec267ca6c9.png`
- Implementation screenshot: `/private/tmp/rose-final-stable.png`
- Source viewport: 1400 × 890
- Implementation viewport: 1499 × 765
- State: macOS Codex 26.707.91948, light shell, New Task home, four native suggestion cards visible
- Full-view comparison evidence: the reference and final live screenshot were loaded together in the in-app Browser through `/private/tmp/design-compare.html`.
- Focused comparison evidence: the same comparison page includes a second side-by-side crop of the brand, hero, four native cards, project selector, composer lane, and polaroid.
- Comparison page console errors: 0.
- Responsive evidence: `/private/tmp/rose-responsive-900.png` at 900 × 700; three native cards remain visible, the polaroid hides, composer remains usable, and horizontal/vertical overflow are both false.
- Interaction evidence: live verifier reports `composerEditable: true`, `composerPointerEvents: auto`, `cardInteractionPass: true`, `chromePointerEvents: none`, and `pass: true`.

## Comparison history

### Iteration 1 — blocked

**Findings**

- [P1] Hero copy is covered by the suggestion cards.
  - Location: rose home hero and four-card overlay.
  - Evidence: the reference leaves the headline and supporting line unobstructed; iteration 1 begins cards at y=345 and clips the supporting line.
  - Impact: the main message loses hierarchy and readability.
  - Fix: increase hero/first-section height and move cards down while keeping them overlapped with the hero.

- [P1] Project selector retains the old dark portal surface.
  - Location: project selector immediately above the composer.
  - Evidence: reference uses a pale pink/white surface; iteration 1 displays a nearly black horizontal bar.
  - Impact: the single dark region breaks the visual system and looks like a failed theme override.
  - Fix: add rose-specific selector and button surface overrides.

- [P2] Composer and polaroid overlap.
  - Location: lower-right home area.
  - Evidence: iteration 1 composer extends beneath the polaroid; reference reserves a clear right-side lane for the polaroid.
  - Impact: decorative imagery competes with native input controls.
  - Fix: reduce composer width, retain the left offset, and slightly enlarge the polaroid in the reserved lane.

- [P2] Brand crop shows a portrait instead of the reference rose mark.
  - Location: rose preset brand lockup.
  - Evidence: reference uses a rose image; iteration 1 shows a small face crop.
  - Impact: the lockup reads like an avatar rather than a themed brand mark.
  - Fix: crop the supplied real hero asset to its far-right rose region inside an overflow-hidden frame.

**Required fidelity surfaces**

- Fonts and typography: hierarchy is directionally correct; hero supporting text needs separation from cards.
- Spacing and layout rhythm: major regions align, but hero/card/composer vertical rhythm needs correction.
- Colors and visual tokens: rose palette matches except for the dark project selector.
- Image quality and asset fidelity: supplied hero is sharp and correctly cropped; brand crop needs adjustment.
- Copy and content: native card copy matches the reference intent; real sidebar/project content is intentionally preserved.
- Icons and interaction: native Codex icons and buttons are preserved; interaction testing remains pending.
- Responsiveness and accessibility: no horizontal overflow; responsive and focus checks remain pending.

iteration result: blocked

### Iteration 2 — blocked

**Earlier findings fixed**

- Increased hero and first-section height and moved cards down; headline and supporting copy are no longer covered.
- Replaced the dark project selector with the rose glass surface and light native project buttons.
- Reserved a right-side polaroid lane by reducing composer width.
- Added a real-image crop frame for the brand mark.

**Post-fix evidence**

- Screenshot: `/private/tmp/rose-iteration-2.png`.
- Hero copy and all four cards are readable; project selector matches the rose palette.

**Remaining findings**

- [P2] Composer height extended below the shorter 765px viewport.
  - Fix: restored the native 98px composer height and shifted the full composer lane upward.
- [P2] Existing live chrome reused the earlier same-version brand markup.
  - Fix: removed and rebuilt the injected chrome once, then verified the crop frame's computed 38 × 38 bounds and `overflow: hidden`.

### Final iteration — passed

**Fixes made**

- Shifted the composer upward 14px; final bounds are x=312, y=657, width=998, height=98 within a 1499 × 765 viewport.
- Tightened the brand crop to the far-right rose region of the supplied hero image.
- Added a compositor warm-up capture so acceptance screenshots no longer save transient black GPU tiles.
- Added live interaction checks for card hit targets and the native editable composer.

**Post-fix visual evidence**

- Final screenshot: `/private/tmp/rose-final-stable.png`.
- Side-by-side full and focused comparison: `/private/tmp/design-compare.html`, inspected in the in-app Browser.
- Responsive screenshot: `/private/tmp/rose-responsive-900.png`.

**Findings**

- No actionable P0, P1, or P2 findings remain.

**Required fidelity surfaces**

- Fonts and typography: pink editorial hierarchy, serif hero title, compact brand lockup, native card labels, and Chinese fallbacks are coherent and readable.
- Spacing and layout rhythm: header, hero, card overlay, project selector, composer, and polaroid form the same hierarchy as the source without viewport overflow.
- Colors and visual tokens: pale rose background, warm white cards, pink icon medallions, borders, and shadows consistently match the source direction.
- Image quality and asset fidelity: a real 1915 × 821 bundled hero is used for hero, wallpaper, brand rose crop, and polaroid crop; no placeholder or CSS-drawn image substitute is used.
- Copy and content: hero brand/tagline match the selected direction; native Codex card copy, projects, tasks, and account data remain real.
- Icons and interaction: native Codex SVG icons and click targets remain enabled; decorative chrome is non-interactive and cannot block controls.
- Responsiveness and accessibility: 1499 × 765 and 900 × 700 pass without document overflow; reduced motion disables card transitions; composer stays editable and cards retain hit targets.

**Acceptable P3 differences**

- The reference's Windows menu frame and sample sidebar data are intentionally not cloned on macOS.
- The reference's handwritten name graphic is not present in the available pure hero asset.
- Card glyph shapes remain Codex's real product icons rather than decorative replacements.

**Implementation Checklist**

- [x] Live rose preset and bundled image asset
- [x] Native sidebar and card interactions preserved
- [x] Stable screenshot capture
- [x] Desktop and compact responsive verification
- [x] Full regression suite and signed-runtime doctor

**Follow-up Polish**

- A future licensed pure hero carrying the exact handwritten mark could close the remaining P3 image-content difference without changing layout code.

prior full-build result: passed

## Current result

prior 1.4.2 result: blocked
