class AddAuthenticationToUsers < ActiveRecord::Migration
  def up
    add_column :users, :role, :integer, default: 0, null: false

    connection.execute(%q{
      /* https://github.com/postgraphql/postgraphql/blob/master/examples/forum/TUTORIAL.md#setting-up-your-schemas */

      CREATE EXTENSION IF NOT EXISTS pgcrypto;

      /* Create role in users */
      /* Roles: public, user, reader, editor, author, admin */

      /* ************************************************************************ */
      /* Create logged_in_user type ********************************************* */

      CREATE TYPE api.logged_in_user AS (
        user_id integer,
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
          INSERT INTO users (first_name, last_name, email, encrypted_password, created_at, updated_at) VALUES
            (first_name, last_name, email, crypt(password, gen_salt('bf')), current_timestamp, current_timestamp)
            RETURNING users.id, users.first_name, users.last_name, users.email INTO person;
          RETURN person;
        END;
      $$ language plpgsql strict security definer;

      COMMENT ON FUNCTION api.register_user(text, text, text, text)
       IS 'Registers a single user with normal permissions.';


       /* *********************************************************************** */
       /* Create found user ***************************************************** */

       CREATE TYPE api.found_user AS (
         user_id integer,
         encrypted_password text
       );

      /* ************************************************************************ */
      /* Create jwt type ******************************************************** */

      CREATE TYPE api.jwt_token AS (
        role text,
        user_id integer
      );

      /* ************************************************************************ */
      /* Create authenticate function ******************************************* */

      CREATE OR REPLACE FUNCTION api.authenticate_user(
        email text,
        password text
      ) RETURNS api.jwt_token AS $$
        DECLARE
          person api.found_user;
        BEGIN
          SELECT id, encrypted_password INTO person
          FROM users
          WHERE users.email = $1;

          IF person.encrypted_password = crypt(password, person.encrypted_password) THEN
            RETURN ('user', person.user_id)::api.jwt_token;
          ELSE
            RETURN null;
          END IF;
        END;
      $$ language plpgsql strict security definer;

      COMMENT ON FUNCTION api.authenticate_user(text, text)
       IS 'Creates a JWT token that will securely identify a person and give them certain permissions.';
    })
  end

  def down
    remove_column :users, :role

    connection.execute(%q{
      COMMENT ON FUNCTION api.register_user(text, text, text, text) IS null;
      DROP FUNCTION api.register_user(text, text, text, text);

      COMMENT ON FUNCTION api.authenticate_user(text, text) IS null;
      DROP FUNCTION api.authenticate_user(text, text);

      DROP TYPE api.found_user;
      DROP TYPE api.logged_in_user;
      DROP TYPE api.jwt_token;
    })
  end
end
