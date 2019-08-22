class CommandLineInterface
  attr_accessor :user
  PROMPT = TTY::Prompt.new

  ###############################################################################
  ##### HELPER METHODS ##########################################################
  ###############################################################################

  # create new CLI instance and call #welcome on this new run
  def self.runner
    new_run = self.new
    new_run.welcome
  end

  # clear the terminal screen
  def clear
    puts `clear`
  end

  def logout
    self.clear
    exit
  end

  # convert an array into a human-readable numbered list format
  def list_array(arr)
    arr.each_with_index do |item, index|
      puts "#{index + 1}. #{item.name}"
    end
  end

  ###############################################################################
  ##### SESSION METHODS #########################################################
  ###############################################################################

  ########## LANDING PAGE ###############################

  # start the program
  # landing page with login options
  # called by CLI.runner, in turn called by bin/run.rb
  def welcome
    # clear the screen and show logo, login option
    self.clear
    a = Artii::Base.new :font => 'doh'
    puts a.asciify('FriendUp')
    puts

    PROMPT.select("Are you a new or returning user?") do |menu|
      menu.choice "New User", -> {self.create_new_user}
      menu.choice "Returning User\n", -> {self.login_page}
      menu.choice "QUIT", -> {self.logout}
    end
  end

  ########## NEW USER ###############################

  # new screen draw for creating new user name
  def create_new_user
    self.clear
    input = PROMPT.ask("Please enter a desired user name: ")
    if input.downcase == 'back'
      self.welcome
    elsif input.downcase == 'exit'
      self.logout
    elsif User.find_by(user_name: input)
      puts "That user name already exists."
      sleep 0.7
      self.create_new_user
    else
      self.build_profile(input)
    end
  end

  # if username is valid, create profile
  def build_profile(username)
    @user = User.new(user_name: username)
    puts "*Create your user profile*"
    puts
    self.set_name
    # call helper method to choose location from list of valid option
    self.choose_location
    # call helper method to add interests to this user
    self.choose_interests
  end

  def set_name
    self.clear
    self.user.name = PROMPT.ask("Please enter your full name: ")
  end

  # provide user a list of valid locations & return the one they select
  def choose_location
    self.clear
    current_location = []
    current_location << self.user.location
    locations =
    [
      "Washington D.C.",
      "New York City",
      "Chicago",
      "Los Angeles"
    ]-current_location # if user has location, remove it from array of options

    locations << ["BACK", "EXIT"]
    input = PROMPT.select("Please choose your location", locations)
    if input == "BACK"
      self.display_user_profile
    elsif input == "EXIT"
      self.logout
    else
      self.user.location = input
    end
  end

  # let user add an interest, with option to repeat or go to profile
  def choose_interests
    self.clear
    # list all available interests the user hasn't added to their profile
    possible_interests = (Interest.all - self.user.interests).map do |interest|
      interest.name
    end
    #check if all interests are selected
    if possible_interests == []
      self.clear
      puts "There are no additional interests to select. Returning you to your profile."
      sleep 1
      self.display_user_profile
    else
      selected_interests = PROMPT.multi_select("Please select one or more interests to add to your profile\n Press 'SPACE' to add and 'ENTER' to finish\n", possible_interests, echo:false, per_page:20)
      selected_interests.each do |interest_name|
        self.user.add_interest(Interest.find_by(name: interest_name))
      end
      self.user.save
      self.display_user_profile
    end
  end

  ########## RETURNING USER ###############################

  def login_page
    self.clear
    input = PROMPT.ask("Welcome back, please enter your username: ")
    if input.downcase == "back"
      self.welcome
    elsif input.downcase == 'exit'
      self.logout
    elsif User.find_by(user_name: input)
      @user = User.find_by(user_name: input)
      self.display_user_profile
    else
      PROMPT.select("That username does not exist") do |menu|
        menu.choice "Try Again", -> {self.login_page}
        menu.choice "Create New User", -> {self.create_new_user}
      end
    end
  end

  ########## MAIN PROFILE PAGE ###############################

  # landing page for user profile
  def display_user_profile
    self.clear
    puts "username: #{self.user.user_name}"
    puts
    puts "Name: #{self.user.name}"
    puts "Location: #{self.user.location}"
    puts "Interests:"
    puts
    self.list_array(self.user.interests)
    puts
    PROMPT.select ("") do |menu|
      menu.choice "View Events", -> {self.find_events}
      menu.choice "View your RSVPs", -> {self.show_rsvps}
      menu.choice "Edit Profile\n", -> {self.profile_edit}
      menu.choice "LOGOUT", -> {self.logout}
    end
  end

  ########## EDITING PROFILE ###############################

  def profile_edit
    self.clear
    PROMPT.select("Choose your profile information to edit:") do |menu|
      menu.choice "Name", -> {self.set_name}
      menu.choice "Location", -> {self.choose_location}
      menu.choice "Interests\n", -> {self.add_or_remove_interests}
      menu.choice "BACK", -> {self.display_user_profile}
      menu.choice "LOGOUT", -> {self.logout}
    end
    self.user.save
    self.profile_edit
  end

  def add_or_remove_interests
    self.clear
    PROMPT.select("") do |menu|
      menu.choice "Add new interests", -> {self.choose_interests}
      menu.choice "Remove current interests\n", -> {self.remove_interests}
      menu.choice "BACK", -> {self.profile_edit}
      menu.choice "LOGOUT", -> {self.logout}
    end
  end

  def remove_interests
    self.clear
    puts "Please enter number of interest to remove"
    current_interests = self.user.interests.map do |interest|
      interest.name
    end
    selected_interests = PROMPT.multi_select("Please select one or more interests you wish to remove from your profile\n Press 'SPACE' to select and 'ENTER' to finish\n", current_interests, echo:false, per_page:20)

    selected_interests.each do |interest_name|
      self.user.remove_interest(Interest.find_by(name: interest_name))
    end

    self.user.save
    self.add_or_remove_interests
  end

  ########## FIND EVENTS ################

  def find_events
    self.clear
    matched_events = self.user.matching_events
    if matched_events == []
      puts "No events found in your location matching your interests"
      sleep 0.7
      self.display_user_profile
    else
      choices = {}
      matched_events.each do |event|
        choices[event.name] = "self.display_event_details('#{event.name}')"
      end
      choices["[] BACK"] = 'self.display_user_profile'
      choices["[] LOGOUT"] = 'self.logout'
      eval(PROMPT.select("Choose an event to see more details", choices, per_page:45))
    end
  end

  def display_event_details(eventname)
    self.clear
    event = Event.find_by(name: eventname)
    puts "Event Name: #{event.name}"
    puts "Event Description: #{event.description}"
    puts "Location: #{event.location}"
    puts "Date/Time: #{event.event_datetime}"
    puts "Attendees:"
    self.list_array(event.users)
    puts

    PROMPT.select("") do |menu|
      if self.user.events.include?(event)
        menu.choice "Remove your RSVP for this event\n", -> {self.user.remove_event(event)}
      else
        menu.choice "RSVP for this event\n", -> {self.user.rsvp_to(event)}
      end
        menu.choice "[] BACK", -> {self.find_events}
        menu.choice "[] LOGOUT", -> {self.logout}
    end
    self.user.save
    self.user.reload
    self.display_event_details(eventname)
  end

  def show_rsvps
    self.clear
    user_events = (self.user.events)

    if user_events == []
      puts "You have no events! You should try adding some."
      sleep 1.5
      self.display_user_profile
    else
      choices = {}

      user_events.each do |event|
        choices[event.name] = "self.display_rsvp_details('#{event.name}')"
      end

      choices["BACK"] = 'self.display_user_profile'
      choices["LOGOUT"] = 'self.logout'

      eval(PROMPT.select("Choose an event to see more details", choices, per_page:45))
    end
  end

  def display_rsvp_details(eventname)
    event = Event.find_by(name: eventname)
    event.reload
    self.clear
    puts "Event Name: #{event.name}"
    puts "Event Description: #{event.description}"
    puts "Location: #{event.location}"
    puts "Date/Time: #{event.event_datetime}"
    puts "Attendees:"
    self.list_array(event.users)

    PROMPT.select("") do |menu|
      if self.user.events.include?(event)
        menu.choice "Remove your RSVP for this event\n", -> {self.user.remove_event(event)}
      else
        menu.choice "Re-add RSVP for this event\n", -> {self.user.rsvp_to(event)}
      end
        menu.choice "BACK", -> {self.show_rsvps}
        menu.choice "LOGOUT", -> {self.logout}
    end
    self.user.save
    self.user.reload
    self.display_rsvp_details(eventname)
  end
end