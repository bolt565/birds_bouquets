class ContactMailer < ApplicationMailer
  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL", "admin@birdsbouquets.com")

  def contact_message(name:, email:, message:)
    @name = name
    @email = email
    @message = message
    mail(to: ADMIN_EMAIL, reply_to: email, subject: "Contact Form: #{name}")
  end
end
