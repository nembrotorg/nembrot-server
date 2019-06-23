class CreateGetNoteFunctions < ActiveRecord::Migration
  def up
    connection.execute(%q{
      CREATE OR REPLACE FUNCTION api.text(uid integer) RETURNS notes AS $$
        SELECT *
         FROM notes
         WHERE notes.id = uid
           AND notes.content_type = 0
           AND (notes.role)::user_role <= current_setting('role')::user_role
      $$ language sql stable;

      CREATE OR REPLACE FUNCTION api.citation(uid integer) RETURNS notes AS $$
        SELECT *
         FROM notes
         WHERE notes.id = uid
           AND notes.content_type = 1
           AND (notes.role)::user_role <= current_setting('role')::user_role
      $$ language sql stable;

      CREATE OR REPLACE FUNCTION api.link(uid integer) RETURNS notes AS $$
        SELECT *
         FROM notes
         WHERE notes.id = uid
           AND notes.content_type = 2
           AND (notes.role)::user_role <= current_setting('role')::user_role
      $$ language sql stable;
    })
  end

  def down
    connection.execute(%q{
      DROP FUNCTION api.text();
      DROP FUNCTION api.citation();
      DROP FUNCTION api.link();
    })
  end
end
