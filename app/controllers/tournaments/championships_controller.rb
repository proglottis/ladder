class Tournaments::ChampionshipsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :join, :remove_player]
  before_action :find_tournament
  before_action :find_championship, except: [:create]
  before_action :require_owner!, only: [:create, :update, :remove_player]

  layout 'tournament_title', only: [:show]

  def show
    @players = @championship.players.includes(:user).order('users.name ASC')
    @player = @tournament.players.active.find_by(user_id: current_user)
    @championship_player = @players.find_by(user_id: current_user)
    @matches = @championship.matches.incomplete.allocated
    @next_match = @matches.with_player(@player).first
    if @next_match
      @next_opponent = @next_match.player1 == @player ? @next_match.player2 : @next_match.player1
    end
  end

  def bracket
    @bracket = @championship.matches.
      includes({:player1 => :user}, {:player2 => :user}).
      order('matches.bracket').
      to_a.map do |match|
      {
        id: match.id,
        winners_match_id: match.winners_match_id,
        game_url: match.game_id? ? game_url(match.game_id) : nil,
        player1: {
          name: match.player1.try(:user).try(:name),
          image_url: gravatar_image_url(match.player1.try(:user).try(:email))
        },
        player2: {
          name: match.player2.try(:user).try(:name),
          image_url: gravatar_image_url(match.player2.try(:user).try(:email))
        }
      }
    end
    respond_to do |format|
      format.json { render :json => @bracket }
    end
  end

  def join
    @player = @championship.tournament.players.active.find_by!(user_id: current_user)
    @championship.championship_players.create!(player: @player)
    redirect_back fallback_location: tournament_championship_path(@tournament)
  end

  def remove_player
    championship_player = @championship.championship_players.find_by!(player_id: params[:id])
    championship_player.destroy
    redirect_to tournament_championship_path(@tournament)
  end

  def create
    @championship = @tournament.championships.build
    if @championship.save
      redirect_to tournament_championship_path(@tournament)
    else
      redirect_back fallback_location: tournament_championship_path(@tournament)
    end
  end

  def update
    unless @championship.started?
      @championship.start!
      @championship.matches.allocated.incomplete.each do |match|
        Notifications.championship_match(match.player1.user, match).deliver_now
        Notifications.championship_match(match.player2.user, match).deliver_now
      end
    end
    redirect_back fallback_location: tournament_championship_path(@tournament)
  end

  private

  def find_tournament
    if user_logged_in?
      @tournament = Tournament.participant_or_public(current_user).friendly.find(params[:tournament_id])
    else
      @tournament = Tournament.where(public: true).friendly.find(params[:tournament_id])
    end
  end

  def find_championship
    @championship = @tournament.championships.active
  end

  def require_owner!
    unless current_user.id == @tournament.owner_id
      redirect_to tournament_path(@tournament)
    end
  end
end
