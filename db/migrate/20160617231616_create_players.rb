class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :game_id, index: true
      t.string :name
      t.integer :final_score

      t.timestamps null: false
    end
  end
end
