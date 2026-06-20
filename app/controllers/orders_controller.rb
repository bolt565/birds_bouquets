class OrdersController < ApplicationController
  layout "landing"

  before_action :require_login!, only: [:index, :show]

  def index
    @orders = current_user.orders.recent
  end

  def show
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Order not found."
    redirect_to orders_path
  end

  def lookup
    # GET — show the lookup form
  end

  def find
    email = params[:email].to_s.strip.downcase
    order_number = params[:order_number].to_s.strip.upcase

    @order = Order.find_by(email: email, order_number: order_number)

    if @order
      render :show
    else
      flash.now[:alert] = "No order found matching that email and order number."
      render :lookup
    end
  end
end
