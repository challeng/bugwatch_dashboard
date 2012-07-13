class AddDateToDefects < ActiveRecord::Migration
  def change
    add_column :defects, :date, :datetime
  end
end
