class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end

  helper_method :user_logged_in?
  def user_logged_in?
    current_user != nil
  end

  helper_method :gravatar_image_url
  def gravatar_image_url(email, size = 16)
    return nil unless email
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon"
  end

  private

  def authenticate_user!
    unless user_logged_in?
      session[:redirect] = request.fullpath
      redirect_to session_path, :notice => t('sessions.authentication_required')
    end
  end

end
