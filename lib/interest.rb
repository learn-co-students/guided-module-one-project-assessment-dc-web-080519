class Interest < ActiveRecord::Base
  has_many :user_interests
  has_many :users, through: :user_interests
  has_many :interest_events
  has_many :events, through: :interest_events

  def self.get_id(selected_interest)
    self.all.find do |interest|
      interest.name == selected_interest
    end.id
  end
end