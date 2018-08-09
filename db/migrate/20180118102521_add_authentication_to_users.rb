class AddAuthenticationToUsers < ActiveRecord::Migration
  def up
    add_column :users, :role, :integer, default: 0, null: false

    connection.execute(%q{
      /* https://github.com/postgraphql/postgraphql/blob/master/examples/forum/TUTORIAL.md#setting-up-your-schemas */

      CREATE EXTENSION IF NOT EXISTS pgcrypto;

      /* Create role in users */
      /* Roles: public, user, reader, editor, author, admin */

      /* ************************************************************************ */
      /* Create jwt type ******************************************************** */

      CREATE TYPE api.logged_in_user AS (
        first_name text,
        last_name text,
        email text
      );

      /* ************************************************************************ */
      /* Create registration function ******************************************* */

      CREATE OR REPLACE FUNCTION api.register_user(first_name text, last_name text, email text, password text) RETURNS api.logged_in_user AS $$
        DECLARE
          person api.logged_in_user;
        BEGIN
          INSERT INTO users (first_name, last_name, email, password, created_at, updated_at) VALUES
            (first_name, last_name, email, crypt(password, gen_salt('bf')), current_timestamp, current_timestamp)
            RETURNING * INTO person;
          RETURN person;
        END;
      $$ language plpgsql strict security definer;

      COMMENT ON FUNCTION api.register_user(text, text, text, text) IS 'Registers a single user with normal permissions.';


      /* ************************************************************************ */
      /* Create jwt type ******************************************************** */

      CREATE TYPE api.jwt_token AS (
        role integer,
        user_id integer
      );


      /* ************************************************************************ */
      /* Create authenticate function ******************************************* */

      CREATE OR REPLACE FUNCTION api.authenticate(
        email text,
        password text
      ) RETURNS api.jwt_token AS $$
        BEGIN
          SELECT a.* AS authenticated_user
          FROM users AS a
          WHERE a.email = $1;

          IF password = crypt(password, gen_salt('bf')) THEN
            RETURN ('user', authenticated_user.id)::api.jwt_token;
          ELSE
            RETURN null;
          END IF;
        END;
      $$ language plpgsql strict security definer;

      COMMENT ON FUNCTION api.authenticate(text, text) IS 'Creates a JWT token that will securely identify a person and give them certain permissions.';
    })
  end

  def down
    remove_column :users, :role

    connection.execute(%q{
      COMMENT ON FUNCTION api.register_user(text, text, text, text) IS null;
      DROP FUNCTION api.register_user(text, text, text, text);

      COMMENT ON FUNCTION api.authenticate(text, text) IS null;
      DROP FUNCTION api.authenticate(text, text);

      DROP TYPE api.logged_in_user;
      DROP TYPE api.jwt_token;
    })
  end
end
