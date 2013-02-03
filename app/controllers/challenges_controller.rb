class ChallengesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_tournament_and_defender, :only => [:new, :create]

  def index
    @challenging = Challenge.active.challenging(current_user.id)
    @defending = Challenge.active.defending(current_user.id)
  end

  def new
    @challenge = @tournament.challenges.build(:challenger => current_user, :defender => @defender)
  end

  def show
    @challenge = Challenge.find(params[:id])
    @tournament = Tournament.participant(current_user).find(@challenge.tournament_id)
  end

  def create
    @challenge = @tournament.challenges.build(params.require(:challenge).permit(:message))
    @challenge.challenger = current_user
    @challenge.defender = @defender
    if @challenge.save
      Notifications.challenged(@challenge).deliver
      redirect_to challenge_path(@challenge)
    else
      render :new
    end
  end

  def update
    @challenge = Challenge.active.find(params[:id])
    @tournament = Tournament.participant(current_user).find(@challenge.tournament_id)
    if @challenge.defender == current_user
      @challenge.attributes = params.require(:challenge).permit(:response)
      @challenge.respond!
      redirect_to tournament_game_path(@tournament, @challenge.game)
    else
      redirect_to challenge_path(@challenge)
    end
  end

  private

  def find_tournament_and_defender
    @tournament = Tournament.participant(current_user).find(params[:tournament_id])
    @defender = @tournament.users.find(params[:defender_id])
  end
end
