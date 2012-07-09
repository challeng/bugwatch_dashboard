class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.references :repo
      t.string :sha
      t.datetime :deploy_date
      t.string :env

      t.timestamps
    end
    add_index :releases, :repo_id
  end
end
