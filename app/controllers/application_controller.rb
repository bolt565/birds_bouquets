class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  include SeoHelper

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :track_visitor

  helper_method :current_cart, :cart_count

  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found unless Rails.env.development?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def require_login!
    unless user_signed_in?
      flash[:alert] = "Please sign in to continue."
      redirect_to new_user_session_path
    end
  end

  def require_admin!
    unless user_signed_in?
      flash[:alert] = "Please sign in to continue."
      redirect_to new_user_session_path and return
    end
    unless current_user.admin?
      flash[:alert] = "Access denied."
      redirect_to root_path
    end
  end

  def current_cart
    @current_cart ||= CartService.new(session)
  end

  def cart_count
    current_cart.count
  end

  def track_visitor
    return if devise_controller?
    store_utm_in_session if params[:utm_source].present?

    PageVisit.create!(
      user: current_user,
      landing_url: request.original_url,
      referring_url: request.referer,
      utm_source: session[:utm_source],
      utm_medium: session[:utm_medium],
      utm_campaign: session[:utm_campaign],
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  rescue => e
    Rails.logger.warn("[PageVisit] Failed to record: #{e.message}")
  end

  def store_utm_in_session
    session[:utm_source] = params[:utm_source] if params[:utm_source].present?
    session[:utm_medium] = params[:utm_medium] if params[:utm_medium].present?
    session[:utm_campaign] = params[:utm_campaign] if params[:utm_campaign].present?
  end

  def handle_not_found
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end
end
