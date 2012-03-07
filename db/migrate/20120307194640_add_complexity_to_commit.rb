class AddComplexityToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :complexity, :float
  end
end
