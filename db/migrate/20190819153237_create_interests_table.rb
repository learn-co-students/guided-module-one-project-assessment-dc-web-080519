class CreateInterestsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :interests do |t|
      t.string :name
    end
  end
end
