class GrantPermissions < ActiveRecord::Migration
  def change
    connection.execute(%q{
      GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA api TO unregistered;
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO unregistered;

      GRANT unregistered TO registered;
      GRANT unregistered TO reader;
      GRANT unregistered TO editor;
      GRANT unregistered TO author;
      GRANT unregistered TO admin;
    });
  end
end
