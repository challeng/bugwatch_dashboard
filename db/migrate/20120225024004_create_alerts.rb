class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.references :commit
      t.string :file
      t.string :klass
      t.string :function

      t.timestamps
    end
    add_index :alerts, :commit_id
  end
end
