class AddDateToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :date, :datetime
  end
end
