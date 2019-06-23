class UpdatePermissionsAgain < ActiveRecord::Migration
  def change
    connection.execute(%q{
      ALTER DEFAULT PRIVILEGES IN SCHEMA api GRANT SELECT ON TABLES TO unregistered;

      GRANT unregistered TO registered;
      GRANT unregistered TO reader;
      GRANT unregistered TO editor;
      GRANT unregistered TO author;
      GRANT unregistered TO admin;
    });
  end
end
