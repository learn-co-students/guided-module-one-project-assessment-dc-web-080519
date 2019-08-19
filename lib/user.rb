class User < ActiveRecord::Base
  has_many :user_interests
  has_many :interests, through: :user_interests
  has_many :rsvps
  has_many :events, through: :rsvps

  def add_interest(interest)
    new_interest = UserInterest.find_or_create_by(
      user_id: self.id,
      interest_id: Interest.get_id(interest)
    )
  end

  def display_interests
    self.interests.each_with_index do |interest, index|
      puts "#{index + 1}. #{interest.name}"
      interest
    end
  end

  def remove_interest
    # prompt user
    puts "Please enter number of interest to remove"
    # display interests
    self.display_interests
    # get user input
    input = gets.chomp
    binding.pry
    # match user input to index of listed interest
    
    # remove that interest from array
  end

end