SitemapGenerator::Sitemap.default_host = ENV.fetch("APP_HOST", "https://birdsbouquets.com")
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  add "/", changefreq: "daily", priority: 1.0
  add "/products", changefreq: "daily", priority: 0.9
  add "/about", changefreq: "monthly", priority: 0.6
  add "/faq", changefreq: "monthly", priority: 0.7
  add "/contact", changefreq: "yearly", priority: 0.4
  add "/blog", changefreq: "weekly", priority: 0.7
  add "/orders/lookup", changefreq: "yearly", priority: 0.4

  Product.in_stock.find_each do |product|
    add "/products/#{product.slug}", lastmod: product.updated_at, changefreq: "weekly", priority: 0.8
  end

  Category.active.find_each do |category|
    add "/products?category=#{category.slug}", changefreq: "weekly", priority: 0.7
  end

  BlogPost.published.find_each do |post|
    add "/blog/#{post.slug}", lastmod: post.updated_at, changefreq: "monthly", priority: 0.6
  end
end
