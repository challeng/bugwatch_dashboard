class AddDateFixedToBugFix < ActiveRecord::Migration
  def change
    add_column :bug_fixes, :date_fixed, :date
  end
end
