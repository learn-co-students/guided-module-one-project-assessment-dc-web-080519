### INTERESTS ###
food = Interest.find_or_create_by(name: "Food")
Interest.find_or_create_by(name: "Board Games")
Interest.find_or_create_by(name: "Photography")
Interest.find_or_create_by(name: "Music")
Interest.find_or_create_by(name: "Drinks")
Interest.find_or_create_by(name: "Technology")
Interest.find_or_create_by(name: "Fitness")
Interest.find_or_create_by(name: "Nature")

interests = Interest.all

### EVENTS ###


### USERS ###
test = User.find_or_create_by(name: "Test")
test.add_interest("Photography")
test.add_interest("Nature")


binding.pry
0