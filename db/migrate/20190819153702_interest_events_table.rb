class InterestEventsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :interest_events do |t|
      t.integer :interest_id
      t.integer :event_id
    end
  end
end
