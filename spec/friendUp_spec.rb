require_relative '../config/environment'

describe "FriendUpChecker" do

    let (:user1) {User.find_or_create_by(name: "Rob Paik", location: "Washington D.C.")}
    let (:user2) {User.find_or_create_by(name: "Pete Hanner")}
    let (:interest1) {Interest.find_or_create_by(name: "Food")}
    let (:event1) {Event.find_or_create_by(name: "Party Pop", location: "Washington D.C.")}
    let (:event2) {Event.find_or_create_by(name: "Baby Sharks Everywhere", location: "New York City")}

    it "returns true when user is created with name 'Rob Paik'" do
        expect(user1.name == 'Rob Paik').to be(true)
    end

    it "returns true when created user returns 'Washington D.C.' for loation" do
        expect(user1.location == 'Washington D.C.').to be(true)
    end

    it "returns true when added interest for user shows up in users interests" do
        user2.add_interest(interest1)
        expect(user2.interests.include?(interest1)).to be(true)
    end

    it "returns false when removed interest no longer shows up in users interests" do
        user2.remove_interest(interest1)
        expect(user2.interests.include?(interest1)).to be(false)
    end

    it "returns true when user RSVPs to an event and event is added to users events" do
        user1.rsvp_to(event1)
        user1.rsvp_to(event2)
        expect(user1.events.include?(event1) && user1.events.include?(event2)).to be(true)
    end

    it "returns false when removed event is no longer included in users events" do
        user1.remove_event(event1)
        expect(user1.events.include?(event1)).to be(false)
    end

    it "returns true when un-removed event is still inside users events after a call to remove another event" do
        user1.remove_event(event1)
        expect(user1.events.include?(event2)).to be(true)
    end

    it "event is included in matched_events list that checks for user interest and location" do
        user1.add_interest(interest1)
        event1.assign_interest(interest1.name)
        expect(user1.matching_events.include?(event1)).to be (true)
    end

    it "users matched events does not include any events with locations outside of users location" do
        non_dc_events = user1.matching_events.find_all do |event|
            event.location != "Washington D.C."
        end
        binding.pry
        expect(non_dc_events.length == 0). to be (true)
    end

end