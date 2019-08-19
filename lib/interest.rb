class Interest < ActiveRecord::Base
    has_many :user_interests
    has_many :users, through: :user_interests
    has_many :interest_events
    has_many :events, through: :interest_events
end