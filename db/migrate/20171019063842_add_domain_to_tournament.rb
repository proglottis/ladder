class AddDomainToTournament < ActiveRecord::Migration[5.1]
  def change
    add_column :tournaments, :domain, :string
  end
end
