class HomesController < ApplicationController
  def show
    @public_tournaments = Tournament.where(public: true).order('tournaments.name ASC')
  end
end
