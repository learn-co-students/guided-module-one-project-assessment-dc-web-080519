class User < ActiveRecord::Base
  has_many :user_interests
  has_many :interests, through: :user_interests
  has_many :rsvps
  has_many :events, through: :rsvps

  def display_profile
    puts "username: #{self.user_name}"
    puts "Name: #{self.name}"
    puts "Location: #{self.location}"
    puts "Interests:"
    self.display_interests
  end

  def input_to_index
    input = gets.chomp
    index = input.to_i - 1
  end

  def list_array(arr)
    arr.each_with_index do |item, index|
      puts "#{index + 1}. #{item.name}"
    end
  end

  def add_interest
    # save array of possible new interests to variable
    possible_interests = Interest.all - self.interests
    # display list of possible interests
    puts "Please select an interest to add to your profile:"
    self.list_array(possible_interests)
    # user selects index of interest to add & is converted to array index
    index = self.input_to_index
    # User instance updated in Ruby
    self.interests << possible_interests[index]
    self.save
  end

  def display_interests
    self.list_array(self.interests)
  end

  def remove_interest
    # prompt user
    puts "Please enter number of interest to remove"
    # display interests
    self.display_interests
    # get user input and convert to array index of user's interests
    index = self.input_to_index
    # save the interest instance to remove as a variable
    remove = self.interests[index]
    # delete saved interest instance and remove its associations
    self.interests.delete(remove)
    puts "#{remove.name} was removed from your interests."
  end

  def find_events
    # compare user interests against events' interests
    matching_events = Event.all.find_all do |event|
      # return any Events with overlapping Interests
      !(self.interests & event.interests).empty?
    end
    # print a list of matching events for the user
    self.list_array(matching_events)
    puts ""
    puts "Please select an event to see more details on."
    index = self.input_to_index
    matching_events[index].display_details
  end
end