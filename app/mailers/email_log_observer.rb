class EmailLogObserver
  LOG = "[EmailLogObserver]"

  def self.delivered_email(message)
    mailer_class = message.delivery_handler&.name || "Unknown"
    mailer_action = message["X-Mailer-Action"]&.value || "unknown"
    to_email = Array(message.to).first
    return unless to_email.present?

    user = User.find_by(email: to_email)
    body_html = message.html_part&.body&.decoded || message.body&.decoded

    EmailLog.create!(
      user: user,
      mailer_class: mailer_class,
      mailer_action: mailer_action,
      to_email: to_email,
      subject: message.subject,
      body_html: body_html
    )

    Rails.logger.info("#{LOG} Logged email | to=#{to_email} | mailer=#{mailer_class}##{mailer_action}")
  rescue => e
    Rails.logger.error("#{LOG} Failed to log email | error=#{e.message} | to=#{to_email}")
  end
end
