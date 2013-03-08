class SettingsController < ApplicationController
  def show
    @user = current_user
    @services = current_user.services
  end
end
