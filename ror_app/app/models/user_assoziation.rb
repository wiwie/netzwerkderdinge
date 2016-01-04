class UserAssoziation < ActiveRecord::Base
  belongs_to :user
  belongs_to :assoziation
end
