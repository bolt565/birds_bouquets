Rails.application.configure do
  config.good_job.execution_mode = :external
  config.good_job.max_threads = 5
  config.good_job.queues = "critical:1;mailers:2;default:3;cleanup:1"
  config.good_job.enable_cron = true
  config.good_job.retry_on_unhandled_error = false
  config.good_job.shutdown_timeout = 25

  config.good_job.cron = {
    daily_order_digest: {
      cron: "0 13 * * *",
      class: "DailyOrderDigestJob",
      key: "DailyOrderDigestJob",
      description: "Send daily order digest to admin (8 AM CT)"
    },
    cleanup_expired_carts: {
      cron: "0 8 * * *",
      class: "CleanupExpiredCartsJob",
      key: "CleanupExpiredCartsJob",
      description: "Nightly cart cleanup (3 AM CT)"
    },
    sitemap_refresh: {
      cron: "0 7 * * 0",
      class: "SitemapRefreshJob",
      key: "SitemapRefreshJob",
      description: "Weekly sitemap regeneration (Sunday 2 AM CT)"
    }
  }
end
