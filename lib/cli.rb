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

  # convert user input into index for use with arrays
  # (when giving them numbered list options)
  def input_to_index(array, input)
    index = input.to_i - 1
    if (array.length - 1) < index.abs
      self.invalid_input_prompt
      self.process_input(array)
    else
      return index
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
    # puts "Are you a new or returning user?"
    # puts "Please enter 'new' or 'returning'"
    # puts "Enter (E)xit or Q(uit) to exit the program at anytime"

    PROMPT.select("Are you a new or returning user?") do |menu|
      menu.choice "New User", -> {self.create_new_user}
      menu.choice "Returning User\n", -> {self.login_page}
      menu.choice "QUIT", -> {self.logout}
    end


    #self.welcome_input_handler(self.process_input)
  end

  # process user input from welcome screen
  # def welcome_input_handler(input)
  #   if input == "new"
  #     self.create_new_user
  #   elsif input == "returning"
  #     self.login_page
  #   else
  #     self.invalid_input_prompt
  #     self.welcome
  #   end
  # end

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
    # self.new_user_input_handler(self.process_input([],"self.welcome"))
  end

  # determine if username already exists
  # def new_user_input_handler(username)
  #   if User.find_by(user_name: username)
  #     puts "That user name already exists."
  #     sleep 0.7
  #     self.create_new_user
  #   else
  #     self.build_profile(username)
  #   end
  # end

  # if username is valid, create profile
  def build_profile(username)
    @user = User.new(user_name: username)
    puts "*Create your user profile*"
    puts
    self.set_name
    # call helper method to choose location from list of valid option
    self.choose_location
    # create, but don't yet save, new User instance
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


    # locations.each_with_index do |location, index|
    #   puts "#{index + 1}. #{location}"
    # end

    # index = self.process_input(locations, "self.display_user_profile")

    # if !index.is_a?(Integer)
    #   self.invalid_input_prompt
    #   self.choose_location
    # else
    #   self.user.location = locations[index]
    # end
  end

  # let user add an interest, with option to repeat or go to profile
  def choose_interests
    self.clear
    # list all available interests the user hasn't added to their profile
    possible_interests = (Interest.all - self.user.interests).map do |interest|
      interest.name
    end
    #check to auto-complete profile if all interests are selected
    if possible_interests == []
      self.clear
      puts "There are no additional interests to select. Returning you to your profile."
      sleep 1
      self.display_user_profile
    else
      selected_interests = PROMPT.multi_select("Please select one or more interests to add to your profile\n Press 'SPACE' to add and 'ENTER' to finish\n", possible_interests, echo:false, per_page:20)
      # self.list_array(possible_interests)
      # get user choice and call User#add_interest to create interest association
      # index = self.process_input(possible_interests, "self.add_or_remove_interests")
      selected_interests.each do |interest_name|
        self.user.add_interest(Interest.find_by(name: interest_name))
      end
      self.user.save
      self.display_user_profile
    end
    #     self.clear
    #   puts "Type 'more' to add more interests or 'done' to view your profile"
    #   self.choose_interests_handler(self.process_input(possible_interests, "self.add_or_remove_interests"))
    # end
  end

  # add another interest or go to profile
  # after user has added interest
  # def choose_interests_handler(input)
  #   if input == "more"
  #     self.clear
  #     self.choose_interests
  #   elsif input == "done"
  #     self.clear
  #     self.user.save
  #     self.display_user_profile
  #   else
  #     self.invalid_input_prompt
  #     self.choose_interests
  #   end
  # end

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
    # self.login_handler(self.process_input([], "self.welcome"))
  end

  # def login_handler(username)
  #   if User.find_by(user_name: username)
  #     @user = User.find_by(user_name: username)
  #     self.display_user_profile
  #   else
  #     puts "That username does not exist, type 'retry' to try another username OR type 'new' to create a new username"
  #     self.login_error_handler(self.process_input([], "self.login_page"))
  #   end
  # end

  # def login_error_handler(input)
  #   if input == "retry"
  #     self.login_page
  #   elsif input == "new"
  #     self.create_new_user
  #   else
  #     self.invalid_input_prompt
  #     self.login_page
  #   end
  # end

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
      
    #   puts "Type 'edit' to change your profile details or interests"
    # puts "Type 'events' to find events in your area matching your interests"
    # puts "Type 'rsvps' to see all events you have RSVP'd to"
    # self.profile_handler(self.process_input([], "self.display_user_profile"))
  end

  # process user input from main profile page
  # reroute to appropriate page/function
  # def profile_handler(input)
  #   if input == "edit"
  #     self.profile_edit
  #   elsif input == "events"
  #     self.find_events
  #   elsif input == "rsvps"
  #     self.show_rsvps
  #   else
  #     self.invalid_input_prompt
  #     self.display_user_profile
  #   end
  # end

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
    # puts <<-ENTRY
    # Enter the number of the profile information you want to edit:

    # 1. Name
    # 2. Location
    # 3. Interests

    # Type 'back' to go back to your profile.
    # ENTRY
    # self.profile_edit_handler(self.process_input(["name", "location", "interests"], "self.display_user_profile"))
  end

  # def profile_edit_handler(input)
  #   if input == 0
  #     self.clear
  #     puts "Please enter your new name:"
  #     self.set_name(gets.chomp)
  #     self.user.save
  #     self.display_user_profile
  #   elsif input == 1
  #     self.clear
  #     puts "Please enter your new location:"
  #     self.choose_location
  #     self.user.save
  #     self.display_user_profile
  #   elsif input == 2
  #     self.clear
  #     self.add_or_remove_interests
  #   else
  #     self.invalid_input_prompt
  #     self.profile_edit
  #   end
  # end

  def add_or_remove_interests
    self.clear
    PROMPT.select("") do |menu|
      menu.choice "Add new interests", -> {self.choose_interests}
      menu.choice "Remove current interests\n", -> {self.remove_interests}
      menu.choice "BACK", -> {self.profile_edit}
      menu.choice "LOGOUT", -> {self.logout}
    end
    # puts <<-TEXT
    # Would you like to add or remove interests?

    # 1. Add new interests
    # 2. Remove current interests

    # Type 'back' to return to options
    # TEXT
    # self.add_or_remove_interests_handler(self.process_input(["add", "remove"], "self.profile_edit"))
  end

  # def add_or_remove_interests_handler(input)
  #   if input == 0
  #     self.clear
  #     self.choose_interests
  #   elsif input == 1
  #     ### write some functions to remove interests
  #     self.clear
  #     self.remove_interests
  #   else
  #     self.invalid_input_prompt
  #     self.add_or_remove_interests
  #   end
  # end

  def remove_interests
    self.clear
    puts "Please enter number of interest to remove"
    # display interests
    # self.list_array(self.user.interests)
    # get user input and convert to array index of user's interests
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
      choiceshash = {}
      matched_events.each do |event|
        choiceshash[event.name] = "self.display_event_details('#{event.name}')"
      end
      choiceshash["BACK"] = 'self.display_user_profile'
      choiceshash["LOGOUT"] = 'self.logout'
      eval(PROMPT.select("Choose an event to see more details", choiceshash, per_page:30))
      #binding.pry
      # self.list_array(matched_events)
      # puts ""
      # puts "Please select the number of an event to see more details on or type 'back' to return to your profile"
      # self.find_event_handler(self.process_input(matched_events, "self.display_user_profile"), matched_events)
    end
  end

  # def find_event_handler(input, matched_events)
  #   self.display_event_details(matched_events[input])
  # end

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
        menu.choice "BACK", -> {self.find_events}
        menu.choice "LOGOUT", -> {self.logout}
    end
    self.user.save
    self.user.reload
    self.display_event_details(eventname)


    # if self.user.events.include?(event)
      # puts "Type 'remove' to remove this event from your profile"
    # else
    #   puts "Type 'rsvp' to add this event to your profile"
    # end
    # puts "Type 'back' to see more events you may be interested in."
    # self.event_detail_handler(self.process_input([], "self.find_events"), event)
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
    else
      self.invalid_input_prompt
      self.display_event_details(event)
    end
  end

  def show_rsvps
    self.clear
    self.list_array(self.user.events)
    puts "Select an event to see more details."
    self.rsvp_handler(self.process_input(self.user.events, "self.display_user_profile"))
  end

  def rsvp_handler(input)
    self.display_rsvp_details(self.user.events[input])
  end

  def display_rsvp_details(event)
    event.reload
    self.clear
    puts "Event Name: #{event.name}"
    puts "Event Description: #{event.description}"
    puts "Location: #{event.location}"
    puts "Date/Time: #{event.event_datetime}"
    puts "Attendees:"
    self.list_array(event.users)
    puts
    puts "Type 'remove' to remove this event from your profile"
    puts "Type 'back' to return to your RSVP's."
    self.rsvp_detail_handler(self.process_input([], "self.show_rsvps"), event)
  end

  def rsvp_detail_handler(input, event)
    if input == 'remove'
      self.user.remove_event(event)
      puts "You have removed your RSVP for #{event.name}"
      sleep 1
      self.show_rsvps
    else
      self.invalid_input_prompt
      self.display_rsvp_details(event)
    end
  end

end