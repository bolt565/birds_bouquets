class PagesController < ApplicationController
  layout "landing"

  def home
    @featured_products = Product.in_stock.featured.ordered.limit(6)
    @categories = Category.active.ordered

    seo_meta(
      title: "Fresh Flower Delivery | Birds Bouquets",
      description: "Buy beautiful fresh flowers online. Birds Bouquets delivers stunning flower bouquets and arrangements right to your door. Shop fresh flower delivery today.",
      url: root_url,
      keywords: "buy flowers online, fresh flower delivery, flower bouquets, flower arrangements"
    )

    organization_structured_data
    local_business_structured_data
  end

  def faq
    @faqs = [
      { question: "How fresh are your flowers?", answer: "All our flowers are sourced fresh daily from local and regional growers. We guarantee your bouquet will stay fresh for at least 7 days with proper care." },
      { question: "When will my order be delivered?", answer: "We offer same-day delivery for orders placed before 12 PM in your local time. Next-day delivery is available for all orders." },
      { question: "Do you deliver to my area?", answer: "We currently deliver throughout the continental United States. Enter your zip code at checkout to confirm delivery availability." },
      { question: "Can I send flowers as a gift?", answer: "Absolutely! You can ship to any address. Simply enter the recipient's address at checkout and add a personal note for free." },
      { question: "What if my flowers arrive damaged?", answer: "We stand behind the quality of our flowers. If your order arrives damaged or doesn't meet your expectations, contact us within 24 hours and we'll make it right." },
      { question: "How do I care for my flowers?", answer: "Cut the stems at an angle under water, place in a clean vase with fresh water, and keep away from direct sunlight and heat. Change the water every 2 days." },
      { question: "Can I cancel or change my order?", answer: "Orders can be cancelled or modified up to 2 hours after placing them. After that, we begin preparing your arrangement. Contact us immediately if you need to make changes." },
      { question: "Do you offer subscriptions?", answer: "Flower subscription boxes are coming soon! Sign up for our newsletter to be the first to know when we launch." },
      { question: "What payment methods do you accept?", answer: "We accept all major credit cards (Visa, Mastercard, American Express, Discover) through our secure Stripe payment system." },
      { question: "Is my payment information secure?", answer: "Yes. All payments are processed securely through Stripe. We never store your credit card information on our servers." }
    ]

    seo_meta(
      title: "FAQ — Birds Bouquets",
      description: "Answers to frequently asked questions about ordering flowers from Birds Bouquets. Learn about delivery, freshness, care, and more.",
      url: faq_url
    )

    faq_structured_data(@faqs)
  end

  def about
    seo_meta(
      title: "About Us — Birds Bouquets",
      description: "Learn about Birds Bouquets — our mission to bring beautiful, fresh flowers to every doorstep. Quality blooms, exceptional service.",
      url: about_url
    )
  end
end
