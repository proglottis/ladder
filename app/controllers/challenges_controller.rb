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
    @tournament = Tournament.with_rated_user(current_user).find(@challenge.tournament_id)
    @game = @challenge.game
    @comments = @challenge.comments
  end

  def create
    @challenge = @tournament.challenges.build params.require(:challenge).permit(:comment)
    @challenge.challenger = current_user
    @challenge.defender = @defender
    if @challenge.save
      CommentService.new(current_user).comment(@challenge, @challenge.comment)
      Notifications.challenged(@challenge).deliver
      redirect_to challenge_path(@challenge)
    else
      render :new
    end
  end

  def update
    @challenge = Challenge.active.find(params[:id])
    @challenge.attributes = params.require(:challenge).permit(:response, :comment)
    @tournament = Tournament.with_rated_user(current_user).find(@challenge.tournament_id)
    CommentService.new(current_user).comment(@challenge, @challenge.comment, @challenge.participants)
    if params.has_key?(:respond) && @challenge.defender == current_user
      @challenge.respond!
      redirect_to game_path(@challenge.game)
    else
      redirect_to challenge_path(@challenge)
    end
  end

  private

  def find_tournament_and_defender
    @tournament = Tournament.with_rated_user(current_user).friendly.find(params[:tournament_id])
    @defender = @tournament.users.friendly.find(params[:defender_id])
  end
end
