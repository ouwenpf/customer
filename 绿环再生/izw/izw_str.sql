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

--
-- Name: bills; Type: SCHEMA; Schema: -; Owner: tom
--

CREATE SCHEMA bills;


ALTER SCHEMA bills OWNER TO tom;

--
-- Name: cate; Type: SCHEMA; Schema: -; Owner: tom
--

CREATE SCHEMA cate;


ALTER SCHEMA cate OWNER TO tom;

--
-- Name: gis; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA gis;


ALTER SCHEMA gis OWNER TO postgres;

--
-- Name: stations; Type: SCHEMA; Schema: -; Owner: tom
--

CREATE SCHEMA stations;


ALTER SCHEMA stations OWNER TO tom;

--
-- Name: vi; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA vi;


ALTER SCHEMA vi OWNER TO postgres;

--
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: reg_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.reg_status AS ENUM (
    'waiting',
    'pass',
    'reject',
    'expired'
);


ALTER TYPE public.reg_status OWNER TO postgres;

--
-- Name: tans_bill_state; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tans_bill_state AS ENUM (
    'waiting',
    'pass',
    'reject',
    'print'
);


ALTER TYPE public.tans_bill_state OWNER TO postgres;

--
-- Name: update_timestamp(); Type: FUNCTION; Schema: bills; Owner: postgres
--

CREATE FUNCTION bills.update_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
NEW.updated_time = current_timestamp;
RETURN NEW;
END;
$$;


ALTER FUNCTION bills.update_timestamp() OWNER TO postgres;

--
-- Name: update_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
NEW.updated_time = current_timestamp;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_timestamp() OWNER TO postgres;

SET default_tablespace = '';


--
-- Name: transfer; Type: TABLE; Schema: bills; Owner: postgres
--

CREATE TABLE bills.transfer (
    id character varying(20) NOT NULL,
    wpu uuid NOT NULL,
    begin_time timestamp(6) without time zone NOT NULL,
    end_time timestamp(6) without time zone NOT NULL,
    contents json,
    created_by character varying(50),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_time timestamp(6) without time zone,
    last_print_time timestamp(6) without time zone,
    state public.tans_bill_state DEFAULT 'waiting'::public.tans_bill_state,
    tu uuid,
    wdu uuid
);


ALTER TABLE bills.transfer OWNER TO postgres;

--
-- Name: COLUMN transfer.id; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.id IS '转移联单单号 格式： AAAAYYWWNNNNNN';


--
-- Name: COLUMN transfer.wpu; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.wpu IS '产废方';


--
-- Name: COLUMN transfer.begin_time; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.begin_time IS '开始时间';


--
-- Name: COLUMN transfer.end_time; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.end_time IS '结束时间';


--
-- Name: COLUMN transfer.contents; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.contents IS '单据详情';


--
-- Name: COLUMN transfer.created_by; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.created_by IS '创建人';


--
-- Name: COLUMN transfer.created_time; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.created_time IS '创建时间';


--
-- Name: COLUMN transfer.updated_by; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.updated_by IS '审核人';


--
-- Name: COLUMN transfer.updated_time; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.updated_time IS '审核时间';


--
-- Name: COLUMN transfer.last_print_time; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.last_print_time IS '最后打印时间';


--
-- Name: COLUMN transfer.state; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.state IS '状态 [ waiting 待审核 | passed 审核通过 | rejected 审核拒绝 | printed 已打印 ]';


--
-- Name: COLUMN transfer.tu; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.tu IS '运输单位';


--
-- Name: COLUMN transfer.wdu; Type: COMMENT; Schema: bills; Owner: postgres
--

COMMENT ON COLUMN bills.transfer.wdu IS '接收方/处置方';


--
-- Name: futures_audit_log; Type: TABLE; Schema: cate; Owner: tom
--

CREATE TABLE cate.futures_audit_log (
    metal_code character varying(20),
    branch_id integer,
    branch_name character varying(20),
    audit_content json,
    audit_status character varying(10) DEFAULT 'apply'::character varying,
    expt_log_id character varying(50),
    created_by character varying(10),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(10),
    updated_time timestamp(6) without time zone,
    parent_id uuid NOT NULL,
    item_no integer NOT NULL
);


ALTER TABLE cate.futures_audit_log OWNER TO tom;

--
-- Name: TABLE futures_audit_log; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON TABLE cate.futures_audit_log IS '价格变动申请审核的日志表';


--
-- Name: COLUMN futures_audit_log.metal_code; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_audit_log.metal_code IS '品类归属';


--
-- Name: COLUMN futures_audit_log.branch_id; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_audit_log.branch_id IS '分部id';


--
-- Name: COLUMN futures_audit_log.branch_name; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_audit_log.branch_name IS '分部名称';


--
-- Name: COLUMN futures_audit_log.audit_content; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_audit_log.audit_content IS '申请内容的json';


--
-- Name: COLUMN futures_audit_log.audit_status; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_audit_log.audit_status IS '是否申请成功: ''waiting''--申请中，''success''--成功，''fail''--失败';


--
-- Name: COLUMN futures_audit_log.expt_log_id; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_audit_log.expt_log_id IS 'uct_waste_cate_expect_log表的id(此审批不走钉钉，是ERP审批)';


--
-- Name: COLUMN futures_audit_log.created_by; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_audit_log.created_by IS '创建人';


--
-- Name: COLUMN futures_audit_log.created_time; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_audit_log.created_time IS '创建时间';


--
-- Name: COLUMN futures_audit_log.updated_by; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_audit_log.updated_by IS '修改人';


--
-- Name: COLUMN futures_audit_log.updated_time; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_audit_log.updated_time IS '修改时间';


--
-- Name: futures_exchange; Type: TABLE; Schema: cate; Owner: postgres
--

CREATE TABLE cate.futures_exchange (
    trading_place character varying(100),
    trading_pace_name character varying(100),
    trading_place_name_en character varying(100),
    trading_place_name_all character varying(100),
    close_time character varying(10),
    trading_time json,
    quote_url character varying(255),
    data_format json
);


ALTER TABLE cate.futures_exchange OWNER TO postgres;

--
-- Name: TABLE futures_exchange; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON TABLE cate.futures_exchange IS '交易场所的信息';


--
-- Name: COLUMN futures_exchange.trading_place; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_exchange.trading_place IS '交易场所';


--
-- Name: COLUMN futures_exchange.trading_pace_name; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_exchange.trading_pace_name IS '交易场所名称';


--
-- Name: COLUMN futures_exchange.trading_place_name_en; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_exchange.trading_place_name_en IS '交易场所名称英文';


--
-- Name: COLUMN futures_exchange.trading_place_name_all; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_exchange.trading_place_name_all IS '交易场所名称全称';


--
-- Name: COLUMN futures_exchange.close_time; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_exchange.close_time IS '收盘时间';


--
-- Name: COLUMN futures_exchange.trading_time; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_exchange.trading_time IS '交易时间';


--
-- Name: COLUMN futures_exchange.quote_url; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_exchange.quote_url IS '获取数据地址';


--
-- Name: COLUMN futures_exchange.data_format; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_exchange.data_format IS '数据格式';


--
-- Name: futures_quote_history; Type: TABLE; Schema: cate; Owner: tom
--

CREATE TABLE cate.futures_quote_history (
    trading_day date NOT NULL,
    instrument_id character varying(20) NOT NULL,
    exchange_code character varying(10) NOT NULL,
    open_price numeric(10,2),
    last_price numeric(10,2),
    highest_price numeric(10,2),
    lowest_price numeric(10,2),
    settlement_price numeric(10,2),
    status character varying(50) DEFAULT 'ready'::character varying,
    created_by character varying(10),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(10),
    updated_time timestamp(6) without time zone,
    metal_code character varying(20),
    id uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE cate.futures_quote_history OWNER TO tom;

--
-- Name: TABLE futures_quote_history; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON TABLE cate.futures_quote_history IS '沪铜价格变动表';


--
-- Name: COLUMN futures_quote_history.trading_day; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.trading_day IS '日期';


--
-- Name: COLUMN futures_quote_history.instrument_id; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.instrument_id IS '期货ID';


--
-- Name: COLUMN futures_quote_history.exchange_code; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.exchange_code IS '期货交易所';


--
-- Name: COLUMN futures_quote_history.open_price; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.open_price IS '开盘价(元/吨)';


--
-- Name: COLUMN futures_quote_history.last_price; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.last_price IS '收盘价(元/吨)';


--
-- Name: COLUMN futures_quote_history.highest_price; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.highest_price IS '最高价(元/吨)';


--
-- Name: COLUMN futures_quote_history.lowest_price; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.lowest_price IS '最低价(元/吨)';


--
-- Name: COLUMN futures_quote_history.settlement_price; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.settlement_price IS '结算价(元/吨)';


--
-- Name: COLUMN futures_quote_history.status; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.status IS '是否生效: ''ready''--准备，''valid''--生效，''invalid''--失效';


--
-- Name: COLUMN futures_quote_history.created_by; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.created_by IS '创建人';


--
-- Name: COLUMN futures_quote_history.created_time; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.created_time IS '创建时间';


--
-- Name: COLUMN futures_quote_history.updated_by; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.updated_by IS '修改人';


--
-- Name: COLUMN futures_quote_history.updated_time; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.updated_time IS '修改时间';


--
-- Name: COLUMN futures_quote_history.metal_code; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.futures_quote_history.metal_code IS '品类归属';


--
-- Name: futures_watch_list; Type: TABLE; Schema: cate; Owner: postgres
--

CREATE TABLE cate.futures_watch_list (
    metal character varying(50),
    exchange_code character varying(50),
    type_name character varying(50),
    price_unit character varying(50),
    price_unit_en character varying(50),
    price_range json,
    switch character varying(10) DEFAULT 'on'::character varying,
    user_info character varying(1000)
);


ALTER TABLE cate.futures_watch_list OWNER TO postgres;

--
-- Name: TABLE futures_watch_list; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON TABLE cate.futures_watch_list IS '需要获取的物料品类';


--
-- Name: COLUMN futures_watch_list.metal; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_watch_list.metal IS '货品归属code';


--
-- Name: COLUMN futures_watch_list.exchange_code; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_watch_list.exchange_code IS '交易代码';


--
-- Name: COLUMN futures_watch_list.type_name; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_watch_list.type_name IS '类型名称';


--
-- Name: COLUMN futures_watch_list.price_unit; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_watch_list.price_unit IS '价格单位';


--
-- Name: COLUMN futures_watch_list.price_unit_en; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_watch_list.price_unit_en IS '价格单位(英文)';


--
-- Name: COLUMN futures_watch_list.price_range; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_watch_list.price_range IS '变动的区间';


--
-- Name: COLUMN futures_watch_list.switch; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_watch_list.switch IS '开关："on"--开， "off"--关';


--
-- Name: COLUMN futures_watch_list.user_info; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.futures_watch_list.user_info IS '处理人信息';


--
-- Name: hw; Type: TABLE; Schema: cate; Owner: postgres
--

CREATE TABLE cate.hw (
    category character varying(255),
    sources character varying(255),
    code character varying(255),
    name character varying(255),
    characteristics character varying(255)
);


ALTER TABLE cate.hw OWNER TO postgres;

--
-- Name: pre_price_clac_rules; Type: TABLE; Schema: cate; Owner: tom
--

CREATE TABLE cate.pre_price_clac_rules (
    cate_name character varying(50) NOT NULL,
    formula character varying(200) NOT NULL,
    status character varying(10) DEFAULT 'enable'::character varying NOT NULL,
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    metal_code character varying(20),
    exchange_code character varying(20)
);


ALTER TABLE cate.pre_price_clac_rules OWNER TO tom;

--
-- Name: TABLE pre_price_clac_rules; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON TABLE cate.pre_price_clac_rules IS '铜泊销售单价计算规则';


--
-- Name: COLUMN pre_price_clac_rules.cate_name; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.pre_price_clac_rules.cate_name IS '货品名称';


--
-- Name: COLUMN pre_price_clac_rules.formula; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.pre_price_clac_rules.formula IS '货品销售单价计算公式';


--
-- Name: COLUMN pre_price_clac_rules.status; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.pre_price_clac_rules.status IS '规则是否禁用：''disable''--禁用   ''enable''--启用';


--
-- Name: COLUMN pre_price_clac_rules.created_by; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.pre_price_clac_rules.created_by IS '创建人';


--
-- Name: COLUMN pre_price_clac_rules.created_time; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.pre_price_clac_rules.created_time IS '创建时间';


--
-- Name: COLUMN pre_price_clac_rules.updated_by; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.pre_price_clac_rules.updated_by IS '更新人';


--
-- Name: COLUMN pre_price_clac_rules.updated_time; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.pre_price_clac_rules.updated_time IS '更新时间';


--
-- Name: COLUMN pre_price_clac_rules.metal_code; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.pre_price_clac_rules.metal_code IS '品类归属';


--
-- Name: COLUMN pre_price_clac_rules.exchange_code; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.pre_price_clac_rules.exchange_code IS '交易所';


--
-- Name: sample_label; Type: TABLE; Schema: cate; Owner: postgres
--

CREATE TABLE cate.sample_label (
    sn character varying(32),
    state character varying(20) DEFAULT 'draft'::character varying,
    copies integer,
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_time timestamp(6) without time zone
);


ALTER TABLE cate.sample_label OWNER TO postgres;

--
-- Name: COLUMN sample_label.sn; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_label.sn IS '样品标签No 格式： YYYYMMDDNNNNN';


--
-- Name: COLUMN sample_label.state; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_label.state IS '样品标签状态： ''draft'' -- 草稿, ''normal'' -- 正常, ''cancel'' -- 取消';


--
-- Name: COLUMN sample_label.copies; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_label.copies IS '副本数量';


--
-- Name: COLUMN sample_label.created_time; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_label.created_time IS '创建时间';


--
-- Name: COLUMN sample_label.updated_time; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_label.updated_time IS '修改时间';


--
-- Name: sample_lifecycle_log; Type: TABLE; Schema: cate; Owner: tom
--

CREATE TABLE cate.sample_lifecycle_log (
    sn character varying(13) NOT NULL,
    item_no integer NOT NULL,
    action character varying(10) DEFAULT 'print'::character varying NOT NULL,
    created_by character varying(10),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    origin character varying(32),
    payload json
);


ALTER TABLE cate.sample_lifecycle_log OWNER TO tom;

--
-- Name: TABLE sample_lifecycle_log; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON TABLE cate.sample_lifecycle_log IS '样品的生命周期的日志';


--
-- Name: COLUMN sample_lifecycle_log.sn; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.sample_lifecycle_log.sn IS '样品标签编号';


--
-- Name: COLUMN sample_lifecycle_log.item_no; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.sample_lifecycle_log.item_no IS '副本的ID';


--
-- Name: COLUMN sample_lifecycle_log.action; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.sample_lifecycle_log.action IS '动作：''print''--打印， ''reprint''--重印， ''cancel''--取消';


--
-- Name: COLUMN sample_lifecycle_log.created_by; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.sample_lifecycle_log.created_by IS '创建人';


--
-- Name: COLUMN sample_lifecycle_log.created_time; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.sample_lifecycle_log.created_time IS '创建时间';


--
-- Name: COLUMN sample_lifecycle_log.origin; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.sample_lifecycle_log.origin IS '来源';


--
-- Name: COLUMN sample_lifecycle_log.payload; Type: COMMENT; Schema: cate; Owner: tom
--

COMMENT ON COLUMN cate.sample_lifecycle_log.payload IS '携带的信息';


--
-- Name: sample_registration; Type: TABLE; Schema: cate; Owner: postgres
--

CREATE TABLE cate.sample_registration (
    sn character varying(32),
    item_no integer,
    sampler character varying(10),
    sampling_time timestamp(6) without time zone,
    sampling_address character varying(100),
    sampling_adcode bigint,
    wh_org_id uuid,
    sample_images json,
    bulk_sample_images json,
    pre_weight_by_month numeric(10,2),
    main_material text,
    secondary_material text,
    appearance_characteristics text,
    physical_characteristics text,
    chemical_characteristics text,
    recycling_reports json,
    material_analysis_reports json,
    created_by character varying(10),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(10),
    updated_time timestamp(6) without time zone
);


ALTER TABLE cate.sample_registration OWNER TO postgres;

--
-- Name: COLUMN sample_registration.sn; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.sn IS '样品SN';


--
-- Name: COLUMN sample_registration.item_no; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.item_no IS '副本编号';


--
-- Name: COLUMN sample_registration.sampler; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.sampler IS '取样人';


--
-- Name: COLUMN sample_registration.sampling_time; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.sampling_time IS '取样时间';


--
-- Name: COLUMN sample_registration.sampling_address; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.sampling_address IS '取样地址';


--
-- Name: COLUMN sample_registration.sampling_adcode; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.sampling_adcode IS '货品所在地 adcode';


--
-- Name: COLUMN sample_registration.wh_org_id; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.wh_org_id IS '样品寄存仓库';


--
-- Name: COLUMN sample_registration.sample_images; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.sample_images IS '小样近照';


--
-- Name: COLUMN sample_registration.bulk_sample_images; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.bulk_sample_images IS '大货堆放';


--
-- Name: COLUMN sample_registration.pre_weight_by_month; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.pre_weight_by_month IS '月/批次样品产生量（t)';


--
-- Name: COLUMN sample_registration.main_material; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.main_material IS '主材质';


--
-- Name: COLUMN sample_registration.secondary_material; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.secondary_material IS '杂质';


--
-- Name: COLUMN sample_registration.appearance_characteristics; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.appearance_characteristics IS '外观特征';


--
-- Name: COLUMN sample_registration.physical_characteristics; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.physical_characteristics IS '物理特征';


--
-- Name: COLUMN sample_registration.chemical_characteristics; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.chemical_characteristics IS '化学特性';


--
-- Name: COLUMN sample_registration.recycling_reports; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.recycling_reports IS '再生应用报告';


--
-- Name: COLUMN sample_registration.material_analysis_reports; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.material_analysis_reports IS '材质分析报告';


--
-- Name: COLUMN sample_registration.created_by; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.created_by IS '创建人';


--
-- Name: COLUMN sample_registration.created_time; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.created_time IS '创建时间';


--
-- Name: COLUMN sample_registration.updated_by; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.updated_by IS '修改人';


--
-- Name: COLUMN sample_registration.updated_time; Type: COMMENT; Schema: cate; Owner: postgres
--

COMMENT ON COLUMN cate.sample_registration.updated_time IS '修改时间';


--
-- Name: sw; Type: TABLE; Schema: cate; Owner: postgres
--

CREATE TABLE cate.sw (
    code character varying(10),
    name character varying(50),
    parent_code character varying(10)
);


ALTER TABLE cate.sw OWNER TO postgres;

--
-- Name: adcode; Type: TABLE; Schema: gis; Owner: postgres
--

CREATE TABLE gis.adcode (
    code bigint NOT NULL,
    parent bigint,
    name character varying(64),
    level character varying(16),
    rank integer,
    adcode integer,
    post_code character varying(8),
    area_code character varying(4),
    ur_code character varying(4),
    municipality boolean,
    virtual boolean,
    dummy boolean,
    longitude double precision,
    latitude double precision,
    center public.geometry(geometry,4326) NOT NULL,
    province character varying(64),
    city character varying(64),
    county character varying(64),
    town character varying(64),
    village character varying(64)
);


ALTER TABLE gis.adcode OWNER TO postgres;

--
-- Name: TABLE adcode; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON TABLE gis.adcode IS '中国行政区划表';


--
-- Name: COLUMN adcode.code; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.code IS '国家统计局12位行政区划代码';


--
-- Name: COLUMN adcode.parent; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.parent IS '12位父级行政区划代码';


--
-- Name: COLUMN adcode.name; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.name IS '行政单位名称';


--
-- Name: COLUMN adcode.level; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.level IS '行政单位级别:国/省/市/县/乡/村';


--
-- Name: COLUMN adcode.rank; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.rank IS '行政单位级别{0:国,1:省,2:市,3:区/县,4:乡/镇，5:街道/村}';


--
-- Name: COLUMN adcode.adcode; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.adcode IS '6位县级行政区划代码';


--
-- Name: COLUMN adcode.post_code; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.post_code IS '邮政编码';


--
-- Name: COLUMN adcode.area_code; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.area_code IS '长途区号';


--
-- Name: COLUMN adcode.ur_code; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.ur_code IS '3位城乡属性划分代码';


--
-- Name: COLUMN adcode.municipality; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.municipality IS '是否为直辖行政单位';


--
-- Name: COLUMN adcode.virtual; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.virtual IS '虚拟行政单位标记，如市辖区、省直辖县';


--
-- Name: COLUMN adcode.dummy; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.dummy IS '虚拟行政单位标记，例如虚拟村、虚拟社区';


--
-- Name: COLUMN adcode.longitude; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.longitude IS '地理中心经度';


--
-- Name: COLUMN adcode.latitude; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.latitude IS '地理中心纬度';


--
-- Name: COLUMN adcode.center; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.center IS '地理中心, ST_Point';


--
-- Name: COLUMN adcode.province; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.province IS '省';


--
-- Name: COLUMN adcode.city; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.city IS '市';


--
-- Name: COLUMN adcode.county; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.county IS '区/县';


--
-- Name: COLUMN adcode.town; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.town IS '乡/镇';


--
-- Name: COLUMN adcode.village; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.adcode.village IS '街道/村';


--
-- Name: fences; Type: TABLE; Schema: gis; Owner: postgres
--

CREATE TABLE gis.fences (
    code bigint NOT NULL,
    adcode integer,
    fence public.geometry(geometry,4326) NOT NULL
);


ALTER TABLE gis.fences OWNER TO postgres;

--
-- Name: TABLE fences; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON TABLE gis.fences IS '行政区划地理围栏';


--
-- Name: COLUMN fences.code; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.fences.code IS '国家统计局12位行政区划代码';


--
-- Name: COLUMN fences.adcode; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.fences.adcode IS '6位县级行政区划代码';


--
-- Name: COLUMN fences.fence; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.fences.fence IS '地理围栏,GCJ-02,MultiPolygon';


--
-- Name: cameras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cameras (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255),
    mfr character varying(255),
    sn character varying(32),
    pin character varying(32),
    channels integer,
    use_channels character varying(255),
    state boolean DEFAULT true,
    org_id uuid,
    site_id uuid,
    facility_id uuid,
    device_id character varying(32),
    properties json,
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    range character varying(255),
    item_no integer
);


ALTER TABLE public.cameras OWNER TO postgres;

--
-- Name: TABLE cameras; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.cameras IS '视频头';


--
-- Name: COLUMN cameras.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.id IS 'ID';


--
-- Name: COLUMN cameras.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.name IS '名称';


--
-- Name: COLUMN cameras.mfr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.mfr IS '设备厂家';


--
-- Name: COLUMN cameras.sn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.sn IS '设备序列号';


--
-- Name: COLUMN cameras.pin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.pin IS '验证码';


--
-- Name: COLUMN cameras.channels; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.channels IS '通道数';


--
-- Name: COLUMN cameras.use_channels; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.use_channels IS '使用通道数';


--
-- Name: COLUMN cameras.state; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.state IS '设备状态';


--
-- Name: COLUMN cameras.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.org_id IS '所属组织ID';


--
-- Name: COLUMN cameras.site_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.site_id IS '所属厂区ID';


--
-- Name: COLUMN cameras.facility_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.facility_id IS '所属设施ID';


--
-- Name: COLUMN cameras.device_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.device_id IS '所属设备ID';


--
-- Name: COLUMN cameras.properties; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.properties IS '附加数据';


--
-- Name: COLUMN cameras.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.revision IS '乐观锁';


--
-- Name: COLUMN cameras.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.created_by IS '创建人';


--
-- Name: COLUMN cameras.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.created_time IS '创建时间';


--
-- Name: COLUMN cameras.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.updated_by IS '更新人';


--
-- Name: COLUMN cameras.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.updated_time IS '更新时间';


--
-- Name: COLUMN cameras.range; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.range IS '通道范围， 例如： 17,32  —表示可选通道范围在17 至 32 之间。   ';


--
-- Name: COLUMN cameras.item_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.item_no IS '显示顺序';


--
-- Name: casbin_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.casbin_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.casbin_rules_id_seq OWNER TO postgres;

--
-- Name: casbin_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.casbin_rules (
    id bigint DEFAULT nextval('public.casbin_rules_id_seq'::regclass) NOT NULL,
    ptype character varying(255) NOT NULL,
    v0 character varying(255) DEFAULT NULL::character varying,
    v1 character varying(255) DEFAULT NULL::character varying,
    v2 character varying(255) DEFAULT NULL::character varying,
    v3 character varying(255) DEFAULT NULL::character varying,
    v4 character varying(255) DEFAULT NULL::character varying,
    v5 character varying(255) DEFAULT NULL::character varying
);


ALTER TABLE public.casbin_rules OWNER TO postgres;

--
-- Name: container_histroy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.container_histroy (
    sn character varying(32),
    org_id uuid,
    use_org_id uuid,
    site_id uuid,
    facility_id uuid,
    owner character varying(60),
    action character varying(32),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.container_histroy OWNER TO postgres;

--
-- Name: TABLE container_histroy; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.container_histroy IS '容器历史表';


--
-- Name: COLUMN container_histroy.sn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.sn IS '容量ID';


--
-- Name: COLUMN container_histroy.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.org_id IS '所属组织';


--
-- Name: COLUMN container_histroy.use_org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.use_org_id IS '当前所在组织';


--
-- Name: COLUMN container_histroy.site_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.site_id IS '当前所在厂区';


--
-- Name: COLUMN container_histroy.facility_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.facility_id IS '当前所在组织';


--
-- Name: COLUMN container_histroy.owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.owner IS '当前拥有者';


--
-- Name: COLUMN container_histroy.action; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.action IS '当前动作';


--
-- Name: COLUMN container_histroy.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.tenant_id IS '租户号';


--
-- Name: COLUMN container_histroy.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.revision IS '乐观锁';


--
-- Name: COLUMN container_histroy.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.created_by IS '创建人';


--
-- Name: COLUMN container_histroy.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.created_time IS '创建时间';


--
-- Name: COLUMN container_histroy.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.updated_by IS '更新人';


--
-- Name: COLUMN container_histroy.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_histroy.updated_time IS '更新时间';


--
-- Name: container_wip; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.container_wip (
    sn character varying(32),
    org_id uuid,
    curr_org_id uuid,
    curr_site_id uuid,
    curr_facility_id uuid,
    curr_owner character varying(60),
    curr_plate_number character varying(32),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    state character varying(32)
);


ALTER TABLE public.container_wip OWNER TO postgres;

--
-- Name: TABLE container_wip; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.container_wip IS '容器WIP表';


--
-- Name: COLUMN container_wip.sn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.sn IS '容量ID';


--
-- Name: COLUMN container_wip.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.org_id IS '所属组织';


--
-- Name: COLUMN container_wip.curr_org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.curr_org_id IS '当前所在组织';


--
-- Name: COLUMN container_wip.curr_site_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.curr_site_id IS '当前所在厂区';


--
-- Name: COLUMN container_wip.curr_facility_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.curr_facility_id IS '当前所在站点';


--
-- Name: COLUMN container_wip.curr_owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.curr_owner IS '当前拥有者';


--
-- Name: COLUMN container_wip.curr_plate_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.curr_plate_number IS '当前所在车牌';


--
-- Name: COLUMN container_wip.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.tenant_id IS '租户号';


--
-- Name: COLUMN container_wip.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.revision IS '乐观锁';


--
-- Name: COLUMN container_wip.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.created_by IS '创建人';


--
-- Name: COLUMN container_wip.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.created_time IS '创建时间';


--
-- Name: COLUMN container_wip.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.updated_by IS '更新人';


--
-- Name: COLUMN container_wip.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.updated_time IS '更新时间';


--
-- Name: COLUMN container_wip.state; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.container_wip.state IS '当前状态 ready 待领用， take 已领取， dropped 已投放， take-back 已收回';


--
-- Name: containers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.containers (
    id uuid DEFAULT public.uuid_generate_v4(),
    sn character varying(32),
    csn character varying(32),
    state character varying(255),
    weight numeric(24,6),
    weight_unit character varying(32),
    last_calibration_at timestamp(6) without time zone,
    hw_info json,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    original_org_id uuid,
    final_org_id uuid,
    tem_id character varying(32)
);


ALTER TABLE public.containers OWNER TO postgres;

--
-- Name: TABLE containers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.containers IS '容量信息';


--
-- Name: COLUMN containers.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.id IS 'ID';


--
-- Name: COLUMN containers.sn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.sn IS '序列号';


--
-- Name: COLUMN containers.csn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.csn IS '容器类型';


--
-- Name: COLUMN containers.state; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.state IS '状态： normal 正常 、 damaged 已损坏、 repairing 修理中、 discarded 已报废';


--
-- Name: COLUMN containers.weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.weight IS '重量';


--
-- Name: COLUMN containers.weight_unit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.weight_unit IS '单位';


--
-- Name: COLUMN containers.last_calibration_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.last_calibration_at IS '最后校正时间';


--
-- Name: COLUMN containers.hw_info; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.hw_info IS '硬件信息';


--
-- Name: COLUMN containers.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.tenant_id IS '租户号';


--
-- Name: COLUMN containers.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.revision IS '乐观锁';


--
-- Name: COLUMN containers.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.created_by IS '创建人';


--
-- Name: COLUMN containers.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.created_time IS '创建时间';


--
-- Name: COLUMN containers.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.updated_by IS '更新人';


--
-- Name: COLUMN containers.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.updated_time IS '更新时间';


--
-- Name: COLUMN containers.original_org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.original_org_id IS '采买的组织';


--
-- Name: COLUMN containers.final_org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.final_org_id IS '最后的';


--
-- Name: COLUMN containers.tem_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.containers.tem_id IS '终端号';


--
-- Name: dept; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dept (
    origin character varying(32) NOT NULL,
    agent_id character varying(32) NOT NULL,
    dept_id integer NOT NULL,
    name character varying(255),
    parent_id integer,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.dept OWNER TO postgres;

--
-- Name: TABLE dept; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.dept IS '部门表';


--
-- Name: COLUMN dept.origin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.origin IS '来源';


--
-- Name: COLUMN dept.agent_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.agent_id IS 'agentID';


--
-- Name: COLUMN dept.dept_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.dept_id IS '部门ID';


--
-- Name: COLUMN dept.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.name IS '部门名称';


--
-- Name: COLUMN dept.parent_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.parent_id IS '上级部门';


--
-- Name: COLUMN dept.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.tenant_id IS '租户号';


--
-- Name: COLUMN dept.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.revision IS '乐观锁';


--
-- Name: COLUMN dept.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.created_by IS '创建人';


--
-- Name: COLUMN dept.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.created_time IS '创建时间';


--
-- Name: COLUMN dept.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.updated_by IS '更新人';


--
-- Name: COLUMN dept.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept.updated_time IS '更新时间';


--
-- Name: dept_org_rel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dept_org_rel (
    dept_id integer,
    org_id uuid,
    active boolean,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.dept_org_rel OWNER TO postgres;

--
-- Name: TABLE dept_org_rel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.dept_org_rel IS '部门与组织关系对照表';


--
-- Name: COLUMN dept_org_rel.dept_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_org_rel.dept_id IS '部门ID';


--
-- Name: COLUMN dept_org_rel.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_org_rel.org_id IS '组织ID';


--
-- Name: COLUMN dept_org_rel.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_org_rel.active IS '有效';


--
-- Name: COLUMN dept_org_rel.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_org_rel.tenant_id IS '租户号';


--
-- Name: COLUMN dept_org_rel.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_org_rel.revision IS '乐观锁';


--
-- Name: COLUMN dept_org_rel.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_org_rel.created_by IS '创建人';


--
-- Name: COLUMN dept_org_rel.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_org_rel.created_time IS '创建时间';


--
-- Name: COLUMN dept_org_rel.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_org_rel.updated_by IS '更新人';


--
-- Name: COLUMN dept_org_rel.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_org_rel.updated_time IS '更新时间';


--
-- Name: dept_user_rel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dept_user_rel (
    dept_id integer NOT NULL,
    dept_order bigint,
    union_id character varying(50) NOT NULL,
    user_id character varying(32) NOT NULL,
    name character varying(50),
    mobile character varying(20),
    title character varying(100),
    leader boolean,
    boss boolean,
    admin boolean,
    avatar character varying(255),
    active boolean,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    sync_flag integer DEFAULT 0
);


ALTER TABLE public.dept_user_rel OWNER TO postgres;

--
-- Name: COLUMN dept_user_rel.dept_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.dept_id IS '所在部门';


--
-- Name: COLUMN dept_user_rel.dept_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.dept_order IS '员工在部中的排序';


--
-- Name: COLUMN dept_user_rel.union_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.union_id IS '唯一标识';


--
-- Name: COLUMN dept_user_rel.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.user_id IS '用户ID';


--
-- Name: COLUMN dept_user_rel.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.name IS '姓名';


--
-- Name: COLUMN dept_user_rel.mobile; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.mobile IS '手机号';


--
-- Name: COLUMN dept_user_rel.title; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.title IS '职位';


--
-- Name: COLUMN dept_user_rel.leader; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.leader IS '是否是部门主管';


--
-- Name: COLUMN dept_user_rel.boss; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.boss IS '是否老板';


--
-- Name: COLUMN dept_user_rel.admin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.admin IS '是否为企业的管理员';


--
-- Name: COLUMN dept_user_rel.avatar; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.avatar IS '头像';


--
-- Name: COLUMN dept_user_rel.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.active IS '是否激活';


--
-- Name: COLUMN dept_user_rel.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.tenant_id IS '租户号';


--
-- Name: COLUMN dept_user_rel.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.revision IS '乐观锁';


--
-- Name: COLUMN dept_user_rel.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.created_by IS '创建人';


--
-- Name: COLUMN dept_user_rel.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.created_time IS '创建时间';


--
-- Name: COLUMN dept_user_rel.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.updated_by IS '更新人';


--
-- Name: COLUMN dept_user_rel.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.updated_time IS '更新时间';


--
-- Name: COLUMN dept_user_rel.sync_flag; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dept_user_rel.sync_flag IS '同步标记位， 0 未同步， 1 已同步';


--
-- Name: dict; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dict (
    id integer NOT NULL,
    pid integer,
    code character varying(100),
    name character varying(100),
    item_no integer,
    status boolean DEFAULT true,
    "default" boolean DEFAULT false,
    "group" character varying(100),
    allow text,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.dict OWNER TO postgres;

--
-- Name: COLUMN dict.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.id IS 'ID';


--
-- Name: COLUMN dict.pid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.pid IS '父级ID';


--
-- Name: COLUMN dict.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.code IS '字典代码';


--
-- Name: COLUMN dict.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.name IS '字典名称';


--
-- Name: COLUMN dict.item_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.item_no IS '序号';


--
-- Name: COLUMN dict.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.status IS '可用状态';


--
-- Name: COLUMN dict."default"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict."default" IS '是否为默认值';


--
-- Name: COLUMN dict."group"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict."group" IS '分类';


--
-- Name: COLUMN dict.allow; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.allow IS '允许的';


--
-- Name: COLUMN dict.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.tenant_id IS '租户号';


--
-- Name: COLUMN dict.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.revision IS '乐观锁';


--
-- Name: COLUMN dict.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.created_by IS '创建人';


--
-- Name: COLUMN dict.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.created_time IS '创建时间';


--
-- Name: COLUMN dict.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.updated_by IS '更新人';


--
-- Name: COLUMN dict.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dict.updated_time IS '更新时间';


--
-- Name: equipments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipments (
    id uuid DEFAULT public.uuid_generate_v4(),
    code character varying(32) NOT NULL,
    name character varying(255),
    category character varying(255),
    type character varying(32),
    tare numeric(24,6),
    weight_unit character varying(32),
    volume numeric(24,6),
    volume_unit character varying(32),
    capacity numeric(24,6),
    lenght numeric(24,6),
    width numeric(24,6),
    height numeric(24,6),
    length_unit character varying(32),
    stackable_qty integer,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.equipments OWNER TO postgres;

--
-- Name: TABLE equipments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.equipments IS '设备信息';


--
-- Name: COLUMN equipments.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.id IS 'ID';


--
-- Name: COLUMN equipments.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.code IS '编码';


--
-- Name: COLUMN equipments.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.name IS '设备名称';


--
-- Name: COLUMN equipments.category; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.category IS '设备分类';


--
-- Name: COLUMN equipments.type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.type IS '设备类型';


--
-- Name: COLUMN equipments.tare; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.tare IS '设备毛重';


--
-- Name: COLUMN equipments.weight_unit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.weight_unit IS '重量单位';


--
-- Name: COLUMN equipments.volume; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.volume IS '体积';


--
-- Name: COLUMN equipments.volume_unit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.volume_unit IS '体积单位';


--
-- Name: COLUMN equipments.capacity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.capacity IS '容积';


--
-- Name: COLUMN equipments.lenght; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.lenght IS '长度';


--
-- Name: COLUMN equipments.width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.width IS '宽度';


--
-- Name: COLUMN equipments.height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.height IS '高度';


--
-- Name: COLUMN equipments.length_unit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.length_unit IS '长度单位';


--
-- Name: COLUMN equipments.stackable_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.stackable_qty IS '可堆叠层数';


--
-- Name: COLUMN equipments.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.tenant_id IS '租户号';


--
-- Name: COLUMN equipments.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.revision IS '乐观锁';


--
-- Name: COLUMN equipments.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.created_by IS '创建人';


--
-- Name: COLUMN equipments.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.created_time IS '创建时间';


--
-- Name: COLUMN equipments.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.updated_by IS '更新人';


--
-- Name: COLUMN equipments.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipments.updated_time IS '更新时间';


--
-- Name: facilitys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facilitys (
    id uuid DEFAULT public.uuid_generate_v4(),
    code character varying(255),
    name character varying(255),
    type character varying(32),
    site_id uuid,
    org_id uuid,
    address character varying(255),
    fence public.geometry(geometry,4326),
    location circle,
    owner character varying(255),
    tel character varying(255),
    active character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    properties json
);


ALTER TABLE public.facilitys OWNER TO postgres;

--
-- Name: TABLE facilitys; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.facilitys IS '设施信息';


--
-- Name: COLUMN facilitys.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.id IS '设施ID';


--
-- Name: COLUMN facilitys.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.code IS '设施编号';


--
-- Name: COLUMN facilitys.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.name IS '设施名称';


--
-- Name: COLUMN facilitys.type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.type IS '设施类型';


--
-- Name: COLUMN facilitys.site_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.site_id IS '所属厂区';


--
-- Name: COLUMN facilitys.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.org_id IS '所属组织ID';


--
-- Name: COLUMN facilitys.address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.address IS '设施所在地址';


--
-- Name: COLUMN facilitys.fence; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.fence IS '围栏';


--
-- Name: COLUMN facilitys.location; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.location IS '定位，半径';


--
-- Name: COLUMN facilitys.owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.owner IS '负责人';


--
-- Name: COLUMN facilitys.tel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.tel IS '联系电话';


--
-- Name: COLUMN facilitys.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.active IS '可用标志';


--
-- Name: COLUMN facilitys.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.tenant_id IS '租户号';


--
-- Name: COLUMN facilitys.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.revision IS '乐观锁';


--
-- Name: COLUMN facilitys.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.created_by IS '创建人';


--
-- Name: COLUMN facilitys.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.created_time IS '创建时间';


--
-- Name: COLUMN facilitys.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.updated_by IS '更新人';


--
-- Name: COLUMN facilitys.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.facilitys.updated_time IS '更新时间';


--
-- Name: icons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.icons (
    code character varying(100),
    type character varying(100),
    color character varying(255),
    image_base64 text,
    name character varying(255)
);


ALTER TABLE public.icons OWNER TO postgres;

--
-- Name: iot_device_mfr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.iot_device_mfr (
    code character varying(15),
    name character varying(50),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.iot_device_mfr OWNER TO postgres;

--
-- Name: COLUMN iot_device_mfr.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_device_mfr.tenant_id IS '租户号';


--
-- Name: COLUMN iot_device_mfr.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_device_mfr.revision IS '乐观锁';


--
-- Name: COLUMN iot_device_mfr.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_device_mfr.created_by IS '创建人';


--
-- Name: COLUMN iot_device_mfr.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_device_mfr.created_time IS '创建时间';


--
-- Name: COLUMN iot_device_mfr.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_device_mfr.updated_by IS '更新人';


--
-- Name: COLUMN iot_device_mfr.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_device_mfr.updated_time IS '更新时间';


--
-- Name: iot_devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.iot_devices (
    id uuid DEFAULT public.uuid_generate_v4(),
    sn character varying(32) NOT NULL,
    imei character varying(32),
    type character varying(255),
    mfr character varying(255),
    state boolean,
    lot_id character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    modules character varying(255),
    hw_info json,
    remarks text
);


ALTER TABLE public.iot_devices OWNER TO postgres;

--
-- Name: TABLE iot_devices; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.iot_devices IS '设备表';


--
-- Name: COLUMN iot_devices.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.id IS 'ID';


--
-- Name: COLUMN iot_devices.sn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.sn IS '设备序列号';


--
-- Name: COLUMN iot_devices.imei; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.imei IS 'IMEI';


--
-- Name: COLUMN iot_devices.type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.type IS '设备类型';


--
-- Name: COLUMN iot_devices.mfr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.mfr IS '设备厂商';


--
-- Name: COLUMN iot_devices.state; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.state IS '设备状态';


--
-- Name: COLUMN iot_devices.lot_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.lot_id IS '采购批号';


--
-- Name: COLUMN iot_devices.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.tenant_id IS '租户号';


--
-- Name: COLUMN iot_devices.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.revision IS '乐观锁';


--
-- Name: COLUMN iot_devices.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.created_by IS '创建人';


--
-- Name: COLUMN iot_devices.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.created_time IS '创建时间';


--
-- Name: COLUMN iot_devices.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.updated_by IS '更新人';


--
-- Name: COLUMN iot_devices.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.updated_time IS '更新时间';


--
-- Name: COLUMN iot_devices.modules; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices.modules IS '使用组件';


--
-- Name: iot_devices_wip; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.iot_devices_wip (
    sn character varying(32) NOT NULL,
    online boolean,
    last_online_at timestamp(6) without time zone,
    last_offline_at timestamp(6) without time zone,
    last_heartbeat_at timestamp(6) without time zone,
    last_gps_report_at timestamp(6) without time zone,
    battery_level integer,
    has_battery boolean,
    low_battery_threshold integer,
    last_alert_report_at timestamp(6) without time zone,
    alert_type character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    tem_type character varying(32),
    alert_payload json,
    last_gps_position public.geometry(geometry,4326)
);


ALTER TABLE public.iot_devices_wip OWNER TO postgres;

--
-- Name: TABLE iot_devices_wip; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.iot_devices_wip IS '设备表';


--
-- Name: COLUMN iot_devices_wip.sn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.sn IS '设备序列号';


--
-- Name: COLUMN iot_devices_wip.online; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.online IS '在线状态';


--
-- Name: COLUMN iot_devices_wip.last_online_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.last_online_at IS '最后上线时间';


--
-- Name: COLUMN iot_devices_wip.last_offline_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.last_offline_at IS '最后离线时间';


--
-- Name: COLUMN iot_devices_wip.last_heartbeat_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.last_heartbeat_at IS '最后心跳回传时间';


--
-- Name: COLUMN iot_devices_wip.last_gps_report_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.last_gps_report_at IS '最后GPS回报时间';


--
-- Name: COLUMN iot_devices_wip.battery_level; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.battery_level IS '电池电量百分比';


--
-- Name: COLUMN iot_devices_wip.has_battery; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.has_battery IS '是否有电池';


--
-- Name: COLUMN iot_devices_wip.low_battery_threshold; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.low_battery_threshold IS '低电压警告';


--
-- Name: COLUMN iot_devices_wip.last_alert_report_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.last_alert_report_at IS '最后警报时间';


--
-- Name: COLUMN iot_devices_wip.alert_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.alert_type IS '警报类型';


--
-- Name: COLUMN iot_devices_wip.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.tenant_id IS '租户号';


--
-- Name: COLUMN iot_devices_wip.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.revision IS '乐观锁';


--
-- Name: COLUMN iot_devices_wip.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.created_by IS '创建人';


--
-- Name: COLUMN iot_devices_wip.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.created_time IS '创建时间';


--
-- Name: COLUMN iot_devices_wip.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.updated_by IS '更新人';


--
-- Name: COLUMN iot_devices_wip.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.updated_time IS '更新时间';


--
-- Name: COLUMN iot_devices_wip.tem_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.tem_type IS '设备类型';


--
-- Name: COLUMN iot_devices_wip.alert_payload; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.alert_payload IS '警报详情';


--
-- Name: COLUMN iot_devices_wip.last_gps_position; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.iot_devices_wip.last_gps_position IS '最后的地理位置, ST_Point';


--
-- Name: menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menu (
    level integer,
    project_code character varying(255),
    name character varying(255),
    code character varying(255),
    parent_code character varying(255),
    icon character varying(255),
    permission character varying(255),
    order_item integer,
    active boolean,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(23),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.menu OWNER TO postgres;

--
-- Name: TABLE menu; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.menu IS '菜单表';


--
-- Name: COLUMN menu.level; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.level IS '菜单级别';


--
-- Name: COLUMN menu.project_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.project_code IS '项目代码';


--
-- Name: COLUMN menu.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.name IS '菜单名称';


--
-- Name: COLUMN menu.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.code IS '菜单代码';


--
-- Name: COLUMN menu.parent_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.parent_code IS '父级代码';


--
-- Name: COLUMN menu.icon; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.icon IS '图标';


--
-- Name: COLUMN menu.permission; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.permission IS '权限';


--
-- Name: COLUMN menu.order_item; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.order_item IS '显示序号';


--
-- Name: COLUMN menu.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.active IS '有效标志';


--
-- Name: COLUMN menu.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.tenant_id IS '租户号';


--
-- Name: COLUMN menu.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.revision IS '乐观锁';


--
-- Name: COLUMN menu.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.created_by IS '创建人';


--
-- Name: COLUMN menu.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.created_time IS '创建时间';


--
-- Name: COLUMN menu.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.updated_by IS '更新人';


--
-- Name: COLUMN menu.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.menu.updated_time IS '更新时间';


--
-- Name: new_discover; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.new_discover (
    hz character varying(1) NOT NULL,
    py character varying(6),
    zm character varying(1)
);


ALTER TABLE public.new_discover OWNER TO postgres;

--
-- Name: org_role_usr_rel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.org_role_usr_rel (
    org_id uuid,
    role_id uuid,
    user_id uuid,
    active character varying(255),
    begin_time timestamp(6) without time zone,
    end_time timestamp(6) without time zone,
    authorizer character varying(255),
    grant_time timestamp(6) without time zone,
    grant_way character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.org_role_usr_rel OWNER TO postgres;

--
-- Name: TABLE org_role_usr_rel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.org_role_usr_rel IS '组织成员角色关系表';


--
-- Name: COLUMN org_role_usr_rel.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.org_id IS '组织ID';


--
-- Name: COLUMN org_role_usr_rel.role_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.role_id IS '角色ID';


--
-- Name: COLUMN org_role_usr_rel.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.user_id IS '用户ID';


--
-- Name: COLUMN org_role_usr_rel.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.active IS '有效标志';


--
-- Name: COLUMN org_role_usr_rel.begin_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.begin_time IS '开始生效时间';


--
-- Name: COLUMN org_role_usr_rel.end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.end_time IS '结束生效时间';


--
-- Name: COLUMN org_role_usr_rel.authorizer; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.authorizer IS '授权人';


--
-- Name: COLUMN org_role_usr_rel.grant_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.grant_time IS '授权时间';


--
-- Name: COLUMN org_role_usr_rel.grant_way; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.grant_way IS '授权方式';


--
-- Name: COLUMN org_role_usr_rel.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.tenant_id IS '租户号';


--
-- Name: COLUMN org_role_usr_rel.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.revision IS '乐观锁';


--
-- Name: COLUMN org_role_usr_rel.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.created_by IS '创建人';


--
-- Name: COLUMN org_role_usr_rel.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.created_time IS '创建时间';


--
-- Name: COLUMN org_role_usr_rel.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.updated_by IS '更新人';


--
-- Name: COLUMN org_role_usr_rel.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.org_role_usr_rel.updated_time IS '更新时间';


--
-- Name: organization_his; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_his (
    month character varying(10),
    org_id uuid,
    org_name character varying(255),
    org_erp_id integer,
    rel_org_id uuid,
    branch_id integer,
    branch_name character varying(255),
    star integer,
    created_by character varying(20),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(20),
    updated_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.organization_his OWNER TO postgres;

--
-- Name: organization_reg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_reg (
    id uuid DEFAULT public.uuid_generate_v4(),
    code character varying(32),
    name character varying(90),
    short_name character varying(90),
    type character varying(32),
    address character varying(255),
    owner character varying(60),
    tel character varying(20),
    email character varying(255),
    reg_org_id uuid,
    relation character varying(255),
    status public.reg_status DEFAULT 'waiting'::public.reg_status,
    adcode integer,
    origin character varying(90),
    oid character varying(32),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.organization_reg OWNER TO postgres;

--
-- Name: TABLE organization_reg; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.organization_reg IS '组织信息-注册';


--
-- Name: COLUMN organization_reg.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.id IS '组织ID';


--
-- Name: COLUMN organization_reg.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.code IS '社会识别码';


--
-- Name: COLUMN organization_reg.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.name IS '组织名称';


--
-- Name: COLUMN organization_reg.short_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.short_name IS '组织简称';


--
-- Name: COLUMN organization_reg.type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.type IS '组织类型';


--
-- Name: COLUMN organization_reg.address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.address IS '组织注册地址';


--
-- Name: COLUMN organization_reg.owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.owner IS '组织负责人';


--
-- Name: COLUMN organization_reg.tel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.tel IS '组织联系电话';


--
-- Name: COLUMN organization_reg.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.email IS '组织电邮';


--
-- Name: COLUMN organization_reg.reg_org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.reg_org_id IS '指定入驻组织';


--
-- Name: COLUMN organization_reg.relation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.relation IS '关系形式';


--
-- Name: COLUMN organization_reg.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.status IS '状态';


--
-- Name: COLUMN organization_reg.adcode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.adcode IS '所属地区';


--
-- Name: COLUMN organization_reg.origin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.origin IS '来源';


--
-- Name: COLUMN organization_reg.oid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.oid IS '来源ID';


--
-- Name: COLUMN organization_reg.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.tenant_id IS '租户号';


--
-- Name: COLUMN organization_reg.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.revision IS '乐观锁';


--
-- Name: COLUMN organization_reg.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.created_by IS '创建人';


--
-- Name: COLUMN organization_reg.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.created_time IS '创建时间';


--
-- Name: COLUMN organization_reg.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.updated_by IS '更新人';


--
-- Name: COLUMN organization_reg.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_reg.updated_time IS '更新时间';


--
-- Name: organization_rel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_rel (
    a_org_id uuid,
    b_org_id uuid,
    relation character varying(255),
    active boolean,
    effective_date timestamp(6) without time zone,
    expiration_date timestamp(6) without time zone,
    contract_id character varying(255),
    contract_data json,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    c_org_id uuid
);


ALTER TABLE public.organization_rel OWNER TO postgres;

--
-- Name: TABLE organization_rel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.organization_rel IS '组织关联关系表';


--
-- Name: COLUMN organization_rel.a_org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.a_org_id IS '甲方-组织ID';


--
-- Name: COLUMN organization_rel.b_org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.b_org_id IS '乙方-组织ID';


--
-- Name: COLUMN organization_rel.relation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.relation IS '关系形式 up 上游，down 下游，subsidiary 子公司， partner 合作伙伴';


--
-- Name: COLUMN organization_rel.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.active IS '有效标志位';


--
-- Name: COLUMN organization_rel.effective_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.effective_date IS '生效日期';


--
-- Name: COLUMN organization_rel.expiration_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.expiration_date IS '失效日期';


--
-- Name: COLUMN organization_rel.contract_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.contract_id IS '合同号';


--
-- Name: COLUMN organization_rel.contract_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.contract_data IS '合同内参数';


--
-- Name: COLUMN organization_rel.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.tenant_id IS '租户号';


--
-- Name: COLUMN organization_rel.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.revision IS '乐观锁';


--
-- Name: COLUMN organization_rel.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.created_by IS '创建人';


--
-- Name: COLUMN organization_rel.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.created_time IS '创建时间';


--
-- Name: COLUMN organization_rel.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.updated_by IS '更新人';


--
-- Name: COLUMN organization_rel.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.updated_time IS '更新时间';


--
-- Name: COLUMN organization_rel.c_org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organization_rel.c_org_id IS '委托方-组织ID';


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizations (
    id uuid DEFAULT public.uuid_generate_v4(),
    code character varying(64),
    name character varying(255),
    short_name character varying(90),
    type character varying(32),
    address character varying(255),
    owner character varying(90),
    tel character varying(20),
    email character varying(255),
    status boolean DEFAULT true,
    adcode bigint,
    properties json,
    origin character varying(50),
    oid character varying(36),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: TABLE organizations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.organizations IS '组织信息';


--
-- Name: COLUMN organizations.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.id IS '组织ID';


--
-- Name: COLUMN organizations.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.code IS '社会识别码';


--
-- Name: COLUMN organizations.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.name IS '组织名称';


--
-- Name: COLUMN organizations.short_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.short_name IS '组织简称';


--
-- Name: COLUMN organizations.type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.type IS '组织类型';


--
-- Name: COLUMN organizations.address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.address IS '组织注册地址';


--
-- Name: COLUMN organizations.owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.owner IS '组织负责人';


--
-- Name: COLUMN organizations.tel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.tel IS '组织联系电话';


--
-- Name: COLUMN organizations.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.email IS '组织电邮';


--
-- Name: COLUMN organizations.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.status IS '状态';


--
-- Name: COLUMN organizations.adcode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.adcode IS '所属地区';


--
-- Name: COLUMN organizations.properties; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.properties IS '附加数据';


--
-- Name: COLUMN organizations.origin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.origin IS '来源';


--
-- Name: COLUMN organizations.oid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.oid IS '来源ID';


--
-- Name: COLUMN organizations.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.tenant_id IS '租户号';


--
-- Name: COLUMN organizations.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.revision IS '乐观锁';


--
-- Name: COLUMN organizations.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.created_by IS '创建人';


--
-- Name: COLUMN organizations.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.created_time IS '创建时间';


--
-- Name: COLUMN organizations.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.updated_by IS '更新人';


--
-- Name: COLUMN organizations.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.updated_time IS '更新时间';


--
-- Name: pinyin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pinyin (
    hz character varying(1),
    py character varying(6),
    zm character varying(1)
);


ALTER TABLE public.pinyin OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id uuid DEFAULT public.uuid_generate_v4(),
    code character varying(255),
    org_type character varying(32),
    name character varying(60),
    remarks character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: TABLE roles; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.roles IS '角色信息';


--
-- Name: COLUMN roles.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.id IS '角色ID';


--
-- Name: COLUMN roles.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.code IS '角色编码';


--
-- Name: COLUMN roles.org_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.org_type IS '组织类型';


--
-- Name: COLUMN roles.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.name IS '角色名称';


--
-- Name: COLUMN roles.remarks; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.remarks IS '角色描述';


--
-- Name: COLUMN roles.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.tenant_id IS '租户号';


--
-- Name: COLUMN roles.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.revision IS '乐观锁';


--
-- Name: COLUMN roles.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.created_by IS '创建人';


--
-- Name: COLUMN roles.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.created_time IS '创建时间';


--
-- Name: COLUMN roles.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.updated_by IS '更新人';


--
-- Name: COLUMN roles.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roles.updated_time IS '更新时间';


--
-- Name: route_template_detail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.route_template_detail (
    id uuid,
    template_id uuid,
    item_no integer,
    station_id uuid,
    address character varying(255),
    location public.geometry(geometry,4326),
    req_arrival_time character varying(255),
    job_use_time integer,
    active character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.route_template_detail OWNER TO postgres;

--
-- Name: TABLE route_template_detail; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.route_template_detail IS '路线模板明细';


--
-- Name: COLUMN route_template_detail.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.id IS '模板详情ID';


--
-- Name: COLUMN route_template_detail.template_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.template_id IS '路线模板ID';


--
-- Name: COLUMN route_template_detail.item_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.item_no IS '序号';


--
-- Name: COLUMN route_template_detail.station_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.station_id IS '站点ID';


--
-- Name: COLUMN route_template_detail.address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.address IS '地址';


--
-- Name: COLUMN route_template_detail.location; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.location IS 'GPS定位';


--
-- Name: COLUMN route_template_detail.req_arrival_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.req_arrival_time IS '要求抵达时间';


--
-- Name: COLUMN route_template_detail.job_use_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.job_use_time IS '作业用时';


--
-- Name: COLUMN route_template_detail.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.active IS '可用标志位';


--
-- Name: COLUMN route_template_detail.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.tenant_id IS '租户号';


--
-- Name: COLUMN route_template_detail.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.revision IS '乐观锁';


--
-- Name: COLUMN route_template_detail.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.created_by IS '创建人';


--
-- Name: COLUMN route_template_detail.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.created_time IS '创建时间';


--
-- Name: COLUMN route_template_detail.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.updated_by IS '更新人';


--
-- Name: COLUMN route_template_detail.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_template_detail.updated_time IS '更新时间';


--
-- Name: route_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.route_templates (
    id character varying(255),
    name character varying(255),
    org_id character varying(255),
    adcode character varying(255),
    active character varying(255),
    vehicle_type character varying(255),
    vehicle_load_weight character varying(255),
    container_type character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.route_templates OWNER TO postgres;

--
-- Name: TABLE route_templates; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.route_templates IS '路线模板';


--
-- Name: COLUMN route_templates.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.id IS '模板ID';


--
-- Name: COLUMN route_templates.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.name IS '模板名称';


--
-- Name: COLUMN route_templates.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.org_id IS '所属组织ID';


--
-- Name: COLUMN route_templates.adcode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.adcode IS '所属区域';


--
-- Name: COLUMN route_templates.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.active IS '可用标志位';


--
-- Name: COLUMN route_templates.vehicle_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.vehicle_type IS '车辆类型';


--
-- Name: COLUMN route_templates.vehicle_load_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.vehicle_load_weight IS '车辆载荷';


--
-- Name: COLUMN route_templates.container_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.container_type IS '容器类型';


--
-- Name: COLUMN route_templates.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.tenant_id IS '租户号';


--
-- Name: COLUMN route_templates.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.revision IS '乐观锁';


--
-- Name: COLUMN route_templates.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.created_by IS '创建人';


--
-- Name: COLUMN route_templates.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.created_time IS '创建时间';


--
-- Name: COLUMN route_templates.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.updated_by IS '更新人';


--
-- Name: COLUMN route_templates.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.route_templates.updated_time IS '更新时间';


--
-- Name: routes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routes (
    route_id character varying(32),
    adcode integer,
    osp_org_id uuid,
    csp_org_id uuid,
    job_date character varying(255),
    plate_number uuid,
    driver_id character varying(32),
    driver_name character varying(90),
    porter_id uuid,
    porter_name character varying(60),
    cate_id uuid,
    cate_name character varying(90),
    status character varying(32),
    template_id uuid,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.routes OWNER TO postgres;

--
-- Name: TABLE routes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.routes IS '路线信息';


--
-- Name: COLUMN routes.route_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.route_id IS '路线代码;RR-YYYYMMDD-HHmmSS-RRR';


--
-- Name: COLUMN routes.adcode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.adcode IS '所属区域';


--
-- Name: COLUMN routes.osp_org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.osp_org_id IS '运营组织ID';


--
-- Name: COLUMN routes.csp_org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.csp_org_id IS '清运商组织ID';


--
-- Name: COLUMN routes.job_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.job_date IS '作业日期';


--
-- Name: COLUMN routes.plate_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.plate_number IS '车牌号';


--
-- Name: COLUMN routes.driver_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.driver_id IS '司机ID';


--
-- Name: COLUMN routes.driver_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.driver_name IS '司机名称';


--
-- Name: COLUMN routes.porter_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.porter_id IS '搬运工ID';


--
-- Name: COLUMN routes.porter_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.porter_name IS '搬运工名称';


--
-- Name: COLUMN routes.cate_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.cate_id IS '物料ID';


--
-- Name: COLUMN routes.cate_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.cate_name IS '物料名称';


--
-- Name: COLUMN routes.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.status IS '状态;waiting-进行中, finish-完成';


--
-- Name: COLUMN routes.template_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.template_id IS '使用的模板ID';


--
-- Name: COLUMN routes.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.tenant_id IS '租户号';


--
-- Name: COLUMN routes.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.revision IS '乐观锁';


--
-- Name: COLUMN routes.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.created_by IS '创建人';


--
-- Name: COLUMN routes.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.created_time IS '创建时间';


--
-- Name: COLUMN routes.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.updated_by IS '更新人';


--
-- Name: COLUMN routes.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.routes.updated_time IS '更新时间';


--
-- Name: sim_card; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sim_card (
    iccid character varying(32) NOT NULL,
    msisdn character varying(32),
    carrier character varying(90),
    provider character varying(90),
    packge character varying(255),
    capacity numeric(24,6),
    register_time timestamp(6) without time zone,
    activation_time timestamp(6) without time zone,
    silent_end_time timestamp(6) without time zone,
    device_id character varying(255),
    active boolean DEFAULT true,
    online boolean DEFAULT false,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    remarks character varying(255)
);


ALTER TABLE public.sim_card OWNER TO postgres;

--
-- Name: TABLE sim_card; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sim_card IS '数据卡表';


--
-- Name: COLUMN sim_card.iccid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.iccid IS 'ICCID';


--
-- Name: COLUMN sim_card.msisdn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.msisdn IS 'MSISDN';


--
-- Name: COLUMN sim_card.carrier; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.carrier IS '电信运营商';


--
-- Name: COLUMN sim_card.provider; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.provider IS '服务提供商';


--
-- Name: COLUMN sim_card.packge; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.packge IS '套餐形式';


--
-- Name: COLUMN sim_card.capacity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.capacity IS '套餐流量';


--
-- Name: COLUMN sim_card.register_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.register_time IS '注册时间';


--
-- Name: COLUMN sim_card.activation_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.activation_time IS '激活时间';


--
-- Name: COLUMN sim_card.silent_end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.silent_end_time IS '沉默结束时间';


--
-- Name: COLUMN sim_card.device_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.device_id IS '绑定设备ID';


--
-- Name: COLUMN sim_card.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.active IS 'SIM卡激活状态';


--
-- Name: COLUMN sim_card.online; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.online IS 'SIM卡在线状态';


--
-- Name: COLUMN sim_card.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.tenant_id IS '租户号';


--
-- Name: COLUMN sim_card.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.revision IS '乐观锁';


--
-- Name: COLUMN sim_card.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.created_by IS '创建人';


--
-- Name: COLUMN sim_card.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.created_time IS '创建时间';


--
-- Name: COLUMN sim_card.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.updated_by IS '更新人';


--
-- Name: COLUMN sim_card.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.updated_time IS '更新时间';


--
-- Name: COLUMN sim_card.remarks; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card.remarks IS '备注';


--
-- Name: sim_card_wip; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sim_card_wip (
    iccid character varying(32) NOT NULL,
    msisdn character varying(32),
    carrier character varying(90),
    provider character varying(90),
    packge character varying(255),
    capacity numeric(24,6),
    register_time timestamp(6) without time zone,
    activation_time timestamp(6) without time zone,
    silent_end_time timestamp(6) without time zone,
    device_id character varying(255),
    active boolean DEFAULT true,
    online boolean DEFAULT false,
    service_end_time timestamp(6) without time zone,
    current_usage numeric(24,6),
    current_cycle_begin timestamp(6) without time zone,
    current_cycle_end timestamp(6) without time zone,
    life_cycle smallint,
    net_status smallint,
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.sim_card_wip OWNER TO postgres;

--
-- Name: TABLE sim_card_wip; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sim_card_wip IS '数据卡表';


--
-- Name: COLUMN sim_card_wip.iccid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.iccid IS 'ICCID';


--
-- Name: COLUMN sim_card_wip.msisdn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.msisdn IS 'MSISDN';


--
-- Name: COLUMN sim_card_wip.carrier; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.carrier IS '电信运营商';


--
-- Name: COLUMN sim_card_wip.provider; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.provider IS '服务提供商';


--
-- Name: COLUMN sim_card_wip.packge; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.packge IS '套餐形式';


--
-- Name: COLUMN sim_card_wip.capacity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.capacity IS '套餐流量';


--
-- Name: COLUMN sim_card_wip.register_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.register_time IS '注册时间';


--
-- Name: COLUMN sim_card_wip.activation_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.activation_time IS '激活时间';


--
-- Name: COLUMN sim_card_wip.silent_end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.silent_end_time IS '沉默结束时间';


--
-- Name: COLUMN sim_card_wip.device_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.device_id IS '绑定设备ID';


--
-- Name: COLUMN sim_card_wip.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.active IS 'SIM卡激活状态';


--
-- Name: COLUMN sim_card_wip.online; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.online IS 'SIM卡在线状态';


--
-- Name: COLUMN sim_card_wip.service_end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.service_end_time IS '服务结束时间';


--
-- Name: COLUMN sim_card_wip.current_usage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.current_usage IS '当前用量';


--
-- Name: COLUMN sim_card_wip.current_cycle_begin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.current_cycle_begin IS '当前周期开始时间';


--
-- Name: COLUMN sim_card_wip.current_cycle_end; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.current_cycle_end IS '当前周期结束时间';


--
-- Name: COLUMN sim_card_wip.life_cycle; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.life_cycle IS '生命周期';


--
-- Name: COLUMN sim_card_wip.net_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.net_status IS '网络状态';


--
-- Name: COLUMN sim_card_wip.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.created_by IS '创建者 ';


--
-- Name: COLUMN sim_card_wip.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.created_time IS '创建时间';


--
-- Name: COLUMN sim_card_wip.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.updated_by IS '修改者';


--
-- Name: COLUMN sim_card_wip.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sim_card_wip.updated_time IS '修改时间';


--
-- Name: sites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sites (
    id uuid DEFAULT public.uuid_generate_v4(),
    name character varying(255),
    org_id uuid,
    address character varying(255),
    owner character varying(60),
    tel character varying(20),
    adcode bigint,
    fence public.geometry(geometry,4326),
    active boolean,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.sites OWNER TO postgres;

--
-- Name: TABLE sites; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sites IS '厂区';


--
-- Name: COLUMN sites.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.id IS '厂区ID';


--
-- Name: COLUMN sites.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.name IS '厂区名称';


--
-- Name: COLUMN sites.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.org_id IS '所属组织';


--
-- Name: COLUMN sites.address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.address IS '厂区地址';


--
-- Name: COLUMN sites.owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.owner IS '联系人';


--
-- Name: COLUMN sites.tel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.tel IS '电话';


--
-- Name: COLUMN sites.adcode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.adcode IS '区域代码';


--
-- Name: COLUMN sites.fence; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.fence IS '地理围栏';


--
-- Name: COLUMN sites.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.active IS '有效标志位';


--
-- Name: COLUMN sites.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.tenant_id IS '租户号';


--
-- Name: COLUMN sites.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.revision IS '乐观锁';


--
-- Name: COLUMN sites.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.created_by IS '创建人';


--
-- Name: COLUMN sites.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.created_time IS '创建时间';


--
-- Name: COLUMN sites.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.updated_by IS '更新人';


--
-- Name: COLUMN sites.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sites.updated_time IS '更新时间';


--
-- Name: stations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stations (
    station_id character varying(22),
    route_id character varying(22),
    item_no integer,
    original_item_no integer,
    facility_id uuid,
    req_arrival_time timestamp(6) without time zone,
    act_begin_time timestamp(6) without time zone,
    act_end_time timestamp(6) without time zone,
    act_status character varying(32),
    plan_job_use_time integer,
    job_ids character varying(255),
    job_status character varying(255),
    job_begin_time timestamp(6) without time zone,
    job_end_time timestamp(6) without time zone,
    real_job_use_time timestamp(6) without time zone,
    reason_code character varying(255),
    reason_text character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.stations OWNER TO postgres;

--
-- Name: TABLE stations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.stations IS '站点信息';


--
-- Name: COLUMN stations.station_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.station_id IS '站点ID;格式： RS-YYYYMMDD-hhmmss-rrr';


--
-- Name: COLUMN stations.route_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.route_id IS '路线ID;格式： RR-YYYYMMDD-hhmmss-rrr';


--
-- Name: COLUMN stations.item_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.item_no IS '序号';


--
-- Name: COLUMN stations.original_item_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.original_item_no IS '初始序号';


--
-- Name: COLUMN stations.facility_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.facility_id IS '设施ID';


--
-- Name: COLUMN stations.req_arrival_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.req_arrival_time IS '要求抵达时间';


--
-- Name: COLUMN stations.act_begin_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.act_begin_time IS '出发时间';


--
-- Name: COLUMN stations.act_end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.act_end_time IS '抵达时间';


--
-- Name: COLUMN stations.act_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.act_status IS '行驶状态';


--
-- Name: COLUMN stations.plan_job_use_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.plan_job_use_time IS '计划作业用时';


--
-- Name: COLUMN stations.job_ids; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.job_ids IS '作业列表';


--
-- Name: COLUMN stations.job_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.job_status IS '作业状态';


--
-- Name: COLUMN stations.job_begin_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.job_begin_time IS '作业开始时间';


--
-- Name: COLUMN stations.job_end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.job_end_time IS '作业结束时间';


--
-- Name: COLUMN stations.real_job_use_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.real_job_use_time IS '实际作业用时';


--
-- Name: COLUMN stations.reason_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.reason_code IS '终止原因代码';


--
-- Name: COLUMN stations.reason_text; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.reason_text IS '终止原因';


--
-- Name: COLUMN stations.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.tenant_id IS '租户号';


--
-- Name: COLUMN stations.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.revision IS '乐观锁';


--
-- Name: COLUMN stations.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.created_by IS '创建人';


--
-- Name: COLUMN stations.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.created_time IS '创建时间';


--
-- Name: COLUMN stations.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.updated_by IS '更新人';


--
-- Name: COLUMN stations.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stations.updated_time IS '更新时间';


--
-- Name: trace_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trace_history (
    tem_id character varying(32) NOT NULL,
    time_dims character varying(2) NOT NULL,
    time_val character varying(16) NOT NULL,
    ts_begin timestamp(6) without time zone,
    ts_end timestamp(6) without time zone,
    mileage numeric(24,2),
    use_time integer,
    max_speed integer,
    count integer,
    plate_number character varying(20),
    container_sn character varying(20),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    state character varying(32)
);


ALTER TABLE public.trace_history OWNER TO postgres;

--
-- Name: COLUMN trace_history.tem_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.tem_id IS '终端ID';


--
-- Name: COLUMN trace_history.time_dims; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.time_dims IS '时间颗粒度';


--
-- Name: COLUMN trace_history.time_val; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.time_val IS '时间值';


--
-- Name: COLUMN trace_history.ts_begin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.ts_begin IS '开始时间';


--
-- Name: COLUMN trace_history.ts_end; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.ts_end IS '结束时间';


--
-- Name: COLUMN trace_history.mileage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.mileage IS '总里程，米';


--
-- Name: COLUMN trace_history.use_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.use_time IS '总用时，秒';


--
-- Name: COLUMN trace_history.max_speed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.max_speed IS '最大时速';


--
-- Name: COLUMN trace_history.count; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.count IS '采集点数';


--
-- Name: COLUMN trace_history.plate_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.plate_number IS '车牌';


--
-- Name: COLUMN trace_history.container_sn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.container_sn IS '容器SN';


--
-- Name: COLUMN trace_history.state; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trace_history.state IS '状态： generate 生成 | fill 填充 | bind 绑定| ';


--
-- Name: user_reg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_reg (
    id uuid DEFAULT public.uuid_generate_v4(),
    identity_card_no character varying(32),
    name character varying(90),
    gender character varying(255),
    tel character varying(20),
    org_id uuid,
    role_code character varying(100),
    avatar character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    status public.reg_status DEFAULT 'waiting'::public.reg_status,
    origin character varying(50),
    oid character varying(64),
    memo character varying(255),
    credential json
);


ALTER TABLE public.user_reg OWNER TO postgres;

--
-- Name: TABLE user_reg; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.user_reg IS '用户信息-注册';


--
-- Name: COLUMN user_reg.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.id IS '用户ID';


--
-- Name: COLUMN user_reg.identity_card_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.identity_card_no IS '身份证号';


--
-- Name: COLUMN user_reg.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.name IS '姓名';


--
-- Name: COLUMN user_reg.gender; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.gender IS '性别';


--
-- Name: COLUMN user_reg.tel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.tel IS '手机号';


--
-- Name: COLUMN user_reg.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.org_id IS '所属组织';


--
-- Name: COLUMN user_reg.role_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.role_code IS '所属角色';


--
-- Name: COLUMN user_reg.avatar; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.avatar IS '用户头像';


--
-- Name: COLUMN user_reg.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.tenant_id IS '租户号';


--
-- Name: COLUMN user_reg.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.revision IS '乐观锁';


--
-- Name: COLUMN user_reg.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.created_by IS '创建人';


--
-- Name: COLUMN user_reg.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.created_time IS '创建时间';


--
-- Name: COLUMN user_reg.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.updated_by IS '更新人';


--
-- Name: COLUMN user_reg.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.updated_time IS '更新时间';


--
-- Name: COLUMN user_reg.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.status IS '激活状态';


--
-- Name: COLUMN user_reg.origin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.origin IS '来源';


--
-- Name: COLUMN user_reg.oid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.oid IS '来源ID';


--
-- Name: COLUMN user_reg.credential; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.user_reg.credential IS '附加信息，例如身份证信息，驾驶证信息 等等。';


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4(),
    identity_card_no character varying(32),
    name character varying(60),
    gender character varying(32),
    tel character varying(20),
    org_id uuid,
    role_code character varying(100),
    avatar character varying(255),
    active boolean,
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    origin character varying(50),
    oid character varying(64),
    credential json
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.users IS '用户信息';


--
-- Name: COLUMN users.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.id IS '用户ID';


--
-- Name: COLUMN users.identity_card_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.identity_card_no IS '身份证号';


--
-- Name: COLUMN users.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.name IS '姓名';


--
-- Name: COLUMN users.gender; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.gender IS '性别';


--
-- Name: COLUMN users.tel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.tel IS '手机号';


--
-- Name: COLUMN users.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.org_id IS '所属组织';


--
-- Name: COLUMN users.role_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.role_code IS '所属角色';


--
-- Name: COLUMN users.avatar; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.avatar IS '用户头像';


--
-- Name: COLUMN users.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.active IS '激活状态';


--
-- Name: COLUMN users.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.tenant_id IS '租户号';


--
-- Name: COLUMN users.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.revision IS '乐观锁';


--
-- Name: COLUMN users.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.created_by IS '创建人';


--
-- Name: COLUMN users.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.created_time IS '创建时间';


--
-- Name: COLUMN users.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.updated_by IS '更新人';


--
-- Name: COLUMN users.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.updated_time IS '更新时间';


--
-- Name: COLUMN users.origin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.origin IS '来源';


--
-- Name: COLUMN users.oid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.oid IS '来源ID';


--
-- Name: COLUMN users.credential; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.credential IS '附加信息，例如身份证信息，驾驶证信息 等等。';


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicles (
    vehicle_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    plate_number character varying(32),
    pass_number character varying(32),
    model character varying(32) DEFAULT 'tlat-car'::character varying,
    status character varying(32),
    vehicle_weight numeric(24,6),
    vehicle_load_weight numeric(24,6),
    manufacturer character varying(255),
    license_plate_color character varying(64),
    engine_no character varying(32),
    engine_number character varying(32),
    container_sn character varying(32),
    tem_id character varying(32),
    org_id uuid,
    remark character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    hw_info json,
    unladen_weight numeric(24,6),
    overall_dimension json,
    vehicle_model character varying(32),
    driver character varying(32),
    owner character varying(32),
    approved_seating integer DEFAULT 2,
    credential json
);


ALTER TABLE public.vehicles OWNER TO postgres;

--
-- Name: TABLE vehicles; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.vehicles IS '车辆信息';


--
-- Name: COLUMN vehicles.vehicle_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.vehicle_id IS '车辆ID';


--
-- Name: COLUMN vehicles.plate_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.plate_number IS '车牌号';


--
-- Name: COLUMN vehicles.pass_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.pass_number IS '行驶证';


--
-- Name: COLUMN vehicles.model; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.model IS '车辆类型 ';


--
-- Name: COLUMN vehicles.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.status IS '车辆状态  正常 normal | damaged 已损坏 | 维修中 repairing | 保养 maintain | 已报废 discarded | 停运 shut-down  | 已销售 sold';


--
-- Name: COLUMN vehicles.vehicle_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.vehicle_weight IS '车辆重量（单位：吨）';


--
-- Name: COLUMN vehicles.vehicle_load_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.vehicle_load_weight IS '车辆荷载（单位：吨）';


--
-- Name: COLUMN vehicles.manufacturer; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.manufacturer IS '生产厂家';


--
-- Name: COLUMN vehicles.license_plate_color; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.license_plate_color IS '车辆颜色';


--
-- Name: COLUMN vehicles.engine_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.engine_no IS '发动机号';


--
-- Name: COLUMN vehicles.engine_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.engine_number IS '车架号';


--
-- Name: COLUMN vehicles.container_sn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.container_sn IS '车厢编号';


--
-- Name: COLUMN vehicles.tem_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.tem_id IS '终端号';


--
-- Name: COLUMN vehicles.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.org_id IS '所属组织';


--
-- Name: COLUMN vehicles.remark; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.remark IS '备注';


--
-- Name: COLUMN vehicles.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.tenant_id IS '租户号';


--
-- Name: COLUMN vehicles.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.revision IS '乐观锁';


--
-- Name: COLUMN vehicles.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.created_by IS '创建人';


--
-- Name: COLUMN vehicles.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.created_time IS '创建时间';


--
-- Name: COLUMN vehicles.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.updated_by IS '更新人';


--
-- Name: COLUMN vehicles.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.updated_time IS '更新时间';


--
-- Name: COLUMN vehicles.unladen_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.unladen_weight IS '整备质量';


--
-- Name: COLUMN vehicles.overall_dimension; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.overall_dimension IS '外廓尺寸';


--
-- Name: COLUMN vehicles.vehicle_model; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.vehicle_model IS '品牌型号';


--
-- Name: COLUMN vehicles.driver; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.driver IS '司机';


--
-- Name: COLUMN vehicles.owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.owner IS '所有人';


--
-- Name: COLUMN vehicles.approved_seating; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.approved_seating IS '核定载人数';


--
-- Name: COLUMN vehicles.credential; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehicles.credential IS '证件信息';


--
-- Name: work_task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_task (
    id uuid,
    parent_id uuid,
    org_id uuid,
    req_type character varying(255),
    req_arrival_time timestamp(6) without time zone,
    facility_id uuid,
    cate_type character varying(32),
    container_type character varying(32),
    forecast_container_qty integer,
    forecast_weight numeric(24,6),
    status character varying(255),
    begin_time timestamp(6) without time zone,
    end_time timestamp(6) without time zone,
    reason_code character varying(255),
    reason_text character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.work_task OWNER TO postgres;

--
-- Name: TABLE work_task; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.work_task IS '作业任务';


--
-- Name: COLUMN work_task.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.id IS '任务ID';


--
-- Name: COLUMN work_task.parent_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.parent_id IS '父任务ID';


--
-- Name: COLUMN work_task.org_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.org_id IS '任务来源组织ID';


--
-- Name: COLUMN work_task.req_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.req_type IS '任务类型';


--
-- Name: COLUMN work_task.req_arrival_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.req_arrival_time IS '要求抵达时间';


--
-- Name: COLUMN work_task.facility_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.facility_id IS '要求抵达站点';


--
-- Name: COLUMN work_task.cate_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.cate_type IS '品类';


--
-- Name: COLUMN work_task.container_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.container_type IS '容器类型';


--
-- Name: COLUMN work_task.forecast_container_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.forecast_container_qty IS '预测容器数量';


--
-- Name: COLUMN work_task.forecast_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.forecast_weight IS '预测重量';


--
-- Name: COLUMN work_task.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.status IS '状态';


--
-- Name: COLUMN work_task.begin_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.begin_time IS '开始作业时间';


--
-- Name: COLUMN work_task.end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.end_time IS '结束作业时间';


--
-- Name: COLUMN work_task.reason_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.reason_code IS '终止原因代码';


--
-- Name: COLUMN work_task.reason_text; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.reason_text IS '终止原因描述';


--
-- Name: COLUMN work_task.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.tenant_id IS '租户号';


--
-- Name: COLUMN work_task.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.revision IS '乐观锁';


--
-- Name: COLUMN work_task.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.created_by IS '创建人';


--
-- Name: COLUMN work_task.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.created_time IS '创建时间';


--
-- Name: COLUMN work_task.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.updated_by IS '更新人';


--
-- Name: COLUMN work_task.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task.updated_time IS '更新时间';


--
-- Name: work_task_detail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_task_detail (
    task_id uuid,
    ts integer,
    sn character varying(32),
    cate_id character varying(255),
    cate_name character varying(255),
    net_weight numeric(24,6),
    tare_weight numeric(24,6),
    price numeric(24,6),
    amount numeric(24,6),
    action character varying(255),
    status character varying(255),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone
);


ALTER TABLE public.work_task_detail OWNER TO postgres;

--
-- Name: TABLE work_task_detail; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.work_task_detail IS '作业任务明细表';


--
-- Name: COLUMN work_task_detail.task_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.task_id IS '任务需求ID';


--
-- Name: COLUMN work_task_detail.ts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.ts IS '作业时间';


--
-- Name: COLUMN work_task_detail.sn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.sn IS '容器ID';


--
-- Name: COLUMN work_task_detail.cate_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.cate_id IS '品类ID';


--
-- Name: COLUMN work_task_detail.cate_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.cate_name IS '品类名称';


--
-- Name: COLUMN work_task_detail.net_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.net_weight IS '净重';


--
-- Name: COLUMN work_task_detail.tare_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.tare_weight IS '皮重';


--
-- Name: COLUMN work_task_detail.price; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.price IS '单价';


--
-- Name: COLUMN work_task_detail.amount; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.amount IS '金额';


--
-- Name: COLUMN work_task_detail.action; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.action IS '动作';


--
-- Name: COLUMN work_task_detail.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.status IS '状态';


--
-- Name: COLUMN work_task_detail.tenant_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.tenant_id IS '租户号';


--
-- Name: COLUMN work_task_detail.revision; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.revision IS '乐观锁';


--
-- Name: COLUMN work_task_detail.created_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.created_by IS '创建人';


--
-- Name: COLUMN work_task_detail.created_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.created_time IS '创建时间';


--
-- Name: COLUMN work_task_detail.updated_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.updated_by IS '更新人';


--
-- Name: COLUMN work_task_detail.updated_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_task_detail.updated_time IS '更新时间';


--
-- Name: devices; Type: TABLE; Schema: stations; Owner: postgres
--

CREATE TABLE stations.devices (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(50) NOT NULL,
    type character varying(20),
    usage character varying(30),
    model character varying(100),
    manufacture character varying(100),
    data_unit character varying(10),
    config_params json,
    status boolean,
    created_by character varying(50),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_time timestamp(6) without time zone
);


ALTER TABLE stations.devices OWNER TO postgres;

--
-- Name: COLUMN devices.name; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.devices.name IS '硬件设备名称';


--
-- Name: COLUMN devices.type; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.devices.type IS '硬件设备类型';


--
-- Name: COLUMN devices.usage; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.devices.usage IS '用途';


--
-- Name: COLUMN devices.model; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.devices.model IS '型号';


--
-- Name: COLUMN devices.manufacture; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.devices.manufacture IS '厂家';


--
-- Name: COLUMN devices.data_unit; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.devices.data_unit IS '数据单位';


--
-- Name: COLUMN devices.config_params; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.devices.config_params IS '配置参数';


--
-- Name: COLUMN devices.status; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.devices.status IS '状态';


--
-- Name: model; Type: TABLE; Schema: stations; Owner: postgres
--

CREATE TABLE stations.model (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255),
    station_type character varying(255),
    config json,
    created_by character varying(50),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_time timestamp(6) without time zone,
    status boolean DEFAULT true
);


ALTER TABLE stations.model OWNER TO postgres;

--
-- Name: COLUMN model.id; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.model.id IS '工站模板ID';


--
-- Name: COLUMN model.name; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.model.name IS '工站模板名称';


--
-- Name: COLUMN model.station_type; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.model.station_type IS '工站类型';


--
-- Name: COLUMN model.config; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.model.config IS '配置信息';


--
-- Name: COLUMN model.status; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.model.status IS '状态';


--
-- Name: print_jobs; Type: TABLE; Schema: stations; Owner: postgres
--

CREATE TABLE stations.print_jobs (
    name character varying(255),
    data text,
    status character varying(20) DEFAULT 'ready'::character varying,
    printer character varying(50),
    owner character varying(50),
    execute_log character varying(255),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    id uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE stations.print_jobs OWNER TO postgres;

--
-- Name: COLUMN print_jobs.name; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.print_jobs.name IS '任务名称';


--
-- Name: COLUMN print_jobs.data; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.print_jobs.data IS '打印数据';


--
-- Name: COLUMN print_jobs.status; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.print_jobs.status IS '执行状态

ready 准备中 | processing 执行中 | success 执行成功 | failure 执行失败
';


--
-- Name: COLUMN print_jobs.printer; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.print_jobs.printer IS '指派打印机';


--
-- Name: COLUMN print_jobs.owner; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.print_jobs.owner IS '打印者';


--
-- Name: COLUMN print_jobs.execute_log; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.print_jobs.execute_log IS '执行日志';


--
-- Name: COLUMN print_jobs.created_by; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.print_jobs.created_by IS '创建人';


--
-- Name: COLUMN print_jobs.created_time; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.print_jobs.created_time IS '创建时间';


--
-- Name: COLUMN print_jobs.updated_by; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.print_jobs.updated_by IS '更新人';


--
-- Name: COLUMN print_jobs.updated_time; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.print_jobs.updated_time IS '更新时间';


--
-- Name: station_reg; Type: TABLE; Schema: stations; Owner: postgres
--

CREATE TABLE stations.station_reg (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    device_sn character varying(255),
    device_model character varying(255),
    devices json,
    station_type character varying(50),
    register_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    status public.reg_status DEFAULT 'waiting'::public.reg_status
);


ALTER TABLE stations.station_reg OWNER TO postgres;

--
-- Name: COLUMN station_reg.device_sn; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.station_reg.device_sn IS '自注册设备SN';


--
-- Name: COLUMN station_reg.device_model; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.station_reg.device_model IS '设备类型';


--
-- Name: COLUMN station_reg.devices; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.station_reg.devices IS '工站的硬件设备信息';


--
-- Name: COLUMN station_reg.station_type; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.station_reg.station_type IS '工站类型';


--
-- Name: COLUMN station_reg.register_time; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.station_reg.register_time IS '自注册时间';


--
-- Name: COLUMN station_reg.created_by; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.station_reg.created_by IS '创建人';


--
-- Name: COLUMN station_reg.created_time; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.station_reg.created_time IS '创建时间';


--
-- Name: COLUMN station_reg.updated_by; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.station_reg.updated_by IS '更新人';


--
-- Name: COLUMN station_reg.updated_time; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.station_reg.updated_time IS '更新时间';


--
-- Name: stations; Type: TABLE; Schema: stations; Owner: postgres
--

CREATE TABLE stations.stations (
    code character varying(50) NOT NULL,
    device_sn character varying(50),
    device_model character varying(50),
    direction character varying(50),
    name character varying(100),
    type character varying(50),
    status boolean DEFAULT true,
    version character varying(100),
    devices json,
    curr_org_id uuid,
    curr_site_id uuid,
    curr_facility_id uuid,
    curr_owner character varying(60),
    curr_plate_number character varying(32),
    tenant_id character varying(32),
    revision character varying(32),
    created_by character varying(32),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(32),
    updated_time timestamp(6) without time zone,
    item_no integer,
    ref_model_id uuid
);


ALTER TABLE stations.stations OWNER TO postgres;

--
-- Name: COLUMN stations.code; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.code IS '工站ID';


--
-- Name: COLUMN stations.device_sn; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.device_sn IS '设备唯一序列号';


--
-- Name: COLUMN stations.device_model; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.device_model IS '工站设备型号';


--
-- Name: COLUMN stations.direction; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.direction IS '屏幕朝向（normal，right，left）';


--
-- Name: COLUMN stations.name; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.name IS '工站名称';


--
-- Name: COLUMN stations.type; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.type IS '工站类型';


--
-- Name: COLUMN stations.status; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.status IS '状态';


--
-- Name: COLUMN stations.version; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.version IS '软件版本';


--
-- Name: COLUMN stations.devices; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.devices IS '硬件设备列表';


--
-- Name: COLUMN stations.curr_org_id; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.curr_org_id IS '当前所在组织';


--
-- Name: COLUMN stations.curr_site_id; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.curr_site_id IS '当前所在厂区';


--
-- Name: COLUMN stations.curr_facility_id; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.curr_facility_id IS '当前所在站点';


--
-- Name: COLUMN stations.curr_owner; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.curr_owner IS '当前拥有者';


--
-- Name: COLUMN stations.curr_plate_number; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.curr_plate_number IS '当前所在车牌';


--
-- Name: COLUMN stations.tenant_id; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.tenant_id IS '租户号';


--
-- Name: COLUMN stations.revision; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.revision IS '乐观锁';


--
-- Name: COLUMN stations.created_by; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.created_by IS '创建人';


--
-- Name: COLUMN stations.created_time; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.created_time IS '创建时间';


--
-- Name: COLUMN stations.updated_by; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.updated_by IS '更新人';


--
-- Name: COLUMN stations.updated_time; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.updated_time IS '更新时间';


--
-- Name: COLUMN stations.item_no; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.item_no IS '顺序号';


--
-- Name: COLUMN stations.ref_model_id; Type: COMMENT; Schema: stations; Owner: postgres
--

COMMENT ON COLUMN stations.stations.ref_model_id IS '引用的工站模板ID';


--
-- Name: kanban; Type: TABLE; Schema: vi; Owner: postgres
--

CREATE TABLE vi.kanban (
    code character varying(100),
    name character varying(255),
    state character varying(50),
    "time-dims" character varying(10),
    roles json,
    created_by character varying(20),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(20),
    updated_time timestamp(6) without time zone
);


ALTER TABLE vi.kanban OWNER TO postgres;

--
-- Name: kanban_events; Type: TABLE; Schema: vi; Owner: postgres
--

CREATE TABLE vi.kanban_events (
    kanban_code character varying(100) NOT NULL,
    module_code character varying(100) NOT NULL,
    module_name character varying(255),
    object character varying(50) NOT NULL,
    action character varying(50),
    form character varying(50),
    target character varying(1024),
    target_info json,
    params json,
    req_params json,
    created_by character varying(20),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(20),
    updated_time timestamp(6) without time zone,
    roles json
);


ALTER TABLE vi.kanban_events OWNER TO postgres;

--
-- Name: COLUMN kanban_events.kanban_code; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.kanban_events.kanban_code IS '看板ID';


--
-- Name: COLUMN kanban_events.module_code; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.kanban_events.module_code IS '模块ID';


--
-- Name: COLUMN kanban_events.module_name; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.kanban_events.module_name IS '模块名称';


--
-- Name: COLUMN kanban_events.object; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.kanban_events.object IS '事件对象';


--
-- Name: COLUMN kanban_events.action; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.kanban_events.action IS '事件动作';


--
-- Name: COLUMN kanban_events.form; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.kanban_events.form IS '跳转方式';


--
-- Name: COLUMN kanban_events.target; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.kanban_events.target IS '目标';


--
-- Name: COLUMN kanban_events.target_info; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.kanban_events.target_info IS '目标信息';


--
-- Name: COLUMN kanban_events.params; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.kanban_events.params IS '跳转参数';


--
-- Name: COLUMN kanban_events.req_params; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.kanban_events.req_params IS '请求参数';


--
-- Name: portal; Type: TABLE; Schema: vi; Owner: postgres
--

CREATE TABLE vi.portal (
    id integer NOT NULL,
    "group" character varying(100),
    icon character varying(100),
    title character varying(100),
    url character varying(1024),
    item_no integer,
    level integer,
    active boolean DEFAULT true
);


ALTER TABLE vi.portal OWNER TO postgres;

--
-- Name: portal_id_seq; Type: SEQUENCE; Schema: vi; Owner: postgres
--

ALTER TABLE vi.portal ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vi.portal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: spi_index_level; Type: TABLE; Schema: vi; Owner: postgres
--

CREATE TABLE vi.spi_index_level (
    id integer NOT NULL,
    name text,
    props json,
    remarks text
);


ALTER TABLE vi.spi_index_level OWNER TO postgres;

--
-- Name: spi_index_level_id_seq; Type: SEQUENCE; Schema: vi; Owner: postgres
--

ALTER TABLE vi.spi_index_level ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vi.spi_index_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: template_orgs; Type: TABLE; Schema: vi; Owner: postgres
--

CREATE TABLE vi.template_orgs (
    tid uuid DEFAULT public.uuid_generate_v4(),
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100),
    type character varying(100),
    "internal-type" character varying(100),
    "oper-state" character varying(100),
    "bussiness-scope" character varying(100),
    address json,
    location json,
    "service-scope" character varying(100),
    "service-radius" character varying(100),
    hidden boolean DEFAULT true,
    item_no integer,
    zoom real DEFAULT 1,
    "fake-location" json,
    "has-warehouse" boolean DEFAULT false,
    created_by character varying(20),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(20),
    updated_time timestamp(6) without time zone
);


ALTER TABLE vi.template_orgs OWNER TO postgres;

--
-- Name: COLUMN template_orgs.tid; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs.tid IS '模板ID';


--
-- Name: COLUMN template_orgs.name; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs.name IS '组织名称';


--
-- Name: COLUMN template_orgs.type; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs.type IS '类型';


--
-- Name: COLUMN template_orgs."internal-type"; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs."internal-type" IS '内部组织类型';


--
-- Name: COLUMN template_orgs."oper-state"; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs."oper-state" IS '营业状态';


--
-- Name: COLUMN template_orgs."bussiness-scope"; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs."bussiness-scope" IS '业务类型';


--
-- Name: COLUMN template_orgs.address; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs.address IS '地址';


--
-- Name: COLUMN template_orgs.location; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs.location IS '定位';


--
-- Name: COLUMN template_orgs."service-scope"; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs."service-scope" IS '服务范围';


--
-- Name: COLUMN template_orgs."service-radius"; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs."service-radius" IS '服务半径';


--
-- Name: COLUMN template_orgs.hidden; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs.hidden IS '是否隐藏';


--
-- Name: COLUMN template_orgs.item_no; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs.item_no IS '在列表中的顺序号';


--
-- Name: COLUMN template_orgs.zoom; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs.zoom IS '地图放大系数';


--
-- Name: COLUMN template_orgs."has-warehouse"; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_orgs."has-warehouse" IS '是否有仓库';


--
-- Name: template_rels; Type: TABLE; Schema: vi; Owner: postgres
--

CREATE TABLE vi.template_rels (
    tid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    source uuid,
    destination uuid,
    direction character varying(20) DEFAULT 'go'::character varying,
    style json DEFAULT ' { "arrow": "normal",
   "line": "normal"}'::json,
    item_no integer,
    created_by character varying(20),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(20),
    updated_time timestamp(6) without time zone
);


ALTER TABLE vi.template_rels OWNER TO postgres;

--
-- Name: COLUMN template_rels.tid; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_rels.tid IS '模板ID';


--
-- Name: COLUMN template_rels.source; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_rels.source IS '来源';


--
-- Name: COLUMN template_rels.destination; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_rels.destination IS '目的地';


--
-- Name: COLUMN template_rels.direction; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_rels.direction IS '方向';


--
-- Name: COLUMN template_rels.style; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_rels.style IS '样式';


--
-- Name: COLUMN template_rels.item_no; Type: COMMENT; Schema: vi; Owner: postgres
--

COMMENT ON COLUMN vi.template_rels.item_no IS '顺序号';


--
-- Name: templates; Type: TABLE; Schema: vi; Owner: postgres
--

CREATE TABLE vi.templates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100),
    state character varying(20) DEFAULT 'draft'::character varying,
    created_by character varying(20),
    created_time timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(20),
    updated_time timestamp(6) without time zone
);


ALTER TABLE vi.templates OWNER TO postgres;

--
-- Name: futures_audit_log futures_audit_log_pkey; Type: CONSTRAINT; Schema: cate; Owner: tom
--

ALTER TABLE ONLY cate.futures_audit_log
    ADD CONSTRAINT futures_audit_log_pkey PRIMARY KEY (parent_id, item_no);


--
-- Name: futures_quote_history futures_quote_history_pkey; Type: CONSTRAINT; Schema: cate; Owner: tom
--

ALTER TABLE ONLY cate.futures_quote_history
    ADD CONSTRAINT futures_quote_history_pkey PRIMARY KEY (trading_day, instrument_id, exchange_code);


--
-- Name: adcode adcode_pkey; Type: CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.adcode
    ADD CONSTRAINT adcode_pkey PRIMARY KEY (code);


--
-- Name: fences fences_pkey; Type: CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.fences
    ADD CONSTRAINT fences_pkey PRIMARY KEY (code);


--
-- Name: cameras cameras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cameras
    ADD CONSTRAINT cameras_pkey PRIMARY KEY (id);


--
-- Name: casbin_rules casbin_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.casbin_rules
    ADD CONSTRAINT casbin_rules_pkey PRIMARY KEY (id);


--
-- Name: dept dept_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dept
    ADD CONSTRAINT dept_pkey PRIMARY KEY (origin, agent_id, dept_id);


--
-- Name: dept_user_rel dept_user_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dept_user_rel
    ADD CONSTRAINT dept_user_rel_pkey PRIMARY KEY (dept_id, union_id, user_id);


--
-- Name: dict dict_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dict
    ADD CONSTRAINT dict_pkey PRIMARY KEY (id);


--
-- Name: equipments equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_pkey PRIMARY KEY (code);


--
-- Name: iot_devices iot_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.iot_devices
    ADD CONSTRAINT iot_devices_pkey PRIMARY KEY (sn);


--
-- Name: iot_devices_wip iot_devices_wip_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.iot_devices_wip
    ADD CONSTRAINT iot_devices_wip_pkey PRIMARY KEY (sn);


--
-- Name: new_discover new_discover_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.new_discover
    ADD CONSTRAINT new_discover_pkey PRIMARY KEY (hz);


--
-- Name: sim_card_wip sim_card_copy1_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_card_wip
    ADD CONSTRAINT sim_card_copy1_pkey PRIMARY KEY (iccid);


--
-- Name: sim_card sim_card_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_card
    ADD CONSTRAINT sim_card_pkey PRIMARY KEY (iccid);


--
-- Name: trace_history trace_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trace_history
    ADD CONSTRAINT trace_history_pkey PRIMARY KEY (tem_id, time_dims, time_val);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);


--
-- Name: containers xt; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.containers
    ADD CONSTRAINT xt UNIQUE (sn);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: stations; Owner: postgres
--

ALTER TABLE ONLY stations.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: model model_pkey; Type: CONSTRAINT; Schema: stations; Owner: postgres
--

ALTER TABLE ONLY stations.model
    ADD CONSTRAINT model_pkey PRIMARY KEY (id);


--
-- Name: station_reg station_reg_pkey; Type: CONSTRAINT; Schema: stations; Owner: postgres
--

ALTER TABLE ONLY stations.station_reg
    ADD CONSTRAINT station_reg_pkey PRIMARY KEY (id);


--
-- Name: stations stations_pkey; Type: CONSTRAINT; Schema: stations; Owner: postgres
--

ALTER TABLE ONLY stations.stations
    ADD CONSTRAINT stations_pkey PRIMARY KEY (code);


--
-- Name: kanban_events kanban_events_pkey; Type: CONSTRAINT; Schema: vi; Owner: postgres
--

ALTER TABLE ONLY vi.kanban_events
    ADD CONSTRAINT kanban_events_pkey PRIMARY KEY (kanban_code, module_code, object);


--
-- Name: portal portal_pkey; Type: CONSTRAINT; Schema: vi; Owner: postgres
--

ALTER TABLE ONLY vi.portal
    ADD CONSTRAINT portal_pkey PRIMARY KEY (id);


--
-- Name: spi_index_level spi_index_level_pkey; Type: CONSTRAINT; Schema: vi; Owner: postgres
--

ALTER TABLE ONLY vi.spi_index_level
    ADD CONSTRAINT spi_index_level_pkey PRIMARY KEY (id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: vi; Owner: postgres
--

ALTER TABLE ONLY vi.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: adcode_adcode_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX adcode_adcode_idx ON gis.adcode USING btree (adcode);


--
-- Name: adcode_center_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX adcode_center_idx ON gis.adcode USING gist (center);


--
-- Name: adcode_code_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX adcode_code_idx ON gis.adcode USING btree (((code)::text));


--
-- Name: adcode_name_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX adcode_name_idx ON gis.adcode USING btree (name);


--
-- Name: adcode_parent_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX adcode_parent_idx ON gis.adcode USING btree (parent);


--
-- Name: adcode_rank_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX adcode_rank_idx ON gis.adcode USING btree (rank);


--
-- Name: fences_adcode_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX fences_adcode_idx ON gis.fences USING btree (adcode);


--
-- Name: fences_code_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX fences_code_idx ON gis.fences USING btree (((code)::text));


--
-- Name: fences_fence_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX fences_fence_idx ON gis.fences USING gist (fence);


--
-- Name: idx_pinyin_hz; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pinyin_hz ON public.pinyin USING btree (hz);


--
-- Name: transfer upd_time_by_tans_bill; Type: TRIGGER; Schema: bills; Owner: postgres
--

CREATE TRIGGER upd_time_by_tans_bill BEFORE UPDATE ON bills.transfer FOR EACH ROW EXECUTE FUNCTION bills.update_timestamp();


--
-- Name: futures_audit_log upd_time_by_audit; Type: TRIGGER; Schema: cate; Owner: tom
--

CREATE TRIGGER upd_time_by_audit BEFORE UPDATE ON cate.futures_audit_log FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: pre_price_clac_rules upd_time_by_rule; Type: TRIGGER; Schema: cate; Owner: tom
--

CREATE TRIGGER upd_time_by_rule BEFORE UPDATE ON cate.pre_price_clac_rules FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: futures_quote_history upd_time_by_tongprice; Type: TRIGGER; Schema: cate; Owner: tom
--

CREATE TRIGGER upd_time_by_tongprice BEFORE UPDATE ON cate.futures_quote_history FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: cameras upd_time_by_cameras; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_cameras BEFORE UPDATE ON public.cameras FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: container_wip upd_time_by_con_wip; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_con_wip BEFORE UPDATE ON public.container_wip FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: containers upd_time_by_containers; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_containers BEFORE UPDATE ON public.containers FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: dept upd_time_by_dept; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_dept BEFORE UPDATE ON public.dept FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: dept_user_rel upd_time_by_dept_user_rel; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_dept_user_rel BEFORE UPDATE ON public.dept_user_rel FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: equipments upd_time_by_equ; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_equ BEFORE UPDATE ON public.equipments FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: facilitys upd_time_by_fac; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_fac BEFORE UPDATE ON public.facilitys FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: iot_devices upd_time_by_iot_dev; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_iot_dev BEFORE UPDATE ON public.iot_devices FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: iot_devices_wip upd_time_by_iot_dev_wip; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_iot_dev_wip BEFORE UPDATE ON public.iot_devices_wip FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: organizations upd_time_by_org; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_org BEFORE UPDATE ON public.organizations FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: organization_reg upd_time_by_org_reg; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_org_reg BEFORE UPDATE ON public.organization_reg FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: organization_rel upd_time_by_org_rel; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_org_rel BEFORE UPDATE ON public.organization_rel FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: routes upd_time_by_routes; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_routes BEFORE UPDATE ON public.routes FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: sim_card upd_time_by_sim; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_sim BEFORE UPDATE ON public.sim_card FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: sim_card_wip upd_time_by_sim_wip; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_sim_wip BEFORE UPDATE ON public.sim_card_wip FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: sites upd_time_by_sites; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_sites BEFORE UPDATE ON public.sites FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: stations upd_time_by_stations; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_stations BEFORE UPDATE ON public.stations FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: trace_history upd_time_by_trace_his; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_trace_his BEFORE UPDATE ON public.trace_history FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: user_reg upd_time_by_user_reg; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_user_reg BEFORE UPDATE ON public.user_reg FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: users upd_time_by_users; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_users BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: vehicles upd_time_by_veh; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER upd_time_by_veh BEFORE UPDATE ON public.vehicles FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: devices upd_time_by_station_dev; Type: TRIGGER; Schema: stations; Owner: postgres
--

CREATE TRIGGER upd_time_by_station_dev BEFORE UPDATE ON stations.devices FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: model upd_time_by_station_model; Type: TRIGGER; Schema: stations; Owner: postgres
--

CREATE TRIGGER upd_time_by_station_model BEFORE UPDATE ON stations.model FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: station_reg update_time_by_st_reg; Type: TRIGGER; Schema: stations; Owner: postgres
--

CREATE TRIGGER update_time_by_st_reg BEFORE UPDATE ON stations.station_reg FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- PostgreSQL database dump complete
--

