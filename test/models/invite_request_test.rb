require "test_helper"

describe InviteRequest do
  before do
    @invite_request = InviteRequest.new
  end

  it "must be valid" do
    @invite_request.valid?.must_equal true
  end
end
