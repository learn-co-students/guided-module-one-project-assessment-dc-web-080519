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

  def add_interest
    # save array of possible new interests to variable
    possible_interests = Interest.all - self.interests
    # display list of possible interests
    puts "Please select an interest to add to your profile:"
    possible_interests.each_with_index do |interest, index|
      puts "#{index + 1}. #{interest.name}"
    end
    # user selects index of interest to add & is converted to array index
    input = gets.chomp
    index = input.to_i - 1
    # User instance updated in Ruby
    self.interests << possible_interests[index]
  end

  def display_interests
    self.interests.each_with_index do |interest, index|
      puts "#{index + 1}. #{interest.name}"
    end
  end

  def remove_interest
    # prompt user
    puts "Please enter number of interest to remove"
    # display interests
    self.display_interests
    # get user input and convert to array index of user's interests
    input = gets.chomp
    index = input.to_i - 1
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
    matching_events.each_with_index do |event, index|
      puts "#{index + 1}. #{event.name}"
    end
    puts ""
    puts "Please select an event to see more details on."
    input = gets.chomp
    index = input.to_i - 1
    matching_events[index].display_details
  end
end