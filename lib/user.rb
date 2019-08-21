class User < ActiveRecord::Base
  has_many :user_interests
  has_many :interests, through: :user_interests
  has_many :rsvps
  has_many :events, through: :rsvps

  def add_interest(interest)
    self.interests << interest
  end

  def remove_interest(interest_to_delete)
    self.interests.delete(interest_to_delete)
    self.save

  end

  def matching_events
    # compare user interests against events' interests
    Event.all.find_all do |event|
      # return any Events with overlapping Interests
      !(self.interests & event.interests).empty?
    end.find_all do |events_by_interest|
      events_by_interest.location == self.location
    end
  end

  def rsvp_to(event)
    self.events << event
    self.save
  end

  def remove_event(event)
    self.events.delete(event)
    self.save
  end
end