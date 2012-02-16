class CreateBugFixes < ActiveRecord::Migration
  def change
    create_table :bug_fixes do |t|
      t.references :commit
      t.string :file
      t.string :klass
      t.string :function

      t.timestamps
    end
    add_index :bug_fixes, :commit_id
  end
end
