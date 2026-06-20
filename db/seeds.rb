puts "Seeding Birds Bouquets..."

# Admin user
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@birdsbouquets.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "changeme123!")

admin = User.find_or_initialize_by(email: admin_email)
admin.assign_attributes(
  name: "Admin",
  admin: true,
  password: admin_password,
  password_confirmation: admin_password
)
admin.save!
puts "Admin: #{admin_email}"

# Categories
categories_data = [
  { name: "Bouquets", description: "Professionally arranged flower bouquets", position: 1 },
  { name: "Single Stems", description: "Individual fresh-cut stems", position: 2 },
  { name: "Arrangements", description: "Flowers in vases, ready to display", position: 3 },
  { name: "Seasonal", description: "Fresh seasonal flowers", position: 4 },
  { name: "Gift Sets", description: "Flowers bundled with gifts", position: 5 }
]

categories = {}
categories_data.each do |data|
  cat = Category.find_or_initialize_by(name: data[:name])
  cat.assign_attributes(data)
  cat.save!
  categories[data[:name]] = cat
  puts "Category: #{data[:name]}"
end

# Products
products_data = [
  {
    name: "Classic Red Roses",
    description: "A dozen premium long-stem red roses, hand-arranged with baby's breath and greenery. The timeless expression of love and affection. Perfect for anniversaries, Valentine's Day, or any romantic occasion.",
    price_cents: 4999,
    compare_at_price_cents: 6499,
    category: categories["Bouquets"],
    in_stock: true,
    featured: true,
    position: 1,
    meta_title: "Buy Classic Red Roses Online — Birds Bouquets",
    meta_description: "Order a dozen premium red roses with same-day delivery. Fresh, beautiful, guaranteed.",
    meta_keywords: "red roses, buy roses online, rose bouquet delivery"
  },
  {
    name: "Pink Garden Bouquet",
    description: "A lush, romantic mix of pink roses, garden roses, and ranunculus arranged with eucalyptus and lush greens. Perfect for birthdays, Mother's Day, or celebrating special people.",
    price_cents: 3499,
    category: categories["Bouquets"],
    in_stock: true,
    featured: true,
    position: 2,
    meta_description: "Beautiful pink garden bouquet with roses and ranunculus. Same-day delivery."
  },
  {
    name: "Sunflower Bouquet",
    description: "Bright, cheerful sunflowers to lift anyone's spirits. Features 6-8 full sunflowers with lush greenery. A little sunshine, delivered.",
    price_cents: 2999,
    category: categories["Bouquets"],
    in_stock: true,
    featured: true,
    position: 3,
    meta_description: "Fresh sunflower bouquet — the perfect gift to brighten someone's day."
  },
  {
    name: "Wildflower Mix",
    description: "A hand-gathered mix of seasonal wildflowers in a loose, garden-fresh style. Every bouquet is unique — features cosmos, zinnias, statice, and whatever's most beautiful in season.",
    price_cents: 2799,
    category: categories["Bouquets"],
    in_stock: true,
    featured: false,
    position: 4,
    meta_description: "Fresh seasonal wildflower mix — unique, garden-inspired bouquets."
  },
  {
    name: "White Lily Bouquet",
    description: "Elegant white oriental lilies arranged with lush tropical greenery. Pure, sophisticated, and wonderfully fragrant. Perfect for sympathy, celebrations, or elevating any space.",
    price_cents: 3999,
    category: categories["Bouquets"],
    in_stock: true,
    featured: false,
    position: 5,
    meta_description: "Fresh white lily bouquet — elegant and fragrant. Same-day delivery available."
  },
  {
    name: "Long-Stem Red Rose",
    description: "A single premium long-stem red rose with full foliage. Sometimes one perfect rose says everything.",
    price_cents: 799,
    category: categories["Single Stems"],
    in_stock: true,
    featured: false,
    position: 1,
    meta_description: "Buy single long-stem red roses online. Fresh, premium quality."
  },
  {
    name: "Fresh Tulips (3-pack)",
    description: "Three fresh tulips in your choice of color: red, pink, yellow, purple, or white. Simple and beautiful. Specify color preference in order notes.",
    price_cents: 1499,
    category: categories["Single Stems"],
    in_stock: true,
    featured: false,
    position: 2,
    meta_description: "Fresh tulips in multiple colors. Order online with same-day delivery."
  },
  {
    name: "Countryside Arrangement",
    description: "A mixed-flower arrangement in a rustic ceramic vase, ready to display upon arrival. Features seasonal flowers in warm tones. Vase included.",
    price_cents: 5499,
    compare_at_price_cents: 6999,
    category: categories["Arrangements"],
    in_stock: true,
    featured: true,
    position: 1,
    meta_description: "Ready-to-display countryside flower arrangement with ceramic vase."
  },
  {
    name: "Spring Tulip Collection",
    description: "A vibrant mix of seasonal spring flowers: tulips, daffodils, hyacinths, and muscari. Available while supplies last — a true celebration of spring.",
    price_cents: 3299,
    category: categories["Seasonal"],
    in_stock: true,
    featured: false,
    position: 1,
    meta_description: "Fresh spring flower collection with tulips, daffodils, and hyacinths."
  },
  {
    name: "Flowers + Vase Gift Set",
    description: "Our best-selling bouquet paired with a beautiful glass vase — everything the recipient needs to display their flowers. A complete, thoughtful gift for any occasion.",
    price_cents: 4499,
    category: categories["Gift Sets"],
    in_stock: true,
    featured: true,
    position: 1,
    meta_description: "Flowers and vase gift set — a complete, thoughtful gift for any occasion."
  }
]

products_data.each do |data|
  product = Product.find_or_initialize_by(name: data[:name])
  product.assign_attributes(data)
  product.save!
  puts "Product: #{data[:name]}"
end

# Blog posts
[
  {
    slug: "how-to-care-for-fresh-cut-flowers",
    title: "How to Care for Fresh Cut Flowers",
    body: "Fresh cut flowers can last 7-14 days with proper care.\n\nTrim stems at a 45-degree angle under running water. Place in a clean vase with cool fresh water. Keep away from direct sunlight and heat. Change water every 2 days.\n\nWith these simple steps, your Birds Bouquets flowers will look beautiful for over a week.",
    excerpt: "Keep your flowers looking beautiful for longer with these simple care tips.",
    status: "draft",
    author_name: "Birds Bouquets Team"
  },
  {
    slug: "best-flowers-for-every-occasion",
    title: "Best Flowers for Every Occasion",
    body: "Choosing the right flowers for the right moment makes all the difference.\n\nFor Romance: Red roses are classic, but pink peonies or garden roses offer a softer feel.\n\nFor Birthdays: Bright sunflowers, colorful wildflowers, or a vibrant mixed bouquet.\n\nFor Sympathy: White lilies, white roses, and soft pastels convey comfort.\n\nFor Congratulations: Bright cheerful colors — sunflowers, yellow roses, orange tulips.\n\nFor 'Just Because': Any flowers! The unexpected gesture is often most meaningful.",
    excerpt: "Our guide to choosing the perfect flowers for birthdays, anniversaries, sympathy, and more.",
    status: "draft",
    author_name: "Birds Bouquets Team"
  }
].each do |data|
  BlogPost.find_or_create_by!(slug: data[:slug]) do |post|
    post.assign_attributes(data)
  end
  puts "BlogPost: #{data[:title]}"
end

puts "\nSeeding complete!"
puts "  #{Product.count} products"
puts "  #{Category.count} categories"
puts "  #{User.count} users"
puts "  #{BlogPost.count} blog posts"
