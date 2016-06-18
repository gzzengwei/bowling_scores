class CreateFrames < ActiveRecord::Migration
  def change
    create_table :frames do |t|
      t.integer :player_id, index: true
      t.integer :round
      t.integer :roll_1
      t.integer :roll_2
      t.integer :roll_3

      t.timestamps null: false
    end
  end
end
