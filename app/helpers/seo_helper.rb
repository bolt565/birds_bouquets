module SeoHelper
  SITE_NAME = "Bird's Blossoms".freeze
  BASE_URL = ENV.fetch("APP_HOST", "https://birdsbouquets.com").freeze
  DEFAULT_DESCRIPTION = "Bird's Blossoms — fresh flower delivery. Shop beautiful bouquets and arrangements online with fast delivery.".freeze

  def seo_meta(title:, description:, url:, image: nil, keywords: nil)
    @seo_title = title
    @seo_description = description
    @seo_canonical_url = url
    @seo_og_image = image || "#{BASE_URL}/og-default.jpg"
    @seo_keywords = keywords
  end

  def organization_structured_data
    data = {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => SITE_NAME,
      "url" => BASE_URL,
      "logo" => "#{BASE_URL}/logo.png",
      "description" => DEFAULT_DESCRIPTION,
      "contactPoint" => {
        "@type" => "ContactPoint",
        "contactType" => "customer support",
        "url" => "#{BASE_URL}/contact"
      }
    }
    push_structured_data(data)
  end

  def local_business_structured_data
    data = {
      "@context" => "https://schema.org",
      "@type" => "Florist",
      "name" => SITE_NAME,
      "url" => BASE_URL,
      "description" => DEFAULT_DESCRIPTION,
      "image" => "#{BASE_URL}/og-default.jpg",
      "priceRange" => "$$",
      "openingHours" => "Mo-Su 00:00-24:00",
      "hasMap" => BASE_URL
    }
    push_structured_data(data)
  end

  def product_structured_data(product)
    data = {
      "@context" => "https://schema.org",
      "@type" => "Product",
      "name" => product.name,
      "description" => product.description,
      "url" => "#{BASE_URL}/products/#{product.slug}",
      "offers" => {
        "@type" => "Offer",
        "price" => format("%.2f", product.price_cents / 100.0),
        "priceCurrency" => "USD",
        "availability" => product.in_stock? ? "https://schema.org/InStock" : "https://schema.org/OutOfStock"
      }
    }
    push_structured_data(data)
  end

  def faq_structured_data(faqs)
    data = {
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => faqs.map do |faq|
        {
          "@type" => "Question",
          "name" => faq[:question],
          "acceptedAnswer" => { "@type" => "Answer", "text" => faq[:answer] }
        }
      end
    }
    push_structured_data(data)
  end

  def breadcrumb_structured_data(items)
    data = {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => items.each_with_index.map do |item, i|
        element = { "@type" => "ListItem", "position" => i + 1, "name" => item[:name] }
        element["item"] = item[:url] if item[:url].present?
        element
      end
    }
    push_structured_data(data)
  end

  def article_structured_data(post)
    data = {
      "@context" => "https://schema.org",
      "@type" => "Article",
      "headline" => post.title,
      "description" => post.excerpt || post.body.truncate(200),
      "url" => "#{BASE_URL}/blog/#{post.slug}",
      "author" => { "@type" => "Person", "name" => post.author_name || SITE_NAME },
      "publisher" => { "@type" => "Organization", "name" => SITE_NAME, "url" => BASE_URL },
      "datePublished" => post.published_at&.iso8601,
      "dateModified" => post.updated_at.iso8601
    }
    push_structured_data(data)
  end

  def render_structured_data
    return "" if @structured_data_scripts.blank?
    @structured_data_scripts.map do |data|
      "<script type=\"application/ld+json\">#{data.to_json}</script>"
    end.join("\n").html_safe
  end

  private

  def push_structured_data(data)
    @structured_data_scripts ||= []
    @structured_data_scripts << data
  end
end
