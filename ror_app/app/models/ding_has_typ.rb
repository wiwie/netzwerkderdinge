class DingHasTyp < ActiveRecord::Base
  belongs_to :ding
  belongs_to :ding_typ
  belongs_to :user
end
