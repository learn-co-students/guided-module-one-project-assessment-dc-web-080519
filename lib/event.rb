class Event < ActiveRecord::Base
    has_many :interest_events
    has_many :interests, through: :interest_events
    has_many :rsvps
    has_many :users, through: :rsvps
end