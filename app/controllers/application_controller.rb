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

end
