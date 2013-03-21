class SettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user_and_services

  def show
  end

  def update
    if @user.update_attributes(params.require(:user).permit(:game_confirmed_email))
      redirect_to setting_path, :notice => I18n.t('settings.update.updated')
    else
      render :show
    end
  end

  private

  def find_user_and_services
    @user = current_user
    @services = current_user.services
  end
end
