class SitemapRefreshJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("[SitemapRefreshJob] Regenerating sitemap")
    SitemapGenerator::Sitemap.create(compress: false)
    Rails.logger.info("[SitemapRefreshJob] Sitemap regenerated")
  rescue => e
    Rails.logger.error("[SitemapRefreshJob] Failed: #{e.message}")
  end
end
