require_relative '../config/environment'

User.destroy_all
UserInterest.destroy_all
Event.destroy_all
InterestEvent.destroy_all
Rsvp.destroy_all

user1 = User.create(user_name: "user1", name: "Rob")
user1.interests = [Interest.find_by(name: "Photography"), Interest.find_by(name: "Nature")]



CommandLineInterface.runner