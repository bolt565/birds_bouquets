class ApplicationMailer < ActionMailer::Base
  default from: "Birds Bouquets <hello@birdsbouquets.com>"
  layout "mailer"
  helper :application

  after_action :set_mailer_headers

  private

  def set_mailer_headers
    headers["X-Mailer-Action"] = action_name
  end
end
