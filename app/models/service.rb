class Service < ApplicationRecord
  belongs_to :user

  def self.anonymize
    find_each do |service|
      service.anonymize
    end
  end

  def anonymize
    update_attributes! :name => "User #{id}", :email => "user_#{id}@example.com", :provider => 'developer', :uid => "user_#{id}@example.com", :first_name => nil, :last_name => nil, :image_url => nil
  end
end
