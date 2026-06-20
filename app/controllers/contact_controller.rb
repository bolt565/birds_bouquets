class ContactController < ApplicationController
  layout "landing"

  def new
    seo_meta(
      title: "Contact Us — Birds Bouquets",
      description: "Get in touch with the Birds Bouquets team. We're here to help with your flower orders and questions.",
      url: contact_url
    )
  end

  def create
    name = params[:name].to_s.strip
    email = params[:email].to_s.strip
    message = params[:message].to_s.strip

    if name.blank? || email.blank? || message.blank?
      flash.now[:alert] = "Please fill in all fields."
      render :new and return
    end

    ContactMailer.contact_message(name: name, email: email, message: message).deliver_later

    flash[:notice] = "Thank you! We'll get back to you within 1 business day."
    redirect_to contact_path
  end
end
