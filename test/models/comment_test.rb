require "test_helper"

describe Comment do
  before do
    @comment = Comment.new
  end

  it "must be valid" do
    @comment.valid?.must_equal true
  end
end
