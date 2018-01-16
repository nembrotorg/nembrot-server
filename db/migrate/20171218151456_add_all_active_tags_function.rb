class AddAllActiveTagsFunction < ActiveRecord::Migration
  def up
    connection.execute(%q{
      CREATE OR REPLACE FUNCTION all_active_notes_id() RETURNS TABLE(id int) AS $$
        SELECT notes.id
         FROM notes
         WHERE notes.active = 't'
           AND notes.hide = 'f'
         ORDER BY weight ASC, external_updated_at DESC
      $$ language sql stable;

      CREATE TYPE activeTags AS (name varchar(255), slug varchar(255), active_tags_count integer);

      CREATE OR REPLACE FUNCTION all_active_tags() RETURNS setof activeTags AS $$
        SELECT tags.name, tags.slug, active_tags_count
        FROM tags
        JOIN
          (SELECT taggings.tag_id,
                  CAST(COUNT(taggings.tag_id) AS integer) AS active_tags_count
           FROM taggings
           INNER JOIN notes ON notes.id = taggings.taggable_id
           WHERE (taggings.taggable_type = 'Note'
                  AND taggings.context = 'tags')
             AND (taggings.taggable_id IN (all_active_notes_id()))
           GROUP BY taggings.tag_id
           HAVING COUNT(taggings.tag_id) >= 2) AS taggings ON taggings.tag_id = tags.id
        ORDER BY slug
        LIMIT 120
        OFFSET 0
      $$ language sql stable;

      COMMENT ON FUNCTION all_active_tags() IS 'Reads and enables pagination through a set of `Tag` - only tags that are associated with at least two active notes, citations or links are returned.';
    })
  end

  def down
    connection.execute(%q{
      DROP  FUNCTION all_active_notes_id() CASCADE;
      DROP  FUNCTION all_active_tags() CASCADE;
      DROP TYPE activeTags CASCADE;
    })
  end
end
