class Account::DashboardController < ApplicationController
  before_action :require_login!

  def index
    @recent_orders = current_user.orders.recent.limit(5)
    @addresses = current_user.addresses.default_first
  end
end
