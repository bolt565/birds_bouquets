require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["STRIPE_WEBHOOK_SECRET"] ||= "whsec_test_secret"
  end

  test "returns 400 for invalid signature" do
    post stripe_webhooks_path,
      params: '{"type":"payment_intent.succeeded"}',
      headers: {
        "Content-Type" => "application/json",
        "Stripe-Signature" => "t=1,v1=invalid"
      }
    assert_response :bad_request
  end

  test "returns 200 for valid constructed event" do
    payload = '{"id":"evt_test","type":"payment_intent.payment_failed","data":{"object":{"id":"pi_test"}}}'
    timestamp = Time.now.to_i.to_s
    signature = "t=#{timestamp},v1=#{OpenSSL::HMAC.hexdigest('SHA256', ENV['STRIPE_WEBHOOK_SECRET'], "#{timestamp}.#{payload}")}"

    post stripe_webhooks_path,
      params: payload,
      headers: {
        "Content-Type" => "application/json",
        "Stripe-Signature" => signature
      }
    assert_response :success
  end
end
