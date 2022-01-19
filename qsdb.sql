--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.1

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

SET default_table_access_method = heap;

--
-- Name: accounts_firebase; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts_firebase (
    id double precision,
    user_id double precision,
    firebase_id text,
    created timestamp with time zone,
    modified timestamp with time zone
);


ALTER TABLE public.accounts_firebase OWNER TO postgres;

--
-- Name: accounts_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts_user (
    id integer,
    user_id integer,
    created text,
    modified text,
    first_name text,
    last_name text,
    privilege text
);


ALTER TABLE public.accounts_user OWNER TO postgres;

--
-- Name: accounts_user_demographics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts_user_demographics (
    id double precision,
    user_id double precision,
    sex text,
    age double precision,
    birth_decade double precision,
    zip double precision
);


ALTER TABLE public.accounts_user_demographics OWNER TO postgres;

--
-- Name: experiments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.experiments (
    id integer,
    experiment_id integer,
    experiment_name text,
    experiment_image_url text
);


ALTER TABLE public.experiments OWNER TO postgres;

--
-- Name: experiments_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.experiments_mapping (
    pattern text,
    replacement text
);


ALTER TABLE public.experiments_mapping OWNER TO postgres;

--
-- Name: glucose_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.glucose_records (
    "time" timestamp with time zone,
    scan double precision,
    hist double precision,
    strip double precision,
    value double precision,
    food text,
    user_id double precision
);


ALTER TABLE public.glucose_records OWNER TO postgres;

--
-- Name: notes_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notes_records (
    "Start" timestamp with time zone,
    "End" timestamp with time zone,
    "Activity" text,
    "Comment" text,
    "Z" double precision,
    user_id double precision
);


ALTER TABLE public.notes_records OWNER TO postgres;

--
-- Name: raw_glucose; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.raw_glucose (
    user_id double precision,
    "timestamp" timestamp with time zone,
    record_type double precision,
    glucose_historic double precision,
    glucose_scan double precision,
    strip_glucose double precision,
    notes text,
    device text,
    serial_number text,
    food text,
    carbs double precision
);


ALTER TABLE public.raw_glucose OWNER TO postgres;

--
-- Name: raw_notes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.raw_notes (
    "Start" timestamp with time zone,
    "End" timestamp with time zone,
    "Activity" text,
    "Comment" text,
    "Z" boolean,
    user_id double precision,
    "TZ" integer
);


ALTER TABLE public.raw_notes OWNER TO postgres;

--
-- Name: user_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_list (
    first_name text,
    last_name text,
    birthdate date,
    latest_data text,
    libreview_status text,
    user_id double precision
);


ALTER TABLE public.user_list OWNER TO postgres;

--
-- Name: accounts_firebase_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX accounts_firebase_user_id ON public.accounts_firebase USING btree (user_id);


--
-- Name: accounts_user_demographics_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX accounts_user_demographics_user_id ON public.accounts_user_demographics USING btree (user_id);


--
-- Name: accounts_user_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX accounts_user_user_id ON public.accounts_user USING btree (user_id);


--
-- Name: experiments_experiment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX experiments_experiment_id ON public.experiments USING btree (experiment_id);


--
-- PostgreSQL database dump complete
--

