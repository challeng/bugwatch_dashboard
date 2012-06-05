class CreateMysteries < ActiveRecord::Migration
  def change
    create_table :mysteries do |t|
      t.string :exception_type
      t.string :backtrace

      t.timestamps
    end
  end
end
