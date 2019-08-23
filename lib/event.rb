class Event < ActiveRecord::Base
  has_many :interest_events
  has_many :interests, through: :interest_events
  has_many :rsvps
  has_many :users, through: :rsvps

  def assign_interest(interest_string)
    converted_id = Interest.get_id(interest_string)
    InterestEvent.find_or_create_by(interest_id: converted_id, event_id: self.id)
  end

  def assign_interests(interests_array)
    interests_array.each do |interest_string|
      self.assign_interest(interest_string)
    end
  end
end