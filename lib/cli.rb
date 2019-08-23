class CommandLineInterface
  attr_accessor :user
  PROMPT = TTY::Prompt.new

  ##############################################################################
  ##### HELPER METHODS #########################################################
  ##############################################################################

  # create new CLI instance and call #welcome on this new run
  def self.runner
    new_run = self.new
    new_run.welcome
  end

  # clear the terminal screen
  def clear
    puts `clear`
  end

  # blank screen & terminate program
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

    # login options
    PROMPT.select("Are you a new or returning user?") do |menu|
      menu.choice "New User", -> {self.create_new_user}
      menu.choice "Returning User\n", -> {self.login_page}
      menu.choice "[] QUIT", -> {self.logout}
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
    elsif !(input =~ /\A[a-z\d][a-z\d_]*[a-z\d]\z/i)
      # validate username
      puts "Usernames can only have characters, numbers, or underscores."
      sleep 0.7
      self.create_new_user
    elsif User.find_by(user_name: input)
      # check if username is taken
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
    self.set_name
    # call helper method to choose location from list of valid option
    self.choose_location
    # call helper method to add interests to this user
    self.choose_interests
  end

  # assign name attribute with input
  def set_name
    self.clear
    input = PROMPT.ask("Please enter your full name: ")
    # validate user name only has single spaces and valid characters
    if (input == input.split.join(" ") && !(input =~ /[^a-z\s'.-]/i))
      self.user.name = input
    else
      puts "Please enter a valid name"
      sleep 1
      self.set_name
    end
  end

  # provide list of valid locations to set location attribute
  def choose_location
    self.clear
    # if user has location, put it in an array so only new locations are shown
    locations = [
      "Washington D.C.",
      "New York City",
      "Chicago",
      "Los Angeles"
    ]

    # subtract arrays to remove user location
    current_location = []
    current_location << self.user.location
    locations = (locations - current_location)

    # tack special options to end of menu
    locations << ["[] BACK", "[] LOGOUT"]

    input = PROMPT.select("Please choose your location", locations)
    # check for special options, otherwise set location
    if input == "[] BACK"
      self.display_user_profile
    elsif input == "[] LOGOUT"
      self.logout
    else
      self.user.location = input
    end
  end

  # let user add interests
  def choose_interests
    self.clear
    # list all available interests the user hasn't added to their profile
    possible_interests = (Interest.all - self.user.interests).map do |interest|
      interest.name
    end
    if possible_interests == []
      # check if user has already selected all interests
      self.clear
      puts "There are no additional interests to select. Returning you to your profile."
      sleep 1
      self.display_user_profile
    else
      # let user select multiple interests to add to their profile
      selected_interests = PROMPT.multi_select("Please select one or more interests to add to your profile\n Press 'SPACE' to add and 'ENTER' to finish\n", possible_interests, echo:false, per_page:20)
      # associate all chosen interests to user
      selected_interests.each do |interest_name|
        self.user.add_interest(Interest.find_by(name: interest_name))
      end
      self.user.save
      self.display_user_profile
    end
  end

  ########## RETURNING USER ###############################

  # handle returning users
  def login_page
    self.clear
    input = PROMPT.ask("Welcome back, please enter your username: ")
    if input.downcase == "back"
      self.welcome
    elsif input.downcase == 'exit'
      self.logout
    elsif User.find_by(user_name: input)
      # valid input
      @user = User.find_by(user_name: input)
      self.display_user_profile
    else
      # if username not found, let them try again or go to new user creation
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
    # profile information
    puts "username: #{self.user.user_name}"
    puts
    puts "Name: #{self.user.name}"
    puts "Location: #{self.user.location}"
    puts "Interests:"
    self.list_array(self.user.interests)
    puts
    # menu options
    PROMPT.select ("") do |menu|
      menu.choice "View Events", -> {self.find_events}
      menu.choice "View your RSVPs", -> {self.show_rsvps}
      menu.choice "Edit Profile\n", -> {self.profile_edit}
      menu.choice "[] LOGOUT", -> {self.logout}
    end
  end

  ########## EDITING PROFILE ###############################

  # let user choose various profile information to edit
  def profile_edit
    self.clear
    PROMPT.select("Choose your profile information to edit:") do |menu|
      menu.choice "Name", -> {self.set_name}
      menu.choice "Location", -> {self.choose_location}
      menu.choice "Interests\n", -> {self.add_or_remove_interests}
      menu.choice "[] BACK", -> {self.display_user_profile}
      menu.choice "[] LOGOUT", -> {self.logout}
    end
    # destination methods would terminate program, so:
    # save user and reload page once any edits are made
    self.user.save
    self.profile_edit
  end

  # forked choice for user
  def add_or_remove_interests
    self.clear
    PROMPT.select("") do |menu|
      menu.choice "Add new interests", -> {self.choose_interests}
      menu.choice "Remove current interests\n", -> {self.remove_interests}
      menu.choice "[] BACK", -> {self.profile_edit}
      menu.choice "[] LOGOUT", -> {self.logout}
    end
  end

  # user can remove interests they've added to profile
  def remove_interests
    self.clear
    # make sure interests are there to be removed
    if self.user.interests == []
      puts "Please add some interests before you try to remove any."
      sleep 1.5
      self.add_or_remove_interests
    else
      current_interests = self.user.interests.map do |interest|
        interest.name
      end
      # let user select multiple interests to remove
      selected_interests = PROMPT.multi_select("Please select one or more interests you wish to remove from your profile\n Press 'SPACE' to select and 'ENTER' to finish\n", current_interests, echo:false, per_page:20)
      # disassociate user from events
      selected_interests.each do |interest_name|
        self.user.remove_interest(Interest.find_by(name: interest_name))
      end
      # save user and return to option screen
      self.user.save
      self.add_or_remove_interests
    end
  end

  ########## FIND EVENTS ################

  # show user a list of events in their area matching their interests
  def find_events
    self.clear
    matched_events = self.user.matching_events
    if self.user.location == nil
      # make sure location is set
      puts "Please set your location to see events in your area."
      sleep 1.5
      self.display_user_profile
    elsif self.user.interests == []
      # make sure interests are set
      puts "Please choose some interests so we can show you matching events."
      sleep 1.5
      self.display_user_profile
    elsif matched_events == []
      # just in case there are no matching events
      puts "No events found in your location matching your interests."
      sleep 1.5
      self.display_user_profile
    else
      # populate list of matching events
      # define code to run for each event if selected
      # tack navigation options onto bottom of list
      choices = {}
      matched_events.each do |event|
        choices[event.name] = "self.display_event_details('#{event.name}', 'self.find_events')"
      end
      choices["[] BACK"] = 'self.display_user_profile'
      choices["[] LOGOUT"] = 'self.logout'
      # user selection returns as method call in string format; execute that call
      eval(PROMPT.select("Choose an event to see more details:", choices, per_page:45))
    end
  end

  # a more detailed view for a given event
  def display_event_details(eventname, backpage)
    self.clear
    event = Event.find_by(name: eventname)
    puts "Event Name: #{event.name}"
    puts "Event Description: #{event.description}"
    puts "Location: #{event.location}"
    puts "Date/Time: #{event.event_datetime}"
    puts "Attendees:"
    self.list_array(event.users)
    puts

    # let user add or remove RSVP for event
    PROMPT.select("") do |menu|
      if self.user.events.include?(event)
        menu.choice "Remove your RSVP for this event\n", -> {self.user.remove_event(event)}
      else
        menu.choice "RSVP for this event\n", -> {self.user.rsvp_to(event)}
      end
      menu.choice "[] BACK", -> {eval(backpage)}
      menu.choice "[] LOGOUT", -> {self.logout}
    end
    # update object models and refresh this page on any RSVP change
    self.user.save
    self.user.reload
    self.display_event_details(eventname, backpage)
  end

  # user can view events they've rsvp'd to
  def show_rsvps
    self.clear
    user_events = (self.user.events)
    if user_events == []
      # make sure there are events to view
      puts "You have no events! You should try adding some."
      sleep 1.5
      self.display_user_profile
    else
      # populate list of RSVP'd events
      # define code to run for each event if selected
      # navigation options on bottom of list
      choices = {}
      user_events.each do |event|
        choices[event.name] = "self.display_event_details('#{event.name}', 'self.show_rsvps')"
      end
      choices["[] BACK"] = 'self.display_user_profile'
      choices["[] LOGOUT"] = 'self.logout'
      # selection returns method call as string; execute that call
      eval(PROMPT.select("Choose an event to see more details", choices, per_page:45))
    end
  end
end