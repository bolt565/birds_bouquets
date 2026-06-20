class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [:show, :update_status, :add_tracking]

  def index
    @orders = Order.includes(:user, :order_items).recent

    @orders = @orders.by_status(params[:status]) if params[:status].present?
    @orders = @orders.where("email ILIKE ? OR order_number ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?

    if params[:from].present? && params[:to].present?
      from = Date.parse(params[:from]) rescue nil
      to = Date.parse(params[:to]) rescue nil
      @orders = @orders.where(created_at: from.beginning_of_day..to.end_of_day) if from && to
    end

    respond_to do |format|
      format.html
      format.csv do
        send_data generate_csv(@orders), filename: "orders-#{Date.current}.csv", type: "text/csv"
      end
    end
  end

  def show; end

  def update_status
    new_status = params[:status].to_s

    if new_status == "shipped" && params[:tracking_number].present?
      @order.update!(tracking_number: params[:tracking_number])
    end

    @order.transition_to!(new_status)

    if new_status == "shipped"
      OrderMailer.order_shipped(@order).deliver_later
    end

    flash[:notice] = "Order status updated to #{new_status}."
    redirect_to admin_order_path(@order)
  rescue Order::InvalidTransition => e
    flash[:alert] = e.message
    redirect_to admin_order_path(@order)
  end

  def add_tracking
    if params[:tracking_number].blank?
      flash[:alert] = "Tracking number cannot be blank."
    else
      @order.update!(tracking_number: params[:tracking_number])
      flash[:notice] = "Tracking number added."
    end
    redirect_to admin_order_path(@order)
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def generate_csv(orders)
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << ["Order Number", "Email", "Status", "Total", "Date"]
      orders.each do |o|
        csv << [o.order_number, o.email, o.status, o.total_in_dollars, o.created_at.strftime("%Y-%m-%d")]
      end
    end
  end
end
