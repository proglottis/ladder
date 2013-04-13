class Api::UsersController < Api::BaseController
  def show
    respond_with User.find(params[:id])
  end
end
