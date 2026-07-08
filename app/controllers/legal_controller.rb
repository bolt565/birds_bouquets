class LegalController < ApplicationController
  layout "landing"

  def privacy
    seo_meta(title: "Privacy Policy — Bird's Blossoms", description: "Bird's Blossoms privacy policy.", url: privacy_url)
  end

  def terms
    seo_meta(title: "Terms of Service — Bird's Blossoms", description: "Bird's Blossoms terms of service.", url: terms_url)
  end

  def returns
    seo_meta(title: "Return Policy — Bird's Blossoms", description: "Bird's Blossoms return and refund policy.", url: returns_url)
  end
end
