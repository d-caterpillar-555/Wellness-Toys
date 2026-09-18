# The eight architectures

> **This document supersedes `design/DESIGN.md` for everything it covers.** The instruction
> on 2026-09-19 was to delete the four `data-style` worlds and build **eight different
> *kinds of websites*** - not eight colourways. Each world disagrees about what a page is,
> how many pages there are, how you navigate, and how the page moves. The divergence from
> `DESIGN.md` is deliberate and is recorded here rather than edited into the design system,
> which continues to govern the baseline chrome (cart, checkout, account, admin) and the
> institute world.

## The shared frame

- **One store, eight architectures.** Every world renders the same records: `Product`,
  `Category`, `Brand`, `Article`, `Topic`, `Author`, `Page`. No world invents facts, prices,
  materials or citations. The content rules in `AGENTS.md` still apply everywhere.
- **The store keeps working.** `cart_items_path` (add to cart), `shop_path`, `learn_path`,
  the age gate, the consent banner and the transactional pages are shared. Cart, checkout,
  order, account and admin keep the baseline design in every world: the checkout is its own
  sober system.
- **A world owns**: its route prefix, its layout, its CSS file, its JS module, its templates.
  A world never edits another world's files.
- **The dock** (`shared/_world_dock`) is on every page. It is the only piece of chrome
  common to all eight, and it must stay out of the way: a fixed, small pill, keyboard
  reachable, no more than one line.
- **Files per world**
  - `app/views/layouts/worlds/<slug>.html.erb` - the layout
  - `app/views/worlds/<slug>/*` - templates
  - `app/assets/stylesheets/worlds/<slug>.css` - served by Propshaft, no build step
  - `app/javascript/worlds/<slug>.js` - pinned in `config/importmap.rb`
  - `app/controllers/worlds/<slug>_controller.rb`
- **Every world declares its palette** at the top of its CSS as `--w-*` tokens in OKLCH, so
  `script/check-contrast` can verify text pairs. Floors: 4.5:1 for body text, 3:1 for large
  display type and UI marks.
- **Accessibility floor is not a style choice.** Semantic landmarks, one `h1`, visible focus,
  44px touch targets, no horizontal scroll at 375px, and `prefers-reduced-motion` honoured.
  A world may look like anything; it may not be unusable.
- **No world may break the suite.** `spec/system/buying_spec.rb` and `reading_spec.rb` run
  against the canonical routes, which are the institute world's routes.

## 1. institute - the default, canonical routes (`/`)

**Premise.** A health institution that publishes. The site is an annual report: every page
is a numbered section, every section has a contents rail and a running head.

**Architecture.** Multi-page, one page per section, real URLs for everything. `/` front page
(statement, departments, catalogue head, library head), `/shop`, `/shop/:category`,
`/shop/:category/:slug`, `/learn`, `/learn/:topic`, `/learn/:topic/:slug`, `/blog`, `/about`
and the other static pages. Breadcrumbs on every page, sitemap in the footer.

**Navigation.** Persistent top bar plus a section rail on each page (the page's own
contents), breadcrumb trail. Cross-references between sections are written as numbered
clauses ("see 4.2").

**Look.** The existing tokens (bone paper, ink, one jade accent, Newsreader + Instrument
Sans) pushed to a print-like density: hairline rules, clause numbering, running heads,
marginal notes. Deliberately restrained.

**Motion.** The single authored reveal, nothing else.

**Signature.** The clause number. Every heading on the site carries its section number
(`3.1 Materials and safety`), and the rail tracks where you are.

**Must not.** Invent an editorial voice; the copy stays the shop's own plain voice.

## 2. folio - everything on one page (`/folio`)

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
the foot of the document.

**Motion.** Almost none: the index marker slides, disclosures open.

**Signature.** The living index: it knows where you are and marks it, and every entry is a
real anchor.

**Must not.** Become a long scroll of interchangeable cards. Each section has its own
composition.

## 3. figure - the scroll choreography (`/figure`)

**Premise.** The shop as a figure study. A drawn figure moves through a sequence of poses as
you scroll; the copy and the catalogue arrive with each pose.

**Architecture.** Three pages: `/figure` (the choreography), `/figure/pieces` (the catalogue,
poses on hover), `/figure/pieces/:slug` (a piece, with a still pose).

**Navigation.** Scroll is the navigation on the home page; poses are chapters and are also
listed as links.

**Look.** Dusk: a deep gradient ground, the figure drawn in chalk line and ink fill with a
warm rim light, type in a high-contrast display serif and a grotesk. The figure is stylised,
abstract, fully drawn - a figure study, never photographic, never sexualised.

**Motion.** The figure's pose interpolates with scroll progress between key poses (stand,
reach, fold, rest, open), drawn as SVG with joint interpolation. Reduced motion shows one
composed pose and no interpolation.

**Signature.** The figure. It is the only world with a scroll-driven drawing, and the pose
sequence is the page's structure.

**Must not.** Use scroll listeners that jank (drive it from `IntersectionObserver` +
`requestAnimationFrame`, or scroll-driven CSS animation where supported); must not imply a
real person.

## 4. plan - the shop as a building (`/plan`)

**Premise.** The store as a floor plan. Departments are rooms; products sit on the plan with
callout lines.

**Architecture.** Spatial. `/plan` (the plan), `/plan/room/:slug` (a department, the view
zoomed into that room), `/plan/object/:slug` (one object, drawn as an elevation with
dimensions), `/plan/register` (the same data as a plain ruled index, for anyone who does not
want to walk).

**Navigation.** Click a room to walk into it; a minimap in the corner always shows where you
are; the register is the escape hatch.

**Look.** A daylight architectural model: plan-white, thin ink lines, soft shadows, one
terracotta for the current room. Dimensions and north arrow drawn as real annotations.

**Motion.** Camera-like transitions between plan and room; nothing else moves.

**Signature.** The plan itself is the navigation, and the URL is a place.

**Must not.** Hide the catalogue behind the metaphor: the register must always reach every
product in one click.

## 5. shell - the shop as a command line (`/shell`)

**Premise.** The store as a machine you talk to: a prompt, a filesystem, and output.

**Architecture.** One surface. Commands navigate a virtual tree (`/catalogue`, `/library`,
`/about`, each department, each product). `cat <object>` prints the record, `find <term>`
searches, `add <object>` puts it in the cart, `open cart` leaves for the real cart.

**Navigation.** Keyboard first: a real prompt with history (up/down), tab completion, and
`help`. Every command is also a clickable suggestion, so the mouse works.

**Look.** A dark terminal that is not a costume: deep green-black (never pure black),
phosphor ink, amber for warnings, one rule line. Mono type throughout - this world's
deliberate divergence.

**Motion.** Typing, a blinking caret, output that appears in place. Reduced motion: output
simply present.

**Signature.** You can drive the entire shop by typing, and the filesystem is real: every
path resolves.

**Must not.** Let the metaphor break the store: `add` must really add to the cart, and any
unknown command must say so honestly.

## 6. press - the shop as a newspaper (`/press`)

**Premise.** A paper that reviews what it sells. Masthead, editions, columns, notices.

**Architecture.** Front page with a column grid; `/press/catalogue` (the reviewed objects,
set as notices and small reviews), `/press/issue` (this edition's features, drawn from the
article library), `/press/story/:slug` (an article, reprinted), `/press/notices` (shipping,
standards, privacy as small printed notices).

**Navigation.** Masthead with sections; the front page is a real front page - headlines,
bylines, jump lines.

**Look.** Newsprint, ink, one spot red. Hairline column rules, dense headlines, a weather-
box-style data panel, and a proper folio line at the foot of each page.

**Motion.** None. Print does not animate; the discipline is the point.

**Signature.** Typographic density: a front page that is genuinely composed, not a grid of
cards with a serif.

**Must not.** Fake a news voice. Headlines stay factual and the copy stays the shop's own.

## 7. desk - the shop as a conversation (`/desk`)

**Premise.** A concierge. The page is a transcript; the assistant asks what you need and
brings things to the desk.

**Architecture.** `/desk` (the conversation, with a shelf beside it), `/desk/shelf` (the
whole shelf, quiet grid), `/desk/item/:slug` (one object, brought to the desk).

**Navigation.** Scripted dialogue with quick replies, plus free text that searches the
catalogue. Every answer is also a link, so nothing is trapped in the script.

**Look.** A warm lobby: deep green, brass, cream; soft shadows; a serif for the assistant, a
sans for you.

**Motion.** Messages rise in; a typing indicator between turns. Reduced motion: they are
simply there.

**Signature.** The dialogue is real navigation, and it never dead-ends: any concern the
script does not know falls through to search and a human-readable answer.

**Must not.** Imply a clinician or a real person is speaking; the assistant says it is a
script and links to the library.

## 8. deck - the shop as a control room (`/deck`)

**Premise.** An operations console for the shop: dense, keyboard-driven, split-pane.

**Architecture.** An application shell: sidebar, top bar, panes. `/deck` (catalogue as a
filterable table), `/deck/item/:slug` (the record as a side sheet), `/deck/library`,
`/deck/policies`.

**Navigation.** Client-side filter and sort, a comparison tray, a command palette
(`cmd/ctrl + k`), and single-key shortcuts (`/` to filter, `j`/`k` to move, `enter` to open).

**Look.** A dark workstation: slate surfaces, one electric lime accent, mono numerals for
data. Density is the aesthetic.

**Motion.** Panels slide; the table updates instantly. No decorative motion.

**Signature.** Speed: filtering, sorting and opening never leave the page.

**Must not.** Look like a generic admin template: the density must be composed, the type
must be deliberate, and it must not use the same three-column card grid as anyone else.
