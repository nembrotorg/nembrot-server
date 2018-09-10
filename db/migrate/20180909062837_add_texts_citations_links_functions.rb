class AddTextsCitationsLinksFunctions < ActiveRecord::Migration
  def up
    connection.execute(%q{
      CREATE OR REPLACE FUNCTION api.texts() RETURNS setof notes AS $$
        SELECT *
         FROM notes
         WHERE notes.content_type = 0
           AND notes.listable = 't'
           AND (notes.role)::user_role <= current_setting('role')::user_role
         ORDER BY external_updated_at DESC
      $$ language sql stable;

      CREATE OR REPLACE FUNCTION api.citations() RETURNS setof notes AS $$
        SELECT *
         FROM notes
         WHERE notes.content_type = 1
           AND notes.listable = 't'
           AND (notes.role)::user_role <= current_setting('role')::user_role
         ORDER BY external_updated_at DESC
      $$ language sql stable;

      CREATE OR REPLACE FUNCTION api.links() RETURNS setof notes AS $$
        SELECT *
         FROM notes
         WHERE notes.content_type = 2
           AND notes.listable = 't'
           AND (notes.role)::user_role <= current_setting('role')::user_role
         ORDER BY external_updated_at DESC
      $$ language sql stable;
    })
  end

  def down
    connection.execute(%q{
      DROP FUNCTION api.texts();
      DROP FUNCTION api.citations();
      DROP FUNCTION api.links();
    })
  end
end
