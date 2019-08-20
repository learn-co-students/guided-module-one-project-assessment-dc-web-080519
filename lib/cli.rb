class CommandLineInterface
  
  attr_accessor :user

  def self.runner
    self.welcome
  end
  
  def self.clear
    puts `clear`
  end
  
  def self.get_input
    input = gets.chomp
    input.downcase
  end

  def self.invalid_input_prompt
    puts "Please enter a valid input"
    sleep 0.7
  end

  def self.check_exit(input)
    exit_array = ["e", "q", "quit", "exit"]
    exit_array.each do |exit_term|
      if input == exit_term
        self.clear
        exit
      end
    end
  end

  def self.welcome
    self.clear
    a = Artii::Base.new :font => 'doh'
    puts a.asciify('FriendUp')
    puts
    puts "Are you a new or returning user?"
    puts "Please enter 'new' or 'returning'"
    puts "Enter (E)xit or Q(uit) to exit the program at anytime"
    self.welcome_input_handler(self.get_input)
  end

  def self.welcome_input_handler(input)
    self.check_exit(input)
    if input == "new"
      self.create_new_user # DEFINE METHOD
    elsif input == "returning"
      self.login_page #DEFINE METHOD
    else
      self.invalid_input_prompt
      self.welcome
    end
  end

  def self.choose_locations
    locations = ["Washington D.C.", "New York City", "Chicago", "Los Angeles"]
    locations.each_with_index do |location, index|
      puts "#{index + 1}. #{location}"
    end
    input = gets.chomp
    index = input.to_i - 1
    return locations[index]
  end

  def self.new_user_input_handler(input)
    self.check_exit(input)
    if User.find_by(user_name: input)
      puts "That user name already exists."
      sleep 0.7
      self.create_new_user
    else
      puts "*Create your user profile*"
      puts "Please enter your full name"
      name = gets.chomp
      puts "Please enter the number of your location"
      location = self.choose_locations
      user = User.new(user_name: input, name: name, location: location)
      self.set_starting_interests
      # user.add_interest
    end
  end

  def self.create_new_user
    self.clear
    puts "Please enter a desired user name"
    self.new_user_input_handler(self.get_input)
  end
  
end