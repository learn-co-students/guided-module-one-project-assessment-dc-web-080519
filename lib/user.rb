class User < ActiveRecord::Base
  has_many :user_interests
  has_many :interests, through: :user_interests
  has_many :rsvps
  has_many :events, through: :rsvps

  def add_interest(interest)
    self.interests << interest
  end

  def remove_interest(interest_to_delete)
  #   # prompt user
  #   puts "Please enter number of interest to remove"
  #   # display interests
  #   self.display_interests
  #   # get user input and convert to array index of user's interests
  #   index = self.input_to_index
  #   # save the interest instance to remove as a variable
  #   remove = self.interests[index]
  #   # delete saved interest instance and remove its associations
  #   self.interests.delete(remove)
  #   puts "#{remove.name} was removed from your interests."
    self.interests.delete(interest_to_delete)
    self.save
    
  end

  def find_events
    # compare user interests against events' interests
    interested_events = Event.all.find_all do |event|
      # return any Events with overlapping Interests
      !(self.interests & event.interests).empty?
    end
    # print a list of matching events for the user
    # TODO: further filter list of interested events by user location
    self.list_array(interested_events)
    puts ""
    puts "Please select an event to see more details on."
    index = self.input_to_index
    interested_events[index].display_details
  end

  def rsvp_to(event)
    self.events << event
  end

  def view_rsvps
    self.list_array(self.events)
  end
end