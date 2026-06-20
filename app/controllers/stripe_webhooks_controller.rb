class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :track_visitor

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV.fetch("STRIPE_WEBHOOK_SECRET")
      )
    rescue JSON::ParserError
      Rails.logger.error("[StripeWebhook] Invalid JSON payload")
      render json: { error: "Invalid payload" }, status: :bad_request and return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("[StripeWebhook] Invalid signature: #{e.message}")
      render json: { error: "Invalid signature" }, status: :bad_request and return
    end

    Rails.logger.info("[StripeWebhook] Received event: #{event.type} | id=#{event.id}")

    case event.type
    when "payment_intent.succeeded"
      handle_payment_succeeded(event.data.object)
    when "payment_intent.payment_failed"
      handle_payment_failed(event.data.object)
    end

    render json: { received: true }
  end

  private

  def handle_payment_succeeded(payment_intent)
    order = Order.find_by(stripe_payment_intent_id: payment_intent.id)
    unless order
      Rails.logger.warn("[StripeWebhook] No order found for payment_intent #{payment_intent.id}")
      return
    end

    return if order.status == "paid"

    order.update!(
      status: "paid",
      paid_at: Time.current,
      stripe_charge_id: payment_intent.latest_charge
    )

    Rails.logger.info("[StripeWebhook] Order #{order.order_number} marked as paid")
    SendOrderNotificationJob.perform_later(order.id)
  end

  def handle_payment_failed(payment_intent)
    order = Order.find_by(stripe_payment_intent_id: payment_intent.id)
    return unless order

    Rails.logger.warn("[StripeWebhook] Payment failed for order #{order.order_number}")
  end
end
