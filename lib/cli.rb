class CommandLineInterface
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

  def self.welcome
    self.clear
    a = Artii::Base.new :font => 'doh'
    puts a.asciify('FriendUp')
    puts
    puts "Are you a new or returning user?"
    self.welcome_input_handler(self.get_input)
  end

  def self.welcome_input_handler(input)
    if input == "new"
      self.create_new_user # DEFINE METHOD
    else
      self.invalid_input_prompt
      self.welcome
    end
  end

  def self.runner
    self.welcome
  end
end