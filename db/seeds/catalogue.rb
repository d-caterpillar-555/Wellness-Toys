# Demo catalogue.
#
# SYNTHETIC DATA. Every product, brand and price here is invented for
# development. Nothing in this file is a real product, a real brand, or a real
# price, and none of it may ship to production.
#
# Deliberately absent, per docs/project-context.md section 7:
#   - no clinical or therapeutic claims
#   - no certifications, awards or accreditations
#   - no efficacy statistics of any kind
#   - no clinician names
#
# Materials and care instructions ARE filled in, because those are descriptive
# facts about a category of product rather than claims, and an empty materials
# field would make the product page design impossible to evaluate.

puts "Seeding catalogue"

brands = {
  "Northlight" => "Small-batch manufacturer working in medical-grade silicone.",
  "Ashgrove" => "Body-care formulations made in the UK.",
  "Corvid" => "Precision-engineered devices with a two-year warranty.",
  "Fenwick" => "Everyday essentials at accessible prices."
}.map do |name, description|
  Brand.find_or_initialize_by(slug: name.parameterize).tap do |brand|
    brand.assign_attributes(name: name, description: description)
    brand.save!
  end
end

brand_by_name = brands.index_by(&:name)

categories = [
  { name: "Vibrators", position: 1, description: "Internal and external devices, mains and rechargeable." },
  { name: "Lubricants", position: 2, description: "Water-based, silicone-based and hybrid formulations." },
  { name: "Massage", position: 3, description: "Oils, candles and massage tools." },
  { name: "Pelvic health", position: 4, description: "Trainers and tools for pelvic floor work." },
  { name: "Barrier methods", position: 5, description: "Condoms and dental dams." },
  { name: "Care and storage", position: 6, description: "Cleaners, cases and storage." }
].map do |attributes|
  Category.find_or_initialize_by(slug: attributes[:name].parameterize).tap do |category|
    category.assign_attributes(attributes)
    category.save!
  end
end

category_by_name = categories.index_by(&:name)

CATALOGUE = [
  {
    name: "Aperture Wand",
    brand: "Corvid",
    category: "Vibrators",
    subtitle: "A mains-powered external massager with a stepless dial.",
    materials: "Body-safe ABS housing, silicone head, aluminium dial.",
    care: "Wipe the head with a dedicated toy cleaner before and after use. Do not submerge the body.",
    dimensions: "220 x 55 mm head",
    weight_grams: 380,
    body_safe: true,
    variants: [
      { name: "Standard", price_cents: 8900, stock: 12 },
      { name: "With travel case", price_cents: 10900, stock: 4 }
    ]
  },
  {
    name: "Aperture Mini",
    brand: "Corvid",
    category: "Vibrators",
    subtitle: "The same motor in a rechargeable pocket format.",
    materials: "Body-safe silicone, anodised aluminium.",
    care: "Fully waterproof to IPX7. Clean with soap and warm water, or a dedicated cleaner.",
    dimensions: "120 x 32 mm",
    weight_grams: 145,
    body_safe: true,
    variants: [
      { name: "Slate", price_cents: 5400, stock: 20 },
      { name: "Bone", price_cents: 5400, stock: 0 }
    ]
  },
  {
    name: "Northlight Internal",
    brand: "Northlight",
    category: "Vibrators",
    subtitle: "A smooth, gently curved internal vibrator with five speeds.",
    materials: "Medical-grade silicone (platinum-cured), ABS core.",
    care: "Waterproof. Clean before and after use. Use with water-based lubricant only.",
    dimensions: "185 x 34 mm, 3.2 mm wall",
    weight_grams: 210,
    body_safe: true,
    variants: [
      { name: "Deep Jade", price_cents: 7200, stock: 9 },
      { name: "Graphite", price_cents: 7200, stock: 6 }
    ]
  },
  {
    name: "Ashgrove Water-Based",
    brand: "Ashgrove",
    category: "Lubricants",
    subtitle: "A plain water-based lubricant with no glycerine and no fragrance.",
    materials: "Water, propanediol, hydroxyethylcellulose, sodium benzoate, citric acid.",
    care: "Store upright below 25C. Discard six months after opening.",
    dimensions: "150 ml",
    weight_grams: 190,
    body_safe: true,
    variants: [
      { name: "150 ml", price_cents: 1800, stock: 40 },
      { name: "250 ml", price_cents: 2600, stock: 22 }
    ]
  },
  {
    name: "Ashgrove Silicone",
    brand: "Ashgrove",
    category: "Lubricants",
    subtitle: "Silicone-based, for use in water and with condoms.",
    materials: "Dimethicone, dimethiconol, cyclopentasiloxane.",
    care: "Do not use with silicone toys. Store at room temperature.",
    dimensions: "100 ml",
    weight_grams: 140,
    body_safe: true,
    variants: [
      { name: "100 ml", price_cents: 2200, stock: 18 }
    ]
  },
  {
    name: "Fenwick Hybrid",
    brand: "Fenwick",
    category: "Lubricants",
    subtitle: "Water-based feel with silicone staying power.",
    materials: "Water, dimethicone, propanediol, sodium hyaluronate.",
    care: "Store upright. Safe with latex and polyisoprene condoms.",
    dimensions: "120 ml",
    weight_grams: 160,
    body_safe: true,
    variants: [
      { name: "120 ml", price_cents: 1600, compare_at_price_cents: 2000, stock: 30 }
    ]
  },
  {
    name: "Corvid Massage Oil",
    brand: "Corvid",
    category: "Massage",
    subtitle: "A slow-absorbing blend for longer massage.",
    materials: "Sweet almond oil, jojoba, vitamin E.",
    care: "Contains nuts. Patch test before first use. Not for internal use.",
    dimensions: "200 ml",
    weight_grams: 230,
    body_safe: false,
    variants: [
      { name: "Unscented", price_cents: 2400, stock: 25 },
      { name: "Cedar", price_cents: 2600, stock: 14 }
    ]
  },
  {
    name: "Northlight Massage Stone",
    brand: "Northlight",
    category: "Massage",
    subtitle: "A hand-finished basalt stone for warm or cold massage.",
    materials: "Polished basalt.",
    care: "Warm in water no hotter than 50C. Dry fully before storing.",
    dimensions: "90 x 60 mm",
    weight_grams: 420,
    body_safe: false,
    variants: [
      { name: "Single", price_cents: 1900, stock: 35 }
    ]
  },
  {
    name: "Ashgrove Pelvic Trainer Set",
    brand: "Ashgrove",
    category: "Pelvic health",
    subtitle: "A graduated set for pelvic floor exercise.",
    materials: "Medical-grade silicone, weighted cores.",
    care: "Clean with soap and warm water. Use with water-based lubricant.",
    dimensions: "Three weights, 55 to 90 g",
    weight_grams: 260,
    body_safe: true,
    variants: [
      { name: "Set of three", price_cents: 4200, stock: 16 }
    ]
  },
  {
    name: "Fenwick Condoms",
    brand: "Fenwick",
    category: "Barrier methods",
    subtitle: "Natural rubber latex, nominal width 54 mm.",
    materials: "Natural rubber latex, silicone lubricant.",
    care: "Store away from heat and light. Check the expiry date before use.",
    dimensions: "54 mm nominal width, 12 pack",
    body_safe: true,
    variants: [
      { name: "12 pack", price_cents: 1200, stock: 60 },
      { name: "36 pack", price_cents: 3000, stock: 28 }
    ]
  },
  {
    name: "Corvid Toy Cleaner",
    brand: "Corvid",
    category: "Care and storage",
    subtitle: "A fragrance-free cleaner for silicone and hard surfaces.",
    materials: "Water, benzalkonium chloride, citric acid.",
    care: "Spray, leave for ten seconds, wipe. Do not rinse silicone under hot water.",
    dimensions: "200 ml",
    weight_grams: 220,
    body_safe: false,
    variants: [
      { name: "200 ml", price_cents: 1400, stock: 45 }
    ]
  },
  {
    name: "Northlight Storage Case",
    brand: "Northlight",
    category: "Care and storage",
    subtitle: "A lockable case with a ventilated lining.",
    materials: "Recycled ABS shell, cotton lining.",
    care: "Wipe the shell with a damp cloth. The lining is removable and washable.",
    dimensions: "260 x 120 x 90 mm",
    weight_grams: 520,
    body_safe: false,
    variants: [
      { name: "Slate", price_cents: 3400, stock: 8 },
      { name: "Bone", price_cents: 3400, stock: 3 }
    ]
  }
].freeze

CATALOGUE.each_with_index do |entry, index|
  category = category_by_name.fetch(entry[:category])

  product = Product.find_or_initialize_by(slug: entry[:name].parameterize)
  product.assign_attributes(
    name: entry[:name],
    sku: format("WT-%03d", index + 1),
    subtitle: entry[:subtitle],
    description: entry[:subtitle],
    materials: entry[:materials],
    care_instructions: entry[:care],
    dimensions: entry[:dimensions],
    weight_grams: entry[:weight_grams],
    body_safe: entry[:body_safe],
    brand: brand_by_name.fetch(entry[:brand]),
    status: "active",
    published_at: 30.days.ago
  )
  product.save!

  product.categories = [ category ] unless product.categories.include?(category)

  entry[:variants].each_with_index do |variant_attributes, position|
    variant = product.variants.find_or_initialize_by(sku: "#{product.sku}-#{position + 1}")
    variant.assign_attributes(
      name: variant_attributes[:name],
      price_cents: variant_attributes[:price_cents],
      compare_at_price_cents: variant_attributes[:compare_at_price_cents],
      stock_quantity: variant_attributes[:stock],
      position: position,
      active: true,
      options: { "colour" => variant_attributes[:name].downcase }
    )
    variant.save!
  end

  puts "  #{product.name}"
end

puts "Brands: #{Brand.count}, Categories: #{Category.count}, " \
     "Products: #{Product.count}, Variants: #{Variant.count}"
