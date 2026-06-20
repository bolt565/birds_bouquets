class LegalController < ApplicationController
  layout "landing"

  def privacy
    seo_meta(title: "Privacy Policy — Birds Bouquets", description: "Birds Bouquets privacy policy.", url: privacy_url)
  end

  def terms
    seo_meta(title: "Terms of Service — Birds Bouquets", description: "Birds Bouquets terms of service.", url: terms_url)
  end

  def returns
    seo_meta(title: "Return Policy — Birds Bouquets", description: "Birds Bouquets return and refund policy.", url: returns_url)
  end
end
