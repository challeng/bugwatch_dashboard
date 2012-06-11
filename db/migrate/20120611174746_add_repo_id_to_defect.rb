class AddRepoIdToDefect < ActiveRecord::Migration
  def change
    add_column :defects, :repo_id, :integer
  end
end
