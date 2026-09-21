# The folio world

> **This document governs the folio.** `design/DESIGN.md` continues to govern the store's
> own chrome - the institute architecture, the age and consent prompts, and the
> transactional pages (cart, checkout, order, account, admin). Where the two disagree about
> the folio, this file wins, and the divergence is recorded here rather than edited into the
> design system.
>
> The store was once published in eight architectures in one pass. Seven of them - figure,
> plan, shell, press, desk, deck and the gallery that listed the set - have since been
> removed, and the folio is the one that stayed. They live in the history rather than on
> disk: `v1.1` is the last commit that carried all eight.

## The shared frame

- **One store, two architectures.** The folio renders the same records as the storefront:
  `Product`, `Category`, `Brand`, `Article`, `Topic`, `Author`, `Page`. No architecture
  invents facts, prices, materials or citations. The content rules in `AGENTS.md` still
  apply everywhere.
- **The store keeps working.** `cart_items_path` (add to basket), `shop_path`, `learn_path`,
  the age gate, the consent banner and the transactional pages are shared. Cart, checkout,
  order, account and admin keep the baseline design in both architectures: the checkout is
  its own sober system.
- **The folio owns**: its route prefix, its layout, its CSS file, its JS module, its
  templates.
- **Files**
  - `app/views/layouts/worlds/folio.html.erb` - the layout
  - `app/views/worlds/folio/*` - templates
  - `app/assets/stylesheets/worlds/folio.css` - served by Propshaft, no build step
  - `app/javascript/worlds/folio.js` - pinned in `config/importmap.rb`
  - `app/controllers/worlds/folio_controller.rb`
- **The folio declares its palette** at the top of its CSS as `--w-*` tokens in OKLCH, so
  `script/check-contrast` can verify text pairs. Floors: 4.5:1 for body text, 3:1 for large
  display type and UI marks.
- **Accessibility floor is not a style choice.** Semantic landmarks, one `h1`, visible focus,
  44px touch targets, no horizontal scroll at 375px, and `prefers-reduced-motion` honoured.
  The folio may look like anything; it may not be unusable.
- **The folio may not break the suite.** `spec/system/buying_spec.rb` and `reading_spec.rb`
  run against the canonical routes, which are the store's own.

## folio - everything on one page (`/folio`)

**Premise.** The whole shop as one continuous document, read top to bottom, with an index
that never leaves the screen.

**Architecture.** One page. Every other address in this world is an anchor on it:
`#departments`, `#catalogue`, `#library`, `#standards`, `#contact`. Products are records in
the catalogue section that open in place (disclosure), not separate pages. Its only other
real page is the print view (`/folio/print`).

**Navigation.** A sticky index rail (left, desktop) that marks the current section; a
persistent progress line; `#anchor` deep links work.

**Look.** A book: warm paper, generous margins, a serif for prose, a vermilion accent used
for the index and one ornament. Drop caps on section openings, marginal notes, footnotes at
the foot of the document. Behind it, held at the right edge of the window, a rendered film
of two models is printed into the paper - a multiply blend, so it reads as an impression in
the page rather than a picture laid on top of it.

**Motion.** Almost none of the document itself: the index marker slides and disclosures
open. The film behind it is the exception - one sequence of 3,809 frames, clip_1, link_1 and
clip_2 joined frame for frame, advanced by the reader's scroll through the whole document
rather than by a passage, so the pair move as the reader reads and no line of copy is ever
asked to sit on a photograph. A cold open would show a slideshow of whatever frames arrived
first, so the sequence is fetched up front behind a loading screen
(`app/javascript/lib/sequence_loader.js`), the frames arriving in passes - every sixteenth,
then every eighth, and so on - so any position has a frame near it long before the whole
sequence has downloaded.

**Signature.** The living index: it knows where you are and marks it, and every entry is a
real anchor.

**Must not.** Become a long scroll of interchangeable cards. Each section has its own
composition. It must not imply a real person - the pair are models in a rendered study and
the page says so - and it must not show anything explicit: the frame stops at the
collarbones.
