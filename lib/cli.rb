class CommandLineInterface
  attr_accessor :user

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

  def process_input(array = nil, back_page=nil)
    input = gets.chomp.downcase
    # exit condition
    self.check_exit(input)
    # back condition
    if input == "back"
      eval(back_page)
    # index condition
    elsif (Integer(input) rescue false)
      self.input_to_index(array, input)
    # text condition
    else
      return input
    end
  end

  # take in and standardize user input
  # def get_input
  #   input = gets.chomp
  #   self.check_exit(input.downcase)
  #   input.downcase
  # end

  # convert user input into index for use with arrays
  # (when giving them numbered list options)
  def input_to_index(array, input)
    # if input == nil
    #   input = gets.chomp
    # end
    # self.check_exit(input.downcase)
    newarray = [*0...array.length]
    index = input.to_i - 1
    if newarray.include?(index)
      return index
    else
      self.invalid_input_prompt
      self.process_input(array)
      # self.input_to_index(array, gets.chomp)
    end
  end

  # display brief error message
  # for use as final condition when getting user input
  def invalid_input_prompt
    puts "Please enter a valid input"
    # pause screen on error message for set period of time
    sleep 0.7
  end

  # check if user wants to exit the program
  # to be included as first call of any input handler method
  def check_exit(input)
    exit_array = ["e", "q", "quit", "exit"]
    exit_array.each do |exit_term|
      if input == exit_term
        self.clear
        exit
      end
    end
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
    puts "Are you a new or returning user?"
    puts "Please enter 'new' or 'returning'"
    puts "Enter (E)xit or Q(uit) to exit the program at anytime"
    self.welcome_input_handler(self.process_input)
  end

  # process user input from welcome screen
  def welcome_input_handler(input)
    if input == "new"
      self.create_new_user
    elsif input == "returning"
      self.login_page
    else
      self.invalid_input_prompt
      self.welcome
    end
  end

  ########## NEW USER ###############################

  # new screen draw for creating new user name
  def create_new_user
    self.clear
    puts "Please enter a desired user name"
    self.new_user_input_handler(self.process_input([],"self.welcome"))
  end

  # determine if username already exists
  def new_user_input_handler(username)
    if User.find_by(user_name: username)
      puts "That user name already exists."
      sleep 0.7
      self.create_new_user
    else
      self.build_profile(username)
    end
  end

  # if username is valid, create profile
  def build_profile(username)
    @user = User.new(user_name: username)
    puts "*Create your user profile*"
    puts
    puts "Please enter your full name"
    self.set_name(gets.chomp)
    puts "Please enter the number of your location"
    # call helper method to choose location from list of valid option
    self.choose_location
    # create, but don't yet save, new User instance
    # call helper method to add interests to this user
    self.choose_interests
  end

  def set_name(name)
    self.check_exit(name.downcase)
    self.user.name = name
    self.clear
  end

  # provide user a list of valid locations & return the one they select
  def choose_location
    current_location = []
    current_location << self.user.location
    locations = [
      "Washington D.C.",
      "New York City",
      "Chicago",
      "Los Angeles"
      ] - current_location

    locations.each_with_index do |location, index|
      puts "#{index + 1}. #{location}"
    end # TODO: refactor #list_array into normal & object-based version
    index = self.input_to_index(locations)
    self.clear
    self.user.location = locations[index]
  end

  # let user add an interest, with option to repeat or go to profile
  def choose_interests
    puts "Please select an interest to add to your profile:"
    # list all available interests the user hasn't added to their profile
    possible_interests = Interest.all - self.user.interests
    self.list_array(possible_interests)
    # get user choice and call User#add_interest to create interest association
    index = self.input_to_index(possible_interests)
    self.user.add_interest(possible_interests[index])
    self.clear
    puts "Type 'more' to add more interests or 'done' to view your profile"
    self.choose_interests_handler(self.process_input(possible_interests, "self.display_user_profile"))
  end

  # add another interest or go to profile
  # after user has added interest
  def choose_interests_handler(input)
    if input == "more"
      self.clear
      self.choose_interests
    elsif input == "done"
      self.clear
      self.user.save
      self.display_user_profile
    else
      self.invalid_input_prompt
      self.choose_interests
    end
  end

  ########## RETURNING USER ###############################

  def login_page
    self.clear
    puts "Welcome back, please enter your username"
    self.login_handler(self.process_input([], "self.welcome"))
  end

  def login_handler(username)
    if User.find_by(user_name: username)
      @user = User.find_by(user_name: username)
      self.display_user_profile
    else
      puts "That username does not exist, type 'retry' to try another username OR type 'new' to create a new username"
      self.login_error_handler(self.process_input([], "self.login_page"))
    end
  end

  def login_error_handler(input)
    if input == "retry"
      self.login_page
    elsif input == "new"
      self.create_new_user
    else
      self.invalid_input_prompt
      self.login_page
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
    puts "Type 'edit' to change your profile details or interests"
    puts "Type 'events' to find events in your area matching your interests"
    puts "Type 'rsvps' to see all events you have RSVP'd to"
    self.profile_handler(self.process_input([],"self.display_user_profile"))
  end

  # process user input from main profile page
  # reroute to appropriate page/function
  def profile_handler(input)
    if input == "edit"
      self.profile_edit
    elsif input == "events"
      self.find_events #TODO : re-factor user method -find_events and event method -display details
    elsif input == "rsvps"
      self.show_rsvps
    else
      self.invalid_input_prompt
      self.display_user_profile
    end
  end

  ########## EDITING PROFILE ###############################

  def profile_edit
    self.clear
    puts <<-ENTRY
    Enter the number of the profile information you want to edit:

    1. Name
    2. Location
    3. Interests

    Type 'back' to go back to your profile.
    ENTRY
    self.profile_edit_handler(self.process_input(["name", "location", "interests"], "self.display_user_profile"))
  end

  def profile_edit_handler(input)
    if input == 0
      self.clear
      puts "Please enter your new name:"
      self.set_name(gets.chomp)
      self.user.save
      self.display_user_profile
    elsif input == 1
      self.clear
      puts "Please enter your new location:"
      self.choose_location
      self.user.save
      self.display_user_profile
    elsif input == 2
      self.clear
      self.add_or_remove_interests
    else
      self.invalid_input_prompt
      self.profile_edit
    end
  end

  def add_or_remove_interests
    self.clear
    puts <<-TEXT
    Would you like to add or remove interests?

    1. Add new interests
    2. Remove current interests

    0. Go Back
    TEXT
    self.add_or_remove_interests_handler(self.get_input)
  end

  def add_or_remove_interests_handler(input)
    if input == "0"
      self.profile_edit
    elsif input == "1"
      self.clear
      self.choose_interests
    elsif input == "2"
      ### write some functions to remove interests
      self.clear
      self.remove_interests
    else
      self.invalid_input_prompt
      self.add_or_remove_interests
    end
  end

  def remove_interests
    puts "Please enter number of interest to remove"
    # display interests
    self.list_array(self.user.interests)
    # get user input and convert to array index of user's interests
    index = self.input_to_index(self.user.interests)
    self.user.remove_interest(self.user.interests[index])
    self.clear
    #TODO: Give user option to remove more interests
    self.display_user_profile
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
      self.list_array(matched_events)
      puts ""
      puts "Please select an event to see more details on or type 'back' to go back"
      self.find_event_handler(self.get_input, matched_events)
    end
  end

  def find_event_handler(input, matched_events)
    if input == "back"
      self.display_user_profile
    else
      index = self.input_to_index(matched_events, input)
      self.display_event_details(matched_events[index])
    end
  end


  def display_event_details(event)
    self.clear
    puts "Event Name: #{event.name}"
    puts "Event Description: #{event.description}"
    puts "Location: #{event.location}"
    puts "Date/Time: #{event.event_datetime}"
    puts "Attendees:"
    self.list_array(event.users)
    puts
    if self.user.events.include?(event)
      puts "Type 'remove' to remove this event from your profile"
    else
      puts "Type 'rsvp' to add this event to your profile"
    end
    puts "Type 'back' to go back to the event list"
    self.event_detail_handler(self.get_input, event)
  end

  def event_detail_handler(input, event)
    if input == 'rsvp'
      self.user.rsvp_to(event)
      puts "You have successfully RSVP'd to #{event.name}"
      sleep 1
      self.find_events
    elsif input == 'remove'
      self.user.remove_event(event)
      puts "You have removed your RSVP for #{event.name}"
      sleep 1
      self.find_events
    elsif input == 'back'
      self.find_events
    else
      self.invalid_input_prompt
      self.display_event_details(event)
    end
  end

  def show_rsvps
    self.clear
    self.list_array(self.user.events)
  end

end