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
DROP TRIGGER descontar_inventario_teorico_orden_salida ON public.orden_salida_moldura;
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
DROP TABLE public.comparacion;
DROP SEQUENCE public.bandera_id_seq;
DROP TABLE public.bandera;
DROP FUNCTION public.suma_teor_desp();
DROP FUNCTION public.niveles_criticos();
DROP FUNCTION public.insertar_inventario_desperdicio(nueva_cantidad double precision, id bigint);
DROP FUNCTION public.desp_plus_comp_teor_temp();
DROP FUNCTION public.descontar_inventario_teorico_orden_salida();
DROP FUNCTION public.desc_inv_teorico();
DROP FUNCTION public.copia_inv_temp();
DROP FUNCTION public.comp_teor_temp();
DROP FUNCTION public.actualizar_nuevo_material(rate double precision);
DROP FUNCTION public.actualizar_nuevo_material();
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
-- Name: actualizar_nuevo_material(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION actualizar_nuevo_material() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE inventario_teorico
   SET cantidad = inventario_teorico.cantidad+(entrada_almacen.cantidad*64*0.3048)
  FROM entrada_almacen 
 WHERE entrada_almacen.moldura_id = inventario_teorico.moldura_id;

 INSERT INTO inventario_teorico (moldura_id, cantidad)
    SELECT moldura_id,(cantidad *64*0.3048)
    FROM entrada_almacen as a1 
    WHERE NOT EXISTS (
    SELECT 1 FROM entrada_almacen as a , inventario_teorico as t 
    WHERE a1.moldura_id=t.moldura_id);

    UPDATE maestro_moldura
    SET precio_unitario = entrada_almacen.precio_unitario/64*3.2808399
    FROM entrada_almacen
    WHERE entrada_almacen.moldura_id = maestro_moldura.moldura_id;

RETURN TRUE;
    
END; $$;


ALTER FUNCTION public.actualizar_nuevo_material() OWNER TO postgres;

--
-- Name: actualizar_nuevo_material(double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION actualizar_nuevo_material(rate double precision) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE inventario_teorico
   SET cantidad = inventario_teorico.cantidad+((entrada_almacen.cantidad*64*0.3048)*rate)
  FROM entrada_almacen 
 WHERE entrada_almacen.moldura_id = inventario_teorico.moldura_id;

 INSERT INTO inventario_teorico (moldura_id, cantidad)
    SELECT moldura_id,(cantidad *64*0.3048)
    FROM entrada_almacen as a1 
    WHERE NOT EXISTS (
    SELECT 1 FROM entrada_almacen as a , inventario_teorico as t 
    WHERE a1.moldura_id=t.moldura_id);

    UPDATE maestro_moldura
    SET precio_unitario = (entrada_almacen.precio_unitario/64*3.2808399)*rate
    FROM entrada_almacen
    WHERE entrada_almacen.moldura_id = maestro_moldura.moldura_id;

RETURN TRUE;
    
END; $$;


ALTER FUNCTION public.actualizar_nuevo_material(rate double precision) OWNER TO postgres;

--
-- Name: comp_teor_temp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comp_teor_temp() RETURNS TABLE(moldura_id bigint, teo_cant double precision, temp_cant double precision, diferencia double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY 
SELECT
CASE

WHEN inventario_teorico.moldura_id IS NOT NULL
THEN inventario_teorico.moldura_id

WHEN inventario_temporal.moldura_id IS NOT NULL
THEN inventario_temporal.moldura_id

END,

inventario_teorico.cantidad, inventario_temporal.cantidad,

CASE
WHEN inventario_teorico.cantidad IS NOT NULL and inventario_temporal.cantidad IS NOT NULL
THEN inventario_teorico.cantidad - inventario_temporal.cantidad

WHEN inventario_teorico.cantidad IS NOT NULL
THEN inventario_teorico.cantidad

ELSE -inventario_temporal.cantidad
END

FROM inventario_teorico
FULL OUTER JOIN inventario_temporal
ON inventario_teorico.moldura_id = inventario_temporal.moldura_id;

END;
$$;


ALTER FUNCTION public.comp_teor_temp() OWNER TO postgres;

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
-- Name: descontar_inventario_teorico_orden_salida(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION descontar_inventario_teorico_orden_salida() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE
base float8 := NEW.base_marco;
altura float8 := NEW.altura_marco;
total float8 := 2*base + 2*altura;

BEGIN

IF (NEW.estado = 1) THEN
UPDATE inventario_teorico SET cantidad = cantidad-total WHERE moldura_id = NEW.moldura_id;
END IF;

RETURN NEW;

END;

$$;


ALTER FUNCTION public.descontar_inventario_teorico_orden_salida() OWNER TO postgres;

--
-- Name: desp_plus_comp_teor_temp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION desp_plus_comp_teor_temp() RETURNS TABLE(moldura_id bigint, teo_cant double precision, temp_cant double precision, diferencia double precision, desp double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY 
SELECT
CASE

WHEN inventario_desperdicio.moldura_id IS NOT NULL
THEN inventario_desperdicio.moldura_id

ELSE comparacion.moldura_id
END,

comparacion.teo_cant, comparacion.temp_cant, comparacion.diferencia, inventario_desperdicio.cantidad

FROM inventario_desperdicio
FULL OUTER JOIN comparacion
ON inventario_desperdicio.moldura_id = comparacion.moldura_id;

END;
$$;


ALTER FUNCTION public.desp_plus_comp_teor_temp() OWNER TO postgres;

--
-- Name: insertar_inventario_desperdicio(double precision, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_inventario_desperdicio(nueva_cantidad double precision, id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE inventario_desperdicio
   SET cantidad = cantidad + nueva_cantidad
 WHERE moldura_id = id;

 INSERT INTO inventario_desperdicio(moldura_id, cantidad)
    SELECT id, nueva_cantidad
    WHERE NOT EXISTS (
    SELECT 1 FROM inventario_desperdicio 
    WHERE moldura_id = id);
RETURN TRUE;
    
END; $$;


ALTER FUNCTION public.insertar_inventario_desperdicio(nueva_cantidad double precision, id bigint) OWNER TO postgres;

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
-- Name: suma_teor_desp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION suma_teor_desp() RETURNS TABLE(moldura_id bigint, suma double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY 
SELECT
CASE

WHEN inventario_teorico.moldura_id IS NOT NULL
THEN inventario_teorico.moldura_id

ELSE inventario_desperdicio.moldura_id
END,

CASE 
WHEN inventario_teorico.cantidad IS NOT NULL and inventario_desperdicio.cantidad IS NOT NULL
THEN inventario_teorico.cantidad + inventario_desperdicio.cantidad

WHEN inventario_teorico.cantidad IS NOT NULL 
THEN inventario_teorico.cantidad

ELSE inventario_desperdicio.cantidad
END

FROM inventario_teorico
FULL OUTER JOIN inventario_desperdicio
ON inventario_teorico.moldura_id = inventario_desperdicio.moldura_id;

END;
$$;


ALTER FUNCTION public.suma_teor_desp() OWNER TO postgres;

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
-- Name: comparacion; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE comparacion (
    moldura_id bigint,
    teo_cant double precision,
    temp_cant double precision,
    diferencia double precision
);


ALTER TABLE public.comparacion OWNER TO postgres;

--
-- Name: conversiones; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE conversiones (
    ultima_actualizacion timestamp without time zone,
    dolares_a_pesos double precision,
    pesos_a_dolares double precision
);


ALTER TABLE public.conversiones OWNER TO postgres;

--
-- Name: entrada_almacen; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE entrada_almacen (
    entrada_material_id bigint NOT NULL,
    moldura_id bigint NOT NULL,
    cantidad double precision NOT NULL,
    precio_unitario double precision NOT NULL,
    CONSTRAINT entrada_almacen_cantidad_check CHECK ((cantidad >= (0)::double precision)),
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
    moldura_id bigint NOT NULL,
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
    moldura_id bigint NOT NULL,
    cantidad double precision,
    CONSTRAINT inventario_real_cantidad_check CHECK ((cantidad >= (0.0)::double precision))
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
    moldura_id bigint NOT NULL,
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
    moldura_id bigint NOT NULL,
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
    CONSTRAINT maestro_moldura_ancho_moldura_check CHECK ((ancho_moldura > (0.0)::double precision)),
    CONSTRAINT maestro_moldura_clave_interna_check CHECK (((clave_interna)::text <> ''::text)),
    CONSTRAINT maestro_moldura_clave_proveedor_check CHECK (((clave_proveedor)::text <> ''::text)),
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
    tienda_id bigint NOT NULL,
    base_marco double precision NOT NULL,
    altura_marco double precision NOT NULL,
    fecha_recepcion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_procesado timestamp without time zone,
    moldura_id bigint NOT NULL,
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
1	f
\.


--
-- Name: bandera_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('bandera_id_seq', 1, true);


--
-- Data for Name: comparacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY comparacion (moldura_id, teo_cant, temp_cant, diferencia) FROM stdin;
1	\N	2	-2
\.


--
-- Data for Name: conversiones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY conversiones (ultima_actualizacion, dolares_a_pesos, pesos_a_dolares) FROM stdin;
2013-11-26 12:33:18.960495	13.0443999999999996	0.0767000000000000043
\.


--
-- Data for Name: entrada_almacen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY entrada_almacen (entrada_material_id, moldura_id, cantidad, precio_unitario) FROM stdin;
\.


--
-- Name: entrada_almacen_entrada_material_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('entrada_almacen_entrada_material_id_seq', 25, true);


--
-- Data for Name: inventario_desperdicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY inventario_desperdicio (entrada_inventario_desp_id, moldura_id, cantidad) FROM stdin;
17	1	256
18	1	500
19	1	9
20	1	500
21	1	9
22	1	254
23	1	255
24	1	250
25	1	4
26	1	255
27	1	254
28	1	255
29	1	254
30	1	345
\.


--
-- Name: inventario_desperdicio_entrada_inventario_desp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('inventario_desperdicio_entrada_inventario_desp_id_seq', 30, true);


--
-- Data for Name: inventario_real; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY inventario_real (entrada_inventario_reaal_id, moldura_id, cantidad) FROM stdin;
104	1	2
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

SELECT pg_catalog.setval('inventario_temporal_entrada_inventario_temporal_id_seq', 104, true);


--
-- Data for Name: inventario_teorico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY inventario_teorico (entrada_inventario_teorico_id, moldura_id, cantidad) FROM stdin;
9	2	508.919439360000013
104	1	150.436075520000145
\.


--
-- Name: inventario_teorico_entrada_inventario_teorico_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('inventario_teorico_entrada_inventario_teorico_id_seq', 9, true);


--
-- Data for Name: maestro_moldura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY maestro_moldura (moldura_id, clave_interna, clave_proveedor, precio_unitario, activo, punto_reorden, ancho_moldura, nombre_moldura, descripcion) FROM stdin;
5	E	e	8	t	10	1	\N	\N
7	G	g	10	t	10	10	\N	\N
8	H	h	4	t	10	20	\N	\N
9	I	i	5.5	t	5	15	\N	\N
10	J	j	0.0512631234375000022	t	10	12	\N	\N
1	A	a	10.030450310521875	f	3	3	\N	\N
2	B	b	36.7783178052468784	f	10	5	\N	\N
3	C	c	6	f	10	4	\N	\N
4	D	d	7	f	10	2	\N	\N
6	F	f	9	t	10	0.5	Hola	Jiji
\.


--
-- Name: maestro_moldura_moldura_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('maestro_moldura_moldura_id_seq', 11, true);


--
-- Data for Name: orden_salida_moldura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY orden_salida_moldura (orden_id, folio, tienda_id, base_marco, altura_marco, fecha_recepcion, fecha_procesado, moldura_id, estado) FROM stdin;
\.


--
-- Name: orden_salida_moldura_orden_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('orden_salida_moldura_orden_id_seq', 9, true);


--
-- Data for Name: tienda; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tienda (tienda_id, telefono, direccion) FROM stdin;
1	3262435	Atenas
\.


--
-- Name: tienda_tienda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tienda_tienda_id_seq', 1, true);


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
-- Name: descontar_inventario_teorico_orden_salida; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER descontar_inventario_teorico_orden_salida AFTER UPDATE ON orden_salida_moldura FOR EACH ROW EXECUTE PROCEDURE descontar_inventario_teorico_orden_salida();


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

