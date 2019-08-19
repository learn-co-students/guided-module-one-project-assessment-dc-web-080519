class Interest < ActiveRecord::Base
    has_many :user_interests
    has_many :users, through: :user_interests
    has_many :interest_events
    has_many :events, through: :interest_events

    def my_interests
        User_Interests.all.find_all do |interests|
            interests.user_id  == self.id
        end
    end

    def display_interests
        counter = 1
        self.my_interests.each do |my_interests|
            puts "#{counter}. my_interests"
            counter += 1
        end
    end

    def add_interest(interest)
        self.my_interests << interest
    end

    def remove_interest(interest)
        if self.my_interest.include?(interest)
        end
    end     


end