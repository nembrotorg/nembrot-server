class AddAuthenticationToUsers < ActiveRecord::Migration
  def up
    connection.execute(%q{
      /* https://github.com/postgraphql/postgraphql/blob/master/examples/forum/TUTORIAL.md#setting-up-your-schemas */

      CREATE TYPE user_role AS ENUM ('public', 'registered', 'reader', 'editor', 'author', 'admin');

      ALTER TABLE users ADD COLUMN role user_role;

      CREATE EXTENSION IF NOT EXISTS pgcrypto;

      /* Create role in users */
      /* Roles: unregistered, registered, reader, editor, author, admin */

      /* ************************************************************************ */
      /* Create logged_in_user type ********************************************* */

      CREATE TYPE api.logged_in_user AS (
        user_id integer,
        first_name text,
        last_name text,
        email text,
        role text
      );

      /* ************************************************************************ */
      /* Create registration function ******************************************* */

      CREATE OR REPLACE FUNCTION api.register_user(first_name text, last_name text, email text, password text) RETURNS api.logged_in_user AS $$
        DECLARE
          person api.logged_in_user;
        BEGIN
          INSERT INTO users (first_name, last_name, email, role, encrypted_password, created_at, updated_at) VALUES
            (first_name, last_name, email, 'registered', crypt(password, gen_salt('bf')), current_timestamp, current_timestamp)
            RETURNING users.id, users.first_name, users.last_name, users.email, users.role INTO person;
          RETURN person;
        END;
      $$ language plpgsql strict security definer;

      COMMENT ON FUNCTION api.register_user(text, text, text, text)
       IS 'Registers a single user with normal permissions.';


       /* *********************************************************************** */
       /* Create found user ***************************************************** */

       CREATE TYPE api.found_user AS (
         user_id integer,
         first_name text,
         last_name text,
         role text,
         encrypted_password text
       );

      /* ************************************************************************ */
      /* Create jwt type ******************************************************** */

      CREATE TYPE api.jwt_token AS (
        role text,
        user_id integer,
        first_name text,
        last_name text
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
          SELECT id, first_name, last_name, role, encrypted_password INTO person
          FROM users
          WHERE users.email = $1;

          IF person.encrypted_password = crypt(password, person.encrypted_password) THEN
            RETURN (person.role, person.user_id, person.first_name, person.last_name)::api.jwt_token;
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
    connection.execute(%q{
      ALTER TABLE users DROP COLUMN role;
      DROP TYPE user_role;

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
