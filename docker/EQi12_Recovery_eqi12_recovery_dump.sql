--
-- PostgreSQL database dump
--

\restrict Lqo0thU09CDBih5ddQXz1pVGonUYBvz371koJczKH9QhlOb2mjclkCHhZXWMwX3

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: marker; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marker (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Data for Name: marker; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.marker (id, created_at) FROM stdin;
EQI12-RECOVERY-bc292a1b0fd742d3bca133b8ac6d35cc	2026-07-13 16:22:10.302992+00
\.


--
-- Name: marker marker_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marker
    ADD CONSTRAINT marker_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict Lqo0thU09CDBih5ddQXz1pVGonUYBvz371koJczKH9QhlOb2mjclkCHhZXWMwX3

