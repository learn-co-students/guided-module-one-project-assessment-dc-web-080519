require_relative '../config/environment'

event1 = Event.find_or_create_by(
  name: "Smash Party",
  description: "Smash Bros rules",
  location: "My mom's basement",
  event_datetime: "2019-08-29 [08:30:00] "
)
event1.assign_interests(["Board Games", "Nature"])

event2 = Event.find_or_create_by(
  name: "Street Festival"
)
event2.assign_interests(["Food", "Photography"])

event3 = Event.find_or_create_by(name: "Drink N Code")
event3.assign_interests(["Technology", "Drinks"])

event4 = Event.find_or_create_by(name: "Photos of Birds")
event4.assign_interests(["Photography", "Nature"])



user1 = User.find_or_create_by(
  user_name: "user1",
  name: "User 1",
  location: "Adams Morgan"
)
user1.add_interest("Photography")
user1.add_interest("Nature")


binding.pry
0