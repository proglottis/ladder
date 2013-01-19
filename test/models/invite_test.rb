require "minitest_helper"

describe Invite do
  describe ".create" do
    before do
      @user = create(:user)
      @tournament = create(:tournament)
      @invites = create_list(:invite, 10, :owner => @user, :tournament => @tournament)
    end

    it "must only allow owner to have a limited number for a tournament" do
      @invite = @tournament.invites.create(attributes_for(:invite).merge(:owner => @user))
      @invite.errors.size.must_equal 1
    end

    it "wont limited number of expired for a tournament" do
      Invite.update_all :expires_at => 1.day.ago
      @invite = @tournament.invites.create(attributes_for(:invite).merge(:owner => @user))
      @invite.errors.size.must_equal 0
    end
  end

  describe ".available" do
    before do
      @invite = create(:invite)
    end

    it "must match when available" do
      Invite.available.must_include @invite
    end

    it "wont match when expired" do
      @invite.update_attribute(:expires_at, 1.day.ago)
      Invite.available.wont_include @invite
    end

    it "wont match when accepted" do
      @invite.update_attribute(:user, create(:user))
      Invite.available.wont_include @invite
    end
  end

  describe "#code" do
    it "must be generated on save when blank" do
      create(:tournament).invites.create!(:email => "test@example.com", :owner => create(:user)).code.wont_be_nil
    end
  end

  describe "#expires_at" do
    it "must be generated on save when blank" do
      create(:tournament).invites.create!(:email => "test@example.com", :owner => create(:user)).expires_at.wont_be_nil
    end
  end

  describe "#to_param" do
    it "must use code" do
      build(:invite, :code => "my_code").to_param.must_equal "my_code"
    end
  end
end
