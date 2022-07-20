--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Drop databases (except postgres and template1)
--

DROP DATABASE ghostwriter;
DROP DATABASE test_ghostwriter;




--
-- Drop roles
--

DROP ROLE postgres;


--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md570c3549be70dcd9a7ff2f0de8999f53a';






--
-- PostgreSQL database dump
--

-- Dumped from database version 11.12 (Debian 11.12-1.pgdg90+1)
-- Dumped by pg_dump version 11.12 (Debian 11.12-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

UPDATE pg_catalog.pg_database SET datistemplate = false WHERE datname = 'template1';
DROP DATABASE template1;
--
-- Name: template1; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE template1 OWNER TO postgres;

\connect template1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: template1; Type: DATABASE PROPERTIES; Schema: -; Owner: postgres
--

ALTER DATABASE template1 IS_TEMPLATE = true;


\connect template1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE template1; Type: ACL; Schema: -; Owner: postgres
--

REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.12 (Debian 11.12-1.pgdg90+1)
-- Dumped by pg_dump version 11.12 (Debian 11.12-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ghostwriter; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE ghostwriter WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE ghostwriter OWNER TO postgres;

\connect ghostwriter

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: postgres
--

CREATE FUNCTION hdb_catalog.gen_hasura_uuid() RETURNS uuid
    LANGUAGE sql
    AS $$select gen_random_uuid()$$;


ALTER FUNCTION hdb_catalog.gen_hasura_uuid() OWNER TO postgres;

--
-- Name: insert_event_log(text, text, text, text, json); Type: FUNCTION; Schema: hdb_catalog; Owner: postgres
--

CREATE FUNCTION hdb_catalog.insert_event_log(schema_name text, table_name text, trigger_name text, op text, row_data json) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    id text;
    payload json;
    session_variables json;
    server_version_num int;
    trace_context json;
  BEGIN
    id := gen_random_uuid();
    server_version_num := current_setting('server_version_num');
    IF server_version_num >= 90600 THEN
      session_variables := current_setting('hasura.user', 't');
      trace_context := current_setting('hasura.tracecontext', 't');
    ELSE
      BEGIN
        session_variables := current_setting('hasura.user');
      EXCEPTION WHEN OTHERS THEN
                  session_variables := NULL;
      END;
      BEGIN
        trace_context := current_setting('hasura.tracecontext');
      EXCEPTION WHEN OTHERS THEN
        trace_context := NULL;
      END;
    END IF;
    payload := json_build_object(
      'op', op,
      'data', row_data,
      'session_variables', session_variables,
      'trace_context', trace_context
    );
    INSERT INTO hdb_catalog.event_log
                (id, schema_name, table_name, trigger_name, payload)
    VALUES
    (id, schema_name, table_name, trigger_name, payload);
    RETURN id;
  END;
$$;


ALTER FUNCTION hdb_catalog.insert_event_log(schema_name text, table_name text, trigger_name text, op text, row_data json) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.event_invocation_logs OWNER TO postgres;

--
-- Name: event_log; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.event_log (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    trigger_name text NOT NULL,
    payload jsonb NOT NULL,
    delivered boolean DEFAULT false NOT NULL,
    error boolean DEFAULT false NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    locked timestamp with time zone,
    next_retry_at timestamp without time zone,
    archived boolean DEFAULT false NOT NULL
);


ALTER TABLE hdb_catalog.event_log OWNER TO postgres;

--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


ALTER TABLE hdb_catalog.hdb_action_log OWNER TO postgres;

--
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_cron_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_cron_event_invocation_logs OWNER TO postgres;

--
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_cron_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    trigger_name text NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_cron_events OWNER TO postgres;

--
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_metadata (
    id integer NOT NULL,
    metadata json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL
);


ALTER TABLE hdb_catalog.hdb_metadata OWNER TO postgres;

--
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_scheduled_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_scheduled_event_invocation_logs OWNER TO postgres;

--
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_scheduled_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    webhook_conf json NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    retry_conf json,
    payload json,
    header_conf json,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    comment text,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_scheduled_events OWNER TO postgres;

--
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_schema_notifications (
    id integer NOT NULL,
    notification json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL,
    instance_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hdb_schema_notifications_id_check CHECK ((id = 1))
);


ALTER TABLE hdb_catalog.hdb_schema_notifications OWNER TO postgres;

--
-- Name: hdb_source_catalog_version; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_source_catalog_version (
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL
);


ALTER TABLE hdb_catalog.hdb_source_catalog_version OWNER TO postgres;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO postgres;

--
-- Name: account_emailaddress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_emailaddress (
    id integer NOT NULL,
    email character varying(254) NOT NULL,
    verified boolean NOT NULL,
    "primary" boolean NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.account_emailaddress OWNER TO postgres;

--
-- Name: account_emailaddress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_emailaddress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_emailaddress_id_seq OWNER TO postgres;

--
-- Name: account_emailaddress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_emailaddress_id_seq OWNED BY public.account_emailaddress.id;


--
-- Name: account_emailconfirmation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_emailconfirmation (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    sent timestamp with time zone,
    key character varying(64) NOT NULL,
    email_address_id integer NOT NULL
);


ALTER TABLE public.account_emailconfirmation OWNER TO postgres;

--
-- Name: account_emailconfirmation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_emailconfirmation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_emailconfirmation_id_seq OWNER TO postgres;

--
-- Name: account_emailconfirmation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_emailconfirmation_id_seq OWNED BY public.account_emailconfirmation.id;


--
-- Name: api_apikey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_apikey (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token text NOT NULL,
    created timestamp with time zone NOT NULL,
    expiry_date timestamp with time zone,
    revoked boolean NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.api_apikey OWNER TO postgres;

--
-- Name: api_apikey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.api_apikey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.api_apikey_id_seq OWNER TO postgres;

--
-- Name: api_apikey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.api_apikey_id_seq OWNED BY public.api_apikey.id;


--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- Name: commandcenter_cloudservicesconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_cloudservicesconfiguration (
    id bigint NOT NULL,
    enable boolean NOT NULL,
    aws_key character varying(255) NOT NULL,
    aws_secret character varying(255) NOT NULL,
    do_api_key character varying(255) NOT NULL,
    ignore_tag character varying(255) NOT NULL,
    notification_delay integer NOT NULL
);


ALTER TABLE public.commandcenter_cloudservicesconfiguration OWNER TO postgres;

--
-- Name: commandcenter_cloudservicesconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_cloudservicesconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_cloudservicesconfiguration_id_seq OWNER TO postgres;

--
-- Name: commandcenter_cloudservicesconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_cloudservicesconfiguration_id_seq OWNED BY public.commandcenter_cloudservicesconfiguration.id;


--
-- Name: commandcenter_companyinformation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_companyinformation (
    id bigint NOT NULL,
    company_name character varying(255) NOT NULL,
    company_twitter character varying(255) NOT NULL,
    company_email character varying(255) NOT NULL
);


ALTER TABLE public.commandcenter_companyinformation OWNER TO postgres;

--
-- Name: commandcenter_companyinformation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_companyinformation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_companyinformation_id_seq OWNER TO postgres;

--
-- Name: commandcenter_companyinformation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_companyinformation_id_seq OWNED BY public.commandcenter_companyinformation.id;


--
-- Name: commandcenter_namecheapconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_namecheapconfiguration (
    id bigint NOT NULL,
    enable boolean NOT NULL,
    api_key character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    api_username character varying(255) NOT NULL,
    client_ip character varying(255) NOT NULL,
    page_size integer NOT NULL
);


ALTER TABLE public.commandcenter_namecheapconfiguration OWNER TO postgres;

--
-- Name: commandcenter_namecheapconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_namecheapconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_namecheapconfiguration_id_seq OWNER TO postgres;

--
-- Name: commandcenter_namecheapconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_namecheapconfiguration_id_seq OWNED BY public.commandcenter_namecheapconfiguration.id;


--
-- Name: commandcenter_reportconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_reportconfiguration (
    id bigint NOT NULL,
    border_weight integer NOT NULL,
    border_color character varying(6) NOT NULL,
    prefix_figure character varying(255) NOT NULL,
    prefix_table character varying(255) NOT NULL,
    default_docx_template_id bigint,
    default_pptx_template_id bigint,
    enable_borders boolean NOT NULL,
    label_figure character varying(255) NOT NULL,
    label_table character varying(255) NOT NULL
);


ALTER TABLE public.commandcenter_reportconfiguration OWNER TO postgres;

--
-- Name: commandcenter_reportconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_reportconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_reportconfiguration_id_seq OWNER TO postgres;

--
-- Name: commandcenter_reportconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_reportconfiguration_id_seq OWNED BY public.commandcenter_reportconfiguration.id;


--
-- Name: commandcenter_slackconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_slackconfiguration (
    id bigint NOT NULL,
    enable boolean NOT NULL,
    webhook_url character varying(255) NOT NULL,
    slack_emoji character varying(255) NOT NULL,
    slack_channel character varying(255) NOT NULL,
    slack_username character varying(255) NOT NULL,
    slack_alert_target character varying(255) NOT NULL
);


ALTER TABLE public.commandcenter_slackconfiguration OWNER TO postgres;

--
-- Name: commandcenter_slackconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_slackconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_slackconfiguration_id_seq OWNER TO postgres;

--
-- Name: commandcenter_slackconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_slackconfiguration_id_seq OWNED BY public.commandcenter_slackconfiguration.id;


--
-- Name: commandcenter_virustotalconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_virustotalconfiguration (
    id bigint NOT NULL,
    enable boolean NOT NULL,
    api_key character varying(255) NOT NULL,
    sleep_time integer NOT NULL
);


ALTER TABLE public.commandcenter_virustotalconfiguration OWNER TO postgres;

--
-- Name: commandcenter_virustotalconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_virustotalconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_virustotalconfiguration_id_seq OWNER TO postgres;

--
-- Name: commandcenter_virustotalconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_virustotalconfiguration_id_seq OWNED BY public.commandcenter_virustotalconfiguration.id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id bigint NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- Name: django_q_ormq; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_q_ormq (
    id integer NOT NULL,
    key character varying(100) NOT NULL,
    payload text NOT NULL,
    lock timestamp with time zone
);


ALTER TABLE public.django_q_ormq OWNER TO postgres;

--
-- Name: django_q_ormq_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_q_ormq_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_q_ormq_id_seq OWNER TO postgres;

--
-- Name: django_q_ormq_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_q_ormq_id_seq OWNED BY public.django_q_ormq.id;


--
-- Name: django_q_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_q_schedule (
    id integer NOT NULL,
    func character varying(256) NOT NULL,
    hook character varying(256),
    args text,
    kwargs text,
    schedule_type character varying(1) NOT NULL,
    repeats integer NOT NULL,
    next_run timestamp with time zone,
    task character varying(100),
    name character varying(100),
    minutes smallint,
    cron character varying(100),
    cluster character varying(100),
    CONSTRAINT django_q_schedule_minutes_check CHECK ((minutes >= 0))
);


ALTER TABLE public.django_q_schedule OWNER TO postgres;

--
-- Name: django_q_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_q_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_q_schedule_id_seq OWNER TO postgres;

--
-- Name: django_q_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_q_schedule_id_seq OWNED BY public.django_q_schedule.id;


--
-- Name: django_q_task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_q_task (
    name character varying(100) NOT NULL,
    func character varying(256) NOT NULL,
    hook character varying(256),
    args text,
    kwargs text,
    result text,
    started timestamp with time zone NOT NULL,
    stopped timestamp with time zone NOT NULL,
    success boolean NOT NULL,
    id character varying(32) NOT NULL,
    "group" character varying(100),
    attempt_count integer NOT NULL
);


ALTER TABLE public.django_q_task OWNER TO postgres;

--
-- Name: django_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO postgres;

--
-- Name: django_site; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_site (
    id integer NOT NULL,
    domain character varying(100) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.django_site OWNER TO postgres;

--
-- Name: django_site_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_site_id_seq OWNER TO postgres;

--
-- Name: django_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_site_id_seq OWNED BY public.django_site.id;


--
-- Name: home_userprofile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.home_userprofile (
    id bigint NOT NULL,
    avatar character varying(100) NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.home_userprofile OWNER TO postgres;

--
-- Name: home_userprofile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.home_userprofile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.home_userprofile_id_seq OWNER TO postgres;

--
-- Name: home_userprofile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.home_userprofile_id_seq OWNED BY public.home_userprofile.id;


--
-- Name: oplog_oplog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oplog_oplog (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    project_id bigint
);


ALTER TABLE public.oplog_oplog OWNER TO postgres;

--
-- Name: oplog_oplog_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oplog_oplog_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oplog_oplog_id_seq OWNER TO postgres;

--
-- Name: oplog_oplog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oplog_oplog_id_seq OWNED BY public.oplog_oplog.id;


--
-- Name: oplog_oplogentry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oplog_oplogentry (
    id bigint NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    source_ip text NOT NULL,
    dest_ip text NOT NULL,
    tool text NOT NULL,
    user_context text NOT NULL,
    command text NOT NULL,
    description text NOT NULL,
    output text,
    comments text NOT NULL,
    operator_name character varying(255) NOT NULL,
    oplog_id_id bigint
);


ALTER TABLE public.oplog_oplogentry OWNER TO postgres;

--
-- Name: oplog_oplogentry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oplog_oplogentry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oplog_oplogentry_id_seq OWNER TO postgres;

--
-- Name: oplog_oplogentry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oplog_oplogentry_id_seq OWNED BY public.oplog_oplogentry.id;


--
-- Name: reporting_archive; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_archive (
    id bigint NOT NULL,
    report_archive character varying(100) NOT NULL,
    project_id bigint
);


ALTER TABLE public.reporting_archive OWNER TO postgres;

--
-- Name: reporting_archive_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_archive_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_archive_id_seq OWNER TO postgres;

--
-- Name: reporting_archive_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_archive_id_seq OWNED BY public.reporting_archive.id;


--
-- Name: reporting_doctype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_doctype (
    id bigint NOT NULL,
    doc_type character varying(5) NOT NULL
);


ALTER TABLE public.reporting_doctype OWNER TO postgres;

--
-- Name: reporting_doctype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_doctype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_doctype_id_seq OWNER TO postgres;

--
-- Name: reporting_doctype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_doctype_id_seq OWNED BY public.reporting_doctype.id;


--
-- Name: reporting_evidence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_evidence (
    id bigint NOT NULL,
    document character varying(100) NOT NULL,
    friendly_name character varying(255),
    upload_date date NOT NULL,
    caption character varying(255) NOT NULL,
    description text NOT NULL,
    finding_id bigint NOT NULL,
    uploaded_by_id bigint
);


ALTER TABLE public.reporting_evidence OWNER TO postgres;

--
-- Name: reporting_evidence_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_evidence_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_evidence_id_seq OWNER TO postgres;

--
-- Name: reporting_evidence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_evidence_id_seq OWNED BY public.reporting_evidence.id;


--
-- Name: reporting_finding; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_finding (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    impact text,
    mitigation text,
    replication_steps text,
    host_detection_techniques text,
    network_detection_techniques text,
    "references" text,
    finding_guidance text,
    finding_type_id bigint,
    severity_id bigint,
    cvss_score double precision,
    cvss_vector character varying(54) NOT NULL
);


ALTER TABLE public.reporting_finding OWNER TO postgres;

--
-- Name: reporting_finding_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_finding_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_finding_id_seq OWNER TO postgres;

--
-- Name: reporting_finding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_finding_id_seq OWNED BY public.reporting_finding.id;


--
-- Name: reporting_findingnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_findingnote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    finding_id bigint NOT NULL,
    operator_id bigint
);


ALTER TABLE public.reporting_findingnote OWNER TO postgres;

--
-- Name: reporting_findingnote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_findingnote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_findingnote_id_seq OWNER TO postgres;

--
-- Name: reporting_findingnote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_findingnote_id_seq OWNED BY public.reporting_findingnote.id;


--
-- Name: reporting_findingtype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_findingtype (
    id bigint NOT NULL,
    finding_type character varying(255) NOT NULL
);


ALTER TABLE public.reporting_findingtype OWNER TO postgres;

--
-- Name: reporting_findingtype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_findingtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_findingtype_id_seq OWNER TO postgres;

--
-- Name: reporting_findingtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_findingtype_id_seq OWNED BY public.reporting_findingtype.id;


--
-- Name: reporting_localfindingnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_localfindingnote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    finding_id bigint NOT NULL,
    operator_id bigint
);


ALTER TABLE public.reporting_localfindingnote OWNER TO postgres;

--
-- Name: reporting_localfindingnote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_localfindingnote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_localfindingnote_id_seq OWNER TO postgres;

--
-- Name: reporting_localfindingnote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_localfindingnote_id_seq OWNED BY public.reporting_localfindingnote.id;


--
-- Name: reporting_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_report (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    creation date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_update date NOT NULL,
    complete boolean DEFAULT false NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    created_by_id bigint,
    project_id bigint,
    delivered boolean DEFAULT false NOT NULL,
    docx_template_id bigint,
    pptx_template_id bigint
);


ALTER TABLE public.reporting_report OWNER TO postgres;

--
-- Name: reporting_report_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_report_id_seq OWNER TO postgres;

--
-- Name: reporting_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_report_id_seq OWNED BY public.reporting_report.id;


--
-- Name: reporting_reportfindinglink; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_reportfindinglink (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    "position" integer NOT NULL,
    affected_entities text,
    description text,
    impact text,
    mitigation text,
    replication_steps text,
    host_detection_techniques text,
    network_detection_techniques text,
    "references" text,
    complete boolean NOT NULL,
    assigned_to_id bigint,
    finding_type_id bigint,
    report_id bigint,
    severity_id bigint,
    finding_guidance text,
    cvss_score double precision,
    cvss_vector character varying(54) NOT NULL
);


ALTER TABLE public.reporting_reportfindinglink OWNER TO postgres;

--
-- Name: reporting_reportfindinglink_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_reportfindinglink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_reportfindinglink_id_seq OWNER TO postgres;

--
-- Name: reporting_reportfindinglink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_reportfindinglink_id_seq OWNED BY public.reporting_reportfindinglink.id;


--
-- Name: reporting_reporttemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_reporttemplate (
    id bigint NOT NULL,
    document character varying(100) NOT NULL,
    name character varying(255),
    upload_date date NOT NULL,
    last_update date NOT NULL,
    description text NOT NULL,
    protected boolean DEFAULT false NOT NULL,
    client_id bigint,
    uploaded_by_id bigint,
    lint_result jsonb,
    changelog text,
    doc_type_id bigint
);


ALTER TABLE public.reporting_reporttemplate OWNER TO postgres;

--
-- Name: reporting_reporttemplate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_reporttemplate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_reporttemplate_id_seq OWNER TO postgres;

--
-- Name: reporting_reporttemplate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_reporttemplate_id_seq OWNED BY public.reporting_reporttemplate.id;


--
-- Name: reporting_severity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_severity (
    id bigint NOT NULL,
    severity character varying(255) NOT NULL,
    weight integer NOT NULL,
    color character varying(6) NOT NULL
);


ALTER TABLE public.reporting_severity OWNER TO postgres;

--
-- Name: reporting_severity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_severity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_severity_id_seq OWNER TO postgres;

--
-- Name: reporting_severity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_severity_id_seq OWNED BY public.reporting_severity.id;


--
-- Name: rest_framework_api_key_apikey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rest_framework_api_key_apikey (
    id character varying(150) NOT NULL,
    created timestamp with time zone NOT NULL,
    name character varying(50) NOT NULL,
    revoked boolean NOT NULL,
    expiry_date timestamp with time zone,
    hashed_key character varying(150) NOT NULL,
    prefix character varying(8) NOT NULL
);


ALTER TABLE public.rest_framework_api_key_apikey OWNER TO postgres;

--
-- Name: rolodex_client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_client (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    short_name character varying(255),
    codename character varying(255),
    note text,
    address text,
    timezone character varying(63) DEFAULT 'America/Los_Angeles'::character varying NOT NULL
);


ALTER TABLE public.rolodex_client OWNER TO postgres;

--
-- Name: rolodex_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_client_id_seq OWNER TO postgres;

--
-- Name: rolodex_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_client_id_seq OWNED BY public.rolodex_client.id;


--
-- Name: rolodex_clientcontact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_clientcontact (
    id bigint NOT NULL,
    name character varying(255),
    job_title character varying(255),
    email character varying(255),
    phone character varying(50),
    note text,
    client_id bigint NOT NULL,
    timezone character varying(63) DEFAULT 'America/Los_Angeles'::character varying NOT NULL
);


ALTER TABLE public.rolodex_clientcontact OWNER TO postgres;

--
-- Name: rolodex_clientcontact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_clientcontact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_clientcontact_id_seq OWNER TO postgres;

--
-- Name: rolodex_clientcontact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_clientcontact_id_seq OWNED BY public.rolodex_clientcontact.id;


--
-- Name: rolodex_clientinvite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_clientinvite (
    id bigint NOT NULL,
    comment text,
    client_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.rolodex_clientinvite OWNER TO postgres;

--
-- Name: rolodex_clientinvite_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_clientinvite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_clientinvite_id_seq OWNER TO postgres;

--
-- Name: rolodex_clientinvite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_clientinvite_id_seq OWNED BY public.rolodex_clientinvite.id;


--
-- Name: rolodex_clientnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_clientnote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    client_id bigint NOT NULL,
    operator_id bigint
);


ALTER TABLE public.rolodex_clientnote OWNER TO postgres;

--
-- Name: rolodex_clientnote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_clientnote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_clientnote_id_seq OWNER TO postgres;

--
-- Name: rolodex_clientnote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_clientnote_id_seq OWNED BY public.rolodex_clientnote.id;


--
-- Name: rolodex_objectivepriority; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_objectivepriority (
    id bigint NOT NULL,
    weight integer NOT NULL,
    priority character varying(255) NOT NULL
);


ALTER TABLE public.rolodex_objectivepriority OWNER TO postgres;

--
-- Name: rolodex_objectivepriority_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_objectivepriority_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_objectivepriority_id_seq OWNER TO postgres;

--
-- Name: rolodex_objectivepriority_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_objectivepriority_id_seq OWNED BY public.rolodex_objectivepriority.id;


--
-- Name: rolodex_objectivestatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_objectivestatus (
    id bigint NOT NULL,
    objective_status character varying(255) NOT NULL
);


ALTER TABLE public.rolodex_objectivestatus OWNER TO postgres;

--
-- Name: rolodex_objectivestatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_objectivestatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_objectivestatus_id_seq OWNER TO postgres;

--
-- Name: rolodex_objectivestatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_objectivestatus_id_seq OWNED BY public.rolodex_objectivestatus.id;


--
-- Name: rolodex_project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_project (
    id bigint NOT NULL,
    codename character varying(255),
    start_date date NOT NULL,
    end_date date NOT NULL,
    note text,
    slack_channel character varying(255),
    complete boolean DEFAULT false NOT NULL,
    client_id bigint NOT NULL,
    operator_id bigint,
    project_type_id bigint NOT NULL,
    timezone character varying(63) DEFAULT 'America/Los_Angeles'::character varying NOT NULL,
    end_time time without time zone,
    start_time time without time zone
);


ALTER TABLE public.rolodex_project OWNER TO postgres;

--
-- Name: rolodex_project_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_project_id_seq OWNER TO postgres;

--
-- Name: rolodex_project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_project_id_seq OWNED BY public.rolodex_project.id;


--
-- Name: rolodex_projectassignment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectassignment (
    id bigint NOT NULL,
    start_date date,
    end_date date,
    note text,
    operator_id bigint,
    project_id bigint NOT NULL,
    role_id bigint
);


ALTER TABLE public.rolodex_projectassignment OWNER TO postgres;

--
-- Name: rolodex_projectassignment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectassignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectassignment_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectassignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectassignment_id_seq OWNED BY public.rolodex_projectassignment.id;


--
-- Name: rolodex_projectinvite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectinvite (
    id bigint NOT NULL,
    comment text,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.rolodex_projectinvite OWNER TO postgres;

--
-- Name: rolodex_projectinvite_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectinvite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectinvite_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectinvite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectinvite_id_seq OWNED BY public.rolodex_projectinvite.id;


--
-- Name: rolodex_projectnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectnote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    operator_id bigint,
    project_id bigint NOT NULL
);


ALTER TABLE public.rolodex_projectnote OWNER TO postgres;

--
-- Name: rolodex_projectnote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectnote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectnote_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectnote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectnote_id_seq OWNED BY public.rolodex_projectnote.id;


--
-- Name: rolodex_projectobjective; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectobjective (
    id bigint NOT NULL,
    objective character varying(255),
    complete boolean DEFAULT false NOT NULL,
    deadline date,
    project_id bigint NOT NULL,
    status_id bigint NOT NULL,
    marked_complete date,
    description text,
    priority_id bigint,
    "position" integer NOT NULL
);


ALTER TABLE public.rolodex_projectobjective OWNER TO postgres;

--
-- Name: rolodex_projectobjective_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectobjective_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectobjective_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectobjective_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectobjective_id_seq OWNED BY public.rolodex_projectobjective.id;


--
-- Name: rolodex_projectrole; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectrole (
    id bigint NOT NULL,
    project_role character varying(255) NOT NULL
);


ALTER TABLE public.rolodex_projectrole OWNER TO postgres;

--
-- Name: rolodex_projectrole_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectrole_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectrole_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectrole_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectrole_id_seq OWNED BY public.rolodex_projectrole.id;


--
-- Name: rolodex_projectscope; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectscope (
    id bigint NOT NULL,
    name character varying(255),
    scope text,
    description text,
    disallowed boolean DEFAULT false NOT NULL,
    requires_caution boolean DEFAULT false NOT NULL,
    project_id bigint NOT NULL
);


ALTER TABLE public.rolodex_projectscope OWNER TO postgres;

--
-- Name: rolodex_projectscope_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectscope_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectscope_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectscope_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectscope_id_seq OWNED BY public.rolodex_projectscope.id;


--
-- Name: rolodex_projectsubtask; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectsubtask (
    id bigint NOT NULL,
    task text,
    complete boolean DEFAULT false NOT NULL,
    deadline date,
    parent_id bigint NOT NULL,
    status_id bigint NOT NULL,
    marked_complete date
);


ALTER TABLE public.rolodex_projectsubtask OWNER TO postgres;

--
-- Name: rolodex_projectsubtask_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectsubtask_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectsubtask_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectsubtask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectsubtask_id_seq OWNED BY public.rolodex_projectsubtask.id;


--
-- Name: rolodex_projecttarget; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projecttarget (
    id bigint NOT NULL,
    ip_address inet,
    hostname character varying(255),
    note text,
    compromised boolean DEFAULT false NOT NULL,
    project_id bigint NOT NULL
);


ALTER TABLE public.rolodex_projecttarget OWNER TO postgres;

--
-- Name: rolodex_projecttarget_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projecttarget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projecttarget_id_seq OWNER TO postgres;

--
-- Name: rolodex_projecttarget_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projecttarget_id_seq OWNED BY public.rolodex_projecttarget.id;


--
-- Name: rolodex_projecttype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projecttype (
    id bigint NOT NULL,
    project_type character varying(255) NOT NULL
);


ALTER TABLE public.rolodex_projecttype OWNER TO postgres;

--
-- Name: rolodex_projecttype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projecttype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projecttype_id_seq OWNER TO postgres;

--
-- Name: rolodex_projecttype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projecttype_id_seq OWNED BY public.rolodex_projecttype.id;


--
-- Name: shepherd_activitytype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_activitytype (
    id bigint NOT NULL,
    activity character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_activitytype OWNER TO postgres;

--
-- Name: shepherd_activitytype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_activitytype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_activitytype_id_seq OWNER TO postgres;

--
-- Name: shepherd_activitytype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_activitytype_id_seq OWNED BY public.shepherd_activitytype.id;


--
-- Name: shepherd_auxserveraddress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_auxserveraddress (
    id bigint NOT NULL,
    ip_address inet,
    static_server_id bigint NOT NULL,
    "primary" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.shepherd_auxserveraddress OWNER TO postgres;

--
-- Name: shepherd_auxserveraddress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_auxserveraddress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_auxserveraddress_id_seq OWNER TO postgres;

--
-- Name: shepherd_auxserveraddress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_auxserveraddress_id_seq OWNED BY public.shepherd_auxserveraddress.id;


--
-- Name: shepherd_domain; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_domain (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    registrar character varying(255),
    creation date NOT NULL,
    expiration date NOT NULL,
    note text,
    burned_explanation text,
    domain_status_id bigint,
    health_status_id bigint,
    last_used_by_id bigint,
    whois_status_id bigint,
    auto_renew boolean DEFAULT false NOT NULL,
    expired boolean DEFAULT false NOT NULL,
    last_health_check date,
    vt_permalink character varying(255),
    reset_dns boolean DEFAULT false NOT NULL,
    categorization jsonb,
    dns jsonb
);


ALTER TABLE public.shepherd_domain OWNER TO postgres;

--
-- Name: shepherd_domain_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_domain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_domain_id_seq OWNER TO postgres;

--
-- Name: shepherd_domain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_domain_id_seq OWNED BY public.shepherd_domain.id;


--
-- Name: shepherd_domainnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_domainnote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    domain_id bigint NOT NULL,
    operator_id bigint
);


ALTER TABLE public.shepherd_domainnote OWNER TO postgres;

--
-- Name: shepherd_domainnote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_domainnote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_domainnote_id_seq OWNER TO postgres;

--
-- Name: shepherd_domainnote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_domainnote_id_seq OWNED BY public.shepherd_domainnote.id;


--
-- Name: shepherd_domainserverconnection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_domainserverconnection (
    id bigint NOT NULL,
    endpoint character varying(255),
    subdomain character varying(255) DEFAULT '*'::character varying,
    domain_id bigint NOT NULL,
    project_id bigint NOT NULL,
    static_server_id bigint,
    transient_server_id bigint,
    CONSTRAINT only_one_server CHECK ((((static_server_id IS NOT NULL) AND (transient_server_id IS NULL)) OR ((static_server_id IS NULL) AND (transient_server_id IS NOT NULL))))
);


ALTER TABLE public.shepherd_domainserverconnection OWNER TO postgres;

--
-- Name: shepherd_domainserverconnection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_domainserverconnection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_domainserverconnection_id_seq OWNER TO postgres;

--
-- Name: shepherd_domainserverconnection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_domainserverconnection_id_seq OWNED BY public.shepherd_domainserverconnection.id;


--
-- Name: shepherd_domainstatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_domainstatus (
    id bigint NOT NULL,
    domain_status character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_domainstatus OWNER TO postgres;

--
-- Name: shepherd_domainstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_domainstatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_domainstatus_id_seq OWNER TO postgres;

--
-- Name: shepherd_domainstatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_domainstatus_id_seq OWNED BY public.shepherd_domainstatus.id;


--
-- Name: shepherd_healthstatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_healthstatus (
    id bigint NOT NULL,
    health_status character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_healthstatus OWNER TO postgres;

--
-- Name: shepherd_healthstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_healthstatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_healthstatus_id_seq OWNER TO postgres;

--
-- Name: shepherd_healthstatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_healthstatus_id_seq OWNED BY public.shepherd_healthstatus.id;


--
-- Name: shepherd_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_history (
    id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    note text,
    activity_type_id bigint NOT NULL,
    client_id bigint NOT NULL,
    domain_id bigint NOT NULL,
    operator_id bigint,
    project_id bigint
);


ALTER TABLE public.shepherd_history OWNER TO postgres;

--
-- Name: shepherd_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_history_id_seq OWNER TO postgres;

--
-- Name: shepherd_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_history_id_seq OWNED BY public.shepherd_history.id;


--
-- Name: shepherd_serverhistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_serverhistory (
    id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    note text,
    activity_type_id bigint NOT NULL,
    client_id bigint NOT NULL,
    operator_id bigint,
    project_id bigint,
    server_id bigint NOT NULL,
    server_role_id bigint NOT NULL
);


ALTER TABLE public.shepherd_serverhistory OWNER TO postgres;

--
-- Name: shepherd_serverhistory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_serverhistory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_serverhistory_id_seq OWNER TO postgres;

--
-- Name: shepherd_serverhistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_serverhistory_id_seq OWNED BY public.shepherd_serverhistory.id;


--
-- Name: shepherd_servernote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_servernote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    operator_id bigint,
    server_id bigint NOT NULL
);


ALTER TABLE public.shepherd_servernote OWNER TO postgres;

--
-- Name: shepherd_servernote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_servernote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_servernote_id_seq OWNER TO postgres;

--
-- Name: shepherd_servernote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_servernote_id_seq OWNED BY public.shepherd_servernote.id;


--
-- Name: shepherd_serverprovider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_serverprovider (
    id bigint NOT NULL,
    server_provider character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_serverprovider OWNER TO postgres;

--
-- Name: shepherd_serverprovider_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_serverprovider_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_serverprovider_id_seq OWNER TO postgres;

--
-- Name: shepherd_serverprovider_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_serverprovider_id_seq OWNED BY public.shepherd_serverprovider.id;


--
-- Name: shepherd_serverrole; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_serverrole (
    id bigint NOT NULL,
    server_role character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_serverrole OWNER TO postgres;

--
-- Name: shepherd_serverrole_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_serverrole_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_serverrole_id_seq OWNER TO postgres;

--
-- Name: shepherd_serverrole_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_serverrole_id_seq OWNED BY public.shepherd_serverrole.id;


--
-- Name: shepherd_serverstatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_serverstatus (
    id bigint NOT NULL,
    server_status character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_serverstatus OWNER TO postgres;

--
-- Name: shepherd_serverstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_serverstatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_serverstatus_id_seq OWNER TO postgres;

--
-- Name: shepherd_serverstatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_serverstatus_id_seq OWNED BY public.shepherd_serverstatus.id;


--
-- Name: shepherd_staticserver; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_staticserver (
    id bigint NOT NULL,
    ip_address inet NOT NULL,
    note text,
    last_used_by_id bigint,
    server_provider_id bigint,
    server_status_id bigint,
    name character varying(255)
);


ALTER TABLE public.shepherd_staticserver OWNER TO postgres;

--
-- Name: shepherd_staticserver_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_staticserver_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_staticserver_id_seq OWNER TO postgres;

--
-- Name: shepherd_staticserver_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_staticserver_id_seq OWNED BY public.shepherd_staticserver.id;


--
-- Name: shepherd_transientserver; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_transientserver (
    id bigint NOT NULL,
    ip_address inet NOT NULL,
    note text,
    activity_type_id bigint NOT NULL,
    operator_id bigint,
    project_id bigint,
    server_provider_id bigint,
    server_role_id bigint NOT NULL,
    name character varying(255),
    aux_address inet[]
);


ALTER TABLE public.shepherd_transientserver OWNER TO postgres;

--
-- Name: shepherd_transientserver_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_transientserver_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_transientserver_id_seq OWNER TO postgres;

--
-- Name: shepherd_transientserver_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_transientserver_id_seq OWNED BY public.shepherd_transientserver.id;


--
-- Name: shepherd_whoisstatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_whoisstatus (
    id bigint NOT NULL,
    whois_status character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_whoisstatus OWNER TO postgres;

--
-- Name: shepherd_whoisstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_whoisstatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_whoisstatus_id_seq OWNER TO postgres;

--
-- Name: shepherd_whoisstatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_whoisstatus_id_seq OWNED BY public.shepherd_whoisstatus.id;


--
-- Name: socialaccount_socialaccount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.socialaccount_socialaccount (
    id integer NOT NULL,
    provider character varying(30) NOT NULL,
    uid character varying(191) NOT NULL,
    last_login timestamp with time zone NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    extra_data text NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.socialaccount_socialaccount OWNER TO postgres;

--
-- Name: socialaccount_socialaccount_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.socialaccount_socialaccount_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.socialaccount_socialaccount_id_seq OWNER TO postgres;

--
-- Name: socialaccount_socialaccount_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.socialaccount_socialaccount_id_seq OWNED BY public.socialaccount_socialaccount.id;


--
-- Name: socialaccount_socialapp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.socialaccount_socialapp (
    id integer NOT NULL,
    provider character varying(30) NOT NULL,
    name character varying(40) NOT NULL,
    client_id character varying(191) NOT NULL,
    secret character varying(191) NOT NULL,
    key character varying(191) NOT NULL
);


ALTER TABLE public.socialaccount_socialapp OWNER TO postgres;

--
-- Name: socialaccount_socialapp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.socialaccount_socialapp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.socialaccount_socialapp_id_seq OWNER TO postgres;

--
-- Name: socialaccount_socialapp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.socialaccount_socialapp_id_seq OWNED BY public.socialaccount_socialapp.id;


--
-- Name: socialaccount_socialapp_sites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.socialaccount_socialapp_sites (
    id bigint NOT NULL,
    socialapp_id integer NOT NULL,
    site_id integer NOT NULL
);


ALTER TABLE public.socialaccount_socialapp_sites OWNER TO postgres;

--
-- Name: socialaccount_socialapp_sites_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.socialaccount_socialapp_sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.socialaccount_socialapp_sites_id_seq OWNER TO postgres;

--
-- Name: socialaccount_socialapp_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.socialaccount_socialapp_sites_id_seq OWNED BY public.socialaccount_socialapp_sites.id;


--
-- Name: socialaccount_socialtoken; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.socialaccount_socialtoken (
    id integer NOT NULL,
    token text NOT NULL,
    token_secret text NOT NULL,
    expires_at timestamp with time zone,
    account_id integer NOT NULL,
    app_id integer NOT NULL
);


ALTER TABLE public.socialaccount_socialtoken OWNER TO postgres;

--
-- Name: socialaccount_socialtoken_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.socialaccount_socialtoken_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.socialaccount_socialtoken_id_seq OWNER TO postgres;

--
-- Name: socialaccount_socialtoken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.socialaccount_socialtoken_id_seq OWNED BY public.socialaccount_socialtoken.id;


--
-- Name: users_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_user (
    id bigint NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    phone character varying(50),
    timezone character varying(63) NOT NULL,
    role character varying(120) NOT NULL
);


ALTER TABLE public.users_user OWNER TO postgres;

--
-- Name: users_user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_user_groups (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.users_user_groups OWNER TO postgres;

--
-- Name: users_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_groups_id_seq OWNER TO postgres;

--
-- Name: users_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_groups_id_seq OWNED BY public.users_user_groups.id;


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users_user.id;


--
-- Name: users_user_user_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_user_user_permissions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.users_user_user_permissions OWNER TO postgres;

--
-- Name: users_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_user_permissions_id_seq OWNER TO postgres;

--
-- Name: users_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_user_permissions_id_seq OWNED BY public.users_user_user_permissions.id;


--
-- Name: account_emailaddress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailaddress ALTER COLUMN id SET DEFAULT nextval('public.account_emailaddress_id_seq'::regclass);


--
-- Name: account_emailconfirmation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailconfirmation ALTER COLUMN id SET DEFAULT nextval('public.account_emailconfirmation_id_seq'::regclass);


--
-- Name: api_apikey id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_apikey ALTER COLUMN id SET DEFAULT nextval('public.api_apikey_id_seq'::regclass);


--
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- Name: commandcenter_cloudservicesconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_cloudservicesconfiguration ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_cloudservicesconfiguration_id_seq'::regclass);


--
-- Name: commandcenter_companyinformation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_companyinformation ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_companyinformation_id_seq'::regclass);


--
-- Name: commandcenter_namecheapconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_namecheapconfiguration ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_namecheapconfiguration_id_seq'::regclass);


--
-- Name: commandcenter_reportconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_reportconfiguration ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_reportconfiguration_id_seq'::regclass);


--
-- Name: commandcenter_slackconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_slackconfiguration ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_slackconfiguration_id_seq'::regclass);


--
-- Name: commandcenter_virustotalconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_virustotalconfiguration ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_virustotalconfiguration_id_seq'::regclass);


--
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- Name: django_q_ormq id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_q_ormq ALTER COLUMN id SET DEFAULT nextval('public.django_q_ormq_id_seq'::regclass);


--
-- Name: django_q_schedule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_q_schedule ALTER COLUMN id SET DEFAULT nextval('public.django_q_schedule_id_seq'::regclass);


--
-- Name: django_site id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_site ALTER COLUMN id SET DEFAULT nextval('public.django_site_id_seq'::regclass);


--
-- Name: home_userprofile id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home_userprofile ALTER COLUMN id SET DEFAULT nextval('public.home_userprofile_id_seq'::regclass);


--
-- Name: oplog_oplog id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplog ALTER COLUMN id SET DEFAULT nextval('public.oplog_oplog_id_seq'::regclass);


--
-- Name: oplog_oplogentry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplogentry ALTER COLUMN id SET DEFAULT nextval('public.oplog_oplogentry_id_seq'::regclass);


--
-- Name: reporting_archive id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_archive ALTER COLUMN id SET DEFAULT nextval('public.reporting_archive_id_seq'::regclass);


--
-- Name: reporting_doctype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_doctype ALTER COLUMN id SET DEFAULT nextval('public.reporting_doctype_id_seq'::regclass);


--
-- Name: reporting_evidence id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_evidence ALTER COLUMN id SET DEFAULT nextval('public.reporting_evidence_id_seq'::regclass);


--
-- Name: reporting_finding id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_finding ALTER COLUMN id SET DEFAULT nextval('public.reporting_finding_id_seq'::regclass);


--
-- Name: reporting_findingnote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingnote ALTER COLUMN id SET DEFAULT nextval('public.reporting_findingnote_id_seq'::regclass);


--
-- Name: reporting_findingtype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingtype ALTER COLUMN id SET DEFAULT nextval('public.reporting_findingtype_id_seq'::regclass);


--
-- Name: reporting_localfindingnote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_localfindingnote ALTER COLUMN id SET DEFAULT nextval('public.reporting_localfindingnote_id_seq'::regclass);


--
-- Name: reporting_report id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report ALTER COLUMN id SET DEFAULT nextval('public.reporting_report_id_seq'::regclass);


--
-- Name: reporting_reportfindinglink id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink ALTER COLUMN id SET DEFAULT nextval('public.reporting_reportfindinglink_id_seq'::regclass);


--
-- Name: reporting_reporttemplate id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reporttemplate ALTER COLUMN id SET DEFAULT nextval('public.reporting_reporttemplate_id_seq'::regclass);


--
-- Name: reporting_severity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_severity ALTER COLUMN id SET DEFAULT nextval('public.reporting_severity_id_seq'::regclass);


--
-- Name: rolodex_client id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_client ALTER COLUMN id SET DEFAULT nextval('public.rolodex_client_id_seq'::regclass);


--
-- Name: rolodex_clientcontact id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientcontact ALTER COLUMN id SET DEFAULT nextval('public.rolodex_clientcontact_id_seq'::regclass);


--
-- Name: rolodex_clientinvite id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientinvite ALTER COLUMN id SET DEFAULT nextval('public.rolodex_clientinvite_id_seq'::regclass);


--
-- Name: rolodex_clientnote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientnote ALTER COLUMN id SET DEFAULT nextval('public.rolodex_clientnote_id_seq'::regclass);


--
-- Name: rolodex_objectivepriority id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivepriority ALTER COLUMN id SET DEFAULT nextval('public.rolodex_objectivepriority_id_seq'::regclass);


--
-- Name: rolodex_objectivestatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivestatus ALTER COLUMN id SET DEFAULT nextval('public.rolodex_objectivestatus_id_seq'::regclass);


--
-- Name: rolodex_project id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_project ALTER COLUMN id SET DEFAULT nextval('public.rolodex_project_id_seq'::regclass);


--
-- Name: rolodex_projectassignment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectassignment ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectassignment_id_seq'::regclass);


--
-- Name: rolodex_projectinvite id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectinvite ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectinvite_id_seq'::regclass);


--
-- Name: rolodex_projectnote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectnote ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectnote_id_seq'::regclass);


--
-- Name: rolodex_projectobjective id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectobjective ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectobjective_id_seq'::regclass);


--
-- Name: rolodex_projectrole id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectrole ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectrole_id_seq'::regclass);


--
-- Name: rolodex_projectscope id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectscope ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectscope_id_seq'::regclass);


--
-- Name: rolodex_projectsubtask id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectsubtask ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectsubtask_id_seq'::regclass);


--
-- Name: rolodex_projecttarget id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttarget ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projecttarget_id_seq'::regclass);


--
-- Name: rolodex_projecttype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttype ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projecttype_id_seq'::regclass);


--
-- Name: shepherd_activitytype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_activitytype ALTER COLUMN id SET DEFAULT nextval('public.shepherd_activitytype_id_seq'::regclass);


--
-- Name: shepherd_auxserveraddress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_auxserveraddress ALTER COLUMN id SET DEFAULT nextval('public.shepherd_auxserveraddress_id_seq'::regclass);


--
-- Name: shepherd_domain id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain ALTER COLUMN id SET DEFAULT nextval('public.shepherd_domain_id_seq'::regclass);


--
-- Name: shepherd_domainnote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainnote ALTER COLUMN id SET DEFAULT nextval('public.shepherd_domainnote_id_seq'::regclass);


--
-- Name: shepherd_domainserverconnection id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection ALTER COLUMN id SET DEFAULT nextval('public.shepherd_domainserverconnection_id_seq'::regclass);


--
-- Name: shepherd_domainstatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainstatus ALTER COLUMN id SET DEFAULT nextval('public.shepherd_domainstatus_id_seq'::regclass);


--
-- Name: shepherd_healthstatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_healthstatus ALTER COLUMN id SET DEFAULT nextval('public.shepherd_healthstatus_id_seq'::regclass);


--
-- Name: shepherd_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history ALTER COLUMN id SET DEFAULT nextval('public.shepherd_history_id_seq'::regclass);


--
-- Name: shepherd_serverhistory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory ALTER COLUMN id SET DEFAULT nextval('public.shepherd_serverhistory_id_seq'::regclass);


--
-- Name: shepherd_servernote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_servernote ALTER COLUMN id SET DEFAULT nextval('public.shepherd_servernote_id_seq'::regclass);


--
-- Name: shepherd_serverprovider id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverprovider ALTER COLUMN id SET DEFAULT nextval('public.shepherd_serverprovider_id_seq'::regclass);


--
-- Name: shepherd_serverrole id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverrole ALTER COLUMN id SET DEFAULT nextval('public.shepherd_serverrole_id_seq'::regclass);


--
-- Name: shepherd_serverstatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverstatus ALTER COLUMN id SET DEFAULT nextval('public.shepherd_serverstatus_id_seq'::regclass);


--
-- Name: shepherd_staticserver id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver ALTER COLUMN id SET DEFAULT nextval('public.shepherd_staticserver_id_seq'::regclass);


--
-- Name: shepherd_transientserver id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver ALTER COLUMN id SET DEFAULT nextval('public.shepherd_transientserver_id_seq'::regclass);


--
-- Name: shepherd_whoisstatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_whoisstatus ALTER COLUMN id SET DEFAULT nextval('public.shepherd_whoisstatus_id_seq'::regclass);


--
-- Name: socialaccount_socialaccount id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialaccount ALTER COLUMN id SET DEFAULT nextval('public.socialaccount_socialaccount_id_seq'::regclass);


--
-- Name: socialaccount_socialapp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp ALTER COLUMN id SET DEFAULT nextval('public.socialaccount_socialapp_id_seq'::regclass);


--
-- Name: socialaccount_socialapp_sites id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp_sites ALTER COLUMN id SET DEFAULT nextval('public.socialaccount_socialapp_sites_id_seq'::regclass);


--
-- Name: socialaccount_socialtoken id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialtoken ALTER COLUMN id SET DEFAULT nextval('public.socialaccount_socialtoken_id_seq'::regclass);


--
-- Name: users_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user ALTER COLUMN id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: users_user_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups ALTER COLUMN id SET DEFAULT nextval('public.users_user_groups_id_seq'::regclass);


--
-- Name: users_user_user_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.users_user_user_permissions_id_seq'::regclass);


--
-- Data for Name: event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: event_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.event_log (id, schema_name, table_name, trigger_name, payload, delivered, error, tries, created_at, locked, next_retry_at, archived) FROM stdin;
\.


--
-- Data for Name: hdb_action_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_action_log (id, action_name, input_payload, request_headers, session_variables, response_payload, errors, created_at, response_received_at, status) FROM stdin;
\.


--
-- Data for Name: hdb_cron_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_cron_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_cron_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_cron_events (id, trigger_name, scheduled_time, status, tries, created_at, next_retry_at) FROM stdin;
\.


--
-- Data for Name: hdb_metadata; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_metadata (id, metadata, resource_version) FROM stdin;
1	{"custom_types":{"objects":[{"name":"LoginResponse","fields":[{"name":"token","type":"String!"},{"name":"expires","type":"date"}]},{"name":"WhoamiOutput","fields":[{"name":"username","type":"String!"},{"name":"role","type":"String!"},{"name":"expires","type":"date"}]},{"name":"ReportResponse","fields":[{"name":"reportData","type":"String!"},{"name":"docxUrl","type":"String!"},{"name":"xlsxUrl","type":"String!"},{"name":"pptxUrl","type":"String!"}]},{"name":"checkoutResponse","fields":[{"name":"result","type":"String!"}]},{"name":"deleteResponse","fields":[{"name":"result","type":"String!"}]}]},"actions":[{"definition":{"kind":"synchronous","output_type":"checkoutResponse","arguments":[{"name":"domainId","type":"Int!"},{"name":"projectId","type":"Int!"},{"name":"startDate","type":"date!"},{"name":"endDate","type":"date!"},{"name":"activityTypeId","type":"Int!"},{"name":"note","type":"String"}],"headers":[{"name":"Hasura-Action-Secret","value_from_env":"HASURA_ACTION_SECRET"}],"handler":"{{ACTIONS_URL_BASE}}/checkoutDomain","type":"mutation","forward_client_headers":true},"name":"checkoutDomain","permissions":[{"role":"user"},{"role":"manager"}],"comment":"Attempt to checkout a domain for a project"},{"definition":{"kind":"synchronous","output_type":"checkoutResponse","arguments":[{"name":"serverId","type":"Int!"},{"name":"projectId","type":"Int!"},{"name":"startDate","type":"date!"},{"name":"endDate","type":"date!"},{"name":"activityTypeId","type":"Int!"},{"name":"serverRoleId","type":"Int!"},{"name":"note","type":"String"}],"headers":[{"name":"Hasura-Action-Secret","value_from_env":"HASURA_ACTION_SECRET"}],"handler":"{{ACTIONS_URL_BASE}}/checkoutServer","type":"mutation","forward_client_headers":true},"name":"checkoutServer","permissions":[{"role":"user"},{"role":"manager"}],"comment":"Attempt to checkout a server for a project"},{"definition":{"kind":"synchronous","output_type":"checkoutResponse","arguments":[{"name":"checkoutId","type":"Int!"}],"headers":[{"name":"Hasura-Action-Secret","value_from_env":"HASURA_ACTION_SECRET"}],"handler":"{{ACTIONS_URL_BASE}}/deleteDomainCheckout","type":"mutation","forward_client_headers":true},"name":"deleteDomainCheckout","permissions":[{"role":"user"},{"role":"manager"}],"comment":"Delete the specified domain checkout and release the domain if deleted entry was the latest checkout"},{"definition":{"kind":"synchronous","output_type":"deleteResponse","arguments":[{"name":"evidenceId","type":"Int!"}],"headers":[{"name":"Hasura-Action-Secret","value_from_env":"HASURA_ACTION_SECRET"}],"handler":"{{ACTIONS_URL_BASE}}/deleteEvidence","type":"mutation","forward_client_headers":true},"name":"deleteEvidence","permissions":[{"role":"user"},{"role":"manager"}],"comment":"Delete the specified evidence file and remove the associated file from the filesystem"},{"definition":{"kind":"synchronous","output_type":"checkoutResponse","arguments":[{"name":"checkoutId","type":"Int!"}],"headers":[{"name":"Hasura-Action-Secret","value_from_env":"HASURA_ACTION_SECRET"}],"handler":"{{ACTIONS_URL_BASE}}/deleteServerCheckout","type":"mutation","forward_client_headers":true},"name":"deleteServerCheckout","permissions":[{"role":"user"},{"role":"manager"}],"comment":"Delete the specified server checkout and release the server if deleted entry was the latest checkout"},{"definition":{"kind":"synchronous","output_type":"deleteResponse","arguments":[{"name":"templateId","type":"Int!"}],"headers":[{"name":"Hasura-Action-Secret","value_from_env":"HASURA_ACTION_SECRET"}],"handler":"{{ACTIONS_URL_BASE}}/deleteTemplate","type":"mutation","forward_client_headers":true},"name":"deleteTemplate","permissions":[{"role":"user"},{"role":"manager"}],"comment":"Delete the specified template file and remove the associated file from the filesystem"},{"definition":{"kind":"synchronous","output_type":"ReportResponse","arguments":[{"name":"id","type":"Int!"}],"headers":[{"name":"Hasura-Action-Secret","value_from_env":"HASURA_ACTION_SECRET"}],"handler":"{{ACTIONS_URL_BASE}}/generateReport","type":"mutation","forward_client_headers":true},"name":"generateReport","permissions":[{"role":"user"},{"role":"manager"}],"comment":"Generate a JSON report for the given report ID"},{"definition":{"kind":"synchronous","output_type":"LoginResponse","arguments":[{"name":"username","type":"String!"},{"name":"password","type":"String!"}],"headers":[{"name":"Hasura-Action-Secret","value_from_env":"HASURA_ACTION_SECRET"}],"handler":"{{ACTIONS_URL_BASE}}/login","type":"mutation"},"name":"login","permissions":[{"role":"manager"},{"role":"restricted"},{"role":"user"},{"role":"public"}]},{"definition":{"output_type":"WhoamiOutput","headers":[{"name":"Hasura-Action-Secret","value_from_env":"HASURA_ACTION_SECRET"}],"handler":"{{ACTIONS_URL_BASE}}/whoami","type":"query","forward_client_headers":true},"name":"whoami","permissions":[{"role":"user"},{"role":"restricted"},{"role":"manager"}],"comment":"User `whoami` query for JWT"}],"network":{"tls_allowlist":[{"suffix":null,"permissions":null,"host":"host.docker.internal"}]},"sources":[{"kind":"postgres","name":"default","tables":[{"configuration":{"custom_root_fields":{},"custom_name":"group","column_config":{},"custom_column_names":{}},"table":{"schema":"public","name":"auth_group"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"group_id","table":{"schema":"public","name":"auth_group_permissions"}}},"name":"groupPermissions"},{"using":{"foreign_key_constraint_on":{"column":"group_id","table":{"schema":"public","name":"users_user_groups"}}},"name":"users"}]},{"object_relationships":[{"using":{"foreign_key_constraint_on":"group_id"},"name":"authGroup"},{"using":{"foreign_key_constraint_on":"permission_id"},"name":"authPermission"}],"configuration":{"custom_root_fields":{},"custom_name":"groupPermission","column_config":{"permission_id":{"custom_name":"permissionId"},"group_id":{"custom_name":"groupId"}},"custom_column_names":{"permission_id":"permissionId","group_id":"groupId"}},"table":{"schema":"public","name":"auth_group_permissions"}},{"object_relationships":[{"using":{"foreign_key_constraint_on":"content_type_id"},"name":"djangoContentType"}],"configuration":{"custom_root_fields":{},"custom_name":"authPermission","column_config":{"content_type_id":{"custom_name":"contentTypeId"}},"custom_column_names":{"content_type_id":"contentTypeId"}},"table":{"schema":"public","name":"auth_permission"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"permission_id","table":{"schema":"public","name":"auth_group_permissions"}}},"name":"authGroupPermissions"},{"using":{"foreign_key_constraint_on":{"column":"permission_id","table":{"schema":"public","name":"users_user_user_permissions"}}},"name":"userPermissions"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["company_email","company_name","company_twitter","id"],"filter":{}}},{"role":"restricted","permission":{"columns":["company_email","company_name","company_twitter","id"],"filter":{}}},{"role":"user","permission":{"columns":["company_email","company_name","company_twitter","id"],"filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"companyInfo","column_config":{"company_name":{"custom_name":"name"},"company_email":{"custom_name":"email"},"company_twitter":{"custom_name":"twitter"}},"custom_column_names":{"company_name":"name","company_email":"email","company_twitter":"twitter"}},"table":{"schema":"public","name":"commandcenter_companyinformation"},"update_permissions":[{"role":"manager","permission":{"check":null,"columns":["company_email","company_name","company_twitter"],"filter":{}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["border_color","border_weight","default_docx_template_id","default_pptx_template_id","enable_borders","id","label_figure","label_table","prefix_figure","prefix_table"],"filter":{}}},{"role":"restricted","permission":{"columns":["border_color","border_weight","default_docx_template_id","default_pptx_template_id","enable_borders","id","label_figure","label_table","prefix_figure","prefix_table"],"filter":{}}},{"role":"user","permission":{"columns":["border_color","border_weight","default_docx_template_id","default_pptx_template_id","enable_borders","id","label_figure","label_table","prefix_figure","prefix_table"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"default_docx_template_id"},"name":"docxTemplate"},{"using":{"foreign_key_constraint_on":"default_pptx_template_id"},"name":"pptxTemplate"}],"configuration":{"custom_root_fields":{},"custom_name":"reportConfiguration","column_config":{"label_table":{"custom_name":"labelTable"},"prefix_figure":{"custom_name":"prefixFigure"},"label_figure":{"custom_name":"labelFigure"},"border_weight":{"custom_name":"borderWeight"},"border_color":{"custom_name":"borderColor"},"prefix_table":{"custom_name":"prefixTable"},"default_docx_template_id":{"custom_name":"docxTemplateId"},"enable_borders":{"custom_name":"enableBorders"},"default_pptx_template_id":{"custom_name":"pptxTemplateId"}},"custom_column_names":{"label_table":"labelTable","prefix_figure":"prefixFigure","label_figure":"labelFigure","border_weight":"borderWeight","border_color":"borderColor","prefix_table":"prefixTable","default_docx_template_id":"docxTemplateId","enable_borders":"enableBorders","default_pptx_template_id":"pptxTemplateId"}},"table":{"schema":"public","name":"commandcenter_reportconfiguration"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["border_color","border_weight","default_docx_template_id","default_pptx_template_id","enable_borders","label_figure","label_table","prefix_figure","prefix_table"],"filter":{}}}]},{"configuration":{"custom_root_fields":{},"custom_name":"djangoContentType","column_config":{"app_label":{"custom_name":"appLabel"}},"custom_column_names":{"app_label":"appLabel"}},"table":{"schema":"public","name":"django_content_type"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"content_type_id","table":{"schema":"public","name":"auth_permission"}}},"name":"authPermissions"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["success","func","group","hook","id","name","attempt_count","args","kwargs","result","started","stopped"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"insert_permissions":[{"role":"manager","permission":{"backend_only":true,"check":{},"columns":["args","attempt_count","func","group","hook","kwargs"]}},{"role":"restricted","permission":{"backend_only":true,"check":{},"columns":["args","attempt_count","func","group","hook","kwargs"]}},{"role":"user","permission":{"backend_only":true,"check":{},"columns":["args","attempt_count","func","group","hook","kwargs"]}}],"configuration":{"custom_root_fields":{},"custom_name":"task","column_config":{},"custom_column_names":{}},"table":{"schema":"public","name":"django_q_task"}},{"select_permissions":[{"role":"manager","permission":{"columns":["avatar","user_id"],"filter":{}}},{"role":"restricted","permission":{"columns":["avatar","user_id"],"filter":{}}},{"role":"user","permission":{"columns":["avatar","user_id"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"user_id"},"name":"user"}],"configuration":{"custom_root_fields":{},"custom_name":"userProfile","column_config":{"user_id":{"custom_name":"userId"}},"custom_column_names":{"user_id":"userId"}},"table":{"schema":"public","name":"home_userprofile"},"update_permissions":[{"role":"manager","permission":{"check":{"user_id":{"_eq":"X-Hasura-User-Id"}},"columns":["avatar"],"filter":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"check":{"user_id":{"_eq":"X-Hasura-User-Id"}},"columns":["avatar"],"filter":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"user","permission":{"check":{"user_id":{"_eq":"X-Hasura-User-Id"}},"columns":["avatar"],"filter":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["name","id","project_id"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["name","project_id"]}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["name","project_id"]}},{"role":"user","permission":{"check":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["name","project_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"oplog","column_config":{"project_id":{"custom_name":"projectId"}},"custom_column_names":{"project_id":"projectId"}},"table":{"schema":"public","name":"oplog_oplog"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["name","project_id"],"filter":{}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["name","project_id"],"filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["name","project_id"],"filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"oplog_id_id","table":{"schema":"public","name":"oplog_oplogentry"}}},"name":"entries"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","oplog_id_id","operator_name","command","comments","description","dest_ip","output","source_ip","tool","user_context","end_date","start_date"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"log":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}},{"role":"user","permission":{"columns":"*","filter":{"log":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"oplog_id_id"},"name":"log"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["command","comments","description","dest_ip","end_date","operator_name","oplog_id_id","output","source_ip","start_date","tool","user_context"]}},{"role":"restricted","permission":{"set":{"operator_name":"x-hasura-User-Name"},"check":{"log":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["command","comments","description","dest_ip","end_date","oplog_id_id","output","source_ip","start_date","tool","user_context"]}},{"role":"user","permission":{"set":{"operator_name":"x-hasura-User-Name"},"check":{"log":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["command","comments","description","dest_ip","end_date","oplog_id_id","output","source_ip","start_date","tool","user_context"]}}],"configuration":{"custom_root_fields":{},"custom_name":"oplogEntry","column_config":{"end_date":{"custom_name":"endDate"},"operator_name":{"custom_name":"operatorName"},"dest_ip":{"custom_name":"destIp"},"start_date":{"custom_name":"startDate"},"user_context":{"custom_name":"userContext"},"oplog_id_id":{"custom_name":"oplog"},"source_ip":{"custom_name":"sourceIp"}},"custom_column_names":{"end_date":"endDate","operator_name":"operatorName","dest_ip":"destIp","start_date":"startDate","user_context":"userContext","oplog_id_id":"oplog","source_ip":"sourceIp"}},"table":{"schema":"public","name":"oplog_oplogentry"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["command","comments","description","dest_ip","end_date","operator_name","oplog_id_id","output","source_ip","start_date","tool","user_context"],"filter":{}}},{"role":"restricted","permission":{"check":{"log":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["command","comments","description","dest_ip","end_date","oplog_id_id","output","source_ip","start_date","tool","user_context"],"filter":{"log":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}},{"role":"user","permission":{"check":{"log":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["command","comments","description","dest_ip","end_date","oplog_id_id","output","source_ip","start_date","tool","user_context"],"filter":{"log":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"log":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}},{"role":"user","permission":{"filter":{"log":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["report_archive","id","project_id"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"}],"configuration":{"custom_root_fields":{},"custom_name":"archive","column_config":{"report_archive":{"custom_name":"reportArchive"},"project_id":{"custom_name":"projectId"}},"custom_column_names":{"report_archive":"reportArchive","project_id":"projectId"}},"table":{"schema":"public","name":"reporting_archive"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["project_id","report_archive"],"filter":{}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["project_id","report_archive"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["project_id","report_archive"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","doc_type"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"docType","column_config":{"doc_type":{"custom_name":"docType"}},"custom_column_names":{"doc_type":"docType"}},"table":{"schema":"public","name":"reporting_doctype"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"doc_type_id","table":{"schema":"public","name":"reporting_reporttemplate"}}},"name":"templates"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["caption","description","document","finding_id","friendly_name","id","upload_date","uploaded_by_id"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"finding":{"report":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}},{"role":"user","permission":{"columns":"*","filter":{"finding":{"report":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"finding_id"},"name":"finding"},{"using":{"foreign_key_constraint_on":"uploaded_by_id"},"name":"user"}],"configuration":{"custom_root_fields":{},"custom_name":"evidence","column_config":{"friendly_name":{"custom_name":"friendlyName"},"upload_date":{"custom_name":"uploadDate"},"uploaded_by_id":{"custom_name":"uploadedById"},"finding_id":{"custom_name":"findingId"}},"custom_column_names":{"friendly_name":"friendlyName","upload_date":"uploadDate","uploaded_by_id":"uploadedById","finding_id":"findingId"}},"table":{"schema":"public","name":"reporting_evidence"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["caption","description","finding_id","friendly_name"],"filter":{}}},{"role":"restricted","permission":{"check":{"finding":{"report":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},"columns":["caption","description","finding_id","friendly_name"],"filter":{"finding":{"report":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}},{"role":"user","permission":{"check":{"finding":{"report":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},"columns":["caption","description","finding_id","friendly_name"],"filter":{"finding":{"report":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["finding_type_id","id","severity_id","cvss_vector","title","cvss_score","description","finding_guidance","host_detection_techniques","impact","mitigation","network_detection_techniques","references","replication_steps"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"severity_id"},"name":"severity"},{"using":{"foreign_key_constraint_on":"finding_type_id"},"name":"type"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["cvss_score","cvss_vector","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","references","replication_steps","severity_id","title"]}},{"role":"restricted","permission":{"check":{},"columns":["description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","references","replication_steps","severity_id","title"]}},{"role":"user","permission":{"check":{},"columns":["cvss_score","cvss_vector","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","references","replication_steps","severity_id","title"]}}],"configuration":{"custom_root_fields":{},"custom_name":"finding","column_config":{"finding_guidance":{"custom_name":"findingGuidance"},"host_detection_techniques":{"custom_name":"hostDetectionTechniques"},"finding_type_id":{"custom_name":"findingTypeId"},"network_detection_techniques":{"custom_name":"networkDetectionTechniques"},"severity_id":{"custom_name":"severityId"}},"custom_column_names":{"finding_guidance":"findingGuidance","host_detection_techniques":"hostDetectionTechniques","finding_type_id":"findingTypeId","network_detection_techniques":"networkDetectionTechniques","severity_id":"severityId"}},"table":{"schema":"public","name":"reporting_finding"},"update_permissions":[{"role":"manager","permission":{"check":null,"columns":["cvss_score","cvss_vector","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","references","replication_steps","severity_id","title"],"filter":{}}},{"role":"restricted","permission":{"check":{},"columns":["cvss_score","cvss_vector","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","references","replication_steps","severity_id","title"],"filter":{}}},{"role":"user","permission":{"check":{},"columns":["cvss_score","cvss_vector","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","references","replication_steps","severity_id","title"],"filter":{}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{}}},{"role":"user","permission":{"filter":{}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"finding_id","table":{"schema":"public","name":"reporting_findingnote"}}},"name":"comments"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["finding_id","id","operator_id","timestamp","note"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"finding_id"},"name":"finding"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["finding_id","note"]}},{"role":"restricted","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["finding_id","note"]}},{"role":"user","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["finding_id","note"]}}],"configuration":{"custom_root_fields":{},"custom_name":"findingNote","column_config":{"operator_id":{"custom_name":"operatorId"},"finding_id":{"custom_name":"findingId"}},"custom_column_names":{"operator_id":"operatorId","finding_id":"findingId"}},"table":{"schema":"public","name":"reporting_findingnote"},"update_permissions":[{"role":"manager","permission":{"check":{"note":{"_neq":"\\"\\""}},"columns":["finding_id","note"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"operator_id":{"_eq":"X-Hasura-User-Id"}},"columns":["finding_id","note"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"user","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"operator_id":{"_eq":"X-Hasura-User-Id"}},"columns":["finding_id","note"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"user","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["finding_type","id"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"findingType","column_config":{"finding_type":{"custom_name":"findingType"}},"custom_column_names":{"finding_type":"findingType"}},"table":{"schema":"public","name":"reporting_findingtype"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"finding_type_id","table":{"schema":"public","name":"reporting_finding"}}},"name":"findings"},{"using":{"foreign_key_constraint_on":{"column":"finding_type_id","table":{"schema":"public","name":"reporting_reportfindinglink"}}},"name":"reportedFindings"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["finding_id","id","operator_id","timestamp","note"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"_or":[{"finding":{"report":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]}}},{"role":"user","permission":{"columns":"*","filter":{"_or":[{"finding":{"report":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"finding_id"},"name":"finding"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["finding_id","note"]}},{"role":"restricted","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"_or":[{"finding":{"report":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]},"columns":["finding_id","note"]}},{"role":"user","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"_or":[{"finding":{"report":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]},"columns":["finding_id","note"]}}],"configuration":{"custom_root_fields":{},"custom_name":"reportedFindingNote","column_config":{"operator_id":{"custom_name":"operatorId"},"finding_id":{"custom_name":"findingId"}},"custom_column_names":{"operator_id":"operatorId","finding_id":"findingId"}},"table":{"schema":"public","name":"reporting_localfindingnote"},"update_permissions":[{"role":"manager","permission":{"check":{"note":{"_neq":"\\"\\""}},"columns":["finding_id","note"],"filter":{"user":{"id":{"_eq":"X-Hasura-User-Id"}}}}},{"role":"restricted","permission":{"check":{"_or":[{"finding":{"report":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]},"columns":["finding_id","note"],"filter":{"_or":[{"finding":{"report":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]}}},{"role":"user","permission":{"check":{"_or":[{"finding":{"report":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]},"columns":["finding_id","note"],"filter":{"_or":[{"finding":{"report":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{"user":{"id":{"_eq":"X-Hasura-User-Id"}}}}},{"role":"restricted","permission":{"filter":{"_or":[{"finding":{"report":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]}}},{"role":"user","permission":{"filter":{"_or":[{"finding":{"report":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","title","creation","last_update","complete","archived","created_by_id","project_id","delivered","docx_template_id","pptx_template_id"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"docx_template_id"},"name":"docxTemplate"},{"using":{"foreign_key_constraint_on":"pptx_template_id"},"name":"pptxTemplate"},{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"},{"using":{"foreign_key_constraint_on":"created_by_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"created_by_id":"x-hasura-User-Id"},"check":{},"columns":["docx_template_id","pptx_template_id","project_id","title"]}},{"role":"restricted","permission":{"set":{"created_by_id":"x-hasura-User-Id"},"check":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["docx_template_id","pptx_template_id","project_id","title"]}},{"role":"user","permission":{"set":{"created_by_id":"x-hasura-User-Id"},"check":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["docx_template_id","pptx_template_id","project_id","title"]}}],"configuration":{"custom_root_fields":{},"custom_name":"report","column_config":{"docx_template_id":{"custom_name":"docxTemplateId"},"created_by_id":{"custom_name":"createdById"},"project_id":{"custom_name":"projectId"},"pptx_template_id":{"custom_name":"pptxTemplateId"}},"custom_column_names":{"docx_template_id":"docxTemplateId","created_by_id":"createdById","project_id":"projectId","pptx_template_id":"pptxTemplateId"}},"table":{"schema":"public","name":"reporting_report"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["archived","complete","delivered","docx_template_id","pptx_template_id","project_id","title"],"filter":{}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["complete","delivered","docx_template_id","pptx_template_id","project_id","title"],"filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["complete","delivered","docx_template_id","pptx_template_id","project_id","title"],"filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"filter":{"project":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"report_id","table":{"schema":"public","name":"reporting_reportfindinglink"}}},"name":"findings"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["assigned_to_id","finding_type_id","id","report_id","severity_id","complete","cvss_vector","title","cvss_score","position","affected_entities","description","finding_guidance","host_detection_techniques","impact","mitigation","network_detection_techniques","references","replication_steps"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"report":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}},{"role":"user","permission":{"columns":["assigned_to_id","finding_type_id","id","report_id","severity_id","complete","cvss_vector","title","cvss_score","position","affected_entities","description","finding_guidance","host_detection_techniques","impact","mitigation","network_detection_techniques","references","replication_steps"],"filter":{"report":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"finding_type_id"},"name":"findingtype"},{"using":{"foreign_key_constraint_on":"report_id"},"name":"report"},{"using":{"foreign_key_constraint_on":"severity_id"},"name":"severity"},{"using":{"foreign_key_constraint_on":"assigned_to_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"assigned_to_id":"x-hasura-User-Id"},"check":{},"columns":["affected_entities","assigned_to_id","cvss_score","cvss_vector","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","position","references","replication_steps","report_id","severity_id","title"]}},{"role":"restricted","permission":{"set":{"assigned_to_id":"x-hasura-User-Id"},"check":{"report":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["affected_entities","assigned_to_id","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","position","references","replication_steps","report_id","severity_id","title"]}},{"role":"user","permission":{"set":{"assigned_to_id":"x-hasura-User-Id"},"check":{"report":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["affected_entities","assigned_to_id","cvss_score","cvss_vector","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","position","references","replication_steps","report_id","severity_id","title"]}}],"configuration":{"custom_root_fields":{},"custom_name":"reportedFinding","column_config":{"finding_guidance":{"custom_name":"findingGuidance"},"host_detection_techniques":{"custom_name":"hostDetectionTechniques"},"assigned_to_id":{"custom_name":"assignedToId"},"report_id":{"custom_name":"reportId"},"affected_entities":{"custom_name":"affectedEntities"},"finding_type_id":{"custom_name":"findingTypeId"},"network_detection_techniques":{"custom_name":"networkDetectionTechniques"},"severity_id":{"custom_name":"severityId"}},"custom_column_names":{"finding_guidance":"findingGuidance","host_detection_techniques":"hostDetectionTechniques","assigned_to_id":"assignedToId","report_id":"reportId","affected_entities":"affectedEntities","finding_type_id":"findingTypeId","network_detection_techniques":"networkDetectionTechniques","severity_id":"severityId"}},"table":{"schema":"public","name":"reporting_reportfindinglink"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["affected_entities","assigned_to_id","complete","cvss_score","cvss_vector","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","position","references","replication_steps","report_id","severity_id","title"],"filter":{}}},{"role":"restricted","permission":{"check":{"report":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["affected_entities","assigned_to_id","complete","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","position","references","replication_steps","report_id","severity_id","title"],"filter":{"report":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}},{"role":"user","permission":{"check":{"report":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["affected_entities","assigned_to_id","complete","cvss_score","cvss_vector","description","finding_guidance","finding_type_id","host_detection_techniques","impact","mitigation","network_detection_techniques","position","references","replication_steps","report_id","severity_id","title"],"filter":{"report":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"report":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}},{"role":"user","permission":{"filter":{"report":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"finding_id","table":{"schema":"public","name":"reporting_localfindingnote"}}},"name":"comments"},{"using":{"foreign_key_constraint_on":{"column":"finding_id","table":{"schema":"public","name":"reporting_evidence"}}},"name":"evidences"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["protected","document","name","last_update","upload_date","client_id","doc_type_id","id","uploaded_by_id","changelog","description","lint_result"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"_or":[{"client_id":{"_is_null":true}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"client":{"projects":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}}]}}},{"role":"user","permission":{"columns":"*","filter":{"_or":[{"client_id":{"_is_null":true}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"client":{"projects":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}}]}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"client_id"},"name":"client"},{"using":{"foreign_key_constraint_on":"doc_type_id"},"name":"reporting_doctype"},{"using":{"foreign_key_constraint_on":"uploaded_by_id"},"name":"user"}],"configuration":{"custom_root_fields":{},"custom_name":"template","column_config":{"upload_date":{"custom_name":"uploadDate"},"client_id":{"custom_name":"clientId"},"last_update":{"custom_name":"lastUpdate"},"uploaded_by_id":{"custom_name":"uploadedById"},"doc_type_id":{"custom_name":"docTypeId"},"lint_result":{"custom_name":"lintResult"}},"custom_column_names":{"upload_date":"uploadDate","client_id":"clientId","last_update":"lastUpdate","uploaded_by_id":"uploadedById","doc_type_id":"docTypeId","lint_result":"lintResult"}},"table":{"schema":"public","name":"reporting_reporttemplate"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["changelog","client_id","description","doc_type_id","name","protected"],"filter":{}}},{"role":"restricted","permission":{"check":{"_and":[{"protected":{"_eq":false}},{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}]},"columns":["changelog","client_id","description","doc_type_id","name","protected"],"filter":{"_and":[{"protected":{"_eq":false}},{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}]}}},{"role":"user","permission":{"check":{"_and":[{"protected":{"_eq":false}},{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}]},"columns":["changelog","client_id","description","doc_type_id","name","protected"],"filter":{"_and":[{"protected":{"_eq":false}},{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}]}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"default_pptx_template_id","table":{"schema":"public","name":"commandcenter_reportconfiguration"}}},"name":"commandcenterReportconfigurationsByDefaultPptxTemplateId"},{"using":{"foreign_key_constraint_on":{"column":"default_docx_template_id","table":{"schema":"public","name":"commandcenter_reportconfiguration"}}},"name":"commandcenter_reportconfigurations"},{"using":{"foreign_key_constraint_on":{"column":"docx_template_id","table":{"schema":"public","name":"reporting_report"}}},"name":"docxTemplates"},{"using":{"foreign_key_constraint_on":{"column":"pptx_template_id","table":{"schema":"public","name":"reporting_report"}}},"name":"pptxTemplates"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","severity","weight","color"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"findingSeverity","column_config":{},"custom_column_names":{}},"table":{"schema":"public","name":"reporting_severity"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"severity_id","table":{"schema":"public","name":"reporting_finding"}}},"name":"findings"},{"using":{"foreign_key_constraint_on":{"column":"severity_id","table":{"schema":"public","name":"reporting_reportfindinglink"}}},"name":"reportedFindings"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","name","short_name","codename","note","address","timezone"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}},{"role":"user","permission":{"columns":"*","filter":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["address","codename","name","note","short_name","timezone"]}},{"role":"restricted","permission":{"check":{"_and":[{"_exists":{"_where":{"_and":[{"user_id":{"_eq":"X-Hasura-User-Id"}},{"authGroup":{"groupPermissions":{"authPermission":{"codename":{"_eq":"add_clientcontact"}}}}}]},"_table":{"schema":"public","name":"users_user_groups"}}}]},"columns":[]}},{"role":"user","permission":{"check":{"_and":[{"_exists":{"_where":{"_and":[{"user_id":{"_eq":"X-Hasura-User-Id"}},{"authGroup":{"groupPermissions":{"authPermission":{"codename":{"_eq":"add_clientcontact"}}}}}]},"_table":{"schema":"public","name":"users_user_groups"}}}]},"columns":[]}}],"configuration":{"custom_root_fields":{},"custom_name":"client","column_config":{"short_name":{"custom_name":"shortName"}},"custom_column_names":{"short_name":"shortName"}},"table":{"schema":"public","name":"rolodex_client"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["address","codename","name","note","short_name","timezone"],"filter":{}}},{"role":"restricted","permission":{"check":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]},"columns":["address","codename","name","note","short_name","timezone"],"filter":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}},{"role":"user","permission":{"check":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]},"columns":["address","codename","name","note","short_name","timezone"],"filter":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"client_id","table":{"schema":"public","name":"rolodex_clientnote"}}},"name":"comments"},{"using":{"foreign_key_constraint_on":{"column":"client_id","table":{"schema":"public","name":"rolodex_clientcontact"}}},"name":"contacts"},{"using":{"foreign_key_constraint_on":{"column":"client_id","table":{"schema":"public","name":"shepherd_history"}}},"name":"domains"},{"using":{"foreign_key_constraint_on":{"column":"client_id","table":{"schema":"public","name":"rolodex_clientinvite"}}},"name":"invites"},{"using":{"foreign_key_constraint_on":{"column":"client_id","table":{"schema":"public","name":"rolodex_project"}}},"name":"projects"},{"using":{"foreign_key_constraint_on":{"column":"client_id","table":{"schema":"public","name":"shepherd_serverhistory"}}},"name":"servers"},{"using":{"foreign_key_constraint_on":{"column":"client_id","table":{"schema":"public","name":"reporting_reporttemplate"}}},"name":"templates"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["email","job_title","name","phone","timezone","client_id","id","note"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"client_id"},"name":"client"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["client_id","email","job_title","name","note","phone","timezone"]}},{"role":"restricted","permission":{"check":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}},"columns":["client_id","email","job_title","name","note","phone","timezone"]}},{"role":"user","permission":{"check":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}},"columns":["client_id","email","job_title","name","note","phone","timezone"]}}],"configuration":{"custom_root_fields":{},"custom_name":"contacts","column_config":{"job_title":{"custom_name":"jobTitle"},"client_id":{"custom_name":"clientId"}},"custom_column_names":{"job_title":"jobTitle","client_id":"clientId"}},"table":{"schema":"public","name":"rolodex_clientcontact"},"update_permissions":[{"role":"manager","permission":{"check":null,"columns":["client_id","email","job_title","name","note","phone","timezone"],"filter":{}}},{"role":"restricted","permission":{"check":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}},"columns":["client_id","email","job_title","name","note","phone","timezone"],"filter":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}}},{"role":"user","permission":{"check":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}},"columns":["client_id","email","job_title","name","note","phone","timezone"],"filter":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}}},{"role":"user","permission":{"filter":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["client_id","comment","id","user_id"],"filter":{}}},{"role":"restricted","permission":{"columns":["client_id","id","user_id","comment"],"filter":{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}}},{"role":"user","permission":{"columns":["client_id","id","user_id","comment"],"filter":{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"client_id"},"name":"client"},{"using":{"foreign_key_constraint_on":"user_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["client_id","comment","user_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"clientInvite","column_config":{"client_id":{"custom_name":"clientId"},"user_id":{"custom_name":"userId"}},"custom_column_names":{"client_id":"clientId","user_id":"userId"}},"table":{"schema":"public","name":"rolodex_clientinvite"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["client_id","comment","user_id"],"filter":{}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}}],"array_relationships":[{"using":{"manual_configuration":{"remote_table":{"schema":"public","name":"rolodex_project"},"insertion_order":null,"column_mapping":{"client_id":"client_id"}}},"name":"projects"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["client_id","id","operator_id","timestamp","note"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"client_id"},"name":"client"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["client_id","note"]}},{"role":"restricted","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}},"columns":["client_id","note"]}},{"role":"user","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}},"columns":["client_id","note"]}}],"configuration":{"custom_root_fields":{},"custom_name":"clientNote","column_config":{"operator_id":{"custom_name":"operatorId"},"client_id":{"custom_name":"clientId"}},"custom_column_names":{"operator_id":"operatorId","client_id":"clientId"}},"table":{"schema":"public","name":"rolodex_clientnote"},"update_permissions":[{"role":"manager","permission":{"check":{"_and":[{"operator_id":{"_eq":"X-Hasura-User-Id"}},{"note":{"_neq":"\\"\\""}}]},"columns":["client_id","note"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"check":{"_and":[{"operator_id":{"_eq":"X-Hasura-User-Id"}},{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}]},"columns":["client_id","note"],"filter":{"_and":[{"operator_id":{"_eq":"X-Hasura-User-Id"}},{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}]}}},{"role":"user","permission":{"check":{"_and":[{"operator_id":{"_eq":"X-Hasura-User-Id"}},{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}]},"columns":["client_id","note"],"filter":{"_and":[{"operator_id":{"_eq":"X-Hasura-User-Id"}},{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}]}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"filter":{"_and":[{"operator_id":{"_eq":"X-Hasura-User-Id"}},{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}]}}},{"role":"user","permission":{"filter":{"_and":[{"operator_id":{"_eq":"X-Hasura-User-Id"}},{"client":{"_or":[{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"projects":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}]}}]}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","weight","priority"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"objectivePriority","column_config":{},"custom_column_names":{}},"table":{"schema":"public","name":"rolodex_objectivepriority"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"priority_id","table":{"schema":"public","name":"rolodex_projectobjective"}}},"name":"objectives"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","objective_status"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"objectiveStatus","column_config":{"objective_status":{"custom_name":"objectiveStatus"}},"custom_column_names":{"objective_status":"objectiveStatus"}},"table":{"schema":"public","name":"rolodex_objectivestatus"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"status_id","table":{"schema":"public","name":"rolodex_projectsubtask"}}},"name":"objectiveSubTasks"},{"using":{"foreign_key_constraint_on":{"column":"status_id","table":{"schema":"public","name":"rolodex_projectobjective"}}},"name":"objectives"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["client_id","codename","complete","end_date","end_time","id","note","operator_id","project_type_id","slack_channel","start_date","start_time","timezone"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}},{"role":"user","permission":{"columns":"*","filter":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"client_id"},"name":"client"},{"using":{"foreign_key_constraint_on":"project_type_id"},"name":"projectType"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["client_id","codename","end_date","end_time","note","project_type_id","slack_channel","start_date","start_time","timezone"]}},{"role":"restricted","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},"columns":["client_id","codename","end_date","end_time","note","project_type_id","slack_channel","start_date","start_time","timezone"]}},{"role":"user","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},"columns":["client_id","codename","end_date","end_time","note","project_type_id","slack_channel","start_date","start_time","timezone"]}}],"configuration":{"custom_root_fields":{},"custom_name":"project","column_config":{"end_date":{"custom_name":"endDate"},"operator_id":{"custom_name":"operatorId"},"start_date":{"custom_name":"startDate"},"client_id":{"custom_name":"clientId"},"start_time":{"custom_name":"startTime"},"slack_channel":{"custom_name":"slackChannel"},"end_time":{"custom_name":"endTime"},"project_type_id":{"custom_name":"projectTypeId"}},"custom_column_names":{"end_date":"endDate","operator_id":"operatorId","start_date":"startDate","client_id":"clientId","start_time":"startTime","slack_channel":"slackChannel","end_time":"endTime","project_type_id":"projectTypeId"}},"table":{"schema":"public","name":"rolodex_project"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["client_id","codename","complete","end_date","end_time","note","project_type_id","slack_channel","start_date","start_time","timezone"],"filter":{}}},{"role":"restricted","permission":{"check":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]},"columns":["client_id","codename","complete","end_date","end_time","note","project_type_id","slack_channel","start_date","start_time","timezone"],"filter":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}},{"role":"user","permission":{"check":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]},"columns":["client_id","codename","complete","end_date","end_time","note","project_type_id","slack_channel","start_date","start_time","timezone"],"filter":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"reporting_archive"}}},"name":"archives"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"rolodex_projectassignment"}}},"name":"assignments"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"shepherd_transientserver"}}},"name":"cloudServers"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"rolodex_projectnote"}}},"name":"comments"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"shepherd_domainserverconnection"}}},"name":"domainServerConnections"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"shepherd_history"}}},"name":"domains"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"rolodex_projectinvite"}}},"name":"invites"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"rolodex_projectobjective"}}},"name":"objectives"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"oplog_oplog"}}},"name":"oplogs"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"reporting_report"}}},"name":"reports"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"rolodex_projectscope"}}},"name":"scopes"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"shepherd_serverhistory"}}},"name":"staticServers"},{"using":{"foreign_key_constraint_on":{"column":"project_id","table":{"schema":"public","name":"rolodex_projecttarget"}}},"name":"targets"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","operator_id","project_id","role_id","end_date","start_date","note"],"filter":{}}},{"role":"restricted","permission":{"columns":["end_date","id","note","operator_id","project_id","role_id","start_date"],"filter":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}}},{"role":"user","permission":{"columns":["end_date","id","note","operator_id","project_id","role_id","start_date"],"filter":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"},{"using":{"foreign_key_constraint_on":"role_id"},"name":"projectRole"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["end_date","note","operator_id","project_id","role_id","start_date"]}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}},"columns":["end_date","note","operator_id","project_id","role_id","start_date"]}},{"role":"user","permission":{"check":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}},"columns":["end_date","note","operator_id","project_id","role_id","start_date"]}}],"configuration":{"custom_root_fields":{},"custom_name":"projectAssignment","column_config":{"end_date":{"custom_name":"endDate"},"operator_id":{"custom_name":"operatorId"},"start_date":{"custom_name":"startDate"},"role_id":{"custom_name":"roleId"},"project_id":{"custom_name":"projectId"}},"custom_column_names":{"end_date":"endDate","operator_id":"operatorId","start_date":"startDate","role_id":"roleId","project_id":"projectId"}},"table":{"schema":"public","name":"rolodex_projectassignment"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["end_date","note","operator_id","project_id","role_id","start_date"],"filter":{}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}},"columns":["end_date","note","operator_id","project_id","role_id","start_date"],"filter":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}},"columns":["end_date","note","operator_id","project_id","role_id","start_date"],"filter":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}}},{"role":"user","permission":{"filter":{"project":{"_or":[{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}},{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","project_id","user_id","comment"],"filter":{}}},{"role":"restricted","permission":{"columns":["id","project_id","user_id","comment"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}}},{"role":"user","permission":{"columns":["id","project_id","user_id","comment"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"},{"using":{"foreign_key_constraint_on":"user_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["comment","project_id","user_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"projectInvite","column_config":{"project_id":{"custom_name":"projectId"},"user_id":{"custom_name":"userId"}},"custom_column_names":{"project_id":"projectId","user_id":"userId"}},"table":{"schema":"public","name":"rolodex_projectinvite"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["comment","project_id","user_id"],"filter":{}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}}],"array_relationships":[{"using":{"manual_configuration":{"remote_table":{"schema":"public","name":"rolodex_projectassignment"},"insertion_order":null,"column_mapping":{"project_id":"project_id"}}},"name":"assignments"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","operator_id","project_id","timestamp","note"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["note","project_id"]}},{"role":"restricted","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["note","project_id"]}},{"role":"user","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["note","project_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"projectNote","column_config":{"operator_id":{"custom_name":"operatorId"},"project_id":{"custom_name":"projectId"}},"custom_column_names":{"operator_id":"operatorId","project_id":"projectId"}},"table":{"schema":"public","name":"rolodex_projectnote"},"update_permissions":[{"role":"manager","permission":{"check":{"note":{"_neq":"\\"\\""}},"columns":["note","project_id"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"check":{"_and":[{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},{"operator_id":{"_eq":"X-Hasura-User-Id"}}]},"columns":["note","project_id"],"filter":{"_and":[{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},{"operator_id":{"_eq":"X-Hasura-User-Id"}}]}}},{"role":"user","permission":{"check":{"_and":[{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},{"operator_id":{"_eq":"X-Hasura-User-Id"}}]},"columns":["note","project_id"],"filter":{"_and":[{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},{"operator_id":{"_eq":"X-Hasura-User-Id"}}]}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"filter":{"_and":[{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},{"operator_id":{"_eq":"X-Hasura-User-Id"}}]}}},{"role":"user","permission":{"filter":{"_and":[{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},{"operator_id":{"_eq":"X-Hasura-User-Id"}}]}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","priority_id","project_id","status_id","complete","objective","deadline","marked_complete","position","description"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"priority_id"},"name":"objectivePriority"},{"using":{"foreign_key_constraint_on":"status_id"},"name":"objectiveStatus"},{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["deadline","description","objective","position","priority_id","project_id","status_id"]}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["deadline","description","objective","position","priority_id","project_id","status_id"]}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["deadline","description","objective","position","priority_id","project_id","status_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"objective","column_config":{"priority_id":{"custom_name":"priorityId"},"project_id":{"custom_name":"projectId"},"marked_complete":{"custom_name":"markedComplete"},"status_id":{"custom_name":"statusId"}},"custom_column_names":{"priority_id":"priorityId","project_id":"projectId","marked_complete":"markedComplete","status_id":"statusId"}},"table":{"schema":"public","name":"rolodex_projectobjective"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["complete","deadline","description","objective","position","priority_id","project_id","status_id"],"filter":{}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["complete","deadline","description","objective","position","priority_id","project_id","status_id"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["complete","deadline","description","objective","position","priority_id","project_id","status_id"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"parent_id","table":{"schema":"public","name":"rolodex_projectsubtask"}}},"name":"objectiveSubTasks"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","project_role"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"projectRole","column_config":{"project_role":{"custom_name":"projectRole"}},"custom_column_names":{"project_role":"projectRole"}},"table":{"schema":"public","name":"rolodex_projectrole"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"role_id","table":{"schema":"public","name":"rolodex_projectassignment"}}},"name":"assignments"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","project_id","disallowed","requires_caution","name","description","scope"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["description","disallowed","name","project_id","requires_caution","scope"]}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["description","disallowed","name","project_id","requires_caution","scope"]}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["description","disallowed","name","project_id","requires_caution","scope"]}}],"configuration":{"custom_root_fields":{},"custom_name":"scope","column_config":{"requires_caution":{"custom_name":"requiresCaution"},"project_id":{"custom_name":"projectId"}},"custom_column_names":{"requires_caution":"requiresCaution","project_id":"projectId"}},"table":{"schema":"public","name":"rolodex_projectscope"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["description","disallowed","name","project_id","requires_caution","scope"],"filter":{}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["description","disallowed","name","project_id","requires_caution","scope"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["description","disallowed","name","project_id","requires_caution","scope"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["complete","deadline","id","parent_id","status_id","task"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"objective":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}},{"role":"user","permission":{"columns":"*","filter":{"objective":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"parent_id"},"name":"objective"},{"using":{"foreign_key_constraint_on":"status_id"},"name":"objectiveStatus"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["deadline","parent_id","status_id","task"]}},{"role":"restricted","permission":{"check":{"objective":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["deadline","parent_id","status_id","task"]}},{"role":"user","permission":{"check":{"objective":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["deadline","parent_id","status_id","task"]}}],"configuration":{"custom_root_fields":{},"custom_name":"objectiveSubTask","column_config":{"marked_complete":{"custom_name":"markedComplete"},"status_id":{"custom_name":"statusId"},"parent_id":{"custom_name":"parentId"}},"custom_column_names":{"marked_complete":"markedComplete","status_id":"statusId","parent_id":"parentId"}},"table":{"schema":"public","name":"rolodex_projectsubtask"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["complete","deadline","parent_id","status_id","task"],"filter":{}}},{"role":"restricted","permission":{"check":{"objective":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["complete","deadline","parent_id","status_id","task"],"filter":{"objective":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}},{"role":"user","permission":{"check":{"objective":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}},"columns":["complete","deadline","parent_id","status_id","task"],"filter":{"objective":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"objective":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}},{"role":"user","permission":{"filter":{"objective":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","project_id","compromised","hostname","ip_address","note"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["compromised","hostname","ip_address","note","project_id"]}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["compromised","hostname","ip_address","note","project_id"]}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["compromised","hostname","ip_address","note","project_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"target","column_config":{"project_id":{"custom_name":"projectId"},"ip_address":{"custom_name":"ipAddress"}},"custom_column_names":{"project_id":"projectId","ip_address":"ipAddress"}},"table":{"schema":"public","name":"rolodex_projecttarget"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["compromised","hostname","ip_address","note","project_id"],"filter":{}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["compromised","hostname","ip_address","note","project_id"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["compromised","hostname","ip_address","note","project_id"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","project_type"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"projectType","column_config":{"project_type":{"custom_name":"projectType"}},"custom_column_names":{"project_type":"projectType"}},"table":{"schema":"public","name":"rolodex_projecttype"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"project_type_id","table":{"schema":"public","name":"rolodex_project"}}},"name":"projects"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["activity","id"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"activityType","column_config":{},"custom_column_names":{}},"table":{"schema":"public","name":"shepherd_activitytype"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"activity_type_id","table":{"schema":"public","name":"shepherd_transientserver"}}},"name":"cloudServers"},{"using":{"foreign_key_constraint_on":{"column":"activity_type_id","table":{"schema":"public","name":"shepherd_history"}}},"name":"domains"},{"using":{"foreign_key_constraint_on":{"column":"activity_type_id","table":{"schema":"public","name":"shepherd_serverhistory"}}},"name":"staticServers"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["ip_address","primary","static_server_id"],"filter":{}}},{"role":"restricted","permission":{"columns":["id","ip_address","primary","static_server_id"],"filter":{}}},{"role":"user","permission":{"columns":["id","ip_address","primary","static_server_id"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"static_server_id"},"name":"server"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["ip_address","primary","static_server_id"]}},{"role":"restricted","permission":{"check":{},"columns":["ip_address","primary","static_server_id"]}},{"role":"user","permission":{"check":{},"columns":["ip_address","primary","static_server_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"auxServerAddresses","column_config":{"static_server_id":{"custom_name":"staticServerId"},"ip_address":{"custom_name":"ipAddress"}},"custom_column_names":{"static_server_id":"staticServerId","ip_address":"ipAddress"}},"table":{"schema":"public","name":"shepherd_auxserveraddress"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["ip_address","primary","static_server_id"],"filter":{}}},{"role":"restricted","permission":{"check":{},"columns":["ip_address","primary","static_server_id"],"filter":{}}},{"role":"user","permission":{"check":{},"columns":["ip_address","primary","static_server_id"],"filter":{}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{}}},{"role":"user","permission":{"filter":{}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["domain_status_id","health_status_id","id","last_used_by_id","whois_status_id","auto_renew","expired","reset_dns","name","registrar","vt_permalink","creation","expiration","last_health_check","categorization","dns","burned_explanation","note"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"domain_status_id"},"name":"domainStatus"},{"using":{"foreign_key_constraint_on":"health_status_id"},"name":"healthStatus"},{"using":{"foreign_key_constraint_on":"last_used_by_id"},"name":"user"},{"using":{"foreign_key_constraint_on":"whois_status_id"},"name":"whoisStatus"}],"event_triggers":[{"definition":{"enable_manual":true,"insert":{"columns":"*"},"update":{"columns":["name"]}},"headers":[{"name":"Hasura-Action-Secret","value_from_env":"HASURA_ACTION_SECRET"}],"name":"CleanDomainName","retry_conf":{"num_retries":0,"interval_sec":10,"timeout_sec":60},"webhook":"{{ACTIONS_URL_BASE}}/event/domain/update"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["auto_renew","categorization","creation","dns","domain_status_id","expiration","expired","health_status_id","name","note","registrar","reset_dns","vt_permalink","whois_status_id"]}},{"role":"restricted","permission":{"check":{},"columns":["auto_renew","burned_explanation","categorization","creation","dns","domain_status_id","expiration","expired","health_status_id","last_health_check","name","note","registrar","reset_dns","vt_permalink","whois_status_id"]}},{"role":"user","permission":{"check":{},"columns":["auto_renew","burned_explanation","categorization","creation","dns","domain_status_id","expiration","expired","health_status_id","last_health_check","name","note","registrar","reset_dns","vt_permalink","whois_status_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"domain","column_config":{"last_health_check":{"custom_name":"lastHealthCheck"},"auto_renew":{"custom_name":"autoRenew"},"reset_dns":{"custom_name":"resetDns"},"vt_permalink":{"custom_name":"vtPermalink"},"domain_status_id":{"custom_name":"domainStatusId"},"last_used_by_id":{"custom_name":"lastUsedById"},"health_status_id":{"custom_name":"healthStatusId"},"whois_status_id":{"custom_name":"whoisStatusId"}},"custom_column_names":{"last_health_check":"lastHealthCheck","auto_renew":"autoRenew","reset_dns":"resetDns","vt_permalink":"vtPermalink","domain_status_id":"domainStatusId","last_used_by_id":"lastUsedById","health_status_id":"healthStatusId","whois_status_id":"whoisStatusId"}},"table":{"schema":"public","name":"shepherd_domain"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["auto_renew","burned_explanation","categorization","creation","dns","domain_status_id","expiration","expired","health_status_id","name","note","registrar","reset_dns","vt_permalink","whois_status_id"],"filter":{}}},{"role":"restricted","permission":{"check":{},"columns":["auto_renew","burned_explanation","categorization","creation","dns","domain_status_id","expiration","expired","health_status_id","name","note","registrar","reset_dns","vt_permalink","whois_status_id"],"filter":{}}},{"role":"user","permission":{"check":{},"columns":["auto_renew","burned_explanation","categorization","creation","dns","domain_status_id","expiration","expired","health_status_id","name","note","registrar","reset_dns","vt_permalink","whois_status_id"],"filter":{}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"domain_id","table":{"schema":"public","name":"shepherd_history"}}},"name":"checkouts"},{"using":{"foreign_key_constraint_on":{"column":"domain_id","table":{"schema":"public","name":"shepherd_domainnote"}}},"name":"comments"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["domain_id","id","operator_id","timestamp","note"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"domain_id"},"name":"domain"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["domain_id","note"]}},{"role":"restricted","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["domain_id","note"]}},{"role":"user","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["domain_id","note"]}}],"configuration":{"custom_root_fields":{},"custom_name":"domainNote","column_config":{"domain_id":{"custom_name":"domainId"},"operator_id":{"custom_name":"operatorId"}},"custom_column_names":{"domain_id":"domainId","operator_id":"operatorId"}},"table":{"schema":"public","name":"shepherd_domainnote"},"update_permissions":[{"role":"manager","permission":{"check":{"note":{"_neq":"\\"\\""}},"columns":["domain_id","note"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"check":{"operator_id":{"_eq":"X-Hasura-User-Id"}},"columns":["domain_id","note"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"user","permission":{"check":{"operator_id":{"_eq":"X-Hasura-User-Id"}},"columns":["domain_id","note"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"user","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["domain_id","id","project_id","static_server_id","transient_server_id","endpoint","subdomain"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"transient_server_id"},"name":"cloudServer"},{"using":{"foreign_key_constraint_on":"domain_id"},"name":"domain"},{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"},{"using":{"foreign_key_constraint_on":"static_server_id"},"name":"staticServer"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["domain_id","endpoint","project_id","static_server_id","subdomain","transient_server_id"]}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["domain_id","endpoint","project_id","static_server_id","subdomain","transient_server_id"]}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["domain_id","endpoint","project_id","static_server_id","subdomain","transient_server_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"domainServerConnection","column_config":{"domain_id":{"custom_name":"domainId"},"static_server_id":{"custom_name":"staticServerId"},"transient_server_id":{"custom_name":"transientServerId"},"project_id":{"custom_name":"projectId"}},"custom_column_names":{"domain_id":"domainId","static_server_id":"staticServerId","transient_server_id":"transientServerId","project_id":"projectId"}},"table":{"schema":"public","name":"shepherd_domainserverconnection"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["domain_id","endpoint","project_id","static_server_id","subdomain","transient_server_id"],"filter":{}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["domain_id","endpoint","project_id","static_server_id","subdomain","transient_server_id"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["domain_id","endpoint","project_id","static_server_id","subdomain","transient_server_id"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["domain_status","id"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"domainStatus","column_config":{"domain_status":{"custom_name":"domainStatus"}},"custom_column_names":{"domain_status":"domainStatus"}},"table":{"schema":"public","name":"shepherd_domainstatus"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"domain_status_id","table":{"schema":"public","name":"shepherd_domain"}}},"name":"domains"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["health_status","id"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"healthStatus","column_config":{"health_status":{"custom_name":"healthStatus"}},"custom_column_names":{"health_status":"healthStatus"}},"table":{"schema":"public","name":"shepherd_healthstatus"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"health_status_id","table":{"schema":"public","name":"shepherd_domain"}}},"name":"domains"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["activity_type_id","client_id","domain_id","end_date","id","note","operator_id","project_id","start_date"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"activity_type_id"},"name":"activityType"},{"using":{"foreign_key_constraint_on":"client_id"},"name":"client"},{"using":{"foreign_key_constraint_on":"domain_id"},"name":"domain"},{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"configuration":{"custom_root_fields":{},"custom_name":"domainCheckout","column_config":{"end_date":{"custom_name":"endDate"},"domain_id":{"custom_name":"domainId"},"operator_id":{"custom_name":"operatorId"},"activity_type_id":{"custom_name":"activityTypeId"},"start_date":{"custom_name":"startDate"},"client_id":{"custom_name":"clientId"},"project_id":{"custom_name":"projectId"}},"custom_column_names":{"end_date":"endDate","domain_id":"domainId","operator_id":"operatorId","activity_type_id":"activityTypeId","start_date":"startDate","client_id":"clientId","project_id":"projectId"}},"table":{"schema":"public","name":"shepherd_history"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["activity_type_id","client_id","domain_id","end_date","note","project_id","start_date"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["activity_type_id","client_id","domain_id","end_date","note","project_id","start_date"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["activity_type_id","client_id","domain_id","end_date","note","project_id","start_date"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"domain_id","table":{"schema":"public","name":"shepherd_domainserverconnection"}}},"name":"domainServerConnections"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["activity_type_id","client_id","id","operator_id","project_id","server_id","server_role_id","end_date","start_date","note"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"activity_type_id"},"name":"activityType"},{"using":{"foreign_key_constraint_on":"client_id"},"name":"client"},{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"},{"using":{"foreign_key_constraint_on":"server_id"},"name":"server"},{"using":{"foreign_key_constraint_on":"server_role_id"},"name":"serverRole"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["activity_type_id","client_id","end_date","note","project_id","server_id","server_role_id","start_date"]}},{"role":"restricted","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["activity_type_id","client_id","end_date","note","project_id","server_id","server_role_id","start_date"]}},{"role":"user","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["activity_type_id","client_id","end_date","note","project_id","server_id","server_role_id","start_date"]}}],"configuration":{"custom_root_fields":{},"custom_name":"serverCheckout","column_config":{"server_role_id":{"custom_name":"serverRoleId"},"end_date":{"custom_name":"endDate"},"server_id":{"custom_name":"serverId"},"operator_id":{"custom_name":"operatorId"},"activity_type_id":{"custom_name":"activityTypeId"},"start_date":{"custom_name":"startDate"},"client_id":{"custom_name":"clientId"},"project_id":{"custom_name":"projectId"}},"custom_column_names":{"server_role_id":"serverRoleId","end_date":"endDate","server_id":"serverId","operator_id":"operatorId","activity_type_id":"activityTypeId","start_date":"startDate","client_id":"clientId","project_id":"projectId"}},"table":{"schema":"public","name":"shepherd_serverhistory"},"update_permissions":[{"role":"manager","permission":{"check":null,"columns":["activity_type_id","client_id","end_date","note","project_id","server_id","server_role_id","start_date"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["activity_type_id","client_id","end_date","note","project_id","server_id","server_role_id","start_date"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["activity_type_id","client_id","end_date","note","project_id","server_id","server_role_id","start_date"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"static_server_id","table":{"schema":"public","name":"shepherd_domainserverconnection"}}},"name":"domainServerConnections"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","note","operator_id","server_id","timestamp"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"server_id"},"name":"staticServer"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["note","server_id"]}},{"role":"restricted","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["note","server_id"]}},{"role":"user","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["note","server_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"serverNote","column_config":{"server_id":{"custom_name":"serverId"},"operator_id":{"custom_name":"operatorId"}},"custom_column_names":{"server_id":"serverId","operator_id":"operatorId"}},"table":{"schema":"public","name":"shepherd_servernote"},"update_permissions":[{"role":"manager","permission":{"check":{"note":{"_neq":"\\"\\""}},"columns":["note","server_id"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"check":{"operator_id":{"_eq":"X-Hasura-User-Id"}},"columns":["note","server_id"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"user","permission":{"check":{"operator_id":{"_eq":"X-Hasura-User-Id"}},"columns":["note","server_id"],"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"user","permission":{"filter":{"operator_id":{"_eq":"X-Hasura-User-Id"}}}}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","server_provider"],"filter":{}}},{"role":"restricted","permission":{"columns":["id","server_provider"],"filter":{}}},{"role":"user","permission":{"columns":["id","server_provider"],"filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"serverProvider","column_config":{"server_provider":{"custom_name":"serverProvider"}},"custom_column_names":{"server_provider":"serverProvider"}},"table":{"schema":"public","name":"shepherd_serverprovider"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"server_provider_id","table":{"schema":"public","name":"shepherd_transientserver"}}},"name":"cloudServers"},{"using":{"foreign_key_constraint_on":{"column":"server_provider_id","table":{"schema":"public","name":"shepherd_staticserver"}}},"name":"staticServers"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","server_role"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"serverRole","column_config":{"server_role":{"custom_name":"serverRole"}},"custom_column_names":{"server_role":"serverRole"}},"table":{"schema":"public","name":"shepherd_serverrole"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"server_role_id","table":{"schema":"public","name":"shepherd_transientserver"}}},"name":"cloudServers"},{"using":{"foreign_key_constraint_on":{"column":"server_role_id","table":{"schema":"public","name":"shepherd_serverhistory"}}},"name":"staticServers"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","server_status"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"serverStatus","column_config":{"server_status":{"custom_name":"serverStatus"}},"custom_column_names":{"server_status":"serverStatus"}},"table":{"schema":"public","name":"shepherd_serverstatus"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"server_status_id","table":{"schema":"public","name":"shepherd_staticserver"}}},"name":"servers"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","ip_address","last_used_by_id","name","note","server_provider_id","server_status_id"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"server_provider_id"},"name":"serverProvider"},{"using":{"foreign_key_constraint_on":"server_status_id"},"name":"serverStatus"},{"using":{"foreign_key_constraint_on":"last_used_by_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"check":{},"columns":["ip_address","name","note","server_provider_id","server_status_id"]}},{"role":"restricted","permission":{"check":{},"columns":["ip_address","name","note","server_provider_id","server_status_id"]}},{"role":"user","permission":{"check":{},"columns":["ip_address","name","note","server_provider_id","server_status_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"staticServer","column_config":{"last_used_by_id":{"custom_name":"lastUsedById"},"server_status_id":{"custom_name":"serverStatusId"},"ip_address":{"custom_name":"ipAddress"},"server_provider_id":{"custom_name":"serverProviderId"}},"custom_column_names":{"last_used_by_id":"lastUsedById","server_status_id":"serverStatusId","ip_address":"ipAddress","server_provider_id":"serverProviderId"}},"table":{"schema":"public","name":"shepherd_staticserver"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["ip_address","name","note","server_provider_id","server_status_id"],"filter":{}}},{"role":"restricted","permission":{"check":{},"columns":["ip_address","name","note","server_provider_id","server_status_id"],"filter":{}}},{"role":"user","permission":{"check":{},"columns":["ip_address","name","note","server_provider_id","server_status_id"],"filter":{}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{}}},{"role":"user","permission":{"filter":{}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"static_server_id","table":{"schema":"public","name":"shepherd_auxserveraddress"}}},"name":"auxServerAddresses"},{"using":{"foreign_key_constraint_on":{"column":"server_id","table":{"schema":"public","name":"shepherd_serverhistory"}}},"name":"checkouts"},{"using":{"foreign_key_constraint_on":{"column":"server_id","table":{"schema":"public","name":"shepherd_servernote"}}},"name":"comments"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["aux_address","activity_type_id","id","operator_id","project_id","server_provider_id","server_role_id","name","ip_address","note"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"columns":"*","filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"activity_type_id"},"name":"activityType"},{"using":{"foreign_key_constraint_on":"project_id"},"name":"project"},{"using":{"foreign_key_constraint_on":"server_provider_id"},"name":"serverProvider"},{"using":{"foreign_key_constraint_on":"server_role_id"},"name":"serverRole"},{"using":{"foreign_key_constraint_on":"operator_id"},"name":"user"}],"insert_permissions":[{"role":"manager","permission":{"backend_only":false,"set":{"operator_id":"x-hasura-User-Id"},"check":{},"columns":["activity_type_id","aux_address","ip_address","name","note","project_id","server_provider_id","server_role_id"]}},{"role":"restricted","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["activity_type_id","aux_address","ip_address","name","note","project_id","server_provider_id","server_role_id"]}},{"role":"user","permission":{"set":{"operator_id":"x-hasura-User-Id"},"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["activity_type_id","aux_address","ip_address","name","note","project_id","server_provider_id","server_role_id"]}}],"configuration":{"custom_root_fields":{},"custom_name":"cloudServer","column_config":{"server_role_id":{"custom_name":"serverRoleId"},"operator_id":{"custom_name":"operatorId"},"aux_address":{"custom_name":"auxAddress"},"activity_type_id":{"custom_name":"activityTypeId"},"project_id":{"custom_name":"projectId"},"ip_address":{"custom_name":"ipAddress"},"server_provider_id":{"custom_name":"serverProviderId"}},"custom_column_names":{"server_role_id":"serverRoleId","operator_id":"operatorId","aux_address":"auxAddress","activity_type_id":"activityTypeId","project_id":"projectId","ip_address":"ipAddress","server_provider_id":"serverProviderId"}},"table":{"schema":"public","name":"shepherd_transientserver"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["activity_type_id","aux_address","ip_address","name","note","project_id","server_provider_id","server_role_id"],"filter":{}}},{"role":"restricted","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["activity_type_id","aux_address","ip_address","name","note","project_id","server_provider_id","server_role_id"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"check":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"columns":["activity_type_id","aux_address","ip_address","name","note","project_id","server_provider_id","server_role_id"],"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"delete_permissions":[{"role":"manager","permission":{"filter":{}}},{"role":"restricted","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}},{"role":"user","permission":{"filter":{"project":{"_or":[{"assignments":{"operator_id":{"_eq":"X-Hasura-User-Id"}}},{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"client":{"invites":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"transient_server_id","table":{"schema":"public","name":"shepherd_domainserverconnection"}}},"name":"domainServerConnections"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["id","whois_status"],"filter":{}}},{"role":"restricted","permission":{"columns":"*","filter":{}}},{"role":"user","permission":{"columns":"*","filter":{}}}],"configuration":{"custom_root_fields":{},"custom_name":"whoisStatus","column_config":{"whois_status":{"custom_name":"whoisStatus"}},"custom_column_names":{"whois_status":"whoisStatus"}},"table":{"schema":"public","name":"shepherd_whoisstatus"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"whois_status_id","table":{"schema":"public","name":"shepherd_domain"}}},"name":"domains"}]},{"select_permissions":[{"role":"manager","permission":{"columns":["email","id","is_active","name","phone","role","timezone","username"],"filter":{}}},{"role":"restricted","permission":{"columns":["email","id","is_active","name","phone","role","timezone","username"],"filter":{"_and":[{"_exists":{"_where":{"_and":[{"user_id":{"_eq":"X-Hasura-User-Id"}},{"authGroup":{"groupPermissions":{"authPermission":{"codename":{"_eq":"view_user"}}}}}]},"_table":{"schema":"public","name":"users_user_groups"}}}]}}},{"role":"user","permission":{"columns":["email","id","is_active","name","phone","role","timezone","username"],"filter":{"_and":[{"_exists":{"_where":{"_and":[{"user_id":{"_eq":"X-Hasura-User-Id"}},{"authGroup":{"groupPermissions":{"authPermission":{"codename":{"_eq":"view_user"}}}}}]},"_table":{"schema":"public","name":"users_user_groups"}}}]}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":{"column":"user_id","table":{"schema":"public","name":"home_userprofile"}}},"name":"profile"}],"configuration":{"custom_root_fields":{},"custom_name":"user","column_config":{"is_superuser":{"custom_name":"isSuperuser"},"date_joined":{"custom_name":"dateJoined"},"is_staff":{"custom_name":"isStaff"},"last_login":{"custom_name":"lastLogin"},"is_active":{"custom_name":"isActive"}},"custom_column_names":{"is_superuser":"isSuperuser","date_joined":"dateJoined","is_staff":"isStaff","last_login":"lastLogin","is_active":"isActive"}},"table":{"schema":"public","name":"users_user"},"update_permissions":[{"role":"manager","permission":{"check":{},"columns":["email","name","phone","timezone","username"],"filter":{"id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"restricted","permission":{"check":{"id":{"_eq":"X-Hasura-User-Id"}},"columns":["email","name","phone","timezone"],"filter":{"id":{"_eq":"X-Hasura-User-Id"}}}},{"role":"user","permission":{"check":{"id":{"_eq":"X-Hasura-User-Id"}},"columns":["email","name","phone","timezone"],"filter":{"id":{"_eq":"X-Hasura-User-Id"}}}}],"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"rolodex_projectassignment"}}},"name":"assignments"},{"using":{"foreign_key_constraint_on":{"column":"user_id","table":{"schema":"public","name":"rolodex_clientinvite"}}},"name":"clientInvites"},{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"rolodex_clientnote"}}},"name":"clientNotes"},{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"shepherd_transientserver"}}},"name":"cloudServers"},{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"shepherd_history"}}},"name":"domainCheckouts"},{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"shepherd_domainnote"}}},"name":"domainNotes"},{"using":{"foreign_key_constraint_on":{"column":"last_used_by_id","table":{"schema":"public","name":"shepherd_domain"}}},"name":"domains"},{"using":{"foreign_key_constraint_on":{"column":"uploaded_by_id","table":{"schema":"public","name":"reporting_evidence"}}},"name":"evidences"},{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"reporting_findingnote"}}},"name":"findingNotes"},{"using":{"manual_configuration":{"remote_table":{"schema":"public","name":"users_user_groups"},"insertion_order":null,"column_mapping":{"id":"user_id"}}},"name":"groups"},{"using":{"foreign_key_constraint_on":{"column":"user_id","table":{"schema":"public","name":"rolodex_projectinvite"}}},"name":"projectInvites"},{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"rolodex_projectnote"}}},"name":"projectNotes"},{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"rolodex_project"}}},"name":"projects"},{"using":{"foreign_key_constraint_on":{"column":"uploaded_by_id","table":{"schema":"public","name":"reporting_reporttemplate"}}},"name":"reportTemplates"},{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"reporting_localfindingnote"}}},"name":"reportedFindingNotes"},{"using":{"foreign_key_constraint_on":{"column":"assigned_to_id","table":{"schema":"public","name":"reporting_reportfindinglink"}}},"name":"reportedFindings"},{"using":{"foreign_key_constraint_on":{"column":"created_by_id","table":{"schema":"public","name":"reporting_report"}}},"name":"reports"},{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"shepherd_serverhistory"}}},"name":"serverCheckouts"},{"using":{"foreign_key_constraint_on":{"column":"operator_id","table":{"schema":"public","name":"shepherd_servernote"}}},"name":"serverNotes"},{"using":{"foreign_key_constraint_on":{"column":"last_used_by_id","table":{"schema":"public","name":"shepherd_staticserver"}}},"name":"servers"}]},{"object_relationships":[{"using":{"foreign_key_constraint_on":"group_id"},"name":"authGroup"}],"configuration":{"custom_root_fields":{},"custom_name":"userGroup","column_config":{"group_id":{"custom_name":"groupId"},"user_id":{"custom_name":"userId"}},"custom_column_names":{"group_id":"groupId","user_id":"userId"}},"table":{"schema":"public","name":"users_user_groups"}},{"object_relationships":[{"using":{"foreign_key_constraint_on":"permission_id"},"name":"authPermission"}],"configuration":{"custom_root_fields":{},"custom_name":"userPermission","column_config":{"permission_id":{"custom_name":"permissionId"}},"custom_column_names":{"permission_id":"permissionId"}},"table":{"schema":"public","name":"users_user_user_permissions"}}],"configuration":{"connection_info":{"use_prepared_statements":true,"database_url":{"from_env":"HASURA_GRAPHQL_DATABASE_URL"},"isolation_level":"read-committed","pool_settings":{"connection_lifetime":600,"retries":1,"idle_timeout":180,"max_connections":50}}}}],"version":3}	11
\.


--
-- Data for Name: hdb_scheduled_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_scheduled_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_scheduled_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_scheduled_events (id, webhook_conf, scheduled_time, retry_conf, payload, header_conf, status, tries, created_at, next_retry_at, comment) FROM stdin;
\.


--
-- Data for Name: hdb_schema_notifications; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_schema_notifications (id, notification, resource_version, instance_id, updated_at) FROM stdin;
1	{"metadata":false,"remote_schemas":[],"sources":[]}	11	4b421f01-f866-4698-93c6-731261940d34	2022-07-11 19:59:08.235377+00
\.


--
-- Data for Name: hdb_source_catalog_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_source_catalog_version (version, upgraded_on) FROM stdin;
2	2022-07-11 19:59:07.99426+00
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state) FROM stdin;
2f22ecfe-ea58-43f1-b01d-fb6bb5094fa4	47	2022-07-11 19:59:01.169425+00	{}	{}
\.


--
-- Data for Name: account_emailaddress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_emailaddress (id, email, verified, "primary", user_id) FROM stdin;
\.


--
-- Data for Name: account_emailconfirmation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_emailconfirmation (id, created, sent, key, email_address_id) FROM stdin;
\.


--
-- Data for Name: api_apikey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_apikey (id, name, token, created, expiry_date, revoked, user_id) FROM stdin;
\.


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add permission	1	add_permission
2	Can change permission	1	change_permission
3	Can delete permission	1	delete_permission
4	Can view permission	1	view_permission
5	Can add group	2	add_group
6	Can change group	2	change_group
7	Can delete group	2	delete_group
8	Can view group	2	view_group
9	Can add content type	3	add_contenttype
10	Can change content type	3	change_contenttype
11	Can delete content type	3	delete_contenttype
12	Can view content type	3	view_contenttype
13	Can add session	4	add_session
14	Can change session	4	change_session
15	Can delete session	4	delete_session
16	Can view session	4	view_session
17	Can add site	5	add_site
18	Can change site	5	change_site
19	Can delete site	5	delete_site
20	Can view site	5	view_site
21	Can add log entry	6	add_logentry
22	Can change log entry	6	change_logentry
23	Can delete log entry	6	delete_logentry
24	Can view log entry	6	view_logentry
25	Can add email address	7	add_emailaddress
26	Can change email address	7	change_emailaddress
27	Can delete email address	7	delete_emailaddress
28	Can view email address	7	view_emailaddress
29	Can add email confirmation	8	add_emailconfirmation
30	Can change email confirmation	8	change_emailconfirmation
31	Can delete email confirmation	8	delete_emailconfirmation
32	Can view email confirmation	8	view_emailconfirmation
33	Can add social account	9	add_socialaccount
34	Can change social account	9	change_socialaccount
35	Can delete social account	9	delete_socialaccount
36	Can view social account	9	view_socialaccount
37	Can add social application	10	add_socialapp
38	Can change social application	10	change_socialapp
39	Can delete social application	10	delete_socialapp
40	Can view social application	10	view_socialapp
41	Can add social application token	11	add_socialtoken
42	Can change social application token	11	change_socialtoken
43	Can delete social application token	11	delete_socialtoken
44	Can view social application token	11	view_socialtoken
45	Can add API key	12	add_apikey
46	Can change API key	12	change_apikey
47	Can delete API key	12	delete_apikey
48	Can view API key	12	view_apikey
49	Can add Scheduled task	13	add_schedule
50	Can change Scheduled task	13	change_schedule
51	Can delete Scheduled task	13	delete_schedule
52	Can view Scheduled task	13	view_schedule
53	Can add task	14	add_task
54	Can change task	14	change_task
55	Can delete task	14	delete_task
56	Can view task	14	view_task
57	Can add Failed task	15	add_failure
58	Can change Failed task	15	change_failure
59	Can delete Failed task	15	delete_failure
60	Can view Failed task	15	view_failure
61	Can add Successful task	16	add_success
62	Can change Successful task	16	change_success
63	Can delete Successful task	16	delete_success
64	Can view Successful task	16	view_success
65	Can add Queued task	17	add_ormq
66	Can change Queued task	17	change_ormq
67	Can delete Queued task	17	delete_ormq
68	Can view Queued task	17	view_ormq
69	Can add user	18	add_user
70	Can change user	18	change_user
71	Can delete user	18	delete_user
72	Can view user	18	view_user
73	Can add User profile	19	add_userprofile
74	Can change User profile	19	change_userprofile
75	Can delete User profile	19	delete_userprofile
76	Can view User profile	19	view_userprofile
77	Can add Client	20	add_client
78	Can change Client	20	change_client
79	Can delete Client	20	delete_client
80	Can view Client	20	view_client
81	Can add Project	21	add_project
82	Can change Project	21	change_project
83	Can delete Project	21	delete_project
84	Can view Project	21	view_project
85	Can add Project role	22	add_projectrole
86	Can change Project role	22	change_projectrole
87	Can delete Project role	22	delete_projectrole
88	Can view Project role	22	view_projectrole
89	Can add Project type	23	add_projecttype
90	Can change Project type	23	change_projecttype
91	Can delete Project type	23	delete_projecttype
92	Can view Project type	23	view_projecttype
93	Can add Project note	24	add_projectnote
94	Can change Project note	24	change_projectnote
95	Can delete Project note	24	delete_projectnote
96	Can view Project note	24	view_projectnote
97	Can add Project assignment	25	add_projectassignment
98	Can change Project assignment	25	change_projectassignment
99	Can delete Project assignment	25	delete_projectassignment
100	Can view Project assignment	25	view_projectassignment
101	Can add Client note	26	add_clientnote
102	Can change Client note	26	change_clientnote
103	Can delete Client note	26	delete_clientnote
104	Can view Client note	26	view_clientnote
105	Can add Client POC	27	add_clientcontact
106	Can change Client POC	27	change_clientcontact
107	Can delete Client POC	27	delete_clientcontact
108	Can view Client POC	27	view_clientcontact
109	Can add Objective status	28	add_objectivestatus
110	Can change Objective status	28	change_objectivestatus
111	Can delete Objective status	28	delete_objectivestatus
112	Can view Objective status	28	view_objectivestatus
113	Can add Project objective	29	add_projectobjective
114	Can change Project objective	29	change_projectobjective
115	Can delete Project objective	29	delete_projectobjective
116	Can view Project objective	29	view_projectobjective
117	Can add Project scope list	30	add_projectscope
118	Can change Project scope list	30	change_projectscope
119	Can delete Project scope list	30	delete_projectscope
120	Can view Project scope list	30	view_projectscope
121	Can add Project target	31	add_projecttarget
122	Can change Project target	31	change_projecttarget
123	Can delete Project target	31	delete_projecttarget
124	Can view Project target	31	view_projecttarget
125	Can add Objective sub-task	32	add_projectsubtask
126	Can change Objective sub-task	32	change_projectsubtask
127	Can delete Objective sub-task	32	delete_projectsubtask
128	Can view Objective sub-task	32	view_projectsubtask
129	Can add Objective priority	33	add_objectivepriority
130	Can change Objective priority	33	change_objectivepriority
131	Can delete Objective priority	33	delete_objectivepriority
132	Can view Objective priority	33	view_objectivepriority
133	Can add Project invite	34	add_projectinvite
134	Can change Project invite	34	change_projectinvite
135	Can delete Project invite	34	delete_projectinvite
136	Can view Project invite	34	view_projectinvite
137	Can add Client invite	35	add_clientinvite
138	Can change Client invite	35	change_clientinvite
139	Can delete Client invite	35	delete_clientinvite
140	Can view Client invite	35	view_clientinvite
141	Can add Activity type	36	add_activitytype
142	Can change Activity type	36	change_activitytype
143	Can delete Activity type	36	delete_activitytype
144	Can view Activity type	36	view_activitytype
145	Can add Domain	37	add_domain
146	Can change Domain	37	change_domain
147	Can delete Domain	37	delete_domain
148	Can view Domain	37	view_domain
149	Can add Domain status	38	add_domainstatus
150	Can change Domain status	38	change_domainstatus
151	Can delete Domain status	38	delete_domainstatus
152	Can view Domain status	38	view_domainstatus
153	Can add Health status	39	add_healthstatus
154	Can change Health status	39	change_healthstatus
155	Can delete Health status	39	delete_healthstatus
156	Can view Health status	39	view_healthstatus
157	Can add Server provider	40	add_serverprovider
158	Can change Server provider	40	change_serverprovider
159	Can delete Server provider	40	delete_serverprovider
160	Can view Server provider	40	view_serverprovider
161	Can add Server role	41	add_serverrole
162	Can change Server role	41	change_serverrole
163	Can delete Server role	41	delete_serverrole
164	Can view Server role	41	view_serverrole
165	Can add Server status	42	add_serverstatus
166	Can change Server status	42	change_serverstatus
167	Can delete Server status	42	delete_serverstatus
168	Can view Server status	42	view_serverstatus
169	Can add WHOIS status	43	add_whoisstatus
170	Can change WHOIS status	43	change_whoisstatus
171	Can delete WHOIS status	43	delete_whoisstatus
172	Can view WHOIS status	43	view_whoisstatus
173	Can add Virtual private server	44	add_transientserver
174	Can change Virtual private server	44	change_transientserver
175	Can delete Virtual private server	44	delete_transientserver
176	Can view Virtual private server	44	view_transientserver
177	Can add Static server	45	add_staticserver
178	Can change Static server	45	change_staticserver
179	Can delete Static server	45	delete_staticserver
180	Can view Static server	45	view_staticserver
181	Can add Server note	46	add_servernote
182	Can change Server note	46	change_servernote
183	Can delete Server note	46	delete_servernote
184	Can view Server note	46	view_servernote
185	Can add Server history	47	add_serverhistory
186	Can change Server history	47	change_serverhistory
187	Can delete Server history	47	delete_serverhistory
188	Can view Server history	47	view_serverhistory
189	Can add Domain history	48	add_history
190	Can change Domain history	48	change_history
191	Can delete Domain history	48	delete_history
192	Can view Domain history	48	view_history
193	Can add Domain and server record	49	add_domainserverconnection
194	Can change Domain and server record	49	change_domainserverconnection
195	Can delete Domain and server record	49	delete_domainserverconnection
196	Can view Domain and server record	49	view_domainserverconnection
197	Can add Domain note	50	add_domainnote
198	Can change Domain note	50	change_domainnote
199	Can delete Domain note	50	delete_domainnote
200	Can view Domain note	50	view_domainnote
201	Can add Auxiliary IP address	51	add_auxserveraddress
202	Can change Auxiliary IP address	51	change_auxserveraddress
203	Can delete Auxiliary IP address	51	delete_auxserveraddress
204	Can view Auxiliary IP address	51	view_auxserveraddress
205	Can add Finding type	52	add_findingtype
206	Can change Finding type	52	change_findingtype
207	Can delete Finding type	52	delete_findingtype
208	Can view Finding type	52	view_findingtype
209	Can add Report	53	add_report
210	Can change Report	53	change_report
211	Can delete Report	53	delete_report
212	Can view Report	53	view_report
213	Can add Severity rating	54	add_severity
214	Can change Severity rating	54	change_severity
215	Can delete Severity rating	54	delete_severity
216	Can view Severity rating	54	view_severity
217	Can add Report finding	55	add_reportfindinglink
218	Can change Report finding	55	change_reportfindinglink
219	Can delete Report finding	55	delete_reportfindinglink
220	Can view Report finding	55	view_reportfindinglink
221	Can add Finding	56	add_finding
222	Can change Finding	56	change_finding
223	Can delete Finding	56	delete_finding
224	Can view Finding	56	view_finding
225	Can add Evidence	57	add_evidence
226	Can change Evidence	57	change_evidence
227	Can delete Evidence	57	delete_evidence
228	Can view Evidence	57	view_evidence
229	Can add Archived report	58	add_archive
230	Can change Archived report	58	change_archive
231	Can delete Archived report	58	delete_archive
232	Can view Archived report	58	view_archive
233	Can add Local finding note	59	add_localfindingnote
234	Can change Local finding note	59	change_localfindingnote
235	Can delete Local finding note	59	delete_localfindingnote
236	Can view Local finding note	59	view_localfindingnote
237	Can add Finding note	60	add_findingnote
238	Can change Finding note	60	change_findingnote
239	Can delete Finding note	60	delete_findingnote
240	Can view Finding note	60	view_findingnote
241	Can add Report template	61	add_reporttemplate
242	Can change Report template	61	change_reporttemplate
243	Can delete Report template	61	delete_reporttemplate
244	Can view Report template	61	view_reporttemplate
245	Can add Document type	62	add_doctype
246	Can change Document type	62	change_doctype
247	Can delete Document type	62	delete_doctype
248	Can view Document type	62	view_doctype
249	Can add oplog	63	add_oplog
250	Can change oplog	63	change_oplog
251	Can delete oplog	63	delete_oplog
252	Can view oplog	63	view_oplog
253	Can add oplog entry	64	add_oplogentry
254	Can change oplog entry	64	change_oplogentry
255	Can delete oplog entry	64	delete_oplogentry
256	Can view oplog entry	64	view_oplogentry
257	Can add Cloud Services Configuration	65	add_cloudservicesconfiguration
258	Can change Cloud Services Configuration	65	change_cloudservicesconfiguration
259	Can delete Cloud Services Configuration	65	delete_cloudservicesconfiguration
260	Can view Cloud Services Configuration	65	view_cloudservicesconfiguration
261	Can add Company Information	66	add_companyinformation
262	Can change Company Information	66	change_companyinformation
263	Can delete Company Information	66	delete_companyinformation
264	Can view Company Information	66	view_companyinformation
265	Can add Namecheap Configuration	67	add_namecheapconfiguration
266	Can change Namecheap Configuration	67	change_namecheapconfiguration
267	Can delete Namecheap Configuration	67	delete_namecheapconfiguration
268	Can view Namecheap Configuration	67	view_namecheapconfiguration
269	Can add Global Report Configuration	68	add_reportconfiguration
270	Can change Global Report Configuration	68	change_reportconfiguration
271	Can delete Global Report Configuration	68	delete_reportconfiguration
272	Can view Global Report Configuration	68	view_reportconfiguration
273	Can add Slack Configuration	69	add_slackconfiguration
274	Can change Slack Configuration	69	change_slackconfiguration
275	Can delete Slack Configuration	69	delete_slackconfiguration
276	Can view Slack Configuration	69	view_slackconfiguration
277	Can add VirusTotal Configuration	70	add_virustotalconfiguration
278	Can change VirusTotal Configuration	70	change_virustotalconfiguration
279	Can delete VirusTotal Configuration	70	delete_virustotalconfiguration
280	Can view VirusTotal Configuration	70	view_virustotalconfiguration
281	Can add API key	71	add_apikey
282	Can change API key	71	change_apikey
283	Can delete API key	71	delete_apikey
284	Can view API key	71	view_apikey
\.


--
-- Data for Name: commandcenter_cloudservicesconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_cloudservicesconfiguration (id, enable, aws_key, aws_secret, do_api_key, ignore_tag, notification_delay) FROM stdin;
1	f	Your AWS Access Key	Your AWS Secret Key	Digital Ocean API Key	gw_ignore	7
\.


--
-- Data for Name: commandcenter_companyinformation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_companyinformation (id, company_name, company_twitter, company_email) FROM stdin;
1	SpecterOps	@specterops	info@specterops.io
\.


--
-- Data for Name: commandcenter_namecheapconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_namecheapconfiguration (id, enable, api_key, username, api_username, client_ip, page_size) FROM stdin;
1	f	Namecheap API Key	Account Username	API Username	Whitelisted IP Address	100
\.


--
-- Data for Name: commandcenter_reportconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_reportconfiguration (id, border_weight, border_color, prefix_figure, prefix_table, default_docx_template_id, default_pptx_template_id, enable_borders, label_figure, label_table) FROM stdin;
1	12700	2D2B6B	–	–	\N	\N	f	Figure	Table
\.


--
-- Data for Name: commandcenter_slackconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_slackconfiguration (id, enable, webhook_url, slack_emoji, slack_channel, slack_username, slack_alert_target) FROM stdin;
1	f	https://hooks.slack.com/services/<your_webhook_url>	:ghost:	#ghostwriter	Ghostwriter	<!here>
\.


--
-- Data for Name: commandcenter_virustotalconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_virustotalconfiguration (id, enable, api_key, sleep_time) FROM stdin;
1	t	501caf66349cc7357eb4398ac3298fdd03dec01a3e2f3ad576525aa7b57a1987	20
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
1	2022-07-15 19:25:16.725001+00	2	iceberg	1	[{"added": {}}]	18	1
2	2022-07-15 19:25:28.834862+00	2	iceberg	2	[{"changed": {"fields": ["Staff status", "Superuser status"]}}]	18	1
3	2022-07-15 19:26:05.463334+00	3	3t3rn4l	1	[{"added": {}}]	18	1
4	2022-07-15 19:26:16.924543+00	3	3t3rn4l	2	[{"changed": {"fields": ["User's Timezone", "Staff status", "Superuser status"]}}]	18	1
5	2022-07-15 19:28:27.616719+00	1	VirusTotal Configuration	2	[{"changed": {"fields": ["Enable", "Api key"]}}]	70	1
6	2022-07-15 19:29:25.80713+00	3	Test	3		61	1
7	2022-07-15 19:30:33.113227+00	4	RH Template	1	[{"added": {}}]	61	1
8	2022-07-15 19:31:05.080819+00	1	test	2	[{"changed": {"fields": ["Delivered", "Docx template"]}}]	53	1
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	auth	permission
2	auth	group
3	contenttypes	contenttype
4	sessions	session
5	sites	site
6	admin	logentry
7	account	emailaddress
8	account	emailconfirmation
9	socialaccount	socialaccount
10	socialaccount	socialapp
11	socialaccount	socialtoken
12	rest_framework_api_key	apikey
13	django_q	schedule
14	django_q	task
15	django_q	failure
16	django_q	success
17	django_q	ormq
18	users	user
19	home	userprofile
20	rolodex	client
21	rolodex	project
22	rolodex	projectrole
23	rolodex	projecttype
24	rolodex	projectnote
25	rolodex	projectassignment
26	rolodex	clientnote
27	rolodex	clientcontact
28	rolodex	objectivestatus
29	rolodex	projectobjective
30	rolodex	projectscope
31	rolodex	projecttarget
32	rolodex	projectsubtask
33	rolodex	objectivepriority
34	rolodex	projectinvite
35	rolodex	clientinvite
36	shepherd	activitytype
37	shepherd	domain
38	shepherd	domainstatus
39	shepherd	healthstatus
40	shepherd	serverprovider
41	shepherd	serverrole
42	shepherd	serverstatus
43	shepherd	whoisstatus
44	shepherd	transientserver
45	shepherd	staticserver
46	shepherd	servernote
47	shepherd	serverhistory
48	shepherd	history
49	shepherd	domainserverconnection
50	shepherd	domainnote
51	shepherd	auxserveraddress
52	reporting	findingtype
53	reporting	report
54	reporting	severity
55	reporting	reportfindinglink
56	reporting	finding
57	reporting	evidence
58	reporting	archive
59	reporting	localfindingnote
60	reporting	findingnote
61	reporting	reporttemplate
62	reporting	doctype
63	oplog	oplog
64	oplog	oplogentry
65	commandcenter	cloudservicesconfiguration
66	commandcenter	companyinformation
67	commandcenter	namecheapconfiguration
68	commandcenter	reportconfiguration
69	commandcenter	slackconfiguration
70	commandcenter	virustotalconfiguration
71	api	apikey
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2022-07-11 19:59:05.724274+00
2	contenttypes	0002_remove_content_type_name	2022-07-11 19:59:05.736898+00
3	auth	0001_initial	2022-07-11 19:59:05.773665+00
4	auth	0002_alter_permission_name_max_length	2022-07-11 19:59:05.781247+00
5	auth	0003_alter_user_email_max_length	2022-07-11 19:59:05.787482+00
6	auth	0004_alter_user_username_opts	2022-07-11 19:59:05.795821+00
7	auth	0005_alter_user_last_login_null	2022-07-11 19:59:05.800968+00
8	auth	0006_require_contenttypes_0002	2022-07-11 19:59:05.803294+00
9	auth	0007_alter_validators_add_error_messages	2022-07-11 19:59:05.808796+00
10	auth	0008_alter_user_username_max_length	2022-07-11 19:59:05.814207+00
11	auth	0009_alter_user_last_name_max_length	2022-07-11 19:59:05.819112+00
12	auth	0010_alter_group_name_max_length	2022-07-11 19:59:05.82471+00
13	auth	0011_update_proxy_permissions	2022-07-11 19:59:05.829838+00
14	users	0001_initial	2022-07-11 19:59:05.865671+00
15	account	0001_initial	2022-07-11 19:59:05.899828+00
16	account	0002_email_max_length	2022-07-11 19:59:05.907833+00
17	admin	0001_initial	2022-07-11 19:59:05.923907+00
18	admin	0002_logentry_remove_auto_add	2022-07-11 19:59:05.930541+00
19	admin	0003_logentry_add_action_flag_choices	2022-07-11 19:59:05.937524+00
20	api	0001_initial	2022-07-11 19:59:05.956968+00
21	auth	0012_alter_user_first_name_max_length	2022-07-11 19:59:05.965824+00
22	rolodex	0001_initial	2022-07-11 19:59:06.122503+00
23	rolodex	0002_objectivestatus_projectobjective	2022-07-11 19:59:06.152311+00
24	rolodex	0003_auto_20190828_0007	2022-07-11 19:59:06.159345+00
25	rolodex	0004_auto_20190910_0113	2022-07-11 19:59:06.171398+00
26	rolodex	0005_auto_20191122_2304	2022-07-11 19:59:06.185385+00
27	rolodex	0006_auto_20200825_1947	2022-07-11 19:59:06.505293+00
28	reporting	0001_initial	2022-07-11 19:59:06.653549+00
29	reporting	0002_localfindingnote	2022-07-11 19:59:06.679296+00
30	reporting	0003_findingnote	2022-07-11 19:59:06.705352+00
31	reporting	0004_report_delivered	2022-07-11 19:59:06.71919+00
32	reporting	0005_reportfindinglink_finding_guidance	2022-07-11 19:59:06.733927+00
33	reporting	0006_auto_20191122_2304	2022-07-11 19:59:06.784303+00
34	reporting	0007_auto_20200110_0505	2022-07-11 19:59:06.79705+00
35	reporting	0008_auto_20200825_1947	2022-07-11 19:59:07.123359+00
36	reporting	0009_auto_20200915_0011	2022-07-11 19:59:07.135954+00
37	reporting	0010_reporttemplate	2022-07-11 19:59:07.168572+00
38	reporting	0011_report_template	2022-07-11 19:59:07.194304+00
39	reporting	0012_auto_20200923_2228	2022-07-11 19:59:07.220588+00
40	reporting	0013_reporttemplate_lint_result	2022-07-11 19:59:07.243007+00
41	reporting	0014_auto_20200924_1822	2022-07-11 19:59:07.258099+00
42	reporting	0015_auto_20201016_1756	2022-07-11 19:59:07.326869+00
43	reporting	0016_auto_20201017_0014	2022-07-11 19:59:07.404819+00
44	reporting	0017_auto_20201019_2318	2022-07-11 19:59:07.441644+00
45	reporting	0018_auto_20201027_1914	2022-07-11 19:59:07.47426+00
46	commandcenter	0001_initial	2022-07-11 19:59:07.516643+00
47	commandcenter	0002_auto_20201009_1918	2022-07-11 19:59:07.522078+00
48	commandcenter	0003_auto_20201027_1914	2022-07-11 19:59:07.564788+00
49	commandcenter	0004_auto_20201028_1633	2022-07-11 19:59:07.612536+00
50	commandcenter	0005_auto_20201102_2207	2022-07-11 19:59:07.638571+00
51	commandcenter	0006_auto_20210614_2224	2022-07-11 19:59:07.653589+00
52	commandcenter	0007_auto_20210616_0340	2022-07-11 19:59:07.662303+00
53	commandcenter	0008_remove_namecheapconfiguration_reset_dns	2022-07-11 19:59:07.669695+00
54	commandcenter	0009_cloudservicesconfiguration_notification_delay	2022-07-11 19:59:07.67399+00
55	commandcenter	0010_auto_20220205_0026	2022-07-11 19:59:07.728412+00
56	django_q	0001_initial	2022-07-11 19:59:07.747173+00
57	django_q	0002_auto_20150630_1624	2022-07-11 19:59:07.754351+00
58	django_q	0003_auto_20150708_1326	2022-07-11 19:59:07.776485+00
59	django_q	0004_auto_20150710_1043	2022-07-11 19:59:07.786166+00
60	django_q	0005_auto_20150718_1506	2022-07-11 19:59:07.794184+00
61	django_q	0006_auto_20150805_1817	2022-07-11 19:59:07.800914+00
62	django_q	0007_ormq	2022-07-11 19:59:07.80808+00
63	django_q	0008_auto_20160224_1026	2022-07-11 19:59:07.812587+00
64	django_q	0009_auto_20171009_0915	2022-07-11 19:59:07.821085+00
65	django_q	0010_auto_20200610_0856	2022-07-11 19:59:07.833617+00
66	django_q	0011_auto_20200628_1055	2022-07-11 19:59:07.840409+00
67	django_q	0012_auto_20200702_1608	2022-07-11 19:59:07.844607+00
68	django_q	0013_task_attempt_count	2022-07-11 19:59:07.849995+00
69	django_q	0014_schedule_cluster	2022-07-11 19:59:07.856616+00
70	home	0001_initial	2022-07-11 19:59:07.86389+00
71	home	0002_userprofile_user	2022-07-11 19:59:07.891729+00
72	home	0003_auto_20190729_2213	2022-07-11 19:59:07.999297+00
73	home	0004_auto_20220125_2358	2022-07-11 19:59:08.020947+00
74	home	0005_alter_userprofile_id	2022-07-11 19:59:08.056676+00
75	oplog	0001_initial	2022-07-11 19:59:08.114203+00
76	oplog	0002_auto_20200825_2127	2022-07-11 19:59:08.169491+00
77	oplog	0003_auto_20210729_2132	2022-07-11 19:59:08.211308+00
78	oplog	0004_auto_20220205_0026	2022-07-11 19:59:08.290071+00
79	reporting	0019_auto_20201105_0609	2022-07-11 19:59:08.311462+00
80	reporting	0020_auto_20201105_0641	2022-07-11 19:59:08.328116+00
81	reporting	0021_auto_20201119_2343	2022-07-11 19:59:08.345073+00
82	reporting	0022_auto_20210211_2109	2022-07-11 19:59:08.363689+00
83	reporting	0023_auto_20210318_2120	2022-07-11 19:59:08.373222+00
84	reporting	0024_auto_20220205_0026	2022-07-11 19:59:09.071844+00
85	reporting	0025_alter_reporttemplate_lint_result	2022-07-11 19:59:09.114345+00
86	reporting	0026_convert_linting_status_to_json	2022-07-11 19:59:09.144542+00
87	reporting	0027_auto_20220510_1923	2022-07-11 19:59:09.157737+00
88	reporting	0028_auto_20220608_1808	2022-07-11 19:59:09.212327+00
89	rest_framework_api_key	0001_initial	2022-07-11 19:59:09.222964+00
90	rest_framework_api_key	0002_auto_20190529_2243	2022-07-11 19:59:09.231438+00
91	rest_framework_api_key	0003_auto_20190623_1952	2022-07-11 19:59:09.242243+00
92	rest_framework_api_key	0004_prefix_hashed_key	2022-07-11 19:59:09.286075+00
93	rest_framework_api_key	0005_auto_20220110_1102	2022-07-11 19:59:09.295284+00
94	rolodex	0007_auto_20201027_1914	2022-07-11 19:59:09.347024+00
95	rolodex	0008_projectscope	2022-07-11 19:59:09.386966+00
96	rolodex	0009_projecttarget	2022-07-11 19:59:09.419564+00
97	rolodex	0010_auto_20210204_1957	2022-07-11 19:59:09.448587+00
98	rolodex	0011_projectsubtask	2022-07-11 19:59:09.489433+00
99	rolodex	0012_auto_20210211_1853	2022-07-11 19:59:09.514969+00
100	rolodex	0013_projectsubtask_marked_complete	2022-07-11 19:59:09.521491+00
101	rolodex	0014_projectobjective_marked_complete	2022-07-11 19:59:09.535257+00
102	rolodex	0015_auto_20210219_2204	2022-07-11 19:59:09.567342+00
103	rolodex	0016_auto_20210224_0645	2022-07-11 19:59:09.617262+00
104	rolodex	0017_projectobjective_position	2022-07-11 19:59:09.631446+00
105	rolodex	0018_auto_20210227_0228	2022-07-11 19:59:09.646565+00
106	rolodex	0019_auto_20210303_2155	2022-07-11 19:59:09.683751+00
107	rolodex	0020_auto_20210922_2337	2022-07-11 19:59:09.698295+00
108	rolodex	0021_project_timezone	2022-07-11 19:59:09.724011+00
109	rolodex	0022_auto_20210923_0011	2022-07-11 19:59:09.86144+00
110	rolodex	0023_auto_20210923_0038	2022-07-11 19:59:09.89918+00
111	rolodex	0024_clientcontact_timezone	2022-07-11 19:59:09.908613+00
112	rolodex	0025_auto_20210923_1540	2022-07-11 19:59:09.917921+00
113	rolodex	0026_auto_20211109_1908	2022-07-11 19:59:09.937237+00
114	rolodex	0027_auto_20220205_0026	2022-07-11 19:59:10.706599+00
115	rolodex	0028_clientinvite_projectinvite	2022-07-11 19:59:10.792912+00
116	rolodex	0029_auto_20220510_1922	2022-07-11 19:59:10.812314+00
117	rolodex	0030_auto_20220526_1737	2022-07-11 19:59:10.865465+00
118	sessions	0001_initial	2022-07-11 19:59:10.876484+00
119	shepherd	0001_initial	2022-07-11 19:59:11.532582+00
120	shepherd	0002_auto_20190726_1841	2022-07-11 19:59:11.53945+00
121	shepherd	0003_auto_20190824_0401	2022-07-11 19:59:11.663403+00
122	shepherd	0004_auto_20190910_0113	2022-07-11 19:59:11.747231+00
123	shepherd	0005_auto_20191001_1352	2022-07-11 19:59:11.889863+00
124	shepherd	0006_auto_20191001_1353	2022-07-11 19:59:11.921208+00
125	shepherd	0007_auto_20191029_1636	2022-07-11 19:59:11.962018+00
126	shepherd	0008_auto_20191122_2304	2022-07-11 19:59:11.986909+00
127	shepherd	0009_auxserveraddress	2022-07-11 19:59:12.087116+00
128	shepherd	0010_auto_20200123_0204	2022-07-11 19:59:12.105166+00
129	shepherd	0011_auto_20200123_0726	2022-07-11 19:59:12.116724+00
130	shepherd	0012_auto_20200616_0441	2022-07-11 19:59:12.138911+00
131	shepherd	0013_auto_20200825_1947	2022-07-11 19:59:12.218028+00
132	shepherd	0014_auto_20200909_1804	2022-07-11 19:59:12.838817+00
133	shepherd	0015_auto_20201120_0620	2022-07-11 19:59:12.880881+00
134	shepherd	0016_auto_20210227_0056	2022-07-11 19:59:12.893688+00
135	shepherd	0017_domain_reset_dns	2022-07-11 19:59:12.913292+00
136	shepherd	0018_auto_20210630_2205	2022-07-11 19:59:12.937054+00
137	shepherd	0019_auto_20210706_2242	2022-07-11 19:59:12.954868+00
138	shepherd	0020_transientserver_address	2022-07-11 19:59:12.979243+00
139	shepherd	0021_auto_20210923_1953	2022-07-11 19:59:13.016808+00
140	shepherd	0022_auto_20210923_2115	2022-07-11 19:59:13.042041+00
141	shepherd	0023_auto_20210923_2142	2022-07-11 19:59:13.096632+00
142	shepherd	0024_auto_20210923_2209	2022-07-11 19:59:13.122687+00
143	shepherd	0025_auto_20210923_2214	2022-07-11 19:59:13.225719+00
144	shepherd	0026_auto_20210923_2217	2022-07-11 19:59:13.25079+00
145	shepherd	0027_auto_20210923_2218	2022-07-11 19:59:13.275564+00
146	shepherd	0028_auto_20210923_2234	2022-07-11 19:59:13.299388+00
147	shepherd	0029_auto_20210923_2235	2022-07-11 19:59:13.324073+00
148	shepherd	0030_auto_20211103_1719	2022-07-11 19:59:13.349382+00
149	shepherd	0031_auto_20220201_2331	2022-07-11 19:59:13.370093+00
150	shepherd	0032_migrate_domain_categories	2022-07-11 19:59:13.405121+00
151	shepherd	0033_delete_old_domain_categories	2022-07-11 19:59:13.56567+00
152	shepherd	0034_remove_domain_health_dns	2022-07-11 19:59:13.674193+00
153	shepherd	0035_auto_20220205_0026	2022-07-11 19:59:14.621605+00
154	shepherd	0036_auto_20220209_1815	2022-07-11 19:59:14.685224+00
155	shepherd	0037_convert_dns_record_to_json	2022-07-11 19:59:14.721833+00
156	shepherd	0038_alter_domain_dns_record	2022-07-11 19:59:14.743262+00
157	shepherd	0039_auto_20220510_1909	2022-07-11 19:59:14.747789+00
158	shepherd	0040_auto_20220510_1949	2022-07-11 19:59:14.762479+00
159	sites	0001_initial	2022-07-11 19:59:14.774048+00
160	sites	0002_alter_domain_unique	2022-07-11 19:59:14.781954+00
161	sites	0003_set_site_domain_and_name	2022-07-11 19:59:14.821864+00
162	sites	0004_auto_20210406_0058	2022-07-11 19:59:14.82667+00
163	sites	0005_auto_20210614_1732	2022-07-11 19:59:14.83102+00
164	sites	0006_auto_20210922_2325	2022-07-11 19:59:14.834852+00
165	socialaccount	0001_initial	2022-07-11 19:59:15.034319+00
166	socialaccount	0002_token_max_lengths	2022-07-11 19:59:15.074728+00
167	socialaccount	0003_extra_data_default_dict	2022-07-11 19:59:15.097127+00
168	users	0002_auto_20190729_1749	2022-07-11 19:59:15.138816+00
169	users	0003_auto_20210922_2349	2022-07-11 19:59:15.178847+00
170	users	0004_auto_20220126_1735	2022-07-11 19:59:15.200529+00
171	users	0005_alter_user_id	2022-07-11 19:59:15.523088+00
172	users	0006_user_role	2022-07-11 19:59:15.559687+00
\.


--
-- Data for Name: django_q_ormq; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_q_ormq (id, key, payload, lock) FROM stdin;
\.


--
-- Data for Name: django_q_schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_q_schedule (id, func, hook, args, kwargs, schedule_type, repeats, next_run, task, name, minutes, cron, cluster) FROM stdin;
\.


--
-- Data for Name: django_q_task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_q_task (name, func, hook, args, kwargs, result, started, stopped, success, id, "group", attempt_count) FROM stdin;
mountain-iowa-glucose-colorado	ghostwriter.shepherd.tasks.test_aws_keys	\N	gAWVXAIAAAAAAACMFWRqYW5nby5kYi5tb2RlbHMuYmFzZZSMDm1vZGVsX3VucGlja2xllJOUjAV1c2Vyc5SMBFVzZXKUhpSFlFKUfZQojAZfc3RhdGWUaACMCk1vZGVsU3RhdGWUk5QpgZR9lCiMBmFkZGluZ5SJjAJkYpSMB2RlZmF1bHSUjAxmaWVsZHNfY2FjaGWUfZR1YowCaWSUSwGMCHBhc3N3b3JklIxwYXJnb24yJGFyZ29uMmlkJHY9MTkkbT0xMDI0MDAsdD0yLHA9OCRVbXMxYzBKVE0yc3laMVYyWlVKeVRsZHNOVmREZEEkc3ZQakh0dmx6eFZpWmtBd05mbTJPQ1Z4TndmWTVMTjdza0NFMVpjVFRMTZSMCmxhc3RfbG9naW6UjAhkYXRldGltZZSMCGRhdGV0aW1llJOUQwoH5gcTCCcQBFKelIwEcHl0epSMBF9VVEOUk5QpUpSGlFKUjAxpc19zdXBlcnVzZXKUiIwIdXNlcm5hbWWUjAVhZG1pbpSMBWVtYWlslIwXYWRtaW5AZ2hvc3R3cml0ZXIubG9jYWyUjAhpc19zdGFmZpSIjAlpc19hY3RpdmWUiIwLZGF0ZV9qb2luZWSUaBlDCgfmBwsUDicOagaUaB6GlFKUjARuYW1llIwEemVyMJSMCHRpbWV6b25llGgbjAJfcJSTlCiMEEFtZXJpY2EvTmV3X1lvcmuUSqC6//9LAIwDTE1UlHSUUpSMBXBob25llE6MBHJvbGWUjAR1c2VylIwPX2RqYW5nb192ZXJzaW9ulIwGMy4yLjExlHVihZQu	gAV9lC4=	gAWVfAAAAAAAAAB9lCiMBnJlc3VsdJSMBWVycm9ylIwHbWVzc2FnZZSMWUFXUyBjb3VsZCBub3QgdmFsaWRhdGUgdGhlIHByb3ZpZGVkIGNyZWRlbnRpYWxzIGZvciBFQzI7IGNoZWNrIHlvdXIgYXR0YWNoZWQgQVdTIHBvbGljaWVzlHUu	2022-07-19 08:42:59.990549+00	2022-07-19 08:43:00.656052+00	t	383b73e42fd140d8a848fa4ef784550c	AWS Test	1
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
vw6qsjs07cepfxky2z65nl29kpix46gp	.eJxVj8FuwyAQRP9lz5YFskzAx977DWhhl5omMhGsq0aR_z1GyqG9zpsZzTzB4y6r3xtXnwkW0DD81QLGK28d0DduX2WMZZOaw9gt45u28bMQ3z7e3n8FK7b1TJvINqAjqwMGR6hcmBVOU3DJqItTadLG0cUZ4pSMSeSCtpbdbMnMVrle2ri1XDbPv_dcH7CoAVomDlhheUKTHK-nKnXnYwCMkn_YV76XKp33d3oAyXLjc5BwEziOFwQEViU:1oB0RR:3LxGx_d-BOMHJE2NO-jFzKEYYZIP-NEhe-YxONmEvtU	2022-07-25 20:55:41.133128+00
owpqf43r3hljk61apfkzuodtpnp4hr3z	.eJxVj8FuwyAQRP9lz5YFskzAx977DWhhl5omMhGsq0aR_z1GyqG9zpsZzTzB4y6r3xtXnwkW0DD81QLGK28d0DduX2WMZZOaw9gt45u28bMQ3z7e3n8FK7b1TJvINqAjqwMGR6hcmBVOU3DJqItTadLG0cUZ4pSMSeSCtpbdbMnMVrle2ri1XDbPv_dcH7CoAVomDlhheUKTHK-nKnXnYwCMkn_YV76XKp33d3oAyXLjc5BwEziOFwQEViU:1oCR43:gtQMkT4i9adU94z4KFTrvHdAYbM9t-inR_SW5xCV6Pk	2022-07-29 19:33:27.4821+00
mse978k69vh43jlz7whqa0ggo6zlseqs	.eJxVj8FuwyAQRP9lz5YFskzAx977DWhhl5omMhGsq0aR_z1GyqG9zpsZzTzB4y6r3xtXnwkW0DD81QLGK28d0DduX2WMZZOaw9gt45u28bMQ3z7e3n8FK7b1TJvINqAjqwMGR6hcmBVOU3DJqItTadLG0cUZ4pSMSeSCtpbdbMnMVrle2ri1XDbPv_dcH7CoAVomDlhheUKTHK-nKnXnYwCMkn_YV76XKp33d3oAyXLjc5BwEziOFwQEViU:1oDimV:RXQZOdSL3-Vc7yz5OMMscwzdgGXkRx-VB4vrf7tCCBA	2022-08-02 08:40:39.099849+00
j812pn6g23a12sfuwsn7vqfvijpzkzns	.eJxVjEEKgzAQRe-StUhEjBmX3fcMMuNMatqSlCRCi3j3Krhot--9_1c14lLmccmSRs9qUI2qfhnh9JBwCL5juMV6iqEkT_WR1KfN9TWyPC9n-3cwY573tZnEEgLbhpCAUQN1GtuWwBndg3ZtY4B7MCzOGeMYqLFWoLNsOqvhOM2Ss49hlPfLp48adKWyZyFMalhVLn567LSkRbbtC5UhSMA:1oDnQW:bZrCgk9pfPRGB48OavoUemzQlczRgcvShGLOcCM_8Ug	2022-08-02 13:38:16.990934+00
uokv8assp87h23ltablzlzzsbnahv5dg	.eJxVjEEKgzAQRe-StUhEjBmX3fcMMuNMatqSlCRCi3j3Krhot--9_1c14lLmccmSRs9qUI2qfhnh9JBwCL5juMV6iqEkT_WR1KfN9TWyPC9n-3cwY573tZnEEgLbhpCAUQN1GtuWwBndg3ZtY4B7MCzOGeMYqLFWoLNsOqvhOM2Ss49hlPfLp48adKWyZyFMalhVLn567LSkRbbtC5UhSMA:1oED29:fOhekflmnfPo0b2d8aTETCQQssRZQzfo5BhSqYvAvIo	2022-08-03 16:58:49.034387+00
\.


--
-- Data for Name: django_site; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_site (id, domain, name) FROM stdin;
1	specterops.training	Student Dashboard
\.


--
-- Data for Name: home_userprofile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.home_userprofile (id, avatar, user_id) FROM stdin;
1		1
2		2
3		3
\.


--
-- Data for Name: oplog_oplog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oplog_oplog (id, name, project_id) FROM stdin;
\.


--
-- Data for Name: oplog_oplogentry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oplog_oplogentry (id, start_date, end_date, source_ip, dest_ip, tool, user_context, command, description, output, comments, operator_name, oplog_id_id) FROM stdin;
\.


--
-- Data for Name: reporting_archive; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_archive (id, report_archive, project_id) FROM stdin;
\.


--
-- Data for Name: reporting_doctype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_doctype (id, doc_type) FROM stdin;
1	docx
2	pptx
\.


--
-- Data for Name: reporting_evidence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_evidence (id, document, friendly_name, upload_date, caption, description, finding_id, uploaded_by_id) FROM stdin;
\.


--
-- Data for Name: reporting_finding; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_finding (id, title, description, impact, mitigation, replication_steps, host_detection_techniques, network_detection_techniques, "references", finding_guidance, finding_type_id, severity_id, cvss_score, cvss_vector) FROM stdin;
1	Cloud tests	<p>test</p>	<p>test</p>	<p>sanitise user input</p>		<p>run poc.py and proceed to pwn</p>	<p>look for IOC .....</p>	<p>github</p>		6	5	9.80000000000000071	CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
\.


--
-- Data for Name: reporting_findingnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_findingnote (id, "timestamp", note, finding_id, operator_id) FROM stdin;
\.


--
-- Data for Name: reporting_findingtype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_findingtype (id, finding_type) FROM stdin;
1	Network
2	Physical
3	Wireless
4	Web
5	Mobile
6	Cloud
7	Host
\.


--
-- Data for Name: reporting_localfindingnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_localfindingnote (id, "timestamp", note, finding_id, operator_id) FROM stdin;
\.


--
-- Data for Name: reporting_report; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_report (id, title, creation, last_update, complete, archived, created_by_id, project_id, delivered, docx_template_id, pptx_template_id) FROM stdin;
1	test	2022-07-11	2022-07-15	f	f	1	3	t	4	2
\.


--
-- Data for Name: reporting_reportfindinglink; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_reportfindinglink (id, title, "position", affected_entities, description, impact, mitigation, replication_steps, host_detection_techniques, network_detection_techniques, "references", complete, assigned_to_id, finding_type_id, report_id, severity_id, finding_guidance, cvss_score, cvss_vector) FROM stdin;
1	Test Template	1	<p>127.0.0.1</p>	<p>unauth RCE</p>	<p>pwnd</p>	<p>sanitize user input</p>	<p>run exploit.py</p>	<p>use ioc</p>	<p>snort</p>	<p>github</p>	f	1	1	1	5	\N	9.80000000000000071	CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
\.


--
-- Data for Name: reporting_reporttemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_reporttemplate (id, document, name, upload_date, last_update, description, protected, client_id, uploaded_by_id, lint_result, changelog, doc_type_id) FROM stdin;
1	/app/ghostwriter/media/templates/template.docx	Default Word Template	2022-07-11	2022-07-11	A sample Word template provided by Ghostwriter.	f	\N	\N	{"errors": ["Template file does not exist – upload it again"], "result": "failed"}	\N	1
2	/app/ghostwriter/media/templates/template.pptx	Default PowerPoint Template	2022-07-11	2022-07-11	A sample PowerPoint presentation template provided by Ghostwriter.	f	\N	\N	{"errors": ["Template file does not exist – upload it again"], "result": "failed"}	\N	2
4	RHtemplate.docx	RH Template	2022-07-15	2022-07-15	Test Template	f	1	\N	{"errors": ["Jinja2 template syntax error: 'server' is undefined"], "result": "failed"}	\N	1
\.


--
-- Data for Name: reporting_severity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_severity (id, severity, weight, color) FROM stdin;
1	Informational	5	8EAADB
2	Low	4	A8D08D
3	Medium	3	F4B083
4	High	2	FF7E79
5	Critical	1	966FD6
\.


--
-- Data for Name: rest_framework_api_key_apikey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rest_framework_api_key_apikey (id, created, name, revoked, expiry_date, hashed_key, prefix) FROM stdin;
\.


--
-- Data for Name: rolodex_client; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_client (id, name, short_name, codename, note, address, timezone) FROM stdin;
1	Robert Half	RHI	URBAN TOLL	<p>Talent Solutions</p>	<p>2884 Sand Hill Road<br />Menlo Park, California 94025</p>	America/Los_Angeles
\.


--
-- Data for Name: rolodex_clientcontact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_clientcontact (id, name, job_title, email, phone, note, client_id, timezone) FROM stdin;
1	Dave Lowe	EIS SecOps Boss	dave.lowe@roberthalf.com	+19259131439		1	America/Los_Angeles
\.


--
-- Data for Name: rolodex_clientinvite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_clientinvite (id, comment, client_id, user_id) FROM stdin;
\.


--
-- Data for Name: rolodex_clientnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_clientnote (id, "timestamp", note, client_id, operator_id) FROM stdin;
\.


--
-- Data for Name: rolodex_objectivepriority; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_objectivepriority (id, weight, priority) FROM stdin;
1	0	Primary
2	1	Secondary
3	2	Tertiary
\.


--
-- Data for Name: rolodex_objectivestatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_objectivestatus (id, objective_status) FROM stdin;
1	Active
2	On Hold
3	In Progress
4	Missed
\.


--
-- Data for Name: rolodex_project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_project (id, codename, start_date, end_date, note, slack_channel, complete, client_id, operator_id, project_type_id, timezone, end_time, start_time) FROM stdin;
1	ROWDY CYBORG	2022-07-11	2022-07-25	<p>Test Ghost Writer</p>	\N	t	1	\N	1	America/Los_Angeles	17:00:00	09:00:00
3	ONYX ANDROID	2022-07-11	2022-07-25		\N	f	1	\N	1	America/Los_Angeles	17:00:00	09:00:00
\.


--
-- Data for Name: rolodex_projectassignment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectassignment (id, start_date, end_date, note, operator_id, project_id, role_id) FROM stdin;
2	2022-07-11	2022-07-25		1	3	1
\.


--
-- Data for Name: rolodex_projectinvite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectinvite (id, comment, project_id, user_id) FROM stdin;
\.


--
-- Data for Name: rolodex_projectnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectnote (id, "timestamp", note, operator_id, project_id) FROM stdin;
\.


--
-- Data for Name: rolodex_projectobjective; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectobjective (id, objective, complete, deadline, project_id, status_id, marked_complete, description, priority_id, "position") FROM stdin;
1	Domain admin	t	2022-07-25	1	1	\N		1	1
2	Ransomware Simulation	f	2022-07-25	1	1	\N		2	1
4	domain admin	f	2022-07-25	3	1	\N		1	1
\.


--
-- Data for Name: rolodex_projectrole; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectrole (id, project_role) FROM stdin;
1	Assessment Lead
2	Assessment Oversight
3	Operator
\.


--
-- Data for Name: rolodex_projectscope; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectscope (id, name, scope, description, disallowed, requires_caution, project_id) FROM stdin;
1	All IP space and Domains	204.75.64.0/18\r\n*.roberthalf.com\r\n*.provtiviti.com\r\n*.rhi.com\r\n*.rht.com\r\n*.rhalf.com		f	f	1
3	All ips and domains	roberthalf.com\r\nprovtiviti.com\r\nrhi.com\r\nrht.com\r\nrhalf.com		f	f	3
\.


--
-- Data for Name: rolodex_projectsubtask; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectsubtask (id, task, complete, deadline, parent_id, status_id, marked_complete) FROM stdin;
\.


--
-- Data for Name: rolodex_projecttarget; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projecttarget (id, ip_address, hostname, note, compromised, project_id) FROM stdin;
1	204.75.64.1	roberthalf.com	<p>roberthalf.com<br />provtiviti.com<br />rhi.com<br />rht.com<br />rhalf.com</p>	f	3
\.


--
-- Data for Name: rolodex_projecttype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projecttype (id, project_type) FROM stdin;
1	Red Team
2	Penetration Test
3	Phishing Assessment
4	Web Application Assessment
\.


--
-- Data for Name: shepherd_activitytype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_activitytype (id, activity) FROM stdin;
1	Command and Control
2	Phishing
\.


--
-- Data for Name: shepherd_auxserveraddress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_auxserveraddress (id, ip_address, static_server_id, "primary") FROM stdin;
\.


--
-- Data for Name: shepherd_domain; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_domain (id, name, registrar, creation, expiration, note, burned_explanation, domain_status_id, health_status_id, last_used_by_id, whois_status_id, auto_renew, expired, last_health_check, vt_permalink, reset_dns, categorization, dns) FROM stdin;
\.


--
-- Data for Name: shepherd_domainnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_domainnote (id, "timestamp", note, domain_id, operator_id) FROM stdin;
\.


--
-- Data for Name: shepherd_domainserverconnection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_domainserverconnection (id, endpoint, subdomain, domain_id, project_id, static_server_id, transient_server_id) FROM stdin;
\.


--
-- Data for Name: shepherd_domainstatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_domainstatus (id, domain_status) FROM stdin;
1	Available
2	Unavailable
3	Reserved
4	Burned
5	Expired
\.


--
-- Data for Name: shepherd_healthstatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_healthstatus (id, health_status) FROM stdin;
1	Healthy
2	Burned
3	Questionable
\.


--
-- Data for Name: shepherd_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_history (id, start_date, end_date, note, activity_type_id, client_id, domain_id, operator_id, project_id) FROM stdin;
\.


--
-- Data for Name: shepherd_serverhistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_serverhistory (id, start_date, end_date, note, activity_type_id, client_id, operator_id, project_id, server_id, server_role_id) FROM stdin;
\.


--
-- Data for Name: shepherd_servernote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_servernote (id, "timestamp", note, operator_id, server_id) FROM stdin;
\.


--
-- Data for Name: shepherd_serverprovider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_serverprovider (id, server_provider) FROM stdin;
1	Amazon Web Services
2	Microsoft Azure
3	Digital Ocean
4	Google Compute Engine
5	Linode
6	Rackspace
\.


--
-- Data for Name: shepherd_serverrole; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_serverrole (id, server_role) FROM stdin;
1	Team Server / C2 Server
2	Redirector
3	Payload Hosting
4	SMTP
5	Burner Workstation
\.


--
-- Data for Name: shepherd_serverstatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_serverstatus (id, server_status) FROM stdin;
1	Available
2	Unavailable
3	Reserved
\.


--
-- Data for Name: shepherd_staticserver; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_staticserver (id, ip_address, note, last_used_by_id, server_provider_id, server_status_id, name) FROM stdin;
1	127.0.0.1	<p>test</p>	\N	1	1	test.local
\.


--
-- Data for Name: shepherd_transientserver; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_transientserver (id, ip_address, note, activity_type_id, operator_id, project_id, server_provider_id, server_role_id, name, aux_address) FROM stdin;
\.


--
-- Data for Name: shepherd_whoisstatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_whoisstatus (id, whois_status) FROM stdin;
1	Enabled
2	Disabled
3	Unknown
\.


--
-- Data for Name: socialaccount_socialaccount; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.socialaccount_socialaccount (id, provider, uid, last_login, date_joined, extra_data, user_id) FROM stdin;
\.


--
-- Data for Name: socialaccount_socialapp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.socialaccount_socialapp (id, provider, name, client_id, secret, key) FROM stdin;
\.


--
-- Data for Name: socialaccount_socialapp_sites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.socialaccount_socialapp_sites (id, socialapp_id, site_id) FROM stdin;
\.


--
-- Data for Name: socialaccount_socialtoken; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.socialaccount_socialtoken (id, token, token_secret, expires_at, account_id, app_id) FROM stdin;
\.


--
-- Data for Name: users_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_user (id, password, last_login, is_superuser, username, email, is_staff, is_active, date_joined, name, phone, timezone, role) FROM stdin;
2	argon2$argon2id$v=19$m=102400,t=2,p=8$WkVMVkMwQVpkVmNQSmhNamIxSno0Ug$0GB3gK6tFlkGkROfyYA796PzHFl+Oh0rk31DPwZJ4s8	\N	t	iceberg		t	t	2022-07-15 19:25:16+00		\N	America/Los_Angeles	user
3	argon2$argon2id$v=19$m=102400,t=2,p=8$MjFNeUlpWEl4UWVKdnRmT0FhVlMwQw$275zC5BH/vxu0OWx00HvzmW/O+dq2QFXb0I3hCuJAZs	\N	t	3t3rn4l		t	t	2022-07-15 19:26:05+00		\N	America/New_York	user
1	argon2$argon2id$v=19$m=102400,t=2,p=8$Ums1c0JTM2syZ1V2ZUJyTldsNVdDdA$svPjHtvlzxViZkAwNfm2OCVxNwfY5LN7skCE1ZcTTLM	2022-07-20 16:58:11.215418+00	t	admin	admin@ghostwriter.local	t	t	2022-07-11 20:14:39.944646+00	zer0	\N	America/New_York	user
\.


--
-- Data for Name: users_user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Data for Name: users_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Name: account_emailaddress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_emailaddress_id_seq', 1, false);


--
-- Name: account_emailconfirmation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_emailconfirmation_id_seq', 1, false);


--
-- Name: api_apikey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.api_apikey_id_seq', 1, false);


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 284, true);


--
-- Name: commandcenter_cloudservicesconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_cloudservicesconfiguration_id_seq', 1, false);


--
-- Name: commandcenter_companyinformation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_companyinformation_id_seq', 1, false);


--
-- Name: commandcenter_namecheapconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_namecheapconfiguration_id_seq', 1, false);


--
-- Name: commandcenter_reportconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_reportconfiguration_id_seq', 1, false);


--
-- Name: commandcenter_slackconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_slackconfiguration_id_seq', 1, false);


--
-- Name: commandcenter_virustotalconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_virustotalconfiguration_id_seq', 1, false);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 8, true);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 71, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 172, true);


--
-- Name: django_q_ormq_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_q_ormq_id_seq', 1, false);


--
-- Name: django_q_schedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_q_schedule_id_seq', 1, false);


--
-- Name: django_site_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_site_id_seq', 1, false);


--
-- Name: home_userprofile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.home_userprofile_id_seq', 3, true);


--
-- Name: oplog_oplog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oplog_oplog_id_seq', 1, false);


--
-- Name: oplog_oplogentry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oplog_oplogentry_id_seq', 1, false);


--
-- Name: reporting_archive_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_archive_id_seq', 1, false);


--
-- Name: reporting_doctype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_doctype_id_seq', 2, true);


--
-- Name: reporting_evidence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_evidence_id_seq', 1, false);


--
-- Name: reporting_finding_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_finding_id_seq', 1, true);


--
-- Name: reporting_findingnote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_findingnote_id_seq', 1, false);


--
-- Name: reporting_findingtype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_findingtype_id_seq', 7, true);


--
-- Name: reporting_localfindingnote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_localfindingnote_id_seq', 1, false);


--
-- Name: reporting_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_report_id_seq', 1, true);


--
-- Name: reporting_reportfindinglink_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_reportfindinglink_id_seq', 1, true);


--
-- Name: reporting_reporttemplate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_reporttemplate_id_seq', 4, true);


--
-- Name: reporting_severity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_severity_id_seq', 5, true);


--
-- Name: rolodex_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_client_id_seq', 1, true);


--
-- Name: rolodex_clientcontact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_clientcontact_id_seq', 1, true);


--
-- Name: rolodex_clientinvite_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_clientinvite_id_seq', 1, false);


--
-- Name: rolodex_clientnote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_clientnote_id_seq', 1, false);


--
-- Name: rolodex_objectivepriority_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_objectivepriority_id_seq', 3, true);


--
-- Name: rolodex_objectivestatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_objectivestatus_id_seq', 4, true);


--
-- Name: rolodex_project_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_project_id_seq', 3, true);


--
-- Name: rolodex_projectassignment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectassignment_id_seq', 2, true);


--
-- Name: rolodex_projectinvite_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectinvite_id_seq', 1, false);


--
-- Name: rolodex_projectnote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectnote_id_seq', 1, false);


--
-- Name: rolodex_projectobjective_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectobjective_id_seq', 4, true);


--
-- Name: rolodex_projectrole_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectrole_id_seq', 3, true);


--
-- Name: rolodex_projectscope_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectscope_id_seq', 3, true);


--
-- Name: rolodex_projectsubtask_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectsubtask_id_seq', 1, false);


--
-- Name: rolodex_projecttarget_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projecttarget_id_seq', 1, true);


--
-- Name: rolodex_projecttype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projecttype_id_seq', 4, true);


--
-- Name: shepherd_activitytype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_activitytype_id_seq', 2, true);


--
-- Name: shepherd_auxserveraddress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_auxserveraddress_id_seq', 1, false);


--
-- Name: shepherd_domain_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_domain_id_seq', 1, false);


--
-- Name: shepherd_domainnote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_domainnote_id_seq', 1, false);


--
-- Name: shepherd_domainserverconnection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_domainserverconnection_id_seq', 1, false);


--
-- Name: shepherd_domainstatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_domainstatus_id_seq', 5, true);


--
-- Name: shepherd_healthstatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_healthstatus_id_seq', 3, true);


--
-- Name: shepherd_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_history_id_seq', 1, false);


--
-- Name: shepherd_serverhistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_serverhistory_id_seq', 1, false);


--
-- Name: shepherd_servernote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_servernote_id_seq', 1, false);


--
-- Name: shepherd_serverprovider_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_serverprovider_id_seq', 6, true);


--
-- Name: shepherd_serverrole_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_serverrole_id_seq', 5, true);


--
-- Name: shepherd_serverstatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_serverstatus_id_seq', 3, true);


--
-- Name: shepherd_staticserver_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_staticserver_id_seq', 1, true);


--
-- Name: shepherd_transientserver_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_transientserver_id_seq', 1, false);


--
-- Name: shepherd_whoisstatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_whoisstatus_id_seq', 3, true);


--
-- Name: socialaccount_socialaccount_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.socialaccount_socialaccount_id_seq', 1, false);


--
-- Name: socialaccount_socialapp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.socialaccount_socialapp_id_seq', 1, false);


--
-- Name: socialaccount_socialapp_sites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.socialaccount_socialapp_sites_id_seq', 1, false);


--
-- Name: socialaccount_socialtoken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.socialaccount_socialtoken_id_seq', 1, false);


--
-- Name: users_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_groups_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 3, true);


--
-- Name: users_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_user_permissions_id_seq', 1, false);


--
-- Name: event_invocation_logs event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: event_log event_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.event_log
    ADD CONSTRAINT event_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_events
    ADD CONSTRAINT hdb_cron_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_resource_version_key UNIQUE (resource_version);


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_events
    ADD CONSTRAINT hdb_scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_notifications
    ADD CONSTRAINT hdb_schema_notifications_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: account_emailaddress account_emailaddress_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailaddress
    ADD CONSTRAINT account_emailaddress_email_key UNIQUE (email);


--
-- Name: account_emailaddress account_emailaddress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailaddress
    ADD CONSTRAINT account_emailaddress_pkey PRIMARY KEY (id);


--
-- Name: account_emailconfirmation account_emailconfirmation_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailconfirmation
    ADD CONSTRAINT account_emailconfirmation_key_key UNIQUE (key);


--
-- Name: account_emailconfirmation account_emailconfirmation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailconfirmation
    ADD CONSTRAINT account_emailconfirmation_pkey PRIMARY KEY (id);


--
-- Name: api_apikey api_apikey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_apikey
    ADD CONSTRAINT api_apikey_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_cloudservicesconfiguration commandcenter_cloudservicesconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_cloudservicesconfiguration
    ADD CONSTRAINT commandcenter_cloudservicesconfiguration_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_companyinformation commandcenter_companyinformation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_companyinformation
    ADD CONSTRAINT commandcenter_companyinformation_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_namecheapconfiguration commandcenter_namecheapconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_namecheapconfiguration
    ADD CONSTRAINT commandcenter_namecheapconfiguration_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_reportconfiguration commandcenter_reportconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_reportconfiguration
    ADD CONSTRAINT commandcenter_reportconfiguration_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_slackconfiguration commandcenter_slackconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_slackconfiguration
    ADD CONSTRAINT commandcenter_slackconfiguration_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_virustotalconfiguration commandcenter_virustotalconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_virustotalconfiguration
    ADD CONSTRAINT commandcenter_virustotalconfiguration_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_q_ormq django_q_ormq_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_q_ormq
    ADD CONSTRAINT django_q_ormq_pkey PRIMARY KEY (id);


--
-- Name: django_q_schedule django_q_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_q_schedule
    ADD CONSTRAINT django_q_schedule_pkey PRIMARY KEY (id);


--
-- Name: django_q_task django_q_task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_q_task
    ADD CONSTRAINT django_q_task_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: django_site django_site_domain_a2e37b91_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_site
    ADD CONSTRAINT django_site_domain_a2e37b91_uniq UNIQUE (domain);


--
-- Name: django_site django_site_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_site
    ADD CONSTRAINT django_site_pkey PRIMARY KEY (id);


--
-- Name: home_userprofile home_userprofile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home_userprofile
    ADD CONSTRAINT home_userprofile_pkey PRIMARY KEY (id);


--
-- Name: home_userprofile home_userprofile_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home_userprofile
    ADD CONSTRAINT home_userprofile_user_id_key UNIQUE (user_id);


--
-- Name: oplog_oplog oplog_oplog_name_project_id_cf3103ee_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplog
    ADD CONSTRAINT oplog_oplog_name_project_id_cf3103ee_uniq UNIQUE (name, project_id);


--
-- Name: oplog_oplog oplog_oplog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplog
    ADD CONSTRAINT oplog_oplog_pkey PRIMARY KEY (id);


--
-- Name: oplog_oplogentry oplog_oplogentry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplogentry
    ADD CONSTRAINT oplog_oplogentry_pkey PRIMARY KEY (id);


--
-- Name: reporting_archive reporting_archive_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_archive
    ADD CONSTRAINT reporting_archive_pkey PRIMARY KEY (id);


--
-- Name: reporting_doctype reporting_doctype_doc_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_doctype
    ADD CONSTRAINT reporting_doctype_doc_type_key UNIQUE (doc_type);


--
-- Name: reporting_doctype reporting_doctype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_doctype
    ADD CONSTRAINT reporting_doctype_pkey PRIMARY KEY (id);


--
-- Name: reporting_evidence reporting_evidence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_evidence
    ADD CONSTRAINT reporting_evidence_pkey PRIMARY KEY (id);


--
-- Name: reporting_finding reporting_finding_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_finding
    ADD CONSTRAINT reporting_finding_pkey PRIMARY KEY (id);


--
-- Name: reporting_finding reporting_finding_title_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_finding
    ADD CONSTRAINT reporting_finding_title_key UNIQUE (title);


--
-- Name: reporting_findingnote reporting_findingnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingnote
    ADD CONSTRAINT reporting_findingnote_pkey PRIMARY KEY (id);


--
-- Name: reporting_findingtype reporting_findingtype_finding_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingtype
    ADD CONSTRAINT reporting_findingtype_finding_type_key UNIQUE (finding_type);


--
-- Name: reporting_findingtype reporting_findingtype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingtype
    ADD CONSTRAINT reporting_findingtype_pkey PRIMARY KEY (id);


--
-- Name: reporting_localfindingnote reporting_localfindingnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_localfindingnote
    ADD CONSTRAINT reporting_localfindingnote_pkey PRIMARY KEY (id);


--
-- Name: reporting_report reporting_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report
    ADD CONSTRAINT reporting_report_pkey PRIMARY KEY (id);


--
-- Name: reporting_reportfindinglink reporting_reportfindinglink_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink
    ADD CONSTRAINT reporting_reportfindinglink_pkey PRIMARY KEY (id);


--
-- Name: reporting_reporttemplate reporting_reporttemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reporttemplate
    ADD CONSTRAINT reporting_reporttemplate_pkey PRIMARY KEY (id);


--
-- Name: reporting_severity reporting_severity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_severity
    ADD CONSTRAINT reporting_severity_pkey PRIMARY KEY (id);


--
-- Name: reporting_severity reporting_severity_severity_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_severity
    ADD CONSTRAINT reporting_severity_severity_key UNIQUE (severity);


--
-- Name: rest_framework_api_key_apikey rest_framework_api_key_apikey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rest_framework_api_key_apikey
    ADD CONSTRAINT rest_framework_api_key_apikey_pkey PRIMARY KEY (id);


--
-- Name: rest_framework_api_key_apikey rest_framework_api_key_apikey_prefix_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rest_framework_api_key_apikey
    ADD CONSTRAINT rest_framework_api_key_apikey_prefix_key UNIQUE (prefix);


--
-- Name: rolodex_client rolodex_client_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_client
    ADD CONSTRAINT rolodex_client_name_key UNIQUE (name);


--
-- Name: rolodex_client rolodex_client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_client
    ADD CONSTRAINT rolodex_client_pkey PRIMARY KEY (id);


--
-- Name: rolodex_clientcontact rolodex_clientcontact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientcontact
    ADD CONSTRAINT rolodex_clientcontact_pkey PRIMARY KEY (id);


--
-- Name: rolodex_clientinvite rolodex_clientinvite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientinvite
    ADD CONSTRAINT rolodex_clientinvite_pkey PRIMARY KEY (id);


--
-- Name: rolodex_clientnote rolodex_clientnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientnote
    ADD CONSTRAINT rolodex_clientnote_pkey PRIMARY KEY (id);


--
-- Name: rolodex_objectivepriority rolodex_objectivepriority_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivepriority
    ADD CONSTRAINT rolodex_objectivepriority_pkey PRIMARY KEY (id);


--
-- Name: rolodex_objectivepriority rolodex_objectivepriority_priority_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivepriority
    ADD CONSTRAINT rolodex_objectivepriority_priority_key UNIQUE (priority);


--
-- Name: rolodex_objectivestatus rolodex_objectivestatus_objective_status_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivestatus
    ADD CONSTRAINT rolodex_objectivestatus_objective_status_key UNIQUE (objective_status);


--
-- Name: rolodex_objectivestatus rolodex_objectivestatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivestatus
    ADD CONSTRAINT rolodex_objectivestatus_pkey PRIMARY KEY (id);


--
-- Name: rolodex_project rolodex_project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_project
    ADD CONSTRAINT rolodex_project_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectassignment rolodex_projectassignment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectassignment
    ADD CONSTRAINT rolodex_projectassignment_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectinvite rolodex_projectinvite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectinvite
    ADD CONSTRAINT rolodex_projectinvite_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectnote rolodex_projectnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectnote
    ADD CONSTRAINT rolodex_projectnote_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectobjective rolodex_projectobjective_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectobjective
    ADD CONSTRAINT rolodex_projectobjective_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectrole rolodex_projectrole_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectrole
    ADD CONSTRAINT rolodex_projectrole_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectrole rolodex_projectrole_project_role_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectrole
    ADD CONSTRAINT rolodex_projectrole_project_role_key UNIQUE (project_role);


--
-- Name: rolodex_projectscope rolodex_projectscope_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectscope
    ADD CONSTRAINT rolodex_projectscope_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectsubtask rolodex_projectsubtask_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectsubtask
    ADD CONSTRAINT rolodex_projectsubtask_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projecttarget rolodex_projecttarget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttarget
    ADD CONSTRAINT rolodex_projecttarget_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projecttype rolodex_projecttype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttype
    ADD CONSTRAINT rolodex_projecttype_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projecttype rolodex_projecttype_project_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttype
    ADD CONSTRAINT rolodex_projecttype_project_type_key UNIQUE (project_type);


--
-- Name: shepherd_activitytype shepherd_activitytype_activity_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_activitytype
    ADD CONSTRAINT shepherd_activitytype_activity_key UNIQUE (activity);


--
-- Name: shepherd_activitytype shepherd_activitytype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_activitytype
    ADD CONSTRAINT shepherd_activitytype_pkey PRIMARY KEY (id);


--
-- Name: shepherd_auxserveraddress shepherd_auxserveraddress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_auxserveraddress
    ADD CONSTRAINT shepherd_auxserveraddress_pkey PRIMARY KEY (id);


--
-- Name: shepherd_domain shepherd_domain_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_name_key UNIQUE (name);


--
-- Name: shepherd_domain shepherd_domain_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_pkey PRIMARY KEY (id);


--
-- Name: shepherd_domainnote shepherd_domainnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainnote
    ADD CONSTRAINT shepherd_domainnote_pkey PRIMARY KEY (id);


--
-- Name: shepherd_domainserverconnection shepherd_domainserverconnection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection
    ADD CONSTRAINT shepherd_domainserverconnection_pkey PRIMARY KEY (id);


--
-- Name: shepherd_domainstatus shepherd_domainstatus_domain_status_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainstatus
    ADD CONSTRAINT shepherd_domainstatus_domain_status_key UNIQUE (domain_status);


--
-- Name: shepherd_domainstatus shepherd_domainstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainstatus
    ADD CONSTRAINT shepherd_domainstatus_pkey PRIMARY KEY (id);


--
-- Name: shepherd_healthstatus shepherd_healthstatus_health_status_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_healthstatus
    ADD CONSTRAINT shepherd_healthstatus_health_status_key UNIQUE (health_status);


--
-- Name: shepherd_healthstatus shepherd_healthstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_healthstatus
    ADD CONSTRAINT shepherd_healthstatus_pkey PRIMARY KEY (id);


--
-- Name: shepherd_history shepherd_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_pkey PRIMARY KEY (id);


--
-- Name: shepherd_serverhistory shepherd_serverhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_pkey PRIMARY KEY (id);


--
-- Name: shepherd_servernote shepherd_servernote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_servernote
    ADD CONSTRAINT shepherd_servernote_pkey PRIMARY KEY (id);


--
-- Name: shepherd_serverprovider shepherd_serverprovider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverprovider
    ADD CONSTRAINT shepherd_serverprovider_pkey PRIMARY KEY (id);


--
-- Name: shepherd_serverprovider shepherd_serverprovider_server_provider_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverprovider
    ADD CONSTRAINT shepherd_serverprovider_server_provider_key UNIQUE (server_provider);


--
-- Name: shepherd_serverrole shepherd_serverrole_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverrole
    ADD CONSTRAINT shepherd_serverrole_pkey PRIMARY KEY (id);


--
-- Name: shepherd_serverrole shepherd_serverrole_server_role_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverrole
    ADD CONSTRAINT shepherd_serverrole_server_role_key UNIQUE (server_role);


--
-- Name: shepherd_serverstatus shepherd_serverstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverstatus
    ADD CONSTRAINT shepherd_serverstatus_pkey PRIMARY KEY (id);


--
-- Name: shepherd_serverstatus shepherd_serverstatus_server_status_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverstatus
    ADD CONSTRAINT shepherd_serverstatus_server_status_key UNIQUE (server_status);


--
-- Name: shepherd_staticserver shepherd_staticserver_ip_address_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver
    ADD CONSTRAINT shepherd_staticserver_ip_address_key UNIQUE (ip_address);


--
-- Name: shepherd_staticserver shepherd_staticserver_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver
    ADD CONSTRAINT shepherd_staticserver_pkey PRIMARY KEY (id);


--
-- Name: shepherd_transientserver shepherd_transientserver_ip_address_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_ip_address_key UNIQUE (ip_address);


--
-- Name: shepherd_transientserver shepherd_transientserver_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_pkey PRIMARY KEY (id);


--
-- Name: shepherd_whoisstatus shepherd_whoisstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_whoisstatus
    ADD CONSTRAINT shepherd_whoisstatus_pkey PRIMARY KEY (id);


--
-- Name: shepherd_whoisstatus shepherd_whoisstatus_whois_status_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_whoisstatus
    ADD CONSTRAINT shepherd_whoisstatus_whois_status_key UNIQUE (whois_status);


--
-- Name: socialaccount_socialaccount socialaccount_socialaccount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialaccount
    ADD CONSTRAINT socialaccount_socialaccount_pkey PRIMARY KEY (id);


--
-- Name: socialaccount_socialaccount socialaccount_socialaccount_provider_uid_fc810c6e_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialaccount
    ADD CONSTRAINT socialaccount_socialaccount_provider_uid_fc810c6e_uniq UNIQUE (provider, uid);


--
-- Name: socialaccount_socialapp_sites socialaccount_socialapp__socialapp_id_site_id_71a9a768_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp_sites
    ADD CONSTRAINT socialaccount_socialapp__socialapp_id_site_id_71a9a768_uniq UNIQUE (socialapp_id, site_id);


--
-- Name: socialaccount_socialapp socialaccount_socialapp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp
    ADD CONSTRAINT socialaccount_socialapp_pkey PRIMARY KEY (id);


--
-- Name: socialaccount_socialapp_sites socialaccount_socialapp_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp_sites
    ADD CONSTRAINT socialaccount_socialapp_sites_pkey PRIMARY KEY (id);


--
-- Name: socialaccount_socialtoken socialaccount_socialtoken_app_id_account_id_fca4e0ac_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialtoken
    ADD CONSTRAINT socialaccount_socialtoken_app_id_account_id_fca4e0ac_uniq UNIQUE (app_id, account_id);


--
-- Name: socialaccount_socialtoken socialaccount_socialtoken_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialtoken
    ADD CONSTRAINT socialaccount_socialtoken_pkey PRIMARY KEY (id);


--
-- Name: users_user_groups users_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups
    ADD CONSTRAINT users_user_groups_pkey PRIMARY KEY (id);


--
-- Name: users_user_groups users_user_groups_user_id_group_id_b88eab82_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups
    ADD CONSTRAINT users_user_groups_user_id_group_id_b88eab82_uniq UNIQUE (user_id, group_id);


--
-- Name: users_user users_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user
    ADD CONSTRAINT users_user_pkey PRIMARY KEY (id);


--
-- Name: users_user_user_permissions users_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions
    ADD CONSTRAINT users_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: users_user_user_permissions users_user_user_permissions_user_id_permission_id_43338c45_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions
    ADD CONSTRAINT users_user_user_permissions_user_id_permission_id_43338c45_uniq UNIQUE (user_id, permission_id);


--
-- Name: users_user users_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user
    ADD CONSTRAINT users_user_username_key UNIQUE (username);


--
-- Name: event_invocation_logs_event_id_idx; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX event_invocation_logs_event_id_idx ON hdb_catalog.event_invocation_logs USING btree (event_id);


--
-- Name: event_log_fetch_events; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX event_log_fetch_events ON hdb_catalog.event_log USING btree (locked NULLS FIRST, next_retry_at NULLS FIRST, created_at) WHERE ((delivered = false) AND (error = false) AND (archived = false));


--
-- Name: event_log_trigger_name_idx; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX event_log_trigger_name_idx ON hdb_catalog.event_log USING btree (trigger_name);


--
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_cron_event_invocation_event_id ON hdb_catalog.hdb_cron_event_invocation_logs USING btree (event_id);


--
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_cron_event_status ON hdb_catalog.hdb_cron_events USING btree (status);


--
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE UNIQUE INDEX hdb_cron_events_unique_scheduled ON hdb_catalog.hdb_cron_events USING btree (trigger_name, scheduled_time) WHERE (status = 'scheduled'::text);


--
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_scheduled_event_status ON hdb_catalog.hdb_scheduled_events USING btree (status);


--
-- Name: hdb_source_catalog_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE UNIQUE INDEX hdb_source_catalog_version_one_row ON hdb_catalog.hdb_source_catalog_version USING btree (((version IS NOT NULL)));


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: account_emailaddress_email_03be32b2_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX account_emailaddress_email_03be32b2_like ON public.account_emailaddress USING btree (email varchar_pattern_ops);


--
-- Name: account_emailaddress_user_id_2c513194; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX account_emailaddress_user_id_2c513194 ON public.account_emailaddress USING btree (user_id);


--
-- Name: account_emailconfirmation_email_address_id_5b7f8c58; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX account_emailconfirmation_email_address_id_5b7f8c58 ON public.account_emailconfirmation USING btree (email_address_id);


--
-- Name: account_emailconfirmation_key_f43612bd_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX account_emailconfirmation_key_f43612bd_like ON public.account_emailconfirmation USING btree (key varchar_pattern_ops);


--
-- Name: api_apikey_created_9c07f10e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_apikey_created_9c07f10e ON public.api_apikey USING btree (created);


--
-- Name: api_apikey_user_id_7ebe0e24; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_apikey_user_id_7ebe0e24 ON public.api_apikey USING btree (user_id);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: commandcenter_reportconfig_default_docx_template_id_f383cbd0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX commandcenter_reportconfig_default_docx_template_id_f383cbd0 ON public.commandcenter_reportconfiguration USING btree (default_docx_template_id);


--
-- Name: commandcenter_reportconfig_default_pptx_template_id_9fc0d6e9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX commandcenter_reportconfig_default_pptx_template_id_9fc0d6e9 ON public.commandcenter_reportconfiguration USING btree (default_pptx_template_id);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_q_task_id_32882367_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_q_task_id_32882367_like ON public.django_q_task USING btree (id varchar_pattern_ops);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: django_site_domain_a2e37b91_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_site_domain_a2e37b91_like ON public.django_site USING btree (domain varchar_pattern_ops);


--
-- Name: oplog_oplog_project_id_fe4a93f0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oplog_oplog_project_id_fe4a93f0 ON public.oplog_oplog USING btree (project_id);


--
-- Name: oplog_oplogentry_oplog_id_id_18ef13d0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oplog_oplogentry_oplog_id_id_18ef13d0 ON public.oplog_oplogentry USING btree (oplog_id_id);


--
-- Name: reporting_archive_project_id_e00a60e1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_archive_project_id_e00a60e1 ON public.reporting_archive USING btree (project_id);


--
-- Name: reporting_doctype_doc_type_4f8902f4_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_doctype_doc_type_4f8902f4_like ON public.reporting_doctype USING btree (doc_type varchar_pattern_ops);


--
-- Name: reporting_evidence_finding_id_00138d5b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_evidence_finding_id_00138d5b ON public.reporting_evidence USING btree (finding_id);


--
-- Name: reporting_evidence_uploaded_by_id_71b7b76f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_evidence_uploaded_by_id_71b7b76f ON public.reporting_evidence USING btree (uploaded_by_id);


--
-- Name: reporting_finding_finding_type_id_576232af; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_finding_finding_type_id_576232af ON public.reporting_finding USING btree (finding_type_id);


--
-- Name: reporting_finding_severity_id_c4aea0a2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_finding_severity_id_c4aea0a2 ON public.reporting_finding USING btree (severity_id);


--
-- Name: reporting_finding_title_04c8a16e_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_finding_title_04c8a16e_like ON public.reporting_finding USING btree (title varchar_pattern_ops);


--
-- Name: reporting_findingnote_finding_id_e9bb21d2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_findingnote_finding_id_e9bb21d2 ON public.reporting_findingnote USING btree (finding_id);


--
-- Name: reporting_findingnote_operator_id_ec6a14fc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_findingnote_operator_id_ec6a14fc ON public.reporting_findingnote USING btree (operator_id);


--
-- Name: reporting_findingtype_finding_type_b1ff95e7_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_findingtype_finding_type_b1ff95e7_like ON public.reporting_findingtype USING btree (finding_type varchar_pattern_ops);


--
-- Name: reporting_localfindingnote_finding_id_667858fe; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_localfindingnote_finding_id_667858fe ON public.reporting_localfindingnote USING btree (finding_id);


--
-- Name: reporting_localfindingnote_operator_id_ccc74743; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_localfindingnote_operator_id_ccc74743 ON public.reporting_localfindingnote USING btree (operator_id);


--
-- Name: reporting_report_created_by_id_1c6d7e8d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_report_created_by_id_1c6d7e8d ON public.reporting_report USING btree (created_by_id);


--
-- Name: reporting_report_docx_template_id_f9bf3a47; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_report_docx_template_id_f9bf3a47 ON public.reporting_report USING btree (docx_template_id);


--
-- Name: reporting_report_pptx_template_id_b818b902; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_report_pptx_template_id_b818b902 ON public.reporting_report USING btree (pptx_template_id);


--
-- Name: reporting_report_project_id_8d586862; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_report_project_id_8d586862 ON public.reporting_report USING btree (project_id);


--
-- Name: reporting_reportfindinglink_assigned_to_id_586a64f4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reportfindinglink_assigned_to_id_586a64f4 ON public.reporting_reportfindinglink USING btree (assigned_to_id);


--
-- Name: reporting_reportfindinglink_finding_type_id_b165acad; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reportfindinglink_finding_type_id_b165acad ON public.reporting_reportfindinglink USING btree (finding_type_id);


--
-- Name: reporting_reportfindinglink_report_id_173cdfe4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reportfindinglink_report_id_173cdfe4 ON public.reporting_reportfindinglink USING btree (report_id);


--
-- Name: reporting_reportfindinglink_severity_id_ed92c09e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reportfindinglink_severity_id_ed92c09e ON public.reporting_reportfindinglink USING btree (severity_id);


--
-- Name: reporting_reporttemplate_client_id_119d84a5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reporttemplate_client_id_119d84a5 ON public.reporting_reporttemplate USING btree (client_id);


--
-- Name: reporting_reporttemplate_doc_type_id_6e8237de; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reporttemplate_doc_type_id_6e8237de ON public.reporting_reporttemplate USING btree (doc_type_id);


--
-- Name: reporting_reporttemplate_uploaded_by_id_03b1497c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reporttemplate_uploaded_by_id_03b1497c ON public.reporting_reporttemplate USING btree (uploaded_by_id);


--
-- Name: reporting_severity_severity_22f33466_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_severity_severity_22f33466_like ON public.reporting_severity USING btree (severity varchar_pattern_ops);


--
-- Name: rest_framework_api_key_apikey_created_c61872d9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rest_framework_api_key_apikey_created_c61872d9 ON public.rest_framework_api_key_apikey USING btree (created);


--
-- Name: rest_framework_api_key_apikey_id_6e07e68e_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rest_framework_api_key_apikey_id_6e07e68e_like ON public.rest_framework_api_key_apikey USING btree (id varchar_pattern_ops);


--
-- Name: rest_framework_api_key_apikey_prefix_4e0db5f8_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rest_framework_api_key_apikey_prefix_4e0db5f8_like ON public.rest_framework_api_key_apikey USING btree (prefix varchar_pattern_ops);


--
-- Name: rolodex_client_name_98e55485_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_client_name_98e55485_like ON public.rolodex_client USING btree (name varchar_pattern_ops);


--
-- Name: rolodex_clientcontact_client_id_48f1bd5e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_clientcontact_client_id_48f1bd5e ON public.rolodex_clientcontact USING btree (client_id);


--
-- Name: rolodex_clientinvite_client_id_5d0aef60; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_clientinvite_client_id_5d0aef60 ON public.rolodex_clientinvite USING btree (client_id);


--
-- Name: rolodex_clientinvite_user_id_7ca0ba49; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_clientinvite_user_id_7ca0ba49 ON public.rolodex_clientinvite USING btree (user_id);


--
-- Name: rolodex_clientnote_client_id_c2ca9488; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_clientnote_client_id_c2ca9488 ON public.rolodex_clientnote USING btree (client_id);


--
-- Name: rolodex_clientnote_operator_id_739d4005; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_clientnote_operator_id_739d4005 ON public.rolodex_clientnote USING btree (operator_id);


--
-- Name: rolodex_objectivepriority_priority_b62df365_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_objectivepriority_priority_b62df365_like ON public.rolodex_objectivepriority USING btree (priority varchar_pattern_ops);


--
-- Name: rolodex_objectivestatus_objective_status_788992bb_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_objectivestatus_objective_status_788992bb_like ON public.rolodex_objectivestatus USING btree (objective_status varchar_pattern_ops);


--
-- Name: rolodex_project_client_id_ebd2cbf5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_project_client_id_ebd2cbf5 ON public.rolodex_project USING btree (client_id);


--
-- Name: rolodex_project_operator_id_9e407adf; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_project_operator_id_9e407adf ON public.rolodex_project USING btree (operator_id);


--
-- Name: rolodex_project_project_type_id_07953f1d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_project_project_type_id_07953f1d ON public.rolodex_project USING btree (project_type_id);


--
-- Name: rolodex_projectassignment_operator_id_c4c462d8; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectassignment_operator_id_c4c462d8 ON public.rolodex_projectassignment USING btree (operator_id);


--
-- Name: rolodex_projectassignment_project_id_ce701acc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectassignment_project_id_ce701acc ON public.rolodex_projectassignment USING btree (project_id);


--
-- Name: rolodex_projectassignment_role_id_cbab79b0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectassignment_role_id_cbab79b0 ON public.rolodex_projectassignment USING btree (role_id);


--
-- Name: rolodex_projectinvite_project_id_d510b642; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectinvite_project_id_d510b642 ON public.rolodex_projectinvite USING btree (project_id);


--
-- Name: rolodex_projectinvite_user_id_13704bd9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectinvite_user_id_13704bd9 ON public.rolodex_projectinvite USING btree (user_id);


--
-- Name: rolodex_projectnote_operator_id_5b9299b1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectnote_operator_id_5b9299b1 ON public.rolodex_projectnote USING btree (operator_id);


--
-- Name: rolodex_projectnote_project_id_79acb8a5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectnote_project_id_79acb8a5 ON public.rolodex_projectnote USING btree (project_id);


--
-- Name: rolodex_projectobjective_priority_id_cf6de852; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectobjective_priority_id_cf6de852 ON public.rolodex_projectobjective USING btree (priority_id);


--
-- Name: rolodex_projectobjective_project_id_62b27a4b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectobjective_project_id_62b27a4b ON public.rolodex_projectobjective USING btree (project_id);


--
-- Name: rolodex_projectobjective_status_id_98de9086; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectobjective_status_id_98de9086 ON public.rolodex_projectobjective USING btree (status_id);


--
-- Name: rolodex_projectrole_project_role_4166a92d_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectrole_project_role_4166a92d_like ON public.rolodex_projectrole USING btree (project_role varchar_pattern_ops);


--
-- Name: rolodex_projectscope_project_id_dcf53f05; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectscope_project_id_dcf53f05 ON public.rolodex_projectscope USING btree (project_id);


--
-- Name: rolodex_projectsubtask_parent_id_63a99f77; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectsubtask_parent_id_63a99f77 ON public.rolodex_projectsubtask USING btree (parent_id);


--
-- Name: rolodex_projectsubtask_status_id_c5e132c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectsubtask_status_id_c5e132c9 ON public.rolodex_projectsubtask USING btree (status_id);


--
-- Name: rolodex_projecttarget_project_id_69dd3e2f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projecttarget_project_id_69dd3e2f ON public.rolodex_projecttarget USING btree (project_id);


--
-- Name: rolodex_projecttype_project_type_d0196b5d_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projecttype_project_type_d0196b5d_like ON public.rolodex_projecttype USING btree (project_type varchar_pattern_ops);


--
-- Name: shepherd_activitytype_activity_63101d2c_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_activitytype_activity_63101d2c_like ON public.shepherd_activitytype USING btree (activity varchar_pattern_ops);


--
-- Name: shepherd_auxserveraddress_static_server_id_5112503d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_auxserveraddress_static_server_id_5112503d ON public.shepherd_auxserveraddress USING btree (static_server_id);


--
-- Name: shepherd_domain_domain_status_id_a2fa7330; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domain_domain_status_id_a2fa7330 ON public.shepherd_domain USING btree (domain_status_id);


--
-- Name: shepherd_domain_health_status_id_cebe65d3; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domain_health_status_id_cebe65d3 ON public.shepherd_domain USING btree (health_status_id);


--
-- Name: shepherd_domain_last_used_by_id_119db0c5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domain_last_used_by_id_119db0c5 ON public.shepherd_domain USING btree (last_used_by_id);


--
-- Name: shepherd_domain_name_41096be4_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domain_name_41096be4_like ON public.shepherd_domain USING btree (name varchar_pattern_ops);


--
-- Name: shepherd_domain_whois_status_id_a0721cb6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domain_whois_status_id_a0721cb6 ON public.shepherd_domain USING btree (whois_status_id);


--
-- Name: shepherd_domainnote_domain_id_9e6a4961; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainnote_domain_id_9e6a4961 ON public.shepherd_domainnote USING btree (domain_id);


--
-- Name: shepherd_domainnote_operator_id_040fcb51; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainnote_operator_id_040fcb51 ON public.shepherd_domainnote USING btree (operator_id);


--
-- Name: shepherd_domainserverconnection_domain_id_398e22e4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainserverconnection_domain_id_398e22e4 ON public.shepherd_domainserverconnection USING btree (domain_id);


--
-- Name: shepherd_domainserverconnection_project_id_35af0efe; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainserverconnection_project_id_35af0efe ON public.shepherd_domainserverconnection USING btree (project_id);


--
-- Name: shepherd_domainserverconnection_static_server_id_2ab6ed26; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainserverconnection_static_server_id_2ab6ed26 ON public.shepherd_domainserverconnection USING btree (static_server_id);


--
-- Name: shepherd_domainserverconnection_transient_server_id_48f0ff5a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainserverconnection_transient_server_id_48f0ff5a ON public.shepherd_domainserverconnection USING btree (transient_server_id);


--
-- Name: shepherd_domainstatus_domain_status_5c10b8e9_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainstatus_domain_status_5c10b8e9_like ON public.shepherd_domainstatus USING btree (domain_status varchar_pattern_ops);


--
-- Name: shepherd_healthstatus_health_status_17241bb6_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_healthstatus_health_status_17241bb6_like ON public.shepherd_healthstatus USING btree (health_status varchar_pattern_ops);


--
-- Name: shepherd_history_activity_type_id_a2669c34; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_history_activity_type_id_a2669c34 ON public.shepherd_history USING btree (activity_type_id);


--
-- Name: shepherd_history_client_id_89d8cfd3; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_history_client_id_89d8cfd3 ON public.shepherd_history USING btree (client_id);


--
-- Name: shepherd_history_domain_id_5ac2c2ca; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_history_domain_id_5ac2c2ca ON public.shepherd_history USING btree (domain_id);


--
-- Name: shepherd_history_operator_id_0acb0189; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_history_operator_id_0acb0189 ON public.shepherd_history USING btree (operator_id);


--
-- Name: shepherd_history_project_id_1fe0dabb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_history_project_id_1fe0dabb ON public.shepherd_history USING btree (project_id);


--
-- Name: shepherd_serverhistory_activity_type_id_b8698fb0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_activity_type_id_b8698fb0 ON public.shepherd_serverhistory USING btree (activity_type_id);


--
-- Name: shepherd_serverhistory_client_id_132ff5c2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_client_id_132ff5c2 ON public.shepherd_serverhistory USING btree (client_id);


--
-- Name: shepherd_serverhistory_operator_id_34e8e348; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_operator_id_34e8e348 ON public.shepherd_serverhistory USING btree (operator_id);


--
-- Name: shepherd_serverhistory_project_id_1c40d316; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_project_id_1c40d316 ON public.shepherd_serverhistory USING btree (project_id);


--
-- Name: shepherd_serverhistory_server_id_cd484fac; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_server_id_cd484fac ON public.shepherd_serverhistory USING btree (server_id);


--
-- Name: shepherd_serverhistory_server_role_id_d6b6cc81; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_server_role_id_d6b6cc81 ON public.shepherd_serverhistory USING btree (server_role_id);


--
-- Name: shepherd_servernote_operator_id_0645b3ab; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_servernote_operator_id_0645b3ab ON public.shepherd_servernote USING btree (operator_id);


--
-- Name: shepherd_servernote_server_id_30ba51f2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_servernote_server_id_30ba51f2 ON public.shepherd_servernote USING btree (server_id);


--
-- Name: shepherd_serverprovider_server_provider_b5fbd433_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverprovider_server_provider_b5fbd433_like ON public.shepherd_serverprovider USING btree (server_provider varchar_pattern_ops);


--
-- Name: shepherd_serverrole_server_role_083b015e_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverrole_server_role_083b015e_like ON public.shepherd_serverrole USING btree (server_role varchar_pattern_ops);


--
-- Name: shepherd_serverstatus_server_status_f5001f85_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverstatus_server_status_f5001f85_like ON public.shepherd_serverstatus USING btree (server_status varchar_pattern_ops);


--
-- Name: shepherd_staticserver_last_used_by_id_442a30d9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_staticserver_last_used_by_id_442a30d9 ON public.shepherd_staticserver USING btree (last_used_by_id);


--
-- Name: shepherd_staticserver_server_provider_id_11a19799; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_staticserver_server_provider_id_11a19799 ON public.shepherd_staticserver USING btree (server_provider_id);


--
-- Name: shepherd_staticserver_server_status_id_d41f1ab4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_staticserver_server_status_id_d41f1ab4 ON public.shepherd_staticserver USING btree (server_status_id);


--
-- Name: shepherd_transientserver_activity_type_id_97b100c2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_transientserver_activity_type_id_97b100c2 ON public.shepherd_transientserver USING btree (activity_type_id);


--
-- Name: shepherd_transientserver_operator_id_d2301a78; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_transientserver_operator_id_d2301a78 ON public.shepherd_transientserver USING btree (operator_id);


--
-- Name: shepherd_transientserver_project_id_f0e29dd2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_transientserver_project_id_f0e29dd2 ON public.shepherd_transientserver USING btree (project_id);


--
-- Name: shepherd_transientserver_server_provider_id_e89609a9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_transientserver_server_provider_id_e89609a9 ON public.shepherd_transientserver USING btree (server_provider_id);


--
-- Name: shepherd_transientserver_server_role_id_7e24d482; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_transientserver_server_role_id_7e24d482 ON public.shepherd_transientserver USING btree (server_role_id);


--
-- Name: shepherd_whoisstatus_whois_status_10b8b42e_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_whoisstatus_whois_status_10b8b42e_like ON public.shepherd_whoisstatus USING btree (whois_status varchar_pattern_ops);


--
-- Name: socialaccount_socialaccount_user_id_8146e70c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX socialaccount_socialaccount_user_id_8146e70c ON public.socialaccount_socialaccount USING btree (user_id);


--
-- Name: socialaccount_socialapp_sites_site_id_2579dee5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX socialaccount_socialapp_sites_site_id_2579dee5 ON public.socialaccount_socialapp_sites USING btree (site_id);


--
-- Name: socialaccount_socialapp_sites_socialapp_id_97fb6e7d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX socialaccount_socialapp_sites_socialapp_id_97fb6e7d ON public.socialaccount_socialapp_sites USING btree (socialapp_id);


--
-- Name: socialaccount_socialtoken_account_id_951f210e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX socialaccount_socialtoken_account_id_951f210e ON public.socialaccount_socialtoken USING btree (account_id);


--
-- Name: socialaccount_socialtoken_app_id_636a42d7; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX socialaccount_socialtoken_app_id_636a42d7 ON public.socialaccount_socialtoken USING btree (app_id);


--
-- Name: users_user_groups_group_id_9afc8d0e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_groups_group_id_9afc8d0e ON public.users_user_groups USING btree (group_id);


--
-- Name: users_user_groups_user_id_5f6f5a90; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_groups_user_id_5f6f5a90 ON public.users_user_groups USING btree (user_id);


--
-- Name: users_user_user_permissions_permission_id_0b93982e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_user_permissions_permission_id_0b93982e ON public.users_user_user_permissions USING btree (permission_id);


--
-- Name: users_user_user_permissions_user_id_20aca447; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_user_permissions_user_id_20aca447 ON public.users_user_user_permissions USING btree (user_id);


--
-- Name: users_user_username_06e46fe6_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_username_06e46fe6_like ON public.users_user USING btree (username varchar_pattern_ops);


--
-- Name: event_invocation_logs event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.event_log(id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_cron_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: account_emailaddress account_emailaddress_user_id_2c513194_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailaddress
    ADD CONSTRAINT account_emailaddress_user_id_2c513194_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: account_emailconfirmation account_emailconfirm_email_address_id_5b7f8c58_fk_account_e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailconfirmation
    ADD CONSTRAINT account_emailconfirm_email_address_id_5b7f8c58_fk_account_e FOREIGN KEY (email_address_id) REFERENCES public.account_emailaddress(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: api_apikey api_apikey_user_id_7ebe0e24_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_apikey
    ADD CONSTRAINT api_apikey_user_id_7ebe0e24_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: commandcenter_reportconfiguration commandcenter_reportconfi_default_docx_template_id_f383cbd0_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_reportconfiguration
    ADD CONSTRAINT commandcenter_reportconfi_default_docx_template_id_f383cbd0_fk FOREIGN KEY (default_docx_template_id) REFERENCES public.reporting_reporttemplate(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: commandcenter_reportconfiguration commandcenter_reportconfi_default_pptx_template_id_9fc0d6e9_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_reportconfiguration
    ADD CONSTRAINT commandcenter_reportconfi_default_pptx_template_id_9fc0d6e9_fk FOREIGN KEY (default_pptx_template_id) REFERENCES public.reporting_reporttemplate(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: home_userprofile home_userprofile_user_id_d1f7b466_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home_userprofile
    ADD CONSTRAINT home_userprofile_user_id_d1f7b466_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: oplog_oplog oplog_oplog_project_id_fe4a93f0_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplog
    ADD CONSTRAINT oplog_oplog_project_id_fe4a93f0_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: oplog_oplogentry oplog_oplogentry_oplog_id_id_18ef13d0_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplogentry
    ADD CONSTRAINT oplog_oplogentry_oplog_id_id_18ef13d0_fk FOREIGN KEY (oplog_id_id) REFERENCES public.oplog_oplog(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_archive reporting_archive_project_id_e00a60e1_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_archive
    ADD CONSTRAINT reporting_archive_project_id_e00a60e1_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_evidence reporting_evidence_finding_id_00138d5b_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_evidence
    ADD CONSTRAINT reporting_evidence_finding_id_00138d5b_fk FOREIGN KEY (finding_id) REFERENCES public.reporting_reportfindinglink(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_evidence reporting_evidence_uploaded_by_id_71b7b76f_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_evidence
    ADD CONSTRAINT reporting_evidence_uploaded_by_id_71b7b76f_fk FOREIGN KEY (uploaded_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_finding reporting_finding_finding_type_id_576232af_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_finding
    ADD CONSTRAINT reporting_finding_finding_type_id_576232af_fk FOREIGN KEY (finding_type_id) REFERENCES public.reporting_findingtype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_finding reporting_finding_severity_id_c4aea0a2_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_finding
    ADD CONSTRAINT reporting_finding_severity_id_c4aea0a2_fk FOREIGN KEY (severity_id) REFERENCES public.reporting_severity(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_findingnote reporting_findingnote_finding_id_e9bb21d2_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingnote
    ADD CONSTRAINT reporting_findingnote_finding_id_e9bb21d2_fk FOREIGN KEY (finding_id) REFERENCES public.reporting_finding(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_findingnote reporting_findingnote_operator_id_ec6a14fc_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingnote
    ADD CONSTRAINT reporting_findingnote_operator_id_ec6a14fc_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_localfindingnote reporting_localfindingnote_finding_id_667858fe_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_localfindingnote
    ADD CONSTRAINT reporting_localfindingnote_finding_id_667858fe_fk FOREIGN KEY (finding_id) REFERENCES public.reporting_reportfindinglink(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_localfindingnote reporting_localfindingnote_operator_id_ccc74743_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_localfindingnote
    ADD CONSTRAINT reporting_localfindingnote_operator_id_ccc74743_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_report reporting_report_created_by_id_1c6d7e8d_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report
    ADD CONSTRAINT reporting_report_created_by_id_1c6d7e8d_fk FOREIGN KEY (created_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_report reporting_report_docx_template_id_f9bf3a47_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report
    ADD CONSTRAINT reporting_report_docx_template_id_f9bf3a47_fk FOREIGN KEY (docx_template_id) REFERENCES public.reporting_reporttemplate(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_report reporting_report_pptx_template_id_b818b902_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report
    ADD CONSTRAINT reporting_report_pptx_template_id_b818b902_fk FOREIGN KEY (pptx_template_id) REFERENCES public.reporting_reporttemplate(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_report reporting_report_project_id_8d586862_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report
    ADD CONSTRAINT reporting_report_project_id_8d586862_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reportfindinglink reporting_reportfindinglink_assigned_to_id_586a64f4_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink
    ADD CONSTRAINT reporting_reportfindinglink_assigned_to_id_586a64f4_fk FOREIGN KEY (assigned_to_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reportfindinglink reporting_reportfindinglink_finding_type_id_b165acad_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink
    ADD CONSTRAINT reporting_reportfindinglink_finding_type_id_b165acad_fk FOREIGN KEY (finding_type_id) REFERENCES public.reporting_findingtype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reportfindinglink reporting_reportfindinglink_report_id_173cdfe4_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink
    ADD CONSTRAINT reporting_reportfindinglink_report_id_173cdfe4_fk FOREIGN KEY (report_id) REFERENCES public.reporting_report(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reportfindinglink reporting_reportfindinglink_severity_id_ed92c09e_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink
    ADD CONSTRAINT reporting_reportfindinglink_severity_id_ed92c09e_fk FOREIGN KEY (severity_id) REFERENCES public.reporting_severity(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reporttemplate reporting_reporttemplate_client_id_119d84a5_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reporttemplate
    ADD CONSTRAINT reporting_reporttemplate_client_id_119d84a5_fk FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reporttemplate reporting_reporttemplate_doc_type_id_6e8237de_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reporttemplate
    ADD CONSTRAINT reporting_reporttemplate_doc_type_id_6e8237de_fk FOREIGN KEY (doc_type_id) REFERENCES public.reporting_doctype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reporttemplate reporting_reporttemplate_uploaded_by_id_03b1497c_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reporttemplate
    ADD CONSTRAINT reporting_reporttemplate_uploaded_by_id_03b1497c_fk FOREIGN KEY (uploaded_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_clientcontact rolodex_clientcontact_client_id_48f1bd5e_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientcontact
    ADD CONSTRAINT rolodex_clientcontact_client_id_48f1bd5e_fk FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_clientinvite rolodex_clientinvite_client_id_5d0aef60_fk_rolodex_client_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientinvite
    ADD CONSTRAINT rolodex_clientinvite_client_id_5d0aef60_fk_rolodex_client_id FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_clientinvite rolodex_clientinvite_user_id_7ca0ba49_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientinvite
    ADD CONSTRAINT rolodex_clientinvite_user_id_7ca0ba49_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_clientnote rolodex_clientnote_client_id_c2ca9488_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientnote
    ADD CONSTRAINT rolodex_clientnote_client_id_c2ca9488_fk FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_clientnote rolodex_clientnote_operator_id_739d4005_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientnote
    ADD CONSTRAINT rolodex_clientnote_operator_id_739d4005_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_project rolodex_project_client_id_ebd2cbf5_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_project
    ADD CONSTRAINT rolodex_project_client_id_ebd2cbf5_fk FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_project rolodex_project_operator_id_9e407adf_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_project
    ADD CONSTRAINT rolodex_project_operator_id_9e407adf_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_project rolodex_project_project_type_id_07953f1d_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_project
    ADD CONSTRAINT rolodex_project_project_type_id_07953f1d_fk FOREIGN KEY (project_type_id) REFERENCES public.rolodex_projecttype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectassignment rolodex_projectassignment_operator_id_c4c462d8_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectassignment
    ADD CONSTRAINT rolodex_projectassignment_operator_id_c4c462d8_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectassignment rolodex_projectassignment_project_id_ce701acc_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectassignment
    ADD CONSTRAINT rolodex_projectassignment_project_id_ce701acc_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectassignment rolodex_projectassignment_role_id_cbab79b0_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectassignment
    ADD CONSTRAINT rolodex_projectassignment_role_id_cbab79b0_fk FOREIGN KEY (role_id) REFERENCES public.rolodex_projectrole(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectinvite rolodex_projectinvite_project_id_d510b642_fk_rolodex_project_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectinvite
    ADD CONSTRAINT rolodex_projectinvite_project_id_d510b642_fk_rolodex_project_id FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectinvite rolodex_projectinvite_user_id_13704bd9_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectinvite
    ADD CONSTRAINT rolodex_projectinvite_user_id_13704bd9_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectnote rolodex_projectnote_operator_id_5b9299b1_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectnote
    ADD CONSTRAINT rolodex_projectnote_operator_id_5b9299b1_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectnote rolodex_projectnote_project_id_79acb8a5_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectnote
    ADD CONSTRAINT rolodex_projectnote_project_id_79acb8a5_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectobjective rolodex_projectobjective_priority_id_cf6de852_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectobjective
    ADD CONSTRAINT rolodex_projectobjective_priority_id_cf6de852_fk FOREIGN KEY (priority_id) REFERENCES public.rolodex_objectivepriority(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectobjective rolodex_projectobjective_project_id_62b27a4b_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectobjective
    ADD CONSTRAINT rolodex_projectobjective_project_id_62b27a4b_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectobjective rolodex_projectobjective_status_id_98de9086_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectobjective
    ADD CONSTRAINT rolodex_projectobjective_status_id_98de9086_fk FOREIGN KEY (status_id) REFERENCES public.rolodex_objectivestatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectscope rolodex_projectscope_project_id_dcf53f05_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectscope
    ADD CONSTRAINT rolodex_projectscope_project_id_dcf53f05_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectsubtask rolodex_projectsubtask_parent_id_63a99f77_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectsubtask
    ADD CONSTRAINT rolodex_projectsubtask_parent_id_63a99f77_fk FOREIGN KEY (parent_id) REFERENCES public.rolodex_projectobjective(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectsubtask rolodex_projectsubtask_status_id_c5e132c9_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectsubtask
    ADD CONSTRAINT rolodex_projectsubtask_status_id_c5e132c9_fk FOREIGN KEY (status_id) REFERENCES public.rolodex_objectivestatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projecttarget rolodex_projecttarget_project_id_69dd3e2f_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttarget
    ADD CONSTRAINT rolodex_projecttarget_project_id_69dd3e2f_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_auxserveraddress shepherd_auxserveraddress_static_server_id_5112503d_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_auxserveraddress
    ADD CONSTRAINT shepherd_auxserveraddress_static_server_id_5112503d_fk FOREIGN KEY (static_server_id) REFERENCES public.shepherd_staticserver(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domain shepherd_domain_domain_status_id_a2fa7330_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_domain_status_id_a2fa7330_fk FOREIGN KEY (domain_status_id) REFERENCES public.shepherd_domainstatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domain shepherd_domain_health_status_id_cebe65d3_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_health_status_id_cebe65d3_fk FOREIGN KEY (health_status_id) REFERENCES public.shepherd_healthstatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domain shepherd_domain_last_used_by_id_119db0c5_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_last_used_by_id_119db0c5_fk FOREIGN KEY (last_used_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domain shepherd_domain_whois_status_id_a0721cb6_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_whois_status_id_a0721cb6_fk FOREIGN KEY (whois_status_id) REFERENCES public.shepherd_whoisstatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainnote shepherd_domainnote_domain_id_9e6a4961_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainnote
    ADD CONSTRAINT shepherd_domainnote_domain_id_9e6a4961_fk FOREIGN KEY (domain_id) REFERENCES public.shepherd_domain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainnote shepherd_domainnote_operator_id_040fcb51_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainnote
    ADD CONSTRAINT shepherd_domainnote_operator_id_040fcb51_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainserverconnection shepherd_domainserve_project_id_35af0efe_fk_rolodex_p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection
    ADD CONSTRAINT shepherd_domainserve_project_id_35af0efe_fk_rolodex_p FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainserverconnection shepherd_domainserverconnection_domain_id_398e22e4_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection
    ADD CONSTRAINT shepherd_domainserverconnection_domain_id_398e22e4_fk FOREIGN KEY (domain_id) REFERENCES public.shepherd_history(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainserverconnection shepherd_domainserverconnection_static_server_id_2ab6ed26_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection
    ADD CONSTRAINT shepherd_domainserverconnection_static_server_id_2ab6ed26_fk FOREIGN KEY (static_server_id) REFERENCES public.shepherd_serverhistory(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainserverconnection shepherd_domainserverconnection_transient_server_id_48f0ff5a_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection
    ADD CONSTRAINT shepherd_domainserverconnection_transient_server_id_48f0ff5a_fk FOREIGN KEY (transient_server_id) REFERENCES public.shepherd_transientserver(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_history shepherd_history_activity_type_id_a2669c34_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_activity_type_id_a2669c34_fk FOREIGN KEY (activity_type_id) REFERENCES public.shepherd_activitytype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_history shepherd_history_client_id_89d8cfd3_fk_rolodex_client_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_client_id_89d8cfd3_fk_rolodex_client_id FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_history shepherd_history_domain_id_5ac2c2ca_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_domain_id_5ac2c2ca_fk FOREIGN KEY (domain_id) REFERENCES public.shepherd_domain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_history shepherd_history_operator_id_0acb0189_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_operator_id_0acb0189_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_history shepherd_history_project_id_1fe0dabb_fk_rolodex_project_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_project_id_1fe0dabb_fk_rolodex_project_id FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhisto_project_id_1c40d316_fk_rolodex_p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhisto_project_id_1c40d316_fk_rolodex_p FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhistory_activity_type_id_b8698fb0_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_activity_type_id_b8698fb0_fk FOREIGN KEY (activity_type_id) REFERENCES public.shepherd_activitytype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhistory_client_id_132ff5c2_fk_rolodex_client_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_client_id_132ff5c2_fk_rolodex_client_id FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhistory_operator_id_34e8e348_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_operator_id_34e8e348_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhistory_server_id_cd484fac_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_server_id_cd484fac_fk FOREIGN KEY (server_id) REFERENCES public.shepherd_staticserver(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhistory_server_role_id_d6b6cc81_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_server_role_id_d6b6cc81_fk FOREIGN KEY (server_role_id) REFERENCES public.shepherd_serverrole(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_servernote shepherd_servernote_operator_id_0645b3ab_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_servernote
    ADD CONSTRAINT shepherd_servernote_operator_id_0645b3ab_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_servernote shepherd_servernote_server_id_30ba51f2_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_servernote
    ADD CONSTRAINT shepherd_servernote_server_id_30ba51f2_fk FOREIGN KEY (server_id) REFERENCES public.shepherd_staticserver(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_staticserver shepherd_staticserver_last_used_by_id_442a30d9_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver
    ADD CONSTRAINT shepherd_staticserver_last_used_by_id_442a30d9_fk FOREIGN KEY (last_used_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_staticserver shepherd_staticserver_server_provider_id_11a19799_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver
    ADD CONSTRAINT shepherd_staticserver_server_provider_id_11a19799_fk FOREIGN KEY (server_provider_id) REFERENCES public.shepherd_serverprovider(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_staticserver shepherd_staticserver_server_status_id_d41f1ab4_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver
    ADD CONSTRAINT shepherd_staticserver_server_status_id_d41f1ab4_fk FOREIGN KEY (server_status_id) REFERENCES public.shepherd_serverstatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_transientserver shepherd_transientse_project_id_f0e29dd2_fk_rolodex_p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientse_project_id_f0e29dd2_fk_rolodex_p FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_transientserver shepherd_transientserver_activity_type_id_97b100c2_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_activity_type_id_97b100c2_fk FOREIGN KEY (activity_type_id) REFERENCES public.shepherd_activitytype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_transientserver shepherd_transientserver_operator_id_d2301a78_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_operator_id_d2301a78_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_transientserver shepherd_transientserver_server_provider_id_e89609a9_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_server_provider_id_e89609a9_fk FOREIGN KEY (server_provider_id) REFERENCES public.shepherd_serverprovider(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_transientserver shepherd_transientserver_server_role_id_7e24d482_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_server_role_id_7e24d482_fk FOREIGN KEY (server_role_id) REFERENCES public.shepherd_serverrole(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: socialaccount_socialtoken socialaccount_social_account_id_951f210e_fk_socialacc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialtoken
    ADD CONSTRAINT socialaccount_social_account_id_951f210e_fk_socialacc FOREIGN KEY (account_id) REFERENCES public.socialaccount_socialaccount(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: socialaccount_socialtoken socialaccount_social_app_id_636a42d7_fk_socialacc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialtoken
    ADD CONSTRAINT socialaccount_social_app_id_636a42d7_fk_socialacc FOREIGN KEY (app_id) REFERENCES public.socialaccount_socialapp(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: socialaccount_socialapp_sites socialaccount_social_site_id_2579dee5_fk_django_si; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp_sites
    ADD CONSTRAINT socialaccount_social_site_id_2579dee5_fk_django_si FOREIGN KEY (site_id) REFERENCES public.django_site(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: socialaccount_socialapp_sites socialaccount_social_socialapp_id_97fb6e7d_fk_socialacc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp_sites
    ADD CONSTRAINT socialaccount_social_socialapp_id_97fb6e7d_fk_socialacc FOREIGN KEY (socialapp_id) REFERENCES public.socialaccount_socialapp(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: socialaccount_socialaccount socialaccount_socialaccount_user_id_8146e70c_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialaccount
    ADD CONSTRAINT socialaccount_socialaccount_user_id_8146e70c_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_user_groups users_user_groups_group_id_9afc8d0e_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups
    ADD CONSTRAINT users_user_groups_group_id_9afc8d0e_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_user_user_permissions users_user_user_perm_permission_id_0b93982e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions
    ADD CONSTRAINT users_user_user_perm_permission_id_0b93982e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.12 (Debian 11.12-1.pgdg90+1)
-- Dumped by pg_dump version 11.12 (Debian 11.12-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE postgres;
--
-- Name: postgres; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE postgres OWNER TO postgres;

\connect postgres

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.12 (Debian 11.12-1.pgdg90+1)
-- Dumped by pg_dump version 11.12 (Debian 11.12-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: test_ghostwriter; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE test_ghostwriter WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE test_ghostwriter OWNER TO postgres;

\connect test_ghostwriter

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_emailaddress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_emailaddress (
    id integer NOT NULL,
    email character varying(254) NOT NULL,
    verified boolean NOT NULL,
    "primary" boolean NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.account_emailaddress OWNER TO postgres;

--
-- Name: account_emailaddress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_emailaddress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_emailaddress_id_seq OWNER TO postgres;

--
-- Name: account_emailaddress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_emailaddress_id_seq OWNED BY public.account_emailaddress.id;


--
-- Name: account_emailconfirmation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_emailconfirmation (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    sent timestamp with time zone,
    key character varying(64) NOT NULL,
    email_address_id integer NOT NULL
);


ALTER TABLE public.account_emailconfirmation OWNER TO postgres;

--
-- Name: account_emailconfirmation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_emailconfirmation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_emailconfirmation_id_seq OWNER TO postgres;

--
-- Name: account_emailconfirmation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_emailconfirmation_id_seq OWNED BY public.account_emailconfirmation.id;


--
-- Name: api_apikey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_apikey (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token text NOT NULL,
    created timestamp with time zone NOT NULL,
    expiry_date timestamp with time zone,
    revoked boolean NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.api_apikey OWNER TO postgres;

--
-- Name: api_apikey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.api_apikey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.api_apikey_id_seq OWNER TO postgres;

--
-- Name: api_apikey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.api_apikey_id_seq OWNED BY public.api_apikey.id;


--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- Name: commandcenter_cloudservicesconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_cloudservicesconfiguration (
    id bigint NOT NULL,
    enable boolean NOT NULL,
    aws_key character varying(255) NOT NULL,
    aws_secret character varying(255) NOT NULL,
    do_api_key character varying(255) NOT NULL,
    ignore_tag character varying(255) NOT NULL,
    notification_delay integer NOT NULL
);


ALTER TABLE public.commandcenter_cloudservicesconfiguration OWNER TO postgres;

--
-- Name: commandcenter_cloudservicesconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_cloudservicesconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_cloudservicesconfiguration_id_seq OWNER TO postgres;

--
-- Name: commandcenter_cloudservicesconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_cloudservicesconfiguration_id_seq OWNED BY public.commandcenter_cloudservicesconfiguration.id;


--
-- Name: commandcenter_companyinformation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_companyinformation (
    id bigint NOT NULL,
    company_name character varying(255) NOT NULL,
    company_twitter character varying(255) NOT NULL,
    company_email character varying(255) NOT NULL
);


ALTER TABLE public.commandcenter_companyinformation OWNER TO postgres;

--
-- Name: commandcenter_companyinformation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_companyinformation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_companyinformation_id_seq OWNER TO postgres;

--
-- Name: commandcenter_companyinformation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_companyinformation_id_seq OWNED BY public.commandcenter_companyinformation.id;


--
-- Name: commandcenter_namecheapconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_namecheapconfiguration (
    id bigint NOT NULL,
    enable boolean NOT NULL,
    api_key character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    api_username character varying(255) NOT NULL,
    client_ip character varying(255) NOT NULL,
    page_size integer NOT NULL
);


ALTER TABLE public.commandcenter_namecheapconfiguration OWNER TO postgres;

--
-- Name: commandcenter_namecheapconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_namecheapconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_namecheapconfiguration_id_seq OWNER TO postgres;

--
-- Name: commandcenter_namecheapconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_namecheapconfiguration_id_seq OWNED BY public.commandcenter_namecheapconfiguration.id;


--
-- Name: commandcenter_reportconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_reportconfiguration (
    id bigint NOT NULL,
    border_weight integer NOT NULL,
    border_color character varying(6) NOT NULL,
    prefix_figure character varying(255) NOT NULL,
    prefix_table character varying(255) NOT NULL,
    default_docx_template_id bigint,
    default_pptx_template_id bigint,
    enable_borders boolean NOT NULL,
    label_figure character varying(255) NOT NULL,
    label_table character varying(255) NOT NULL
);


ALTER TABLE public.commandcenter_reportconfiguration OWNER TO postgres;

--
-- Name: commandcenter_reportconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_reportconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_reportconfiguration_id_seq OWNER TO postgres;

--
-- Name: commandcenter_reportconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_reportconfiguration_id_seq OWNED BY public.commandcenter_reportconfiguration.id;


--
-- Name: commandcenter_slackconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_slackconfiguration (
    id bigint NOT NULL,
    enable boolean NOT NULL,
    webhook_url character varying(255) NOT NULL,
    slack_emoji character varying(255) NOT NULL,
    slack_channel character varying(255) NOT NULL,
    slack_username character varying(255) NOT NULL,
    slack_alert_target character varying(255) NOT NULL
);


ALTER TABLE public.commandcenter_slackconfiguration OWNER TO postgres;

--
-- Name: commandcenter_slackconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_slackconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_slackconfiguration_id_seq OWNER TO postgres;

--
-- Name: commandcenter_slackconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_slackconfiguration_id_seq OWNED BY public.commandcenter_slackconfiguration.id;


--
-- Name: commandcenter_virustotalconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commandcenter_virustotalconfiguration (
    id bigint NOT NULL,
    enable boolean NOT NULL,
    api_key character varying(255) NOT NULL,
    sleep_time integer NOT NULL
);


ALTER TABLE public.commandcenter_virustotalconfiguration OWNER TO postgres;

--
-- Name: commandcenter_virustotalconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commandcenter_virustotalconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commandcenter_virustotalconfiguration_id_seq OWNER TO postgres;

--
-- Name: commandcenter_virustotalconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commandcenter_virustotalconfiguration_id_seq OWNED BY public.commandcenter_virustotalconfiguration.id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id bigint NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- Name: django_q_ormq; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_q_ormq (
    id integer NOT NULL,
    key character varying(100) NOT NULL,
    payload text NOT NULL,
    lock timestamp with time zone
);


ALTER TABLE public.django_q_ormq OWNER TO postgres;

--
-- Name: django_q_ormq_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_q_ormq_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_q_ormq_id_seq OWNER TO postgres;

--
-- Name: django_q_ormq_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_q_ormq_id_seq OWNED BY public.django_q_ormq.id;


--
-- Name: django_q_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_q_schedule (
    id integer NOT NULL,
    func character varying(256) NOT NULL,
    hook character varying(256),
    args text,
    kwargs text,
    schedule_type character varying(1) NOT NULL,
    repeats integer NOT NULL,
    next_run timestamp with time zone,
    task character varying(100),
    name character varying(100),
    minutes smallint,
    cron character varying(100),
    cluster character varying(100),
    CONSTRAINT django_q_schedule_minutes_check CHECK ((minutes >= 0))
);


ALTER TABLE public.django_q_schedule OWNER TO postgres;

--
-- Name: django_q_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_q_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_q_schedule_id_seq OWNER TO postgres;

--
-- Name: django_q_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_q_schedule_id_seq OWNED BY public.django_q_schedule.id;


--
-- Name: django_q_task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_q_task (
    name character varying(100) NOT NULL,
    func character varying(256) NOT NULL,
    hook character varying(256),
    args text,
    kwargs text,
    result text,
    started timestamp with time zone NOT NULL,
    stopped timestamp with time zone NOT NULL,
    success boolean NOT NULL,
    id character varying(32) NOT NULL,
    "group" character varying(100),
    attempt_count integer NOT NULL
);


ALTER TABLE public.django_q_task OWNER TO postgres;

--
-- Name: django_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO postgres;

--
-- Name: django_site; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_site (
    id integer NOT NULL,
    domain character varying(100) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.django_site OWNER TO postgres;

--
-- Name: django_site_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_site_id_seq OWNER TO postgres;

--
-- Name: django_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_site_id_seq OWNED BY public.django_site.id;


--
-- Name: home_userprofile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.home_userprofile (
    id bigint NOT NULL,
    avatar character varying(100) NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.home_userprofile OWNER TO postgres;

--
-- Name: home_userprofile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.home_userprofile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.home_userprofile_id_seq OWNER TO postgres;

--
-- Name: home_userprofile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.home_userprofile_id_seq OWNED BY public.home_userprofile.id;


--
-- Name: oplog_oplog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oplog_oplog (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    project_id bigint
);


ALTER TABLE public.oplog_oplog OWNER TO postgres;

--
-- Name: oplog_oplog_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oplog_oplog_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oplog_oplog_id_seq OWNER TO postgres;

--
-- Name: oplog_oplog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oplog_oplog_id_seq OWNED BY public.oplog_oplog.id;


--
-- Name: oplog_oplogentry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oplog_oplogentry (
    id bigint NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    source_ip text NOT NULL,
    dest_ip text NOT NULL,
    tool text NOT NULL,
    user_context text NOT NULL,
    command text NOT NULL,
    description text NOT NULL,
    output text,
    comments text NOT NULL,
    operator_name character varying(255) NOT NULL,
    oplog_id_id bigint
);


ALTER TABLE public.oplog_oplogentry OWNER TO postgres;

--
-- Name: oplog_oplogentry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oplog_oplogentry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oplog_oplogentry_id_seq OWNER TO postgres;

--
-- Name: oplog_oplogentry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oplog_oplogentry_id_seq OWNED BY public.oplog_oplogentry.id;


--
-- Name: reporting_archive; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_archive (
    id bigint NOT NULL,
    report_archive character varying(100) NOT NULL,
    project_id bigint
);


ALTER TABLE public.reporting_archive OWNER TO postgres;

--
-- Name: reporting_archive_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_archive_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_archive_id_seq OWNER TO postgres;

--
-- Name: reporting_archive_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_archive_id_seq OWNED BY public.reporting_archive.id;


--
-- Name: reporting_doctype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_doctype (
    id bigint NOT NULL,
    doc_type character varying(5) NOT NULL
);


ALTER TABLE public.reporting_doctype OWNER TO postgres;

--
-- Name: reporting_doctype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_doctype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_doctype_id_seq OWNER TO postgres;

--
-- Name: reporting_doctype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_doctype_id_seq OWNED BY public.reporting_doctype.id;


--
-- Name: reporting_evidence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_evidence (
    id bigint NOT NULL,
    document character varying(100) NOT NULL,
    friendly_name character varying(255),
    upload_date date NOT NULL,
    caption character varying(255) NOT NULL,
    description text NOT NULL,
    finding_id bigint NOT NULL,
    uploaded_by_id bigint
);


ALTER TABLE public.reporting_evidence OWNER TO postgres;

--
-- Name: reporting_evidence_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_evidence_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_evidence_id_seq OWNER TO postgres;

--
-- Name: reporting_evidence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_evidence_id_seq OWNED BY public.reporting_evidence.id;


--
-- Name: reporting_finding; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_finding (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    impact text,
    mitigation text,
    replication_steps text,
    host_detection_techniques text,
    network_detection_techniques text,
    "references" text,
    finding_guidance text,
    finding_type_id bigint,
    severity_id bigint,
    cvss_score double precision,
    cvss_vector character varying(54) NOT NULL
);


ALTER TABLE public.reporting_finding OWNER TO postgres;

--
-- Name: reporting_finding_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_finding_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_finding_id_seq OWNER TO postgres;

--
-- Name: reporting_finding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_finding_id_seq OWNED BY public.reporting_finding.id;


--
-- Name: reporting_findingnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_findingnote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    finding_id bigint NOT NULL,
    operator_id bigint
);


ALTER TABLE public.reporting_findingnote OWNER TO postgres;

--
-- Name: reporting_findingnote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_findingnote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_findingnote_id_seq OWNER TO postgres;

--
-- Name: reporting_findingnote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_findingnote_id_seq OWNED BY public.reporting_findingnote.id;


--
-- Name: reporting_findingtype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_findingtype (
    id bigint NOT NULL,
    finding_type character varying(255) NOT NULL
);


ALTER TABLE public.reporting_findingtype OWNER TO postgres;

--
-- Name: reporting_findingtype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_findingtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_findingtype_id_seq OWNER TO postgres;

--
-- Name: reporting_findingtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_findingtype_id_seq OWNED BY public.reporting_findingtype.id;


--
-- Name: reporting_localfindingnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_localfindingnote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    finding_id bigint NOT NULL,
    operator_id bigint
);


ALTER TABLE public.reporting_localfindingnote OWNER TO postgres;

--
-- Name: reporting_localfindingnote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_localfindingnote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_localfindingnote_id_seq OWNER TO postgres;

--
-- Name: reporting_localfindingnote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_localfindingnote_id_seq OWNED BY public.reporting_localfindingnote.id;


--
-- Name: reporting_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_report (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    creation date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_update date NOT NULL,
    complete boolean DEFAULT false NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    created_by_id bigint,
    project_id bigint,
    delivered boolean DEFAULT false NOT NULL,
    docx_template_id bigint,
    pptx_template_id bigint
);


ALTER TABLE public.reporting_report OWNER TO postgres;

--
-- Name: reporting_report_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_report_id_seq OWNER TO postgres;

--
-- Name: reporting_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_report_id_seq OWNED BY public.reporting_report.id;


--
-- Name: reporting_reportfindinglink; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_reportfindinglink (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    "position" integer NOT NULL,
    affected_entities text,
    description text,
    impact text,
    mitigation text,
    replication_steps text,
    host_detection_techniques text,
    network_detection_techniques text,
    "references" text,
    complete boolean NOT NULL,
    assigned_to_id bigint,
    finding_type_id bigint,
    report_id bigint,
    severity_id bigint,
    finding_guidance text,
    cvss_score double precision,
    cvss_vector character varying(54) NOT NULL
);


ALTER TABLE public.reporting_reportfindinglink OWNER TO postgres;

--
-- Name: reporting_reportfindinglink_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_reportfindinglink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_reportfindinglink_id_seq OWNER TO postgres;

--
-- Name: reporting_reportfindinglink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_reportfindinglink_id_seq OWNED BY public.reporting_reportfindinglink.id;


--
-- Name: reporting_reporttemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_reporttemplate (
    id bigint NOT NULL,
    document character varying(100) NOT NULL,
    name character varying(255),
    upload_date date NOT NULL,
    last_update date NOT NULL,
    description text NOT NULL,
    protected boolean DEFAULT false NOT NULL,
    client_id bigint,
    uploaded_by_id bigint,
    lint_result jsonb,
    changelog text,
    doc_type_id bigint
);


ALTER TABLE public.reporting_reporttemplate OWNER TO postgres;

--
-- Name: reporting_reporttemplate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_reporttemplate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_reporttemplate_id_seq OWNER TO postgres;

--
-- Name: reporting_reporttemplate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_reporttemplate_id_seq OWNED BY public.reporting_reporttemplate.id;


--
-- Name: reporting_severity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reporting_severity (
    id bigint NOT NULL,
    severity character varying(255) NOT NULL,
    weight integer NOT NULL,
    color character varying(6) NOT NULL
);


ALTER TABLE public.reporting_severity OWNER TO postgres;

--
-- Name: reporting_severity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reporting_severity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reporting_severity_id_seq OWNER TO postgres;

--
-- Name: reporting_severity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reporting_severity_id_seq OWNED BY public.reporting_severity.id;


--
-- Name: rest_framework_api_key_apikey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rest_framework_api_key_apikey (
    id character varying(150) NOT NULL,
    created timestamp with time zone NOT NULL,
    name character varying(50) NOT NULL,
    revoked boolean NOT NULL,
    expiry_date timestamp with time zone,
    hashed_key character varying(150) NOT NULL,
    prefix character varying(8) NOT NULL
);


ALTER TABLE public.rest_framework_api_key_apikey OWNER TO postgres;

--
-- Name: rolodex_client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_client (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    short_name character varying(255),
    codename character varying(255),
    note text,
    address text,
    timezone character varying(63) DEFAULT 'America/Los_Angeles'::character varying NOT NULL
);


ALTER TABLE public.rolodex_client OWNER TO postgres;

--
-- Name: rolodex_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_client_id_seq OWNER TO postgres;

--
-- Name: rolodex_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_client_id_seq OWNED BY public.rolodex_client.id;


--
-- Name: rolodex_clientcontact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_clientcontact (
    id bigint NOT NULL,
    name character varying(255),
    job_title character varying(255),
    email character varying(255),
    phone character varying(50),
    note text,
    client_id bigint NOT NULL,
    timezone character varying(63) DEFAULT 'America/Los_Angeles'::character varying NOT NULL
);


ALTER TABLE public.rolodex_clientcontact OWNER TO postgres;

--
-- Name: rolodex_clientcontact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_clientcontact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_clientcontact_id_seq OWNER TO postgres;

--
-- Name: rolodex_clientcontact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_clientcontact_id_seq OWNED BY public.rolodex_clientcontact.id;


--
-- Name: rolodex_clientinvite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_clientinvite (
    id bigint NOT NULL,
    comment text,
    client_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.rolodex_clientinvite OWNER TO postgres;

--
-- Name: rolodex_clientinvite_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_clientinvite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_clientinvite_id_seq OWNER TO postgres;

--
-- Name: rolodex_clientinvite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_clientinvite_id_seq OWNED BY public.rolodex_clientinvite.id;


--
-- Name: rolodex_clientnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_clientnote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    client_id bigint NOT NULL,
    operator_id bigint
);


ALTER TABLE public.rolodex_clientnote OWNER TO postgres;

--
-- Name: rolodex_clientnote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_clientnote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_clientnote_id_seq OWNER TO postgres;

--
-- Name: rolodex_clientnote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_clientnote_id_seq OWNED BY public.rolodex_clientnote.id;


--
-- Name: rolodex_objectivepriority; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_objectivepriority (
    id bigint NOT NULL,
    weight integer NOT NULL,
    priority character varying(255) NOT NULL
);


ALTER TABLE public.rolodex_objectivepriority OWNER TO postgres;

--
-- Name: rolodex_objectivepriority_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_objectivepriority_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_objectivepriority_id_seq OWNER TO postgres;

--
-- Name: rolodex_objectivepriority_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_objectivepriority_id_seq OWNED BY public.rolodex_objectivepriority.id;


--
-- Name: rolodex_objectivestatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_objectivestatus (
    id bigint NOT NULL,
    objective_status character varying(255) NOT NULL
);


ALTER TABLE public.rolodex_objectivestatus OWNER TO postgres;

--
-- Name: rolodex_objectivestatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_objectivestatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_objectivestatus_id_seq OWNER TO postgres;

--
-- Name: rolodex_objectivestatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_objectivestatus_id_seq OWNED BY public.rolodex_objectivestatus.id;


--
-- Name: rolodex_project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_project (
    id bigint NOT NULL,
    codename character varying(255),
    start_date date NOT NULL,
    end_date date NOT NULL,
    note text,
    slack_channel character varying(255),
    complete boolean DEFAULT false NOT NULL,
    client_id bigint NOT NULL,
    operator_id bigint,
    project_type_id bigint NOT NULL,
    timezone character varying(63) DEFAULT 'America/Los_Angeles'::character varying NOT NULL,
    end_time time without time zone,
    start_time time without time zone
);


ALTER TABLE public.rolodex_project OWNER TO postgres;

--
-- Name: rolodex_project_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_project_id_seq OWNER TO postgres;

--
-- Name: rolodex_project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_project_id_seq OWNED BY public.rolodex_project.id;


--
-- Name: rolodex_projectassignment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectassignment (
    id bigint NOT NULL,
    start_date date,
    end_date date,
    note text,
    operator_id bigint,
    project_id bigint NOT NULL,
    role_id bigint
);


ALTER TABLE public.rolodex_projectassignment OWNER TO postgres;

--
-- Name: rolodex_projectassignment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectassignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectassignment_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectassignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectassignment_id_seq OWNED BY public.rolodex_projectassignment.id;


--
-- Name: rolodex_projectinvite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectinvite (
    id bigint NOT NULL,
    comment text,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.rolodex_projectinvite OWNER TO postgres;

--
-- Name: rolodex_projectinvite_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectinvite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectinvite_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectinvite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectinvite_id_seq OWNED BY public.rolodex_projectinvite.id;


--
-- Name: rolodex_projectnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectnote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    operator_id bigint,
    project_id bigint NOT NULL
);


ALTER TABLE public.rolodex_projectnote OWNER TO postgres;

--
-- Name: rolodex_projectnote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectnote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectnote_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectnote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectnote_id_seq OWNED BY public.rolodex_projectnote.id;


--
-- Name: rolodex_projectobjective; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectobjective (
    id bigint NOT NULL,
    objective character varying(255),
    complete boolean DEFAULT false NOT NULL,
    deadline date,
    project_id bigint NOT NULL,
    status_id bigint NOT NULL,
    marked_complete date,
    description text,
    priority_id bigint,
    "position" integer NOT NULL
);


ALTER TABLE public.rolodex_projectobjective OWNER TO postgres;

--
-- Name: rolodex_projectobjective_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectobjective_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectobjective_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectobjective_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectobjective_id_seq OWNED BY public.rolodex_projectobjective.id;


--
-- Name: rolodex_projectrole; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectrole (
    id bigint NOT NULL,
    project_role character varying(255) NOT NULL
);


ALTER TABLE public.rolodex_projectrole OWNER TO postgres;

--
-- Name: rolodex_projectrole_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectrole_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectrole_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectrole_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectrole_id_seq OWNED BY public.rolodex_projectrole.id;


--
-- Name: rolodex_projectscope; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectscope (
    id bigint NOT NULL,
    name character varying(255),
    scope text,
    description text,
    disallowed boolean DEFAULT false NOT NULL,
    requires_caution boolean DEFAULT false NOT NULL,
    project_id bigint NOT NULL
);


ALTER TABLE public.rolodex_projectscope OWNER TO postgres;

--
-- Name: rolodex_projectscope_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectscope_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectscope_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectscope_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectscope_id_seq OWNED BY public.rolodex_projectscope.id;


--
-- Name: rolodex_projectsubtask; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projectsubtask (
    id bigint NOT NULL,
    task text,
    complete boolean DEFAULT false NOT NULL,
    deadline date,
    parent_id bigint NOT NULL,
    status_id bigint NOT NULL,
    marked_complete date
);


ALTER TABLE public.rolodex_projectsubtask OWNER TO postgres;

--
-- Name: rolodex_projectsubtask_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projectsubtask_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projectsubtask_id_seq OWNER TO postgres;

--
-- Name: rolodex_projectsubtask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projectsubtask_id_seq OWNED BY public.rolodex_projectsubtask.id;


--
-- Name: rolodex_projecttarget; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projecttarget (
    id bigint NOT NULL,
    ip_address inet,
    hostname character varying(255),
    note text,
    compromised boolean DEFAULT false NOT NULL,
    project_id bigint NOT NULL
);


ALTER TABLE public.rolodex_projecttarget OWNER TO postgres;

--
-- Name: rolodex_projecttarget_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projecttarget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projecttarget_id_seq OWNER TO postgres;

--
-- Name: rolodex_projecttarget_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projecttarget_id_seq OWNED BY public.rolodex_projecttarget.id;


--
-- Name: rolodex_projecttype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolodex_projecttype (
    id bigint NOT NULL,
    project_type character varying(255) NOT NULL
);


ALTER TABLE public.rolodex_projecttype OWNER TO postgres;

--
-- Name: rolodex_projecttype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rolodex_projecttype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rolodex_projecttype_id_seq OWNER TO postgres;

--
-- Name: rolodex_projecttype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rolodex_projecttype_id_seq OWNED BY public.rolodex_projecttype.id;


--
-- Name: shepherd_activitytype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_activitytype (
    id bigint NOT NULL,
    activity character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_activitytype OWNER TO postgres;

--
-- Name: shepherd_activitytype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_activitytype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_activitytype_id_seq OWNER TO postgres;

--
-- Name: shepherd_activitytype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_activitytype_id_seq OWNED BY public.shepherd_activitytype.id;


--
-- Name: shepherd_auxserveraddress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_auxserveraddress (
    id bigint NOT NULL,
    ip_address inet,
    static_server_id bigint NOT NULL,
    "primary" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.shepherd_auxserveraddress OWNER TO postgres;

--
-- Name: shepherd_auxserveraddress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_auxserveraddress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_auxserveraddress_id_seq OWNER TO postgres;

--
-- Name: shepherd_auxserveraddress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_auxserveraddress_id_seq OWNED BY public.shepherd_auxserveraddress.id;


--
-- Name: shepherd_domain; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_domain (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    registrar character varying(255),
    creation date NOT NULL,
    expiration date NOT NULL,
    note text,
    burned_explanation text,
    domain_status_id bigint,
    health_status_id bigint,
    last_used_by_id bigint,
    whois_status_id bigint,
    auto_renew boolean DEFAULT false NOT NULL,
    expired boolean DEFAULT false NOT NULL,
    last_health_check date,
    vt_permalink character varying(255),
    reset_dns boolean DEFAULT false NOT NULL,
    categorization jsonb,
    dns jsonb
);


ALTER TABLE public.shepherd_domain OWNER TO postgres;

--
-- Name: shepherd_domain_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_domain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_domain_id_seq OWNER TO postgres;

--
-- Name: shepherd_domain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_domain_id_seq OWNED BY public.shepherd_domain.id;


--
-- Name: shepherd_domainnote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_domainnote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    domain_id bigint NOT NULL,
    operator_id bigint
);


ALTER TABLE public.shepherd_domainnote OWNER TO postgres;

--
-- Name: shepherd_domainnote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_domainnote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_domainnote_id_seq OWNER TO postgres;

--
-- Name: shepherd_domainnote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_domainnote_id_seq OWNED BY public.shepherd_domainnote.id;


--
-- Name: shepherd_domainserverconnection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_domainserverconnection (
    id bigint NOT NULL,
    endpoint character varying(255),
    subdomain character varying(255) DEFAULT '*'::character varying,
    domain_id bigint NOT NULL,
    project_id bigint NOT NULL,
    static_server_id bigint,
    transient_server_id bigint,
    CONSTRAINT only_one_server CHECK ((((static_server_id IS NOT NULL) AND (transient_server_id IS NULL)) OR ((static_server_id IS NULL) AND (transient_server_id IS NOT NULL))))
);


ALTER TABLE public.shepherd_domainserverconnection OWNER TO postgres;

--
-- Name: shepherd_domainserverconnection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_domainserverconnection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_domainserverconnection_id_seq OWNER TO postgres;

--
-- Name: shepherd_domainserverconnection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_domainserverconnection_id_seq OWNED BY public.shepherd_domainserverconnection.id;


--
-- Name: shepherd_domainstatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_domainstatus (
    id bigint NOT NULL,
    domain_status character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_domainstatus OWNER TO postgres;

--
-- Name: shepherd_domainstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_domainstatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_domainstatus_id_seq OWNER TO postgres;

--
-- Name: shepherd_domainstatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_domainstatus_id_seq OWNED BY public.shepherd_domainstatus.id;


--
-- Name: shepherd_healthstatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_healthstatus (
    id bigint NOT NULL,
    health_status character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_healthstatus OWNER TO postgres;

--
-- Name: shepherd_healthstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_healthstatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_healthstatus_id_seq OWNER TO postgres;

--
-- Name: shepherd_healthstatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_healthstatus_id_seq OWNED BY public.shepherd_healthstatus.id;


--
-- Name: shepherd_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_history (
    id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    note text,
    activity_type_id bigint NOT NULL,
    client_id bigint NOT NULL,
    domain_id bigint NOT NULL,
    operator_id bigint,
    project_id bigint
);


ALTER TABLE public.shepherd_history OWNER TO postgres;

--
-- Name: shepherd_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_history_id_seq OWNER TO postgres;

--
-- Name: shepherd_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_history_id_seq OWNED BY public.shepherd_history.id;


--
-- Name: shepherd_serverhistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_serverhistory (
    id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    note text,
    activity_type_id bigint NOT NULL,
    client_id bigint NOT NULL,
    operator_id bigint,
    project_id bigint,
    server_id bigint NOT NULL,
    server_role_id bigint NOT NULL
);


ALTER TABLE public.shepherd_serverhistory OWNER TO postgres;

--
-- Name: shepherd_serverhistory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_serverhistory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_serverhistory_id_seq OWNER TO postgres;

--
-- Name: shepherd_serverhistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_serverhistory_id_seq OWNED BY public.shepherd_serverhistory.id;


--
-- Name: shepherd_servernote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_servernote (
    id bigint NOT NULL,
    "timestamp" date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note text,
    operator_id bigint,
    server_id bigint NOT NULL
);


ALTER TABLE public.shepherd_servernote OWNER TO postgres;

--
-- Name: shepherd_servernote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_servernote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_servernote_id_seq OWNER TO postgres;

--
-- Name: shepherd_servernote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_servernote_id_seq OWNED BY public.shepherd_servernote.id;


--
-- Name: shepherd_serverprovider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_serverprovider (
    id bigint NOT NULL,
    server_provider character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_serverprovider OWNER TO postgres;

--
-- Name: shepherd_serverprovider_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_serverprovider_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_serverprovider_id_seq OWNER TO postgres;

--
-- Name: shepherd_serverprovider_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_serverprovider_id_seq OWNED BY public.shepherd_serverprovider.id;


--
-- Name: shepherd_serverrole; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_serverrole (
    id bigint NOT NULL,
    server_role character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_serverrole OWNER TO postgres;

--
-- Name: shepherd_serverrole_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_serverrole_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_serverrole_id_seq OWNER TO postgres;

--
-- Name: shepherd_serverrole_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_serverrole_id_seq OWNED BY public.shepherd_serverrole.id;


--
-- Name: shepherd_serverstatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_serverstatus (
    id bigint NOT NULL,
    server_status character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_serverstatus OWNER TO postgres;

--
-- Name: shepherd_serverstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_serverstatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_serverstatus_id_seq OWNER TO postgres;

--
-- Name: shepherd_serverstatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_serverstatus_id_seq OWNED BY public.shepherd_serverstatus.id;


--
-- Name: shepherd_staticserver; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_staticserver (
    id bigint NOT NULL,
    ip_address inet NOT NULL,
    note text,
    last_used_by_id bigint,
    server_provider_id bigint,
    server_status_id bigint,
    name character varying(255)
);


ALTER TABLE public.shepherd_staticserver OWNER TO postgres;

--
-- Name: shepherd_staticserver_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_staticserver_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_staticserver_id_seq OWNER TO postgres;

--
-- Name: shepherd_staticserver_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_staticserver_id_seq OWNED BY public.shepherd_staticserver.id;


--
-- Name: shepherd_transientserver; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_transientserver (
    id bigint NOT NULL,
    ip_address inet NOT NULL,
    note text,
    activity_type_id bigint NOT NULL,
    operator_id bigint,
    project_id bigint,
    server_provider_id bigint,
    server_role_id bigint NOT NULL,
    name character varying(255),
    aux_address inet[]
);


ALTER TABLE public.shepherd_transientserver OWNER TO postgres;

--
-- Name: shepherd_transientserver_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_transientserver_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_transientserver_id_seq OWNER TO postgres;

--
-- Name: shepherd_transientserver_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_transientserver_id_seq OWNED BY public.shepherd_transientserver.id;


--
-- Name: shepherd_whoisstatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shepherd_whoisstatus (
    id bigint NOT NULL,
    whois_status character varying(255) NOT NULL
);


ALTER TABLE public.shepherd_whoisstatus OWNER TO postgres;

--
-- Name: shepherd_whoisstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shepherd_whoisstatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shepherd_whoisstatus_id_seq OWNER TO postgres;

--
-- Name: shepherd_whoisstatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shepherd_whoisstatus_id_seq OWNED BY public.shepherd_whoisstatus.id;


--
-- Name: singleton_siteconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.singleton_siteconfiguration (
    id bigint NOT NULL,
    site_name character varying(255) NOT NULL,
    file character varying(100) NOT NULL
);


ALTER TABLE public.singleton_siteconfiguration OWNER TO postgres;

--
-- Name: singleton_siteconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.singleton_siteconfiguration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.singleton_siteconfiguration_id_seq OWNER TO postgres;

--
-- Name: singleton_siteconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.singleton_siteconfiguration_id_seq OWNED BY public.singleton_siteconfiguration.id;


--
-- Name: singleton_siteconfigurationwithexplicitlygivenid; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.singleton_siteconfigurationwithexplicitlygivenid (
    id bigint NOT NULL,
    site_name character varying(255) NOT NULL
);


ALTER TABLE public.singleton_siteconfigurationwithexplicitlygivenid OWNER TO postgres;

--
-- Name: singleton_siteconfigurationwithexplicitlygivenid_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.singleton_siteconfigurationwithexplicitlygivenid_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.singleton_siteconfigurationwithexplicitlygivenid_id_seq OWNER TO postgres;

--
-- Name: singleton_siteconfigurationwithexplicitlygivenid_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.singleton_siteconfigurationwithexplicitlygivenid_id_seq OWNED BY public.singleton_siteconfigurationwithexplicitlygivenid.id;


--
-- Name: socialaccount_socialaccount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.socialaccount_socialaccount (
    id integer NOT NULL,
    provider character varying(30) NOT NULL,
    uid character varying(191) NOT NULL,
    last_login timestamp with time zone NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    extra_data text NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.socialaccount_socialaccount OWNER TO postgres;

--
-- Name: socialaccount_socialaccount_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.socialaccount_socialaccount_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.socialaccount_socialaccount_id_seq OWNER TO postgres;

--
-- Name: socialaccount_socialaccount_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.socialaccount_socialaccount_id_seq OWNED BY public.socialaccount_socialaccount.id;


--
-- Name: socialaccount_socialapp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.socialaccount_socialapp (
    id integer NOT NULL,
    provider character varying(30) NOT NULL,
    name character varying(40) NOT NULL,
    client_id character varying(191) NOT NULL,
    secret character varying(191) NOT NULL,
    key character varying(191) NOT NULL
);


ALTER TABLE public.socialaccount_socialapp OWNER TO postgres;

--
-- Name: socialaccount_socialapp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.socialaccount_socialapp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.socialaccount_socialapp_id_seq OWNER TO postgres;

--
-- Name: socialaccount_socialapp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.socialaccount_socialapp_id_seq OWNED BY public.socialaccount_socialapp.id;


--
-- Name: socialaccount_socialapp_sites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.socialaccount_socialapp_sites (
    id bigint NOT NULL,
    socialapp_id integer NOT NULL,
    site_id integer NOT NULL
);


ALTER TABLE public.socialaccount_socialapp_sites OWNER TO postgres;

--
-- Name: socialaccount_socialapp_sites_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.socialaccount_socialapp_sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.socialaccount_socialapp_sites_id_seq OWNER TO postgres;

--
-- Name: socialaccount_socialapp_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.socialaccount_socialapp_sites_id_seq OWNED BY public.socialaccount_socialapp_sites.id;


--
-- Name: socialaccount_socialtoken; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.socialaccount_socialtoken (
    id integer NOT NULL,
    token text NOT NULL,
    token_secret text NOT NULL,
    expires_at timestamp with time zone,
    account_id integer NOT NULL,
    app_id integer NOT NULL
);


ALTER TABLE public.socialaccount_socialtoken OWNER TO postgres;

--
-- Name: socialaccount_socialtoken_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.socialaccount_socialtoken_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.socialaccount_socialtoken_id_seq OWNER TO postgres;

--
-- Name: socialaccount_socialtoken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.socialaccount_socialtoken_id_seq OWNED BY public.socialaccount_socialtoken.id;


--
-- Name: users_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_user (
    id bigint NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    phone character varying(50),
    timezone character varying(63) NOT NULL,
    role character varying(120) NOT NULL
);


ALTER TABLE public.users_user OWNER TO postgres;

--
-- Name: users_user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_user_groups (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.users_user_groups OWNER TO postgres;

--
-- Name: users_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_groups_id_seq OWNER TO postgres;

--
-- Name: users_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_groups_id_seq OWNED BY public.users_user_groups.id;


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users_user.id;


--
-- Name: users_user_user_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_user_user_permissions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.users_user_user_permissions OWNER TO postgres;

--
-- Name: users_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_user_permissions_id_seq OWNER TO postgres;

--
-- Name: users_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_user_permissions_id_seq OWNED BY public.users_user_user_permissions.id;


--
-- Name: account_emailaddress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailaddress ALTER COLUMN id SET DEFAULT nextval('public.account_emailaddress_id_seq'::regclass);


--
-- Name: account_emailconfirmation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailconfirmation ALTER COLUMN id SET DEFAULT nextval('public.account_emailconfirmation_id_seq'::regclass);


--
-- Name: api_apikey id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_apikey ALTER COLUMN id SET DEFAULT nextval('public.api_apikey_id_seq'::regclass);


--
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- Name: commandcenter_cloudservicesconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_cloudservicesconfiguration ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_cloudservicesconfiguration_id_seq'::regclass);


--
-- Name: commandcenter_companyinformation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_companyinformation ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_companyinformation_id_seq'::regclass);


--
-- Name: commandcenter_namecheapconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_namecheapconfiguration ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_namecheapconfiguration_id_seq'::regclass);


--
-- Name: commandcenter_reportconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_reportconfiguration ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_reportconfiguration_id_seq'::regclass);


--
-- Name: commandcenter_slackconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_slackconfiguration ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_slackconfiguration_id_seq'::regclass);


--
-- Name: commandcenter_virustotalconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_virustotalconfiguration ALTER COLUMN id SET DEFAULT nextval('public.commandcenter_virustotalconfiguration_id_seq'::regclass);


--
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- Name: django_q_ormq id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_q_ormq ALTER COLUMN id SET DEFAULT nextval('public.django_q_ormq_id_seq'::regclass);


--
-- Name: django_q_schedule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_q_schedule ALTER COLUMN id SET DEFAULT nextval('public.django_q_schedule_id_seq'::regclass);


--
-- Name: django_site id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_site ALTER COLUMN id SET DEFAULT nextval('public.django_site_id_seq'::regclass);


--
-- Name: home_userprofile id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home_userprofile ALTER COLUMN id SET DEFAULT nextval('public.home_userprofile_id_seq'::regclass);


--
-- Name: oplog_oplog id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplog ALTER COLUMN id SET DEFAULT nextval('public.oplog_oplog_id_seq'::regclass);


--
-- Name: oplog_oplogentry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplogentry ALTER COLUMN id SET DEFAULT nextval('public.oplog_oplogentry_id_seq'::regclass);


--
-- Name: reporting_archive id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_archive ALTER COLUMN id SET DEFAULT nextval('public.reporting_archive_id_seq'::regclass);


--
-- Name: reporting_doctype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_doctype ALTER COLUMN id SET DEFAULT nextval('public.reporting_doctype_id_seq'::regclass);


--
-- Name: reporting_evidence id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_evidence ALTER COLUMN id SET DEFAULT nextval('public.reporting_evidence_id_seq'::regclass);


--
-- Name: reporting_finding id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_finding ALTER COLUMN id SET DEFAULT nextval('public.reporting_finding_id_seq'::regclass);


--
-- Name: reporting_findingnote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingnote ALTER COLUMN id SET DEFAULT nextval('public.reporting_findingnote_id_seq'::regclass);


--
-- Name: reporting_findingtype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingtype ALTER COLUMN id SET DEFAULT nextval('public.reporting_findingtype_id_seq'::regclass);


--
-- Name: reporting_localfindingnote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_localfindingnote ALTER COLUMN id SET DEFAULT nextval('public.reporting_localfindingnote_id_seq'::regclass);


--
-- Name: reporting_report id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report ALTER COLUMN id SET DEFAULT nextval('public.reporting_report_id_seq'::regclass);


--
-- Name: reporting_reportfindinglink id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink ALTER COLUMN id SET DEFAULT nextval('public.reporting_reportfindinglink_id_seq'::regclass);


--
-- Name: reporting_reporttemplate id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reporttemplate ALTER COLUMN id SET DEFAULT nextval('public.reporting_reporttemplate_id_seq'::regclass);


--
-- Name: reporting_severity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_severity ALTER COLUMN id SET DEFAULT nextval('public.reporting_severity_id_seq'::regclass);


--
-- Name: rolodex_client id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_client ALTER COLUMN id SET DEFAULT nextval('public.rolodex_client_id_seq'::regclass);


--
-- Name: rolodex_clientcontact id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientcontact ALTER COLUMN id SET DEFAULT nextval('public.rolodex_clientcontact_id_seq'::regclass);


--
-- Name: rolodex_clientinvite id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientinvite ALTER COLUMN id SET DEFAULT nextval('public.rolodex_clientinvite_id_seq'::regclass);


--
-- Name: rolodex_clientnote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientnote ALTER COLUMN id SET DEFAULT nextval('public.rolodex_clientnote_id_seq'::regclass);


--
-- Name: rolodex_objectivepriority id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivepriority ALTER COLUMN id SET DEFAULT nextval('public.rolodex_objectivepriority_id_seq'::regclass);


--
-- Name: rolodex_objectivestatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivestatus ALTER COLUMN id SET DEFAULT nextval('public.rolodex_objectivestatus_id_seq'::regclass);


--
-- Name: rolodex_project id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_project ALTER COLUMN id SET DEFAULT nextval('public.rolodex_project_id_seq'::regclass);


--
-- Name: rolodex_projectassignment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectassignment ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectassignment_id_seq'::regclass);


--
-- Name: rolodex_projectinvite id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectinvite ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectinvite_id_seq'::regclass);


--
-- Name: rolodex_projectnote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectnote ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectnote_id_seq'::regclass);


--
-- Name: rolodex_projectobjective id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectobjective ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectobjective_id_seq'::regclass);


--
-- Name: rolodex_projectrole id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectrole ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectrole_id_seq'::regclass);


--
-- Name: rolodex_projectscope id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectscope ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectscope_id_seq'::regclass);


--
-- Name: rolodex_projectsubtask id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectsubtask ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projectsubtask_id_seq'::regclass);


--
-- Name: rolodex_projecttarget id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttarget ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projecttarget_id_seq'::regclass);


--
-- Name: rolodex_projecttype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttype ALTER COLUMN id SET DEFAULT nextval('public.rolodex_projecttype_id_seq'::regclass);


--
-- Name: shepherd_activitytype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_activitytype ALTER COLUMN id SET DEFAULT nextval('public.shepherd_activitytype_id_seq'::regclass);


--
-- Name: shepherd_auxserveraddress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_auxserveraddress ALTER COLUMN id SET DEFAULT nextval('public.shepherd_auxserveraddress_id_seq'::regclass);


--
-- Name: shepherd_domain id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain ALTER COLUMN id SET DEFAULT nextval('public.shepherd_domain_id_seq'::regclass);


--
-- Name: shepherd_domainnote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainnote ALTER COLUMN id SET DEFAULT nextval('public.shepherd_domainnote_id_seq'::regclass);


--
-- Name: shepherd_domainserverconnection id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection ALTER COLUMN id SET DEFAULT nextval('public.shepherd_domainserverconnection_id_seq'::regclass);


--
-- Name: shepherd_domainstatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainstatus ALTER COLUMN id SET DEFAULT nextval('public.shepherd_domainstatus_id_seq'::regclass);


--
-- Name: shepherd_healthstatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_healthstatus ALTER COLUMN id SET DEFAULT nextval('public.shepherd_healthstatus_id_seq'::regclass);


--
-- Name: shepherd_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history ALTER COLUMN id SET DEFAULT nextval('public.shepherd_history_id_seq'::regclass);


--
-- Name: shepherd_serverhistory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory ALTER COLUMN id SET DEFAULT nextval('public.shepherd_serverhistory_id_seq'::regclass);


--
-- Name: shepherd_servernote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_servernote ALTER COLUMN id SET DEFAULT nextval('public.shepherd_servernote_id_seq'::regclass);


--
-- Name: shepherd_serverprovider id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverprovider ALTER COLUMN id SET DEFAULT nextval('public.shepherd_serverprovider_id_seq'::regclass);


--
-- Name: shepherd_serverrole id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverrole ALTER COLUMN id SET DEFAULT nextval('public.shepherd_serverrole_id_seq'::regclass);


--
-- Name: shepherd_serverstatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverstatus ALTER COLUMN id SET DEFAULT nextval('public.shepherd_serverstatus_id_seq'::regclass);


--
-- Name: shepherd_staticserver id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver ALTER COLUMN id SET DEFAULT nextval('public.shepherd_staticserver_id_seq'::regclass);


--
-- Name: shepherd_transientserver id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver ALTER COLUMN id SET DEFAULT nextval('public.shepherd_transientserver_id_seq'::regclass);


--
-- Name: shepherd_whoisstatus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_whoisstatus ALTER COLUMN id SET DEFAULT nextval('public.shepherd_whoisstatus_id_seq'::regclass);


--
-- Name: singleton_siteconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.singleton_siteconfiguration ALTER COLUMN id SET DEFAULT nextval('public.singleton_siteconfiguration_id_seq'::regclass);


--
-- Name: singleton_siteconfigurationwithexplicitlygivenid id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.singleton_siteconfigurationwithexplicitlygivenid ALTER COLUMN id SET DEFAULT nextval('public.singleton_siteconfigurationwithexplicitlygivenid_id_seq'::regclass);


--
-- Name: socialaccount_socialaccount id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialaccount ALTER COLUMN id SET DEFAULT nextval('public.socialaccount_socialaccount_id_seq'::regclass);


--
-- Name: socialaccount_socialapp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp ALTER COLUMN id SET DEFAULT nextval('public.socialaccount_socialapp_id_seq'::regclass);


--
-- Name: socialaccount_socialapp_sites id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp_sites ALTER COLUMN id SET DEFAULT nextval('public.socialaccount_socialapp_sites_id_seq'::regclass);


--
-- Name: socialaccount_socialtoken id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialtoken ALTER COLUMN id SET DEFAULT nextval('public.socialaccount_socialtoken_id_seq'::regclass);


--
-- Name: users_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user ALTER COLUMN id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: users_user_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups ALTER COLUMN id SET DEFAULT nextval('public.users_user_groups_id_seq'::regclass);


--
-- Name: users_user_user_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.users_user_user_permissions_id_seq'::regclass);


--
-- Data for Name: account_emailaddress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_emailaddress (id, email, verified, "primary", user_id) FROM stdin;
\.


--
-- Data for Name: account_emailconfirmation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_emailconfirmation (id, created, sent, key, email_address_id) FROM stdin;
\.


--
-- Data for Name: api_apikey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_apikey (id, name, token, created, expiry_date, revoked, user_id) FROM stdin;
\.


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add permission	1	add_permission
2	Can change permission	1	change_permission
3	Can delete permission	1	delete_permission
4	Can view permission	1	view_permission
5	Can add group	2	add_group
6	Can change group	2	change_group
7	Can delete group	2	delete_group
8	Can view group	2	view_group
9	Can add content type	3	add_contenttype
10	Can change content type	3	change_contenttype
11	Can delete content type	3	delete_contenttype
12	Can view content type	3	view_contenttype
13	Can add session	4	add_session
14	Can change session	4	change_session
15	Can delete session	4	delete_session
16	Can view session	4	view_session
17	Can add site	5	add_site
18	Can change site	5	change_site
19	Can delete site	5	delete_site
20	Can view site	5	view_site
21	Can add log entry	6	add_logentry
22	Can change log entry	6	change_logentry
23	Can delete log entry	6	delete_logentry
24	Can view log entry	6	view_logentry
25	Can add email address	7	add_emailaddress
26	Can change email address	7	change_emailaddress
27	Can delete email address	7	delete_emailaddress
28	Can view email address	7	view_emailaddress
29	Can add email confirmation	8	add_emailconfirmation
30	Can change email confirmation	8	change_emailconfirmation
31	Can delete email confirmation	8	delete_emailconfirmation
32	Can view email confirmation	8	view_emailconfirmation
33	Can add social account	9	add_socialaccount
34	Can change social account	9	change_socialaccount
35	Can delete social account	9	delete_socialaccount
36	Can view social account	9	view_socialaccount
37	Can add social application	10	add_socialapp
38	Can change social application	10	change_socialapp
39	Can delete social application	10	delete_socialapp
40	Can view social application	10	view_socialapp
41	Can add social application token	11	add_socialtoken
42	Can change social application token	11	change_socialtoken
43	Can delete social application token	11	delete_socialtoken
44	Can view social application token	11	view_socialtoken
45	Can add API key	12	add_apikey
46	Can change API key	12	change_apikey
47	Can delete API key	12	delete_apikey
48	Can view API key	12	view_apikey
49	Can add Scheduled task	13	add_schedule
50	Can change Scheduled task	13	change_schedule
51	Can delete Scheduled task	13	delete_schedule
52	Can view Scheduled task	13	view_schedule
53	Can add task	14	add_task
54	Can change task	14	change_task
55	Can delete task	14	delete_task
56	Can view task	14	view_task
57	Can add Failed task	15	add_failure
58	Can change Failed task	15	change_failure
59	Can delete Failed task	15	delete_failure
60	Can view Failed task	15	view_failure
61	Can add Successful task	16	add_success
62	Can change Successful task	16	change_success
63	Can delete Successful task	16	delete_success
64	Can view Successful task	16	view_success
65	Can add Queued task	17	add_ormq
66	Can change Queued task	17	change_ormq
67	Can delete Queued task	17	delete_ormq
68	Can view Queued task	17	view_ormq
69	Can add user	18	add_user
70	Can change user	18	change_user
71	Can delete user	18	delete_user
72	Can view user	18	view_user
73	Can add User profile	19	add_userprofile
74	Can change User profile	19	change_userprofile
75	Can delete User profile	19	delete_userprofile
76	Can view User profile	19	view_userprofile
77	Can add Client	20	add_client
78	Can change Client	20	change_client
79	Can delete Client	20	delete_client
80	Can view Client	20	view_client
81	Can add Project	21	add_project
82	Can change Project	21	change_project
83	Can delete Project	21	delete_project
84	Can view Project	21	view_project
85	Can add Project role	22	add_projectrole
86	Can change Project role	22	change_projectrole
87	Can delete Project role	22	delete_projectrole
88	Can view Project role	22	view_projectrole
89	Can add Project type	23	add_projecttype
90	Can change Project type	23	change_projecttype
91	Can delete Project type	23	delete_projecttype
92	Can view Project type	23	view_projecttype
93	Can add Project note	24	add_projectnote
94	Can change Project note	24	change_projectnote
95	Can delete Project note	24	delete_projectnote
96	Can view Project note	24	view_projectnote
97	Can add Project assignment	25	add_projectassignment
98	Can change Project assignment	25	change_projectassignment
99	Can delete Project assignment	25	delete_projectassignment
100	Can view Project assignment	25	view_projectassignment
101	Can add Client note	26	add_clientnote
102	Can change Client note	26	change_clientnote
103	Can delete Client note	26	delete_clientnote
104	Can view Client note	26	view_clientnote
105	Can add Client POC	27	add_clientcontact
106	Can change Client POC	27	change_clientcontact
107	Can delete Client POC	27	delete_clientcontact
108	Can view Client POC	27	view_clientcontact
109	Can add Objective status	28	add_objectivestatus
110	Can change Objective status	28	change_objectivestatus
111	Can delete Objective status	28	delete_objectivestatus
112	Can view Objective status	28	view_objectivestatus
113	Can add Project objective	29	add_projectobjective
114	Can change Project objective	29	change_projectobjective
115	Can delete Project objective	29	delete_projectobjective
116	Can view Project objective	29	view_projectobjective
117	Can add Project scope list	30	add_projectscope
118	Can change Project scope list	30	change_projectscope
119	Can delete Project scope list	30	delete_projectscope
120	Can view Project scope list	30	view_projectscope
121	Can add Project target	31	add_projecttarget
122	Can change Project target	31	change_projecttarget
123	Can delete Project target	31	delete_projecttarget
124	Can view Project target	31	view_projecttarget
125	Can add Objective sub-task	32	add_projectsubtask
126	Can change Objective sub-task	32	change_projectsubtask
127	Can delete Objective sub-task	32	delete_projectsubtask
128	Can view Objective sub-task	32	view_projectsubtask
129	Can add Objective priority	33	add_objectivepriority
130	Can change Objective priority	33	change_objectivepriority
131	Can delete Objective priority	33	delete_objectivepriority
132	Can view Objective priority	33	view_objectivepriority
133	Can add Project invite	34	add_projectinvite
134	Can change Project invite	34	change_projectinvite
135	Can delete Project invite	34	delete_projectinvite
136	Can view Project invite	34	view_projectinvite
137	Can add Client invite	35	add_clientinvite
138	Can change Client invite	35	change_clientinvite
139	Can delete Client invite	35	delete_clientinvite
140	Can view Client invite	35	view_clientinvite
141	Can add Activity type	36	add_activitytype
142	Can change Activity type	36	change_activitytype
143	Can delete Activity type	36	delete_activitytype
144	Can view Activity type	36	view_activitytype
145	Can add Domain	37	add_domain
146	Can change Domain	37	change_domain
147	Can delete Domain	37	delete_domain
148	Can view Domain	37	view_domain
149	Can add Domain status	38	add_domainstatus
150	Can change Domain status	38	change_domainstatus
151	Can delete Domain status	38	delete_domainstatus
152	Can view Domain status	38	view_domainstatus
153	Can add Health status	39	add_healthstatus
154	Can change Health status	39	change_healthstatus
155	Can delete Health status	39	delete_healthstatus
156	Can view Health status	39	view_healthstatus
157	Can add Server provider	40	add_serverprovider
158	Can change Server provider	40	change_serverprovider
159	Can delete Server provider	40	delete_serverprovider
160	Can view Server provider	40	view_serverprovider
161	Can add Server role	41	add_serverrole
162	Can change Server role	41	change_serverrole
163	Can delete Server role	41	delete_serverrole
164	Can view Server role	41	view_serverrole
165	Can add Server status	42	add_serverstatus
166	Can change Server status	42	change_serverstatus
167	Can delete Server status	42	delete_serverstatus
168	Can view Server status	42	view_serverstatus
169	Can add WHOIS status	43	add_whoisstatus
170	Can change WHOIS status	43	change_whoisstatus
171	Can delete WHOIS status	43	delete_whoisstatus
172	Can view WHOIS status	43	view_whoisstatus
173	Can add Virtual private server	44	add_transientserver
174	Can change Virtual private server	44	change_transientserver
175	Can delete Virtual private server	44	delete_transientserver
176	Can view Virtual private server	44	view_transientserver
177	Can add Static server	45	add_staticserver
178	Can change Static server	45	change_staticserver
179	Can delete Static server	45	delete_staticserver
180	Can view Static server	45	view_staticserver
181	Can add Server note	46	add_servernote
182	Can change Server note	46	change_servernote
183	Can delete Server note	46	delete_servernote
184	Can view Server note	46	view_servernote
185	Can add Server history	47	add_serverhistory
186	Can change Server history	47	change_serverhistory
187	Can delete Server history	47	delete_serverhistory
188	Can view Server history	47	view_serverhistory
189	Can add Domain history	48	add_history
190	Can change Domain history	48	change_history
191	Can delete Domain history	48	delete_history
192	Can view Domain history	48	view_history
193	Can add Domain and server record	49	add_domainserverconnection
194	Can change Domain and server record	49	change_domainserverconnection
195	Can delete Domain and server record	49	delete_domainserverconnection
196	Can view Domain and server record	49	view_domainserverconnection
197	Can add Domain note	50	add_domainnote
198	Can change Domain note	50	change_domainnote
199	Can delete Domain note	50	delete_domainnote
200	Can view Domain note	50	view_domainnote
201	Can add Auxiliary IP address	51	add_auxserveraddress
202	Can change Auxiliary IP address	51	change_auxserveraddress
203	Can delete Auxiliary IP address	51	delete_auxserveraddress
204	Can view Auxiliary IP address	51	view_auxserveraddress
205	Can add Finding type	52	add_findingtype
206	Can change Finding type	52	change_findingtype
207	Can delete Finding type	52	delete_findingtype
208	Can view Finding type	52	view_findingtype
209	Can add Report	53	add_report
210	Can change Report	53	change_report
211	Can delete Report	53	delete_report
212	Can view Report	53	view_report
213	Can add Severity rating	54	add_severity
214	Can change Severity rating	54	change_severity
215	Can delete Severity rating	54	delete_severity
216	Can view Severity rating	54	view_severity
217	Can add Report finding	55	add_reportfindinglink
218	Can change Report finding	55	change_reportfindinglink
219	Can delete Report finding	55	delete_reportfindinglink
220	Can view Report finding	55	view_reportfindinglink
221	Can add Finding	56	add_finding
222	Can change Finding	56	change_finding
223	Can delete Finding	56	delete_finding
224	Can view Finding	56	view_finding
225	Can add Evidence	57	add_evidence
226	Can change Evidence	57	change_evidence
227	Can delete Evidence	57	delete_evidence
228	Can view Evidence	57	view_evidence
229	Can add Archived report	58	add_archive
230	Can change Archived report	58	change_archive
231	Can delete Archived report	58	delete_archive
232	Can view Archived report	58	view_archive
233	Can add Local finding note	59	add_localfindingnote
234	Can change Local finding note	59	change_localfindingnote
235	Can delete Local finding note	59	delete_localfindingnote
236	Can view Local finding note	59	view_localfindingnote
237	Can add Finding note	60	add_findingnote
238	Can change Finding note	60	change_findingnote
239	Can delete Finding note	60	delete_findingnote
240	Can view Finding note	60	view_findingnote
241	Can add Report template	61	add_reporttemplate
242	Can change Report template	61	change_reporttemplate
243	Can delete Report template	61	delete_reporttemplate
244	Can view Report template	61	view_reporttemplate
245	Can add Document type	62	add_doctype
246	Can change Document type	62	change_doctype
247	Can delete Document type	62	delete_doctype
248	Can view Document type	62	view_doctype
249	Can add oplog	63	add_oplog
250	Can change oplog	63	change_oplog
251	Can delete oplog	63	delete_oplog
252	Can view oplog	63	view_oplog
253	Can add oplog entry	64	add_oplogentry
254	Can change oplog entry	64	change_oplogentry
255	Can delete oplog entry	64	delete_oplogentry
256	Can view oplog entry	64	view_oplogentry
257	Can add Cloud Services Configuration	65	add_cloudservicesconfiguration
258	Can change Cloud Services Configuration	65	change_cloudservicesconfiguration
259	Can delete Cloud Services Configuration	65	delete_cloudservicesconfiguration
260	Can view Cloud Services Configuration	65	view_cloudservicesconfiguration
261	Can add Company Information	66	add_companyinformation
262	Can change Company Information	66	change_companyinformation
263	Can delete Company Information	66	delete_companyinformation
264	Can view Company Information	66	view_companyinformation
265	Can add Namecheap Configuration	67	add_namecheapconfiguration
266	Can change Namecheap Configuration	67	change_namecheapconfiguration
267	Can delete Namecheap Configuration	67	delete_namecheapconfiguration
268	Can view Namecheap Configuration	67	view_namecheapconfiguration
269	Can add Global Report Configuration	68	add_reportconfiguration
270	Can change Global Report Configuration	68	change_reportconfiguration
271	Can delete Global Report Configuration	68	delete_reportconfiguration
272	Can view Global Report Configuration	68	view_reportconfiguration
273	Can add Slack Configuration	69	add_slackconfiguration
274	Can change Slack Configuration	69	change_slackconfiguration
275	Can delete Slack Configuration	69	delete_slackconfiguration
276	Can view Slack Configuration	69	view_slackconfiguration
277	Can add VirusTotal Configuration	70	add_virustotalconfiguration
278	Can change VirusTotal Configuration	70	change_virustotalconfiguration
279	Can delete VirusTotal Configuration	70	delete_virustotalconfiguration
280	Can view VirusTotal Configuration	70	view_virustotalconfiguration
281	Can add Site Configuration	71	add_siteconfiguration
282	Can change Site Configuration	71	change_siteconfiguration
283	Can delete Site Configuration	71	delete_siteconfiguration
284	Can view Site Configuration	71	view_siteconfiguration
285	Can add Site Configuration	72	add_siteconfigurationwithexplicitlygivenid
286	Can change Site Configuration	72	change_siteconfigurationwithexplicitlygivenid
287	Can delete Site Configuration	72	delete_siteconfigurationwithexplicitlygivenid
288	Can view Site Configuration	72	view_siteconfigurationwithexplicitlygivenid
289	Can add API key	73	add_apikey
290	Can change API key	73	change_apikey
291	Can delete API key	73	delete_apikey
292	Can view API key	73	view_apikey
\.


--
-- Data for Name: commandcenter_cloudservicesconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_cloudservicesconfiguration (id, enable, aws_key, aws_secret, do_api_key, ignore_tag, notification_delay) FROM stdin;
\.


--
-- Data for Name: commandcenter_companyinformation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_companyinformation (id, company_name, company_twitter, company_email) FROM stdin;
\.


--
-- Data for Name: commandcenter_namecheapconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_namecheapconfiguration (id, enable, api_key, username, api_username, client_ip, page_size) FROM stdin;
\.


--
-- Data for Name: commandcenter_reportconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_reportconfiguration (id, border_weight, border_color, prefix_figure, prefix_table, default_docx_template_id, default_pptx_template_id, enable_borders, label_figure, label_table) FROM stdin;
\.


--
-- Data for Name: commandcenter_slackconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_slackconfiguration (id, enable, webhook_url, slack_emoji, slack_channel, slack_username, slack_alert_target) FROM stdin;
\.


--
-- Data for Name: commandcenter_virustotalconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commandcenter_virustotalconfiguration (id, enable, api_key, sleep_time) FROM stdin;
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	auth	permission
2	auth	group
3	contenttypes	contenttype
4	sessions	session
5	sites	site
6	admin	logentry
7	account	emailaddress
8	account	emailconfirmation
9	socialaccount	socialaccount
10	socialaccount	socialapp
11	socialaccount	socialtoken
12	rest_framework_api_key	apikey
13	django_q	schedule
14	django_q	task
15	django_q	failure
16	django_q	success
17	django_q	ormq
18	users	user
19	home	userprofile
20	rolodex	client
21	rolodex	project
22	rolodex	projectrole
23	rolodex	projecttype
24	rolodex	projectnote
25	rolodex	projectassignment
26	rolodex	clientnote
27	rolodex	clientcontact
28	rolodex	objectivestatus
29	rolodex	projectobjective
30	rolodex	projectscope
31	rolodex	projecttarget
32	rolodex	projectsubtask
33	rolodex	objectivepriority
34	rolodex	projectinvite
35	rolodex	clientinvite
36	shepherd	activitytype
37	shepherd	domain
38	shepherd	domainstatus
39	shepherd	healthstatus
40	shepherd	serverprovider
41	shepherd	serverrole
42	shepherd	serverstatus
43	shepherd	whoisstatus
44	shepherd	transientserver
45	shepherd	staticserver
46	shepherd	servernote
47	shepherd	serverhistory
48	shepherd	history
49	shepherd	domainserverconnection
50	shepherd	domainnote
51	shepherd	auxserveraddress
52	reporting	findingtype
53	reporting	report
54	reporting	severity
55	reporting	reportfindinglink
56	reporting	finding
57	reporting	evidence
58	reporting	archive
59	reporting	localfindingnote
60	reporting	findingnote
61	reporting	reporttemplate
62	reporting	doctype
63	oplog	oplog
64	oplog	oplogentry
65	commandcenter	cloudservicesconfiguration
66	commandcenter	companyinformation
67	commandcenter	namecheapconfiguration
68	commandcenter	reportconfiguration
69	commandcenter	slackconfiguration
70	commandcenter	virustotalconfiguration
71	singleton	siteconfiguration
72	singleton	siteconfigurationwithexplicitlygivenid
73	api	apikey
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2022-07-11 21:31:06.427208+00
2	contenttypes	0002_remove_content_type_name	2022-07-11 21:31:06.433837+00
3	auth	0001_initial	2022-07-11 21:31:06.469946+00
4	auth	0002_alter_permission_name_max_length	2022-07-11 21:31:06.474646+00
5	auth	0003_alter_user_email_max_length	2022-07-11 21:31:06.47887+00
6	auth	0004_alter_user_username_opts	2022-07-11 21:31:06.483041+00
7	auth	0005_alter_user_last_login_null	2022-07-11 21:31:06.487227+00
8	auth	0006_require_contenttypes_0002	2022-07-11 21:31:06.48857+00
9	auth	0007_alter_validators_add_error_messages	2022-07-11 21:31:06.492696+00
10	auth	0008_alter_user_username_max_length	2022-07-11 21:31:06.496896+00
11	auth	0009_alter_user_last_name_max_length	2022-07-11 21:31:06.500956+00
12	auth	0010_alter_group_name_max_length	2022-07-11 21:31:06.505349+00
13	auth	0011_update_proxy_permissions	2022-07-11 21:31:06.510332+00
14	users	0001_initial	2022-07-11 21:31:06.538226+00
15	account	0001_initial	2022-07-11 21:31:06.565453+00
16	account	0002_email_max_length	2022-07-11 21:31:06.571604+00
17	admin	0001_initial	2022-07-11 21:31:06.587169+00
18	admin	0002_logentry_remove_auto_add	2022-07-11 21:31:06.593383+00
19	admin	0003_logentry_add_action_flag_choices	2022-07-11 21:31:06.599548+00
20	api	0001_initial	2022-07-11 21:31:06.616453+00
21	auth	0012_alter_user_first_name_max_length	2022-07-11 21:31:06.623462+00
22	rolodex	0001_initial	2022-07-11 21:31:06.834154+00
23	rolodex	0002_objectivestatus_projectobjective	2022-07-11 21:31:06.860879+00
24	rolodex	0003_auto_20190828_0007	2022-07-11 21:31:06.868537+00
25	rolodex	0004_auto_20190910_0113	2022-07-11 21:31:06.879668+00
26	rolodex	0005_auto_20191122_2304	2022-07-11 21:31:06.891346+00
27	rolodex	0006_auto_20200825_1947	2022-07-11 21:31:07.110413+00
28	reporting	0001_initial	2022-07-11 21:31:07.249671+00
29	reporting	0002_localfindingnote	2022-07-11 21:31:07.274115+00
30	reporting	0003_findingnote	2022-07-11 21:31:07.299304+00
31	reporting	0004_report_delivered	2022-07-11 21:31:07.312793+00
32	reporting	0005_reportfindinglink_finding_guidance	2022-07-11 21:31:07.326449+00
33	reporting	0006_auto_20191122_2304	2022-07-11 21:31:07.36722+00
34	reporting	0007_auto_20200110_0505	2022-07-11 21:31:07.379789+00
35	reporting	0008_auto_20200825_1947	2022-07-11 21:31:07.646226+00
36	reporting	0009_auto_20200915_0011	2022-07-11 21:31:07.656436+00
37	reporting	0010_reporttemplate	2022-07-11 21:31:07.682447+00
38	reporting	0011_report_template	2022-07-11 21:31:07.702795+00
39	reporting	0012_auto_20200923_2228	2022-07-11 21:31:07.727735+00
40	reporting	0013_reporttemplate_lint_result	2022-07-11 21:31:07.741026+00
41	reporting	0014_auto_20200924_1822	2022-07-11 21:31:07.75521+00
42	reporting	0015_auto_20201016_1756	2022-07-11 21:31:07.805634+00
43	reporting	0016_auto_20201017_0014	2022-07-11 21:31:07.873648+00
44	reporting	0017_auto_20201019_2318	2022-07-11 21:31:07.921448+00
45	reporting	0018_auto_20201027_1914	2022-07-11 21:31:07.959852+00
46	commandcenter	0001_initial	2022-07-11 21:31:07.990449+00
47	commandcenter	0002_auto_20201009_1918	2022-07-11 21:31:07.994514+00
48	commandcenter	0003_auto_20201027_1914	2022-07-11 21:31:08.037182+00
49	commandcenter	0004_auto_20201028_1633	2022-07-11 21:31:08.146813+00
50	commandcenter	0005_auto_20201102_2207	2022-07-11 21:31:08.170409+00
51	commandcenter	0006_auto_20210614_2224	2022-07-11 21:31:08.18223+00
52	commandcenter	0007_auto_20210616_0340	2022-07-11 21:31:08.186944+00
53	commandcenter	0008_remove_namecheapconfiguration_reset_dns	2022-07-11 21:31:08.19008+00
54	commandcenter	0009_cloudservicesconfiguration_notification_delay	2022-07-11 21:31:08.193453+00
55	commandcenter	0010_auto_20220205_0026	2022-07-11 21:31:08.242683+00
56	django_q	0001_initial	2022-07-11 21:31:08.259607+00
57	django_q	0002_auto_20150630_1624	2022-07-11 21:31:08.265443+00
58	django_q	0003_auto_20150708_1326	2022-07-11 21:31:08.279462+00
59	django_q	0004_auto_20150710_1043	2022-07-11 21:31:08.285804+00
60	django_q	0005_auto_20150718_1506	2022-07-11 21:31:08.291768+00
61	django_q	0006_auto_20150805_1817	2022-07-11 21:31:08.297448+00
62	django_q	0007_ormq	2022-07-11 21:31:08.303684+00
63	django_q	0008_auto_20160224_1026	2022-07-11 21:31:08.307106+00
64	django_q	0009_auto_20171009_0915	2022-07-11 21:31:08.313993+00
65	django_q	0010_auto_20200610_0856	2022-07-11 21:31:08.323018+00
66	django_q	0011_auto_20200628_1055	2022-07-11 21:31:08.328182+00
67	django_q	0012_auto_20200702_1608	2022-07-11 21:31:08.331485+00
68	django_q	0013_task_attempt_count	2022-07-11 21:31:08.33583+00
69	django_q	0014_schedule_cluster	2022-07-11 21:31:08.339057+00
70	home	0001_initial	2022-07-11 21:31:08.343641+00
71	home	0002_userprofile_user	2022-07-11 21:31:08.36357+00
72	home	0003_auto_20190729_2213	2022-07-11 21:31:08.377495+00
73	home	0004_auto_20220125_2358	2022-07-11 21:31:08.390208+00
74	home	0005_alter_userprofile_id	2022-07-11 21:31:08.409752+00
75	oplog	0001_initial	2022-07-11 21:31:08.462286+00
76	oplog	0002_auto_20200825_2127	2022-07-11 21:31:08.514584+00
77	oplog	0003_auto_20210729_2132	2022-07-11 21:31:08.546561+00
78	oplog	0004_auto_20220205_0026	2022-07-11 21:31:08.588911+00
79	reporting	0019_auto_20201105_0609	2022-07-11 21:31:08.60541+00
80	reporting	0020_auto_20201105_0641	2022-07-11 21:31:08.620536+00
81	reporting	0021_auto_20201119_2343	2022-07-11 21:31:08.634847+00
82	reporting	0022_auto_20210211_2109	2022-07-11 21:31:08.650323+00
83	reporting	0023_auto_20210318_2120	2022-07-11 21:31:08.654762+00
84	reporting	0024_auto_20220205_0026	2022-07-11 21:31:09.133755+00
85	reporting	0025_alter_reporttemplate_lint_result	2022-07-11 21:31:09.168273+00
86	reporting	0026_convert_linting_status_to_json	2022-07-11 21:31:09.196971+00
87	reporting	0027_auto_20220510_1923	2022-07-11 21:31:09.206112+00
88	reporting	0028_auto_20220608_1808	2022-07-11 21:31:09.246826+00
89	rest_framework_api_key	0001_initial	2022-07-11 21:31:09.256401+00
90	rest_framework_api_key	0002_auto_20190529_2243	2022-07-11 21:31:09.263616+00
91	rest_framework_api_key	0003_auto_20190623_1952	2022-07-11 21:31:09.267149+00
92	rest_framework_api_key	0004_prefix_hashed_key	2022-07-11 21:31:09.305+00
93	rest_framework_api_key	0005_auto_20220110_1102	2022-07-11 21:31:09.312534+00
94	rolodex	0007_auto_20201027_1914	2022-07-11 21:31:09.331676+00
95	rolodex	0008_projectscope	2022-07-11 21:31:09.359859+00
96	rolodex	0009_projecttarget	2022-07-11 21:31:09.389653+00
97	rolodex	0010_auto_20210204_1957	2022-07-11 21:31:09.40494+00
98	rolodex	0011_projectsubtask	2022-07-11 21:31:09.436158+00
99	rolodex	0012_auto_20210211_1853	2022-07-11 21:31:09.458768+00
100	rolodex	0013_projectsubtask_marked_complete	2022-07-11 21:31:09.464535+00
101	rolodex	0014_projectobjective_marked_complete	2022-07-11 21:31:09.474961+00
102	rolodex	0015_auto_20210219_2204	2022-07-11 21:31:09.500633+00
103	rolodex	0016_auto_20210224_0645	2022-07-11 21:31:09.542495+00
104	rolodex	0017_projectobjective_position	2022-07-11 21:31:09.553581+00
105	rolodex	0018_auto_20210227_0228	2022-07-11 21:31:09.564256+00
106	rolodex	0019_auto_20210303_2155	2022-07-11 21:31:09.656095+00
107	rolodex	0020_auto_20210922_2337	2022-07-11 21:31:09.666789+00
108	rolodex	0021_project_timezone	2022-07-11 21:31:09.687453+00
109	rolodex	0022_auto_20210923_0011	2022-07-11 21:31:09.721385+00
110	rolodex	0023_auto_20210923_0038	2022-07-11 21:31:09.754497+00
111	rolodex	0024_clientcontact_timezone	2022-07-11 21:31:09.761885+00
112	rolodex	0025_auto_20210923_1540	2022-07-11 21:31:09.768588+00
113	rolodex	0026_auto_20211109_1908	2022-07-11 21:31:09.786001+00
114	rolodex	0027_auto_20220205_0026	2022-07-11 21:31:10.36529+00
115	rolodex	0028_clientinvite_projectinvite	2022-07-11 21:31:10.441722+00
116	rolodex	0029_auto_20220510_1922	2022-07-11 21:31:10.454689+00
117	rolodex	0030_auto_20220526_1737	2022-07-11 21:31:10.500772+00
118	sessions	0001_initial	2022-07-11 21:31:10.510961+00
119	shepherd	0001_initial	2022-07-11 21:31:11.180999+00
120	shepherd	0002_auto_20190726_1841	2022-07-11 21:31:11.187523+00
121	shepherd	0003_auto_20190824_0401	2022-07-11 21:31:11.29103+00
122	shepherd	0004_auto_20190910_0113	2022-07-11 21:31:11.478045+00
123	shepherd	0005_auto_20191001_1352	2022-07-11 21:31:11.584872+00
124	shepherd	0006_auto_20191001_1353	2022-07-11 21:31:11.639799+00
125	shepherd	0007_auto_20191029_1636	2022-07-11 21:31:11.68066+00
126	shepherd	0008_auto_20191122_2304	2022-07-11 21:31:11.702667+00
127	shepherd	0009_auxserveraddress	2022-07-11 21:31:11.742351+00
128	shepherd	0010_auto_20200123_0204	2022-07-11 21:31:11.757706+00
129	shepherd	0011_auto_20200123_0726	2022-07-11 21:31:11.767824+00
130	shepherd	0012_auto_20200616_0441	2022-07-11 21:31:11.789741+00
131	shepherd	0013_auto_20200825_1947	2022-07-11 21:31:11.879007+00
132	shepherd	0014_auto_20200909_1804	2022-07-11 21:31:12.606746+00
133	shepherd	0015_auto_20201120_0620	2022-07-11 21:31:12.652818+00
134	shepherd	0016_auto_20210227_0056	2022-07-11 21:31:12.666778+00
135	shepherd	0017_domain_reset_dns	2022-07-11 21:31:12.688107+00
136	shepherd	0018_auto_20210630_2205	2022-07-11 21:31:12.713791+00
137	shepherd	0019_auto_20210706_2242	2022-07-11 21:31:12.733747+00
138	shepherd	0020_transientserver_address	2022-07-11 21:31:12.759535+00
139	shepherd	0021_auto_20210923_1953	2022-07-11 21:31:12.802977+00
140	shepherd	0022_auto_20210923_2115	2022-07-11 21:31:12.842285+00
141	shepherd	0023_auto_20210923_2142	2022-07-11 21:31:12.923894+00
142	shepherd	0024_auto_20210923_2209	2022-07-11 21:31:13.058142+00
143	shepherd	0025_auto_20210923_2214	2022-07-11 21:31:13.083756+00
144	shepherd	0026_auto_20210923_2217	2022-07-11 21:31:13.11061+00
145	shepherd	0027_auto_20210923_2218	2022-07-11 21:31:13.135616+00
146	shepherd	0028_auto_20210923_2234	2022-07-11 21:31:13.15978+00
147	shepherd	0029_auto_20210923_2235	2022-07-11 21:31:13.184377+00
148	shepherd	0030_auto_20211103_1719	2022-07-11 21:31:13.209226+00
149	shepherd	0031_auto_20220201_2331	2022-07-11 21:31:13.238168+00
150	shepherd	0032_migrate_domain_categories	2022-07-11 21:31:13.303941+00
151	shepherd	0033_delete_old_domain_categories	2022-07-11 21:31:13.589234+00
152	shepherd	0034_remove_domain_health_dns	2022-07-11 21:31:13.610555+00
153	shepherd	0035_auto_20220205_0026	2022-07-11 21:31:14.633127+00
154	shepherd	0036_auto_20220209_1815	2022-07-11 21:31:14.741266+00
155	shepherd	0037_convert_dns_record_to_json	2022-07-11 21:31:14.77874+00
156	shepherd	0038_alter_domain_dns_record	2022-07-11 21:31:14.800558+00
157	shepherd	0039_auto_20220510_1909	2022-07-11 21:31:14.806992+00
158	shepherd	0040_auto_20220510_1949	2022-07-11 21:31:14.819704+00
159	sites	0001_initial	2022-07-11 21:31:14.826509+00
160	sites	0002_alter_domain_unique	2022-07-11 21:31:14.848846+00
161	sites	0003_set_site_domain_and_name	2022-07-11 21:31:14.890866+00
162	sites	0004_auto_20210406_0058	2022-07-11 21:31:14.895675+00
163	sites	0005_auto_20210614_1732	2022-07-11 21:31:14.899312+00
164	sites	0006_auto_20210922_2325	2022-07-11 21:31:14.902928+00
165	socialaccount	0001_initial	2022-07-11 21:31:15.236142+00
166	socialaccount	0002_token_max_lengths	2022-07-11 21:31:15.272308+00
167	socialaccount	0003_extra_data_default_dict	2022-07-11 21:31:15.292169+00
168	users	0002_auto_20190729_1749	2022-07-11 21:31:15.330705+00
169	users	0003_auto_20210922_2349	2022-07-11 21:31:15.3726+00
170	users	0004_auto_20220126_1735	2022-07-11 21:31:15.395381+00
171	users	0005_alter_user_id	2022-07-11 21:31:15.707988+00
172	users	0006_user_role	2022-07-11 21:31:15.740097+00
\.


--
-- Data for Name: django_q_ormq; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_q_ormq (id, key, payload, lock) FROM stdin;
\.


--
-- Data for Name: django_q_schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_q_schedule (id, func, hook, args, kwargs, schedule_type, repeats, next_run, task, name, minutes, cron, cluster) FROM stdin;
\.


--
-- Data for Name: django_q_task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_q_task (name, func, hook, args, kwargs, result, started, stopped, success, id, "group", attempt_count) FROM stdin;
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
\.


--
-- Data for Name: django_site; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_site (id, domain, name) FROM stdin;
1	specterops.training	Student Dashboard
\.


--
-- Data for Name: home_userprofile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.home_userprofile (id, avatar, user_id) FROM stdin;
\.


--
-- Data for Name: oplog_oplog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oplog_oplog (id, name, project_id) FROM stdin;
\.


--
-- Data for Name: oplog_oplogentry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oplog_oplogentry (id, start_date, end_date, source_ip, dest_ip, tool, user_context, command, description, output, comments, operator_name, oplog_id_id) FROM stdin;
\.


--
-- Data for Name: reporting_archive; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_archive (id, report_archive, project_id) FROM stdin;
\.


--
-- Data for Name: reporting_doctype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_doctype (id, doc_type) FROM stdin;
\.


--
-- Data for Name: reporting_evidence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_evidence (id, document, friendly_name, upload_date, caption, description, finding_id, uploaded_by_id) FROM stdin;
\.


--
-- Data for Name: reporting_finding; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_finding (id, title, description, impact, mitigation, replication_steps, host_detection_techniques, network_detection_techniques, "references", finding_guidance, finding_type_id, severity_id, cvss_score, cvss_vector) FROM stdin;
\.


--
-- Data for Name: reporting_findingnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_findingnote (id, "timestamp", note, finding_id, operator_id) FROM stdin;
\.


--
-- Data for Name: reporting_findingtype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_findingtype (id, finding_type) FROM stdin;
\.


--
-- Data for Name: reporting_localfindingnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_localfindingnote (id, "timestamp", note, finding_id, operator_id) FROM stdin;
\.


--
-- Data for Name: reporting_report; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_report (id, title, creation, last_update, complete, archived, created_by_id, project_id, delivered, docx_template_id, pptx_template_id) FROM stdin;
\.


--
-- Data for Name: reporting_reportfindinglink; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_reportfindinglink (id, title, "position", affected_entities, description, impact, mitigation, replication_steps, host_detection_techniques, network_detection_techniques, "references", complete, assigned_to_id, finding_type_id, report_id, severity_id, finding_guidance, cvss_score, cvss_vector) FROM stdin;
\.


--
-- Data for Name: reporting_reporttemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_reporttemplate (id, document, name, upload_date, last_update, description, protected, client_id, uploaded_by_id, lint_result, changelog, doc_type_id) FROM stdin;
\.


--
-- Data for Name: reporting_severity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reporting_severity (id, severity, weight, color) FROM stdin;
\.


--
-- Data for Name: rest_framework_api_key_apikey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rest_framework_api_key_apikey (id, created, name, revoked, expiry_date, hashed_key, prefix) FROM stdin;
\.


--
-- Data for Name: rolodex_client; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_client (id, name, short_name, codename, note, address, timezone) FROM stdin;
\.


--
-- Data for Name: rolodex_clientcontact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_clientcontact (id, name, job_title, email, phone, note, client_id, timezone) FROM stdin;
\.


--
-- Data for Name: rolodex_clientinvite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_clientinvite (id, comment, client_id, user_id) FROM stdin;
\.


--
-- Data for Name: rolodex_clientnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_clientnote (id, "timestamp", note, client_id, operator_id) FROM stdin;
\.


--
-- Data for Name: rolodex_objectivepriority; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_objectivepriority (id, weight, priority) FROM stdin;
\.


--
-- Data for Name: rolodex_objectivestatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_objectivestatus (id, objective_status) FROM stdin;
\.


--
-- Data for Name: rolodex_project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_project (id, codename, start_date, end_date, note, slack_channel, complete, client_id, operator_id, project_type_id, timezone, end_time, start_time) FROM stdin;
\.


--
-- Data for Name: rolodex_projectassignment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectassignment (id, start_date, end_date, note, operator_id, project_id, role_id) FROM stdin;
\.


--
-- Data for Name: rolodex_projectinvite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectinvite (id, comment, project_id, user_id) FROM stdin;
\.


--
-- Data for Name: rolodex_projectnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectnote (id, "timestamp", note, operator_id, project_id) FROM stdin;
\.


--
-- Data for Name: rolodex_projectobjective; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectobjective (id, objective, complete, deadline, project_id, status_id, marked_complete, description, priority_id, "position") FROM stdin;
\.


--
-- Data for Name: rolodex_projectrole; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectrole (id, project_role) FROM stdin;
\.


--
-- Data for Name: rolodex_projectscope; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectscope (id, name, scope, description, disallowed, requires_caution, project_id) FROM stdin;
\.


--
-- Data for Name: rolodex_projectsubtask; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projectsubtask (id, task, complete, deadline, parent_id, status_id, marked_complete) FROM stdin;
\.


--
-- Data for Name: rolodex_projecttarget; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projecttarget (id, ip_address, hostname, note, compromised, project_id) FROM stdin;
\.


--
-- Data for Name: rolodex_projecttype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolodex_projecttype (id, project_type) FROM stdin;
\.


--
-- Data for Name: shepherd_activitytype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_activitytype (id, activity) FROM stdin;
\.


--
-- Data for Name: shepherd_auxserveraddress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_auxserveraddress (id, ip_address, static_server_id, "primary") FROM stdin;
\.


--
-- Data for Name: shepherd_domain; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_domain (id, name, registrar, creation, expiration, note, burned_explanation, domain_status_id, health_status_id, last_used_by_id, whois_status_id, auto_renew, expired, last_health_check, vt_permalink, reset_dns, categorization, dns) FROM stdin;
\.


--
-- Data for Name: shepherd_domainnote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_domainnote (id, "timestamp", note, domain_id, operator_id) FROM stdin;
\.


--
-- Data for Name: shepherd_domainserverconnection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_domainserverconnection (id, endpoint, subdomain, domain_id, project_id, static_server_id, transient_server_id) FROM stdin;
\.


--
-- Data for Name: shepherd_domainstatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_domainstatus (id, domain_status) FROM stdin;
\.


--
-- Data for Name: shepherd_healthstatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_healthstatus (id, health_status) FROM stdin;
\.


--
-- Data for Name: shepherd_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_history (id, start_date, end_date, note, activity_type_id, client_id, domain_id, operator_id, project_id) FROM stdin;
\.


--
-- Data for Name: shepherd_serverhistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_serverhistory (id, start_date, end_date, note, activity_type_id, client_id, operator_id, project_id, server_id, server_role_id) FROM stdin;
\.


--
-- Data for Name: shepherd_servernote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_servernote (id, "timestamp", note, operator_id, server_id) FROM stdin;
\.


--
-- Data for Name: shepherd_serverprovider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_serverprovider (id, server_provider) FROM stdin;
\.


--
-- Data for Name: shepherd_serverrole; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_serverrole (id, server_role) FROM stdin;
\.


--
-- Data for Name: shepherd_serverstatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_serverstatus (id, server_status) FROM stdin;
\.


--
-- Data for Name: shepherd_staticserver; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_staticserver (id, ip_address, note, last_used_by_id, server_provider_id, server_status_id, name) FROM stdin;
\.


--
-- Data for Name: shepherd_transientserver; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_transientserver (id, ip_address, note, activity_type_id, operator_id, project_id, server_provider_id, server_role_id, name, aux_address) FROM stdin;
\.


--
-- Data for Name: shepherd_whoisstatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shepherd_whoisstatus (id, whois_status) FROM stdin;
\.


--
-- Data for Name: singleton_siteconfiguration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.singleton_siteconfiguration (id, site_name, file) FROM stdin;
\.


--
-- Data for Name: singleton_siteconfigurationwithexplicitlygivenid; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.singleton_siteconfigurationwithexplicitlygivenid (id, site_name) FROM stdin;
\.


--
-- Data for Name: socialaccount_socialaccount; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.socialaccount_socialaccount (id, provider, uid, last_login, date_joined, extra_data, user_id) FROM stdin;
\.


--
-- Data for Name: socialaccount_socialapp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.socialaccount_socialapp (id, provider, name, client_id, secret, key) FROM stdin;
\.


--
-- Data for Name: socialaccount_socialapp_sites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.socialaccount_socialapp_sites (id, socialapp_id, site_id) FROM stdin;
\.


--
-- Data for Name: socialaccount_socialtoken; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.socialaccount_socialtoken (id, token, token_secret, expires_at, account_id, app_id) FROM stdin;
\.


--
-- Data for Name: users_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_user (id, password, last_login, is_superuser, username, email, is_staff, is_active, date_joined, name, phone, timezone, role) FROM stdin;
\.


--
-- Data for Name: users_user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Data for Name: users_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Name: account_emailaddress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_emailaddress_id_seq', 1, false);


--
-- Name: account_emailconfirmation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_emailconfirmation_id_seq', 1, false);


--
-- Name: api_apikey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.api_apikey_id_seq', 14, true);


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 292, true);


--
-- Name: commandcenter_cloudservicesconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_cloudservicesconfiguration_id_seq', 1, false);


--
-- Name: commandcenter_companyinformation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_companyinformation_id_seq', 1, false);


--
-- Name: commandcenter_namecheapconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_namecheapconfiguration_id_seq', 1, false);


--
-- Name: commandcenter_reportconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_reportconfiguration_id_seq', 1, false);


--
-- Name: commandcenter_slackconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_slackconfiguration_id_seq', 1, false);


--
-- Name: commandcenter_virustotalconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commandcenter_virustotalconfiguration_id_seq', 1, false);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 73, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 172, true);


--
-- Name: django_q_ormq_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_q_ormq_id_seq', 1, false);


--
-- Name: django_q_schedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_q_schedule_id_seq', 1, false);


--
-- Name: django_site_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_site_id_seq', 1, false);


--
-- Name: home_userprofile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.home_userprofile_id_seq', 53, true);


--
-- Name: oplog_oplog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oplog_oplog_id_seq', 1, false);


--
-- Name: oplog_oplogentry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oplog_oplogentry_id_seq', 1, false);


--
-- Name: reporting_archive_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_archive_id_seq', 1, false);


--
-- Name: reporting_doctype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_doctype_id_seq', 5, true);


--
-- Name: reporting_evidence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_evidence_id_seq', 2, true);


--
-- Name: reporting_finding_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_finding_id_seq', 1, false);


--
-- Name: reporting_findingnote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_findingnote_id_seq', 1, false);


--
-- Name: reporting_findingtype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_findingtype_id_seq', 2, true);


--
-- Name: reporting_localfindingnote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_localfindingnote_id_seq', 1, false);


--
-- Name: reporting_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_report_id_seq', 4, true);


--
-- Name: reporting_reportfindinglink_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_reportfindinglink_id_seq', 2, true);


--
-- Name: reporting_reporttemplate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_reporttemplate_id_seq', 10, true);


--
-- Name: reporting_severity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reporting_severity_id_seq', 2, true);


--
-- Name: rolodex_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_client_id_seq', 12, true);


--
-- Name: rolodex_clientcontact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_clientcontact_id_seq', 1, false);


--
-- Name: rolodex_clientinvite_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_clientinvite_id_seq', 1, true);


--
-- Name: rolodex_clientnote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_clientnote_id_seq', 1, false);


--
-- Name: rolodex_objectivepriority_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_objectivepriority_id_seq', 1, false);


--
-- Name: rolodex_objectivestatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_objectivestatus_id_seq', 1, false);


--
-- Name: rolodex_project_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_project_id_seq', 9, true);


--
-- Name: rolodex_projectassignment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectassignment_id_seq', 5, true);


--
-- Name: rolodex_projectinvite_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectinvite_id_seq', 1, true);


--
-- Name: rolodex_projectnote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectnote_id_seq', 1, false);


--
-- Name: rolodex_projectobjective_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectobjective_id_seq', 1, false);


--
-- Name: rolodex_projectrole_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectrole_id_seq', 5, true);


--
-- Name: rolodex_projectscope_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectscope_id_seq', 1, false);


--
-- Name: rolodex_projectsubtask_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projectsubtask_id_seq', 1, false);


--
-- Name: rolodex_projecttarget_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projecttarget_id_seq', 1, false);


--
-- Name: rolodex_projecttype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rolodex_projecttype_id_seq', 9, true);


--
-- Name: shepherd_activitytype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_activitytype_id_seq', 4, true);


--
-- Name: shepherd_auxserveraddress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_auxserveraddress_id_seq', 1, false);


--
-- Name: shepherd_domain_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_domain_id_seq', 6, true);


--
-- Name: shepherd_domainnote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_domainnote_id_seq', 1, false);


--
-- Name: shepherd_domainserverconnection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_domainserverconnection_id_seq', 1, false);


--
-- Name: shepherd_domainstatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_domainstatus_id_seq', 6, true);


--
-- Name: shepherd_healthstatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_healthstatus_id_seq', 6, true);


--
-- Name: shepherd_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_history_id_seq', 3, true);


--
-- Name: shepherd_serverhistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_serverhistory_id_seq', 2, true);


--
-- Name: shepherd_servernote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_servernote_id_seq', 1, false);


--
-- Name: shepherd_serverprovider_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_serverprovider_id_seq', 3, true);


--
-- Name: shepherd_serverrole_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_serverrole_id_seq', 2, true);


--
-- Name: shepherd_serverstatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_serverstatus_id_seq', 4, true);


--
-- Name: shepherd_staticserver_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_staticserver_id_seq', 3, true);


--
-- Name: shepherd_transientserver_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_transientserver_id_seq', 1, false);


--
-- Name: shepherd_whoisstatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shepherd_whoisstatus_id_seq', 6, true);


--
-- Name: singleton_siteconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.singleton_siteconfiguration_id_seq', 1, false);


--
-- Name: singleton_siteconfigurationwithexplicitlygivenid_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.singleton_siteconfigurationwithexplicitlygivenid_id_seq', 1, false);


--
-- Name: socialaccount_socialaccount_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.socialaccount_socialaccount_id_seq', 1, false);


--
-- Name: socialaccount_socialapp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.socialaccount_socialapp_id_seq', 1, false);


--
-- Name: socialaccount_socialapp_sites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.socialaccount_socialapp_sites_id_seq', 1, false);


--
-- Name: socialaccount_socialtoken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.socialaccount_socialtoken_id_seq', 1, false);


--
-- Name: users_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_groups_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 53, true);


--
-- Name: users_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_user_permissions_id_seq', 1, false);


--
-- Name: account_emailaddress account_emailaddress_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailaddress
    ADD CONSTRAINT account_emailaddress_email_key UNIQUE (email);


--
-- Name: account_emailaddress account_emailaddress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailaddress
    ADD CONSTRAINT account_emailaddress_pkey PRIMARY KEY (id);


--
-- Name: account_emailconfirmation account_emailconfirmation_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailconfirmation
    ADD CONSTRAINT account_emailconfirmation_key_key UNIQUE (key);


--
-- Name: account_emailconfirmation account_emailconfirmation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailconfirmation
    ADD CONSTRAINT account_emailconfirmation_pkey PRIMARY KEY (id);


--
-- Name: api_apikey api_apikey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_apikey
    ADD CONSTRAINT api_apikey_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_cloudservicesconfiguration commandcenter_cloudservicesconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_cloudservicesconfiguration
    ADD CONSTRAINT commandcenter_cloudservicesconfiguration_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_companyinformation commandcenter_companyinformation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_companyinformation
    ADD CONSTRAINT commandcenter_companyinformation_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_namecheapconfiguration commandcenter_namecheapconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_namecheapconfiguration
    ADD CONSTRAINT commandcenter_namecheapconfiguration_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_reportconfiguration commandcenter_reportconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_reportconfiguration
    ADD CONSTRAINT commandcenter_reportconfiguration_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_slackconfiguration commandcenter_slackconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_slackconfiguration
    ADD CONSTRAINT commandcenter_slackconfiguration_pkey PRIMARY KEY (id);


--
-- Name: commandcenter_virustotalconfiguration commandcenter_virustotalconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_virustotalconfiguration
    ADD CONSTRAINT commandcenter_virustotalconfiguration_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_q_ormq django_q_ormq_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_q_ormq
    ADD CONSTRAINT django_q_ormq_pkey PRIMARY KEY (id);


--
-- Name: django_q_schedule django_q_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_q_schedule
    ADD CONSTRAINT django_q_schedule_pkey PRIMARY KEY (id);


--
-- Name: django_q_task django_q_task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_q_task
    ADD CONSTRAINT django_q_task_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: django_site django_site_domain_a2e37b91_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_site
    ADD CONSTRAINT django_site_domain_a2e37b91_uniq UNIQUE (domain);


--
-- Name: django_site django_site_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_site
    ADD CONSTRAINT django_site_pkey PRIMARY KEY (id);


--
-- Name: home_userprofile home_userprofile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home_userprofile
    ADD CONSTRAINT home_userprofile_pkey PRIMARY KEY (id);


--
-- Name: home_userprofile home_userprofile_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home_userprofile
    ADD CONSTRAINT home_userprofile_user_id_key UNIQUE (user_id);


--
-- Name: oplog_oplog oplog_oplog_name_project_id_cf3103ee_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplog
    ADD CONSTRAINT oplog_oplog_name_project_id_cf3103ee_uniq UNIQUE (name, project_id);


--
-- Name: oplog_oplog oplog_oplog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplog
    ADD CONSTRAINT oplog_oplog_pkey PRIMARY KEY (id);


--
-- Name: oplog_oplogentry oplog_oplogentry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplogentry
    ADD CONSTRAINT oplog_oplogentry_pkey PRIMARY KEY (id);


--
-- Name: reporting_archive reporting_archive_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_archive
    ADD CONSTRAINT reporting_archive_pkey PRIMARY KEY (id);


--
-- Name: reporting_doctype reporting_doctype_doc_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_doctype
    ADD CONSTRAINT reporting_doctype_doc_type_key UNIQUE (doc_type);


--
-- Name: reporting_doctype reporting_doctype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_doctype
    ADD CONSTRAINT reporting_doctype_pkey PRIMARY KEY (id);


--
-- Name: reporting_evidence reporting_evidence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_evidence
    ADD CONSTRAINT reporting_evidence_pkey PRIMARY KEY (id);


--
-- Name: reporting_finding reporting_finding_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_finding
    ADD CONSTRAINT reporting_finding_pkey PRIMARY KEY (id);


--
-- Name: reporting_finding reporting_finding_title_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_finding
    ADD CONSTRAINT reporting_finding_title_key UNIQUE (title);


--
-- Name: reporting_findingnote reporting_findingnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingnote
    ADD CONSTRAINT reporting_findingnote_pkey PRIMARY KEY (id);


--
-- Name: reporting_findingtype reporting_findingtype_finding_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingtype
    ADD CONSTRAINT reporting_findingtype_finding_type_key UNIQUE (finding_type);


--
-- Name: reporting_findingtype reporting_findingtype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingtype
    ADD CONSTRAINT reporting_findingtype_pkey PRIMARY KEY (id);


--
-- Name: reporting_localfindingnote reporting_localfindingnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_localfindingnote
    ADD CONSTRAINT reporting_localfindingnote_pkey PRIMARY KEY (id);


--
-- Name: reporting_report reporting_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report
    ADD CONSTRAINT reporting_report_pkey PRIMARY KEY (id);


--
-- Name: reporting_reportfindinglink reporting_reportfindinglink_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink
    ADD CONSTRAINT reporting_reportfindinglink_pkey PRIMARY KEY (id);


--
-- Name: reporting_reporttemplate reporting_reporttemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reporttemplate
    ADD CONSTRAINT reporting_reporttemplate_pkey PRIMARY KEY (id);


--
-- Name: reporting_severity reporting_severity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_severity
    ADD CONSTRAINT reporting_severity_pkey PRIMARY KEY (id);


--
-- Name: reporting_severity reporting_severity_severity_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_severity
    ADD CONSTRAINT reporting_severity_severity_key UNIQUE (severity);


--
-- Name: rest_framework_api_key_apikey rest_framework_api_key_apikey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rest_framework_api_key_apikey
    ADD CONSTRAINT rest_framework_api_key_apikey_pkey PRIMARY KEY (id);


--
-- Name: rest_framework_api_key_apikey rest_framework_api_key_apikey_prefix_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rest_framework_api_key_apikey
    ADD CONSTRAINT rest_framework_api_key_apikey_prefix_key UNIQUE (prefix);


--
-- Name: rolodex_client rolodex_client_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_client
    ADD CONSTRAINT rolodex_client_name_key UNIQUE (name);


--
-- Name: rolodex_client rolodex_client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_client
    ADD CONSTRAINT rolodex_client_pkey PRIMARY KEY (id);


--
-- Name: rolodex_clientcontact rolodex_clientcontact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientcontact
    ADD CONSTRAINT rolodex_clientcontact_pkey PRIMARY KEY (id);


--
-- Name: rolodex_clientinvite rolodex_clientinvite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientinvite
    ADD CONSTRAINT rolodex_clientinvite_pkey PRIMARY KEY (id);


--
-- Name: rolodex_clientnote rolodex_clientnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientnote
    ADD CONSTRAINT rolodex_clientnote_pkey PRIMARY KEY (id);


--
-- Name: rolodex_objectivepriority rolodex_objectivepriority_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivepriority
    ADD CONSTRAINT rolodex_objectivepriority_pkey PRIMARY KEY (id);


--
-- Name: rolodex_objectivepriority rolodex_objectivepriority_priority_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivepriority
    ADD CONSTRAINT rolodex_objectivepriority_priority_key UNIQUE (priority);


--
-- Name: rolodex_objectivestatus rolodex_objectivestatus_objective_status_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivestatus
    ADD CONSTRAINT rolodex_objectivestatus_objective_status_key UNIQUE (objective_status);


--
-- Name: rolodex_objectivestatus rolodex_objectivestatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_objectivestatus
    ADD CONSTRAINT rolodex_objectivestatus_pkey PRIMARY KEY (id);


--
-- Name: rolodex_project rolodex_project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_project
    ADD CONSTRAINT rolodex_project_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectassignment rolodex_projectassignment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectassignment
    ADD CONSTRAINT rolodex_projectassignment_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectinvite rolodex_projectinvite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectinvite
    ADD CONSTRAINT rolodex_projectinvite_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectnote rolodex_projectnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectnote
    ADD CONSTRAINT rolodex_projectnote_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectobjective rolodex_projectobjective_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectobjective
    ADD CONSTRAINT rolodex_projectobjective_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectrole rolodex_projectrole_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectrole
    ADD CONSTRAINT rolodex_projectrole_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectrole rolodex_projectrole_project_role_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectrole
    ADD CONSTRAINT rolodex_projectrole_project_role_key UNIQUE (project_role);


--
-- Name: rolodex_projectscope rolodex_projectscope_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectscope
    ADD CONSTRAINT rolodex_projectscope_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projectsubtask rolodex_projectsubtask_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectsubtask
    ADD CONSTRAINT rolodex_projectsubtask_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projecttarget rolodex_projecttarget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttarget
    ADD CONSTRAINT rolodex_projecttarget_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projecttype rolodex_projecttype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttype
    ADD CONSTRAINT rolodex_projecttype_pkey PRIMARY KEY (id);


--
-- Name: rolodex_projecttype rolodex_projecttype_project_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttype
    ADD CONSTRAINT rolodex_projecttype_project_type_key UNIQUE (project_type);


--
-- Name: shepherd_activitytype shepherd_activitytype_activity_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_activitytype
    ADD CONSTRAINT shepherd_activitytype_activity_key UNIQUE (activity);


--
-- Name: shepherd_activitytype shepherd_activitytype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_activitytype
    ADD CONSTRAINT shepherd_activitytype_pkey PRIMARY KEY (id);


--
-- Name: shepherd_auxserveraddress shepherd_auxserveraddress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_auxserveraddress
    ADD CONSTRAINT shepherd_auxserveraddress_pkey PRIMARY KEY (id);


--
-- Name: shepherd_domain shepherd_domain_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_name_key UNIQUE (name);


--
-- Name: shepherd_domain shepherd_domain_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_pkey PRIMARY KEY (id);


--
-- Name: shepherd_domainnote shepherd_domainnote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainnote
    ADD CONSTRAINT shepherd_domainnote_pkey PRIMARY KEY (id);


--
-- Name: shepherd_domainserverconnection shepherd_domainserverconnection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection
    ADD CONSTRAINT shepherd_domainserverconnection_pkey PRIMARY KEY (id);


--
-- Name: shepherd_domainstatus shepherd_domainstatus_domain_status_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainstatus
    ADD CONSTRAINT shepherd_domainstatus_domain_status_key UNIQUE (domain_status);


--
-- Name: shepherd_domainstatus shepherd_domainstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainstatus
    ADD CONSTRAINT shepherd_domainstatus_pkey PRIMARY KEY (id);


--
-- Name: shepherd_healthstatus shepherd_healthstatus_health_status_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_healthstatus
    ADD CONSTRAINT shepherd_healthstatus_health_status_key UNIQUE (health_status);


--
-- Name: shepherd_healthstatus shepherd_healthstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_healthstatus
    ADD CONSTRAINT shepherd_healthstatus_pkey PRIMARY KEY (id);


--
-- Name: shepherd_history shepherd_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_pkey PRIMARY KEY (id);


--
-- Name: shepherd_serverhistory shepherd_serverhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_pkey PRIMARY KEY (id);


--
-- Name: shepherd_servernote shepherd_servernote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_servernote
    ADD CONSTRAINT shepherd_servernote_pkey PRIMARY KEY (id);


--
-- Name: shepherd_serverprovider shepherd_serverprovider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverprovider
    ADD CONSTRAINT shepherd_serverprovider_pkey PRIMARY KEY (id);


--
-- Name: shepherd_serverprovider shepherd_serverprovider_server_provider_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverprovider
    ADD CONSTRAINT shepherd_serverprovider_server_provider_key UNIQUE (server_provider);


--
-- Name: shepherd_serverrole shepherd_serverrole_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverrole
    ADD CONSTRAINT shepherd_serverrole_pkey PRIMARY KEY (id);


--
-- Name: shepherd_serverrole shepherd_serverrole_server_role_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverrole
    ADD CONSTRAINT shepherd_serverrole_server_role_key UNIQUE (server_role);


--
-- Name: shepherd_serverstatus shepherd_serverstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverstatus
    ADD CONSTRAINT shepherd_serverstatus_pkey PRIMARY KEY (id);


--
-- Name: shepherd_serverstatus shepherd_serverstatus_server_status_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverstatus
    ADD CONSTRAINT shepherd_serverstatus_server_status_key UNIQUE (server_status);


--
-- Name: shepherd_staticserver shepherd_staticserver_ip_address_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver
    ADD CONSTRAINT shepherd_staticserver_ip_address_key UNIQUE (ip_address);


--
-- Name: shepherd_staticserver shepherd_staticserver_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver
    ADD CONSTRAINT shepherd_staticserver_pkey PRIMARY KEY (id);


--
-- Name: shepherd_transientserver shepherd_transientserver_ip_address_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_ip_address_key UNIQUE (ip_address);


--
-- Name: shepherd_transientserver shepherd_transientserver_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_pkey PRIMARY KEY (id);


--
-- Name: shepherd_whoisstatus shepherd_whoisstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_whoisstatus
    ADD CONSTRAINT shepherd_whoisstatus_pkey PRIMARY KEY (id);


--
-- Name: shepherd_whoisstatus shepherd_whoisstatus_whois_status_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_whoisstatus
    ADD CONSTRAINT shepherd_whoisstatus_whois_status_key UNIQUE (whois_status);


--
-- Name: singleton_siteconfiguration singleton_siteconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.singleton_siteconfiguration
    ADD CONSTRAINT singleton_siteconfiguration_pkey PRIMARY KEY (id);


--
-- Name: singleton_siteconfigurationwithexplicitlygivenid singleton_siteconfigurationwithexplicitlygivenid_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.singleton_siteconfigurationwithexplicitlygivenid
    ADD CONSTRAINT singleton_siteconfigurationwithexplicitlygivenid_pkey PRIMARY KEY (id);


--
-- Name: socialaccount_socialaccount socialaccount_socialaccount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialaccount
    ADD CONSTRAINT socialaccount_socialaccount_pkey PRIMARY KEY (id);


--
-- Name: socialaccount_socialaccount socialaccount_socialaccount_provider_uid_fc810c6e_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialaccount
    ADD CONSTRAINT socialaccount_socialaccount_provider_uid_fc810c6e_uniq UNIQUE (provider, uid);


--
-- Name: socialaccount_socialapp_sites socialaccount_socialapp__socialapp_id_site_id_71a9a768_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp_sites
    ADD CONSTRAINT socialaccount_socialapp__socialapp_id_site_id_71a9a768_uniq UNIQUE (socialapp_id, site_id);


--
-- Name: socialaccount_socialapp socialaccount_socialapp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp
    ADD CONSTRAINT socialaccount_socialapp_pkey PRIMARY KEY (id);


--
-- Name: socialaccount_socialapp_sites socialaccount_socialapp_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp_sites
    ADD CONSTRAINT socialaccount_socialapp_sites_pkey PRIMARY KEY (id);


--
-- Name: socialaccount_socialtoken socialaccount_socialtoken_app_id_account_id_fca4e0ac_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialtoken
    ADD CONSTRAINT socialaccount_socialtoken_app_id_account_id_fca4e0ac_uniq UNIQUE (app_id, account_id);


--
-- Name: socialaccount_socialtoken socialaccount_socialtoken_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialtoken
    ADD CONSTRAINT socialaccount_socialtoken_pkey PRIMARY KEY (id);


--
-- Name: users_user_groups users_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups
    ADD CONSTRAINT users_user_groups_pkey PRIMARY KEY (id);


--
-- Name: users_user_groups users_user_groups_user_id_group_id_b88eab82_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups
    ADD CONSTRAINT users_user_groups_user_id_group_id_b88eab82_uniq UNIQUE (user_id, group_id);


--
-- Name: users_user users_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user
    ADD CONSTRAINT users_user_pkey PRIMARY KEY (id);


--
-- Name: users_user_user_permissions users_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions
    ADD CONSTRAINT users_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: users_user_user_permissions users_user_user_permissions_user_id_permission_id_43338c45_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions
    ADD CONSTRAINT users_user_user_permissions_user_id_permission_id_43338c45_uniq UNIQUE (user_id, permission_id);


--
-- Name: users_user users_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user
    ADD CONSTRAINT users_user_username_key UNIQUE (username);


--
-- Name: account_emailaddress_email_03be32b2_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX account_emailaddress_email_03be32b2_like ON public.account_emailaddress USING btree (email varchar_pattern_ops);


--
-- Name: account_emailaddress_user_id_2c513194; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX account_emailaddress_user_id_2c513194 ON public.account_emailaddress USING btree (user_id);


--
-- Name: account_emailconfirmation_email_address_id_5b7f8c58; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX account_emailconfirmation_email_address_id_5b7f8c58 ON public.account_emailconfirmation USING btree (email_address_id);


--
-- Name: account_emailconfirmation_key_f43612bd_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX account_emailconfirmation_key_f43612bd_like ON public.account_emailconfirmation USING btree (key varchar_pattern_ops);


--
-- Name: api_apikey_created_9c07f10e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_apikey_created_9c07f10e ON public.api_apikey USING btree (created);


--
-- Name: api_apikey_user_id_7ebe0e24; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_apikey_user_id_7ebe0e24 ON public.api_apikey USING btree (user_id);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: commandcenter_reportconfig_default_docx_template_id_f383cbd0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX commandcenter_reportconfig_default_docx_template_id_f383cbd0 ON public.commandcenter_reportconfiguration USING btree (default_docx_template_id);


--
-- Name: commandcenter_reportconfig_default_pptx_template_id_9fc0d6e9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX commandcenter_reportconfig_default_pptx_template_id_9fc0d6e9 ON public.commandcenter_reportconfiguration USING btree (default_pptx_template_id);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_q_task_id_32882367_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_q_task_id_32882367_like ON public.django_q_task USING btree (id varchar_pattern_ops);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: django_site_domain_a2e37b91_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_site_domain_a2e37b91_like ON public.django_site USING btree (domain varchar_pattern_ops);


--
-- Name: oplog_oplog_project_id_fe4a93f0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oplog_oplog_project_id_fe4a93f0 ON public.oplog_oplog USING btree (project_id);


--
-- Name: oplog_oplogentry_oplog_id_id_18ef13d0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oplog_oplogentry_oplog_id_id_18ef13d0 ON public.oplog_oplogentry USING btree (oplog_id_id);


--
-- Name: reporting_archive_project_id_e00a60e1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_archive_project_id_e00a60e1 ON public.reporting_archive USING btree (project_id);


--
-- Name: reporting_doctype_doc_type_4f8902f4_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_doctype_doc_type_4f8902f4_like ON public.reporting_doctype USING btree (doc_type varchar_pattern_ops);


--
-- Name: reporting_evidence_finding_id_00138d5b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_evidence_finding_id_00138d5b ON public.reporting_evidence USING btree (finding_id);


--
-- Name: reporting_evidence_uploaded_by_id_71b7b76f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_evidence_uploaded_by_id_71b7b76f ON public.reporting_evidence USING btree (uploaded_by_id);


--
-- Name: reporting_finding_finding_type_id_576232af; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_finding_finding_type_id_576232af ON public.reporting_finding USING btree (finding_type_id);


--
-- Name: reporting_finding_severity_id_c4aea0a2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_finding_severity_id_c4aea0a2 ON public.reporting_finding USING btree (severity_id);


--
-- Name: reporting_finding_title_04c8a16e_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_finding_title_04c8a16e_like ON public.reporting_finding USING btree (title varchar_pattern_ops);


--
-- Name: reporting_findingnote_finding_id_e9bb21d2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_findingnote_finding_id_e9bb21d2 ON public.reporting_findingnote USING btree (finding_id);


--
-- Name: reporting_findingnote_operator_id_ec6a14fc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_findingnote_operator_id_ec6a14fc ON public.reporting_findingnote USING btree (operator_id);


--
-- Name: reporting_findingtype_finding_type_b1ff95e7_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_findingtype_finding_type_b1ff95e7_like ON public.reporting_findingtype USING btree (finding_type varchar_pattern_ops);


--
-- Name: reporting_localfindingnote_finding_id_667858fe; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_localfindingnote_finding_id_667858fe ON public.reporting_localfindingnote USING btree (finding_id);


--
-- Name: reporting_localfindingnote_operator_id_ccc74743; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_localfindingnote_operator_id_ccc74743 ON public.reporting_localfindingnote USING btree (operator_id);


--
-- Name: reporting_report_created_by_id_1c6d7e8d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_report_created_by_id_1c6d7e8d ON public.reporting_report USING btree (created_by_id);


--
-- Name: reporting_report_docx_template_id_f9bf3a47; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_report_docx_template_id_f9bf3a47 ON public.reporting_report USING btree (docx_template_id);


--
-- Name: reporting_report_pptx_template_id_b818b902; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_report_pptx_template_id_b818b902 ON public.reporting_report USING btree (pptx_template_id);


--
-- Name: reporting_report_project_id_8d586862; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_report_project_id_8d586862 ON public.reporting_report USING btree (project_id);


--
-- Name: reporting_reportfindinglink_assigned_to_id_586a64f4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reportfindinglink_assigned_to_id_586a64f4 ON public.reporting_reportfindinglink USING btree (assigned_to_id);


--
-- Name: reporting_reportfindinglink_finding_type_id_b165acad; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reportfindinglink_finding_type_id_b165acad ON public.reporting_reportfindinglink USING btree (finding_type_id);


--
-- Name: reporting_reportfindinglink_report_id_173cdfe4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reportfindinglink_report_id_173cdfe4 ON public.reporting_reportfindinglink USING btree (report_id);


--
-- Name: reporting_reportfindinglink_severity_id_ed92c09e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reportfindinglink_severity_id_ed92c09e ON public.reporting_reportfindinglink USING btree (severity_id);


--
-- Name: reporting_reporttemplate_client_id_119d84a5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reporttemplate_client_id_119d84a5 ON public.reporting_reporttemplate USING btree (client_id);


--
-- Name: reporting_reporttemplate_doc_type_id_6e8237de; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reporttemplate_doc_type_id_6e8237de ON public.reporting_reporttemplate USING btree (doc_type_id);


--
-- Name: reporting_reporttemplate_uploaded_by_id_03b1497c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_reporttemplate_uploaded_by_id_03b1497c ON public.reporting_reporttemplate USING btree (uploaded_by_id);


--
-- Name: reporting_severity_severity_22f33466_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reporting_severity_severity_22f33466_like ON public.reporting_severity USING btree (severity varchar_pattern_ops);


--
-- Name: rest_framework_api_key_apikey_created_c61872d9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rest_framework_api_key_apikey_created_c61872d9 ON public.rest_framework_api_key_apikey USING btree (created);


--
-- Name: rest_framework_api_key_apikey_id_6e07e68e_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rest_framework_api_key_apikey_id_6e07e68e_like ON public.rest_framework_api_key_apikey USING btree (id varchar_pattern_ops);


--
-- Name: rest_framework_api_key_apikey_prefix_4e0db5f8_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rest_framework_api_key_apikey_prefix_4e0db5f8_like ON public.rest_framework_api_key_apikey USING btree (prefix varchar_pattern_ops);


--
-- Name: rolodex_client_name_98e55485_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_client_name_98e55485_like ON public.rolodex_client USING btree (name varchar_pattern_ops);


--
-- Name: rolodex_clientcontact_client_id_48f1bd5e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_clientcontact_client_id_48f1bd5e ON public.rolodex_clientcontact USING btree (client_id);


--
-- Name: rolodex_clientinvite_client_id_5d0aef60; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_clientinvite_client_id_5d0aef60 ON public.rolodex_clientinvite USING btree (client_id);


--
-- Name: rolodex_clientinvite_user_id_7ca0ba49; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_clientinvite_user_id_7ca0ba49 ON public.rolodex_clientinvite USING btree (user_id);


--
-- Name: rolodex_clientnote_client_id_c2ca9488; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_clientnote_client_id_c2ca9488 ON public.rolodex_clientnote USING btree (client_id);


--
-- Name: rolodex_clientnote_operator_id_739d4005; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_clientnote_operator_id_739d4005 ON public.rolodex_clientnote USING btree (operator_id);


--
-- Name: rolodex_objectivepriority_priority_b62df365_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_objectivepriority_priority_b62df365_like ON public.rolodex_objectivepriority USING btree (priority varchar_pattern_ops);


--
-- Name: rolodex_objectivestatus_objective_status_788992bb_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_objectivestatus_objective_status_788992bb_like ON public.rolodex_objectivestatus USING btree (objective_status varchar_pattern_ops);


--
-- Name: rolodex_project_client_id_ebd2cbf5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_project_client_id_ebd2cbf5 ON public.rolodex_project USING btree (client_id);


--
-- Name: rolodex_project_operator_id_9e407adf; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_project_operator_id_9e407adf ON public.rolodex_project USING btree (operator_id);


--
-- Name: rolodex_project_project_type_id_07953f1d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_project_project_type_id_07953f1d ON public.rolodex_project USING btree (project_type_id);


--
-- Name: rolodex_projectassignment_operator_id_c4c462d8; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectassignment_operator_id_c4c462d8 ON public.rolodex_projectassignment USING btree (operator_id);


--
-- Name: rolodex_projectassignment_project_id_ce701acc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectassignment_project_id_ce701acc ON public.rolodex_projectassignment USING btree (project_id);


--
-- Name: rolodex_projectassignment_role_id_cbab79b0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectassignment_role_id_cbab79b0 ON public.rolodex_projectassignment USING btree (role_id);


--
-- Name: rolodex_projectinvite_project_id_d510b642; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectinvite_project_id_d510b642 ON public.rolodex_projectinvite USING btree (project_id);


--
-- Name: rolodex_projectinvite_user_id_13704bd9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectinvite_user_id_13704bd9 ON public.rolodex_projectinvite USING btree (user_id);


--
-- Name: rolodex_projectnote_operator_id_5b9299b1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectnote_operator_id_5b9299b1 ON public.rolodex_projectnote USING btree (operator_id);


--
-- Name: rolodex_projectnote_project_id_79acb8a5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectnote_project_id_79acb8a5 ON public.rolodex_projectnote USING btree (project_id);


--
-- Name: rolodex_projectobjective_priority_id_cf6de852; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectobjective_priority_id_cf6de852 ON public.rolodex_projectobjective USING btree (priority_id);


--
-- Name: rolodex_projectobjective_project_id_62b27a4b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectobjective_project_id_62b27a4b ON public.rolodex_projectobjective USING btree (project_id);


--
-- Name: rolodex_projectobjective_status_id_98de9086; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectobjective_status_id_98de9086 ON public.rolodex_projectobjective USING btree (status_id);


--
-- Name: rolodex_projectrole_project_role_4166a92d_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectrole_project_role_4166a92d_like ON public.rolodex_projectrole USING btree (project_role varchar_pattern_ops);


--
-- Name: rolodex_projectscope_project_id_dcf53f05; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectscope_project_id_dcf53f05 ON public.rolodex_projectscope USING btree (project_id);


--
-- Name: rolodex_projectsubtask_parent_id_63a99f77; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectsubtask_parent_id_63a99f77 ON public.rolodex_projectsubtask USING btree (parent_id);


--
-- Name: rolodex_projectsubtask_status_id_c5e132c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projectsubtask_status_id_c5e132c9 ON public.rolodex_projectsubtask USING btree (status_id);


--
-- Name: rolodex_projecttarget_project_id_69dd3e2f; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projecttarget_project_id_69dd3e2f ON public.rolodex_projecttarget USING btree (project_id);


--
-- Name: rolodex_projecttype_project_type_d0196b5d_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rolodex_projecttype_project_type_d0196b5d_like ON public.rolodex_projecttype USING btree (project_type varchar_pattern_ops);


--
-- Name: shepherd_activitytype_activity_63101d2c_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_activitytype_activity_63101d2c_like ON public.shepherd_activitytype USING btree (activity varchar_pattern_ops);


--
-- Name: shepherd_auxserveraddress_static_server_id_5112503d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_auxserveraddress_static_server_id_5112503d ON public.shepherd_auxserveraddress USING btree (static_server_id);


--
-- Name: shepherd_domain_domain_status_id_a2fa7330; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domain_domain_status_id_a2fa7330 ON public.shepherd_domain USING btree (domain_status_id);


--
-- Name: shepherd_domain_health_status_id_cebe65d3; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domain_health_status_id_cebe65d3 ON public.shepherd_domain USING btree (health_status_id);


--
-- Name: shepherd_domain_last_used_by_id_119db0c5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domain_last_used_by_id_119db0c5 ON public.shepherd_domain USING btree (last_used_by_id);


--
-- Name: shepherd_domain_name_41096be4_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domain_name_41096be4_like ON public.shepherd_domain USING btree (name varchar_pattern_ops);


--
-- Name: shepherd_domain_whois_status_id_a0721cb6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domain_whois_status_id_a0721cb6 ON public.shepherd_domain USING btree (whois_status_id);


--
-- Name: shepherd_domainnote_domain_id_9e6a4961; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainnote_domain_id_9e6a4961 ON public.shepherd_domainnote USING btree (domain_id);


--
-- Name: shepherd_domainnote_operator_id_040fcb51; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainnote_operator_id_040fcb51 ON public.shepherd_domainnote USING btree (operator_id);


--
-- Name: shepherd_domainserverconnection_domain_id_398e22e4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainserverconnection_domain_id_398e22e4 ON public.shepherd_domainserverconnection USING btree (domain_id);


--
-- Name: shepherd_domainserverconnection_project_id_35af0efe; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainserverconnection_project_id_35af0efe ON public.shepherd_domainserverconnection USING btree (project_id);


--
-- Name: shepherd_domainserverconnection_static_server_id_2ab6ed26; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainserverconnection_static_server_id_2ab6ed26 ON public.shepherd_domainserverconnection USING btree (static_server_id);


--
-- Name: shepherd_domainserverconnection_transient_server_id_48f0ff5a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainserverconnection_transient_server_id_48f0ff5a ON public.shepherd_domainserverconnection USING btree (transient_server_id);


--
-- Name: shepherd_domainstatus_domain_status_5c10b8e9_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_domainstatus_domain_status_5c10b8e9_like ON public.shepherd_domainstatus USING btree (domain_status varchar_pattern_ops);


--
-- Name: shepherd_healthstatus_health_status_17241bb6_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_healthstatus_health_status_17241bb6_like ON public.shepherd_healthstatus USING btree (health_status varchar_pattern_ops);


--
-- Name: shepherd_history_activity_type_id_a2669c34; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_history_activity_type_id_a2669c34 ON public.shepherd_history USING btree (activity_type_id);


--
-- Name: shepherd_history_client_id_89d8cfd3; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_history_client_id_89d8cfd3 ON public.shepherd_history USING btree (client_id);


--
-- Name: shepherd_history_domain_id_5ac2c2ca; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_history_domain_id_5ac2c2ca ON public.shepherd_history USING btree (domain_id);


--
-- Name: shepherd_history_operator_id_0acb0189; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_history_operator_id_0acb0189 ON public.shepherd_history USING btree (operator_id);


--
-- Name: shepherd_history_project_id_1fe0dabb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_history_project_id_1fe0dabb ON public.shepherd_history USING btree (project_id);


--
-- Name: shepherd_serverhistory_activity_type_id_b8698fb0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_activity_type_id_b8698fb0 ON public.shepherd_serverhistory USING btree (activity_type_id);


--
-- Name: shepherd_serverhistory_client_id_132ff5c2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_client_id_132ff5c2 ON public.shepherd_serverhistory USING btree (client_id);


--
-- Name: shepherd_serverhistory_operator_id_34e8e348; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_operator_id_34e8e348 ON public.shepherd_serverhistory USING btree (operator_id);


--
-- Name: shepherd_serverhistory_project_id_1c40d316; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_project_id_1c40d316 ON public.shepherd_serverhistory USING btree (project_id);


--
-- Name: shepherd_serverhistory_server_id_cd484fac; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_server_id_cd484fac ON public.shepherd_serverhistory USING btree (server_id);


--
-- Name: shepherd_serverhistory_server_role_id_d6b6cc81; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverhistory_server_role_id_d6b6cc81 ON public.shepherd_serverhistory USING btree (server_role_id);


--
-- Name: shepherd_servernote_operator_id_0645b3ab; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_servernote_operator_id_0645b3ab ON public.shepherd_servernote USING btree (operator_id);


--
-- Name: shepherd_servernote_server_id_30ba51f2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_servernote_server_id_30ba51f2 ON public.shepherd_servernote USING btree (server_id);


--
-- Name: shepherd_serverprovider_server_provider_b5fbd433_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverprovider_server_provider_b5fbd433_like ON public.shepherd_serverprovider USING btree (server_provider varchar_pattern_ops);


--
-- Name: shepherd_serverrole_server_role_083b015e_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverrole_server_role_083b015e_like ON public.shepherd_serverrole USING btree (server_role varchar_pattern_ops);


--
-- Name: shepherd_serverstatus_server_status_f5001f85_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_serverstatus_server_status_f5001f85_like ON public.shepherd_serverstatus USING btree (server_status varchar_pattern_ops);


--
-- Name: shepherd_staticserver_last_used_by_id_442a30d9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_staticserver_last_used_by_id_442a30d9 ON public.shepherd_staticserver USING btree (last_used_by_id);


--
-- Name: shepherd_staticserver_server_provider_id_11a19799; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_staticserver_server_provider_id_11a19799 ON public.shepherd_staticserver USING btree (server_provider_id);


--
-- Name: shepherd_staticserver_server_status_id_d41f1ab4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_staticserver_server_status_id_d41f1ab4 ON public.shepherd_staticserver USING btree (server_status_id);


--
-- Name: shepherd_transientserver_activity_type_id_97b100c2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_transientserver_activity_type_id_97b100c2 ON public.shepherd_transientserver USING btree (activity_type_id);


--
-- Name: shepherd_transientserver_operator_id_d2301a78; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_transientserver_operator_id_d2301a78 ON public.shepherd_transientserver USING btree (operator_id);


--
-- Name: shepherd_transientserver_project_id_f0e29dd2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_transientserver_project_id_f0e29dd2 ON public.shepherd_transientserver USING btree (project_id);


--
-- Name: shepherd_transientserver_server_provider_id_e89609a9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_transientserver_server_provider_id_e89609a9 ON public.shepherd_transientserver USING btree (server_provider_id);


--
-- Name: shepherd_transientserver_server_role_id_7e24d482; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_transientserver_server_role_id_7e24d482 ON public.shepherd_transientserver USING btree (server_role_id);


--
-- Name: shepherd_whoisstatus_whois_status_10b8b42e_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shepherd_whoisstatus_whois_status_10b8b42e_like ON public.shepherd_whoisstatus USING btree (whois_status varchar_pattern_ops);


--
-- Name: socialaccount_socialaccount_user_id_8146e70c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX socialaccount_socialaccount_user_id_8146e70c ON public.socialaccount_socialaccount USING btree (user_id);


--
-- Name: socialaccount_socialapp_sites_site_id_2579dee5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX socialaccount_socialapp_sites_site_id_2579dee5 ON public.socialaccount_socialapp_sites USING btree (site_id);


--
-- Name: socialaccount_socialapp_sites_socialapp_id_97fb6e7d; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX socialaccount_socialapp_sites_socialapp_id_97fb6e7d ON public.socialaccount_socialapp_sites USING btree (socialapp_id);


--
-- Name: socialaccount_socialtoken_account_id_951f210e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX socialaccount_socialtoken_account_id_951f210e ON public.socialaccount_socialtoken USING btree (account_id);


--
-- Name: socialaccount_socialtoken_app_id_636a42d7; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX socialaccount_socialtoken_app_id_636a42d7 ON public.socialaccount_socialtoken USING btree (app_id);


--
-- Name: users_user_groups_group_id_9afc8d0e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_groups_group_id_9afc8d0e ON public.users_user_groups USING btree (group_id);


--
-- Name: users_user_groups_user_id_5f6f5a90; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_groups_user_id_5f6f5a90 ON public.users_user_groups USING btree (user_id);


--
-- Name: users_user_user_permissions_permission_id_0b93982e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_user_permissions_permission_id_0b93982e ON public.users_user_user_permissions USING btree (permission_id);


--
-- Name: users_user_user_permissions_user_id_20aca447; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_user_permissions_user_id_20aca447 ON public.users_user_user_permissions USING btree (user_id);


--
-- Name: users_user_username_06e46fe6_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_username_06e46fe6_like ON public.users_user USING btree (username varchar_pattern_ops);


--
-- Name: account_emailaddress account_emailaddress_user_id_2c513194_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailaddress
    ADD CONSTRAINT account_emailaddress_user_id_2c513194_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: account_emailconfirmation account_emailconfirm_email_address_id_5b7f8c58_fk_account_e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_emailconfirmation
    ADD CONSTRAINT account_emailconfirm_email_address_id_5b7f8c58_fk_account_e FOREIGN KEY (email_address_id) REFERENCES public.account_emailaddress(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: api_apikey api_apikey_user_id_7ebe0e24_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_apikey
    ADD CONSTRAINT api_apikey_user_id_7ebe0e24_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: commandcenter_reportconfiguration commandcenter_reportconfi_default_docx_template_id_f383cbd0_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_reportconfiguration
    ADD CONSTRAINT commandcenter_reportconfi_default_docx_template_id_f383cbd0_fk FOREIGN KEY (default_docx_template_id) REFERENCES public.reporting_reporttemplate(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: commandcenter_reportconfiguration commandcenter_reportconfi_default_pptx_template_id_9fc0d6e9_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commandcenter_reportconfiguration
    ADD CONSTRAINT commandcenter_reportconfi_default_pptx_template_id_9fc0d6e9_fk FOREIGN KEY (default_pptx_template_id) REFERENCES public.reporting_reporttemplate(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: home_userprofile home_userprofile_user_id_d1f7b466_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home_userprofile
    ADD CONSTRAINT home_userprofile_user_id_d1f7b466_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: oplog_oplog oplog_oplog_project_id_fe4a93f0_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplog
    ADD CONSTRAINT oplog_oplog_project_id_fe4a93f0_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: oplog_oplogentry oplog_oplogentry_oplog_id_id_18ef13d0_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oplog_oplogentry
    ADD CONSTRAINT oplog_oplogentry_oplog_id_id_18ef13d0_fk FOREIGN KEY (oplog_id_id) REFERENCES public.oplog_oplog(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_archive reporting_archive_project_id_e00a60e1_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_archive
    ADD CONSTRAINT reporting_archive_project_id_e00a60e1_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_evidence reporting_evidence_finding_id_00138d5b_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_evidence
    ADD CONSTRAINT reporting_evidence_finding_id_00138d5b_fk FOREIGN KEY (finding_id) REFERENCES public.reporting_reportfindinglink(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_evidence reporting_evidence_uploaded_by_id_71b7b76f_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_evidence
    ADD CONSTRAINT reporting_evidence_uploaded_by_id_71b7b76f_fk FOREIGN KEY (uploaded_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_finding reporting_finding_finding_type_id_576232af_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_finding
    ADD CONSTRAINT reporting_finding_finding_type_id_576232af_fk FOREIGN KEY (finding_type_id) REFERENCES public.reporting_findingtype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_finding reporting_finding_severity_id_c4aea0a2_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_finding
    ADD CONSTRAINT reporting_finding_severity_id_c4aea0a2_fk FOREIGN KEY (severity_id) REFERENCES public.reporting_severity(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_findingnote reporting_findingnote_finding_id_e9bb21d2_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingnote
    ADD CONSTRAINT reporting_findingnote_finding_id_e9bb21d2_fk FOREIGN KEY (finding_id) REFERENCES public.reporting_finding(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_findingnote reporting_findingnote_operator_id_ec6a14fc_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_findingnote
    ADD CONSTRAINT reporting_findingnote_operator_id_ec6a14fc_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_localfindingnote reporting_localfindingnote_finding_id_667858fe_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_localfindingnote
    ADD CONSTRAINT reporting_localfindingnote_finding_id_667858fe_fk FOREIGN KEY (finding_id) REFERENCES public.reporting_reportfindinglink(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_localfindingnote reporting_localfindingnote_operator_id_ccc74743_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_localfindingnote
    ADD CONSTRAINT reporting_localfindingnote_operator_id_ccc74743_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_report reporting_report_created_by_id_1c6d7e8d_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report
    ADD CONSTRAINT reporting_report_created_by_id_1c6d7e8d_fk FOREIGN KEY (created_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_report reporting_report_docx_template_id_f9bf3a47_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report
    ADD CONSTRAINT reporting_report_docx_template_id_f9bf3a47_fk FOREIGN KEY (docx_template_id) REFERENCES public.reporting_reporttemplate(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_report reporting_report_pptx_template_id_b818b902_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report
    ADD CONSTRAINT reporting_report_pptx_template_id_b818b902_fk FOREIGN KEY (pptx_template_id) REFERENCES public.reporting_reporttemplate(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_report reporting_report_project_id_8d586862_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_report
    ADD CONSTRAINT reporting_report_project_id_8d586862_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reportfindinglink reporting_reportfindinglink_assigned_to_id_586a64f4_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink
    ADD CONSTRAINT reporting_reportfindinglink_assigned_to_id_586a64f4_fk FOREIGN KEY (assigned_to_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reportfindinglink reporting_reportfindinglink_finding_type_id_b165acad_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink
    ADD CONSTRAINT reporting_reportfindinglink_finding_type_id_b165acad_fk FOREIGN KEY (finding_type_id) REFERENCES public.reporting_findingtype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reportfindinglink reporting_reportfindinglink_report_id_173cdfe4_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink
    ADD CONSTRAINT reporting_reportfindinglink_report_id_173cdfe4_fk FOREIGN KEY (report_id) REFERENCES public.reporting_report(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reportfindinglink reporting_reportfindinglink_severity_id_ed92c09e_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reportfindinglink
    ADD CONSTRAINT reporting_reportfindinglink_severity_id_ed92c09e_fk FOREIGN KEY (severity_id) REFERENCES public.reporting_severity(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reporttemplate reporting_reporttemplate_client_id_119d84a5_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reporttemplate
    ADD CONSTRAINT reporting_reporttemplate_client_id_119d84a5_fk FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reporttemplate reporting_reporttemplate_doc_type_id_6e8237de_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reporttemplate
    ADD CONSTRAINT reporting_reporttemplate_doc_type_id_6e8237de_fk FOREIGN KEY (doc_type_id) REFERENCES public.reporting_doctype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reporting_reporttemplate reporting_reporttemplate_uploaded_by_id_03b1497c_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reporting_reporttemplate
    ADD CONSTRAINT reporting_reporttemplate_uploaded_by_id_03b1497c_fk FOREIGN KEY (uploaded_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_clientcontact rolodex_clientcontact_client_id_48f1bd5e_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientcontact
    ADD CONSTRAINT rolodex_clientcontact_client_id_48f1bd5e_fk FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_clientinvite rolodex_clientinvite_client_id_5d0aef60_fk_rolodex_client_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientinvite
    ADD CONSTRAINT rolodex_clientinvite_client_id_5d0aef60_fk_rolodex_client_id FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_clientinvite rolodex_clientinvite_user_id_7ca0ba49_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientinvite
    ADD CONSTRAINT rolodex_clientinvite_user_id_7ca0ba49_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_clientnote rolodex_clientnote_client_id_c2ca9488_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientnote
    ADD CONSTRAINT rolodex_clientnote_client_id_c2ca9488_fk FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_clientnote rolodex_clientnote_operator_id_739d4005_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_clientnote
    ADD CONSTRAINT rolodex_clientnote_operator_id_739d4005_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_project rolodex_project_client_id_ebd2cbf5_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_project
    ADD CONSTRAINT rolodex_project_client_id_ebd2cbf5_fk FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_project rolodex_project_operator_id_9e407adf_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_project
    ADD CONSTRAINT rolodex_project_operator_id_9e407adf_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_project rolodex_project_project_type_id_07953f1d_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_project
    ADD CONSTRAINT rolodex_project_project_type_id_07953f1d_fk FOREIGN KEY (project_type_id) REFERENCES public.rolodex_projecttype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectassignment rolodex_projectassignment_operator_id_c4c462d8_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectassignment
    ADD CONSTRAINT rolodex_projectassignment_operator_id_c4c462d8_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectassignment rolodex_projectassignment_project_id_ce701acc_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectassignment
    ADD CONSTRAINT rolodex_projectassignment_project_id_ce701acc_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectassignment rolodex_projectassignment_role_id_cbab79b0_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectassignment
    ADD CONSTRAINT rolodex_projectassignment_role_id_cbab79b0_fk FOREIGN KEY (role_id) REFERENCES public.rolodex_projectrole(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectinvite rolodex_projectinvite_project_id_d510b642_fk_rolodex_project_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectinvite
    ADD CONSTRAINT rolodex_projectinvite_project_id_d510b642_fk_rolodex_project_id FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectinvite rolodex_projectinvite_user_id_13704bd9_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectinvite
    ADD CONSTRAINT rolodex_projectinvite_user_id_13704bd9_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectnote rolodex_projectnote_operator_id_5b9299b1_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectnote
    ADD CONSTRAINT rolodex_projectnote_operator_id_5b9299b1_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectnote rolodex_projectnote_project_id_79acb8a5_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectnote
    ADD CONSTRAINT rolodex_projectnote_project_id_79acb8a5_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectobjective rolodex_projectobjective_priority_id_cf6de852_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectobjective
    ADD CONSTRAINT rolodex_projectobjective_priority_id_cf6de852_fk FOREIGN KEY (priority_id) REFERENCES public.rolodex_objectivepriority(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectobjective rolodex_projectobjective_project_id_62b27a4b_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectobjective
    ADD CONSTRAINT rolodex_projectobjective_project_id_62b27a4b_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectobjective rolodex_projectobjective_status_id_98de9086_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectobjective
    ADD CONSTRAINT rolodex_projectobjective_status_id_98de9086_fk FOREIGN KEY (status_id) REFERENCES public.rolodex_objectivestatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectscope rolodex_projectscope_project_id_dcf53f05_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectscope
    ADD CONSTRAINT rolodex_projectscope_project_id_dcf53f05_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectsubtask rolodex_projectsubtask_parent_id_63a99f77_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectsubtask
    ADD CONSTRAINT rolodex_projectsubtask_parent_id_63a99f77_fk FOREIGN KEY (parent_id) REFERENCES public.rolodex_projectobjective(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projectsubtask rolodex_projectsubtask_status_id_c5e132c9_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projectsubtask
    ADD CONSTRAINT rolodex_projectsubtask_status_id_c5e132c9_fk FOREIGN KEY (status_id) REFERENCES public.rolodex_objectivestatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rolodex_projecttarget rolodex_projecttarget_project_id_69dd3e2f_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolodex_projecttarget
    ADD CONSTRAINT rolodex_projecttarget_project_id_69dd3e2f_fk FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_auxserveraddress shepherd_auxserveraddress_static_server_id_5112503d_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_auxserveraddress
    ADD CONSTRAINT shepherd_auxserveraddress_static_server_id_5112503d_fk FOREIGN KEY (static_server_id) REFERENCES public.shepherd_staticserver(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domain shepherd_domain_domain_status_id_a2fa7330_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_domain_status_id_a2fa7330_fk FOREIGN KEY (domain_status_id) REFERENCES public.shepherd_domainstatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domain shepherd_domain_health_status_id_cebe65d3_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_health_status_id_cebe65d3_fk FOREIGN KEY (health_status_id) REFERENCES public.shepherd_healthstatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domain shepherd_domain_last_used_by_id_119db0c5_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_last_used_by_id_119db0c5_fk FOREIGN KEY (last_used_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domain shepherd_domain_whois_status_id_a0721cb6_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domain
    ADD CONSTRAINT shepherd_domain_whois_status_id_a0721cb6_fk FOREIGN KEY (whois_status_id) REFERENCES public.shepherd_whoisstatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainnote shepherd_domainnote_domain_id_9e6a4961_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainnote
    ADD CONSTRAINT shepherd_domainnote_domain_id_9e6a4961_fk FOREIGN KEY (domain_id) REFERENCES public.shepherd_domain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainnote shepherd_domainnote_operator_id_040fcb51_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainnote
    ADD CONSTRAINT shepherd_domainnote_operator_id_040fcb51_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainserverconnection shepherd_domainserve_project_id_35af0efe_fk_rolodex_p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection
    ADD CONSTRAINT shepherd_domainserve_project_id_35af0efe_fk_rolodex_p FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainserverconnection shepherd_domainserverconnection_domain_id_398e22e4_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection
    ADD CONSTRAINT shepherd_domainserverconnection_domain_id_398e22e4_fk FOREIGN KEY (domain_id) REFERENCES public.shepherd_history(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainserverconnection shepherd_domainserverconnection_static_server_id_2ab6ed26_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection
    ADD CONSTRAINT shepherd_domainserverconnection_static_server_id_2ab6ed26_fk FOREIGN KEY (static_server_id) REFERENCES public.shepherd_serverhistory(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_domainserverconnection shepherd_domainserverconnection_transient_server_id_48f0ff5a_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_domainserverconnection
    ADD CONSTRAINT shepherd_domainserverconnection_transient_server_id_48f0ff5a_fk FOREIGN KEY (transient_server_id) REFERENCES public.shepherd_transientserver(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_history shepherd_history_activity_type_id_a2669c34_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_activity_type_id_a2669c34_fk FOREIGN KEY (activity_type_id) REFERENCES public.shepherd_activitytype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_history shepherd_history_client_id_89d8cfd3_fk_rolodex_client_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_client_id_89d8cfd3_fk_rolodex_client_id FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_history shepherd_history_domain_id_5ac2c2ca_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_domain_id_5ac2c2ca_fk FOREIGN KEY (domain_id) REFERENCES public.shepherd_domain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_history shepherd_history_operator_id_0acb0189_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_operator_id_0acb0189_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_history shepherd_history_project_id_1fe0dabb_fk_rolodex_project_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_history
    ADD CONSTRAINT shepherd_history_project_id_1fe0dabb_fk_rolodex_project_id FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhisto_project_id_1c40d316_fk_rolodex_p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhisto_project_id_1c40d316_fk_rolodex_p FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhistory_activity_type_id_b8698fb0_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_activity_type_id_b8698fb0_fk FOREIGN KEY (activity_type_id) REFERENCES public.shepherd_activitytype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhistory_client_id_132ff5c2_fk_rolodex_client_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_client_id_132ff5c2_fk_rolodex_client_id FOREIGN KEY (client_id) REFERENCES public.rolodex_client(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhistory_operator_id_34e8e348_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_operator_id_34e8e348_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhistory_server_id_cd484fac_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_server_id_cd484fac_fk FOREIGN KEY (server_id) REFERENCES public.shepherd_staticserver(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_serverhistory shepherd_serverhistory_server_role_id_d6b6cc81_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_serverhistory
    ADD CONSTRAINT shepherd_serverhistory_server_role_id_d6b6cc81_fk FOREIGN KEY (server_role_id) REFERENCES public.shepherd_serverrole(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_servernote shepherd_servernote_operator_id_0645b3ab_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_servernote
    ADD CONSTRAINT shepherd_servernote_operator_id_0645b3ab_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_servernote shepherd_servernote_server_id_30ba51f2_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_servernote
    ADD CONSTRAINT shepherd_servernote_server_id_30ba51f2_fk FOREIGN KEY (server_id) REFERENCES public.shepherd_staticserver(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_staticserver shepherd_staticserver_last_used_by_id_442a30d9_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver
    ADD CONSTRAINT shepherd_staticserver_last_used_by_id_442a30d9_fk FOREIGN KEY (last_used_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_staticserver shepherd_staticserver_server_provider_id_11a19799_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver
    ADD CONSTRAINT shepherd_staticserver_server_provider_id_11a19799_fk FOREIGN KEY (server_provider_id) REFERENCES public.shepherd_serverprovider(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_staticserver shepherd_staticserver_server_status_id_d41f1ab4_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_staticserver
    ADD CONSTRAINT shepherd_staticserver_server_status_id_d41f1ab4_fk FOREIGN KEY (server_status_id) REFERENCES public.shepherd_serverstatus(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_transientserver shepherd_transientse_project_id_f0e29dd2_fk_rolodex_p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientse_project_id_f0e29dd2_fk_rolodex_p FOREIGN KEY (project_id) REFERENCES public.rolodex_project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_transientserver shepherd_transientserver_activity_type_id_97b100c2_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_activity_type_id_97b100c2_fk FOREIGN KEY (activity_type_id) REFERENCES public.shepherd_activitytype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_transientserver shepherd_transientserver_operator_id_d2301a78_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_operator_id_d2301a78_fk FOREIGN KEY (operator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_transientserver shepherd_transientserver_server_provider_id_e89609a9_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_server_provider_id_e89609a9_fk FOREIGN KEY (server_provider_id) REFERENCES public.shepherd_serverprovider(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shepherd_transientserver shepherd_transientserver_server_role_id_7e24d482_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shepherd_transientserver
    ADD CONSTRAINT shepherd_transientserver_server_role_id_7e24d482_fk FOREIGN KEY (server_role_id) REFERENCES public.shepherd_serverrole(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: socialaccount_socialtoken socialaccount_social_account_id_951f210e_fk_socialacc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialtoken
    ADD CONSTRAINT socialaccount_social_account_id_951f210e_fk_socialacc FOREIGN KEY (account_id) REFERENCES public.socialaccount_socialaccount(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: socialaccount_socialtoken socialaccount_social_app_id_636a42d7_fk_socialacc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialtoken
    ADD CONSTRAINT socialaccount_social_app_id_636a42d7_fk_socialacc FOREIGN KEY (app_id) REFERENCES public.socialaccount_socialapp(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: socialaccount_socialapp_sites socialaccount_social_site_id_2579dee5_fk_django_si; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp_sites
    ADD CONSTRAINT socialaccount_social_site_id_2579dee5_fk_django_si FOREIGN KEY (site_id) REFERENCES public.django_site(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: socialaccount_socialapp_sites socialaccount_social_socialapp_id_97fb6e7d_fk_socialacc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialapp_sites
    ADD CONSTRAINT socialaccount_social_socialapp_id_97fb6e7d_fk_socialacc FOREIGN KEY (socialapp_id) REFERENCES public.socialaccount_socialapp(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: socialaccount_socialaccount socialaccount_socialaccount_user_id_8146e70c_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.socialaccount_socialaccount
    ADD CONSTRAINT socialaccount_socialaccount_user_id_8146e70c_fk FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_user_groups users_user_groups_group_id_9afc8d0e_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups
    ADD CONSTRAINT users_user_groups_group_id_9afc8d0e_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_user_user_permissions users_user_user_perm_permission_id_0b93982e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions
    ADD CONSTRAINT users_user_user_perm_permission_id_0b93982e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

