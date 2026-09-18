# Seeds.
#
# Everything created here is DEMO DATA. Products, articles and authors are
# synthetic. No real credential, citation, statistic, price or clinical claim is
# invented anywhere in this file. Where a fact would be required, the seed says
# so plainly and marks it as a value to replace before launch.
#
# See docs/project-context.md section 7.
#
# Run with: bin/rails db:seed

puts "Seeding pages"

PAGES = [
  {
    slug: "about",
    title: "Why we exist",
    subtitle: "This category is marketed badly, and the cost of that is not cosmetic.",
    position: 1,
    body: <<~TEXT
      Most shops in this category are built on the assumption that you would
      rather not be seen buying anything. So the copy winks, the photography
      leers, and the information you actually need sits somewhere below all of it.

      We think that assumption is wrong, and that it does real harm. A category
      that cannot talk about itself plainly is a category where people guess, and
      guessing is how people end up with the wrong product, the wrong material,
      or the wrong expectation.

      So #{Brand.name} is built the other way round. Products are described the
      way any other product in a health category would be described: what it is
      made of, what it measures, how it is cleaned, and who it is not suitable
      for. Alongside that we publish an education library, and we cite our
      sources so you can check them.

      Where a question is medical, we say so. We are a shop, not a clinic, and
      pretending otherwise would be the most dishonest thing we could do.

      DEMO CONTENT. Replace this page before launch.
    TEXT
  },
  {
    slug: "standards",
    title: "How we choose what we stock",
    subtitle: "Four questions, asked of every product before it is listed.",
    position: 2,
    body: <<~TEXT
      We do not stock a product because it sells. Every item has to answer four
      questions, and a failure on any of them means it does not get listed.

      What is it made of? The materials are named specifically. If a manufacturer
      will not disclose a material, we do not carry the product.

      Is it body safe? Material claims are checked against published material
      safety guidance rather than taken from the packaging.

      Can we explain it honestly? If the only thing we can say about a product is
      that it feels good, that product does not need a page on this site.

      Would we tell a friend to buy it? This one is subjective, and it is the
      filter that removes the most products.

      We do not accept payment for placement, we do not rank products by
      commission, and we do not publish reviews written by anyone other than
      verified purchasers.

      DEMO CONTENT. The checks described here are a policy statement, not yet an
      enforced workflow. Replace before launch.
    TEXT
  },
  {
    slug: "contact",
    title: "Contact",
    subtitle: "A real person reads every message, usually within one working day.",
    position: 3,
    body: <<~TEXT
      Email is the fastest way to reach us, and the only channel we monitor for
      order problems.

      For anything about an order, include the order number. Do not send payment
      details or identity documents by email.

      If your question is medical, we are not able to answer it. We will say so,
      and we will suggest you speak to a clinician. That is not us being
      unhelpful, it is us being honest about what we are.
    TEXT
  },
  {
    slug: "shipping",
    title: "Shipping",
    subtitle: "Plain packaging, neutral billing descriptor, no exceptions.",
    position: 4,
    body: <<~TEXT
      Every order ships in plain, unbranded packaging. There is no product name,
      no category description and no logo on the outside. The return address is a
      neutral initials-only address.

      The billing descriptor on your statement is the legal entity name and
      nothing else. It does not describe what you bought.

      Where the law allows a generic customs description, we use one rather than
      naming the product.

      DEMO CONTENT. Rates, carriers and delivery windows are not yet configured.
      This section must be completed with real values before launch.
    TEXT
  },
  {
    slug: "discreet-shipping",
    title: "What arrives, and what it says on it",
    subtitle: "The short version: nothing on the outside tells anyone what is inside.",
    position: 5,
    body: <<~TEXT
      This is the page people look for first, so here it is without the
      theatrics.

      The outer packaging is plain. No logo, no product name, no category. The
      sender name is a neutral business name that does not mention this industry.

      Your bank statement shows the legal entity name only.

      Delivery notifications, where we send them, say that a parcel is on its
      way. They do not name what is in it.

      Email subject lines never describe an order's contents. A confirmation
      names the order number and links you back to the order, where you can see
      the detail after proving you are entitled to.

      None of this is a special feature. It is the minimum, and it is what lets
      the rest of the site talk about products normally.
    TEXT
  },
  {
    slug: "returns",
    title: "Returns",
    subtitle: "What we can accept, what we cannot, and why.",
    position: 6,
    body: <<~TEXT
      For hygiene and safety reasons an intimate product cannot be returned once
      its packaging has been opened. This is a legal requirement in most of the
      places we ship to, and it is also the correct rule.

      An unopened item in its original sealed packaging can be returned within
      the window stated at checkout.

      If an item arrives damaged or faulty, or is not what you ordered, that is
      our problem and we will fix it. Contact us with the order number and a
      photograph, and we will replace or refund it.

      DEMO CONTENT. The return window and the exact exceptions are not yet
      configured. Complete this section with a real policy before launch.
    TEXT
  },
  {
    slug: "privacy",
    title: "What we collect, and what we refuse to",
    subtitle: "Purchase history here reveals health intent. We treat it that way.",
    position: 7,
    body: <<~TEXT
      Buying something here, or even browsing a category page, says something
      about your health. That makes this data sensitive even though there is no
      medical record anywhere in it. We handle it on that basis.

      What we collect: your email address, your name and delivery address, your
      order history, and the technical information required to serve a page and
      keep your account secure.

      What we do not do: there are no advertising trackers, no session recording,
      no social media pixels, and no third party analytics on this site. Not on
      the shop, not in checkout, and not in your account.

      We do not put your name, your email or your order contents in a URL. Order
      links use a random token rather than a guessable number.

      We do not write your name, email, address or order contents to application
      logs, and we do not send them to an error monitoring service.

      You can export everything we hold about you, and you can ask us to delete
      it, from your account. Both are working features rather than a policy
      paragraph.

      We do not claim certification under any healthcare privacy framework. We
      are not a healthcare provider and we do not pretend to be one.

      DEMO CONTENT. This page must be reviewed against the law of each
      jurisdiction you ship to, by someone qualified to do so, before launch.
    TEXT
  },
  {
    slug: "terms",
    title: "Terms of sale",
    subtitle: "The agreement between you and us when you buy something.",
    position: 8,
    body: <<~TEXT
      You must be of legal age to purchase adult products in your jurisdiction.
      By placing an order you confirm that you are.

      Products are sold for personal use. Nothing on this site is medical advice,
      and no product is sold as a treatment for any condition.

      We describe products as accurately as we can, from manufacturer information
      and our own checks. We do not warrant any particular outcome from use.

      DEMO CONTENT. This is a summary, not a complete set of terms. A full set
      must be drafted and reviewed by a qualified professional before launch.
    TEXT
  },
  {
    slug: "accessibility",
    title: "Accessibility",
    subtitle: "Where we are, and what we know is still missing.",
    position: 9,
    body: <<~TEXT
      This site targets WCAG 2.1 level AA. We test with a keyboard alone, at 200
      percent zoom, and at a narrow mobile viewport.

      Specifically: every interactive element is reachable and operable by
      keyboard, focus is always visible, text contrast meets AA against the
      background it sits on, touch targets are at least 44 by 44 pixels, and the
      site honours a reduced motion preference.

      Automated checks only catch part of this. If something here does not work
      for you, tell us and we will fix it.

      DEMO CONTENT. An independent accessibility audit is recommended before
      launch.
    TEXT
  },
  {
    slug: "faq",
    title: "Questions we get asked",
    subtitle: "",
    position: 10,
    body: <<~TEXT
      Does anything on the packaging say what it is?

      No. Plain outer packaging, a neutral sender name, and a billing descriptor
      that is only the legal entity.

      Do you sell my data?

      No. There are no advertising trackers or third party analytics on this site
      at all, so there is nothing to sell.

      Can I return an opened product?

      No, for hygiene reasons. Unopened items in sealed packaging can be
      returned. Faulty or incorrect items are always our problem to fix.

      Do you give medical advice?

      No, and we will say so rather than improvise. If your question is clinical
      it belongs with a clinician.

      Is my order confidential?

      Yes. Order access uses a random token rather than a guessable number, and
      order contents never appear in a URL, an email subject line or a log.
    TEXT
  }
].freeze

PAGES.each do |attributes|
  page = Page.find_or_initialize_by(slug: attributes[:slug])
  page.assign_attributes(attributes.merge(published_at: Time.current, show_in_footer: true))
  page.save!
  puts "  #{page.slug}"
end

puts "Pages: #{Page.count}"
