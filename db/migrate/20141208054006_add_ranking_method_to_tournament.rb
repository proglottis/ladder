class AddRankingMethodToTournament < ActiveRecord::Migration
  def change
    add_column :tournaments, :ranking_type, :string, null: false, default: Tournament::DEFAULT_RANKING_TYPE.to_s
  end
end
