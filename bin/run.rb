require_relative '../config/environment'

test = User.find_or_create_by(name: "Test")
test.add_interest("Photography")
test.add_interest("Nature")

# input = gets.chomp
test.remove_interest

# binding.pry