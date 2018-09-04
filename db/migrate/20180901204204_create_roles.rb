class CreateRoles < ActiveRecord::Migration
  def up
    connection.execute(%q{
      CREATE ROLE unregistered;
      CREATE ROLE registered;
      CREATE ROLE reader;
      CREATE ROLE editor;
      CREATE ROLE author;
      CREATE ROLE admin;
    })
  end

  def down
    connection.execute(%q{
      DROP ROLE unregistered;
      DROP ROLE registered;
      DROP ROLE reader;
      DROP ROLE editor;
      DROP ROLE author;
    })
  end
end
