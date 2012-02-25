class AddUserToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :user_id, :integer
  end
end
