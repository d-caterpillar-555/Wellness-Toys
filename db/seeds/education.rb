# Demo education library.
#
# SYNTHETIC DATA, with one important exception: the SOURCES are real.
#
# Every URL in this file points to a real page published by a real
# organisation. Fabricating a citation is worse than having none, so where a
# claim would need a source that does not exist, the article simply does not
# make the claim.
#
# Authors are DEMO records. `credentials` is deliberately left blank rather
# than filled with plausible-looking qualifications, because an invented
# credential is a lie told by the interface.
#
# Article bodies are short placeholders that demonstrate the layout. They are
# not medical advice and must be replaced with reviewed writing before launch.

puts "Seeding education library"

TOPICS = [
  { name: "Sexual health basics", position: 1,
    description: "The groundwork: how bodies work, what routine care looks like, and when to see someone." },
  { name: "Contraception", position: 2,
    description: "Methods, effectiveness, side effects and how to choose between them." },
  { name: "Pleasure and anatomy", position: 3,
    description: "What is actually there, what it does, and why so much of what people repeat is wrong." },
  { name: "Communication and consent", position: 4,
    description: "Talking about sex before, during and after, including the awkward parts." },
  { name: "Sexual wellbeing", position: 5,
    description: "Desire, pain, ageing, medication and mental health, treated as ordinary subjects." }
].map do |attributes|
  Topic.find_or_initialize_by(slug: attributes[:name].parameterize).tap do |topic|
    topic.assign_attributes(attributes)
    topic.save!
  end
end

topic_by_name = TOPICS.index_by(&:name)

AUTHORS = [
  { name: "Rowan Ellis", is_clinician: false,
    bio: "DEMO AUTHOR. Writes about sexual health and product safety. Replace with a real, verified contributor before launch." },
  { name: "Priya Raghunathan", is_clinician: false,
    bio: "DEMO AUTHOR. Writes about contraception and sexual wellbeing. Replace with a real, verified contributor before launch." },
  { name: "Marcus Adeyemi", is_clinician: false,
    bio: "DEMO AUTHOR. Writes about communication and relationships. Replace with a real, verified contributor before launch." }
].map do |attributes|
  Author.find_or_initialize_by(slug: attributes[:name].parameterize).tap do |author|
    # credentials is intentionally absent. Left blank.
    author.assign_attributes(attributes)
    author.save!
  end
end

author_by_name = AUTHORS.index_by(&:name)

ARTICLES = [
  {
    title: "How to read a materials list on an intimate product",
    kind: "guide",
    topic: "Sexual health basics",
    author: "Rowan Ellis",
    excerpt: "Silicone, TPE, ABS and elastomer are not interchangeable. Here is what each one means in practice.",
    reading_minutes: 6,
    sources: [
      { title: "Sexual health", publisher: "World Health Organization",
        url: "https://www.who.int/health-topics/sexual-health" }
    ],
    body: <<~TEXT
      The materials list is the most useful thing on an intimate product's
      packaging, and it is usually the smallest print.

      Platinum-cured silicone is inert, non-porous, and can be cleaned
      thoroughly. It costs more, and it lasts. TPE and elastomer are softer and
      cheaper, and they are porous, which means they hold onto bacteria in a way
      that silicone does not. That is not a scandal, it is a property, and it
      changes how you clean the thing and how long you keep it.

      ABS is a hard plastic, common in device housings. It is fine on the
      outside. It is not a surface you want internally.

      This article is a DEMO placeholder. The full version would go into each
      material, what it is compatible with, and how to tell them apart.
    TEXT
  },
  {
    title: "Water-based, silicone-based, hybrid: choosing a lubricant",
    kind: "guide",
    topic: "Sexual health basics",
    author: "Rowan Ellis",
    excerpt: "The choice usually comes down to two questions: what you are using it with, and how long you need it to last.",
    reading_minutes: 5,
    sources: [
      { title: "Sexual health", publisher: "NHS",
        url: "https://www.nhs.uk/live-well/sexual-health/" },
      { title: "Sexual health", publisher: "World Health Organization",
        url: "https://www.who.int/health-topics/sexual-health" }
    ],
    body: <<~TEXT
      Water-based lubricant is compatible with everything, including silicone
      toys and latex condoms. It is also the one that dries out fastest, which
      is why it is usually sold in larger bottles than people expect.

      Silicone-based lubricant lasts far longer and is the right answer for
      anything in water. It will degrade silicone toys, so it is not the right
      answer for those.

      Hybrid formulations try to sit between the two. They are usually
      water-based with a small amount of silicone, which means a slightly longer
      working time without the toy problem.

      DEMO placeholder. The full version would cover glycerine, osmolality,
      preservatives, and what to do when something stings.
    TEXT
  },
  {
    title: "What the research actually says about pelvic floor training",
    kind: "guide",
    topic: "Sexual wellbeing",
    author: "Priya Raghunathan",
    excerpt: "Pelvic floor exercise is well evidenced for some things, and oversold for others.",
    reading_minutes: 8,
    sources: [
      { title: "Sexual health", publisher: "World Health Organization",
        url: "https://www.who.int/health-topics/sexual-health" },
      { title: "Sexual and reproductive health", publisher: "CDC",
        url: "https://www.cdc.gov/sexual-health/" }
    ],
    body: <<~TEXT
      Pelvic floor muscle training has reasonable evidence behind it for
      specific indications. It is also marketed for a great deal more than that.

      This article is a DEMO placeholder. It exists to demonstrate the evidence
      rail, which lists the sources for the piece in a column beside the body
      text on wide screens, and as an appendix on narrow ones.

      The point of the rail is that a reader can check the claim. An article
      with no sources is an article making assertions on its author's authority
      alone, and this publication does not do that.

      Replace this body with reviewed writing before launch.
    TEXT
  },
  {
    title: "Talking about sex when it is awkward",
    kind: "guide",
    topic: "Communication and consent",
    author: "Marcus Adeyemi",
    excerpt: "Most people find this difficult. The difficulty is not a sign you are doing it wrong.",
    reading_minutes: 7,
    sources: [
      { title: "Sexual health", publisher: "NHS",
        url: "https://www.nhs.uk/live-well/sexual-health/" }
    ],
    body: <<~TEXT
      The expectation that conversations about sex should be effortless is
      itself the main obstacle. They are awkward for most people, most of the
      time, and that is not a failure of the relationship.

      DEMO placeholder. The full version would cover opening lines that work,
      what to do when a conversation goes badly, and how to raise a change in
      what you want without it landing as criticism.
    TEXT
  },
  {
    title: "Contraception effectiveness, without the marketing",
    kind: "guide",
    topic: "Contraception",
    author: "Priya Raghunathan",
    excerpt: "Typical use and perfect use are different numbers, and the gap matters more than the headline.",
    reading_minutes: 9,
    sources: [
      { title: "Contraception", publisher: "CDC",
        url: "https://www.cdc.gov/contraception/" },
      { title: "Sexual and reproductive health", publisher: "World Health Organization",
        url: "https://www.who.int/health-topics/sexual-health" }
    ],
    body: <<~TEXT
      Every method has two effectiveness figures, and the one in the marketing
      is usually the better of the two.

      DEMO placeholder. The full version would set out perfect-use and
      typical-use rates side by side for each method, explain why the gap varies
      so much between methods, and cover what happens when one fails.

      Nothing in this publication is a substitute for talking to a clinician
      about your own situation.
    TEXT
  },
  {
    title: "Desire is not a fixed quantity",
    kind: "guide",
    topic: "Sexual wellbeing",
    author: "Marcus Adeyemi",
    excerpt: "The idea that everyone has a set libido, and that mismatched libidos are a problem, causes a lot of unnecessary distress.",
    reading_minutes: 6,
    sources: [
      { title: "Sexual health", publisher: "World Health Organization",
        url: "https://www.who.int/health-topics/sexual-health" }
    ],
    body: <<~TEXT
      DEMO placeholder. The full version would cover responsive versus
      spontaneous desire, how medication, sleep, stress and ageing move it, and
      why treating it as a fixed trait sets couples up to read normal variation
      as rejection.
    TEXT
  },
  {
    title: "What is a dental dam, and who actually uses one",
    kind: "glossary",
    topic: "Sexual health basics",
    author: "Rowan Ellis",
    excerpt: "A thin sheet of latex used as a barrier during oral sex.",
    reading_minutes: 2,
    sources: [
      { title: "Sexual health", publisher: "NHS",
        url: "https://www.nhs.uk/live-well/sexual-health/" }
    ],
    body: <<~TEXT
      A dental dam is a thin, flexible sheet of latex or polyisoprene placed
      over the vulva or anus during oral sex. It acts as a barrier in the same
      way a condom does.

      DEMO placeholder. The full version would cover correct use, whether you
      can make one from a condom, and how to raise the subject.
    TEXT
  },
  {
    title: "Sexual health after 50 is not a niche subject",
    kind: "post",
    topic: "Sexual wellbeing",
    author: "Priya Raghunathan",
    excerpt: "Rates of many STIs are rising fastest in older age groups, and almost nobody is talking to them about it.",
    reading_minutes: 5,
    sources: [
      { title: "Sexually transmitted infections surveillance", publisher: "CDC",
        url: "https://www.cdc.gov/sti-statistics/" }
    ],
    body: <<~TEXT
      DEMO placeholder. This is a post rather than a guide, which means it is
      reachable under /blog rather than /learn, and it carries a publication
      date because it is timely rather than evergreen.
    TEXT
  }
].freeze

ARTICLES.each_with_index do |entry, index|
  topic = topic_by_name.fetch(entry[:topic])
  author = author_by_name.fetch(entry[:author])

  article = Article.find_or_initialize_by(slug: entry[:title].parameterize)
  article.assign_attributes(
    title: entry[:title],
    kind: entry[:kind],
    status: "published",
    excerpt: entry[:excerpt],
    body: entry[:body],
    author: author,
    primary_topic: topic,
    reading_minutes: entry[:reading_minutes],
    published_at: (index * 4).days.ago
  )
  article.save!

  article.topics = [ topic ] unless article.topics.include?(topic)

  article.sources.destroy_all
  entry[:sources].each_with_index do |source_attributes, position|
    article.sources.create!(source_attributes.merge(position: position))
  end

  puts "  #{article.title}"
end

puts "Topics: #{Topic.count}, Authors: #{Author.count}, " \
     "Articles: #{Article.count}, Sources: #{Source.count}"
