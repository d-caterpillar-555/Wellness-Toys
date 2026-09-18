# Domain Terms

Canonical vocabulary for Wellness Toys. **One term per concept, everywhere** - code, routes,
params, persisted fields, admin, docs, and UI copy.

When a term changes, update the call chain. Do not add a wrapper or a parallel name to avoid
a rename.

---

## Naming rules

- **Precise one-word names.** Qualify only when the bare word is ambiguous.
- **Domain nouns over technical descriptions.** `Closure`, not `CardCloseRecord`.
- **No `*Service`, `*Manager`, `*Processor`, `*Handler`, `*Helper` suffixes.** Name the
  domain concept instead.
- **Positive predicates.** `active?`, not `not_deleted?`.
- **`id` / `uuid` are ours. `eid` belongs to an external system.** Never alias a local
  identifier as `eid`. Meilisearch document IDs are ours, so they are not `eid`s.
- **Presentation wording may differ from domain naming**, but models, params, routes,
  serializers, persisted columns, and technical docs use the canonical term.

---

## Shop

| Canonical term | Definition | Not to be called |
|---|---|---|
| **Product** | A sellable item in the abstract. Holds the shared description, materials, care, and safety information. | Item, SKU, listing, good |
| **Variant** | A specific purchasable configuration of a Product. This is what a cart line and an order line reference. Owns price and stock. | SKU *as a model name*, option, size |
| **SKU** | The human/business stock code, a **string column** on Product and Variant. Never a model name. | Product code |
| **Brand** | The maker of a Product. | Manufacturer, vendor, supplier |
| **Category** | A browsable taxonomic bucket. Hierarchical. Not curated, not editorial. | Collection, department, taxonomy |
| **Collection** | A **curated**, editorial grouping of products, chosen by a human. Not taxonomic and not hierarchical. | Category, tag |
| **Cart** | A pre-purchase basket of Variants, held by a Customer or an anonymous Visitor. | Basket, bag, trolley |
| **Cart Item** | One Variant plus a quantity, inside a Cart. | Basket line, cart row |
| **Order** | A placed request to purchase. Created once; never recreated. | Purchase, transaction, sale |
| **Order Item** | A **snapshot** of what was ordered, frozen at the moment of purchase. Never a live reference to a Variant's current values. | Line item, order line |
| **Order Event** | A dated, attributed record of a transition or note on an Order. The audit trail that makes a status boolean unnecessary. | Status log, history entry |
| **Order Number** | The human-facing reference shown to a customer, e.g. `WT-2026-000123`. **Not** an access credential. | Order ID, reference number |
| **Public Token** | The opaque, unguessable string that grants access to a guest's Order. **This** is the access credential. | Order key, hash |
| **Checkout Token** | A single-use, client-supplied token that makes order creation idempotent against double submission. | Idempotency key, nonce |
| **Review** | A customer's rating and text about a Product, subject to moderation. | Rating, testimonial, feedback |
| **Stock Quantity** | Units of a Variant physically available to sell. Integer, never negative. | Inventory, quantity on hand, qty |

### Cart behaviour, stated once

A Cart belongs to **exactly one** of: a signed-in Customer, or an anonymous Visitor via a
guest token. Never both, never neither. This is a database `CHECK` constraint, not a
convention.

---

## Education

| Canonical term | Definition | Not to be called |
|---|---|---|
| **Topic** | An evergreen subject area. The pillar in a pillar-and-spoke structure. Hierarchical via `parent_id`. | Category, tag, subject, vertical |
| **Article** | A published piece of educational writing. Has a `kind`. | Post, blog, content, page |
| **Article Kind** | One of `guide`, `pillar`, `glossary`, `post`. Determines presentation and route. | Type, format |
| **Guide** | An Article that teaches a practice or answers a recurring question. Lives under a Topic. | Tutorial, howto |
| **Pillar** | The canonical Article for a Topic. One per Topic. | Hub page, index |
| **Glossary Term** | A short Article defining one word or phrase. | Definition, entry |
| **Post** | A timely Article. Lives under `/blog`, not under a Topic. | Blog post, news, update |
| **Author** | A named person credited for an Article, with credentials. Drives E-E-A-T. | User, writer, contributor |
| **Credentials** | The Author's stated qualifications, in their own words. **Never invented.** Empty is better than fabricated. | Title, role, byline |
| **Source** | A citation attached to an Article: title, publisher, URL, date. Rendered in the evidence rail. | Reference, citation, footnote |

### Post versus Article

`Post` is a *kind of* Article, not a separate model. Both are `Article` records. The
distinction is `kind`, plus the route they are reachable at. Do not introduce a `Post` model.

---

## Content and trust

| Canonical term | Definition | Not to be called |
|---|---|---|
| **Page** | A standalone, non-article page whose body an editor can change: shipping, returns, privacy, terms, accessibility, discreet shipping, FAQ, about. | Static page, CMS page, content page |
| **FAQ** | A question and answer attached to a Product or a Page. Polymorphic. | Q&A, help entry |
| **Redirect** | A persisted mapping from an old path to a new one, so slug changes do not break inbound links. | Rewrite, forward |

---

## Accounts and privacy

| Canonical term | Definition | Not to be called |
|---|---|---|
| **Customer** | A person with a Devise account. Model name is `User`. | Member, account holder, client |
| **Address** | A saved shipping address belonging to a Customer. | Location, shipping info |
| **Consent Record** | An append-only record of a privacy choice: what kind, granted when, revoked when, against which policy version. Never updated in place. | Cookie entry, opt-in row |
| **Data Request** | A customer-initiated export or deletion request, with a lifecycle. | GDPR request, SAR, DSAR |
| **Audit Event** | A record that something sensitive was read or changed, by whom, and when. **Never contains raw PII.** | Log entry, activity feed |

### Why the model is `User` and the term is Customer

`User` is Devise's and Rails' convention, and fighting it buys nothing. The **domain term**
is Customer, and it is what UI copy, policies, and docs say. `User` never appears in
customer-facing text.

---

## Deprecated terms

Do not introduce these. If they already exist, rename the call chain rather than aliasing.

| Deprecated | Use instead | Why |
|---|---|---|
| `Item` (bare) | Product, Variant, Cart Item, or Order Item - whichever is meant | Ambiguous across four concepts |
| `SKU` as a model | Variant (`sku` is a column) | Confuses a code with an entity |
| `Basket`, `Bag` | Cart | One canonical term |
| `Order` status as a boolean | Order status enum plus Order Event | Loses who, when, and why |
| `Post` as a model | Article with `kind: "post"` | One model, one table |
| `Service` (as a class name) | The domain noun | Says nothing about what it does |
| `Admin` as a boolean on User | A role enum or a separate staff model | See below |

### Authorisation vocabulary

The base `gems.md` assumes clinic/doctor/patient actors. They do not exist here. The actors
are **Visitor**, **Customer**, **Editor**, and **Admin**, expressed as a role on `User` and
enforced through Pundit policies. A policy is named for the resource it protects
(`ProductPolicy`, `OrderPolicy`), never for the actor.
