# Wellness Toys - Project Context

> **This is the overlay file.** `gems.md` and `skills.md` were written for **Follica**, a
> medical-tourism coordination platform. Wellness Toys borrows that project's *engineering
> discipline* - dependency restraint, database-level integrity, transactional writes,
> tested authorisation, privacy-first handling of health-adjacent data - but it is a
> **different product**.
>
> Where the Follica base and this file disagree, **this file wins.** The base files are not
> edited to record the divergence; it is recorded here.

---

## 1. What Wellness Toys is

A direct-to-consumer storefront and education platform for sexual health and wellness
products.

It sells physical products. It also publishes. The education side is not marketing filler
bolted onto a shop - it is the reason the brand exists and the thing that makes the shop
credible.

**Wellness Toys is not a medical provider.** It does not diagnose, treat, prescribe, or
give clinical advice. Where a question is medical, the site says so and points to a
clinician.

## 2. Positioning

The category norm is black backgrounds, neon glow, lace textures, euphemism, and
"discreet billing" shouted as the loudest message on the page. Wellness Toys does the
opposite: it presents as a **health institution that publishes**.

Three positions follow:

1. **Evidence over euphemism.** Education articles carry cited sources. Product pages
   state specifications. Nothing is invented.
2. **Discretion as a standard, not a scream.** Discreet packaging is stated once, plainly,
   in the footer and on the shipping page.
3. **No shame, no titillation.** Copy is adult, direct, unembarrassed. It never moralises
   and never winks.

### Why the name is the strategy

"Wellness Toys" is deliberately plain. It says *wellness* and it says *toys*, in that
order, without apology and without a euphemism anywhere in it. That is the taboo-breaking
argument, made in two words.

Which means the **design carries the other half of the deal.** A playful name paired with a
playful design reads as a novelty shop. A plain name paired with a serious editorial
treatment reads as a health institution. The tension is the brand.

Concretely: the wordmark is set in an editorial serif, both words at equal weight and case.
It is never softened, abbreviated, or turned into a cute monogram. The cliché of italicising
the "respectable" half of the name would undercut the whole point.

## 3. Deliberate divergences from the Follica base

| Follica base | Wellness Toys | Why |
|---|---|---|
| Razorpay is the only payment provider (§2 rule 16) | **No payment provider in v1.** Orders are created in `awaiting_invoice`. | Payment provider eligibility for this product category is an open human decision. The order flow is built to the transactional standard so a gateway drops into existing plug points. |
| HIPAA / PHI compliance is a first-class concern | **Not a HIPAA covered entity.** The strict posture is kept anyway, under FTC HBNR and state consumer-health law. | See §6. |
| Devise + devise-two-factor for doctors and admin | **Devise for customers. No 2FA in v1.** | There are no clinical staff accounts. Admin 2FA is a deferred follow-up, not a silent omission. |
| Meilisearch self-hosted on our own server | **Installed and server-proxied, but v1 search runs the PostgreSQL `ILIKE` fallback.** No index is wired yet. | The binary at `.tools/meilisearch` has to be running to index, and the fallback needed no service, so it shipped first. The swap points are `Product.search_by_text` and `Article.search_by_title`; the controller and the key-hiding architecture are already in place. An open item, not a silent omission. |
| Avo Pro / paid tiers | **Avo Community** (free open-core). Per-action authorization inside Avo lives in the paid `avo-authorization` add-on, so the application supplies its own adapter. | `Avo::PunditResource` plus `lib/avo/pundit_authorization.rb` answer Avo's questions from the same Pundit policies the storefront uses, through a separate `avo_*?` set so a customer-facing rule is never reused for the console. The panel itself is staff-only (`config/initializers/avo.rb`). |
| Bullet in development only, per `gems.md` | **Bullet in development and test**, with `Bullet.raise` on in the suite. | `gems.md` §35B keeps "Bullet warnings zero" as a CI condition, and a condition nobody runs is not a condition. Switching it on found and fixed several real N+1s and unused eager loads. |
| RSpec (per `gems.md` §15) | **RSpec retained.** | The `rails-conventions` skill says Minitest and forbids factory gems. `gems.md` is the declared dependency authority and this project's existing tooling is RSpec. Recorded as a deliberate, reasoned deviation. |
| ABDM, MSG91, WhatsApp Cloud API, Daily.co, FullCalendar, Leaflet, Hotwire Native | **Not installed.** | Medical-tourism and telehealth concerns. No equivalent need here. |

**Everything else in `gems.md` still applies**: Rails 8 built-ins before gems, dependency
restraint, database-level constraints, transactional and idempotent writes, Pundit on every
action, expand/contract migrations, CI gates.

### Known gaps at the end of this build

Each of these is deliberate and each is a follow-up rather than a surprise.

- **The live browser pass has run, without root.** Chrome's missing libraries
  (`libnspr4`, `libnss3`, `libasound2`) were extracted to `~/.local/lib/chrome-deps` and
  `LD_LIBRARY_PATH` points there, so Playwright's bundled Chromium starts. Every page in
  the build has since been rendered and read at 1440px and 390px. What is still unrun is
  `script/install-system-deps` itself: it needs an interactive `sudo`, and until it runs
  `libvips` is unavailable, so Active Storage variants (thumbnails, resizes) cannot be
  generated. The catalogue carries no photography yet, so nothing depends on it today.
- **Development runs the content security policy in report-only mode.** Design tooling
  (the `variate` card, which injects its own styles from a local port) cannot run under an
  enforcing policy with style nonces. Production enforces the policy exactly as written.
  `config/content_security_policy.rb` gates this on `Rails.env.development?`.
- **`.variate/` is design-round scratch space, not application code.** It is gitignored.
  While a round is open the layout carries one marker-bracketed line that loads the card;
  `variate end` removes it, and it must never reach a release.
- **`data-test-id` selectors are not used.** The suite asserts on rendered text and roles,
  which is what a reader actually sees. The plan asked for test ids; this is a knowing
  deviation, recorded here rather than quietly.
- **`paper_trail` is installed and unused.** No model declares `has_paper_trail`. Audit
  history currently lives in `audit_events` and `order_events`, which record who did what;
  the `versions` table stays empty until a model needs full field history.
- **Meilisearch indexing is unwired** (see the table above).
- **Admin 2FA is still deferred**, as the plan states, and needs a decision before launch.

## 4. Two sides of the product

### Shop

Home, category browse, curated collections, product detail, search, cart, checkout as an
order request, order status for guests and account holders, reviews.

### Learn

An evergreen education hub (`/learn`) organised as topic pillars with spoke articles, a
glossary, and named expert authors with credentials. A separate `/blog` carries timely
posts. Education articles cite real sources, rendered as a visible evidence rail - not a
footnote nobody reads.

`/learn` and `/blog` are deliberately separate: one is a compounding search asset, the
other is a running commentary.

## 5. Actors

| Actor | Can |
|---|---|
| **Visitor** | Browse shop and learn, search, hold a cart, place an order as a guest, read an order's status via its public token |
| **Customer** | Everything a visitor can, plus order history, saved addresses, reviews, consent management, data export and deletion requests |
| **Editor** | Manage articles, topics, authors, sources, and product content in admin |
| **Admin** | Full operational access, including orders, products, inventory, moderation, and redirects |

Authorisation is Pundit, server-side, on every action. Default deny. Hiding a link is never
authorisation.

## 6. Privacy posture

Wellness Toys is **not a HIPAA covered entity** and makes no HIPAA-compliance claim. Claiming
otherwise would be a deceptive-practices risk in itself.

It is nonetheless subject to, or exposed to:

- **FTC Health Breach Notification Rule** - a voluntary disclosure of health data to an ad
  or analytics vendor counts as a reportable breach.
- **State consumer-health law**, notably Washington's My Health My Data Act, which treats
  **inferences drawn from browsing** as consumer health data, and carries a private right
  of action.
- **PCI-DSS** once a payment provider is added.

**The operative consequence:** order contents, order history, cart contents, search queries,
and the fact that someone visited a category page are all health-revealing. They are treated
as sensitive even though no clinical record exists.

Therefore:

- No third-party analytics, ad pixels, or session replay anywhere in v1. Not on the shop,
  not on `/learn`, not anywhere.
- No PII in URLs. Orders are accessed by an opaque `public_token`, never a sequential number.
- No health-adjacent data in logs, in Sentry breadcrumbs, in search indexes, or in email
  subject lines.
- Field-level encryption for phone numbers and street addresses.
- Consent records are append-only and separate collection from sharing.
- Data export and deletion are real, working, user-facing features, not policy prose.

## 7. Content rules

- **Never invent facts.** No fabricated statistics, studies, certifications, credentials,
  prices, ingredients, materials, outcomes, or clinician names.
- **No medical claims.** Products are described, not prescribed.
- **Seed data is synthetic and labelled as such.** Demo products, demo articles, demo
  authors. Nothing in the seed set may look like a real credential or a real citation to a
  study that does not exist.
- Sources attached to seed articles must point to real, verifiable publications or be
  omitted. A fabricated citation is worse than a missing one.
- Copy uses hyphens, not em-dashes.
