class CreateDefects < ActiveRecord::Migration
  def change
    create_table :defects do |t|
      t.string :priority
      t.string :title
      t.string :ticket_id

      t.timestamps
    end
  end
end
