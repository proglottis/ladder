class Comment < ApplicationRecord
  MAX_LENGTH = 500

  belongs_to :user
  belongs_to :commentable, polymorphic: true, touch: true

  validates_length_of :content, :maximum => MAX_LENGTH
end
