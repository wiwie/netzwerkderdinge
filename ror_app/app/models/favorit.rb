class Favorit < ActiveRecord::Base
  belongs_to :ding
  belongs_to :user
end
