class RemoveHideAndActiveColumns < ActiveRecord::Migration
  def up
    connection.execute(%q{
      UPDATE notes SET role = 'reader' WHERE title LIKE 'Mintoff Alla: %';   
    })

    remove_column :notes, :hide
    remove_column :notes, :active
    remove_column :notes, :is_citation
  end

  def down
    add_column :notes, :hide, :boolean
    add_column :notes, :active, :boolean
    add_column :notes, :is_citation, :boolean
  end
end
