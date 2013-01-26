class ProfilesController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = User.find(params[:id])
    @games = Kaminari.paginate_array((Game.with_participant(current_user) & Game.with_participant(@user)).sort_by{|u| Time.zone.now - u.updated_at}).page(params[:page]).per(10)
  end
end
