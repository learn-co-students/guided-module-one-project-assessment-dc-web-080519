Event.destroy_all
InterestEvent.destroy_all
Interest.destroy_all
User.destroy_all
UserInterest.destroy_all
Rsvp.destroy_all

locations = [
  "Washington D.C.",
  "New York City",
  "Chicago",
  "Los Angeles"
]

### INTERESTS ###
Interest.find_or_create_by(name: "Food")
Interest.find_or_create_by(name: "Board Games")
Interest.find_or_create_by(name: "Photography")
Interest.find_or_create_by(name: "Music")
Interest.find_or_create_by(name: "Drinks")
Interest.find_or_create_by(name: "Technology")
Interest.find_or_create_by(name: "Fitness")
Interest.find_or_create_by(name: "Nature")
Interest.find_or_create_by(name: "Video Games")
Interest.find_or_create_by(name: "Theater")
Interest.find_or_create_by(name: "Movies")
Interest.find_or_create_by(name: "Languages")
Interest.find_or_create_by(name: "Networking")

interests = Interest.all

### EVENTS ###

250.times do
  new_event = Event.find_or_create_by(
    name: Faker::Hipster.sentence(word_count: 3),
    description: Faker::Lorem.paragraph,
    location: locations.sample,
    event_datetime: Faker::Date.forward(days: 31)
  )
  new_event.interests << interests.sample
  new_event.interests << interests.sample
  new_event.interests << interests.sample
  new_event.save
end

user1 = User.create(user_name: "user1", name: "Rob", location: "Washington D.C.")
user1.interests = [Interest.find_by(name: "Photography"), Interest.find_by(name: "Nature")]

event1 = Event.find_or_create_by(
  name: "Smash Party",
  description: "Smash Bros rules",
  location: "Washington D.C.",
  event_datetime: "2019-08-29 [08:30:00] "
)
event1.assign_interests(["Board Games", "Nature"])

event2 = Event.find_or_create_by(
  name: "Street Festival",
  location: "New York City"
)
event2.assign_interests(["Food", "Photography"])

event3 = Event.find_or_create_by(
    name: "Drink N Code",
    location: "Chicago"
)
event3.assign_interests(["Technology", "Drinks"])

event4 = Event.find_or_create_by(
    name: "Photos of Birds",
    location: "Washington D.C.")
event4.assign_interests(["Photography", "Nature"])

events = Event.all

### USERS ###
50.times do
  new_user = User.find_or_create_by(
    user_name: Faker::String.random(length: 8..20),
    name: Faker::FunnyName.two_word_name,
    location: locations.sample
  )
  new_user.interests << interests.sample
  new_user.interests << interests.sample
  new_user.interests << interests.sample

  new_user.events << events.sample
  new_user.events << events.sample
  new_user.events << events.sample
  new_user.events << events.sample
  new_user.events << events.sample

  new_user.save
end



# binding.pry
# 0