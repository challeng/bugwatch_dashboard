class AddTypeAndStatusToDefect < ActiveRecord::Migration
  def change
    add_column :defects, :type, :string

    add_column :defects, :status, :integer
  end
end
