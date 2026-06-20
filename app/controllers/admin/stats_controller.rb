class Admin::StatsController < Admin::BaseController
  RANGES = { "1d" => 1, "7d" => 7, "30d" => 30, "90d" => 90 }.freeze

  def show
    @days = RANGES.fetch(params[:range], 30)
    @active_range = "#{@days}d"
    @service = Admin::StatsService.new(days: @days)
    @overview = @service.overview
    @traffic = @service.traffic
    @daily_visits = @service.daily_visits
    @top_pages = @service.top_pages
    @top_referrers = @service.top_referrers
    @utm_sources = @service.utm_sources
    @utm_campaigns = @service.utm_campaigns
    @utm_mediums = @service.utm_mediums
    @orders_by_status = @service.orders_by_status
    @recent_signups = @service.recent_signups

    Rails.logger.info("[Admin::Stats] Viewed | user=#{current_user.id} | range=#{@active_range}")
  end
end
