class AddAuthenticationToNotes < ActiveRecord::Migration
  def up
    add_column :notes, :role_visibility, :integer, default: 9, null: false

    connection.execute(%q{
      # https://github.com/postgraphql/postgraphql/blob/master/examples/forum/TUTORIAL.md#setting-up-your-schemas

      ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

      CREATE POLICY select_notes on notes FOR SELECT USING (true);

    })
  end

  def down
    remove_column :notes, :role_visibility

    connection.execute(%q{
      ALTER TABLE notes DISABLE ROW LEVEL SECURITY;

      DROP POLICY select_notes;
    })
  end
end
