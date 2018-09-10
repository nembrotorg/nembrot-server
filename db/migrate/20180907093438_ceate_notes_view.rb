class CeateNotesView < ActiveRecord::Migration
  def up
    connection.execute(%q{
      CREATE OR REPLACE VIEW api.texts AS
        SELECT *
        FROM notes
    })
  end

  def down
    connection.execute(%q{
      DROP VIEW api.texts;
    })
  end
end
