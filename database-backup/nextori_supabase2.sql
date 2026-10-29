--
-- PostgreSQL database dump
--

\restrict h5UKgP9ys5gz39OhcDurLRwjEg834tBWjWkZSxaVM4QHYKqiWXlFbFRdwhAWUXj

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone',
    'recovery_code'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in',
    'like',
    'ilike',
    'is',
    'match',
    'imatch',
    'isdistinct'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text,
	negate boolean
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
    revoke trigger on cron.job_run_details from postgres;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $_$
begin
    if not exists (
        select 1
        from pg_catalog.pg_event_trigger_ddl_commands() ev
        join pg_catalog.pg_extension e on ev.objid = e.oid
        where e.extname = 'pg_graphql'
    ) then
        return;
    end if;

    drop function if exists graphql_public.graphql;
    create or replace function graphql_public.graphql(
        "operationName" text default null,
        query text default null,
        variables jsonb default null,
        extensions jsonb default null
    )
        returns jsonb
        language sql
    as $$
        select graphql.resolve(
            query := query,
            variables := coalesce(variables, '{}'),
            "operationName" := "operationName",
            extensions := extensions
        );
    $$;

    -- Attach the wrapper to the extension so DROP EXTENSION cascades to it,
    -- which in turn triggers set_graphql_placeholder to reinstall the "not enabled" stub.
    alter extension pg_graphql add function graphql_public.graphql(text, text, jsonb, jsonb);

    grant usage on schema graphql to postgres, anon, authenticated, service_role;
    grant execute on function graphql.resolve to postgres, anon, authenticated, service_role;
    grant usage on schema graphql to postgres with grant option;
    grant usage on schema graphql_public to postgres with grant option;
end;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8.0', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
            set search_path to ''
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: graphql(text, text, jsonb, jsonb); Type: FUNCTION; Schema: graphql_public; Owner: -
--

CREATE FUNCTION graphql_public.graphql("operationName" text DEFAULT NULL::text, query text DEFAULT NULL::text, variables jsonb DEFAULT NULL::jsonb, extensions jsonb DEFAULT NULL::jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
    -- Regclass of the table e.g. public.notes
    entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

    -- I, U, D, T: insert, update ...
    action realtime.action = (
        case wal ->> 'action'
            when 'I' then 'INSERT'
            when 'U' then 'UPDATE'
            when 'D' then 'DELETE'
            else 'ERROR'
        end
    );

    -- Is row level security enabled for the table
    is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

    subscriptions realtime.subscription[] = array_agg(subs)
        from
            realtime.subscription subs
        where
            subs.entity = entity_
            -- Filter by action early - only get subscriptions interested in this action
            -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
            and (subs.action_filter = '*' or subs.action_filter = action::text);

    -- Subscription vars
    working_role regrole;
    working_selected_columns text[];
    claimed_role regrole;
    claims jsonb;

    subscription_id uuid;
    subscription_has_access bool;
    visible_to_subscription_ids uuid[] = '{}';

    -- structured info for wal's columns
    columns realtime.wal_column[];
    -- previous identity values for update/delete
    old_columns realtime.wal_column[];

    error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

    -- Primary jsonb output for record
    output jsonb;

    -- Loop record for iterating unique roles (outer loop)
    role_record record;
    -- Loop record for iterating unique selected_columns within a role (inner loop)
    cols_record record;
    -- Subscription ids visible at the role level (before fanning out by selected_columns)
    visible_role_sub_ids uuid[] = '{}';

begin
    perform set_config('role', null, true);

    columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'columns') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    old_columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'identity') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    for role_record in
        select claims_role
        from (select distinct claims_role from unnest(subscriptions)) t
        order by claims_role::text
    loop
        working_role := role_record.claims_role;

        -- Update `is_selectable` for columns and old_columns (once per role)
        columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(columns) c;

        old_columns =
                array_agg(
                    (
                        c.name,
                        c.type_name,
                        c.type_oid,
                        c.value,
                        c.is_pkey,
                        pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                    )::realtime.wal_column
                )
                from
                    unnest(old_columns) c;

        if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
            -- Fan out 400 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 400: Bad Request, no primary key']
                )::realtime.wal_rls;
            end loop;

        -- The claims role does not have SELECT permission to the primary key of entity
        elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
            -- Fan out 401 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 401: Unauthorized']
                )::realtime.wal_rls;
            end loop;

        else
            -- Create the prepared statement (once per role)
            if is_rls_enabled and action <> 'DELETE' then
                if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                    deallocate walrus_rls_stmt;
                end if;
                execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
            end if;

            -- Collect all visible subscription IDs for this role (filter check + RLS check)
            visible_role_sub_ids = '{}';

            for subscription_id, claims in (
                    select
                        subs.subscription_id,
                        subs.claims
                    from
                        unnest(subscriptions) subs
                    where
                        subs.entity = entity_
                        and subs.claims_role = working_role
                        and (
                            realtime.is_visible_through_filters(columns, subs.filters)
                            or (
                              action = 'DELETE'
                              and realtime.is_visible_through_filters(old_columns, subs.filters)
                            )
                        )
            ) loop

                if not is_rls_enabled or action = 'DELETE' then
                    visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                else
                    -- Check if RLS allows the role to see the record
                    perform
                        -- Trim leading and trailing quotes from working_role because set_config
                        -- doesn't recognize the role as valid if they are included
                        set_config('role', trim(both '"' from working_role::text), true),
                        set_config('request.jwt.claims', claims::text, true);

                    execute 'execute walrus_rls_stmt' into subscription_has_access;

                    -- Reset the role on every FOR..LOOP batch execution.
                    -- The first batch of 10 rows is pre-fetched using the current connection role (PG internal behaviour)
                    -- then we have to reset it again otherwise it would use the role defined in the `set_config` above
                    -- to fetch the remaining rows when rows>10, which could be a user-defined role that lacks execution grants.
                    -- The flow is:
                    --   1. run batch with conn role
                    --   2. set_config working_role
                    --   3. execute walrus
                    --   4. reset role (revert)
                    --   5. repeat
                    perform set_config('role', null, true);

                    if subscription_has_access then
                        visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                    end if;
                end if;
            end loop;

            perform set_config('role', null, true);

            -- Inner loop: per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;

                output = jsonb_build_object(
                    'schema', wal ->> 'schema',
                    'table', wal ->> 'table',
                    'type', action,
                    'commit_timestamp', to_char(
                        ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                        'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
                    ),
                    'columns', (
                        select
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', pa.attname,
                                    'type', pt.typname
                                )
                                order by pa.attnum asc
                            )
                        from
                            pg_attribute pa
                            join pg_type pt
                                on pa.atttypid = pt.oid
                            left join (
                                select unnest(conkey) as pkey_attnum
                                from pg_constraint
                                where conrelid = entity_ and contype = 'p'
                            ) pk on pk.pkey_attnum = pa.attnum
                        where
                            attrelid = entity_
                            and attnum > 0
                            and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                            and (working_selected_columns is null or pa.attname = any(working_selected_columns) or pk.pkey_attnum is not null)
                    )
                )
                -- Add "record" key for insert and update
                || case
                    when action in ('INSERT', 'UPDATE') then
                        jsonb_build_object(
                            'record',
                            (
                                select
                                    jsonb_object_agg(
                                        -- if unchanged toast, get column name and value from old record
                                        coalesce((c).name, (oc).name),
                                        case
                                            when (c).name is null then (oc).value
                                            else (c).value
                                        end
                                    )
                                from
                                    unnest(columns) c
                                    full outer join unnest(old_columns) oc
                                        on (c).name = (oc).name
                                where
                                    coalesce((c).is_selectable, (oc).is_selectable)
                                    and (working_selected_columns is null or coalesce((c).name, (oc).name) = any(working_selected_columns) or coalesce((c).is_pkey, (oc).is_pkey))
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            )
                        )
                    else '{}'::jsonb
                end
                -- Add "old_record" key for update and delete
                || case
                    when action = 'UPDATE' then
                        jsonb_build_object(
                                'old_record',
                                (
                                    select jsonb_object_agg((c).name, (c).value)
                                    from unnest(old_columns) c
                                    where
                                        (c).is_selectable
                                        and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                        and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                )
                            )
                    when action = 'DELETE' then
                        jsonb_build_object(
                            'old_record',
                            (
                                select jsonb_object_agg((c).name, (c).value)
                                from unnest(old_columns) c
                                where
                                    (c).is_selectable
                                    and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                    and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                            )
                        )
                    else '{}'::jsonb
                end;

                -- Filter visible_role_sub_ids to those matching the current selected_columns group
                visible_to_subscription_ids = coalesce(
                    (
                        select array_agg(s.subscription_id)
                        from unnest(subscriptions) s
                        where s.claims_role = working_role
                          and (s.selected_columns is not distinct from working_selected_columns)
                          and s.subscription_id = any(visible_role_sub_ids)
                    ),
                    '{}'::uuid[]
                );

                return next (
                    output,
                    is_rls_enabled,
                    visible_to_subscription_ids,
                    case
                        when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                        else '{}'
                    end
                )::realtime.wal_rls;
            end loop;

        end if;
    end loop;

    perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*
Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
*/
declare
    op_symbol text = (
        case
            when op = 'eq' then '='
            when op = 'neq' then '!='
            when op = 'lt' then '<'
            when op = 'lte' then '<='
            when op = 'gt' then '>'
            when op = 'gte' then '>='
            when op = 'in' then '= any'
            else 'UNKNOWN OP'
        end
    );
    res boolean;
begin
    execute format(
        'select %L::'|| type_::text || ' ' || op_symbol
        || ' ( %L::'
        || (
            case
                when op = 'in' then type_::text || '[]'
                else type_::text end
        )
        || ')', val_1, val_2) into res;
    return res;
end;
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
declare
    op_symbol text;
    res boolean;
begin
    -- IS DISTINCT FROM / IS NOT DISTINCT FROM: infix, both sides typed literals
    if op = 'isdistinct' then
        execute format(
            'select %L::%s %s %L::%s',
            val_1,
            type_::text,
            case when negate then 'IS NOT DISTINCT FROM' else 'IS DISTINCT FROM' end,
            val_2,
            type_::text
        ) into res;
        return res;
    end if;

    -- IS requires a keyword RHS (NULL, TRUE, FALSE, UNKNOWN), not a typed literal
    if op = 'is' then
        if val_2 not in ('null', 'true', 'false', 'unknown') then
            raise exception 'invalid value for is filter: must be null, true, false, or unknown';
        end if;
        execute format(
            'select %L::%s %s %s',
            val_1,
            type_::text,
            case when negate then 'IS NOT' else 'IS' end,
            upper(val_2)
        ) into res;
        return res;
    end if;

    op_symbol = case
        when op = 'eq'    then '='
        when op = 'neq'   then '!='
        when op = 'lt'    then '<'
        when op = 'lte'   then '<='
        when op = 'gt'    then '>'
        when op = 'gte'   then '>='
        when op = 'in'    then '= any'
        when op = 'like'   then 'LIKE'
        when op = 'ilike'  then 'ILIKE'
        when op = 'match'  then '~'
        when op = 'imatch' then '~*'
        else null
    end;

    if op_symbol is null then
        raise exception 'unsupported equality operator: %', op::text;
    end if;

    execute format(
        'select %L::%s %s (%L::%s)',
        val_1,
        type_::text,
        op_symbol,
        val_2,
        case when op = 'in' then type_::text || '[]' else type_::text end
    ) into res;

    return case when negate then not res else res end;
end;
$$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
    select
        filters is null
        or array_length(filters, 1) is null
        or coalesce(
            count(col.name) = count(1)
            and sum(
                realtime.check_equality_op(
                    op:=f.op,
                    type_:=coalesce(col.type_oid::regtype, col.type_name::regtype),
                    val_1:=col.value #>> '{}',
                    val_2:=f.value,
                    negate:=coalesce(f.negate, false)
                )::int
            ) filter (where col.name is not null) = count(col.name),
            false
        )
    from
        unnest(filters) f
        left join unnest(columns) col
            on f.column_name = col.name;
$$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures pg_logical_slot_get_changes is called exactly once
  w2j AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         pg_logical_slot_get_changes(
           slot_name, null, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM w2j
    WHERE w2j.w2j_add_tables <> ''
  ),
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM w2j,
         realtime.apply_rls(
           wal := w2j.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE w2j.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  SELECT
    realtime.wal2json_escape_identifier(nsp.nspname::text)
    || '.'
    || realtime.wal2json_escape_identifier(pc.relname::text)
  FROM pg_class pc
  JOIN pg_namespace nsp ON pc.relnamespace = nsp.oid
  WHERE pc.oid = entity
$$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: send_binary(bytea, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, binary_payload, event, topic, private, extension)
    VALUES (generated_id, payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    col_names text[] = coalesce(
            array_agg(a.attname order by a.attnum),
            '{}'::text[]
        )
        from
            pg_catalog.pg_attribute a
        where
            a.attrelid = new.entity
            and a.attnum > 0
            and not a.attisdropped
            and pg_catalog.has_column_privilege(
                (new.claims ->> 'role'),
                a.attrelid,
                a.attnum,
                'SELECT'
            );
    filter realtime.user_defined_filter;
    col_type regtype;
    in_val jsonb;
    selected_col text;
begin
    for filter in select * from unnest(new.filters) loop
        if not filter.column_name = any(col_names) then
            raise exception 'invalid column for filter %', filter.column_name;
        end if;

        col_type = (
            select atttypid::regtype
            from pg_catalog.pg_attribute
            where attrelid = new.entity
                  and attname = filter.column_name
        );
        if col_type is null then
            raise exception 'failed to lookup type for column %', filter.column_name;
        end if;

        if filter.op = 'in'::realtime.equality_op then
            in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
            if coalesce(jsonb_array_length(in_val), 0) > 100 then
                raise exception 'too many values for `in` filter. Maximum 100';
            end if;
        elsif filter.op = 'is'::realtime.equality_op then
            -- `is` requires a keyword RHS rather than a typed literal
            if filter.value not in ('null', 'true', 'false', 'unknown') then
                raise exception 'invalid value for is filter: must be null, true, false, or unknown';
            end if;
            -- IS NULL works for any type, but IS TRUE/FALSE/UNKNOWN require a boolean
            -- operand. Reject the non-null keywords on non-boolean columns here so they
            -- don't abort apply_rls at WAL time.
            if filter.value <> 'null' and col_type <> 'boolean'::regtype then
                raise exception 'is % filter requires a boolean column, got %', filter.value, col_type::text;
            end if;
        elsif filter.op in ('like'::realtime.equality_op, 'ilike'::realtime.equality_op) then
            -- like/ilike apply the text pattern operator (~~); reject column types that
            -- have no such operator instead of failing at WAL time
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = '~~' and oprleft = col_type
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
        elsif filter.op in ('match'::realtime.equality_op, 'imatch'::realtime.equality_op) then
            -- match/imatch apply the regex operators ~ / ~*; reject column types that have
            -- no such operator (e.g. integer) instead of failing at WAL time, mirroring the
            -- like/ilike guard above.
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = case when filter.op = 'imatch'::realtime.equality_op then '~*' else '~' end
                  and oprleft = col_type
                  and oprright = col_type
                  and oprresult = 'boolean'::regtype
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
            -- validate the regex eagerly so a bad pattern is rejected here, not inside
            -- apply_rls where it would abort the WAL stream for the entity
            begin
                perform '' ~ filter.value;
            exception when others then
                raise exception 'invalid regular expression for % filter: %', filter.op::text, sqlerrm;
            end;
        else
            -- eq/neq/lt/lte/gt/gte: value must be coercable to the type
            perform realtime.cast(filter.value, col_type);
        end if;
    end loop;

    if new.selected_columns is not null then
        for selected_col in select * from unnest(new.selected_columns) loop
            if not selected_col = any(col_names) then
                raise exception 'invalid column for select %', selected_col;
            end if;
        end loop;
    end if;

    -- Apply consistent order to filters so the unique constraint can't be tricked by a
    -- different filter order. negate is part of the sort key.
    new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value, f.negate),
        '{}'
    ) from unnest(new.filters) f;

    -- Normalize selected_columns order so ARRAY['a','b'] and ARRAY['b','a'] are treated
    -- as the same subscription group in apply_rls. Preserve an empty array as '{}'
    -- ("primary keys only") so it stays distinct from NULL ("all columns"); array_agg
    -- over an empty set would otherwise collapse '{}' back to NULL.
    if new.selected_columns is not null then
        new.selected_columns = coalesce(
            (
                select array_agg(c order by c)
                from unnest(new.selected_columns) c
            ),
            '{}'::text[]
        );
    end if;

    return new;
end;
$$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: wal2json_escape_identifier(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.wal2json_escape_identifier(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  -- Prefix `\`, `,`, `.`, and any whitespace with `\`
  SELECT regexp_replace(name, '([\\,.[:space:]])', '\\\1', 'g')
$$;


--
-- Name: allow_any_operation(text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_any_operation(expected_operations text[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$$;


--
-- Name: allow_only_operation(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_only_operation(expected_operation text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: enforce_bucket_lifecycle_service_role(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_lifecycle_service_role() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
  IF current_user::text IS DISTINCT FROM TG_ARGV[0]
     AND (
       OLD.lifecycle_configuration IS DISTINCT FROM NEW.lifecycle_configuration
       OR OLD.lifecycle_configuration_generation IS DISTINCT FROM NEW.lifecycle_configuration_generation
     ) THEN
    -- AFTER runs only after caller RLS has accepted the proposed row. The API
    -- recognizes this specific error after rolling back its permission probe;
    -- direct non-service writes still fail and cannot persist the change.
    RAISE EXCEPTION 'bucket control columns may only be changed by the configured storage service role'
      USING ERRCODE = 'PST01',
            SCHEMA = TG_TABLE_SCHEMA,
            TABLE = TG_TABLE_NAME,
            CONSTRAINT = TG_NAME;
  END IF;

  RETURN NULL;
END;
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    RETURN _parts[array_length(_parts, 1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN p_delimiter <> ''
         AND position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(
        p_key,
        length(p_prefix)
            + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1))
            + length(p_delimiter) - 1
    )
    ELSE NULL
END;
$$;


--
-- Name: get_size_by_bucket(text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket(noncurrent_versions text DEFAULT 'include'::text, delete_markers text DEFAULT 'include'::text) RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'include');
    delete_markers := COALESCE(delete_markers, 'include');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'include';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'include';
    END IF;

    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        where (noncurrent_versions != 'exclude' OR obj.archived_at IS NULL)
          and (noncurrent_versions != 'only' OR obj.archived_at IS NOT NULL)
          and (delete_markers != 'exclude' OR NOT obj.is_delete_marker)
          and (delete_markers != 'only' OR obj.is_delete_marker)
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text, raw_prefix_param text DEFAULT NULL::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE sql STABLE
    AS $_$
WITH candidates AS (
    SELECT
        upload.key AS object_key,
        CASE
            WHEN position($3 IN substring(upload.key FROM length(coalesce($7, $2)) + 1)) > 0
            THEN left(
                upload.key,
                length(coalesce($7, $2))
                    + position($3 IN substring(upload.key FROM length(coalesce($7, $2)) + 1))
                    + length($3) - 1
            )
            ELSE upload.key
        END AS result_key,
        upload.id,
        upload.created_at,
        position($3 IN substring(upload.key FROM length(coalesce($7, $2)) + 1)) > 0 AS is_common_prefix
    FROM storage.s3_multipart_uploads AS upload
    WHERE upload.bucket_id = $1
      AND upload.key COLLATE "C" LIKE $2 || '%'
), filtered AS (
    SELECT candidate.*
    FROM candidates AS candidate
    WHERE $5 = ''
       OR candidate.result_key COLLATE "C" > $5
       OR (
           candidate.result_key COLLATE "C" = $5
           AND NOT candidate.is_common_prefix
           AND $6 <> ''
           -- A completed or aborted marker repeats the remaining same-key uploads.
           AND COALESCE(
               (candidate.created_at, candidate.id COLLATE "C") > (
                   SELECT marker.created_at, marker.id COLLATE "C"
                   FROM storage.s3_multipart_uploads AS marker
                   WHERE marker.bucket_id = $1
                     AND marker.key COLLATE "C" = $5
                     AND marker.id = $6
               ),
               TRUE
           )
       )
), ranked AS (
    SELECT
        filtered.*,
        row_number() OVER (
            PARTITION BY filtered.result_key COLLATE "C"
            ORDER BY filtered.created_at, filtered.id COLLATE "C"
        ) AS prefix_rank
    FROM filtered
)
SELECT ranked.result_key, ranked.id, ranked.created_at
FROM ranked
WHERE NOT ranked.is_common_prefix OR ranked.prefix_rank = 1
ORDER BY ranked.result_key COLLATE "C", ranked.created_at, ranked.id COLLATE "C"
LIMIT $4;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text, text, text, timestamp with time zone, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text, next_token_archived_at timestamp with time zone DEFAULT NULL::timestamp with time zone, next_token_version text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_start_relative TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;
    v_version_filter TEXT;

    -- true when noncurrent_versions can return >1 row per name; keeps them
    -- ordered most-recent-first and lets pagination resume mid-key
    v_multi_row BOOLEAN;
    v_name_order TEXT;
    v_exact_range_predicate TEXT;
    v_strict_range_predicate TEXT;
    v_inclusive_range_predicate TEXT;

    -- Seek state for the current name. archived_at is normalized to JavaScript's
    -- millisecond precision and version breaks ties within the same millisecond.
    -- Current rows use 'infinity'; NULL means no tiebreak has been established.
    v_next_seek TEXT;
    v_next_seek_at TIMESTAMPTZ;
    v_next_seek_version TEXT;
    v_next_seek_strict BOOLEAN := false;
    v_cursor_is_folder BOOLEAN;
    v_count INT := 0;
    v_previous_seek TEXT;
    v_previous_seek_at TIMESTAMPTZ;
    v_previous_seek_version TEXT;
    v_previous_count INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;
    v_batch_query_strict TEXT;
    v_delete_marker_peek_query TEXT;
    v_delete_marker_peek_query_strict TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);
    v_next_seek_at := NULL;
    v_next_seek_version := '';

    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'exclude');
    delete_markers := COALESCE(delete_markers, 'exclude');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'exclude';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'exclude';
    END IF;

    v_multi_row := noncurrent_versions IN ('only', 'include');
    v_name_order := CASE WHEN v_is_asc THEN 'ASC' ELSE 'DESC' END;

    v_version_filter := '';
    IF noncurrent_versions = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NULL';
    ELSIF noncurrent_versions = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NOT NULL';
    END IF;
    IF delete_markers = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND NOT o.is_delete_marker';
    ELSIF delete_markers = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.is_delete_marker';
    END IF;

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Keep caller-provided cursors inside the requested prefix range.
    IF v_start <> '' AND v_upper_bound IS NOT NULL THEN
        IF v_is_asc THEN
            IF v_start COLLATE "C" < v_prefix COLLATE "C" THEN
                v_start := '';
            ELSIF v_start COLLATE "C" >= v_upper_bound COLLATE "C" THEN
                RETURN;
            END IF;
        ELSE
            IF v_start COLLATE "C" < v_prefix COLLATE "C" THEN
                RETURN;
            ELSIF v_start COLLATE "C" >= v_upper_bound COLLATE "C" THEN
                v_start := '';
            END IF;
        END IF;
    END IF;

    v_start_relative := substring(v_start FROM length(v_prefix) + 1);

    -- Direction affects only the indexed name range and its ordering. Cursor
    -- state transitions and within-key version ordering stay shared.
    IF v_is_asc THEN
        v_exact_range_predicate := 'TRUE';
        v_strict_range_predicate := 'o.name COLLATE "C" > $2';
        v_inclusive_range_predicate := 'o.name COLLATE "C" >= $2';
        IF v_upper_bound IS NOT NULL THEN
            v_exact_range_predicate := 'o.name COLLATE "C" < $3';
            v_strict_range_predicate := v_strict_range_predicate || ' AND o.name COLLATE "C" < $3';
            v_inclusive_range_predicate := v_inclusive_range_predicate || ' AND o.name COLLATE "C" < $3';
        END IF;
    ELSE
        v_exact_range_predicate := 'TRUE';
        v_strict_range_predicate := 'o.name COLLATE "C" < $2';
        v_inclusive_range_predicate := 'o.name COLLATE "C" < $2';
        IF v_prefix <> '' THEN
            v_exact_range_predicate := 'o.name COLLATE "C" >= $3';
            v_strict_range_predicate := v_strict_range_predicate || ' AND o.name COLLATE "C" >= $3';
            v_inclusive_range_predicate := v_inclusive_range_predicate || ' AND o.name COLLATE "C" >= $3';
        END IF;
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    -- The multi-row order matches the externally serialized cursor exactly:
    -- archived_at at millisecond precision, then version as the final tiebreak.
    --
    -- When v_multi_row, the seek is a keyset tuple comparison ("name > $2 OR
    -- (name = $2 AND tiebreak)") - Postgres won't split that OR into indexable
    -- form (confirmed even with fully literal values), so as one WHERE clause
    -- it forces a full bucket scan filtered row-by-row. Splitting it into two
    -- independently-indexable branches (exact name match with the tiebreak
    -- filter, vs. strictly-past names) combined with UNION ALL lets each
    -- branch keep name as a real index condition; the outer ORDER BY/LIMIT
    -- re-merges them into the same page the single query used to produce.
    IF v_multi_row THEN
        v_batch_query := format(
            $sql$
            SELECT *
            FROM (
                (
                    SELECT o.name, o.id, o.updated_at, o.created_at,
                           o.last_accessed_at, o.metadata, o.version,
                           o.archived_at, o.is_delete_marker, o.is_versioned
                    FROM storage.objects o
                    WHERE o.bucket_id = $1
                      AND o.name COLLATE "C" = $2
                      AND %s
                      AND NOT $7::boolean
                      AND (
                          $5::timestamptz IS NULL
                          OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < $5
                          OR (
                              COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = $5
                              AND COALESCE(o.version, '') > $6
                          )
                      )
                      %s
                    ORDER BY
                        COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC,
                        COALESCE(o.version, '') ASC
                    LIMIT $4
                )
                UNION ALL
                (
                    SELECT o.name, o.id, o.updated_at, o.created_at,
                           o.last_accessed_at, o.metadata, o.version,
                           o.archived_at, o.is_delete_marker, o.is_versioned
                    FROM storage.objects o
                    WHERE o.bucket_id = $1
                      AND %s
                      %s
                    ORDER BY
                        o.name COLLATE "C" %s,
                        COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC,
                        COALESCE(o.version, '') ASC
                    LIMIT $4
                )
            ) sub
            ORDER BY
                sub.name COLLATE "C" %s,
                COALESCE(date_trunc('milliseconds', sub.archived_at), 'infinity'::timestamptz) DESC,
                COALESCE(sub.version, '') ASC
            LIMIT $4
            $sql$,
            v_exact_range_predicate,
            v_version_filter,
            v_strict_range_predicate,
            v_version_filter,
            v_name_order,
            v_name_order
        );
    ELSE
        v_batch_query := format(
            $sql$
            SELECT o.name, o.id, o.updated_at, o.created_at,
                   o.last_accessed_at, o.metadata, o.version,
                   o.archived_at, o.is_delete_marker, o.is_versioned
            FROM storage.objects o
            WHERE o.bucket_id = $1
              AND %s
              %s
            ORDER BY o.name COLLATE "C" %s, o.archived_at DESC
            LIMIT $4
            $sql$,
            v_inclusive_range_predicate,
            v_version_filter,
            v_name_order
        );

        -- Strict counterpart of the query above: used once the single-row
        -- ASC batch advance (below) has left v_next_seek pointing at the
        -- last row already emitted, so an inclusive predicate would
        -- re-match it forever. Only single-row mode ever sets strict mode,
        -- so this variant is never needed when v_multi_row.
        v_batch_query_strict := format(
            $sql$
            SELECT o.name, o.id, o.updated_at, o.created_at,
                   o.last_accessed_at, o.metadata, o.version,
                   o.archived_at, o.is_delete_marker, o.is_versioned
            FROM storage.objects o
            WHERE o.bucket_id = $1
              AND %s
              %s
            ORDER BY o.name COLLATE "C" %s, o.archived_at DESC
            LIMIT $4
            $sql$,
            v_strict_range_predicate,
            v_version_filter,
            v_name_order
        );
    END IF;

    -- The static peek predicates cannot use the partial delete-marker index
    -- once PL/pgSQL switches to a generic plan because whether
    -- is_delete_marker is required remains parameter-dependent. Reuse the
    -- already-specialized batch query with a one-row limit for this sparse
    -- filter so the plan sees a literal `o.is_delete_marker` predicate.
    IF delete_markers = 'only' THEN
        v_delete_marker_peek_query :=
            'SELECT marker_page.name FROM (' || v_batch_query || ') marker_page LIMIT 1';
        IF NOT v_multi_row THEN
            v_delete_marker_peek_query_strict :=
                'SELECT marker_page.name FROM (' || v_batch_query_strict || ') marker_page LIMIT 1';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor performs one specialized initial seek so
            -- partial current-version and delete-marker indexes remain available.
            EXECUTE format(
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1%s%s ORDER BY o.name COLLATE "C" DESC LIMIT 1',
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND o.name COLLATE "C" >= $2 AND o.name COLLATE "C" < $3'
                    ELSE ''
                END,
                v_version_filter
            )
            INTO v_next_seek
            USING _bucket_id, v_prefix, v_upper_bound;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Folder continuation tokens retain their trailing delimiter. A
        -- delimiter-less startAfter is always a literal key boundary.
        v_cursor_is_folder := delimiter_param <> ''
            AND v_start_relative <> ''
            AND right(v_start_relative, length(delimiter_param)) = delimiter_param;

        IF v_cursor_is_folder THEN
            v_next_seek := CASE
                WHEN right(v_start, length(delimiter_param)) = delimiter_param
                    THEN v_start
                ELSE v_start || delimiter_param
            END;
            IF v_is_asc THEN
                v_next_seek := left(v_next_seek, -1)
                    || chr(ascii(right(v_next_seek, 1)) + 1);
            END IF;
            v_next_seek_strict := NOT v_is_asc;
        ELSE
            -- leaf object: when v_multi_row, stay on v_start with the
            -- caller-supplied tiebreak so a page boundary mid-key resumes
            -- that key's remaining rows instead of skipping them. Truncate
            -- to milliseconds like every other v_next_seek_at assignment -
            -- harmless today since object.ts's cursor always round-trips
            -- through JS Date first, but this shouldn't rely on that.
            IF v_multi_row THEN
                v_next_seek := v_start;
                v_next_seek_at := date_trunc('milliseconds', next_token_archived_at);
                v_next_seek_version := coalesce(next_token_version, '');
                v_next_seek_strict := coalesce(next_token, '') = '';
            ELSIF v_is_asc THEN
                v_next_seek := v_start;
                v_next_seek_strict := true;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        v_previous_seek := v_next_seek;
        v_previous_seek_at := v_next_seek_at;
        v_previous_seek_version := v_next_seek_version;
        v_previous_count := v_count;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        -- v_multi_row is branched here (rather than folded into the WHERE
        -- clause as a bound parameter) so each concrete query keeps an
        -- unconditional seek predicate - once PL/pgSQL switches to its
        -- cached generic plan (after 5 calls), a parameter-gated
        -- "(NOT v_multi_row AND name >= $x) OR (v_multi_row AND ...)"
        -- predicate stops the planner from using name as an index
        -- condition at all, degrading every subsequent peek to a full
        -- index scan filtered row-by-row instead of a bounded range scan.
        -- v_multi_row's seek predicate is a keyset tuple comparison
        -- ("name > x OR (name = x AND tiebreak)") - Postgres does not
        -- split this OR into indexable form even with fully literal
        -- values, so it falls back to a full scan filtered row-by-row.
        -- Splitting it into two independently-indexable branches (exact
        -- name match with the tiebreak filter, vs. strictly-past name)
        -- combined with UNION ALL lets each branch keep name as a real
        -- index condition; the outer ORDER BY/LIMIT picks whichever of
        -- the (at most 2) rows sorts first.
        IF delete_markers = 'only' THEN
            EXECUTE CASE WHEN v_next_seek_strict AND NOT v_multi_row
                THEN v_delete_marker_peek_query_strict
                ELSE v_delete_marker_peek_query
            END
                INTO v_peek_name
                USING _bucket_id, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END,
                    1, v_next_seek_at, v_next_seek_version, v_next_seek_strict;
        ELSIF v_multi_row THEN
            IF v_is_asc THEN
                IF v_upper_bound IS NOT NULL THEN
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND o.name COLLATE "C" < v_upper_bound
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" > v_next_seek AND o.name COLLATE "C" < v_upper_bound
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" ASC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" ASC LIMIT 1;
                ELSE
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" > v_next_seek
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" ASC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" ASC LIMIT 1;
                END IF;
            ELSE
                IF v_upper_bound IS NOT NULL THEN
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND o.name COLLATE "C" >= v_prefix
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" DESC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" DESC LIMIT 1;
                ELSE
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" DESC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" DESC LIMIT 1;
                END IF;
            END IF;
        ELSE
            -- Single-row mode is always noncurrent_versions='exclude'. Keep
            -- this predicate literal so generic plans use the current index.
            IF v_is_asc THEN
                IF v_next_seek_strict AND v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" > v_next_seek
                      AND o.name COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                ELSIF v_next_seek_strict THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" > v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                ELSIF v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" >= v_next_seek
                      AND o.name COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                ELSE
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" >= v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                END IF;
            ELSE
                IF v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" < v_next_seek
                      AND o.name COLLATE "C" >= v_prefix
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" DESC LIMIT 1;
                ELSE
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" < v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" DESC LIMIT 1;
                END IF;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := v_common_prefix;
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            version := NULL;
            archived_at := NULL;
            is_delete_marker := NULL;
            is_versioned := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1)
                    || chr(ascii(right(v_common_prefix, 1)) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
            v_next_seek_at := NULL;
            v_next_seek_version := '';
            v_next_seek_strict := NOT v_is_asc;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE CASE WHEN v_next_seek_strict AND NOT v_multi_row THEN v_batch_query_strict ELSE v_batch_query END
                USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size, v_next_seek_at, v_next_seek_version,
                v_next_seek_strict
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it. Reset
                    -- strict mode too it may have been set by an earlier
                    -- row in this same batch (see the single-row ASC advance
                    -- below), and v_next_seek here is the folder-triggering
                    -- row's own name, which the next peek must find inclusively.
                    v_next_seek := CASE
                        WHEN v_is_asc THEN v_current.name
                        ELSE v_current.name || delimiter_param
                    END;
                    v_next_seek_at := NULL;
                    v_next_seek_version := '';
                    v_next_seek_strict := false;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                version := v_current.version;
                archived_at := v_current.archived_at;
                is_delete_marker := v_current.is_delete_marker;
                is_versioned := v_current.is_versioned;
                RETURN NEXT;
                v_count := v_count + 1;

                -- when v_multi_row, stay on this name and record its
                -- archived_at as the new tiebreak so remaining rows for the
                -- same key are picked up before moving to the next name
                IF v_multi_row THEN
                    v_next_seek := v_current.name;
                    v_next_seek_at := COALESCE(date_trunc('milliseconds', v_current.archived_at), 'infinity'::timestamptz);
                    v_next_seek_version := COALESCE(v_current.version, '');
                    v_next_seek_strict := false;
                ELSIF v_is_asc THEN
                    -- Appending the delimiter as a fake lexical successor
                    -- would skip a real key like `name || '!'` (or any
                    -- character sorting below the delimiter), which sorts
                    -- between `name` and `name || delimiter`. Track the real
                    -- name and mark the next comparison strict instead.
                    v_next_seek := v_current.name;
                    v_next_seek_strict := true;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;

        IF v_count = v_previous_count
           AND v_next_seek IS NOT DISTINCT FROM v_previous_seek
           AND v_next_seek_at IS NOT DISTINCT FROM v_previous_seek_at
           AND v_next_seek_version IS NOT DISTINCT FROM v_previous_seek_version THEN
            RAISE EXCEPTION 'storage.list_objects_with_delimiter made no progress at seek (%, %, %)',
                v_next_seek, v_next_seek_at, v_next_seek_version;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_bucket_control_columns(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_bucket_control_columns() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
  configuration_changed boolean;
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.lifecycle_configuration IS NOT NULL
       OR NEW.lifecycle_configuration_generation IS NOT NULL THEN
      IF NOT pg_has_role(current_user, TG_ARGV[0], 'MEMBER') THEN
        RAISE EXCEPTION 'only members of the configured storage service role may insert lifecycle policy state'
          USING ERRCODE = '42501',
                HINT = format(
                  'Insert with both lifecycle columns NULL and configure lifecycle through the Storage API afterward, or insert as a member of %I.',
                  TG_ARGV[0]
                );
      END IF;
    END IF;

    RETURN NEW;
  END IF;

  configuration_changed =
    OLD.lifecycle_configuration IS DISTINCT FROM NEW.lifecycle_configuration
    OR OLD.lifecycle_configuration_generation IS DISTINCT FROM NEW.lifecycle_configuration_generation;

  IF NOT configuration_changed THEN
    RETURN NEW;
  END IF;

  IF NEW.type IS DISTINCT FROM 'STANDARD' THEN
    RAISE EXCEPTION 'bucket versioning and lifecycle controls require a Standard bucket'
      USING ERRCODE = '0A000';
  END IF;

  IF NEW.lifecycle_configuration IS NULL
     AND NEW.lifecycle_configuration_generation IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.lifecycle_configuration IS NULL
     OR NEW.lifecycle_configuration_generation IS NULL
     OR OLD.lifecycle_configuration IS NOT DISTINCT FROM NEW.lifecycle_configuration
     OR OLD.lifecycle_configuration_generation IS NOT DISTINCT FROM NEW.lifecycle_configuration_generation THEN
    RAISE EXCEPTION 'a changed lifecycle policy requires a new non-null generation'
      USING ERRCODE = '22023';
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_prefix_len INT;
    v_prefix_start INT;
    v_combined_levels INT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;
    v_version_filter TEXT;
    v_multi_row BOOLEAN;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;
    v_delete_marker_peek_query TEXT;
    v_delete_marker_peek_query_strict TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_next_seek_at TIMESTAMPTZ;
    v_next_seek_version TEXT;
    v_next_seek_strict BOOLEAN := false;
    v_count INT := 0;
    v_skipped INT := 0;
    v_previous_seek TEXT;
    v_previous_seek_at TIMESTAMPTZ;
    v_previous_seek_version TEXT;
    v_previous_count INT;
    v_previous_skipped INT;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_prefix_len := length(coalesce(prefix, ''));
    v_prefix_start := coalesce(array_length(string_to_array(coalesce(prefix, ''), v_delimiter), 1), 1);
    v_combined_levels := coalesce(array_length(string_to_array(v_prefix, v_delimiter), 1), 1);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);
    v_next_seek_at := NULL;
    v_next_seek_version := '';

    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'exclude');
    delete_markers := COALESCE(delete_markers, 'exclude');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'exclude';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'exclude';
    END IF;

    v_multi_row := noncurrent_versions IN ('only', 'include');

    v_version_filter := '';
    IF noncurrent_versions = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NULL';
    ELSIF noncurrent_versions = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NOT NULL';
    END IF;
    IF delete_markers = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND NOT o.is_delete_marker';
    ELSIF delete_markers = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.is_delete_marker';
    END IF;

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT array_to_string(path_tokens[$1:$2], '/') AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $3 || '%%'
                  AND bucket_id = $4
                  AND array_length(objects.path_tokens, 1) <> $2
                  AND ($7 != 'exclude' OR objects.archived_at IS NULL)
                  AND ($7 != 'only' OR objects.archived_at IS NOT NULL)
                  AND ($8 != 'exclude' OR NOT objects.is_delete_marker)
                  AND ($8 != 'only' OR objects.is_delete_marker)
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata,
                   NULL::text AS version,
                   NULL::timestamptz AS archived_at,
                   NULL::boolean AS is_delete_marker,
                   NULL::boolean AS is_versioned FROM folders)
            UNION ALL
            (SELECT array_to_string(path_tokens[$1:$2], '/') AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata,
                   version, archived_at, is_delete_marker, is_versioned
             FROM storage.objects
             WHERE objects.name ILIKE $3 || '%%'
               AND bucket_id = $4
               AND array_length(objects.path_tokens, 1) = $2
               AND ($7 != 'exclude' OR objects.archived_at IS NULL)
               AND ($7 != 'only' OR objects.archived_at IS NOT NULL)
               AND ($8 != 'exclude' OR NOT objects.is_delete_marker)
               AND ($8 != 'only' OR objects.is_delete_marker)
             -- name, then version, as tiebreaks so two versions of the same
             -- key tying on the sort column still sort deterministically
             ORDER BY %I %s, name COLLATE "C" %s, COALESCE(version, '') %s)
            LIMIT $5 OFFSET $6
            $sql$, v_sort_order, v_order_by, v_sort_order, v_sort_order, v_sort_order
        ) USING v_prefix_start, v_combined_levels, v_prefix, bucketname, v_limit, offsets, noncurrent_versions, delete_markers;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build a resume-safe batch query. The exact-name branch returns remaining
    -- versions after the current (archived_at, version) boundary; the strict
    -- name branch returns subsequent keys. UNION ALL keeps both predicates
    -- independently indexable.
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" > $2 AND lower(o.name) COLLATE "C" < $3' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" ASC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" > $2' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" ASC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 AND lower(o.name) COLLATE "C" >= $3' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" DESC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" DESC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" DESC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" DESC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        END IF;
    END IF;

    -- Keep the delete-marker predicate literal so the cached generic
    -- plan can use idx_objects_delete_markers during the main-loop peek.
    IF delete_markers = 'only' THEN
        IF v_multi_row THEN
            v_delete_marker_peek_query :=
                'SELECT marker_page.name FROM (' || v_batch_query || ') marker_page LIMIT 1';
        ELSIF v_is_asc THEN
            -- Two separate literal query strings, not one gated by a bound
            -- boolean: folding "$n AND op1 OR NOT $n AND op2" into a single
            -- query defeats the generic plan's ability to push either
            -- comparison into the index. Branching in PL/pgSQL control flow
            -- instead keeps each query's index condition intact.
            v_delete_marker_peek_query :=
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1 ' ||
                'AND lower(o.name) COLLATE "C" >= $2' ||
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND lower(o.name) COLLATE "C" < $3'
                    ELSE ''
                END ||
                v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1';
            -- Strict variant: used once the single-row ASC batch advance
            -- (below) has left v_next_seek pointing at the last row already
            -- emitted, so a plain >= would re-match it forever.
            v_delete_marker_peek_query_strict :=
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1 ' ||
                'AND lower(o.name) COLLATE "C" > $2' ||
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND lower(o.name) COLLATE "C" < $3'
                    ELSE ''
                END ||
                v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1';
        ELSE
            v_delete_marker_peek_query :=
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1 ' ||
                'AND lower(o.name) COLLATE "C" < $2' ||
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND lower(o.name) COLLATE "C" >= $3'
                    ELSE ''
                END ||
                v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC performs one specialized initial seek so partial current-version
        -- and delete-marker indexes remain available.
        EXECUTE format(
            'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1%s%s ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1',
            CASE WHEN v_upper_bound IS NOT NULL
                THEN ' AND lower(o.name) COLLATE "C" >= $2 AND lower(o.name) COLLATE "C" < $3'
                ELSE ''
            END,
            v_version_filter
        )
        INTO v_peek_name
        USING bucketname, v_prefix_lower, v_upper_bound;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch and
    -- the delete-marker-only path
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        v_previous_seek := v_next_seek;
        v_previous_seek_at := v_next_seek_at;
        v_previous_seek_version := v_next_seek_version;
        v_previous_count := v_count;
        v_previous_skipped := v_skipped;

        -- STEP 1: PEEK
        v_peek_name := NULL;
        IF delete_markers = 'only' THEN
            EXECUTE CASE WHEN v_next_seek_strict
                THEN v_delete_marker_peek_query_strict
                ELSE v_delete_marker_peek_query
            END
                INTO v_peek_name
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END,
                    1, v_next_seek_at, v_next_seek_version;
        ELSIF v_multi_row AND v_next_seek_at IS NOT NULL THEN
            SELECT o.name INTO v_peek_name
            FROM storage.objects o
            WHERE o.bucket_id = bucketname
              AND lower(o.name) COLLATE "C" = v_next_seek
              AND (COALESCE(o.archived_at, 'infinity'::timestamptz) < v_next_seek_at
                   OR (COALESCE(o.archived_at, 'infinity'::timestamptz) = v_next_seek_at
                       AND COALESCE(o.version, '') > v_next_seek_version))
              AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
              AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
              AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
              AND (delete_markers != 'only' OR o.is_delete_marker)
            ORDER BY COALESCE(o.archived_at, 'infinity'::timestamptz) DESC,
                     COALESCE(o.version, '') ASC
            LIMIT 1;

            -- The current key is exhausted. Clear its version boundary and
            -- make the following ASC name peek strict. Appending '/' is not a
            -- valid lexical successor because keys ending in characters such
            -- as '!' sort between the exhausted name and name || '/'.
            IF v_peek_name IS NULL THEN
                IF v_is_asc THEN
                    v_next_seek_strict := true;
                END IF;
                v_next_seek_at := NULL;
                v_next_seek_version := '';
            END IF;
        END IF;

        -- Single-row mode is always noncurrent_versions='exclude'. Keep the
        -- current-row predicate literal so generic plans use the current index.
        IF delete_markers != 'only' AND v_peek_name IS NULL AND NOT v_multi_row THEN
            IF v_is_asc THEN
                IF v_next_seek_strict AND v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                ELSIF v_next_seek_strict THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                ELSIF v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                ELSE
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                END IF;
            ELSIF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                  AND o.archived_at IS NULL
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                  AND o.archived_at IS NULL
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        ELSIF delete_markers != 'only' AND v_peek_name IS NULL AND v_is_asc THEN
            IF v_next_seek_strict AND v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSIF v_next_seek_strict THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSIF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSIF delete_markers != 'only' AND v_peek_name IS NULL THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- If the peek landed on a different key than we were tracking, any
        -- version boundary belongs to the OLD key and must not leak into the
        -- new one - e.g. the deleteMarkers='only' peek doesn't know or care
        -- whether it's continuing the same key or jumping to a new one, so
        -- it never clears these itself.
        IF lower(v_peek_name) IS DISTINCT FROM v_next_seek THEN
            v_next_seek_at := NULL;
            v_next_seek_version := '';
        END IF;

        -- The peek is authoritative for the next key to process. This is
        -- especially important after exhausting a multi-version key: the
        -- version boundary has been cleared, so executing the batch against
        -- a stale v_next_seek would replay every version of that old key.
        v_next_seek := lower(v_peek_name);
        v_next_seek_strict := false;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := substring(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter) from v_prefix_len + 1);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                version := NULL;
                archived_at := NULL;
                is_delete_marker := NULL;
                is_versioned := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
            v_next_seek_at := NULL;
            v_next_seek_version := '';
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size,
                    v_next_seek_at, v_next_seek_version
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it. Reset
                    -- strict mode too - it may have been set by an earlier
                    -- row in this same batch (see the single-row ASC advance
                    -- below), and v_next_seek here is the folder-triggering
                    -- row's own name, which the next peek must find inclusively.
                    v_next_seek := CASE
                        WHEN v_is_asc THEN lower(v_current.name)
                        ELSE lower(v_current.name) || v_delimiter
                    END;
                    v_next_seek_at := NULL;
                    v_next_seek_version := '';
                    v_next_seek_strict := false;
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := substring(v_current.name from v_prefix_len + 1);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    version := v_current.version;
                    archived_at := v_current.archived_at;
                    is_delete_marker := v_current.is_delete_marker;
                    is_versioned := v_current.is_versioned;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Multi-row mode must remain on this key until all of its
                -- versions have crossed the internal batch boundary.
                IF v_multi_row THEN
                    v_next_seek := lower(v_current.name);
                    v_next_seek_at := COALESCE(v_current.archived_at, 'infinity'::timestamptz);
                    v_next_seek_version := COALESCE(v_current.version, '');
                ELSIF v_is_asc THEN
                    -- Appending the delimiter as a fake lexical successor would
                    -- skip a real key like `name || '!'` (or any character
                    -- sorting below the delimiter), which sorts between `name`
                    -- and `name || delimiter`. Track the real name and mark the
                    -- next comparison strict instead - same fix as the
                    -- exhausted-key case above.
                    v_next_seek := lower(v_current.name);
                    v_next_seek_strict := true;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;

        IF v_count = v_previous_count
           AND v_skipped = v_previous_skipped
           AND v_next_seek IS NOT DISTINCT FROM v_previous_seek
           AND v_next_seek_at IS NOT DISTINCT FROM v_previous_seek_at
           AND v_next_seek_version IS NOT DISTINCT FROM v_previous_seek_version THEN
            RAISE EXCEPTION 'storage.search made no progress at seek (%, %, %)',
                v_next_seek, v_next_seek_at, v_next_seek_version;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text, p_start_after_version text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
    v_prefix_pattern text;
    v_sort_order text;
    v_sort_column text;
    v_version_tiebreak text;
BEGIN
    v_prefix := coalesce(p_prefix, '');
    -- Keep the raw prefix for common-prefix calculations and escape only LIKE metacharacters.
    v_prefix_pattern := replace(v_prefix, chr(92), chr(92) || chr(92));
    v_prefix_pattern := replace(v_prefix_pattern, '%', chr(92) || '%');
    v_prefix_pattern := replace(v_prefix_pattern, '_', chr(92) || '_');

    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'exclude');
    delete_markers := COALESCE(delete_markers, 'exclude');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'exclude';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'exclude';
    END IF;

    -- $9 is only populated in multi-row mode; it's always '' otherwise, so
    -- only use each row's real version as a tiebreak in multi-row mode.
    v_version_tiebreak := CASE WHEN noncurrent_versions IN ('only', 'include') THEN 'COALESCE(version, '''')' ELSE '''''' END;

    -- Defense-in-depth: this function is independently reachable and must
    -- not trust p_sort_order/p_sort_column to already be validated by a
    -- caller. Normalize to the same strict allow-list storage.search_v2
    -- uses before interpolating anything into dynamic SQL below.
    v_sort_order := lower(coalesce(p_sort_order, 'asc'));
    IF v_sort_order NOT IN ('asc', 'desc') THEN
        v_sort_order := 'asc';
    END IF;

    v_sort_column := lower(coalesce(p_sort_column, 'updated_at'));
    IF v_sort_column NOT IN ('updated_at', 'created_at') THEN
        v_sort_column := 'updated_at';
    END IF;

    IF v_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                o.version AS obj_version,
                o.archived_at AS obj_archived_at,
                o.is_delete_marker AS obj_is_delete_marker,
                o.is_versioned AS obj_is_versioned,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $10 || '%%'
              AND ($7 != 'exclude' OR o.archived_at IS NULL)
              AND ($7 != 'only' OR o.archived_at IS NOT NULL)
              AND ($8 != 'exclude' OR NOT o.is_delete_marker)
              AND ($8 != 'only' OR o.is_delete_marker)
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                common_prefix AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                NULL::text AS version,
                NULL::timestamptz AS archived_at,
                NULL::boolean AS is_delete_marker,
                NULL::boolean AS is_versioned,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                obj_version AS version,
                obj_archived_at AS archived_at,
                obj_is_delete_marker AS is_delete_marker,
                obj_is_versioned AS is_versioned,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz),
                    name COLLATE "C",
                    %s
                ) %s ROW(
                    -- truncated the same way as the stored value above
                    date_trunc('milliseconds', COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz)),
                    $5,
                    $9
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata,
            version,
            archived_at,
            is_delete_marker,
            is_versioned
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s,
            COALESCE(version, '') %s
        LIMIT $4
    $sql$,
        v_sort_column,
        v_version_tiebreak,
        v_cursor_op,
        v_sort_column,
        v_sort_order,
        v_sort_order,
        v_sort_order
    );

    -- version is the third tiebreak component for two versions of the same
    -- key tying on both timestamp and name (see filtered CTE / ORDER BY above)
    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after, noncurrent_versions, delete_markers, coalesce(p_start_after_version, ''), v_prefix_pattern;
END;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text, text, text, timestamp with time zone, text, boolean); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text, start_after_archived_at timestamp with time zone DEFAULT NULL::timestamp with time zone, start_after_version text DEFAULT ''::text, start_after_is_continuation boolean DEFAULT false) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata,
            l.version,
            l.archived_at,
            l.is_delete_marker,
            l.is_versioned
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            CASE WHEN start_after_is_continuation THEN '' ELSE start_after END,
            CASE WHEN start_after_is_continuation THEN start_after ELSE '' END,
            v_sort_ord,
            noncurrent_versions,
            delete_markers,
            start_after_archived_at,
            start_after_version
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after,
            noncurrent_versions, delete_markers, start_after_version
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    custom_claims_allowlist text[] DEFAULT '{}'::text[] NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: mfa_recovery_code_sets; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_recovery_code_sets (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    mfa_factor_id uuid NOT NULL,
    failed_verification_count integer DEFAULT 0 NOT NULL,
    verification_locked_until timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT mfa_recovery_code_sets_failed_verification_count_check CHECK ((failed_verification_count >= 0))
);


--
-- Name: mfa_recovery_codes; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_recovery_codes (
    id uuid NOT NULL,
    mfa_recovery_code_set_id uuid NOT NULL,
    code_hash text NOT NULL,
    consumed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: scim_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.scim_tokens (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    token_hash text NOT NULL,
    prefix text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    revoked_at timestamp with time zone,
    last_used_at timestamp with time zone,
    CONSTRAINT scim_tokens_expires_at_future CHECK (((expires_at IS NULL) OR (expires_at > created_at))),
    CONSTRAINT scim_tokens_revoked_after_created CHECK (((revoked_at IS NULL) OR (revoked_at >= created_at))),
    CONSTRAINT scim_tokens_token_hash_check CHECK ((token_hash ~ '^[0-9a-f]{64}$'::text))
);


--
-- Name: scim_users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.scim_users (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    user_id uuid,
    resource jsonb NOT NULL,
    user_name text GENERATED ALWAYS AS (lower((resource ->> 'userName'::text))) STORED NOT NULL,
    external_id text GENERATED ALWAYS AS ((resource ->> 'externalId'::text)) STORED,
    active boolean GENERATED ALWAYS AS (COALESCE(((resource ->> 'active'::text))::boolean, true)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: webauthn_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);


--
-- Name: webauthn_credentials; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: attente_fonctionnalite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attente_fonctionnalite (
    id_attente integer NOT NULL,
    id_user integer NOT NULL,
    fonctionnalite character varying(100) NOT NULL,
    date_inscription timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    statut character varying(50) DEFAULT 'en_attente'::character varying,
    date_notification timestamp without time zone
);


--
-- Name: attente_fonctionnalite_id_attente_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attente_fonctionnalite_id_attente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attente_fonctionnalite_id_attente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attente_fonctionnalite_id_attente_seq OWNED BY public.attente_fonctionnalite.id_attente;


--
-- Name: avis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.avis (
    id_avis integer NOT NULL,
    id_user integer NOT NULL,
    note smallint NOT NULL,
    commentaire text NOT NULL,
    afficher boolean DEFAULT false,
    approuve boolean DEFAULT false,
    date_creation timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: avis_id_avis_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.avis_id_avis_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: avis_id_avis_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.avis_id_avis_seq OWNED BY public.avis.id_avis;


--
-- Name: badge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.badge (
    id_badge integer NOT NULL,
    code character varying(50) NOT NULL,
    nom character varying(100) NOT NULL,
    icone character varying(100) NOT NULL,
    description character varying(255) NOT NULL,
    points integer DEFAULT 0 NOT NULL
);


--
-- Name: badge_id_badge_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.badge_id_badge_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badge_id_badge_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.badge_id_badge_seq OWNED BY public.badge.id_badge;


--
-- Name: badge_utilisateur; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.badge_utilisateur (
    id_badge_utilisateur integer NOT NULL,
    id_user integer NOT NULL,
    id_badge integer NOT NULL,
    date_obtention date NOT NULL
);


--
-- Name: badge_utilisateur_id_badge_utilisateur_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.badge_utilisateur_id_badge_utilisateur_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badge_utilisateur_id_badge_utilisateur_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.badge_utilisateur_id_badge_utilisateur_seq OWNED BY public.badge_utilisateur.id_badge_utilisateur;


--
-- Name: connexion_utilisateur; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.connexion_utilisateur (
    id_connexion integer NOT NULL,
    id_user integer NOT NULL,
    date_connexion date NOT NULL
);


--
-- Name: connexion_utilisateur_id_connexion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.connexion_utilisateur_id_connexion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: connexion_utilisateur_id_connexion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.connexion_utilisateur_id_connexion_seq OWNED BY public.connexion_utilisateur.id_connexion;


--
-- Name: favori; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favori (
    id_favori integer NOT NULL,
    id_user integer NOT NULL,
    id_metier integer NOT NULL,
    date_ajout timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: favori_id_favori_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favori_id_favori_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favori_id_favori_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favori_id_favori_seq OWNED BY public.favori.id_favori;


--
-- Name: filiere; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filiere (
    id_filiere integer NOT NULL,
    nom character varying(150) NOT NULL,
    description text NOT NULL,
    presentation text,
    domaine character varying(100) NOT NULL,
    duree character varying(50) NOT NULL,
    competences_developpees text
);


--
-- Name: filiere_critere; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filiere_critere (
    id_filiere_critere integer NOT NULL,
    id_filiere integer NOT NULL,
    id_critere integer NOT NULL,
    valeur numeric(4,2) DEFAULT 0.00 NOT NULL
);


--
-- Name: filiere_critere_id_filiere_critere_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.filiere_critere_id_filiere_critere_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filiere_critere_id_filiere_critere_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.filiere_critere_id_filiere_critere_seq OWNED BY public.filiere_critere.id_filiere_critere;


--
-- Name: filiere_id_filiere_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.filiere_id_filiere_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filiere_id_filiere_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.filiere_id_filiere_seq OWNED BY public.filiere.id_filiere;


--
-- Name: hesitation_critere; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hesitation_critere (
    id_critere integer NOT NULL,
    code character varying(50) NOT NULL,
    nom character varying(150) NOT NULL,
    categorie character varying(50) NOT NULL,
    actif boolean DEFAULT true NOT NULL
);


--
-- Name: hesitation_critere_id_critere_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hesitation_critere_id_critere_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hesitation_critere_id_critere_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hesitation_critere_id_critere_seq OWNED BY public.hesitation_critere.id_critere;


--
-- Name: hesitation_option; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hesitation_option (
    id_hesitation_option integer NOT NULL,
    id_hesitation_test integer NOT NULL,
    id_metier integer,
    id_filiere integer,
    ordre integer NOT NULL
);


--
-- Name: hesitation_option_id_hesitation_option_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hesitation_option_id_hesitation_option_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hesitation_option_id_hesitation_option_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hesitation_option_id_hesitation_option_seq OWNED BY public.hesitation_option.id_hesitation_option;


--
-- Name: hesitation_question; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hesitation_question (
    id_question integer NOT NULL,
    question text NOT NULL,
    ordre integer NOT NULL,
    actif boolean DEFAULT true NOT NULL
);


--
-- Name: hesitation_question_id_question_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hesitation_question_id_question_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hesitation_question_id_question_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hesitation_question_id_question_seq OWNED BY public.hesitation_question.id_question;


--
-- Name: hesitation_reponse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hesitation_reponse (
    id_reponse integer NOT NULL,
    id_question integer NOT NULL,
    texte text NOT NULL,
    code character varying(50) NOT NULL,
    ordre integer NOT NULL
);


--
-- Name: hesitation_reponse_id_reponse_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hesitation_reponse_id_reponse_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hesitation_reponse_id_reponse_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hesitation_reponse_id_reponse_seq OWNED BY public.hesitation_reponse.id_reponse;


--
-- Name: hesitation_reponse_utilisateur; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hesitation_reponse_utilisateur (
    id_reponse_utilisateur integer NOT NULL,
    id_hesitation_test integer NOT NULL,
    id_question integer NOT NULL,
    id_reponse integer NOT NULL
);


--
-- Name: hesitation_reponse_utilisateur_id_reponse_utilisateur_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hesitation_reponse_utilisateur_id_reponse_utilisateur_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hesitation_reponse_utilisateur_id_reponse_utilisateur_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hesitation_reponse_utilisateur_id_reponse_utilisateur_seq OWNED BY public.hesitation_reponse_utilisateur.id_reponse_utilisateur;


--
-- Name: hesitation_test; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hesitation_test (
    id_hesitation_test integer NOT NULL,
    id_user integer NOT NULL,
    type_choix character varying(50) NOT NULL,
    date_creation timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    statut character varying(50) DEFAULT 'en_cours'::character varying NOT NULL
);


--
-- Name: hesitation_test_id_hesitation_test_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hesitation_test_id_hesitation_test_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hesitation_test_id_hesitation_test_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hesitation_test_id_hesitation_test_seq OWNED BY public.hesitation_test.id_hesitation_test;


--
-- Name: historique; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.historique (
    id_historique integer NOT NULL,
    id_user integer NOT NULL,
    action character varying(255) NOT NULL,
    date_action timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: historique_id_historique_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.historique_id_historique_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: historique_id_historique_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.historique_id_historique_seq OWNED BY public.historique.id_historique;


--
-- Name: metier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metier (
    id_metier integer NOT NULL,
    nom character varying(150) NOT NULL,
    description text NOT NULL,
    presentation text,
    competences text,
    secteur character varying(100) NOT NULL,
    niveau_etude character varying(100) NOT NULL,
    salaire_min numeric(12,2) DEFAULT NULL::numeric,
    salaire_max numeric(12,2) DEFAULT NULL::numeric,
    profil_riasec character varying(3) NOT NULL,
    tendance character varying(100) DEFAULT NULL::character varying,
    accessible_test boolean DEFAULT false NOT NULL
);


--
-- Name: metier_critere; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metier_critere (
    id_metier_critere integer NOT NULL,
    id_metier integer NOT NULL,
    id_critere integer NOT NULL,
    valeur numeric(4,2) DEFAULT 0.00 NOT NULL
);


--
-- Name: metier_critere_id_metier_critere_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.metier_critere_id_metier_critere_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metier_critere_id_metier_critere_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.metier_critere_id_metier_critere_seq OWNED BY public.metier_critere.id_metier_critere;


--
-- Name: metier_filiere; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metier_filiere (
    id_metier integer NOT NULL,
    id_filiere integer NOT NULL
);


--
-- Name: metier_id_metier_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.metier_id_metier_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metier_id_metier_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.metier_id_metier_seq OWNED BY public.metier.id_metier;


--
-- Name: metier_serie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metier_serie (
    id_metier integer NOT NULL,
    id_serie integer NOT NULL,
    niveau_compatibilite character varying(50) DEFAULT 'directe'::character varying
);


--
-- Name: profil_riasec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profil_riasec (
    code character varying(2) NOT NULL,
    nom character varying(100) NOT NULL,
    description text NOT NULL,
    forces jsonb DEFAULT '[]'::jsonb NOT NULL,
    competences jsonb DEFAULT '[]'::jsonb NOT NULL,
    environnements jsonb DEFAULT '[]'::jsonb NOT NULL,
    actif boolean DEFAULT true NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL,
    date_modification timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT profil_riasec_code_format CHECK ((((code)::text ~ '^[RIASEC]{2}$'::text) AND (SUBSTRING(code FROM 1 FOR 1) <> SUBSTRING(code FROM 2 FOR 1)))),
    CONSTRAINT profil_riasec_competences_array CHECK ((jsonb_typeof(competences) = 'array'::text)),
    CONSTRAINT profil_riasec_environnements_array CHECK ((jsonb_typeof(environnements) = 'array'::text)),
    CONSTRAINT profil_riasec_forces_array CHECK ((jsonb_typeof(forces) = 'array'::text))
);


--
-- Name: TABLE profil_riasec; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.profil_riasec IS 'Référentiel partagé des descriptions et informations des profils RIASEC à deux lettres.';


--
-- Name: proposition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proposition (
    id_proposition integer NOT NULL,
    id_question integer NOT NULL,
    lettre character varying(50) NOT NULL,
    libelle character varying(255) NOT NULL,
    type_riasec character varying(50) NOT NULL
);


--
-- Name: proposition_id_proposition_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.proposition_id_proposition_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposition_id_proposition_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.proposition_id_proposition_seq OWNED BY public.proposition.id_proposition;


--
-- Name: question; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.question (
    id_question integer NOT NULL,
    id_questionnaire integer NOT NULL,
    texte text NOT NULL,
    ordre integer NOT NULL
);


--
-- Name: question_id_question_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.question_id_question_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_id_question_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.question_id_question_seq OWNED BY public.question.id_question;


--
-- Name: questionnaire; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questionnaire (
    id_questionnaire integer NOT NULL,
    nom character varying(100) NOT NULL,
    description text,
    version character varying(20) NOT NULL,
    actif boolean DEFAULT true NOT NULL,
    date_creation timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: questionnaire_id_questionnaire_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.questionnaire_id_questionnaire_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questionnaire_id_questionnaire_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.questionnaire_id_questionnaire_seq OWNED BY public.questionnaire.id_questionnaire;


--
-- Name: recommandation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommandation (
    id_recommandation integer NOT NULL,
    id_test integer NOT NULL,
    id_metier integer NOT NULL,
    compatibilite numeric(5,2) NOT NULL,
    type character varying(50) NOT NULL,
    date_recommandation timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: recommandation_id_recommandation_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommandation_id_recommandation_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommandation_id_recommandation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommandation_id_recommandation_seq OWNED BY public.recommandation.id_recommandation;


--
-- Name: reponse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reponse (
    id_reponse integer NOT NULL,
    id_test integer NOT NULL,
    id_proposition integer NOT NULL
);


--
-- Name: reponse_id_reponse_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reponse_id_reponse_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reponse_id_reponse_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reponse_id_reponse_seq OWNED BY public.reponse.id_reponse;


--
-- Name: serie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.serie (
    id_serie integer NOT NULL,
    nom character varying(100) NOT NULL,
    description text
);


--
-- Name: serie_id_serie_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.serie_id_serie_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: serie_id_serie_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.serie_id_serie_seq OWNED BY public.serie.id_serie;


--
-- Name: test_riasec; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_riasec (
    id_test integer NOT NULL,
    id_user integer NOT NULL,
    id_questionnaire integer NOT NULL,
    date_test timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    score_r integer DEFAULT 0 NOT NULL,
    score_i integer DEFAULT 0 NOT NULL,
    score_a integer DEFAULT 0 NOT NULL,
    score_s integer DEFAULT 0 NOT NULL,
    score_e integer DEFAULT 0 NOT NULL,
    score_c integer DEFAULT 0 NOT NULL,
    profil_dominant character varying(10) DEFAULT NULL::character varying
);


--
-- Name: test_riasec_id_test_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.test_riasec_id_test_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_riasec_id_test_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.test_riasec_id_test_seq OWNED BY public.test_riasec.id_test;


--
-- Name: universite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.universite (
    id_universite integer NOT NULL,
    nom character varying(200) NOT NULL,
    description text NOT NULL,
    type character varying(50) NOT NULL,
    pays character varying(100) NOT NULL,
    ville character varying(100) NOT NULL,
    region character varying(100) DEFAULT NULL::character varying,
    adresse character varying(255) DEFAULT NULL::character varying,
    telephone character varying(100) DEFAULT NULL::character varying,
    email character varying(150) DEFAULT NULL::character varying,
    site_web character varying(255) DEFAULT NULL::character varying,
    logo text
);


--
-- Name: universite_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.universite_detail (
    id_detail integer NOT NULL,
    id_universite integer NOT NULL,
    presentation text,
    conditions_admission text,
    bourses text
);


--
-- Name: universite_detail_id_detail_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.universite_detail_id_detail_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: universite_detail_id_detail_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.universite_detail_id_detail_seq OWNED BY public.universite_detail.id_detail;


--
-- Name: universite_filiere; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.universite_filiere (
    id_universite integer NOT NULL,
    id_filiere integer NOT NULL
);


--
-- Name: universite_id_universite_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.universite_id_universite_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: universite_id_universite_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.universite_id_universite_seq OWNED BY public.universite.id_universite;


--
-- Name: utilisateur; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.utilisateur (
    id_user integer NOT NULL,
    nom character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    mot_de_passe character varying(255) NOT NULL,
    pays character varying(100) NOT NULL,
    niveau_etude character varying(100) NOT NULL,
    id_serie integer,
    date_creation timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: utilisateur_id_user_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.utilisateur_id_user_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: utilisateur_id_user_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.utilisateur_id_user_seq OWNED BY public.utilisateur.id_user;


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone DEFAULT now()
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    selected_columns text[],
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL,
    versioning_status text DEFAULT 'DISABLED'::text NOT NULL,
    lifecycle_configuration jsonb,
    lifecycle_configuration_generation uuid,
    CONSTRAINT buckets_lifecycle_configuration_pair_check CHECK (((lifecycle_configuration IS NULL) = (lifecycle_configuration_generation IS NULL))),
    CONSTRAINT buckets_lifecycle_configuration_shape_check CHECK (((lifecycle_configuration IS NULL) OR ((jsonb_typeof(lifecycle_configuration) = 'object'::text) AND (lifecycle_configuration ? 'rules'::text) AND
CASE
    WHEN (jsonb_typeof((lifecycle_configuration -> 'rules'::text)) = 'array'::text) THEN ((jsonb_array_length((lifecycle_configuration -> 'rules'::text)) >= 1) AND (jsonb_array_length((lifecycle_configuration -> 'rules'::text)) <= 1000))
    ELSE false
END))),
    CONSTRAINT buckets_lifecycle_configuration_standard_only_check CHECK (((type = 'STANDARD'::storage.buckettype) OR ((lifecycle_configuration IS NULL) AND (lifecycle_configuration_generation IS NULL)))),
    CONSTRAINT buckets_versioning_dark_check CHECK ((versioning_status = 'DISABLED'::text)),
    CONSTRAINT buckets_versioning_standard_only_check CHECK (((type = 'STANDARD'::storage.buckettype) OR (versioning_status = 'DISABLED'::text))),
    CONSTRAINT buckets_versioning_status_check CHECK ((versioning_status = ANY (ARRAY['DISABLED'::text, 'ENABLED'::text, 'SUSPENDED'::text])))
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    archived_at timestamp with time zone,
    is_delete_marker boolean DEFAULT false NOT NULL,
    is_versioned boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb,
    metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: attente_fonctionnalite id_attente; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attente_fonctionnalite ALTER COLUMN id_attente SET DEFAULT nextval('public.attente_fonctionnalite_id_attente_seq'::regclass);


--
-- Name: avis id_avis; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avis ALTER COLUMN id_avis SET DEFAULT nextval('public.avis_id_avis_seq'::regclass);


--
-- Name: badge id_badge; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badge ALTER COLUMN id_badge SET DEFAULT nextval('public.badge_id_badge_seq'::regclass);


--
-- Name: badge_utilisateur id_badge_utilisateur; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badge_utilisateur ALTER COLUMN id_badge_utilisateur SET DEFAULT nextval('public.badge_utilisateur_id_badge_utilisateur_seq'::regclass);


--
-- Name: connexion_utilisateur id_connexion; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connexion_utilisateur ALTER COLUMN id_connexion SET DEFAULT nextval('public.connexion_utilisateur_id_connexion_seq'::regclass);


--
-- Name: favori id_favori; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favori ALTER COLUMN id_favori SET DEFAULT nextval('public.favori_id_favori_seq'::regclass);


--
-- Name: filiere id_filiere; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiere ALTER COLUMN id_filiere SET DEFAULT nextval('public.filiere_id_filiere_seq'::regclass);


--
-- Name: filiere_critere id_filiere_critere; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiere_critere ALTER COLUMN id_filiere_critere SET DEFAULT nextval('public.filiere_critere_id_filiere_critere_seq'::regclass);


--
-- Name: hesitation_critere id_critere; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_critere ALTER COLUMN id_critere SET DEFAULT nextval('public.hesitation_critere_id_critere_seq'::regclass);


--
-- Name: hesitation_option id_hesitation_option; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_option ALTER COLUMN id_hesitation_option SET DEFAULT nextval('public.hesitation_option_id_hesitation_option_seq'::regclass);


--
-- Name: hesitation_question id_question; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_question ALTER COLUMN id_question SET DEFAULT nextval('public.hesitation_question_id_question_seq'::regclass);


--
-- Name: hesitation_reponse id_reponse; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_reponse ALTER COLUMN id_reponse SET DEFAULT nextval('public.hesitation_reponse_id_reponse_seq'::regclass);


--
-- Name: hesitation_reponse_utilisateur id_reponse_utilisateur; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_reponse_utilisateur ALTER COLUMN id_reponse_utilisateur SET DEFAULT nextval('public.hesitation_reponse_utilisateur_id_reponse_utilisateur_seq'::regclass);


--
-- Name: hesitation_test id_hesitation_test; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_test ALTER COLUMN id_hesitation_test SET DEFAULT nextval('public.hesitation_test_id_hesitation_test_seq'::regclass);


--
-- Name: historique id_historique; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historique ALTER COLUMN id_historique SET DEFAULT nextval('public.historique_id_historique_seq'::regclass);


--
-- Name: metier id_metier; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier ALTER COLUMN id_metier SET DEFAULT nextval('public.metier_id_metier_seq'::regclass);


--
-- Name: metier_critere id_metier_critere; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier_critere ALTER COLUMN id_metier_critere SET DEFAULT nextval('public.metier_critere_id_metier_critere_seq'::regclass);


--
-- Name: proposition id_proposition; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposition ALTER COLUMN id_proposition SET DEFAULT nextval('public.proposition_id_proposition_seq'::regclass);


--
-- Name: question id_question; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question ALTER COLUMN id_question SET DEFAULT nextval('public.question_id_question_seq'::regclass);


--
-- Name: questionnaire id_questionnaire; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questionnaire ALTER COLUMN id_questionnaire SET DEFAULT nextval('public.questionnaire_id_questionnaire_seq'::regclass);


--
-- Name: recommandation id_recommandation; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommandation ALTER COLUMN id_recommandation SET DEFAULT nextval('public.recommandation_id_recommandation_seq'::regclass);


--
-- Name: reponse id_reponse; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reponse ALTER COLUMN id_reponse SET DEFAULT nextval('public.reponse_id_reponse_seq'::regclass);


--
-- Name: serie id_serie; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serie ALTER COLUMN id_serie SET DEFAULT nextval('public.serie_id_serie_seq'::regclass);


--
-- Name: test_riasec id_test; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_riasec ALTER COLUMN id_test SET DEFAULT nextval('public.test_riasec_id_test_seq'::regclass);


--
-- Name: universite id_universite; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universite ALTER COLUMN id_universite SET DEFAULT nextval('public.universite_id_universite_seq'::regclass);


--
-- Name: universite_detail id_detail; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universite_detail ALTER COLUMN id_detail SET DEFAULT nextval('public.universite_detail_id_detail_seq'::regclass);


--
-- Name: utilisateur id_user; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateur ALTER COLUMN id_user SET DEFAULT nextval('public.utilisateur_id_user_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.custom_oauth_providers (id, provider_type, identifier, name, client_id, client_secret, acceptable_client_ids, scopes, pkce_enabled, attribute_mapping, authorization_params, enabled, email_optional, issuer, discovery_url, skip_nonce_check, cached_discovery, discovery_cached_at, authorization_url, token_url, userinfo_url, jwks_uri, created_at, updated_at, custom_claims_allowlist) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at, invite_token, referrer, oauth_client_state_id, linking_target_id, email_optional) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: mfa_recovery_code_sets; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_recovery_code_sets (id, user_id, mfa_factor_id, failed_verification_count, verification_locked_until, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_recovery_codes; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_recovery_codes (id, mfa_recovery_code_set_id, code_hash, consumed_at, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type, token_endpoint_auth_method) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at, expires_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
20260115000000
20260121000000
20260219120000
20260302000000
20260625000000
20260821000000
20260821010000
20260824000000
20260824000001
20260831180000
\.


--
-- Data for Name: scim_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.scim_tokens (id, sso_provider_id, token_hash, prefix, created_at, expires_at, revoked_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: scim_users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.scim_users (id, sso_provider_id, user_id, resource, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
\.


--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_challenges (id, user_id, challenge_type, session_data, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_credentials (id, user_id, credential_id, public_key, attestation_type, aaguid, sign_count, transports, backup_eligible, backed_up, friendly_name, created_at, updated_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: attente_fonctionnalite; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attente_fonctionnalite (id_attente, id_user, fonctionnalite, date_inscription, statut, date_notification) FROM stdin;
7	28	COACHING_PERSONNALISE	2026-09-12 19:14:25.241	EN_ATTENTE	\N
6	26	COACHING_PERSONNALISE	2026-09-19 19:50:47.009	EN_ATTENTE	\N
9	50	COACHING_PERSONNALISE	2026-09-22 22:10:25.161	EN_ATTENTE	\N
10	24	COACHING_PERSONNALISE	2026-09-24 17:54:53.57	EN_ATTENTE	\N
11	64	COACHING_PERSONNALISE	2026-09-25 19:33:23.87	EN_ATTENTE	\N
\.


--
-- Data for Name: avis; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.avis (id_avis, id_user, note, commentaire, afficher, approuve, date_creation) FROM stdin;
10	24	4	NextOri c le meilleur	f	f	2026-09-12 15:23:35.676
11	40	5	C'est une très bonne application pour tous personnes qui veulent se renseigner avant de construire son propre avenir dans les études comme dans les métiers	t	t	2026-09-13 21:15:16.708
12	46	5	En tant que jeune étudiant, je sais à quel point le choix d’une filière, d’une formation ou d’un métier peut être difficile. On se pose beaucoup de questions et on ne sait pas toujours par où commencer.\nAvec NextOri, j’ai découvert une solution simple et accessible qui permet de mieux connaître son profil, d’explorer les formations et les métiers et de réfléchir plus clairement à son avenir professionnel.\nNextOri, ce n’est pas seulement une application : c’est un outil qui peut aider chaque jeune à faire des choix plus éclairés pour construire son avenir.	t	t	2026-09-18 14:42:17.641
13	50	4	C’est une très bonne plateforme ça permet de mieux aider les élèves et étudiants dans leur chemin des objectifs	t	t	2026-09-22 23:22:43.786
15	50	4	C’est une très bonne appli.\nBeaucoup de jeunes senegalais on eu des difficultés sur leur avenir et de quoi il veut suivre . Avec nextori,il se renseigne non seulement sur ce que l’on veut ,nos points forts …. Et aussi il nous propose des métiers et filières qui nous correspondent belle et bien	t	t	2026-09-22 23:33:02.673
14	50	4	J’aime quand il s’agit des questions personnelles ça nous permet d’être nous même et qu’on nous oriente en fonction de ce que l’on veut	t	t	2026-09-22 23:30:06.418
\.


--
-- Data for Name: badge; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.badge (id_badge, code, nom, icone, description, points) FROM stdin;
1	SERIE_5_JOURS	Série de 5 jours	serie-5-jours	A été actif pendant 5 jours consécutifs.	25
5	DECOUVREUR_METIERS	Découvreur de métiers	decouvreur-metiers	A découvert les métiers recommandés.	0
6	CHOIX_CARRIERE	Choix de carrière	choix-carriere	A consulté une formation.	0
9	SERIE_15_JOURS	Série de 15 jours	serie-15-jours	A été actif pendant 15 jours consécutifs.	75
10	SERIE_30_JOURS	Série de 30 jours	serie-30-jours	A été actif pendant 30 jours consécutifs.	150
2	PREMIER_PAS	Premier Pas	premier-pas	A créé son compte sur NextOri.	25
4	CONNAISSANCE_SOI	Connaissance de soi	connaissance-de-soi	A consulté son profil RIASEC.	0
3	EXPLORATEUR	Explorateur	explorateur	A terminé le test RIASEC.	0
7	PRET_UNIVERSITE	Prêt pour l’université	pret-universite	A consulté une université.	0
8	SERIE_7_JOURS	Série de 7 jours	serie-7-jours	A été actif pendant 7 jours consécutifs.	35
11	CONTRIBUTEUR	Contributeur	contributeur	Vous avez contribué à améliorer NextOri en partageant votre expérience.	20
\.


--
-- Data for Name: badge_utilisateur; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.badge_utilisateur (id_badge_utilisateur, id_user, id_badge, date_obtention) FROM stdin;
83	24	2	2026-09-12
84	25	2	2026-09-12
85	26	2	2026-09-12
86	27	2	2026-09-12
88	24	4	2026-09-12
89	24	5	2026-09-12
90	24	6	2026-09-12
91	24	7	2026-09-12
92	24	11	2026-09-12
240	71	6	2026-09-27
241	71	7	2026-09-27
242	72	2	2026-09-27
243	73	2	2026-09-28
244	73	3	2026-09-28
245	73	4	2026-09-28
99	26	3	2026-09-12
100	26	4	2026-09-12
101	26	5	2026-09-12
102	26	6	2026-09-12
103	26	7	2026-09-12
105	28	2	2026-09-12
106	29	2	2026-09-12
107	29	3	2026-09-12
108	29	5	2026-09-12
110	28	4	2026-09-12
111	28	5	2026-09-12
112	28	6	2026-09-12
113	28	7	2026-09-12
109	28	3	2026-09-12
115	30	2	2026-09-12
116	31	2	2026-09-12
117	31	3	2026-09-12
118	31	4	2026-09-12
119	31	5	2026-09-12
120	31	6	2026-09-12
121	31	7	2026-09-12
122	32	2	2026-09-12
123	33	2	2026-09-12
124	32	3	2026-09-12
125	34	2	2026-09-12
126	33	3	2026-09-12
128	33	5	2026-09-12
129	27	5	2026-09-12
130	27	6	2026-09-12
131	34	5	2026-09-12
132	35	2	2026-09-12
127	34	3	2026-09-12
134	36	2	2026-09-13
135	37	2	2026-09-13
136	37	3	2026-09-13
137	37	5	2026-09-13
138	38	2	2026-09-13
139	39	2	2026-09-13
140	38	3	2026-09-13
141	39	3	2026-09-13
142	38	5	2026-09-13
143	38	6	2026-09-13
144	27	7	2026-09-13
145	40	2	2026-09-13
146	40	11	2026-09-13
147	41	2	2026-09-14
148	35	5	2026-09-14
149	42	2	2026-09-14
150	43	2	2026-09-14
151	44	2	2026-09-14
153	44	4	2026-09-14
154	44	5	2026-09-14
155	44	6	2026-09-14
156	44	7	2026-09-14
152	44	3	2026-09-14
158	45	2	2026-09-15
159	45	3	2026-09-15
160	20	2	2026-09-15
161	20	5	2026-09-15
162	20	7	2026-09-15
163	46	2	2026-09-15
164	46	3	2026-09-15
165	47	2	2026-09-15
166	34	6	2026-09-16
167	34	7	2026-09-16
168	48	2	2026-09-16
169	48	3	2026-09-16
170	49	2	2026-09-16
171	49	3	2026-09-16
173	49	4	2026-09-16
174	49	5	2026-09-16
175	49	6	2026-09-16
176	49	7	2026-09-16
177	46	4	2026-09-18
178	46	5	2026-09-18
179	46	6	2026-09-18
180	46	7	2026-09-18
181	46	11	2026-09-18
182	26	1	2026-09-19
183	50	2	2026-09-22
185	50	4	2026-09-22
186	50	5	2026-09-22
187	50	6	2026-09-22
188	50	7	2026-09-22
189	50	11	2026-09-22
184	50	3	2026-09-22
191	51	2	2026-09-23
192	52	2	2026-09-23
193	51	3	2026-09-23
194	51	4	2026-09-23
195	51	5	2026-09-23
196	53	2	2026-09-23
197	54	2	2026-09-23
198	54	3	2026-09-23
199	54	4	2026-09-23
200	54	5	2026-09-23
201	54	6	2026-09-23
202	54	7	2026-09-23
203	55	2	2026-09-23
204	56	2	2026-09-23
205	55	3	2026-09-23
206	55	5	2026-09-23
207	56	3	2026-09-23
208	55	6	2026-09-23
209	55	7	2026-09-23
210	57	2	2026-09-23
211	58	2	2026-09-23
212	58	3	2026-09-23
213	59	2	2026-09-23
214	59	3	2026-09-23
215	59	5	2026-09-23
216	59	6	2026-09-23
217	59	7	2026-09-23
218	60	2	2026-09-23
219	60	3	2026-09-23
220	26	8	2026-09-24
221	61	2	2026-09-24
222	34	1	2026-09-24
223	53	3	2026-09-24
224	62	2	2026-09-24
225	62	3	2026-09-24
226	63	2	2026-09-24
227	64	2	2026-09-25
228	64	3	2026-09-25
229	65	2	2026-09-25
230	65	3	2026-09-25
231	66	2	2026-09-25
232	67	2	2026-09-25
233	64	4	2026-09-25
234	64	5	2026-09-25
235	68	2	2026-09-25
236	68	6	2026-09-25
237	69	2	2026-09-26
238	70	2	2026-09-27
239	71	2	2026-09-27
246	73	5	2026-09-28
247	73	6	2026-09-28
248	73	7	2026-09-28
249	52	6	2026-09-28
250	52	7	2026-09-28
251	74	2	2026-09-28
252	74	3	2026-09-28
253	24	1	2026-09-28
254	52	3	2026-09-28
255	52	5	2026-09-28
87	24	3	2026-09-29
\.


--
-- Data for Name: connexion_utilisateur; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.connexion_utilisateur (id_connexion, id_user, date_connexion) FROM stdin;
272	26	2026-09-22
267	50	2026-09-22
279	24	2026-09-23
352	24	2026-09-28
277	34	2026-09-23
374	24	2026-09-29
283	52	2026-09-23
287	53	2026-09-23
288	54	2026-09-23
291	56	2026-09-23
290	55	2026-09-23
297	57	2026-09-23
298	58	2026-09-23
282	51	2026-09-23
217	26	2026-09-13
300	59	2026-09-23
302	60	2026-09-23
303	55	2026-09-24
222	39	2026-09-13
159	25	2026-09-12
220	38	2026-09-13
221	27	2026-09-13
305	61	2026-09-24
226	40	2026-09-13
232	41	2026-09-14
233	35	2026-09-14
235	42	2026-09-14
236	43	2026-09-14
229	26	2026-09-14
309	34	2026-09-24
240	44	2026-09-14
243	45	2026-09-15
244	20	2026-09-15
245	29	2026-09-15
247	46	2026-09-15
248	47	2026-09-15
249	34	2026-09-16
251	48	2026-09-16
157	24	2026-09-12
252	49	2026-09-16
189	29	2026-09-12
255	26	2026-09-16
188	28	2026-09-12
257	24	2026-09-17
260	34	2026-09-17
160	26	2026-09-12
201	30	2026-09-12
202	31	2026-09-12
204	32	2026-09-12
205	33	2026-09-12
167	27	2026-09-12
261	46	2026-09-18
206	34	2026-09-12
211	35	2026-09-12
213	36	2026-09-13
214	37	2026-09-13
263	26	2026-09-19
307	24	2026-09-24
319	62	2026-09-24
304	26	2026-09-24
321	63	2026-09-24
324	65	2026-09-25
325	66	2026-09-25
326	34	2026-09-25
327	67	2026-09-25
323	64	2026-09-25
330	68	2026-09-25
335	69	2026-09-26
337	70	2026-09-27
338	71	2026-09-27
341	72	2026-09-27
342	71	2026-09-28
349	74	2026-09-28
343	73	2026-09-28
346	52	2026-09-28
\.


--
-- Data for Name: favori; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.favori (id_favori, id_user, id_metier, date_ajout) FROM stdin;
\.


--
-- Data for Name: filiere; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.filiere (id_filiere, nom, description, presentation, domaine, duree, competences_developpees) FROM stdin;
1	Informatique	Étude des systèmes informatiques, développement et réseaux	Formation orientée vers les sciences informatiques, la programmation, les bases de données, les réseaux et le développement de solutions numériques.	Sciences et Technologies	3 ans	Programmation, Bases de données, Développement Web, Réseaux, Algorithmique, Résolution de problèmes
2	Génie Civil	Construction et infrastructures	Formation spécialisée dans la conception, la construction et la gestion des infrastructures telles que les bâtiments, les routes et les ponts.	 Génie Civil / BTP	3 ans	Calcul des structures, DAO, Gestion de chantier, Topographie, Résistance des matériaux, Organisation
3	Médecine	Études médicales et santé humaine	Formation dédiée aux sciences médicales, au diagnostic, à la prévention et au traitement des maladies afin d’améliorer la santé des populations.	Santé	6 à 8 ans	Diagnostic, Anatomie, Soins médicaux, Communication, Esprit d’analyse, Prise de décision
4	Droit	Étude des lois et du système juridique	Formation permettant de comprendre les règles juridiques, les institutions et les procédures afin de défendre les droits et conseiller les organisations.	Droit et Sciences Juridiques	5 ans	Analyse juridique, Argumentation, Plaidoirie, Rédaction, Négociation, Esprit critique
5	Gestion	Management et administration des entreprises	Formation axée sur la gestion des organisations, la planification, le management et la coordination des ressources humaines, matérielles et financières.	Économie et Gestion	3 ans	Management, Organisation, Leadership, Gestion de projet, Communication, Planification
7	Marketing	Stratégies commerciales et communication	Formation consacrée à la compréhension des marchés, du comportement des consommateurs et à la promotion des produits et services.	Commerce et Communication	3 ans	Marketing digital, Étude de marché, Communication, Vente, Stratégie commerciale, Créativité
8	Électronique	Systèmes électroniques et embarqués	Formation orientée vers la conception, le développement et la maintenance des systèmes électroniques et des équipements intelligents.	Sciences & Technologies	3 ans	Électronique analogique, Électronique numérique, Microcontrôleurs, Maintenance, Automatisation, Électricité
9	Génie Logiciel	Conception et développement de logiciels.	Cette filière prépare les étudiants à concevoir, développer, tester et maintenir des applications logicielles répondant aux besoins des entreprises.	Sciences et Technologies	3 ans	Programmation, Génie logiciel, UML, Tests logiciels, Gestion de projet, Git
10	Réseaux et Télécommunications	Administration des réseaux informatiques et des systèmes de télécommunication.	Cette filière permet de maîtriser les infrastructures réseaux, les équipements de communication et les technologies de télécommunications modernes.	Sciences et Technologies	3 ans	Administration réseau, Cisco, Routage, Commutation, Télécommunications, Sécurité réseau
11	Cybersécurité	Sécurisation des systèmes d’information.	Cette filière forme des spécialistes capables de protéger les systèmes informatiques contre les cyberattaques et les vulnérabilités.	Sciences et Technologies	3 ans	Sécurité informatique, Cryptographie, Pentest, Réseaux, Analyse des risques, Linux
12	Data Science	Analyse et exploitation des données.	Cette filière prépare les étudiants à collecter, analyser et interpréter les données afin d'aider les organisations dans leurs prises de décision.	Sciences et Technologies	3 ans	Python, SQL, Statistiques, Machine Learning, Visualisation des données, Analyse de données
13	Intelligence Artificielle	Développement de solutions basées sur l’intelligence artificielle.	Cette filière permet d’acquérir les compétences nécessaires pour concevoir des systèmes intelligents et automatisés.	Sciences et Technologies	3 ans	Python, Machine Learning, Deep Learning, Intelligence artificielle, Analyse de données, Mathématiques
14	Systèmes et Réseaux	Formation spécialisée dans l’administration et la gestion des infrastructures informatiques.	Cette filière prépare les étudiants à concevoir, administrer et maintenir les systèmes informatiques et les infrastructures réseaux des organisations.	Sciences et Technologies	3 ans	Administration systèmes, Linux, Réseaux informatiques, Serveurs, Virtualisation, Sécurité informatique
15	Informatique de Gestion	Formation combinant informatique et gestion des organisations.	Cette filière forme des professionnels capables de développer et gérer des solutions informatiques adaptées aux besoins des entreprises.	Sciences et Technologies	3 ans	Bases de données, SQL, Gestion d’entreprise, Développement logiciel, Systèmes d’information, Analyse des besoins
16	Systèmes d’Information	Gestion et pilotage des systèmes informatiques des organisations.	Cette filière prépare les étudiants à analyser les besoins des entreprises et à mettre en place des solutions numériques adaptées.	Économie & Technologies	3 ans	Analyse fonctionnelle, Gestion de projet, Bases de données, Systèmes d’information, Modélisation, Programmation
17	Statistique et Informatique Décisionnelle	Analyse des données et aide à la décision.	Cette filière forme des spécialistes capables d’exploiter les données pour produire des analyses utiles aux organisations.	Sciences et Technologies	3 ans	Statistiques, Programmation, Bases de données, Analyse de données, Modélisation, Intelligence décisionnelle
18	Pharmacie	Formation spécialisée dans les médicaments et les produits de santé.	Cette filière prépare les étudiants à la conception, la production, la distribution et le contrôle des médicaments.	Santé	6 ans	Pharmacologie, Chimie, Biologie, Gestion des médicaments, Analyse biologique, Santé publique
19	Odontologie	Formation consacrée aux soins dentaires et à la santé bucco-dentaire.	Cette filière forme les chirurgiens-dentistes spécialisés dans la prévention et le traitement des maladies dentaires.	Santé	6 ans	Anatomie dentaire, Chirurgie dentaire, Prévention, Diagnostic, Soins bucco-dentaires
20	Sciences infirmières	Formation dédiée aux soins et à l’accompagnement des patients.	Cette filière prépare les professionnels capables d’assurer les soins, le suivi des patients et la prévention sanitaire.	Santé	3 à 4 ans	Soins infirmiers, Anatomie, Hygiène, Relation patient, Urgences médicales, Santé communautaire
21	Sage-femme	Formation spécialisée dans la santé maternelle et infantile.	Cette filière prépare les professionnels de la prise en charge de la grossesse, de l’accouchement et du suivi mère-enfant.	Santé	3 à 4 ans	Obstétrique, Santé reproductive, Soins maternels, Néonatologie, Communication
22	Biologie médicale	Formation en analyses biologiques et diagnostic médical.	Cette filière forme des spécialistes capables de réaliser et interpréter des analyses nécessaires au diagnostic des maladies.	Santé	3 à 5 ans	Biologie, Microbiologie, Biochimie, Analyses médicales, Laboratoire, Recherche
23	Santé publique	Formation orientée vers la prévention et la gestion de la santé des populations.	Cette filière prépare les professionnels capables d’analyser les problèmes sanitaires et de concevoir des programmes de santé publique.	Santé	3 à 5 ans	Épidémiologie, Statistiques sanitaires, Prévention, Gestion sanitaire, Recherche, Politiques de santé
24	Imagerie médicale	Formation spécialisée dans les techniques d’exploration médicale par l’image.	Cette filière prépare les professionnels utilisant les technologies d’imagerie pour aider au diagnostic médical.	Santé	3 à 4 ans	Radiologie, Imagerie médicale, Technologies médicales, Anatomie, Sécurité des patients
25	Nutrition et Diététique	Formation dans l’alimentation, la nutrition et la prévention des maladies.	Cette filière forme des spécialistes capables d’accompagner les patients et les populations dans la gestion nutritionnelle.	Santé	3 ans	Nutrition, Alimentation, Santé publique, Conseil nutritionnel, Analyse alimentaire
26	Kinésithérapie	Formation spécialisée dans la rééducation fonctionnelle.	Cette filière prépare les professionnels de la réadaptation physique et de l’accompagnement des patients.	Santé	3 à 5 ans	Rééducation, Anatomie, Physiologie, Thérapie physique, Accompagnement patient
28	Systèmes Embarqués	Formation spécialisée dans les systèmes informatiques intégrés aux équipements électroniques.	Cette filière forme des professionnels capables de concevoir des systèmes intelligents utilisés dans l’industrie, les objets connectés et les équipements numériques.	Sciences et Technologies	3 ans	Programmation embarquée, Microcontrôleurs, Électronique numérique, Automatisation, C, C++, Systèmes temps réel
29	Mathématiques-Physique-Informatique (MPI)	Formation scientifique combinant mathématiques, physique et informatique.	Cette filière apporte une base solide pour les métiers liés à la modélisation, la recherche, l’intelligence artificielle et l’analyse des données.	Sciences et Technologies	3 ans	Mathématiques, Physique, Algorithmique, Programmation, Modélisation, Analyse scientifique
31	Médecine vétérinaire	Formation consacrée à la santé animale, à la prévention et au traitement des maladies animales.	Cette filière forme des professionnels capables de diagnostiquer, prévenir et traiter les maladies animales. Elle intervient également dans la sécurité alimentaire, l’élevage et la santé publique vétérinaire.	Santé	5 ans	Anatomie animale, Physiologie animale, Diagnostic vétérinaire, Pathologie animale, Chirurgie vétérinaire, Santé publique vétérinaire
32	Psychologie	Formation consacrée à l’étude du comportement humain, des processus mentaux et de l’accompagnement psychologique.	Cette filière prépare des professionnels capables d’analyser les comportements, d’accompagner les personnes et d’intervenir dans différents contextes comme la santé, l’éducation et le travail.	Sciences Humaines et Santé	3 ans à 5 ans	Psychologie clinique, Psychologie sociale, Évaluation psychologique, Communication, Accompagnement, Analyse du comportement
33	Génie biomédical	Formation à l’intersection entre l’ingénierie, les technologies médicales et les sciences de la santé.	Cette filière forme des ingénieurs capables de concevoir, installer, maintenir et améliorer les équipements médicaux utilisés dans les établissements de santé.	Sciences et Technologies	3 ans à 5 ans	Électronique médicale, Instrumentation biomédicale, Maintenance des équipements médicaux, Traitement du signal, Technologies de santé, Innovation médicale
64	Management	Formation axée sur la gestion des organisations, le leadership et la prise de décision.	Cette formation prépare les étudiants à organiser, piloter et développer des structures publiques ou privées.	Économie et Gestion	3 ans	Management, Leadership, Gestion de projet, Organisation, Communication professionnelle, Stratégie
67	Gestion d’entreprise	Formation orientée vers le fonctionnement et le développement des entreprises.	Elle permet de maîtriser les outils nécessaires à la création, l’administration et la croissance d’une organisation.	Économie et Gestion	3 ans	Entrepreneuriat, Management, Gestion financière, Organisation, Stratégie
68	Gestion des ressources humaines	Formation spécialisée dans la gestion du personnel et le développement organisationnel.	Elle prépare aux métiers liés au recrutement, à la formation et à l’accompagnement des employés.	Sciences Humaines et Gestion	3 ans	Recrutement, Gestion du personnel, Formation, Communication, Droit du travail
69	Génie logistique	Formation axée sur la gestion des flux, du transport et de la chaîne logistique.	Elle prépare aux métiers de la supply chain, du transport et du commerce international.	Transport, Logistique et Supply Chain	3 ans	Logistique, Gestion des stocks, Transport, Approvisionnement, Supply Chain
70	Management des affaires internationales	Formation liée au commerce international et à la gestion des échanges mondiaux.	Elle prépare aux métiers des entreprises internationales, import-export et développement commercial.	Commerce International et Gestion	3 ans	Commerce international, Import-export, Négociation, Gestion de projet, Communication
71	Marketing et communication	Formation combinant stratégies marketing et communication professionnelle.	Elle prépare aux métiers de la communication commerciale, du digital et de la promotion des marques.	Commerce et Communication	3 ans	Communication, Marketing digital, Réseaux sociaux, Vente, Création de contenu
72	Qualité, Hygiène, Sécurité et Environnement (QHSE)	Formation consacrée à l’amélioration de la qualité et à la prévention des risques.	Elle prépare aux métiers de la qualité, sécurité industrielle et environnement.	Sciences et Technologies	3 ans	Gestion qualité, Sécurité, Normes, Gestion environnementale, Prévention des risques
73	Droit des affaires	Formation spécialisée dans les règles juridiques appliquées aux entreprises.	Elle prépare aux métiers du droit commercial, juridique et administratif.	Droit et Sciences Juridiques	4 ans	Droit des entreprises, Contrats, Fiscalité, Analyse juridique, Rédaction
74	Administration publique et territoriale	Formation portant sur la gestion des institutions publiques et des collectivités.	Elle prépare aux métiers de l’administration, des politiques publiques et du développement territorial.	Administration et Sciences Sociales	3 ans	Gestion publique, Politiques publiques, Administration, Droit administratif, Développement local
75	Management de projet	Formation axée sur la conception, la planification et le pilotage des projets.	Elle prépare à la gestion de projets dans les entreprises, ONG et administrations.	Économie et Gestion	3 ans	Gestion de projet, Planification, Budget, Coordination, Évaluation
76	Master of Business Administration (MBA)	Formation avancée en management et stratégie d’entreprise.	Elle développe les compétences nécessaires au pilotage des organisations et à la prise de décision stratégique.	Économie et Gestion	1 à 2 ans	Stratégie d’entreprise, Leadership, Finance, Management, Entrepreneuriat
77	Banque, Assurance, Finance	Formation spécialisée dans les services financiers, bancaires, l’assurance et la gestion des risques.	Cette formation prépare les étudiants aux métiers de la banque, de l’assurance, de la finance d’entreprise, de l’analyse financière et de la gestion des risques.	Économie et Gestion	3 ans	Analyse financière, Gestion bancaire, Assurance, Gestion des risques, Comptabilité, Finance d’entreprise, Investissement, Analyse crédit
78	Transport logistique	Formation spécialisée dans la gestion des flux, du transport et de la chaîne logistique.	Cette formation prépare les étudiants à organiser les opérations de transport, d’approvisionnement et de distribution dans les entreprises.	Transport, Logistique et Supply Chain	3 ans	Gestion logistique, Transport, Gestion des stocks, Approvisionnement, Supply Chain, Organisation des flux
79	Commerce international	Formation dédiée aux échanges commerciaux internationaux et aux opérations d’import-export.	Elle prépare aux métiers liés au commerce mondial, à la négociation internationale et aux échanges entre entreprises.	Commerce International et Gestion	3 ans	Import-export, Négociation commerciale, Commerce international, Gestion des échanges, Marketing international
80	Management des organisations	Formation axée sur la gestion, la coordination et l’organisation des structures.	Elle permet de développer des compétences dans le pilotage des organisations publiques et privées.	Économie et Gestion	3 ans	Organisation, Management, Leadership, Gestion de projet, Stratégie, Communication
81	Électrotechnique	Formation spécialisée dans les systèmes électriques et les équipements énergétiques.	Elle prépare aux métiers liés à la conception, l’installation et la maintenance des systèmes électriques.	Sciences et Technologies	3 ans	Électricité, Systèmes électriques, Automatisation, Maintenance, Électronique, Énergie
82	Géomètre Topographe	Formation consacrée aux mesures, relevés et représentations des terrains.	Elle prépare aux métiers de la topographie, de la cartographie et des travaux d’infrastructures.	Sciences et Technologies	3 ans	Topographie, Cartographie, DAO, Géométrie, Mesure de terrain, Géomatique
83	Électromécanique et systèmes automatisés	Formation combinant mécanique, électricité et automatisation industrielle.	Elle prépare aux métiers de la maintenance industrielle et des systèmes automatisés.	Sciences et Technologies	3 ans	Électromécanique, Automatisme, Maintenance industrielle, Machines électriques, Robotique
84	Géotechnique	Formation spécialisée dans l’étude des sols et des propriétés des terrains.	Elle prépare aux métiers liés aux études géotechniques dans les projets de construction.	Sciences et Technologies	3 ans	Mécanique des sols, Étude des terrains, Fondations, Géologie, Calculs techniques
85	Hydraulique et assainissement	Formation dédiée à la gestion de l’eau et des infrastructures hydrauliques.	Elle prépare aux métiers liés aux réseaux d’eau, à l’assainissement et à la protection environnementale.	Sciences et Technologies	3 ans	Hydraulique, Réseaux d’eau, Assainissement, Gestion des ressources hydriques, Environnement
86	Énergie renouvelable	Formation orientée vers les solutions énergétiques durables.	Elle prépare aux métiers liés à la production et la gestion des énergies propres.	Sciences et Technologies	3 ans	Énergies renouvelables, Électricité, Systèmes énergétiques, Maintenance, Développement durable
87	Management de l’environnement et stratégie de développement durable	Formation spécialisée dans la gestion environnementale et le développement durable.	Elle prépare aux métiers liés à la protection de l’environnement et aux stratégies durables.	Sciences et Technologies	3 ans	Gestion environnementale, Développement durable, Normes environnementales, Gestion des risques, Stratégie
88	Informatique industrielle	Formation combinant informatique, automatisation et systèmes industriels.	Elle prépare à la conception et la gestion des systèmes informatiques appliqués à l’industrie.	Sciences et Technologies	3 ans	Programmation industrielle, Automatisation, Systèmes embarqués, Réseaux industriels, Informatique
89	Génie biologique	Formation appliquée aux sciences biologiques et aux biotechnologies.	Elle prépare aux métiers liés aux analyses biologiques, à la santé et aux industries du vivant.	Sciences et Technologies	3 ans	Biologie, Biotechnologies, Analyse biologique, Microbiologie, Recherche
90	Génie des industries chimiques	Formation spécialisée dans les procédés chimiques industriels.	Elle prépare aux métiers de l’industrie chimique, de la production et du contrôle qualité.	Sciences et Technologies	3 ans	Chimie industrielle, Procédés chimiques, Contrôle qualité, Sécurité industrielle, Production
91	Génie des industries agroalimentaires	Formation dédiée à la transformation et la qualité des produits alimentaires.	Elle prépare aux métiers de l’agroalimentaire et du contrôle des produits alimentaires.	Agriculture, Agroalimentaire et Environnement	3 ans	Transformation alimentaire, Qualité agroalimentaire, Production, Hygiène, Sécurité alimentaire
92	Management des entreprises	Formation axée sur la gestion et le développement des entreprises.	Elle prépare aux métiers liés à la création, l’administration et la croissance des entreprises.	Économie et Gestion	3 ans	Gestion d’entreprise, Entrepreneuriat, Finance, Management, Stratégie commerciale
93	Tourisme, Hôtellerie et Langues	Formation regroupant les métiers du tourisme, de l’hôtellerie et des langues appliquées.	Elle prépare aux métiers de l’accueil, du voyage, de la gestion hôtelière et des services touristiques.	Tourisme, Communication et Services	3 ans	Accueil, Gestion hôtelière, Tourisme, Langues étrangères, Communication
94	Langue appliquée aux affaires	Formation orientée vers l’utilisation des langues dans les activités professionnelles.	Elle prépare aux métiers nécessitant communication internationale et compétences linguistiques.	Langues, Commerce et Communication	3 ans	Langues étrangères, Communication professionnelle, Négociation, Traduction, Relations internationales
95	Gestion hôtelière et restauration	Formation spécialisée dans la gestion des établissements hôteliers et de restauration.	Elle prépare aux métiers de l’hôtellerie, de la restauration et de la gestion des services.	Tourisme, Hôtellerie et Services	3 ans	Gestion hôtelière, Restauration, Accueil client, Organisation, Management
96	Interprétariat de conférence	Formation spécialisée dans la traduction orale professionnelle.	Elle prépare aux métiers de l’interprétation dans les organisations nationales et internationales.	Langues, Commerce et Communication	3 ans	Interprétation, Langues étrangères, Communication orale, Traduction, Relations internationales
97	Audit et Contrôle de Gestion	Formation spécialisée dans le contrôle des performances financières et organisationnelles des entreprises.	Elle prépare aux métiers de l’audit, du contrôle interne, du pilotage financier et de l’aide à la décision.	Économie et Gestion	3 ans	Audit, Contrôle de gestion, Analyse financière, Contrôle interne, Reporting, Aide à la décision
98	Administration Économique et Sociale (AES)	Formation pluridisciplinaire en économie, droit, gestion et sciences sociales.	Elle prépare aux métiers de l’administration, de la gestion publique et du développement social.	Économie, Droit et Sciences sociales	3 ans	Économie, Droit, Gestion administrative, Sciences sociales, Analyse des politiques publiques
99	Économie et Gestion	Formation combinant l’analyse économique et les techniques de gestion.	Elle prépare aux métiers de la gestion des organisations, de l’analyse économique et du management.	Économie et Gestion	3 ans	Économie, Gestion, Analyse financière, Management, Statistiques, Gestion d’entreprise
100	Méthodes Informatiques Appliquées à la Gestion des Entreprises (MIAGE)	Formation combinant informatique, systèmes d’information et gestion des entreprises.	Elle prépare à la conception et au pilotage des solutions numériques pour les organisations.	Sciences et Technologies	3 ans	Systèmes d’information, Bases de données, Gestion d’entreprise, Programmation, Analyse des besoins
101	Sciences Politiques	Formation consacrée à l’étude des institutions politiques et des relations de pouvoir.	Elle prépare aux métiers de l’administration publique, des organisations internationales et de la recherche.	Droit et Sciences sociales	3 ans	Analyse politique, Institutions, Relations internationales, Recherche, Communication
102	Gestion de Projets de Développement	Formation orientée vers la conception et la gestion des projets de développement.	Elle prépare aux métiers des ONG, programmes publics et organisations de développement.	Droit, Économie et Développement	3 ans	Gestion de projet, Suivi-évaluation, Planification, Développement local, Coordination
103	Gouvernance Locale et Développement Territorial	Formation spécialisée dans la gestion des collectivités et du développement territorial.	Elle prépare aux métiers liés aux collectivités locales et aux politiques territoriales.	Droit et Administration publique	3 ans	Développement territorial, Administration locale, Gestion publique, Planification
104	Gouvernance Publique et Développement Local	Formation dédiée à la gestion publique et aux stratégies de développement local.	Elle prépare aux fonctions administratives et aux projets publics.	Droit et Administration publique	3 ans	Gouvernance, Gestion publique, Politiques publiques, Administration, Développement local
105	Comptabilité	Formation spécialisée dans l’enregistrement et l’analyse des opérations comptables.	Elle prépare aux métiers de la comptabilité et du suivi financier des organisations.	Économie et Gestion	3 ans	Comptabilité, Analyse financière, Fiscalité, Gestion budgétaire, Logiciels comptables
106	Comptabilité et Gestion	Formation combinant comptabilité, finance et gestion d’entreprise.	Elle prépare aux métiers de la gestion financière et administrative des entreprises.	Économie et Gestion	3 ans	Comptabilité, Gestion, Finance, Fiscalité, Contrôle de gestion
107	Réseaux Informatiques	Formation spécialisée dans la conception et la gestion des réseaux informatiques.	Elle prépare aux métiers liés aux infrastructures réseaux et aux systèmes informatiques.	Sciences et Technologies	3 ans	Réseaux informatiques, Administration système, Sécurité réseau, Protocoles, Maintenance
108	Actuariat	Formation spécialisée dans l’évaluation des risques financiers et assurantiels.	Elle prépare aux métiers de l’assurance, de la finance et de la gestion des risques.	Économie et Gestion	5 ans	Mathématiques financières, Statistiques, Probabilités, Gestion des risques, Assurance
109	Administration et Gestion des Entreprises	Formation axée sur l’administration et le fonctionnement des entreprises.	Elle prépare aux métiers de la gestion administrative et du management.	Économie et Gestion	3 ans	Administration, Gestion, Organisation, Management, Communication
110	Agronomie	Formation consacrée aux sciences agricoles et aux systèmes de production.	Elle prépare aux métiers de l’agriculture, de la production végétale et du développement rural.	Agriculture, Agroalimentaire et Environnement	3 ans	Agriculture, Production végétale, Gestion des cultures, Développement rural, Environnement
111	Journalisme	Formation dédiée aux techniques d’information et de communication médiatique.	Elle prépare aux métiers de la presse, des médias et de la production d’information.	Communication et Médias	3 ans	Recherche d’information, Rédaction, Communication, Investigation, Analyse
112	Administration des Affaires	Formation orientée vers la gestion globale des entreprises.	Elle prépare aux métiers du management, du commerce et de l’entrepreneuriat.	Économie et Gestion	3 ans	Management, Commerce, Stratégie, Gestion financière, Entrepreneuriat
113	Architecture	Formation spécialisée dans la conception et la réalisation des espaces construits.	Elle prépare aux métiers de la conception architecturale et de la gestion des projets de construction.	Sciences et Technologies	5 ans	Conception architecturale, DAO, Urbanisme, Dessin technique, Gestion de projet
114	Mathématiques Appliquées	Formation orientée vers l’utilisation des mathématiques dans les sciences et l’entreprise.	Elle prépare aux métiers de la modélisation, de la statistique et de l’analyse.	Sciences et Technologies	3 ans	Mathématiques, Modélisation, Statistiques, Analyse de données, Probabilités
115	Infographie et Multimédia	Formation spécialisée dans la création graphique et les contenus numériques.	Elle prépare aux métiers du design numérique, de la communication visuelle et du multimédia.	Communication et Création	3 ans	Design graphique, Création numérique, Montage vidéo, Multimédia, Créativité
116	Maintenance Informatique	Formation dédiée à l’installation, la réparation et la maintenance des équipements informatiques.	Elle prépare aux métiers du support informatique et de la maintenance des systèmes.	Sciences et Technologies	3 ans	Maintenance informatique, Diagnostic, Matériel informatique, Systèmes d’exploitation
117	Fiscalité	Formation spécialisée dans les règles fiscales et la gestion des obligations fiscales.	Elle prépare aux métiers de la fiscalité et du conseil financier.	Économie et Gestion	3 ans	Fiscalité, Droit fiscal, Comptabilité, Analyse financière, Conseil
118	Ingénierie Financière	Formation spécialisée dans les techniques financières avancées.	Elle prépare aux métiers de la finance d’entreprise, de l’investissement et de l’analyse financière.	Économie et Gestion	5 ans	Finance, Modélisation financière, Investissement, Gestion des risques, Analyse
119	Management des NTIC	Formation combinant management et technologies numériques.	Elle prépare aux métiers du pilotage des projets numériques et des organisations technologiques.	Sciences et Technologies	3 ans	Management, Technologies numériques, Gestion de projet, Innovation, Systèmes d’information
120	Passation des Marchés	Formation spécialisée dans les procédures d’achat et de marchés publics.	Elle prépare aux métiers des marchés publics et de la gestion des contrats.	Droit et Administration publique	3 ans	Marchés publics, Droit administratif, Gestion des contrats, Négociation
121	Communication	Formation consacrée aux stratégies de communication et aux médias.	Elle prépare aux métiers de la communication institutionnelle et commerciale.	Communication et Médias	3 ans	Communication, Relations publiques, Stratégie média, Créativité
122	Créativité Événementielle	Formation spécialisée dans la conception et l’organisation d’événements.	Elle prépare aux métiers de l’événementiel et de la communication.	Communication et Culture	3 ans	Organisation événementielle, Communication, Gestion de projet, Créativité
123	Vente et Relation Client	Formation orientée vers les techniques commerciales et la gestion client.	Elle prépare aux métiers de la vente, du commerce et du développement commercial.	Commerce et Gestion	3 ans	Vente, Relation client, Négociation, Communication commerciale
124	Stratégie de l’Entreprise	Formation dédiée à l’analyse et au développement stratégique des organisations.	Elle prépare aux métiers du conseil, du management et du pilotage stratégique.	Économie et Gestion	5 ans	Stratégie, Analyse organisationnelle, Management, Gestion de projet
125	Sciences Politiques et Relations Internationales	Formation combinant sciences politiques et relations internationales.	Elle prépare aux métiers de la diplomatie, des organisations internationales et de l’administration.	Droit et Sciences sociales	3 ans	Relations internationales, Géopolitique, Analyse politique, Communication
126	Sociologie des Organisations	Formation spécialisée dans l’étude des comportements humains dans les organisations.	Elle prépare aux métiers des ressources humaines, du conseil et du développement organisationnel.	Sciences sociales et Gestion	3 ans	Sociologie, Organisation, Ressources humaines, Analyse sociale, Communication
127	Management appliqué	Formation orientée vers le management opérationnel des organisations.	Prépare aux métiers de gestion et de coordination des entreprises.	Économie et Gestion	3 ans	Management,Leadership,Organisation,Gestion,Communication
128	Droit public	Étude des institutions publiques et du droit administratif.	Prépare aux carrières de l’administration publique et des collectivités.	Droit et Sciences sociales	4 ans	Droit administratif,Droit constitutionnel,Rédaction juridique,Analyse juridique
129	Droit privé	Étude des relations juridiques entre les personnes physiques et morales.	Prépare aux métiers du droit des affaires, du conseil juridique et de la magistrature.	Droit et Sciences sociales	4 ans	Droit civil,Droit commercial,Contentieux,Rédaction juridique
130	Communication et Leadership	Formation combinant communication professionnelle et développement du leadership.	Prépare aux métiers de la communication institutionnelle et du management.	Communication et Médias	3 ans	Communication,Leadership,Relations publiques,Prise de parole
131	Microfinance	Formation spécialisée dans les institutions financières décentralisées.	Prépare aux métiers de la finance inclusive et du développement économique.	Économie et Gestion	3 ans	Finance,Microfinance,Gestion des risques,Analyse financière
132	Management de la Distribution Automobile	Formation spécialisée dans la gestion des réseaux de distribution automobile.	Prépare aux métiers du commerce automobile et de la gestion des concessions.	Commerce et Gestion	3 ans	Commerce,Management,Négociation,Relation client
133	Maintenance industrielle	Formation orientée vers la maintenance des équipements industriels.	Prépare aux métiers de la maintenance et de la production industrielle.	Sciences et Technologies	3 ans	Maintenance,Électromécanique,Diagnostic,Production
134	Graphisme	Formation spécialisée dans la conception graphique.	Prépare aux métiers du design graphique et de la communication visuelle.	Communication et Création	3 ans	Design graphique,PAO,Illustration,Créativité
135	Audiovisuel	Formation spécialisée dans la production audiovisuelle.	Prépare aux métiers du cinéma, de la télévision et des médias numériques.	Communication et Médias	3 ans	Montage vidéo,Cadrage,Production,Créativité
136	Management des Systèmes d'Information	Formation combinant management et systèmes d’information.	Prépare aux métiers du pilotage des systèmes d’information.	Sciences et Technologies	3 ans	Systèmes d'information,Management,Analyse,ERP
137	Réseaux et Systèmes de Sécurité	Formation spécialisée dans la sécurisation des réseaux informatiques.	Prépare aux métiers de l’administration réseau et de la cybersécurité.	Sciences et Technologies	3 ans	Réseaux,Cybersécurité,Administration système,Sécurité
138	Assistanat de Direction	Formation spécialisée dans l’assistanat de direction.	Prépare aux métiers de l’administration et du secrétariat de direction.	Économie et Gestion	2 ans	Organisation,Bureautique,Communication,Gestion administrative
139	Marketing digital	Formation spécialisée dans le marketing numérique.	Prépare aux métiers du marketing digital et du e-commerce.	Commerce et Gestion	3 ans	Marketing digital,SEO,Publicité,Community management
140	Management Supply Chain	Formation spécialisée dans la gestion de la chaîne logistique.	Prépare aux métiers de la logistique et de la supply chain.	Transport, Logistique, Commerce International et Supply Chain	3 ans	Supply chain,Logistique,Approvisionnement,Transport
141	Systèmes économiques et de gestion	Formation axée sur les systèmes économiques et le management.	Prépare aux métiers de l’analyse économique et de la gestion.	Économie et Gestion	3 ans	Économie,Gestion,Analyse financière,Management
142	Sciences et Technologies	Formation scientifique pluridisciplinaire.	Prépare aux poursuites d’études scientifiques et technologiques.	Sciences et Technologies	3 ans	Mathématiques,Physique,Analyse,Raisonnement scientifique
143	Internet et Web	Formation spécialisée dans les technologies du web.	Prépare aux métiers du développement web et des services Internet.	Sciences et Technologies	3 ans	HTML,CSS,JavaScript,Développement Web
144	Luxury and Hospitality Management	Formation spécialisée dans le management du tourisme haut de gamme.	Prépare aux métiers de l’hôtellerie de luxe et du tourisme international.	Tourisme, Hôtellerie et Restauration	3 ans	Management hôtelier,Service client,Hospitality,Gestion
145	Sciences juridiques	Formation générale en droit et sciences juridiques.	Prépare aux métiers du droit, de la justice et de l’administration.	Droit et Sciences sociales	4 ans	Analyse juridique,Rédaction juridique,Argumentation,Droit public,Droit privé
146	Sciences agroalimentaires	Formation spécialisée dans la transformation et la qualité des produits alimentaires.	Prépare aux métiers de l’industrie agroalimentaire.	Agriculture, Agroalimentaire et Environnement	3 ans	Transformation alimentaire,Contrôle qualité,HACCP,Production,Innovation
147	Agronomie et Production végétale	Formation spécialisée dans les productions agricoles végétales.	Prépare aux métiers de l’agriculture moderne et durable.	Agriculture, Agroalimentaire et Environnement	3 ans	Agronomie,Agriculture,Production végétale,Irrigation,Développement rural
148	Sciences de l'Information et de la Communication	Formation consacrée à la communication, aux médias et à l’information.	Prépare aux métiers des médias et de la communication.	Communication et Médias	3 ans	Communication,Rédaction,Relations publiques,Médias,Prise de parole
149	Études comptables et financières	Formation spécialisée en comptabilité et finance.	Prépare aux métiers de la comptabilité, de l’audit et de la finance.	Économie et Gestion	3 ans	Comptabilité,Finance,Audit,Fiscalité,Analyse financière
150	Droit économique et des affaires	Formation en droit appliqué aux entreprises.	Prépare aux métiers du conseil juridique et du droit des sociétés.	Droit et Sciences sociales	4 ans	Droit des affaires,Droit économique,Négociation,Rédaction juridique
151	Sciences de gestion	Formation générale en management et gestion.	Prépare aux métiers de gestion des organisations.	Économie et Gestion	3 ans	Management,Gestion,Leadership,Organisation,Planification
152	Physique-Chimie	Formation scientifique en physique et chimie.	Prépare aux études scientifiques et industrielles.	Sciences et Technologies	3 ans	Physique,Chimie,Analyse scientifique,Expérimentation
153	Mathématiques	Formation spécialisée en mathématiques.	Prépare aux métiers de l’enseignement, de la recherche et de l’analyse.	Sciences et Technologies	3 ans	Mathématiques,Analyse,Statistiques,Raisonnement logique
154	Langues, Traduction et Interprétariat	Formation spécialisée dans les langues étrangères.	Prépare aux métiers de la traduction et de l’interprétation.	Langues et Lettres	3 ans	Traduction,Interprétation,Communication,Rédaction,Langues
155	Sociologie	Formation spécialisée dans l’étude des sociétés.	Prépare aux métiers de la recherche sociale et du développement.	Droit et Sciences sociales	3 ans	Sociologie,Recherche,Analyse sociale,Enquête
156	Entrepreneuriat	Formation orientée vers la création et la gestion d’entreprise.	Prépare aux métiers de l’innovation et de l’entrepreneuriat.	Économie et Gestion	3 ans	Création d'entreprise,Business plan,Leadership,Innovation
157	Journalisme et Communication	Formation spécialisée dans les médias et la communication.	Prépare aux métiers du journalisme et de la communication.	Communication et Médias	3 ans	Journalisme,Rédaction,Communication,Reportage
158	Génie informatique	Formation spécialisée dans le développement logiciel et les systèmes informatiques.	Prépare aux métiers de l’ingénierie informatique.	Sciences et Technologies	3 ans	Programmation,Génie logiciel,Bases de données,Réseaux
159	Droit des affaires et Fiscalité	Formation spécialisée en droit des entreprises et fiscalité.	Prépare aux métiers du droit fiscal et des entreprises.	Droit et Sciences sociales	4 ans	Droit fiscal,Droit des affaires,Fiscalité,Négociation
160	Ingénierie immobilière et Gestion foncière	Formation spécialisée dans l’immobilier et le foncier.	Prépare aux métiers de l’immobilier et de la gestion foncière.	Génie Civil / BTP	3 ans	Immobilier,Gestion foncière,Urbanisme,Évaluation immobilière
161	Biologie	Formation spécialisée dans les sciences biologiques.	Prépare aux métiers de la recherche, de la santé et des laboratoires.	Santé	3 ans	Biologie,Génétique,Microbiologie,Biochimie,Recherche
162	Télécommunications	Formation spécialisée dans les technologies de communication et les réseaux de télécommunication.	Elle prépare aux métiers liés aux infrastructures télécom, aux réseaux mobiles et aux systèmes de communication.	Sciences et Technologies	3 ans	Télécommunications,Réseaux,Transmission,Communication numérique,Systèmes mobiles
163	Marketing Management	Formation combinant les techniques marketing et la gestion des organisations commerciales.	Elle prépare aux métiers du marketing, du management commercial et du développement des entreprises.	Commerce et Gestion	3 ans	Marketing,Management,Étude de marché,Stratégie commerciale,Vente
164	Marketing Finance	Formation combinant les approches marketing et les techniques financières.	Elle prépare aux métiers liés à la gestion commerciale, financière et stratégique des entreprises.	Économie et Gestion	3 ans	Marketing,Finance,Analyse financière,Gestion commerciale,Stratégie
165	Systèmes et Technologies de l'Information	Formation spécialisée dans les systèmes d’information et les technologies numériques.	Elle prépare aux métiers de la gestion des infrastructures numériques et des systèmes informatiques.	Sciences et Technologies	3 ans	Systèmes d’information,Réseaux,Bases de données,Gestion informatique,Cybersécurité
166	Logistique et Transit	Formation spécialisée dans la gestion des opérations logistiques et douanières.	Elle prépare aux métiers du transport international, du transit et de la chaîne logistique.	Transport, Logistique, Commerce International et Supply Chain	3 ans	Logistique,Transit,Transport,Douane,Supply Chain
167	Professeur de Mathématiques	Formation destinée à l’enseignement des mathématiques.	Elle prépare aux métiers de l’enseignement secondaire et supérieur en mathématiques.	Éducation, Formation et Recherche	3 ans à 5 ans	Mathématiques,Pédagogie,Didactique,Communication,Évaluation
168	Professeur de Physique-Chimie	Formation destinée à l’enseignement de la physique et de la chimie.	Elle prépare aux métiers de l’enseignement scientifique.	Éducation, Formation et Recherche	3 ans à 5 ans	Physique,Chimie,Pédagogie,Didactique,Expérimentation
169	Professeur de Sciences de la Vie et de la Terre	Formation destinée à l’enseignement des sciences naturelles.	Elle prépare aux métiers de l’enseignement des SVT.	Éducation, Formation et Recherche	3 ans à 5 ans	Biologie,Géologie,Pédagogie,Didactique,Recherche
170	Professeur de Français	Formation spécialisée dans l’enseignement du français.	Elle prépare aux métiers de l’enseignement et de la communication linguistique.	Éducation, Formation et Recherche	3 ans à 5 ans	Français,Littérature,Pédagogie,Rédaction,Communication
171	Professeur de Géographie	Formation spécialisée dans l’enseignement de la géographie.	Elle prépare aux métiers de l’enseignement et de la recherche géographique.	Éducation, Formation et Recherche	3 ans à 5 ans	Géographie,Cartographie,Analyse territoriale,Pédagogie
172	Professeur d'Anglais	Formation spécialisée dans l’enseignement de la langue anglaise.	Elle prépare aux métiers de l’enseignement et de la communication internationale.	Éducation, Formation et Recherche	3 ans à 5 ans	Anglais,Communication,Traduction,Pédagogie
173	Professeur d'Espagnol	Formation spécialisée dans l’enseignement de la langue espagnole.	Elle prépare aux métiers de l’enseignement des langues étrangères.	Éducation, Formation et Recherche	3 ans à 5 ans	Espagnol,Communication,Traduction,Pédagogie
174	Professeur de Philosophie	Formation spécialisée dans l’enseignement de la philosophie.	Elle prépare aux métiers de l’enseignement et de la réflexion critique.	Éducation, Formation et Recherche	3 ans à 5 ans	Philosophie,Analyse critique,Argumentation,Pédagogie
175	Professeur d'Éducation Physique et Sportive	Formation spécialisée dans l’enseignement sportif et l’éducation physique.	Elle prépare aux métiers de l’enseignement de l’EPS.	Éducation, Formation et Recherche	3 ans à 5 ans	Sport,Pédagogie,Préparation physique,Encadrement
176	Eau, Environnement et Assainissement	Formation spécialisée dans la gestion de l’eau et des problématiques environnementales.	Elle prépare aux métiers liés à l’hydraulique, l’environnement et l’assainissement.	Génie Civil / BTP	3 ans	Hydraulique,Environnement,Assainissement,Gestion des ressources
177	Travaux Publics	Formation spécialisée dans la construction des infrastructures publiques.	Elle prépare aux métiers des routes, ouvrages publics et infrastructures.	Génie Civil / BTP	3 ans à 5 ans	Construction,Routes,Gestion de chantier,Topographie,Structures
178	Marketing Vente	Formation spécialisée dans les techniques commerciales et la vente.	Elle prépare aux métiers du commerce, de la négociation et de la relation client.	Commerce et Gestion	3 ans	Vente,Négociation,Marketing,Relation client,Communication
179	Sciences économiques	Formation en économie.	La filière Sciences économiques forme des spécialistes capables d’analyser les phénomènes économiques, les politiques publiques, les marchés et le développement économique.	Économie	3 ans	Analyse économique, modélisation, statistiques, politiques économiques
180	Langues	Formation en langues.	La filière Langues développe les compétences linguistiques, culturelles et communicationnelles dans plusieurs langues étrangères.	Langues	3 ans	Communication multilingue, traduction, expression écrite et orale
181	Géographie	Formation en géographie.	La filière Géographie prépare aux études de l’espace, de l’aménagement du territoire, de l’environnement et du développement territorial.	Lettres et Sciences humaines	3 ans	Cartographie, SIG, aménagement du territoire
182	Histoire	Formation en histoire.	La filière Histoire permet d’étudier les civilisations, les sociétés et les événements historiques afin de développer une compréhension critique du passé.	Lettres et Sciences humaines	3 ans	Recherche historique, analyse documentaire
183	Philosophie	Formation en philosophie.	La filière Philosophie développe la réflexion critique, l’éthique et l’analyse des grandes pensées philosophiques.	Lettres et Sciences humaines	3 ans	Esprit critique, argumentation, analyse
184	Physique	Formation en physique.	La filière Physique forme aux sciences fondamentales de la matière, de l’énergie et des phénomènes physiques.	Sciences	3 ans	Modélisation, expérimentation, analyse
185	Chimie	Formation en chimie.	La filière Chimie prépare aux sciences de la matière, aux réactions chimiques et aux applications industrielles.	Sciences	3 ans	Analyse chimique, laboratoire, formulation
186	Sciences de la Vie et de la Terre	Formation en SVT.	La filière Sciences de la Vie et de la Terre étudie les organismes vivants, les écosystèmes et les sciences de la Terre.	Sciences	3 ans	Biologie, écologie, géologie
187	Anthropologie	Formation en anthropologie.	La filière Anthropologie étudie les cultures, les sociétés humaines et leurs évolutions.	Lettres et Sciences humaines	3 ans	Recherche sociale, observation, analyse culturelle
188	Lettres modernes	Formation en lettres modernes.	La filière Lettres modernes développe les connaissances en littérature, linguistique et analyse des textes.	Lettres et Sciences humaines	3 ans	Analyse littéraire, rédaction, expression
189	Littérature	Formation en littérature.	La filière Littérature développe les connaissances en littérature classique, contemporaine et comparée ainsi que les capacités d’analyse des œuvres.	Lettres et Sciences humaines	3 ans	Analyse littéraire, rédaction, esprit critique
190	Métiers des Arts	Formation en arts.	La filière Métiers des Arts prépare aux métiers de la création artistique et culturelle.	Arts et Culture	3 ans	Créativité, techniques artistiques, gestion de projets culturels
191	Cinéma	Formation en cinéma.	La filière Cinéma forme aux métiers de la réalisation, de la production audiovisuelle et de l’écriture cinématographique.	Arts et Audiovisuel	3 ans	Réalisation, montage, scénario
192	Socio-anthropologie	Formation en socio-anthropologie.	La filière Socio-anthropologie combine les approches sociologiques et anthropologiques pour analyser les sociétés humaines.	Lettres et Sciences humaines	3 ans	Analyse sociale, recherche qualitative
193	Élevage	Formation en élevage.	La filière Élevage prépare aux métiers de la production animale et de la gestion des exploitations.	Agriculture	3 ans	Zootechnie, gestion des élevages
194	Aquaculture	Formation en aquaculture.	La filière Aquaculture forme aux techniques de production des organismes aquatiques.	Agriculture	3 ans	Pisciculture, gestion des ressources aquatiques
195	Enseignement	Formation en enseignement.	La filière Enseignement prépare aux métiers de l’éducation et de la pédagogie.	Éducation	3 ans	Pédagogie, didactique
196	Formation	Formation de formateurs.	La filière Formation prépare à la conception, l’organisation et l’animation de formations professionnelles.	Éducation	3 ans	Ingénierie de formation, pédagogie
197	STAPS	Sciences et Techniques des Activités Physiques et Sportives.	La filière STAPS prépare aux métiers du sport, de l’éducation physique et de l’entraînement.	Sport	3 ans	Entraînement, pédagogie sportive
198	Musique	Formation en musique.	La filière Musique prépare aux métiers de la création, de l’interprétation et de l’enseignement musical.	Arts et Culture	3 ans	Interprétation, composition
199	Production animale	Formation en production animale.	La filière Production animale forme aux techniques modernes de production et de gestion animale.	Agriculture	3 ans	Production animale, zootechnie
200	Physique appliquée	Formation en physique appliquée.	La filière Physique appliquée développe les applications industrielles et technologiques de la physique.	Sciences	3 ans	Instrumentation, technologies, expérimentation
201	Arts dramatiques	Formation en arts dramatiques.	La filière Arts dramatiques prépare aux métiers du théâtre, de la scène et de la mise en scène.	Arts et Culture	3 ans	Jeu d’acteur, mise en scène
202	Génie électrique	Formation en génie électrique.	La filière Génie électrique forme des spécialistes des systèmes électriques, de l’énergie et des installations industrielles.	Ingénierie	3 ans	Électricité, énergie, automatisme
203	Orthoptie	Formation en orthoptie.	La filière Orthoptie prépare aux métiers de la rééducation visuelle et de l’exploration fonctionnelle de la vision.	Santé	3 ans	Rééducation visuelle, examens ophtalmologiques
204	Optique lunetterie	Formation en optique lunetterie.	La filière Optique lunetterie prépare aux métiers de l’optique médicale et de la correction visuelle.	Santé	3 ans	Optique, contactologie, équipements
205	Géomatique	Formation en géomatique.	La filière Géomatique développe les compétences en cartographie numérique, SIG et télédétection.	Géosciences	3 ans	SIG, cartographie, télédétection
206	Géo-mesures et Aménagement	Formation en géo-mesures et aménagement.	La filière prépare aux métiers des mesures topographiques et de l’aménagement du territoire.	Géosciences	3 ans	Topographie, aménagement, mesures
207	Hydrogéologie	Formation en hydrogéologie.	La filière forme à l’étude des eaux souterraines et des ressources hydriques.	Sciences de la Terre	3 ans	Hydrologie, géologie, ressources en eau
208	Hydrosciences	Formation en hydrosciences.	La filière est spécialisée dans les sciences de l’eau, l’hydrologie et la gestion durable des ressources hydriques.	Sciences	3 ans	Hydrologie, gestion de l’eau
209	Environnement	Formation en environnement.	La filière prépare aux métiers de la protection de l’environnement, du développement durable et de la gestion des ressources naturelles.	Environnement	3 ans	Développement durable, gestion environnementale
210	Big Data	Formation en Big Data.	La filière Big Data forme des spécialistes du traitement massif des données, des architectures distribuées et de l’analyse décisionnelle.	Informatique	3 ans	Analyse de données, Hadoop, Spark, bases de données
211	Génie mécanique	Formation en génie mécanique.	La filière Génie mécanique prépare aux métiers de la conception, de la fabrication et de la maintenance des systèmes mécaniques.	Ingénierie	3 ans	Conception mécanique, CAO, fabrication
212	Génie de données et Technologies Omics	Formation en génie de données et technologies omics.	La filière prépare aux métiers de la bioinformatique, des sciences omiques et de la gestion des données biologiques.	Informatique	3 ans	Bioinformatique, génomique, analyse de données
213	Automatisme industriel	Formation en automatisme industriel.	La filière forme à la conception et à la maintenance des systèmes automatisés industriels.	Ingénierie	3 ans	Automates programmables, robotique, supervision
214	Analyses biologiques	Formation en analyses biologiques.	La filière prépare aux métiers des laboratoires d’analyses biologiques et biomédicales.	Santé	3 ans	Techniques de laboratoire, microbiologie, biochimie
215	Technologies de l'eau et de l'environnement	Formation en technologies de l'eau et de l'environnement.	La filière forme aux métiers de la gestion de l’eau, du traitement des eaux et de la protection de l’environnement.	Environnement	3 ans	Traitement des eaux, environnement, assainissement
216	Modélisation et traitement informatique des données	Formation en modélisation des données.	La filière prépare aux techniques de modélisation, de simulation et de traitement informatique des données scientifiques.	Informatique	3 ans	Programmation, modélisation, analyse de données
217	Gestion et exploitation durable des ressources forestières et agricoles locales	Formation en gestion des ressources naturelles.	La filière forme à la gestion durable des ressources forestières et agricoles en intégrant les enjeux environnementaux.	Agriculture	3 ans	Gestion forestière, agriculture durable, environnement
218	Mécanique	Formation en mécanique.	La filière développe les compétences fondamentales en mécanique générale et appliquée.	Ingénierie	3 ans	Conception mécanique, calcul, maintenance
219	Thermodynamique	Formation en thermodynamique.	La filière prépare aux applications énergétiques et industrielles de la thermodynamique.	Sciences	3 ans	Énergie, transferts thermiques, physique
220	Économie internationale	Formation en économie internationale.	La filière prépare aux échanges internationaux, à la mondialisation et aux politiques commerciales.	Économie	3 ans	Commerce international, analyse économique
221	Politiques publiques et planification du développement	Formation en politiques publiques.	La filière prépare à la conception, la gestion et l’évaluation des politiques publiques et des programmes de développement.	Administration	3 ans	Planification, gouvernance, développement
222	Finance d'entreprise	Formation en finance d'entreprise.	La filière forme à la gestion financière des organisations et aux décisions d’investissement.	Finance	3 ans	Analyse financière, investissement, contrôle
223	Entrepreneuriat et Développement (ENDEV)	Formation en entrepreneuriat.	La filière prépare à la création d’entreprise et au développement économique local.	Management	3 ans	Création d’entreprise, innovation
224	Langues étrangères appliquées (LEA)	Formation en LEA.	La filière développe les compétences linguistiques appliquées aux affaires, au commerce et aux relations internationales.	Langues	3 ans	Communication multilingue, traduction
225	Criminologie	Formation en criminologie.	La filière prépare à l’étude scientifique de la criminalité, de la justice pénale et de la prévention.	Droit	3 ans	Analyse criminelle, droit pénal
226	Sciences paramédicales	Formation en sciences paramédicales.	La filière prépare aux professions paramédicales et aux soins spécialisés.	Santé	3 ans	Soins, techniques médicales
227	Santé communautaire	Formation en santé communautaire.	La filière forme à la prévention, à la promotion de la santé et aux interventions communautaires.	Santé	3 ans	Santé publique, prévention, épidémiologie
228	Management juridique environnemental et foncier	Formation en management juridique.	La filière prépare aux métiers du droit foncier, de l’environnement et de la gestion juridique des territoires.	Droit	3 ans	Droit foncier, droit de l’environnement, gestion territoriale
229	Commerce électronique et Cybersécurité	Formation en e-commerce et cybersécurité.	La filière forme aux plateformes numériques, au commerce électronique et à la sécurisation des systèmes d’information.	Informatique	3 ans	E-commerce, cybersécurité, réseaux
230	Santé-Environnement	Formation en santé-environnement.	La filière prépare à l’étude des interactions entre la santé publique et les facteurs environnementaux.	Santé	3 ans	Santé publique, environnement, prévention
231	Conseil agricole	Formation en conseil agricole.	La filière prépare aux métiers de l’accompagnement des exploitations agricoles et du développement rural.	Agriculture	3 ans	Conseil, développement rural, production agricole
232	Eaux et Forêts	Formation en eaux et forêts.	La filière forme à la gestion durable des ressources forestières, de la faune et des ressources en eau.	Environnement	3 ans	Gestion forestière, conservation, ressources naturelles
233	Développement Mobile	Formation en développement mobile.	La filière prépare à la conception et au développement d’applications mobiles Android, iOS et multiplateformes.	Informatique	3 ans	Programmation mobile, UX/UI, API
234	Sciences Informatiques et Mathématiques de la Cybersécurité (SIMAC)	Formation en cybersécurité.	La filière combine informatique, mathématiques et cybersécurité pour former des spécialistes de la sécurité numérique.	Informatique	3 ans	Cybersécurité, cryptographie, mathématiques
235	Mathématiques Appliquées et Informatique (MAI)	Formation en mathématiques appliquées.	La filière associe les mathématiques appliquées et l’informatique pour répondre aux besoins de l’analyse scientifique et décisionnelle.	Informatique	3 ans	Programmation, modélisation, mathématiques
236	Multimédia Internet et Communication (MIC)	Formation en multimédia.	La filière prépare aux métiers du multimédia, du web, de la communication numérique et des contenus interactifs.	Communication	3 ans	Web, audiovisuel, communication digitale
237	Robotique	Formation en robotique.	La filière prépare à la conception, la programmation et la maintenance des systèmes robotisés.	Ingénierie	3 ans	Robotique, automatisation, programmation
238	Anglais	Formation en anglais.	La filière développe les compétences linguistiques et culturelles en langue anglaise.	Langues	3 ans	Communication, traduction, expression
239	Sciences de l'éducation	Formation en sciences de l'éducation.	La filière prépare aux métiers de l’éducation, de la pédagogie et de la formation.	Éducation	3 ans	Pédagogie, didactique, ingénierie pédagogique
240	Communication d'entreprise	Formation en communication d'entreprise.	La filière prépare aux métiers de la communication institutionnelle, interne et externe des organisations.	Communication	3 ans	Communication institutionnelle, stratégie, médias
241	Agroécologie	Formation en agroécologie.	La filière Agroécologie forme aux systèmes agricoles durables conciliant production, environnement et développement rural.	Agriculture	3 ans	Agriculture durable, écologie, développement rural
242	Sciences halieutiques	Formation en sciences halieutiques.	La filière prépare aux métiers des pêches, de l’aquaculture et de la gestion durable des ressources halieutiques.	Agriculture	3 ans	Pêches, aquaculture, gestion des ressources
243	Transformation des agroressources	Formation en transformation agroalimentaire.	La filière forme à la valorisation et à la transformation industrielle des produits agricoles.	Agroalimentaire	3 ans	Transformation, qualité, procédés
244	Gestion de la qualité et sécurité des aliments	Formation en qualité alimentaire.	La filière prépare à la maîtrise de la qualité et de la sécurité sanitaire des aliments.	Agroalimentaire	3 ans	Qualité, HACCP, sécurité alimentaire
245	Finance rurale	Formation en finance rurale.	La filière prépare au financement des exploitations agricoles et au développement économique rural.	Finance	3 ans	Microfinance, finance agricole
246	Management des entreprises agricoles et agroalimentaires	Formation en management agricole.	La filière prépare à la gestion des entreprises agricoles et des industries agroalimentaires.	Management	3 ans	Management, agroalimentaire, entrepreneuriat
247	Restauration et gastronomie	Formation en restauration.	La filière prépare aux métiers de la restauration, de la gastronomie et des arts culinaires.	Hôtellerie	3 ans	Cuisine, gestion de restaurant
248	Production touristique et management culturel	Formation en tourisme.	La filière forme aux métiers du tourisme, de la valorisation culturelle et du patrimoine.	Tourisme	3 ans	Tourisme, patrimoine, management culturel
249	Droit de l'environnement et du foncier	Formation en droit.	La filière prépare aux métiers du droit environnemental et de la gestion foncière.	Droit	3 ans	Droit foncier, droit environnemental
250	Machinisme agricole	Formation en machinisme agricole.	La filière prépare à la conception, l’utilisation et la maintenance des équipements agricoles.	Agriculture	3 ans	Mécanisation, maintenance
251	Énergies renouvelables appliquées à l'agriculture	Formation en énergies renouvelables.	La filière prépare à l’utilisation des technologies énergétiques renouvelables dans les exploitations agricoles.	Énergie	3 ans	Énergies renouvelables, agriculture
252	Hydrologie et gestion de l'eau	Formation en hydrologie.	La filière prépare à la gestion durable des ressources en eau et à l’hydrologie appliquée.	Environnement	3 ans	Hydrologie, gestion de l’eau
253	Amélioration des plantes	Formation en amélioration végétale.	La filière forme aux techniques de sélection, d’amélioration génétique et de développement des variétés végétales adaptées.	Agriculture	3 ans	Génétique végétale, sélection, production agricole
254	Protection des cultures et phytiatrie	Formation en protection des cultures.	La filière prépare à la prévention et au traitement des maladies et ravageurs des cultures.	Agriculture	3 ans	Phytopathologie, protection végétale
255	Alimentation et nutrition animale	Formation en nutrition animale.	La filière développe les compétences liées à l’alimentation, la formulation des rations et la santé nutritionnelle animale.	Agriculture	3 ans	Nutrition animale, formulation, élevage
256	Hydraulique agricole	Formation en hydraulique agricole.	La filière prépare à la gestion de l’eau dans les systèmes agricoles et l’irrigation.	Agriculture	3 ans	Irrigation, hydraulique, gestion de l’eau
257	Aménagement hydro-agricole et infrastructure rurale	Formation en aménagement rural.	La filière forme aux infrastructures agricoles, à l’aménagement des territoires ruraux et aux systèmes hydro-agricoles.	Agriculture	3 ans	Aménagement rural, infrastructures, irrigation
258	Agroforesterie	Formation en agroforesterie.	La filière étudie l’association entre agriculture et ressources forestières pour une production durable.	Environnement	3 ans	Gestion des écosystèmes, agriculture durable
259	Gestion de la faune et des aires protégées	Formation en gestion de la faune.	La filière prépare à la conservation de la biodiversité et à la gestion des espaces protégés.	Environnement	3 ans	Conservation, biodiversité, gestion des ressources
260	Politique agricole	Formation en politiques agricoles.	La filière prépare à l’analyse et la mise en œuvre des politiques publiques agricoles.	Agriculture	3 ans	Politiques publiques, développement rural
261	Sociologie des organisations rurales	Formation en sociologie rurale.	La filière analyse les dynamiques sociales, les organisations rurales et le développement agricole.	Sociologie	3 ans	Analyse sociale, développement rural
262	Agrobusiness	Formation en agrobusiness.	La filière prépare à la gestion entrepreneuriale des activités agricoles et agroalimentaires.	Management	3 ans	Entrepreneuriat agricole, gestion commerciale
263	Marketing des produits agricoles	Formation en marketing agricole.	La filière forme aux stratégies de commercialisation et de valorisation des produits agricoles.	Marketing	3 ans	Marketing, commercialisation, marchés agricoles
264	Gestion d’exploitation agricole	Formation en gestion agricole.	La filière prépare à la gestion technique, économique et administrative des exploitations agricoles.	Agriculture	3 ans	Gestion agricole, planification, entrepreneuriat
265	Cycle Ingénieur Statisticien Économiste (ISE)	Formation d’ingénieur statisticien économiste.	La filière Ingénieur Statisticien Économiste forme des cadres spécialisés dans l’analyse statistique, l’économie quantitative, la modélisation et l’aide à la décision pour les administrations, entreprises et organisations internationales.	Statistique et Économie	3 ans	Statistique avancée, économétrie, analyse économique, modélisation
266	Cycle Analyste Statisticien	Formation en analyse statistique.	La filière Analyste Statisticien prépare aux métiers de l’exploitation, du traitement et de l’interprétation des données statistiques dans différents secteurs.	Statistique	3 ans	Analyse de données, statistiques appliquées, outils décisionnels
268	Génie industriel	Formation en génie industriel.	La filière Génie industriel forme des ingénieurs capables d’optimiser les systèmes de production, les processus industriels et la performance des organisations.	Ingénierie	3 ans	Gestion de production, optimisation, qualité, organisation industrielle
269	Génie aéronautique	Formation en génie aéronautique.	La filière Génie aéronautique prépare aux métiers liés à la conception, la maintenance et l’exploitation des systèmes aéronautiques.	Ingénierie	3 ans	Conception aéronautique, mécanique, maintenance
270	Aérospatial	Formation en aérospatial.	La filière Aérospatial développe les compétences dans les domaines des systèmes spatiaux, de la mécanique spatiale et des technologies aéronautiques avancées.	Ingénierie	3 ans	Aérospatial, mécanique, systèmes embarqués
271	Diplôme d'État de Docteur Vétérinaire	Formation de docteur vétérinaire.	Cette formation prépare des docteurs vétérinaires capables d’assurer la santé animale, la prévention des maladies, la sécurité sanitaire et la protection de la santé publique.	Santé animale	6 ans	Médecine vétérinaire, diagnostic, chirurgie animale, santé publique
272	Biochimie	Formation en biochimie.	La filière Biochimie étudie les mécanismes chimiques du vivant et leurs applications dans les domaines médical, vétérinaire et biologique.	Sciences biologiques	3 ans	Biologie moléculaire, analyses biochimiques, laboratoire
273	Pharmacie vétérinaire	Formation en pharmacie vétérinaire.	La filière prépare à l’étude, l’utilisation et la gestion des médicaments destinés aux animaux.	Santé animale	3 ans	Pharmacologie vétérinaire, médicaments, traitements
274	Qualité des aliments de l'homme	Formation en qualité alimentaire.	La filière forme aux techniques de contrôle, d’analyse et de gestion de la qualité sanitaire des aliments destinés à la consommation humaine.	Agroalimentaire	3 ans	Sécurité alimentaire, contrôle qualité, hygiène
275	Gestion et surveillance sanitaire de la faune sauvage	Formation en santé de la faune sauvage.	La filière prépare à la surveillance sanitaire des populations animales sauvages et à la conservation de la biodiversité.	Environnement	3 ans	Épidémiologie animale, faune sauvage, conservation
277	Gestion de l’environnement familial et artisanat textile	Formation en gestion familiale et artisanat textile.	La filière prépare aux techniques de gestion de l’environnement familial, de l’artisanat, de la production textile et des activités créatives.	Artisanat et Gestion	3 ans	Gestion familiale, artisanat, techniques textiles
278	Archivistique	Formation en archivistique.	La filière Archivistique forme des spécialistes de la collecte, du classement, de la conservation et de la valorisation des documents et archives. Elle prépare aux techniques modernes de gestion des archives physiques et numériques dans les institutions publiques et privées.	Information et Documentation	3 ans	Gestion des archives, classement documentaire, conservation, archivage numérique
279	Bibliothéconomie	Formation en bibliothéconomie.	La filière Bibliothéconomie prépare aux métiers liés à la gestion des bibliothèques, à l’organisation des collections, aux services aux usagers et à la diffusion de l’information scientifique et culturelle.	Information et Documentation	3 ans	Gestion des bibliothèques, organisation des collections, services documentaires
280	Documentation	Formation en documentation.	La filière Documentation forme des professionnels capables de rechercher, traiter, organiser, diffuser et valoriser l’information documentaire pour répondre aux besoins des organisations et des chercheurs.	Information et Documentation	3 ans	Recherche documentaire, veille informationnelle, gestion de l’information
281	Gestion des PME	Formation en gestion des petites et moyennes entreprises.	La filière Gestion des PME forme des professionnels capables d’accompagner la création, le développement et la gestion des petites et moyennes entreprises. Elle développe des compétences en entrepreneuriat, gestion financière, organisation, stratégie et pilotage des activités des PME.	Gestion et Entrepreneuriat	3 ans	Entrepreneuriat, gestion financière, management des PME, stratégie d’entreprise, création d’entreprise
282	Commande numérique	Formation en commande numérique.	La filière Commande numérique forme des techniciens capables de programmer, utiliser et maintenir des machines-outils à commande numérique utilisées dans les secteurs industriels.	Industrie et Automatisation	1 ans	Programmation CNC, usinage numérique, maintenance industrielle, automatisation
283	Maintenance des équipements biomédicaux	Formation en maintenance des équipements biomédicaux.	La filière Maintenance des équipements biomédicaux prépare des spécialistes capables d’assurer l’installation, le contrôle, la maintenance et la réparation des équipements utilisés dans les établissements de santé.	Génie biomédical	1 ans	Maintenance biomédicale, diagnostic des équipements, électronique médicale
284	Automobile	Formation dans le domaine automobile.	La filière Automobile forme aux techniques de diagnostic, entretien, réparation et maintenance des véhicules et systèmes automobiles modernes.	Transport et Mécanique	3 ans	Mécanique automobile, diagnostic, maintenance des véhicules
285	Domotique	Formation en domotique.	La filière Domotique développe les compétences liées à l’automatisation des bâtiments, aux systèmes intelligents et aux installations connectées.	Technologies et Automatisation	3 ans	Automatisation, systèmes connectés, installations intelligentes
286	Froid et climatisation	Formation en froid et climatisation.	La filière Froid et climatisation forme des techniciens spécialisés dans l’installation, la maintenance et l’exploitation des systèmes frigorifiques et de climatisation.	Énergie et Maintenance	3 ans	Installation frigorifique, climatisation, maintenance énergétique
287	Développement web	Formation en développement web.	La filière Développement web forme des professionnels capables de concevoir, développer et maintenir des sites web et applications web modernes.	Informatique et numérique	3 ans	Programmation web, développement frontend et backend, bases de données, conception d’applications web
288	Entrepreneuriat agricole	Formation en création et gestion d’activités agricoles.	La filière Entrepreneuriat agricole développe les compétences nécessaires à la création, la gestion et le développement de projets dans le secteur agricole.	Agriculture et entrepreneuriat	3 ans	Création d’entreprise agricole, gestion de projets, innovation agricole
289	Art numérique	Formation dans les arts numériques.	La filière Art numérique forme aux techniques de création artistique utilisant les technologies numériques.	Numérique et création	3 ans	Création numérique, design graphique, outils multimédias
290	Gestion administrative	Formation en gestion administrative.	La filière Gestion administrative prépare aux fonctions d’organisation, de gestion des dossiers et d’assistance administrative dans les organisations.	Gestion et administration	3 ans	Organisation administrative, gestion documentaire, communication professionnelle
291	Contact humain	Formation dans les métiers liés à la relation humaine.	La filière Contact humain développe les compétences relationnelles nécessaires aux métiers de l’accueil, de l’accompagnement et des services aux personnes.	Services et relation humaine	3 ans	Communication, accueil, relation client, accompagnement
292	Tourisme et loisirs	Formation dans le tourisme et les activités de loisirs.	La filière Tourisme et loisirs forme aux métiers liés à la gestion touristique, l’organisation des activités de loisirs et l’accueil.	Tourisme et services	3 ans	Gestion touristique, accueil, organisation d’événements
293	Gestion immobilière	Formation en gestion immobilière.	La filière Gestion immobilière prépare aux activités de gestion, administration et valorisation des biens immobiliers.	Immobilier et gestion	3 ans	Gestion immobilière, gestion locative, administration des biens
294	Management du sport	Formation en management sportif.	La filière Management du sport forme des professionnels capables de gérer des structures sportives et des projets liés au sport.	Sport et management	3 ans	Gestion sportive, organisation d’événements, management d’équipes
295	Diagnostic et électronique automobile	Formation en diagnostic et électronique automobile.	La filière Diagnostic et électronique automobile forme des techniciens capables d’utiliser les outils de diagnostic, d’analyser les systèmes électroniques des véhicules modernes et d’intervenir sur les équipements embarqués.	Automobile et systèmes électroniques	3 ans	Diagnostic automobile, électronique embarquée, systèmes électriques des véhicules, utilisation des outils de diagnostic
296	Maintenance et réparation automobile	Formation en maintenance et réparation automobile.	La filière Maintenance et réparation automobile prépare des professionnels capables d’assurer l’entretien, le dépannage et la réparation des véhicules et de leurs différents systèmes mécaniques et électroniques.	Mécanique et maintenance	3 ans	Maintenance automobile, mécanique générale, réparation des véhicules, contrôle technique
297	Internet des objets	Formation en Internet des objets (IoT).	La filière Internet des objets forme aux technologies permettant de connecter des équipements, collecter des données et développer des solutions intelligentes basées sur les objets connectés.	Informatique et technologies numériques	3 ans	Objets connectés, réseaux IoT, programmation embarquée, systèmes intelligents
298	Agriculture	Formation dans le domaine agricole.	La filière Agriculture forme des professionnels capables de maîtriser les techniques de production agricole, la gestion des exploitations et l’accompagnement du développement rural.	Agriculture	3 ans	Techniques agricoles, gestion d’exploitation, production végétale, développement rural
299	Élevage et aquaculture	Formation en élevage et aquaculture.	La filière Élevage et aquaculture prépare des professionnels spécialisés dans la production animale, la gestion des élevages et les techniques de production aquacole.	Agriculture et productions animales	3 ans	Production animale, gestion des élevages, aquaculture, alimentation animale
300	Agroéquipements et eau	Formation en équipements agricoles et gestion de l’eau.	La filière Agroéquipements et eau forme aux technologies utilisées dans l’agriculture moderne, notamment les équipements agricoles, l’irrigation et la gestion des ressources hydriques.	Agriculture et hydraulique	3 ans	Maintenance des équipements agricoles, irrigation, hydraulique agricole
301	Commercialisation agroalimentaire et logistique	Formation en commercialisation agroalimentaire et logistique.	La filière Commercialisation agroalimentaire et logistique développe les compétences liées à la transformation, la distribution, la commercialisation des produits agricoles et la gestion des flux logistiques.	Agroalimentaire et logistique	3 ans	Marketing agroalimentaire, gestion logistique, distribution, chaîne d’approvisionnement
302	Tourisme et services	Formation dans le tourisme et les services.	La filière Tourisme et services prépare aux métiers liés à l’accueil, la gestion des activités touristiques et le développement des services.	Tourisme et services	3 ans	Accueil, gestion touristique, organisation de services
303	Production végétale	Formation en production végétale.	La filière Production végétale forme des techniciens capables de maîtriser les techniques de culture, la gestion des productions agricoles et l’amélioration des rendements.	Agriculture	2 ans	Techniques culturales, gestion des cultures, suivi des productions végétales
304	Gestion d’exploitation agroforestière	Formation en gestion d’exploitation agroforestière.	La filière Gestion d’exploitation agroforestière prépare des professionnels capables de gérer des systèmes combinant agriculture, foresterie et préservation des ressources naturelles.	Agriculture et environnement	2 ans	Gestion des exploitations, agroforesterie, développement durable, gestion des ressources naturelles
305	Gestion d’unité agroalimentaire	Formation en gestion d’unité agroalimentaire.	La filière Gestion d’unité agroalimentaire forme des techniciens capables d’organiser et gérer les activités de transformation et de valorisation des produits agricoles.	Agroalimentaire	2 ans	Transformation agroalimentaire, gestion de production, qualité des produits
306	Métiers de l’eau	Formation dans les métiers liés à l’eau.	La filière Métiers de l’eau prépare aux techniques de gestion, traitement, exploitation et suivi des ressources hydriques.	Eau et environnement	2 ans	Hydraulique, gestion de l’eau, traitement et exploitation des ressources hydriques
307	Énergie renouvelable et production durable	Formation en énergie renouvelable et production durable.	La filière Énergie renouvelable et production durable forme des techniciens capables de développer et gérer des solutions énergétiques respectueuses de l’environnement dans une logique de développement durable.	Énergie et développement durable	2 ans	Énergies renouvelables, gestion énergétique, production durable
308	Mines et énergie	Formation dans les domaines des mines et de l’énergie.	La filière Mines et énergie forme des techniciens capables d’intervenir dans l’exploitation des ressources minières, la gestion énergétique et les technologies liées aux secteurs extractifs.	Mines et énergie	3 ans	Exploitation minière, gestion énergétique, techniques industrielles, sécurité des opérations
309	Agro-alimentaire et eau	Formation en agroalimentaire et gestion de l’eau.	La filière Agro-alimentaire et eau prépare des professionnels capables de participer à la transformation des produits agricoles, au contrôle qualité et à la gestion des ressources hydriques.	Agroalimentaire et environnement	3 ans	Transformation agroalimentaire, contrôle qualité, gestion de l’eau, procédés alimentaires
310	Éco-construction	Formation dans le domaine de la construction durable.	La filière Éco-construction forme des techniciens capables de concevoir et réaliser des bâtiments respectueux de l’environnement en intégrant les principes de performance énergétique et de développement durable.	Bâtiment et construction durable	2 ans	Construction durable, matériaux écologiques, techniques du bâtiment, performance énergétique
311	Efficacité énergétique	Formation dans la maîtrise et l’optimisation énergétique.	La filière Efficacité énergétique prépare des professionnels capables d’analyser, réduire et optimiser la consommation énergétique des bâtiments et installations.	Énergie et environnement	2 ans	Gestion énergétique, diagnostic énergétique, optimisation des consommations
312	Construction métallique	Formation en construction métallique.	La filière Construction métallique forme des techniciens spécialisés dans la fabrication, l’assemblage et la maintenance des structures métalliques utilisées dans le bâtiment et l’industrie.	Génie civil et industrie	2 ans	Structures métalliques, fabrication, assemblage, lecture de plans
313	Développement territorial	Formation en développement territorial.	La filière Développement territorial prépare des professionnels capables d’accompagner les projets de développement local et la gestion des territoires.	Développement et administration territoriale	2 ans	Gestion de projets, développement local, aménagement du territoire
314	Artisanat	Formation dans les métiers de l’artisanat.	La filière Artisanat développe les compétences techniques et entrepreneuriales nécessaires à la création, la production et la gestion d’activités artisanales.	Artisanat et métiers manuels	2 ans	Techniques artisanales, créativité, gestion d’activité, entrepreneuriat
315	Techniques minières et géologie	Formation dans les techniques minières et la géologie.	La filière Techniques minières et géologie forme des techniciens capables d’intervenir dans l’exploration, l’exploitation des ressources minières et l’analyse géologique des terrains.	Mines et géologie	2 ans	Prospection minière, géologie appliquée, exploitation minière, sécurité des opérations
316	Énergie solaire	Formation dans le domaine de l’énergie solaire.	La filière Énergie solaire prépare des techniciens spécialisés dans l’installation, la maintenance et l’exploitation des systèmes photovoltaïques.	Énergie renouvelable	2 ans	Installation photovoltaïque, maintenance énergétique, production solaire
317	Agriculture biologique	Formation en agriculture biologique.	La filière Agriculture biologique forme des professionnels capables de développer des pratiques agricoles respectueuses de l’environnement et de produire selon les principes de l’agriculture durable.	Agriculture durable	2 ans	Production biologique, agroécologie, gestion des cultures durables
318	Écotourisme	Formation dans l’écotourisme.	La filière Écotourisme prépare des professionnels capables de développer et gérer des activités touristiques valorisant les ressources naturelles et culturelles.	Tourisme et environnement	2 ans	Gestion touristique, valorisation du patrimoine, protection environnementale
319	Hôtellerie	Formation dans les métiers de l’hôtellerie.	La filière Hôtellerie forme des professionnels capables de gérer les activités d’accueil, d’hébergement et de restauration.	Tourisme et services	2 ans	Accueil, gestion hôtelière, service client, organisation des prestations
320	Droit du numérique	Formation spécialisée en droit applicable aux technologies numériques, aux données personnelles et au cyberespace.	La filière Droit du numérique forme des juristes capables d'accompagner les entreprises, les administrations et les organisations dans les problématiques juridiques liées aux technologies de l'information, à la protection des données personnelles, au commerce électronique, à la cybersécurité, à la propriété intellectuelle numérique et à la réglementation des plateformes numériques.	Droit	3 ans	Maîtrise du droit du numérique, protection des données personnelles, cybersécurité juridique, propriété intellectuelle, droit des plateformes numériques, conformité réglementaire, rédaction d'actes juridiques.
321	Droit bancaire et financier	Formation spécialisée en droit des établissements financiers, des opérations bancaires et des marchés financiers.	La filière Droit bancaire et financier prépare les étudiants aux métiers juridiques des banques, établissements financiers, compagnies d'assurance, institutions de microfinance et autorités de régulation. Elle couvre le droit bancaire, le droit des marchés financiers, le financement des entreprises, la conformité et la gestion des risques juridiques.	Droit	3 ans	Droit bancaire, droit financier, conformité réglementaire, gestion des risques juridiques, droit des assurances, financement des entreprises, rédaction de contrats bancaires.
322	Gestion de l'indemnisation	Formation spécialisée dans la gestion des sinistres et des procédures d'indemnisation en assurance.	La filière Gestion de l'indemnisation forme des spécialistes capables d'évaluer les sinistres, d'analyser les garanties, de calculer les indemnisations et d'assurer le suivi des dossiers d'assurance dans le respect des procédures et de la réglementation en vigueur.	Assurance	3 ans	Gestion des sinistres, évaluation des dommages, techniques d'indemnisation, droit des assurances, relation client, analyse des garanties, gestion des dossiers d'assurance.
\.


--
-- Data for Name: filiere_critere; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.filiere_critere (id_filiere_critere, id_filiere, id_critere, valeur) FROM stdin;
1	108	1	3.00
2	108	2	3.00
3	108	3	4.00
4	108	4	3.00
5	108	5	3.00
6	108	6	5.00
7	108	7	3.00
8	108	8	2.00
9	108	9	3.00
10	108	10	3.00
11	108	11	3.00
12	108	12	5.00
13	108	13	3.00
14	112	1	3.00
15	112	2	3.00
16	112	3	4.00
17	112	4	3.00
18	112	5	3.00
19	112	6	3.00
20	112	7	3.00
21	112	8	2.00
22	112	9	5.00
23	112	10	3.00
24	112	11	3.00
25	112	12	3.00
26	112	13	3.00
27	98	1	3.00
28	98	2	3.00
29	98	3	4.00
30	98	4	3.00
31	98	5	3.00
32	98	6	3.00
33	98	7	3.00
34	98	8	2.00
35	98	9	5.00
36	98	10	3.00
37	98	11	3.00
38	98	12	3.00
39	98	13	3.00
40	109	1	4.00
41	109	2	3.00
42	109	3	5.00
43	109	4	4.00
44	109	5	5.00
45	109	6	4.00
46	109	7	3.00
47	109	8	4.00
48	109	9	5.00
49	109	10	3.00
50	109	11	3.00
51	109	12	4.00
52	109	13	4.00
53	74	1	3.00
54	74	2	4.50
55	74	3	4.00
56	74	4	3.00
57	74	5	3.00
58	74	6	3.00
59	74	7	3.00
60	74	8	2.00
61	74	9	5.00
62	74	10	3.00
63	74	11	3.00
64	74	12	3.00
65	74	13	5.00
66	270	1	3.00
67	270	2	3.00
68	270	3	4.00
69	270	4	3.00
70	270	5	3.00
71	270	6	3.00
72	270	7	3.00
73	270	8	2.00
74	270	9	3.00
75	270	10	3.00
76	270	11	3.00
77	270	12	3.00
78	270	13	3.00
79	298	1	3.00
80	298	2	5.00
81	298	3	4.00
82	298	4	2.50
83	298	5	3.00
84	298	6	3.00
85	298	7	3.00
86	298	8	2.00
87	298	9	3.00
88	298	10	5.00
89	298	11	3.00
90	298	12	3.00
91	298	13	3.00
92	317	1	3.00
93	317	2	5.00
94	317	3	4.00
95	317	4	2.50
96	317	5	3.00
97	317	6	3.00
98	317	7	3.00
99	317	8	2.00
100	317	9	3.00
101	317	10	5.00
102	317	11	3.00
103	317	12	3.00
104	317	13	3.00
105	309	1	3.00
106	309	2	5.00
107	309	3	4.00
108	309	4	3.00
109	309	5	3.00
110	309	6	3.00
111	309	7	3.00
112	309	8	2.00
113	309	9	3.00
114	309	10	3.00
115	309	11	3.00
116	309	12	3.00
117	309	13	3.00
118	262	1	3.00
119	262	2	3.00
120	262	3	4.00
121	262	4	3.00
122	262	5	3.00
123	262	6	3.00
124	262	7	3.00
125	262	8	2.00
126	262	9	3.00
127	262	10	3.00
128	262	11	3.00
129	262	12	3.00
130	262	13	3.00
131	241	1	3.00
132	241	2	3.00
133	241	3	4.00
134	241	4	3.00
135	241	5	3.00
136	241	6	3.00
137	241	7	3.00
138	241	8	2.00
139	241	9	3.00
140	241	10	3.00
141	241	11	3.00
142	241	12	3.00
143	241	13	3.00
144	300	1	3.00
145	300	2	5.00
146	300	3	4.00
147	300	4	3.00
148	300	5	3.00
149	300	6	3.00
150	300	7	3.00
151	300	8	2.00
152	300	9	3.00
153	300	10	3.00
154	300	11	3.00
155	300	12	3.00
156	300	13	3.00
157	258	1	3.00
158	258	2	3.00
159	258	3	4.00
160	258	4	3.00
161	258	5	3.00
162	258	6	3.00
163	258	7	3.00
164	258	8	2.00
165	258	9	3.00
166	258	10	3.00
167	258	11	3.00
168	258	12	3.00
169	258	13	3.00
170	110	1	3.00
171	110	2	5.00
172	110	3	4.50
173	110	4	3.00
174	110	5	4.00
175	110	6	3.00
176	110	7	3.00
177	110	8	2.00
178	110	9	3.00
179	110	10	3.00
180	110	11	3.00
181	110	12	3.00
182	110	13	3.00
183	147	1	3.00
184	147	2	5.00
185	147	3	4.50
186	147	4	3.00
187	147	5	4.00
188	147	6	3.00
189	147	7	3.00
190	147	8	2.00
191	147	9	3.00
192	147	10	3.00
193	147	11	3.00
194	147	12	3.00
195	147	13	3.00
196	255	1	3.00
197	255	2	5.00
198	255	3	4.00
199	255	4	3.00
200	255	5	3.00
201	255	6	3.00
202	255	7	3.00
203	255	8	2.00
204	255	9	3.00
205	255	10	3.00
206	255	11	3.00
207	255	12	3.00
208	255	13	3.00
209	253	1	3.00
210	253	2	3.00
211	253	3	4.00
212	253	4	3.00
213	253	5	3.00
214	253	6	3.00
215	253	7	3.00
216	253	8	2.00
217	253	9	3.00
218	253	10	3.00
219	253	11	3.00
220	253	12	3.00
221	253	13	3.00
222	257	1	3.00
223	257	2	3.00
224	257	3	4.00
225	257	4	3.00
226	257	5	3.00
227	257	6	3.00
228	257	7	3.00
229	257	8	2.00
230	257	9	3.00
231	257	10	3.00
232	257	11	3.00
233	257	12	3.00
234	257	13	3.00
235	214	1	3.00
236	214	2	3.00
237	214	3	4.00
238	214	4	3.00
239	214	5	3.00
240	214	6	3.00
241	214	7	3.00
242	214	8	2.00
243	214	9	3.00
244	214	10	3.00
245	214	11	3.00
246	214	12	3.00
247	214	13	3.00
248	238	1	3.00
249	238	2	3.00
250	238	3	4.00
251	238	4	3.00
252	238	5	3.00
253	238	6	3.00
254	238	7	3.00
255	238	8	2.00
256	238	9	3.00
257	238	10	3.00
258	238	11	3.00
259	238	12	3.00
260	238	13	3.00
261	187	1	3.00
262	187	2	3.00
263	187	3	4.00
264	187	4	3.00
265	187	5	3.00
266	187	6	3.00
267	187	7	3.00
268	187	8	2.00
269	187	9	3.00
270	187	10	3.00
271	187	11	3.00
272	187	12	3.00
273	187	13	3.00
274	194	1	3.00
275	194	2	3.00
276	194	3	4.00
277	194	4	3.00
278	194	5	3.00
279	194	6	3.00
280	194	7	3.00
281	194	8	2.00
282	194	9	3.00
283	194	10	3.00
284	194	11	3.00
285	194	12	3.00
286	194	13	3.00
287	113	1	3.00
288	113	2	3.00
289	113	3	4.50
290	113	4	3.00
291	113	5	3.00
292	113	6	3.00
293	113	7	4.00
294	113	8	2.00
295	113	9	3.00
296	113	10	4.00
297	113	11	3.00
298	113	12	3.00
299	113	13	3.00
300	278	1	3.00
301	278	2	3.00
302	278	3	4.00
303	278	4	3.00
304	278	5	3.00
305	278	6	3.00
306	278	7	3.00
307	278	8	2.00
308	278	9	3.00
309	278	10	3.00
310	278	11	3.00
311	278	12	3.00
312	278	13	3.00
313	289	1	3.00
314	289	2	3.00
315	289	3	4.00
316	289	4	3.00
317	289	5	3.00
318	289	6	3.00
319	289	7	5.00
320	289	8	2.00
321	289	9	3.00
322	289	10	3.00
323	289	11	3.00
324	289	12	3.00
325	289	13	3.00
326	314	1	3.00
327	314	2	3.00
328	314	3	4.00
329	314	4	3.00
330	314	5	3.00
331	314	6	3.00
332	314	7	3.00
333	314	8	2.00
334	314	9	3.00
335	314	10	3.00
336	314	11	3.00
337	314	12	3.00
338	314	13	3.00
339	201	1	3.00
340	201	2	3.00
341	201	3	4.00
342	201	4	3.00
343	201	5	3.00
344	201	6	3.00
345	201	7	5.00
346	201	8	2.00
347	201	9	3.00
348	201	10	3.00
349	201	11	3.00
350	201	12	3.00
351	201	13	3.00
352	138	1	3.00
353	138	2	3.00
354	138	3	4.00
355	138	4	3.00
356	138	5	3.00
357	138	6	3.00
358	138	7	3.00
359	138	8	2.00
360	138	9	5.00
361	138	10	3.00
362	138	11	3.00
363	138	12	3.00
364	138	13	3.00
365	135	1	3.00
366	135	2	3.00
367	135	3	4.00
368	135	4	3.00
369	135	5	3.00
370	135	6	3.00
371	135	7	5.00
372	135	8	2.00
373	135	9	3.00
374	135	10	3.00
375	135	11	3.00
376	135	12	3.00
377	135	13	3.00
378	97	1	4.00
379	97	2	3.00
380	97	3	5.00
381	97	4	4.00
382	97	5	5.00
383	97	6	5.00
384	97	7	3.00
385	97	8	4.00
386	97	9	5.00
387	97	10	3.00
388	97	11	3.00
389	97	12	4.00
390	97	13	4.00
391	213	1	3.00
392	213	2	3.00
393	213	3	4.00
394	213	4	3.00
395	213	5	3.00
396	213	6	3.00
397	213	7	3.00
398	213	8	2.00
399	213	9	3.00
400	213	10	3.00
401	213	11	3.00
402	213	12	3.00
403	213	13	3.00
404	284	1	3.00
405	284	2	3.00
406	284	3	4.00
407	284	4	3.00
408	284	5	3.00
409	284	6	3.00
410	284	7	3.00
411	284	8	2.00
412	284	9	3.00
413	284	10	3.00
414	284	11	3.00
415	284	12	3.00
416	284	13	3.00
417	77	1	3.00
418	77	2	3.00
419	77	3	5.00
420	77	4	4.00
421	77	5	5.00
422	77	6	5.00
423	77	7	3.00
424	77	8	2.00
425	77	9	5.00
426	77	10	3.00
427	77	11	3.00
428	77	12	5.00
429	77	13	5.00
430	279	1	3.00
431	279	2	3.00
432	279	3	4.00
433	279	4	3.00
434	279	5	3.00
435	279	6	5.00
436	279	7	3.00
437	279	8	2.00
438	279	9	3.00
439	279	10	3.00
440	279	11	3.00
441	279	12	3.00
442	279	13	3.00
443	210	1	5.00
444	210	2	3.00
445	210	3	5.00
446	210	4	4.00
447	210	5	5.00
448	210	6	5.00
449	210	7	3.00
450	210	8	2.00
451	210	9	3.00
452	210	10	3.00
453	210	11	3.00
454	210	12	5.00
455	210	13	4.00
456	272	1	3.00
457	272	2	3.00
458	272	3	4.00
459	272	4	3.00
460	272	5	3.00
461	272	6	5.00
462	272	7	3.00
463	272	8	2.00
464	272	9	3.00
465	272	10	3.00
466	272	11	3.00
467	272	12	5.00
468	272	13	3.00
469	161	1	3.00
470	161	2	5.00
471	161	3	4.00
472	161	4	3.00
473	161	5	3.00
474	161	6	3.00
475	161	7	3.00
476	161	8	2.00
477	161	9	3.00
478	161	10	3.00
479	161	11	3.00
480	161	12	3.00
481	161	13	3.00
482	22	1	3.00
483	22	2	5.00
484	22	3	4.00
485	22	4	3.00
486	22	5	3.00
487	22	6	3.00
488	22	7	3.00
489	22	8	2.00
490	22	9	3.00
491	22	10	3.00
492	22	11	3.00
493	22	12	3.00
494	22	13	3.00
495	185	1	3.00
496	185	2	3.00
497	185	3	4.00
498	185	4	3.00
499	185	5	3.00
500	185	6	5.00
501	185	7	3.00
502	185	8	2.00
503	185	9	3.00
504	185	10	3.00
505	185	11	3.00
506	185	12	5.00
507	185	13	3.00
508	191	1	3.00
509	191	2	3.00
510	191	3	4.00
511	191	4	3.00
512	191	5	3.00
513	191	6	3.00
514	191	7	5.00
515	191	8	2.00
516	191	9	3.00
517	191	10	3.00
518	191	11	3.00
519	191	12	3.00
520	191	13	3.00
521	282	1	3.00
522	282	2	3.00
523	282	3	4.00
524	282	4	3.00
525	282	5	3.00
526	282	6	3.00
527	282	7	3.00
528	282	8	2.00
529	282	9	3.00
530	282	10	3.00
531	282	11	3.00
532	282	12	3.00
533	282	13	3.00
534	229	1	5.00
535	229	2	3.00
536	229	3	5.00
537	229	4	3.00
538	229	5	5.00
539	229	6	3.00
540	229	7	3.00
541	229	8	5.00
542	229	9	5.00
543	229	10	5.00
544	229	11	3.00
545	229	12	5.00
546	229	13	3.00
547	79	1	4.00
548	79	2	3.00
549	79	3	5.00
550	79	4	3.00
551	79	5	5.00
552	79	6	3.00
553	79	7	3.00
554	79	8	5.00
555	79	9	5.00
556	79	10	5.00
557	79	11	3.00
558	79	12	3.00
559	79	13	3.00
560	301	1	3.00
561	301	2	3.00
562	301	3	5.00
563	301	4	3.00
564	301	5	3.00
565	301	6	3.00
566	301	7	3.00
567	301	8	2.00
568	301	9	5.00
569	301	10	5.00
570	301	11	3.00
571	301	12	3.00
572	301	13	4.00
573	121	1	4.00
574	121	2	3.00
575	121	3	4.00
576	121	4	4.00
577	121	5	4.00
578	121	6	3.00
579	121	7	5.00
580	121	8	5.00
581	121	9	3.00
582	121	10	3.00
583	121	11	3.00
584	121	12	3.00
585	121	13	3.00
586	240	1	4.00
587	240	2	3.00
588	240	3	4.00
589	240	4	4.00
590	240	5	4.00
591	240	6	3.00
592	240	7	5.00
593	240	8	5.00
594	240	9	3.00
595	240	10	3.00
596	240	11	3.00
597	240	12	3.00
598	240	13	3.00
599	130	1	4.00
600	130	2	3.00
601	130	3	4.00
602	130	4	4.00
603	130	5	4.00
604	130	6	3.00
605	130	7	5.00
606	130	8	5.00
607	130	9	3.00
608	130	10	3.00
609	130	11	3.00
610	130	12	3.00
611	130	13	3.00
612	105	1	3.00
613	105	2	3.00
614	105	3	4.00
615	105	4	4.00
616	105	5	3.00
617	105	6	5.00
618	105	7	3.00
619	105	8	2.00
620	105	9	5.00
621	105	10	3.00
622	105	11	3.00
623	105	12	4.00
624	105	13	5.00
625	106	1	4.00
626	106	2	3.00
627	106	3	5.00
628	106	4	4.00
629	106	5	5.00
630	106	6	5.00
631	106	7	3.00
632	106	8	4.00
633	106	9	5.00
634	106	10	3.00
635	106	11	3.00
636	106	12	4.00
637	106	13	5.00
638	231	1	3.00
639	231	2	3.00
640	231	3	4.00
641	231	4	3.00
642	231	5	3.00
643	231	6	3.00
644	231	7	3.00
645	231	8	2.00
646	231	9	3.00
647	231	10	3.00
648	231	11	3.00
649	231	12	3.00
650	231	13	3.00
651	312	1	3.00
652	312	2	3.00
653	312	3	4.00
654	312	4	3.00
655	312	5	3.00
656	312	6	3.00
657	312	7	3.00
658	312	8	2.00
659	312	9	3.00
660	312	10	3.00
661	312	11	3.00
662	312	12	3.00
663	312	13	3.00
664	291	1	3.00
665	291	2	3.00
666	291	3	4.00
667	291	4	3.00
668	291	5	3.00
669	291	6	3.00
670	291	7	3.00
671	291	8	2.00
672	291	9	3.00
673	291	10	3.00
674	291	11	3.00
675	291	12	3.00
676	291	13	3.00
677	122	1	3.00
678	122	2	3.00
679	122	3	4.00
680	122	4	3.00
681	122	5	3.00
682	122	6	3.00
683	122	7	3.00
684	122	8	2.00
685	122	9	3.00
686	122	10	5.00
687	122	11	3.00
688	122	12	3.00
689	122	13	3.00
690	225	1	3.00
691	225	2	3.00
692	225	3	4.00
693	225	4	3.00
694	225	5	3.00
695	225	6	3.00
696	225	7	3.00
697	225	8	2.00
698	225	9	3.00
699	225	10	3.00
700	225	11	3.00
701	225	12	3.00
702	225	13	3.00
703	11	1	5.00
704	11	2	3.00
705	11	3	5.00
706	11	4	3.00
707	11	5	5.00
708	11	6	3.00
709	11	7	3.00
710	11	8	2.00
711	11	9	3.00
712	11	10	3.00
713	11	11	3.00
714	11	12	5.00
715	11	13	3.00
716	266	1	3.00
717	266	2	3.00
718	266	3	4.00
719	266	4	3.00
720	266	5	3.00
721	266	6	3.00
722	266	7	3.00
723	266	8	2.00
724	266	9	3.00
725	266	10	3.00
726	266	11	3.00
727	266	12	3.00
728	266	13	3.00
729	265	1	3.00
730	265	2	3.00
731	265	3	4.00
732	265	4	3.00
733	265	5	5.00
734	265	6	5.00
735	265	7	4.00
736	265	8	2.00
737	265	9	4.00
738	265	10	4.00
739	265	11	3.00
740	265	12	5.00
741	265	13	4.00
742	12	1	5.00
743	12	2	3.00
744	12	3	5.00
745	12	4	4.00
746	12	5	5.00
747	12	6	5.00
748	12	7	3.00
749	12	8	2.00
750	12	9	3.00
751	12	10	3.00
752	12	11	3.00
753	12	12	5.00
754	12	13	4.00
755	233	1	3.00
756	233	2	4.50
757	233	3	5.00
758	233	4	4.00
759	233	5	3.00
760	233	6	3.00
761	233	7	3.00
762	233	8	2.00
763	233	9	3.00
764	233	10	3.00
765	233	11	3.00
766	233	12	3.00
767	233	13	3.00
768	313	1	3.00
769	313	2	4.50
770	313	3	4.00
771	313	4	4.00
772	313	5	3.00
773	313	6	3.00
774	313	7	3.00
775	313	8	2.00
776	313	9	3.00
777	313	10	3.00
778	313	11	3.00
779	313	12	3.00
780	313	13	3.00
781	287	1	3.00
782	287	2	4.50
783	287	3	4.00
784	287	4	4.00
785	287	5	3.00
786	287	6	3.00
787	287	7	3.00
788	287	8	2.00
789	287	9	3.00
790	287	10	3.00
791	287	11	3.00
792	287	12	3.00
793	287	13	3.00
794	295	1	3.00
795	295	2	3.00
796	295	3	4.00
797	295	4	3.00
798	295	5	3.00
799	295	6	3.00
800	295	7	3.00
801	295	8	2.00
802	295	9	3.00
803	295	10	3.00
804	295	11	3.00
805	295	12	3.00
806	295	13	3.00
807	271	1	3.00
808	271	2	3.00
809	271	3	4.00
810	271	4	3.00
811	271	5	3.00
812	271	6	3.00
813	271	7	3.00
814	271	8	2.00
815	271	9	3.00
816	271	10	3.00
817	271	11	3.00
818	271	12	3.00
819	271	13	3.00
820	280	1	3.00
821	280	2	3.00
822	280	3	4.00
823	280	4	3.00
824	280	5	3.00
825	280	6	3.00
826	280	7	3.00
827	280	8	2.00
828	280	9	3.00
829	280	10	3.00
830	280	11	3.00
831	280	12	3.00
832	280	13	3.00
833	285	1	3.00
834	285	2	3.00
835	285	3	4.00
836	285	4	3.00
837	285	5	3.00
838	285	6	3.00
839	285	7	3.00
840	285	8	2.00
841	285	9	3.00
842	285	10	3.00
843	285	11	3.00
844	285	12	3.00
845	285	13	3.00
846	4	1	4.00
847	4	2	3.00
848	4	3	4.50
849	4	4	3.00
850	4	5	4.00
851	4	6	4.00
852	4	7	3.00
853	4	8	4.00
854	4	9	4.00
855	4	10	3.00
856	4	11	3.00
857	4	12	4.00
858	4	13	5.00
859	321	1	4.00
860	321	2	3.00
861	321	3	4.50
862	321	4	3.00
863	321	5	4.00
864	321	6	4.00
865	321	7	3.00
866	321	8	4.00
867	321	9	4.00
868	321	10	3.00
869	321	11	3.00
870	321	12	4.00
871	321	13	5.00
872	249	1	4.00
873	249	2	5.00
874	249	3	4.50
875	249	4	3.00
876	249	5	4.00
877	249	6	4.00
878	249	7	3.00
879	249	8	4.00
880	249	9	4.00
881	249	10	3.00
882	249	11	3.00
883	249	12	4.00
884	249	13	5.00
885	73	1	4.00
886	73	2	3.00
887	73	3	4.50
888	73	4	3.00
889	73	5	4.00
890	73	6	4.00
891	73	7	3.00
892	73	8	4.00
893	73	9	4.00
894	73	10	3.00
895	73	11	3.00
896	73	12	4.00
897	73	13	5.00
898	159	1	4.00
899	159	2	3.00
900	159	3	4.50
901	159	4	3.00
902	159	5	4.00
903	159	6	4.00
904	159	7	3.00
905	159	8	4.00
906	159	9	4.00
907	159	10	3.00
908	159	11	3.00
909	159	12	4.00
910	159	13	5.00
911	320	1	4.00
912	320	2	3.00
913	320	3	4.50
914	320	4	3.00
915	320	5	4.00
916	320	6	4.00
917	320	7	3.00
918	320	8	4.00
919	320	9	4.00
920	320	10	3.00
921	320	11	3.00
922	320	12	4.00
923	320	13	5.00
924	150	1	4.00
925	150	2	3.00
926	150	3	4.50
927	150	4	3.00
928	150	5	4.00
929	150	6	4.00
930	150	7	3.00
931	150	8	4.00
932	150	9	4.00
933	150	10	3.00
934	150	11	3.00
935	150	12	4.00
936	150	13	5.00
937	129	1	4.00
938	129	2	3.00
939	129	3	4.50
940	129	4	3.00
941	129	5	4.00
942	129	6	4.00
943	129	7	3.00
944	129	8	4.00
945	129	9	4.00
946	129	10	3.00
947	129	11	3.00
948	129	12	4.00
949	129	13	5.00
950	128	1	4.00
951	128	2	3.00
952	128	3	4.50
953	128	4	3.00
954	128	5	4.00
955	128	6	4.00
956	128	7	3.00
957	128	8	4.00
958	128	9	4.00
959	128	10	3.00
960	128	11	3.00
961	128	12	4.00
962	128	13	5.00
963	176	1	3.00
964	176	2	5.00
965	176	3	4.00
966	176	4	3.00
967	176	5	3.00
968	176	6	3.00
969	176	7	3.00
970	176	8	2.00
971	176	9	3.00
972	176	10	3.00
973	176	11	3.00
974	176	12	3.00
975	176	13	3.00
976	232	1	3.00
977	232	2	5.00
978	232	3	4.00
979	232	4	3.00
980	232	5	3.00
981	232	6	3.00
982	232	7	3.00
983	232	8	2.00
984	232	9	3.00
985	232	10	3.00
986	232	11	3.00
987	232	12	3.00
988	232	13	3.00
989	310	1	3.00
990	310	2	3.00
991	310	3	4.00
992	310	4	3.00
993	310	5	3.00
994	310	6	3.00
995	310	7	3.00
996	310	8	2.00
997	310	9	3.00
998	310	10	3.00
999	310	11	3.00
1000	310	12	3.00
1001	310	13	3.00
1002	99	1	4.00
1003	99	2	3.00
1004	99	3	5.00
1005	99	4	4.00
1006	99	5	5.00
1007	99	6	5.00
1008	99	7	3.00
1009	99	8	4.00
1010	99	9	5.00
1011	99	10	3.00
1012	99	11	3.00
1013	99	12	4.00
1014	99	13	4.00
1015	220	1	3.00
1016	220	2	3.00
1017	220	3	4.00
1018	220	4	3.00
1019	220	5	3.00
1020	220	6	5.00
1021	220	7	3.00
1022	220	8	2.00
1023	220	9	3.00
1024	220	10	3.00
1025	220	11	3.00
1026	220	12	3.00
1027	220	13	3.00
1028	318	1	3.00
1029	318	2	3.00
1030	318	3	4.00
1031	318	4	3.00
1032	318	5	3.00
1033	318	6	3.00
1034	318	7	3.00
1035	318	8	5.00
1036	318	9	3.00
1037	318	10	5.00
1038	318	11	3.00
1039	318	12	3.00
1040	318	13	3.00
1041	311	1	3.00
1042	311	2	3.00
1043	311	3	4.00
1044	311	4	3.00
1045	311	5	3.00
1046	311	6	3.00
1047	311	7	3.00
1048	311	8	2.00
1049	311	9	3.00
1050	311	10	3.00
1051	311	11	3.00
1052	311	12	3.00
1053	311	13	3.00
1054	83	1	3.00
1055	83	2	3.00
1056	83	3	5.00
1057	83	4	3.00
1058	83	5	5.00
1059	83	6	4.00
1060	83	7	3.00
1061	83	8	2.00
1062	83	9	3.00
1063	83	10	3.00
1064	83	11	3.00
1065	83	12	3.00
1066	83	13	3.00
1067	8	1	3.00
1068	8	2	3.00
1069	8	3	4.00
1070	8	4	3.00
1071	8	5	3.00
1072	8	6	3.00
1073	8	7	3.00
1074	8	8	2.00
1075	8	9	3.00
1076	8	10	3.00
1077	8	11	3.00
1078	8	12	3.00
1079	8	13	3.00
1080	81	1	3.00
1081	81	2	3.00
1082	81	3	4.00
1083	81	4	3.00
1084	81	5	3.00
1085	81	6	3.00
1086	81	7	3.00
1087	81	8	2.00
1088	81	9	3.00
1089	81	10	3.00
1090	81	11	3.00
1091	81	12	3.00
1092	81	13	3.00
1093	193	1	3.00
1094	193	2	5.00
1095	193	3	4.00
1096	193	4	2.50
1097	193	5	3.00
1098	193	6	3.00
1099	193	7	3.00
1100	193	8	2.00
1101	193	9	3.00
1102	193	10	5.00
1103	193	11	3.00
1104	193	12	3.00
1105	193	13	3.00
1106	299	1	3.00
1107	299	2	5.00
1108	299	3	4.00
1109	299	4	2.50
1110	299	5	3.00
1111	299	6	3.00
1112	299	7	3.00
1113	299	8	2.00
1114	299	9	3.00
1115	299	10	5.00
1116	299	11	3.00
1117	299	12	3.00
1118	299	13	3.00
1119	86	1	3.00
1120	86	2	3.00
1121	86	3	5.00
1122	86	4	3.00
1123	86	5	3.00
1124	86	6	3.00
1125	86	7	3.00
1126	86	8	2.00
1127	86	9	3.00
1128	86	10	3.00
1129	86	11	3.00
1130	86	12	3.00
1131	86	13	3.00
1132	307	1	3.00
1133	307	2	3.00
1134	307	3	5.00
1135	307	4	3.00
1136	307	5	3.00
1137	307	6	3.00
1138	307	7	3.00
1139	307	8	2.00
1140	307	9	3.00
1141	307	10	3.00
1142	307	11	3.00
1143	307	12	3.00
1144	307	13	3.00
1145	316	1	3.00
1146	316	2	3.00
1147	316	3	5.00
1148	316	4	3.00
1149	316	5	3.00
1150	316	6	3.00
1151	316	7	3.00
1152	316	8	2.00
1153	316	9	3.00
1154	316	10	3.00
1155	316	11	3.00
1156	316	12	3.00
1157	316	13	3.00
1158	251	1	3.00
1159	251	2	5.00
1160	251	3	5.00
1161	251	4	2.50
1162	251	5	3.00
1163	251	6	3.00
1164	251	7	3.00
1165	251	8	2.00
1166	251	9	3.00
1167	251	10	5.00
1168	251	11	3.00
1169	251	12	3.00
1170	251	13	3.00
1171	195	1	3.00
1172	195	2	5.00
1173	195	3	4.00
1174	195	4	3.00
1175	195	5	3.00
1176	195	6	3.00
1177	195	7	3.00
1178	195	8	5.00
1179	195	9	3.00
1180	195	10	3.00
1181	195	11	3.00
1182	195	12	3.00
1183	195	13	5.00
1184	156	1	3.00
1185	156	2	3.00
1186	156	3	4.00
1187	156	4	3.00
1188	156	5	5.00
1189	156	6	3.00
1190	156	7	5.00
1191	156	8	4.00
1192	156	9	3.00
1193	156	10	5.00
1194	156	11	3.00
1195	156	12	3.00
1196	156	13	3.00
1197	288	1	3.00
1198	288	2	3.00
1199	288	3	4.00
1200	288	4	3.00
1201	288	5	5.00
1202	288	6	3.00
1203	288	7	5.00
1204	288	8	4.00
1205	288	9	3.00
1206	288	10	5.00
1207	288	11	3.00
1208	288	12	3.00
1209	288	13	3.00
1210	223	1	3.00
1211	223	2	4.50
1212	223	3	4.00
1213	223	4	4.00
1214	223	5	5.00
1215	223	6	3.00
1216	223	7	5.00
1217	223	8	4.00
1218	223	9	3.00
1219	223	10	5.00
1220	223	11	3.00
1221	223	12	3.00
1222	223	13	3.00
1223	209	1	3.00
1224	209	2	5.00
1225	209	3	4.00
1226	209	4	3.00
1227	209	5	3.00
1228	209	6	3.00
1229	209	7	3.00
1230	209	8	2.00
1231	209	9	3.00
1232	209	10	3.00
1233	209	11	3.00
1234	209	12	3.00
1235	209	13	3.00
1236	149	1	3.00
1237	149	2	3.00
1238	149	3	4.00
1239	149	4	3.00
1240	149	5	3.00
1241	149	6	3.00
1242	149	7	3.00
1243	149	8	2.00
1244	149	9	3.00
1245	149	10	3.00
1246	149	11	3.00
1247	149	12	3.00
1248	149	13	3.00
1249	222	1	3.00
1250	222	2	3.00
1251	222	3	5.00
1252	222	4	4.00
1253	222	5	5.00
1254	222	6	5.00
1255	222	7	3.00
1256	222	8	2.00
1257	222	9	5.00
1258	222	10	3.00
1259	222	11	3.00
1260	222	12	5.00
1261	222	13	5.00
1262	245	1	3.00
1263	245	2	3.00
1264	245	3	5.00
1265	245	4	4.00
1266	245	5	5.00
1267	245	6	5.00
1268	245	7	3.00
1269	245	8	2.00
1270	245	9	5.00
1271	245	10	3.00
1272	245	11	3.00
1273	245	12	5.00
1274	245	13	5.00
1275	117	1	3.00
1276	117	2	3.00
1277	117	3	4.00
1278	117	4	3.00
1279	117	5	3.00
1280	117	6	3.00
1281	117	7	3.00
1282	117	8	2.00
1283	117	9	3.00
1284	117	10	3.00
1285	117	11	3.00
1286	117	12	3.00
1287	117	13	3.00
1288	196	1	3.00
1289	196	2	5.00
1290	196	3	4.00
1291	196	4	3.00
1292	196	5	3.00
1293	196	6	3.00
1294	196	7	3.00
1295	196	8	5.00
1296	196	9	3.00
1297	196	10	3.00
1298	196	11	3.00
1299	196	12	3.00
1300	196	13	3.00
1301	286	1	3.00
1302	286	2	3.00
1303	286	3	4.00
1304	286	4	3.00
1305	286	5	3.00
1306	286	6	3.00
1307	286	7	3.00
1308	286	8	2.00
1309	286	9	3.00
1310	286	10	3.00
1311	286	11	3.00
1312	286	12	3.00
1313	286	13	3.00
1314	269	1	3.00
1315	269	2	3.00
1316	269	3	4.00
1317	269	4	3.00
1318	269	5	5.00
1319	269	6	5.00
1320	269	7	4.00
1321	269	8	2.00
1322	269	9	4.00
1323	269	10	4.00
1324	269	11	3.00
1325	269	12	5.00
1326	269	13	4.00
1327	89	1	3.00
1328	89	2	3.00
1329	89	3	4.00
1330	89	4	3.00
1331	89	5	5.00
1332	89	6	5.00
1333	89	7	4.00
1334	89	8	2.00
1335	89	9	4.00
1336	89	10	4.00
1337	89	11	3.00
1338	89	12	5.00
1339	89	13	4.00
1340	33	1	3.00
1341	33	2	3.00
1342	33	3	4.00
1343	33	4	3.00
1344	33	5	5.00
1345	33	6	5.00
1346	33	7	4.00
1347	33	8	2.00
1348	33	9	4.00
1349	33	10	4.00
1350	33	11	3.00
1351	33	12	5.00
1352	33	13	4.00
1353	2	1	3.00
1354	2	2	3.00
1355	2	3	4.50
1356	2	4	2.50
1357	2	5	5.00
1358	2	6	5.00
1359	2	7	4.00
1360	2	8	2.00
1361	2	9	4.00
1362	2	10	4.00
1363	2	11	3.00
1364	2	12	5.00
1365	2	13	4.00
1366	212	1	3.00
1367	212	2	3.00
1368	212	3	4.00
1369	212	4	3.00
1370	212	5	5.00
1371	212	6	5.00
1372	212	7	4.00
1373	212	8	2.00
1374	212	9	4.00
1375	212	10	4.00
1376	212	11	3.00
1377	212	12	5.00
1378	212	13	4.00
1379	91	1	3.00
1380	91	2	3.00
1381	91	3	4.00
1382	91	4	3.00
1383	91	5	5.00
1384	91	6	5.00
1385	91	7	4.00
1386	91	8	2.00
1387	91	9	4.00
1388	91	10	4.00
1389	91	11	3.00
1390	91	12	5.00
1391	91	13	4.00
1392	90	1	3.00
1393	90	2	3.00
1394	90	3	4.00
1395	90	4	3.00
1396	90	5	5.00
1397	90	6	5.00
1398	90	7	4.00
1399	90	8	2.00
1400	90	9	4.00
1401	90	10	4.00
1402	90	11	3.00
1403	90	12	5.00
1404	90	13	4.00
1405	202	1	3.00
1406	202	2	3.00
1407	202	3	4.00
1408	202	4	3.00
1409	202	5	5.00
1410	202	6	5.00
1411	202	7	4.00
1412	202	8	2.00
1413	202	9	4.00
1414	202	10	4.00
1415	202	11	3.00
1416	202	12	5.00
1417	202	13	4.00
1418	268	1	3.00
1419	268	2	3.00
1420	268	3	5.00
1421	268	4	3.00
1422	268	5	5.00
1423	268	6	5.00
1424	268	7	4.00
1425	268	8	2.00
1426	268	9	4.00
1427	268	10	4.00
1428	268	11	3.00
1429	268	12	5.00
1430	268	13	4.00
1431	158	1	5.00
1432	158	2	3.00
1433	158	3	5.00
1434	158	4	4.00
1435	158	5	5.00
1436	158	6	5.00
1437	158	7	4.00
1438	158	8	2.00
1439	158	9	4.00
1440	158	10	4.00
1441	158	11	3.00
1442	158	12	5.00
1443	158	13	4.00
1444	9	1	5.00
1445	9	2	3.00
1446	9	3	5.00
1447	9	4	3.00
1448	9	5	5.00
1449	9	6	5.00
1450	9	7	4.00
1451	9	8	2.00
1452	9	9	4.00
1453	9	10	4.00
1454	9	11	3.00
1455	9	12	5.00
1456	9	13	4.00
1457	69	1	3.00
1458	69	2	3.00
1459	69	3	5.00
1460	69	4	3.00
1461	69	5	5.00
1462	69	6	5.00
1463	69	7	4.00
1464	69	8	2.00
1465	69	9	5.00
1466	69	10	5.00
1467	69	11	3.00
1468	69	12	5.00
1469	69	13	4.00
1470	211	1	3.00
1471	211	2	3.00
1472	211	3	4.00
1473	211	4	3.00
1474	211	5	5.00
1475	211	6	5.00
1476	211	7	4.00
1477	211	8	2.00
1478	211	9	4.00
1479	211	10	4.00
1480	211	11	3.00
1481	211	12	5.00
1482	211	13	4.00
1483	206	1	3.00
1484	206	2	3.00
1485	206	3	4.00
1486	206	4	3.00
1487	206	5	3.00
1488	206	6	3.00
1489	206	7	3.00
1490	206	8	2.00
1491	206	9	3.00
1492	206	10	3.00
1493	206	11	3.00
1494	206	12	3.00
1495	206	13	3.00
1496	181	1	3.00
1497	181	2	3.00
1498	181	3	4.00
1499	181	4	3.00
1500	181	5	3.00
1501	181	6	3.00
1502	181	7	3.00
1503	181	8	2.00
1504	181	9	3.00
1505	181	10	3.00
1506	181	11	3.00
1507	181	12	3.00
1508	181	13	3.00
1509	205	1	3.00
1510	205	2	3.00
1511	205	3	4.00
1512	205	4	3.00
1513	205	5	3.00
1514	205	6	3.00
1515	205	7	3.00
1516	205	8	2.00
1517	205	9	3.00
1518	205	10	3.00
1519	205	11	3.00
1520	205	12	3.00
1521	205	13	3.00
1522	82	1	3.00
1523	82	2	3.00
1524	82	3	4.00
1525	82	4	3.00
1526	82	5	3.00
1527	82	6	3.00
1528	82	7	3.00
1529	82	8	2.00
1530	82	9	3.00
1531	82	10	3.00
1532	82	11	3.00
1533	82	12	3.00
1534	82	13	3.00
1535	84	1	3.00
1536	84	2	3.00
1537	84	3	4.00
1538	84	4	3.00
1539	84	5	3.00
1540	84	6	3.00
1541	84	7	3.00
1542	84	8	2.00
1543	84	9	3.00
1544	84	10	3.00
1545	84	11	3.00
1546	84	12	3.00
1547	84	13	3.00
1548	5	1	4.00
1549	5	2	3.00
1550	5	3	5.00
1551	5	4	4.00
1552	5	5	5.00
1553	5	6	4.00
1554	5	7	3.00
1555	5	8	4.00
1556	5	9	5.00
1557	5	10	3.00
1558	5	11	3.00
1559	5	12	4.00
1560	5	13	4.00
1561	290	1	4.00
1562	290	2	3.00
1563	290	3	5.00
1564	290	4	4.00
1565	290	5	5.00
1566	290	6	4.00
1567	290	7	3.00
1568	290	8	4.00
1569	290	9	5.00
1570	290	10	3.00
1571	290	11	3.00
1572	290	12	4.00
1573	290	13	4.00
1574	67	1	4.00
1575	67	2	3.00
1576	67	3	5.00
1577	67	4	4.00
1578	67	5	5.00
1579	67	6	4.00
1580	67	7	3.00
1581	67	8	4.00
1582	67	9	5.00
1583	67	10	3.00
1584	67	11	3.00
1585	67	12	4.00
1586	67	13	4.00
1587	264	1	4.00
1588	264	2	3.00
1589	264	3	5.00
1590	264	4	4.00
1591	264	5	5.00
1592	264	6	4.00
1593	264	7	3.00
1594	264	8	4.00
1595	264	9	5.00
1596	264	10	3.00
1597	264	11	3.00
1598	264	12	4.00
1599	264	13	4.00
1600	304	1	4.00
1601	304	2	3.00
1602	304	3	5.00
1603	304	4	4.00
1604	304	5	5.00
1605	304	6	4.00
1606	304	7	3.00
1607	304	8	4.00
1608	304	9	5.00
1609	304	10	3.00
1610	304	11	3.00
1611	304	12	4.00
1612	304	13	4.00
1613	305	1	4.00
1614	305	2	3.00
1615	305	3	5.00
1616	305	4	4.00
1617	305	5	5.00
1618	305	6	4.00
1619	305	7	3.00
1620	305	8	4.00
1621	305	9	5.00
1622	305	10	3.00
1623	305	11	3.00
1624	305	12	4.00
1625	305	13	4.00
1626	322	1	4.00
1627	322	2	3.00
1628	322	3	5.00
1629	322	4	4.00
1630	322	5	5.00
1631	322	6	4.00
1632	322	7	3.00
1633	322	8	4.00
1634	322	9	5.00
1635	322	10	3.00
1636	322	11	3.00
1637	322	12	4.00
1638	322	13	4.00
1639	277	1	4.00
1640	277	2	5.00
1641	277	3	5.00
1642	277	4	4.00
1643	277	5	5.00
1644	277	6	4.00
1645	277	7	3.00
1646	277	8	4.00
1647	277	9	5.00
1648	277	10	3.00
1649	277	11	3.00
1650	277	12	4.00
1651	277	13	4.00
1652	259	1	4.00
1653	259	2	3.00
1654	259	3	5.00
1655	259	4	4.00
1656	259	5	5.00
1657	259	6	4.00
1658	259	7	3.00
1659	259	8	4.00
1660	259	9	5.00
1661	259	10	3.00
1662	259	11	3.00
1663	259	12	4.00
1664	259	13	4.00
1665	244	1	4.00
1666	244	2	3.00
1667	244	3	5.00
1668	244	4	4.00
1669	244	5	5.00
1670	244	6	4.00
1671	244	7	3.00
1672	244	8	4.00
1673	244	9	5.00
1674	244	10	3.00
1675	244	11	3.00
1676	244	12	4.00
1677	244	13	4.00
1678	102	1	4.00
1679	102	2	4.50
1680	102	3	5.00
1681	102	4	4.00
1682	102	5	5.00
1683	102	6	4.00
1684	102	7	3.00
1685	102	8	4.00
1686	102	9	5.00
1687	102	10	5.00
1688	102	11	3.00
1689	102	12	4.00
1690	102	13	4.00
1691	281	1	4.00
1692	281	2	3.00
1693	281	3	5.00
1694	281	4	4.00
1695	281	5	5.00
1696	281	6	4.00
1697	281	7	3.00
1698	281	8	4.00
1699	281	9	5.00
1700	281	10	3.00
1701	281	11	3.00
1702	281	12	4.00
1703	281	13	4.00
1704	68	1	4.00
1705	68	2	3.00
1706	68	3	5.00
1707	68	4	4.00
1708	68	5	5.00
1709	68	6	4.00
1710	68	7	3.00
1711	68	8	5.00
1712	68	9	5.00
1713	68	10	3.00
1714	68	11	3.00
1715	68	12	4.00
1716	68	13	4.00
1717	217	1	4.00
1718	217	2	3.00
1719	217	3	5.00
1720	217	4	4.00
1721	217	5	5.00
1722	217	6	4.00
1723	217	7	3.00
1724	217	8	4.00
1725	217	9	5.00
1726	217	10	3.00
1727	217	11	3.00
1728	217	12	4.00
1729	217	13	4.00
1730	275	1	4.00
1731	275	2	3.00
1732	275	3	5.00
1733	275	4	4.00
1734	275	5	5.00
1735	275	6	4.00
1736	275	7	3.00
1737	275	8	4.00
1738	275	9	5.00
1739	275	10	3.00
1740	275	11	3.00
1741	275	12	4.00
1742	275	13	4.00
1743	95	1	4.00
1744	95	2	3.00
1745	95	3	5.00
1746	95	4	4.00
1747	95	5	5.00
1748	95	6	4.00
1749	95	7	3.00
1750	95	8	5.00
1751	95	9	5.00
1752	95	10	5.00
1753	95	11	3.00
1754	95	12	4.00
1755	95	13	4.00
1756	293	1	4.00
1757	293	2	3.00
1758	293	3	5.00
1759	293	4	4.00
1760	293	5	5.00
1761	293	6	4.00
1762	293	7	3.00
1763	293	8	4.00
1764	293	9	5.00
1765	293	10	3.00
1766	293	11	3.00
1767	293	12	4.00
1768	293	13	4.00
1769	103	1	3.00
1770	103	2	4.50
1771	103	3	4.00
1772	103	4	4.00
1773	103	5	3.00
1774	103	6	3.00
1775	103	7	3.00
1776	103	8	2.00
1777	103	9	3.00
1778	103	10	3.00
1779	103	11	3.00
1780	103	12	3.00
1781	103	13	3.00
1782	104	1	3.00
1783	104	2	4.50
1784	104	3	4.00
1785	104	4	4.00
1786	104	5	3.00
1787	104	6	3.00
1788	104	7	3.00
1789	104	8	2.00
1790	104	9	3.00
1791	104	10	3.00
1792	104	11	3.00
1793	104	12	3.00
1794	104	13	3.00
1795	134	1	3.00
1796	134	2	3.00
1797	134	3	4.00
1798	134	4	4.00
1799	134	5	3.00
1800	134	6	3.00
1801	134	7	5.00
1802	134	8	2.00
1803	134	9	3.00
1804	134	10	3.00
1805	134	11	3.00
1806	134	12	3.00
1807	134	13	3.00
1808	182	1	3.00
1809	182	2	3.00
1810	182	3	4.00
1811	182	4	3.00
1812	182	5	3.00
1813	182	6	3.00
1814	182	7	3.00
1815	182	8	2.00
1816	182	9	3.00
1817	182	10	3.00
1818	182	11	3.00
1819	182	12	3.00
1820	182	13	3.00
1821	319	1	3.00
1822	319	2	3.00
1823	319	3	4.00
1824	319	4	3.00
1825	319	5	3.00
1826	319	6	3.00
1827	319	7	3.00
1828	319	8	5.00
1829	319	9	3.00
1830	319	10	5.00
1831	319	11	3.00
1832	319	12	3.00
1833	319	13	3.00
1834	256	1	3.00
1835	256	2	3.00
1836	256	3	4.00
1837	256	4	3.00
1838	256	5	3.00
1839	256	6	3.00
1840	256	7	3.00
1841	256	8	2.00
1842	256	9	3.00
1843	256	10	3.00
1844	256	11	3.00
1845	256	12	3.00
1846	256	13	3.00
1847	85	1	3.00
1848	85	2	3.00
1849	85	3	4.00
1850	85	4	3.00
1851	85	5	3.00
1852	85	6	3.00
1853	85	7	3.00
1854	85	8	2.00
1855	85	9	3.00
1856	85	10	3.00
1857	85	11	3.00
1858	85	12	3.00
1859	85	13	3.00
1860	207	1	3.00
1861	207	2	3.00
1862	207	3	4.00
1863	207	4	3.00
1864	207	5	3.00
1865	207	6	3.00
1866	207	7	3.00
1867	207	8	2.00
1868	207	9	3.00
1869	207	10	3.00
1870	207	11	3.00
1871	207	12	3.00
1872	207	13	3.00
1873	252	1	4.00
1874	252	2	5.00
1875	252	3	5.00
1876	252	4	4.00
1877	252	5	5.00
1878	252	6	4.00
1879	252	7	3.00
1880	252	8	4.00
1881	252	9	5.00
1882	252	10	3.00
1883	252	11	3.00
1884	252	12	4.00
1885	252	13	4.00
1886	208	1	5.00
1887	208	2	3.00
1888	208	3	4.00
1889	208	4	3.00
1890	208	5	3.00
1891	208	6	5.00
1892	208	7	3.00
1893	208	8	2.00
1894	208	9	3.00
1895	208	10	3.00
1896	208	11	3.00
1897	208	12	5.00
1898	208	13	3.00
1899	24	1	3.00
1900	24	2	3.00
1901	24	3	4.00
1902	24	4	3.00
1903	24	5	3.00
1904	24	6	3.00
1905	24	7	3.00
1906	24	8	2.00
1907	24	9	3.00
1908	24	10	3.00
1909	24	11	3.00
1910	24	12	3.00
1911	24	13	3.00
1912	115	1	3.00
1913	115	2	3.00
1914	115	3	4.00
1915	115	4	4.00
1916	115	5	3.00
1917	115	6	3.00
1918	115	7	5.00
1919	115	8	2.00
1920	115	9	3.00
1921	115	10	3.00
1922	115	11	3.00
1923	115	12	3.00
1924	115	13	3.00
1925	1	1	5.00
1926	1	2	3.00
1927	1	3	5.00
1928	1	4	4.00
1929	1	5	5.00
1930	1	6	5.00
1931	1	7	4.00
1932	1	8	2.00
1933	1	9	4.00
1934	1	10	4.00
1935	1	11	3.00
1936	1	12	5.00
1937	1	13	4.00
1938	15	1	5.00
1939	15	2	3.00
1940	15	3	5.00
1941	15	4	4.00
1942	15	5	5.00
1943	15	6	5.00
1944	15	7	4.00
1945	15	8	4.00
1946	15	9	5.00
1947	15	10	4.00
1948	15	11	3.00
1949	15	12	5.00
1950	15	13	4.00
1951	88	1	5.00
1952	88	2	3.00
1953	88	3	5.00
1954	88	4	4.00
1955	88	5	5.00
1956	88	6	5.00
1957	88	7	4.00
1958	88	8	2.00
1959	88	9	4.00
1960	88	10	4.00
1961	88	11	3.00
1962	88	12	5.00
1963	88	13	4.00
1964	118	1	3.00
1965	118	2	3.00
1966	118	3	4.00
1967	118	4	3.00
1968	118	5	5.00
1969	118	6	5.00
1970	118	7	4.00
1971	118	8	2.00
1972	118	9	4.00
1973	118	10	4.00
1974	118	11	3.00
1975	118	12	5.00
1976	118	13	4.00
1977	160	1	4.00
1978	160	2	3.00
1979	160	3	5.00
1980	160	4	4.00
1981	160	5	5.00
1982	160	6	5.00
1983	160	7	4.00
1984	160	8	4.00
1985	160	9	5.00
1986	160	10	4.00
1987	160	11	3.00
1988	160	12	5.00
1989	160	13	4.00
1990	13	1	5.00
1991	13	2	3.00
1992	13	3	5.00
1993	13	4	3.00
1994	13	5	5.00
1995	13	6	3.00
1996	13	7	3.00
1997	13	8	2.00
1998	13	9	3.00
1999	13	10	3.00
2000	13	11	3.00
2001	13	12	5.00
2002	13	13	3.00
2003	297	1	3.00
2004	297	2	3.00
2005	297	3	5.00
2006	297	4	4.00
2007	297	5	3.00
2008	297	6	3.00
2009	297	7	3.00
2010	297	8	2.00
2011	297	9	3.00
2012	297	10	3.00
2013	297	11	3.00
2014	297	12	3.00
2015	297	13	3.00
2016	143	1	3.00
2017	143	2	3.00
2018	143	3	5.00
2019	143	4	4.00
2020	143	5	3.00
2021	143	6	3.00
2022	143	7	3.00
2023	143	8	2.00
2024	143	9	3.00
2025	143	10	3.00
2026	143	11	3.00
2027	143	12	3.00
2028	143	13	3.00
2029	96	1	3.00
2030	96	2	3.00
2031	96	3	4.00
2032	96	4	3.00
2033	96	5	3.00
2034	96	6	3.00
2035	96	7	3.00
2036	96	8	5.00
2037	96	9	3.00
2038	96	10	3.00
2039	96	11	3.00
2040	96	12	3.00
2041	96	13	3.00
2042	111	1	3.00
2043	111	2	3.00
2044	111	3	4.00
2045	111	4	3.00
2046	111	5	3.00
2047	111	6	3.00
2048	111	7	5.00
2049	111	8	5.00
2050	111	9	3.00
2051	111	10	3.00
2052	111	11	3.00
2053	111	12	3.00
2054	111	13	3.00
2055	157	1	4.00
2056	157	2	3.00
2057	157	3	4.00
2058	157	4	4.00
2059	157	5	4.00
2060	157	6	3.00
2061	157	7	5.00
2062	157	8	5.00
2063	157	9	3.00
2064	157	10	3.00
2065	157	11	3.00
2066	157	12	3.00
2067	157	13	3.00
2068	26	1	3.00
2069	26	2	5.00
2070	26	3	4.00
2071	26	4	3.00
2072	26	5	3.00
2073	26	6	3.00
2074	26	7	3.00
2075	26	8	2.00
2076	26	9	3.00
2077	26	10	3.00
2078	26	11	3.00
2079	26	12	3.00
2080	26	13	3.00
2081	94	1	3.00
2082	94	2	3.00
2083	94	3	4.00
2084	94	4	3.00
2085	94	5	3.00
2086	94	6	3.00
2087	94	7	3.00
2088	94	8	2.00
2089	94	9	3.00
2090	94	10	3.00
2091	94	11	3.00
2092	94	12	3.00
2093	94	13	3.00
2094	180	1	3.00
2095	180	2	3.00
2096	180	3	4.00
2097	180	4	3.00
2098	180	5	3.00
2099	180	6	3.00
2100	180	7	3.00
2101	180	8	5.00
2102	180	9	3.00
2103	180	10	3.00
2104	180	11	3.00
2105	180	12	3.00
2106	180	13	3.00
2107	224	1	3.00
2108	224	2	3.00
2109	224	3	4.00
2110	224	4	3.00
2111	224	5	3.00
2112	224	6	3.00
2113	224	7	3.00
2114	224	8	5.00
2115	224	9	3.00
2116	224	10	3.00
2117	224	11	3.00
2118	224	12	3.00
2119	224	13	3.00
2120	154	1	3.00
2121	154	2	3.00
2122	154	3	4.00
2123	154	4	3.00
2124	154	5	3.00
2125	154	6	3.00
2126	154	7	3.00
2127	154	8	5.00
2128	154	9	3.00
2129	154	10	3.00
2130	154	11	3.00
2131	154	12	3.00
2132	154	13	3.00
2133	188	1	3.00
2134	188	2	3.00
2135	188	3	4.00
2136	188	4	3.00
2137	188	5	3.00
2138	188	6	3.00
2139	188	7	3.00
2140	188	8	2.00
2141	188	9	3.00
2142	188	10	3.00
2143	188	11	3.00
2144	188	12	3.00
2145	188	13	3.00
2146	189	1	3.00
2147	189	2	3.00
2148	189	3	4.00
2149	189	4	3.00
2150	189	5	3.00
2151	189	6	3.00
2152	189	7	3.00
2153	189	8	2.00
2154	189	9	3.00
2155	189	10	3.00
2156	189	11	3.00
2157	189	12	3.00
2158	189	13	3.00
2159	166	1	3.00
2160	166	2	3.00
2161	166	3	5.00
2162	166	4	3.00
2163	166	5	3.00
2164	166	6	3.00
2165	166	7	3.00
2166	166	8	2.00
2167	166	9	5.00
2168	166	10	5.00
2169	166	11	3.00
2170	166	12	3.00
2171	166	13	4.00
2172	144	1	4.00
2173	144	2	3.00
2174	144	3	4.00
2175	144	4	3.00
2176	144	5	5.00
2177	144	6	4.00
2178	144	7	3.00
2179	144	8	5.00
2180	144	9	5.00
2181	144	10	5.00
2182	144	11	3.00
2183	144	12	4.00
2184	144	13	4.00
2185	250	1	3.00
2186	250	2	3.00
2187	250	3	4.00
2188	250	4	3.00
2189	250	5	3.00
2190	250	6	3.00
2191	250	7	3.00
2192	250	8	2.00
2193	250	9	3.00
2194	250	10	3.00
2195	250	11	3.00
2196	250	12	3.00
2197	250	13	3.00
2198	283	1	3.00
2199	283	2	3.00
2200	283	3	4.00
2201	283	4	3.00
2202	283	5	3.00
2203	283	6	3.00
2204	283	7	3.00
2205	283	8	2.00
2206	283	9	3.00
2207	283	10	4.00
2208	283	11	3.00
2209	283	12	3.00
2210	283	13	3.00
2211	296	1	3.00
2212	296	2	3.00
2213	296	3	4.00
2214	296	4	3.00
2215	296	5	3.00
2216	296	6	3.00
2217	296	7	3.00
2218	296	8	2.00
2219	296	9	3.00
2220	296	10	4.00
2221	296	11	3.00
2222	296	12	3.00
2223	296	13	3.00
2224	133	1	3.00
2225	133	2	3.00
2226	133	3	4.00
2227	133	4	2.50
2228	133	5	3.00
2229	133	6	3.00
2230	133	7	3.00
2231	133	8	2.00
2232	133	9	3.00
2233	133	10	4.00
2234	133	11	3.00
2235	133	12	3.00
2236	133	13	3.00
2237	116	1	5.00
2238	116	2	3.00
2239	116	3	5.00
2240	116	4	4.00
2241	116	5	5.00
2242	116	6	5.00
2243	116	7	4.00
2244	116	8	2.00
2245	116	9	4.00
2246	116	10	4.00
2247	116	11	3.00
2248	116	12	5.00
2249	116	13	4.00
2250	64	1	4.00
2251	64	2	3.00
2252	64	3	4.00
2253	64	4	3.00
2254	64	5	5.00
2255	64	6	4.00
2256	64	7	3.00
2257	64	8	5.00
2258	64	9	5.00
2259	64	10	5.00
2260	64	11	3.00
2261	64	12	4.00
2262	64	13	4.00
2263	127	1	4.00
2264	127	2	3.00
2265	127	3	4.00
2266	127	4	3.00
2267	127	5	5.00
2268	127	6	4.00
2269	127	7	3.00
2270	127	8	5.00
2271	127	9	5.00
2272	127	10	5.00
2273	127	11	3.00
2274	127	12	4.00
2275	127	13	4.00
2276	87	1	4.00
2277	87	2	5.00
2278	87	3	4.00
2279	87	4	4.00
2280	87	5	5.00
2281	87	6	4.00
2282	87	7	3.00
2283	87	8	5.00
2284	87	9	5.00
2285	87	10	5.00
2286	87	11	3.00
2287	87	12	4.00
2288	87	13	4.00
2289	132	1	4.00
2290	132	2	3.00
2291	132	3	4.00
2292	132	4	3.00
2293	132	5	5.00
2294	132	6	4.00
2295	132	7	3.00
2296	132	8	5.00
2297	132	9	5.00
2298	132	10	5.00
2299	132	11	3.00
2300	132	12	4.00
2301	132	13	4.00
2302	75	1	4.00
2303	75	2	3.00
2304	75	3	4.00
2305	75	4	3.00
2306	75	5	5.00
2307	75	6	4.00
2308	75	7	3.00
2309	75	8	5.00
2310	75	9	5.00
2311	75	10	5.00
2312	75	11	3.00
2313	75	12	4.00
2314	75	13	4.00
2315	70	1	4.00
2316	70	2	3.00
2317	70	3	4.00
2318	70	4	3.00
2319	70	5	5.00
2320	70	6	4.00
2321	70	7	3.00
2322	70	8	5.00
2323	70	9	5.00
2324	70	10	5.00
2325	70	11	3.00
2326	70	12	4.00
2327	70	13	4.00
2328	92	1	4.00
2329	92	2	3.00
2330	92	3	4.00
2331	92	4	3.00
2332	92	5	5.00
2333	92	6	4.00
2334	92	7	3.00
2335	92	8	5.00
2336	92	9	5.00
2337	92	10	5.00
2338	92	11	3.00
2339	92	12	4.00
2340	92	13	4.00
2341	246	1	4.00
2342	246	2	3.00
2343	246	3	4.00
2344	246	4	3.00
2345	246	5	5.00
2346	246	6	4.00
2347	246	7	3.00
2348	246	8	5.00
2349	246	9	5.00
2350	246	10	5.00
2351	246	11	3.00
2352	246	12	4.00
2353	246	13	4.00
2354	119	1	4.00
2355	119	2	3.00
2356	119	3	4.00
2357	119	4	3.00
2358	119	5	5.00
2359	119	6	4.00
2360	119	7	3.00
2361	119	8	5.00
2362	119	9	5.00
2363	119	10	5.00
2364	119	11	3.00
2365	119	12	4.00
2366	119	13	4.00
2367	80	1	4.00
2368	80	2	3.00
2369	80	3	4.00
2370	80	4	3.00
2371	80	5	5.00
2372	80	6	4.00
2373	80	7	3.00
2374	80	8	5.00
2375	80	9	5.00
2376	80	10	5.00
2377	80	11	3.00
2378	80	12	4.00
2379	80	13	4.00
2380	136	1	4.00
2381	136	2	5.00
2382	136	3	5.00
2383	136	4	3.00
2384	136	5	5.00
2385	136	6	4.00
2386	136	7	3.00
2387	136	8	5.00
2388	136	9	5.00
2389	136	10	5.00
2390	136	11	3.00
2391	136	12	4.00
2392	136	13	4.00
2393	294	1	4.00
2394	294	2	3.00
2395	294	3	4.00
2396	294	4	3.00
2397	294	5	5.00
2398	294	6	4.00
2399	294	7	3.00
2400	294	8	5.00
2401	294	9	5.00
2402	294	10	5.00
2403	294	11	3.00
2404	294	12	4.00
2405	294	13	4.00
2406	228	1	4.00
2407	228	2	5.00
2408	228	3	4.00
2409	228	4	3.00
2410	228	5	5.00
2411	228	6	4.00
2412	228	7	3.00
2413	228	8	5.00
2414	228	9	5.00
2415	228	10	5.00
2416	228	11	3.00
2417	228	12	4.00
2418	228	13	4.00
2419	140	1	4.00
2420	140	2	3.00
2421	140	3	5.00
2422	140	4	3.00
2423	140	5	5.00
2424	140	6	4.00
2425	140	7	3.00
2426	140	8	5.00
2427	140	9	5.00
2428	140	10	5.00
2429	140	11	3.00
2430	140	12	4.00
2431	140	13	4.00
2432	7	1	4.00
2433	7	2	3.00
2434	7	3	5.00
2435	7	4	3.00
2436	7	5	5.00
2437	7	6	3.00
2438	7	7	5.00
2439	7	8	5.00
2440	7	9	4.00
2441	7	10	5.00
2442	7	11	3.00
2443	7	12	4.00
2444	7	13	3.00
2445	263	1	4.00
2446	263	2	3.00
2447	263	3	5.00
2448	263	4	3.00
2449	263	5	5.00
2450	263	6	3.00
2451	263	7	5.00
2452	263	8	5.00
2453	263	9	4.00
2454	263	10	5.00
2455	263	11	3.00
2456	263	12	4.00
2457	263	13	3.00
2458	139	1	4.00
2459	139	2	3.00
2460	139	3	5.00
2461	139	4	4.00
2462	139	5	5.00
2463	139	6	3.00
2464	139	7	5.00
2465	139	8	5.00
2466	139	9	4.00
2467	139	10	5.00
2468	139	11	3.00
2469	139	12	4.00
2470	139	13	3.00
2471	71	1	4.00
2472	71	2	3.00
2473	71	3	5.00
2474	71	4	4.00
2475	71	5	5.00
2476	71	6	3.00
2477	71	7	5.00
2478	71	8	5.00
2479	71	9	4.00
2480	71	10	5.00
2481	71	11	3.00
2482	71	12	4.00
2483	71	13	3.00
2484	164	1	4.00
2485	164	2	3.00
2486	164	3	5.00
2487	164	4	4.00
2488	164	5	5.00
2489	164	6	5.00
2490	164	7	5.00
2491	164	8	5.00
2492	164	9	5.00
2493	164	10	5.00
2494	164	11	3.00
2495	164	12	5.00
2496	164	13	5.00
2497	163	1	4.00
2498	163	2	3.00
2499	163	3	5.00
2500	163	4	3.00
2501	163	5	5.00
2502	163	6	4.00
2503	163	7	5.00
2504	163	8	5.00
2505	163	9	5.00
2506	163	10	5.00
2507	163	11	3.00
2508	163	12	4.00
2509	163	13	4.00
2510	178	1	4.00
2511	178	2	3.00
2512	178	3	5.00
2513	178	4	3.00
2514	178	5	5.00
2515	178	6	3.00
2516	178	7	5.00
2517	178	8	5.00
2518	178	9	4.00
2519	178	10	5.00
2520	178	11	3.00
2521	178	12	4.00
2522	178	13	3.00
2523	76	1	3.00
2524	76	2	3.00
2525	76	3	4.00
2526	76	4	3.00
2527	76	5	3.00
2528	76	6	3.00
2529	76	7	3.00
2530	76	8	2.00
2531	76	9	5.00
2532	76	10	3.00
2533	76	11	3.00
2534	76	12	3.00
2535	76	13	3.00
2536	153	1	5.00
2537	153	2	3.00
2538	153	3	4.00
2539	153	4	3.00
2540	153	5	3.00
2541	153	6	5.00
2542	153	7	3.00
2543	153	8	2.00
2544	153	9	3.00
2545	153	10	3.00
2546	153	11	3.00
2547	153	12	5.00
2548	153	13	3.00
2549	114	1	5.00
2550	114	2	3.00
2551	114	3	4.00
2552	114	4	3.00
2553	114	5	3.00
2554	114	6	5.00
2555	114	7	3.00
2556	114	8	2.00
2557	114	9	3.00
2558	114	10	3.00
2559	114	11	3.00
2560	114	12	5.00
2561	114	13	3.00
2562	235	1	5.00
2563	235	2	3.00
2564	235	3	5.00
2565	235	4	4.00
2566	235	5	5.00
2567	235	6	5.00
2568	235	7	4.00
2569	235	8	2.00
2570	235	9	4.00
2571	235	10	4.00
2572	235	11	3.00
2573	235	12	5.00
2574	235	13	4.00
2575	29	1	5.00
2576	29	2	3.00
2577	29	3	5.00
2578	29	4	4.00
2579	29	5	5.00
2580	29	6	5.00
2581	29	7	4.00
2582	29	8	2.00
2583	29	9	4.00
2584	29	10	4.00
2585	29	11	3.00
2586	29	12	5.00
2587	29	13	4.00
2588	218	1	3.00
2589	218	2	3.00
2590	218	3	4.00
2591	218	4	3.00
2592	218	5	3.00
2593	218	6	3.00
2594	218	7	3.00
2595	218	8	2.00
2596	218	9	3.00
2597	218	10	3.00
2598	218	11	3.00
2599	218	12	3.00
2600	218	13	3.00
2601	3	1	3.00
2602	3	2	5.00
2603	3	3	4.50
2604	3	4	2.50
2605	3	5	3.00
2606	3	6	3.00
2607	3	7	3.00
2608	3	8	2.00
2609	3	9	3.00
2610	3	10	3.00
2611	3	11	3.00
2612	3	12	3.00
2613	3	13	5.00
2614	31	1	3.00
2615	31	2	5.00
2616	31	3	4.50
2617	31	4	2.50
2618	31	5	3.00
2619	31	6	3.00
2620	31	7	3.00
2621	31	8	2.00
2622	31	9	3.00
2623	31	10	3.00
2624	31	11	3.00
2625	31	12	3.00
2626	31	13	5.00
2627	100	1	5.00
2628	100	2	3.00
2629	100	3	5.00
2630	100	4	4.00
2631	100	5	5.00
2632	100	6	5.00
2633	100	7	4.00
2634	100	8	4.00
2635	100	9	5.00
2636	100	10	4.00
2637	100	11	3.00
2638	100	12	5.00
2639	100	13	4.00
2640	306	1	3.00
2641	306	2	5.00
2642	306	3	4.00
2643	306	4	3.00
2644	306	5	3.00
2645	306	6	3.00
2646	306	7	3.00
2647	306	8	2.00
2648	306	9	3.00
2649	306	10	3.00
2650	306	11	3.00
2651	306	12	3.00
2652	306	13	3.00
2653	190	1	3.00
2654	190	2	3.00
2655	190	3	4.00
2656	190	4	3.00
2657	190	5	3.00
2658	190	6	3.00
2659	190	7	5.00
2660	190	8	2.00
2661	190	9	3.00
2662	190	10	3.00
2663	190	11	3.00
2664	190	12	3.00
2665	190	13	3.00
2666	131	1	3.00
2667	131	2	3.00
2668	131	3	5.00
2669	131	4	4.00
2670	131	5	5.00
2671	131	6	5.00
2672	131	7	3.00
2673	131	8	2.00
2674	131	9	5.00
2675	131	10	3.00
2676	131	11	3.00
2677	131	12	5.00
2678	131	13	5.00
2679	308	1	3.00
2680	308	2	3.00
2681	308	3	5.00
2682	308	4	3.00
2683	308	5	3.00
2684	308	6	3.00
2685	308	7	3.00
2686	308	8	2.00
2687	308	9	3.00
2688	308	10	3.00
2689	308	11	3.00
2690	308	12	3.00
2691	308	13	3.00
2692	216	1	5.00
2693	216	2	3.00
2694	216	3	5.00
2695	216	4	4.00
2696	216	5	5.00
2697	216	6	5.00
2698	216	7	4.00
2699	216	8	2.00
2700	216	9	4.00
2701	216	10	4.00
2702	216	11	3.00
2703	216	12	5.00
2704	216	13	4.00
2705	236	1	4.00
2706	236	2	3.00
2707	236	3	5.00
2708	236	4	4.00
2709	236	5	4.00
2710	236	6	3.00
2711	236	7	5.00
2712	236	8	5.00
2713	236	9	3.00
2714	236	10	3.00
2715	236	11	3.00
2716	236	12	3.00
2717	236	13	3.00
2718	198	1	3.00
2719	198	2	3.00
2720	198	3	4.00
2721	198	4	3.00
2722	198	5	3.00
2723	198	6	3.00
2724	198	7	5.00
2725	198	8	2.00
2726	198	9	3.00
2727	198	10	3.00
2728	198	11	3.00
2729	198	12	3.00
2730	198	13	3.00
2731	25	1	3.00
2732	25	2	5.00
2733	25	3	4.00
2734	25	4	3.00
2735	25	5	3.00
2736	25	6	3.00
2737	25	7	3.00
2738	25	8	2.00
2739	25	9	3.00
2740	25	10	3.00
2741	25	11	3.00
2742	25	12	3.00
2743	25	13	3.00
2744	19	1	3.00
2745	19	2	3.00
2746	19	3	4.00
2747	19	4	3.00
2748	19	5	3.00
2749	19	6	3.00
2750	19	7	3.00
2751	19	8	2.00
2752	19	9	3.00
2753	19	10	3.00
2754	19	11	3.00
2755	19	12	3.00
2756	19	13	3.00
2757	204	1	3.00
2758	204	2	3.00
2759	204	3	4.00
2760	204	4	3.00
2761	204	5	3.00
2762	204	6	3.00
2763	204	7	3.00
2764	204	8	2.00
2765	204	9	3.00
2766	204	10	3.00
2767	204	11	3.00
2768	204	12	3.00
2769	204	13	3.00
2770	203	1	3.00
2771	203	2	3.00
2772	203	3	4.00
2773	203	4	3.00
2774	203	5	3.00
2775	203	6	3.00
2776	203	7	3.00
2777	203	8	2.00
2778	203	9	3.00
2779	203	10	3.00
2780	203	11	3.00
2781	203	12	3.00
2782	203	13	3.00
2783	120	1	3.00
2784	120	2	3.00
2785	120	3	4.00
2786	120	4	3.00
2787	120	5	3.00
2788	120	6	3.00
2789	120	7	3.00
2790	120	8	2.00
2791	120	9	3.00
2792	120	10	3.00
2793	120	11	3.00
2794	120	12	3.00
2795	120	13	3.00
2796	18	1	3.00
2797	18	2	5.00
2798	18	3	4.50
2799	18	4	3.00
2800	18	5	3.00
2801	18	6	3.00
2802	18	7	3.00
2803	18	8	2.00
2804	18	9	3.00
2805	18	10	3.00
2806	18	11	3.00
2807	18	12	3.00
2808	18	13	5.00
2809	273	1	3.00
2810	273	2	5.00
2811	273	3	4.50
2812	273	4	3.00
2813	273	5	3.00
2814	273	6	3.00
2815	273	7	3.00
2816	273	8	2.00
2817	273	9	3.00
2818	273	10	3.00
2819	273	11	3.00
2820	273	12	3.00
2821	273	13	5.00
2822	183	1	3.00
2823	183	2	3.00
2824	183	3	4.00
2825	183	4	3.00
2826	183	5	3.00
2827	183	6	3.00
2828	183	7	3.00
2829	183	8	2.00
2830	183	9	3.00
2831	183	10	3.00
2832	183	11	3.00
2833	183	12	3.00
2834	183	13	3.00
2835	184	1	3.00
2836	184	2	3.00
2837	184	3	4.00
2838	184	4	3.00
2839	184	5	3.00
2840	184	6	5.00
2841	184	7	3.00
2842	184	8	2.00
2843	184	9	3.00
2844	184	10	3.00
2845	184	11	3.00
2846	184	12	5.00
2847	184	13	3.00
2848	200	1	3.00
2849	200	2	3.00
2850	200	3	4.00
2851	200	4	3.00
2852	200	5	3.00
2853	200	6	5.00
2854	200	7	3.00
2855	200	8	2.00
2856	200	9	3.00
2857	200	10	3.00
2858	200	11	3.00
2859	200	12	5.00
2860	200	13	3.00
2861	152	1	3.00
2862	152	2	3.00
2863	152	3	4.00
2864	152	4	3.00
2865	152	5	3.00
2866	152	6	5.00
2867	152	7	3.00
2868	152	8	2.00
2869	152	9	3.00
2870	152	10	3.00
2871	152	11	3.00
2872	152	12	5.00
2873	152	13	3.00
2874	260	1	3.00
2875	260	2	3.00
2876	260	3	4.00
2877	260	4	3.00
2878	260	5	3.00
2879	260	6	3.00
2880	260	7	3.00
2881	260	8	2.00
2882	260	9	3.00
2883	260	10	3.00
2884	260	11	3.00
2885	260	12	3.00
2886	260	13	3.00
2887	221	1	3.00
2888	221	2	4.50
2889	221	3	4.00
2890	221	4	4.00
2891	221	5	3.00
2892	221	6	3.00
2893	221	7	3.00
2894	221	8	2.00
2895	221	9	3.00
2896	221	10	3.00
2897	221	11	3.00
2898	221	12	3.00
2899	221	13	3.00
2900	199	1	3.00
2901	199	2	3.00
2902	199	3	4.00
2903	199	4	3.00
2904	199	5	3.00
2905	199	6	3.00
2906	199	7	3.00
2907	199	8	2.00
2908	199	9	3.00
2909	199	10	3.00
2910	199	11	3.00
2911	199	12	3.00
2912	199	13	3.00
2913	248	1	4.00
2914	248	2	3.00
2915	248	3	4.00
2916	248	4	3.00
2917	248	5	5.00
2918	248	6	4.00
2919	248	7	3.00
2920	248	8	5.00
2921	248	9	5.00
2922	248	10	5.00
2923	248	11	3.00
2924	248	12	4.00
2925	248	13	4.00
2926	303	1	3.00
2927	303	2	3.00
2928	303	3	4.00
2929	303	4	3.00
2930	303	5	3.00
2931	303	6	3.00
2932	303	7	3.00
2933	303	8	2.00
2934	303	9	3.00
2935	303	10	3.00
2936	303	11	3.00
2937	303	12	3.00
2938	303	13	3.00
2939	172	1	3.00
2940	172	2	5.00
2941	172	3	4.00
2942	172	4	3.00
2943	172	5	3.00
2944	172	6	3.00
2945	172	7	3.00
2946	172	8	5.00
2947	172	9	3.00
2948	172	10	3.00
2949	172	11	3.00
2950	172	12	3.00
2951	172	13	5.00
2952	175	1	3.00
2953	175	2	5.00
2954	175	3	4.00
2955	175	4	3.00
2956	175	5	3.00
2957	175	6	5.00
2958	175	7	3.00
2959	175	8	5.00
2960	175	9	3.00
2961	175	10	3.00
2962	175	11	3.00
2963	175	12	5.00
2964	175	13	5.00
2965	173	1	3.00
2966	173	2	5.00
2967	173	3	4.00
2968	173	4	3.00
2969	173	5	3.00
2970	173	6	3.00
2971	173	7	3.00
2972	173	8	5.00
2973	173	9	3.00
2974	173	10	3.00
2975	173	11	3.00
2976	173	12	3.00
2977	173	13	5.00
2978	170	1	3.00
2979	170	2	5.00
2980	170	3	4.00
2981	170	4	3.00
2982	170	5	3.00
2983	170	6	3.00
2984	170	7	3.00
2985	170	8	5.00
2986	170	9	3.00
2987	170	10	3.00
2988	170	11	3.00
2989	170	12	3.00
2990	170	13	5.00
2991	171	1	3.00
2992	171	2	5.00
2993	171	3	4.00
2994	171	4	3.00
2995	171	5	3.00
2996	171	6	3.00
2997	171	7	3.00
2998	171	8	5.00
2999	171	9	3.00
3000	171	10	3.00
3001	171	11	3.00
3002	171	12	3.00
3003	171	13	5.00
3004	167	1	5.00
3005	167	2	5.00
3006	167	3	4.00
3007	167	4	3.00
3008	167	5	3.00
3009	167	6	5.00
3010	167	7	3.00
3011	167	8	5.00
3012	167	9	3.00
3013	167	10	3.00
3014	167	11	3.00
3015	167	12	5.00
3016	167	13	5.00
3017	174	1	3.00
3018	174	2	5.00
3019	174	3	4.00
3020	174	4	3.00
3021	174	5	3.00
3022	174	6	3.00
3023	174	7	3.00
3024	174	8	5.00
3025	174	9	3.00
3026	174	10	3.00
3027	174	11	3.00
3028	174	12	3.00
3029	174	13	5.00
3030	168	1	3.00
3031	168	2	5.00
3032	168	3	4.00
3033	168	4	3.00
3034	168	5	3.00
3035	168	6	5.00
3036	168	7	3.00
3037	168	8	5.00
3038	168	9	3.00
3039	168	10	3.00
3040	168	11	3.00
3041	168	12	5.00
3042	168	13	5.00
3043	169	1	5.00
3044	169	2	5.00
3045	169	3	4.00
3046	169	4	3.00
3047	169	5	3.00
3048	169	6	5.00
3049	169	7	3.00
3050	169	8	5.00
3051	169	9	3.00
3052	169	10	3.00
3053	169	11	3.00
3054	169	12	5.00
3055	169	13	5.00
3056	254	1	3.00
3057	254	2	3.00
3058	254	3	4.00
3059	254	4	3.00
3060	254	5	3.00
3061	254	6	3.00
3062	254	7	3.00
3063	254	8	2.00
3064	254	9	3.00
3065	254	10	3.00
3066	254	11	3.00
3067	254	12	3.00
3068	254	13	3.00
3069	32	1	3.00
3070	32	2	3.00
3071	32	3	4.00
3072	32	4	3.00
3073	32	5	3.00
3074	32	6	3.00
3075	32	7	3.00
3076	32	8	5.00
3077	32	9	3.00
3078	32	10	3.00
3079	32	11	3.00
3080	32	12	3.00
3081	32	13	3.00
3082	274	1	3.00
3083	274	2	3.00
3084	274	3	4.00
3085	274	4	3.00
3086	274	5	3.00
3087	274	6	3.00
3088	274	7	3.00
3089	274	8	2.00
3090	274	9	3.00
3091	274	10	3.00
3092	274	11	3.00
3093	274	12	3.00
3094	274	13	3.00
3095	72	1	3.00
3096	72	2	5.00
3097	72	3	4.00
3098	72	4	3.00
3099	72	5	3.00
3100	72	6	3.00
3101	72	7	3.00
3102	72	8	2.00
3103	72	9	3.00
3104	72	10	3.00
3105	72	11	3.00
3106	72	12	3.00
3107	72	13	3.00
3108	137	1	3.00
3109	137	2	5.00
3110	137	3	5.00
3111	137	4	3.00
3112	137	5	5.00
3113	137	6	4.00
3114	137	7	3.00
3115	137	8	2.00
3116	137	9	3.00
3117	137	10	3.00
3118	137	11	3.00
3119	137	12	3.00
3120	137	13	3.00
3121	10	1	4.00
3122	10	2	5.00
3123	10	3	5.00
3124	10	4	4.00
3125	10	5	5.00
3126	10	6	3.00
3127	10	7	5.00
3128	10	8	5.00
3129	10	9	3.00
3130	10	10	3.00
3131	10	11	3.00
3132	10	12	3.00
3133	10	13	3.00
3134	107	1	5.00
3135	107	2	5.00
3136	107	3	5.00
3137	107	4	4.00
3138	107	5	5.00
3139	107	6	5.00
3140	107	7	4.00
3141	107	8	2.00
3142	107	9	4.00
3143	107	10	4.00
3144	107	11	3.00
3145	107	12	5.00
3146	107	13	4.00
3147	247	1	3.00
3148	247	2	3.00
3149	247	3	4.00
3150	247	4	3.00
3151	247	5	3.00
3152	247	6	3.00
3153	247	7	3.00
3154	247	8	5.00
3155	247	9	3.00
3156	247	10	5.00
3157	247	11	3.00
3158	247	12	3.00
3159	247	13	3.00
3160	237	1	3.00
3161	237	2	3.00
3162	237	3	5.00
3163	237	4	3.00
3164	237	5	3.00
3165	237	6	3.00
3166	237	7	4.00
3167	237	8	2.00
3168	237	9	3.00
3169	237	10	3.00
3170	237	11	3.00
3171	237	12	3.00
3172	237	13	3.00
3173	21	1	3.00
3174	21	2	5.00
3175	21	3	4.00
3176	21	4	2.50
3177	21	5	3.00
3178	21	6	3.00
3179	21	7	3.00
3180	21	8	2.00
3181	21	9	3.00
3182	21	10	3.00
3183	21	11	3.00
3184	21	12	3.00
3185	21	13	5.00
3186	227	1	3.00
3187	227	2	5.00
3188	227	3	4.00
3189	227	4	3.00
3190	227	5	4.00
3191	227	6	3.00
3192	227	7	3.00
3193	227	8	2.00
3194	227	9	3.00
3195	227	10	3.00
3196	227	11	3.00
3197	227	12	3.00
3198	227	13	3.00
3199	23	1	3.00
3200	23	2	5.00
3201	23	3	4.00
3202	23	4	3.00
3203	23	5	4.00
3204	23	6	3.00
3205	23	7	3.00
3206	23	8	2.00
3207	23	9	3.00
3208	23	10	3.00
3209	23	11	3.00
3210	23	12	3.00
3211	23	13	3.00
3212	230	1	3.00
3213	230	2	5.00
3214	230	3	4.00
3215	230	4	3.00
3216	230	5	4.00
3217	230	6	3.00
3218	230	7	3.00
3219	230	8	2.00
3220	230	9	3.00
3221	230	10	3.00
3222	230	11	3.00
3223	230	12	3.00
3224	230	13	3.00
3225	146	1	5.00
3226	146	2	3.00
3227	146	3	4.00
3228	146	4	3.00
3229	146	5	3.00
3230	146	6	5.00
3231	146	7	3.00
3232	146	8	2.00
3233	146	9	3.00
3234	146	10	3.00
3235	146	11	3.00
3236	146	12	5.00
3237	146	13	3.00
3238	151	1	5.00
3239	151	2	3.00
3240	151	3	5.00
3241	151	4	4.00
3242	151	5	5.00
3243	151	6	5.00
3244	151	7	3.00
3245	151	8	4.00
3246	151	9	5.00
3247	151	10	3.00
3248	151	11	3.00
3249	151	12	5.00
3250	151	13	4.00
3251	239	1	5.00
3252	239	2	3.00
3253	239	3	4.00
3254	239	4	3.00
3255	239	5	3.00
3256	239	6	5.00
3257	239	7	3.00
3258	239	8	2.00
3259	239	9	3.00
3260	239	10	3.00
3261	239	11	3.00
3262	239	12	5.00
3263	239	13	3.00
3264	148	1	5.00
3265	148	2	5.00
3266	148	3	4.00
3267	148	4	4.00
3268	148	5	4.00
3269	148	6	5.00
3270	148	7	5.00
3271	148	8	5.00
3272	148	9	3.00
3273	148	10	3.00
3274	148	11	3.00
3275	148	12	5.00
3276	148	13	3.00
3277	186	1	5.00
3278	186	2	3.00
3279	186	3	4.00
3280	186	4	3.00
3281	186	5	3.00
3282	186	6	5.00
3283	186	7	3.00
3284	186	8	2.00
3285	186	9	3.00
3286	186	10	3.00
3287	186	11	3.00
3288	186	12	5.00
3289	186	13	3.00
3290	179	1	5.00
3291	179	2	3.00
3292	179	3	4.00
3293	179	4	3.00
3294	179	5	3.00
3295	179	6	5.00
3296	179	7	3.00
3297	179	8	2.00
3298	179	9	3.00
3299	179	10	3.00
3300	179	11	3.00
3301	179	12	5.00
3302	179	13	3.00
3303	142	1	5.00
3304	142	2	3.00
3305	142	3	4.00
3306	142	4	3.00
3307	142	5	3.00
3308	142	6	5.00
3309	142	7	3.00
3310	142	8	2.00
3311	142	9	3.00
3312	142	10	3.00
3313	142	11	3.00
3314	142	12	5.00
3315	142	13	3.00
3316	242	1	5.00
3317	242	2	3.00
3318	242	3	4.00
3319	242	4	3.00
3320	242	5	3.00
3321	242	6	5.00
3322	242	7	3.00
3323	242	8	2.00
3324	242	9	3.00
3325	242	10	3.00
3326	242	11	3.00
3327	242	12	5.00
3328	242	13	3.00
3329	20	1	5.00
3330	20	2	5.00
3331	20	3	4.00
3332	20	4	2.50
3333	20	5	3.00
3334	20	6	5.00
3335	20	7	3.00
3336	20	8	2.00
3337	20	9	3.00
3338	20	10	3.00
3339	20	11	3.00
3340	20	12	5.00
3341	20	13	5.00
3342	234	1	5.00
3343	234	2	3.00
3344	234	3	5.00
3345	234	4	4.00
3346	234	5	5.00
3347	234	6	5.00
3348	234	7	4.00
3349	234	8	2.00
3350	234	9	4.00
3351	234	10	4.00
3352	234	11	3.00
3353	234	12	5.00
3354	234	13	4.00
3355	145	1	5.00
3356	145	2	3.00
3357	145	3	4.00
3358	145	4	3.00
3359	145	5	3.00
3360	145	6	5.00
3361	145	7	3.00
3362	145	8	2.00
3363	145	9	3.00
3364	145	10	3.00
3365	145	11	3.00
3366	145	12	5.00
3367	145	13	3.00
3368	226	1	5.00
3369	226	2	3.00
3370	226	3	4.00
3371	226	4	3.00
3372	226	5	3.00
3373	226	6	5.00
3374	226	7	3.00
3375	226	8	2.00
3376	226	9	3.00
3377	226	10	3.00
3378	226	11	3.00
3379	226	12	5.00
3380	226	13	3.00
3381	101	1	5.00
3382	101	2	3.00
3383	101	3	4.00
3384	101	4	3.00
3385	101	5	3.00
3386	101	6	5.00
3387	101	7	3.00
3388	101	8	2.00
3389	101	9	3.00
3390	101	10	3.00
3391	101	11	3.00
3392	101	12	5.00
3393	101	13	3.00
3394	125	1	5.00
3395	125	2	3.00
3396	125	3	4.00
3397	125	4	3.00
3398	125	5	3.00
3399	125	6	5.00
3400	125	7	3.00
3401	125	8	5.00
3402	125	9	3.00
3403	125	10	3.00
3404	125	11	3.00
3405	125	12	5.00
3406	125	13	3.00
3407	192	1	3.00
3408	192	2	3.00
3409	192	3	4.00
3410	192	4	3.00
3411	192	5	3.00
3412	192	6	3.00
3413	192	7	3.00
3414	192	8	2.00
3415	192	9	3.00
3416	192	10	3.00
3417	192	11	3.00
3418	192	12	3.00
3419	192	13	3.00
3420	155	1	3.00
3421	155	2	3.00
3422	155	3	4.00
3423	155	4	3.00
3424	155	5	3.00
3425	155	6	3.00
3426	155	7	3.00
3427	155	8	2.00
3428	155	9	3.00
3429	155	10	3.00
3430	155	11	3.00
3431	155	12	3.00
3432	155	13	3.00
3433	126	1	3.00
3434	126	2	3.00
3435	126	3	4.00
3436	126	4	3.00
3437	126	5	3.00
3438	126	6	3.00
3439	126	7	3.00
3440	126	8	2.00
3441	126	9	3.00
3442	126	10	3.00
3443	126	11	3.00
3444	126	12	3.00
3445	126	13	3.00
3446	261	1	3.00
3447	261	2	3.00
3448	261	3	4.00
3449	261	4	3.00
3450	261	5	3.00
3451	261	6	3.00
3452	261	7	3.00
3453	261	8	2.00
3454	261	9	3.00
3455	261	10	3.00
3456	261	11	3.00
3457	261	12	3.00
3458	261	13	3.00
3459	197	1	3.00
3460	197	2	3.00
3461	197	3	4.00
3462	197	4	3.00
3463	197	5	3.00
3464	197	6	3.00
3465	197	7	3.00
3466	197	8	2.00
3467	197	9	3.00
3468	197	10	3.00
3469	197	11	3.00
3470	197	12	3.00
3471	197	13	3.00
3472	17	1	5.00
3473	17	2	3.00
3474	17	3	5.00
3475	17	4	4.00
3476	17	5	5.00
3477	17	6	5.00
3478	17	7	4.00
3479	17	8	2.00
3480	17	9	4.00
3481	17	10	4.00
3482	17	11	3.00
3483	17	12	5.00
3484	17	13	4.00
3485	124	1	3.00
3486	124	2	3.00
3487	124	3	4.00
3488	124	4	3.00
3489	124	5	3.00
3490	124	6	3.00
3491	124	7	3.00
3492	124	8	2.00
3493	124	9	3.00
3494	124	10	3.00
3495	124	11	3.00
3496	124	12	3.00
3497	124	13	3.00
3498	16	1	3.00
3499	16	2	5.00
3500	16	3	5.00
3501	16	4	3.00
3502	16	5	5.00
3503	16	6	4.00
3504	16	7	3.00
3505	16	8	5.00
3506	16	9	3.00
3507	16	10	3.00
3508	16	11	3.00
3509	16	12	3.00
3510	16	13	3.00
3511	141	1	4.00
3512	141	2	3.00
3513	141	3	5.00
3514	141	4	4.00
3515	141	5	5.00
3516	141	6	5.00
3517	141	7	3.00
3518	141	8	4.00
3519	141	9	5.00
3520	141	10	3.00
3521	141	11	3.00
3522	141	12	4.00
3523	141	13	4.00
3524	28	1	3.00
3525	28	2	3.00
3526	28	3	5.00
3527	28	4	3.00
3528	28	5	5.00
3529	28	6	4.00
3530	28	7	3.00
3531	28	8	2.00
3532	28	9	3.00
3533	28	10	3.00
3534	28	11	3.00
3535	28	12	3.00
3536	28	13	3.00
3537	14	1	3.00
3538	14	2	5.00
3539	14	3	5.00
3540	14	4	3.00
3541	14	5	5.00
3542	14	6	4.00
3543	14	7	3.00
3544	14	8	2.00
3545	14	9	3.00
3546	14	10	3.00
3547	14	11	3.00
3548	14	12	3.00
3549	14	13	3.00
3550	165	1	3.00
3551	165	2	5.00
3552	165	3	5.00
3553	165	4	3.00
3554	165	5	5.00
3555	165	6	4.00
3556	165	7	3.00
3557	165	8	5.00
3558	165	9	3.00
3559	165	10	3.00
3560	165	11	3.00
3561	165	12	3.00
3562	165	13	3.00
3563	315	1	3.00
3564	315	2	3.00
3565	315	3	4.00
3566	315	4	3.00
3567	315	5	3.00
3568	315	6	3.00
3569	315	7	3.00
3570	315	8	2.00
3571	315	9	3.00
3572	315	10	3.00
3573	315	11	3.00
3574	315	12	3.00
3575	315	13	3.00
3576	215	1	3.00
3577	215	2	5.00
3578	215	3	4.00
3579	215	4	3.00
3580	215	5	3.00
3581	215	6	3.00
3582	215	7	3.00
3583	215	8	2.00
3584	215	9	3.00
3585	215	10	3.00
3586	215	11	3.00
3587	215	12	3.00
3588	215	13	3.00
3589	162	1	4.00
3590	162	2	3.00
3591	162	3	5.00
3592	162	4	4.00
3593	162	5	4.00
3594	162	6	3.00
3595	162	7	5.00
3596	162	8	5.00
3597	162	9	3.00
3598	162	10	3.00
3599	162	11	3.00
3600	162	12	3.00
3601	162	13	3.00
3602	219	1	3.00
3603	219	2	3.00
3604	219	3	4.00
3605	219	4	3.00
3606	219	5	3.00
3607	219	6	3.00
3608	219	7	3.00
3609	219	8	2.00
3610	219	9	3.00
3611	219	10	3.00
3612	219	11	3.00
3613	219	12	3.00
3614	219	13	3.00
3615	292	1	3.00
3616	292	2	3.00
3617	292	3	4.00
3618	292	4	3.00
3619	292	5	3.00
3620	292	6	3.00
3621	292	7	3.00
3622	292	8	5.00
3623	292	9	3.00
3624	292	10	5.00
3625	292	11	3.00
3626	292	12	3.00
3627	292	13	3.00
3628	302	1	3.00
3629	302	2	3.00
3630	302	3	4.00
3631	302	4	3.00
3632	302	5	3.00
3633	302	6	3.00
3634	302	7	3.00
3635	302	8	5.00
3636	302	9	3.00
3637	302	10	5.00
3638	302	11	3.00
3639	302	12	3.00
3640	302	13	3.00
3641	93	1	3.00
3642	93	2	3.00
3643	93	3	4.00
3644	93	4	3.00
3645	93	5	3.00
3646	93	6	3.00
3647	93	7	3.00
3648	93	8	5.00
3649	93	9	3.00
3650	93	10	5.00
3651	93	11	3.00
3652	93	12	3.00
3653	93	13	3.00
3654	243	1	3.00
3655	243	2	5.00
3656	243	3	4.00
3657	243	4	3.00
3658	243	5	3.00
3659	243	6	3.00
3660	243	7	3.00
3661	243	8	5.00
3662	243	9	3.00
3663	243	10	3.00
3664	243	11	3.00
3665	243	12	3.00
3666	243	13	3.00
3667	78	1	3.00
3668	78	2	3.00
3669	78	3	5.00
3670	78	4	3.00
3671	78	5	3.00
3672	78	6	3.00
3673	78	7	3.00
3674	78	8	2.00
3675	78	9	5.00
3676	78	10	5.00
3677	78	11	3.00
3678	78	12	3.00
3679	78	13	4.00
3680	177	1	3.00
3681	177	2	3.00
3682	177	3	4.00
3683	177	4	2.50
3684	177	5	3.00
3685	177	6	3.00
3686	177	7	3.00
3687	177	8	2.00
3688	177	9	3.00
3689	177	10	3.00
3690	177	11	3.00
3691	177	12	3.00
3692	177	13	3.00
3693	123	1	3.00
3694	123	2	3.00
3695	123	3	4.00
3696	123	4	3.00
3697	123	5	3.00
3698	123	6	3.00
3699	123	7	3.00
3700	123	8	5.00
3701	123	9	3.00
3702	123	10	5.00
3703	123	11	3.00
3704	123	12	3.00
3705	123	13	3.00
\.


--
-- Data for Name: hesitation_critere; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hesitation_critere (id_critere, code, nom, categorie, actif) FROM stdin;
1	contenu	Contenu du métier ou de la formation	attirance	t
2	sens	Sens et utilité	attirance	t
3	debouches	Perspectives professionnelles	attirance	t
4	conditions	Conditions de travail	attirance	t
5	progression	Possibilités de progression	attirance	t
6	analyse	Analyse	force	t
7	creation	Créativité	force	t
8	relation	Relation et accompagnement	force	t
9	organisation	Organisation	force	t
10	action	Initiative et passage à l’action	force	t
11	interet	Intérêt personnel	attente	t
12	capacites	Capacités et points forts	attente	t
13	stabilite	Stabilité et sécurité	attente	t
\.


--
-- Data for Name: hesitation_option; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hesitation_option (id_hesitation_option, id_hesitation_test, id_metier, id_filiere, ordre) FROM stdin;
\.


--
-- Data for Name: hesitation_question; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hesitation_question (id_question, question, ordre, actif) FROM stdin;
1	Quand tu penses aux options que tu hésites à choisir, qu’est-ce qui t’attire le plus ?	1	t
2	Dans quelle situation te sens-tu généralement le plus à l’aise ?	2	t
3	Qu’est-ce qui rend ton choix le plus difficile aujourd’hui ?	3	t
4	Si tu devais aujourd’hui donner le plus de poids à un seul critère, lequel serait-ce ?	4	t
5	Qu’est-ce qui t’aiderait le plus à avancer vers une décision ?	5	t
\.


--
-- Data for Name: hesitation_reponse; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hesitation_reponse (id_reponse, id_question, texte, code, ordre) FROM stdin;
1	1	Le contenu : les activités et ce que je vais réellement faire.	ATTIRANCE_CONTENU	1
2	1	Le sens : me sentir utile et faire quelque chose qui me correspond.	ATTIRANCE_SENS	2
3	1	Les possibilités : évolution, débouchés et opportunités.	ATTIRANCE_OPPORTUNITES	3
4	1	Le cadre : environnement, conditions et façon de travailler.	ATTIRANCE_CADRE	4
5	1	Le défi : apprendre, progresser et me dépasser.	ATTIRANCE_DEFI	5
6	2	Résoudre : analyser un problème et trouver une solution.	FORCE_ANALYSER	1
7	2	Créer : imaginer quelque chose et proposer des idées.	FORCE_CREER	2
8	2	Aider : écouter, expliquer ou accompagner quelqu’un.	FORCE_AIDER	3
9	2	Organiser : structurer, planifier et gérer les choses.	FORCE_ORGANISER	4
10	2	Agir : prendre des initiatives et faire avancer un projet.	FORCE_AGIR	5
11	3	J’ai peur de me tromper.	BLOCAGE_ERREUR	1
12	3	J’ai plusieurs options qui m’intéressent réellement.	BLOCAGE_OPTIONS	2
13	3	Je manque d’informations pour comparer.	BLOCAGE_INFORMATION	3
14	3	Je ne suis pas sûr(e) d’avoir le niveau ou les capacités nécessaires.	BLOCAGE_CAPACITES	4
15	3	Mon entourage influence beaucoup mon choix.	BLOCAGE_ENTOURAGE	5
16	4	Mon intérêt personnel.	CRITERE_INTERET	1
17	4	Mes capacités et mes points forts.	CRITERE_CAPACITES	2
18	4	Les débouchés professionnels.	CRITERE_DEBOUCHES	3
19	4	Les conditions de travail.	CRITERE_CONDITIONS	4
20	4	La stabilité et la sécurité.	CRITERE_STABILITE	5
21	5	Mieux comprendre les différences entre mes options.	BESOIN_COMPARAISON	1
22	5	Vérifier laquelle correspond le mieux à mes forces.	BESOIN_COMPATIBILITE	2
23	5	Découvrir la réalité du métier ou de la filière.	BESOIN_REALITE	3
24	5	Vérifier les débouchés et les possibilités d’évolution.	BESOIN_DEBOUCHES	4
25	5	Me rassurer avant de faire mon choix.	BESOIN_RASSURANCE	5
\.


--
-- Data for Name: hesitation_reponse_utilisateur; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hesitation_reponse_utilisateur (id_reponse_utilisateur, id_hesitation_test, id_question, id_reponse) FROM stdin;
\.


--
-- Data for Name: hesitation_test; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hesitation_test (id_hesitation_test, id_user, type_choix, date_creation, statut) FROM stdin;
\.


--
-- Data for Name: historique; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.historique (id_historique, id_user, action, date_action) FROM stdin;
609	46	METIER_CONSULTE: Actuaire	2026-09-18 14:33:12.322
610	46	METIER_CONSULTE: Auditeur Financier	2026-09-18 14:35:13.317
618	26	FORMATION_CONSULTEE: Génie Logiciel	2026-09-19 19:56:48.706
638	26	UNIVERSITE_CONSULTEE: BEM Dakar	2026-09-22 22:54:11.905
645	26	UNIVERSITE_CONSULTEE: BEM Dakar	2026-09-22 22:58:39.531
650	50	AVIS_DONNE	2026-09-22 23:30:07.295
656	50	METIERS_CONSULTES	2026-09-22 23:49:44.305
664	52	UNIVERSITE_CONSULTEE: UCAD	2026-09-23 19:39:41.366
669	54	METIER_CONSULTE: Analyste Crédit	2026-09-23 20:25:54.94
675	54	METIER_CONSULTE: Collaborateur de cabinet comptable	2026-09-23 20:31:35.636
681	54	METIERS_CONSULTES	2026-09-23 20:44:29.749
693	55	FORMATION_CONSULTEE: Pharmacie	2026-09-23 21:23:21.929
698	57	FORMATION_CONSULTEE: Électronique	2026-09-23 21:35:24.382
709	58	UNIVERSITES_CONSULTEES	2026-09-23 22:11:25.9
720	60	TEST_EFFECTUE	2026-09-23 23:05:37.595
721	60	METIERS_CONSULTES	2026-09-23 23:05:37.595
722	60	METIERS_CONSULTES	2026-09-23 23:05:52.607
740	61	FORMATION_CONSULTEE: Mathématiques-Physique-Informatique (MPI)	2026-09-24 11:09:30.872
747	26	FORMATION_CONSULTEE: Mathématiques-Physique-Informatique (MPI)	2026-09-24 15:58:01.207
761	62	TEST_EFFECTUE	2026-09-24 22:20:18.26
762	62	METIERS_CONSULTES	2026-09-24 22:20:18.26
763	62	METIERS_CONSULTES	2026-09-24 22:20:47.562
773	26	FORMATION_CONSULTEE: Transport logistique	2026-09-24 22:41:38.282
787	66	FORMATION_CONSULTEE: Gestion hôtelière et restauration	2026-09-25 13:39:53.816
788	65	UNIVERSITES_CONSULTEES	2026-09-25 13:40:28.169
789	65	FORMATION_CONSULTEE: Agronomie et Production végétale	2026-09-25 13:40:29.395
790	65	UNIVERSITES_CONSULTEES	2026-09-25 13:40:30.81
799	68	FORMATION_CONSULTEE: Droit	2026-09-25 22:35:29.967
800	68	FORMATION_CONSULTEE: Droit public	2026-09-25 22:36:04.327
801	68	FORMATION_CONSULTEE: Droit privé	2026-09-25 22:36:40.278
802	61	FORMATION_CONSULTEE: Mathématiques-Physique-Informatique (MPI)	2026-09-25 22:37:49.429
807	69	UNIVERSITE_CONSULTEE: UGB	2026-09-26 12:28:04.082
808	69	FORMATION_CONSULTEE: Communication	2026-09-26 12:28:34.015
809	69	UNIVERSITE_CONSULTEE: USSEIN	2026-09-26 12:29:20.571
817	73	PROFIL_CONSULTE	2026-09-28 01:14:27.05
833	73	UNIVERSITE_CONSULTEE:  ESGIB	2026-09-28 01:29:52.711
834	73	FORMATION_CONSULTEE: Biologie	2026-09-28 01:30:21.002
839	71	UNIVERSITE_CONSULTEE: ISEP Thiès	2026-09-28 09:38:57.728
845	71	FORMATION_CONSULTEE: Électromécanique et systèmes automatisés	2026-09-28 10:04:17.461
855	74	FORMATION_CONSULTEE	2026-09-28 13:45:54.345
856	74	UNIVERSITES_CONSULTEES	2026-09-28 13:46:07.179
867	24	METIER_CONSULTE: Actuaire	2026-09-28 15:24:17.531
868	24	FORMATION_CONSULTEE: Administration des Affaires	2026-09-28 15:24:28.649
869	24	FORMATION_CONSULTEE: Mathématiques-Physique-Informatique (MPI)	2026-09-28 15:24:50.353
875	24	METIER_CONSULTE: Actuaire	2026-09-28 16:32:32.648
882	24	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-28 16:57:11.612
887	52	FORMATION_CONSULTEE: Informatique	2026-09-28 17:29:39.074
891	24	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-28 18:20:00.61
895	24	UNIVERSITE_CONSULTEE:  BATISUP	2026-09-28 19:06:05.167
899	24	PROFIL_CONSULTE	2026-09-28 19:23:56.62
904	24	METIER_CONSULTE: Infirmier	2026-09-28 19:30:46.923
906	24	METIER_CONSULTE: Infirmier	2026-09-28 19:30:56.958
908	24	PROFIL_CONSULTE	2026-09-28 19:31:06.608
611	46	UNIVERSITE_CONSULTEE: EMIA	2026-09-18 14:36:23.656
619	26	UNIVERSITE_CONSULTEE: EPT	2026-09-19 19:59:33.439
639	26	UNIVERSITE_CONSULTEE: BEM TECH	2026-09-22 22:54:53.307
640	26	FORMATION_CONSULTEE: Informatique	2026-09-22 22:55:01.652
646	26	UNIVERSITE_CONSULTEE: BEM Dakar	2026-09-22 22:59:27.126
651	50	AVIS_DONNE	2026-09-22 23:33:03.142
657	34	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-23 13:13:55.8
665	52	FORMATION_CONSULTEE: Pharmacie	2026-09-23 19:40:36.357
670	54	FORMATION_CONSULTEE: Actuariat	2026-09-23 20:26:47.881
672	54	FORMATION_CONSULTEE: Audit et Contrôle de Gestion	2026-09-23 20:27:33.588
676	54	METIER_CONSULTE: Expert-comptable	2026-09-23 20:32:41.1
683	56	FORMATION_CONSULTEE: Aérospatial	2026-09-23 21:13:28.905
684	56	UNIVERSITE_CONSULTEE: EISMV	2026-09-23 21:14:09.802
685	56	UNIVERSITE_CONSULTEE: ESP	2026-09-23 21:14:37.727
694	55	UNIVERSITE_CONSULTEE: UIDT	2026-09-23 21:24:26.081
700	58	TEST_EFFECTUE	2026-09-23 22:06:43.017
701	58	METIERS_CONSULTES	2026-09-23 22:06:43.017
702	58	METIERS_CONSULTES	2026-09-23 22:06:55.117
710	59	TEST_EFFECTUE	2026-09-23 22:48:20.962
711	59	METIERS_CONSULTES	2026-09-23 22:48:20.962
712	59	METIERS_CONSULTES	2026-09-23 22:48:28.686
723	60	PROFIL_CONSULTE	2026-09-23 23:06:05.594
741	26	UNIVERSITE_CONSULTEE: EMIA	2026-09-24 12:29:20.114
742	26	UNIVERSITE_CONSULTEE: EMIA	2026-09-24 12:29:42.721
748	24	PROFIL_CONSULTE	2026-09-24 17:07:27.665
764	62	METIER_CONSULTE: Gestionnaire des ressources humaines	2026-09-24 22:22:13.599
765	62	FORMATION_CONSULTEE	2026-09-24 22:22:14.422
774	63	FORMATION_CONSULTEE: Transport logistique	2026-09-24 23:18:31.907
791	66	FORMATION_CONSULTEE: Droit	2026-09-25 13:41:02.405
792	65	UNIVERSITES_CONSULTEES	2026-09-25 13:41:34.707
803	69	METIER_CONSULTE: Ingénieur Biomédical	2026-09-26 12:21:28.979
810	71	FORMATION_CONSULTEE: Pharmacie	2026-09-27 20:34:17.753
818	73	METIER_CONSULTE: Ingénieur pédagogique	2026-09-28 01:17:00.987
819	73	FORMATION_CONSULTEE	2026-09-28 01:17:05.208
820	73	METIER_CONSULTE: Ingénieur pédagogique	2026-09-28 01:17:08.439
821	73	FORMATION_CONSULTEE	2026-09-28 01:17:08.958
822	73	METIER_CONSULTE: Médecin	2026-09-28 01:17:27.564
823	73	FORMATION_CONSULTEE	2026-09-28 01:17:28.099
824	73	UNIVERSITES_CONSULTEES	2026-09-28 01:17:36.663
825	73	FORMATION_CONSULTEE: Médecine	2026-09-28 01:17:38.051
826	73	UNIVERSITES_CONSULTEES	2026-09-28 01:17:38.709
835	52	UNIVERSITE_CONSULTEE: UIDT	2026-09-28 08:31:45.03
840	71	UNIVERSITE_CONSULTEE: ISEP Diamniadio	2026-09-28 10:00:03.812
846	71	UNIVERSITE_CONSULTEE: UIDT	2026-09-28 10:06:08.617
859	74	UNIVERSITES_CONSULTEES	2026-09-28 13:47:38.336
870	24	PROFIL_CONSULTE	2026-09-28 16:21:41.722
872	24	FORMATION_CONSULTEE	2026-09-28 16:21:56.594
877	24	METIER_CONSULTE: Administrateur Systèmes	2026-09-28 16:35:39.921
879	24	FORMATION_CONSULTEE	2026-09-28 16:36:26.431
880	24	FORMATION_CONSULTEE: Actuariat	2026-09-28 16:36:57.55
883	52	TEST_EFFECTUE	2026-09-28 17:25:48.129
884	52	METIERS_CONSULTES	2026-09-28 17:25:48.129
888	24	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-28 17:55:42.723
892	24	UNIVERSITE_CONSULTEE:  ISI	2026-09-28 18:21:08.69
896	24	METIER_CONSULTE: Assistant Médical	2026-09-28 19:14:19.011
900	24	FORMATION_CONSULTEE: Actuariat	2026-09-28 19:25:06.22
902	24	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-28 19:25:19.376
909	63	FORMATION_CONSULTEE: Transport logistique	2026-09-28 20:52:10.485
209	20	METIER_CONSULTE: Administrateur Systèmes	2026-09-02 14:21:35
210	20	UNIVERSITE_CONSULTEE: ESGE	2026-09-02 14:23:44
211	20	/UNIVERSITE_CONSULTEE:  UAHB	2026-09-02 14:27:58
612	46	FORMATION_CONSULTEE: Management appliqué	2026-09-18 14:38:03.911
620	50	TEST_EFFECTUE	2026-09-22 22:16:12.66
621	50	METIERS_CONSULTES	2026-09-22 22:16:12.66
622	50	METIERS_CONSULTES	2026-09-22 22:16:27.242
641	26	UNIVERSITE_CONSULTEE: BEM TECH	2026-09-22 22:55:50.742
647	50	AVIS_DONNE	2026-09-22 23:22:44.356
652	50	AVIS_DONNE	2026-09-22 23:33:03.733
658	34	FORMATION_CONSULTEE: Marketing et communication	2026-09-23 13:14:57.028
666	52	FORMATION_CONSULTEE: Odontologie	2026-09-23 19:42:25.336
671	54	FORMATION_CONSULTEE: Administration et Gestion des Entreprises	2026-09-23 20:27:11.969
677	54	UNIVERSITE_CONSULTEE: CESAG	2026-09-23 20:34:41.169
686	55	TEST_EFFECTUE	2026-09-23 21:14:44.615
687	55	METIERS_CONSULTES	2026-09-23 21:14:44.615
688	55	METIERS_CONSULTES	2026-09-23 21:14:58.97
695	55	UNIVERSITE_CONSULTEE: UCAD	2026-09-23 21:26:14.185
703	58	PROFIL_CONSULTE	2026-09-23 22:09:34.865
713	59	METIER_CONSULTE: Médecin	2026-09-23 22:49:53.102
716	59	FORMATION_CONSULTEE: Médecine	2026-09-23 22:49:58.486
717	59	UNIVERSITES_CONSULTEES	2026-09-23 22:50:00.114
724	60	METIER_CONSULTE: Ingénieur Intelligence Artificielle	2026-09-23 23:07:41.32
727	60	FORMATION_CONSULTEE	2026-09-23 23:07:43.134
728	60	UNIVERSITES_CONSULTEES	2026-09-23 23:07:58.417
731	60	FORMATION_CONSULTEE: Génie informatique	2026-09-23 23:07:59.887
732	60	UNIVERSITES_CONSULTEES	2026-09-23 23:08:00.626
736	60	FORMATION_CONSULTEE: Data Science	2026-09-23 23:08:29.899
737	60	UNIVERSITES_CONSULTEES	2026-09-23 23:08:30.818
743	24	FORMATION_CONSULTEE: Mathématiques-Physique-Informatique (MPI)	2026-09-24 12:51:18.353
744	24	FORMATION_CONSULTEE: Mathématiques-Physique-Informatique (MPI)	2026-09-24 12:51:20.645
749	24	PROFIL_CONSULTE	2026-09-24 17:45:58.011
766	62	UNIVERSITES_CONSULTEES	2026-09-24 22:23:54.693
767	62	FORMATION_CONSULTEE: Gestion	2026-09-24 22:23:55.021
768	62	UNIVERSITES_CONSULTEES	2026-09-24 22:23:55.775
769	62	UNIVERSITES_CONSULTEES	2026-09-24 22:24:19.282
770	62	PROFIL_CONSULTE	2026-09-24 22:24:38.142
775	64	TEST_EFFECTUE	2026-09-25 01:28:20.839
776	64	METIERS_CONSULTES	2026-09-25 01:28:20.839
777	64	METIERS_CONSULTES	2026-09-25 01:28:27.737
793	67	FORMATION_CONSULTEE: Entrepreneuriat et Développement (ENDEV)	2026-09-25 18:54:24.978
794	67	FORMATION_CONSULTEE: Administration des Affaires	2026-09-25 18:54:44.362
795	67	FORMATION_CONSULTEE: Comptabilité et Gestion	2026-09-25 18:55:27.108
796	67	FORMATION_CONSULTEE: Gestion	2026-09-25 18:55:46.046
804	69	UNIVERSITE_CONSULTEE: USSEIN	2026-09-26 12:24:05.431
811	71	FORMATION_CONSULTEE: Gestion	2026-09-27 20:35:58.023
827	73	METIER_CONSULTE: Biologiste Médical	2026-09-28 01:20:26.537
836	52	FORMATION_CONSULTEE: Informatique	2026-09-28 08:32:32.691
841	71	FORMATION_CONSULTEE: Cybersécurité	2026-09-28 10:01:09.564
842	71	UNIVERSITE_CONSULTEE:  IPSL	2026-09-28 10:01:27.765
847	71	FORMATION_CONSULTEE: Gestion	2026-09-28 10:07:47.716
848	71	FORMATION_CONSULTEE: Informatique de Gestion	2026-09-28 10:11:39.235
849	71	FORMATION_CONSULTEE: Pharmacie	2026-09-28 10:11:59.318
850	71	FORMATION_CONSULTEE: Gestion	2026-09-28 10:12:26.006
860	74	FORMATION_CONSULTEE: Marketing	2026-09-28 13:47:38.908
861	74	UNIVERSITES_CONSULTEES	2026-09-28 13:47:39.808
871	24	METIER_CONSULTE: Infirmier	2026-09-28 16:21:56.054
878	24	METIER_CONSULTE: Infirmier	2026-09-28 16:36:25.871
885	52	METIERS_CONSULTES	2026-09-28 17:25:59.665
889	24	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-28 17:57:39.555
893	24	UNIVERSITE_CONSULTEE:  BATISUP	2026-09-28 18:21:42.904
897	24	FORMATION_CONSULTEE	2026-09-28 19:14:19.888
901	24	FORMATION_CONSULTEE: Actuariat	2026-09-28 19:25:04.205
910	24	TEST_EFFECTUE	2026-09-29 10:32:02.129
911	24	METIERS_CONSULTES	2026-09-29 10:32:02.129
912	24	METIERS_CONSULTES	2026-09-29 10:32:21.286
319	24	METIERS_CONSULTES	2026-09-12 11:43:54.876
320	24	PROFIL_CONSULTE	2026-09-12 11:44:03.866
321	24	METIER_CONSULTE: Dessinateur-Projeteur BTP	2026-09-12 11:44:11.99
322	24	FORMATION_CONSULTEE	2026-09-12 11:44:12.352
323	24	METIER_CONSULTE: Dessinateur-Projeteur BTP	2026-09-12 11:44:24.463
324	24	FORMATION_CONSULTEE	2026-09-12 11:44:24.772
325	24	UNIVERSITES_CONSULTEES	2026-09-12 11:44:30.925
326	24	FORMATION_CONSULTEE: Génie Civil	2026-09-12 11:44:31.387
327	26	METIERS_CONSULTES	2026-09-12 11:57:23.337
328	26	PROFIL_CONSULTE	2026-09-12 11:57:33.666
329	26	METIER_CONSULTE: Infirmier	2026-09-12 11:58:13.259
330	26	FORMATION_CONSULTEE	2026-09-12 11:58:13.821
331	26	UNIVERSITES_CONSULTEES	2026-09-12 11:58:29.408
332	26	FORMATION_CONSULTEE: Sciences infirmières	2026-09-12 11:58:29.865
333	26	UNIVERSITE_CONSULTEE: ESUP Dakar	2026-09-12 11:59:05.314
334	26	UNIVERSITE_CONSULTEE: BEM TECH	2026-09-12 11:59:47.691
335	24	UNIVERSITE_CONSULTEE:  IFAGE	2026-09-12 12:03:23.272
336	24	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-12 12:03:39.757
337	24	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-12 12:03:46.18
338	24	UNIVERSITE_CONSULTEE:  ESGIB	2026-09-12 12:03:58.357
339	24	UNIVERSITE_CONSULTEE: UCAD	2026-09-12 12:05:05.559
340	26	FORMATION_CONSULTEE: Data Science	2026-09-12 12:05:50.105
341	24	FORMATION_CONSULTEE: Odontologie	2026-09-12 12:07:15.307
342	26	UNIVERSITE_CONSULTEE: AKADEMIA DAKAR - 	2026-09-12 13:19:04.687
343	26	UNIVERSITE_CONSULTEE: AKADEMIA DAKAR - 	2026-09-12 13:19:27.466
344	26	FORMATION_CONSULTEE: Droit des affaires	2026-09-12 13:19:58.629
345	24	UNIVERSITE_CONSULTEE:  UCAO Saint-Michel	2026-09-12 13:27:51.539
346	24	UNIVERSITE_CONSULTEE: EMIA 	2026-09-12 14:04:53.474
347	24	FORMATION_CONSULTEE: Gouvernance Publique et Développement Local	2026-09-12 14:10:32.53
348	24	FORMATION_CONSULTEE: Gouvernance Locale et Développement Territorial	2026-09-12 14:10:42.041
349	24	FORMATION_CONSULTEE: Gouvernance Publique et Développement Local	2026-09-12 14:10:54.094
350	24	FORMATION_CONSULTEE: Gouvernance Locale et Développement Territorial	2026-09-12 14:11:08.072
351	24	FORMATION_CONSULTEE: Gouvernance Publique et Développement Local	2026-09-12 14:11:19.93
352	24	FORMATION_CONSULTEE: Gouvernance Locale et Développement Territorial	2026-09-12 14:11:33.376
353	24	FORMATION_CONSULTEE: Gouvernance Publique et Développement Local	2026-09-12 14:11:47.822
354	24	UNIVERSITE_CONSULTEE: EMIA 	2026-09-12 14:15:34.447
355	24	METIERS_CONSULTES	2026-09-12 14:54:54.96
356	24	METIERS_CONSULTES	2026-09-12 14:55:12.565
357	24	UNIVERSITE_CONSULTEE: EMIA	2026-09-12 15:22:43.96
358	24	AVIS_DONNE	2026-09-12 15:23:35.96
359	24	AVIS_DONNE	2026-09-12 15:23:36.474
360	24	TEST_EFFECTUE	2026-09-12 15:25:34.099
361	24	METIERS_CONSULTES	2026-09-12 15:25:34.099
362	24	METIERS_CONSULTES	2026-09-12 15:25:41.309
363	24	TEST_EFFECTUE	2026-09-12 15:42:44.839
364	24	METIERS_CONSULTES	2026-09-12 15:42:44.839
365	24	METIERS_CONSULTES	2026-09-12 15:42:48.958
366	24	TEST_EFFECTUE	2026-09-12 15:45:24.643
367	24	METIERS_CONSULTES	2026-09-12 15:45:24.643
368	24	METIERS_CONSULTES	2026-09-12 15:45:36.512
369	24	METIER_CONSULTE: Architecte	2026-09-12 15:50:14.121
370	24	FORMATION_CONSULTEE	2026-09-12 15:50:14.804
371	24	UNIVERSITES_CONSULTEES	2026-09-12 15:50:24.354
372	24	FORMATION_CONSULTEE: Travaux Publics	2026-09-12 15:50:24.759
373	24	UNIVERSITES_CONSULTEES	2026-09-12 15:50:25.769
374	24	PROFIL_CONSULTE	2026-09-12 15:50:49.273
375	24	TEST_EFFECTUE	2026-09-12 15:54:08.352
376	24	METIERS_CONSULTES	2026-09-12 15:54:08.352
377	24	METIERS_CONSULTES	2026-09-12 15:54:15.716
378	24	TEST_EFFECTUE	2026-09-12 15:56:16.5
379	24	METIERS_CONSULTES	2026-09-12 15:56:16.5
380	24	METIERS_CONSULTES	2026-09-12 15:56:22.129
382	24	TEST_EFFECTUE	2026-09-12 16:10:05.272
383	24	METIERS_CONSULTES	2026-09-12 16:10:05.272
384	24	METIERS_CONSULTES	2026-09-12 16:10:29.901
385	26	UNIVERSITE_CONSULTEE: EMIA	2026-09-12 16:12:25.045
386	26	UNIVERSITE_CONSULTEE: EMIA	2026-09-12 16:13:04.854
387	24	TEST_EFFECTUE	2026-09-12 16:51:35.896
388	24	METIERS_CONSULTES	2026-09-12 16:51:35.896
389	24	METIERS_CONSULTES	2026-09-12 16:51:41.092
390	26	FORMATION_CONSULTEE: Master of Business Administration (MBA)	2026-09-12 17:12:34.172
391	26	FORMATION_CONSULTEE: Transport logistique	2026-09-12 17:13:05.961
392	29	TEST_EFFECTUE	2026-09-12 19:24:29.422
393	29	METIERS_CONSULTES	2026-09-12 19:24:29.422
394	29	METIERS_CONSULTES	2026-09-12 19:24:35.676
395	28	TEST_EFFECTUE	2026-09-12 19:34:57.452
396	28	METIERS_CONSULTES	2026-09-12 19:34:57.452
397	28	METIERS_CONSULTES	2026-09-12 19:35:10.433
398	28	PROFIL_CONSULTE	2026-09-12 19:36:08.958
399	28	METIER_CONSULTE: Développeur Web	2026-09-12 19:36:49.76
400	28	FORMATION_CONSULTEE	2026-09-12 19:36:50.31
401	28	UNIVERSITES_CONSULTEES	2026-09-12 19:37:08.995
402	28	FORMATION_CONSULTEE: Informatique	2026-09-12 19:37:09.459
403	28	UNIVERSITES_CONSULTEES	2026-09-12 19:37:10.149
404	28	METIER_CONSULTE: Data Scientist	2026-09-12 19:39:02.371
405	28	FORMATION_CONSULTEE	2026-09-12 19:39:03.028
406	28	UNIVERSITES_CONSULTEES	2026-09-12 19:39:24.34
407	28	FORMATION_CONSULTEE: Data Science	2026-09-12 19:39:24.836
408	28	UNIVERSITES_CONSULTEES	2026-09-12 19:39:25.459
409	28	UNIVERSITES_CONSULTEES	2026-09-12 19:39:41.782
410	28	FORMATION_CONSULTEE: Sciences et Technologies	2026-09-12 19:39:42.079
411	28	UNIVERSITES_CONSULTEES	2026-09-12 19:39:42.852
412	28	UNIVERSITES_CONSULTEES	2026-09-12 19:39:52.856
413	28	FORMATION_CONSULTEE: Génie informatique	2026-09-12 19:39:53.308
414	28	UNIVERSITES_CONSULTEES	2026-09-12 19:39:54.158
415	28	UNIVERSITES_CONSULTEES	2026-09-12 19:40:13.823
416	28	METIER_CONSULTE: Ingénieur Intelligence Artificielle	2026-09-12 19:40:56.552
417	28	FORMATION_CONSULTEE	2026-09-12 19:40:57.099
418	28	UNIVERSITES_CONSULTEES	2026-09-12 19:41:00.505
419	28	FORMATION_CONSULTEE: Professeur de Mathématiques	2026-09-12 19:41:00.925
420	28	UNIVERSITES_CONSULTEES	2026-09-12 19:41:01.555
421	28	TEST_EFFECTUE	2026-09-12 19:47:45.57
422	28	METIERS_CONSULTES	2026-09-12 19:47:45.57
423	28	METIERS_CONSULTES	2026-09-12 19:47:55.314
424	26	METIER_CONSULTE: Infirmier	2026-09-12 20:17:59.985
425	26	FORMATION_CONSULTEE	2026-09-12 20:18:00.292
426	26	UNIVERSITES_CONSULTEES	2026-09-12 20:18:15.631
427	26	FORMATION_CONSULTEE: Sciences infirmières	2026-09-12 20:18:16.427
428	26	UNIVERSITES_CONSULTEES	2026-09-12 20:18:17.216
429	31	TEST_EFFECTUE	2026-09-12 21:02:08.1
430	31	METIERS_CONSULTES	2026-09-12 21:02:08.1
431	31	METIERS_CONSULTES	2026-09-12 21:02:14.433
432	31	PROFIL_CONSULTE	2026-09-12 21:03:34.964
433	31	METIER_CONSULTE: Concepteur pédagogique numérique	2026-09-12 21:05:04.691
434	31	FORMATION_CONSULTEE	2026-09-12 21:05:05.201
435	31	FORMATION_CONSULTEE	2026-09-12 21:05:05.943
436	31	METIER_CONSULTE: UX/UI Designer	2026-09-12 21:05:22.977
437	31	FORMATION_CONSULTEE	2026-09-12 21:05:23.425
438	31	UNIVERSITES_CONSULTEES	2026-09-12 21:05:57.569
439	31	FORMATION_CONSULTEE: Informatique	2026-09-12 21:05:58.038
440	31	UNIVERSITES_CONSULTEES	2026-09-12 21:05:58.987
441	32	TEST_EFFECTUE	2026-09-12 21:23:02.997
442	32	METIERS_CONSULTES	2026-09-12 21:23:02.997
443	32	METIERS_CONSULTES	2026-09-12 21:23:13.642
444	32	METIER_CONSULTE: Économiste	2026-09-12 21:24:35.167
445	32	FORMATION_CONSULTEE	2026-09-12 21:24:35.46
446	32	UNIVERSITES_CONSULTEES	2026-09-12 21:24:44.568
447	32	FORMATION_CONSULTEE: Systèmes économiques et de gestion	2026-09-12 21:24:44.868
448	32	UNIVERSITES_CONSULTEES	2026-09-12 21:24:45.66
449	32	UNIVERSITES_CONSULTEES	2026-09-12 21:25:04.932
452	32	UNIVERSITE_CONSULTEE:  UCAO Saint-Michel	2026-09-12 21:25:16.76
453	33	TEST_EFFECTUE	2026-09-12 21:25:58.506
454	33	METIERS_CONSULTES	2026-09-12 21:25:58.506
455	33	METIERS_CONSULTES	2026-09-12 21:26:12.781
458	34	METIERS_CONSULTES	2026-09-12 21:26:51.963
613	46	AVIS_DONNE	2026-09-18 14:42:18.494
614	46	AVIS_DONNE	2026-09-18 14:42:21.095
623	50	PROFIL_CONSULTE	2026-09-22 22:17:51.909
624	50	METIER_CONSULTE: Développeur Web	2026-09-22 22:18:15.037
625	50	FORMATION_CONSULTEE	2026-09-22 22:18:15.434
626	50	UNIVERSITES_CONSULTEES	2026-09-22 22:18:38.246
627	50	FORMATION_CONSULTEE: Informatique	2026-09-22 22:18:38.874
628	50	UNIVERSITES_CONSULTEES	2026-09-22 22:18:39.689
629	50	UNIVERSITE_CONSULTEE: UCAD	2026-09-22 22:19:08.838
630	50	UNIVERSITES_CONSULTEES	2026-09-22 22:19:24.459
631	50	FORMATION_CONSULTEE: Génie Logiciel	2026-09-22 22:19:24.868
632	50	UNIVERSITES_CONSULTEES	2026-09-22 22:19:25.879
634	50	FORMATION_CONSULTEE	2026-09-22 22:20:43.908
636	50	FORMATION_CONSULTEE: Mathématiques	2026-09-22 22:21:01.523
642	26	UNIVERSITE_CONSULTEE: BEM Dakar	2026-09-22 22:56:19.967
643	26	UNIVERSITE_CONSULTEE: BEM Dakar	2026-09-22 22:56:25.036
648	50	AVIS_DONNE	2026-09-22 23:22:44.802
653	50	FORMATION_CONSULTEE: Génie informatique	2026-09-22 23:36:22.735
659	34	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-23 13:15:30.705
667	54	METIER_CONSULTE: Actuaire	2026-09-23 20:23:47.213
673	54	FORMATION_CONSULTEE: Comptabilité	2026-09-23 20:28:17.074
678	54	UNIVERSITE_CONSULTEE: CESAG	2026-09-23 20:34:54.854
689	56	FORMATION_CONSULTEE: Automobile	2026-09-23 21:18:15.106
692	56	METIERS_CONSULTES	2026-09-23 21:22:47.084
696	57	UNIVERSITE_CONSULTEE: UAM	2026-09-23 21:34:09
704	58	METIER_CONSULTE: Gestionnaire Assurance	2026-09-23 22:10:23.4
707	58	FORMATION_CONSULTEE: Banque, Assurance, Finance	2026-09-23 22:10:40.194
708	58	UNIVERSITES_CONSULTEES	2026-09-23 22:10:41.134
714	59	FORMATION_CONSULTEE	2026-09-23 22:49:53.814
715	59	UNIVERSITES_CONSULTEES	2026-09-23 22:49:58.067
718	59	UNIVERSITE_CONSULTEE: UCAD	2026-09-23 22:50:06.917
725	60	FORMATION_CONSULTEE	2026-09-23 23:07:42.074
726	60	METIER_CONSULTE: Ingénieur Intelligence Artificielle	2026-09-23 23:07:42.639
729	60	FORMATION_CONSULTEE: Génie informatique	2026-09-23 23:07:58.97
730	60	UNIVERSITES_CONSULTEES	2026-09-23 23:07:59.323
733	60	UNIVERSITES_CONSULTEES	2026-09-23 23:08:01.141
734	60	UNIVERSITES_CONSULTEES	2026-09-23 23:08:18.984
735	60	UNIVERSITES_CONSULTEES	2026-09-23 23:08:29.281
738	60	UNIVERSITE_CONSULTEE:  ISI	2026-09-23 23:08:44.981
745	24	FORMATION_CONSULTEE: Mathématiques-Physique-Informatique (MPI)	2026-09-24 12:58:37.546
750	53	TEST_EFFECTUE	2026-09-24 19:29:08.273
751	53	METIERS_CONSULTES	2026-09-24 19:29:08.273
752	53	METIERS_CONSULTES	2026-09-24 19:29:22.547
771	62	PROFIL_CONSULTE	2026-09-24 22:24:31.234
778	65	TEST_EFFECTUE	2026-09-25 13:31:25.359
779	65	METIERS_CONSULTES	2026-09-25 13:31:25.359
780	65	METIERS_CONSULTES	2026-09-25 13:31:39.742
797	64	PROFIL_CONSULTE	2026-09-25 19:31:25.191
805	69	UNIVERSITE_CONSULTEE: UCAD	2026-09-26 12:25:41.424
812	71	FORMATION_CONSULTEE: Robotique	2026-09-27 20:36:43.679
813	71	UNIVERSITE_CONSULTEE: EISMV	2026-09-27 20:37:27.203
828	73	FORMATION_CONSULTEE: Analyses biologiques	2026-09-28 01:24:23.305
831	73	FORMATION_CONSULTEE: Thermodynamique	2026-09-28 01:25:45.384
837	52	FORMATION_CONSULTEE: Informatique	2026-09-28 08:35:01.523
843	71	UNIVERSITE_CONSULTEE: CFPT	2026-09-28 10:01:47.061
851	74	TEST_EFFECTUE	2026-09-28 13:38:13.404
852	74	METIERS_CONSULTES	2026-09-28 13:38:13.404
853	74	METIERS_CONSULTES	2026-09-28 13:38:27.178
862	74	METIER_CONSULTE: Spécialiste e-commerce	2026-09-28 13:48:38.272
865	74	FORMATION_CONSULTEE: Marketing digital	2026-09-28 13:48:53.131
866	74	UNIVERSITES_CONSULTEES	2026-09-28 13:48:53.957
873	24	PROFIL_CONSULTE	2026-09-28 16:22:31.753
881	24	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-28 16:38:07.548
886	52	UNIVERSITE_CONSULTEE: UIDT	2026-09-28 17:28:10.119
890	24	UNIVERSITE_CONSULTEE:  BATISUP	2026-09-28 18:19:34.903
894	24	FORMATION_CONSULTEE: Actuariat	2026-09-28 18:42:43.386
898	24	PROFIL_CONSULTE	2026-09-28 19:22:35.661
903	24	PROFIL_CONSULTE	2026-09-28 19:30:33.686
905	24	FORMATION_CONSULTEE	2026-09-28 19:30:47.599
907	24	FORMATION_CONSULTEE	2026-09-28 19:30:57.313
913	24	PROFIL_CONSULTE	2026-09-29 10:32:57.633
450	32	FORMATION_CONSULTEE: Économie et Gestion	2026-09-12 21:25:05.32
451	32	UNIVERSITES_CONSULTEES	2026-09-12 21:25:06.031
456	34	TEST_EFFECTUE	2026-09-12 21:26:46.939
457	34	METIERS_CONSULTES	2026-09-12 21:26:46.939
459	34	METIER_CONSULTE: Actuaire	2026-09-12 21:33:09.986
460	34	METIER_CONSULTE: Assistant comptable	2026-09-12 21:34:19.902
461	27	METIER_CONSULTE: Data Scientist	2026-09-12 22:00:39.38
462	27	FORMATION_CONSULTEE: Statistique et Informatique Décisionnelle	2026-09-12 22:02:42.333
463	35	METIER_CONSULTE: Data Scientist	2026-09-12 23:29:11.606
464	34	TEST_EFFECTUE	2026-09-12 23:58:46.174
465	34	METIERS_CONSULTES	2026-09-12 23:58:46.174
466	34	METIERS_CONSULTES	2026-09-12 23:58:52.205
467	34	METIER_CONSULTE: Actuaire	2026-09-13 00:02:37.198
468	34	METIER_CONSULTE: Actuaire	2026-09-13 00:02:37.838
469	34	FORMATION_CONSULTEE: Administration et Gestion des Entreprises	2026-09-13 00:03:18.691
470	34	FORMATION_CONSULTEE: Génie Civil	2026-09-13 00:04:02.928
471	34	UNIVERSITE_CONSULTEE: EMIA	2026-09-13 00:05:39.871
472	34	METIER_CONSULTE: Administrateur Réseau	2026-09-13 08:34:48.731
473	37	TEST_EFFECTUE	2026-09-13 11:32:24.259
474	37	METIERS_CONSULTES	2026-09-13 11:32:24.259
475	37	METIERS_CONSULTES	2026-09-13 11:32:30.07
476	37	METIER_CONSULTE: Développeur Backend	2026-09-13 11:38:16.482
477	26	METIER_CONSULTE: Infirmier	2026-09-13 12:01:59.319
478	26	FORMATION_CONSULTEE	2026-09-13 12:01:59.614
479	26	UNIVERSITES_CONSULTEES	2026-09-13 12:02:14.477
480	26	FORMATION_CONSULTEE: Sciences infirmières	2026-09-13 12:02:14.968
481	26	UNIVERSITES_CONSULTEES	2026-09-13 12:02:15.321
482	26	FORMATION_CONSULTEE: Sciences infirmières	2026-09-13 12:02:15.842
483	26	UNIVERSITES_CONSULTEES	2026-09-13 12:02:15.986
484	26	UNIVERSITES_CONSULTEES	2026-09-13 12:02:16.667
485	26	UNIVERSITE_CONSULTEE:  CEFAS	2026-09-13 12:02:37.228
486	26	UNIVERSITES_CONSULTEES	2026-09-13 12:03:17.192
487	26	METIER_CONSULTE: Technicien Agricole	2026-09-13 12:03:38.304
488	26	FORMATION_CONSULTEE	2026-09-13 12:03:38.643
489	26	UNIVERSITES_CONSULTEES	2026-09-13 12:03:51.697
490	26	FORMATION_CONSULTEE: Agronomie	2026-09-13 12:03:52.023
491	26	UNIVERSITES_CONSULTEES	2026-09-13 12:03:52.607
492	26	UNIVERSITE_CONSULTEE: EMIA	2026-09-13 12:04:23.606
493	26	UNIVERSITE_CONSULTEE: ENSAE	2026-09-13 12:05:37.021
494	26	UNIVERSITE_CONSULTEE: ENSAE	2026-09-13 12:05:40.608
495	26	UNIVERSITE_CONSULTEE: ENSAE	2026-09-13 12:05:45.484
496	26	FORMATION_CONSULTEE: Cycle Analyste Statisticien	2026-09-13 12:10:02.701
497	26	UNIVERSITE_CONSULTEE: ENSAE	2026-09-13 12:10:26.957
498	26	FORMATION_CONSULTEE: Cycle Analyste Statisticien	2026-09-13 12:10:32.906
499	27	UNIVERSITE_CONSULTEE:  IPSL	2026-09-13 13:09:37.714
500	27	FORMATION_CONSULTEE: Génie Civil	2026-09-13 13:09:48.81
501	38	TEST_EFFECTUE	2026-09-13 13:40:35.279
502	38	METIERS_CONSULTES	2026-09-13 13:40:35.279
503	38	METIERS_CONSULTES	2026-09-13 13:40:43.337
504	38	METIER_CONSULTE: Ingénieur pédagogique	2026-09-13 13:42:17.372
505	38	METIER_CONSULTE: Ingénieur pédagogique	2026-09-13 13:42:18.251
506	38	FORMATION_CONSULTEE	2026-09-13 13:42:20.314
507	38	FORMATION_CONSULTEE	2026-09-13 13:42:20.254
508	38	METIER_CONSULTE: Ingénieur pédagogique	2026-09-13 13:42:20.273
509	38	FORMATION_CONSULTEE	2026-09-13 13:42:23.036
510	38	METIER_CONSULTE: Ingénieur pédagogique	2026-09-13 13:42:40.025
511	38	FORMATION_CONSULTEE	2026-09-13 13:42:40.405
512	38	METIER_CONSULTE: Psychologue du travail	2026-09-13 13:42:58.671
513	38	FORMATION_CONSULTEE	2026-09-13 13:42:58.975
514	38	METIER_CONSULTE: Ingénieur pédagogique	2026-09-13 13:43:11.568
515	38	FORMATION_CONSULTEE	2026-09-13 13:43:12.091
516	39	TEST_EFFECTUE	2026-09-13 13:43:24.933
517	39	METIERS_CONSULTES	2026-09-13 13:43:24.933
518	39	METIERS_CONSULTES	2026-09-13 13:43:34.562
519	27	METIER_CONSULTE: Ingénieur pédagogique	2026-09-13 13:44:03.641
520	39	METIER_CONSULTE: Gestionnaire des ressources humaines	2026-09-13 13:45:49.349
521	39	FORMATION_CONSULTEE	2026-09-13 13:45:50.515
522	38	FORMATION_CONSULTEE: Administration des Affaires	2026-09-13 13:52:17.79
523	38	METIER_CONSULTE: Administrateur Base de Données	2026-09-13 13:55:15.055
524	40	AVIS_DONNE	2026-09-13 21:15:17.366
525	40	AVIS_DONNE	2026-09-13 21:15:17.918
526	41	UNIVERSITE_CONSULTEE:  IPSL	2026-09-14 11:48:13.648
527	41	UNIVERSITE_CONSULTEE:  DIT	2026-09-14 11:48:59.509
528	41	FORMATION_CONSULTEE: Informatique	2026-09-14 11:50:14.086
529	41	FORMATION_CONSULTEE: Communication d'entreprise	2026-09-14 11:52:57.385
530	41	FORMATION_CONSULTEE: Maintenance Informatique	2026-09-14 11:53:42.176
531	41	UNIVERSITE_CONSULTEE:  IAM 	2026-09-14 11:54:36.92
532	41	FORMATION_CONSULTEE: Informatique de Gestion	2026-09-14 11:56:10.477
533	41	FORMATION_CONSULTEE: Informatique de Gestion	2026-09-14 11:59:27.175
534	41	FORMATION_CONSULTEE: Informatique de Gestion	2026-09-14 12:00:59.282
535	35	FORMATION_CONSULTEE: Data Science	2026-09-14 12:52:04.828
536	26	UNIVERSITE_CONSULTEE:  DIT	2026-09-14 22:04:23.958
537	26	UNIVERSITE_CONSULTEE:  CEFAS	2026-09-14 22:04:36.118
538	26	UNIVERSITE_CONSULTEE:  BATISUP	2026-09-14 22:04:36.36
539	26	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-14 22:04:36.795
540	26	UNIVERSITE_CONSULTEE:  DIT	2026-09-14 22:04:36.801
541	26	FORMATION_CONSULTEE: Big Data	2026-09-14 22:05:14.369
542	44	TEST_EFFECTUE	2026-09-14 23:07:19.009
543	44	METIERS_CONSULTES	2026-09-14 23:07:19.009
544	44	METIERS_CONSULTES	2026-09-14 23:07:24.454
545	44	PROFIL_CONSULTE	2026-09-14 23:07:41.208
546	44	METIER_CONSULTE: Enseignant / Professeur	2026-09-14 23:08:05.022
547	44	FORMATION_CONSULTEE	2026-09-14 23:08:05.582
548	44	UNIVERSITES_CONSULTEES	2026-09-14 23:08:12.945
549	44	FORMATION_CONSULTEE: Professeur de Mathématiques	2026-09-14 23:08:13.378
550	44	UNIVERSITES_CONSULTEES	2026-09-14 23:08:14.41
551	44	TEST_EFFECTUE	2026-09-14 23:15:06.171
552	44	METIERS_CONSULTES	2026-09-14 23:15:06.171
553	44	METIERS_CONSULTES	2026-09-14 23:15:12.567
554	44	PROFIL_CONSULTE	2026-09-14 23:15:30.086
555	44	METIER_CONSULTE: Assistant Médical	2026-09-14 23:17:52.044
556	44	METIER_CONSULTE: Avocat	2026-09-14 23:18:59.652
557	44	METIER_CONSULTE: Chef de Chantier BTP	2026-09-14 23:19:39.76
558	44	METIER_CONSULTE: Dentiste	2026-09-14 23:20:09.223
559	44	METIER_CONSULTE: Dentiste	2026-09-14 23:20:28.57
560	45	TEST_EFFECTUE	2026-09-15 01:16:43
561	45	METIERS_CONSULTES	2026-09-15 01:16:43
562	45	METIERS_CONSULTES	2026-09-15 01:16:51.623
563	46	TEST_EFFECTUE	2026-09-15 20:54:59.644
564	46	METIERS_CONSULTES	2026-09-15 20:54:59.644
565	46	METIERS_CONSULTES	2026-09-15 20:55:01.752
566	46	PROFIL_CONSULTE	2026-09-15 20:57:22.824
567	48	TEST_EFFECTUE	2026-09-16 19:04:06.59
568	48	METIERS_CONSULTES	2026-09-16 19:04:06.59
569	48	METIERS_CONSULTES	2026-09-16 19:04:24.081
570	48	PROFIL_CONSULTE	2026-09-16 19:05:01.428
571	48	PROFIL_CONSULTE	2026-09-16 19:06:47.795
572	49	TEST_EFFECTUE	2026-09-16 20:13:50.531
573	49	METIERS_CONSULTES	2026-09-16 20:13:50.531
574	49	METIERS_CONSULTES	2026-09-16 20:14:02.593
575	49	PROFIL_CONSULTE	2026-09-16 20:15:46.717
576	49	TEST_EFFECTUE	2026-09-16 20:22:45.957
577	49	METIERS_CONSULTES	2026-09-16 20:22:45.957
578	49	METIERS_CONSULTES	2026-09-16 20:22:54.932
579	49	METIER_CONSULTE: Technicien Support Informatique	2026-09-16 20:23:33.242
580	49	FORMATION_CONSULTEE	2026-09-16 20:23:34.366
581	49	METIER_CONSULTE: Ingénieur Mines et Géologie	2026-09-16 20:24:21.639
582	49	FORMATION_CONSULTEE	2026-09-16 20:24:22.22
583	49	METIER_CONSULTE: Technicien de Laboratoire Médical	2026-09-16 20:25:15.654
584	49	FORMATION_CONSULTEE	2026-09-16 20:25:16.62
585	49	METIER_CONSULTE: Technicien Support Informatique	2026-09-16 20:25:24.82
586	49	FORMATION_CONSULTEE	2026-09-16 20:25:25.414
587	49	UNIVERSITES_CONSULTEES	2026-09-16 20:25:38.118
588	49	FORMATION_CONSULTEE: Maintenance Informatique	2026-09-16 20:25:38.629
589	49	UNIVERSITES_CONSULTEES	2026-09-16 20:25:39.791
590	49	UNIVERSITES_CONSULTEES	2026-09-16 20:26:05.835
591	49	FORMATION_CONSULTEE: Informatique	2026-09-16 20:26:06.614
592	49	UNIVERSITES_CONSULTEES	2026-09-16 20:26:07.634
593	49	UNIVERSITES_CONSULTEES	2026-09-16 20:26:25.787
594	49	FORMATION_CONSULTEE: Maintenance Informatique	2026-09-16 20:26:26.657
595	49	UNIVERSITES_CONSULTEES	2026-09-16 20:26:27.712
596	49	FORMATION_CONSULTEE: Électrotechnique	2026-09-16 20:30:50.67
597	49	FORMATION_CONSULTEE: Électrotechnique	2026-09-16 20:30:52.606
598	49	FORMATION_CONSULTEE: Électrotechnique	2026-09-16 20:30:57.058
599	49	FORMATION_CONSULTEE: Électrotechnique	2026-09-16 20:30:57.556
600	49	FORMATION_CONSULTEE: Électrotechnique	2026-09-16 20:31:00.226
601	49	FORMATION_CONSULTEE: Électrotechnique	2026-09-16 20:31:00.88
602	49	FORMATION_CONSULTEE: Électrotechnique	2026-09-16 20:31:02.744
603	49	FORMATION_CONSULTEE: Électrotechnique	2026-09-16 20:31:03.027
604	49	UNIVERSITE_CONSULTEE: ESGE	2026-09-16 20:36:36.952
605	49	FORMATION_CONSULTEE: Génie mécanique	2026-09-16 20:43:22.458
606	49	FORMATION_CONSULTEE: Électrotechnique	2026-09-16 20:43:47.213
607	49	UNIVERSITE_CONSULTEE: IPG/ISTI	2026-09-16 20:44:49.204
608	49	FORMATION_CONSULTEE: Génie mécanique	2026-09-16 20:47:15.12
615	26	FORMATION_CONSULTEE: Informatique	2026-09-19 19:53:32.444
616	26	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-19 19:55:07.158
617	26	UNIVERSITE_CONSULTEE:  AFI-UE	2026-09-19 19:55:28.028
633	50	METIER_CONSULTE: Ingénieur Intelligence Artificielle	2026-09-22 22:20:43.369
635	50	UNIVERSITES_CONSULTEES	2026-09-22 22:21:00.99
637	50	UNIVERSITES_CONSULTEES	2026-09-22 22:21:02.75
644	26	UNIVERSITE_CONSULTEE: BEM Dakar	2026-09-22 22:58:12.486
649	50	AVIS_DONNE	2026-09-22 23:30:06.909
654	50	TEST_EFFECTUE	2026-09-22 23:46:35.36
655	50	METIERS_CONSULTES	2026-09-22 23:46:35.36
660	51	TEST_EFFECTUE	2026-09-23 19:36:18.678
661	51	METIERS_CONSULTES	2026-09-23 19:36:18.678
662	51	METIERS_CONSULTES	2026-09-23 19:36:28.385
663	51	PROFIL_CONSULTE	2026-09-23 19:36:58.396
668	54	METIER_CONSULTE: Administrateur public	2026-09-23 20:24:42.821
674	54	FORMATION_CONSULTEE: Économie et Gestion	2026-09-23 20:29:59.003
679	54	TEST_EFFECTUE	2026-09-23 20:44:14.431
680	54	METIERS_CONSULTES	2026-09-23 20:44:14.431
682	54	PROFIL_CONSULTE	2026-09-23 20:44:50.048
690	56	TEST_EFFECTUE	2026-09-23 21:22:39.136
691	56	METIERS_CONSULTES	2026-09-23 21:22:39.136
697	57	FORMATION_CONSULTEE: Mathématiques	2026-09-23 21:34:44.858
699	57	FORMATION_CONSULTEE: Informatique	2026-09-23 21:35:41.991
705	58	FORMATION_CONSULTEE	2026-09-23 22:10:24.102
706	58	UNIVERSITES_CONSULTEES	2026-09-23 22:10:39.472
719	60	UNIVERSITE_CONSULTEE: UAM	2026-09-23 22:58:11.686
739	26	FORMATION_CONSULTEE: Mathématiques-Physique-Informatique (MPI)	2026-09-24 11:02:30.395
746	24	METIER_CONSULTE: Enseignant / Professeur	2026-09-24 13:08:18.901
753	53	METIER_CONSULTE: Community Manager	2026-09-24 19:30:45.732
754	53	FORMATION_CONSULTEE	2026-09-24 19:30:46.269
755	53	UNIVERSITES_CONSULTEES	2026-09-24 19:31:00.749
756	53	FORMATION_CONSULTEE: Sciences de l'Information et de la Communication	2026-09-24 19:31:01.412
757	53	UNIVERSITES_CONSULTEES	2026-09-24 19:31:02.555
758	53	UNIVERSITES_CONSULTEES	2026-09-24 19:31:30.564
759	53	FORMATION_CONSULTEE: Créativité Événementielle	2026-09-24 19:31:34.895
760	53	UNIVERSITES_CONSULTEES	2026-09-24 19:31:36.056
772	26	FORMATION_CONSULTEE: Transport logistique	2026-09-24 22:41:00.463
781	65	METIER_CONSULTE: Agripreneur	2026-09-25 13:32:24.432
782	65	FORMATION_CONSULTEE	2026-09-25 13:32:24.983
783	65	UNIVERSITES_CONSULTEES	2026-09-25 13:32:46.136
784	65	FORMATION_CONSULTEE: Agronomie	2026-09-25 13:32:46.731
785	65	UNIVERSITES_CONSULTEES	2026-09-25 13:32:48.042
786	65	UNIVERSITE_CONSULTEE: EMIA	2026-09-25 13:33:09.476
798	68	FORMATION_CONSULTEE: Droit	2026-09-25 22:31:45.503
806	69	FORMATION_CONSULTEE: Géographie	2026-09-26 12:26:31.415
814	73	TEST_EFFECTUE	2026-09-28 01:12:39.13
815	73	METIERS_CONSULTES	2026-09-28 01:12:39.13
816	73	METIERS_CONSULTES	2026-09-28 01:12:47.461
829	73	FORMATION_CONSULTEE: Biologie	2026-09-28 01:24:38.874
830	73	FORMATION_CONSULTEE: Biologie médicale	2026-09-28 01:25:17.871
832	73	FORMATION_CONSULTEE: Sciences de la Vie et de la Terre	2026-09-28 01:26:00.695
838	71	UNIVERSITE_CONSULTEE: UIDT	2026-09-28 09:35:26.159
844	71	UNIVERSITE_CONSULTEE: EPT	2026-09-28 10:02:53.006
854	74	METIER_CONSULTE: Spécialiste marketing digital	2026-09-28 13:45:53.613
857	74	FORMATION_CONSULTEE: Marketing digital	2026-09-28 13:46:07.559
858	74	UNIVERSITES_CONSULTEES	2026-09-28 13:46:08.437
863	74	FORMATION_CONSULTEE	2026-09-28 13:48:38.786
864	74	UNIVERSITES_CONSULTEES	2026-09-28 13:48:52.813
874	24	METIER_CONSULTE: Actuaire	2026-09-28 16:32:26.085
876	24	METIER_CONSULTE: Actuaire	2026-09-28 16:32:34.509
\.


--
-- Data for Name: metier; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.metier (id_metier, nom, description, presentation, competences, secteur, niveau_etude, salaire_min, salaire_max, profil_riasec, tendance, accessible_test) FROM stdin;
1	Développeur Web	Création de sites et applications web	Le développeur web conçoit, développe et maintient des sites internet et des applications web. Il transforme les besoins des utilisateurs en solutions numériques grâce aux technologies du développement web.	HTML, CSS, JavaScript, PHP, bases de données, frameworks web, logique de programmation, résolution de problèmes	Informatique	Bac+3	300000.00	1500000.00	IRA	Forte croissance	t
2	Data Scientist	Analyse de données et intelligence artificielle	Le data scientist analyse de grandes quantités de données afin d'extraire des informations utiles et aider les organisations à prendre de meilleures décisions. Il utilise les statistiques, la programmation et l'intelligence artificielle.	Python, statistiques, analyse de données, machine learning, intelligence artificielle, bases de données, visualisation de données	Informatique	Bac+5	500000.00	2000000.00	IRC	Très forte croissance	t
3	Ingénieur Génie Civil	Construction de bâtiments et infrastructures	L'ingénieur génie civil conçoit, planifie et supervise la réalisation des infrastructures comme les bâtiments, les routes et les ouvrages publics. Il veille au respect des normes techniques et de sécurité.	Conception technique, calculs de structures, AutoCAD, gestion de projet, résistance des matériaux, analyse des plans, travail en équipe	Génie Civil / BTP	Bac+5	400000.00	1800000.00	RIC	En croissance	f
4	Médecin	Diagnostic et traitement des patients	Le médecin diagnostique, traite et accompagne les patients afin de préserver leur santé. Il utilise ses connaissances scientifiques et médicales pour prévenir et soigner les maladies.	Diagnostic médical, connaissances en sciences de la santé, écoute, communication, analyse clinique, prise de décision, éthique professionnelle	Santé	Bac+7+	600000.00	3000000.00	ISR	Stable	t
5	Avocat	Défense juridique et conseils	L'avocat conseille et représente ses clients dans les affaires juridiques. Il analyse les lois, prépare des dossiers et défend les intérêts des personnes ou des organisations devant les institutions compétentes.	Connaissance du droit, analyse juridique, argumentation, rédaction juridique, communication, négociation, esprit critique	Administration publique, Économie et Sciences sociales	Bac+5	300000.00	2000000.00	ESA	Stable	t
6	Comptable	Gestion des finances et comptabilité	Le comptable assure la gestion des opérations financières d'une organisation. Il enregistre les transactions, prépare les documents comptables et contribue au suivi de la situation financière.	Comptabilité générale, analyse financière, Excel, logiciels comptables, rigueur, organisation, gestion des chiffres	Comptabilité, Fiscalité et Expertise	Bac+3	250000.00	1200000.00	CER	Stable	f
7	Marketeur	Stratégies marketing et communication	Le marketeur étudie les besoins des consommateurs et développe des stratégies pour promouvoir des produits ou services. Il participe à la communication, à la publicité et au développement commercial.	Étude de marché, communication, stratégie marketing, réseaux sociaux, analyse des données, créativité, gestion de projet	Commerce, Marketing et Communication	Bac+3	250000.00	1500000.00	EAS	Forte croissance	f
8	Administrateur Réseau	Gestion des réseaux informatiques	L'administrateur réseau installe, configure et assure la maintenance des réseaux informatiques d'une organisation. Il garantit la disponibilité, la sécurité et la performance des systèmes connectés.	Configuration réseau, TCP/IP, cybersécurité, systèmes Linux et Windows, maintenance informatique, résolution de problèmes, surveillance réseau	Télécommunications et Réseaux	Bac+3	300000.00	1400000.00	IRC	Forte croissance	t
9	Data Analyst	Analyse et interprétation des données pour aider à la prise de décision	Le Data Analyst collecte, nettoie, analyse et interprète les données afin de produire des informations utiles aux organisations. Il utilise les statistiques, les outils informatiques et la visualisation de données pour aider les entreprises, administrations et institutions à prendre de meilleures décisions.	SQL, Excel avancé, Python, R, statistiques, analyse de données, visualisation de données, Power BI, bases de données	Informatique	Bac+3	350000.00	1500000.00	IRC	Très forte croissance	t
10	Ingénieur Logiciel	Conception et développement de solutions logicielles	L’ingénieur logiciel conçoit, développe et maintient des applications informatiques complexes. Il participe à toutes les étapes de création d’un logiciel, depuis l’analyse des besoins jusqu’au déploiement et à l’amélioration des solutions.	Programmation, architecture logicielle, Java, Python, JavaScript, bases de données, conception système, tests logiciels	Informatique	Bac+5	500000.00	2000000.00	IRC	Très forte croissance	t
11	Développeur Mobile	Création d’applications mobiles pour smartphones et tablettes	Le développeur mobile conçoit et développe des applications destinées aux appareils mobiles. Il transforme des idées et besoins utilisateurs en applications performantes adaptées aux systèmes Android et iOS.	Java, Kotlin, Flutter, React Native, développement Android, développement iOS, API, bases de données	Informatique	Bac+3	300000.00	1500000.00	IRA	Forte croissance	f
12	Développeur Backend	Développement de la logique serveur des applications	Le développeur backend crée et maintient la partie serveur des applications web et mobiles. Il développe les API, gère les bases de données et assure le bon fonctionnement des échanges entre les différentes parties d’une application.	PHP, Python, Java, Node.js, API REST, bases de données, sécurité serveur, architecture backend	Informatique	Bac+3	350000.00	1700000.00	IRC	Forte croissance	f
13	Développeur Frontend	Création des interfaces visibles des applications web	Le développeur frontend développe les interfaces avec lesquelles les utilisateurs interagissent. Il transforme les maquettes et besoins graphiques en expériences numériques modernes, rapides et accessibles.	HTML, CSS, JavaScript, React, interfaces utilisateur, responsive design, intégration web	Informatique	Bac+3	300000.00	1500000.00	IAR	Forte croissance	f
14	Expert Cybersécurité	Protection des systèmes informatiques contre les menaces numériques	L’expert cybersécurité analyse les risques, protège les systèmes informatiques et met en place des solutions pour prévenir les attaques numériques. Il intervient auprès des entreprises, banques, administrations et organisations sensibles.	Sécurité informatique, réseaux, Linux, cryptographie, tests d’intrusion, gestion des risques, cybersécurité	Informatique	Bac+5	500000.00	2500000.00	IRC	Très forte croissance	t
15	Administrateur Base de Données	Gestion et sécurisation des bases de données	L’administrateur base de données assure l’installation, la maintenance, l’organisation et la sécurité des bases de données utilisées par les organisations. Il garantit la disponibilité et la fiabilité des informations.	SQL, MySQL, PostgreSQL, administration base de données, sauvegarde, sécurité des données, optimisation	Informatique	Bac+3	350000.00	1800000.00	ICR	Forte croissance	t
129	Responsable Formation	Gestion des programmes de formation	Le responsable formation organise les besoins en compétences, développe les plans de formation et accompagne les organisations dans le développement des talents.	Gestion formation, analyse besoins, gestion projet, ressources humaines, pédagogie	Éducation, Formation et Recherche	Bac+5	400000.00	2500000.00	ESA	Forte croissance	t
16	Ingénieur Cloud et DevOps	Gestion des infrastructures numériques et automatisation des déploiements	L’ingénieur Cloud et DevOps automatise, déploie et supervise les applications sur des infrastructures modernes. Il améliore la fiabilité, la performance et la disponibilité des services numériques.	Cloud computing, Linux, Docker, Kubernetes, CI/CD, AWS, administration système, automatisation	Informatique	Bac+5	500000.00	2500000.00	IRC	Très forte croissance	t
17	UX/UI Designer	Conception d’expériences et interfaces numériques	L’UX/UI Designer conçoit des interfaces numériques simples, accessibles et adaptées aux besoins des utilisateurs. Il travaille sur l’apparence, l’ergonomie et l’expérience globale des applications et plateformes numériques.	Figma, design graphique, expérience utilisateur, prototypage, recherche utilisateur, ergonomie, créativité	Informatique	Bac+3	250000.00	1500000.00	ASI	Forte croissance	t
18	Ingénieur Intelligence Artificielle	Conception de systèmes intelligents utilisant les données et les algorithmes	L’ingénieur en intelligence artificielle conçoit et développe des solutions capables d’analyser des données, d’apprendre automatiquement et d’automatiser certaines tâches. Il travaille sur des domaines comme la reconnaissance d’images, le traitement du langage, les systèmes prédictifs et les applications intelligentes.	Python, machine learning, deep learning, statistiques, mathématiques, intelligence artificielle, TensorFlow, PyTorch, analyse de données	Informatique	Bac+5	600000.00	3000000.00	IRC	Très forte croissance	t
19	Ingénieur Data / Big Data	Gestion et analyse de grandes quantités de données	L’ingénieur Data et Big Data conçoit des infrastructures permettant de collecter, stocker et traiter de grands volumes de données. Il travaille avec les entreprises afin de rendre les données exploitables pour la décision stratégique et l’innovation.	Python, SQL, Big Data, Hadoop, Spark, bases de données, architecture des données, cloud computing, traitement de données	Informatique	Bac+5	500000.00	2500000.00	IRC	Très forte croissance	f
20	Administrateur Systèmes	Gestion et maintenance des systèmes informatiques	L’administrateur systèmes assure l’installation, la configuration et la maintenance des serveurs et systèmes informatiques d’une organisation. Il garantit la disponibilité, la sécurité et le bon fonctionnement des infrastructures techniques.	Linux, Windows Server, administration système, virtualisation, serveurs, sécurité informatique, sauvegarde, supervision	Informatique	Bac+3	300000.00	1800000.00	RIC	Forte croissance	t
21	Ingénieur Systèmes et Réseaux	Conception et supervision des infrastructures informatiques	L’ingénieur systèmes et réseaux conçoit, déploie et supervise les infrastructures réseau et système des organisations. Il assure la performance, la disponibilité et la sécurité des équipements informatiques.	Réseaux, TCP/IP, routage, commutation, Linux, cybersécurité, administration réseau, infrastructure informatique	Informatique	Bac+5	500000.00	2200000.00	RIC	Forte croissance	f
22	Technicien Support Informatique	Assistance technique et maintenance des équipements informatiques	Le technicien support informatique accompagne les utilisateurs dans la résolution de leurs problèmes techniques. Il installe, configure et entretient les équipements informatiques afin d’assurer la continuité des activités.	Maintenance informatique, installation logiciels, dépannage, systèmes Windows, réseaux, assistance utilisateur, diagnostic technique	Informatique	Bac+2	200000.00	800000.00	RCS	Stable	t
23	Analyste Cybersécurité SOC	Surveillance et analyse des menaces informatiques	L’analyste cybersécurité SOC surveille les systèmes informatiques afin de détecter, analyser et répondre aux incidents de sécurité. Il participe à la protection des organisations contre les attaques numériques.	Sécurité informatique, analyse des incidents, SIEM, réseaux, Linux, tests de sécurité, gestion des vulnérabilités, cybersécurité	Informatique	Bac+3	400000.00	2000000.00	IRC	Très forte croissance	f
24	Pharmacien	Préparation, contrôle et dispensation des médicaments	Le pharmacien est un professionnel de santé spécialisé dans les médicaments. Il assure leur préparation, leur contrôle, leur distribution et conseille les patients sur leur utilisation. Il peut travailler en pharmacie, dans les hôpitaux, les laboratoires ou l’industrie pharmaceutique.	Pharmacologie, sciences médicales, gestion des médicaments, conseil patient, biologie, réglementation sanitaire, communication	Santé	Bac+5	400000.00	2500000.00	ICS	Stable	t
25	Infirmier	Soins médicaux et accompagnement des patients	L’infirmier assure les soins aux patients, accompagne leur prise en charge et collabore avec les médecins et les autres professionnels de santé. Il intervient dans les hôpitaux, cliniques, centres de santé et programmes de santé publique.	Soins infirmiers, surveillance médicale, hygiène, communication, premiers secours, accompagnement patient, organisation	Santé	Bac+3	200000.00	1000000.00	SRC	Forte croissance	t
26	Sage-femme	Accompagnement médical des femmes enceintes et suivi des naissances	La sage-femme accompagne les femmes pendant la grossesse, l’accouchement et la période postnatale. Elle joue un rôle essentiel dans la santé maternelle et infantile.	Santé maternelle, suivi grossesse, accouchement, soins du nouveau-né, communication, prévention sanitaire	Santé	Bac+3	250000.00	1200000.00	SRC	Forte croissance	t
27	Dentiste	Diagnostic et traitement des problèmes bucco-dentaires	Le dentiste diagnostique et traite les maladies des dents et de la bouche. Il réalise des soins, prévient les problèmes dentaires et accompagne les patients dans leur santé bucco-dentaire.	Chirurgie dentaire, diagnostic, anatomie, soins dentaires, communication patient, hygiène médicale	Santé	Bac+6	500000.00	3000000.00	IRS	Stable	t
28	Biologiste Médical	Réalisation et interprétation des analyses médicales	Le biologiste médical supervise les analyses réalisées en laboratoire afin d’aider au diagnostic des maladies. Il travaille avec des équipements scientifiques et participe au suivi médical des patients.	Biologie médicale, analyses laboratoire, microbiologie, biochimie, recherche, équipements médicaux, qualité	Santé	Bac+5	400000.00	2000000.00	ICR	Forte croissance	t
29	Technicien de Laboratoire Médical	Analyse d’échantillons biologiques en laboratoire	Le technicien de laboratoire médical réalise des analyses sur des prélèvements biologiques sous la supervision de professionnels spécialisés. Il contribue au diagnostic et au suivi des patients.	Analyses médicales, microbiologie, biologie, équipements laboratoire, prélèvements, procédures qualité	Santé	Bac+2	200000.00	900000.00	RIC	Forte croissance	t
30	Vétérinaire	Prévention et traitement des maladies animales	Le vétérinaire assure la santé des animaux, réalise des diagnostics et accompagne les éleveurs dans la prévention des maladies animales. Il joue également un rôle dans la sécurité alimentaire.	Médecine animale, diagnostic, élevage, chirurgie animale, santé publique, biologie, communication	Santé	Bac+6	400000.00	2000000.00	IRS	En croissance	t
31	Psychologue	Accompagnement psychologique et analyse du comportement humain	Le psychologue accompagne les personnes rencontrant des difficultés émotionnelles, sociales ou psychologiques. Il utilise des méthodes d’écoute et d’analyse afin d’aider les patients à améliorer leur bien-être.	Psychologie, écoute, communication, analyse comportementale, accompagnement, entretien clinique	Santé	Bac+5	250000.00	1500000.00	SIA	Forte croissance	t
32	Nutritionniste / Diététicien	Conseil alimentaire et accompagnement nutritionnel	Le nutritionniste accompagne les personnes dans l’amélioration de leur alimentation et leur santé. Il intervient dans la prévention des maladies liées à la nutrition et dans l’éducation alimentaire.	Nutrition, alimentation, santé publique, conseil, analyse alimentaire, prévention, communication	Santé	Bac+3	250000.00	1500000.00	SIC	En croissance	t
33	Kinésithérapeute	Rééducation physique et récupération fonctionnelle des patients	Le kinésithérapeute accompagne les patients dans leur récupération après une blessure, une maladie ou une intervention médicale. Il utilise des techniques de rééducation afin d’améliorer la mobilité et l’autonomie des personnes.	Rééducation, anatomie, physiothérapie, exercices thérapeutiques, accompagnement patient, techniques manuelles	Santé	Bac+3	300000.00	1500000.00	SRI	Forte croissance	t
34	Ingénieur Biomédical	Conception, maintenance et gestion des équipements médicaux	L’ingénieur biomédical assure le développement, l’installation, la maintenance et l’amélioration des équipements utilisés dans les établissements de santé. Il travaille à l’interface entre les technologies de l’ingénierie et les besoins médicaux afin d’améliorer la qualité des soins.	Ingénierie biomédicale, électronique, maintenance médicale, équipements hospitaliers, informatique médicale, gestion de projet, analyse technique	Santé	Bac+5	500000.00	2500000.00	IRC	Très forte croissance	t
35	Épidémiologiste	Analyse et surveillance des maladies dans les populations	L’épidémiologiste étudie la fréquence, les causes et la propagation des maladies afin d’aider à mettre en place des stratégies de prévention et de contrôle sanitaire. Il intervient dans les programmes de santé publique, les organismes de recherche et les institutions sanitaires.	Statistiques, analyse de données, santé publique, recherche, méthodologie scientifique, prévention des maladies, collecte de données	Santé	Bac+5	400000.00	2000000.00	ICS	Forte croissance	f
36	Chercheur en Sciences de la Santé	Recherche scientifique dans le domaine médical et biologique	Le chercheur en sciences de la santé réalise des travaux scientifiques afin de mieux comprendre les maladies, développer de nouveaux traitements et améliorer les connaissances médicales. Il peut travailler dans les universités, laboratoires et instituts de recherche.	Recherche scientifique, biologie, méthodologie expérimentale, analyse scientifique, rédaction scientifique, statistiques, innovation	Santé	Bac+5/Doctorat	400000.00	2000000.00	ICA	En croissance	f
37	Manipulateur en Imagerie Médicale	Réalisation d’examens médicaux utilisant des équipements d’imagerie	Le manipulateur en imagerie médicale réalise des examens comme les radiographies, scanners ou autres techniques d’imagerie sous la responsabilité des médecins spécialistes. Il prépare les patients et veille à la qualité des images obtenues.	Radiologie, imagerie médicale, scanner, radiographie, équipements médicaux, anatomie, relation patient	Santé	Bac+3	300000.00	1500000.00	RIS	Forte croissance	t
38	Assistant Médical	Accompagnement des professionnels de santé dans la prise en charge des patients	L’assistant médical participe à l’organisation des consultations, accompagne les patients et aide les professionnels de santé dans certaines tâches administratives et médicales. Il contribue au bon fonctionnement des structures de soins.	Accueil patient, organisation médicale, assistance aux soins, dossiers médicaux, communication, hygiène médicale	Santé	Bac+2/Bac+3	200000.00	900000.00	SCR	Forte croissance	t
39	Technicien en Pharmacie	Gestion et préparation des produits pharmaceutiques	Le technicien en pharmacie participe à la préparation, au stockage et à la gestion des produits pharmaceutiques. Il travaille sous la responsabilité des pharmaciens dans les pharmacies, hôpitaux ou structures de distribution.	Produits pharmaceutiques, gestion stock, préparation médicaments, réglementation, conseil patient, organisation	Santé	Bac+2/Bac+3	200000.00	900000.00	CSR	Stable	t
40	Spécialiste Santé Publique	Gestion et amélioration des programmes de santé des populations	Le spécialiste en santé publique conçoit, coordonne et évalue des programmes visant à améliorer la santé des populations. Il intervient dans les ministères, ONG, organisations internationales et projets sanitaires.	Santé publique, gestion de projet, statistiques, prévention, politiques sanitaires, analyse de données, communication	Santé	Bac+5	400000.00	2500000.00	SIC	Forte croissance	f
41	Architecte	Conception et réalisation de projets architecturaux	L’architecte imagine, conçoit et supervise la réalisation de bâtiments et d’espaces. Il transforme les besoins des clients en projets adaptés aux contraintes techniques, esthétiques et environnementales.	Conception architecturale, dessin technique, AutoCAD, modélisation 3D, créativité, réglementation bâtiment, gestion de projet	Génie Civil / BTP	Bac+5	400000.00	2500000.00	AIR	Forte croissance	t
42	Conducteur de Travaux	Organisation et supervision des chantiers de construction	Le conducteur de travaux coordonne les différentes étapes d’un chantier. Il assure le suivi des équipes, des délais, des matériaux et de la qualité des travaux réalisés.	Gestion chantier, management équipe, planification, suivi travaux, sécurité, contrôle qualité, lecture de plans	Génie Civil / BTP	Bac+3/Bac+5	350000.00	2000000.00	RCE	Très forte croissance	t
43	Ingénieur Structures	Conception et analyse des structures des bâtiments et ouvrages	L’ingénieur structures étudie la résistance et la stabilité des constructions. Il réalise des calculs techniques afin de garantir la sécurité et la durabilité des ouvrages.	Calcul structures, résistance des matériaux, béton armé, modélisation, logiciels techniques, analyse plans, normes construction	Génie Civil / BTP	Bac+5	500000.00	2500000.00	IRC	Forte croissance	f
44	Ingénieur Hydraulique	Conception des systèmes liés à l’eau et aux infrastructures hydrauliques	L’ingénieur hydraulique travaille sur les projets liés à l’eau, l’assainissement et les ouvrages hydrauliques. Il participe à la gestion durable des ressources en eau.	Hydraulique, assainissement, gestion eau, calculs hydrauliques, études techniques, logiciels spécialisés	Génie Civil / BTP	Bac+5	500000.00	2500000.00	IRC	Très forte croissance	f
45	Géomètre-Topographe	Mesure et étude des terrains pour les projets de construction	Le géomètre-topographe réalise des mesures précises des terrains afin de préparer les projets de construction, d’aménagement et d’infrastructures.	Topographie, cartographie, GPS, AutoCAD, relevés terrain, mesures, analyse spatiale	Génie Civil / BTP	Bac+2/Bac+3	250000.00	1200000.00	RIC	Forte croissance	t
46	Technicien Génie Civil	Suivi technique et contrôle des travaux de construction	Le technicien génie civil participe à la réalisation et au suivi des projets de construction. Il aide à la préparation des plans, au contrôle des matériaux et au suivi des chantiers.	Lecture plans, contrôle travaux, matériaux construction, dessin technique, suivi chantier, sécurité	Génie Civil / BTP	Bac+2/Bac+3	200000.00	1000000.00	RCI	Forte croissance	t
47	Dessinateur-Projeteur BTP	Réalisation de plans techniques pour les projets de construction	Le dessinateur-projeteur réalise les plans et représentations techniques nécessaires aux projets de bâtiment et de travaux publics à l’aide de logiciels spécialisés.	AutoCAD, DAO, modélisation 3D, dessin technique, plans bâtiment, logiciels conception	Génie Civil / BTP	Bac+2/Bac+3	250000.00	1200000.00	ARC	Forte croissance	t
48	Urbaniste	Aménagement et organisation des espaces urbains	L’urbaniste analyse et participe à la planification des villes et territoires. Il contribue à créer des espaces adaptés aux besoins des populations et au développement durable.	Aménagement urbain, analyse territoire, cartographie, urbanisme, développement durable, gestion projet	Génie Civil / BTP	Bac+5	400000.00	2000000.00	IAS	En croissance	t
49	Ingénieur Environnement et Construction Durable	Développement de solutions de construction respectueuses de l’environnement	L’ingénieur environnement spécialisé en construction durable accompagne les projets afin de réduire leur impact environnemental et améliorer leur efficacité énergétique.	Environnement, construction durable, efficacité énergétique, gestion déchets, normes environnementales, analyse risques	Génie Civil / BTP	Bac+5	400000.00	2000000.00	IRA	Très forte croissance	t
50	Ingénieur Routes et Transports	Conception et gestion des infrastructures routières et de transport	L’ingénieur routes et transports participe aux études, à la conception et au suivi des infrastructures routières et des systèmes de transport. Il contribue au développement des réseaux de mobilité.	Routes, infrastructures transport, matériaux, études techniques, gestion projet, calculs, normes routières	Génie Civil / BTP	Bac+5	400000.00	2000000.00	RIC	Très forte croissance	t
66	Chef de Chantier BTP	Gestion opérationnelle des équipes et du suivi des travaux sur les chantiers	Le chef de chantier organise les activités quotidiennes d’un chantier de construction. Il coordonne les équipes, contrôle l’avancement des travaux et veille au respect des règles de sécurité et de qualité.	Organisation chantier, management équipe, lecture plans, suivi travaux, sécurité, contrôle qualité	Génie Civil / BTP	Bac+2/Bac+3	250000.00	1200000.00	RCE	Très forte croissance	f
67	Ingénieur Géotechnicien	Analyse des sols et étude des fondations des ouvrages	L’ingénieur géotechnicien étudie les caractéristiques des sols afin de garantir la stabilité des bâtiments, routes et infrastructures. Il intervient dans les études avant la construction des ouvrages.	Mécanique des sols, géologie, fondations, études terrain, calculs, analyse risques	Génie Civil / BTP	Bac+5	450000.00	2200000.00	IRC	Forte croissance	f
68	Métreur / Économiste de la Construction	Estimation des coûts et gestion économique des projets de construction	Le métreur ou économiste de la construction évalue les quantités de matériaux, prépare les devis et participe à la maîtrise des coûts des projets BTP.	Métré, devis, estimation coûts, Excel, calcul quantités, analyse budget, appels offres	Génie Civil / BTP	Bac+2/Bac+3	250000.00	1500000.00	CRE	Forte croissance	t
69	Électricien Bâtiment	Installation et maintenance des équipements électriques des bâtiments	L’électricien bâtiment réalise les installations électriques dans les logements, bâtiments professionnels et infrastructures. Il assure le câblage, le dépannage et la conformité des installations.	Électricité bâtiment, câblage, maintenance électrique, lecture schémas, sécurité électrique	Génie Civil / BTP	CAP/BT/Bac+2	200000.00	1000000.00	RCE	Forte croissance	t
70	Ingénieur Électrique / Énergétique	Conception et gestion des systèmes électriques et énergétiques	L’ingénieur électrique ou énergétique conçoit et supervise des systèmes liés à l’électricité, aux énergies renouvelables et aux infrastructures énergétiques modernes.	Électricité, énergie solaire, réseaux électriques, efficacité énergétique, maintenance, études techniques	Génie Civil / BTP	Bac+5	400000.00	2500000.00	IRC	Très forte croissance	f
71	Géomaticien BTP	Analyse des données géographiques pour les projets de construction et d’aménagement	Le géomaticien BTP utilise les systèmes d’information géographique et les données spatiales pour accompagner les projets de construction, d’aménagement urbain et d’infrastructures.	SIG, QGIS, ArcGIS, cartographie, GPS, télédétection, analyse spatiale, bases données géographiques	Génie Civil / BTP	Bac+3/Bac+5	300000.00	1800000.00	IRC	Forte croissance	t
72	Logisticien	Organisation et optimisation des flux de marchandises et des opérations logistiques	Le logisticien organise le transport, le stockage et la distribution des marchandises. Il veille à la bonne circulation des produits entre les fournisseurs, les entreprises et les clients.	Gestion des flux, organisation transport, gestion stocks, planification, outils logistiques, analyse problèmes	Transport, Logistique, Commerce International et Supply Chain	Bac+2/Bac+3	250000.00	1500000.00	CRE	Très forte croissance	t
73	Responsable Logistique	Supervision des activités logistiques d’une organisation	Le responsable logistique planifie et coordonne les opérations de transport, stockage et distribution afin d’améliorer les délais, les coûts et la qualité du service.	Management équipe, gestion transport, optimisation flux, gestion stocks, analyse performance, planification	Transport, Logistique, Commerce International et Supply Chain	Bac+3/Bac+5	400000.00	2500000.00	ECR	Très forte croissance	f
74	Supply Chain Manager	Gestion stratégique de la chaîne d’approvisionnement	Le supply chain manager pilote l’ensemble de la chaîne logistique, depuis l’approvisionnement jusqu’à la livraison finale, afin d’optimiser la performance des entreprises.	Supply chain, analyse données, achats, gestion fournisseurs, stratégie logistique, optimisation coûts	Transport, Logistique, Commerce International et Supply Chain	Bac+5	600000.00	3000000.00	ECI	Très forte croissance	f
75	Responsable Import-Export	Gestion des opérations commerciales internationales	Le responsable import-export organise les échanges internationaux de marchandises. Il assure le suivi des fournisseurs étrangers, des documents commerciaux et des procédures d’expédition.	Commerce international, négociation, réglementation douanière, gestion fournisseurs, langues étrangères, documentation	Transport, Logistique, Commerce International et Supply Chain	Bac+3/Bac+5	400000.00	2500000.00	ECR	Forte croissance	t
76	Agent Transit / Déclarant en Douane	Gestion des procédures douanières et du passage des marchandises	L’agent transit accompagne les entreprises dans les formalités douanières, l’importation et l’exportation des marchandises.	Procédures douanières, réglementation, documents import-export, suivi marchandises, communication	Transport, Logistique, Commerce International et Supply Chain	Bac+2/Bac+3	250000.00	1500000.00	CER	Forte croissance	t
77	Gestionnaire Transport	Organisation des opérations de transport de marchandises	Le gestionnaire transport planifie les déplacements des marchandises, optimise les itinéraires et assure le suivi des opérations de livraison.	Planification transport, gestion véhicules, suivi livraison, organisation, outils logistiques	Transport, Logistique, Commerce International et Supply Chain	Bac+2/Bac+3	250000.00	1500000.00	RCE	En croissance	f
78	Responsable Approvisionnement	Gestion des achats et de la disponibilité des ressources	Le responsable approvisionnement sélectionne les fournisseurs, suit les commandes et garantit la disponibilité des produits nécessaires aux activités de l’entreprise.	Achats, négociation fournisseurs, gestion commandes, analyse besoins, gestion stocks	Transport, Logistique, Commerce International et Supply Chain	Bac+3/Bac+5	350000.00	2000000.00	ECR	Forte croissance	f
79	Gestionnaire des Stocks	Contrôle et organisation des stocks d’une entreprise	Le gestionnaire des stocks assure le suivi des entrées et sorties de marchandises afin d’éviter les ruptures et les pertes.	Gestion stocks, inventaire, logiciels gestion, organisation, contrôle qualité	Transport, Logistique, Commerce International et Supply Chain	Bac+2/Bac+3	200000.00	1200000.00	CER	Stable	t
80	Responsable Transport et Distribution	Supervision des activités de transport et de distribution	Le responsable transport et distribution organise les réseaux de livraison et supervise les opérations permettant d’acheminer les produits vers les clients.	Distribution, management, transport, analyse performance, organisation réseau	Transport, Logistique, Commerce International et Supply Chain	Bac+3/Bac+5	400000.00	2000000.00	ECR	Forte croissance	f
81	Analyste Supply Chain	Analyse des données pour améliorer les performances logistiques	L’analyste supply chain utilise les données pour optimiser les coûts, les délais et les processus de la chaîne d’approvisionnement.	Analyse données, Excel, statistiques, tableaux de bord, supply chain, optimisation	Transport, Logistique, Commerce International et Supply Chain	Bac+5	500000.00	2500000.00	IRC	Très forte croissance	t
83	Ingénieur Pétrole et Gaz	Gestion des activités liées aux ressources pétrolières et gazières	L’ingénieur pétrole et gaz participe à l’exploration, l’exploitation et l’optimisation des ressources pétrolières et gazières. Il travaille sur les installations, les procédés et la sécurité des opérations.	Génie pétrolier, géologie, exploitation, forage, analyse technique, sécurité industrielle	Énergie, Mines et Industrie	Bac+5	700000.00	4000000.00	IRC	Très forte croissance	t
84	Ingénieur Mines et Géologie	Analyse et exploitation des ressources minières	L’ingénieur mines et géologie étudie les ressources du sous-sol et participe aux opérations d’extraction, d’exploitation et de gestion des sites miniers.	Géologie, exploitation minière, cartographie, analyse terrain, gestion projet, environnement	Énergie, Mines et Industrie	Bac+5	500000.00	3000000.00	RIC	Forte croissance	t
85	Ingénieur Industriel	Optimisation des processus industriels	L’ingénieur industriel améliore les méthodes de production, l’organisation des entreprises industrielles et la performance des systèmes de fabrication.	Gestion production, optimisation processus, qualité, analyse industrielle, gestion projet, amélioration continue	Énergie, Mines et Industrie	Bac+5	500000.00	2500000.00	IRC	Forte croissance	t
86	Ingénieur Maintenance Industrielle	Maintenance et amélioration des équipements industriels	L’ingénieur maintenance industrielle assure la disponibilité et la performance des machines et équipements utilisés dans les industries.	Mécanique industrielle, maintenance préventive, diagnostic équipements, gestion maintenance, fiabilité	Énergie, Mines et Industrie	Bac+5	500000.00	2500000.00	RIC	Très forte croissance	f
87	Technicien Maintenance Industrielle	Entretien et réparation des équipements industriels	Le technicien maintenance industrielle intervient sur les machines et installations afin d’assurer leur fonctionnement et limiter les arrêts de production.	Électromécanique, maintenance, diagnostic panne, mécanique, électricité industrielle, sécurité	Énergie, Mines et Industrie	Bac+2/Bac+3	250000.00	1500000.00	RCE	Forte croissance	t
88	Ingénieur Automatisme Industriel	Conception et gestion des systèmes automatisés	L’ingénieur automatisme industriel développe et supervise les systèmes permettant d’automatiser les machines et les processus industriels.	Automatisme, programmation industrielle, systèmes embarqués, robotique, instrumentation, contrôle industriel	Énergie, Mines et Industrie	Bac+5	500000.00	3000000.00	IRC	Très forte croissance	t
89	Ingénieur HSE (Hygiène Sécurité Environnement)	Gestion de la sécurité et de l’environnement dans les organisations	L’ingénieur HSE met en place les politiques de prévention des risques, de sécurité au travail et de protection de l’environnement dans les secteurs industriels.	Sécurité industrielle, réglementation HSE, gestion risques, environnement, audit, prévention	Énergie, Mines et Industrie	Bac+3/Bac+5	400000.00	2500000.00	CSI	Forte croissance	t
90	Responsable Production Industrielle	Gestion des opérations de production industrielle	Le responsable production industrielle organise et supervise les activités de fabrication afin d’atteindre les objectifs de qualité, coût et délai.	Management équipe, gestion production, planification, qualité, organisation industrielle	Énergie, Mines et Industrie	Bac+3/Bac+5	400000.00	2500000.00	ECR	Forte croissance	t
91	Technicien Électromécanique Industrielle	Installation et maintenance des systèmes électromécaniques	Le technicien électromécanique industrielle installe, entretient et répare les équipements combinant électricité et mécanique dans les entreprises industrielles.	Électromécanique, moteurs, machines industrielles, électricité, maintenance, lecture plans techniques	Énergie, Mines et Industrie	Bac+2/Bac+3	250000.00	1500000.00	RCI	Forte croissance	f
92	Ingénieur Agronome	Amélioration des systèmes de production agricole	L’ingénieur agronome accompagne la modernisation de l’agriculture en développant des techniques permettant d’améliorer les rendements, la qualité des productions et la gestion durable des ressources agricoles.	Agronomie, production végétale, gestion cultures, techniques agricoles, analyse sols, développement rural	Agriculture, Agroalimentaire et Environnement	Bac+5	400000.00	2000000.00	RIC	Forte croissance	t
110	Expert Finance Digitale et Fintech	Développement des solutions financières numériques	L’expert en finance digitale participe à la création et à l’amélioration des services financiers numériques comme les paiements mobiles et les plateformes financières.	Fintech, finance numérique, analyse données, technologies financières, innovation, gestion projet	Banque, Finance, Assurance et Gestion	Bac+5	500000.00	3000000.00	IRC	Très forte croissance	t
93	Ingénieur Agroalimentaire	Transformation et valorisation des produits agricoles	L’ingénieur agroalimentaire conçoit et améliore les procédés de transformation des produits agricoles afin de garantir la qualité, la sécurité alimentaire et l’efficacité des industries alimentaires.	Génie alimentaire, transformation aliments, qualité, sécurité alimentaire, procédés industriels, innovation	Agriculture, Agroalimentaire et Environnement	Bac+5	400000.00	2500000.00	IRC	Très forte croissance	t
94	Technicien Agricole	Accompagnement technique des exploitations agricoles	Le technicien agricole conseille les producteurs, suit les cultures et participe à l’application des techniques modernes de production agricole.	Techniques agricoles, suivi cultures, conseil agricole, irrigation, fertilisation, terrain	Agriculture, Agroalimentaire et Environnement	Bac+2/Bac+3	200000.00	1000000.00	RSC	Forte croissance	t
95	Responsable Production Agricole	Gestion des activités de production agricole	Le responsable production agricole organise les opérations d’une exploitation, supervise les équipes et optimise l’utilisation des ressources pour améliorer la production.	Gestion exploitation, management équipe, planification, production agricole, organisation	Agriculture, Agroalimentaire et Environnement	Bac+3/Bac+5	300000.00	1800000.00	REC	Forte croissance	t
96	Ingénieur Environnement	Gestion et protection des ressources environnementales	L’ingénieur environnement analyse les impacts des activités humaines et développe des solutions pour protéger les ressources naturelles et favoriser un développement durable.	Gestion environnementale, analyse risques, traitement déchets, développement durable, réglementation	Agriculture, Agroalimentaire et Environnement	Bac+5	400000.00	2500000.00	IRC	Très forte croissance	f
97	Spécialiste Développement Durable	Conception de projets liés au développement durable	Le spécialiste en développement durable accompagne les organisations dans la mise en place de stratégies responsables liées à l’environnement, aux ressources et aux impacts sociaux.	Développement durable, environnement, gestion projets, analyse impacts, responsabilité sociale	Agriculture, Agroalimentaire et Environnement	Bac+5	400000.00	2000000.00	SIA	Forte croissance	f
98	Contrôleur Qualité Agroalimentaire	Contrôle de la qualité des produits alimentaires	Le contrôleur qualité agroalimentaire vérifie la conformité des produits alimentaires aux normes sanitaires et participe à l’amélioration des processus de production.	Contrôle qualité, normes alimentaires, hygiène, sécurité alimentaire, analyse laboratoire	Agriculture, Agroalimentaire et Environnement	Bac+3/Bac+5	300000.00	1800000.00	CIR	Très forte croissance	t
99	Ingénieur Élevage et Productions Animales	Amélioration des systèmes d’élevage	L’ingénieur élevage travaille à l’amélioration des productions animales, à la gestion des élevages et au développement de solutions adaptées aux besoins agricoles.	Zootechnie, élevage, santé animale, production animale, gestion exploitation	Agriculture, Agroalimentaire et Environnement	Bac+5	350000.00	2000000.00	RIC	En croissance	t
100	Technicien Agroalimentaire	Participation aux opérations de transformation alimentaire	Le technicien agroalimentaire intervient dans les unités de transformation, assure le suivi des procédés et participe au contrôle des produits alimentaires.	Transformation alimentaire, contrôle production, hygiène, procédés industriels, qualité	Agriculture, Agroalimentaire et Environnement	Bac+2/Bac+3	250000.00	1200000.00	RCI	Forte croissance	t
101	Agripreneur	Création et gestion de projets agricoles innovants	L’agripreneur développe des activités agricoles, de transformation ou de commercialisation en utilisant des méthodes modernes pour créer de la valeur dans le secteur agricole.	Entrepreneuriat, gestion projet, agriculture moderne, commercialisation, innovation	Agriculture, Agroalimentaire et Environnement	Bac+2/Bac+5	200000.00	3000000.00	ECR	Très forte croissance	t
102	Analyste Financier	Analyse des données financières et aide à la décision	L’analyste financier étudie la situation financière des entreprises et des organisations afin de produire des analyses utiles à la prise de décision et à l’évaluation des performances.	Analyse financière, Excel, modélisation financière, statistiques, comptabilité, analyse données	Banque, Finance, Assurance et Gestion	Bac+3/Bac+5	400000.00	2500000.00	IRC	Forte croissance	t
103	Contrôleur de Gestion	Suivi des performances et contrôle budgétaire	Le contrôleur de gestion accompagne les entreprises dans le suivi des budgets, l’analyse des écarts et l’amélioration de la performance financière.	Gestion budgétaire, comptabilité analytique, Excel, analyse coûts, reporting, gestion performance	Banque, Finance, Assurance et Gestion	Bac+5	400000.00	2500000.00	CER	Forte croissance	t
104	Auditeur Financier	Contrôle et vérification des informations financières	L’auditeur financier examine les comptes et les procédures des organisations afin de garantir leur fiabilité et leur conformité aux normes.	Audit, comptabilité, contrôle interne, analyse financière, normes comptables, rigueur	Banque, Finance, Assurance et Gestion	Bac+5	400000.00	3000000.00	CIR	Forte croissance	t
105	Gestionnaire de Banque	Gestion des opérations et services bancaires	Le gestionnaire de banque assure le suivi des opérations bancaires, accompagne les clients et participe au développement des services financiers.	Produits bancaires, gestion clientèle, finance, analyse dossiers, communication, organisation	Banque, Finance, Assurance et Gestion	Bac+3/Bac+5	300000.00	1800000.00	CER	En croissance	t
106	Chargé de Clientèle Banque	Accompagnement et conseil des clients bancaires	Le chargé de clientèle banque conseille les particuliers et entreprises, propose des solutions financières et développe la relation client.	Relation client, finance, communication, négociation, analyse besoins, produits bancaires	Banque, Finance, Assurance et Gestion	Bac+3	250000.00	1500000.00	ESC	Forte croissance	t
107	Actuaire	Analyse des risques financiers et assurantiels	L’actuaire utilise les mathématiques et les statistiques pour évaluer les risques, prévoir les événements financiers et construire des solutions d’assurance.	Statistiques, probabilités, mathématiques financières, modélisation risques, analyse données	Banque, Finance, Assurance et Gestion	Bac+5	500000.00	3000000.00	IRC	Très forte croissance	f
108	Analyste Crédit	Évaluation des demandes de financement	L’analyste crédit étudie les dossiers de financement afin d’évaluer les risques et la capacité de remboursement des clients ou entreprises.	Analyse crédit, finance, gestion risques, analyse financière, économie, dossiers clients	Banque, Finance, Assurance et Gestion	Bac+3/Bac+5	300000.00	2000000.00	ICR	Forte croissance	t
109	Gestionnaire Assurance	Gestion des contrats et opérations d’assurance	Le gestionnaire assurance assure le suivi des contrats, traite les dossiers clients et participe à la gestion des risques assurantiels.	Assurance, gestion contrats, relation client, analyse risques, réglementation, organisation	Banque, Finance, Assurance et Gestion	Bac+3	250000.00	1800000.00	CER	En croissance	t
111	Trésorier d’Entreprise	Gestion des flux financiers d’une organisation	Le trésorier d’entreprise assure la gestion de la trésorerie, le suivi des flux financiers et l’optimisation des ressources financières.	Gestion trésorerie, finance, analyse flux, Excel, prévisions financières, gestion risques	Banque, Finance, Assurance et Gestion	Bac+3/Bac+5	350000.00	2200000.00	CER	Forte croissance	f
112	Juriste d’entreprise	Conseil juridique auprès des entreprises et organisations	Le juriste d’entreprise accompagne les organisations dans leurs activités juridiques. Il analyse les contrats, veille au respect des lois et conseille les dirigeants sur les aspects réglementaires.	Droit des affaires, analyse juridique, rédaction contrats, veille réglementaire, négociation	Administration publique, Économie et Sciences sociales	Bac+5	300000.00	2000000.00	ESA	Forte croissance	t
113	Magistrat	Application du droit et administration de la justice	Le magistrat représente l’autorité judiciaire et participe au jugement des affaires conformément aux lois et aux principes de justice.	Droit, analyse juridique, raisonnement, décision, éthique professionnelle	Administration publique, Économie et Sciences sociales	Bac+5/+6	500000.00	3000000.00	ESA	Stable	t
114	Administrateur public	Gestion des services et politiques publiques	L’administrateur public participe à la gestion des institutions publiques, à l’organisation des services de l’État et à la mise en œuvre des politiques publiques.	Administration publique, gestion projet, droit public, organisation, management	Administration publique, Économie et Sciences sociales	Bac+5	400000.00	2500000.00	ECR	Stable	t
115	Inspecteur des finances publiques	Contrôle et gestion des ressources publiques	L’inspecteur des finances publiques contrôle l’utilisation des ressources publiques et participe à la bonne gestion financière des administrations.	Finance publique, contrôle, fiscalité, audit, analyse financière, réglementation	Administration publique, Économie et Sciences sociales	Bac+5	400000.00	2500000.00	CER	Stable	t
116	Chargé de projet développement	Conception et suivi des projets de développement	Le chargé de projet développement accompagne les programmes économiques et sociaux menés par les institutions publiques, ONG et organismes internationaux.	Gestion projet, développement local, suivi-évaluation, analyse besoins, coordination	Administration publique, Économie et Sciences sociales	Bac+3/Bac+5	300000.00	2000000.00	EAS	Forte croissance	t
117	Spécialiste Passation des Marchés Publics	Gestion des procédures d’achat public	Le spécialiste en passation des marchés publics prépare et suit les procédures d’acquisition des institutions publiques et organisations.	Droit public, marchés publics, réglementation, gestion contrats, analyse dossiers	Administration publique, Économie et Sciences sociales	Bac+3/Bac+5	300000.00	2000000.00	CER	Forte croissance	t
118	Économiste	Analyse des phénomènes économiques et aide à la décision	L’économiste étudie les mécanismes économiques, analyse les données et produit des recommandations utiles aux entreprises, institutions publiques et organismes de développement.	Microéconomie, macroéconomie, statistiques, économétrie, analyse données, recherche	Administration publique, Économie et Sciences sociales	Bac+5	400000.00	2500000.00	IRC	Forte croissance	t
119	Sociologue	Analyse des comportements et phénomènes sociaux	Le sociologue étudie les sociétés, les comportements humains et les dynamiques sociales afin d’aider à comprendre et résoudre des problématiques collectives.	Recherche sociale, enquêtes, analyse données, sociologie, communication, études terrain	Administration publique, Économie et Sciences sociales	Bac+5	250000.00	1500000.00	SIA	Stable	t
120	Analyste des politiques publiques	Évaluation et amélioration des politiques publiques	L’analyste des politiques publiques étudie les programmes publics, mesure leurs impacts et propose des améliorations pour les décideurs.	Analyse politiques publiques, statistiques, économie, recherche, évaluation programmes	Administration publique, Économie et Sciences sociales	Bac+5	400000.00	2500000.00	ISA	En croissance	t
121	Gestionnaire de projet humanitaire	Organisation de programmes humanitaires et sociaux	Le gestionnaire de projet humanitaire coordonne les actions d’aide et de développement menées par les ONG et organisations internationales.	Gestion projet, développement international, coordination, communication, suivi-évaluation	Administration publique, Économie et Sciences sociales	Bac+3/Bac+5	300000.00	2000000.00	ESA	Forte croissance	t
122	Enseignant / Professeur	Transmission des connaissances et accompagnement des apprenants	L’enseignant ou professeur transmet des connaissances, développe les compétences des élèves et participe à leur formation académique et professionnelle.	Pédagogie, communication, gestion classe, préparation cours, évaluation, discipline enseignée	Éducation, Formation et Recherche	Bac+3/Bac+5	250000.00	1500000.00	SIA	Stable	t
123	Enseignant-chercheur	Enseignement supérieur et recherche scientifique	L’enseignant-chercheur exerce dans les universités et centres de recherche. Il combine l’enseignement, la production scientifique et l’encadrement des étudiants.	Recherche scientifique, enseignement supérieur, publication, analyse, encadrement, innovation	Éducation, Formation et Recherche	Bac+8	500000.00	3000000.00	ICA	En croissance	t
124	Formateur professionnel	Formation des professionnels et développement des compétences	Le formateur professionnel accompagne les jeunes et les adultes dans l’acquisition de compétences techniques et professionnelles.	Animation formation, pédagogie, communication, accompagnement, conception supports	Éducation, Formation et Recherche	Bac+3/Bac+5	250000.00	1800000.00	SIA	Forte croissance	t
125	Ingénieur pédagogique	Conception et amélioration des systèmes de formation	L’ingénieur pédagogique conçoit des méthodes d’apprentissage innovantes, notamment dans les formations numériques et l’enseignement à distance.	Ingénierie pédagogique, e-learning, outils numériques, conception cours, analyse besoins	Éducation, Formation et Recherche	Bac+5	400000.00	2500000.00	ISA	Très forte croissance	t
126	Concepteur pédagogique numérique	Création de contenus éducatifs numériques	Le concepteur pédagogique numérique développe des ressources d’apprentissage adaptées aux plateformes digitales et aux nouvelles méthodes éducatives.	E-learning, création contenus, technologies éducatives, pédagogie, multimédia	Éducation, Formation et Recherche	Bac+3/Bac+5	300000.00	2000000.00	ASI	Très forte croissance	t
127	Chercheur scientifique	Production de connaissances et innovation scientifique	Le chercheur scientifique mène des travaux de recherche dans différents domaines afin de produire de nouvelles connaissances et solutions.	Méthodologie recherche, analyse données, expérimentation, rédaction scientifique, innovation	Éducation, Formation et Recherche	Bac+5/Bac+8	350000.00	2500000.00	ICA	En croissance	t
128	Conseiller d’orientation scolaire et professionnelle	Accompagnement des choix d’études et de carrière	Le conseiller d’orientation aide les élèves et étudiants à mieux comprendre leurs profils, leurs compétences et les possibilités de formation et de métiers.	Orientation, psychologie, accompagnement, analyse profils, communication, conseil	Éducation, Formation et Recherche	Bac+5	300000.00	2000000.00	SIA	Très forte croissance	t
130	Statisticien chercheur / Chargé d’études	Analyse de données pour la recherche et les études	Le statisticien chercheur exploite les données pour produire des analyses utiles aux institutions, chercheurs et organisations.	Statistiques, analyse données, enquêtes, méthodologie, logiciels statistiques, recherche	Éducation, Formation et Recherche	Bac+5	400000.00	2500000.00	IRC	Très forte croissance	t
131	Chargé de communication	Gestion de la communication interne et externe des organisations	Le chargé de communication élabore les stratégies de communication, crée des contenus et assure la diffusion des informations auprès des différents publics.	Communication, rédaction, stratégie communication, gestion réseaux sociaux, relations médias, organisation	Communication, Médias, Culture et Création	Bac+3/Bac+5	250000.00	1800000.00	EAS	Forte croissance	t
132	Journaliste	Collecte, analyse et diffusion de l’information	Le journaliste recherche, vérifie et présente des informations à travers différents supports comme la presse écrite, la radio, la télévision ou le numérique.	Investigation, rédaction, enquête, communication, analyse information, expression orale	Communication, Médias, Culture et Création	Bac+3/Bac+5	200000.00	1500000.00	IAS	Stable	t
133	Community Manager	Gestion de la présence numérique des organisations	Le community manager anime les communautés en ligne, crée des contenus numériques et développe l’image des marques ou institutions sur les réseaux sociaux.	Réseaux sociaux, création contenu, communication digitale, analyse audience, créativité	Communication, Médias, Culture et Création	Bac+2/Bac+5	200000.00	1500000.00	ASI	Très forte croissance	t
134	Graphiste Designer	Création de contenus visuels et supports graphiques	Le graphiste designer conçoit des identités visuelles, affiches, supports numériques et éléments graphiques pour les entreprises et organisations.	Design graphique, logiciels création, créativité, identité visuelle, communication visuelle	Communication, Médias, Culture et Création	Bac+2/Bac+3	200000.00	1500000.00	AIC	Forte croissance	t
135	Designer Multimédia	Création de contenus numériques interactifs	Le designer multimédia réalise des contenus combinant images, vidéos, animations et éléments interactifs pour les supports numériques.	Design numérique, multimédia, audiovisuel, UX, création contenu, outils digitaux	Communication, Médias, Culture et Création	Bac+3/Bac+5	250000.00	2000000.00	ASI	Très forte croissance	t
136	Réalisateur audiovisuel	Conception et réalisation de productions audiovisuelles	Le réalisateur audiovisuel dirige la création de films, documentaires, émissions ou contenus vidéo destinés aux médias et plateformes numériques.	Production audiovisuelle, scénario, direction artistique, montage, gestion équipe	Communication, Médias, Culture et Création	Bac+3/Bac+5	250000.00	2500000.00	AIS	En croissance	t
137	Technicien audiovisuel	Gestion technique des productions audiovisuelles	Le technicien audiovisuel intervient dans la prise de son, l’image, l’éclairage et les équipements techniques utilisés dans les productions médias.	Prise de son, vidéo, équipements audiovisuels, montage, maintenance technique	Communication, Médias, Culture et Création	Bac+2/Bac+3	200000.00	1200000.00	RAC	En croissance	t
138	Responsable événementiel	Organisation et gestion d’événements professionnels et culturels	Le responsable événementiel planifie et coordonne des événements comme des conférences, salons, manifestations culturelles ou commerciales.	Organisation événement, gestion projet, communication, logistique, négociation	Communication, Médias, Culture et Création	Bac+3/Bac+5	250000.00	2000000.00	EAS	Forte croissance	t
139	Chargé des relations publiques	Gestion de l’image et des relations avec les publics	Le chargé des relations publiques développe les relations entre une organisation, ses partenaires, les médias et ses différents publics.	Relations publiques, communication, négociation, stratégie image, rédaction	Communication, Médias, Culture et Création	Bac+3/Bac+5	250000.00	1800000.00	ESA	En croissance	t
140	Responsable hôtelier	Gestion et supervision des activités d’un établissement hôtelier	Le responsable hôtelier organise les services d’un hôtel, supervise les équipes et veille à la qualité de l’accueil et de l’expérience client.	Management hôtelier, gestion équipe, relation client, organisation, qualité de service	Tourisme, Hôtellerie et Restauration	Bac+2/Bac+5	300000.00	2000000.00	EAS	Forte croissance	t
141	Directeur d’hôtel	Direction stratégique et opérationnelle d’un établissement hôtelier	Le directeur d’hôtel pilote l’ensemble des activités d’un établissement, de la gestion financière à la qualité des services proposés.	Leadership, gestion, finance, management, stratégie commerciale, organisation	Tourisme, Hôtellerie et Restauration	Bac+3/Bac+5	500000.00	4000000.00	ECR	En croissance	f
142	Réceptionniste hôtelier	Accueil et accompagnement des clients dans un établissement hôtelier	Le réceptionniste hôtelier assure l’accueil des clients, les réservations et la coordination avec les différents services de l’hôtel.	Accueil, communication, langues étrangères, gestion réservation, relation client	Tourisme, Hôtellerie et Restauration	Bac+2	200000.00	1000000.00	SCE	Stable	t
143	Agent de voyage / Conseiller voyage	Organisation et conseil dans les prestations touristiques	L’agent de voyage accompagne les clients dans la préparation de leurs déplacements, réservations et choix de destinations.	Organisation voyage, réservation, conseil client, tourisme, communication	Tourisme, Hôtellerie et Restauration	Bac+2/Bac+3	200000.00	1500000.00	ESA	En croissance	t
144	Guide touristique professionnel	Accompagnement et valorisation du patrimoine touristique	Le guide touristique professionnel présente les sites culturels, historiques et naturels aux visiteurs tout en assurant leur accompagnement.	Culture, histoire, communication, langues, animation, connaissance territoire	Tourisme, Hôtellerie et Restauration	Bac+2/Bac+3	200000.00	1200000.00	ESA	En croissance	t
145	Responsable restauration	Gestion d’un service ou établissement de restauration	Le responsable restauration organise les activités d’un restaurant, supervise les équipes et garantit la qualité des prestations.	Gestion restauration, management, organisation, contrôle qualité, gestion coûts	Tourisme, Hôtellerie et Restauration	Bac+2/Bac+3	300000.00	2000000.00	ECR	Forte croissance	t
146	Chef cuisinier professionnel	Préparation et création de prestations culinaires professionnelles	Le chef cuisinier professionnel dirige la cuisine d’un établissement et développe des créations culinaires adaptées aux exigences des clients.	Cuisine professionnelle, créativité, organisation cuisine, gestion équipe, hygiène alimentaire	Tourisme, Hôtellerie et Restauration	Bac+1/Bac+2	200000.00	2000000.00	RAC	En croissance	t
147	Pâtissier professionnel	Création de produits de pâtisserie dans un cadre professionnel	Le pâtissier professionnel réalise des produits sucrés pour les hôtels, restaurants, entreprises alimentaires ou activités entrepreneuriales.	Pâtisserie, créativité, précision, hygiène alimentaire, techniques culinaires	Tourisme, Hôtellerie et Restauration	Bac+1/Bac+2	200000.00	1500000.00	RAC	En croissance	t
148	Assistant comptable	Assistance dans la gestion des opérations comptables quotidiennes	L’assistant comptable participe à la saisie des opérations, au suivi des documents financiers et à la préparation des travaux comptables.	Saisie comptable, logiciels comptables, organisation, contrôle documents, rigueur	Comptabilité, Fiscalité et Expertise	Bac+2/Bac+3	200000.00	1000000.00	CER	Stable	t
149	Expert-comptable	Expertise avancée en comptabilité et conseil financier	L’expert-comptable accompagne les entreprises dans la tenue des comptes, la conformité financière et le conseil en gestion.	Comptabilité supérieure, normes comptables, fiscalité, conseil, analyse financière	Comptabilité, Fiscalité et Expertise	Bac+5/Bac+8	500000.00	4000000.00	IRC	Forte croissance	t
150	Fiscaliste	Spécialiste de la fiscalité des entreprises et organisations	Le fiscaliste conseille les entreprises sur leurs obligations fiscales et optimise leur situation dans le respect de la réglementation.	Droit fiscal, fiscalité entreprise, analyse réglementation, conseil	Comptabilité, Fiscalité et Expertise	Bac+5	350000.00	2500000.00	CER	Forte croissance	t
151	Comptable public	Gestion comptable dans les administrations publiques	Le comptable public assure le suivi des opérations financières des organismes publics et le respect des règles budgétaires.	Comptabilité publique, finances publiques, contrôle administratif, gestion budget	Comptabilité, Fiscalité et Expertise	Bac+3/Bac+5	300000.00	2000000.00	CER	Stable	t
152	Collaborateur de cabinet comptable	Accompagnement des entreprises dans leurs missions comptables	Le collaborateur de cabinet comptable réalise des missions de tenue comptable, déclarations fiscales et accompagnement des clients.	Comptabilité, fiscalité, relation client, logiciels comptables, analyse documents	Comptabilité, Fiscalité et Expertise	Bac+2/Bac+5	250000.00	2000000.00	CER	Forte croissance	f
153	Spécialiste normes comptables IFRS	Expert des normes comptables internationales	Le spécialiste IFRS accompagne les organisations dans l’application des normes comptables internationales et la conformité financière.	Normes IFRS, comptabilité internationale, analyse financière, reporting	Comptabilité, Fiscalité et Expertise	Bac+5	500000.00	3000000.00	IRC	En croissance	f
154	Spécialiste marketing digital	Développement des stratégies marketing utilisant les outils numériques.	Le spécialiste marketing digital accompagne les organisations dans leur visibilité en ligne, la promotion des produits et l’analyse des comportements des clients.	Marketing digital, réseaux sociaux, publicité en ligne, analyse données, stratégie numérique	Commerce, Marketing et Communication	Bac+3/Bac+5	250000.00	2000000.00	EAS	Très forte croissance	t
155	Commercial	Développement des ventes et gestion de la relation client.	Le commercial représente une entreprise auprès des clients, présente ses produits ou services et développe son portefeuille commercial.	Vente, négociation, prospection, communication, relation client	Commerce, Marketing et Communication	Bac+2/Bac+3	200000.00	1500000.00	ECS	Stable	t
156	Business developer	Création de nouvelles opportunités commerciales pour les entreprises.	Le business developer recherche de nouveaux marchés, développe des partenariats et participe à la croissance des organisations.	Développement commercial, négociation, stratégie, entrepreneuriat, analyse marché	Commerce, Marketing et Communication	Bac+3/Bac+5	300000.00	2500000.00	ECR	Très forte croissance	t
157	Spécialiste e-commerce	Gestion et développement des activités commerciales en ligne.	Le spécialiste e-commerce développe les ventes sur internet et accompagne les entreprises dans leur transformation commerciale numérique.	Commerce électronique, plateformes web, marketing digital, gestion produits, analyse ventes	Commerce, Marketing et Communication	Bac+3/Bac+5	250000.00	2000000.00	EAS	Très forte croissance	t
158	Communicateur commercial	Création de stratégies de communication orientées vers les objectifs commerciaux.	Le communicateur commercial conçoit des messages et supports destinés à promouvoir les produits, services et marques.	Communication, création contenu, image de marque, stratégie commerciale	Commerce, Marketing et Communication	Bac+3/Bac+5	250000.00	1800000.00	ESA	Forte croissance	f
159	Entrepreneur / Consultant en développement commercial	Création ou accompagnement des activités commerciales.	Ce professionnel développe des projets commerciaux, accompagne les entreprises et contribue à leur croissance.	Entrepreneuriat, stratégie commerciale, gestion projet, innovation, négociation	Commerce, Marketing et Communication	Bac+3/Bac+5	0.00	3000000.00	ECR	Très forte croissance	t
160	Ingénieur télécommunications	Conception et gestion des infrastructures de télécommunications.	L’ingénieur télécommunications développe, déploie et supervise les réseaux de communication fixes et mobiles.	Télécommunications, réseaux, transmission, communication numérique, résolution de problèmes	Télécommunications et Réseaux	Bac+5	400000.00	3500000.00	IRC	Très forte croissance	t
161	Technicien réseaux et télécommunications	Installation et maintenance des équipements réseaux et télécoms.	Le technicien intervient sur les infrastructures réseau, les équipements de communication et les systèmes de transmission.	Maintenance réseau, câblage, configuration équipements, diagnostic technique	Télécommunications et Réseaux	Bac+2/Bac+3	200000.00	1200000.00	RIC	En croissance	t
162	Ingénieur réseaux mobiles (4G/5G)	Conception et optimisation des réseaux de téléphonie mobile.	Ce professionnel participe au déploiement et à l’amélioration des réseaux mobiles nouvelle génération.	Réseaux mobiles, télécommunications, radio, optimisation réseau	Télécommunications et Réseaux	Bac+5	450000.00	4000000.00	IRC	Très forte croissance	t
163	Architecte réseaux	Conception des architectures réseaux des organisations.	L’architecte réseaux définit les infrastructures permettant de garantir la performance, la sécurité et la disponibilité des réseaux.	Architecture réseau, cybersécurité, infrastructures, administration réseau	Télécommunications et Réseaux	Bac+5	500000.00	4500000.00	IRC	Très forte croissance	f
164	Technicien fibre optique	Installation et maintenance des réseaux en fibre optique.	Le technicien fibre optique assure le déploiement et la maintenance des infrastructures de fibre optique.	Fibre optique, installation, maintenance, câblage, diagnostic	Télécommunications et Réseaux	Bac+2	200000.00	1000000.00	RIC	Forte croissance	t
165	Administrateur télécom	Administration des systèmes et équipements de télécommunications.	L’administrateur télécom supervise les équipements de communication et garantit leur bon fonctionnement.	Administration télécom, maintenance, réseaux, sécurité	Télécommunications et Réseaux	Bac+3/Bac+5	300000.00	2000000.00	IRC	En croissance	f
166	Ingénieur transmission	Conception et supervision des systèmes de transmission de données.	L’ingénieur transmission assure la fiabilité des échanges de données sur les infrastructures de télécommunications.	Transmission de données, réseaux, télécommunications, analyse technique	Télécommunications et Réseaux	Bac+5	400000.00	3500000.00	IRC	Très forte croissance	f
167	Gestionnaire des ressources humaines	Gestion administrative et humaine des organisations.	Le gestionnaire des ressources humaines accompagne les organisations dans la gestion du personnel, le développement des compétences et l’application du droit du travail.	Gestion RH, droit du travail, organisation, communication, administration	Ressources Humaines et Développement Organisationnel	Bac+3/Bac+5	300000.00	2500000.00	ESA	Forte croissance	t
168	Consultant en ressources humaines	Conseil et accompagnement des organisations dans leur politique RH.	Le consultant RH accompagne les entreprises dans le recrutement, la gestion des talents et le développement organisationnel.	Conseil, RH, gestion des talents, communication, audit organisationnel	Ressources Humaines et Développement Organisationnel	Bac+5	400000.00	3000000.00	ESA	En croissance	t
169	Psychologue du travail	Analyse du comportement humain dans le monde professionnel.	Le psychologue du travail intervient sur le bien-être, la motivation, les risques psychosociaux et l’amélioration des conditions de travail.	Psychologie, écoute, analyse, accompagnement, relations humaines	Ressources Humaines et Développement Organisationnel	Bac+5	350000.00	2500000.00	SIA	En croissance	t
170	Coach professionnel	Accompagnement des personnes dans leur développement professionnel.	Le coach professionnel aide les salariés, managers ou entrepreneurs à développer leurs compétences et atteindre leurs objectifs.	Coaching, communication, accompagnement, leadership, développement personnel	Ressources Humaines et Développement Organisationnel	Bac+3/Bac+5	300000.00	2500000.00	ESA	En croissance	t
171	Spécialiste développement organisationnel	Amélioration des performances et de l’organisation des entreprises.	Le spécialiste en développement organisationnel accompagne les entreprises dans la transformation, la gestion du changement et l’amélioration des performances.	Organisation, management, stratégie, gestion du changement, analyse	Ressources Humaines et Développement Organisationnel	Bac+5	400000.00	3000000.00	EAI	Très forte croissance	t
172	Assistant de direction	Professionnel chargé d’assister un dirigeant dans l’organisation administrative, la gestion des dossiers et la coordination des activités.	Il facilite le fonctionnement quotidien d’une entreprise en assurant le suivi administratif, la planification et la communication.	Organisation,Bureautique,Communication,Gestion administrative,Planification	Économie et Gestion	Bac+2/Bac+3	250000.00	700000.00	CES	Forte demande	t
173	Secrétaire de direction	Professionnel chargé de la gestion du secrétariat, de l’accueil, de la rédaction des documents et du suivi administratif.	Il constitue le premier appui administratif de la direction et assure une bonne circulation de l’information.	Accueil,Rédaction,Bureautique,Organisation,Communication	Économie et Gestion	Bac+2	200000.00	600000.00	CES	Stable	t
174	Gestionnaire administratif	Professionnel chargé d’assurer la gestion administrative d’une organisation.	Il veille au bon fonctionnement administratif, à la gestion documentaire et au respect des procédures.	Gestion administrative,Organisation,Rédaction,Bureautique,Communication	Économie et Gestion	Bac+3	300000.00	900000.00	CES	En croissance	t
175	Office Manager	Professionnel chargé de coordonner les services administratifs et le fonctionnement général d’une entreprise.	Il supervise l’organisation interne, les ressources matérielles et le support administratif.	Management,Organisation,Communication,Gestion administrative,Leadership	Économie et Gestion	Bac+3/Bac+5	500000.00	1200000.00	ESC	Très forte demande	t
82	Ingénieur Énergie	Conception et gestion des systèmes énergétiques	L’ingénieur énergétique conçoit, analyse et améliore les systèmes de production et de consommation d’énergie. Il intervient notamment dans les énergies renouvelables, l’efficacité énergétique et les projets industriels.	Énergies renouvelables, solaire, efficacité énergétique, systèmes électriques, analyse énergétique, gestion de projet	Énergie, Mines et Industrie	Bac+5	500000.00	2500000.00	IRC	Très forte croissance	t
\.


--
-- Data for Name: metier_critere; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.metier_critere (id_metier_critere, id_metier, id_critere, valeur) FROM stdin;
1	107	1	4.00
2	107	2	3.00
3	107	3	4.00
4	107	4	3.00
5	107	5	3.50
6	107	6	5.00
7	107	7	3.00
8	107	8	2.00
9	107	9	3.00
10	107	10	3.00
11	107	11	3.00
12	107	12	5.00
13	107	13	3.00
14	15	1	4.00
15	15	2	3.00
16	15	3	4.00
17	15	4	4.00
18	15	5	3.50
19	15	6	4.00
20	15	7	3.00
21	15	8	2.00
22	15	9	5.00
23	15	10	3.00
24	15	11	3.00
25	15	12	4.00
26	15	13	3.00
27	114	1	4.00
28	114	2	5.00
29	114	3	4.00
30	114	4	4.00
31	114	5	3.50
32	114	6	4.00
33	114	7	3.00
34	114	8	2.00
35	114	9	5.00
36	114	10	3.00
37	114	11	3.00
38	114	12	4.00
39	114	13	5.00
40	8	1	4.00
41	8	2	3.00
42	8	3	5.00
43	8	4	4.00
44	8	5	3.50
45	8	6	4.00
46	8	7	3.00
47	8	8	2.00
48	8	9	5.00
49	8	10	3.00
50	8	11	3.00
51	8	12	4.00
52	8	13	3.00
53	20	1	4.00
54	20	2	3.00
55	20	3	4.00
56	20	4	4.00
57	20	5	3.50
58	20	6	4.00
59	20	7	3.00
60	20	8	2.00
61	20	9	5.00
62	20	10	3.00
63	20	11	3.00
64	20	12	4.00
65	20	13	3.00
66	165	1	4.00
67	165	2	3.00
68	165	3	5.00
69	165	4	4.00
70	165	5	3.50
71	165	6	4.00
72	165	7	3.00
73	165	8	2.00
74	165	9	5.00
75	165	10	3.00
76	165	11	3.00
77	165	12	4.00
78	165	13	3.00
79	143	1	4.00
80	143	2	3.00
81	143	3	4.00
82	143	4	3.00
83	143	5	3.50
84	143	6	3.00
85	143	7	3.00
86	143	8	2.00
87	143	9	3.00
88	143	10	3.00
89	143	11	3.00
90	143	12	3.00
91	143	13	3.00
92	76	1	4.00
93	76	2	3.00
94	76	3	4.00
95	76	4	3.00
96	76	5	3.50
97	76	6	3.00
98	76	7	3.00
99	76	8	2.00
100	76	9	3.00
101	76	10	3.00
102	76	11	3.00
103	76	12	3.00
104	76	13	3.00
105	101	1	4.00
106	101	2	3.00
107	101	3	4.00
108	101	4	3.00
109	101	5	3.50
110	101	6	3.00
111	101	7	3.00
112	101	8	2.00
113	101	9	3.00
114	101	10	3.00
115	101	11	3.00
116	101	12	3.00
117	101	13	3.00
118	108	1	4.00
119	108	2	3.00
120	108	3	4.00
121	108	4	4.00
122	108	5	4.00
123	108	6	5.00
124	108	7	3.00
125	108	8	2.00
126	108	9	3.00
127	108	10	3.00
128	108	11	3.00
129	108	12	5.00
130	108	13	3.00
131	23	1	4.00
132	23	2	3.00
133	23	3	5.00
134	23	4	4.00
135	23	5	4.00
136	23	6	5.00
137	23	7	3.00
138	23	8	2.00
139	23	9	3.00
140	23	10	3.00
141	23	11	3.00
142	23	12	5.00
143	23	13	3.00
144	120	1	4.00
145	120	2	3.00
146	120	3	4.00
147	120	4	4.00
148	120	5	4.00
149	120	6	5.00
150	120	7	3.00
151	120	8	2.00
152	120	9	3.00
153	120	10	3.00
154	120	11	3.00
155	120	12	5.00
156	120	13	3.00
157	102	1	4.00
158	102	2	3.00
159	102	3	4.00
160	102	4	4.00
161	102	5	4.00
162	102	6	5.00
163	102	7	3.00
164	102	8	2.00
165	102	9	3.00
166	102	10	3.00
167	102	11	3.00
168	102	12	5.00
169	102	13	3.00
170	81	1	4.00
171	81	2	3.00
172	81	3	5.00
173	81	4	4.00
174	81	5	4.00
175	81	6	5.00
176	81	7	3.00
177	81	8	2.00
178	81	9	3.00
179	81	10	3.00
180	81	11	3.00
181	81	12	5.00
182	81	13	3.00
183	41	1	4.00
184	41	2	3.00
185	41	3	4.00
186	41	4	3.00
187	41	5	3.50
188	41	6	5.00
189	41	7	5.00
190	41	8	2.00
191	41	9	3.00
192	41	10	3.00
193	41	11	3.00
194	41	12	3.00
195	41	13	3.00
196	163	1	4.00
197	163	2	3.00
198	163	3	5.00
199	163	4	3.00
200	163	5	3.50
201	163	6	5.00
202	163	7	5.00
203	163	8	2.00
204	163	9	3.00
205	163	10	3.00
206	163	11	3.00
207	163	12	3.00
208	163	13	3.00
209	148	1	4.00
210	148	2	3.00
211	148	3	4.50
212	148	4	4.00
213	148	5	3.50
214	148	6	5.00
215	148	7	3.00
216	148	8	2.00
217	148	9	4.00
218	148	10	3.00
219	148	11	3.00
220	148	12	4.00
221	148	13	5.00
222	172	1	4.00
223	172	2	3.00
224	172	3	4.00
225	172	4	3.00
226	172	5	3.50
227	172	6	3.00
228	172	7	3.00
229	172	8	2.00
230	172	9	5.00
231	172	10	3.00
232	172	11	3.00
233	172	12	3.00
234	172	13	3.00
235	38	1	4.00
236	38	2	3.00
237	38	3	4.00
238	38	4	3.00
239	38	5	3.50
240	38	6	3.00
241	38	7	3.00
242	38	8	5.00
243	38	9	3.00
244	38	10	3.00
245	38	11	3.00
246	38	12	3.00
247	38	13	3.00
248	104	1	4.00
249	104	2	3.00
250	104	3	4.00
251	104	4	4.00
252	104	5	3.50
253	104	6	5.00
254	104	7	3.00
255	104	8	2.00
256	104	9	4.00
257	104	10	3.00
258	104	11	3.00
259	104	12	3.00
260	104	13	3.00
261	5	1	4.00
262	5	2	3.00
263	5	3	4.00
264	5	4	3.00
265	5	5	3.50
266	5	6	3.00
267	5	7	3.00
268	5	8	2.00
269	5	9	3.00
270	5	10	3.00
271	5	11	3.00
272	5	12	3.00
273	5	13	3.00
274	28	1	4.00
275	28	2	5.00
276	28	3	4.00
277	28	4	3.00
278	28	5	3.50
279	28	6	3.00
280	28	7	3.00
281	28	8	2.00
282	28	9	3.00
283	28	10	3.00
284	28	11	3.00
285	28	12	3.00
286	28	13	3.00
287	156	1	4.00
288	156	2	3.00
289	156	3	4.00
290	156	4	3.00
291	156	5	5.00
292	156	6	3.00
293	156	7	3.00
294	156	8	2.00
295	156	9	3.00
296	156	10	5.00
297	156	11	3.00
298	156	12	3.00
299	156	13	3.00
300	106	1	4.00
301	106	2	3.00
302	106	3	4.50
303	106	4	3.00
304	106	5	3.50
305	106	6	3.00
306	106	7	3.00
307	106	8	5.00
308	106	9	3.00
309	106	10	3.00
310	106	11	3.00
311	106	12	3.00
312	106	13	4.00
313	131	1	4.00
314	131	2	3.00
315	131	3	4.00
316	131	4	3.00
317	131	5	3.50
318	131	6	3.00
319	131	7	5.00
320	131	8	5.00
321	131	9	3.00
322	131	10	3.00
323	131	11	3.00
324	131	12	3.00
325	131	13	3.00
326	116	1	4.00
327	116	2	5.00
328	116	3	4.00
329	116	4	3.00
330	116	5	3.50
331	116	6	3.00
332	116	7	3.00
333	116	8	2.00
334	116	9	5.00
335	116	10	3.00
336	116	11	3.00
337	116	12	3.00
338	116	13	3.00
339	139	1	4.00
340	139	2	3.00
341	139	3	4.00
342	139	4	3.00
343	139	5	3.50
344	139	6	3.00
345	139	7	3.00
346	139	8	5.00
347	139	9	3.00
348	139	10	3.00
349	139	11	3.00
350	139	12	3.00
351	139	13	3.00
352	146	1	4.00
353	146	2	3.00
354	146	3	4.00
355	146	4	2.50
356	146	5	3.50
357	146	6	3.00
358	146	7	5.00
359	146	8	4.00
360	146	9	5.00
361	146	10	5.00
362	146	11	3.00
363	146	12	3.00
364	146	13	3.00
365	66	1	4.00
366	66	2	3.00
367	66	3	4.00
368	66	4	2.50
369	66	5	3.50
370	66	6	3.00
371	66	7	3.00
372	66	8	4.00
373	66	9	5.00
374	66	10	5.00
375	66	11	3.00
376	66	12	3.00
377	66	13	3.00
378	36	1	4.00
379	36	2	5.00
380	36	3	4.00
381	36	4	3.00
382	36	5	3.50
383	36	6	5.00
384	36	7	4.00
385	36	8	2.00
386	36	9	3.00
387	36	10	3.00
388	36	11	3.00
389	36	12	5.00
390	36	13	3.00
391	127	1	4.00
392	127	2	3.00
393	127	3	4.00
394	127	4	3.00
395	127	5	3.50
396	127	6	5.00
397	127	7	4.00
398	127	8	2.00
399	127	9	3.00
400	127	10	3.00
401	127	11	3.00
402	127	12	5.00
403	127	13	3.00
404	170	1	4.00
405	170	2	3.00
406	170	3	4.00
407	170	4	3.00
408	170	5	3.50
409	170	6	3.00
410	170	7	3.00
411	170	8	5.00
412	170	9	3.00
413	170	10	3.00
414	170	11	3.00
415	170	12	3.00
416	170	13	3.00
417	152	1	4.00
418	152	2	3.00
419	152	3	4.50
420	152	4	4.00
421	152	5	3.50
422	152	6	5.00
423	152	7	3.00
424	152	8	2.00
425	152	9	4.00
426	152	10	3.00
427	152	11	3.00
428	152	12	4.00
429	152	13	5.00
430	155	1	4.00
431	155	2	3.00
432	155	3	4.00
433	155	4	3.00
434	155	5	4.00
435	155	6	3.00
436	155	7	3.00
437	155	8	5.00
438	155	9	3.00
439	155	10	5.00
440	155	11	3.00
441	155	12	3.00
442	155	13	3.00
443	158	1	4.00
444	158	2	3.00
445	158	3	4.00
446	158	4	3.00
447	158	5	4.00
448	158	6	3.00
449	158	7	3.00
450	158	8	5.00
451	158	9	3.00
452	158	10	5.00
453	158	11	3.00
454	158	12	3.00
455	158	13	3.00
456	133	1	4.00
457	133	2	3.00
458	133	3	4.00
459	133	4	4.00
460	133	5	5.00
461	133	6	3.00
462	133	7	3.00
463	133	8	4.00
464	133	9	5.00
465	133	10	5.00
466	133	11	3.00
467	133	12	3.00
468	133	13	3.00
469	6	1	4.00
470	6	2	3.00
471	6	3	4.50
472	6	4	4.00
473	6	5	3.50
474	6	6	5.00
475	6	7	3.00
476	6	8	2.00
477	6	9	4.00
478	6	10	3.00
479	6	11	3.00
480	6	12	4.00
481	6	13	5.00
482	151	1	4.00
483	151	2	3.00
484	151	3	4.50
485	151	4	4.00
486	151	5	3.50
487	151	6	5.00
488	151	7	3.00
489	151	8	2.00
490	151	9	4.00
491	151	10	3.00
492	151	11	3.00
493	151	12	4.00
494	151	13	5.00
495	126	1	4.00
496	126	2	3.00
497	126	3	4.00
498	126	4	3.00
499	126	5	3.50
500	126	6	3.00
501	126	7	3.00
502	126	8	2.00
503	126	9	3.00
504	126	10	3.00
505	126	11	3.00
506	126	12	3.00
507	126	13	3.00
508	42	1	4.00
509	42	2	3.00
510	42	3	4.00
511	42	4	2.50
512	42	5	3.50
513	42	6	3.00
514	42	7	3.00
515	42	8	2.00
516	42	9	3.00
517	42	10	5.00
518	42	11	3.00
519	42	12	3.00
520	42	13	3.00
521	128	1	4.00
522	128	2	5.00
523	128	3	4.00
524	128	4	3.00
525	128	5	3.50
526	128	6	3.00
527	128	7	3.00
528	128	8	2.00
529	128	9	3.00
530	128	10	3.00
531	128	11	3.00
532	128	12	3.00
533	128	13	3.00
534	168	1	4.00
535	168	2	3.00
536	168	3	4.00
537	168	4	4.00
538	168	5	5.00
539	168	6	3.00
540	168	7	3.00
541	168	8	5.00
542	168	9	5.00
543	168	10	4.00
544	168	11	3.00
545	168	12	3.00
546	168	13	3.00
547	103	1	4.00
548	103	2	3.00
549	103	3	4.00
550	103	4	3.00
551	103	5	3.50
552	103	6	3.00
553	103	7	3.00
554	103	8	2.00
555	103	9	3.00
556	103	10	3.00
557	103	11	3.00
558	103	12	3.00
559	103	13	3.00
560	98	1	4.00
561	98	2	3.00
562	98	3	4.00
563	98	4	3.00
564	98	5	3.50
565	98	6	3.00
566	98	7	3.00
567	98	8	2.00
568	98	9	3.00
569	98	10	3.00
570	98	11	3.00
571	98	12	3.00
572	98	13	3.00
573	9	1	4.00
574	9	2	3.00
575	9	3	5.00
576	9	4	4.00
577	9	5	4.00
578	9	6	5.00
579	9	7	3.00
580	9	8	2.00
581	9	9	3.00
582	9	10	3.00
583	9	11	3.00
584	9	12	5.00
585	9	13	4.00
586	2	1	4.00
587	2	2	3.00
588	2	3	5.00
589	2	4	4.00
590	2	5	4.00
591	2	6	5.00
592	2	7	3.00
593	2	8	2.00
594	2	9	3.00
595	2	10	3.00
596	2	11	3.00
597	2	12	5.00
598	2	13	4.00
599	27	1	4.00
600	27	2	5.00
601	27	3	4.00
602	27	4	3.00
603	27	5	3.50
604	27	6	3.00
605	27	7	3.00
606	27	8	2.00
607	27	9	3.00
608	27	10	3.00
609	27	11	3.00
610	27	12	3.00
611	27	13	5.00
612	135	1	4.00
613	135	2	3.00
614	135	3	4.00
615	135	4	4.00
616	135	5	3.50
617	135	6	3.00
618	135	7	5.00
619	135	8	2.00
620	135	9	3.00
621	135	10	3.00
622	135	11	3.00
623	135	12	3.00
624	135	13	3.00
625	47	1	4.00
626	47	2	3.00
627	47	3	4.00
628	47	4	3.00
629	47	5	3.50
630	47	6	3.00
631	47	7	3.00
632	47	8	2.00
633	47	9	5.00
634	47	10	3.00
635	47	11	3.00
636	47	12	3.00
637	47	13	3.00
638	12	1	4.00
639	12	2	3.00
640	12	3	5.00
641	12	4	4.00
642	12	5	4.00
643	12	6	4.00
644	12	7	4.00
645	12	8	2.00
646	12	9	3.00
647	12	10	4.00
648	12	11	3.00
649	12	12	4.00
650	12	13	4.00
651	13	1	4.00
652	13	2	3.00
653	13	3	5.00
654	13	4	4.00
655	13	5	4.00
656	13	6	4.00
657	13	7	4.00
658	13	8	2.00
659	13	9	3.00
660	13	10	4.00
661	13	11	3.00
662	13	12	4.00
663	13	13	4.00
664	11	1	4.00
665	11	2	3.00
666	11	3	5.00
667	11	4	4.00
668	11	5	4.00
669	11	6	4.00
670	11	7	4.00
671	11	8	2.00
672	11	9	3.00
673	11	10	4.00
674	11	11	3.00
675	11	12	4.00
676	11	13	4.00
677	1	1	4.00
678	1	2	3.00
679	1	3	5.00
680	1	4	4.00
681	1	5	4.00
682	1	6	4.00
683	1	7	4.00
684	1	8	2.00
685	1	9	3.00
686	1	10	4.00
687	1	11	3.00
688	1	12	4.00
689	1	13	4.00
690	141	1	4.00
691	141	2	3.00
692	141	3	4.00
693	141	4	3.00
694	141	5	5.00
695	141	6	3.00
696	141	7	3.00
697	141	8	5.00
698	141	9	3.00
699	141	10	5.00
700	141	11	3.00
701	141	12	3.00
702	141	13	3.00
703	118	1	4.00
704	118	2	3.00
705	118	3	4.00
706	118	4	3.00
707	118	5	3.50
708	118	6	5.00
709	118	7	3.00
710	118	8	2.00
711	118	9	3.00
712	118	10	3.00
713	118	11	3.00
714	118	12	3.00
715	118	13	3.00
716	69	1	4.00
717	69	2	3.00
718	69	3	4.00
719	69	4	2.50
720	69	5	3.50
721	69	6	3.00
722	69	7	3.00
723	69	8	2.00
724	69	9	3.00
725	69	10	3.00
726	69	11	3.00
727	69	12	3.00
728	69	13	3.00
729	122	1	4.00
730	122	2	5.00
731	122	3	4.00
732	122	4	3.00
733	122	5	3.50
734	122	6	3.00
735	122	7	3.00
736	122	8	5.00
737	122	9	3.00
738	122	10	3.00
739	122	11	3.00
740	122	12	3.00
741	122	13	5.00
742	123	1	4.00
743	123	2	5.00
744	123	3	4.00
745	123	4	3.00
746	123	5	3.50
747	123	6	5.00
748	123	7	4.00
749	123	8	5.00
750	123	9	3.00
751	123	10	3.00
752	123	11	3.00
753	123	12	5.00
754	123	13	5.00
755	159	1	4.00
756	159	2	5.00
757	159	3	4.00
758	159	4	4.00
759	159	5	5.00
760	159	6	3.00
761	159	7	5.00
762	159	8	5.00
763	159	9	4.00
764	159	10	5.00
765	159	11	3.00
766	159	12	3.00
767	159	13	3.00
768	35	1	4.00
769	35	2	3.00
770	35	3	4.00
771	35	4	3.00
772	35	5	3.50
773	35	6	3.00
774	35	7	3.00
775	35	8	2.00
776	35	9	3.00
777	35	10	3.00
778	35	11	3.00
779	35	12	3.00
780	35	13	3.00
781	14	1	4.00
782	14	2	3.00
783	14	3	5.00
784	14	4	3.00
785	14	5	5.00
786	14	6	5.00
787	14	7	3.00
788	14	8	2.00
789	14	9	3.00
790	14	10	3.00
791	14	11	3.00
792	14	12	5.00
793	14	13	3.00
794	110	1	4.00
795	110	2	3.00
796	110	3	4.50
797	110	4	3.00
798	110	5	5.00
799	110	6	3.00
800	110	7	3.00
801	110	8	2.00
802	110	9	3.00
803	110	10	3.00
804	110	11	3.00
805	110	12	5.00
806	110	13	3.00
807	149	1	4.00
808	149	2	3.00
809	149	3	4.50
810	149	4	4.00
811	149	5	5.00
812	149	6	5.00
813	149	7	3.00
814	149	8	2.00
815	149	9	4.00
816	149	10	3.00
817	149	11	3.00
818	149	12	5.00
819	149	13	5.00
820	150	1	4.00
821	150	2	3.00
822	150	3	4.00
823	150	4	3.00
824	150	5	3.50
825	150	6	5.00
826	150	7	3.00
827	150	8	2.00
828	150	9	3.00
829	150	10	3.00
830	150	11	3.00
831	150	12	3.00
832	150	13	3.00
833	124	1	4.00
834	124	2	5.00
835	124	3	4.00
836	124	4	3.00
837	124	5	3.50
838	124	6	3.00
839	124	7	3.00
840	124	8	5.00
841	124	9	3.00
842	124	10	3.00
843	124	11	3.00
844	124	12	3.00
845	124	13	3.00
846	71	1	4.00
847	71	2	3.00
848	71	3	4.00
849	71	4	3.00
850	71	5	3.50
851	71	6	3.00
852	71	7	3.00
853	71	8	2.00
854	71	9	3.00
855	71	10	3.00
856	71	11	3.00
857	71	12	3.00
858	71	13	3.00
859	45	1	4.00
860	45	2	3.00
861	45	3	4.00
862	45	4	3.00
863	45	5	3.50
864	45	6	5.00
865	45	7	3.00
866	45	8	2.00
867	45	9	3.00
868	45	10	3.00
869	45	11	3.00
870	45	12	3.00
871	45	13	3.00
872	174	1	4.00
873	174	2	3.00
874	174	3	4.00
875	174	4	3.00
876	174	5	3.50
877	174	6	3.00
878	174	7	3.00
879	174	8	2.00
880	174	9	5.00
881	174	10	3.00
882	174	11	3.00
883	174	12	3.00
884	174	13	3.00
885	109	1	4.00
886	109	2	3.00
887	109	3	4.00
888	109	4	3.00
889	109	5	3.50
890	109	6	3.00
891	109	7	3.00
892	109	8	2.00
893	109	9	5.00
894	109	10	3.00
895	109	11	3.00
896	109	12	3.00
897	109	13	4.00
898	105	1	4.00
899	105	2	3.00
900	105	3	4.50
901	105	4	3.00
902	105	5	3.50
903	105	6	3.00
904	105	7	3.00
905	105	8	2.00
906	105	9	5.00
907	105	10	3.00
908	105	11	3.00
909	105	12	3.00
910	105	13	4.00
911	121	1	4.00
912	121	2	5.00
913	121	3	4.00
914	121	4	3.00
915	121	5	3.50
916	121	6	3.00
917	121	7	3.00
918	121	8	2.00
919	121	9	5.00
920	121	10	3.00
921	121	11	3.00
922	121	12	3.00
923	121	13	3.00
924	167	1	4.00
925	167	2	3.00
926	167	3	4.00
927	167	4	3.00
928	167	5	3.50
929	167	6	3.00
930	167	7	3.00
931	167	8	5.00
932	167	9	5.00
933	167	10	3.00
934	167	11	3.00
935	167	12	3.00
936	167	13	3.00
937	79	1	4.00
938	79	2	3.00
939	79	3	4.00
940	79	4	3.00
941	79	5	3.50
942	79	6	3.00
943	79	7	3.00
944	79	8	2.00
945	79	9	5.00
946	79	10	3.00
947	79	11	3.00
948	79	12	3.00
949	79	13	3.00
950	77	1	4.00
951	77	2	3.00
952	77	3	4.00
953	77	4	3.00
954	77	5	3.50
955	77	6	3.00
956	77	7	3.00
957	77	8	2.00
958	77	9	5.00
959	77	10	3.00
960	77	11	3.00
961	77	12	3.00
962	77	13	3.00
963	134	1	4.00
964	134	2	3.00
965	134	3	4.00
966	134	4	4.00
967	134	5	3.50
968	134	6	3.00
969	134	7	5.00
970	134	8	2.00
971	134	9	3.00
972	134	10	3.00
973	134	11	3.00
974	134	12	3.00
975	134	13	3.00
976	144	1	4.00
977	144	2	3.00
978	144	3	4.00
979	144	4	3.00
980	144	5	3.50
981	144	6	3.00
982	144	7	3.00
983	144	8	5.00
984	144	9	3.00
985	144	10	3.00
986	144	11	3.00
987	144	12	3.00
988	144	13	3.00
989	25	1	4.00
990	25	2	5.00
991	25	3	4.50
992	25	4	2.50
993	25	5	3.50
994	25	6	3.00
995	25	7	3.00
996	25	8	5.00
997	25	9	3.00
998	25	10	3.00
999	25	11	3.00
1000	25	12	3.00
1001	25	13	5.00
1002	93	1	4.00
1003	93	2	3.00
1004	93	3	4.50
1005	93	4	3.00
1006	93	5	5.00
1007	93	6	5.00
1008	93	7	4.00
1009	93	8	2.00
1010	93	9	4.00
1011	93	10	4.00
1012	93	11	3.00
1013	93	12	5.00
1014	93	13	4.00
1015	92	1	4.00
1016	92	2	3.00
1017	92	3	4.50
1018	92	4	3.00
1019	92	5	5.00
1020	92	6	5.00
1021	92	7	4.00
1022	92	8	2.00
1023	92	9	4.00
1024	92	10	4.00
1025	92	11	3.00
1026	92	12	5.00
1027	92	13	4.00
1028	88	1	4.00
1029	88	2	3.00
1030	88	3	4.50
1031	88	4	3.00
1032	88	5	5.00
1033	88	6	5.00
1034	88	7	4.00
1035	88	8	2.00
1036	88	9	4.00
1037	88	10	4.00
1038	88	11	3.00
1039	88	12	5.00
1040	88	13	4.00
1041	34	1	4.00
1042	34	2	3.00
1043	34	3	4.50
1044	34	4	3.00
1045	34	5	5.00
1046	34	6	5.00
1047	34	7	4.00
1048	34	8	2.00
1049	34	9	4.00
1050	34	10	4.00
1051	34	11	3.00
1052	34	12	5.00
1053	34	13	4.00
1054	16	1	4.00
1055	16	2	3.00
1056	16	3	5.00
1057	16	4	3.00
1058	16	5	5.00
1059	16	6	5.00
1060	16	7	4.00
1061	16	8	2.00
1062	16	9	4.00
1063	16	10	4.00
1064	16	11	3.00
1065	16	12	5.00
1066	16	13	4.00
1067	19	1	4.00
1068	19	2	3.00
1069	19	3	5.00
1070	19	4	4.00
1071	19	5	5.00
1072	19	6	5.00
1073	19	7	4.00
1074	19	8	2.00
1075	19	9	4.00
1076	19	10	4.00
1077	19	11	3.00
1078	19	12	5.00
1079	19	13	4.00
1080	70	1	4.00
1081	70	2	3.00
1082	70	3	4.50
1083	70	4	3.00
1084	70	5	5.00
1085	70	6	5.00
1086	70	7	4.00
1087	70	8	2.00
1088	70	9	4.00
1089	70	10	4.00
1090	70	11	3.00
1091	70	12	5.00
1092	70	13	4.00
1093	99	1	4.00
1094	99	2	3.00
1095	99	3	4.50
1096	99	4	3.00
1097	99	5	5.00
1098	99	6	5.00
1099	99	7	4.00
1100	99	8	2.00
1101	99	9	4.00
1102	99	10	4.00
1103	99	11	3.00
1104	99	12	5.00
1105	99	13	4.00
1106	82	1	4.00
1107	82	2	3.00
1108	82	3	4.50
1109	82	4	3.00
1110	82	5	5.00
1111	82	6	5.00
1112	82	7	4.00
1113	82	8	2.00
1114	82	9	4.00
1115	82	10	4.00
1116	82	11	3.00
1117	82	12	5.00
1118	82	13	4.00
1119	96	1	4.00
1120	96	2	5.00
1121	96	3	4.50
1122	96	4	3.00
1123	96	5	5.00
1124	96	6	5.00
1125	96	7	4.00
1126	96	8	2.00
1127	96	9	4.00
1128	96	10	4.00
1129	96	11	3.00
1130	96	12	5.00
1131	96	13	4.00
1132	49	1	4.00
1133	49	2	5.00
1134	49	3	4.50
1135	49	4	3.00
1136	49	5	5.00
1137	49	6	5.00
1138	49	7	4.00
1139	49	8	2.00
1140	49	9	4.00
1141	49	10	4.00
1142	49	11	3.00
1143	49	12	5.00
1144	49	13	4.00
1145	3	1	4.00
1146	3	2	3.00
1147	3	3	4.50
1148	3	4	3.00
1149	3	5	5.00
1150	3	6	5.00
1151	3	7	4.00
1152	3	8	2.00
1153	3	9	4.00
1154	3	10	4.00
1155	3	11	3.00
1156	3	12	5.00
1157	3	13	4.00
1158	67	1	4.00
1159	67	2	3.00
1160	67	3	4.50
1161	67	4	3.00
1162	67	5	5.00
1163	67	6	5.00
1164	67	7	4.00
1165	67	8	2.00
1166	67	9	4.00
1167	67	10	4.00
1168	67	11	3.00
1169	67	12	5.00
1170	67	13	4.00
1171	89	1	4.00
1172	89	2	5.00
1173	89	3	4.50
1174	89	4	3.00
1175	89	5	5.00
1176	89	6	5.00
1177	89	7	4.00
1178	89	8	2.00
1179	89	9	4.00
1180	89	10	4.00
1181	89	11	3.00
1182	89	12	5.00
1183	89	13	4.00
1184	44	1	4.00
1185	44	2	3.00
1186	44	3	4.50
1187	44	4	3.00
1188	44	5	5.00
1189	44	6	5.00
1190	44	7	4.00
1191	44	8	2.00
1192	44	9	4.00
1193	44	10	4.00
1194	44	11	3.00
1195	44	12	5.00
1196	44	13	4.00
1197	85	1	4.00
1198	85	2	3.00
1199	85	3	4.50
1200	85	4	3.00
1201	85	5	5.00
1202	85	6	5.00
1203	85	7	4.00
1204	85	8	2.00
1205	85	9	4.00
1206	85	10	4.00
1207	85	11	3.00
1208	85	12	5.00
1209	85	13	4.00
1210	18	1	4.00
1211	18	2	3.00
1212	18	3	5.00
1213	18	4	3.00
1214	18	5	5.00
1215	18	6	5.00
1216	18	7	4.00
1217	18	8	2.00
1218	18	9	4.00
1219	18	10	4.00
1220	18	11	3.00
1221	18	12	5.00
1222	18	13	4.00
1223	10	1	4.00
1224	10	2	3.00
1225	10	3	5.00
1226	10	4	3.00
1227	10	5	5.00
1228	10	6	5.00
1229	10	7	4.00
1230	10	8	2.00
1231	10	9	4.00
1232	10	10	4.00
1233	10	11	3.00
1234	10	12	5.00
1235	10	13	4.00
1236	86	1	4.00
1237	86	2	3.00
1238	86	3	4.50
1239	86	4	3.00
1240	86	5	5.00
1241	86	6	5.00
1242	86	7	4.00
1243	86	8	2.00
1244	86	9	4.00
1245	86	10	4.00
1246	86	11	3.00
1247	86	12	5.00
1248	86	13	4.00
1249	84	1	4.00
1250	84	2	3.00
1251	84	3	4.50
1252	84	4	3.00
1253	84	5	5.00
1254	84	6	5.00
1255	84	7	4.00
1256	84	8	2.00
1257	84	9	4.00
1258	84	10	4.00
1259	84	11	3.00
1260	84	12	5.00
1261	84	13	4.00
1262	125	1	4.00
1263	125	2	3.00
1264	125	3	4.50
1265	125	4	3.00
1266	125	5	5.00
1267	125	6	5.00
1268	125	7	4.00
1269	125	8	2.00
1270	125	9	4.00
1271	125	10	4.00
1272	125	11	3.00
1273	125	12	5.00
1274	125	13	4.00
1275	83	1	4.00
1276	83	2	3.00
1277	83	3	4.50
1278	83	4	3.00
1279	83	5	5.00
1280	83	6	5.00
1281	83	7	4.00
1282	83	8	2.00
1283	83	9	4.00
1284	83	10	4.00
1285	83	11	3.00
1286	83	12	5.00
1287	83	13	4.00
1288	162	1	4.00
1289	162	2	3.00
1290	162	3	5.00
1291	162	4	3.00
1292	162	5	5.00
1293	162	6	5.00
1294	162	7	4.00
1295	162	8	2.00
1296	162	9	4.00
1297	162	10	4.00
1298	162	11	3.00
1299	162	12	5.00
1300	162	13	4.00
1301	50	1	4.00
1302	50	2	3.00
1303	50	3	4.50
1304	50	4	3.00
1305	50	5	5.00
1306	50	6	5.00
1307	50	7	4.00
1308	50	8	2.00
1309	50	9	4.00
1310	50	10	4.00
1311	50	11	3.00
1312	50	12	5.00
1313	50	13	4.00
1314	43	1	4.00
1315	43	2	3.00
1316	43	3	4.50
1317	43	4	3.00
1318	43	5	5.00
1319	43	6	5.00
1320	43	7	4.00
1321	43	8	2.00
1322	43	9	4.00
1323	43	10	4.00
1324	43	11	3.00
1325	43	12	5.00
1326	43	13	4.00
1327	21	1	4.00
1328	21	2	3.00
1329	21	3	5.00
1330	21	4	3.00
1331	21	5	5.00
1332	21	6	5.00
1333	21	7	4.00
1334	21	8	2.00
1335	21	9	4.00
1336	21	10	4.00
1337	21	11	3.00
1338	21	12	5.00
1339	21	13	4.00
1340	160	1	4.00
1341	160	2	3.00
1342	160	3	5.00
1343	160	4	3.00
1344	160	5	5.00
1345	160	6	5.00
1346	160	7	5.00
1347	160	8	5.00
1348	160	9	4.00
1349	160	10	4.00
1350	160	11	3.00
1351	160	12	5.00
1352	160	13	4.00
1353	166	1	4.00
1354	166	2	3.00
1355	166	3	4.50
1356	166	4	3.00
1357	166	5	5.00
1358	166	6	5.00
1359	166	7	4.00
1360	166	8	2.00
1361	166	9	4.00
1362	166	10	4.00
1363	166	11	3.00
1364	166	12	5.00
1365	166	13	4.00
1366	115	1	4.00
1367	115	2	3.00
1368	115	3	4.50
1369	115	4	3.00
1370	115	5	3.50
1371	115	6	3.00
1372	115	7	3.00
1373	115	8	2.00
1374	115	9	3.00
1375	115	10	3.00
1376	115	11	3.00
1377	115	12	3.00
1378	115	13	5.00
1379	132	1	4.00
1380	132	2	3.00
1381	132	3	4.00
1382	132	4	3.00
1383	132	5	3.50
1384	132	6	3.00
1385	132	7	5.00
1386	132	8	2.00
1387	132	9	3.00
1388	132	10	3.00
1389	132	11	3.00
1390	132	12	3.00
1391	132	13	3.00
1392	112	1	4.00
1393	112	2	3.00
1394	112	3	4.00
1395	112	4	3.00
1396	112	5	3.50
1397	112	6	4.00
1398	112	7	3.00
1399	112	8	2.00
1400	112	9	3.00
1401	112	10	3.00
1402	112	11	3.00
1403	112	12	3.00
1404	112	13	3.00
1405	33	1	4.00
1406	33	2	5.00
1407	33	3	4.00
1408	33	4	3.00
1409	33	5	3.50
1410	33	6	3.00
1411	33	7	3.00
1412	33	8	2.00
1413	33	9	3.00
1414	33	10	3.00
1415	33	11	3.00
1416	33	12	3.00
1417	33	13	3.00
1418	72	1	4.00
1419	72	2	3.00
1420	72	3	4.00
1421	72	4	3.00
1422	72	5	3.50
1423	72	6	3.00
1424	72	7	3.00
1425	72	8	2.00
1426	72	9	5.00
1427	72	10	3.00
1428	72	11	3.00
1429	72	12	3.00
1430	72	13	3.00
1431	113	1	4.00
1432	113	2	3.00
1433	113	3	4.00
1434	113	4	3.00
1435	113	5	3.50
1436	113	6	3.00
1437	113	7	3.00
1438	113	8	2.00
1439	113	9	3.00
1440	113	10	3.00
1441	113	11	3.00
1442	113	12	3.00
1443	113	13	5.00
1444	37	1	4.00
1445	37	2	3.00
1446	37	3	4.00
1447	37	4	3.00
1448	37	5	3.50
1449	37	6	3.00
1450	37	7	3.00
1451	37	8	2.00
1452	37	9	3.00
1453	37	10	3.00
1454	37	11	3.00
1455	37	12	3.00
1456	37	13	3.00
1457	7	1	4.00
1458	7	2	3.00
1459	7	3	4.00
1460	7	4	3.00
1461	7	5	3.50
1462	7	6	3.00
1463	7	7	3.00
1464	7	8	2.00
1465	7	9	3.00
1466	7	10	3.00
1467	7	11	3.00
1468	7	12	3.00
1469	7	13	3.00
1470	4	1	4.00
1471	4	2	5.00
1472	4	3	4.50
1473	4	4	2.50
1474	4	5	3.50
1475	4	6	3.00
1476	4	7	3.00
1477	4	8	5.00
1478	4	9	3.00
1479	4	10	3.00
1480	4	11	3.00
1481	4	12	3.00
1482	4	13	5.00
1483	68	1	4.00
1484	68	2	3.00
1485	68	3	4.00
1486	68	4	3.00
1487	68	5	3.50
1488	68	6	5.00
1489	68	7	3.00
1490	68	8	2.00
1491	68	9	3.00
1492	68	10	3.00
1493	68	11	3.00
1494	68	12	3.00
1495	68	13	3.00
1496	32	1	4.00
1497	32	2	3.00
1498	32	3	4.00
1499	32	4	3.00
1500	32	5	3.50
1501	32	6	3.00
1502	32	7	3.00
1503	32	8	2.00
1504	32	9	3.00
1505	32	10	3.00
1506	32	11	3.00
1507	32	12	3.00
1508	32	13	3.00
1509	175	1	4.00
1510	175	2	3.00
1511	175	3	4.00
1512	175	4	3.00
1513	175	5	5.00
1514	175	6	3.00
1515	175	7	3.00
1516	175	8	4.00
1517	175	9	5.00
1518	175	10	5.00
1519	175	11	3.00
1520	175	12	3.00
1521	175	13	3.00
1522	147	1	4.00
1523	147	2	3.00
1524	147	3	4.00
1525	147	4	2.50
1526	147	5	3.50
1527	147	6	3.00
1528	147	7	5.00
1529	147	8	2.00
1530	147	9	3.00
1531	147	10	3.00
1532	147	11	3.00
1533	147	12	3.00
1534	147	13	3.00
1535	24	1	4.00
1536	24	2	5.00
1537	24	3	4.50
1538	24	4	3.00
1539	24	5	3.50
1540	24	6	3.00
1541	24	7	3.00
1542	24	8	2.00
1543	24	9	3.00
1544	24	10	3.00
1545	24	11	3.00
1546	24	12	3.00
1547	24	13	5.00
1548	31	1	4.00
1549	31	2	5.00
1550	31	3	4.00
1551	31	4	3.00
1552	31	5	3.50
1553	31	6	3.00
1554	31	7	3.00
1555	31	8	5.00
1556	31	9	3.00
1557	31	10	3.00
1558	31	11	3.00
1559	31	12	3.00
1560	31	13	3.00
1561	169	1	4.00
1562	169	2	5.00
1563	169	3	4.00
1564	169	4	3.00
1565	169	5	3.50
1566	169	6	3.00
1567	169	7	3.00
1568	169	8	5.00
1569	169	9	3.00
1570	169	10	3.00
1571	169	11	3.00
1572	169	12	3.00
1573	169	13	3.00
1574	136	1	4.00
1575	136	2	3.00
1576	136	3	4.00
1577	136	4	3.00
1578	136	5	3.50
1579	136	6	3.00
1580	136	7	5.00
1581	136	8	2.00
1582	136	9	3.00
1583	136	10	3.00
1584	136	11	3.00
1585	136	12	3.00
1586	136	13	3.00
1587	142	1	4.00
1588	142	2	3.00
1589	142	3	4.00
1590	142	4	3.00
1591	142	5	3.50
1592	142	6	3.00
1593	142	7	3.00
1594	142	8	5.00
1595	142	9	3.00
1596	142	10	3.00
1597	142	11	3.00
1598	142	12	3.00
1599	142	13	3.00
1600	78	1	4.00
1601	78	2	3.00
1602	78	3	4.00
1603	78	4	3.00
1604	78	5	5.00
1605	78	6	3.00
1606	78	7	3.00
1607	78	8	4.00
1608	78	9	5.00
1609	78	10	5.00
1610	78	11	3.00
1611	78	12	3.00
1612	78	13	3.00
1613	138	1	4.00
1614	138	2	3.00
1615	138	3	4.00
1616	138	4	3.00
1617	138	5	5.00
1618	138	6	3.00
1619	138	7	3.00
1620	138	8	4.00
1621	138	9	5.00
1622	138	10	5.00
1623	138	11	3.00
1624	138	12	3.00
1625	138	13	3.00
1626	129	1	4.00
1627	129	2	5.00
1628	129	3	4.00
1629	129	4	3.00
1630	129	5	5.00
1631	129	6	3.00
1632	129	7	3.00
1633	129	8	4.00
1634	129	9	5.00
1635	129	10	5.00
1636	129	11	3.00
1637	129	12	3.00
1638	129	13	3.00
1639	140	1	4.00
1640	140	2	3.00
1641	140	3	4.00
1642	140	4	3.00
1643	140	5	5.00
1644	140	6	3.00
1645	140	7	3.00
1646	140	8	5.00
1647	140	9	5.00
1648	140	10	5.00
1649	140	11	3.00
1650	140	12	3.00
1651	140	13	3.00
1652	75	1	4.00
1653	75	2	3.00
1654	75	3	4.00
1655	75	4	3.00
1656	75	5	5.00
1657	75	6	3.00
1658	75	7	3.00
1659	75	8	4.00
1660	75	9	5.00
1661	75	10	5.00
1662	75	11	3.00
1663	75	12	3.00
1664	75	13	3.00
1665	73	1	4.00
1666	73	2	3.00
1667	73	3	4.00
1668	73	4	3.00
1669	73	5	5.00
1670	73	6	3.00
1671	73	7	3.00
1672	73	8	4.00
1673	73	9	5.00
1674	73	10	5.00
1675	73	11	3.00
1676	73	12	3.00
1677	73	13	3.00
1678	95	1	4.00
1679	95	2	3.00
1680	95	3	4.00
1681	95	4	3.00
1682	95	5	5.00
1683	95	6	3.00
1684	95	7	3.00
1685	95	8	4.00
1686	95	9	5.00
1687	95	10	5.00
1688	95	11	3.00
1689	95	12	3.00
1690	95	13	3.00
1691	90	1	4.00
1692	90	2	3.00
1693	90	3	4.00
1694	90	4	3.00
1695	90	5	5.00
1696	90	6	3.00
1697	90	7	3.00
1698	90	8	4.00
1699	90	9	5.00
1700	90	10	5.00
1701	90	11	3.00
1702	90	12	3.00
1703	90	13	3.00
1704	145	1	4.00
1705	145	2	3.00
1706	145	3	4.00
1707	145	4	3.00
1708	145	5	5.00
1709	145	6	3.00
1710	145	7	3.00
1711	145	8	4.00
1712	145	9	5.00
1713	145	10	5.00
1714	145	11	3.00
1715	145	12	3.00
1716	145	13	3.00
1717	80	1	4.00
1718	80	2	3.00
1719	80	3	4.00
1720	80	4	3.00
1721	80	5	5.00
1722	80	6	3.00
1723	80	7	3.00
1724	80	8	4.00
1725	80	9	5.00
1726	80	10	5.00
1727	80	11	3.00
1728	80	12	3.00
1729	80	13	3.00
1730	26	1	4.00
1731	26	2	5.00
1732	26	3	4.00
1733	26	4	2.50
1734	26	5	3.50
1735	26	6	3.00
1736	26	7	3.00
1737	26	8	5.00
1738	26	9	3.00
1739	26	10	3.00
1740	26	11	3.00
1741	26	12	3.00
1742	26	13	5.00
1743	173	1	4.00
1744	173	2	3.00
1745	173	3	4.00
1746	173	4	3.00
1747	173	5	3.50
1748	173	6	3.00
1749	173	7	3.00
1750	173	8	2.00
1751	173	9	5.00
1752	173	10	3.00
1753	173	11	3.00
1754	173	12	3.00
1755	173	13	3.00
1756	119	1	4.00
1757	119	2	3.00
1758	119	3	4.00
1759	119	4	3.00
1760	119	5	3.50
1761	119	6	3.00
1762	119	7	3.00
1763	119	8	2.00
1764	119	9	3.00
1765	119	10	3.00
1766	119	11	3.00
1767	119	12	3.00
1768	119	13	3.00
1769	97	1	4.00
1770	97	2	5.00
1771	97	3	4.00
1772	97	4	3.00
1773	97	5	3.50
1774	97	6	3.00
1775	97	7	3.00
1776	97	8	2.00
1777	97	9	3.00
1778	97	10	3.00
1779	97	11	3.00
1780	97	12	3.00
1781	97	13	3.00
1782	171	1	4.00
1783	171	2	5.00
1784	171	3	4.00
1785	171	4	3.00
1786	171	5	3.50
1787	171	6	3.00
1788	171	7	3.00
1789	171	8	2.00
1790	171	9	3.00
1791	171	10	3.00
1792	171	11	3.00
1793	171	12	3.00
1794	171	13	3.00
1795	157	1	4.00
1796	157	2	3.00
1797	157	3	4.00
1798	157	4	3.00
1799	157	5	3.50
1800	157	6	3.00
1801	157	7	3.00
1802	157	8	2.00
1803	157	9	3.00
1804	157	10	3.00
1805	157	11	3.00
1806	157	12	3.00
1807	157	13	3.00
1808	154	1	4.00
1809	154	2	3.00
1810	154	3	5.00
1811	154	4	3.00
1812	154	5	4.00
1813	154	6	3.00
1814	154	7	5.00
1815	154	8	2.00
1816	154	9	3.00
1817	154	10	3.00
1818	154	11	3.00
1819	154	12	3.00
1820	154	13	3.00
1821	153	1	4.00
1822	153	2	3.00
1823	153	3	4.50
1824	153	4	4.00
1825	153	5	3.50
1826	153	6	5.00
1827	153	7	3.00
1828	153	8	2.00
1829	153	9	4.00
1830	153	10	3.00
1831	153	11	3.00
1832	153	12	4.00
1833	153	13	5.00
1834	117	1	4.00
1835	117	2	3.00
1836	117	3	4.00
1837	117	4	3.00
1838	117	5	3.50
1839	117	6	3.00
1840	117	7	3.00
1841	117	8	2.00
1842	117	9	3.00
1843	117	10	3.00
1844	117	11	3.00
1845	117	12	3.00
1846	117	13	3.00
1847	40	1	4.00
1848	40	2	5.00
1849	40	3	4.00
1850	40	4	3.00
1851	40	5	3.50
1852	40	6	3.00
1853	40	7	3.00
1854	40	8	2.00
1855	40	9	3.00
1856	40	10	3.00
1857	40	11	3.00
1858	40	12	3.00
1859	40	13	3.00
1860	130	1	4.00
1861	130	2	3.00
1862	130	3	4.00
1863	130	4	3.00
1864	130	5	3.50
1865	130	6	5.00
1866	130	7	4.00
1867	130	8	2.00
1868	130	9	3.00
1869	130	10	3.00
1870	130	11	3.00
1871	130	12	5.00
1872	130	13	3.00
1873	74	1	4.00
1874	74	2	3.00
1875	74	3	5.00
1876	74	4	3.00
1877	74	5	5.00
1878	74	6	3.00
1879	74	7	3.00
1880	74	8	4.00
1881	74	9	5.00
1882	74	10	5.00
1883	74	11	3.00
1884	74	12	3.00
1885	74	13	3.00
1886	94	1	4.00
1887	94	2	3.00
1888	94	3	4.00
1889	94	4	2.50
1890	94	5	4.00
1891	94	6	4.00
1892	94	7	3.00
1893	94	8	2.00
1894	94	9	3.00
1895	94	10	4.00
1896	94	11	3.00
1897	94	12	4.00
1898	94	13	4.00
1899	100	1	4.00
1900	100	2	3.00
1901	100	3	4.00
1902	100	4	3.00
1903	100	5	4.00
1904	100	6	4.00
1905	100	7	3.00
1906	100	8	2.00
1907	100	9	3.00
1908	100	10	4.00
1909	100	11	3.00
1910	100	12	4.00
1911	100	13	4.00
1912	137	1	4.00
1913	137	2	3.00
1914	137	3	4.00
1915	137	4	3.00
1916	137	5	4.00
1917	137	6	4.00
1918	137	7	5.00
1919	137	8	2.00
1920	137	9	3.00
1921	137	10	4.00
1922	137	11	3.00
1923	137	12	4.00
1924	137	13	4.00
1925	29	1	4.00
1926	29	2	3.00
1927	29	3	4.00
1928	29	4	3.00
1929	29	5	4.00
1930	29	6	4.00
1931	29	7	3.00
1932	29	8	2.00
1933	29	9	3.00
1934	29	10	4.00
1935	29	11	3.00
1936	29	12	4.00
1937	29	13	4.00
1938	91	1	4.00
1939	91	2	3.00
1940	91	3	4.00
1941	91	4	3.00
1942	91	5	4.00
1943	91	6	4.00
1944	91	7	3.00
1945	91	8	2.00
1946	91	9	3.00
1947	91	10	4.00
1948	91	11	3.00
1949	91	12	4.00
1950	91	13	4.00
1951	39	1	4.00
1952	39	2	3.00
1953	39	3	4.00
1954	39	4	3.00
1955	39	5	4.00
1956	39	6	4.00
1957	39	7	3.00
1958	39	8	2.00
1959	39	9	3.00
1960	39	10	4.00
1961	39	11	3.00
1962	39	12	4.00
1963	39	13	4.00
1964	164	1	4.00
1965	164	2	3.00
1966	164	3	4.00
1967	164	4	3.00
1968	164	5	4.00
1969	164	6	4.00
1970	164	7	3.00
1971	164	8	2.00
1972	164	9	3.00
1973	164	10	4.00
1974	164	11	3.00
1975	164	12	4.00
1976	164	13	4.00
1977	46	1	4.00
1978	46	2	3.00
1979	46	3	4.00
1980	46	4	3.00
1981	46	5	4.00
1982	46	6	4.00
1983	46	7	3.00
1984	46	8	2.00
1985	46	9	3.00
1986	46	10	4.00
1987	46	11	3.00
1988	46	12	4.00
1989	46	13	4.00
1990	87	1	4.00
1991	87	2	3.00
1992	87	3	4.00
1993	87	4	2.50
1994	87	5	4.00
1995	87	6	4.00
1996	87	7	3.00
1997	87	8	2.00
1998	87	9	3.00
1999	87	10	4.00
2000	87	11	3.00
2001	87	12	4.00
2002	87	13	4.00
2003	161	1	4.00
2004	161	2	3.00
2005	161	3	5.00
2006	161	4	3.00
2007	161	5	4.00
2008	161	6	4.00
2009	161	7	5.00
2010	161	8	5.00
2011	161	9	3.00
2012	161	10	4.00
2013	161	11	3.00
2014	161	12	4.00
2015	161	13	4.00
2016	22	1	4.00
2017	22	2	3.00
2018	22	3	4.00
2019	22	4	3.00
2020	22	5	4.00
2021	22	6	4.00
2022	22	7	3.00
2023	22	8	2.00
2024	22	9	3.00
2025	22	10	4.00
2026	22	11	3.00
2027	22	12	4.00
2028	22	13	4.00
2029	111	1	4.00
2030	111	2	3.00
2031	111	3	4.00
2032	111	4	3.00
2033	111	5	3.50
2034	111	6	3.00
2035	111	7	3.00
2036	111	8	2.00
2037	111	9	3.00
2038	111	10	3.00
2039	111	11	3.00
2040	111	12	3.00
2041	111	13	3.00
2042	48	1	4.00
2043	48	2	3.00
2044	48	3	4.00
2045	48	4	3.00
2046	48	5	3.50
2047	48	6	3.00
2048	48	7	3.00
2049	48	8	2.00
2050	48	9	3.00
2051	48	10	3.00
2052	48	11	3.00
2053	48	12	3.00
2054	48	13	3.00
2055	17	1	4.00
2056	17	2	3.00
2057	17	3	4.00
2058	17	4	4.00
2059	17	5	3.50
2060	17	6	3.00
2061	17	7	5.00
2062	17	8	2.00
2063	17	9	3.00
2064	17	10	3.00
2065	17	11	3.00
2066	17	12	3.00
2067	17	13	3.00
2068	30	1	4.00
2069	30	2	5.00
2070	30	3	4.00
2071	30	4	3.00
2072	30	5	3.50
2073	30	6	3.00
2074	30	7	3.00
2075	30	8	2.00
2076	30	9	3.00
2077	30	10	3.00
2078	30	11	3.00
2079	30	12	3.00
2080	30	13	3.00
\.


--
-- Data for Name: metier_filiere; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.metier_filiere (id_metier, id_filiere) FROM stdin;
1	1
1	9
1	143
1	158
1	165
2	12
2	13
2	17
2	29
2	114
2	142
2	153
2	158
3	2
3	142
4	3
5	4
5	73
5	101
5	128
5	129
5	145
5	150
6	5
6	105
6	106
6	117
6	149
7	7
7	71
7	139
8	10
8	14
8	107
8	137
8	162
9	1
9	12
9	17
9	100
9	114
9	119
9	136
9	153
10	1
10	9
10	88
10	142
10	143
10	158
10	165
11	1
11	9
11	143
12	1
12	9
12	143
12	158
12	165
13	1
13	9
13	143
13	158
13	165
14	10
14	11
14	14
14	137
14	162
15	1
15	15
15	100
15	119
15	136
15	158
15	165
16	9
16	10
16	14
16	119
16	136
17	1
17	9
17	115
18	12
18	13
18	29
18	88
18	114
18	119
18	142
18	153
18	158
18	167
19	12
19	13
19	17
19	114
19	142
19	153
19	167
20	10
20	14
20	88
20	100
20	107
20	116
20	119
20	136
21	10
21	14
21	88
21	100
21	107
21	119
21	136
21	137
21	162
21	165
22	1
22	10
22	14
22	107
22	116
23	10
23	11
23	14
23	107
23	137
23	162
24	18
25	20
26	21
27	19
28	22
28	89
28	161
28	169
29	22
29	161
29	169
30	31
31	32
32	25
33	26
34	33
34	89
34	142
34	152
34	161
34	167
34	168
34	169
35	23
35	89
36	3
36	23
36	89
36	161
36	169
37	24
38	20
39	18
40	23
41	2
41	113
41	142
41	160
41	177
42	2
43	2
43	84
44	2
44	85
45	2
45	82
45	160
45	176
45	177
46	2
46	82
46	84
47	2
47	113
48	2
48	113
48	160
48	176
48	177
49	2
49	72
49	85
49	87
50	2
66	2
67	2
67	84
68	2
69	2
70	2
70	8
70	81
70	86
71	2
71	82
72	69
72	70
72	78
72	79
72	132
72	140
72	163
72	166
72	178
73	69
73	78
73	140
73	166
74	69
74	70
74	78
74	140
74	166
75	70
75	79
76	70
76	78
76	79
77	69
77	78
77	132
77	140
77	163
77	166
77	178
78	69
78	78
78	140
78	166
79	69
79	78
79	140
79	166
80	69
80	78
80	132
80	140
80	166
80	178
81	69
81	70
81	78
81	114
81	140
82	8
82	81
82	86
82	142
82	152
82	168
82	177
83	152
83	168
84	152
84	168
84	176
85	83
85	86
85	90
85	133
85	176
86	81
86	83
86	133
87	8
87	81
87	83
87	116
87	133
88	8
88	81
88	83
88	88
88	133
89	72
89	86
89	87
89	90
91	8
91	81
91	83
91	116
91	133
92	110
92	147
93	91
93	146
94	110
94	147
95	110
95	147
96	72
96	85
96	87
97	72
97	87
97	102
98	72
98	90
98	91
98	146
99	110
100	91
100	146
101	110
101	147
101	156
102	64
102	77
102	99
102	100
102	108
102	118
102	131
102	141
102	164
103	5
103	64
103	67
103	76
103	77
103	80
103	92
103	97
103	99
103	100
103	106
103	118
103	124
103	127
103	141
103	151
103	163
104	76
104	77
104	97
105	5
105	64
105	67
105	76
105	77
105	80
105	99
105	109
105	112
105	124
105	127
105	131
105	141
105	151
105	163
105	164
106	77
106	109
106	112
106	123
106	127
106	151
107	77
107	108
107	118
107	131
107	164
108	77
108	108
108	118
108	131
108	164
109	77
109	108
109	131
109	164
110	77
111	5
111	64
111	67
111	77
111	80
111	97
111	99
111	118
112	4
112	73
112	129
112	145
112	150
112	159
113	4
113	73
113	101
113	104
113	125
113	128
113	129
113	145
114	4
114	74
114	98
114	101
114	103
114	104
114	109
114	120
114	128
115	74
115	98
115	104
115	120
115	128
116	74
116	75
116	80
116	102
116	103
117	4
117	73
117	74
117	120
117	128
118	74
118	98
118	99
118	101
118	103
118	120
118	125
118	141
119	74
119	98
119	126
119	155
119	171
119	174
120	74
120	75
120	98
120	99
120	101
120	102
120	103
120	104
120	125
120	155
120	171
120	174
121	5
121	64
121	74
121	75
121	80
121	98
121	102
121	104
121	125
121	155
121	171
122	167
122	168
122	169
122	170
122	171
122	172
122	173
122	174
122	175
123	167
123	168
123	169
123	170
123	171
123	172
123	173
123	174
123	178
124	170
124	172
124	173
124	174
124	175
127	167
127	168
127	169
127	171
130	167
131	71
131	94
131	96
131	111
131	121
131	122
131	130
131	148
131	157
132	94
132	96
132	111
132	121
132	148
132	157
133	71
133	111
133	121
133	122
133	130
133	139
133	148
133	157
134	115
134	134
135	115
135	134
136	115
136	135
137	135
138	122
138	130
139	94
139	96
139	121
139	122
139	130
139	148
139	157
140	93
140	95
140	144
140	175
141	93
141	144
141	175
142	93
142	95
142	144
143	93
143	144
143	154
143	170
143	172
143	173
144	93
144	154
144	170
144	172
144	173
145	93
145	95
145	144
146	95
146	144
147	144
148	97
148	105
148	106
148	149
149	97
149	105
149	106
149	149
150	106
150	117
150	129
150	149
150	150
150	159
151	105
151	117
151	149
151	159
152	105
152	106
153	97
153	117
153	149
153	159
153	164
154	7
154	71
154	139
155	7
155	70
155	71
155	79
155	94
155	112
155	123
155	132
155	178
156	5
156	7
156	64
156	67
156	70
156	75
156	76
156	79
156	92
156	94
156	109
156	112
156	123
156	124
156	127
156	132
156	151
156	156
156	163
157	7
157	71
157	139
158	7
158	71
158	123
159	5
159	7
159	64
159	67
159	75
159	76
159	79
159	92
159	109
159	112
159	124
159	127
159	151
159	156
159	163
160	137
160	162
163	137
163	162
167	5
167	64
167	67
167	68
167	76
167	80
167	92
167	126
168	5
168	68
168	76
168	80
168	126
169	68
169	126
170	68
171	68
171	126
172	138
173	138
174	138
175	138
10	29
12	29
23	29
16	29
20	29
8	29
21	29
9	29
123	29
122	29
14	29
82	29
107	29
\.


--
-- Data for Name: metier_serie; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.metier_serie (id_metier, id_serie, niveau_compatibilite) FROM stdin;
1	1	directe
1	4	directe
2	1	directe
4	1	directe
5	2	directe
5	3	directe
8	1	directe
8	4	directe
9	1	directe
9	3	directe
10	1	directe
10	4	directe
14	1	directe
14	4	directe
15	1	directe
15	4	directe
16	1	directe
16	4	directe
17	1	directe
17	2	directe
17	4	directe
18	1	directe
20	1	directe
20	4	directe
22	1	directe
22	4	directe
24	1	directe
25	1	directe
25	2	directe
26	1	directe
26	2	directe
27	1	directe
28	1	directe
29	1	directe
29	4	directe
30	1	directe
31	1	directe
31	2	directe
32	1	directe
33	1	directe
34	1	directe
37	1	directe
37	4	directe
38	1	directe
38	2	directe
39	1	directe
39	4	directe
41	1	directe
41	4	directe
42	1	directe
42	4	directe
45	1	directe
45	4	directe
46	1	directe
46	4	directe
47	1	directe
47	4	directe
48	1	directe
48	2	directe
49	1	directe
50	1	directe
50	4	directe
68	3	directe
68	4	directe
69	4	directe
71	1	directe
71	4	directe
72	3	directe
72	4	directe
75	2	directe
75	3	directe
76	3	directe
76	4	directe
79	3	directe
79	4	directe
81	1	directe
81	3	directe
82	1	directe
82	4	directe
83	1	directe
84	1	directe
85	1	directe
85	4	directe
87	1	directe
87	4	directe
88	1	directe
88	4	directe
89	1	directe
89	4	directe
90	3	directe
90	4	directe
92	1	directe
93	1	directe
93	4	directe
94	1	directe
94	4	directe
95	1	directe
95	3	directe
98	1	directe
98	4	directe
99	1	directe
100	1	directe
100	4	directe
101	1	directe
101	3	directe
102	1	directe
102	3	directe
103	3	directe
104	3	directe
105	3	directe
106	2	directe
106	3	directe
108	1	directe
108	3	directe
109	2	directe
109	3	directe
110	1	directe
110	3	directe
112	2	directe
112	3	directe
113	2	directe
113	3	directe
114	2	directe
114	3	directe
115	3	directe
116	2	directe
116	3	directe
117	2	directe
117	3	directe
118	1	directe
118	3	directe
119	2	directe
119	3	directe
120	2	directe
120	3	directe
121	2	directe
121	3	directe
122	1	directe
122	2	directe
122	3	directe
122	4	directe
122	5	directe
123	1	directe
123	2	directe
124	1	directe
124	2	directe
124	3	directe
124	4	directe
124	5	directe
125	1	directe
125	2	directe
126	1	directe
126	2	directe
127	1	directe
128	2	directe
128	3	directe
129	2	directe
129	3	directe
130	1	directe
131	2	directe
131	3	directe
132	2	directe
133	2	directe
133	3	directe
134	2	directe
134	4	directe
135	2	directe
135	4	directe
136	2	directe
137	2	directe
137	4	directe
138	2	directe
138	3	directe
139	2	directe
139	3	directe
140	2	directe
140	3	directe
142	2	directe
142	3	directe
143	2	directe
143	3	directe
144	2	directe
145	2	directe
145	3	directe
146	2	directe
146	3	directe
146	4	directe
147	2	directe
147	3	directe
147	4	directe
148	2	directe
148	3	directe
149	3	directe
150	2	directe
150	3	directe
151	2	directe
151	3	directe
154	1	directe
154	2	directe
154	3	directe
155	2	directe
155	3	directe
156	2	directe
156	3	directe
157	2	directe
157	3	directe
157	4	directe
159	2	directe
159	3	directe
160	1	directe
160	4	directe
161	1	directe
161	4	directe
162	1	directe
162	4	directe
164	1	directe
164	4	directe
167	2	directe
167	3	directe
168	2	directe
168	3	directe
169	1	directe
169	2	directe
169	3	directe
170	2	directe
170	3	directe
171	2	directe
171	3	directe
172	2	directe
172	3	directe
173	2	directe
173	3	directe
174	2	directe
174	3	directe
175	2	directe
175	3	directe
\.


--
-- Data for Name: profil_riasec; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profil_riasec (code, nom, description, forces, competences, environnements, actif, date_creation, date_modification) FROM stdin;
RI	Réaliste - Investigateur	Vous aimez comprendre le fonctionnement des choses et résoudre des problèmes concrets par l'observation, l'analyse et l'expérimentation. Vous vous épanouissez lorsque la réflexion mène à une solution technique ou pratique.	["Analyse", "Précision", "Esprit logique", "Observation"]	["Résolution de problèmes", "Analyse technique", "Recherche de solutions", "Méthodes scientifiques"]	["Laboratoires", "Bureaux techniques", "Centres de recherche", "Industries"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
RA	Réaliste - Artistique	Vous aimez créer et réaliser des projets tangibles tout en donnant une place importante à l'imagination et au sens esthétique. Vous appréciez de transformer une idée en réalisation visible et utile.	["Créativité appliquée", "Habileté pratique", "Capacité de conception", "Résolution de problèmes"]	["Conception de projets", "Création et innovation", "Analyse technique", "Utilisation d'outils spécialisés"]	["Bureaux d'études", "Ateliers de conception", "Laboratoires", "Structures créatives"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
RS	Réaliste - Social	Vous appréciez les activités pratiques qui ont une utilité directe pour les autres. Vous aimez agir sur le terrain, apporter une aide concrète et contribuer à des solutions simples, humaines et efficaces.	["Sens pratique", "Entraide", "Responsabilité", "Adaptation"]	["Accompagnement technique", "Communication pratique", "Résolution de problèmes", "Travail en équipe"]	["Services techniques", "Organisations sociales", "Structures d'accompagnement", "Entreprises de terrain"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
RE	Réaliste - Entreprenant	Vous aimez passer à l'action, prendre des initiatives et voir des résultats concrets. Vous combinez goût du terrain, organisation et envie de faire avancer un projet ou une équipe.	["Leadership", "Initiative", "Organisation", "Détermination"]	["Gestion de projet", "Prise de décision", "Coordination", "Planification"]	["Entreprises", "Chantiers", "Organisations commerciales", "Structures entrepreneuriales"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
RC	Réaliste - Conventionnel	Vous aimez les activités concrètes menées avec méthode, précision et sens de l'organisation. Vous êtes à l'aise lorsque les procédures sont claires et que la qualité du travail dépend de votre rigueur.	["Rigueur", "Précision", "Organisation", "Fiabilité"]	["Gestion technique", "Organisation de données", "Application de procédures", "Contrôle qualité"]	["Entreprises techniques", "Administrations", "Services opérationnels", "Bureaux professionnels"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
IR	Investigateur - Réaliste	Vous êtes curieux, méthodique et attiré par la compréhension des phénomènes. Vous aimez mobiliser vos connaissances pour diagnostiquer un problème et proposer une réponse applicable dans la réalité.	["Curiosité", "Esprit scientifique", "Rigueur", "Logique"]	["Recherche", "Analyse de données", "Expérimentation", "Diagnostic"]	["Laboratoires", "Centres de recherche", "Entreprises technologiques", "Institutions scientifiques"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
AR	Artistique - Réaliste	Vous êtes créatif et aimez donner forme à vos idées. Vous combinez imagination, sens esthétique et capacité à concrétiser vos projets à l'aide de techniques, d'outils ou de matériaux.	["Imagination", "Expression créative", "Sens esthétique", "Adaptation"]	["Création artistique", "Conception visuelle", "Innovation", "Réalisation de projets"]	["Agences créatives", "Studios", "Ateliers artistiques", "Entreprises de création"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
SR	Social - Réaliste	Vous aimez aider les autres par des actions concrètes et utiles. L'écoute, l'accompagnement et le sens pratique se complètent chez vous pour répondre efficacement à des besoins réels.	["Empathie", "Écoute", "Organisation", "Pragmatisme"]	["Accompagnement", "Formation", "Gestion de situations concrètes", "Communication"]	["Associations", "Établissements éducatifs", "Services publics", "Structures d'aide"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
ER	Entreprenant - Réaliste	Vous êtes motivé par les défis, la coordination d'actions et l'atteinte d'objectifs visibles. Vous aimez transformer une idée en action, mobiliser les moyens nécessaires et obtenir des résultats concrets.	["Ambition", "Leadership", "Organisation", "Esprit d'action"]	["Management", "Négociation", "Gestion d'équipe", "Développement de projets"]	["Entreprises", "Startups", "Organisations commerciales", "Structures de gestion"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
CR	Conventionnel - Réaliste	Vous aimez organiser les informations et appliquer des méthodes fiables dans des situations concrètes. Votre sens du détail et votre méthode soutiennent la bonne exécution des activités quotidiennes.	["Organisation", "Méthode", "Attention aux détails", "Fiabilité"]	["Gestion administrative", "Suivi des procédures", "Analyse d'informations", "Planification"]	["Administrations", "Entreprises", "Services de gestion", "Organisations structurées"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
IA	Investigateur - Artistique	Vous aimez explorer des idées, comprendre des situations complexes et imaginer des réponses originales. Vous réunissez curiosité intellectuelle, pensée critique et créativité.	["Curiosité intellectuelle", "Créativité", "Analyse", "Innovation"]	["Recherche", "Analyse de données", "Création de solutions", "Pensée critique"]	["Laboratoires", "Centres d'innovation", "Bureaux de recherche", "Structures créatives"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
AI	Artistique - Investigateur	Vous aimez exprimer votre créativité tout en cherchant à comprendre les idées et les phénomènes qui vous entourent. Vous appréciez les projets qui demandent imagination, recherche et réflexion.	["Imagination", "Réflexion", "Sens de l'analyse", "Créativité"]	["Conception", "Recherche", "Analyse", "Communication d'idées"]	["Studios", "Laboratoires créatifs", "Agences", "Centres de recherche"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
IS	Investigateur - Social	Vous aimez comprendre les personnes et les situations afin de leur être utile. Vous vous intéressez à l'analyse, à la transmission des connaissances et à l'accompagnement fondé sur la réflexion.	["Analyse", "Écoute", "Curiosité", "Empathie"]	["Analyse comportementale", "Recherche", "Accompagnement", "Résolution de problèmes"]	["Établissements éducatifs", "Centres de recherche", "Structures sociales", "Institutions"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
SI	Social - Investigateur	Vous aimez accompagner les autres en vous appuyant sur l'observation, l'écoute et la compréhension des besoins. Vous recherchez des solutions utiles, adaptées et fondées sur une analyse sérieuse.	["Empathie", "Analyse", "Patience", "Écoute"]	["Conseil", "Recherche", "Formation", "Analyse des besoins"]	["Écoles", "Centres sociaux", "Institutions", "Organisations d'aide"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
IE	Investigateur - Entreprenant	Vous aimez analyser des problèmes complexes et utiliser vos connaissances pour faire avancer des projets. Vous êtes stimulé par l'innovation, la stratégie et la possibilité de prendre des initiatives réfléchies.	["Analyse stratégique", "Autonomie", "Innovation", "Esprit d'initiative"]	["Analyse de projet", "Prise de décision", "Recherche de solutions", "Gestion de projet"]	["Entreprises technologiques", "Startups", "Bureaux d'études", "Organisations innovantes"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
EI	Entreprenant - Investigateur	Vous aimez conduire des projets en vous appuyant sur l'analyse, la stratégie et la recherche d'informations. Vous êtes à l'aise pour décider, organiser et mobiliser une équipe vers un objectif.	["Leadership", "Réflexion stratégique", "Organisation", "Initiative"]	["Management", "Analyse stratégique", "Développement de projets", "Innovation"]	["Entreprises", "Cabinets de conseil", "Startups", "Organisations professionnelles"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
IC	Investigateur - Conventionnel	Vous aimez étudier les informations avec précision, comprendre les systèmes et travailler selon des méthodes fiables. Vous appréciez les environnements où l'analyse et l'organisation vont de pair.	["Rigueur", "Analyse", "Organisation", "Précision"]	["Analyse de données", "Gestion d'informations", "Recherche", "Documentation"]	["Laboratoires", "Services d'analyse", "Administrations", "Entreprises"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
CI	Conventionnel - Investigateur	Vous aimez organiser les informations et rechercher des solutions logiques, cohérentes et efficaces. Votre méthode vous aide à traiter des données complexes avec fiabilité.	["Méthode", "Organisation", "Logique", "Fiabilité"]	["Gestion de données", "Analyse", "Contrôle", "Planification"]	["Administrations", "Entreprises", "Services financiers", "Organisations structurées"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
AS	Artistique - Social	Vous aimez créer, communiquer et mettre votre sensibilité au service des autres. Vous appréciez les activités qui permettent d'exprimer des idées, de transmettre un message ou de soutenir un public.	["Créativité", "Empathie", "Communication", "Expression"]	["Création de contenus", "Communication", "Expression artistique", "Accompagnement"]	["Associations", "Agences de communication", "Structures culturelles", "Organisations sociales"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
SA	Social - Artistique	Vous aimez accompagner les personnes tout en utilisant votre créativité pour expliquer, sensibiliser ou transmettre. Les projets collectifs et les formes d'expression qui créent du lien vous conviennent particulièrement.	["Écoute", "Créativité", "Communication", "Sensibilité"]	["Animation", "Formation", "Communication", "Création pédagogique"]	["Écoles", "Associations", "Centres culturels", "Organisations d'accompagnement"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
AE	Artistique - Entreprenant	Vous aimez imaginer, créer et faire grandir des projets. Vous combinez créativité, autonomie et capacité à convaincre pour transformer une idée en initiative concrète.	["Créativité", "Leadership", "Innovation", "Autonomie"]	["Création de projets", "Communication", "Entrepreneuriat", "Gestion d'idées"]	["Startups", "Agences créatives", "Entreprises innovantes", "Structures entrepreneuriales"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
EA	Entreprenant - Artistique	Vous aimez diriger des projets créatifs, défendre une vision et développer de nouvelles idées. Vous êtes stimulé par la communication, l'innovation et la réalisation d'objectifs ambitieux.	["Leadership", "Créativité", "Ambition", "Communication"]	["Gestion de projets", "Marketing", "Négociation", "Développement d'activités"]	["Entreprises", "Agences", "Startups", "Organisations commerciales"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
AC	Artistique - Conventionnel	Vous aimez produire des réalisations créatives dans un cadre organisé. Vous trouvez un bon équilibre entre imagination, précision et respect des étapes nécessaires à un projet de qualité.	["Créativité", "Organisation", "Précision", "Adaptation"]	["Conception", "Gestion de contenu", "Organisation de projets", "Présentation d'informations"]	["Agences", "Services de communication", "Entreprises", "Structures organisées"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
CA	Conventionnel - Artistique	Vous aimez structurer les informations et apporter une touche créative pour améliorer un support, un processus ou une présentation. Vous êtes à l'aise dans les projets qui demandent à la fois méthode et sens visuel.	["Organisation", "Créativité", "Rigueur", "Méthode"]	["Gestion documentaire", "Organisation visuelle", "Analyse d'informations", "Création de supports"]	["Administrations", "Entreprises", "Services de communication", "Organisations structurées"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
SE	Social - Entreprenant	Vous aimez aider, conseiller et mobiliser les autres autour d'un objectif. Vous combinez sens relationnel, initiative et capacité à organiser des projets ou des équipes.	["Empathie", "Leadership", "Communication", "Organisation"]	["Accompagnement", "Gestion d'équipe", "Communication", "Coordination de projets"]	["Associations", "Entreprises", "Institutions", "Structures éducatives"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
ES	Entreprenant - Social	Vous aimez influencer, organiser et diriger tout en maintenant un lien fort avec les autres. Vous êtes stimulé par la communication, la coordination et la capacité à faire progresser un collectif.	["Leadership", "Communication", "Organisation", "Motivation des autres"]	["Management", "Négociation", "Gestion de projets", "Animation d'équipe"]	["Entreprises", "Cabinets de conseil", "Institutions", "Organisations sociales"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
SC	Social - Conventionnel	Vous aimez aider les autres dans un cadre organisé, où la méthode et le suivi sont importants. Votre sens du service s'exprime pleinement lorsque vous pouvez apporter un accompagnement fiable et structuré.	["Écoute", "Organisation", "Patience", "Fiabilité"]	["Gestion administrative", "Accompagnement", "Organisation", "Suivi de dossiers"]	["Administrations", "Établissements éducatifs", "Services sociaux", "Institutions"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
CS	Conventionnel - Social	Vous aimez travailler avec des informations organisées tout en contribuant au bon accueil et à l'accompagnement des personnes. Vous combinez rigueur, sens du service et responsabilité.	["Rigueur", "Organisation", "Sens du service", "Responsabilité"]	["Gestion de documents", "Communication", "Suivi administratif", "Organisation"]	["Administrations", "Écoles", "Services publics", "Entreprises"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
EC	Entreprenant - Conventionnel	Vous aimez atteindre des objectifs, organiser les ressources et prendre des décisions dans un cadre structuré. Vous appréciez les responsabilités qui demandent planification, efficacité et sens du résultat.	["Leadership", "Organisation", "Prise de décision", "Efficacité"]	["Management", "Gestion financière", "Planification", "Coordination"]	["Entreprises", "Banques", "Cabinets de gestion", "Organisations commerciales"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
CE	Conventionnel - Entreprenant	Vous aimez organiser les ressources et assurer le bon fonctionnement d'une activité. Vous combinez méthode, rigueur et initiative pour contribuer à la réalisation d'objectifs collectifs.	["Méthode", "Organisation", "Rigueur", "Responsabilité"]	["Gestion administrative", "Analyse financière", "Planification", "Suivi d'activités"]	["Entreprises", "Administrations", "Services financiers", "Organisations structurées"]	t	2026-09-24 17:39:18.930462+00	2026-09-24 17:39:18.930462+00
\.


--
-- Data for Name: proposition; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.proposition (id_proposition, id_question, lettre, libelle, type_riasec) FROM stdin;
1	1	A	Réparer ou assembler des objets	R
2	1	B	Aider des personnes autour de moi	S
3	1	C	Résoudre des problèmes logiques	I
4	1	D	Ranger et organiser mes affaires	C
5	1	E	Dessiner ou créer quelque chose	A
6	1	F	Organiser une sortie ou une activité de groupe	E
7	2	A	Créer une œuvre artistique ou visuelle	A
8	2	B	Construire ou fabriquer un objet concret	R
9	2	C	Améliorer la vie des autres	S
10	2	D	Lancer une entreprise ou un projet commercial	E
11	2	E	Analyser un problème complexe	I
12	2	F	Créer un système organisé et structuré	C
13	3	A	Celui qui dirige et prend les décisions	E
14	3	B	Celui qui agit et fait le travail concret	R
15	3	C	Celui qui organise et structure le travail	C
16	3	D	Celui qui propose des idées créatives	A
17	3	E	Celui qui soutient et écoute les autres	S
18	3	F	Celui qui analyse et trouve les solutions	I
19	4	A	Un bureau organisé et structuré	C
20	4	B	Un environnement dynamique et compétitif	E
21	4	C	Un laboratoire ou un environnement d’analyse	I
22	4	D	Un studio créatif ou artistique	A
23	4	E	Un environnement humain et collaboratif	S
24	4	F	Un atelier ou un lieu pratique	R
25	5	A	Technologie, sciences physiques appliquées ou technique industrielle	R
26	5	B	Mathématiques, sciences physiques ou SVT	I
27	5	C	Arts plastiques, littérature ou philosophie	A
28	5	D	Sciences humaines, langues ou éducation civique	S
29	5	E	Économie, management ou sciences commerciales	E
30	5	F	Comptabilité, gestion ou droit	C
31	6	A	Un stage en laboratoire de recherche	I
32	6	B	Un stage dans une ONG ou service social	S
33	6	C	Un stage dans un atelier technique ou industriel	R
34	6	D	Un stage en administration ou bureau organisé	C
35	6	E	Un stage dans un studio créatif ou design	A
36	6	F	Un stage en entreprise ou start-up	E
37	7	D	Aider quelqu’un à résoudre ses difficultés	S
38	7	F	Organiser un système ou améliorer une méthode	C
39	7	A	Résoudre un problème concret ou technique	R
40	7	C	Créer quelque chose d’unique ou artistique	A
41	7	B	Comprendre un problème complexe ou scientifique	I
42	7	E	Atteindre un objectif ambitieux ou gagner	E
43	8	A	Outils manuels ou machines	R
44	8	B	Outils de communication et d’aide	S
45	8	C	Ordinateur pour analyser des données	I
46	8	D	Logiciels de création graphique ou audio	A
47	8	E	Tableurs et logiciels d’organisation	C
48	8	F	Outils de gestion de projet ou business	E
49	9	A	Créer un projet qui a de l’impact ou du profit	E
50	9	B	Organiser des tâches pour que tout soit efficace	C
51	9	C	Comprendre comment fonctionne un système ou une idée	I
52	9	D	Créer quelque chose d’artistique ou original	A
53	9	E	Réparer ou construire quelque chose de concret	R
54	9	F	Aider directement des personnes en difficulté	S
55	10	A	Guides d’organisation ou de gestion	C
56	10	B	Livres scientifiques ou d’analyse	I
57	10	C	Livres pratiques ou techniques	R
58	10	D	Histoires humaines ou sociales	S
59	10	E	Romans, art ou contenus créatifs	A
60	10	F	Livres sur la réussite et l’entrepreneuriat	E
61	11	A	Gérer les relations humaines et l’équipe	S
62	11	B	Analyser les données et stratégies	I
63	11	C	Créer l’image et le design de l’entreprise	A
64	11	D	Diriger et prendre les décisions importantes	E
65	11	E	Organiser la gestion et les procédures	C
66	11	F	Fabriquer ou produire un produit concret	R
67	12	A	Un travail avec des responsabilités et des objectifs	E
68	12	B	Un travail manuel ou technique concret	R
69	12	C	Un travail de réflexion et d’analyse	I
70	12	D	Un travail structuré et organisé	C
71	12	E	Un travail créatif et artistique	A
72	12	F	Un travail basé sur l’aide aux autres	S
73	13	A	Rechercher des informations et analyser les données	I
74	13	B	Organiser les tâches et respecter le planning	C
75	13	C	Construire ou réaliser la partie technique du projet	R
76	13	D	Diriger le groupe et prendre les décisions	E
77	13	E	Créer la présentation ou les éléments visuels	A
78	13	F	Aider et coordonner les membres du groupe	S
79	14	A	Faire une activité manuelle ou sportive	R
80	14	B	Ranger ou organiser mon espace	C
81	14	C	Dessiner, écouter de la musique ou créer	A
82	14	D	Passer du temps avec des amis ou aider quelqu’un	S
83	14	E	Parler de projets ou d’idées ambitieuses	E
84	14	F	Lire ou réfléchir sur un sujet intéressant	I
85	15	A	Résoudre des problèmes logiques ou scientifiques	I
86	15	B	Suivre des procédures claires et structurées	C
87	15	C	Prendre des décisions importantes	E
88	15	D	Créer ou imaginer quelque chose de nouveau	A
89	15	E	Travailler avec des personnes	S
90	15	F	Travailler avec des outils ou objets concrets	R
91	16	A	Avoir créé quelque chose d’unique et artistique	A
92	16	B	Avoir construit ou réparé quelque chose de concret	R
93	16	C	Avoir trouvé une solution à un problème complexe	I
94	16	D	Avoir organisé quelque chose parfaitement	C
95	16	E	Avoir réussi un projet ambitieux ou une entreprise	E
96	16	F	Avoir aidé beaucoup de personnes	S
97	17	A	En travaillant en groupe et en échangeant avec les autres	S
98	17	B	En pratiquant directement avec des outils ou des exercices	R
99	17	C	En étant motivé par des objectifs et des défis	E
100	17	D	En comprenant les théories et les concepts	I
101	17	E	En utilisant des méthodes créatives ou visuelles	A
102	17	F	En suivant des étapes structurées et organisées	C
103	18	A	Mon habileté manuelle ou technique	R
104	18	B	Ma capacité à analyser et résoudre des problèmes	I
105	18	C	Mon sens de l’organisation et de la rigueur	C
106	18	D	Ma créativité et mon imagination	A
107	18	E	Mon sens de l’aide et de l’écoute	S
108	18	F	Mon leadership et ma capacité à convaincre	E
109	19	A	Travaillant dans un domaine créatif ou artistique	A
110	19	B	Travaillant dans un métier manuel ou technique	R
111	19	C	Travaillant dans l’aide ou le social	S
112	19	D	Travaillant dans la recherche ou l’analyse	I
113	19	E	Dans un métier structuré et organisé	C
114	19	F	À la tête d’un projet ou d’une entreprise	E
115	20	A	L’organisation et la planification efficace du travail	C
116	20	B	La pratique et l’application concrète des connaissances	R
117	20	C	La réflexion et l’analyse approfondie des problèmes	I
118	20	D	La réussite et la reconnaissance dans son domaine	E
119	20	E	La créativité et l’innovation dans le travail	A
120	20	F	L’aide et le soutien aux autres dans leur travail	S
\.


--
-- Data for Name: question; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.question (id_question, id_questionnaire, texte, ordre) FROM stdin;
1	1	Quelle activité préfères-tu faire pendant ton temps libre ?	1
2	1	Quel type de projet aimerais-tu réaliser ?	2
3	1	Dans un groupe, quel rôle prends-tu naturellement ?	3
4	1	Quel environnement de travail préfères-tu ?	4
5	1	Quelle matière préfères-tu à l'école ?	5
6	1	Si tu pouvais choisir un stage aujourd'hui, lequel choisirais-tu ?	6
7	1	Quel type de défi te motive le plus ?	7
8	1	Quel outil utiliserais-tu le plus volontiers ?	8
9	1	Quelle activité te semble la plus utile ?	9
10	1	Quel type de livre ou de contenu préfères-tu ?	10
11	1	Si tu créais une entreprise, quel serait ton rôle durant la mise en place ?	11
12	1	Quel type de travail te procure le plus de satisfaction ?	12
13	1	Lors d'un projet scolaire, quel rôle préfères-tu ?	13
14	1	Quelle activité te détend le plus ?	14
15	1	Qu'est-ce qui te stresse le moins ?	15
16	1	Quel type de réussite te rendrait le plus fier(ère) ?	16
17	1	Comment préfères-tu apprendre ?	17
18	1	Quelle qualité apprécies-tu le plus chez toi ?	18
19	1	Dans 10 ans, tu te vois...	19
20	1	Qu'est-ce qui est le plus important pour toi dans une carrière ?	20
\.


--
-- Data for Name: questionnaire; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.questionnaire (id_questionnaire, nom, description, version, actif, date_creation) FROM stdin;
1	Test RIASEC Standard	Questionnaire d'orientation professionnelle basé sur la théorie de John Holland et adapté au contexte africain.	1.0	t	2026-07-23 12:51:37
\.


--
-- Data for Name: recommandation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recommandation (id_recommandation, id_test, id_metier, compatibilite, type, date_recommandation) FROM stdin;
\.


--
-- Data for Name: reponse; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reponse (id_reponse, id_test, id_proposition) FROM stdin;
1278	73	3
1279	73	11
1280	73	14
1281	73	22
1282	73	26
1283	73	34
1284	73	42
1285	73	45
1286	73	49
1287	73	56
1288	73	64
1289	73	67
1290	73	73
1291	73	79
1292	73	87
1293	73	93
1294	73	98
1295	73	104
1296	73	112
1297	73	118
1398	79	3
1399	79	12
1400	79	14
1401	79	19
1402	79	30
1403	79	34
1404	79	42
1405	79	45
1406	79	50
1407	79	55
1408	79	65
1409	79	70
1410	79	75
1411	79	83
1412	79	90
1413	79	95
1414	79	98
1415	79	108
1416	79	114
1417	79	118
1518	85	3
1519	85	9
1520	85	18
1521	85	21
1522	85	26
1523	85	32
1524	85	38
1525	85	48
1526	85	51
1527	85	60
1528	85	61
1529	85	67
1530	85	76
1531	85	83
1532	85	89
1533	85	95
1534	85	98
1535	85	108
1536	85	114
1537	85	119
1298	74	3
1299	74	11
1300	74	14
1301	74	19
1302	74	26
1303	74	36
1304	74	41
1305	74	45
1306	74	49
1307	74	56
1308	74	64
1309	74	70
1310	74	73
1311	74	79
1312	74	89
1313	74	93
1314	74	97
1315	74	107
1316	74	113
1317	74	116
1418	80	6
1419	80	11
1420	80	16
1421	80	21
1422	80	26
1423	80	31
1424	80	39
1425	80	44
1426	80	54
1427	80	60
1428	80	64
1429	80	69
1430	80	76
1431	80	79
1432	80	89
1433	80	96
1434	80	100
1435	80	107
1436	80	112
1437	80	116
1538	86	3
1539	86	9
1540	86	15
1541	86	21
1542	86	26
1543	86	31
1544	86	41
1545	86	44
1546	86	54
1547	86	56
1548	86	66
1549	86	67
1550	86	73
1551	86	82
1552	86	86
1553	86	96
1554	86	99
1555	86	103
1556	86	112
1557	86	116
1318	75	2
1319	75	9
1320	75	16
1321	75	21
1322	75	26
1323	75	31
1324	75	42
1325	75	45
1326	75	49
1327	75	60
1328	75	62
1329	75	69
1330	75	78
1331	75	79
1332	75	89
1333	75	96
1334	75	97
1335	75	107
1336	75	112
1337	75	118
1438	81	3
1439	81	12
1440	81	13
1441	81	19
1442	81	26
1443	81	36
1444	81	38
1445	81	45
1446	81	49
1447	81	56
1448	81	65
1449	81	67
1450	81	78
1451	81	84
1452	81	90
1453	81	95
1454	81	100
1455	81	104
1456	81	114
1457	81	118
1558	87	6
1559	87	10
1560	87	17
1561	87	19
1562	87	29
1563	87	33
1564	87	42
1565	87	43
1566	87	49
1567	87	58
1568	87	62
1569	87	67
1570	87	73
1571	87	81
1572	87	88
1573	87	95
1574	87	97
1575	87	106
1576	87	114
1577	87	118
1338	76	2
1339	76	10
1340	76	16
1341	76	19
1342	76	30
1343	76	36
1344	76	42
1345	76	48
1346	76	54
1347	76	55
1348	76	61
1349	76	70
1350	76	78
1351	76	82
1352	76	90
1353	76	96
1354	76	99
1355	76	108
1356	76	114
1357	76	115
1458	82	2
1459	82	7
1460	82	14
1461	82	20
1462	82	25
1463	82	35
1464	82	37
1465	82	46
1466	82	49
1467	82	60
1468	82	63
1469	82	67
1470	82	77
1471	82	84
1472	82	90
1473	82	96
1474	82	101
1475	82	106
1476	82	114
1477	82	119
1578	88	3
1579	88	12
1580	88	18
1581	88	22
1582	88	26
1583	88	36
1584	88	37
1585	88	45
1586	88	51
1587	88	56
1588	88	62
1589	88	69
1590	88	73
1591	88	79
1592	88	88
1593	88	93
1594	88	99
1595	88	106
1596	88	114
1597	88	118
1358	77	2
1359	77	9
1360	77	17
1361	77	21
1362	77	26
1363	77	31
1364	77	42
1365	77	43
1366	77	53
1367	77	56
1368	77	64
1369	77	69
1370	77	78
1371	77	79
1372	77	86
1373	77	93
1374	77	99
1375	77	103
1376	77	112
1377	77	118
1478	83	6
1479	83	10
1480	83	13
1481	83	23
1482	83	27
1483	83	32
1484	83	42
1485	83	44
1486	83	54
1487	83	58
1488	83	64
1489	83	70
1490	83	76
1491	83	82
1492	83	87
1493	83	94
1494	83	97
1495	83	108
1496	83	114
1497	83	118
1238	71	1
1239	71	8
1240	71	14
1241	71	24
1242	71	25
1243	71	33
1244	71	39
1245	71	43
829	49	4
830	49	12
831	49	18
832	49	24
833	49	28
834	49	36
835	49	37
836	49	48
837	49	54
838	49	58
839	49	66
840	49	70
841	49	76
842	49	82
843	49	88
844	49	96
845	49	102
846	49	106
847	49	112
848	49	118
849	50	3
850	50	12
851	50	16
852	50	24
853	50	29
854	50	34
855	50	40
856	50	46
857	50	52
858	50	58
859	50	63
860	50	70
861	50	76
862	50	82
863	50	90
864	50	94
865	50	99
866	50	100
867	50	112
868	50	118
869	51	4
870	51	12
871	51	18
872	51	22
873	51	28
874	51	36
875	51	37
876	51	46
877	51	51
878	51	58
879	51	66
880	51	70
881	51	76
882	51	82
883	51	88
884	51	94
885	51	102
886	51	106
887	51	112
888	51	118
889	52	3
890	52	10
891	52	18
892	52	22
893	52	30
894	52	34
895	52	37
896	52	48
897	52	51
898	52	58
899	52	64
900	52	70
901	52	78
902	52	82
903	52	88
904	52	96
905	52	100
906	52	108
907	52	112
908	52	118
909	53	4
910	53	12
911	53	16
912	53	24
913	53	28
914	53	33
915	53	37
916	53	46
917	53	51
918	53	58
919	53	63
920	53	70
921	53	76
922	53	82
923	53	87
924	53	94
925	53	100
926	53	106
927	53	114
928	53	112
929	54	4
930	54	12
931	54	18
932	54	24
933	54	30
934	54	36
935	54	38
936	54	48
937	54	54
938	54	58
939	54	64
940	54	72
941	54	78
942	54	82
943	54	88
944	54	96
945	54	100
946	54	108
947	54	114
948	54	118
949	55	4
950	55	10
951	55	13
952	55	24
953	55	25
954	55	34
955	55	39
956	55	45
957	55	54
958	55	55
959	55	62
960	55	67
961	55	77
962	55	82
963	55	85
964	55	96
965	55	98
966	55	107
967	55	114
968	55	120
969	56	3
970	56	8
971	56	18
972	56	19
973	56	26
974	56	31
975	56	41
976	56	45
977	56	51
978	56	56
979	56	66
980	56	72
981	56	73
982	56	84
983	56	90
984	56	96
985	56	100
986	56	107
987	56	112
988	56	116
989	57	4
990	57	8
991	57	14
992	57	20
993	57	26
994	57	31
995	57	38
996	57	45
997	57	49
998	57	59
999	57	66
1000	57	72
1001	57	73
1002	57	84
1003	57	85
1004	57	95
1005	57	98
1006	57	107
1007	57	112
1008	57	118
1009	58	2
1010	58	8
1011	58	14
1012	58	20
1013	58	27
1014	58	32
1015	58	40
1016	58	44
1017	58	51
1018	58	57
1019	58	63
1020	58	69
1021	58	68
1022	58	81
1023	58	87
1024	58	96
1025	58	98
1026	58	103
1027	58	110
1028	58	115
1029	59	1
1030	59	10
1031	59	18
1032	59	24
1033	59	29
1034	59	36
1035	59	41
1036	59	45
1037	59	51
1038	59	55
1039	59	65
1040	59	67
1041	59	73
1042	59	79
1043	59	85
1044	59	95
1045	59	97
1046	59	104
1047	59	112
1048	59	115
1246	71	53
1247	71	57
1248	71	66
1249	71	68
1250	71	75
1054	61	1
1055	61	9
1056	61	17
1057	61	23
1058	61	29
1059	61	35
1060	61	42
1061	61	47
1062	61	53
1063	61	59
1064	61	57
1065	61	71
1066	61	76
1067	61	82
1068	61	89
1069	61	94
1070	61	101
1071	61	107
1072	61	113
1073	61	118
1251	71	81
1252	71	90
1253	71	92
1254	71	97
1255	71	103
1256	71	110
1257	71	119
1378	78	4
1379	78	10
1380	78	14
1381	78	19
1382	78	26
1383	78	33
1384	78	41
1385	78	43
1386	78	50
1387	78	58
1388	78	64
1389	78	67
1390	78	75
1391	78	79
1392	78	85
1393	78	93
1394	78	99
1098	64	2
1099	64	9
1100	64	17
1101	64	19
1102	64	26
1103	64	34
1104	64	37
1105	64	45
1106	64	54
1107	64	55
1108	64	64
1109	64	69
1110	64	78
1111	64	84
1112	64	90
1113	64	96
1114	64	101
1115	64	107
1116	64	113
1117	64	117
1118	65	2
1119	65	10
1120	65	14
1121	65	19
1122	65	29
1123	65	36
1124	65	38
1125	65	44
1126	65	51
1127	65	60
1128	65	61
1129	65	67
1130	65	73
1131	65	84
1132	65	79
1133	65	95
1134	65	97
1135	65	108
1136	65	114
1137	65	119
1138	66	4
1139	66	7
1140	66	13
1141	66	21
1142	66	27
1143	66	31
1144	66	37
1145	66	43
1146	66	54
1147	66	58
1148	66	63
1149	66	72
1150	66	77
1151	66	81
1152	66	89
1153	66	96
1154	66	102
1155	66	107
1156	66	111
1157	66	120
1158	67	4
1159	67	10
1160	67	15
1161	67	21
1162	67	30
1163	67	36
1164	67	41
1165	67	45
1166	67	53
1167	67	60
1168	67	61
1169	67	67
1170	67	75
1171	67	81
1172	67	89
1173	67	96
1174	67	99
1175	67	107
1176	67	114
1177	67	115
1178	68	1
1179	68	8
1180	68	13
1181	68	23
1182	68	25
1183	68	33
1184	68	39
1185	68	43
1186	68	49
1187	68	57
1188	68	62
1189	68	71
1190	68	75
1191	68	83
1192	68	89
1193	68	91
1194	68	97
1195	68	103
1196	68	114
1197	68	120
1198	69	4
1199	69	10
1200	69	13
1201	69	20
1202	69	29
1203	69	36
1204	69	42
1205	69	48
1206	69	49
1207	69	60
1208	69	64
1209	69	67
1210	69	76
1211	69	83
1212	69	89
1213	69	95
1214	69	102
1215	69	108
1216	69	114
1217	69	119
1218	70	2
1219	70	10
1220	70	13
1221	70	24
1222	70	27
1223	70	36
1224	70	42
1225	70	43
1226	70	49
1227	70	58
1228	70	61
1229	70	67
1230	70	76
1231	70	83
1232	70	89
1233	70	95
1234	70	98
1235	70	108
1236	70	114
1237	70	118
1258	72	1
1259	72	8
1260	72	14
1261	72	24
1262	72	25
1263	72	33
1264	72	39
1265	72	43
1266	72	53
1267	72	57
1268	72	66
1269	72	68
1270	72	75
1271	72	79
1272	72	90
1273	72	92
1274	72	102
1275	72	103
1276	72	110
1277	72	119
1395	78	106
1396	78	110
1397	78	116
1498	84	5
1499	84	8
1500	84	18
1501	84	21
1502	84	26
1503	84	33
1504	84	39
1505	84	43
1506	84	51
1507	84	56
1508	84	66
1509	84	68
1510	84	75
1511	84	79
1512	84	85
1513	84	92
1514	84	98
1515	84	104
1516	84	110
1517	84	116
\.


--
-- Data for Name: serie; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.serie (id_serie, nom, description) FROM stdin;
1	Scientifique	Série orientée vers les sciences, les mathématiques et les disciplines scientifiques.
2	Littéraire	Série orientée vers les lettres, les langues, les sciences humaines et les disciplines littéraires.
3	Économique et gestion	Série orientée vers l’économie, la gestion, le commerce et les disciplines associées.
4	Technique	Série orientée vers les sciences et techniques appliquées.
5	Autre	Autre parcours ou série scolaire.
\.


--
-- Data for Name: test_riasec; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.test_riasec (id_test, id_user, id_questionnaire, date_test, score_r, score_i, score_a, score_s, score_e, score_c, profil_dominant) FROM stdin;
85	65	1	2026-09-25 13:31:24.219	1	5	1	4	8	1	EI
44	24	1	2026-09-12 11:43:49.018	6	3	4	4	2	1	RA
45	26	1	2026-09-12 11:57:19.035	4	2	2	5	3	4	SR
46	24	1	2026-09-12 14:54:37.483	3	4	3	4	1	5	CI
47	24	1	2026-09-12 14:54:48.434	3	4	3	4	1	5	CI
48	24	1	2026-09-12 15:25:33.196	0	5	4	4	2	4	IA
49	24	1	2026-09-12 15:42:44.198	2	2	2	6	4	4	SE
50	24	1	2026-09-12 15:45:23.911	2	3	5	2	4	4	AE
51	24	1	2026-09-12 15:54:07.142	1	3	4	4	3	5	CA
52	24	1	2026-09-12 15:56:15.808	0	5	2	5	5	3	IS
53	24	1	2026-09-12 16:10:02.868	2	3	4	4	3	4	AS
54	24	1	2026-09-12 16:51:35.184	1	2	1	6	6	4	SE
55	29	1	2026-09-12 19:24:28.533	4	3	1	5	4	3	SR
56	28	1	2026-09-12 19:34:56.717	4	12	0	3	0	1	IR
57	28	1	2026-09-12 19:47:44.916	4	7	1	2	4	2	IR
58	31	1	2026-09-12 21:02:07.377	7	2	4	4	2	1	RA
59	32	1	2026-09-12 21:23:02.415	3	8	0	1	5	3	IE
60	33	1	2026-09-12 21:25:57.661	2	0	1	3	8	4	EC
61	34	1	2026-09-12 21:26:46.399	3	0	4	6	4	3	SA
62	34	1	2026-09-12 23:58:45.527	1	2	7	5	1	3	AS
63	37	1	2026-09-13 11:32:23.129	4	3	1	3	6	2	ER
64	38	1	2026-09-13 13:40:33.821	1	5	1	8	1	4	SI
65	39	1	2026-09-13 13:43:24.394	2	3	1	4	8	2	ES
66	44	1	2026-09-14 23:07:17.879	1	2	5	9	1	2	SA
67	44	1	2026-09-14 23:15:00.948	2	3	1	4	6	4	ES
68	45	1	2026-09-15 01:16:41.85	9	1	2	4	4	0	RS
69	46	1	2026-09-15 20:54:58.44	0	0	1	1	16	2	EC
70	48	1	2026-09-16 19:04:05.267	3	0	1	4	12	0	ES
71	49	1	2026-09-16 20:13:49.135	17	0	2	1	0	0	RA
72	49	1	2026-09-16 20:22:44.808	18	0	1	0	0	1	RA
73	50	1	2026-09-22 22:16:11.322	3	9	1	0	6	1	IE
74	50	1	2026-09-22 23:46:34.438	3	8	0	3	3	3	IR
75	51	1	2026-09-23 19:36:17.512	1	7	1	7	4	0	IS
76	54	1	2026-09-23 20:44:13.253	1	0	1	6	7	5	ES
77	55	1	2026-09-23 21:14:43.262	4	7	0	4	4	1	IR
78	56	1	2026-09-23 21:22:38.22	7	4	1	1	4	3	RI
79	58	1	2026-09-23 22:06:42.241	4	2	0	0	6	8	CE
80	59	1	2026-09-23 22:48:20.216	3	7	1	5	4	0	IS
81	60	1	2026-09-23 23:05:36.665	1	7	0	1	7	4	IE
82	53	1	2026-09-24 19:29:06.877	3	1	8	3	5	0	AE
83	62	1	2026-09-24 22:20:17.526	0	0	1	7	10	2	ES
84	64	1	2026-09-25 01:28:19.958	12	7	1	0	0	0	RI
86	73	1	2026-09-28 01:12:37.585	3	8	0	5	2	2	IS
87	74	1	2026-09-28 13:38:11.646	2	2	3	3	9	1	EA
88	52	1	2026-09-28 17:25:46.544	1	10	3	1	4	1	IE
89	24	1	2026-09-29 10:32:01.023	0	5	4	1	5	4	IE
\.


--
-- Data for Name: universite; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.universite (id_universite, nom, description, type, pays, ville, region, adresse, telephone, email, site_web, logo) FROM stdin;
64	EMIA	Université africaine des sciences et technologies	privee	Sénégal	Dakar	Dakar	Sicap Foire, N° 10753, Dakar, Sénégal	+221 33 824 63 10 / +221 77 669 61 61	contact@emia-sn.com	https://emia-sn.com/	/assets/logo/universites/EMIA.png
2	UGB	Université Gaston Berger de Saint-Louis	publique	Sénégal	Saint-Louis	Saint-Louis	Route de Ngallèle, Nationale 2, BP 234, Saint-Louis	+221 33 961 23 45	dcm@ugb.edu.sn / webmaster@ugb.edu.sn	https://ugb.sn	/assets/logo/universites/UGB.png
3	UIDT	Université Iba Der Thiam de Thiès	publique	Sénégal	Thiès	Thiès	Quartier Escale / Voie Contournement Nord (VCN), Thiès	+221 33 894 40 00	info@uidt.sn	https://www.uidt.sn	/assets/logo/universites/UIDT.png
4	ESP	École Supérieure Polytechnique de Dakar	publique	Sénégal	Dakar	Dakar	Campus universitaire de l'UCAD, Corniche Ouest, BP 5085, Dakar-Fann	+221 33 824 05 40	esp@esp.sn	https://www.esp.sn	/assets/logo/universites/ESP.png
29	 ISI	Institut Supérieur d'Informatique	privee	Sénégal	Dakar	Dakar	Km 1, Avenue Cheikh Anta Diop, Dakar	+221 33 822 19 81	contact@groupeisi.com / isi@isi.sn	https://groupeisi.com	/assets/logo/universites/ISI.png
31	ESEBAT	École Supérieure d'Électricité, du Bâtiment et des Travaux Publics	privee	Sénégal	Dakar	Dakar	Rue de Ziguinchor, Boulevard SUD, Point E, Dakar	+221 33 825 44 42 / +221 78 197 50 50	esebat@esebat.com	https://www.esebat.com	/assets/logo/universites/ESEBAT.png
5	SUPDECO	École Supérieure de Commerce de Dakar	privee	Sénégal	Dakar	Dakar	7, Avenue Faidherbe, BP 21354, Dakar	+221 33 849 69 19 / +221 33 859 95 95	admission@supdeco.edu.sn	https://supdeco.sn	/assets/logo/universites/SUPDECO.png
6	UASZ	Université Assane Seck de Ziguinchor	publique	Sénégal	Ziguinchor	Ziguinchor	Quartier Diabir	+221 33 991 68 09	rectorat@univ-zig.sn	https://uasz.sn	/assets/logo/universites/UASZ.png
7	UADB	Université Alioune Diop de Bambey	publique	Sénégal	Bambey	Diourbel	Quartier Escale, Bambey (Dispose d'un Centre de Ressources à Dakar sur la VDN, Mermoz Pyrotechnie, Villa n°3)	+221 33 973 30 86 (Bambey) / +221 33 860 64 67 (Dakar)	rectorat@uadb.edu.sn / crd@uadb.edu.sn	https://uadb.edu.sn	/assets/logo/universites/UADB.png
8	UNCHK (ex UVS)	Université numérique Cheikh Hamidou Kane	publique	Sénégal	Dakar	Dakar	Siège : Cité du Savoir, Diamniadio (BP 15126 Dakar-Fann)	+221 30 108 41 53	contact@unchk.edu.sn	https://www.unchk.sn/	/assets/logo/universites/UNCHK.png
9	USSEIN	Université du Sine Saloum El Hadji Ibrahima Niass	publique	Sénégal	Kaolack	Kaolack	Quartier Kasnack (Face ex-Cinéma ABC), Kaolack	+221 33 942 29 29 / +221 33 959 11 82	secretariat@ussein.edu.sn / scolarite@ussein.edu.sn	https://ussein.sn	/assets/logo/universites/USSEIN.png
10	ENSAE	École Nationale de la Statistique et de l’Analyse Économique	publique	Sénégal	Dakar	Dakar	Rocade Fann Bel-Air, Cerf-Volant (Près de la Maison du Parti, Colobane), Dakar	+221 33 825 15 19	scolarite.ensae@ansd.sn	https://www.ensae.sn/	/assets/logo/universites/ENSAE.png
11	ENSA	École Nationale Supérieure d’Agriculture	publique	Sénégal	Thiès	Thiès	Route de Khombole, BP A296, Thiès	+221 33 939 59 26 / +221 33 939 59 25	secretariat@ensa.edu.sn / ensath@orange.sn	https://www.concoursensa.com/	/assets/logo/universites/ENSA.png
12	EPT	École Polytechnique de Thiès	publique	Sénégal	Thiès	Thiès	Quartier VCN, Route de Base, Thiès	+221 76 223 61 60 / +221 76 223 61 77	contact@ept.edu.sn	https://ept.edu.sn	/assets/logo/universites/EPT.png
32	CEFER	Centre Européen de Formation en Énergie Renouvelable	privee	Sénégal	Dakar	Dakar	Liberté 6 Extension, Villa Fatima n°6 / Lot n° 442 (près de la Pharmacie Leclerc), Dakar	221 33 827 50 57 / +221 77 360 60 54	ceferdakar@gmail.com	https://ceferdakar.org	/assets/logo/universites/CEFER.png
1	UCAD	Université Cheikh Anta Diop de Dakar, la plus grande université du Sénégal	publique	Sénégal	Dakar	Dakar	Avenue Cheikh Anta Diop, BP 5005, Dakar-Fann	+221 33 825 05 30 / +221 33 825 23 36	rectorat@ucad.edu.sn	https://ucad.sn	/assets/logo/universites/UCAD.png
13	EISMV	École Inter-États des Sciences et Médecine Vétérinaires	publique	Sénégal	Dakar	Dakar	Avenue Cheikh Anta Diop, BP 5077, Dakar-Fann	+221 33 865 10 08 / +221 33 865 10 29	contact@eismv.org / directiongenerale@eismv.org	https://eismv.org	/assets/logo/universites/EISMV.png
14	ENSETP	École Normale Supérieure d’Enseignement Technique et Professionnel	publique	Sénégal	Dakar	Dakar	Campus de l'UCAD, Corniche Ouest, BP 5005, Dakar-Fann	+221 33 821 76 69	ensetp@ucad.edu.sn	https://ensetp.ucad.sn/fr	/assets/logo/universites/ENSETP.png
16	INSEPS	Institut National Supérieur de l’Éducation Populaire et du Sport	publique	Sénégal	Dakar	Dakar	Rue 11 x 18, Médina, Dakar	+221 32 823 33 84	inseps@ucad.edu.sn	https://inseps.ucad.sn	/assets/logo/universites/INSEPS.png
17	EBAD	École des Bibliothécaires, Archivistes et Documentalistes	publique	Sénégal	Dakar	Dakar	Campus de l'Université Cheikh Anta Diop (UCAD), Fann, Dakar	+221 33 825 76 60 / +221 33 864 21 22	ebad@ucad.edu.sn	https://ebad.ucad.sn	/assets/logo/universites/EBAD.png
18	CESAG	Centre Africain d’Études Supérieures en Gestion	publique	Sénégal	Dakar	Dakar	Boulevard du Général de Gaulle x Rue Malick Sy, BP 3802, Dakar	+221 33 839 73 60	courrier@cesag.edu.sn	https://cesag.sn	/assets/logo/universites/CESAG.png
19	CFPT	Centre de Formation Professionnelle et Technique Sénégal-Japon	publique	Sénégal	Dakar	Dakar	Route de l'Aéroport (Sud FIDAK CICES - VDN), Dakar	+221 33 869 82 82 / +221 78 295 74 22	contact@cfptsj.sn	https://www.cfptsj.sn	/assets/logo/universites/CFPT.png
20	ISEP Thiès	Institut Supérieur d'Enseignement Professionnel de Thiès	publique	Sénégal	Thiès	Thiès	Route Nationale 2 x VCN, Thiès	+221 33 951 24 25	sep@isep-thies.edu.sn	https://www.isep-thies.sn	/assets/logo/universites/ISEP_Thies.png
21	ISEP Diamniadio	Institut Supérieur d'Enseignement Professionnel de Diamniadio	publique	Sénégal	Diamniadio	Dakar	Cité du Savoir, Diamniadio	+221 77 548 55 09	contact@isepdiamniadio.com	https://isepdiamniadio.com/	/assets/logo/universites/ISEP_Diamniadio.png
22	ISEP Richard-Toll	Institut Supérieur d'Enseignement Professionnel de Richard-Toll	publique	Sénégal	Richard-Toll	Saint-Louis	Route nationale N°2, Quartier Khouma (En face de la station Neptune), Richard-Toll	+221 33 964 20 16	isep@isep-rt.edu.sn	https://iseprichardtoll.sn/	/assets/logo/universites/ISEP_Richard_Toll.png
23	ISEP Bignona	Institut Supérieur d'Enseignement Professionnel de Bignona	publique	Sénégal	Bignona	Ziguinchor	HLM Médina Plateau, Villa N°2501, Bignona	+221 33 994 07 81	admin@isep-bignona.edu.sn	https://isep-bignona.edu.sn/	/assets/logo/universites/ISEP_Bignona.png
24	ISEP Matam	Institut Supérieur d'Enseignement Professionnel de Matam	publique	Sénégal	Matam	Matam	Quartier Tantadji, Lot n° 365 (en face du fleuve), Matam	+221 33 966 31 22 / +221 33 966 31 23	direction@isepmatam.sn	https://isepmatam.sn/	/assets/logo/universites/ISEP_Matam.png
25	ISEP Mbacké	Institut Supérieur d'Enseignement Professionnel de Mbacké	publique	Sénégal	Mbacké	Diourbel	Quartier Mbacké Khewar (Ancien siège ASP), Mbacké	+221 33 972 82 10 / +221 76 622 16 01	mbackeisep@gmail.com	https://isepmbacke.sn/	/assets/logo/universites/ISEP_Mbacke.png
26	ISEP Kédougou	Institut Supérieur d'Enseignement Professionnel de Kédougou	publique	Sénégal	Kédougou	Kédougou			contact@mesr.gouv.sn	https://mesrisenegal.sn	/assets/logo/universites/ISEP_Kedougou.png
28	ISM	Institut Supérieur de Management	privee	Sénégal	Dakar	Dakar	Point E, 2 Rue des Écrivains, Dakar	+221 33 869 76 76 / +221 33 869 76 77	info@ism.edu.sn	https://www.groupeism.sn/	/assets/logo/universites/ISM.png
30	ESTM	École Supérieure de Technologie et de Management 	privee	Sénégal	Dakar	Dakar	Avenue Cheikh Anta Diop (en face de l'Hôpital de Fann), Dakar	+221 33 825 28 89 / +221 71 062 00 55	estm@estm.edu.sn	https://estm.sn	/assets/logo/universites/ESTM.png
33	 IFAA	Institut de Formation en Administration des Affaires	privee	Sénégal	Dakar	Dakar	Cité Sipres II (en face de l'Hypermarché Exclusive VDN), villas n° 2 et 3, Dakar	+221 77 566 01 91 / +221 78 112 47 18 / +221 33 867 36 35	contact@ifaa.sn / ifaasecretariat@gmail.com	https://ifaa.sn	/assets/logo/universites/IFAA.png
34	 IFAGE	Institut de Formation en Administration et Gestion d'Entreprises	privee	Sénégal	Dakar	Dakar	VDN 04, Liberté 6 Extension, Dakar	+221 33 867 91 10 / +221 77 740 30 52	contact@ifage.net	https://www.ifage.net/	/assets/logo/universites/IFAGE.png
35	 IPD Thomas Sankara	Institut Panafricain pour le Développement Thomas Sankara.	privee	Sénégal	Dakar	Dakar	Sud Foire n° 8477, Dakar	+221 33 867 90 45	admin@ipd.sn	https://www.ipd.sn/	/assets/logo/universites/IPD_Thomas_Sankara.png
36	IPG/ISTI	Institut Privé de Gestion / Institut Supérieur de Technologie Industrielle	privee	Sénégal	Dakar	Dakar	Boulevard Boubacar Sall, Sicap Sacré Cœur 2, Immeuble IPG, Dakar	+221 33 824 28 39 / +221 77 469 69 61	contact@ipg-isti.sn	https://ipg-isti.com/	/assets/logo/universites/IPG_ISTI.png
37	 UAHB	Université Amadou Hampâté Bâ	privee	Sénégal	Dakar	Dakar	Rocade Fann, Bel-Air (en face du Canal IV), Dakar	+221 33 824 01 24 / +221 77 325 80 80	contact@uahb.sn	https://univ.uahb.sn/	/assets/logo/universites/UAHB.png
38	 UCAO Saint-Michel	Université Catholique de l'Afrique de l'Ouest - Unité Universitaire de Saint-Michel	privee	Sénégal	Dakar	Dakar	17, rue Saint Michel, BP 3402, Dakar	+221 33 823 08 40	stmichel@ucao.edu.sn	https://www.st-michel.sn	/assets/logo/universites/UCAO_Saint_Michel.png
39	 IMES	Institut Mariste d'Enseignement Supérieur	privee	Sénégal	Dakar	Dakar	Square sise Cours Sainte Marie de Hann, Hann-Bel Air, Dakar	+221 33 832 08 29	imes@maristes.sn	https://www.st-michel.sn/	/assets/logo/universites/UCAO_IMES.png
40	UDB	Université Dakar Bourguiba 	privee	Sénégal	Dakar	Dakar	12, Avenue Bourguiba, BP 15744, Dakar	+221 33 825 36 11	info@udb-sn.com / udb@udb.sn	https://udb-sn.com	/assets/logo/universites/UDB.png
41	 UNI-PRO	L'Univers Professionnel	privee	Sénégal	Dakar	Dakar	Rue MZ 83, Mermoz, Dakar	+221 77 855 94 19	uniprocomsn@gmail.com	https://universprofessionnel.com	/assets/logo/universites/UNIPRO.png
42	 UNIS	Université du Sahel	privee	Sénégal	Dakar	Dakar	33, Rue MZ-198 Mermoz, Dakar	+221 33 860 99 75	contact@sahel.education	https://sahel.education 	/assets/logo/universites/UNIS.png
43	SUP'INFO	Groupe SUP'INFO Sénégal	privee	Sénégal	Dakar	Dakar	3, rue Aristide Le Dantec x rue Huart, BP 21104 Dakar-Ponty	+221 33 889 11 88 / +221 77 247 99 07	supinfo@supinfo.sn	https://www.groupesupinfo.com	/assets/logo/universites/SUP_INFO.png
44	SUP de Santé	Institut Supérieur des Sciences de la Santé 	privee	Sénégal	Dakar	Dakar	4 VDN Mermoz, Pyrotechnie, Dakar	+221 33 860 41 78 / +221 77 650 21 82	contact@supdesante.sn	https://supdesante.org/	/assets/logo/universites/SUP_DE_SANTE.png
45	BEM Dakar	BEM Management School	privee	Sénégal	Dakar	Dakar	Campus Sacré-Cœur, Sacré-Cœur III Pyrotechnie, Dakar	+221 33 869 82 81 / +221 77 704 77 77	contact@bem.sn	https://bem.sn	/assets/logo/universites/BEM_DAKAR.png
46	BEM TECH	École d'Ingénieurs et de Technologies	privee	Sénégal	Dakar	Dakar	Sacré-cœur 1, Dakar	+221 77 338 73 73	contact@bemtech.sn	https://bemtech.sn	/assets/logo/universites/BEM_TECH.png
47	BEM School of Law	Établissement privé d'enseignement supérieur spécialisé dans les sciences juridiques, politiques, bancaires et les relations internationales.	privee	Sénégal	Dakar	Dakar	Sacré Cœur III Pyrotechnie (Siège)	+221 33 869 82 81 / +221 77 704 77 77	contact@bem.sn	https://bemschooloflaw.sn	/assets/logo/universites/BEM_SCHOOL_OF_LAW.png
48	ENSUP Afrique	Établissement d'Enseignement Supérieur, des Finances et de l'Administration	privee	Sénégal	Dakar	Dakar	Liberté 6 Extension, villa n°205, en face Camp Leclerc, Dakar, Sénégal	+221 33 867 36 32 / +221 77 856 59 90	ensupafrique@gmail.com	https://www.ensupafrique.com	/assets/logo/universites/ENSUP.png
49	 CEFAS	Centre de Formation Africain du Sénégal	privee	Sénégal	Dakar	Dakar	Cité Keur Damel, Dakar	+221 77 996 08 08 / +221 77 919 49 49 / +221 77 077 57 57	cefassenegal@gmail.com	https://cefas-senegal.com	/assets/logo/universites/CEFAS.png
50	 IAM 	Institut Africain de Management	privee	Sénégal	Dakar	Dakar	Mermoz, villa 7606, Dakar	+221 33 869 36 36 / +221 77 698 39 66	info@groupeiam.com / registrariat@groupeiam.com	https://groupeiam.com/	/assets/logo/universites/IAM.png
51	UAM	Université Amadou Mahtar Mbow 	publique	Sénégal	Diamniadio	Région de Dakar	Rue 21x20, 2ème Arrondissement, Pôle Urbain de Diamniadio	+221 78 345 56 77	uam@uam.edu.sn	https://uam.sn	/assets/logo/universites/UAM.png
52	 DIT	Dakar Institute of Technology	privee	Sénégal	Dakar	Dakar	Immeuble 46, Cité Keur Gorgui, Dakar	+221 77 308 92 92 / +221 78 429 77 77	info@dit.sn	https://dit.sn	/assets/logo/universites/DIT.png
53	 ICAGI 	Institut Communautaire Africain de Gestion et d'Ingénierie - Amadou Mahtar Mbow	privee	Sénégal	Dakar	Dakar	Dakar, Nord Foire Lot B1	+221 33 827 51 52 / +221 77 941 69 69	icagidakar@gmail.com	https://icagi.sn	/assets/logo/universites/ICAGI.png
54	 AFI-UE	AFI-L'Université de l'Entreprise	privee	Sénégal	Dakar	Dakar	Zone B, Rue G, Dakar	+221 33 824 71 10 / +221 33 864 51 46 / +221 77 508 87 28	afi@afi-ue.sn	https://afi-ue.sn	/assets/logo/universites/AFI-UE.png
55	 IESMD	Institut d'Études Supérieures de Management et de Droit	privee	Sénégal	Dakar	Dakar	04, Patte D'oie Builders, Cité BCEAO, Dakar	+221 33 835 51 75 / +221 77 168 60 27 / +221 78 450 70 80	contact@iesmd-sn.org	https://www.iesmd-sn.org/	/assets/logo/universites/IESMD.png
56	ETICCA Business School	École des Techniques Internationales du Commerce, de la Communication et des Affaires	privee	Sénégal	Dakar	Dakar	Sacré-Cœur 3, VDN, Dakar	+221 33 867 31 66 / +221 77 099 17 99 / +221 77 278 40 64	eticca@eticcadakar.net / contact.eticca@gmail.com	http://www.eticcadakar.fr/	/assets/logo/universites/ETICCA.png
57	 ESGIB	École Supérieure de Génie Industriel et Biologique	privee	Sénégal	Dakar	Dakar	Sacré-Cœur 3 (en face de la Boulangerie Jaune), Dakar	+221 33 825 99 12 / +221 77 435 48 48	esgib@esgib.com	https://esgib-edudakar.net	/assets/logo/universites/ESGIB.png
58	ESUP Dakar	École Supérieure de Commerce et de Gestion 	privee	Sénégal	Dakar	Dakar	Sacré Cœur III, Villas N° 9256/9255 (en face du terrain de football), Dakar	+221 33 867 07 90 (Fixe) / +221 76 638 60 08 / +221 78 308 43 43	infos@esupdakar.sn / esupdakar@gmail.com	https://esupdakar.sn	/assets/logo/universites/ESUP.png
59	 ESTG 	École Supérieure des Techniques de Gestion	privee	Sénégal	Dakar	Dakar	Sicap Liberté 4, Lot N° 5001, Dakar	+221 33 867 57 57 / +221 77 864 47 47	contact@estg.sn	https://estg.sn	/assets/logo/universites/ESTG.png
60	 IPSL	Institut Polytechnique de Saint-Louis	publique	Sénégal	Saint-Louis	Saint-Louis	Université Gaston Berger (UGB), Route de Gandon, Saint-Louis	+221 33 960 00 39	ipsl@ugb.edu.sn	https://ipsl-concours.ugb.sn/	/assets/logo/universites/IPSL.png
61	 BATISUP	École Supérieure du Bâtiment	privee	Sénégal	Dakar	Dakar	Avenue Bourguiba Angle Rue 9, Sicap Amitié 3 (en face de la station Ola Energy), Dakar	+221 33 824 02 18 / +221 77 529 66 19	contact@batisup.com	https://www.batisup.com	/assets/logo/universites/BATISUP.png
62	ESGE	École Supérieure de Génies	privee	Sénégal	Dakar	Dakar	Point E, Rue 4 x Boulevard de l'Est n° 5315, Dakar	+221 33 860 64 41 / +221 77 242 78 27	info@esge-sa.com / direction-des-etudes@esge-sa.com	https://esge-sa.com	/assets/logo/universites/ESGE.png
63	AKADEMIA DAKAR - 	École de Droit et de Sciences Politiques	privee	Sénégal	Dakar	Dakar	Point E, villa n°368, Rue A x Rue 5, Dakar	+221 33 843 72 27 / +221 78 591 18 79	admission@akademiadakar.edu.sn	https://akademiadakar.com	/assets/logo/universites/AKADEMIA.png
\.


--
-- Data for Name: universite_detail; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.universite_detail (id_detail, id_universite, presentation, conditions_admission, bourses) FROM stdin;
1	1	L'Université Cheikh Anta Diop de Dakar (UCAD) est l'une des principales universités publiques du Sénégal. Créée en 1957, elle propose des formations dans plusieurs domaines comme les sciences, la santé, le droit, l'économie, les lettres et les technologies.	Admission Générale : Être titulaire du Baccalauréat. Sélection sur Campusen selon les places disponibles. Cas Spécifiques (FMPOS - Médecine) : Sélection drastique sur Campusen (priorité aux séries S1/S2 avec d'excellentes moyennes) suivie d'une validation obligatoire sur la plateforme d'admission de l'UCAD. Droits d'inscription fixés à 25 000 FCFA.	Bourse d'Excellence : Réservée aux nouveaux bacheliers avec mention Très Bien ou Bien, ou aux lauréats du Concours Général. Bourse Entière (40 000 FCFA/mois) : Accordée aux bacheliers avec mention Assez-Bien, ou aux admis sur concours dans les grandes écoles/instituts. Demi-Bourse (20 000 FCFA/mois) : Attribuée selon les quotas disponibles aux bacheliers sans mention (Passable) selon les performances de leur série.
2	2	L'Université Gaston Berger de Saint-Louis (UGB) est une université publique créée en 1990. Elle est reconnue pour ses formations en sciences, technologies, économie, gestion, lettres et sciences humaines.	Admission Générale : Orientation exclusive via Campusen. L'UGB applique des critères stricts basés sur l'excellence des notes du secondaire (notamment en mathématiques/sciences pour les filières scientifiques).Étudiants étrangers : Admission sur dossier directement auprès du Rectorat (lettre manuscrite, relevés légalisés).	Bourse d'Excellence : Réservée aux nouveaux bacheliers avec mention Très Bien ou Bien, ou aux lauréats du Concours Général. Bourse Entière (40 000 FCFA/mois) : Accordée aux bacheliers avec mention Assez-Bien, ou aux admis sur concours dans les grandes écoles/instituts.Demi-Bourse (20 000 FCFA/mois) : Attribuée selon les quotas disponibles aux bacheliers sans mention (Passable) selon les performances de leur série.
3	3	L'Université Iba Der Thiam de Thiès (UIDT) est une université publique située dans la région de Thiès. Elle développe des formations orientées vers les sciences, technologies, ingénierie, économie et autres domaines professionnels.	Admission Générale : Via Campusen pour les Unités de Formation et de Recherche (UFR) en Sciences de l'Ingénieur, Santé et Économie. Instituts internes (IUT) : Accès sur concours direct ou sélection sur dossier rigoureuse en plus de Campusen.	Bourse d'Excellence : Réservée aux nouveaux bacheliers avec mention Très Bien ou Bien, ou aux lauréats du Concours Général. Bourse Entière (40 000 FCFA/mois) : Accordée aux bacheliers avec mention Assez-Bien, ou aux admis sur concours dans les grandes écoles/instituts. Demi-Bourse (20 000 FCFA/mois) : Attribuée selon les quotas disponibles aux bacheliers sans mention (Passable) selon les performances de leur série.
4	4	L'École Supérieure Polytechnique (ESP) de Dakar est une grande école publique spécialisée dans les formations scientifiques, techniques et d'ingénierie. Elle forme des professionnels dans plusieurs domaines liés à l'industrie et aux technologies.	Admission : Double procédure obligatoire. Dépôt d'un dossier de candidature directement auprès de l'ESP pour passer les tests/concours d'entrée en DUT, parallèlement aux choix formulés sur Campusen. 	Bourse : Les admis au concours d'entrée de l'ESP bénéficient automatiquement d'une bourse entière d'État au titre de leur admission sur sélection.
5	5	Le Groupe Supdeco Dakar (École Supérieure de Commerce de Dakar) est la première Business School privée du Sénégal, fondée en 1993. Elle dispose de diplômes accrédités par l'ANAQ-Sup et reconnus par le CAMES.\\r\\nIl est spécialisé dans les domaines du management, de la gestion, du commerce, de la finance et du marketing.	L'accès à Supdeco est payant et sélectif :Niveau Bachelor / Licence (L1, L2, L3) : Être titulaire du Baccalauréat (toutes séries) ou d'un diplôme de niveau Bac+2. Sélection sur étude de dossier scolaire (bulletins de notes) suivie d'un test écrit et d'un entretien de motivation. Niveau Master (M1, M2) : Être titulaire d'une Licence ou d'un Bac+4 validé dans un domaine compatible. L'admission se fait sur dossier, présentation du projet professionnel, et entretien avec un jury de l'école.Plateforme de candidature : Les inscriptions doivent être soumises directement sur l'Espace d'admission Supdeco.	L'école étant un institut privé, les frais d'études incombent normalement à l'étudiant. Il existe toutefois des dispositifs d'aide financière :Bourses d'Excellence Supdeco : L'institution organise périodiquement des vagues de concours internes attribuant des Bourses d'excellence Supdeco (réductions partielles sur la scolarité) pour les bacheliers ou licenciés méritants ayant d'excellents dossiers scolaires.Bourses institutionnelles et étatiques : Les gouvernements de l'espace UEMOA ou la Direction des Bourses du Sénégal allouent occasionnellement des quotas de prises en charge à des étudiants orientés dans les filières d'excellence du privé.Alternance et Formations Continues : Certains programmes de Master en Executive Academy ou en alternance peuvent être financés directement par des entreprises partenaires ou des OPCO.
6	6	L’Université Assane Seck de Ziguinchor est une université publique sénégalaise créée pour renforcer l’accès à l’enseignement supérieur dans la région sud du Sénégal. Elle participe au développement de formations adaptées aux besoins économiques et sociaux du pays, notamment dans les sciences, les technologies, les lettres, les langues et les sciences humaines.	Admission : Sélection automatisée via Campusen. Les filières phares (Agroforesterie, Sciences de la Santé) requièrent d'excellents scores dans les matières scientifiques (SVT, Chimie, Physique).	Bourse d'Excellence : Réservée aux nouveaux bacheliers avec mention Très Bien ou Bien, ou aux lauréats du Concours Général. Bourse Entière (40 000 FCFA/mois) : Accordée aux bacheliers avec mention Assez-Bien, ou aux admis sur concours dans les grandes écoles/instituts. Demi-Bourse (20 000 FCFA/mois) : Attribuée selon les quotas disponibles aux bacheliers sans mention (Passable) selon les performances de leur série.
7	7	L’Université Alioune Diop de Bambey (UADB) est une université publique sénégalaise située dans la région de Diourbel. Créée dans le cadre de la politique de décentralisation de l’enseignement supérieur au Sénégal, elle a pour mission de renforcer l’accès aux études universitaires en dehors de Dakar. L’université développe des formations adaptées aux besoins du pays dans plusieurs domaines, notamment les sciences, les technologies, l’agriculture, l’économie, la gestion et les sciences humaines. Elle participe également à la recherche et à la formation de cadres capables d’accompagner le développement économique et social du Sénégal.	Admission : Via Campusen. Spécialisée dans les filières professionnalisantes et les technologies de l'information. Un niveau solide en sciences ou en gestion (série G, L ou S) est requis selon l'UFR visée.	Bourse d'Excellence : Réservée aux nouveaux bacheliers avec mention Très Bien ou Bien, ou aux lauréats du Concours Général. Bourse Entière (40 000 FCFA/mois) : Accordée aux bacheliers avec mention Assez-Bien, ou aux admis sur concours dans les grandes écoles/instituts. Demi-Bourse (20 000 FCFA/mois) : Attribuée selon les quotas disponibles aux bacheliers sans mention (Passable) selon les performances de leur série.
8	8	L’Université numérique Cheikh Hamidou Kane (UNCHK) est une université publique sénégalaise spécialisée dans l’enseignement numérique et la formation à distance. Elle a été créée pour démocratiser l’accès à l’enseignement supérieur grâce aux technologies de l’information et de la communication. L’université permet aux étudiants de suivre des formations universitaires avec des dispositifs numériques adaptés, tout en répondant aux enjeux actuels liés au numérique, à l’innovation et à la transformation digitale.	Admission : Via Campusen. C'est l'université qui dispose de la plus grande capacité d'accueil. L'accès est ouvert à toutes les séries de baccalauréat. Particularité : Les étudiants reçoivent une dotation en équipement numérique (ordinateur portable) et une clé de connexion internet financée par l'État pour suivre les cours dans les Espaces Numériques Ouverts (ENO).	Bourse d'Excellence : Réservée aux nouveaux bacheliers avec mention Très Bien ou Bien, ou aux lauréats du Concours Général. Bourse Entière (40 000 FCFA/mois) : Accordée aux bacheliers avec mention Assez-Bien, ou aux admis sur concours dans les grandes écoles/instituts. Demi-Bourse (20 000 FCFA/mois) : Attribuée selon les quotas disponibles aux bacheliers sans mention (Passable) selon les performances de leur série.
9	9	L’Université du Sine Saloum El Hadji Ibrahima Niass (USSEIN) est une université publique sénégalaise implantée dans le centre du pays. Elle a été créée pour répondre aux besoins de formation et de recherche dans des secteurs stratégiques liés au développement durable. L’université met particulièrement l’accent sur l’agriculture, l’agroalimentaire, l’environnement, les sciences de la vie et les domaines liés aux ressources naturelles. Elle contribue à former des cadres capables d’accompagner la modernisation du secteur agricole et le développement territorial.	Admission : Via Campusen. L'orientation est fortement axée sur les métiers de l'agriculture, de l'élevage, de la pêche et du développement durable. Une priorité est accordée aux filières scientifiques et techniques.	Bourse d'Excellence : Réservée aux nouveaux bacheliers avec mention Très Bien ou Bien, ou aux lauréats du Concours Général. Bourse Entière (40 000 FCFA/mois) : Accordée aux bacheliers avec mention Assez-Bien, ou aux admis sur concours dans les grandes écoles/instituts. Demi-Bourse (20 000 FCFA/mois) : Attribuée selon les quotas disponibles aux bacheliers sans mention (Passable) selon les performances de leur série.
10	10	L’École Nationale de la Statistique et de l’Analyse Économique (ENSAE Sénégal) est une grande école publique spécialisée dans la formation des statisticiens, économistes et analystes de données. Elle joue un rôle majeur dans la formation des cadres destinés aux administrations publiques, aux organisations internationales, aux entreprises et aux institutions de recherche. L’école forme des spécialistes capables d’exploiter les données pour l’aide à la décision, la planification économique et l’évaluation des politiques publiques.	Admission : Concours international direct très sélectif (généralement organisé en avril/mai). Il existe plusieurs niveaux d'accès : Techniciens Supérieurs (niveau BAC) ou Ingénieurs (niveau Classes Préparatoires ou Licence).	Bourse : Tous les élèves sénégalais réussissant le concours de l'ENSAE bénéficient d'une bourse d'études mensuelle spécifique (souvent plus élevée que la bourse universitaire classique) octroyée par l'État ou des partenaires institutionnels.
11	11	L’École Nationale Supérieure d’Agriculture (ENSA) est un établissement public sénégalais spécialisé dans la formation des ingénieurs agronomes et des cadres du secteur agricole. Elle contribue au développement de l’agriculture sénégalaise à travers la formation, la recherche et l’innovation. L’école forme des professionnels capables d’intervenir dans la production agricole, la gestion des ressources naturelles, l’agroalimentaire et le développement rural.	Admission : Concours direct national accessible aux bacheliers des séries scientifiques (S1, S2, S3, S4, S5). L'inscription au concours se fait indépendamment de Campusen au cours du dernier trimestre de l'année scolaire de Terminale.	Bourse : À l'image des grandes écoles d'ingénieurs, l'admission sur concours ouvre automatiquement droit à l'octroi d'une bourse entière d'État.
12	12	L’École Polytechnique de Thiès (EPT) est une grande école publique sénégalaise spécialisée dans la formation d’ingénieurs et de cadres scientifiques. Elle participe au développement des compétences techniques du Sénégal dans les domaines de l’ingénierie, des infrastructures, de l’industrie, de l’énergie et des technologies. L’école accueille des étudiants sélectionnés selon des critères académiques exigeants et contribue également aux activités de recherche et d’innovation.	L'admission en première année s'effectue exclusivement par voie de concours direct très compétitif. Elle ne dépend pas de la plateforme Campusen.\\r\\nÊtre élève en classe de Terminale Scientifique ou Technique (S1, S2, S3, STIDD, T1, T2) ou déjà titulaire de l'un de ces baccalauréats.\\r\\nAvoir moins de 22 ans au 1er octobre de l'année du concours.	Bourses d'État : En tant qu'école d'ingénieurs publique, tous les candidats de nationalité sénégalaise qui réussissent le concours d'entrée obtiennent automatiquement le statut d'étudiant boursier (bourse entière de l'État du Sénégal).\\r\\nRégime d'internat : Les étudiants admis bénéficient (dans la limite des places disponibles et selon le règlement) d'un accès au campus résidentiel de l'école (hébergement et restauration subventionnée).\\r\\nÉtudiants étrangers : L'admission pour les ressortissants hors-Sénégal se fait généralement sur dossier via des quotas ou accords de coopération bilatérale entre les États africains. Ces étudiants sont le plus souvent pris en charge par des bourses de leur gouvernement d'origine ou d'organismes internationaux.
13	13	L’École Inter-États des Sciences et Médecine Vétérinaires (EISMV) est un établissement sous-régional spécialisé dans la formation des vétérinaires et des cadres des sciences animales. Elle accueille des étudiants provenant de 15 pays africains et joue un rôle important dans la santé animale, la sécurité alimentaire et le développement de l’élevage en Afrique de l’Ouest.	Titulaire d'un Baccalauréat Scientifique (S1, S2 ou équivalent) de l'année en cours.\\r\\nSélection Sur examen rigoureux du dossier scolaire. Une moyenne générale d'au moins 12/20 (voire supérieure selon les pays d'origine) avec d'excellentes notes en SVT/Biologie et Physique-Chimie est indispensable.	Bourses des États Membres : La grande majorité des étudiants y accèdent sous le statut de boursiers de leur propre gouvernement. Chaque année, les ministères de l'enseignement supérieur des pays membres (Sénégal, Burkina Faso, Mali, Niger, Mauritanie, Togo, etc.) organisent une commission nationale pour attribuer un quota limité de bourses d'excellence aux meilleurs bacheliers ou étudiants scientifiques voulant partir étudier à l'EISMV de Dakar.\\r\\nBourses de projets et d’organismes internationaux : L'EISMV bénéficie d'appuis de partenaires de développement. Par exemple, le Projet Régional d'Appui au Pastoralisme au Sahel (PRAPS) ou le réseau AFROHUN octroient régulièrement des bourses d'études complètes à des étudiants méritants.
14	14	L’École Normale Supérieure d’Enseignement Technique et Professionnel (ENSETP) est un établissement public spécialisé dans la formation des enseignants techniques et professionnels. Elle contribue au développement de l’enseignement professionnel au Sénégal en préparant des formateurs capables de transmettre des compétences techniques dans différents secteurs.	L'entrée à l'ENSETP est réglementée, très sélective et s'effectue exclusivement par voie de concours direct ou professionnel. L'accès n'est pas géré par Campusen pour le premier cycle.\\r\\nVoie du Concours Direct (Pour les bacheliers ou étudiants) :Niveau Bac : Être titulaire d'un Baccalauréat Technique (T1, T2, G) ou Scientifique (S1, S2, S3) selon l'option visée. Les conditions d'âge varient généralement entre 22 et 24 ans maximum.	Statut d'Élève-Professeur : Les étudiants sénégalais admis par voie de concours direct intègrent l'école avec le statut privilégié d'élève-professeur.\\r\\nBourse entière d'office : En raison de ce statut particulier, l’État du Sénégal attribue automatiquement une bourse d'études entière mensuelle à tous les élèves nationaux du cycle régulier, afin de soutenir leur parcours de formation d'enseignant.\\r\\nPrise en charge professionnelle (Voie pro) : Les candidats issus du concours professionnel conservent généralement leur salaire ou bénéficient d'indemnités de stage spécifiques de la part de leur ministère de tutelle pendant toute la durée de leur formation.
16	16	L’Institut National Supérieur de l’Éducation Populaire et du Sport (INSEPS) est un établissement public rattaché à l’Université Cheikh Anta Diop de Dakar (UCAD). Il est spécialisé dans la formation des professionnels du sport, de l’éducation physique et de l’animation sportive. L’institut contribue au développement des compétences dans le domaine sportif au Sénégal.	L'entrée à l'INSEPS se fait exclusivement sur concours direct ou professionnel très sélectif. L'admission ne passe pas par la plateforme Campusen.\\r\\nÊtre titulaire d'un Baccalauréat (toutes séries) ou d'un diplôme équivalent.\\r\\nÊtre âgé de 18 ans au moins et de 24 ans au plus au 31 décembre de l'année du concours.	Statut d'Élève-Professeur : Les candidats qui réussissent le concours direct pour le cycle d'enseignement acquièrent le statut privilégié d'élève-professeur.Bourse d'État automatique : En raison de ce statut d'encadreur de l'État en formation, tous les étudiants sénégalais admis au cycle régulier reçoivent automatiquement une bourse d'études entière mensuelle.Prise en charge interne : Les étudiants ont accès (dans la limite des places disponibles) aux infrastructures d'hébergement, aux installations sportives de haut niveau et au restaurant de l'institut situé sur le campus de l'UCAD.
17	17	L’École des Bibliothécaires, Archivistes et Documentalistes (EBAD) est un établissement public rattaché à l’Université Cheikh Anta Diop de Dakar (UCAD). Elle est spécialisée dans la formation des professionnels de l’information documentaire, notamment dans les domaines des bibliothèques, archives, documentation et gestion de l’information.	Concours direct\\r\\nÊtre bachelier (Bac de l'année en cours ou précédente) ou élève en classe de Terminale.	L'attribution des bourses dépend de la nationalité et du statut de l'étudiant :Pour les étudiants sénégalais : Comme pour toutes les facultés de l'Université Cheikh Anta Diop (UCAD), l'octroi des bourses d'études nationales dépend de la Direction des Bourses du Ministère de l'Enseignement Supérieur. Elles sont attribuées sur critères sociaux ou d'excellence académique après l'inscription officielle.Pour les étudiants internationaux : L'EBAD n'attribue pas directement de bourses. Les candidats étrangers doivent solliciter une bourse auprès de leur propre gouvernement, d'organismes internationaux (comme l'AUF) ou de programmes de coopération bilatérale.Régime salarié / En ligne : Les formations à distance (Enseignement à distance) ou les parcours destinés aux professionnels ne bénéficient généralement pas des bourses universitaires classiques et sont à la charge de l'étudiant ou de son employeur.
18	18	Le Centre Africain d’Études Supérieures en Gestion (CESAG) est un établissement d’enseignement supérieur spécialisé dans la gestion, la finance, le management et les domaines associés. Il possède un statut particulier avec une vocation régionale africaine et accueille des étudiants et professionnels provenant de plusieurs pays. Le CESAG joue un rôle important dans la formation des cadres et dirigeants dans les secteurs publics et privés.	L'admission se fait par voie de concours (épreuves écrites) combiné à une étude de dossier.\\r\\nFrais de traitement de dossier : 25 000 FCFA (ou 39 €) payables via les canaux officiels (comme Ecobank).\\r\\nCritères pédagogiques requis :Entrée en L1 : Titre de bachelier + relevés de notes de la Seconde à la Terminale.	Bourses des États membres : Les gouvernements de l'espace UEMOA (Sénégal, Burkina Faso, Côte d'Ivoire, etc.) octroient chaque année des bourses d'excellence spécifiques pour le CESAG via leurs ministères de l'enseignement supérieur (comme les offres gérées sur CampusFaso ou la Direction des Bourses du Sénégal). Les dossiers doivent être soumis directement auprès de ces commissions nationales. Prises en charge institutionnelles : Financements par des banques partenaires, la BCEAO ou des employeurs pour les programmes de formation continue et certificats. Échéances de paiement : Pour les étudiants autofinancés, un versement initial de 50% de la scolarité est exigé à l'inscription, suivi de deux tranches de 25% au cours de l'année.
19	19	Le Centre de Formation Professionnelle et Technique Sénégal-Japon (CFPT Sénégal-Japon) est un établissement public sénégalais de référence dans la formation technique et professionnelle. Créé dans le cadre de la coopération entre le Sénégal et le Japon, il a pour mission de former des techniciens supérieurs et des professionnels hautement qualifiés répondant aux besoins du marché de l’emploi. Le CFPT propose des formations dans plusieurs domaines tels que la mécanique, l’électrotechnique, l’électronique, l’informatique, le génie civil, la maintenance industrielle, la logistique et d’autres spécialités techniques. L’établissement entretient des liens étroits avec les entreprises afin de favoriser l’insertion professionnelle de ses diplômés et participe activement au développement des compétences techniques au Sénégal.	Par Concours National (Cours du jour publics)Niveau BTI : Être titulaire du BFEM, CAP ou équivalent. Être âgé de 14 à 22 ans.\\r\\nNiveau BTS : Être titulaire d'un Baccalauréat Scientifique (S), Technique (T) ou d'un BTI. Être âgé de 18 à 25 ans.Frais d’inscription au concours : 6 000 FCFA.\\r\\nPar Test d'Entrée (Cours du soir / Filière payante)Sélection : Étude de dossier suivie d’épreuves (Maths, Français, Anglais).Frais de dossier : 3 000 FCFA.Public : Professionnels en activité, étudiants en réorientation ou candidats hors critères d'âge du concours public.	Le CFPT-SJ n'accorde pas directement de bourses, mais plusieurs dispositifs étatiques s'appliquent :Bourses d’État (Concours public) : Les élèves admis via le concours national de la formation professionnelle peuvent bénéficier d'une allocation mensuelle de l’État sénégalais, gérée par la Direction des Bourses, sous réserve de remplir les critères académiques. Bons de Formation de l’État (Dispositif 3FPT) : Pour les filières payantes ou les jeunes en situation de vulnérabilité, il est possible de postuler aux campagnes de financement initial du 3FPT. Le 3FPT peut prendre en charge jusqu’à 90 % des frais de scolarité annuels.
20	20	L'ISEP de Thiès est un établissement public d'enseignement supérieur professionnel créé pour former des techniciens supérieurs qualifiés répondant aux besoins du marché de l'emploi. Les formations sont basées sur une forte composante pratique, des stages en entreprise et une insertion professionnelle rapide.	L'entrée en première année est soumise à différentes procédures :Nouveaux bacheliers : Orientation obligatoire via Campusen.Titulaires d'un BT : Sélection sur dossier à déposer à la direction des études.Sélection : Sur dossier et entretien avec un jury professionnel, selon l'ordre de mérite.Coût : Les droits d'inscription sont fixés à 90 000 FCFA par an.	L’ISEP-Thiès ne gère pas directement les bourses :Bourses nationales : Les étudiants sénégalais doivent soumettre leur demande auprès de la Direction des Bourses du ministère. Stages : Les stages en entreprise, bien que faisant partie intégrante de la formation (jusqu'à 16 semaines), ne sont pas obligatoirement rémunérés.
21	21	L'ISEP de Diamniadio est un établissement public orienté vers les formations professionnalisantes dans les domaines techniques, industriels et numériques. Il privilégie l'approche par compétences et les partenariats avec les entreprises.	Admission après le baccalauréat selon les procédures officielles de sélection.	Les étudiants éligibles peuvent bénéficier des bourses nationales.
22	22	L'ISEP de Richard-Toll assure une formation professionnelle adaptée aux besoins économiques de la vallée du fleuve Sénégal, notamment dans les secteurs industriels, agricoles et des services.	Pour les nouveaux bacheliers : L'accès se fait sur orientation nationale via la plateforme étatique Campusen. Sont éligibles les bacheliers des séries scientifiques, techniques ou littéraires (selon la filière demandée).Pour les titulaires d'un Brevet de Technicien (BT) : L'admission s'effectue sur dossier de candidature suivi d'un entretien de motivation devant un jury. Le BT doit être de l'année en cours et correspondre au secteur d'activité de la formation choisie. Frais d'inscription : Les droits de scolarité annuels s'élèvent généralement à 90 000 FCFA, conformément à la réglementation des ISEP publics au Sénégal.	L'institut lui-même ne délivre pas directement de bourses de subsistance. Le volet financier s'organise ainsi :Bourses nationales de l'Enseignement supérieur : Les étudiants réguliers de nationalité sénégalaise (notamment ceux orientés via Campusen) peuvent solliciter et obtenir une bourse d'études auprès de la Direction des Bourses du ministère de tutelle. Financements professionnels et stages : Le modèle de formation par alternance s’appuie sur un partenariat solide avec les entreprises de la région (comme la Compagnie Sucrière Sénégalaise). Bien que certains stages de fin de cycle offrent une indemnité variable selon les entreprises accueillantes, cela ne constitue pas une bourse automatique d'étude.
23	23	L'ISEP de Bignona propose des formations professionnelles destinées à renforcer les compétences techniques des jeunes de la région de la Casamance et à favoriser leur insertion professionnelle.	L'accès à l'établissement dépend du statut de l'apprenant :Pour les nouveaux bacheliers (DiSEP) : L'orientation se fait obligatoirement en ligne via la plateforme nationale Campusen pour les bacheliers des séries scientifiques, techniques ou littéraires.Pour les titulaires d'un Brevet de Technicien (BT) : Admission sur étude de dossier de candidature et entretien individuel de motivation devant un jury.Pour les CCP (6 mois) : Recrutement sur appel à candidatures. Les candidats doivent être âgés de 18 à 40 ans, être issus de couches vulnérables ou présenter un projet professionnel validé.Droits d'inscription : Les frais administratifs annuels s'élèvent à 90 000 FCFA pour le parcours DiSEP.	L'institut lui-même n'octroie pas de bourses directes, mais applique les dispositifs nationaux suivants :Bourses d’État (MESRI) : Les étudiants de nationalité sénégalaise régulièrement orientés par Campusen peuvent introduire une demande auprès de la Direction des Bourses pour bénéficier de l’allocation universitaire mensuelle.Bons de formation (3FPT) : Dans le cadre de programmes d'insertion (ex : Projet Espoir-Jeunes), le Fonds de Financement de la Formation Professionnelle et Technique (3FPT) subventionne intégralement ou en grande partie les parcours de courte durée (CCP) pour les jeunes.
24	24	L'ISEP de Matam forme des techniciens supérieurs dans plusieurs domaines répondant aux besoins du développement économique régional et national.	Admission après le baccalauréat sur dossier ou selon les modalités officielles.	Bourses nationales accessibles aux étudiants remplissant les conditions.
25	25	L'ISEP de Mbacké développe des formations professionnalisantes favorisant l'employabilité, l'innovation et l'entrepreneuriat dans différents secteurs d'activité.	L'entrée à l'institut s'effectue après une sélection rigoureuse par ordre de mérite :Pour le DiSEP (Nouveaux bacheliers) : L'orientation se fait en ligne via la plateforme nationale Campusen. Pour le DiSEP (Titulaires d'un Brevet de Technicien - BT) : L'admission nécessite le dépôt d'un dossier complet à la Direction des Études de l'institut, suivi d'un entretien obligatoire avec un jury. Frais de dossier : Fixés à 5 000 FCFA pour les candidats sur dossier. Les frais d'inscription pédagogique s'élèvent ensuite à 90 000 FCFA par an (frais communs aux ISEP publics)	Bourses d’État nationales : Les étudiants sénégalais inscrits en formation régulière (sélectionnés par Campusen ou par test de l'institut) peuvent soumettre une demande auprès de la Direction des Bourses du Ministère de l'Enseignement Supérieur afin de bénéficier d'allocations universitaires mensuelles. Prise en charge de projets (ex: 3FPT) : Pour les certificats courts (CCP) ou certaines cohortes spécifiques, le Fonds de Financement de la Formation Professionnelle et Technique (3FPT via le programme Espoir Jeunes) peut subventionner intégralement le coût de la formation des jeunes de 18 à 40 ans porteurs d'un projet professionnel
26	26	L'ISEP de Kédougou dispense des formations professionnelles adaptées aux besoins des secteurs économiques de la région, notamment les ressources naturelles, les technologies et les services.	Pour le DiSEP (Nouveaux bacheliers) : L'accès se fait obligatoirement sur orientation via la plateforme nationale Campusen. L'admission est ouverte aux titulaires d'un Baccalauréat (séries scientifiques, techniques ou littéraires selon la filière souhaitée).Pour le DiSEP (Titulaires d'un Brevet de Technicien - BT) : Sélection sur dossier de candidature (généralement ouvert aux diplômés en électricité, mécanique ou métiers ruraux) suivie d'un entretien de motivation obligatoire devant un jury. Frais d'inscription : Les droits d'inscription administratifs annuels s'élèvent à 90 000 FCFA, conformément au régime des instituts publics au Sénégal.	Bourses nationales (MESRI) : Les étudiants de nationalité sénégalaise régulièrement orientés par l'État peuvent soumettre un dossier auprès de la Direction des Bourses pour bénéficier des allocations d'études universitaires mensuelles.Financements de projets (ex: 3FPT) : Pour les formations courtes (CCP), les frais de scolarité sont le plus souvent intégralement pris en charge ou fortement subventionnés par le Fonds de Financement de la Formation Professionnelle et Technique (3FPT) via des guichets d'insertion pour les jeunes de la région.
28	28	L'Institut Supérieur de Management (ISM) est l'un des principaux établissements privés d'enseignement supérieur du Sénégal. Il propose des formations professionnalisantes dans les domaines du management, de la finance, du marketing, de la communication, du droit, de l'informatique et de l'ingénierie. L'école met l'accent sur l'innovation, l'entrepreneuriat, les stages en entreprise et l'insertion professionnelle.	L'accès s'effectue après une sélection rigoureuse qui comprend l'évaluation académique et des tests.Dossier de candidature : Soumission des diplômes, relevés de notes légalisés de la dernière classe fréquentée et attestations professionnelles (pour les masters). Le dossier peut être géré directement par e-mail ou sur le site.Tests d'entrée obligatoires : Les candidats retenus doivent passer trois épreuves :Épreuve écrite de culture générale.Entretien individuel en anglais.Entretien collectif de motivation.Frais de scolarité indicatifs : Les frais standards s'élèvent généralement à environ 950 000 FCFA par an pour la formation initiale, payables en totalité ou étalés sur 10 mensualités de 95 000 FCFA.	L'ISM propose des solutions d'aide au financement basées sur le mérite académique :Bourses d’excellence du Groupe ISM : Ce programme est destiné aux bacheliers très méritants de l'espace UEMOA. L'obtention d'une mention au Baccalauréat est une condition obligatoire (sine qua non) pour y postuler. Dossier de demande de bourse : Il doit comporter les copies certifiées conformes des bulletins de la Seconde à la Terminale, la pièce d'identité, un extrait de naissance et un certificat de visite médicale.
29	29	L'Institut Supérieur d'Informatique (ISI) est un établissement privé d'enseignement supérieur reconnu au Sénégal. Il propose des formations professionnalisantes en informatique, réseaux, cybersécurité, intelligence artificielle, management, finance, marketing et télécommunications. Les formations sont orientées vers les compétences pratiques, l'innovation, les stages et l'insertion professionnelle.	L’accès aux différents programmes de l'ISI s'effectue selon le niveau d'études visé :Admission en 1ère année (Licence 1 / BTS) : Être titulaire du Baccalauréat (toutes séries) ou d'un diplôme équivalent. La sélection se fait sur étude de dossier scolaire (bulletins de notes) suivie d'un entretien de motivation.Admission en Master : Être titulaire d'une Licence (Bac+3) ou d'un diplôme jugé équivalent dans un domaine compatible. L'admission se fait sur examen du dossier académique et validation du projet professionnel.Dossier de candidature de base : Une copie légalisée du diplôme (Bac ou Licence), les relevés de notes des deux dernières années, une copie de la pièce d'identité et des photos d'identité.	L'ISI est un institut privé payant, mais il propose plusieurs mécanismes d'accompagnement financier pour alléger les frais de scolarité :Bourses d’Excellence et de Solidarité ISI : Le groupe octroie chaque année, sous forme de concours ou sur critères sociaux très rigoureux, des demi-bourses ou des réductions partielles de scolarité pour les bacheliers ou licenciés ayant obtenu de très bonnes mentions.Bons de formation (3FPT) : Pour les filières techniques et les diplômes d'État (comme le BTS), les étudiants sénégalais peuvent postuler aux guichets de financement du 3FPT pour obtenir une prise en charge partielle ou totale de leurs frais de scolarité.Conventions de partenariat : L'ISI a signé des accords avec plusieurs communes, associations et groupements du Sénégal permettant à leurs membres ou résidents de bénéficier de tarifs préférentiels.
30	30	L'École Supérieure de Technologie et de Management (ESTM) est un établissement privé d'enseignement supérieur qui forme des professionnels dans les domaines du management, des technologies, de l'informatique, de l'ingénierie et des sciences appliquées. Les formations privilégient une approche professionnalisante, les stages en entreprise et le développement des compétences techniques et managériales.	L’entrée à l’ESTM s'effectue principalement sur dossier et validation académique :Admission en Licence 1 (L1) : Être titulaire d'un Baccalauréat (toutes séries selon la filière visée).Admission en Licence 3 (L3) ou Master : Être titulaire d’un diplôme de niveau Bac+2 (DUT, BTS, L2) ou d'une Licence (Bac+3) dans une spécialité équivalente ou compatible.	L'ESTM met en place plusieurs dispositifs pour faciliter le financement de ses programmes :Programme de Bourses Master ESTM : L’école lance périodiquement des campagnes d'attribution de bourses partielles de réduction de scolarité. Elles s'adressent aux étudiants ou professionnels de niveau Bac+3 souhaitant intégrer un master d'ingénierie ou de management sur critères d'excellence académique.Prises en charge étatiques (3FPT) : Pour les filières éligibles (notamment les parcours techniques en génie électrique, informatique et énergies renouvelables), les étudiants de nationalité sénégalaise peuvent solliciter des bons de financement auprès du 3FPT pour prendre en charge tout ou partie des frais d’études.
31	31	L'ESEBAT (École Supérieure d'Électricité, du Bâtiment et des Travaux Publics) du Sénégal est un pôle d'enseignement technique et d'ingénierie de premier plan. L'établissement bénéficie d'une double reconnaissance de l'État : il est agréé par le Ministère de l'Enseignement Supérieur (MESRI) ainsi que par le Ministère de la Formation Professionnelle (MEFPAI).	L’accès aux programmes de l'ESEBAT repose sur une étude minutieuse du dossier scolaire :Pour la section BT : Être titulaire du BFEM ou du BEP. Les bulletins de la classe de 3ème sont requis.Pour la section BTS : Être titulaire du Baccalauréat (séries S ou T exigées pour les filières industrielles lourdes comme le Génie Civil) ou du diplôme du BT. Les titulaires de Bac L peuvent être acceptés sous conditions spécifiques à discuter sur place. Pour les cycles Licence et Master : Justifier des prérequis académiques directs conformes au niveau visé (ex. : Bac+2 validé pour la Licence 3, Bac+3 en adéquation technique pour le Master 1). Un profil en transport-logistique ne peut pas intégrer directement une Licence de Génie Civil.Particularités pratiques : L'uniforme/tenue d'école est obligatoire pour tous les étudiants (les frais s'élèvent à 30 000 FCFA au 1er cycle et 50 000 FCFA au 2ème cycle). L'accès à la bibliothèque est également assujetti à des frais obligatoires d'environ 15 000 FCFA.	L'école s'associe à plusieurs leviers d'aide financière pour les apprenants nationaux :Bourses d’État du Sénégal : En tant qu'établissement agréé par le MESRI, l'ESEBAT est habilitée à recevoir des boursiers de l'État du Sénégal (étudiants orientés officiellement).Bons de formation initiale (Partenariat 3FPT) : L'ESEBAT collabore régulièrement avec le 3FPT (Fonds de Financement de la Formation Professionnelle et Technique). Ce dispositif permet aux jeunes Sénégalais âgés de 15 à 40 ans (notamment les profils en reconversion, déscolarisés ou en situation de handicap) de bénéficier de bourses d'études prenant en charge la quasi-totalité de leurs frais pour des diplômes de type BT, BTS ou Licence.
32	32	Le CEFER (Centre Européen de Formation en Énergie Renouvelable) de Dakar est une institution supérieure de formation professionnelle et technique agréée par l'État du Sénégal (MESRI et MFPAI). Créé à l'initiative de jeunes immigrés sénégalais avec l'appui technique de multinationales espagnoles de l'ingénierie solaire, l'établissement est fortement axé sur le développement durable, la transition énergétique et les métiers de l'industrie.	Bachelier (les profils scientifiques S ou techniques T sont fortement privilégiés en raison de la nature des enseignements).	Bourses d’État sénégalaises : Grâce à ses agréments ministériels officiels, le CEFER peut accueillir des étudiants de nationalité sénégalaise dont la scolarité est partiellement ou totalement financée par l'État, ou par le biais de conventions spécifiques d'aide à la formation technique (tels que les dispositifs du 3FPT). Bourses de Mobilité Internationale (ERASMUS+) : Le CEFER se distingue par sa participation active au programme européen Erasmus+. Il offre périodiquement à ses étudiants officiellement inscrits des bourses de mobilité internationale permettant d'effectuer des stages ou des séjours d'études en dehors de leur pays de résidence (notamment en Europe) afin de valider leurs compétences.
33	33	L'IFAA (Institut de Formation en Administration des Affaires) de Dakar est un établissement privé d'enseignement supérieur technique créé en 2005. Agréé par l'État du Sénégal et habilité par l'ANAQ-Sup, il prépare ses étudiants aux diplômes du système LMD ainsi qu'à des diplômes d'État.	L'accès à l'institut s'effectue selon le niveau visé sur étude de dossier :Entrée en BTS / Licence 1 : Être titulaire du Baccalauréat (toutes séries, ou séries spécifiques S/T pour les BTS scientifiques).Entrée en Licence 3 ou Master : Justifier d'un diplôme de niveau Bac+2 ou Bac+3 dans une filière compatible.Processus : Soumission du dossier scolaire (bulletins de notes et diplômes légalisés) suivie d'un entretien obligatoire de motivation avec le service des admissions.	L'IFAA intègre une politique d'aide financière gérée directement sur sa plateforme :Bourses sur critères sociaux et académiques : Les candidats peuvent postuler directement en ligne via le Formulaire de demande de bourse IFAA. Les attributions (réductions partielles de scolarité) se font après étude du mérite ou des difficultés financières.Bourses d’inclusion (Handicap) : L'IFAA applique une politique d'inclusion stricte : les personnes à mobilité réduite bénéficient automatiquement d'une bourse d'études au sein de l'établissement.
34	34	L'IFAGE (Institut Interafricain de Formation en Assurance et en Gestion des Entreprises) est le premier institut privé d'enseignement supérieur d'Afrique francophone spécialisé en Assurance et en Actuariat. Ses diplômes sont accrédités par l'ANAQ-Sup et reconnus dans l'espace de la zone CIMA (Conférence Interafricaine des Marchés d'Assurances).	L'entrée à l'IFAGE est sélective et s'effectue après une évaluation pédagogique :Admission en 1ère année (Licence 1) : Être titulaire du Baccalauréat (les séries scientifiques S et économiques G sont fortement recommandées).Admission en Licence 3 Professionnelle d'Actuariat : Être titulaire d'un Bac+2 (Classes prépa, DUT, L2) en mathématiques, informatique ou économie quantitative.Admission en Master : Être titulaire d'une Licence (Bac+3) dans une filière en adéquation ou compatible avec le management, l'économie ou les mathématiques.	L'IFAGE propose des mécanismes d'appui financier pour soutenir ses étudiants méritants :Bourses d'Excellence IFAGE : L'institut organise chaque année des campagnes d'attribution de bourses d'études partielles (généralement applicables pour le niveau Licence). Les attributions sont soumises à conditions et basées sur l'excellence académique du dossier scolaire de l'étudiant.Prises en charge institutionnelles : De nombreuses compagnies d'assurances de la zone CIMA parrainent ou financent directement les études de certains étudiants ou cadres en formation continue dans l'établissement.
35	35	L’IPD (Institut Polytechnique de Dakar Thomas Sankara) est un établissement privé d’enseignement supérieur et de formation professionnelle d’Afrique de l'Ouest. Fondé en 1991, il propose des diplômes accrédités par l'ANAQ-Sup et basés sur le système LMD (du BTS au Master).	L'accès dépend strictement du niveau académique recherché :Entrée en 1ère année (BTS / Licence 1) : Être titulaire du Baccalauréat (toutes séries) ou diplôme équivalent. L'admission des séries scientifiques (S) ou techniques (T) reste obligatoire pour le pôle d'ingénierie lourde.Entrée en Master : Être titulaire d'une Licence (Bac+3) validée dans la même spécialité ou un domaine jugé équivalent.Processus d'admission : Retrait et dépôt d'un dossier de candidature complet (bulletins de notes antérieurs, diplôme légalisé du Bac, pièce d'identité et CV pour les masters) suivi d'un entretien de motivation obligatoire.Frais de scolarité : Les frais d'inscription administratifs de base s'élèvent généralement à 10 000 FCFA.	L'IPD n'attribue pas automatiquement de bourses de gratuité totale, mais facilite l'accès via deux solutions :Recommandations et Partenariats extérieurs : L'institut dispose de partenariats et de plateformes de gestion (comme BourseSchool) pour accompagner les meilleurs dossiers vers des bourses d'excellence extérieures (comme la bourse UEMOA) ou d'ONG. Aide au financement social : L'école peut étudier les dossiers sociaux corrects pour proposer des tarifications allégées et des modalités de paiement mensuelles très flexibles.
36	36	Le Groupe IPG-ISTI (Institut Privé de Gestion / Institut Supérieur de Technologie Industrielle), fondé en 1981, est une institution d'enseignement supérieur privée de référence à Dakar. Ses formations d'ingénieurs et de gestionnaires sont habilitées par l'ANAQ-Sup et reconnues par le CAMES.	L’accès à l'IPG-ISTI se fait après examen du dossier pédagogique selon le niveau visé :Admission en 1ère année (BTS / Licence 1) : Être titulaire du Baccalauréat (toutes séries) ou diplôme équivalent (BT pour les branches industrielles). Sauf exceptions, les séries scientifiques (S) et techniques (T) sont indispensables pour les diplômes d'ingénieurs avancés.Admission en Master / Cycle Ingénieur : Être titulaire d'une Licence (Bac+3) ou d'un niveau d'ingénieur en adéquation avec la filière demandée.Dossier d'inscription standard : Formulaire de préinscription, bulletins de notes de la dernière classe, copie légalisée du diplôme et relevé du Bac, copie de la pièce d'identité et photos d'identité.	L'IPG-ISTI propose plusieurs leviers d'allègement ou d'aide financière :Prises en charge étatiques (Bourses 3FPT) : L'établissement est éligible aux financements du 3FPT (Fonds de Financement de la Formation Professionnelle et Technique). Les étudiants sénégalais peuvent postuler pour obtenir des bons de prise en charge (partielle ou totale) sur les filières techniques et professionnelles.Bourses sur plateformes partenaires : Le groupe met à disposition des places sur des plateformes centralisées de bourses (comme BourseFi) offrant des opportunités de bourses d'études complètes ou de réductions significatives pour les étudiants sénégalais ou résidents.Bourses des collectivités locales : Grâce à sa reconnaissance d'utilité publique, les étudiants de l'IPG-ISTI bénéficient fréquemment des bourses sociales attribuées par la Mairie de Dakar ou d'autres municipalités du pays.
37	37	L'Université Amadou Hampaté Bâ (UAHB) est un établissement d'enseignement supérieur privé laïc situé à Dakar, au Sénégal. Ses formations mènent aux diplômes de BTS, Licence, Master et Doctorat d'État en Médecine. 	L'admission globale se fait principalement sur étude de dossier pédagogique.En Licence 1 (L1) / BTS : Être titulaire du Baccalauréat sénégalais ou d'un titre admis en équivalence.En Licence 2 ou Licence 3 : Avoir validé les crédits requis des années précédentes (système LMD) ou disposer d'un diplôme intermédiaire (DUT, BTS) dans la même mention.En Master : Justifier d'un diplôme de Licence (Bac+3) dans un domaine compatible.	L'UAHB étant une université privée, les étudiants s'acquittent généralement de frais de scolarité mensuels. Toutefois, des solutions de financement existent :Prise en charge et bourses d'excellence : L'université accepte les étudiants disposant d'une attestation de prise en charge ou d'une bourse octroyée par des organismes partenaires ou l'État.Réductions internes : Des exonérations partielles ou bourses d'études internes peuvent être accordées selon des critères d'excellence académique ou sociale lors de l'étude du dossier.
38	38	L'UCAO-Saint Michel (le Complexe Saint-Michel situé à Dakar) est l'une des composantes majeures de l’Université Catholique de l’Afrique de l’Ouest au Sénégal. Cet établissement privé réputé propose des cursus professionnalisants allant du BTS au Master, ainsi que des parcours de Doctorat, largement reconnus par le CAMES et l'ANAQ-Sup.	L’admission à l'UCAO-Saint Michel n'est pas automatique. Elle repose sur la sélection et la motivation du candidat.Admission en 1ère année (BTS / Licence 1) : Être titulaire du Baccalauréat (toutes séries, avec une préférence pour les séries L, S ou G selon la filière). La sélection se fait sur étude de dossier, suivie d’un entretien de motivation avec le responsable pédagogique.Admission en Master 1 : Être titulaire d'une Licence 3 ou d'un diplôme équivalent (Bac+3) validé dans le même domaine d'études.	L'UCAO-Saint Michel est un établissement privé dont les frais de scolarité sont entièrement à la charge de l'étudiant (frais d'inscription annuels d'environ 100 000 FCFA + mensualités variables selon le cycle). Cependant, plusieurs leviers d'aide existent :Bourses sociales et d'excellence de l'établissement : Des réductions de scolarité (exonérations partielles) peuvent être accordées aux étudiants déjà inscrits affichant d'excellents résultats académiques ou traversant des difficultés financières justifiées.Prises en charge de l'État : L'établissement accueille les bacheliers orientés par l'État du Sénégal via la plateforme Campusen (selon les quotas et conventions en vigueur).Partenariats entreprises et ONG : Possibilité de financement pour les étudiants parrainés par des organisations ou des entreprises partenaires de l'école.
39	39	L'Institut Mariste d'Enseignement Supérieur (IMES) est un pôle d'excellence de l'UCAO situé au sein du prestigieux domaine du Cours Sainte-Marie de Hann à Dakar. Contrairement à Saint-Michel, l'IMES s'est fait une réputation unique grâce à ses classes préparatoires scientifiques intégrées et ses diplômes d'ingénieur en partenariat avec des universités européennes.	L'accès à l'IMES est sélectif, en particulier pour les filières scientifiques et préparatoires.Filières Prépas / Ingénieur : Sélection rigoureuse sur étude de dossier. Les candidats doivent être titulaires d'un Baccalauréat Scientifique (S1, S2 ou équivalent) avec d'excellentes notes en Mathématiques, Physique-Chimie et Français. Un entretien de motivation valide l'admission.Filières Générales (Sciences Po, Comm, Gestion) : Accessibles avec un Baccalauréat (Séries L, G ou S), après examen du dossier scolaire de Seconde, Première et Terminale.	L'IMES applique des frais de scolarité propres aux écoles de cadres supérieures privées. Des mécanismes de soutien sont prévus :Bourses d'Excellence et de Partenariat : Grâce à ses accords internationaux (comme avec la FESIC), certains étudiants peuvent obtenir des bourses d'études ou des facilités pour poursuivre leur cycle ingénieur à l'étranger (notamment en France).Financements nationaux et sociaux : Conventionné avec l'État du Sénégal, l'institut peut accueillir des étudiants boursiers de l'État ou aidés par des financements de formation professionnelle (comme le 3FPT).
40	40	L''Université Dakar Bourguiba (UDB) est un établissement privé d''enseignement supérieur qui propose des formations professionnalisantes dans plusieurs domaines tels que les sciences de la santé, les sciences et technologies, la gestion, les sciences humaines et les sciences juridiques. L''université met l''accent sur la qualité académique, l''innovation et l''insertion professionnelle.	L'accès à l'UDB dépend du niveau d'études visé et s'organise principalement comme suit :En Licence 1 (L1) : Être titulaire du Baccalauréat sénégalais ou d'un titre admis en équivalence. Un Baccalauréat scientifique (S1, S2, etc.) est expressément exigé pour s'inscrire en UFR de Sciences et Technologies.En Master et Doctorat : Admission prononcée après étude d'équivalence sur dossier et validation par un jury ou un comité scientifique de l'UFR concernée.	En tant qu'établissement privé, l'UDB propose et accepte différents leviers de soutien financier :Bourses d'excellence de l'UDB : Octroyées de manière interne aux étudiants qui affichent des résultats académiques exceptionnels.Bourses de l'État et collectivités : L'UDB est conventionnée pour recevoir les bacheliers orientés par l'État. Elle est aussi éligible aux bourses d'études octroyées par les mairies locales (comme les Bourses de la Mairie de Dakar).
41	41	L''Université Professionnelle (UNIPRO) est un établissement privé d''enseignement supérieur qui dispense des formations orientées vers l''insertion professionnelle dans plusieurs domaines, notamment le management, les sciences, les technologies, l''informatique, la santé et les métiers professionnels. Les enseignements privilégient les compétences pratiques, les stages et l''employabilité.	L’admission se déroule en 4 étapes clés (Sélection sur dossier puis entretien) :En Licence 1 / BTS : Être titulaire du Baccalauréat toutes séries (ou équivalent).En Licence 3 : Avoir validé une Licence 2 ou détenir un diplôme de niveau Bac+2 équivalent.En Master : Justifier d'un diplôme de niveau Licence (Bac+3) dans une filière d'études compatible.Pièces à fournir : Copie légalisée du Bac, relevés de notes associés, copie de la pièce d'identité et photos d'identité récentes.	L'école applique un système de scolarité privée, mais propose des alternatives d'aide financière importantes pour intégrer son réseau d'alternance :Bourses d'études internes : Un formulaire dédié sur le site permet de postuler à des réductions partielles de scolarité.Financement par l'alternance : Grâce à ses 200+ entreprises partenaires, l'étudiant est placé en entreprise dès la première année, ce qui facilite l'insertion et l'autofinancement professionnel.
42	42	L'Université du Sahel (UNIS), fondée en 1998 et située à Mermoz (Dakar), est une institution privée reconnue par l'État du Sénégal et accréditée par le CAMES. Elle propose plus de 50 programmes de formation.	Le processus d'intégration s'effectue principalement par le biais d'un portail numérique en 4 étapes :En BTS / Licence 1 : Être titulaire du Baccalauréat (ou d'un titre admis en équivalence). L'accès se fait sur étude approfondie du dossier scolaire (relevés de notes de Seconde, Première, Terminale) et peut être complété par un entretien de motivation ou un examen d'entrée.En Licence 2/3 ou Master : Admission sur dossier pour les étudiants en réorientation ou titulaires d'un Bac+3 compatible.	L'université étant un établissement privé, le financement repose sur des frais d'inscription et de scolarité annuels (variables selon la filière). Plusieurs solutions existent :Exonérations internes : L'UNIS accorde parfois des réductions partielles de scolarité basées sur les résultats académiques ou des critères sociaux de l'étudiant.Bourses d'État et de partenaires : Acceptation des prises en charge d'organismes, de mairies, ou de bourses du gouvernement sénégalais pour les bacheliers orientés.
43	43	Le Groupe SUP'INFO Sénégal (Académie Internationale de Dakar), fondé en 1992, est un établissement privé d'enseignement supérieur agréé par l'État sénégalais et accrédité par le CAMES. C'est l'un des pionniers de la formation aux métiers du numérique, de l'informatique et des technologies émergentes en Afrique de l'Ouest.	L'accès à l'école est sélectif et s'effectue en plusieurs étapes :En Licence 1 / Bachelor 1 : Être titulaire du Baccalauréat (Toutes séries admises, mais les profils scientifiques S ou techniques G sont fortement recommandés pour les parcours d'ingénierie).En Admission parallèle (L2, L3, Master) : Sur étude de dossier pour les titulaires d'un BTS, DUT ou Licence d'une autre institution dans un domaine compatible.	SUP'INFO est un établissement entièrement privé. Cependant, des solutions de soutien existent pour alléger les frais de scolarité :Bourses d'État (Sénégal et sous-région) : En tant qu'école accréditée par le CAMES, SUP'INFO accueille les bacheliers sénégalais orientés par l'État via les quotas de bourses nationales.Financement par l'Alternance et les Stages : La pédagogie est très axée sur l'entreprise. Des partenariats permettent aux étudiants en fin de cycle de réaliser des stages rémunérés ou de l'alternance prenant en charge une partie de leurs mensualités.Réductions sociales / Mairies : Des conventions locales permettent aux étudiants d'obtenir des exonérations partielles via des partenariats avec les municipalités ou le fonds [3FPT].
44	44	L'Institut Supérieur des Sciences de la Santé (SUP de Santé), situé à Mermoz, Dakar, est un établissement privé accrédité par l'État et l'ANAQ-Sup, spécialisé dans les formations médicales et paramédicales.	L'admission se fait sur étude de dossier et entretien de motivation :BTS/Licence : Baccalauréat requis (profils scientifiques valorisés).Master : Licence 3 validée dans le domaine de la santé ou gestion compatible.	Orientation État : L'institut accueille des bacheliers via Campusen.Financement 3FPT : Possibilité de solliciter des bons de prise en charge.Aides : Accords avec des municipalités pour des demi-bourses.
45	45	L'BEM Management School (BEM Dakar) est une grande école de commerce privée de référence basée à Dakar. Issue d'un partenariat historique avec BEM Bordeaux (devenu KEDGE Business School), elle propose des diplômes de Bachelor, Master, MSc et DBA, largement accrédités par le CAMES.	L'accès à l'école est hautement compétitif et repose sur un processus de sélection strict.En 1ère année (Bachelor / Licence) : Être titulaire du Baccalauréat (toutes séries). L'entrée s'effectue obligatoirement sur test écrit et entretien oral d'admission.Admissions Parallèles (L2, L3, Master) : Accessibles sur étude de dossier pour les étudiants ou professionnels titulaires d’un niveau Bac+1, Bac+2 (BTS, DUT) ou d'une Licence 3 compatible.	Les frais de scolarité à BEM Dakar reflètent les standards internationaux des écoles de cadres (comptant environ 1 635 000 F CFA à plus de 3 300 000 F CFA par an selon le programme). Les aides envisageables sont :Exonérations au mérite : Des réductions partielles de scolarité ou bourses internes de 50% sont périodiquement attribuées aux dossiers académiques d'exception.Bourses d’État et régionales : Bien qu'école d'élite, BEM est habilitée à accueillir certains boursiers nationaux via des conventions avec des institutions étatiques ou des mairies (comme les bourses de la Mairie de Dakar).
46	46	L'École d'Ingénieurs et de Technologies BEM TECH est la branche technologique et scientifique de BEM Africa située à Dakar (Sacré-Cœur I). Cet établissement privé propose des cursus d'excellence dans le secteur des technologies, de l'énergie et des infrastructures, menant à des diplômes de Licence, Master, et Cycles Ingénieurs.	L’entrée à BEM TECH est sélective et s'organise en 4 étapes clés :Dépôt du Dossier de candidature : Formulaire rempli, relevés de notes des trois dernières années de lycée, copie légalement certifiée du Baccalauréat.Sélection des profils : Les séries scientifiques (S1, S2) et techniques sont fortement privilégiées pour l'ensemble des spécialités d'ingénierie.Test d'entrée : Évaluations écrites en présentiel ou en ligne (logique, sciences, aptitudes) organisées entre mai et septembre.Entretien individuel : Oral de motivation devant un jury pour valider définitivement le projet d'études.	BEM TECH applique la grille de financement des écoles de cadres supérieures privées de BEM Africa. Cependant, des solutions de soutien existent :Bourses au mérite académique : Des exonérations ou réductions partielles de scolarité internes sont attribuées aux dossiers démontrant une excellence scientifique évidente.Financements et aides territoriales : L'école est éligible aux programmes d'appui des mairies partenaires (comme la Mairie de Dakar) et aux aides au financement de la formation professionnelle via le dispositif national du [3FPT].
47	47	La BEM School of Law est la Grande École de Droit du groupe BEM Africa, située à Dakar (Sacré-Cœur). Placée sous l'autorité académique de l'éminent Professeur Isaac Yankhoba Ndiaye, elle forme des juristes à forte valeur ajoutée en combinant le droit, la gestion et les humanités.	En Bachelor (L1) : Titulaires du Baccalauréat. Entrée sur concours écrit (tests de logique, expression, culture générale) et entretien oral.Admissions parallèles (L2, L3, Masters) : Étudiants titulaires de crédits validés (Bac+2, L3) via une étude de dossier et un entretien.	La scolarité est payante, avec des dispositifs d'appui :Bourses internes d'excellence : Basées sur les résultats au concours.Partenariats institutionnels : Financements via le 3FPT ou des mairies partenaires.
48	48	L'Établissement d'Enseignement Supérieur, des Finances et de l'Administration (ENSUP AFRIQUE), fondé en 2012 et situé à Dakar (Liberté 6 Extension, en face du Camp Leclerc), est une grande école privée sénégalaise. Elle propose un catalogue de 15 filières diplômantes, du BTS au Master, accréditées et reconnues par l'État du Sénégal via le Ministère de l'Enseignement Supérieur (MESRI).	Le recrutement s'organise en fonction du niveau académique visé :En BTS et Licence 1 : Être titulaire du Baccalauréat (sénégalais ou titre équivalent reconnu). La sélection s'effectue sur étude de dossier scolaire (comprenant les bulletins des classes de Seconde, Première et Terminale) suivie d'un entretien de motivation.En Admission parallèle (Licence 3 ou Master) : Accessible aux titulaires d’un diplôme de niveau Bac+2 (BTS, DUT) ou Bac+3 (Licence) compatible avec la mention demandée, après examen de leur cursus antérieur.	ENSUP AFRIQUE intègre plusieurs solutions de financement pour alléger les coûts de scolarité :Bourses et exonérations au mérite : Des campagnes annuelles offrent la possibilité de solliciter des réductions ou demi-bourses de formation internes en fonction de la qualité du dossier académique.Financements professionnels (3FPT) : L'école est éligible aux financements nationaux de la formation professionnelle, permettant d'obtenir des bons de prise en charge pour les étudiants.Conventions Locales : Des partenariats spécifiques sont conclus avec des municipalités et mairies pour accueillir des étudiants boursiers des collectivités locales.
49	49	Le Centre de Formation Africain du Sénégal (CEFAS) est un établissement privé d'enseignement professionnel, technique et supérieur agréé et reconnu par l'État du Sénégal. Situé à Dakar (Cité Keur Damel, Parcelles Assainies), il forme des étudiants du niveau secondaire jusqu'au troisième cycle.	L'accès s'adresse à différents profils selon le cursus visé :Niveau BT / BEP : Accessible après la classe de 3ème avec le BFEM.Niveau BTS / Licence : Être titulaire du Baccalauréat (toutes séries, profils scientifiques recommandés pour la santé et la technique).Niveau Master : Justifier d'une Licence 3 validée dans un domaine d'études compatible.	Le CEFAS est réputé pour sa politique d'ouverture sociale et de financement facilité :Bourses d'Excellence et Sociales du CEFAS : L'école octroie des exonérations allant de 50%, 70% à 100% de réduction sur la scolarité aux étudiants méritants ou en situation financière fragile.Tarifs Boursiers : À titre d'exemple, les bénéficiaires d'une réduction partielle en management règlent environ 100 000 F CFA à l'inscription puis des mensualités réduites à 30 000 F CFA (au lieu du tarif normal).Partenariats Publics : L'établissement collabore avec le [3FPT] (Bons de formation), l'ONFP et diverses mairies pour la prise en charge des étudiants.
50	50	L'Institut Africain de Management (IAM Dakar) est l'une des meilleures grandes écoles de commerce privées d'Afrique. Fondé en 1996 et situé à Mermoz, il propose des cursus d'élite reconnus et accrédités par l'ANAQ-Sup et le CAMES.	L’intégration à l'IAM Grande École est conditionnée par un processus sélectif en plusieurs phases :En Première Année (Licence 1 / Bachelor) : Être titulaire du Baccalauréat (toutes séries acceptées). L'admission se fait sur la base d'une étude de dossier, suivie de tests écrits d'évaluation et d’un entretien de motivation individuel devant un jury.En Admissions Parallèles (Licence 3, Master) : Accessible aux titulaires de diplômes de niveau Bac+2 ou Bac+3 (DUT, BTS, Licence) compatibles avec le parcours visé, après étude approfondie du dossier scolaire et validation des équivalences.	L'IAM étant un établissement privé réputé pour former les cadres d'Afrique, ses frais de scolarité annuels sont entièrement à la charge des familles. Plusieurs options d'appui financier sont toutefois disponibles :Bourses d’Excellence Internes : Lors des rentrées académiques, l'institut peut octroyer des bourses d'études internes avec des réductions partielles significatives (souvent de 50%) accordées aux meilleurs profils de chaque classe.Quotas de l'État : Conventionné avec les autorités nationales, l'IAM accueille chaque année des bacheliers sénégalais boursiers ou orientés directement par l'État du Sénégal.Partenariats Publics et Institutionnels : L'école accepte les dispositifs d'aide au financement comme le [3FPT] pour la formation professionnelle ou des accords passés avec des mairies de la place.
51	51	L'Université Amadou Mahtar Mbow (UAM) est une université publique d'excellence située au cœur du pôle urbain de Diamniadio, au Sénégal. Résolument tournée vers les sciences, les technologies, les métiers des mines, de l'urbanisme et de la gestion, elle propose des formations de pointe alignées sur le système LMD (Licence, Master, Doctorat).	Le mode d'admission à l'UAM dépend de la structure visée :Pour les UFR (Filières classiques LMD) : L'accès direct en Licence 1 pour les bacheliers sénégalais se fait intégralement par orientation de l'État via la plateforme Campusen.Pour Polytech Diamniadio : L'accès reste soumis à la réussite d'un concours d'entrée sélectif national ouvert aux bacheliers des séries scientifiques (S, T) ou de gestion selon les filières, âgés de moins de 22 ans.Pour les étudiants étrangers : L'admission se réalise sur étude de dossier pédagogique pour un recrutement en régime payant. (Frais indicatifs d'environ 120 000 F CFA/mois en Licence et 150 000 F CFA/mois en Master).	L'UAM étant une université publique d'État, les conditions d'aide sont encadrées par les dispositifs publics du Sénégal :Bourses Nationales : Les étudiants de nationalité sénégalaise orientés à l'UAM peuvent bénéficier des bourses d'études de l'État (entière ou demi-bourse) attribuées et gérées par la Direction des Bourses du Ministère de l'Enseignement Supérieur.Bourses d'excellence sous-régionales : L'UAM est également éligible aux programmes d'appui des institutions régionales (tels que les programmes de bourses d'excellence de l'UEMOA).
52	52	Le Dakar Institute of Technology (DIT), fondé en 2019 à la Cité Keur Gorgui (Dakar), est la toute première école supérieure d'Afrique de l'Ouest exclusivement spécialisée en Big Data et Intelligence Artificielle (IA). Ses diplômes sont reconnus par l'ANAQ-SUP et signés par le Ministère de l'Enseignement Supérieur du Sénégal.	L'accès aux différents programmes repose sur une sélection numérique et humaine :En Licence 1 : Être titulaire du Baccalauréat. Les séries scientifiques (S1, S2) ou techniques sont vivement recommandées pour la filière Big Data. L'admission se réalise directement en ligne sur leur site web.En Master : Justifier d'un niveau minimum Licence 3 (Bac+3) validé en informatique, mathématiques ou statistiques.Processus général : Examen minutieux du dossier scolaire, tests de niveau (logique et technique) et validation par un entretien de motivation.	En tant qu'établissement privé de pointe, la scolarité y est payante, mais plusieurs mécanismes d'appui sont mis en œuvre :Bourses internes d'excellence : Des réductions partielles de scolarité ou des exonérations de droits d'inscription peuvent être accordées aux profils affichant des résultats exceptionnels aux tests d'entrée.Financement professionnel (3FPT) : L'école accepte les dispositifs d'aide au financement étatiques sénégalais pour la formation professionnelle.Partenariats entreprises : Grâce aux démonstrations de projets (Démo Days), de nombreux étudiants décrochent des contrats d'alternance ou des stages qualifiants en fin d'études permettant l'autofinancement.
53	53	L'ICAGI (Institut Communautaire Africain de Gestion et d'Ingénierie - Amadou Mahtar Mbow) propose des programmes de niveau Licence et Master basés sur le système LMD, répartis en sciences de gestion, sciences et technologies, ainsi qu'un diplôme en médiation.	La candidature passe par l’étude d'un dossier puis par un entretien obligatoire.Admission en Licence 1 : Être titulaire du Baccalauréat (ou équivalent).Admission en Master 1 : Détenir une Licence 3 (Bac+3) dans une spécialité compatible.	L'école applique une politique d'accompagnement social et d'excellence :Bourses de mérite académique : Des réductions partielles ou totales sur la scolarité sont accordées aux bacheliers ayant obtenu des mentions au Baccalauréat.Prise en charge via conventions : L'école dispose de partenariats offrant des réductions de scolarité à certains groupes communautaires ou associatifs.
54	54	Créé par un couple d’experts-comptables, l’AFI-UE se positionne comme un pont direct entre le monde académique et le milieu professionnel. Surnommée l’« Université de l’Entreprise », l’école met l’accent sur l’employabilité immédiate, l’entrepreneuriat et l’adéquation de ses programmes avec les besoins réels du marché ouest-africain. Elle est également membre de la Fédération Européenne Des Écoles (FEDE).	L'admission se fait sur étude de dossier suivie d'un entretien individuel d'orientation obligatoire.Admission en Licence 1 : Être titulaire du Baccalauréat (toutes séries éligibles selon la filière) ou d’un diplôme équivalent.Admission en Licence 2 / Licence 3 : Justifier respectivement d'un niveau Bac+1 ou d'un diplôme de type BTS, DUT, L2 validé.Admission en Master 1 / Master 2 : Être titulaire d'une Licence 3 (Bac+3) ou d'un Master 1 (Bac+4) homologué dans un domaine compatible.	L'AFI-UE applique différents mécanismes pour faciliter l'accès à ses formations :Bourses d’Excellence : Réductions partielles sur les mensualités de scolarité attribuées aux bacheliers ayant obtenu de fortes moyennes ou des mentions au Baccalauréat.Partenariats Institutionnels : Prise en charge partielle possible grâce à des conventions signées avec des entreprises partenaires, des collectivités locales ou des associations.Quotas de l'État : L’université reçoit périodiquement des étudiants orientés et pris en charge par l'État sénégalais via le Ministère de l’Enseignement Supérieur.
55	55	Fondé le 14 juin 2008 par un collectif de jeunes cadres et d'universitaires, l’IESMD est un établissement d'enseignement supérieur privé agréé par l'État du Sénégal (N° 0088/AG/MESUCUR/DES/DFS) et habilité par l'ANAQ-Sup. Situé à Dakar, l'institut s'est donné pour mission de former des professionnels immédiatement opérationnels en combinant rigueur théorique et immersion en entreprise, afin de répondre avec précision aux besoins du marché juridique et de la gestion en Afrique.	L'accès aux différents programmes de l'institut est sélectif et s'opère sur étude de dossier académique suivie d'un entretien de motivation.Admission en Licence 1 : Être titulaire du Baccalauréat sénégalais (toutes séries) ou d'un titre étranger équivalent admis en dispense.Admission en Master 1 : Être titulaire d'une Licence 3 (Bac+3) en Droit ou en Gestion délivrée par un établissement reconnu ou accrédité.Dossier type à constituer : Copie légalisée du diplôme (Bac ou Licence), relevés de notes des dernières années d'études, copie de la pièce d'identité et fiches d'inscription dûment remplies.	L'IESMD intègre une dimension sociale forte pour accompagner ses étudiants :Bourses sociales et d'excellence : Des réductions partielles sur les mensualités de scolarité peuvent être octroyées aux étudiants méritants ou sur critères sociaux après examen de leur situation par la commission interne.Partenariats institutionnels : En tant qu'établissement reconnu, l'IESMD peut accueillir des étudiants bénéficiant de programmes de subventions locales (comme les dispositifs de la Mairie de Dakar) ou d'orientations spécifiques liées aux quotas d'aide à la formation.
56	56	L'ETICCA Business School Dakar est une école supérieure de management privée, orientée vers la formation de cadres et de leaders capables de porter la transformation économique du continent. Forte de ses accréditations et partenariats internationaux, l'école combine une pédagogie moderne et opérationnelle, très axée sur l'ouverture internationale grâce à des parcours de continuité d'études en Europe.	L'inscription définitive dépend d'un processus sélectif visant à évaluer le profil du candidat.En 1ère année (BTS / Licence) : Être titulaire du Baccalauréat toutes séries (ou diplôme équivalent homologué).En 3ème année (Licence/Bachelor) : Justifier d'un niveau Bac+2 (BTS, DUT ou L2 validée) dans une filière connexe. Un dossier de projets professionnels peut être analysé.En Master 1 / MBA : Posséder un diplôme de niveau Bac+3 (Licence ou Bachelor d'école de commerce).	L'établissement favorise l'accessibilité à ses formations d'élite via plusieurs leviers :Bourses d’excellence académique : Réductions de scolarité attribuées aux bacheliers méritants ayant décroché une mention au Baccalauréat.Financements et subventions d'entreprises : Grâce à son réseau de partenaires économiques au Sénégal, des facilités de paiement ou des bourses de stage peuvent être accordées.
57	57	Fondée sous l'initiative d'une dizaine d'enseignants du supérieur, l'ESGIB est spécialisée dans la formation technique et scientifique de pointe. L'école se donne pour mission de former des cadres et des ingénieurs hautement qualifiés dans les domaines de la transformation, de la chimie, de la sécurité et des biotechnologies. La pédagogie repose sur un fort ancrage pratique, incluant des travaux en laboratoire, des visites d'usines et des stages industriels obligatoires.	L'accès est sélectif et orienté vers les profils scientifiques/techniques :Licence 1 : Bac scientifique (S1, S2) ou technique (T1, T2).Master 1 : Licence (Bac+3) dans une spécialité compatible.Dossier : Acte de naissance, CNI, attestation Bac, relevés de notes, photos, demande manuscrite.	L'ESGIB propose des solutions de financement :Échelonnement : Paiement des frais de scolarité sur 9 mensualités maximum.Partenariats : Possibilité de prise en charge par des entreprises partenaires.
58	58	Fort de plus de 20 ans d'expérience, le Groupe ESUP Dakar se distingue par une approche pédagogique pluridisciplinaire organisée autour de trois pôles académiques majeurs : le commerce/gestion, la technologie et la santé. L’établissement s’attache à proposer des rythmes flexibles à travers des cours du jour, des cours du soir, le week-end, ainsi que des modules à distance.	L'inscription s'effectue après une sélection rigoureuse.Sélection : L'admission repose sur l’étude de votre dossier académique suivie d'un entretien de motivation obligatoire.Niveau requis : Disposer du Baccalauréat (toutes séries) pour l'entrée en 1ère année (BTS ou Licence). Justifier d'un diplôme Bac+3 homologué dans une spécialité compatible pour intégrer le cycle Master.	Le Groupe ESUP Dakar propose des dispositifs d'accompagnement financier :Financements nationaux : Possibilité de prise en charge ou subvention de votre formation par le 3FPT (Fonds de Financement de la Formation Professionnelle et Technique) ou par la Mairie de la ville de Dakar pour les étudiants de nationalité sénégalaise.Bourses d'intégration : Pour les étudiants internationaux, l'école met en place un mécanisme de réductions sur les coûts d'études grâce à un système de bourses d'établissement.
59	59	L'ESTG Sénégal se donne pour mission de former de jeunes cadres africains opérationnels et prêts à l'emploi en plaçant l'entrepreneuriat au cœur de sa pédagogie. Son corps professoral est composé d’universitaires et d'enseignants issus du secteur professionnel. Grâce à son accréditation FEDE, elle allie un ancrage local fort à des perspectives d'ouverture internationale en délivrant des diplômes européens.	La procédure de recrutement repose sur la sélection des dossiers académiques suivie d'une évaluation individuelle.Admission en Cycle Bachelor / Licence 1 : Être obligatoirement titulaire du Baccalauréat (toutes séries) ou d’un titre admis en équivalence.Admission en Cycle Master 1 : Justifier d'un diplôme de niveau Bac+3 (Licence professionnelle ou Bachelor d’école) dans une spécialité compatible avec le parcours visé.Processus : Soumission du dossier d'inscription suivie d'un entretien de motivation obligatoire avec le jury d'admission.	L'ESTG propose régulièrement des opportunités d'allègement financier pour soutenir ses apprenants :Bourses d'établissement (totales ou partielles) : L'école met périodiquement en place des campagnes de bourses d'études via des formulaires d'offres de bourses dédiés afin de réduire les coûts des mensualités.Partenariats de formation : Des conventions avec des cabinets d'orientation (comme les programmes du Cabinet CAO) permettent de bénéficier de bourses d'exonération partielle lors de la rentrée universitaire.
60	60	L’Institut Polytechnique de Saint-Louis (IPSL) est l’école d’ingénieurs de l’Université Gaston Berger de Saint-Louis. Créé en 2012, il a pour mission de former des ingénieurs de conception et des cadres techniques capables de répondre aux besoins de l’industrie et de contribuer au développement économique du Sénégal, particulièrement dans la région Nord. L’IPSL propose notamment des formations dans les domaines de l’électromécanique, du génie civil, de l’informatique et des télécommunications. L’institut développe une formation scientifique et technologique professionnalisante et participe également aux activités de recherche et d’innovation de l’UGB.	En tant qu'établissement public d'élite, l'accès à la formation initiale est hautement sélectif et s'effectue par voie de concours.Entrée en 1ère année (Classes Préparatoires) :Profil requis : Être titulaire (ou élève en classe de Terminale) d'un Baccalauréat scientifique ou technique (S1, S2, S3, T1, T2).Âge requis : Avoir moins de 22 ans au 1er octobre de l'année en cours.Épreuves écrites : Le concours national se compose de 4 matières fondamentales : Mathématiques, Physique, Français et Anglais.Frais de dossier : 7 000 F CFA pour participer aux épreuves.	Le statut d'école publique rattachée à l'UGB confère aux étudiants un accès direct aux aides de l'État :Bourses nationales du Sénégal : Les étudiants de nationalité sénégalaise admis au concours général de l'IPSL bénéficient, selon les critères d’attribution de la direction des bourses, du taux de bourse entière ou d'allocations d’études universitaires publiques.Programmes d'excellence internationaux : Grâce à des partenariats de co-développement comme le Skilled Africa Project, de nombreux élèves-ingénieurs de l'IPSL bénéficient de bourses de mobilité internationale intégrales pour effectuer une partie de leur cursus en ingénierie à l'étranger (par exemple en Chine ou en Europe).
61	61	L’École Supérieure du Bâtiment (BATISUP) est un établissement privé sénégalais spécialisé dans les métiers du bâtiment, des travaux publics et du génie civil. Créée en 2006, elle forme des étudiants nationaux et étrangers dans les domaines techniques liés au secteur de la construction. L’établissement participe notamment aux examens organisés par l’État du Sénégal et prépare ses étudiants à des diplômes professionnels tels que le Brevet de Technicien Supérieur en génie civil. Sa formation est orientée vers la maîtrise des techniques de construction et l’insertion professionnelle dans le secteur des BTP.	La sélection s'effectue sur examen du dossier de candidature et selon le niveau visé :Admission en 1ère année (DTS / Licence 1) : Être titulaire d'un Baccalauréat (scientifique ou technique) ou d'un Brevet de Technicien (BT) en Génie Civil.Admission en 3ème année (Licence 3) : Justifier d'un diplôme de niveau Bac+2 type DTS, BTS, DUT, DUES ou DEUG scientifique dans le domaine.	BATISUP ne dispose pas d'un système classique de bourses d'État directes, mais applique des mécanismes d'allègement financier intégrés :Discrimination positive pour l'accès aux filières techniques : L'établissement applique un tarif de scolarité réduit pour les étudiantes afin d'encourager l'accès des femmes aux métiers du Génie Civil.Facilités de paiement : Les frais annuels peuvent être échelonnés en mensualités. De plus, une réduction de l'équivalent d'un mois de scolarité est accordée aux familles effectuant un paiement intégral lors de l'inscription.
62	62	L’École Supérieure de Génies (ESGE) est un établissement privé d’enseignement supérieur technique créé en 2004 sous le nom d’École Supérieure de Génie Électrique, avant de devenir École Supérieure de Génies en 2008. L’établissement forme des techniciens supérieurs, des ingénieurs technologues et des ingénieurs de conception dans plusieurs domaines scientifiques et technologiques. Son offre couvre notamment l’électrotechnique, l’électromécanique, l’électronique industrielle, l’informatique industrielle, les télécommunications, le génie civil et l’énergie. L’ESGE propose des formations de niveau BTS, DTS, Licence et Master et développe également des formations modulaires destinées aux entreprises.	L'inscription s'effectue sur étude de dossier académique et entretien d'orientation pédagogique.Pour les cycles BTS, DTS et Licence 1 : Être titulaire d'un Baccalauréat scientifique ou technique (séries S1, S2, S3, T1, T2) ou d'un Brevet de Technicien (BT) correspondant à la filière visée.Pour le cycle Master : Justifier d'un diplôme de niveau Licence 3 (Bac+3) validé dans une spécialité d'ingénierie compatible.Candidature : L'institut met à disposition un espace numérique dédié sur son site internet via le portail d'Inscription ESGE.	L'ESGE s'inscrit dans un cadre d'accompagnement et d'accessibilité aux formations scientifiques :Financements nationaux : En tant qu'école légalement reconnue et habilitée par les instances d'évaluation nationales, ses étudiants sont éligibles aux différents guichets de subventions locales ou d'aide à la formation professionnelle existant au Sénégal.Facilités internes : Des aménagements de paiement par mensualités et des bourses d'allègement de scolarité internes sont évalués par l'administration lors de l'étude du dossier.
63	63	Akademia Dakar s'est positionnée comme l'une des rares grandes écoles privées en Afrique de l'Ouest exclusivement spécialisée dans les carrières juridiques, la science politique et la gouvernance. Sa pédagogie originale repose sur l'approche expérientielle et la professionnalisation à travers des stages et séjours obligatoires en entreprise pour l'ensemble des étudiants. L'école a notamment conclu un partenariat stratégique majeur avec l'Université Senghor d’Alexandrie (opérateur de la Francophonie) pour délivrer des diplômes conjoints de très haut niveau à destination des cadres africains.	La sélection est ouverte à toutes les nationalités africaines et s'effectue sur examen rigoureux du dossier scolaire ou universitaire :Admission en Licence 1 : Êtretitulaire du Baccalauréat (toutes séries).Admission en Master 1 ou Master 2 : Être titulaire d'une Licence en Droit, en Sciences Politiques ou en Administration des Entreprises (accès sur dossier et avis du conseil pédagogique).Candidature : Le dépôt peut s'effectuer directement en ligne sur la plateforme d'Inscription Akademia Dakar.	Akademia Dakar met en œuvre des mécanismes de soutien à l'excellence et à l'inclusion sociale :Bourses internes d'aide : Des exonérations et réductions sur les coûts d'études peuvent être négociées ou octroyées lors de commissions d'excellence pour les profils académiques exceptionnels.Bourses de la Ville de Dakar : En tant qu'école formellement habilitée par les instances ministérielles, les étudiants de nationalité sénégalaise résidant dans la commune peuvent postuler aux enveloppes de Bourses d'Études de la Mairie de Dakar pour financer une partie de leurs frais de scolarité.
64	64	L’EMIA (Université Africaine des Sciences et Technologies), anciennement connue sous le nom d’IAED (Institut Africain des Études du Développement), est un établissement d’enseignement supérieur privé. Elle se situe à Dakar, au Sénégal. La vision de l’université repose sur le panafricanisme et la formation de « changemakers » (leaders et acteurs du changement). Leurs programmes s’axent fortement sur les métiers du développement durable et l’employabilité en Afrique.	Pour l’admission en Licence (Bachelor) : Vous devez obligatoirement posséder le Baccalauréat. L’accès se fait généralement en 1ère année (L1). Pour une admission parallèle (en L2 ou L3), vous devez valider des crédits d’études supérieures dans un domaine similaire. \r\n    Pour postuler, vous devez préparer et transmettre via le Formulaire d’inscription en ligne EMIA ou directement au service de scolarité les documents suivants :\r\n    - Identité : Une photocopie lisible de votre carte nationale d’identité (CNI) ou de votre passeport (obligatoire pour les étudiants internationaux).\r\n    - Scolarité : Vos derniers relevés de notes ou bulletins (les relevés de notes de la Terminale et le relevé du Baccalauréat sont généralement exigés). \r\n    - Motivation : Une lettre de motivation rédigée par vos soins, explicitant votre projet professionnel. \r\n    - Visuel : Une photo d’identité récente. 	L’EMIA propose ou est éligible à plusieurs types d’accompagnements financiers pour aider les étudiants à financer leur scolarité : \r\n    Bourses d’Excellence EMIA :\r\nL’établissement octroie en interne des bourses d’excellence aux meilleurs profils ou aux nouveaux bacheliers ayant obtenu des mentions au Baccalauréat. \r\nFinancements 3FPT : L’université étant accréditée par le 3FPT (Fonds de Financement de la Formation Professionnelle et Technique), les étudiants de nationalité sénégalaise peuvent solliciter des bons de prise en charge auprès de cet organisme pour couvrir une partie importante de leurs frais de scolarité.
\.


--
-- Data for Name: universite_filiere; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.universite_filiere (id_universite, id_filiere) FROM stdin;
1	1
1	3
1	5
1	18
1	19
1	32
1	74
1	101
1	106
1	121
1	128
1	129
1	153
1	155
1	161
1	179
1	180
1	181
1	182
1	183
1	184
1	185
1	186
1	187
1	188
2	1
2	3
2	18
2	25
2	67
2	77
2	97
2	101
2	105
2	110
2	114
2	121
2	128
2	129
2	148
2	153
2	179
2	180
2	181
2	182
2	184
2	189
2	190
2	191
2	192
2	193
2	194
2	195
2	196
2	197
2	198
2	199
2	200
2	201
3	1
3	2
3	3
3	5
3	15
3	18
3	20
3	21
3	78
3	82
3	84
3	88
3	93
3	153
3	161
3	179
3	180
3	184
3	202
3	203
3	204
3	205
3	206
3	207
3	208
3	209
4	1
4	2
4	7
4	8
4	9
4	13
4	14
4	68
4	77
4	81
4	82
4	90
4	91
4	92
4	105
4	137
4	177
4	202
4	210
4	211
4	212
4	213
4	214
4	215
5	1
5	5
5	7
5	9
5	10
5	28
5	67
5	68
5	75
5	77
5	78
5	79
5	97
5	100
5	112
5	121
5	131
5	136
5	137
5	138
5	149
5	159
5	163
5	166
5	178
6	1
6	3
6	7
6	68
6	80
6	93
6	95
6	105
6	114
6	115
6	179
6	181
6	182
6	184
6	185
6	188
6	216
6	217
6	218
6	219
6	220
6	221
6	222
6	223
6	224
6	225
6	226
6	227
7	3
7	17
7	20
7	21
7	73
7	74
7	75
7	80
7	97
7	110
7	115
7	118
7	149
7	152
7	153
7	179
7	199
7	228
7	229
7	230
7	231
7	232
8	1
8	9
8	74
8	99
8	101
8	116
8	128
8	129
8	143
8	145
8	155
8	233
8	234
8	235
8	236
8	237
8	238
8	239
8	240
9	5
9	25
9	95
9	147
9	179
9	199
9	241
9	242
9	243
9	244
9	245
9	246
9	247
9	248
9	249
9	250
9	251
9	252
10	153
10	179
10	265
10	266
11	75
11	91
11	110
11	153
11	161
11	179
11	184
11	185
11	193
11	199
11	232
11	250
11	253
11	254
11	255
11	256
11	257
11	258
11	259
11	260
11	261
11	262
11	263
11	264
12	2
12	83
12	142
12	153
12	158
12	162
12	184
12	185
12	268
12	269
12	270
13	23
13	152
13	153
13	161
13	199
13	271
13	272
13	273
13	274
13	275
14	2
14	25
14	77
14	105
14	138
14	155
14	202
14	211
14	277
16	175
16	197
17	278
17	279
17	280
18	67
18	97
18	100
18	149
18	281
19	8
19	13
19	83
19	88
19	213
19	282
19	283
19	284
19	285
19	286
20	14
20	85
20	86
20	115
20	135
20	166
20	199
20	231
20	233
20	264
20	287
20	288
20	289
20	290
20	291
20	292
20	293
20	294
21	11
21	13
21	14
21	287
21	295
21	296
21	297
22	194
22	242
22	298
22	299
22	300
22	301
22	302
23	199
23	303
23	304
23	305
23	306
23	307
24	193
24	194
24	199
24	289
24	303
24	308
24	309
25	86
25	241
25	310
25	311
25	312
25	313
25	314
26	193
26	194
26	315
26	316
26	317
26	318
26	319
28	5
28	9
28	10
28	12
28	13
28	16
28	67
28	71
28	72
28	77
28	79
28	97
28	114
28	115
28	118
28	119
28	127
28	129
28	159
28	229
29	9
29	10
29	11
29	12
29	13
29	16
29	68
29	71
29	77
29	78
29	79
29	81
29	83
29	97
29	100
29	105
29	107
29	115
29	116
29	138
29	149
29	162
29	286
30	1
30	9
30	10
30	15
30	68
30	71
30	75
30	78
30	79
30	86
30	115
30	116
30	121
30	149
30	151
30	156
30	158
30	162
30	202
31	2
31	15
31	17
31	72
31	75
31	81
31	82
31	83
31	84
31	85
31	86
31	87
31	88
31	160
31	162
31	205
31	308
32	2
32	81
32	86
32	202
32	211
33	7
33	15
33	25
33	68
33	72
33	77
33	78
33	79
33	91
33	97
33	102
33	106
33	107
33	214
33	240
34	5
34	70
34	77
34	97
34	108
35	10
35	67
35	68
35	71
35	72
35	77
35	79
35	97
35	102
35	149
35	166
36	2
36	15
36	68
36	71
36	77
36	79
36	81
36	83
36	88
36	97
36	112
36	131
36	139
36	149
36	166
36	213
36	288
37	1
37	3
37	5
37	10
37	23
37	71
37	77
37	91
37	92
37	97
37	128
37	129
37	147
37	149
38	2
38	9
38	10
38	15
38	68
38	71
38	73
38	78
38	79
38	99
38	106
38	107
38	138
38	149
38	151
39	1
39	8
39	28
39	80
39	125
39	148
39	157
40	9
40	10
40	64
40	73
40	77
40	79
40	97
40	100
40	105
40	143
40	149
40	151
40	152
40	153
40	158
40	224
41	2
41	7
41	68
41	72
41	77
41	78
41	79
41	102
41	106
41	121
41	156
41	158
42	1
42	10
42	79
42	101
42	121
42	128
42	129
42	152
42	159
42	179
42	239
43	1
43	9
43	11
43	12
43	13
43	14
43	142
43	179
44	20
44	21
44	25
44	102
44	161
45	17
45	68
45	70
45	71
45	78
45	97
45	112
45	139
45	140
45	149
45	159
45	262
45	294
46	1
46	11
46	12
46	177
46	202
47	125
47	159
47	320
47	321
47	322
48	15
48	68
48	71
48	77
48	79
48	97
48	106
48	109
48	157
49	10
49	15
49	20
49	21
49	67
49	68
49	71
49	72
49	77
49	78
49	106
49	157
49	158
49	166
50	15
50	64
50	73
50	76
50	78
51	1
51	2
51	8
51	64
51	86
51	99
51	105
51	110
51	113
51	135
51	146
51	153
51	158
51	162
51	315
52	1
52	12
52	13
52	139
52	210
53	2
53	11
53	15
53	64
53	68
53	71
53	75
53	77
53	78
53	97
53	109
53	139
53	149
54	9
54	10
54	13
54	68
54	69
54	70
54	71
54	75
54	77
54	97
54	139
54	149
54	210
54	228
54	287
55	7
55	68
55	73
55	75
55	97
55	106
55	120
56	7
56	68
56	79
56	97
56	105
56	240
57	72
57	90
57	91
57	161
58	9
58	14
58	20
58	67
58	77
58	79
58	106
58	138
58	139
58	161
58	287
59	11
59	14
59	15
59	68
59	71
59	72
59	79
59	97
59	106
60	2
60	10
60	83
60	158
61	2
61	177
62	2
62	81
62	83
62	88
62	113
62	205
63	4
63	73
63	74
63	125
64	17
64	110
64	2
64	104
64	127
1	29
7	29
6	29
42	29
\.


--
-- Data for Name: utilisateur; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.utilisateur (id_user, nom, email, mot_de_passe, pays, niveau_etude, id_serie, date_creation) FROM stdin;
20	Ramata Thimbo	ramata.thimbo@emia-sn.com	$2y$10$ibvthdxop.lXCRix23L/E.zkFGkFs0PbYIqDGpE8p7WDF99wdihIO	Sénégal	Master 2	1	2026-09-02 14:18:58
24	Laurent Denbin MASSOYA	laurentmassoya3@gmail.com	$2b$10$xHthBbyLzIAPwf51hqN3QukhqBHdcYmZoxWyE.DwG.XmA99v6Bf6a	Sénégal	Licence 2	1	2026-09-12 11:42:32.802
25	Mbayang Tall	tallmbayang556@gmail.com	$2b$10$bihIdyFNp/mrjkdzoZUNhuKci5adnjUslV0eQaagzy4OcPTSUkODC	Sénégal	Licence 2	1	2026-09-12 11:53:32.204
26	Ndeye Awa NIANE	nianendeyeawa56@gmail.com	$2b$10$zrlXcU8NtsXjGK9wj20jaOw4DKLL8EIPHPRu4WuRkgVGmKZ9rWEnK	Sénégal	Licence 2	1	2026-09-12 11:54:11.435
27	Moussa NDIAYE	ndiayendeyecodou8@gmail.com	$2b$10$lyGrnerQhZicDWH7l.cxEu.ZabdtKxvIhQNDlBb.a7b2mlXyh3zUC	Sénégal	Baccalauréat	2	2026-09-12 14:50:41.119
28	Amina	syamina931@gmail.com	$2b$10$2CM.JegWVxJO/MfJU8RsZ.zte/LqcWgfmsY0efCi1qI58GKJOMdry	Sénégal	Licence 1	1	2026-09-12 19:13:44.707
29	Sokhna Bacar DIAGNE	sokhnabacar03@gmail.com	$2b$10$/2gp/7ULsxID.Su3sQIUie0GRXOKUsJfkNPCEDniJl.6MRVa12zau	Sénégal	Licence 3	1	2026-09-12 19:17:31.285
30	Tidiane Niang	niangtidiane671@gmail.com	$2b$10$mFSQ.H1uZAgplCCtR/czqOgDs68pnvvtwdXv9qOB3CaD8PBkH/naa	Sénégal	Baccalauréat	2	2026-09-12 20:49:33.465
31	Sinira Mendy	siniramendy2006@gmail.com	$2b$10$fFhVhn.QTpVFUDfS7roHqeHo95biIlji0R5owsw668YFzO.YcQQjO	Sénégal	Seconde	2	2026-09-12 20:58:57.471
32	Boubacar Diagne	boubacardiagne204@gmail.com	$2b$10$WDU36wJ4kfYfU.h2IGBm.ujeJlXLKWNzen5RXeka8c8JRC2z4SZr.	Sénégal	Licence 1	3	2026-09-12 21:13:55.379
33	Ndeye Sophie ndiaye	sophiendeye59@gmail.com	$2b$10$4w6qsTdfn82iLwW54mHTQO7c8Lq7x4Y0ngf2IpmTc9akM0sJiQaRC	Sénégal	Baccalauréat	2	2026-09-12 21:17:06.409
34	Astou Ba	amadou092nd@gmail.com	$2b$10$j/PohV8rfB/kVOBP8brZPOz1qGzGj7SecpGGKJVlnYNdL5Vf531gS	Sénégal	Licence 3	1	2026-09-12 21:24:15.687
35	Ibrahima Mbodj	ibuuuu19@icloud.com	$2b$10$Il2dTIuDH5CcyS0QsqjeRu.cmmZF35JtBsvObW7ZtOC/imfpNYRFy	Sénégal	Licence 3	1	2026-09-12 23:24:27.915
36	Sadatou Cissé	sadatoucisse03@gmail.com	$2b$10$tFTq2qn2CPcWi.FyTDeD9eZw3.GZ7GSPM39px1Oe7kpFacQpSIo7C	Sénégal	Licence 2	3	2026-09-13 11:02:50.385
37	Babacar faye	babacarfayeuh@gmail.com	$2b$10$qdDUTb4So79pejo9q9DnhOnD.sI/xhVC9.YxzO7hYdnaGUEaulrOy	Sénégal	Licence 3	4	2026-09-13 11:27:36.47
38	Diarra Ndiaye	diarristandiaye28@gmail.com	$2b$10$bBfNQU4d276qSM85WfPZTOWE4MNVnv5LCK0QRVhFtammrgbqU9tvC	Sénégal	Seconde	2	2026-09-13 12:53:17.355
39	Dieynaba Gallo	dieynabagallo06@gmail.com	$2b$10$m7mJw6j5vkaD3iE/KBaP8euXSspk.1M895mmMPLazvw/4/I9YEpGG	Sénégal	Licence 3	3	2026-09-13 13:32:45.74
40	Alioune Kandji	aliounekandjiu22@gmail.com	$2b$10$IiGDryTZZlwm/JGFN.6dHOedtJf8ExKcbyJfJSZ2jgNV0P7YWy4Mi	Sénégal	Licence 2	1	2026-09-13 21:07:20.964
41	Dibor	khadythimbo1@icloud.com	$2b$10$hL06zR2tj46QXWd3YXXwkeVQo8ZLra3DFC.CyGiMRjhxrrl7O/vSm	Sénégal	Baccalauréat	2	2026-09-14 11:47:05.998
42	KA Aïssatou	aissatouka546@gmail.com	$2b$10$Vmc8BWHoQX/fdyYaNCA/Ou2/.30Q/16ElKo6aIJ5gfDCH9P.AAx56	Sénégal	Master 1	1	2026-09-14 18:13:43.995
43	Khadidiatou DIAW	diaw.khadidiatou@uam.edu.sn	$2b$10$fywVQzfrCeAmku5k7O6kwexzrdSQwFXr5W18Ce8Qxoifs/EaPCB8G	Sénégal	Licence 1	1	2026-09-14 18:14:23.24
44	Fatoumata bintou seye	bintou.seye@icloud.com	$2b$10$OSikusY5jfaY0/c8YyElDuym3CzNzcLEoh25qRlCPMpk1Ch6Va4.W	Sénégal	Licence 1	5	2026-09-14 23:00:19.552
45	Mouhameddiakite	naby78249@glzil.com	$2b$10$j5ky3s2ZI29C1TL7.J3Z0eah6BN59u1E3onBXMEg/LxFgVUMZyPDG	Sénégal	Baccalauréat	4	2026-09-15 01:10:02.588
46	Abdourahmane Gaye	gayelavoctoire@gmail.com	$2b$10$8S9oPkX6d.aJKD7UKYkdwONGwnBfzLIKzKYpy30pqUttF9ljvDE5q	Sénégal	Licence 2	5	2026-09-15 20:44:55.455
47	papa ismaila kama	kamapapaismaila@gmail.com	$2b$10$BdzSZobESMK1rmQxPDvkIuLE01K5ixo1AfsjobWXywZ5oO75HBFnC	Sénégal	Licence 2	2	2026-09-15 21:25:13.925
48	Barthelemy mendy	mendybarth520@gmail.com	$2b$10$48FvOorYDt3uptdQB/Sp/eAp2be3pjD8gaFRVcXlJL2xAzY877RiC	Sénégal	Seconde	2	2026-09-16 18:57:52.649
49	Gérèmie TENDENG	tendenggeremie@gmail.com	$2b$10$n9rmnlAE8vRInW/sz2EmMeiRvIJh.MN8FjFhdSx29J9hp..VqJ7w2	Sénégal	Baccalauréat	1	2026-09-16 20:04:07.137
50	Amadou daff	amadoudaff0409@gmail.com	$2b$10$6sdAJqy6JEn0DV2mvrpy/eOCg5JIaFK0er3sOkBjhRCzNvQAUpLUC	Sénégal	Licence 1	1	2026-09-22 22:07:51.497
51	Théo thiaw	t4859689@gmail.com	$2b$10$M6mfN4D80VUkElbqJ9Kqhu/JOZU3CRL1jGplyySvphtGDnEHTe6Pa	Sénégal	Baccalauréat	1	2026-09-23 19:31:39.206
52	Oumy Faye	oumyf6668@gmail.com	$2b$10$Rmj/fMjaffAvy9hY9lP0EujPzbRQMz8qvwygxdFCi5mn1fsBUDIDK	Sénégal	Baccalauréat	1	2026-09-23 19:36:03.803
53	Mame Bousso Baly Gueye	jarragueye.02@gmail.com	$2b$10$eQ1pDQ/it2b07ELKs.5iH.GtCw5JKIfyvhuJtx8L1NjCR9d2MhrKy	Sénégal	Baccalauréat	2	2026-09-23 20:09:10.538
54	Koly ba	lyfabdking@gmail.com	$2b$10$p0QimMXunOXChBrWH6yJKe1QE/f6QXBRP6Qm6WHifVEoiFBmXsTEC	Sénégal	Baccalauréat	3	2026-09-23 20:23:19.789
55	Saer sarr	saersarr006@gmail.com	$2b$10$WLU9fSxOCIOMsNxr3iW5W.jM6pFPF/ELCaBhz/LOU.Nf.AbfM8pi6	Sénégal	Baccalauréat	1	2026-09-23 21:07:22.62
56	Mbaye sene	mbayesene010@iclooudd.com	$2b$10$ZjcR.HGEtRVQFV7oSsHlDOef3lCRSmJMdFR56pS67oDpO383Pv0uK	Sénégal	Baccalauréat	1	2026-09-23 21:12:56.838
57	Mouhamed Diop	mouhadiopmomo32@gmail.com	$2b$10$0NIhBp.5IMiArVkriYBWsuNrmJZCHX5HEVrQvDZ0Gx/AkJA6vyySi	Sénégal	Baccalauréat	1	2026-09-23 21:33:36.915
58	Maodo gueye	111maodo@gmail.com	$2b$10$1pHfO4gF0MQVvWFk3LLXAOdGUfiGov4FQx8d2eEMOKrPGVKgB2h8K	Sénégal	Baccalauréat	2	2026-09-23 21:57:05.808
59	Sory Ndiaye	ndiaysory14@gmail.com	$2b$10$O3FTl/06ocBzGI48AfFks.iRByZbpgr9B1HXZneGfZX0rXwDN2ZQ2	Sénégal	Baccalauréat	1	2026-09-23 22:42:30.466
60	Pape Youssoupha Traoré	papeyoussouphatttt@gmail.com	$2b$10$1bbebiN1Jmyuffu/5/eLyurTC1S6jLnGAGbX37.wQMDhLLsMt2cju	Sénégal	Baccalauréat	1	2026-09-23 22:57:22.338
61	Aissatou	aissatou@gmail.com	$2b$10$k3mdtlGI6bT2EJHnyr1e1uo9B7by7t2EYLowZNkeJNB2yzPur05/.	Sénégal	Licence 2	1	2026-09-24 11:08:55.938
62	Bayelatt Mbacke	bayelattmbacke02@gmail.com	$2b$10$staCdgsOt4dxqesXFI7RuujFabXwhZOTPiFOUC2CiHWeGsoNE2oVC	Sénégal	Baccalauréat	2	2026-09-24 22:13:15.293
63	Moustapha Diakhate	taphadiakhate716@gmail.com	$2b$10$VfkypVLjjsoRP5LMD.6FaOZN/aAW0nZ9.lbXPqDPRnqDSgLGmerxy	Sénégal	Baccalauréat	2	2026-09-24 23:14:11.516
64	Massamba Diouf	dioufmassamba221@gmail.com	$2b$10$wzSSNhlOQHqclmY95sBODeG43nD8upmy4Jkn0f9iRdwniwhOBeXpa	Sénégal	Baccalauréat	1	2026-09-25 01:13:01.311
65	Imam Deme	imamdeme60@gmail.com	$2b$10$OhmpWy.fvBZsM6KZFWbT.eJ0TLnNpv0jhT9OTJu5cknmzZU0k/3je	Sénégal	Baccalauréat	1	2026-09-25 13:24:08.464
66	Marietou Badji	bmarietou048@gmail.com	$2b$10$bBk1aFHAn9hoR8KrqiOa7.7u3kaKnE4NwsGOu.3jaUwwQx.tGK2OK	Sénégal	Baccalauréat	2	2026-09-25 13:38:29.727
67	Chiekh	csene1229@gmail.com	$2b$10$3AHLrxcz1aG4NDH222eQAOb9kH.zjJ5waUSnksuLC/tAVL6FQA0sW	Sénégal	Baccalauréat	3	2026-09-25 18:52:29.046
68	Rawane Sene	rawzerpms17@gmail.com	$2b$10$7w3oynwy2CSLphF9ZaxO2ui6ME/1dIA8y3n.B96haw51CNGys7qNq	Sénégal	Baccalauréat	2	2026-09-25 22:29:19.222
69	Diop bb	diopd45678@gmail.com	$2b$10$S6L7wmXuvYt3dZEQkIGHJuA/zlQip.qT5sv8xC1XtJzmpHp09gfTi	Sénégal	Baccalauréat	2	2026-09-26 12:18:29.193
70	Kane	seynaboukane0607@gmail.com	$2b$10$Fj254PfgH61Bm4twOcqh4eQQGTk/i4QFVGHPsXD80mRxxFupGgRWS	Sénégal	Baccalauréat	1	2026-09-27 01:30:13.847
71	Ayikson Kossi Winner David Ayité	divadnoskiya@gmail.com	$2b$10$jluGiNtcDZynB0fss/6eg.EfywM9e6AwPSqWSepTsTCWTo9mF4VmW	Sénégal	Baccalauréat	1	2026-09-27 20:30:49.875
72	Adja Rokhaya Diallo	rokhaya_adja123@icloud.com	$2b$10$pkCThS8xd1MZEujOVFTGtO5I2uJlexzxva6TMmNCJEKm/xAlu.X4u	Sénégal	Baccalauréat	2	2026-09-27 21:04:59.553
73	Mamadou Lamine DIATTA	mldiattaa2006@gmail.com	$2b$10$PeqkJ98HirBjxyej/wRv1eiHpL9v9oN6oJIhPicwLhbGvJE2uYToq	Sénégal	Baccalauréat	1	2026-09-28 01:03:18.87
74	DENISE MENDY	nizamendes23@gmail.com	$2b$10$Dc/VfVkp90wZKc.jRkwRxeUVxaEPIpFAdJrnGmfn.4F53r4KRX.y.	Sénégal	Baccalauréat	2	2026-09-28 13:05:31.603
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2026-09-11 14:29:51
20211116045059	2026-09-11 14:29:51
20211116050929	2026-09-11 14:29:51
20211116051442	2026-09-11 14:29:51
20211116212300	2026-09-11 14:29:51
20211116213355	2026-09-11 14:29:51
20211116213934	2026-09-11 14:29:51
20211116214523	2026-09-11 14:29:51
20211122062447	2026-09-11 14:29:51
20211124070109	2026-09-11 14:29:51
20211202204204	2026-09-11 14:29:51
20211202204605	2026-09-11 14:29:51
20211210212804	2026-09-11 14:29:51
20211228014915	2026-09-11 14:29:51
20220107221237	2026-09-11 14:29:51
20220228202821	2026-09-11 14:29:51
20220312004840	2026-09-11 14:29:51
20220603231003	2026-09-11 14:29:51
20220603232444	2026-09-11 14:29:51
20220615214548	2026-09-11 14:29:51
20220712093339	2026-09-11 14:29:51
20220908172859	2026-09-11 14:29:51
20220916233421	2026-09-11 14:29:51
20230119133233	2026-09-11 14:29:51
20230128025114	2026-09-11 14:29:51
20230128025212	2026-09-11 14:29:51
20230227211149	2026-09-11 14:29:51
20230228184745	2026-09-11 14:29:51
20230308225145	2026-09-11 14:29:51
20230328144023	2026-09-11 14:29:51
20231018144023	2026-09-11 14:29:51
20231204144023	2026-09-11 14:29:51
20231204144024	2026-09-11 14:29:51
20231204144025	2026-09-11 14:29:51
20240108234812	2026-09-11 14:29:51
20240109165339	2026-09-11 14:29:51
20240227174441	2026-09-11 14:29:51
20240311171622	2026-09-11 14:29:51
20240321100241	2026-09-11 14:29:51
20240401105812	2026-09-11 14:29:51
20240418121054	2026-09-11 14:29:51
20240523004032	2026-09-11 14:29:51
20240618124746	2026-09-11 14:29:51
20240801235015	2026-09-11 14:29:51
20240805133720	2026-09-11 14:29:51
20240827160934	2026-09-11 14:29:51
20240919163303	2026-09-11 14:29:51
20240919163305	2026-09-11 14:29:51
20241019105805	2026-09-11 14:29:51
20241030150047	2026-09-11 14:29:51
20241108114728	2026-09-11 14:29:51
20241121104152	2026-09-11 14:29:51
20241130184212	2026-09-11 14:29:51
20241220035512	2026-09-11 14:29:51
20241220123912	2026-09-11 14:29:51
20241224161212	2026-09-11 14:29:51
20250107150512	2026-09-11 14:29:51
20250110162412	2026-09-11 14:29:51
20250123174212	2026-09-11 14:29:51
20250128220012	2026-09-11 14:29:51
20250506224012	2026-09-11 14:29:51
20250523164012	2026-09-11 14:29:51
20250714121412	2026-09-11 14:29:51
20250905041441	2026-09-11 14:29:51
20251103001201	2026-09-11 14:29:51
20251120212548	2026-09-11 14:29:51
20251120215549	2026-09-11 14:29:51
20260218120000	2026-09-11 14:29:51
20260326120000	2026-09-11 14:29:51
20260514120000	2026-09-11 14:29:51
20260527120000	2026-09-11 14:29:51
20260528120000	2026-09-11 14:29:51
20260603120000	2026-09-11 14:29:51
20260605120000	2026-09-11 14:29:51
20260606110000	2026-09-11 14:29:51
20260616120000	2026-09-11 14:29:51
20260624120000	2026-09-11 14:29:51
20260626120000	2026-09-11 14:29:51
20260706120000	2026-09-11 14:29:51
20260707120000	2026-09-11 14:29:51
20260709120000	2026-09-11 14:29:51
20260714120000	2026-09-11 14:29:51
20260827120000	2026-09-17 10:27:10
20260914120000	2026-09-23 13:23:30
20260916120000	2026-09-23 13:23:30
20260922120000	2026-09-24 13:26:58
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at, action_filter, selected_columns) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type, versioning_status, lifecycle_configuration, lifecycle_configuration_generation) FROM stdin;
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2026-09-11 14:29:54.770017
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2026-09-11 14:29:54.791226
2	storage-schema	f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd	2026-09-11 14:29:54.794577
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2026-09-11 14:29:54.811307
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2026-09-11 14:29:54.825952
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2026-09-11 14:29:54.829824
6	change-column-name-in-get-size	ded78e2f1b5d7e616117897e6443a925965b30d2	2026-09-11 14:29:54.834508
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2026-09-11 14:29:54.83867
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2026-09-11 14:29:54.842875
9	fix-search-function	af597a1b590c70519b464a4ab3be54490712796b	2026-09-11 14:29:54.847145
10	search-files-search-function	b595f05e92f7e91211af1bbfe9c6a13bb3391e16	2026-09-11 14:29:54.850696
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2026-09-11 14:29:54.855086
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2026-09-11 14:29:54.859072
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2026-09-11 14:29:54.862511
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2026-09-11 14:29:54.866268
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2026-09-11 14:29:54.894668
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2026-09-11 14:29:54.89834
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2026-09-11 14:29:54.901853
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2026-09-11 14:29:54.905151
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2026-09-11 14:29:54.909732
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2026-09-11 14:29:54.91299
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2026-09-11 14:29:54.917801
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2026-09-11 14:29:54.9274
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2026-09-11 14:29:54.935939
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2026-09-11 14:29:54.939531
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2026-09-11 14:29:54.94282
26	objects-prefixes	215cabcb7f78121892a5a2037a09fedf9a1ae322	2026-09-11 14:29:54.946331
27	search-v2	859ba38092ac96eb3964d83bf53ccc0b141663a6	2026-09-11 14:29:54.949275
28	object-bucket-name-sorting	c73a2b5b5d4041e39705814fd3a1b95502d38ce4	2026-09-11 14:29:54.952215
29	create-prefixes	ad2c1207f76703d11a9f9007f821620017a66c21	2026-09-11 14:29:54.955191
30	update-object-levels	2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6	2026-09-11 14:29:54.958163
31	objects-level-index	b40367c14c3440ec75f19bbce2d71e914ddd3da0	2026-09-11 14:29:54.961065
32	backward-compatible-index-on-objects	e0c37182b0f7aee3efd823298fb3c76f1042c0f7	2026-09-11 14:29:54.964384
33	backward-compatible-index-on-prefixes	b480e99ed951e0900f033ec4eb34b5bdcb4e3d49	2026-09-11 14:29:54.967349
34	optimize-search-function-v1	ca80a3dc7bfef894df17108785ce29a7fc8ee456	2026-09-11 14:29:54.970352
35	add-insert-trigger-prefixes	458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc	2026-09-11 14:29:54.973294
36	optimise-existing-functions	6ae5fca6af5c55abe95369cd4f93985d1814ca8f	2026-09-11 14:29:54.976296
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2026-09-11 14:29:54.979296
38	iceberg-catalog-flag-on-buckets	02716b81ceec9705aed84aa1501657095b32e5c5	2026-09-11 14:29:54.983323
39	add-search-v2-sort-support	6706c5f2928846abee18461279799ad12b279b78	2026-09-11 14:29:54.989966
40	fix-prefix-race-conditions-optimized	7ad69982ae2d372b21f48fc4829ae9752c518f6b	2026-09-11 14:29:54.993085
41	add-object-level-update-trigger	07fcf1a22165849b7a029deed059ffcde08d1ae0	2026-09-11 14:29:54.99608
42	rollback-prefix-triggers	771479077764adc09e2ea2043eb627503c034cd4	2026-09-11 14:29:54.999135
43	fix-object-level	84b35d6caca9d937478ad8a797491f38b8c2979f	2026-09-11 14:29:55.002122
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2026-09-11 14:29:55.00513
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2026-09-11 14:29:55.00889
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2026-09-11 14:29:55.016838
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2026-09-11 14:29:55.020698
48	iceberg-catalog-ids	e0e8b460c609b9999ccd0df9ad14294613eed939	2026-09-11 14:29:55.023999
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2026-09-11 14:29:55.038942
50	search-v2-optimised	6323ac4f850aa14e7387eb32102869578b5bd478	2026-09-11 14:29:55.042773
51	index-backward-compatible-search	2ee395d433f76e38bcd3856debaf6e0e5b674011	2026-09-11 14:29:55.307582
52	drop-not-used-indexes-and-functions	5cc44c8696749ac11dd0dc37f2a3802075f3a171	2026-09-11 14:29:55.308884
53	drop-index-lower-name	d0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854	2026-09-11 14:29:55.316899
54	drop-index-object-level	6289e048b1472da17c31a7eba1ded625a6457e67	2026-09-11 14:29:55.318989
55	prevent-direct-deletes	262a4798d5e0f2e7c8970232e03ce8be695d5819	2026-09-11 14:29:55.320284
56	fix-optimized-search-function	b823ed1e418101032fa01374edc9a436e54e3ed4	2026-09-11 14:29:55.324188
57	s3-multipart-uploads-metadata	f127886e00d1b374fadbc7c6b31e09336aad5287	2026-09-11 14:29:55.328625
58	operation-ergonomics	00ca5d483b3fe0d522133d9002ccc5df98365120	2026-09-11 14:29:55.33178
59	drop-unused-functions	38456f13e39691c2bbb4b5151d0d1cdbabd4a8c4	2026-09-11 14:29:55.335642
60	optimize-existing-functions-again	db35e1c91a9201e59f4fef8d972c2f277d68b157	2026-09-11 14:29:55.339158
61	mark-filename-immutable	fe0096517ae9d60aaec1d110172ba9036dc66bb7	2026-09-11 14:29:55.342976
62	object-versioning-core	0b855f00ff3be0bfca91efee02a9858912491a9a	2026-09-11 14:29:55.346223
63	fix-search-name-relative-to-prefix	c7485e417624f795ce8bb2da21927f48e088904d	2026-09-11 14:29:55.351787
64	fix-search-by-timestamp-sqli	0af424ecd388a39bb1645184b222185a12149675	2026-09-11 14:29:55.356308
66	objects-current-version-index	191466c93aa2c46a00e36505577c5fcab8d7cb4b	2026-09-11 14:29:55.371318
67	objects-null-version-index	15bfe8c35b66642b6c78ba60060fa8793bd2207a	2026-09-11 14:29:55.377416
65	objects-key-version-index	da319c4b89ba800ce795d1b699f3a70675138058	2026-09-11 14:29:55.364345
68	bucket-lifecycle-configuration	3c08f6f889922f399519722a932b51007c11bebc	2026-09-23 13:23:35.473426
69	validate-bucket-lifecycle-constraints	4febacaaaa0e61e2b783bef081fe03a287e65eb3	2026-09-23 13:23:35.502023
70	list-objects-with-versions	5c17c3777616cd8d7b18b82835525fa3205af57b	2026-09-23 13:23:35.506823
71	objects-delete-marker-index	6d14858e66c66f8d6accf8a2630aefd1527fddba	2026-09-23 13:23:35.540426
72	drop-bucketid-objname-index	302beb09e1b469d7d4db19566f2389d280b64aa3	2026-09-23 13:23:35.548174
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, archived_at, is_delete_marker, is_versioned) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata, metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: attente_fonctionnalite_id_attente_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attente_fonctionnalite_id_attente_seq', 11, true);


--
-- Name: avis_id_avis_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.avis_id_avis_seq', 15, true);


--
-- Name: badge_id_badge_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.badge_id_badge_seq', 10, true);


--
-- Name: badge_utilisateur_id_badge_utilisateur_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.badge_utilisateur_id_badge_utilisateur_seq', 256, true);


--
-- Name: connexion_utilisateur_id_connexion_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.connexion_utilisateur_id_connexion_seq', 374, true);


--
-- Name: favori_id_favori_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.favori_id_favori_seq', 1, true);


--
-- Name: filiere_critere_id_filiere_critere_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.filiere_critere_id_filiere_critere_seq', 3705, true);


--
-- Name: filiere_id_filiere_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.filiere_id_filiere_seq', 322, true);


--
-- Name: hesitation_critere_id_critere_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hesitation_critere_id_critere_seq', 13, true);


--
-- Name: hesitation_option_id_hesitation_option_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hesitation_option_id_hesitation_option_seq', 1, true);


--
-- Name: hesitation_question_id_question_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hesitation_question_id_question_seq', 5, true);


--
-- Name: hesitation_reponse_id_reponse_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hesitation_reponse_id_reponse_seq', 25, true);


--
-- Name: hesitation_reponse_utilisateur_id_reponse_utilisateur_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hesitation_reponse_utilisateur_id_reponse_utilisateur_seq', 1, true);


--
-- Name: hesitation_test_id_hesitation_test_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hesitation_test_id_hesitation_test_seq', 1, true);


--
-- Name: historique_id_historique_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.historique_id_historique_seq', 913, true);


--
-- Name: metier_critere_id_metier_critere_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.metier_critere_id_metier_critere_seq', 2080, true);


--
-- Name: metier_id_metier_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.metier_id_metier_seq', 175, true);


--
-- Name: proposition_id_proposition_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.proposition_id_proposition_seq', 120, true);


--
-- Name: question_id_question_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.question_id_question_seq', 20, true);


--
-- Name: questionnaire_id_questionnaire_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.questionnaire_id_questionnaire_seq', 1, true);


--
-- Name: recommandation_id_recommandation_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recommandation_id_recommandation_seq', 1, true);


--
-- Name: reponse_id_reponse_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reponse_id_reponse_seq', 1601, true);


--
-- Name: serie_id_serie_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.serie_id_serie_seq', 5, true);


--
-- Name: test_riasec_id_test_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.test_riasec_id_test_seq', 89, true);


--
-- Name: universite_detail_id_detail_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.universite_detail_id_detail_seq', 64, true);


--
-- Name: universite_id_universite_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.universite_id_universite_seq', 64, true);


--
-- Name: utilisateur_id_user_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.utilisateur_id_user_seq', 74, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_mfa_factor_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_mfa_factor_id_key UNIQUE (mfa_factor_id);


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_pkey PRIMARY KEY (id);


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_user_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_user_id_key UNIQUE (user_id);


--
-- Name: mfa_recovery_codes mfa_recovery_codes_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_codes
    ADD CONSTRAINT mfa_recovery_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: scim_tokens scim_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_tokens
    ADD CONSTRAINT scim_tokens_pkey PRIMARY KEY (id);


--
-- Name: scim_users scim_users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_users
    ADD CONSTRAINT scim_users_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webauthn_challenges webauthn_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: attente_fonctionnalite attente_fonctionnalite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attente_fonctionnalite
    ADD CONSTRAINT attente_fonctionnalite_pkey PRIMARY KEY (id_attente);


--
-- Name: avis avis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avis
    ADD CONSTRAINT avis_pkey PRIMARY KEY (id_avis);


--
-- Name: badge badge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badge
    ADD CONSTRAINT badge_pkey PRIMARY KEY (id_badge);


--
-- Name: badge_utilisateur badge_utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badge_utilisateur
    ADD CONSTRAINT badge_utilisateur_pkey PRIMARY KEY (id_badge_utilisateur);


--
-- Name: connexion_utilisateur connexion_utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connexion_utilisateur
    ADD CONSTRAINT connexion_utilisateur_pkey PRIMARY KEY (id_connexion);


--
-- Name: favori favori_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favori
    ADD CONSTRAINT favori_pkey PRIMARY KEY (id_favori);


--
-- Name: filiere_critere filiere_critere_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiere_critere
    ADD CONSTRAINT filiere_critere_pkey PRIMARY KEY (id_filiere_critere);


--
-- Name: filiere filiere_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiere
    ADD CONSTRAINT filiere_pkey PRIMARY KEY (id_filiere);


--
-- Name: hesitation_critere hesitation_critere_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_critere
    ADD CONSTRAINT hesitation_critere_pkey PRIMARY KEY (id_critere);


--
-- Name: hesitation_option hesitation_option_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_option
    ADD CONSTRAINT hesitation_option_pkey PRIMARY KEY (id_hesitation_option);


--
-- Name: hesitation_question hesitation_question_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_question
    ADD CONSTRAINT hesitation_question_pkey PRIMARY KEY (id_question);


--
-- Name: hesitation_reponse hesitation_reponse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_reponse
    ADD CONSTRAINT hesitation_reponse_pkey PRIMARY KEY (id_reponse);


--
-- Name: hesitation_reponse_utilisateur hesitation_reponse_utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_reponse_utilisateur
    ADD CONSTRAINT hesitation_reponse_utilisateur_pkey PRIMARY KEY (id_reponse_utilisateur);


--
-- Name: hesitation_test hesitation_test_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_test
    ADD CONSTRAINT hesitation_test_pkey PRIMARY KEY (id_hesitation_test);


--
-- Name: historique historique_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT historique_pkey PRIMARY KEY (id_historique);


--
-- Name: metier_critere metier_critere_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier_critere
    ADD CONSTRAINT metier_critere_pkey PRIMARY KEY (id_metier_critere);


--
-- Name: metier_filiere metier_filiere_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier_filiere
    ADD CONSTRAINT metier_filiere_pkey PRIMARY KEY (id_metier, id_filiere);


--
-- Name: metier metier_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier
    ADD CONSTRAINT metier_pkey PRIMARY KEY (id_metier);


--
-- Name: metier_serie metier_serie_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier_serie
    ADD CONSTRAINT metier_serie_pkey PRIMARY KEY (id_metier, id_serie);


--
-- Name: profil_riasec profil_riasec_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profil_riasec
    ADD CONSTRAINT profil_riasec_pkey PRIMARY KEY (code);


--
-- Name: proposition proposition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposition
    ADD CONSTRAINT proposition_pkey PRIMARY KEY (id_proposition);


--
-- Name: question question_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question
    ADD CONSTRAINT question_pkey PRIMARY KEY (id_question);


--
-- Name: questionnaire questionnaire_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questionnaire
    ADD CONSTRAINT questionnaire_pkey PRIMARY KEY (id_questionnaire);


--
-- Name: recommandation recommandation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommandation
    ADD CONSTRAINT recommandation_pkey PRIMARY KEY (id_recommandation);


--
-- Name: reponse reponse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reponse
    ADD CONSTRAINT reponse_pkey PRIMARY KEY (id_reponse);


--
-- Name: serie serie_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serie
    ADD CONSTRAINT serie_pkey PRIMARY KEY (id_serie);


--
-- Name: test_riasec test_riasec_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_riasec
    ADD CONSTRAINT test_riasec_pkey PRIMARY KEY (id_test);


--
-- Name: universite_detail universite_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universite_detail
    ADD CONSTRAINT universite_detail_pkey PRIMARY KEY (id_detail);


--
-- Name: universite_filiere universite_filiere_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universite_filiere
    ADD CONSTRAINT universite_filiere_pkey PRIMARY KEY (id_universite, id_filiere);


--
-- Name: universite universite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universite
    ADD CONSTRAINT universite_pkey PRIMARY KEY (id_universite);


--
-- Name: utilisateur utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_pkey PRIMARY KEY (id_user);


--
-- Name: messages messages_payload_exclusive; Type: CHECK CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages
    ADD CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL))) NOT VALID;


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: idx_users_created_at_desc; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_created_at_desc ON auth.users USING btree (created_at DESC);


--
-- Name: idx_users_email; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_email ON auth.users USING btree (email);


--
-- Name: idx_users_last_sign_in_at_desc; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_last_sign_in_at_desc ON auth.users USING btree (last_sign_in_at DESC);


--
-- Name: idx_users_name; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_name ON auth.users USING btree (((raw_user_meta_data ->> 'name'::text))) WHERE ((raw_user_meta_data ->> 'name'::text) IS NOT NULL);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: mfa_recovery_codes_set_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_recovery_codes_set_id_idx ON auth.mfa_recovery_codes USING btree (mfa_recovery_code_set_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: scim_tokens_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_tokens_expires_at_idx ON auth.scim_tokens USING btree (expires_at);


--
-- Name: scim_tokens_revoked_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_tokens_revoked_at_idx ON auth.scim_tokens USING btree (revoked_at);


--
-- Name: scim_tokens_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_tokens_sso_provider_id_idx ON auth.scim_tokens USING btree (sso_provider_id);


--
-- Name: scim_tokens_token_hash_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX scim_tokens_token_hash_key ON auth.scim_tokens USING btree (token_hash);


--
-- Name: scim_users_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_created_at_idx ON auth.scim_users USING btree (sso_provider_id, created_at, id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_deleted_at_idx ON auth.scim_users USING btree (deleted_at);


--
-- Name: scim_users_external_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX scim_users_external_id_key ON auth.scim_users USING btree (sso_provider_id, external_id) WHERE ((external_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: scim_users_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_id_idx ON auth.scim_users USING btree (sso_provider_id, id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_sso_provider_id_idx ON auth.scim_users USING btree (sso_provider_id);


--
-- Name: scim_users_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_updated_at_idx ON auth.scim_users USING btree (sso_provider_id, updated_at, id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_user_id_idx ON auth.scim_users USING btree (user_id);


--
-- Name: scim_users_user_name_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_user_name_idx ON auth.scim_users USING btree (sso_provider_id, user_name COLLATE "C", id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_user_name_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX scim_users_user_name_key ON auth.scim_users USING btree (sso_provider_id, user_name) WHERE (deleted_at IS NULL);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: webauthn_challenges_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);


--
-- Name: webauthn_challenges_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);


--
-- Name: webauthn_credentials_credential_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);


--
-- Name: webauthn_credentials_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);


--
-- Name: idx_attente_fonctionnalite_unique_attente_fonctionnalite; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_attente_fonctionnalite_unique_attente_fonctionnalite ON public.attente_fonctionnalite USING btree (id_user, fonctionnalite);


--
-- Name: idx_badge_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_badge_code ON public.badge USING btree (code);


--
-- Name: idx_badge_utilisateur_fk_badge_utilisateur_badge; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_badge_utilisateur_fk_badge_utilisateur_badge ON public.badge_utilisateur USING btree (id_badge);


--
-- Name: idx_badge_utilisateur_uq_badge_utilisateur; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_badge_utilisateur_uq_badge_utilisateur ON public.badge_utilisateur USING btree (id_user, id_badge);


--
-- Name: idx_connexion_utilisateur_uq_connexion_utilisateur; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_connexion_utilisateur_uq_connexion_utilisateur ON public.connexion_utilisateur USING btree (id_user, date_connexion);


--
-- Name: idx_favori_fk_favori_metier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_favori_fk_favori_metier ON public.favori USING btree (id_metier);


--
-- Name: idx_favori_uk_favori; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_favori_uk_favori ON public.favori USING btree (id_user, id_metier);


--
-- Name: idx_filiere_critere_fk_filiere_critere_critere; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_filiere_critere_fk_filiere_critere_critere ON public.filiere_critere USING btree (id_critere);


--
-- Name: idx_filiere_critere_uk_filiere_critere; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_filiere_critere_uk_filiere_critere ON public.filiere_critere USING btree (id_filiere, id_critere);


--
-- Name: idx_filiere_nom; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_filiere_nom ON public.filiere USING btree (nom);


--
-- Name: idx_hesitation_critere_uk_hesitation_critere_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_hesitation_critere_uk_hesitation_critere_code ON public.hesitation_critere USING btree (code);


--
-- Name: idx_hesitation_option_fk_hesitation_option_filiere; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hesitation_option_fk_hesitation_option_filiere ON public.hesitation_option USING btree (id_filiere);


--
-- Name: idx_hesitation_option_fk_hesitation_option_metier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hesitation_option_fk_hesitation_option_metier ON public.hesitation_option USING btree (id_metier);


--
-- Name: idx_hesitation_option_fk_hesitation_option_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hesitation_option_fk_hesitation_option_test ON public.hesitation_option USING btree (id_hesitation_test);


--
-- Name: idx_hesitation_reponse_fk_hesitation_reponse_question; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hesitation_reponse_fk_hesitation_reponse_question ON public.hesitation_reponse USING btree (id_question);


--
-- Name: idx_hesitation_reponse_utilisateur_fk_hesitation_ru_question; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hesitation_reponse_utilisateur_fk_hesitation_ru_question ON public.hesitation_reponse_utilisateur USING btree (id_question);


--
-- Name: idx_hesitation_reponse_utilisateur_fk_hesitation_ru_reponse; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hesitation_reponse_utilisateur_fk_hesitation_ru_reponse ON public.hesitation_reponse_utilisateur USING btree (id_reponse);


--
-- Name: idx_hesitation_reponse_utilisateur_id_hesitation_test; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_hesitation_reponse_utilisateur_id_hesitation_test ON public.hesitation_reponse_utilisateur USING btree (id_hesitation_test, id_question);


--
-- Name: idx_hesitation_test_fk_hesitation_test_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hesitation_test_fk_hesitation_test_user ON public.hesitation_test USING btree (id_user);


--
-- Name: idx_historique_fk_historique_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_historique_fk_historique_user ON public.historique USING btree (id_user);


--
-- Name: idx_metier_critere_fk_metier_critere_critere; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_metier_critere_fk_metier_critere_critere ON public.metier_critere USING btree (id_critere);


--
-- Name: idx_metier_critere_uk_metier_critere; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_metier_critere_uk_metier_critere ON public.metier_critere USING btree (id_metier, id_critere);


--
-- Name: idx_metier_filiere_fk_metier_filiere_filiere; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_metier_filiere_fk_metier_filiere_filiere ON public.metier_filiere USING btree (id_filiere);


--
-- Name: idx_metier_nom; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_metier_nom ON public.metier USING btree (nom);


--
-- Name: idx_metier_serie_id_serie; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_metier_serie_id_serie ON public.metier_serie USING btree (id_serie);


--
-- Name: idx_proposition_fk_proposition_question; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_proposition_fk_proposition_question ON public.proposition USING btree (id_question);


--
-- Name: idx_question_fk_question_questionnaire; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_question_fk_question_questionnaire ON public.question USING btree (id_questionnaire);


--
-- Name: idx_recommandation_fk_recommandation_metier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recommandation_fk_recommandation_metier ON public.recommandation USING btree (id_metier);


--
-- Name: idx_recommandation_fk_recommandation_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recommandation_fk_recommandation_test ON public.recommandation USING btree (id_test);


--
-- Name: idx_reponse_fk_reponse_proposition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reponse_fk_reponse_proposition ON public.reponse USING btree (id_proposition);


--
-- Name: idx_reponse_uk_reponse; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_reponse_uk_reponse ON public.reponse USING btree (id_test, id_proposition);


--
-- Name: idx_serie_nom; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_serie_nom ON public.serie USING btree (nom);


--
-- Name: idx_test_riasec_fk_test_questionnaire; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_riasec_fk_test_questionnaire ON public.test_riasec USING btree (id_questionnaire);


--
-- Name: idx_test_riasec_fk_test_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_riasec_fk_test_user ON public.test_riasec USING btree (id_user);


--
-- Name: idx_universite_detail_id_universite; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_universite_detail_id_universite ON public.universite_detail USING btree (id_universite);


--
-- Name: idx_universite_filiere_fk_universite_filiere_filiere; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_universite_filiere_fk_universite_filiere_filiere ON public.universite_filiere USING btree (id_filiere);


--
-- Name: idx_universite_nom; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_universite_nom ON public.universite USING btree (nom);


--
-- Name: idx_utilisateur_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_utilisateur_email ON public.utilisateur USING btree (email);


--
-- Name: idx_utilisateur_fk_utilisateur_serie; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_utilisateur_fk_utilisateur_serie ON public.utilisateur USING btree (id_serie);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_selec; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_selec ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter, COALESCE(selected_columns, '{}'::text[]));


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- Name: idx_objects_current_version; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_objects_current_version ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE (archived_at IS NULL);


--
-- Name: idx_objects_delete_markers; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_delete_markers ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE is_delete_marker;


--
-- Name: idx_objects_null_version; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_objects_null_version ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE (NOT is_versioned);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_name_version_key; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX objects_bucket_id_name_version_key ON storage.objects USING btree (bucket_id, name COLLATE "C", version) NULLS NOT DISTINCT;


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets protect_bucket_control_insert; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_insert BEFORE INSERT ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_bucket_control_columns('service_role');


--
-- Name: buckets protect_bucket_control_update; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_update BEFORE UPDATE OF lifecycle_configuration, lifecycle_configuration_generation ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_bucket_control_columns();


--
-- Name: buckets protect_bucket_control_update_role; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_update_role AFTER UPDATE OF lifecycle_configuration, lifecycle_configuration_generation ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_lifecycle_service_role('service_role');


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_mfa_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_mfa_factor_id_fkey FOREIGN KEY (mfa_factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_recovery_codes mfa_recovery_codes_mfa_recovery_code_set_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_codes
    ADD CONSTRAINT mfa_recovery_codes_mfa_recovery_code_set_id_fkey FOREIGN KEY (mfa_recovery_code_set_id) REFERENCES auth.mfa_recovery_code_sets(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: scim_tokens scim_tokens_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_tokens
    ADD CONSTRAINT scim_tokens_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: scim_users scim_users_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_users
    ADD CONSTRAINT scim_users_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: scim_users scim_users_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_users
    ADD CONSTRAINT scim_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: webauthn_challenges webauthn_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: attente_fonctionnalite fk_attente_fonctionnalite_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attente_fonctionnalite
    ADD CONSTRAINT fk_attente_fonctionnalite_user FOREIGN KEY (id_user) REFERENCES public.utilisateur(id_user) ON DELETE CASCADE;


--
-- Name: avis fk_avis_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avis
    ADD CONSTRAINT fk_avis_user FOREIGN KEY (id_user) REFERENCES public.utilisateur(id_user) ON DELETE CASCADE;


--
-- Name: badge_utilisateur fk_badge_utilisateur_badge; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badge_utilisateur
    ADD CONSTRAINT fk_badge_utilisateur_badge FOREIGN KEY (id_badge) REFERENCES public.badge(id_badge) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: badge_utilisateur fk_badge_utilisateur_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badge_utilisateur
    ADD CONSTRAINT fk_badge_utilisateur_user FOREIGN KEY (id_user) REFERENCES public.utilisateur(id_user) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: connexion_utilisateur fk_connexion_utilisateur; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connexion_utilisateur
    ADD CONSTRAINT fk_connexion_utilisateur FOREIGN KEY (id_user) REFERENCES public.utilisateur(id_user) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: favori fk_favori_metier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favori
    ADD CONSTRAINT fk_favori_metier FOREIGN KEY (id_metier) REFERENCES public.metier(id_metier) ON DELETE CASCADE;


--
-- Name: favori fk_favori_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favori
    ADD CONSTRAINT fk_favori_user FOREIGN KEY (id_user) REFERENCES public.utilisateur(id_user) ON DELETE CASCADE;


--
-- Name: filiere_critere fk_filiere_critere_critere; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiere_critere
    ADD CONSTRAINT fk_filiere_critere_critere FOREIGN KEY (id_critere) REFERENCES public.hesitation_critere(id_critere) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: filiere_critere fk_filiere_critere_filiere; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiere_critere
    ADD CONSTRAINT fk_filiere_critere_filiere FOREIGN KEY (id_filiere) REFERENCES public.filiere(id_filiere) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hesitation_option fk_hesitation_option_filiere; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_option
    ADD CONSTRAINT fk_hesitation_option_filiere FOREIGN KEY (id_filiere) REFERENCES public.filiere(id_filiere) ON DELETE CASCADE;


--
-- Name: hesitation_option fk_hesitation_option_metier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_option
    ADD CONSTRAINT fk_hesitation_option_metier FOREIGN KEY (id_metier) REFERENCES public.metier(id_metier) ON DELETE CASCADE;


--
-- Name: hesitation_option fk_hesitation_option_test; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_option
    ADD CONSTRAINT fk_hesitation_option_test FOREIGN KEY (id_hesitation_test) REFERENCES public.hesitation_test(id_hesitation_test) ON DELETE CASCADE;


--
-- Name: hesitation_reponse fk_hesitation_reponse_question; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_reponse
    ADD CONSTRAINT fk_hesitation_reponse_question FOREIGN KEY (id_question) REFERENCES public.hesitation_question(id_question) ON DELETE CASCADE;


--
-- Name: hesitation_reponse_utilisateur fk_hesitation_ru_question; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_reponse_utilisateur
    ADD CONSTRAINT fk_hesitation_ru_question FOREIGN KEY (id_question) REFERENCES public.hesitation_question(id_question) ON DELETE CASCADE;


--
-- Name: hesitation_reponse_utilisateur fk_hesitation_ru_reponse; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_reponse_utilisateur
    ADD CONSTRAINT fk_hesitation_ru_reponse FOREIGN KEY (id_reponse) REFERENCES public.hesitation_reponse(id_reponse) ON DELETE CASCADE;


--
-- Name: hesitation_reponse_utilisateur fk_hesitation_ru_test; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_reponse_utilisateur
    ADD CONSTRAINT fk_hesitation_ru_test FOREIGN KEY (id_hesitation_test) REFERENCES public.hesitation_test(id_hesitation_test) ON DELETE CASCADE;


--
-- Name: hesitation_test fk_hesitation_test_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hesitation_test
    ADD CONSTRAINT fk_hesitation_test_user FOREIGN KEY (id_user) REFERENCES public.utilisateur(id_user) ON DELETE CASCADE;


--
-- Name: historique fk_historique_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT fk_historique_user FOREIGN KEY (id_user) REFERENCES public.utilisateur(id_user) ON DELETE CASCADE;


--
-- Name: metier_critere fk_metier_critere_critere; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier_critere
    ADD CONSTRAINT fk_metier_critere_critere FOREIGN KEY (id_critere) REFERENCES public.hesitation_critere(id_critere) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: metier_critere fk_metier_critere_metier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier_critere
    ADD CONSTRAINT fk_metier_critere_metier FOREIGN KEY (id_metier) REFERENCES public.metier(id_metier) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: metier_filiere fk_metier_filiere_filiere; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier_filiere
    ADD CONSTRAINT fk_metier_filiere_filiere FOREIGN KEY (id_filiere) REFERENCES public.filiere(id_filiere) ON DELETE CASCADE;


--
-- Name: metier_filiere fk_metier_filiere_metier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier_filiere
    ADD CONSTRAINT fk_metier_filiere_metier FOREIGN KEY (id_metier) REFERENCES public.metier(id_metier) ON DELETE CASCADE;


--
-- Name: proposition fk_proposition_question; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposition
    ADD CONSTRAINT fk_proposition_question FOREIGN KEY (id_question) REFERENCES public.question(id_question) ON DELETE CASCADE;


--
-- Name: question fk_question_questionnaire; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question
    ADD CONSTRAINT fk_question_questionnaire FOREIGN KEY (id_questionnaire) REFERENCES public.questionnaire(id_questionnaire) ON DELETE CASCADE;


--
-- Name: recommandation fk_recommandation_metier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommandation
    ADD CONSTRAINT fk_recommandation_metier FOREIGN KEY (id_metier) REFERENCES public.metier(id_metier) ON DELETE CASCADE;


--
-- Name: recommandation fk_recommandation_test; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommandation
    ADD CONSTRAINT fk_recommandation_test FOREIGN KEY (id_test) REFERENCES public.test_riasec(id_test) ON DELETE CASCADE;


--
-- Name: reponse fk_reponse_proposition; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reponse
    ADD CONSTRAINT fk_reponse_proposition FOREIGN KEY (id_proposition) REFERENCES public.proposition(id_proposition) ON DELETE CASCADE;


--
-- Name: reponse fk_reponse_test; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reponse
    ADD CONSTRAINT fk_reponse_test FOREIGN KEY (id_test) REFERENCES public.test_riasec(id_test) ON DELETE CASCADE;


--
-- Name: test_riasec fk_test_questionnaire; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_riasec
    ADD CONSTRAINT fk_test_questionnaire FOREIGN KEY (id_questionnaire) REFERENCES public.questionnaire(id_questionnaire) ON UPDATE CASCADE;


--
-- Name: test_riasec fk_test_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_riasec
    ADD CONSTRAINT fk_test_user FOREIGN KEY (id_user) REFERENCES public.utilisateur(id_user) ON DELETE CASCADE;


--
-- Name: universite_filiere fk_universite_filiere_filiere; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universite_filiere
    ADD CONSTRAINT fk_universite_filiere_filiere FOREIGN KEY (id_filiere) REFERENCES public.filiere(id_filiere) ON DELETE CASCADE;


--
-- Name: universite_filiere fk_universite_filiere_universite; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universite_filiere
    ADD CONSTRAINT fk_universite_filiere_universite FOREIGN KEY (id_universite) REFERENCES public.universite(id_universite) ON DELETE CASCADE;


--
-- Name: utilisateur fk_utilisateur_serie; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT fk_utilisateur_serie FOREIGN KEY (id_serie) REFERENCES public.serie(id_serie);


--
-- Name: metier_serie metier_serie_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier_serie
    ADD CONSTRAINT metier_serie_ibfk_1 FOREIGN KEY (id_metier) REFERENCES public.metier(id_metier);


--
-- Name: metier_serie metier_serie_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metier_serie
    ADD CONSTRAINT metier_serie_ibfk_2 FOREIGN KEY (id_serie) REFERENCES public.serie(id_serie);


--
-- Name: universite_detail universite_detail_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universite_detail
    ADD CONSTRAINT universite_detail_ibfk_1 FOREIGN KEY (id_universite) REFERENCES public.universite(id_universite) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: profil_riasec Lecture publique des profils RIASEC; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Lecture publique des profils RIASEC" ON public.profil_riasec FOR SELECT USING ((actif = true));


--
-- Name: attente_fonctionnalite; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.attente_fonctionnalite ENABLE ROW LEVEL SECURITY;

--
-- Name: avis; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.avis ENABLE ROW LEVEL SECURITY;

--
-- Name: badge; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.badge ENABLE ROW LEVEL SECURITY;

--
-- Name: badge_utilisateur; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.badge_utilisateur ENABLE ROW LEVEL SECURITY;

--
-- Name: connexion_utilisateur; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.connexion_utilisateur ENABLE ROW LEVEL SECURITY;

--
-- Name: favori; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.favori ENABLE ROW LEVEL SECURITY;

--
-- Name: filiere; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.filiere ENABLE ROW LEVEL SECURITY;

--
-- Name: filiere_critere; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.filiere_critere ENABLE ROW LEVEL SECURITY;

--
-- Name: hesitation_critere; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.hesitation_critere ENABLE ROW LEVEL SECURITY;

--
-- Name: hesitation_option; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.hesitation_option ENABLE ROW LEVEL SECURITY;

--
-- Name: hesitation_question; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.hesitation_question ENABLE ROW LEVEL SECURITY;

--
-- Name: hesitation_reponse; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.hesitation_reponse ENABLE ROW LEVEL SECURITY;

--
-- Name: hesitation_reponse_utilisateur; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.hesitation_reponse_utilisateur ENABLE ROW LEVEL SECURITY;

--
-- Name: hesitation_test; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.hesitation_test ENABLE ROW LEVEL SECURITY;

--
-- Name: historique; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.historique ENABLE ROW LEVEL SECURITY;

--
-- Name: metier; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.metier ENABLE ROW LEVEL SECURITY;

--
-- Name: metier_critere; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.metier_critere ENABLE ROW LEVEL SECURITY;

--
-- Name: metier_filiere; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.metier_filiere ENABLE ROW LEVEL SECURITY;

--
-- Name: metier_serie; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.metier_serie ENABLE ROW LEVEL SECURITY;

--
-- Name: profil_riasec; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profil_riasec ENABLE ROW LEVEL SECURITY;

--
-- Name: proposition; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.proposition ENABLE ROW LEVEL SECURITY;

--
-- Name: question; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.question ENABLE ROW LEVEL SECURITY;

--
-- Name: questionnaire; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.questionnaire ENABLE ROW LEVEL SECURITY;

--
-- Name: recommandation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.recommandation ENABLE ROW LEVEL SECURITY;

--
-- Name: reponse; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reponse ENABLE ROW LEVEL SECURITY;

--
-- Name: serie; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.serie ENABLE ROW LEVEL SECURITY;

--
-- Name: test_riasec; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.test_riasec ENABLE ROW LEVEL SECURITY;

--
-- Name: universite; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.universite ENABLE ROW LEVEL SECURITY;

--
-- Name: universite_detail; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.universite_detail ENABLE ROW LEVEL SECURITY;

--
-- Name: universite_filiere; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.universite_filiere ENABLE ROW LEVEL SECURITY;

--
-- Name: utilisateur; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.utilisateur ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict h5UKgP9ys5gz39OhcDurLRwjEg834tBWjWkZSxaVM4QHYKqiWXlFbFRdwhAWUXj

