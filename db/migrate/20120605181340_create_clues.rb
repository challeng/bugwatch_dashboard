class CreateClues < ActiveRecord::Migration
  def change
    create_table :clues do |t|
      t.references :commit
      t.references :mystery

      t.timestamps
    end
    add_index :clues, :commit_id
    add_index :clues, :mystery_id
  end
end
