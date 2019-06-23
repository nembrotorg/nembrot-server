class ChangeNoteFunction2 < ActiveRecord::Migration
  def up
    connection.execute(%q{
      DROP VIEW api.texts;
      DROP POLICY select_notes_unregistered ON notes CASCADE;
      DROP POLICY select_notes_registered ON notes CASCADE;

      ALTER TABLE notes DROP COLUMN role;
      ALTER TABLE notes ADD COLUMN role VARCHAR DEFAULT 'unregistered';

      CREATE POLICY select_notes_unregistered ON notes for SELECT TO unregistered
        USING (notes.role = 'unregistered');

      CREATE POLICY select_notes_registered ON notes for SELECT TO registered
        USING ((notes.role)::user_role <= current_setting('jwt.claims.role')::user_role);

      CREATE OR REPLACE FUNCTION api.active_notes() RETURNS setof notes AS $$
        SELECT *
         FROM notes
         WHERE notes.active = 't'
           AND notes.hide = 'f'
           AND (notes.role)::user_role <= current_setting('role')::user_role
         ORDER BY weight ASC, external_updated_at DESC
      $$ language sql stable;
    })
  end

  def down
    connection.execute(%q{
      ALTER TABLE notes DROP COLUMN role;
      DROP FUNCTION api.active_notes() CASCADE;
      DROP POLICY select_notes_unregistered ON notes;
      DROP POLICY select_notes_registered ON notes;
    })
  end
end
