class UpdatePermissionsAgain2 < ActiveRecord::Migration
  def change
    connection.execute(%q{
      GRANT USAGE ON SCHEMA api TO unregistered;

      GRANT unregistered TO registered;
      GRANT unregistered TO reader;
      GRANT unregistered TO editor;
      GRANT unregistered TO author;
      GRANT unregistered TO admin;
    });
  end
end
