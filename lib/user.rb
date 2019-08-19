class User < ActiveRecord::Base
    has_many :user_interests
    has_many :interests, through: :user_interests
    has_many :rsvps
    has_many :events, through: :rsvps


    def display_interests
        self.interests.each do |interest|
            puts "#{interest.index + 1}. #{interest.name}"
        end
    end

    def get_interest_id(selected_interest)
        Interest.all.find do |interest|
            interest.name == selected_interest
        end.id
    end

    def add_interest(interest)
            new_interest = UserInterest.new
            new_interest.user_id = self.id
            new_interest.interest_id = (get_interest_id(interest))
    end

    def remove_interest(interest)
        if self.my_interest.include?(interest)
        end
    end     
    
end