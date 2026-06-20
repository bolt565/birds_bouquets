class Rack::Attack
  # Throttle requests per IP
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Throttle POST to login by email
  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params["user"]["email"].to_s.downcase.gsub(/\s+/, "").presence
    end
  end

  # Throttle Stripe webhooks
  throttle("stripe/webhooks", limit: 60, period: 1.minute) do |req|
    req.ip if req.path == "/stripe/webhooks"
  end

  # Block suspicious paths
  blocklist("block bots probing for admin panels") do |req|
    req.path =~ /\.(php|asp|aspx|jsp)$/i
  end

  Rack::Attack.throttled_responder = lambda do |request|
    [429, { "Content-Type" => "application/json" }, [{ error: "Too many requests" }.to_json]]
  end
end
