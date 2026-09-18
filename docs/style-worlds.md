# The four worlds

This storefront has four visual worlds. They are not colourways: each one is a
different idea of what a product is, and that idea decides the structure of the
page, the typography, how a photograph is treated, and how the page moves.

Switch between them with the strip in the bottom left corner of any page, or by
URL: `?style=tidewater`, `?style=solarium`, `?style=studio`, `?style=herbarium`.
The choice is remembered, and it is resolved before the first paint so nobody
watches the site change clothes. Deep links win over the remembered choice, so a
world can be sent to someone.

Four earlier worlds (archive, darkroom, broadside, clinic, kiosk, atelier, mag)
were deleted when these four were built. A visitor holding one of those names in
their browser is validated against the current list and falls back to the
default rather than rendering a half-styled page.

---

## 1. Tidewater

**Backstory.** In 1911 the keeper's wife at a light on the Frisian coast began
keeping a log of what the light showed and what the sea gave back: time,
bearing, condition of the water, what came in with it. Her logbooks are the
founding archive of this shop. Every product is still entered the way she
entered a sighting, and the catalogue is read as a manifest rather than shopped
as a shelf.

**What it changes.** Salt-bleached chart paper with a faint ledger rule, deep
channel ink, one signal orange. The catalogue stops being a grid of cards and
becomes ruled entries: a small plate, the name, the price as data, the
department as a bearing. Log data is set in mono. Section breaks are dotted
leads, the way a chart marks depth. Photography is fogged and slightly
desaturated. Motion is a swell: reveals take 900ms on a long ease, nothing
bounces.

## 2. Solarium

**Backstory.** In 1968 an engineer who built greenhouse glass took over a
sanatorium's south wing and turned it into a room for looking at things in
daylight. Her rule became the shop's rule: nothing may be sold here that cannot
be photographed honestly at noon, without a lamp, a filter or a flattering
shadow. The catalogue is the wall of that room.

**What it changes.** Chalk white, graphite, one enamel blue. Headings are
painted signage: uppercase, 3px rules, no decoration. The catalogue is a tiled
wall, cards meeting edge to edge with a single hairline between them, square
photographs, caption plates with a ruled line. Prices are set as large tabular
data. There is no shadow anywhere and no rounding anywhere. There is also no
motion: state changes are instantaneous, the way a light switch is.

## 3. Studio B

**Backstory.** A converted bakery, 1983. Studio B pressed the country's first
spoken-word sex-education records there, and kept every master tape. The shop is
that tape library, read as a catalogue: reel number, side, running time, session
note. The records are gone. The masters are not.

**What it changes.** Tape black and silver with one hot magenta, printed out of
register. Every piece of data is monospaced: reel numbers, prices, buttons.
Each plate is a tape: a black label bar across the top carrying the SKU reversed
out in mono, the photograph below it pushed into a magenta duotone by filters
rather than blend modes, so it survives whatever colour sits behind it. Two
across, with the space of a cutting room. Buttons carry a hard offset shadow and
move like a printed sheet being registered. Motion has wow and flutter: two
pixels of slip on hover, reveals in three visible steps.

## 4. Herbarium

**Backstory.** A women's health dispensary that kept a herbarium: every
preparation was pressed, mounted, labelled and dated, and the labels became the
shop's record. The cabinet is the catalogue. Nothing here was written by a
marketing department, because nothing here was written at all: it was typed, one
sheet at a time, and filed.

**What it changes.** Pressed linen paper, moss ink, one deep berry. Names are
typeset in a serif; data is typewritten in mono, the two hands a real sheet has.
The catalogue is a cabinet: two across with wide gaps, each product a specimen
sheet with a ruled mount, the photograph inside it, and no two sheets quite
straight. Photography is mounted and washed, never glossy. Motion is a settle:
sheets come to rest with a slight rotation, the way a page laid on a desk does.

---

## The plates

The catalogue ships one studio rendering per product, made from scratch in
Blender: twelve objects framed from their own bounding boxes, shot on a
transparent film so each world can put its own paper behind them and treat the
photograph its own way. They are not photographs of real products and nothing in
the markup or the alt text claims they are. `alt` says "studio rendering". Real
photography replaces them the moment it exists: Active Storage uploads take
precedence over the render, and the render takes precedence over the empty
plate.

## Token contract

Every world defines the same token names, so any component can be styled once
and worn four ways: `paper`, `paper-sunk`, `line`, `line-strong`, `ink`,
`ink-soft`, `body`, `muted`, `disabled`, `plate`, `plate-soft`, `plate-line`,
`plate-ink`, `plate-body`, `plate-muted`, `accent`, `accent-strong`,
`accent-hover`, `accent-wash`, `accent-plate`, `ember`, `on-accent`, the radius
scale, and the two tracking values.

Contrast is machine-checked for every world (`script/check-contrast`): body,
muted, accent, reversed accent, and all four plate pairs must clear 4.5:1, and
accent on a plate must clear 3:1. All four worlds pass.
