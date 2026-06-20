module Admin
  class StatsService
    TIMEZONE = "Central Time (US & Canada)"

    def initialize(days: 30)
      @days = days
      @zone = ActiveSupport::TimeZone[TIMEZONE]
      @since = days.days.ago
      @today_start = Time.current.in_time_zone(@zone).beginning_of_day.utc
    end

    # ── Overview Metrics ──

    def overview
      @overview ||= {
        total_users: User.count,
        new_users_today: User.where("created_at >= ?", @today_start).count,
        new_users_period: User.where("created_at >= ?", @since).count,
        total_orders: Order.count,
        orders_today: Order.where("created_at >= ?", @today_start).count,
        orders_period: Order.where("created_at >= ?", @since).count,
        revenue_today_cents: Order.where(status: "paid").where("paid_at >= ?", @today_start).sum(:total_cents),
        revenue_period_cents: Order.where(status: "paid").where("paid_at >= ?", @since).sum(:total_cents),
        total_revenue_cents: Order.where(status: "paid").sum(:total_cents),
        total_visits: PageVisit.count,
        visits_today: PageVisit.where("created_at >= ?", @today_start).count,
        visits_period: PageVisit.where("created_at >= ?", @since).count,
        guest_visits_period: PageVisit.where("created_at >= ?", @since).where(user_id: nil).count,
        logged_in_visits_period: PageVisit.where("created_at >= ?", @since).where.not(user_id: nil).count,
        unique_ips_period: PageVisit.where("created_at >= ?", @since).distinct.count(:ip_address),
        total_emails_sent: EmailLog.count
      }
    end

    # ── Traffic Metrics ──

    def traffic
      @traffic ||= {
        total_visits: PageVisit.where("created_at >= ?", @since).count,
        anonymous_visits: PageVisit.where("created_at >= ?", @since).where(user_id: nil).count,
        with_referrer: PageVisit.where("created_at >= ?", @since).where.not(referring_url: [nil, ""]).count,
        with_utm: PageVisit.where("created_at >= ?", @since).where.not(utm_source: [nil, ""]).count,
        unique_ips: PageVisit.where("created_at >= ?", @since).distinct.count(:ip_address)
      }
    end

    # ── Daily Visits (for chart) ──

    def daily_visits(days: nil)
      n = days || @days
      (0...n).map do |i|
        day = i.days.ago.in_time_zone(@zone)
        start = day.beginning_of_day.utc
        finish = day.end_of_day.utc
        count = PageVisit.where(created_at: start..finish).count
        { date: day.strftime("%b %d"), count: count }
      end.reverse
    end

    # ── Top Pages ──

    def top_pages(limit: 15)
      PageVisit.where("created_at >= ?", @since)
               .group(:landing_url)
               .order("count_all DESC")
               .limit(limit)
               .count
    end

    # ── Top Referrer Domains ──

    def top_referrers(limit: 10)
      PageVisit.where("created_at >= ?", @since)
               .where.not(referring_url: [nil, ""])
               .group(:referring_url)
               .order("count_all DESC")
               .limit(limit)
               .count
               .transform_keys { |url| extract_domain(url) }
               .group_by { |k, _| k }
               .transform_values { |pairs| pairs.sum { |_, v| v } }
               .sort_by { |_, v| -v }
               .first(limit)
               .to_h
    end

    # ── UTM Breakdowns ──

    def utm_sources(limit: 10)
      PageVisit.where("created_at >= ?", @since)
               .where.not(utm_source: [nil, ""])
               .group(:utm_source)
               .order("count_all DESC")
               .limit(limit)
               .count
    end

    def utm_campaigns(limit: 10)
      PageVisit.where("created_at >= ?", @since)
               .where.not(utm_campaign: [nil, ""])
               .group(:utm_campaign)
               .order("count_all DESC")
               .limit(limit)
               .count
    end

    def utm_mediums(limit: 10)
      PageVisit.where("created_at >= ?", @since)
               .where.not(utm_medium: [nil, ""])
               .group(:utm_medium)
               .order("count_all DESC")
               .limit(limit)
               .count
    end

    # ── Orders by Status ──

    def orders_by_status
      Order.group(:status).count
    end

    # ── Recent Signups ──

    def recent_signups(limit: 10)
      User.order(created_at: :desc).limit(limit)
    end

    private

    def extract_domain(url)
      uri = URI.parse(url)
      uri.host&.sub(/\Awww\./, "") || url
    rescue URI::InvalidURIError
      url.truncate(40)
    end
  end
end
