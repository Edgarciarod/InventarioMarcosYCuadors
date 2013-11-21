--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.orden_salida_moldura DROP CONSTRAINT orden_salida_moldura_tienda_id_fkey;
ALTER TABLE ONLY public.orden_salida_moldura DROP CONSTRAINT orden_salida_moldura_moldura_id_fkey;
ALTER TABLE ONLY public.inventario_teorico DROP CONSTRAINT inventario_teorico_moldura_id_fkey;
ALTER TABLE ONLY public.inventario_temporal DROP CONSTRAINT inventario_temporal_moldura_id_fkey;
ALTER TABLE ONLY public.inventario_real DROP CONSTRAINT inventario_real_moldura_id_fkey;
ALTER TABLE ONLY public.inventario_desperdicio DROP CONSTRAINT inventario_desperdicio_moldura_id_fkey;
ALTER TABLE ONLY public.entrada_almacen DROP CONSTRAINT entrada_almacen_moldura_id_fkey;
DROP TRIGGER trigg_niveles_criticos ON public.inventario_teorico;
DROP TRIGGER trigg_desc_inv_temp ON public.inventario_desperdicio;
ALTER TABLE ONLY public.tienda DROP CONSTRAINT tienda_pkey;
ALTER TABLE ONLY public.orden_salida_moldura DROP CONSTRAINT orden_salida_moldura_pkey;
ALTER TABLE ONLY public.orden_salida_moldura DROP CONSTRAINT orden_salida_moldura_folio_key;
ALTER TABLE ONLY public.maestro_moldura DROP CONSTRAINT maestro_moldura_pkey;
ALTER TABLE ONLY public.maestro_moldura DROP CONSTRAINT maestro_moldura_clave_proveedor_key;
ALTER TABLE ONLY public.maestro_moldura DROP CONSTRAINT maestro_moldura_clave_interna_key;
ALTER TABLE ONLY public.inventario_teorico DROP CONSTRAINT inventario_teorico_pkey;
ALTER TABLE ONLY public.inventario_teorico DROP CONSTRAINT inventario_teorico_moldura_id_key;
ALTER TABLE ONLY public.inventario_temporal DROP CONSTRAINT inventario_temporal_pkey;
ALTER TABLE ONLY public.inventario_temporal DROP CONSTRAINT inventario_temporal_moldura_id_key;
ALTER TABLE ONLY public.inventario_real DROP CONSTRAINT inventario_real_moldura_id_key;
ALTER TABLE ONLY public.inventario_desperdicio DROP CONSTRAINT inventario_desperdicio_pkey;
ALTER TABLE ONLY public.inventario_desperdicio DROP CONSTRAINT inventario_desperdicio_moldura_id_key;
ALTER TABLE ONLY public.entrada_almacen DROP CONSTRAINT entrada_almacen_pkey;
ALTER TABLE ONLY public.entrada_almacen DROP CONSTRAINT entrada_almacen_moldura_id_key;
ALTER TABLE public.tienda ALTER COLUMN tienda_id DROP DEFAULT;
ALTER TABLE public.orden_salida_moldura ALTER COLUMN orden_id DROP DEFAULT;
ALTER TABLE public.maestro_moldura ALTER COLUMN moldura_id DROP DEFAULT;
ALTER TABLE public.inventario_teorico ALTER COLUMN entrada_inventario_teorico_id DROP DEFAULT;
ALTER TABLE public.inventario_temporal ALTER COLUMN entrada_inventario_temporal_id DROP DEFAULT;
ALTER TABLE public.inventario_real ALTER COLUMN entrada_inventario_reaal_id DROP DEFAULT;
ALTER TABLE public.inventario_desperdicio ALTER COLUMN entrada_inventario_desp_id DROP DEFAULT;
ALTER TABLE public.entrada_almacen ALTER COLUMN entrada_material_id DROP DEFAULT;
ALTER TABLE public.bandera ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.tienda_tienda_id_seq;
DROP TABLE public.tienda;
DROP SEQUENCE public.orden_salida_moldura_orden_id_seq;
DROP TABLE public.orden_salida_moldura;
DROP SEQUENCE public.maestro_moldura_moldura_id_seq;
DROP TABLE public.maestro_moldura;
DROP SEQUENCE public.inventario_teorico_entrada_inventario_teorico_id_seq;
DROP TABLE public.inventario_teorico;
DROP SEQUENCE public.inventario_temporal_entrada_inventario_temporal_id_seq;
DROP TABLE public.inventario_temporal;
DROP SEQUENCE public.inventario_real_entrada_inventario_reaal_id_seq;
DROP TABLE public.inventario_real;
DROP SEQUENCE public.inventario_desperdicio_entrada_inventario_desp_id_seq;
DROP TABLE public.inventario_desperdicio;
DROP SEQUENCE public.entrada_almacen_entrada_material_id_seq;
DROP TABLE public.entrada_almacen;
DROP TABLE public.conversiones;
DROP SEQUENCE public.bandera_id_seq;
DROP TABLE public.bandera;
DROP FUNCTION public.suma_temp_desp();
DROP FUNCTION public.suma_copia();
DROP FUNCTION public.niveles_criticos(i bigint);
DROP FUNCTION public.niveles_criticos();
DROP FUNCTION public.emp_stamp();
DROP FUNCTION public.desc_inv_teorico();
DROP FUNCTION public.desc_inv_temp();
DROP FUNCTION public.copia_inv_temp();
DROP FUNCTION public.comparar_cambiar();
DROP FUNCTION public.actualizar_nuevo_material(val integer);
DROP FUNCTION public.actualizar_inventario_teorico();
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: actualizar_inventario_teorico(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION actualizar_inventario_teorico() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
b float8=(SELECT cantidad FROM inventario_teorico WHERE moldura_id=NEW.moldura_id);
c float8;
BEGIN 

       NEW.base_marco := 2*(NEW.base_marco);
       NEW.altura_marco :=2*(NEW.altura_marco);
       c:= (NEW.base_marco)+(NEW.altura_marco);
  IF (c-b<0) THEN
         RETURN NULL;
  END IF;
  
  IF (NEW.estado=1) THEN  
     UPDATE inventario_teorico SET cantidad =c-b WHERE moldura_id=NEW.moldura_id;
       RETURN NEW;
  END IF;
   
   END;
  
$$;


ALTER FUNCTION public.actualizar_inventario_teorico() OWNER TO postgres;

--
-- Name: actualizar_nuevo_material(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION actualizar_nuevo_material(val integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN val + 1;
END; $$;


ALTER FUNCTION public.actualizar_nuevo_material(val integer) OWNER TO postgres;

--
-- Name: comparar_cambiar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comparar_cambiar() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
       DECLARE
       pop float8;
       BEGIN
       pop=(SELECT precio_unitario FROM maestro_moldura WHERE moldura_id = NEW.moldura_id);
      
       IF (NEW.precio_unitario != pop)     
        THEN UPDATE maestro_moldura set precio_unitario=NEW.precio_unitario WHERE moldura_id=NEW.moldura_id;
       END IF;
       RETURN NULL;
      END;
     $$;


ALTER FUNCTION public.comparar_cambiar() OWNER TO postgres;

--
-- Name: copia_inv_temp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION copia_inv_temp() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO inventario_real SELECT * FROM inventario_temporal;
INSERT INTO inventario_teorico SELECT * FROM inventario_temporal;

RETURN TRUE;

END;
$$;


ALTER FUNCTION public.copia_inv_temp() OWNER TO postgres;

--
-- Name: desc_inv_temp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION desc_inv_temp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE
merma float8 = NEW.cantidad;
actual float8 = (SELECT cantidad FROM inventario_teorico WHERE moldura_id = NEW.moldura_id);

BEGIN
IF (actual - merma >= 0) THEN
UPDATE inventario_teorico SET cantidad = actual - merma WHERE moldura_id = NEW.moldura_id;
ELSE
UPDATE inventario_teorico SET cantidad = 0 WHERE moldura_id = NEW.moldura_id;
END IF;

RETURN NEW;
END;
$$;


ALTER FUNCTION public.desc_inv_temp() OWNER TO postgres;

--
-- Name: desc_inv_teorico(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION desc_inv_teorico() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE
merma float8 = NEW.cantidad;
actual float8 = (SELECT cantidad FROM inventario_teorico WHERE moldura_id = NEW.moldura_id);

BEGIN
IF (actual - merma >= 0) THEN
UPDATE inventario_teorico SET cantidad = actual - merma WHERE moldura_id = NEW.moldura_id;
ELSE
UPDATE inventario_teorico SET cantidad = 0 WHERE moldura_id = NEW.moldura_id;
END IF;

RETURN NEW;
END;
$$;


ALTER FUNCTION public.desc_inv_teorico() OWNER TO postgres;

--
-- Name: emp_stamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION emp_stamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- Check that empname and salary are given
        IF NEW.empname IS NULL THEN
            RAISE EXCEPTION 'empname cannot be null';
        END IF;
        IF NEW.salary IS NULL THEN
            RAISE EXCEPTION '% cannot have null salary', NEW.empname;
        END IF;

        -- Who works for us when she must pay for it?
        IF NEW.salary < 0 THEN
            RAISE EXCEPTION '% cannot have a negative salary', NEW.empname;
        END IF;

        -- Remember who changed the payroll when
        NEW.last_date := current_timestamp;
        NEW.last_user := current_user;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.emp_stamp() OWNER TO postgres;

--
-- Name: niveles_criticos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION niveles_criticos() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE 
curs CURSOR FOR SELECT moldura_id, cantidad FROM inventario_teorico;
nivel float8;
existe boolean = FALSE;

BEGIN

FOR moldura IN curs LOOP
nivel := (SELECT punto_reorden FROM maestro_moldura WHERE moldura_id = moldura.moldura_id);
IF (moldura.cantidad <= nivel) THEN
existe := TRUE;
END IF;
END LOOP;

UPDATE bandera SET existe_critico = existe;

RETURN NEW;

END;
$$;


ALTER FUNCTION public.niveles_criticos() OWNER TO postgres;

--
-- Name: niveles_criticos(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION niveles_criticos(i bigint) RETURNS double precision
    LANGUAGE plpgsql
    AS $$

DECLARE 
nivel float8 = (SELECT punto_reorden FROM maestro_moldura WHERE moldura_id = i);

BEGIN
RETURN nivel;
END;
$$;


ALTER FUNCTION public.niveles_criticos(i bigint) OWNER TO postgres;

--
-- Name: suma_copia(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION suma_copia() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
SELECT * FROM suma_temp_desp();
TRUNCATE TABLE inventario_real;
TRUNCATE TABLE inventario_teorico;
EXECUTE copia_inv_temp();
TRUNCATE TABLE inventario_temporal; 
END;
$$;


ALTER FUNCTION public.suma_copia() OWNER TO postgres;

--
-- Name: suma_temp_desp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION suma_temp_desp() RETURNS TABLE(moldura_id bigint, dif double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY 
SELECT
CASE

WHEN inventario_temporal.moldura_id IS NOT NULL
THEN inventario_temporal.moldura_id

ELSE inventario_desperdicio.moldura_id
END,

CASE 
WHEN inventario_temporal.cantidad IS NOT NULL and inventario_desperdicio.cantidad IS NOT NULL
THEN inventario_temporal.cantidad + inventario_desperdicio.cantidad

WHEN inventario_temporal.cantidad IS NOT NULL 
THEN inventario_temporal.cantidad

ELSE inventario_desperdicio.cantidad
END

FROM inventario_temporal
FULL OUTER JOIN inventario_desperdicio
ON inventario_temporal.moldura_id = inventario_desperdicio.moldura_id;

END;
$$;


ALTER FUNCTION public.suma_temp_desp() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bandera; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE bandera (
    id integer NOT NULL,
    existe_critico boolean DEFAULT false
);


ALTER TABLE public.bandera OWNER TO postgres;

--
-- Name: bandera_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE bandera_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bandera_id_seq OWNER TO postgres;

--
-- Name: bandera_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE bandera_id_seq OWNED BY bandera.id;


--
-- Name: conversiones; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE conversiones (
    ultima_actualizacion timestamp without time zone,
    dolares_a_pesos double precision,
    pesos_dolares double precision
);


ALTER TABLE public.conversiones OWNER TO postgres;

--
-- Name: entrada_almacen; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE entrada_almacen (
    entrada_material_id bigint NOT NULL,
    moldura_id bigint,
    cantidad double precision NOT NULL,
    precio_unitario double precision NOT NULL,
    CONSTRAINT entrada_almacen_cantidad_check CHECK ((cantidad > (0)::double precision)),
    CONSTRAINT entrada_almacen_precio_unitario_check CHECK ((precio_unitario > (0)::double precision))
);


ALTER TABLE public.entrada_almacen OWNER TO postgres;

--
-- Name: entrada_almacen_entrada_material_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE entrada_almacen_entrada_material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entrada_almacen_entrada_material_id_seq OWNER TO postgres;

--
-- Name: entrada_almacen_entrada_material_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE entrada_almacen_entrada_material_id_seq OWNED BY entrada_almacen.entrada_material_id;


--
-- Name: inventario_desperdicio; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventario_desperdicio (
    entrada_inventario_desp_id bigint NOT NULL,
    moldura_id bigint,
    cantidad double precision NOT NULL,
    CONSTRAINT inventario_desperdicio_cantidad_check CHECK ((cantidad >= (0)::double precision))
);


ALTER TABLE public.inventario_desperdicio OWNER TO postgres;

--
-- Name: inventario_desperdicio_entrada_inventario_desp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventario_desperdicio_entrada_inventario_desp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventario_desperdicio_entrada_inventario_desp_id_seq OWNER TO postgres;

--
-- Name: inventario_desperdicio_entrada_inventario_desp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventario_desperdicio_entrada_inventario_desp_id_seq OWNED BY inventario_desperdicio.entrada_inventario_desp_id;


--
-- Name: inventario_real; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventario_real (
    entrada_inventario_reaal_id bigint NOT NULL,
    moldura_id bigint,
    cantidad double precision,
    CONSTRAINT inventario_real_cantidad_check CHECK ((cantidad > (0)::double precision))
);


ALTER TABLE public.inventario_real OWNER TO postgres;

--
-- Name: inventario_real_entrada_inventario_reaal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventario_real_entrada_inventario_reaal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventario_real_entrada_inventario_reaal_id_seq OWNER TO postgres;

--
-- Name: inventario_real_entrada_inventario_reaal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventario_real_entrada_inventario_reaal_id_seq OWNED BY inventario_real.entrada_inventario_reaal_id;


--
-- Name: inventario_temporal; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventario_temporal (
    entrada_inventario_temporal_id bigint NOT NULL,
    moldura_id bigint,
    cantidad double precision NOT NULL,
    CONSTRAINT inventario_temporal_cantidad_check CHECK ((cantidad >= (0.0)::double precision))
);


ALTER TABLE public.inventario_temporal OWNER TO postgres;

--
-- Name: inventario_temporal_entrada_inventario_temporal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventario_temporal_entrada_inventario_temporal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventario_temporal_entrada_inventario_temporal_id_seq OWNER TO postgres;

--
-- Name: inventario_temporal_entrada_inventario_temporal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventario_temporal_entrada_inventario_temporal_id_seq OWNED BY inventario_temporal.entrada_inventario_temporal_id;


--
-- Name: inventario_teorico; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventario_teorico (
    entrada_inventario_teorico_id bigint NOT NULL,
    moldura_id bigint,
    cantidad double precision NOT NULL,
    CONSTRAINT inventario_teorico_cantidad_check CHECK ((cantidad >= (0.0)::double precision))
);


ALTER TABLE public.inventario_teorico OWNER TO postgres;

--
-- Name: inventario_teorico_entrada_inventario_teorico_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventario_teorico_entrada_inventario_teorico_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventario_teorico_entrada_inventario_teorico_id_seq OWNER TO postgres;

--
-- Name: inventario_teorico_entrada_inventario_teorico_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventario_teorico_entrada_inventario_teorico_id_seq OWNED BY inventario_teorico.entrada_inventario_teorico_id;


--
-- Name: maestro_moldura; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE maestro_moldura (
    moldura_id bigint NOT NULL,
    clave_interna character varying(10) NOT NULL,
    clave_proveedor character varying(10) NOT NULL,
    precio_unitario double precision NOT NULL,
    activo boolean DEFAULT true,
    punto_reorden double precision NOT NULL,
    ancho_moldura double precision NOT NULL,
    nombre_moldura character varying(20),
    descripcion text,
    factor_desperdicio double precision NOT NULL,
    CONSTRAINT maestro_moldura_ancho_moldura_check CHECK ((ancho_moldura > (0.0)::double precision)),
    CONSTRAINT maestro_moldura_factor_desperdicio_check CHECK ((factor_desperdicio > (0.0)::double precision)),
    CONSTRAINT maestro_moldura_precio_unitario_check CHECK ((precio_unitario > (0.0)::double precision)),
    CONSTRAINT maestro_moldura_punto_reorden_check CHECK ((punto_reorden > (0.0)::double precision))
);


ALTER TABLE public.maestro_moldura OWNER TO postgres;

--
-- Name: maestro_moldura_moldura_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE maestro_moldura_moldura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.maestro_moldura_moldura_id_seq OWNER TO postgres;

--
-- Name: maestro_moldura_moldura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE maestro_moldura_moldura_id_seq OWNED BY maestro_moldura.moldura_id;


--
-- Name: orden_salida_moldura; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE orden_salida_moldura (
    orden_id bigint NOT NULL,
    folio bigint NOT NULL,
    tienda_id bigint,
    base_marco double precision NOT NULL,
    altura_marco double precision NOT NULL,
    fecha_recepcion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_procesado timestamp without time zone,
    moldura_id bigint,
    estado smallint DEFAULT 0 NOT NULL,
    CONSTRAINT orden_salida_moldura_altura_marco_check CHECK ((altura_marco > (0.0)::double precision)),
    CONSTRAINT orden_salida_moldura_base_marco_check CHECK ((base_marco > (0.0)::double precision))
);


ALTER TABLE public.orden_salida_moldura OWNER TO postgres;

--
-- Name: orden_salida_moldura_orden_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE orden_salida_moldura_orden_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orden_salida_moldura_orden_id_seq OWNER TO postgres;

--
-- Name: orden_salida_moldura_orden_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE orden_salida_moldura_orden_id_seq OWNED BY orden_salida_moldura.orden_id;


--
-- Name: tienda; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tienda (
    tienda_id bigint NOT NULL,
    telefono character varying(20),
    direccion character varying(50)
);


ALTER TABLE public.tienda OWNER TO postgres;

--
-- Name: tienda_tienda_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tienda_tienda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tienda_tienda_id_seq OWNER TO postgres;

--
-- Name: tienda_tienda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tienda_tienda_id_seq OWNED BY tienda.tienda_id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bandera ALTER COLUMN id SET DEFAULT nextval('bandera_id_seq'::regclass);


--
-- Name: entrada_material_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entrada_almacen ALTER COLUMN entrada_material_id SET DEFAULT nextval('entrada_almacen_entrada_material_id_seq'::regclass);


--
-- Name: entrada_inventario_desp_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventario_desperdicio ALTER COLUMN entrada_inventario_desp_id SET DEFAULT nextval('inventario_desperdicio_entrada_inventario_desp_id_seq'::regclass);


--
-- Name: entrada_inventario_reaal_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventario_real ALTER COLUMN entrada_inventario_reaal_id SET DEFAULT nextval('inventario_real_entrada_inventario_reaal_id_seq'::regclass);


--
-- Name: entrada_inventario_temporal_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventario_temporal ALTER COLUMN entrada_inventario_temporal_id SET DEFAULT nextval('inventario_temporal_entrada_inventario_temporal_id_seq'::regclass);


--
-- Name: entrada_inventario_teorico_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventario_teorico ALTER COLUMN entrada_inventario_teorico_id SET DEFAULT nextval('inventario_teorico_entrada_inventario_teorico_id_seq'::regclass);


--
-- Name: moldura_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY maestro_moldura ALTER COLUMN moldura_id SET DEFAULT nextval('maestro_moldura_moldura_id_seq'::regclass);


--
-- Name: orden_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orden_salida_moldura ALTER COLUMN orden_id SET DEFAULT nextval('orden_salida_moldura_orden_id_seq'::regclass);


--
-- Name: tienda_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tienda ALTER COLUMN tienda_id SET DEFAULT nextval('tienda_tienda_id_seq'::regclass);


--
-- Data for Name: bandera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY bandera (id, existe_critico) FROM stdin;
1	t
\.


--
-- Name: bandera_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('bandera_id_seq', 1, true);


--
-- Data for Name: conversiones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY conversiones (ultima_actualizacion, dolares_a_pesos, pesos_dolares) FROM stdin;
\.


--
-- Data for Name: entrada_almacen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY entrada_almacen (entrada_material_id, moldura_id, cantidad, precio_unitario) FROM stdin;
\.


--
-- Name: entrada_almacen_entrada_material_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('entrada_almacen_entrada_material_id_seq', 1, false);


--
-- Data for Name: inventario_desperdicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY inventario_desperdicio (entrada_inventario_desp_id, moldura_id, cantidad) FROM stdin;
\.


--
-- Name: inventario_desperdicio_entrada_inventario_desp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('inventario_desperdicio_entrada_inventario_desp_id_seq', 1, false);


--
-- Data for Name: inventario_real; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY inventario_real (entrada_inventario_reaal_id, moldura_id, cantidad) FROM stdin;
\.


--
-- Name: inventario_real_entrada_inventario_reaal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('inventario_real_entrada_inventario_reaal_id_seq', 1, false);


--
-- Data for Name: inventario_temporal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY inventario_temporal (entrada_inventario_temporal_id, moldura_id, cantidad) FROM stdin;
\.


--
-- Name: inventario_temporal_entrada_inventario_temporal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('inventario_temporal_entrada_inventario_temporal_id_seq', 1, false);


--
-- Data for Name: inventario_teorico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY inventario_teorico (entrada_inventario_teorico_id, moldura_id, cantidad) FROM stdin;
\.


--
-- Name: inventario_teorico_entrada_inventario_teorico_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('inventario_teorico_entrada_inventario_teorico_id_seq', 1, false);


--
-- Data for Name: maestro_moldura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY maestro_moldura (moldura_id, clave_interna, clave_proveedor, precio_unitario, activo, punto_reorden, ancho_moldura, nombre_moldura, descripcion, factor_desperdicio) FROM stdin;
2	B	b	5	t	10	5	\N	\N	0.5
3	C	c	6	t	10	4	\N	\N	0.5
4	D	d	7	f	10	2	\N	\N	0.25
5	E	e	8	t	10	1	\N	\N	0.25
6	F	f	9	t	10	0.5	\N	\N	0.5
9	I	i	5.5	t	5	15	\N	\N	0.5
10	J	j	0.25	f	10	12	\N	\N	0.5
1	A	a	8.90000000000000036	t	3	3	\N	\N	0.5
7	G	g	4.66999999999999993	t	10	10	\N	\N	1
8	H	h	36	t	10	20	\N	\N	0.5
\.


--
-- Name: maestro_moldura_moldura_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('maestro_moldura_moldura_id_seq', 10, true);


--
-- Data for Name: orden_salida_moldura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY orden_salida_moldura (orden_id, folio, tienda_id, base_marco, altura_marco, fecha_recepcion, fecha_procesado, moldura_id, estado) FROM stdin;
\.


--
-- Name: orden_salida_moldura_orden_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('orden_salida_moldura_orden_id_seq', 1, false);


--
-- Data for Name: tienda; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tienda (tienda_id, telefono, direccion) FROM stdin;
3	55241656	colroma
\.


--
-- Name: tienda_tienda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tienda_tienda_id_seq', 1, false);


--
-- Name: entrada_almacen_moldura_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entrada_almacen
    ADD CONSTRAINT entrada_almacen_moldura_id_key UNIQUE (moldura_id);


--
-- Name: entrada_almacen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entrada_almacen
    ADD CONSTRAINT entrada_almacen_pkey PRIMARY KEY (entrada_material_id);


--
-- Name: inventario_desperdicio_moldura_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventario_desperdicio
    ADD CONSTRAINT inventario_desperdicio_moldura_id_key UNIQUE (moldura_id);


--
-- Name: inventario_desperdicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventario_desperdicio
    ADD CONSTRAINT inventario_desperdicio_pkey PRIMARY KEY (entrada_inventario_desp_id);


--
-- Name: inventario_real_moldura_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventario_real
    ADD CONSTRAINT inventario_real_moldura_id_key UNIQUE (moldura_id);


--
-- Name: inventario_temporal_moldura_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventario_temporal
    ADD CONSTRAINT inventario_temporal_moldura_id_key UNIQUE (moldura_id);


--
-- Name: inventario_temporal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventario_temporal
    ADD CONSTRAINT inventario_temporal_pkey PRIMARY KEY (entrada_inventario_temporal_id);


--
-- Name: inventario_teorico_moldura_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventario_teorico
    ADD CONSTRAINT inventario_teorico_moldura_id_key UNIQUE (moldura_id);


--
-- Name: inventario_teorico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventario_teorico
    ADD CONSTRAINT inventario_teorico_pkey PRIMARY KEY (entrada_inventario_teorico_id);


--
-- Name: maestro_moldura_clave_interna_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY maestro_moldura
    ADD CONSTRAINT maestro_moldura_clave_interna_key UNIQUE (clave_interna);


--
-- Name: maestro_moldura_clave_proveedor_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY maestro_moldura
    ADD CONSTRAINT maestro_moldura_clave_proveedor_key UNIQUE (clave_proveedor);


--
-- Name: maestro_moldura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY maestro_moldura
    ADD CONSTRAINT maestro_moldura_pkey PRIMARY KEY (moldura_id);


--
-- Name: orden_salida_moldura_folio_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orden_salida_moldura
    ADD CONSTRAINT orden_salida_moldura_folio_key UNIQUE (folio);


--
-- Name: orden_salida_moldura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orden_salida_moldura
    ADD CONSTRAINT orden_salida_moldura_pkey PRIMARY KEY (orden_id);


--
-- Name: tienda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tienda
    ADD CONSTRAINT tienda_pkey PRIMARY KEY (tienda_id);


--
-- Name: trigg_desc_inv_temp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigg_desc_inv_temp AFTER INSERT OR UPDATE ON inventario_desperdicio FOR EACH ROW EXECUTE PROCEDURE desc_inv_teorico();


--
-- Name: trigg_niveles_criticos; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigg_niveles_criticos AFTER INSERT OR UPDATE ON inventario_teorico FOR EACH STATEMENT EXECUTE PROCEDURE niveles_criticos();


--
-- Name: entrada_almacen_moldura_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entrada_almacen
    ADD CONSTRAINT entrada_almacen_moldura_id_fkey FOREIGN KEY (moldura_id) REFERENCES maestro_moldura(moldura_id);


--
-- Name: inventario_desperdicio_moldura_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventario_desperdicio
    ADD CONSTRAINT inventario_desperdicio_moldura_id_fkey FOREIGN KEY (moldura_id) REFERENCES maestro_moldura(moldura_id);


--
-- Name: inventario_real_moldura_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventario_real
    ADD CONSTRAINT inventario_real_moldura_id_fkey FOREIGN KEY (moldura_id) REFERENCES maestro_moldura(moldura_id);


--
-- Name: inventario_temporal_moldura_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventario_temporal
    ADD CONSTRAINT inventario_temporal_moldura_id_fkey FOREIGN KEY (moldura_id) REFERENCES maestro_moldura(moldura_id);


--
-- Name: inventario_teorico_moldura_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventario_teorico
    ADD CONSTRAINT inventario_teorico_moldura_id_fkey FOREIGN KEY (moldura_id) REFERENCES maestro_moldura(moldura_id);


--
-- Name: orden_salida_moldura_moldura_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orden_salida_moldura
    ADD CONSTRAINT orden_salida_moldura_moldura_id_fkey FOREIGN KEY (moldura_id) REFERENCES maestro_moldura(moldura_id);


--
-- Name: orden_salida_moldura_tienda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orden_salida_moldura
    ADD CONSTRAINT orden_salida_moldura_tienda_id_fkey FOREIGN KEY (tienda_id) REFERENCES tienda(tienda_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

