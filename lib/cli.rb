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

  # take in and standardize user input
  def get_input
    input = gets.chomp
    self.check_exit(input.downcase)
    input.downcase
  end

  # convert user input into index for use with arrays
  # (when giving them numbered list options)
  def input_to_index
    input = gets.chomp
    self.check_exit(input.downcase)
    # TODO: make sure input is number
    # TODO: make sure index is valid for array
    index = input.to_i - 1
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
    self.welcome_input_handler(self.get_input)
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
    self.new_user_input_handler(self.get_input)
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
    index = self.input_to_index
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
    index = self.input_to_index
    self.user.add_interest(possible_interests[index])
    self.clear
    puts "Type 'more' to add more interests or 'done' to view your profile"
    self.choose_interests_handler(self.get_input)
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
    self.login_handler(self.get_input)
  end

  def login_handler(username)
    if User.find_by(user_name: username)
      @user = User.find_by(user_name: username)
      self.display_user_profile
    else
      puts "That username does not exist, type 'retry' to try another username OR type 'new' to create a new username"
      self.login_error_handler(self.get_input)
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
    self.profile_handler(self.get_input)
  end

  # process user input from main profile page
  # reroute to appropriate page/function
  def profile_handler(input)
    if input == "edit"
      self.profile_edit
    elsif input == "events"
      self.find_events #TODO : re-factor user method -find_events and event method -display details
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

    0. Go Back

    ENTRY
    self.profile_edit_handler(self.get_input)
  end

  def profile_edit_handler(input)
    if input == "0"
      self.display_user_profile
    elsif
      input == "1"
      self.clear
      puts "Please enter your new name:"
      self.set_name(gets.chomp)
      self.user.save
      self.display_user_profile
    elsif input == "2"
      self.clear
      puts "Please enter your new location:"
      self.choose_location
      self.user.save
      self.display_user_profile
    elsif input == "3"
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
    else
      self.invalid_input_prompt
      self.add_or_remove_interests
    end
  end
end