class Admin::CustomersController < Admin::BaseController
  def index
    @customers = User.where(admin: false).order(created_at: :desc)
    @customers = @customers.where("email ILIKE ? OR name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?

    case params[:sort]
    when "spend"
      @customers = @customers.left_joins(:orders)
        .where(orders: { status: %w[paid processing shipped delivered] })
        .select("users.*, COALESCE(SUM(orders.total_cents), 0) AS lifetime_value_cents")
        .group("users.id")
        .order("lifetime_value_cents DESC")
    else
      @customers = @customers.order(created_at: :desc)
    end
  end

  def show
    @customer = User.find(params[:id])
    @orders = @customer.orders.recent
    @lifetime_value = @customer.orders.paid_orders.sum(:total_cents)
    @addresses = @customer.addresses.default_first
  end
end
