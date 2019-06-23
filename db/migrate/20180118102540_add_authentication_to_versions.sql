class AddAuthenticationToVersions < ActiveRecord::Migration
  def up
    add_column :versions, :role_visibility, :integer, default: 9, null: false

    connection.execute(%q{
      # https://github.com/postgraphql/postgraphql/blob/master/examples/forum/TUTORIAL.md#setting-up-your-schemas

      ALTER TABLE versions ENABLE ROW LEVEL SECURITY;

      CREATE POLICY select_versions on versions FOR SELECT USING (true);

    })
  end

  def down
    remove_column :versions, :role_visibility

    connection.execute(%q{
      ALTER TABLE versions DISABLE ROW LEVEL SECURITY;

      DROP POLICY select_versions;
    })
  end
end
