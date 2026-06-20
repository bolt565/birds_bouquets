class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def after_sign_up_path_for(resource)
    AdminMailer.new_signup(resource).deliver_later
    root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone, :avatar_url])
  end
end
