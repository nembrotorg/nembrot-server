class AddTextsCitationsLinksFunctions < ActiveRecord::Migration
  def up
    add_column :notes, :cached_source_html, :varchar

    connection.execute(%q{
      CREATE OR REPLACE FUNCTION active_notes_id() RETURNS TABLE(id int) AS $$
        SELECT notes.id
         FROM notes
         WHERE notes.listable = 't'
           AND (notes.role)::user_role <= current_setting('role')::user_role
         ORDER BY weight ASC, external_updated_at DESC
      $$ language sql stable;

      CREATE OR REPLACE FUNCTION api.texts() RETURNS setof notes AS $$
        SELECT *
         FROM notes
         WHERE notes.content_type = 0
           AND notes.listable = 't'
           AND notes.cached_url IS NOT NULL
           AND notes.cached_blurb_html IS NOT NULL
           AND (notes.role)::user_role <= current_setting('role')::user_role
         ORDER BY external_updated_at DESC
      $$ language sql stable;

      CREATE OR REPLACE FUNCTION api.citations() RETURNS setof notes AS $$
        SELECT *
         FROM notes
         WHERE notes.content_type = 1
           AND notes.listable = 't'
           AND notes.cached_url IS NOT NULL
           AND notes.cached_blurb_html IS NOT NULL
           AND notes.cached_source_html IS NOT NULL
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
    remove_column :notes, :cached_source_html

    connection.execute(%q{
      DROP FUNCTION api.active_notes_id();
      DROP FUNCTION api.texts();
      DROP FUNCTION api.citations();
      DROP FUNCTION api.links();
    })
  end
end
