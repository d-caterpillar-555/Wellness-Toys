# Wellness Toys

Rails 8 storefront and education platform for sexual health and wellness products.

## Canonical context, in priority order

1. `gems.md` - **dependency authority.** What the app uses. Never add a gem that this file does not sanction without a documented reason.
2. `skills.md` - **agent routing map.** How agents work. It is a routing table, not a preload list.
3. `docs/project-context.md` - the product overlay. Where this project deliberately differs from the Follica base that `gems.md` and `skills.md` were written for.
4. `docs/domain-terms.md` - canonical vocabulary. One term per concept, everywhere.
5. `docs/design/DESIGN.md` - design tokens and the banned-pattern list.

When `gems.md` and `skills.md` disagree with this project's overlay, **the overlay wins**, and the divergence is recorded there rather than edited into the base files.

## Skill protocol

`skills.md` opens with a rule that agents routinely get wrong:

> Agents should activate the smallest relevant skill set for the current task. Do not activate every skill on every task.

The corpus lives on disk at `.skills-mcp/` when present, and at
`~/transplant-teddy/.skills-mcp/stage_all/` and `.../custom/` otherwise. Classify the job, retrieve one to three skills, do the work, then retrieve the review skills the task type requires. Do not preload.

## Non-negotiables

- **Rails 8 built-ins before gems.** Rule 11 of `gems.md` §2. Check the framework first.
- **Database constraints, not just model validations.** Rule 17. Uniqueness, `NOT NULL`, foreign keys and `CHECK` constraints live in the schema. A `validates` call is a user-experience nicety, never the guarantee.
- **Transactions and idempotency for anything multi-step.** `gems.md` §14B. No external network calls inside a database transaction.
- **Authorisation is server-side and tested.** Pundit on every action. A policy without a full actor-by-resource spec matrix is an audit finding, not a pass (`gems.md` §15A).
- **Health-adjacent data is sensitive even though this is not a HIPAA-covered business.** Purchase history and browsing reveal health intent. No such data in URLs, logs, third-party scripts, or search indexes.
- **Never invent facts.** No fabricated statistics, credentials, certifications, prices, ingredients, outcomes, or clinician names. This applies to seed data too, which must be labelled as synthetic.
- **Zero third-party analytics in v1.** Consent records exist so a consented layer can be added later. It is not added now.

## Definition of done

Writing code that appears to work is not the finish line. A task is done only when the checklist in `skills.md` §12A can be honestly checked: behaviour works including edge cases, tests pass, authorisation matrix covered, database integrity enforced, security review applied where warranted, CI gates green, and a final report stating what changed, what was tested, what was deferred and why, and what risk remains.

If a box cannot be checked, say so explicitly rather than reporting completion.

## Commands

```bash
mise exec -- bin/dev              # development server on :3000
mise exec -- bin/rails db:prepare # create + migrate + seed
mise exec -- bundle exec rspec
mise exec -- bundle exec rubocop
mise exec -- bundle exec brakeman
mise exec -- bundle exec bundler-audit
```

Ruby is pinned to 3.4.10 via `mise.toml`. Always run through `mise exec` so the right Ruby is used rather than the system 3.3.8.
