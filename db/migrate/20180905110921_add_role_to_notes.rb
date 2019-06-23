class AddRoleToNotes < ActiveRecord::Migration
  def up
    connection.execute(%q{
      CREATE TYPE user_role AS ENUM ('unregistered', 'registered', 'reader', 'editor', 'author', 'admin');
      ALTER TABLE users ADD COLUMN role user_role;

      ALTER TABLE notes ADD COLUMN role user_role DEFAULT 'unregistered'::user_role;
    })
  end

  def down
    connection.execute(%q{
      ALTER TABLE users DROP COLUMN role;
      ALTER TABLE notes DROP COLUMN role;
      DROP TYPE user_role;
    })
  end
end
