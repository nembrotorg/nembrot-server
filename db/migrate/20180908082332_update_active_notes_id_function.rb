class UpdateActiveNotesIdFunction < ActiveRecord::Migration
  def up
    connection.execute(%q{
      CREATE OR REPLACE FUNCTION active_notes_id() RETURNS TABLE(id int) AS $$
        SELECT notes.id
         FROM notes
         WHERE notes.active = 't'
           AND notes.hide = 'f'
           AND notes.listable = 't'
           AND (notes.role)::user_role <= current_setting('role')::user_role
         ORDER BY weight ASC, external_updated_at DESC
      $$ language sql stable;
    });
  end

  def down
    connection.execute(%q{
      DROP FUNCTION active_notes_id() CASCADE;
    })
  end
end
