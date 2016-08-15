module Api::V1

class ApiController < ActionController::Base

  class BadToken < StandardError; end

  before_action :authenticate_user!

  helper_method :current_user
  def current_user
    @current_user
  end

  helper_method :user_logged_in?
  def user_logged_in?
    current_user != nil
  end

  protected

  def require_user!
    authorization = request.headers['Authorization']
    raise BadToken, "Missing token" if authorization.blank?
    raw_token = authorization.split(" ").last
    token = JWT.decode(raw_token, JWT.base64url_decode(Rails.application.secrets.jwt_secret))
    @current_user = User.friendly.find(token[0]['user_id'])
  rescue BadToken, ActiveRecord::RecordNotFound, JWT::DecodeError, JWT::ExpiredSignature => e
    logger.info("Authentication failed: #{e.message}")
    render json: {message: "Unauthorized"}, status: :unauthorized
  end

  def authenticate_user!
    return if request.headers['Authorization'].blank?
    require_user!
  end
end

end
