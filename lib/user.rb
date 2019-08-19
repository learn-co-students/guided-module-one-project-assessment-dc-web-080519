class User < ActiveRecord::Base
    has_many :user_interests
    has_many :interests, through: :user_interests
    has_many :rsvps
    has_many :events, through: :rsvps
end