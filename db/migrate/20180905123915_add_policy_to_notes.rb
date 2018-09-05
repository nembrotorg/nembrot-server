class AddPolicyToNotes < ActiveRecord::Migration
  def up
    connection.execute(%q{
      CREATE POLICY select_notes_unregistered ON notes for SELECT TO unregistered
        using (role = 'unregistered'::user_role);

      CREATE POLICY select_notes_registered ON notes for SELECT TO registered
        using (role <= current_setting('jwt.claims.role')::user_role);
    })
  end

  def down
    connection.execute(%q{
      DROP POLICY select_notes_unregistered ON notes;
      DROP POLICY select_notes_registered ON notes;
    })
  end
end
