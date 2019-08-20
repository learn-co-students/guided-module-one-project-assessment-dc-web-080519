require_relative '../config/environment'

User.destroy_all
UserInterest.destroy_all
Event.destroy_all
InterestEvent.destroy_all
Rsvp.destroy_all

CommandLineInterface.runner