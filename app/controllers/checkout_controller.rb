class CheckoutController < ApplicationController
  layout "landing"

  before_action :ensure_cart_not_empty

  def address
    if user_signed_in?
      @addresses = current_user.addresses.default_first
      @selected_address = session[:checkout_address_id] ? current_user.addresses.find_by(id: session[:checkout_address_id]) : current_user.default_address
    end
    @address = Address.new
  end

  def set_address
    if params[:saved_address_id].present? && user_signed_in?
      address = current_user.addresses.find(params[:saved_address_id])
      session[:checkout_address] = {
        name: address.name, line1: address.line1, line2: address.line2,
        city: address.city, state: address.state, zip: address.zip,
        country: address.country, phone: address.phone
      }
      session[:checkout_address_id] = address.id
    else
      addr_params = params.require(:address).permit(:name, :line1, :line2, :city, :state, :zip, :country, :phone)
      session[:checkout_address] = addr_params.to_h
      session[:checkout_address_id] = nil

      if user_signed_in? && params[:save_address] == "1"
        current_user.addresses.create(addr_params.merge(default: current_user.addresses.empty?))
      end
    end

    redirect_to checkout_payment_path
  end

  def payment
    unless session[:checkout_address].present?
      redirect_to checkout_address_path and return
    end

    @address = session[:checkout_address]
    @items = current_cart.items
    @subtotal_cents = current_cart.total_cents
    @shipping_cents = 0
    @tax_cents = (@subtotal_cents * 0.0).to_i
    @total_cents = @subtotal_cents + @shipping_cents + @tax_cents

    intent = Stripe::PaymentIntent.create({
      amount: @total_cents,
      currency: "usd",
      metadata: { cart_item_count: current_cart.count }
    })
    @client_secret = intent.client_secret
    session[:checkout_payment_intent_id] = intent.id
  rescue Stripe::StripeError => e
    Rails.logger.error("[Checkout] Stripe error creating payment intent: #{e.message}")
    flash[:alert] = "Payment system unavailable. Please try again."
    redirect_to checkout_address_path
  end

  def confirm
    payment_intent_id = session[:checkout_payment_intent_id]
    address = session[:checkout_address]

    unless payment_intent_id && address
      redirect_to checkout_address_path and return
    end

    intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

    unless intent.status == "succeeded"
      flash[:alert] = "Payment was not completed. Please try again."
      redirect_to checkout_payment_path and return
    end

    items = current_cart.items
    subtotal_cents = current_cart.total_cents
    total_cents = subtotal_cents

    order = Order.create!(
      user: current_user,
      email: current_user&.email || params[:email],
      subtotal_cents: subtotal_cents,
      total_cents: total_cents,
      shipping_cents: 0,
      tax_cents: 0,
      stripe_payment_intent_id: payment_intent_id,
      status: "paid",
      paid_at: Time.current,
      shipping_name: address["name"],
      shipping_line1: address["line1"],
      shipping_line2: address["line2"],
      shipping_city: address["city"],
      shipping_state: address["state"],
      shipping_zip: address["zip"],
      shipping_country: address["country"] || "US"
    )

    items.each do |item|
      order.order_items.create!(
        product: item[:product],
        quantity: item[:quantity],
        unit_price_cents: item[:unit_price_cents],
        product_name: item[:product].name
      )
    end

    SendOrderNotificationJob.perform_later(order.id)

    current_cart.clear
    session.delete(:checkout_address)
    session.delete(:checkout_address_id)
    session.delete(:checkout_payment_intent_id)
    session[:last_order_id] = order.id

    redirect_to checkout_success_path
  rescue Stripe::StripeError => e
    Rails.logger.error("[Checkout] Stripe error confirming payment: #{e.message}")
    flash[:alert] = "Payment verification failed. Please contact support."
    redirect_to checkout_payment_path
  end

  def success
    @order = Order.find_by(id: session[:last_order_id])
  end

  private

  def ensure_cart_not_empty
    return if action_name == "success"
    if current_cart.empty?
      flash[:alert] = "Your cart is empty."
      redirect_to products_path
    end
  end
end
