require 'test_helper'

describe ChampionshipPlayer do

  describe "create" do
    before do
      @championship = create(:championship)
      @championship_player = build(:championship_player, championship: @championship)
    end

    it "validates that the championship is not started" do
      @championship.update_attributes!(started_at: Time.zone.now)
      @championship_player.valid?.must_equal false
      @championship.update_attributes!(started_at: nil)
      @championship_player.save!
      @championship.update_attributes!(started_at: Time.zone.now)
      @championship_player.reload
      @championship_player.valid?.must_equal true
    end
  end
end
