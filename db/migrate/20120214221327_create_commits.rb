class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.string :sha
      t.references :repo

      t.timestamps
    end
    add_index :commits, :sha, :unique => true
  end
end
