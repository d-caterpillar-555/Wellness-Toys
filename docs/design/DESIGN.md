# Design System

Source of truth for colour, type, space, motion, and the banned-pattern list.
Mirrored into `app/assets/tailwind/application.css` as Tailwind `@theme` tokens.

**Rule:** a value that is not in this document does not go in the CSS. Adding a step to a
scale is a design decision, not a convenience.

---

## 0. The design read

> Reading this as: a direct-to-consumer sexual health storefront with an education
> platform attached, for adults who are tired of being marketed to like teenagers, with a
> clinical-editorial language, leaning toward an apothecary-journal system.

**Mode:** `Persuade` for the home, category, PDP and `/learn` surfaces. `Operate` for cart,
checkout, account, and admin, where predictability beats expression.

The tension that makes this work: **a plain brand name against a serious typographic
treatment.** Playful name plus playful design reads as a novelty shop. Plain name plus
serious design reads as a health institution. Only the second one breaks the taboo.

---

## 1. Colour

**OKLCH only.** Hex appears below for reference and for contexts that cannot express OKLCH.
If the two disagree, OKLCH wins.

### Ink and paper

| Token | OKLCH | Hex | Use |
|---|---|---|---|
| `--color-paper` | `oklch(96.2% 0.005 95)` | `#F5F4F0` | Page background |
| `--color-paper-sunk` | `oklch(93.1% 0.007 96)` | `#ECEAE4` | Inset surfaces, table stripes |
| `--color-line` | `oklch(87.4% 0.010 95)` | `#DAD7CE` | Hairlines. **First choice over shadow.** |
| `--color-ink` | `oklch(19.8% 0.011 258)` | `#12151A` | Headings |
| `--color-ink-soft` | `oklch(30.4% 0.014 258)` | `#2A2F38` | Strong secondary text |
| `--color-body` | `oklch(38.9% 0.017 254)` | `#3F4650` | Body copy |
| `--color-muted` | `oklch(50.5% 0.024 259)` | `#616877` | Captions, metadata, placeholder |
| `--color-disabled` | `oklch(72.0% 0.010 258)` | `#A8ACB4` | Disabled label text |

**Never grey.** Secondary text on a tinted surface is tinted from that surface's hue, not
desaturated toward neutral. `--color-muted` above is a cool slate chosen to sit on bone
paper, not a grey.

### Accent

One accent, page-wide. There is no second accent.

| Token | OKLCH | Hex | Use |
|---|---|---|---|
| `--color-accent` | `oklch(52.4% 0.086 170)` | `#1D7A66` | Links, active state, focus ring, accent text on paper |
| `--color-accent-strong` | `oklch(40.6% 0.063 172)` | `#145345` | Button fills, pressed states |
| `--color-accent-hover` | `oklch(52.4% 0.086 170)` | `#1D7A66` | Filled-button hover |
| `--color-accent-wash` | `oklch(94.1% 0.017 172)` | `#E8F1EE` | Selected rows, subtle emphasis blocks |

### Signal

| Token | OKLCH | Hex | Use |
|---|---|---|---|
| `--color-ember` | `oklch(50.8% 0.140 42)` | `#B4491F` | Errors, and a genuine price reduction. Nothing else. |

Ember is used sparingly and never decoratively. A sale badge that is not a real reduction is
a banned pattern (see §9).

### Dark mode

Same tokens, inverted surfaces. One theme per page - **never a mid-page invert.**

| Token | Dark value |
|---|---|
| `--color-paper` | `oklch(17.5% 0.010 258)` |
| `--color-paper-sunk` | `oklch(21.0% 0.012 258)` |
| `--color-line` | `oklch(29.0% 0.014 258)` |
| `--color-ink` | `oklch(95.0% 0.006 95)` |
| `--color-body` | `oklch(84.0% 0.008 95)` |
| `--color-muted` | `oklch(68.0% 0.012 258)` |
| `--color-accent` | `oklch(70.0% 0.098 168)` |
| `--color-accent-strong` | `oklch(62.0% 0.100 169)` |

Light-on-dark copy gets one extra weight step and slightly more leading. Compensate; do not
copy the light-mode numbers across.

### Verified contrast

Computed against these exact values. Re-verify if a token changes.

| Pair | Ratio | Req. | Verdict |
|---|---|---|---|
| `--color-body` on `--color-paper` | 9.00:1 | 4.5 | Pass |
| `--color-muted` on `--color-paper` | 5.08:1 | 4.5 | Pass |
| `--color-ink` on `--color-paper` | 15.2:1 | 4.5 | Pass |
| `--color-accent` on `--color-paper` | 4.74:1 | 4.5 | Pass |
| `#FCFDFC` on `--color-accent-strong` | 8.81:1 | 4.5 | Pass |
| `--color-ember` on `--color-paper` | 4.71:1 | 4.5 | Pass |
| `--color-line` on `--color-paper` | 1.28:1 | 3.0 large | Border only, never text |

---

## 2. Typography

### Families

| Role | Family | Licence |
|---|---|---|
| Display, editorial headings, pull quotes, the wordmark | **Newsreader** | OFL |
| UI, body copy, tables, forms, buttons | **Instrument Sans** | OFL |

Both **self-hosted** from `app/assets/fonts/`. No hosted font CDN - it leaks visitor IP and
referrer, which is unacceptable on health-adjacent pages.

Only the weights actually used are loaded. Subset to Latin and Latin-Extended.

**Not Inter.** Inter as an unconsidered default is one of the named AI-tell patterns in the
design skill, and it has no editorial character.

### Ramp

Fixed and enumerated. Adding a step is a design decision.

| Step | Size | Typical role |
|---|---|---|
| `12` | 0.75rem | Legal fine print only |
| `13` | 0.8125rem | Table metadata, badges |
| `14` | 0.875rem | Labels, captions, helper text |
| `15` | 0.9375rem | Dense UI, table cells |
| `16` | 1rem | **Body floor.** Never smaller. |
| `18` | 1.125rem | Large body, article intro |
| `20` | 1.25rem | Card titles, h4 |
| `24` | 1.5rem | h3 |
| `28` | 1.75rem | h2 in dense contexts |
| `32` | 2rem | h2 |
| `40` | 2.5rem | h2 on marketing surfaces |
| `48` | 3rem | h1, section display |
| `56` | 3.5rem | Display |
| `72` | 4.5rem | Display, large viewports |
| `88` | 5.5rem | **Ceiling.** Display max, large viewports only |

Display sizes may use `clamp()` between two adjacent steps. Nothing exceeds `88`.

### Roles

| Role | Family | Size | Weight | Leading | Tracking |
|---|---|---|---|---|---|
| Wordmark | Newsreader | 20 | 500 | 1.1 | `-0.01em` |
| Display | Newsreader | 48-88 | 400 | 1.05 | `-0.04em` |
| Headline | Newsreader | 32-48 | 400 | 1.15 | `-0.02em` |
| Title | Newsreader | 20-28 | 500 | 1.25 | `-0.01em` |
| Body | Instrument Sans | 16-18 | 400 | 1.8 | `0` |
| UI | Instrument Sans | 14-16 | 450-500 | 1.45 | `0` |
| Label | Instrument Sans | 14 | 500 | 1.3 | `0.01em` |
| Caption | Instrument Sans | 13-14 | 400 | 1.5 | `0.005em` |

### Rules

- **Measure: 65-75ch for prose.** Target 68ch. Line-height scales inversely with measure.
- **`text-wrap: balance`** on all headings. `text-wrap: pretty` on prose.
- **Tabular numerals** on every price, dimension, quantity, date, and stock figure.
- Tracking floor is `-0.04em`. Tighter than that is a mistake, not a style.
- A second family must earn its place. Newsreader plus Instrument Sans is the whole
  system; there is no third.
- **The wordmark is set in Newsreader, both words at equal weight and equal case.** The
  cliché move - italicising or accent-colouring the "respectable" half of the name - is
  banned, because it concedes the point the brand exists to make.

---

## 3. Space

```
4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 · 80 · 112
```

- A 4-unit base, not 8-only. Optical correction needs the small steps.
- **Tight groups, generous separation.** Space above a heading always exceeds space below it.
- Proximity before containers. Reach for spacing before reaching for a border or a box.
- Use `gap` for sibling rhythm. Do not stack margins.
- Section rhythm on marketing surfaces: `64` mobile, `112` desktop.

---

## 4. Radius

```
2 · 4 · 6 · 8 · 10 · 12 · 16 · pill
```

- Inputs, buttons, badges: `6` to `8`
- Cards and panels: **`12` to `16`**. Nothing larger.
- `pill` is for small controls only - filter chips, quantity steppers, status badges.
- One radius system, page-wide. No mixing.
- **Large containers never use `rounded-full`.**

---

## 5. Elevation

**Hairline first. Shadow second.**

- Default card: a 1px `--color-line` border and **no shadow**.
- Shadow is reserved for genuinely floating surfaces: dropdowns, popovers, dialogs, sticky
  headers once scrolled.
- A shadow needs both an offset and a soft blur. A zero-offset coloured halo is decoration,
  and is banned.
- **Ghost cards are banned**: a 1px border under a wide soft shadow is doing both jobs badly.

```
--shadow-popover: 0 8px 24px -8px oklch(19.8% 0.011 258 / 0.16);
--shadow-dialog:  0 24px 64px -16px oklch(19.8% 0.011 258 / 0.24);
```

---

## 6. Motion

- **Animate `transform` and `opacity` only.** Nothing else is compositor-friendly.
- **One authored moment, sitewide.** A single IntersectionObserver-driven reveal that
  fades and lifts once, then never repeats. Not a different entrance per section.
- Easing is exponential ease-out, `cubic-bezier(0.16, 1, 0.3, 1)`. Duration 400-600ms for
  reveals, 150-200ms for state changes.
- **`prefers-reduced-motion: reduce` removes all of it.** Content is visible by default and
  animation is additive, so a reduced-motion visitor sees the finished state immediately.
- **No `window.addEventListener('scroll')`.** IntersectionObserver, or scroll-driven CSS.
- Every animation must be justifiable in one sentence. If the sentence is "it looks nice",
  delete it.
- No parallax. No marquee (one would be the maximum, and this site does not need one).

**The authored moment, stated:** *content resolves into place as you reach it, which gives a
long editorial page a sense of reading rather than scrolling.*

---

## 7. Components

Each is a token-referencing recipe. Reach for the primitive before inventing a class.

| Component | Recipe |
|---|---|
| **Button, primary** | `bg-accent-strong text-[#FCFDFC] rounded-md px-5 py-3 font-medium` · hover `bg-accent-hover` · active `scale-[0.98]` · focus ring `accent` 2px offset 2px · disabled `opacity-50 cursor-not-allowed` |
| **Button, secondary** | `bg-transparent text-ink border border-line rounded-md` · hover `border-ink bg-paper-sunk` |
| **Button, quiet** | `bg-transparent text-body underline underline-offset-4 decoration-line` · hover `decoration-accent text-ink` |
| **Input** | `bg-paper border border-line rounded-md px-4 py-3 text-body` · placeholder `text-muted` · focus `ring-2 ring-accent border-accent` · error `border-ember` plus message below |
| **Card** | `bg-paper border border-line rounded-xl` · no shadow · padding `24` or `32` |
| **Panel (sunk)** | `bg-paper-sunk border border-line rounded-xl` |
| **Badge** | `text-[13px] rounded-full px-3 py-1 border` · variants: default, `accent-wash`, `ember` |
| **Table, spec** | Hairline rows, `text-[15px]`, tabular numerals, label column `text-muted`, generous row height. **Not** a bordered grid. |
| **Nav link** | `text-body` · hover `text-ink` · current `text-ink` plus a 1px accent underline at `offset-4` |
| **Evidence rail** | Right column, `border-l border-line pl-8`, source entries at `text-[14px] text-muted` with the publisher in `text-ink`. Sticky below the header. |
| **Skeleton** | `bg-paper-sunk animate-pulse rounded-md`, **shaped like the content it replaces.** Never a spinner in a content slot. |
| **Empty state** | A composed sentence plus one action. Never a shrug, never an illustration of a sad face. |

### Labels and errors

- Label **above** the input. Error **below** the input. `gap-2` between control and message.
- **Never placeholder-as-label.** The placeholder is an example, never the only label.
- Errors name the problem and the recovery: "That postcode is not five digits. Check and
  try again." Not "Invalid input."

---

## 8. Browser surfaces

Themed from the palette, in both modes. This is the cheapest signal that a page was built
rather than assembled.

| Surface | Treatment |
|---|---|
| `::selection` | `bg-accent-wash`, `color-ink` |
| `caret-color` | `--color-accent` |
| Focus ring | 2px `--color-accent`, 2px offset, `:focus-visible` only |
| `text-decoration-thickness` | `1px`, `text-underline-offset: 4px` |
| `font-variant-numeric` | `tabular-nums` on all data |
| Scrollbar | Thin, `--color-line` thumb on `--color-paper` track |
| `scrollbar-gutter` | `stable`, so opening a dialog never shifts the page |
| `accent-color` | `--color-accent`, for native checkboxes and radios |

---

## 9. Banned patterns

Checked before ship. These are refusals, not preferences.

### Copy

- **Em-dashes (`—`) and en-dashes as separators (`–`).** Use a hyphen. Zero exceptions.
- Eyebrows above sections. Maximum one per three sections, counted mechanically.
- `01 / 02 / 03` section numbering. `1 of 4` counters. Decorative numbering of any kind.
- "Elevate", "Seamless", "Unleash", "Next-Gen", "Discover", "Curated" as filler.
- Placeholder names in examples: "Acme", "John Doe", "Jane Smith", "NovaCore".
- Fabricated precision: "99.99% of users", "10x better".
- Testimonials or statistics that are not real. **This one is a factual-integrity rule, not
  an aesthetic one.**

### Layout

- Three equal feature cards in a row.
- Icon plus heading plus paragraph, repeated as a grid.
- The hero-metric template: big number, small label, row of stats.
- **Nested cards.** A card inside a card.
- **Ghost cards.** A 1px border under a wide soft shadow.
- Split headers: a big headline with a small explainer pushed to the right.
- A layout family appearing more than once per page. Eight sections need at least four
  distinct families.
- More than two consecutive image-plus-text zigzags.
- Bento grids with empty cells, or with cells that are all the same shape.

### Surface

- Gradient text.
- Decorative glass or backdrop blur.
- Neon glow. Coloured halos.
- Hard offset shadows.
- `repeating-linear-gradient` stripes, or grid backgrounds with no real canvas under them.
- Pure `#000` or `#fff` as a surface.
- Textures on anything that is not a fixed, `pointer-events-none` layer.
- Mono type used as a "technical" costume. There is no monospace role in this system.

### Behaviour

- `window.alert`, `window.confirm`, `window.prompt`.
- `window.addEventListener('scroll')`.
- `h-screen`. Use `min-h-[100dvh]`.
- Spinners in content slots where a shaped skeleton belongs.
- Modals as a reflex. Reach for inline disclosure first.
- More than one `prefers-reduced-motion` escape hatch - there is one, globally.
- Emoji used as icons.
- Hand-rolled decorative SVG. Use the vendored Phosphor subset.

### Data display

- A hairline under every row of a long list. Group into chunks with a single divider, use
  a two-column spec grid, or disclose featured versus remainder.
- A default `<ul>` for more than five items.

---

## 10. Accessibility floor

- WCAG 2.1 AA minimum. Contrast verified, not assumed (§1).
- Full keyboard operation. Visible focus on every interactive element.
- **Touch targets at least 44 by 44px.** The visible mark may be smaller; the target may not.
- Semantic HTML: `nav`, `main`, `article`, `aside`, `section`, `figure`, `button`.
- One `h1` per page. No skipped heading levels.
- Meaningful images get alt text. Decorative images get `alt=""` and `aria-hidden`.
- A skip link, visible on focus, before the header.
- Forms: label above, error below, `aria-describedby` wiring the message to its input.
- `prefers-reduced-motion` honoured globally.
- No horizontal scroll at 375px.
- Zoom to 200% without loss of content or function.
