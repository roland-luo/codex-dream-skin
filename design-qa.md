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

final result: passed
