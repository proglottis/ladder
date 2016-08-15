module Api::V1
class PushNotificationKeysController < ApiController
  before_action :require_user!

  def create
    @push_notification = current_user.push_notification_keys.find_or_initialize_by(gcm: params[:gcm])
    if @push_notification.save
      render json: @push_notification
    else
      render json: {message: "Bad request"}, status: :bad_request
    end
  end
end
end
