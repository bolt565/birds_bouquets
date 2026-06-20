class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      session["devise.google_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  rescue => e
    Rails.logger.error("[OmniAuth] Google OAuth error: #{e.message}")
    redirect_to new_user_session_path, alert: "Google sign-in failed. Please try again."
  end

  def failure
    redirect_to root_path, alert: "Authentication failed."
  end
end
