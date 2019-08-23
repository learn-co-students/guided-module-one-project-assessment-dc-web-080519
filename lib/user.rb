class User < ActiveRecord::Base
  has_many :user_interests
  has_many :interests, through: :user_interests
  has_many :rsvps
  has_many :events, through: :rsvps

  def add_interest(interest)
    if !self.interests.include?(interest)
      self.interests << interest
      self.save
      self.reload
    end
end

  def remove_interest(interest_to_delete)
    self.interests.delete(interest_to_delete)
    self.save
    self.reload
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
    if !self.events.include?(event)
      self.events << event
      self.save
      self.reload
    end
end

  def remove_event(event)
    self.events.delete(event)
    self.save
    self.reload
end
end