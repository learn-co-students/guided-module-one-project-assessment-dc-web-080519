require_relative '../config/environment'

new_event = Event.find_or_create_by(name: "Smash Party")
new_event.assign_interests(["Board Games", "Nature"])

binding.pry
0