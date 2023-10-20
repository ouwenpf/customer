DROP PROCEDURE IF EXISTS "test_lvhuan"."insertStockHistory";

CREATE PROCEDURE "test_lvhuan"."insertStockHistory"() 
LANGUAGE plpgsql AS $$
BEGIN
insert into Accoding_stock_history 
SELECT "base"."FRelateBrID" AS "FRelateBrID", "base"."FStockID" AS "FStockID", "base"."FItemID" AS "FItemID"
, round(SUM(COALESCE("base"."FDCQty", 0)), 1) AS "FDCQty"
, round(SUM(COALESCE("base"."FSCQty", 0)), 1) AS "FSCQty"
, '0' AS "FdifQty"
, date_format(concat("base"."FDCTime", ' 23:59:59'), '%Y-%m-%d %H:%i:%s') AS "FDCTime"
FROM (
    SELECT uct_waste_warehouse.branch_id AS "FRelateBrID", concat('LH', uct_waste_warehouse.id) AS "FStockID", "Trans_assist_table"."FItemID" AS "FItemID"
        , CASE "Trans_main_table"."FTranType"
            WHEN 'SOR' THEN "Trans_assist_table"."FQty"
            ELSE 0
        END AS "FDCQty"
        , CASE "Trans_main_table"."FTranType"
            WHEN 'SEL' THEN "Trans_assist_table"."FQty"
            ELSE 0
        END AS "FSCQty", date_format("Trans_assist_table"."FDCTime", '%Y-%m-%d') AS "FDCTime"
    FROM "Trans_assist_table"
        JOIN "Trans_main_table"
        JOIN uct_waste_cate
        JOIN uct_waste_warehouse
    WHERE ("Trans_assist_table"."FinterID" = "Trans_main_table"."FInterID")
        AND ("Trans_assist_table"."FTranType" = "Trans_main_table"."FTranType")
        AND ("Trans_main_table"."FSaleStyle" <> 1)
        AND ("Trans_main_table"."FCancellation" = 1)
        AND uct_waste_cate.id = Trans_assist_table.FItemID
        AND uct_waste_cate.branch_id = uct_waste_warehouse.branch_id
        AND uct_waste_warehouse.parent_id = 0
        AND uct_waste_warehouse.state = 1
        AND (date_format("Trans_assist_table"."FDCTime", '%Y-%m-%d') = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY) or date_format("Trans_assist_table"."red_ink_time", '%Y-%m-%d') = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY))
) "base"
GROUP BY "base"."FStockID", "base"."FItemID", "base"."FDCTime"
HAVING "base"."FStockID" IS NOT NULL
UNION ALL
SELECT "uct_cate_account"."branch_id" AS "FRelateBrID", concat('LH', "uct_cate_account"."warehouse_id") AS "FStockID", "uct_cate_account"."cate_id" AS "FItemID"
, '0' AS "FDCQty", '0' AS "FSCQty", "uct_cate_account"."before_account_num" - "uct_cate_account"."account_num" AS "FdifQty"
, concat(date_format(from_unixtime("uct_cate_account"."createtime"), '%Y-%m-%d'), ' 23:59:59') AS "FDCTime"
FROM "uct_cate_account"
WHERE date_format(from_unixtime("uct_cate_account"."createtime"), '%Y-%m-%d') = DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY);


END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."p_accoding_stock_report";

CREATE PROCEDURE "test_lvhuan"."p_accoding_stock_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
insert into Accoding_stock_iod_table   select * from Accoding_stock_iod where FDCTime =  TO_CHAR(now(),'%Y-%m-%d');
commit;

END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."p_constitute_forCustomer_report";

CREATE PROCEDURE "test_lvhuan"."p_constitute_forCustomer_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
insert into Trans_constitute_forCustomer_table select * from Trans_constitute_forCustomer;
commit;

END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."p_forCustomer_report";

CREATE PROCEDURE "test_lvhuan"."p_forCustomer_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
insert into Trans_forCustomer_table select * from Trans_forCustomer;
commit;

END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."p_INVforDep_day_report";

CREATE PROCEDURE "test_lvhuan"."p_INVforDep_day_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
delete from Trans_daily_INVforDep_table;
insert into Trans_daily_INVforDep_table select * from Trans_daily_INVforDep;
commit;

END; $$;

DROP PROCEDURE IF EXISTS "test_lvhuan"."p_INVforDep_month_report";

CREATE PROCEDURE "test_lvhuan"."p_INVforDep_month_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
insert into Trans_month_INVforDep_table select * from Trans_month_INVforDep;
commit;

END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."p_profit_day_report";

CREATE PROCEDURE "test_lvhuan"."p_profit_day_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
delete from Trans_daily_WH_profit_table;
insert into Trans_daily_WH_profit_table select * from Trans_daily_WH_profit;
commit;

END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."p_profit_month_report";

CREATE PROCEDURE "test_lvhuan"."p_profit_month_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
insert into Trans_month_WH_profit_table select * from Trans_month_WH_profit;
commit;

END; $$;

DROP PROCEDURE IF EXISTS "test_lvhuan"."p_purchase_day_report";

CREATE PROCEDURE "test_lvhuan"."p_purchase_day_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
delete from Trans_daily_SOR_table;
insert into Trans_daily_SOR_table select * from Trans_daily_SOR;
commit;

END; $$;

DROP PROCEDURE IF EXISTS "test_lvhuan"."p_purchase_month_report";

CREATE PROCEDURE "test_lvhuan"."p_purchase_month_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
insert into Trans_month_SOR_table select * from Trans_month_SOR;
commit;

END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."p_sel_day_report";

CREATE PROCEDURE "test_lvhuan"."p_sel_day_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
delete from Trans_daily_SEL_table;
insert into Trans_daily_SEL_table select * from Trans_daily_SEL;
commit;

END; $$;

DROP PROCEDURE IF EXISTS "test_lvhuan"."p_sel_month_report";

CREATE PROCEDURE "test_lvhuan"."p_sel_month_report"() 
LANGUAGE plpgsql AS $$
BEGIN

start transaction;
insert into Trans_month_SEL_table select * from Trans_month_SEL;
commit;

END; $$;

DROP PROCEDURE IF EXISTS "test_lvhuan"."p_sel_rank_month_report";

CREATE PROCEDURE "test_lvhuan"."p_sel_rank_month_report"() 
LANGUAGE plpgsql AS $$
BEGIN
start transaction;
insert into Trans_month_SEL_rank_table select * from Trans_month_SEL_rank;
commit;

END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."test_proc";

CREATE PROCEDURE "test_lvhuan"."test_proc"(IN "region_type" varchar(50)) 
LANGUAGE plpgsql AS $$
BEGIN
  

END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."updateStockHistory";

CREATE PROCEDURE "test_lvhuan"."updateStockHistory"(in branch_id int,in centre_branch_id int,in warehouse_id varchar(10),in cate_id int,in sort_time varchar(30)) 
LANGUAGE plpgsql AS $$
BEGIN


delete from Accoding_stock_history where FRelateBrID = centre_branch_id and FStockID = warehouse_id and FItemID = cate_id and FDCTime = date_format(sort_time, '%Y-%m-%d 23:59:59') and FdifQty = 0; 

insert into Accoding_stock_history SELECT "base"."FRelateBrID" AS "FRelateBrID", "base"."FStockID" AS "FStockID", "base"."FItemID" AS "FItemID"
, round(SUM(COALESCE("base"."FDCQty", 0)), 1) AS "FDCQty"
, round(SUM(COALESCE("base"."FSCQty", 0)), 1) AS "FSCQty"
, '0' AS "FdifQty"
, date_format(concat("base"."FDCTime", ' 23:59:59'), '%Y-%m-%d %H:%i:%s') AS "FDCTime"
FROM (
SELECT centre_branch_id AS "FRelateBrID"
, CASE "Trans_main_table"."FTranType"
WHEN 'SOR' THEN "Trans_main_table"."FDCStockID"
WHEN 'SEL' THEN "Trans_main_table"."FSCStockID"
ELSE NULL
END AS "FStockID", "Trans_assist_table"."FItemID" AS "FItemID"
, CASE "Trans_main_table"."FTranType"
WHEN 'SOR' THEN "Trans_assist_table"."FQty"
ELSE 0
END AS "FDCQty"
, CASE "Trans_main_table"."FTranType"
WHEN 'SEL' THEN "Trans_assist_table"."FQty"
ELSE 0
END AS "FSCQty", date_format("Trans_assist_table"."FDCTime", '%Y-%m-%d') AS "FDCTime"
FROM "Trans_assist_table"
JOIN "Trans_main_table"
WHERE (("Trans_assist_table"."FinterID" = "Trans_main_table"."FInterID")
AND ("Trans_assist_table"."FTranType" = "Trans_main_table"."FTranType")
AND ("Trans_main_table"."FSaleStyle" <> 1)
AND ("Trans_main_table"."FCancellation" = 1)
        AND ("Trans_main_table"."FRelateBrID" = branch_id)
        AND ("Trans_main_table"."FDCStockID" = warehouse_id or "Trans_main_table"."FSCStockID" = warehouse_id)
        AND ("Trans_assist_table"."FItemID" = cate_id))
        AND date_format("Trans_assist_table"."FDCTime", '%Y-%m-%d') = date_format(sort_time, '%Y-%m-%d')
) "base"
GROUP BY "base"."FStockID", "base"."FItemID", "base"."FDCTime"
HAVING "base"."FStockID" IS NOT NULL;

END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."update_previous_common_cate";

CREATE PROCEDURE "test_lvhuan"."update_previous_common_cate"() 
LANGUAGE plpgsql AS $$
BEGIN

DELETE FROM uct_common_cate WHERE date_unix > UNIX_TIMESTAMP()-86400;

INSERT INTO uct_common_cate (
branch_id,
cate_id,
cate_name,
src_type,
weight,
frequency,
date_unix
) SELECT
b.branch_id AS branch_id,
b.id AS cate_id,
b."name" AS cate_name,
IF(a.FTranType='PUR',0,IF(a.FTranType='SOR',1,2)) AS src_type,
ROUND(SUM(IFNULL(a.FQty, 0))) AS weight,
COUNT(b.id) AS frequency,
UNIX_TIMESTAMP(
TO_CHAR(a.FDCTime, '%Y-%m-%d')
) AS date_unix
FROM
Trans_assist_table AS a
JOIN uct_waste_cate AS b ON a.FItemID = b.id
WHERE
a.FDCTime > TO_CHAR(FROM_UNIXTIME(UNIX_TIMESTAMP()-86400),'%Y-%m-%d 00:00:00')
GROUP BY
date_unix,
src_type,
cate_id
ORDER BY
date_unix;

END; $$;










DROP PROCEDURE IF EXISTS "test_lvhuan"."city_wall_report";
CREATE PROCEDURE "test_lvhuan"."city_wall_report"() 
LANGUAGE plpgsql AS $$
DECLARE
    nowdate date := TO_CHAR(CURRENT_DATE - INTERVAL '1 day', '%Y-%m-%d');
BEGIN



insert into uct_day_wall_report(adcode,weight,availability,rubbish,rdf,carbon,box,customer_num,report_date) select ad.adcode,COALESCE(weight,0) as weight ,COALESCE(availability,0) as availability ,COALESCE(rubbish,0) as rubbish ,COALESCE(rdf,0) as rdf,COALESCE(carbon,0) as carbon,COALESCE(box,0) as box,COALESCE(customer.customer_num,0) as customer_num,nowdate as report_date from uct_adcode ad left join 
(select ad.adcode,round(sum(FQty),2) as weight , round(sum(if(c.name = '低值废弃物',FQty,0))/sum(FQty),2) as availability,round(sum(if(c.name = '低值废弃物',FQty,0)),2) as rubbish ,round(sum(if(c.name = '低值废弃物',FQty,0))/sum(FQty)*4.2,2) as rdf , round(sum(FQty*c2.carbon_parm),2) as carbon ,box.box from Trans_main_table mt  join Trans_main_table mt2 on mt.FInterId = mt2.FInterId and mt2.FTranType = 'PUR' and  TO_CHAR(mt2.FDate,'%Y-%m-%d') > '2018-9-30' and TO_CHAR(mt2.FDate,'%Y-%m-%d') = TO_CHAR(nowdate,'%Y-%m-%d') join  uct_waste_purchase p on mt.FBillNo = p.order_id  join  uct_waste_customer_factory cf  on cf.id = p.factory_id   join uct_adcode ad on ad.name =  cf.city    join Trans_assist_table at on mt.FInterID = at.FinterID  and  mt.FTranType = at.FTranType   join uct_waste_cate c on  c.id = at.FItemID  join  uct_waste_cate c2 on c.parent_id = c2.id

left join (select ad.adcode,sum(FUseCount) as box from Trans_main_table mt  join  uct_waste_purchase p on mt.FInterID = p.id  join  uct_waste_customer_factory cf  on cf.id = p.factory_id   join uct_adcode ad on ad.name =  cf.city join Trans_materiel_table materiel on materiel.FInterID = mt.FInterID  join uct_materiel materiel2 on materiel.FMaterielID = materiel2.id and materiel.FTranType in ('PUR','SOR') and materiel2.name = '分类箱'  where TO_CHAR(mt.FDate,'%Y-%m-%d') > '2018-9-30' and TO_CHAR(mt.FDate,'%Y-%m-%d') = TO_CHAR(nowdate,'%Y-%m-%d')  and mt.FTranType = 'PUR' and  mt.FSaleStyle in ('0','1')  and  mt.FCorrent = '1' and mt.FCancellation = '1'  and mt.FRelateBrID != 7  group by cf.province,cf.city order by cf.area ) box  on box.adcode = ad.adcode

where mt.FTranType in ('SOR','SEL') and mt.FSaleStyle in ('0','1')  and  mt.FCorrent = '1' and mt.FCancellation = '1'  and mt.FRelateBrID != 7   group by cf.province,cf.city order by cf.area) data on ad.adcode = data.adcode

left join (select ad.adcode , count(*) as customer_num from uct_up up join uct_adcode ad on up.company_city = ad.name and first_business_time = TO_CHAR(nowdate,'%Y-%m-%d') group by company_province,company_city) customer on customer.adcode = ad.adcode

where right(ad.adcode,4) != '0000' and right(ad.adcode,2) = '00';



update uct_accumulate_wall_report report join  (select ad.adcode,COALESCE(weight,0) as weight ,COALESCE(availability,0) as availability ,COALESCE(rubbish,0) as rubbish ,COALESCE(rdf,0) as rdf,COALESCE(carbon,0) as carbon,COALESCE(box,0) as box,COALESCE(customer.customer_num,0) as customer_num from uct_adcode ad left join
(select ad.adcode,round(sum(FQty),2) as weight , round(sum(if(c.name = '低值废弃物',FQty,0))/sum(FQty),2) as availability,round(sum(if(c.name = '低值废弃物',FQty,0)),2) as rubbish ,round(sum(if(c.name = '低值废弃物',FQty,0))/sum(FQty)*4.2,2) as rdf , round(sum(FQty*c2.carbon_parm),2) as carbon ,box.box from Trans_main_table mt  join Trans_main_table mt2 on mt.FInterId = mt2.FInterId and mt2.FTranType = 'PUR' and  TO_CHAR(mt2.FDate,'%Y-%m-%d') > '2018-9-30'  join  uct_waste_purchase p on mt.FBillNo = p.order_id  join  uct_waste_customer_factory cf  on cf.id = p.factory_id   join uct_adcode ad on ad.name =  cf.city    join Trans_assist_table at on mt.FInterID = at.FinterID  and  mt.FTranType = at.FTranType   join uct_waste_cate c on  c.id = at.FItemID  join  uct_waste_cate c2 on c.parent_id = c2.id

left join (select ad.adcode,sum(FUseCount) as box from Trans_main_table mt  join  uct_waste_purchase p on mt.FInterID = p.id  join  uct_waste_customer_factory cf  on cf.id = p.factory_id   join uct_adcode ad on ad.name =  cf.city join Trans_materiel_table materiel on materiel.FInterID = mt.FInterID  join uct_materiel materiel2 on materiel.FMaterielID = materiel2.id and materiel.FTranType in ('PUR','SOR') and materiel2.name = '分类箱'  where TO_CHAR(mt.FDate,'%Y-%m-%d') > '2018-9-30' and mt.FTranType = 'PUR' and  mt.FSaleStyle in ('0','1')  and  mt.FCorrent = '1' and mt.FCancellation = '1'  and mt.FRelateBrID != 7  group by cf.province,cf.city order by cf.area ) box  on box.adcode = ad.adcode

where mt.FTranType in ('SOR','SEL') and mt.FSaleStyle in ('0','1')  and  mt.FCorrent = '1' and mt.FCancellation = '1'  and mt.FRelateBrID != 7   group by cf.province,cf.city order by cf.area) data on ad.adcode = data.adcode

left join (select ad.adcode , count(*) as customer_num from uct_up up join uct_adcode ad on up.company_city = ad.name  group by company_province,company_city) customer on customer.adcode = ad.adcode

where right(ad.adcode,4) = '0000' and right(ad.adcode,2) = '00') data on report.adcode = data.adcode  
set  report.weight = data.weight , report.availability = data.availability , report.rubbish = data.rubbish ,report.rdf = data.rdf , report.carbon = data.carbon , report.box = data.box , report.customer_num = data.customer_num ; 

END;
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."edit_materiel_num";
CREATE PROCEDURE "test_lvhuan"."edit_materiel_num"(inout io_rv integer, inout io_err varchar(200)) 
LANGUAGE plpgsql AS $$
DECLARE 
  v_FInterID int;
  v_order_id varchar(20);
  v_number int;
  v_meta_id int;
  v_meta_price float;
  v_meta_amount float;
  v_money_all int;
  errno int;

  DECLARE s int DEFAULT 0;

  DECLARE report CURSOR FOR SELECT FInterID, order_id, meta_id, number, meta_price, meta_amount FROM uct_apply_for_material_temp WHERE state = 3;

BEGIN
  open report;

  LOOP
    FETCH report INTO v_FInterID, v_order_id, v_meta_id, v_number, v_meta_price, v_meta_amount;

    IF NOT FOUND THEN
      EXIT;
    END IF;

    start transaction;   
    errno = 0; 

    insert into Trans_materiel_table (
      FInterID,
      FTranType,
      FEntryID,
      FMaterielID,
      FUseCount,
      FPrice,
      FMeterielAmount,
      FMeterieltime,
      red_ink_time,
      is_hedge,
      revise_state
    ) values (
      v_FInterID,
      'PUR',
      0,
      v_meta_id,
      v_number,
      v_meta_price,
      v_meta_amount,
      UNIX_TIMESTAMP(now()),
      now(),
      0,
      2
    );
    errno = 1;

    select SUM(FMeterielAmount) as num into v_money_all 
    from Trans_materiel_table 
    where FInterID = v_FInterID 
    and FTranType in ('SOR','PUR');

    update  Trans_main_table set
      TalSecond = v_money_all,
      is_hedge = 1,
      red_ink_time = now()
    where  FInterID = v_FInterID 
    and  FTranType = 'SOR'
    and  FSaleStyle <> 1;
    errno = 2;

    update  uct_apply_for_material_temp set
      state = 1
    where  FInterID = v_FInterID;
    errno = 3;

    commit;

    if  errno = 3 then
      io_rv = 200;
      io_err = '处理成功.';
    end if;
  END LOOP;

  CLOSE report;

END; $$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."cursor_test";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."cursor_test"() 
LANGUAGE plpgsql AS $$
DECLARE 
  done BOOLEAN := FALSE;
  pid INTEGER;
  cur1 CURSOR FOR SELECT id FROM uct_admin WHERE id = 2;
  cur2 CURSOR FOR SELECT id FROM uct_admin WHERE id = 3;
BEGIN
  -- 开始事务
  START TRANSACTION;

  -- 打开游标 cur1
  OPEN cur1;
  LOOP
    FETCH cur1 INTO pid;
    EXIT WHEN NOT FOUND;
    -- 在这里处理游标 cur1 返回的数据
    SELECT pid;
  END LOOP;
  -- 关闭游标 cur1
  CLOSE cur1;

  -- 打开游标 cur2
  OPEN cur2;
  LOOP
    FETCH cur2 INTO pid;
    EXIT WHEN NOT FOUND;
    -- 在这里处理游标 cur2 返回的数据
    SELECT pid;
  END LOOP;
  -- 关闭游标 cur2

  -- 提交事务
  COMMIT;
END;
$$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."edit_materiel_num_1";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."edit_materiel_num_1"(INOUT o_rv integer, INOUT o_err varchar(200)) 
LANGUAGE plpgsql AS $$
DECLARE 
  v_FInterID int;
  v_order_id varchar(20);
  v_number int;
  v_meta_id int;
  v_meta_price float;
  v_meta_amount float;
  v_money_all int;
  errno int;
  s int DEFAULT 0;
  -- Declare the cursor
  report CURSOR FOR SELECT FInterID, order_id, meta_id, number, meta_price, meta_amount FROM uct_apply_for_material_temp WHERE state = 3;

BEGIN
  -- Open the cursor
  OPEN report;
  
  -- Fetch data from cursor
  FETCH report INTO v_FInterID, v_order_id, v_meta_id, v_number, v_meta_price, v_meta_amount;

  -- Loop through cursor data
  WHILE s <> 1 LOOP
    -- Start transaction
    START TRANSACTION;   

    -- Reset errno
    errno := 0; 

    -- Insert data into Trans_materiel_table
    INSERT INTO Trans_materiel_table (
      FInterID,
      FTranType,
      FEntryID,
      FMaterielID,
      FUseCount,
      FPrice,
      FMeterielAmount,
      FMeterieltime,
      red_ink_time,
      is_hedge,
      revise_state
    ) VALUES (
      v_FInterID,
      'PUR',
      0,
      v_meta_id,
      v_number,
      v_meta_price,
      v_meta_amount,
      UNIX_TIMESTAMP(now()),
      now(),
      0,
      2
    );

    -- Set errno
    errno := 1;

    -- Calculate SUM(FMeterielAmount)
    SELECT SUM(FMeterielAmount) INTO v_money_all 
    FROM Trans_materiel_table 
    WHERE FInterID = v_FInterID 
    AND FTranType IN ('SOR','PUR');

    -- Update Trans_main_table
    UPDATE Trans_main_table SET
      TalSecond = TalSecond + v_money_all,
      is_hedge = 1,
      red_ink_time = now()
    WHERE FInterID = v_FInterID 
    AND FTranType = 'SOR'
    AND FSaleStyle <> 1;

    -- Set errno
    errno := 2;

    -- Update uct_apply_for_material_temp
    UPDATE uct_apply_for_material_temp SET
      state = 1
    WHERE FInterID = v_FInterID;

    -- Set errno
    errno := 3;

    -- Commit transaction
    COMMIT;

    -- If errno is 3, set o_rv and o_err
    IF errno = 3 THEN
      o_rv := 200;
      o_err := '处理成功.';
    END IF;

    -- Fetch the next row of cursor data
    FETCH report INTO v_FInterID, v_order_id, v_meta_id, v_number, v_meta_price, v_meta_amount;
  END LOOP;

  -- Close the cursor
  CLOSE report;

END;
$$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."edit_order_table";
CREATE OR REPLACE PROCEDURE "test_lvhuan"."edit_order_table"(INOUT o_rv integer, INOUT o_err varchar(200)) 
LANGUAGE plpgsql AS $$
DECLARE
    v_FInterID int;
    v_FTranType varchar(20);
    v_metaID int;
    v_net_weight float;
    v_price float;
    v_weight_all float;
    v_money_all float;
    v_FEntryID int;
    v_FItemID int;
    v_FUnitID varchar(20);
    v_FQty float;
    v_FPrice float;
    v_FAmount float;
    v_disposal_way varchar(20);
    v_value_type varchar(20);
    v_FbasePrice char(1);
    v_FbaseAmount char(1);
    v_Ftaxrate char(1);
    v_Fbasetax char(1);
    v_Fbasetaxamount char(1);
    v_FPriceRef char(1);
    v_FDCTime varchar(20);
    v_FSourceInterId varchar(11);
    v_FSourceTranType varchar(3);
    v_revise_state int;
    v_hc_FQty float;
    v_hc_FAmount float;
    v_new_FAmount float;
    errno int;
BEGIN
    DECLARE s int DEFAULT 0;

    DECLARE report CURSOR FOR SELECT FInterID, FTranType, metaID, net_weight, price FROM uct_apply_for_order_temp WHERE state = 2;

    -- 异常块，用于捕获游标异常
    BEGIN
        OPEN report;
        LOOP
            FETCH report INTO v_FInterID, v_FTranType, v_metaID, v_net_weight, v_price;
            EXIT WHEN NOT FOUND;

            -- 开始事务块
            BEGIN
                set errno = 0; 
                
                SELECT FEntryID, FItemID, FUnitID, FQty, FPrice, FAmount, disposal_way, value_type,
                    CASE WHEN FbasePrice IS NOT NULL THEN FbasePrice ELSE '' END,
                    CASE WHEN FbaseAmount IS NOT NULL THEN FbaseAmount ELSE '' END,
                    CASE WHEN Ftaxrate IS NOT NULL THEN Ftaxrate ELSE '' END,
                    CASE WHEN Fbasetax IS NOT NULL THEN Fbasetax ELSE '' END,
                    CASE WHEN Fbasetaxamount IS NOT NULL THEN Fbasetaxamount ELSE '' END,
                    CASE WHEN FPriceRef IS NOT NULL THEN FPriceRef ELSE '' END,
                    FDCTime,
                    CASE WHEN FSourceInterId IS NOT NULL THEN FSourceInterId ELSE '' END,
                    CASE WHEN FSourceTranType IS NOT NULL THEN FSourceTranType ELSE '' END,
                    revise_state
                INTO v_FEntryID, v_FItemID, v_FUnitID, v_FQty, v_FPrice, v_FAmount, v_disposal_way, v_value_type, 
                    v_FbasePrice, v_FbaseAmount, v_Ftaxrate, v_Fbasetax, v_Fbasetaxamount, v_FPriceRef, 
                    v_FDCTime, v_FSourceInterId, v_FSourceTranType, v_revise_state
                FROM Trans_assist_table 
                WHERE FinterID = v_FInterID 
                  AND FTranType = v_FTranType 
                  AND (is_hedge IS NULL OR is_hedge = 0)
                  AND FItemID = v_metaID;

                set errno = 1;

                UPDATE Trans_assist_table SET 
                    is_hedge = 1,
                    red_ink_time = NOW()
                WHERE FinterID = v_FInterID 
                  AND FTranType = v_FTranType 
                  AND FItemID = v_metaID;

                set errno = 2;

                -- 将数量和金额变为负数
                   v_hc_FQty := -v_FQty;
                   v_hc_FAmount := -v_FAmount;

                INSERT INTO Trans_assist_table
                    (FinterID, FTranType, FEntryID, FItemID, FUnitID,
                    FQty, FPrice, FAmount, disposal_way, value_type,
                    FbasePrice, FbaseAmount, Ftaxrate, Fbasetax, Fbasetaxamount,
                    FPriceRef, FDCTime, FSourceInterId, FSourceTranType,
                    red_ink_time, is_hedge, revise_state)
                VALUES 
                    (v_FInterID, v_FTranType, v_FEntryID, v_FItemID, v_FUnitID,
                    v_hc_FQty, v_FPrice, v_hc_FAmount, v_disposal_way, v_value_type,
                    v_FbasePrice, v_FbaseAmount, v_Ftaxrate, v_Fbasetax, v_Fbasetaxamount, 
                    v_FPriceRef, v_FDCTime, v_FSourceInterId, v_FSourceTranType, NOW(), 1, v_revise_state);

                set errno = 3;
                
                -- 计算新的金额
                v_new_FAmount := v_net_weight * v_price;


                INSERT INTO Trans_assist_table
                    (FinterID, FTranType, FEntryID, FItemID, FUnitID,
                    FQty, FPrice, FAmount, disposal_way, value_type,
                    FbasePrice, FbaseAmount, Ftaxrate, Fbasetax, Fbasetaxamount,
                    FPriceRef, FDCTime, FSourceInterId, FSourceTranType,
                    red_ink_time, is_hedge, revise_state)
                VALUES 
                    (v_FInterID, v_FTranType, v_FEntryID, v_FItemID, v_FUnitID,
                    v_net_weight, v_price, v_new_FAmount, v_disposal_way, v_value_type,
                    v_FbasePrice, v_FbaseAmount, v_Ftaxrate, v_Fbasetax, v_Fbasetaxamount, 
                    v_FPriceRef, v_FDCTime, v_FSourceInterId, v_FSourceTranType, NOW(), 0, 1);

                set errno = 4;

                SELECT SUM(FQty) AS Qty_num, SUM(FAmount) AS Amt_num INTO v_weight_all, v_money_all 
                FROM Trans_assist_table 
                WHERE FinterID = v_FInterID 
                  AND FTranType = v_FTranType;

                UPDATE Trans_main_table SET
                    TalFQty = v_weight_all,
                    TalFAmount = v_money_all,
                    is_hedge = 1,
                    red_ink_time = NOW()
                WHERE FInterID = v_FInterID 
                AND FTranType = v_FTranType;

                set errno = 5;

                UPDATE uct_apply_for_order_temp SET
                    state = 1
                WHERE FInterID = v_FInterID 
                AND FTranType = v_FTranType 
                AND state = 2;

                set errno = 6;

                COMMIT;

                IF errno = 6 THEN
                    set o_rv = 200;
                    set o_err = '处理成功.';
                END IF;
            END; -- 结束事务块
        END LOOP;
        CLOSE report;
    EXCEPTION
        WHEN OTHERS THEN
            CLOSE report;
            -- 处理异常，可以在这里添加相关的处理逻辑
    END;
END;
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."edit_order_table_1";
CREATE OR REPLACE PROCEDURE "test_lvhuan"."edit_order_table_1"(INOUT o_rv integer, INOUT o_err varchar(200)) 
LANGUAGE plpgsql AS $$
DECLARE 
    v_FInterID int;
    v_FTranType varchar(20);
    v_metaID int;
    v_net_weight float;
    v_price float;
    v_weight_all float;
    v_money_all float;
    v_FEntryID int;
    v_FItemID int;
    v_FUnitID varchar(20);
    v_FQty float;
    v_FPrice float;
    v_FAmount float;
    v_disposal_way varchar(20);
    v_value_type varchar(20);
    v_FbasePrice char(1);
    v_FbaseAmount char(1);
    v_Ftaxrate char(1);
    v_Fbasetax char(1);
    v_Fbasetaxamount char(1);
    v_FPriceRef char(1);
    v_FDCTime varchar(20);
    v_FSourceInterId varchar(11);
    v_FSourceTranType varchar(3);
    v_revise_state int;
    v_hc_FQty float;
    v_hc_FAmount float;
    v_new_FAmount float;
    errno int;

BEGIN
    DECLARE s int DEFAULT 0;
    DECLARE report CURSOR FOR SELECT FInterID, FTranType, metaID, net_weight, price FROM uct_apply_for_order_temp WHERE state = 3;

    BEGIN
        OPEN report;
        LOOP
            FETCH report INTO v_FInterID, v_FTranType, v_metaID, v_net_weight, v_price;
            EXIT WHEN NOT FOUND;

            -- 移除 start transaction;

            set errno=0; 

            select FEntryID,FItemID,FUnitID,FQty,FPrice,FAmount,disposal_way,value_type,if(FbasePrice,FbasePrice,'') as FbasePrice,if(FbaseAmount,FbaseAmount,'') as FbaseAmount,
                   if(Ftaxrate,Ftaxrate,'') as Ftaxrate,if(Fbasetax,Fbasetax,'') as Fbasetax,if(Fbasetaxamount,Fbasetaxamount,'') as Fbasetaxamount,
                   if(FPriceRef,FPriceRef,'') as FPriceRef,FDCTime,if(FSourceInterId,FSourceInterId,'') as FSourceInterId,if(FSourceTranType is not null,FSourceTranType,'') as FSourceTranType,revise_state into v_FEntryID, v_FItemID, v_FUnitID, v_FQty, v_FPrice, v_FAmount, v_disposal_way, v_value_type,v_FbasePrice, v_FbaseAmount, v_Ftaxrate, v_Fbasetax, v_Fbasetaxamount, v_FPriceRef, v_FDCTime, v_FSourceInterId, v_FSourceTranType,v_revise_state
              from Trans_assist_table 
             where FinterID = v_FInterID 
               and FTranType = v_FTranType 
               and (is_hedge is null or is_hedge = 0)
               and FItemID = v_metaID;
            set errno=1;

            update Trans_assist_table set 
                    is_hedge = 1,
                    red_ink_time = now()
             where FinterID = v_FInterID 
               and FTranType = v_FTranType 
               and FItemID = v_metaID;
            set errno=2;

			v_hc_FQty = -v_FQty;
			v_hc_FAmount = -v_FAmount;



            insert into Trans_assist_table
                        (FinterID,FTranType,FEntryID,FItemID,FUnitID,
                        FQty,FPrice,FAmount,disposal_way,value_type,
    FbasePrice,FbaseAmount,Ftaxrate,Fbasetax,Fbasetaxamount,
                        FPriceRef,FDCTime,FSourceInterId,FSourceTranType,
                        red_ink_time,is_hedge,revise_state)
                 values (v_FInterID,v_FTranType,v_FEntryID, v_FItemID, v_FUnitID,
                        v_hc_FQty,v_FPrice,v_hc_FAmount,v_disposal_way,v_value_type,
    v_FbasePrice,v_FbaseAmount,v_Ftaxrate,v_Fbasetax,v_Fbasetaxamount,
                        v_FPriceRef,v_FDCTime,v_FSourceInterId,v_FSourceTranType,
              now(),1,v_revise_state);
            set errno=3;

            v_new_FAmount = v_net_weight * v_price; 
            insert into Trans_assist_table
                        (FinterID,FTranType,FEntryID,FItemID,FUnitID,
                        FQty,FPrice,FAmount,disposal_way,value_type,
                        FbasePrice,FbaseAmount,Ftaxrate,Fbasetax,Fbasetaxamount,
                        FPriceRef,FDCTime,FSourceInterId,FSourceTranType,
                        red_ink_time,is_hedge,revise_state)
                 values (v_FInterID,v_FTranType,v_FEntryID, v_FItemID, v_FUnitID,
                        v_net_weight,v_price,v_new_FAmount,v_disposal_way,v_value_type,
                        v_FbasePrice,v_FbaseAmount,v_Ftaxrate,v_Fbasetax,v_Fbasetaxamount, 
                        v_FPriceRef,v_FDCTime,v_FSourceInterId,v_FSourceTranType,
    now(),0,1);
            set errno=4;

            select SUM(FQty) as Qty_num,SUM(FAmount) as Amt_num into v_weight_all,v_money_all 
              from Trans_assist_table 
             where FinterID = v_FInterID 
               and FTranType = v_FTranType;

            update  Trans_main_table set
                    TalFQty = v_weight_all,
                    TalFAmount = v_money_all,
                    is_hedge = 1,
                    red_ink_time = now()
             where  FInterID = v_FInterID 
           and  FTranType = v_FTranType;
            set errno=5;

            update  uct_apply_for_order_temp set
                    state = 1
             where  FInterID = v_FInterID 
           and  FTranType = v_FTranType 
     and  state = 3;
     
      set errno=6;

            -- 移除 commit;

            if  errno = 6 then
                set o_rv = 200;
                set o_err = '处理成功.';
            end if;

        END LOOP;
        CLOSE report;
    EXCEPTION
        WHEN OTHERS THEN
            -- Handle exceptions here...
            o_rv := 500; -- Example: Set an error code
            o_err := SQLERRM; -- Example: Set an error message
    END;
END; 
$$;





DROP PROCEDURE IF EXISTS "test_lvhuan"."insertManyDate";
CREATE OR REPLACE PROCEDURE "test_lvhuan"."insertManyDate"(IN "beginDate" date,IN "endDate" date,IN "region_type" varchar(20)) 
LANGUAGE plpgsql AS $$
DECLARE 
    nowdate date DEFAULT CURRENT_DATE;
    endtmp date DEFAULT CURRENT_DATE;
    adcode_where varchar(100);
    customer_where varchar(100);
    customer_group_field varchar(100);
    factory_group_field varchar(100);
    factory_where varchar(100);
    sql_query text;

BEGIN
    nowdate := CURRENT_DATE;
    endtmp := CURRENT_DATE;

    IF region_type = 'area' THEN
        adcode_where := "right(ad.adcode,4) != '0000' and right(ad.adcode,2) != '00'";
        customer_where := "up.company_region";
        customer_group_field := "company_province,company_city,company_region";
        factory_group_field := "cf.province,cf.city,cf.area";
        factory_where := "cf.area";
    ELSIF region_type = 'city' THEN
        adcode_where := "right(ad.adcode,4) != '0000' and right(ad.adcode,2) = '00'";
        customer_where := "up.company_city";
        customer_group_field := "company_province,company_city";
        factory_group_field := "cf.province,cf.city";
        factory_where := "cf.city";
    ELSE
        adcode_where := "right(ad.adcode,4) = '0000'";
        customer_where := "up.company_province";
        customer_group_field := "company_province";
        factory_group_field := "cf.province";
        factory_where := "cf.province";
    END IF;

    nowdate := beginDate;
    endtmp := endDate;

    WHILE nowdate < endtmp LOOP
        sql_query := 
            'insert into uct_day_wall_report(adcode,weight,availability,rubbish,rdf,carbon,box,customer_num,report_date) ' ||
            'select ad.adcode,COALESCE(weight,0) as weight ,COALESCE(availability,0) as availability ,COALESCE(rubbish,0) as rubbish ,' ||
            'COALESCE(rdf,0) as rdf,COALESCE(carbon,0) as carbon,COALESCE(box,0) as box,COALESCE(customer.customer_num,0) as customer_num,''' || nowdate || ''' as report_date ' ||
            'from uct_adcode ad left join (' ||
            'select ad.adcode,round(sum(FQty),2) as weight , round(sum(case when c.name = ''低值废弃物'' then FQty else 0 end)/sum(FQty),2) as availability,' ||
            'round(sum(case when c.name = ''低值废弃物'' then FQty else 0 end),2) as rubbish ,' ||
            'round(sum(case when c.name = ''低值废弃物'' then FQty else 0 end)/sum(FQty)*4.2,2) as rdf ,' ||
            'round(sum(FQty*c2.carbon_parm),2) as carbon ,' ||
            'box.box ' ||
            'from Trans_main_table mt  ' ||
            'join Trans_main_table mt2 on mt.FInterId = mt2.FInterId and mt2.FTranType = ''PUR'' ' ||
            'and date_format(mt2.FDate,''%Y-%m-%d'') > ''2018-09-30'' and date_format(mt2.FDate,''%Y-%m-%d'') = TO_CHAR(''' || nowdate || ''',''%Y-%m-%d'') ' ||
            'join uct_waste_purchase p on mt.FBillNo = p.order_id ' ||
            'join uct_waste_customer_factory cf on cf.id = p.factory_id ' ||
            'join uct_adcode ad on ad.name = ' || factory_where || ' ' ||
            'join Trans_assist_table at on mt.FInterID = at.FinterID  and  mt.FTranType = at.FTranType ' ||
            'join uct_waste_cate c on  c.id = at.FItemID  ' ||
            'join uct_waste_cate c2 on c.parent_id = c2.id  ' ||
            'left join (' ||
            'select ad.adcode,sum(FUseCount) as box ' ||
            'from Trans_main_table mt  ' ||
            'join uct_waste_purchase p on mt.FInterID = p.id  ' ||
            'join uct_waste_customer_factory cf on cf.id = p.factory_id   ' ||
            'join uct_adcode ad on ad.name =  ' || factory_where || ' ' ||
            'join Trans_materiel_table materiel on materiel.FInterID = mt.FInterID  ' ||
            'join uct_materiel materiel2 on materiel.FMaterielID = materiel2.id and materiel.FTranType in (''PUR'',''SOR'') and materiel2.name = ''分类箱''  ' ||
            'where date_format(mt.FDate,''%Y-%m-%d'') > ''2018-09-30'' and date_format(mt.FDate,''%Y-%m-%d'') = TO_CHAR(''' || nowdate || ''',''%Y-%m-%d'')  ' ||
            'and mt.FTranType = ''PUR'' and  mt.FSaleStyle in (''0'',''1'')  and  mt.FCorrent = ''1'' and mt.FCancellation = ''1''  and mt.FRelateBrID != 7  ' ||
            'group by ' || factory_group_field || ' ) box  on box.adcode = ad.adcode   ' ||
            'where mt.FTranType in (''SOR'',''SEL'') and mt.FSaleStyle in (''0'',''1'')  and  mt.FCorrent = ''1'' and mt.FCancellation = ''1''  and mt.FRelateBrID != 7   ' ||
            'group by ' || factory_group_field || ' order by cf.area) data on ad.adcode = data.adcode ' ||
            'left join (' ||
            'select ad.adcode , count(*) as customer_num ' ||
            'from uct_up up ' ||
            'join uct_adcode ad on ' || customer_where || ' = ad.name and first_business_time = TO_CHAR(''' || nowdate || ''',''%Y-%m-%d'') ' ||
            'group by ' || customer_group_field || ') customer on customer.adcode = ad.adcode ' ||
            'where ' || adcode_where;

        EXECUTE sql_query;
        nowdate := nowdate + INTERVAL '1 day';
    END LOOP;

END; 
$$;








DROP PROCEDURE IF EXISTS "test_lvhuan"."insertOneLevelAccumulate";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."insertOneLevelAccumulate"(IN "region_type" varchar(50)) 
LANGUAGE plpgsql AS $$
DECLARE 
    group_field varchar(50);
    region_where varchar(50);
    sql_query text;

BEGIN

    IF region_type = 'area' THEN
        group_field := 'cf.province,cf.city,cf.area';
        region_where := 'ad.name = cf.area';
    ELSIF region_type = 'city' THEN
        group_field := 'cf.province,cf.city';
        region_where := 'ad.name = cf.city';
    ELSE
        group_field := 'cf.province';
        region_where := 'ad.name = cf.province';
    END IF;

    sql_query := 
        'replace into uct_one_level_accumulate_wall_report(adcode,name,weight,carbon) ' ||
        'select ad.adcode,c3.name,round(sum(FQty),2) as weight , round(sum(FQty*c2.carbon_parm),2) as carbon ' ||
        'from Trans_main_table mt  ' ||
        'join Trans_main_table mt2 on mt.FInterId = mt2.FInterId and mt2.FTranType = ''PUR'' and date_format(mt2.FDate,''%Y-%m-%d'') > ''2018-09-30'' ' ||
        'join uct_waste_purchase p on mt.FBillNo = p.order_id ' ||
        'join uct_waste_customer_factory cf  on cf.id = p.factory_id ' ||
        'join uct_adcode ad on ' || region_where || ' ' ||
        'join Trans_assist_table at on mt.FInterID = at.FinterID  and mt.FTranType = at.FTranType   ' ||
        'join uct_waste_cate c on  c.id = at.FItemID  ' ||
        'join uct_waste_cate c2 on c.parent_id = c2.id  ' ||
        'join uct_waste_cate c3 on c2.parent_id = c3.id  ' ||
        'where mt.FTranType in (''SOR'',''SEL'') and mt.FSaleStyle in (''0'',''1'')  and  mt.FCorrent = ''1'' and mt.FCancellation = ''1''  and mt.FRelateBrID != 7   ' ||
        'group by ' || group_field || ',c3.name order by weight';

    EXECUTE sql_query;

END; 
$$;




DROP PROCEDURE IF EXISTS "test_lvhuan"."insertManyDate";
CREATE OR REPLACE PROCEDURE "test_lvhuan"."insertManyDate"(IN "beginDate" date, IN "endDate" date, IN "region_type" varchar(20)) 
LANGUAGE plpgsql AS $$
DECLARE 
    nowdate date DEFAULT CURRENT_DATE;
    endtmp date DEFAULT CURRENT_DATE;
    adcode_where varchar(100);
    customer_where varchar(100);
    customer_group_field varchar(100);
    factory_group_field varchar(100);
    factory_where varchar(100);
    sql_query text;

BEGIN
    IF region_type = 'area' THEN
        adcode_where := 'right(ad.adcode,4) != ''0000'' and right(ad.adcode,2) != ''00''';
        customer_where := 'up.company_region';
        customer_group_field := 'company_province,company_city,company_region';
        factory_group_field := 'cf.province,cf.city,cf.area';
        factory_where := 'cf.area';
    ELSIF region_type = 'city' THEN
        adcode_where := 'right(ad.adcode,4) != ''0000'' and right(ad.adcode,2) = ''00''';
        customer_where := 'up.company_city';
        customer_group_field := 'company_province,company_city';
        factory_group_field := 'cf.province,cf.city';
        factory_where := 'cf.city';
    ELSE
        adcode_where := 'right(ad.adcode,4) = ''0000''';
        customer_where := 'up.company_province';
        customer_group_field := 'company_province';
        factory_group_field := 'cf.province';
        factory_where := 'cf.province';
    END IF;

    nowdate := TO_CHAR(beginDate, 'YYYY-MM-DD');
    endtmp := TO_CHAR(endDate, 'YYYY-MM-DD');

    WHILE nowdate < endtmp
    LOOP
        sql_query := 'INSERT INTO uct_day_wall_report(adcode, weight, availability, rubbish, rdf, carbon, box, customer_num, report_date) ' ||
                     'SELECT ad.adcode, COALESCE(weight, 0) as weight, COALESCE(availability, 0) as availability, COALESCE(rubbish, 0) as rubbish, ' ||
                     'COALESCE(rdf, 0) as rdf, COALESCE(carbon, 0) as carbon, COALESCE(box, 0) as box, COALESCE(customer.customer_num, 0) as customer_num, ''' || nowdate || ''' as report_date ' ||
                     'FROM uct_adcode ad ' ||
                     'LEFT JOIN (SELECT ad.adcode, round(sum(FQty), 2) as weight, round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / sum(FQty), 2) as availability, ' ||
                     'round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END), 2) as rubbish, ' ||
                     'round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / sum(FQty) * 4.2, 2) as rdf, round(sum(FQty * c2.carbon_parm), 2) as carbon, box.box ' ||
                     'FROM Trans_main_table mt ' ||
                     'JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND date_format(mt2.FDate, ''YYYY-MM-DD'') > ''2018-09-30'' ' ||
                     'JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id ' ||
                     'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id ' ||
                     'JOIN uct_adcode ad ON ad.name = ' || factory_where || ' ' ||
                     'JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType ' ||
                     'JOIN uct_waste_cate c ON c.id = at.FItemID ' ||
                     'JOIN uct_waste_cate c2 ON c.parent_id = c2.id ' ||
                     'LEFT JOIN (SELECT ad.adcode, sum(FUseCount) as box ' ||
                     'FROM Trans_main_table mt ' ||
                     'JOIN uct_waste_purchase p ON mt.FInterID = p.id ' ||
                     'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id ' ||
                     'JOIN uct_adcode ad ON ad.name = ' || factory_where || ' ' ||
                     'JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID ' ||
                     'JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType IN (''PUR'',''SOR'') AND materiel2.name = ''分类箱'' ' ||
                     'WHERE date_format(mt.FDate, ''YYYY-MM-DD'') > ''2018-09-30'' AND date_format(mt.FDate, ''YYYY-MM-DD'') = ''' || nowdate || ''' ' ||
                     'AND mt.FTranType = ''PUR'' AND mt.FSaleStyle IN (''0'',''1'') AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 ' ||
                     'GROUP BY ' || factory_group_field || ') box ON box.adcode = ad.adcode ' ||
                     'WHERE mt.FTranType IN (''SOR'',''SEL'') AND mt.FSaleStyle IN (''0'',''1'') AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 ' ||
                     'GROUP BY ' || factory_group_field || ' ORDER BY cf.area) data ON ad.adcode = data.adcode ' ||
                     'LEFT JOIN (SELECT ad.adcode, count(*) as customer_num ' ||
                     'FROM uct_up up ' ||
                     'JOIN uct_adcode ad ON ' || customer_where || ' = ad.name AND first_business_time = ''' || nowdate || ''' ' ||
                     'GROUP BY ' || customer_group_field || ') customer ON customer.adcode = ad.adcode ' ||
                     'WHERE ' || adcode_where;

        EXECUTE sql_query;

        nowdate := nowdate + interval '1 day';
    END LOOP;
END; 
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."insertOneLevelManyDate";
CREATE OR REPLACE PROCEDURE "test_lvhuan"."insertOneLevelManyDate"(IN "beginDate" date, IN "endDate" date, IN "region_type" varchar(20)) 
LANGUAGE plpgsql AS $$
DECLARE 
    nowdate date DEFAULT CURRENT_DATE;
    endtmp date DEFAULT CURRENT_DATE;
    group_field varchar(50);
    region_where varchar(50);
    sql_query text;

BEGIN
    IF region_type = 'area' THEN
        group_field := 'cf.province,cf.city,cf.area';
        region_where := 'ad.name = cf.area';
    ELSIF region_type = 'city' THEN
        group_field := 'cf.province,cf.city';
        region_where := 'ad.name = cf.city';
    ELSE
        group_field := 'cf.province';
        region_where := 'ad.name = cf.province';
    END IF;

    nowdate := TO_CHAR(beginDate, 'YYYY-MM-DD');
    endtmp := TO_CHAR(endDate, 'YYYY-MM-DD');

    WHILE nowdate < endtmp
    LOOP
        sql_query := 'INSERT INTO uct_one_level_day_wall_report(adcode, name, weight, carbon, report_date) ' ||
                     'SELECT ad.adcode, c3.name, round(sum(FQty), 2) as weight, round(sum(FQty * c2.carbon_parm), 2) as carbon, ''' || nowdate || ''' as report_date ' ||
                     'FROM Trans_main_table mt ' ||
                     'JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND date_format(mt2.FDate, ''YYYY-MM-DD'') > ''2018-09-30'' ' ||
                     'JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id ' ||
                     'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id ' ||
                     'JOIN uct_adcode ad ON ' || region_where || ' ' ||
                     'JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType ' ||
                     'JOIN uct_waste_cate c ON c.id = at.FItemID ' ||
                     'JOIN uct_waste_cate c2 ON c.parent_id = c2.id ' ||
                     'JOIN uct_waste_cate c3 ON c2.parent_id = c3.id ' ||
                     'WHERE mt.FTranType IN (''SOR'',''SEL'') AND mt.FSaleStyle IN (''0'',''1'') ' ||
                     'AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 ' ||
                     'GROUP BY ' || group_field || ', c3.name ' ||
                     'ORDER BY weight';

        EXECUTE sql_query;

        nowdate := nowdate + interval '1 day';
    END LOOP;
END; 
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."insertReportAccumulate";
CREATE OR REPLACE PROCEDURE "test_lvhuan"."insertReportAccumulate"(IN "region_type" varchar(50)) 
LANGUAGE plpgsql AS $$
DECLARE 
    group_field varchar(50);
    region_where varchar(50);
    adcode_where varchar(100);
    customer_where varchar(100);
    customer_group_field varchar(100);
    factory_group_field varchar(100);
    factory_where varchar(100);
    sql_query text;

BEGIN
    IF region_type = 'area' THEN       
        adcode_where := 'right(ad.adcode,4) != ''0000'' and right(ad.adcode,2) != ''00''';
        customer_where := 'up.company_region';
        customer_group_field := 'company_province,company_city,company_region';
        factory_group_field := 'cf.province,cf.city,cf.area';
        factory_where := 'cf.area';
    ELSIF region_type = 'city' THEN   
        adcode_where := 'right(ad.adcode,4) != ''0000'' and right(ad.adcode,2) = ''00''';
        customer_where := 'up.company_city';
        customer_group_field := 'company_province,company_city';
        factory_group_field := 'cf.province,cf.city';
        factory_where := 'cf.city';
    ELSE                                
        adcode_where := 'right(ad.adcode,4) = ''0000''';
        customer_where := 'up.company_province';
        customer_group_field := 'company_province';
        factory_group_field := 'cf.province';
        factory_where := 'cf.province';
    END IF;

    sql_query := 'INSERT INTO uct_accumulate_wall_report(adcode, weight, availability, rubbish, rdf, carbon, box, customer_num) ' ||
                 'SELECT ad.adcode, COALESCE(weight,0) as weight, COALESCE(availability,0) as availability, ' ||
                 'COALESCE(rubbish,0) as rubbish, COALESCE(rdf,0) as rdf, COALESCE(carbon,0) as carbon, ' ||
                 'COALESCE(box,0) as box, COALESCE(customer.customer_num,0) as customer_num ' ||
                 'FROM uct_adcode ad ' ||
                 'LEFT JOIN (SELECT ad.adcode, round(sum(FQty),2) as weight, round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / sum(FQty), 2) as availability, ' ||
                 'round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END), 2) as rubbish, ' ||
                 'round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / sum(FQty) * 4.2, 2) as rdf, ' ||
                 'round(sum(FQty * c2.carbon_parm), 2) as carbon, box.box ' ||
                 'FROM Trans_main_table mt ' ||
                 'JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND date_format(mt2.FDate, ''YYYY-MM-DD'') > ''2018-09-30'' ' ||
                 'JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id ' ||
                 'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id ' ||
                 'JOIN uct_adcode ad ON ad.name = ' || factory_where || ' ' ||
                 'JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType ' ||
                 'JOIN uct_waste_cate c ON c.id = at.FItemID ' ||
                 'JOIN uct_waste_cate c2 ON c.parent_id = c2.id ' ||
                 'LEFT JOIN (SELECT ad.adcode, sum(FUseCount) as box ' ||
                 'FROM Trans_main_table mt ' ||
                 'JOIN uct_waste_purchase p ON mt.FInterID = p.id ' ||
                 'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id ' ||
                 'JOIN uct_adcode ad ON ad.name = ' || factory_where || ' ' ||
                 'JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID ' ||
                 'JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id ' ||
                 'AND materiel.FTranType IN (''PUR'',''SOR'') AND materiel2.name = ''分类箱'' ' ||
                 'WHERE date_format(mt.FDate, ''YYYY-MM-DD'') > ''2018-09-30'' AND mt.FTranType = ''PUR'' AND ' ||
                 'mt.FSaleStyle IN (''0'',''1'') AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 ' ||
                 'GROUP BY ' || factory_group_field || ' ' ||
                 'ORDER BY cf.area ) box ON box.adcode = ad.adcode ' ||
                 'WHERE mt.FTranType IN (''SOR'',''SEL'') AND mt.FSaleStyle IN (''0'',''1'') ' ||
                 'AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 ' ||
                 'GROUP BY ' || factory_group_field || ' ' ||
                 'ORDER BY cf.area ) data ON ad.adcode = data.adcode ' ||
                 'LEFT JOIN (SELECT ad.adcode, count(*) as customer_num ' ||
                 'FROM uct_up up ' ||
                 'JOIN uct_adcode ad ON ' || customer_where || ' = ad.name ' ||
                 'GROUP BY ' || customer_group_field || ') customer ON customer.adcode = ad.adcode ' ||
                 'WHERE ' || adcode_where;

    EXECUTE sql_query;

END; 
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."lh_dw_month_report_del";
CREATE OR REPLACE PROCEDURE "test_lvhuan"."lh_dw_month_report_del"(IN "p_day" varchar(50),
INOUT o_rv        integer,
INOUT o_err       varchar(200)) 
LANGUAGE plpgsql AS $$
BEGIN
    DECLARE v_new_day varchar(50);
    DECLARE errno int;
    
    BEGIN
        SELECT TO_CHAR(DATE_ADD(p_day, INTERVAL 0 MONTH),'%Y-%m') INTO v_new_day;
        
        IF v_new_day IS NOT NULL THEN
            RAISE EXCEPTION 'v_new_day is not null';
        END IF;
        
        DELETE FROM lh_dw.data_statistics_results
        WHERE time_dims = 'M' AND time_val = v_new_day;
        
        GET STACKED DIAGNOSTICS errno = PG_EXCEPTION_DETAIL;
        
        IF errno = 'v_new_day is not null' THEN
            o_rv := 200;
            o_err := '月报表数据删除成功.';
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS errno = PG_EXCEPTION_DETAIL;
            o_rv := errno;
            o_err := '月报表数据删除失败.';
    END;
END;
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."lh_dw_table_check1_to_execute";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."lh_dw_table_check1_to_execute"() 
LANGUAGE plpgsql AS $$
BEGIN
    DECLARE v_id              int;
    DECLARE v_pre_tasks       varchar(32);
    DECLARE v_exec_way        varchar(20);
    DECLARE v_exec_alg        varchar(10000);
    DECLARE v_err_logs        varchar(200);
    DECLARE o_rv              int;
    DECLARE o_err             varchar(100);
    DECLARE v_exec_state      int;
    DECLARE sqlUp             varchar(800);
    DECLARE sqlStr            varchar(800);
    DECLARE v_sql             varchar(800);
    DECLARE v_sql_str         varchar(800);
    DECLARE statu             varchar(20);
    DECLARE v_filed           varchar(20);
    DECLARE v_status          int;
    DECLARE v_res_exec_state int;
    DECLARE v_res_err_logs   varchar(200);
    DECLARE errno             int;

    DECLARE s int DEFAULT 0;

    DECLARE report CURSOR FOR 
        SELECT id, pre_tasks, exec_way, exec_alg, err_logs, exec_state 
        FROM lh_dw.data_statistics_execution 
        WHERE UNIX_TIMESTAMP(exec_time) <= UNIX_TIMESTAMP(now()) AND exec_state = 3;

    BEGIN
        OPEN report;

        LOOP
            FETCH report INTO v_id, v_pre_tasks, v_exec_way, v_exec_alg, v_err_logs, v_exec_state;
            EXIT WHEN NOT FOUND;

            v_exec_alg = TRIM(v_exec_alg);
            v_id = TRIM(v_id);

            IF v_pre_tasks IS NULL OR v_pre_tasks = '' OR v_pre_tasks = ' ' THEN
                CALL lh_dw_table_data_execution(v_id, v_exec_alg, o_rv, o_err);
                SELECT o_rv, o_err INTO v_res_exec_state, v_res_err_logs;
                
                IF o_rv = 200 THEN
                    v_res_exec_state = 1;
                    v_res_err_logs = '';
                END IF;
                
                IF o_rv = 400 THEN
                    v_res_exec_state = 2;
                    v_res_err_logs = o_err;
                END IF;

                UPDATE lh_dw.data_statistics_execution  
                SET exec_state = v_res_exec_state, err_logs = v_res_err_logs 
                WHERE id = v_id;
            ELSE
                SELECT EXP(SUM(LN(CASE WHEN exec_state = 1 THEN 1 ELSE 2 END))) INTO v_status 
                FROM lh_dw.data_statistics_execution 
                WHERE id IN (SELECT unnest(string_to_array(v_pre_tasks, ',')));
                
                IF v_status = 1 THEN
                    CALL lh_dw_table_data_execution(v_id, v_exec_alg, o_rv, o_err);
                    SELECT o_rv, o_err INTO v_res_exec_state, v_res_err_logs;

                    IF o_rv = 200 THEN
                        v_res_exec_state = 1;
                        v_res_err_logs = '';
                    END IF;

                    IF o_rv = 400 THEN
                        v_res_exec_state = 2;
                        v_res_err_logs = o_err;
                    END IF;

                    UPDATE lh_dw.data_statistics_execution  
                    SET exec_state = v_res_exec_state, err_logs = v_res_err_logs 
                    WHERE id = v_id;
                END IF;
            END IF;
        END LOOP;
        
        CLOSE report;
    END;
END;
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."lh_dw_table_check_to_execute";
CREATE OR REPLACE PROCEDURE "test_lvhuan"."lh_dw_table_check_to_execute"() 
LANGUAGE plpgsql AS $$
BEGIN
    DECLARE v_id              int;
    DECLARE v_pre_tasks       varchar(100);
    DECLARE v_exec_way        varchar(20);
    DECLARE v_exec_alg        varchar(10000);
    DECLARE v_err_logs        varchar(200);
    DECLARE o_rv              int;
    DECLARE o_err             varchar(100);
    DECLARE v_exec_state      int;
    DECLARE sqlUp             varchar(800);
    DECLARE sqlStr            varchar(800);
    DECLARE v_sql             varchar(800);
    DECLARE v_sql_str         varchar(800);
    DECLARE statu             varchar(20);
    DECLARE v_filed           varchar(20);
    DECLARE v_status          int;
    DECLARE v_res_exec_state int;
    DECLARE v_res_err_logs   varchar(200);
    DECLARE errno             int;
    DECLARE v_exec_code      varchar(300);
    DECLARE v_count_num      int;
    DECLARE v_log_type       varchar(30);
    DECLARE v_res_exec_type  varchar(30);

    DECLARE s int DEFAULT 0;

    DECLARE report CURSOR FOR 
        SELECT id, pre_tasks, exec_way, exec_alg, err_logs, exec_state, code 
        FROM lh_dw.data_statistics_execution 
        WHERE UNIX_TIMESTAMP(exec_time) <= UNIX_TIMESTAMP(now()) 
            AND exec_way = 'sql' 
            AND code LIKE 'cust-m-%' 
            AND exec_state IN (0, 2);

    BEGIN
        OPEN report;

        LOOP
            FETCH report INTO v_id, v_pre_tasks, v_exec_way, v_exec_alg, v_err_logs, v_exec_state, v_exec_code;
            EXIT WHEN NOT FOUND;

            v_exec_alg = TRIM(v_exec_alg);
            v_id = TRIM(v_id);

            SELECT COUNT(*) INTO v_count_num FROM lh_dw.data_statistics_execution_log WHERE exec_id = v_id;

            IF v_count_num > 0 THEN
                SELECT COALESCE(exec_type, 'waiting') INTO v_log_type 
                FROM lh_dw.data_statistics_execution_log 
                WHERE exec_id = v_id 
                ORDER BY create_at DESC 
                LIMIT 1;
            END IF;

            IF v_count_num = 0 OR v_log_type = 'failed' THEN
                INSERT INTO lh_dw.data_statistics_execution_log (exec_id, exec_code, exec_type)
                VALUES (v_id, v_exec_code, 'waiting');
            END IF;

            IF v_count_num = 0 OR (v_log_type = 'waiting' OR v_log_type = 'failed') THEN
                IF v_pre_tasks = '' OR v_pre_tasks = ' ' OR v_pre_tasks IS NULL THEN
                    UPDATE lh_dw.data_statistics_execution_log  
                    SET exec_type = 'operation' 
                    WHERE exec_id = v_id AND finish_at IS NULL;

                    SET o_rv = 0;
                    SET o_err = '';
                    CALL lh_dw_table_data_execution(v_id, v_exec_alg, o_rv, o_err);
                    SELECT o_rv, o_err;
                    
                    IF o_rv = 200 THEN
                        v_res_exec_state = 1;
                        v_res_err_logs = '';
                        v_res_exec_type = 'finish';
                    END IF;
                    
                    IF o_rv = 400 THEN
                        v_res_exec_state = 2;
                        v_res_err_logs = o_err;
                        v_res_exec_type = 'failed';
                    END IF;

                    UPDATE lh_dw.data_statistics_execution  
                    SET exec_state = v_res_exec_state, err_logs = v_res_err_logs 
                    WHERE id = v_id;
                     
                    UPDATE lh_dw.data_statistics_execution_log  
                    SET exec_type = v_res_exec_type, finish_at = now() 
                    WHERE exec_id = v_id AND finish_at IS NULL;
                ELSE
                    SELECT EXP(SUM(LN(CASE WHEN exec_state = 1 THEN 1 ELSE 2 END))) INTO v_status 
                    FROM lh_dw.data_statistics_execution 
                    WHERE id IN (SELECT unnest(string_to_array(v_pre_tasks, ',')));

                    IF v_status = 1 THEN
                        UPDATE lh_dw.data_statistics_execution_log  
                        SET exec_type = 'operation' 
                        WHERE exec_id = v_id AND finish_at IS NULL;

                        SET o_rv = 0;
                        SET o_err = '';
                        CALL lh_dw_table_data_execution(v_id, v_exec_alg, o_rv, o_err);
                        SELECT o_rv, o_err;
                        
                        IF o_rv = 200 THEN
                            v_res_exec_state = 1;
                            v_res_err_logs = '';
                            v_res_exec_type = 'finish';
                        END IF;
                        
                        IF o_rv = 400 THEN
                            v_res_exec_state = 2;
                            v_res_err_logs = o_err;
                            v_res_exec_type = 'failed';
                        END IF;

                        UPDATE lh_dw.data_statistics_execution  
                        SET exec_state = v_res_exec_state, err_logs = v_res_err_logs 
                        WHERE id = v_id;
                        
                        UPDATE lh_dw.data_statistics_execution_log  
                        SET exec_type = v_res_exec_type, finish_at = now() 
                        WHERE exec_id = v_id AND finish_at IS NULL;
                    END IF;
                END IF;
            END IF;
        END LOOP;
        
        CLOSE report;
    END;
END;
$$;






-- 删除已存在的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."lh_dw_table_data_execution";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."lh_dw_table_data_execution"(in p_id integer, in p_content varchar(10000), INOUT o_rv integer, INOUT o_err varchar(200)) 
LANGUAGE plpgsql AS $$
DECLARE 
    errno int;
BEGIN
    BEGIN
        -- 设置初始错误代码和错误消息
        o_rv := 400;
        o_err := '存储过程运行失败';

        -- 尝试执行动态 SQL
        EXECUTE p_content;

        -- 如果执行成功，设置成功状态和消息
        o_rv := 200;
        o_err := '执行成功.';
    EXCEPTION
        WHEN OTHERS THEN
            -- 捕获异常并设置错误状态和消息
            o_rv := 400;
            o_err := SQLERRM;
    END;
END;
$$;



-- 删除已存在的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."lh_dw_visual_check_to_execute";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."lh_dw_visual_check_to_execute"() 
LANGUAGE plpgsql AS $$
DECLARE 
    v_id int;
    v_pre_tasks varchar(100);
    v_exec_way varchar(20);
    v_exec_alg varchar(10000);
    v_err_logs varchar(200);
    o_rv int;
    o_err varchar(100);
    v_exec_state int;
    sqlUp varchar(800);
    sqlStr varchar(800);
    v_sql varchar(800);
    v_sql_str varchar(800);
    statu varchar(20);
    v_filed varchar(20);
    v_status int;
    v_res_exec_state int;
    v_res_err_logs varchar(200);
    errno int;
    v_exec_code varchar(300);
    v_count_num int;
    v_log_type varchar(30);
    v_res_exec_type varchar(30);
    s int DEFAULT 0;
    
    report CURSOR FOR 
        SELECT id, pre_tasks, exec_way, exec_alg, err_logs, exec_state, code 
        FROM lh_dw.data_statistics_execution 
        WHERE UNIX_TIMESTAMP(exec_time) <= UNIX_TIMESTAMP(now()) 
        AND exec_way = 'sql' 
        AND code LIKE 'visualization-large-data%' 
        AND exec_state IN (0, 2);
BEGIN
    OPEN report;

    LOOP
        FETCH report INTO v_id, v_pre_tasks, v_exec_way, v_exec_alg, v_err_logs, v_exec_state, v_exec_code;

        EXIT WHEN s = 1;

        -- 初始化变量
        v_exec_alg := TRIM(v_exec_alg);
        v_id := TRIM(v_id);

        SELECT COUNT(*) INTO v_count_num FROM lh_dw.data_statistics_execution_log WHERE exec_id = v_id;
        
        IF v_count_num > 0 THEN
            SELECT COALESCE(exec_type, 'waiting') INTO v_log_type 
            FROM lh_dw.data_statistics_execution_log 
            WHERE exec_id = v_id 
            ORDER BY create_at DESC 
            LIMIT 1;
        END IF;

        IF v_count_num = 0 OR v_log_type = 'failed' THEN
            INSERT INTO lh_dw.data_statistics_execution_log (exec_id, exec_code, exec_type)
            VALUES (v_id, v_exec_code, 'waiting');
        END IF;

        IF v_count_num = 0 OR v_log_type = 'waiting' OR v_log_type = 'failed' THEN
            IF v_pre_tasks = '' OR v_pre_tasks = ' ' OR v_pre_tasks IS NULL THEN
                UPDATE lh_dw.data_statistics_execution_log  
                SET exec_type = 'operation' 
                WHERE exec_id = v_id AND finish_at IS NULL;

                o_rv := 0;
                o_err := '';
                CALL lh_dw_table_data_execution(v_id, v_exec_alg, o_rv, o_err);
                SELECT o_rv, o_err;
                IF o_rv = 200 THEN
                    v_res_exec_state := 1;
                    v_res_err_logs := '';
                    v_res_exec_type := 'finish';
                END IF;
                IF o_rv = 400 THEN
                    v_res_exec_state := 2;
                    v_res_err_logs := o_err;
                    v_res_exec_type := 'failed';
                END IF;
                UPDATE lh_dw.data_statistics_execution  
                SET exec_state = v_res_exec_state, err_logs = v_res_err_logs 
                WHERE id = v_id;

                UPDATE lh_dw.data_statistics_execution_log  
                SET exec_type = v_res_exec_type, finish_at = NOW() 
                WHERE exec_id = v_id AND finish_at IS NULL;
            ELSE
                SELECT EXP(SUM(LN(CASE WHEN exec_state = 1 THEN 1 ELSE 2 END))) INTO v_status 
                FROM lh_dw.data_statistics_execution 
                WHERE find_in_set(id, v_pre_tasks);

                IF v_status = 1 THEN
                    UPDATE lh_dw.data_statistics_execution_log  
                    SET exec_type = 'operation' 
                    WHERE exec_id = v_id AND finish_at IS NULL;

                    o_rv := 0;
                    o_err := '';
                    CALL lh_dw_table_data_execution(v_id, v_exec_alg, o_rv, o_err);
                    SELECT o_rv, o_err;
                    IF o_rv = 200 THEN
                        v_res_exec_state := 1;
                        v_res_err_logs := '';
                        v_res_exec_type := 'finish';
                    END IF;
                    IF o_rv = 400 THEN
                        v_res_exec_state := 2;
                        v_res_err_logs := o_err;
                        v_res_exec_type := 'failed';
                    END IF;
                    UPDATE lh_dw.data_statistics_execution  
                    SET exec_state = v_res_exec_state, err_logs = v_res_err_logs 
                    WHERE id = v_id;

                    UPDATE lh_dw.data_statistics_execution_log  
                    SET exec_type = v_res_exec_type, finish_at = NOW() 
                    WHERE exec_id = v_id AND finish_at IS NULL;
                END IF;
            END IF;
        END IF;
    END LOOP;

    CLOSE report;
END;
$$;




DROP PROCEDURE IF EXISTS "test_lvhuan"."lh_dw_warehouse_day_mysql";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."lh_dw_warehouse_day_mysql"(IN "p_day" varchar(50),
INOUT o_rv        integer,
INOUT o_err       varchar(200)) 
LANGUAGE plpgsql AS $$
DECLARE
  errno           int;
  v_month_begin   int;
  v_month_end     int;
  v_month         varchar(20);
  v_last_day      varchar(20);
  v_before_day    varchar(20);
  v_today_day     int;
  v_new_day       varchar(20);
BEGIN
  BEGIN
    SELECT INTO v_month_begin, v_month_end, v_month, v_last_day, v_before_day, v_today_day
      UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(now(), INTERVAL 0 MONTH), '%Y-%m-01 00:00:00')),
      UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(now(), INTERVAL 0 MONTH)), '%Y-%m-%d 23:59:59')),
      TO_CHAR(LAST_DAY(DATE_SUB(now(), INTERVAL 0 MONTH)), '%Y-%m'),
      TO_CHAR(DATE_SUB(now(), INTERVAL 0 MONTH), '%Y-%m-%d'),
      TO_CHAR(LAST_DAY(DATE_SUB(now(), INTERVAL 1 MONTH)), '%Y-%m-%d'),
      UNIX_TIMESTAMP(CONCAT(p_day, ' 12:00:00'));
    
    IF v_today_day > v_month_end THEN
      o_rv := 400;
      o_err := '不能给定未来的日期';
      RETURN;
    END IF;

    IF v_today_day < v_month_begin THEN
      v_new_day := v_before_day;
    END IF;

    IF v_month_begin < v_today_day AND v_today_day < v_month_end THEN
      v_new_day := v_last_day;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      GET STACKED DIAGNOSTICS errno = PG_EXCEPTION_DETAIL;
      o_rv := errno;
      o_err := '仓库数据生成失败.';
      RETURN;
  END;
  
start transaction;
set errno=1000;


 insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, 
             group1, group2, txt1, val1, val2, val3, val4, val5) 
      SELECT 'D' as time_dims,baseTime.time_val,FROM_UNIXTIME(baseTime.begin_time) as begin_time, FROM_UNIXTIME(baseTime.end_time) as end_time,
             '分部-仓库' as data_dims,ware.branch_id as data_val,'warehouse-daily-report' as stat_code,'warehouse-weight' as group1,'PUR/SEL' as group2,ware.name as txt1,
             COALESCE(detail.totalWeight,0) as val1,COALESCE(detail.totalValue,0) as val2,
             COALESCE(detail.totalUnvalue,0) as val3,COALESCE(selTotal.toatlQty,0) as val4,
             COALESCE(selTotal.toatlAmout,0) as val5
        FROM (select UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 00:00:00')) as begin_time,
                     UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 23:59:59')) as end_time,
                     DATE_SUB(p_day,INTERVAL 1 DAY) as time_val
             ) as baseTime,
             (SELECT *
                FROM uct_waste_warehouse
               WHERE parent_id = 0
                 AND state = 1
             )  AS ware
   LEFT JOIN (SELECT house.branch_id,main.FDCStockID,
                     ROUND(SUM(deat.FQty),3) as totalWeight,
                     ROUND(SUM(case when deat.value_type = 'valuable' then deat.FQty else 0 end),3) as totalValue,
                     ROUND(SUM(case when deat.value_type = 'unvaluable' then deat.FQty else 0 end),3) as totalUnvalue
                FROM (select UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 00:00:00')) as begin_time,
                             UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 23:59:59')) as end_time
                     ) as base,
                     Trans_assist_table AS deat
           LEFT JOIN Trans_main_table AS main
                  ON deat.FinterID = main.FInterID AND deat.FTranType = main.FTranType
           LEFT JOIN uct_waste_warehouse as house
                  ON SUBSTRING(main.FDCStockID,3) = house.id 
               WHERE main.FCancellation <> 0
                 AND UNIX_TIMESTAMP(deat.FDCTime) BETWEEN base.begin_time AND base.end_time 
                 AND house.parent_id = 0
                 AND house.state = 1
 AND main.FTranType = 'SOR'
                 group by house.branch_id
             ) as detail
          ON ware.branch_id = detail.branch_id
   LEFT JOIN (SELECT house.branch_id,main.FDCStockID,ROUND(SUM(deat.FQty),3) as toatlQty,
                     ROUND(SUM(deat.FAmount),3) as toatlAmout
                FROM (select UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 00:00:00')) as begin_time,
                             UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 23:59:59')) as end_time
                     ) as base,
                     Trans_assist_table AS deat
           LEFT JOIN Trans_main_table AS main
                  ON deat.FinterID = main.FInterID AND deat.FTranType = main.FTranType
           LEFT JOIN uct_waste_warehouse as house
                  ON SUBSTRING(main.FSCStockID,3) = house.id 
               WHERE main.FCancellation <> 0
                 AND UNIX_TIMESTAMP(deat.FDCTime) BETWEEN base.begin_time AND base.end_time 
                 AND house.parent_id = 0
                 AND house.state = 1
 AND main.FTranType = 'SEL' 
 AND main.FSaleStyle = 2 
 AND main.FCorrent = 1 
                 group by house.branch_id
             ) as selTotal
          ON ware.branch_id = selTotal.branch_id;


set errno=1001;


 insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, 
             group1, group2, txt1, val1, val2) 
      SELECT 'D' as time_dims,baseTime.time_val,FROM_UNIXTIME(baseTime.begin_time) as begin_time, FROM_UNIXTIME(baseTime.end_time) as end_time,
             '分部-仓库' as data_dims,ware.branch_id as data_val,'warehouse-daily-report' as stat_code,'warehouse-weight' as group1,'storage' as group2,ware.name as txt1,
             COALESCE(detail.FQty,0) as val1,COALESCE(detail.Amount,0) as val2
        FROM (select UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 00:00:00')) as begin_time,
                     UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 23:59:59')) as end_time,
                     DATE_SUB(p_day,INTERVAL 1 DAY) as time_val
             ) as baseTime,
             (SELECT *
                FROM uct_waste_warehouse
               WHERE parent_id = 0
                 AND state = 1
             )  AS ware
   LEFT JOIN (SELECT main.FRelateBrID,ROUND(SUM(main.FQty),3) as FQty,ROUND(SUM(main.FQty*cate.presell_price),3) as Amount
                FROM (SELECT stoC.FRelateBrID AS FRelateBrID,stoC.FItemID AS FItemID, 
                             if(COALESCE(unix_timestamp(stodif.FdifTime), '0') > unix_timestamp(v_new_day), COALESCE(stodif.FdifQty, 0) - COALESCE(SUM(stoiod.FDCQty), 0) + COALESCE(SUM(stoiod.FSCQty), 0) + COALESCE(SUM(stoiod.FdifQty), 0), COALESCE(stodif.FdifQty, 0) + COALESCE(SUM(stoiod.FDCQty), 0) - COALESCE(SUM(stoiod.FSCQty), 0)) AS FQty
                        FROM Accoding_stock_cate stoC
                   LEFT JOIN Accoding_stock_dif stodif
                          ON stoC.FStockID = stodif.FStockID AND stoC.FItemID = stodif.FItemID
                   LEFT JOIN Accoding_stock_iod stoiod
                          ON (convert(stoC.FStockID USING utf8) = stoiod.FStockID) AND (stoC.FItemID = stoiod.FItemID)
                                AND if(COALESCE(unix_timestamp(stodif.FdifTime), '0') > unix_timestamp(v_new_day), unix_timestamp(stoiod.FDCTime) BETWEEN unix_timestamp(v_new_day) + 1 AND COALESCE(unix_timestamp(stodif.FdifTime), '0'), unix_timestamp(stoiod.FDCTime) BETWEEN COALESCE(unix_timestamp(stodif.FdifTime) + 1, '0') AND unix_timestamp(v_new_day))
                        GROUP BY stoC.FStockID, stoC.FItemID
                     ) AS main
                JOIN uct_waste_cate cate
               WHERE cate.id = main.FItemID
                group by main.FRelateBrID
             ) as detail
          ON ware.branch_id = detail.FRelateBrID;


set errno=1002;



 insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, 
             group1, group2, txt1, val1) 
      SELECT 'D' as time_dims,baseTime.time_val,FROM_UNIXTIME(baseTime.begin_time) as begin_time, FROM_UNIXTIME(baseTime.end_time) as end_time,
             '分部-仓库' as data_dims,ware.branch_id as data_val,'warehouse-daily-report' as stat_code,'warehouse-weight' as group1,'vehicle' as group2,ware.name as txt1,
             COALESCE(detail.totalNum,0) as val1
        FROM (select UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 00:00:00')) as begin_time,
                     UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 23:59:59')) as end_time,
                     DATE_SUB(p_day,INTERVAL 1 DAY) as time_val
             ) as baseTime,
             (SELECT *
                FROM uct_waste_warehouse
               WHERE parent_id = 0
                 AND state = 1
             )  AS ware
   LEFT JOIN (SELECT ware.branch_id,ROUND(SUM(main.FTrainNum),1) as totalNum
                FROM (select UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 00:00:00')) as begin_time,
                             UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 23:59:59')) as end_time
                     ) as base,
                     Trans_main_table AS main
           LEFT JOIN Trans_log_table AS logt
                  ON main.FInterID = logt.FInterID 
           LEFT JOIN uct_waste_warehouse AS ware
                  ON main.FRelateBrID = ware.branch_id
               WHERE main.FCancellation <> 0
                 AND ware.parent_id = 0
                 AND SUBSTRING(main.FDCStockID,3) = ware.id
                 AND main.FTranType = 'SOR'
                 AND logt.FTranType = 'PUR'
                 AND logt.Tsort BETWEEN base.begin_time AND base.end_time
                 AND main.FSaleStyle = 0
                 AND logt.TsortOver = 1
                group by ware.branch_id
             ) as detail
          ON ware.branch_id = detail.branch_id;



set errno=1003;



 insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, 
             group1, group2, txt1, val1, val2, val3, val4, val5, val6, val7) 
      SELECT 'D' as time_dims,baseTime.time_val,FROM_UNIXTIME(baseTime.begin_time) as begin_time, FROM_UNIXTIME(baseTime.end_time) as end_time,
             '分部-仓库' as data_dims,warehouse.branch_id as data_val,'warehouse-daily-report' as stat_code,'sorting-group' as group1,'weight' as group2,COALESCE(warehouse.name,0) as txt1,
             COALESCE(warehouse.toatlQtySort,0) as val1,COALESCE(warehouse.toatlQtyWeig,0) as val2,
             COALESCE(warehouse.toatlQtyVal,0) as val3,COALESCE(warehouse.toatlQtyUnval,0) as val4,
             COALESCE(warehouse.handoverNum,0) as val5,COALESCE(warehouse.waitSortingNum,0) as val6,COALESCE(warehouse.sortingNum,0) as val7
        FROM (select UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 00:00:00')) as begin_time,
                     UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 23:59:59')) as end_time,
                     DATE_SUB(p_day,INTERVAL 1 DAY) as time_val
             ) as baseTime,
             (SELECT sorting.parent_id,sorting.branch_id,sorting.name,COALESCE(detail.toatlQtySort,0) as toatlQtySort,COALESCE(detail.toatlQtyWeig,0) as toatlQtyWeig,COALESCE(detail.toatlQtyVal,0) as toatlQtyVal,COALESCE(detail.toatlQtyUnval,0) as toatlQtyUnval,
                     COALESCE(vehicle.handoverNum,0) as handoverNum,COALESCE(vehicle.waitSortingNum,0) as waitSortingNum,COALESCE(vehicle.sortingNum,0) as sortingNum
                FROM (SELECT * 
                         FROM uct_waste_warehouse
                        WHERE parent_id <> 0
                          AND state = 1
                        group by id
                       order by parent_id ASC
                      ) as sorting
            LEFT JOIN (SELECT ware.id,ware.parent_id,ware.branch_id,ware.name,
                             ROUND(SUM(case when deat.disposal_way = 'sorting' then deat.FQty else 0 end),3) as toatlQtySort,
                             ROUND(SUM(case when deat.disposal_way = 'weighing' then deat.FQty else 0 end),3) as toatlQtyWeig,
                             ROUND(SUM(case when deat.value_type = 'valuable' then deat.FQty else 0 end),3) as toatlQtyVal,
                             ROUND(SUM(case when deat.value_type = 'unvaluable' then deat.FQty else 0 end),3) as toatlQtyUnval
                        FROM (select UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 00:00:00')) as begin_time,
                                     UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 23:59:59')) as end_time
                             ) as base,
                             Trans_assist_table AS deat
                   LEFT JOIN Trans_main_table AS main
                          ON deat.FinterID = main.FInterID AND deat.FTranType = main.FTranType
                   LEFT JOIN uct_waste_warehouse AS ware
                          ON main.FBillerID = ware.admin_id
                       WHERE main.FCancellation <> 0
                         AND ware.parent_id <> 0
                         AND deat.FTranType = 'SOR'
                         AND UNIX_TIMESTAMP(deat.FDCTime) BETWEEN base.begin_time AND base.end_time 
                    group by ware.id
                     ) as detail
  ON sorting.id = detail.id
           LEFT JOIN (SELECT ware.id,ware.parent_id,ware.branch_id,ware.name,
                             ROUND(SUM(case when logt.TchangeOver = 1 AND logt.Tchange BETWEEN base.begin_time AND base.end_time then main.FTrainNum else 0 end),1) as handoverNum,
 ROUND(SUM(case when logt.TchangeOver = 1 AND logt.TsortOver = 0 then main.FTrainNum else 0 end),1) as waitSortingNum,
                             ROUND(SUM(case when logt.TsortOver = 1 AND logt.Tsort BETWEEN base.begin_time AND base.end_time  then main.FTrainNum else 0 end),1) as sortingNum
                        FROM (select UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 00:00:00')) as begin_time,
                                     UNIX_TIMESTAMP(CONCAT(DATE_SUB(p_day,INTERVAL 1 DAY),' 23:59:59')) as end_time
                             ) as base,
                             Trans_main_table AS main
                   LEFT JOIN Trans_log_table AS logt
                          ON main.FInterID = logt.FInterID 
                   LEFT JOIN uct_waste_warehouse AS ware
                          ON main.FBillerID = ware.admin_id
                       WHERE main.FCancellation <> 0
                         AND ware.parent_id <> 0
                         AND main.FTranType = 'SOR'
                         AND logt.FTranType = 'PUR'
                         AND main.FSaleStyle = 0
                         AND ware.state = 1
                    group by ware.id
                     ) as vehicle
                  ON detail.id = vehicle.id
             ) as warehouse
    ORDER BY warehouse.branch_id,warehouse.toatlQtyVal DESC;



COMMIT;
  errno := 1004;

  IF errno = 1004 THEN
    o_rv := 200;
    o_err := '仓库数据生成成功.';
  END IF;
END;
$$;






DROP PROCEDURE IF EXISTS "test_lvhuan"."lh_dw_warehouse_month_mysql";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."lh_dw_warehouse_month_mysql"(IN "p_day" varchar(50),
INOUT o_rv        integer,
INOUT o_err       varchar(200)) 
LANGUAGE plpgsql AS $$
DECLARE 
    errno           int;
    v_month_begin   int;
    v_month_end     int;
    v_month         varchar(20);
    v_last_day      varchar(20);
    v_before_day    varchar(20);
    v_today_day     int;
    v_new_day       varchar(20);
BEGIN
    BEGIN
        -- Convert MySQL's UNIX_TIMESTAMP function for PostgreSQL
        v_month_begin := EXTRACT(EPOCH FROM date_trunc('MONTH', current_date));
        v_month_end := EXTRACT(EPOCH FROM date_trunc('MONTH', current_date) + interval '1 MONTH' - interval '1 second');
        v_month := TO_CHAR(date_trunc('MONTH', current_date) + interval '1 MONTH' - interval '1 day', 'YYYY-MM');
        v_last_day := TO_CHAR(current_date, 'YYYY-MM-DD');
        v_before_day := TO_CHAR(date_trunc('MONTH', current_date) - interval '1 day', 'YYYY-MM-DD');
        v_today_day := EXTRACT(EPOCH FROM (p_day::timestamp + interval '12 hours'));

        IF v_today_day > v_month_end THEN
            o_rv := 400;
            o_err := '不能给定未来的日期';
            RETURN;
        END IF;
        IF v_today_day < v_month_begin THEN
            v_new_day := v_before_day;
        END IF;
        IF v_month_begin < v_today_day AND v_today_day < v_month_end THEN
            v_new_day := v_last_day;
        END IF;  

         
       
start transaction;
set errno=1000;


 insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, 
             group1, group2, txt1, val1, val2, val3, val4, val5) 
      SELECT 'M' as time_dims,baseTime.time_val,FROM_UNIXTIME(baseTime.begin_time) as begin_time, FROM_UNIXTIME(baseTime.end_time) as end_time,
             '分部-仓库' as data_dims,ware.branch_id as data_val,'warehouse-month-report' as stat_code,'warehouse-weight' as group1,'PUR/SEL' as group2,ware.name as txt1,
             COALESCE(detail.totalWeight,0) as val1,COALESCE(detail.totalValue,0) as val2,
             COALESCE(detail.totalUnvalue,0) as val3,COALESCE(selTotal.toatlQty,0) as val4,
             COALESCE(selTotal.toatlAmout,0) as val5
        FROM (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(p_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                     UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                     TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val
             ) as baseTime,
             (SELECT *
                FROM uct_waste_warehouse
               WHERE parent_id = 0
                 AND state = 1
             )  AS ware
   LEFT JOIN (SELECT house.branch_id,main.FDCStockID,
                     ROUND(SUM(deat.FQty),3) as totalWeight,
                     ROUND(SUM(case when deat.value_type = 'valuable' then deat.FQty else 0 end),3) as totalValue,
                     ROUND(SUM(case when deat.value_type = 'unvaluable' then deat.FQty else 0 end),3) as totalUnvalue
                FROM (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(p_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                             UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                     ) as base,
                     Trans_assist_table AS deat
           LEFT JOIN Trans_main_table AS main
                  ON deat.FinterID = main.FInterID AND deat.FTranType = main.FTranType
           LEFT JOIN uct_waste_warehouse as house
                  ON SUBSTRING(main.FDCStockID,3) = house.id
               WHERE main.FCancellation <> 0
                 AND UNIX_TIMESTAMP(deat.FDCTime) BETWEEN base.begin_time AND base.end_time 
                 AND house.parent_id = 0
                 AND house.state = 1
                 AND main.FTranType = 'SOR'
                 group by house.branch_id
             ) as detail
          ON ware.branch_id = detail.branch_id
   LEFT JOIN (SELECT house.branch_id,main.FDCStockID,ROUND(SUM(deat.FQty),3) as toatlQty,ROUND(SUM(deat.FAmount),3) as toatlAmout
                FROM (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(p_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                             UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                     ) as base,
                     Trans_assist_table AS deat
           LEFT JOIN Trans_main_table AS main
                  ON deat.FinterID = main.FInterID AND deat.FTranType = main.FTranType
           LEFT JOIN uct_waste_warehouse as house
                  ON SUBSTRING(main.FSCStockID,3) = house.id
               WHERE main.FCancellation <> 0
                 AND UNIX_TIMESTAMP(deat.FDCTime) BETWEEN base.begin_time AND base.end_time 
                 AND house.parent_id = 0
                 AND house.state = 1
                 AND main.FTranType = 'SEL' 
                 AND main.FSaleStyle = 2 
                 AND main.FCorrent = 1
                 group by house.branch_id
             ) as selTotal
          ON ware.branch_id = selTotal.branch_id;

set errno=1001;


 insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, 
             group1, group2, txt1, val1, val2) 
      SELECT 'M' as time_dims,baseTime.time_val,FROM_UNIXTIME(baseTime.begin_time) as begin_time, FROM_UNIXTIME(baseTime.end_time) as end_time,
             '分部-仓库' as data_dims,ware.branch_id as data_val,'warehouse-month-report' as stat_code,'warehouse-weight' as group1,'storage' as group2,ware.name as txt1,
             COALESCE(detail.FQty,0) as val1,COALESCE(detail.Amount,0) as val2
        FROM (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(p_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                     UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                     TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val
             ) as baseTime,
             (SELECT *
                FROM uct_waste_warehouse
               WHERE parent_id = 0
                 AND state = 1
             )  AS ware
   LEFT JOIN (SELECT main.FRelateBrID,ROUND(SUM(main.FQty),3) as FQty,ROUND(SUM(main.FQty*cate.presell_price),3) as Amount
                FROM (SELECT stoC.FRelateBrID AS FRelateBrID,stoC.FItemID AS FItemID, 
                             if(COALESCE(unix_timestamp(stodif.FdifTime), '0') > unix_timestamp(v_new_day), COALESCE(stodif.FdifQty, 0) - COALESCE(SUM(stoiod.FDCQty), 0) + COALESCE(SUM(stoiod.FSCQty), 0) + COALESCE(SUM(stoiod.FdifQty), 0), COALESCE(stodif.FdifQty, 0) + COALESCE(SUM(stoiod.FDCQty), 0) - COALESCE(SUM(stoiod.FSCQty), 0)) AS FQty
                        FROM Accoding_stock_cate stoC
                   LEFT JOIN Accoding_stock_dif stodif
                          ON stoC.FStockID = stodif.FStockID AND stoC.FItemID = stodif.FItemID
                   LEFT JOIN Accoding_stock_iod stoiod
                          ON (convert(stoC.FStockID USING utf8) = stoiod.FStockID) AND (stoC.FItemID = stoiod.FItemID)
                                AND if(COALESCE(unix_timestamp(stodif.FdifTime), '0') > unix_timestamp(v_new_day), unix_timestamp(stoiod.FDCTime) BETWEEN unix_timestamp(v_new_day) + 1 AND COALESCE(unix_timestamp(stodif.FdifTime), '0'), unix_timestamp(stoiod.FDCTime) BETWEEN COALESCE(unix_timestamp(stodif.FdifTime) + 1, '0') AND unix_timestamp(v_new_day))
                        GROUP BY stoC.FStockID, stoC.FItemID
                     ) AS main
                JOIN uct_waste_cate cate
               WHERE cate.id = main.FItemID
                group by main.FRelateBrID
             ) as detail
          ON ware.branch_id = detail.FRelateBrID;

set errno=1002;


 insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, 
             group1, group2, txt1, val1) 
      SELECT 'M' as time_dims,baseTime.time_val,FROM_UNIXTIME(baseTime.begin_time) as begin_time, FROM_UNIXTIME(baseTime.end_time) as end_time,
             '分部-仓库' as data_dims,ware.branch_id as data_val,'warehouse-month-report' as stat_code,'warehouse-weight' as group1,'vehicle' as group2,ware.name as txt1,
             COALESCE(detail.totalNum,0) as val1
        FROM (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(p_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                     UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                     TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val
             ) as baseTime,
             (SELECT *
                FROM uct_waste_warehouse
               WHERE parent_id = 0
                 AND state = 1
             )  AS ware
   LEFT JOIN (SELECT ware.branch_id,ROUND(SUM(main.FTrainNum),1) as totalNum
                FROM (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(p_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                             UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                     ) as base,
                     Trans_main_table AS main
           LEFT JOIN Trans_log_table AS logt
                  ON main.FInterID = logt.FInterID 
           LEFT JOIN uct_waste_warehouse AS ware
                  ON SUBSTRING(main.FDCStockID,3) = ware.id
               WHERE main.FCancellation <> 0
                 AND ware.parent_id = 0
                 AND main.FTranType = 'SOR'
                 AND logt.FTranType = 'PUR'
                 AND logt.Tsort BETWEEN base.begin_time AND base.end_time
                 AND main.FSaleStyle = 0
                 AND logt.TsortOver = 1
                group by ware.branch_id
             ) as detail
          ON ware.branch_id = detail.branch_id;

set errno=1003;


 insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, 
             group1, group2, txt1, txt2, val1, val2, val3) 
      SELECT 'M' as time_dims,data.time_val,FROM_UNIXTIME(data.begin_time) as begin_time, FROM_UNIXTIME(data.end_time) as end_time,
             '分部-仓库' as data_dims,data.FRelateBrID as data_val,'warehouse-month-report' as stat_code,'warehouse-weight' as group1,'month-receipt' as group2,
             data.name as txt1,data.id as txt2,ROUND(data.toatlQty,3) as val1,ROUND(data.toatlQtyBefore,3) as val2,
             (case when data.toatlQtyBefore = 0 then 0 else ROUND((data.toatlQty - data.toatlQtyBefore)/data.toatlQtyBefore,3) end) as val3
        FROM (SELECT main.FRelateBrID,branch.name,ware.id,base.begin_time,base.end_time,base.time_val,
                     COALESCE(SUM(case when UNIX_TIMESTAMP(deat.FDCTime) BETWEEN base.begin_time AND base.end_time then deat.FQty else 0 end),0) as toatlQty,
                     COALESCE(SUM(case when UNIX_TIMESTAMP(deat.FDCTime) BETWEEN base.begin_time_before AND base.end_time_before then deat.FQty else 0 end),0) as toatlQtyBefore
                FROM (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(p_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                             UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                             TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                             UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(p_day, INTERVAL 2 MONTH), '%Y-%m-01 00:00:00')) as begin_time_before,
                             UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(p_day, INTERVAL 2 MONTH)), '%Y-%m-%d 23:59:59')) as end_time_before
                     ) as base,
                     Trans_assist_table AS deat
           LEFT JOIN Trans_main_table AS main
                  ON main.FInterID = deat.FinterID AND main.FTranType = deat.FTranType
           LEFT JOIN uct_waste_warehouse AS ware
                  ON SUBSTRING(main.FDCStockID,3) = ware.id
           LEFT JOIN uct_branch AS branch
                  ON main.FRelateBrID = branch.setting_key
               WHERE main.FCancellation <> 0
                 AND ware.parent_id = 0
                 AND ware.state = 1
                 AND deat.FTranType = 'SOR'
            GROUP BY main.FRelateBrID 
            ORDER BY ware.id ASC
             ) as data
       WHERE data.toatlQty > 0;

set errno=1004;

    COMMIT;
    EXCEPTION 
        WHEN OTHERS THEN
            ROLLBACK;
            o_rv := SQLSTATE;
            o_err := '仓库月数据生成失败.';
            RETURN;
    END;

    IF errno = 1004 THEN
        o_rv := 200;
        o_err := '仓库月数据生成成功.';
    END IF;

END;
$$;






-- 删除存储过程（如果存在）
DROP PROCEDURE IF EXISTS test_lvhuan.lvhuan_customer_report_data;

-- 创建存储过程
CREATE OR REPLACE PROCEDURE test_lvhuan.lvhuan_customer_report_data(
    IN p_cus_id varchar(20),
    IN p_month varchar(20),
    INOUT o_rv integer,
    INOUT o_err varchar(200)
) 
LANGUAGE plpgsql AS $$
DECLARE
    errno int;
BEGIN
    -- 开始事务
    BEGIN
        -- 初始化变量
        errno := 0;
        
        -- 插入数据
        INSERT INTO data_statistics_results (time_dims, time_val, data_dims, data_val)
        VALUES ('M', p_month, '客户', p_cus_id);
        
        errno := 1;

        -- 根据 errno 设置 o_rv 和 o_err
        IF errno = 1 THEN
            o_rv := 200;
            o_err := '成功.';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            -- 处理异常
            -- 在这里可以添加适当的异常处理代码
            ROLLBACK;
            o_rv := 400;
            o_err := '失败: ' || SQLERRM;
    END;
END;
$$;




-- 删除存储过程（如果存在）
DROP PROCEDURE IF EXISTS test_lvhuan.one_level_wall_report;

-- 创建存储过程
CREATE OR REPLACE PROCEDURE test_lvhuan.one_level_wall_report(IN region_type varchar(50)) 
LANGUAGE plpgsql AS $$
DECLARE 
    group_field varchar(50);
    region_where varchar(50);
    nowdate date := CURRENT_DATE - INTERVAL '1 day';
BEGIN
    IF region_type = 'area' THEN
        group_field := 'cf.province, cf.city, cf.area';
        region_where := 'ad.name = cf.area';
    ELSIF region_type = 'city' THEN
        group_field := 'cf.province, cf.city';
        region_where := 'ad.name = cf.city';
    ELSE
        group_field := 'cf.province';
        region_where := 'ad.name = cf.province';
    END IF;

    -- 创建动态SQL
    EXECUTE 'INSERT INTO uct_one_level_day_wall_report(adcode, name, weight, carbon, report_date)
             SELECT ad.adcode, c3.name, ROUND(SUM(FQty), 2) AS weight, ROUND(SUM(FQty * c2.carbon_parm), 2) AS carbon, $1 AS report_date
             FROM Trans_main_table mt
             JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND DATE_TRUNC(''day'', mt2.FDate) = DATE_TRUNC(''day'', $1)
             JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
             JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
             JOIN uct_adcode ad ON ' || region_where || '
             JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType
             JOIN uct_waste_cate c ON c.id = at.FItemID
             JOIN uct_waste_cate c2 ON c.parent_id = c2.id
             JOIN uct_waste_cate c3 ON c2.parent_id = c3.id
             WHERE mt.FTranType IN (''SOR'',''SEL'') AND mt.FSaleStyle IN (''0'',''1'') AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7
             GROUP BY ' || group_field || ', c3.name
             ORDER BY weight'
    USING nowdate;

    -- 创建另一个动态SQL
    EXECUTE 'REPLACE INTO uct_one_level_accumulate_wall_report(adcode, name, weight, carbon)
             SELECT ad.adcode, c3.name, ROUND(SUM(FQty), 2) AS weight, ROUND(SUM(FQty * c2.carbon_parm), 2) AS carbon
             FROM Trans_main_table mt
             JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND DATE_TRUNC(''day'', mt2.FDate) = DATE_TRUNC(''day'', $1)
             JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
             JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
             JOIN uct_adcode ad ON ' || region_where || '
             JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType
             JOIN uct_waste_cate c ON c.id = at.FItemID
             JOIN uct_waste_cate c2 ON c.parent_id = c2.id
             JOIN uct_waste_cate c3 ON c2.parent_id = c3.id
             WHERE mt.FTranType IN (''SOR'',''SEL'') AND mt.FSaleStyle IN (''0'',''1'') AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7
             GROUP BY ' || group_field || ', c3.name
             ORDER BY weight'
    USING nowdate;
END;
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."operate-daily-report";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."operate-daily-report"()
LANGUAGE plpgsql
AS $$
DECLARE
    _test_date DATE := '2020-01-01';
BEGIN
    -- 开始事务
    START TRANSACTION;
    
    WHILE _test_date < CURRENT_DATE LOOP



insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code, 'stock-in' as group1 ,  round(sum(COALESCE(mt.TalFQty,0)),2) as val1, round(sum(COALESCE(mt.TalFQty,0)),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(mt.TalFQty,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0) as val3 from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo 
right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle != '2' and mt.FTranType in ('SOR','SEL')  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'stock-in' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'gross-profit' as group1 ,  
round(SUM(CASE mt."FTranType"   WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   ELSE '0' END),2) as val1, 
round(SUM(CASE mt."FTranType"   WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   ELSE '0' END),2) - COALESCE(r.val1,0) as val2, 
COALESCE(round((round(SUM(CASE mt."FTranType"   WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   ELSE '0' END),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0) as val3 
from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo  right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle != '2' and mt.FTranType in ('SOR','SEL')  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'gross-profit' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,group3,val1) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims , mt2.FEmpID as data_val, 'operate-daily-report' as stat_code, 'order-detail-loss-list' as group1, mt.FBillNo group2, c.name group3,   round(SUM(CASE mt."FTranType"   WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   ELSE '0' END),2) as val1 from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo join uct_waste_customer c on c.id = mt2.FSupplyID 
where  mt.FCancellation = '1' and mt.FSaleStyle != '2' and mt.FTranType in ('SOR','SEL')  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   group by mt.FBillNo having  round(SUM(CASE mt."FTranType"   WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   ELSE '0' END),2) < 0; 

insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,group3,val1) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims , mt2.FEmpID as data_val, 'operate-daily-report' as stat_code , 'order-detail-profit-list' as group1, mt.FBillNo as group2, c.name as group3,   round(SUM(CASE mt."FTranType"   WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   ELSE '0' END),2) as val1 from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo join uct_waste_customer c on c.id = mt2.FSupplyID 
where  mt.FCancellation = '1' and mt.FSaleStyle != '2' and mt.FTranType in ('SOR','SEL')  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   group by mt.FBillNo having  round(SUM(CASE mt."FTranType"   WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   ELSE '0' END),2) > 0; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3)  select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'service-cost' as group1 , 'transport-cost' as group2 ,  round(sum(COALESCE(mt2.TalSecond,0)),2) as val1, round(sum(COALESCE(mt2.TalSecond,0)),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(mt2.TalSecond,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0) as val3 from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo 
right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle != '2' and mt.FTranType in ('SOR','SEL')  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'service-cost' and r.group2 = 'transport-cost' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'service-cost' as group1, 'sorting-cost' as group2 ,  round(SUM(CASE mt."FTranType"  WHEN  'SOR' THEN COALESCE(mt."TalFrist",0) ELSE 0 END),2) as val1, round(SUM(CASE mt."FTranType"  WHEN  'SOR' THEN COALESCE(mt."TalFrist",0) ELSE 0 END),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(SUM(CASE mt."FTranType"  WHEN  'SOR' THEN COALESCE(mt."TalFrist",0) ELSE 0 END),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0) as val3 from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo 
right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle != '2' and mt.FTranType = 'SOR'  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'service-cost' and r.group2 = 'sorting-cost' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'service-cost' as group1 , 'consumables-cost' as group2 ,  round(SUM(CASE mt."FTranType"  WHEN  'SOR' THEN COALESCE(mt."TalSecond",0) ELSE 0 END),2) as val1, round(SUM(CASE mt."FTranType"  WHEN  'SOR' THEN COALESCE(mt."TalSecond",0) ELSE 0 END),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(SUM(CASE mt."FTranType"  WHEN  'SOR' THEN COALESCE(mt."TalSecond",0) ELSE 0 END),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0) as val3   from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo 
right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle != '2' and mt.FTranType = 'SOR'  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'service-cost' and r.group2 = 'consumables-cost' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'service-cost' as group1 , 'lw-disposal-cost' as group2,  round(sum(COALESCE(at.FAmount,0) + COALESCE(ft.FFeeAmount,0)),2) as val1 , round(sum(COALESCE(at.FAmount,0) + COALESCE(ft.FFeeAmount,0)),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(at.FAmount,0) + COALESCE(ft.FFeeAmount,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0) as val3 from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo  left join Trans_fee_table ft on mt2.FInterID = ft.FInterID and  mt2.FTranType = ft.FTranType and ft.FFeeID = '低值废弃物处理费'  left join  Trans_assist_table at on  at.FInterID = mt.FInterID and at.FTranType = mt.FTranType    and  at.value_type =  'unvaluable'
right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle != '2' and mt.FTranType = 'SOR'  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'service-cost' and r.group2 = 'lw-disposal-cost' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'order-count' as group1 ,sum(if(date_format(mt.FDate,'%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY) and  mt.FCorrent = 1,1,0)) as val1, sum(if(mt2.FCorrent = 0,1,0)) as val2, sum(case date_format(mt2.FDate, '%Y-%m-%d')  when DATE_SUB(_test_date,INTERVAL 1 DAY)  then 1 else 0 end ) as val3  from Trans_main_table mt right join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo 
right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FSaleStyle != '2' and mt.FTranType in ('SOR','SEL')  and  mt2.FTranType = 'PUR'  right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'order-count' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3,val4) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'customer-evaluation' as group1, 'service-result' as group2,  max(COALESCE(pe.remove_level_star,0)) as val1,min(COALESCE(pe.remove_level_star,0)) as val2,round(avg(COALESCE(pe.remove_level_star,0)),2) as val3, COALESCE(round(avg(COALESCE(pe.remove_level_star,0)) - COALESCE(r.val3,0)/COALESCE(r.val3,0),2),0) as val4 from uct_waste_purchase_evaluate pe join Trans_main_table mt on  pe.purchase_id = mt.FInterID 
right join lh_dw.data_statistics_results as r on r.data_val = mt.FEmpID and mt.FCancellation = 1 and mt.FSaleStyle != 2 and  mt.FTranType = 'PUR' and FROM_UNIXTIME(pe.createtime,'%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'customer-evaluation' and r.group2 = 'service-result' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3,val4) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'customer-evaluation' as group1 , 'service-timely' as group2,  max(COALESCE(pe.remove_fast_star,0)) as val1,min(COALESCE(pe.remove_fast_star,0)) as val2,round(avg(COALESCE(pe.remove_fast_star,0)),2) as val3, COALESCE(round(avg(COALESCE(pe.remove_fast_star,0)) - COALESCE(r.val3,0)/COALESCE(r.val3,0),2),0) as val4 from uct_waste_purchase_evaluate pe join Trans_main_table mt on  pe.purchase_id = mt.FInterID 
right join lh_dw.data_statistics_results as r on r.data_val = mt.FEmpID and mt.FCancellation = 1 and mt.FSaleStyle != 2 and  mt.FTranType = 'PUR' and FROM_UNIXTIME(pe.createtime,'%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'customer-evaluation' and r.group2 = 'service-timely' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3,val4) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'customer-evaluation' as group1 , 'service-manner' as group2,  max(COALESCE(pe.service_attitude_star,0)) as val1,min(COALESCE(pe.service_attitude_star,0)) as val2,round(avg(COALESCE(pe.service_attitude_star,0)),2) val3, COALESCE(round(avg(COALESCE(pe.service_attitude_star,0)) - COALESCE(r.val3,0)/COALESCE(r.val3,0),2),0) as val4 from uct_waste_purchase_evaluate pe join Trans_main_table mt on  pe.purchase_id = mt.FInterID 
right join lh_dw.data_statistics_results as r on r.data_val = mt.FEmpID and mt.FCancellation = 1 and mt.FSaleStyle != 2 and  mt.FTranType = 'PUR' and FROM_UNIXTIME(pe.createtime,'%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'customer-evaluation' and r.group2 = 'service-manner' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,group3,txt1,val1,val2,val3,val4,val5,val6,val7)select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims , mt2.FEmpID as data_val, 'operate-daily-report' as stat_code, 'order-detail-list' as group1, mt.FBillNo as group2, c.customer_code group3, c.name as txt1, round(SUM(CASE mt."FTranType"   WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) -COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   ELSE '0' END),2) as val1,round(sum(COALESCE(mt.TalFQty,0)),2) as val2,  round(sum(COALESCE(at.FQty,0)),2) as val3,round(sum(COALESCE(at.FAmount,0) + COALESCE(ft.FFeeAmount,0)),2) as val4 , COALESCE(remove_fast_star,0) as val5 , COALESCE(remove_level_star,0) as val6, COALESCE(service_attitude_star,0) as val7  from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo join uct_waste_customer c on c.id = mt2.FSupplyID  left join Trans_fee_table ft on mt2.FInterID = ft.FInterID and  mt2.FTranType = ft.FTranType and ft.FFeeID = '低值废弃物处理费'  left join  Trans_assist_table at on  at.FInterID = mt.FInterID and at.FTranType = mt.FTranType    and  at.value_type =  'unvaluable'  left join uct_waste_purchase_evaluate pe on pe.purchase_id = mt2.FInterID 
where  mt.FCancellation = '1' and mt.FSaleStyle != '2' and mt.FTranType in ('SOR','SEL')  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   group by mt.FBillNo;



insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'operate-analyse' as group1, 'transport-cost' as group2 , COALESCE(round(sum(COALESCE(mt2.TalSecond,0)) / sum(COALESCE(mt2.TalFQty,0)) * 1000,3),0) as val1, COALESCE(round(sum(COALESCE(mt2.TalSecond,0)) / sum(COALESCE(mt2.TalFQty,0)) * 1000,3) - COALESCE(r.val1,0),0) as val2, COALESCE(round((round(sum(COALESCE(mt2.TalSecond,0)) / sum(COALESCE(mt2.TalFQty,0) * 1000),3) - COALESCE(r.val1,0))/COALESCE(r.val1,0),3),0) as val3 from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo 
right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle != '2' and mt.FTranType = 'SOR'  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'operate-analyse' and r.group2 = 'transport-cost' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'operate-analyse' as group1, 'sorting-cost' as group2 , COALESCE(round(sum(COALESCE(mt.TalFrist,0)) / sum(COALESCE(mt2.TalFQty,0)) * 1000,3),0) as val1, COALESCE(round(sum(COALESCE(mt.TalFrist,0)) / sum(COALESCE(mt2.TalFQty,0)) * 1000,3) - COALESCE(r.val1,0),0) as val2, COALESCE(round((round(sum(COALESCE(mt.TalFrist,0)) / sum(COALESCE(mt2.TalFQty,0) * 1000),3) - COALESCE(r.val1,0))/COALESCE(r.val1,0),3),0) as val3 from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo 
right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FSaleStyle != '2' and mt.FTranType in ('SOR','SEL')  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'operate-analyse' and r.group2 = 'sorting-cost' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'operate-analyse' as group1 , 'consumables-cost' as group2 , COALESCE(round(sum(COALESCE(mt.TalSecond,0)) / sum(COALESCE(mt2.TalFQty,0)) * 1000,3),0) as val1, COALESCE(round(sum(COALESCE(mt.TalSecond,0)) / sum(COALESCE(mt2.TalFQty,0)) * 1000,3) - COALESCE(r.val1,0),0), COALESCE(round((round(sum(COALESCE(mt.TalSecond,0)) / sum(COALESCE(mt2.TalFQty,0) * 1000),3) - COALESCE(r.val1,0))/COALESCE(r.val1,0),3),0) as val3 from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo 
right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FSaleStyle != '2' and mt.FTranType in ('SOR','SEL')  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'operate-analyse' and r.group2 = 'consumables-cost' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'operate-daily-report' as stat_code , 'operate-analyse' as group1 , 'lw-disposal-cost' as group2,  COALESCE(round(sum(COALESCE(at.FAmount,0) + COALESCE(ft.FFeeAmount,0)) / sum(COALESCE(mt2.TalFQty,0)) * 1000,3),0) as val1, round(sum(COALESCE(at.FAmount,0) + COALESCE(ft.FFeeAmount,0)) / sum(COALESCE(mt2.TalFQty,0)) * 1000,3) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(at.FAmount,0) + COALESCE(ft.FFeeAmount,0)) / sum(COALESCE(mt2.TalFQty,0)) * 1000,3) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0) as val3 from Trans_main_table mt join Trans_main_table mt2 on  mt.FBillNo = mt2.FBillNo  left join Trans_fee_table ft on mt2.FInterID = ft.FInterID and  mt2.FTranType = ft.FTranType and ft.FFeeID = '低值废弃物处理费'  left join  Trans_assist_table at on  at.FInterID = mt.FInterID and at.FTranType = mt.FTranType    and  at.value_type =  'unvaluable'
right join lh_dw.data_statistics_results as r on r.data_val = mt2.FEmpID and mt.FCancellation = '1' and mt.FSaleStyle != '2' and mt.FTranType in ('SOR','SEL')  and  mt2.FTranType = 'PUR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   right join uct_admin a on cast(a.id as char ) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'operate-daily-report' and  r.group1 = 'operate-analyse' and r.group2 = 'lw-disposal-cost' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id in(32,36) group by a.id; 

        _test_date := _test_date + INTERVAL '1 DAY';
    END LOOP;

    -- 提交事务
    COMMIT;
END;
$$;





DROP PROCEDURE IF EXISTS test_lvhuan."operate-daily-report-v1";

CREATE OR REPLACE PROCEDURE test_lvhuan."operate-daily-report-v1"() 
LANGUAGE plpgsql
AS $$
DECLARE
    _test_date DATE := '2020-01-01';
	rank INT := 0;
    classname VARCHAR := NULL;
BEGIN
    -- 开始事务
    START TRANSACTION;
    
    WHILE _test_date < CURRENT_DATE LOOP
	
    INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, "group", val1, val2, val3) 
    SELECT 'D' AS time_dims, DATE_SUB(_test_date, INTERVAL 1 DAY) AS time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) AS begin_time, 
           CAST(CAST(_test_date AS DATE) AS DATETIME) AS end_time, '分部-部门' AS data_dims, bs.key AS data_val, 'operate-daily-report-v1' AS stat_code, 
           'stock-in' AS "group", ROUND(SUM(COALESCE(mt.TalFQty,0)), 2) AS val1, ROUND(SUM(COALESCE(mt.TalFQty,0)), 2) - COALESCE(r.val1,0) AS val2, 
           COALESCE(ROUND((ROUND(SUM(COALESCE(mt.TalFQty,0)), 2) - COALESCE(r.val1,0))/COALESCE(r.val1,0), 2), 0)*100 AS val3 
    FROM Trans_main_table mt 
    JOIN Trans_main_table mt2 ON mt.FBillNo = mt2.FBillNo 
    RIGHT JOIN lh_dw.data_statistics_results AS r ON r.data_val = CONCAT(mt.FRelateBrID,'-',mt.FDeptID) AND mt.FCancellation = '1' AND mt.FCorrent = '1' 
            AND mt.FSaleStyle IN ('0','1','3') AND mt.FTranType IN ('SOR','SEL') AND mt2.FTranType = 'PUR' AND mt."Date" = DATE_SUB(_test_date, INTERVAL 1 DAY) 
    RIGHT JOIN (SELECT CONCAT(b.setting_key,'-',s.setting_key) AS "key" FROM uct_branch b JOIN uct_waste_settings s ON s."group" = 'service_department') AS bs 
            ON bs.key = r.data_val AND r.time_dims = 'D' AND r.time_val = FROM_UNIXTIME(UNIX_TIMESTAMP(_test_date)-60*60*48, '%Y-%m-%d') 
            AND r.data_dims = '分部-部门' AND r.stat_code = 'operate-daily-report-v1' AND r."group" = 'stock-in' 
    GROUP BY bs.key;	

    INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, "group1", val1, val2, val3) 
    SELECT 'D' AS time_dims, DATE_SUB(_test_date, INTERVAL 1 DAY) AS time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) AS begin_time, 
           CAST(CAST(_test_date AS DATE) AS DATETIME) AS end_time, '分部-部门' AS data_dims, bs.key AS data_val, 'operate-daily-report-v1' AS stat_code, 
           'gross-profit' AS "group1", ROUND(SUM(COALESCE(mt.TalFQty,0)), 2) AS val1, ROUND(SUM(COALESCE(mt.TalFQty,0)), 2) - COALESCE(r.val1,0) AS val2, 
           COALESCE(ROUND((ROUND(SUM(COALESCE(mt.TalFQty,0)), 2) - COALESCE(r.val1,0))/COALESCE(r.val1,0), 2), 0)*100 AS val3 
    FROM Trans_main_table mt 
    JOIN Trans_main_table mt2 ON mt.FBillNo = mt2.FBillNo 
    RIGHT JOIN lh_dw.data_statistics_results AS r ON r.data_val = CONCAT(mt.FRelateBrID,'-',mt.FDeptID) AND mt.FCancellation = '1' AND mt.FCorrent = '1' 
            AND mt.FSaleStyle != '2' AND mt.FTranType IN ('SOR','SEL') AND mt2.FTranType = 'PUR' AND mt."Date" = DATE_SUB(_test_date, INTERVAL 1 DAY) 
    RIGHT JOIN (SELECT CONCAT(b.setting_key,'-',s.setting_key) AS "key" FROM uct_branch b JOIN uct_waste_settings s ON s."group" = 'service_department') AS bs 
            ON bs.key = r.data_val AND r.time_dims = 'D' AND r.time_val = FROM_UNIXTIME(UNIX_TIMESTAMP(_test_date)-60*60*48, '%Y-%m-%d') 
            AND r.data_dims = '分部-部门' AND r.stat_code = 'operate-daily-report-v1' AND r."group1" = 'gross-profit' 
    GROUP BY bs.key;



    INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, "group1", "group2", val1, val2, val3) 
    SELECT 'D' AS time_dims, DATE_SUB(_test_date, INTERVAL 1 DAY) AS time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) AS begin_time, 
           CAST(CAST(_test_date AS DATE) AS DATETIME) AS end_time, '分部-部门' AS data_dims, bs.key AS data_val, 'operate-daily-report-v1' AS stat_code, 
           'service-cost' AS "group1", 'transport-cost' AS "group2", ROUND(SUM(COALESCE(mt2.TalSecond,0)), 2) AS val1, 
           ROUND(SUM(COALESCE(mt2.TalSecond,0)), 2) - COALESCE(r.val1,0) AS val2, 
           COALESCE(ROUND((ROUND(SUM(COALESCE(mt2.TalSecond,0)), 2) - COALESCE(r.val1,0))/COALESCE(r.val1,0), 2), 0)*100 AS val3 
    FROM Trans_main_table mt 
    JOIN Trans_main_table mt2 ON mt.FBillNo = mt2.FBillNo 
    RIGHT JOIN lh_dw.data_statistics_results AS r ON r.data_val = CONCAT(mt.FRelateBrID,'-',mt.FDeptID) AND mt.FCancellation = '1' 
            AND mt.FCorrent = '1' AND mt.FSaleStyle != '2' AND mt.FTranType IN ('SOR','SEL') AND mt2.FTranType = 'PUR' 
            AND mt."Date" = DATE_SUB(_test_date, INTERVAL 1 DAY) 
    RIGHT JOIN (SELECT CONCAT(b.setting_key,'-',s.setting_key) AS "key" FROM uct_branch b JOIN uct_waste_settings s ON s."group" = 'service_department') AS bs 
            ON bs.key = r.data_val AND r.time_dims = 'D' AND r.time_val = FROM_UNIXTIME(UNIX_TIMESTAMP(_test_date)-60*60*48, '%Y-%m-%d') 
            AND r.data_dims = '分部-部门' AND r.stat_code = 'operate-daily-report-v1' AND r."group1" = 'service-cost' AND r."group2" = 'transport-cost' 
    GROUP BY bs.key;

    INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, "group1", "group2", val1, val2, val3) 
    SELECT 'D' AS time_dims, DATE_SUB(_test_date, INTERVAL 1 DAY) AS time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) AS begin_time, 
           CAST(CAST(_test_date AS DATE) AS DATETIME) AS end_time, '分部-部门' AS data_dims, bs.key AS data_val, 'operate-daily-report-v1' AS stat_code, 
           'service-cost' AS "group1", 'sorting-cost' AS "group2", ROUND(SUM(CASE mt."FTranType"  WHEN  'SOR' THEN COALESCE(mt."TalFrist",0) ELSE 0 END), 2) AS val1, 
           ROUND(SUM(CASE mt."FTranType"  WHEN  'SOR' THEN COALESCE(mt."TalFrist",0) ELSE 0 END), 2) - COALESCE(r.val1,0) AS val2, 
           COALESCE(ROUND((ROUND(SUM(CASE mt."FTranType"  WHEN  'SOR' THEN COALESCE(mt."TalFrist",0) ELSE 0 END), 2) - COALESCE(r.val1,0))/COALESCE(r.val1,0), 2), 0)*100 AS val3 
    FROM Trans_main_table mt 
    JOIN Trans_main_table mt2 ON mt.FBillNo = mt2.FBillNo 
    RIGHT JOIN lh_dw.data_statistics_results AS r ON r.data_val = CONCAT(mt.FRelateBrID,'-',mt.FDeptID) AND mt.FCancellation = '1' 
            AND mt.FCorrent = '1' AND mt.FSaleStyle != '2' AND mt.FTranType = 'SOR' AND mt2.FTranType = 'PUR' 
            AND mt.Date = DATE_SUB(_test_date, INTERVAL 1 DAY) 
    RIGHT JOIN (SELECT CONCAT(b.setting_key,'-',s.setting_key) AS "key" FROM uct_branch b JOIN uct_waste_settings s ON s."group" = 'service_department') AS bs 
            ON bs.key = r.data_val AND r.time_dims = 'D' AND r.time_val = FROM_UNIXTIME(UNIX_TIMESTAMP(_test_date)-60*60*48, '%Y-%m-%d') 
            AND r.data_dims = '分部-部门' AND r.stat_code = 'operate-daily-report-v1' AND r."group1" = 'service-cost' AND r."group2" = 'sorting-cost' 
    GROUP BY bs.key;

        INSERT INTO lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,"group1","group2",val1,val2,val3) 
        SELECT 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, 
               CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部-部门' as data_dims, bs.key as data_val , 'operate-daily-report-v1' as stat_code , 
               'service-cost' as "group1", 'consumables-cost' as "group2",  round(SUM(COALESCE(mt."TalSecond",0)),2) as val1, 
               round(SUM(COALESCE(mt."TalSecond",0)),2) - COALESCE(r.val1,0) as val2, 
               COALESCE(round((round(SUM(COALESCE(mt."TalSecond",0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 
        FROM Trans_main_table mt 
        JOIN Trans_main_table mt2 ON mt.FBillNo = mt2.FBillNo 
        RIGHT JOIN lh_dw.data_statistics_results as r ON r.data_val = CONCAT(mt.FRelateBrID,'-',mt.FDeptID) AND mt.FCancellation = '1' 
                AND mt.FCorrent = '1' AND mt.FSaleStyle != '2' AND mt.FTranType = 'SOR' AND mt2.FTranType = 'PUR' 
                AND mt."Date" = DATE_SUB(_test_date,INTERVAL 1 DAY) 
        RIGHT JOIN (SELECT CONCAT(b.setting_key,'-',s.setting_key) as "key" FROM uct_branch b JOIN uct_waste_settings s ON s."group" = 'service_department') as bs 
                ON bs.key = r.data_val AND r.time_dims = 'D' AND r.time_val = FROM_UNIXTIME(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') 
                AND r.data_dims = '分部-部门' AND r.stat_code = 'operate-daily-report-v1' AND r."group1" = 'service-cost' AND r."group2" = 'consumables-cost' 
        GROUP BY bs.key;

        INSERT INTO lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,"group1","group2",val1,val2,val3) 
        SELECT 'D' as time_dims, DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, 
               CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部-部门' as data_dims, bs.key as data_val , 'operate-daily-report-v1' as stat_code , 
               'service-cost' as "group1", 'lw-disposal-cost' as "group2",  round(sum(COALESCE(at.FAmount,0) + COALESCE(ft.FFeeAmount,0)),2) as val1, 
               round(sum(COALESCE(at.FAmount,0) + COALESCE(ft.FFeeAmount,0)),2) - COALESCE(r.val1,0) as val2, 
               COALESCE(round((round(sum(COALESCE(at.FAmount,0) + COALESCE(ft.FFeeAmount,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0) as val3 
        FROM Trans_main_table mt 
        JOIN Trans_main_table mt2 ON mt.FBillNo = mt2.FBillNo 
        LEFT JOIN Trans_fee_table ft ON mt2.FInterID = ft.FInterID AND mt2.FTranType = ft.FTranType AND ft.FFeeID = '低值废弃物处理费'  
        LEFT JOIN Trans_assist_table at ON at.FInterID = mt.FInterID AND at.FTranType = mt.FTranType AND at.value_type = 'unvaluable'
        RIGHT JOIN lh_dw.data_statistics_results as r ON r.data_val = CONCAT(mt.FRelateBrID,'-',mt.FDeptID) AND mt.FCancellation = '1' 
                AND mt.FCorrent = '1' AND mt.FSaleStyle != '2' AND mt.FTranType = 'SOR' AND mt2.FTranType = 'PUR' 
                AND mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY) 
        RIGHT JOIN (SELECT CONCAT(b.setting_key,'-',s.setting_key) as "key" FROM uct_branch b JOIN uct_waste_settings s ON s."group" = 'service_department') as bs 
                ON bs.key = r.data_val AND r.time_dims = 'D' AND r.time_val = FROM_UNIXTIME(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') 
                AND r.data_dims = '分部-部门' AND r.stat_code = 'operate-daily-report-v1' AND r."group1" = 'service-cost' AND r."group2" = 'lw-disposal-cost' 
        GROUP BY bs.key;


        INSERT INTO lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,"group1",val1,val2,val3) 
        SELECT 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, 
               CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, 
               CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, 
               '分部-部门' as data_dims, bs.key as data_val , 'operate-daily-report-v1' as stat_code , 
               'order-count' as "group1",
               SUM(IF(DATE_FORMAT(mt."FDate", '%Y-%m-%d') = DATE_SUB(_test_date, INTERVAL 1 DAY) AND mt."FCorrent" = 1, 1, 0)) as val1,
               SUM(IF(mt2."FCorrent" = 0, 1, 0)) as val2,
               SUM(CASE DATE_FORMAT(mt2."FDate", '%Y-%m-%d') WHEN DATE_SUB(_test_date, INTERVAL 1 DAY) THEN 1 ELSE 0 END) as val3
        FROM Trans_main_table mt 
        RIGHT JOIN Trans_main_table mt2 ON mt."FBillNo" = mt2."FBillNo" 
        RIGHT JOIN lh_dw.data_statistics_results as r ON r.data_val = CONCAT(mt."FRelateBrID", '-', mt."FDeptID") 
                AND mt."FCancellation" = '1' AND mt."FSaleStyle" != '2' 
                AND mt."FTranType" IN ('SOR', 'SEL')  AND  mt2."FTranType" = 'PUR' 
        RIGHT JOIN (SELECT CONCAT(b."setting_key", '-', s."setting_key") as "key" 
                    FROM uct_branch b JOIN uct_waste_settings s ON s."group" = 'service_department') as bs 
                ON bs."key" = r.data_val AND r.time_dims = 'D' 
                AND r.time_val = FROM_UNIXTIME(UNIX_TIMESTAMP(_test_date)-60*60*48, '%Y-%m-%d') 
                AND r.data_dims = '分部-部门' AND r.stat_code = 'operate-daily-report-v1' 
                AND r."group1" = 'order-count'   
        GROUP BY bs."key";

        INSERT INTO lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,"group1",val1,val2) 
        SELECT 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, 
               CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, 
               CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, 
               '分部-部门' as data_dims, bs.key as data_val , 'operate-daily-report-v1' as stat_code , 
               'customer-count' as "group1", 
               COUNT(c."id") as val1,
               SUM(IF(FROM_UNIXTIME(createtime, '%Y-%m-%d') = DATE_SUB(_test_date, INTERVAL 1 DAY), 1, 0)) as val2
        FROM uct_waste_customer c
        RIGHT JOIN lh_dw.data_statistics_results as r ON r.data_val = CONCAT(c."branch_id", '-', c."service_department") 
                AND c."branch_id" IS NOT NULL AND c."service_department" IS NOT NULL AND c."state" = 'enabled'  
        RIGHT JOIN (SELECT CONCAT(b."setting_key", '-', s."setting_key") as "key" 
                    FROM uct_branch b JOIN uct_waste_settings s ON s."group" = 'service_department') as bs 
                ON bs."key" = r.data_val AND r.time_dims = 'D' 
                AND r.time_val = FROM_UNIXTIME(UNIX_TIMESTAMP(_test_date)-60*60*48, '%Y-%m-%d') 
                AND r.data_dims = '分部-部门' AND r.stat_code = 'operate-daily-report-v1' 
                AND r."group1" = 'customer-count'   
        GROUP BY bs."key";   

        INSERT INTO lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,stat_code,group1,group2,val1,val2,val3,data_val) 
        SELECT rows.time_dims,rows.time_val,rows.begin_time,rows.end_time,rows.data_dims,rows.stat_code,rows.group1,rows.group2,rows.val1,rows.val2,
               CASE WHEN classname = rows.data_val THEN rank + 1 ELSE 1 END as rank,
               classname as data_val
        FROM (SELECT 'D' as time_dims , DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, 
                     CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) as begin_time , 
                     CAST(CAST(_test_date AS DATE) AS DATETIME) as end_time , 
                     '分部-部门' as data_dims , 
                     concat(a.branch_id,'-',if(ga.group_id = 32,1,2)) as data_val , 
                     'operate-daily-report-v1' as stat_code , 
                     'performance-profit-weight' as group1,  
                     a.nickname as group2,
                     round(SUM(CASE mt."FTranType"   
                                WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   
                                              - COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   
                                WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   
                                ELSE '0' 
                             END),2) as val1, 
                     round(sum(COALESCE(mt.TalFQty,0)),2) as val2
              FROM Trans_main_table mt 
              JOIN Trans_main_table mt2 ON  mt."FBillNo" = mt2."FBillNo"   
                                       AND mt.FCancellation = '1' 
                                       AND mt.FCorrent = '1' 
                                       AND mt.FSaleStyle != '2' 
                                       AND mt.FTranType IN ('SOR','SEL')  
                                       AND mt2.FTranType = 'PUR' 
                                       AND mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   
              RIGHT JOIN uct_admin a ON cast(a.id as char ) = mt2.FEmpID 
              JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id IN (32,36) 
              GROUP BY a.id 
              ORDER BY concat(a.branch_id,'-',if(ga.group_id = 32,1,2)), round(sum(COALESCE(mt.TalFQty,0)),2) DESC 
        ) as rows;
        
        INSERT INTO lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,stat_code,group1,group2,val1,val2,val3,val4,data_val) 
        SELECT rows.time_dims,rows.time_val,rows.begin_time,rows.end_time,rows.data_dims,rows.stat_code,rows.group1,rows.group2,rows.val1,rows.val2,rows.val3,
               CASE WHEN classname = rows.data_val THEN rank + 1 ELSE 1 END as rank,
               classname as data_val
        FROM (SELECT 'D' as time_dims , DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, 
                     CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) as begin_time , 
                     CAST(CAST(_test_date AS DATE) AS DATETIME) as end_time , 
                     '分部-部门' as data_dims , 
                     concat(a.branch_id,'-',if(ga.group_id = 32,1,2)) as data_val , 
                     'operate-daily-report-v1' as stat_code , 
                     'performance-evaluation' as group1, 
                     a.nickname as group2 , 
                     round(avg(COALESCE(pe.remove_level_star,0)),3) as val1, 
                     round(avg(COALESCE(pe.remove_fast_star,0)),3) as val2, 
                     round(avg(COALESCE(pe.service_attitude_star,0)),3) as val3  
              FROM uct_waste_purchase_evaluate pe 
              JOIN Trans_main_table mt ON pe.purchase_id = mt.FInterID 
                                      AND mt.FCancellation = '1' 
                                      AND mt.FSaleStyle != '2' 
                                      AND mt.FTranType = 'PUR' 
                                      AND FROM_UNIXTIME(pe.createtime,'%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY) 
              RIGHT JOIN uct_admin a ON cast(a.id as char ) = mt.FEmpID   
              JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id IN (32,36) 
              GROUP BY a.id 
              ORDER BY concat(a.branch_id,'-',if(ga.group_id = 32,1,2)),  COALESCE(pe.remove_level_star,0)+COALESCE(pe.remove_fast_star,0)+COALESCE(pe.service_attitude_star,0) DESC
        ) as rows;


        INSERT INTO lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,stat_code,group1,group2,val1,val2,data_val) 
        SELECT rows.time_dims,rows.time_val,rows.begin_time,rows.end_time,rows.data_dims,rows.stat_code,rows.group1,rows.group2,rows.val1,
               CASE WHEN classname = rows.data_val THEN rank + 1 ELSE 1 END,
               rows.data_val
        FROM (SELECT 'D' as time_dims , DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, 
                     CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) as begin_time , 
                     CAST(CAST(_test_date AS DATE) AS DATETIME) as end_time , 
                     '分部-部门' as data_dims , 
                     concat(a.branch_id,'-',if(ga.group_id = 32,1,2)) as data_val , 
                     'operate-daily-report-v1' as stat_code , 
                     'performance-loss' as group1,  
                     a.nickname as group2 , 
                     round(SUM(CASE mt."FTranType"   
                                WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   
                                              - COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   
                                WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   
                                ELSE '0' 
                             END),2) as val1  
              FROM Trans_main_table mt 
              JOIN Trans_main_table mt2 ON  mt."FBillNo" = mt2."FBillNo"   
                                       AND mt.FCancellation = '1' 
                                       AND mt.FSaleStyle != '2' 
                                       AND mt.FTranType IN ('SOR','SEL')  
                                       AND mt2.FTranType = 'PUR' 
                                       AND mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)   
              JOIN uct_admin a ON cast(a.id as char ) = mt2.FEmpID 
              JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id IN (32,36) 
              GROUP BY a.id 
              HAVING round(SUM(CASE mt."FTranType"   
                                WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   
                                              - COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   
                                WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   
                                ELSE '0' 
                             END),2) < 0 
              ORDER BY concat(a.branch_id,'-',if(ga.group_id = 32,1,2)),round(SUM(CASE mt."FTranType"   
                                WHEN 'SOR' THEN   COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt."TalThird",0)   
                                              - COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   
                                WHEN 'SEL' THEN    COALESCE(mt."TalFAmount",0) - COALESCE(mt."TalFrist",0) - COALESCE(mt."TalSecond",0) - COALESCE(mt2."TalFAmount",0) - COALESCE(mt2."TalFrist",0) - COALESCE(mt2."TalSecond",0) - COALESCE(mt2."TalThird",0) - COALESCE(mt2."TalForth",0)   
                                ELSE '0' 
                             END),2)
        ) as rows;


        -- 递增日期
        _test_date := _test_date + INTERVAL '1 day';
    END LOOP;

    -- 提交事务
    COMMIT;
END;
$$;




DROP PROCEDURE IF EXISTS "test_lvhuan"."order_cancel";
CREATE OR REPLACE PROCEDURE "test_lvhuan"."order_cancel"() 
LANGUAGE plpgsql
AS $$
DECLARE
    id_field INT;                   -- 订单取消表的ID字段
    order_id_field INT;             -- 订单ID字段
    order_num_field VARCHAR(50);    -- 订单号字段
    type_field VARCHAR(5);          -- 类型字段
    hand_mouth_data_field INT;      -- 手工口数据字段
    corrent_field INT;              -- 校正字段
    handle_field INT;               -- 处理字段
    
    order_type VARCHAR(10);         -- 订单类型

    done BOOLEAN := FALSE;          -- 游标标志

    -- 声明游标
    order_cancel_cur CURSOR FOR
        SELECT id, order_id, order_num, type, hand_mouth_data, corrent, handle
        FROM uct_order_cancel
        WHERE handle = 0;

BEGIN
    -- 开启一个事务
    START TRANSACTION;
    
    -- 打开游标
    OPEN order_cancel_cur;
    
    -- 遍历游标结果
    LOOP
        FETCH NEXT FROM order_cancel_cur INTO id_field, order_id_field, order_num_field, type_field, hand_mouth_data_field, corrent_field, handle_field;
        EXIT WHEN NOT FOUND;

        -- 更新uct_order_cancel以标记为已处理
        UPDATE uct_order_cancel SET handle = 1 WHERE id = id_field;

        -- 根据type_field设置order_type
        IF type_field = 'SEL' THEN
            SET order_type = 'SEL';
        ELSE
            SET order_type = 'PUR,SOR';
        END IF;

        -- 更新Trans_main_table
        UPDATE Trans_main_table
        SET
            FCancellation = 0,
            TalFQty = 0,
            TalFAmount = 0,
            TalFrist = 0,
            TalSecond = 0,
            TalThird = 0,
            TalForth = 0,
            TalFeeFifth = 0,
            is_hedge = 1,
            red_ink_time = NOW()
        WHERE
            FInterID = order_id_field
            AND FTranType = ANY(string_to_array(order_type, ','));
        
        -- 更新Trans_fee_table
        UPDATE Trans_fee_table
        SET is_hedge = 1
        WHERE
            FInterID = order_id_field
            AND FTranType = ANY(string_to_array(order_type, ','));

        -- INSERT INTO Trans_fee_table
        INSERT INTO Trans_fee_table
        SELECT FInterID, FTranType, Ffeesence, FEntryID, FFeeID, FFeeType, FFeePerson, FFeeExplain, -FFeeAmount, FFeebaseAmount, Ftaxrate, Fbasetax, Fbasetaxamount, FPriceRef, FFeetime, NOW(), is_hedge, revise_state
        FROM Trans_fee_table 
        WHERE FInterID = order_id_field AND FTranType = ANY (string_to_array(order_type, ','));

        -- UPDATE Trans_materiel_table
        UPDATE Trans_materiel_table 
        SET is_hedge = 1 
        WHERE FInterID = order_id_field AND FTranType = ANY (string_to_array(order_type, ','));

        -- INSERT INTO Trans_materiel_table
        INSERT INTO Trans_materiel_table
        SELECT FInterID, FTranType, FEntryID, FMaterielID, -FUseCount, FPrice, -FMeterielAmount, FMeterieltime, NOW(), is_hedge, revise_state
        FROM Trans_materiel_table 
        WHERE FInterID = order_id_field AND FTranType = ANY (string_to_array(order_type, ','));

        -- UPDATE Trans_assist_table
        UPDATE Trans_assist_table 
        SET is_hedge = 1 
        WHERE FinterID = order_id_field AND FTranType = ANY (string_to_array(order_type, ','));

        -- INSERT INTO Trans_assist_table
        INSERT INTO Trans_assist_table
        SELECT FinterID, FTranType, FEntryID, FItemID, FUnitID, -FQty, FPrice, -FAmount, disposal_way, value_type, FbasePrice, FbaseAmount, Ftaxrate, Fbasetax, Fbasetaxamount, FPriceRef, FDCTime, FSourceInterId, FSourceTranType, NOW(), is_hedge, revise_state
        FROM Trans_assist_table 
        WHERE FinterID = order_id_field AND FTranType = ANY (string_to_array(order_type, ','));

        IF hand_mouth_data_field = 1 THEN
            IF type_field = 'PUR' THEN
                SET order_type = 'SEL';
                SELECT order_type;
                SELECT id INTO order_id_field FROM uct_waste_sell WHERE order_id = order_num_field;
                SELECT order_id_field;
            ELSE
                SET order_type = 'PUR';
                SELECT id INTO order_id_field FROM uct_waste_purchase WHERE order_id = order_num_field;
            END IF;

            -- UPDATE Trans_main_table
            UPDATE Trans_main_table 
            SET FCancellation = 0, TalFQty = 0, TalFAmount = 0, TalFrist = 0, TalSecond = 0, TalThird = 0, TalForth = 0, TalFeeFifth = 0, is_hedge = 1, red_ink_time = NOW() 
            WHERE FInterID = order_id_field AND FTranType = order_type;

            IF corrent_field = 1 THEN
                -- UPDATE Trans_fee_table
                UPDATE Trans_fee_table 
                SET is_hedge = 1 
                WHERE FInterID = order_id_field AND FTranType = order_type; 

                -- INSERT INTO Trans_fee_table
                INSERT INTO Trans_fee_table
                SELECT FInterID, FTranType, Ffeesence, FEntryID, FFeeID, FFeeType, FFeePerson, FFeeExplain, -FFeeAmount, FFeebaseAmount, Ftaxrate, Fbasetax, Fbasetaxamount, FPriceRef, FFeetime, NOW(), is_hedge, revise_state
                FROM Trans_fee_table 
                WHERE FInterID = order_id_field AND FTranType = order_type;

                -- UPDATE Trans_materiel_table
                UPDATE Trans_materiel_table 
                SET is_hedge = 1 
                WHERE FInterID = order_id_field AND FTranType = order_type; 

                -- INSERT INTO Trans_materiel_table
                INSERT INTO Trans_materiel_table
                SELECT FInterID, FTranType, FEntryID, FMaterielID, -FUseCount, FPrice, -FMeterielAmount, FMeterieltime, NOW(), is_hedge, revise_state
                FROM Trans_materiel_table 
                WHERE FInterID = order_id_field AND FTranType = order_type;

                -- UPDATE Trans_assist_table
                UPDATE Trans_assist_table 
                SET is_hedge = 1 
                WHERE FinterID = order_id_field AND FTranType = order_type; 

                -- INSERT INTO Trans_assist_table
                INSERT INTO Trans_assist_table
                SELECT FinterID, FTranType, FEntryID, FItemID, FUnitID, -FQty, FPrice, -FAmount, disposal_way, value_type, FbasePrice, FbaseAmount, Ftaxrate, Fbasetax, Fbasetaxamount, FPriceRef, FDCTime, FSourceInterId, FSourceTranType, NOW(), is_hedge, revise_state
                FROM Trans_assist_table 
                WHERE FinterID = order_id_field AND FTranType = order_type;
            END IF;
        END IF;
   END LOOP;
    
    -- 关闭游标
    CLOSE order_cancel_cur;
    
    -- 提交事务
    COMMIT;
END;
$$;




-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_allot";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_allot"(IN "id" INT, IN "hand_mouth_data" INT, IN "give_frame" INT) 
LANGUAGE plpgsql AS $$
BEGIN
    IF hand_mouth_data = 1 THEN  
        CALL Trans_log_pur_hand(id);
        CALL Trans_main_pur(id);
    ELSIF give_frame = 1 THEN   
        CALL Trans_log_pur_give(id);
        CALL Trans_main_pur(id);
    ELSE                          
        CALL Trans_log_pur(id);
        CALL Trans_main_pur(id);
    END IF;
END;
$$;




DROP PROCEDURE IF EXISTS "test_lvhuan"."province_wall_report";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."province_wall_report"() 
LANGUAGE plpgsql AS $$
DECLARE
    nowdate DATE := CURRENT_DATE - INTERVAL '1 day'; -- 使用TO_CHAR函数会导致错误
BEGIN
insert into uct_day_wall_report(adcode,weight,availability,rubbish,rdf,carbon,box,customer_num,report_date) select ad.adcode,COALESCE(weight,0) as weight ,COALESCE(availability,0) as availability ,COALESCE(rubbish,0) as rubbish ,COALESCE(rdf,0) as rdf,COALESCE(carbon,0) as carbon,COALESCE(box,0) as box,COALESCE(customer.customer_num,0) as customer_num,nowdate as report_date from uct_adcode ad left join 
(select ad.adcode,round(sum(FQty),2) as weight , round(sum(if(c.name = '低值废弃物',FQty,0))/sum(FQty),2) as availability,round(sum(if(c.name = '低值废弃物',FQty,0)),2) as rubbish ,round(sum(if(c.name = '低值废弃物',FQty,0))/sum(FQty)*4.2,2) as rdf , round(sum(FQty*c2.carbon_parm),2) as carbon ,box.box from Trans_main_table mt  join Trans_main_table mt2 on mt.FInterId = mt2.FInterId and mt2.FTranType = 'PUR' and  date_format(mt2.FDate,'%Y-%m-%d') > '2018-9-30' and date_format(mt2.FDate,'%Y-%m-%d') = TO_CHAR(nowdate,'%Y-%m-%d') join  uct_waste_purchase p on mt.FBillNo = p.order_id  join  uct_waste_customer_factory cf  on cf.id = p.factory_id   join uct_adcode ad on ad.name =  cf.province    join Trans_assist_table at on mt.FInterID = at.FinterID  and  mt.FTranType = at.FTranType   join uct_waste_cate c on  c.id = at.FItemID  join  uct_waste_cate c2 on c.parent_id = c2.id

left join (select ad.adcode,sum(FUseCount) as box from Trans_main_table mt  join  uct_waste_purchase p on mt.FInterID = p.id  join  uct_waste_customer_factory cf  on cf.id = p.factory_id   join uct_adcode ad on ad.name =  cf.province join Trans_materiel_table materiel on materiel.FInterID = mt.FInterID  join uct_materiel materiel2 on materiel.FMaterielID = materiel2.id and materiel.FTranType in ('PUR','SOR') and materiel2.name = '分类箱'  where date_format(mt.FDate,'%Y-%m-%d') > '2018-9-30' and date_format(mt.FDate,'%Y-%m-%d') = TO_CHAR(nowdate,'%Y-%m-%d')  and mt.FTranType = 'PUR' and  mt.FSaleStyle in ('0','1')  and  mt.FCorrent = '1' and mt.FCancellation = '1'  and mt.FRelateBrID != 7  group by cf.province order by cf.area ) box  on box.adcode = ad.adcode

where mt.FTranType in ('SOR','SEL') and mt.FSaleStyle in ('0','1')  and  mt.FCorrent = '1' and mt.FCancellation = '1'  and mt.FRelateBrID != 7   group by cf.province order by cf.area) data on ad.adcode = data.adcode

left join (select ad.adcode , count(*) as customer_num from uct_up up join uct_adcode ad on up.company_province = ad.name and first_business_time = TO_CHAR(nowdate,'%Y-%m-%d') group by company_province) customer on customer.adcode = ad.adcode

where right(ad.adcode,4) = '0000';



update uct_accumulate_wall_report report join  (select ad.adcode,COALESCE(weight,0) as weight ,COALESCE(availability,0) as availability ,COALESCE(rubbish,0) as rubbish ,COALESCE(rdf,0) as rdf,COALESCE(carbon,0) as carbon,COALESCE(box,0) as box,COALESCE(customer.customer_num,0) as customer_num from uct_adcode ad left join
(select ad.adcode,round(sum(FQty),2) as weight , round(sum(if(c.name = '低值废弃物',FQty,0))/sum(FQty),2) as availability,round(sum(if(c.name = '低值废弃物',FQty,0)),2) as rubbish ,round(sum(if(c.name = '低值废弃物',FQty,0))/sum(FQty)*4.2,2) as rdf , round(sum(FQty*c2.carbon_parm),2) as carbon ,box.box from Trans_main_table mt  join Trans_main_table mt2 on mt.FInterId = mt2.FInterId and mt2.FTranType = 'PUR' and  date_format(mt2.FDate,'%Y-%m-%d') > '2018-9-30'  join  uct_waste_purchase p on mt.FBillNo = p.order_id  join  uct_waste_customer_factory cf  on cf.id = p.factory_id   join uct_adcode ad on ad.name =  cf.province    join Trans_assist_table at on mt.FInterID = at.FinterID  and  mt.FTranType = at.FTranType   join uct_waste_cate c on  c.id = at.FItemID  join  uct_waste_cate c2 on c.parent_id = c2.id

left join (select ad.adcode,sum(FUseCount) as box from Trans_main_table mt  join  uct_waste_purchase p on mt.FInterID = p.id  join  uct_waste_customer_factory cf  on cf.id = p.factory_id   join uct_adcode ad on ad.name =  cf.province join Trans_materiel_table materiel on materiel.FInterID = mt.FInterID  join uct_materiel materiel2 on materiel.FMaterielID = materiel2.id and materiel.FTranType in ('PUR','SOR') and materiel2.name = '分类箱'  where date_format(mt.FDate,'%Y-%m-%d') > '2018-9-30' and mt.FTranType = 'PUR' and  mt.FSaleStyle in ('0','1')  and  mt.FCorrent = '1' and mt.FCancellation = '1'  and mt.FRelateBrID != 7  group by cf.province order by cf.area ) box  on box.adcode = ad.adcode

where mt.FTranType in ('SOR','SEL') and mt.FSaleStyle in ('0','1')  and  mt.FCorrent = '1' and mt.FCancellation = '1'  and mt.FRelateBrID != 7   group by cf.province order by cf.area) data on ad.adcode = data.adcode

left join (select ad.adcode , count(*) as customer_num from uct_up up join uct_adcode ad on up.company_province = ad.name  group by company_province) customer on customer.adcode = ad.adcode

where right(ad.adcode,4) = '0000') data on report.adcode = data.adcode  
set  report.weight = data.weight , report.availability = data.availability , report.rubbish = data.rubbish ,report.rdf = data.rdf , report.carbon = data.carbon , report.box = data.box , report.customer_num = data.customer_num ; 
END;
$$;




-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_apply_materiel";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_apply_materiel"(IN "id" INT, IN "hand_mouth_data" INT, IN "give_frame" INT) 
LANGUAGE plpgsql AS $$
BEGIN
    IF give_frame = 1 THEN
        CALL Trans_materiel_pur(id);
        CALL Trans_log_pur_give(id);
        CALL Trans_main_pur(id);
    ELSE
        CALL Trans_materiel_pur(id);
        CALL Trans_log_pur(id);
        CALL Trans_main_pur(id);
    END IF;
END;
$$;



-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_fillin_return_fee";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_fillin_return_fee"(IN "pur_id" INT) 
LANGUAGE plpgsql AS $$
DECLARE
    sel_id INT;
BEGIN
    SELECT id INTO sel_id FROM uct_waste_sell WHERE purchase_id = pur_id;
    CALL Trans_fee_rf(pur_id);
    CALL Trans_log_pur_hand(pur_id);
    CALL Trans_main_pur(pur_id);
    CALL Trans_main_sel_hand(sel_id);
END;
$$;


-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_pick_cargo";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_pick_cargo"(IN "id" INT, IN "hand_mouth_data" INT, IN "give_frame" INT) 
LANGUAGE plpgsql AS $$
BEGIN
    IF hand_mouth_data = 1 THEN
        CALL Trans_fee_pc(id);
        CALL Trans_assist_pur(id);
        CALL Trans_log_pur_hand(id);
        CALL Trans_main_pur(id);
    ELSIF give_frame = 1 THEN
        CALL Trans_fee_pc(id);
        CALL Trans_assist_pur(id);
        CALL Trans_log_pur_give(id);
        CALL Trans_main_pur(id);
    ELSE
        CALL Trans_fee_pc(id);
        CALL Trans_assist_pur(id);
        CALL Trans_log_pur(id);
        CALL Trans_main_pur(id);
    END IF;
END;
$$;

-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_pick_materiel";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_pick_materiel"(IN "id" INT, IN "hand_mouth_data" INT, IN "give_frame" INT) 
LANGUAGE plpgsql AS $$
BEGIN
    IF give_frame = 1 THEN
        CALL Trans_materiel_pur(id);
        CALL Trans_log_pur_give(id);
        CALL Trans_main_pur(id);
    ELSE
        CALL Trans_materiel_pur(id);
        CALL Trans_log_pur(id);
        CALL Trans_main_pur(id);
    END IF;
END;
$$;

-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_receive";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_receive"(IN "id" INT, IN "hand_mouth_data" INT, IN "give_frame" INT) 
LANGUAGE plpgsql AS $$
BEGIN
    IF hand_mouth_data = 1 THEN
        CALL Trans_log_pur_hand(id);
        CALL Trans_main_pur(id);
    ELSIF give_frame = 1 THEN
        CALL Trans_log_pur_give(id);
        CALL Trans_main_pur(id);
    ELSE
        CALL Trans_log_pur(id);
        CALL Trans_main_pur(id);
    END IF;
END;
$$;






-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_return_fee_confirm";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_return_fee_confirm"(IN "pur_id" INT, IN "hand_mouth_data" INT, IN "give_frame" INT) 
LANGUAGE plpgsql AS $$
DECLARE
    sel_id INT;
    cw_id INT;
    cw_createtime INT;
BEGIN
    SELECT admin_id, createtime INTO cw_id, cw_createtime FROM uct_waste_purchase_log WHERE purchase_id = pur_id AND state_value = 'wait_confirm_return_fee';

    IF hand_mouth_data = 1 THEN  
        SELECT id INTO sel_id FROM uct_waste_sell WHERE purchase_id = pur_id;
        CALL Trans_log_pur_hand(pur_id);
        
        UPDATE Trans_main_table SET FStatus = 1, FNowState = 'finish', FCheckerID = cw_id, FCheckDate = cw_createtime WHERE FInterID = pur_id AND FTranType = 'PUR';  
        UPDATE Trans_main_table SET FStatus = 1, FNowState = 'finish', FCheckerID = cw_id, FCheckDate = cw_createtime WHERE FInterID = sel_id AND FTranType = 'SEL';  
    ELSE 
        CALL Trans_log_pur(pur_id);
        
        UPDATE Trans_main_table SET FStatus = 1, FNowState = 'finish', FCheckerID = cw_id, FCheckDate = cw_createtime WHERE FInterID = pur_id AND FTranType IN ('PUR', 'SOR');
    END IF;
END;
$$;

-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_signin_materiel";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_signin_materiel"(IN "id" INT, IN "hand_mouth_data" INT, IN "give_frame" INT) 
LANGUAGE plpgsql AS $$
BEGIN
    IF give_frame = 1 THEN    
        CALL Trans_log_pur_give(id);
        CALL Trans_main_pur(id);
    ELSE
        CALL Trans_log_pur(id);
        CALL Trans_main_pur(id);
    END IF;
END;
$$;





-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_storage_confirm";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_storage_confirm"(IN "id" INT) 
LANGUAGE plpgsql AS $$
BEGIN
    CALL Trans_log_pur(id);
    CALL Trans_main_pur(id);
    CALL Trans_main_sor(id);
END;
$$;


-- 删除存储过程 "Trans_fee_so"，如果存在的话
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_so";

-- 创建存储过程 "Trans_fee_so"
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_so"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Trans_fee_table WHERE FTranType = 'SOR' AND Ffeesence = 'SO' AND FInterID = id;
    
    INSERT INTO Trans_fee_table (FInterID, FTranType, Ffeesence, FEntryID, FFeeID, FFeeType, FFeePerson, FFeeExplain, FFeeAmount, FFeebaseAmount, Ftaxrate, Fbasetax, Fbasetaxamount, FPriceRef, FFeetime, red_ink_time, is_hedge)
    SELECT "uct_waste_storage_expense"."purchase_id" AS "FInterID",
           'SOR' AS "FTranType",
           'SO' AS "Ffeesence",
           "uct_waste_storage_expense"."id" AS "FEntryID",
           "uct_waste_storage_expense"."usage" AS "FFeeID",
           'out' AS "FFeeType",
           "uct_waste_storage_expense"."receiver" AS "FFeePerson",
           "uct_waste_storage_expense"."remark" AS "FFeeExplain",
           "uct_waste_storage_expense"."price" AS "FFeeAmount",
           '' AS "FFeebaseAmount",
           '' AS "Ftaxrate",
           '' AS "Fbasetax",
           '' AS "Fbasetaxamount",
           '' AS "FPriceRef",
           TO_CHAR(FROM_UNIXTIME("uct_waste_storage_expense"."createtime"), 'YYYY-MM-DD HH24:MI:SS') AS "FFeetime",
           NULL AS "red_ink_time",
           0 AS "is_hedge",
           0,
           0
    FROM "uct_waste_storage_expense"
    WHERE "uct_waste_storage_expense"."purchase_id" = id;
END;
$$;




-- 删除存储过程 "Trans_fee_sor"，如果存在的话
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_sor";

-- 创建存储过程 "Trans_fee_sor"
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_sor"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    SELECT "uct_waste_storage_sort"."purchase_id" AS "FInterID",
           'SOR' AS "FTranType",
           "uct_waste_storage_sort"."id" AS "FEntryID",
           "uct_waste_storage_sort"."cargo_sort" AS "FItemID",
           '1' AS "FUnitID",
           "uct_waste_storage_sort"."net_weight" AS "FQty",
           "uct_waste_storage_sort"."presell_price" AS "FPrice",
           ROUND("uct_waste_storage_sort"."presell_price" * "uct_waste_storage_sort"."net_weight", 2) AS "FAmount",
           '' AS "FbasePrice",
           '' AS "FbaseAmount",
           '' AS "Ftaxrate",
           '' AS "Fbasetax",
           '' AS "Fbasetaxamount",
           '' AS "FPriceRef",
           TO_CHAR(FROM_UNIXTIME(CASE WHEN "uct_waste_storage_sort"."sort_time" > "uct_waste_storage_sort"."createtime" THEN "uct_waste_storage_sort"."sort_time" ELSE "uct_waste_storage_sort"."createtime" END), 'YYYY-MM-DD HH24:MI:SS') AS "FDCTime",
           "uct_waste_storage_sort"."purchase_id" AS "FSourceInterID",
           'PUR' AS "FSourceTranType"
    FROM "uct_waste_storage_sort"
    WHERE "uct_waste_storage_sort"."purchase_id" = id;
END;
$$;


-- 删除存储过程 "lh_dw_operating_check_to_execute"，如果存在的话
DROP PROCEDURE IF EXISTS "test_lvhuan"."lh_dw_operating_check_to_execute";

-- 创建存储过程 "lh_dw_operating_check_to_execute"
CREATE OR REPLACE PROCEDURE "test_lvhuan"."lh_dw_operating_check_to_execute"() 
LANGUAGE plpgsql AS $$
DECLARE
    v_id int;
    v_pre_tasks varchar(100);
    v_exec_way varchar(20);
    v_exec_alg varchar(10000);
    v_err_logs varchar(200);
    o_rv int;
    o_err varchar(100);
    v_exec_state int;
    sqlUp varchar(800);
    sqlStr varchar(800);
    v_sql varchar(800);
    v_sql_str varchar(800);
    statu varchar(20);
    v_filed varchar(20);
    v_status int;
    v_res_exec_state int;
    v_res_err_logs varchar(200);
    errno int;
    v_exec_code varchar(300);
    v_count_num int;
    v_log_type varchar(30);
    v_res_exec_type varchar(30);
    s int DEFAULT 0;

    -- 声明游标
    report CURSOR FOR
        SELECT id, pre_tasks, exec_way, exec_alg, err_logs, exec_state, code
        FROM lh_dw.data_statistics_execution
        WHERE EXTRACT(EPOCH FROM exec_time) <= EXTRACT(EPOCH FROM NOW()) 
          AND exec_way = 'sql'
          AND code LIKE 'oper-m-%'
          AND exec_state IN (0, 2);
BEGIN
    -- 打开游标
    OPEN report;

    -- 循环处理游标结果集
    LOOP
        -- 从游标中获取数据
        FETCH report INTO
            v_id, v_pre_tasks, v_exec_way, v_exec_alg, v_err_logs, v_exec_state, v_exec_code;

        -- 退出循环条件
        EXIT WHEN NOT FOUND;

        WHILE s <> 1 LOOP
            v_exec_alg := trim(v_exec_alg);
            v_id := trim(v_id); 

            SELECT count(*) INTO v_count_num FROM lh_dw.data_statistics_execution_log WHERE exec_id = v_id;
            
            IF v_count_num > 0 THEN
                SELECT COALESCE(exec_type, 'waiting') INTO v_log_type 
                FROM lh_dw.data_statistics_execution_log 
                WHERE exec_id = v_id 
                ORDER BY create_at DESC 
                LIMIT 1;
            END IF;

            IF v_count_num = 0 OR v_log_type = 'failed' THEN
                INSERT INTO lh_dw.data_statistics_execution_log (exec_id, exec_code, exec_type)
                VALUES (v_id, v_exec_code, 'waiting');
            END IF;

            IF v_count_num = 0 OR v_log_type IN ('waiting', 'failed') THEN
                IF v_pre_tasks = '' OR v_pre_tasks IS NULL THEN
                    UPDATE lh_dw.data_statistics_execution_log  
                    SET exec_type = 'operation' 
                    WHERE exec_id = v_id AND finish_at IS NULL;

                    o_rv := '0';
                    o_err := '';
                    CALL lh_dw_table_data_execution(v_id, v_exec_alg, o_rv, o_err);
                    
                    IF o_rv = 200 THEN
                        v_res_exec_state := 1;
                        v_res_err_logs := '';
                        v_res_exec_type := 'finish';
                    END IF;
                    
                    IF o_rv = 400 THEN
                        v_res_exec_state := 2;
                        v_res_err_logs := o_err;
                        v_res_exec_type := 'failed';
                    END IF;
                    
                    UPDATE lh_dw.data_statistics_execution  
                    SET exec_state = v_res_exec_state, err_logs = v_res_err_logs 
                    WHERE id = v_id;
                    
                    UPDATE lh_dw.data_statistics_execution_log  
                    SET exec_type = v_res_exec_type, finish_at = NOW() 
                    WHERE exec_id = v_id AND finish_at IS NULL;
                ELSE
                    SELECT EXP(SUM(LN(CASE WHEN exec_state = 1 THEN 1 ELSE 2 END))) INTO v_status 
                    FROM lh_dw.data_statistics_execution 
                    WHERE id IN (SELECT unnest(string_to_array(v_pre_tasks, ','))::int);
                    
                    IF v_status = 1 THEN
                        UPDATE lh_dw.data_statistics_execution_log  
                        SET exec_type = 'operation' 
                        WHERE exec_id = v_id AND finish_at IS NULL;

                        o_rv := '0';
                        o_err := '';
                        CALL lh_dw_table_data_execution(v_id, v_exec_alg, o_rv, o_err);

                        IF o_rv = 200 THEN
                            v_res_exec_state := 1;
                            v_res_err_logs := '';
                            v_res_exec_type := 'finish';
                        END IF;

                        IF o_rv = 400 THEN
                            v_res_exec_state := 2;
                            v_res_err_logs := o_err;
                            v_res_exec_type := 'failed';
                        END IF;
                        
                        UPDATE lh_dw.data_statistics_execution  
                        SET exec_state = v_res_exec_state, err_logs = v_res_err_logs 
                        WHERE id = v_id;
                        
                        UPDATE lh_dw.data_statistics_execution_log  
                        SET exec_type = v_res_exec_type, finish_at = NOW() 
                        WHERE exec_id = v_id AND finish_at IS NULL;
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END LOOP;

    -- 关闭游标
    CLOSE report;
END;
$$;




-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_storage_connect";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_storage_connect"(IN "id" INT, IN "hand_mouth_data" INT, IN "give_frame" INT) 
LANGUAGE plpgsql AS $$
BEGIN
    IF give_frame = 1 THEN    
        CALL Trans_fee_so(id);
        CALL Trans_materiel_pur(id);
        CALL Trans_log_pur_give(id);
        CALL Trans_main_pur(id);
        CALL Trans_main_sor(id);
    ELSE
        CALL Trans_fee_so(id);
        CALL Trans_materiel_pur(id);
        CALL Trans_log_pur(id);
        CALL Trans_main_pur(id);
        CALL Trans_main_sor(id);
    END IF;
END;
$$;

-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_storage_connect_confirm";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_storage_connect_confirm"(IN "id" INT, IN "hand_mouth_data" INT, IN "give_frame" INT) 
LANGUAGE plpgsql AS $$
BEGIN
    IF give_frame = 1 THEN    
        CALL Trans_fee_rf(id);
        CALL Trans_log_pur_give(id);
        CALL Trans_main_pur(id);
        CALL Trans_main_sor(id);
    ELSE                       
        CALL Trans_fee_rf(id);
        CALL Trans_log_pur(id);
        CALL Trans_main_pur(id);
        CALL Trans_main_sor(id);
    END IF;
END;
$$;

-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."pur_storage_sort";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."pur_storage_sort"(IN "id" INT) 
LANGUAGE plpgsql AS $$
BEGIN
    CALL Trans_fee_ss(id);
    CALL Trans_assist_sor(id);
    CALL Trans_materiel_sor(id);
    CALL Trans_log_pur(id);
    CALL Trans_main_pur(id);
    CALL Trans_main_sor(id);
END;
$$;


-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."region_wall_report";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."region_wall_report"() 
LANGUAGE plpgsql AS $$
DECLARE
    nowdate date DEFAULT CURRENT_DATE;
BEGIN
    nowdate := TO_CHAR(CURRENT_DATE - INTERVAL '1 day', 'YYYY-MM-DD');

    INSERT INTO uct_day_wall_report(adcode, weight, availability, rubbish, rdf, carbon, box, customer_num, report_date)
    SELECT
        ad.adcode,
        COALESCE(weight, 0) AS weight,
        COALESCE(availability, 0) AS availability,
        COALESCE(rubbish, 0) AS rubbish,
        COALESCE(rdf, 0) AS rdf,
        COALESCE(carbon, 0) AS carbon,
        COALESCE(box, 0) AS box,
        COALESCE(customer.customer_num, 0) AS customer_num,
        nowdate AS report_date
    FROM
        uct_adcode ad
    LEFT JOIN (
        SELECT
            ad.adcode,
            ROUND(SUM(FQty), 2) AS weight,
            ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty), 2) AS availability,
            ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END), 2) AS rubbish,
            ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty) * 4.2, 2) AS rdf,
            ROUND(SUM(FQty * c2.carbon_parm), 2) AS carbon,
            box.box
        FROM
            Trans_main_table mt
        JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = 'PUR' AND DATE_FORMAT(mt2.FDate, 'YYYY-MM-DD') > '2018-09-30' AND DATE_FORMAT(mt2.FDate, 'YYYY-MM-DD') = TO_CHAR(nowdate, 'YYYY-MM-DD')
        JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
        JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
        JOIN uct_adcode ad ON ad.name = cf.area
        JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType
        JOIN uct_waste_cate c ON c.id = at.FItemID
        JOIN uct_waste_cate c2 ON c.parent_id = c2.id
        LEFT JOIN (
            SELECT
                ad.adcode,
                SUM(FUseCount) AS box
            FROM
                Trans_main_table mt
            JOIN uct_waste_purchase p ON mt.FInterID = p.id
            JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
            JOIN uct_adcode ad ON ad.name = cf.area
            JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID
            JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType IN ('PUR', 'SOR') AND materiel2.name = '分类箱'
            WHERE
                DATE_FORMAT(mt.FDate, 'YYYY-MM-DD') > '2018-09-30'
                AND DATE_FORMAT(mt.FDate, 'YYYY-MM-DD') = TO_CHAR(nowdate, 'YYYY-MM-DD')
                AND mt.FTranType = 'PUR'
                AND mt.FSaleStyle IN ('0', '1')
                AND mt.FCorrent = '1'
                AND mt.FCancellation = '1'
                AND mt.FRelateBrID != 7
            GROUP BY
                cf.province,
                cf.city,
                cf.area
            ORDER BY
                cf.area
        ) box ON box.adcode = ad.adcode
        WHERE
            mt.FTranType IN ('SOR', 'SEL')
            AND mt.FSaleStyle IN ('0', '1')
            AND mt.FCorrent = '1'
            AND mt.FCancellation = '1'
            AND mt.FRelateBrID != 7
        GROUP BY
            cf.province,
            cf.city,
            cf.area
        ORDER BY
            cf.area
    ) data ON ad.adcode = data.adcode
    LEFT JOIN (
        SELECT
            ad.adcode,
            COUNT(*) AS customer_num
        FROM
            uct_up up
        JOIN uct_adcode ad ON up.company_region = ad.name AND first_business_time = TO_CHAR(nowdate, 'YYYY-MM-DD')
        GROUP BY
            company_province,
            company_city,
            company_region
    ) customer ON customer.adcode = ad.adcode
    WHERE
        RIGHT(ad.adcode, 4) != '0000'
        AND RIGHT(ad.adcode, 2) != '00'; 

    UPDATE uct_accumulate_wall_report report
    JOIN (
        SELECT
            ad.adcode,
            COALESCE(weight, 0) AS weight,
            COALESCE(availability, 0) AS availability,
            COALESCE(rubbish, 0) AS rubbish,
            COALESCE(rdf, 0) AS rdf,
            COALESCE(carbon, 0) AS carbon,
            COALESCE(box, 0) AS box,
            COALESCE(customer.customer_num, 0) AS customer_num
        FROM
            uct_adcode ad
        LEFT JOIN (
            SELECT
                ad.adcode,
                ROUND(SUM(FQty), 2) AS weight,
                ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty), 2) AS availability,
                ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END), 2) AS rubbish,
                ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty) * 4.2, 2) AS rdf,
                ROUND(SUM(FQty * c2.carbon_parm), 2) AS carbon,
                box.box
            FROM
                Trans_main_table mt
            JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = 'PUR' AND DATE_FORMAT(mt2.FDate, 'YYYY-MM-DD') > '2018-09-30'
            JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
            JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
            JOIN uct_adcode ad ON ad.name = cf.area
            JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType
            JOIN uct_waste_cate c ON c.id = at.FItemID
            JOIN uct_waste_cate c2 ON c.parent_id = c2.id
            LEFT JOIN (
                SELECT
                    ad.adcode,
                    SUM(FUseCount) AS box
                FROM
                    Trans_main_table mt
                JOIN uct_waste_purchase p ON mt.FInterID = p.id
                JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
                JOIN uct_adcode ad ON ad.name = cf.area
                JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID
                JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType IN ('PUR', 'SOR') AND materiel2.name = '分类箱'
                WHERE
                    DATE_FORMAT(mt.FDate, 'YYYY-MM-DD') > '2018-09-30'
                    AND mt.FTranType = 'PUR'
                    AND mt.FSaleStyle IN ('0', '1')
                    AND mt.FCorrent = '1'
                    AND mt.FCancellation = '1'
                    AND mt.FRelateBrID != 7
                GROUP BY
                    cf.province,
                    cf.city,
                    cf.area
                ORDER BY
                    cf.area
            ) box ON box.adcode = ad.adcode
            WHERE
                mt.FTranType IN ('SOR', 'SEL')
                AND mt.FSaleStyle IN ('0', '1')
                AND mt.FCorrent = '1'
                AND mt.FCancellation = '1'
                AND mt.FRelateBrID != 7
            GROUP BY
                cf.province,
                cf.city,
                cf.area
            ORDER BY
                cf.area
        ) data ON ad.adcode = data.adcode
        LEFT JOIN (
            SELECT
                ad.adcode,
                COUNT(*) AS customer_num
            FROM
                uct_up up
            JOIN uct_adcode ad ON up.company_region = ad.name
            GROUP BY
                company_province,
                company_city,
                company_region
        ) customer ON customer.adcode = ad.adcode
        WHERE
            RIGHT(ad.adcode, 4) = '0000'
            AND RIGHT(ad.adcode, 2) != '00'
    ) data ON report.adcode = data.adcode
    SET
        report.weight = data.weight,
        report.availability = data.availability,
        report.rubbish = data.rubbish,
        report.rdf = data.rdf,
        report.carbon = data.carbon,
        report.box = data.box,
        report.customer_num = data.customer_num;
END;
$$;





-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."sales-daily-report";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."sales-daily-report"() 
LANGUAGE plpgsql AS $$
DECLARE
    _test_date DATE := '2020-01-01';
    _rank INT;
    _classname TEXT;
BEGIN
    START TRANSACTION;

    WHILE _test_date < CURRENT_DATE LOOP

insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims , b.setting_key as data_val, 'sales-daily-report' as stat_code, 'stock-out' as group1 ,  round(sum(COALESCE(mt.TalFQty,0)),2) as val1, round(sum(COALESCE(mt.TalFQty,0)),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(mt.TalFQty,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 from Trans_main_table mt
right join lh_dw.data_statistics_results as r on r.data_val = mt.FRelateBrID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle = '2' and mt.FTranType = 'SEL'  and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)  right join uct_branch as b on cast(b.setting_key as char) = r.data_val and r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'sales-daily-report' and r.group1 = 'stock-out'   group by  b.setting_key;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims , b.setting_key as data_val, 'sales-daily-report' as stat_code, 'sales-amount' as group1 ,  round(sum(COALESCE(mt.TalFAmount + mt.TalFrist + mt.TalSecond,0)),2) as val1, round(sum(COALESCE(mt.TalFAmount + mt.TalFrist + mt.TalSecond,0)),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(mt.TalFAmount + mt.TalFrist + mt.TalSecond,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 from Trans_main_table mt
right join lh_dw.data_statistics_results as r on r.data_val = mt.FRelateBrID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle = '2' and mt.FTranType = 'SEL'  and mt.Date  = DATE_SUB(_test_date,INTERVAL 1 DAY)  right join uct_branch as b on cast(b.setting_key as char) = r.data_val and r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'sales-daily-report' and r.group1 = 'sales-amount'   group by  b.setting_key;

insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims , b.setting_key as data_val, 'sales-daily-report' as stat_code , 'sales-planning-count' as group1 ,  count(ali.id) as val1 from uct_waste_cate_actual_log as al join uct_waste_cate_actual_log_item as ali on al.id = ali.actual_log_id and al.status = 5 and ali.state = 1 and FROM_UNIXTIME(ali.start_time,'%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)
right join lh_dw.data_statistics_results as r on r.data_val = al.branch_id  right join uct_branch as b on cast(b.setting_key as char) = r.data_val and r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'sales-daily-report' and r.group1 = 'sales-planning-count'   group by  b.setting_key;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims , b.setting_key as data_val, 'sales-daily-report' as stat_code , 'sales-order-count' as group1 ,  count(mt.FBillNo) as val1 from Trans_main_table mt
right join lh_dw.data_statistics_results as r on r.data_val = mt.FRelateBrID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle = '2' and mt.FTranType = 'SEL'  and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)  right join uct_branch as b on cast(b.setting_key as char) = r.data_val and r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'sales-daily-report' and r.group1 = 'sales-order-count'   group by  b.setting_key;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims , b.setting_key as data_val, 'sales-daily-report' as stat_code , 'direct-sale-order-count' as group1 ,  count(mt.FBillNo) as val1 from Trans_main_table mt
right join lh_dw.data_statistics_results as r on r.data_val = mt.FRelateBrID and mt.FCancellation = '1'  and mt.FSaleStyle = '1' and mt.FTranType = 'PUR'  and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)  right join uct_branch as b on cast(b.setting_key as char) = r.data_val and r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'sales-daily-report' and r.group1 = 'direct-sale-order-count'   group by  b.setting_key;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims , b.setting_key as data_val, 'sales-daily-report' as stat_code , 'customer-cooperation' as group1, count(at.FItemID) as val1, count(ali.cate_id) as val2, COALESCE(round(count(at.FItemID)/count(ali.cate_id) * 100,2),0) as val3 from  Trans_main_table mt  join Trans_assist_table at on mt.FInterID = at.FinterID and at.FTranType = mt.FTranType and  at.FTranType = 'SEL'  and  mt.FCancellation = 1 and mt.FSaleStyle = 2 and mt.FTranType = 'SEL' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY) right join uct_waste_cate_actual_log_item as ali on ali.cate_id = at.FItemID and ali.customer_id = mt.FSupplyID join uct_waste_cate c on c.id = ali.cate_id  right join uct_branch as b on cast(b.setting_key as char) = c.branch_id and FROM_UNIXTIME(ali.start_time,'%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)  group by  b.setting_key;





insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,group3,txt1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time , '分部' as data_dims, mt.FRelateBrID as data_val, 'sales-daily-report' as stat_code, 'sales-order-detail-list' as group1, mt.FBillNo as group2, c.name as group3, case FSaleStyle when '1' then '直销' when '2' then '销售出库' end as txt1, round(sum(COALESCE(mt.TalFQty,0)),2) as val1, round(sum(COALESCE(mt.TalFAmount + mt.TalFrist + mt.TalSecond,0)),2) as val2, case ev.active when 1 then 1 else 0 end val3 from Trans_main_table mt join uct_waste_customer c on mt.FSupplyID = c.id
and mt.FCancellation = '1' and mt.FCorrent = '1'  and mt.FTranType = 'SEL'  and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)  left join uct_waste_sell_evidence_voucher ev  on ev.sell_id = mt.FInterID group by mt.FBillNo;










        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, stat_code, group1, group2, val1, val2, val3, data_val)
        SELECT
            'D' AS time_dims,
            DATE_SUB(_test_date, INTERVAL '1 DAY') AS time_val,
            CAST((CAST(_test_date AS DATE) - INTERVAL '1 DAY') AS DATETIME) AS begin_time,
            CAST(CAST(_test_date AS DATE) AS DATETIME) AS end_time,
            '分部' AS data_dims,
            c.branch_id AS data_val,
            'sales-daily-report' AS stat_code,
            'price-increase' AS group1,
            c.name AS group2,
            ROUND(COALESCE(cl.value, 0), 3) AS val1,
            COALESCE(ROUND((COALESCE(cl.value, 0) - COALESCE(cl.before_value, 0)) / COALESCE(cl.before_value, 0), 3) * 100, 0) AS val2
        FROM
            uct_waste_cate_log cl
        JOIN
            uct_waste_cate c ON c.id = cl.cate_id
        WHERE
            cl.createtime BETWEEN EXTRACT(EPOCH FROM _test_date - INTERVAL '1 DAY') AND EXTRACT(EPOCH FROM _test_date)
            AND ROUND(COALESCE(cl.value, 0), 3) > ROUND(COALESCE(cl.before_value, 0), 3)
        ORDER BY
            c.branch_id, ROUND((COALESCE(cl.value, 0) - COALESCE(cl.before_value, 0)) / COALESCE(cl.before_value, 0), 3) * 100 DESC;

        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, stat_code, group1, group2, val1, val2, val3, data_val)
        SELECT
            'D' AS time_dims,
            DATE_SUB(_test_date, INTERVAL '1 DAY') AS time_val,
            CAST((CAST(_test_date AS DATE) - INTERVAL '1 DAY') AS DATETIME) AS begin_time,
            CAST(CAST(_test_date AS DATE) AS DATETIME) AS end_time,
            '分部' AS data_dims,
            c.branch_id AS data_val,
            'sales-daily-report' AS stat_code,
            'price-decline' AS group1,
            c.name AS group2,
            ROUND(COALESCE(cl.value, 0), 3) AS val1,
            COALESCE(ROUND((COALESCE(cl.value, 0) - COALESCE(cl.before_value, 0)) / COALESCE(cl.before_value, 0), 3) * 100, 0) AS val2
        FROM
            uct_waste_cate_log cl
        JOIN
            uct_waste_cate c ON c.id = cl.cate_id
        WHERE
            cl.createtime BETWEEN EXTRACT(EPOCH FROM _test_date - INTERVAL '1 DAY') AND EXTRACT(EPOCH FROM _test_date)
            AND ROUND(COALESCE(cl.value, 0), 3) < ROUND(COALESCE(cl.before_value, 0), 3)
        ORDER BY
            c.branch_id, ROUND((COALESCE(cl.value, 0) - COALESCE(cl.before_value, 0)) / COALESCE(cl.before_value, 0), 3) * 100;



        -- 递增日期
        _test_date := _test_date + INTERVAL '1 day';
    END LOOP;

    COMMIT;
END;
$$;




-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."warehouse-daily-report";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."warehouse-daily-report"() 
LANGUAGE plpgsql AS $$
DECLARE
    _test_date DATE := '2020-01-01';
BEGIN
    START TRANSACTION;

    WHILE _test_date < CURRENT_DATE LOOP
        -- 在此处添加你的处理逻辑
        

insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims, b.setting_key as data_val, 'warehouse-daily-report' as stat_code, 'stock-in' as group1,  round(sum(COALESCE(at.FQty,0)),2) as val1, round(sum(COALESCE(at.FQty,0)),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(at.FQty,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 from Trans_assist_table at join Trans_main_table mt on mt.FInterID = at.FinterID and mt.FTranType = at.FTranType and mt.FCancellation = 1 and mt.FSaleStyle = 0 and mt.FTranType = 'SOR' and date_format(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)
right join lh_dw.data_statistics_results as r on  r.data_val = mt.FRelateBrID  right join uct_branch b on cast(b.setting_key as char) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'warehouse-daily-report' and r.group1 = 'stock-in' group by b.setting_key;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims, b.setting_key as data_val, 'warehouse-daily-report' as stat_code , 'stock-out' as group1 ,  round(sum(COALESCE(mt.TalFQty,0)),2) as val1, round(sum(COALESCE(mt.TalFQty,0)),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(mt.TalFQty,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 from Trans_main_table mt
right join lh_dw.data_statistics_results as r on r.data_val = mt.FRelateBrID and mt.FCancellation = 1 and mt.FCorrent = 1 and mt.FSaleStyle = 2 and mt.FTranType = 'SEL'  and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY)  right join uct_branch as b on cast(b.setting_key as char) = r.data_val and r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'warehouse-daily-report' and r.group1 = 'stock-out'   group by  b.setting_key;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims, b.setting_key as data_val, 'warehouse-daily-report' as stat_code , 'order-status-count' as group1 , 'wait_storage_sort' as group2 ,sum(if(mt.FNowState = 'wait_storage_sort',1,0)) as val1, sum(if(mt.FNowState = 'wait_storage_sort',1,0)) - COALESCE(r.val1,0) as val2, COALESCE(round((sum(if(mt.FNowState = 'wait_storage_sort',1,0)) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 from Trans_main_table mt
right join lh_dw.data_statistics_results as r on r.data_val = mt.FRelateBrID and mt.FCancellation = 1  and mt.FSaleStyle in(0,3) and mt.FTranType = 'PUR'  right join uct_branch as b on cast(b.setting_key as char) = r.data_val and r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'warehouse-daily-report' and r.group1 = 'order-status-count' and r.group2 = 'wait_storage_sort'  group by  b.setting_key;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims, b.setting_key as data_val, 'warehouse-daily-report' as stat_code , 'order-status-count' as group1 , 'wait_pick_cargo' as group2 ,sum(if(mt.FNowState = 'wait_pick_cargo',1,0)) as val1, sum(if(mt.FNowState = 'wait_pick_cargo',1,0)) - COALESCE(r.val1,0) as val2, COALESCE(round((sum(if(mt.FNowState = 'wait_pick_cargo',1,0)) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 from Trans_main_table mt
right join lh_dw.data_statistics_results as r on r.data_val = mt.FRelateBrID and mt.FCancellation = 1  and mt.FSaleStyle in(0,3) and mt.FTranType = 'PUR'  right join uct_branch as b on cast(b.setting_key as char) = r.data_val and r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'warehouse-daily-report' and r.group1 = 'order-status-count' and r.group2 = 'wait_pick_cargo'  group by  b.setting_key;


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims, b.setting_key as data_val, 'warehouse-daily-report' as stat_code , 'order-status-count' as group1  , 'wait_storage_connect_confirm' as group2 ,sum(if(mt.FNowState = 'wait_storage_connect_confirm',1,0)) as val1, sum(if(mt.FNowState = 'wait_storage_connect_confirm',1,0)) - COALESCE(r.val1,0) as val2, COALESCE(round((sum(if(mt.FNowState = 'wait_storage_connect_confirm',1,0)) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 from Trans_main_table mt
right join lh_dw.data_statistics_results as r on r.data_val = mt.FRelateBrID and mt.FCancellation = 1  and mt.FSaleStyle in(0,3) and mt.FTranType = 'PUR'  right join uct_branch as b on cast(b.setting_key as char) = r.data_val and r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'warehouse-daily-report' and r.group1 = 'order-status-count' and r.group2 = 'wait_storage_connect_confirm'  group by  b.setting_key;



insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '分部' as data_dims, b.setting_key as data_val, 'warehouse-daily-report' as stat_code , 'order-status-count' as group1 , 'wait_storage_connect' as group2 ,sum(if(mt.FNowState = 'wait_storage_connect',1,0)) as val1, sum(if(mt.FNowState = 'wait_storage_connect',1,0)) - COALESCE(r.val1,0) as val2, COALESCE(round((sum(if(mt.FNowState = 'wait_storage_connect',1,0)) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 from Trans_main_table mt
right join lh_dw.data_statistics_results as r on r.data_val = mt.FRelateBrID and mt.FCancellation = 1  and mt.FSaleStyle in(0,3) and mt.FTranType = 'PUR'  right join uct_branch as b on cast(b.setting_key as char) = r.data_val and r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '分部' and r.stat_code = 'warehouse-daily-report' and r.group1 = 'order-status-count' and r.group2 = 'wait_storage_connect'  group by  b.setting_key;



        INSERT INTO lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,stat_code,group1,group2,txt1,val1,val2,val3,data_val) 
        SELECT * FROM (
            SELECT rows.time_dims,rows.time_val,rows.begin_time,rows.end_time,rows.data_dims,rows.stat_code,rows.group1,rows.group2,rows.txt1,rows.val1,rows.val2 ,
                CASE
                    WHEN classname = rows.data_val THEN
                        rank + 1
                    ELSE
                        1
                END AS rank,
                rows.data_val
            FROM (
                SELECT
                    'D' as time_dims,
                    DATE_SUB(_test_date, INTERVAL '1 DAY') as time_val,
                    CAST((CAST(_test_date AS DATE) - INTERVAL '1 DAY') AS DATETIME) as begin_time,
                    CAST(CAST(_test_date AS DATE) AS DATETIME) as end_time,
                    '分部' as data_dims,
                    c.branch_id as data_val,
                    'warehouse-daily-report' as stat_code,
                    'stock-in-out-by-waste-cate-top10' as group1,
                    c.id as group2,
                    c.name as txt1,
                    SUM(CASE
                        WHEN at.FTranType = 'SOR' AND date_format(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date, INTERVAL '1 DAY')
                        THEN at.FQty
                        ELSE 0
                    END) as val1,
                    SUM(CASE
                        WHEN at.FTranType = 'SEL' AND mt.FCorrent = 1 AND date_format(mt.FDate, '%Y-%m-%d') = DATE_SUB(_test_date, INTERVAL '1 DAY')
                        THEN at.FQty
                        ELSE 0
                    END) as val2
                FROM Trans_assist_table at
                JOIN Trans_main_table mt ON at.FinterID = mt.FInterID AND at.FTranType = mt.FTranType AND at.FTranType IN ('SOR', 'SEL') AND mt.FCancellation = 1
                RIGHT JOIN uct_waste_cate c ON c.id = at.FItemID
                GROUP BY c.id
                ORDER BY c.branch_id, SUM(CASE
                    WHEN at.FTranType = 'SOR' AND date_format(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date, INTERVAL '1 DAY')
                    THEN at.FQty
                    ELSE 0
                END) DESC
            ) as rows
        ) as res
        WHERE res.rank < 11;	
		
		
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, stat_code, group1, group2, txt1, val1, val2, data_val) 
        SELECT * FROM (
            SELECT 
                rows.time_dims,
                rows.time_val,
                rows.begin_time,
                rows.end_time,
                rows.data_dims,
                rows.stat_code,
                rows.group1,
                rows.group2,
                rows.txt1,
                rows.val1,
                rows.val2,
                CASE WHEN temp_data_val = rows.data_val THEN rank + 1 ELSE 1 END as rank,
                temp_data_val as data_val
            FROM (
                SELECT 'D' as time_dims, 
                       DATE_SUB(_test_date, INTERVAL 1 DAY) as time_val,
                       CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) as begin_time,
                       CAST(CAST(_test_date AS DATE) AS DATETIME) as end_time,
                       '分部' as data_dims,
                       c.branch_id as data_val,
                       'warehouse-daily-report' as stat_code,
                       'stock-qty-by-waste-cate-top20' as group1,
                       c.id as group2,
                       c.name as txt1,
                       COALESCE(s.FQty, 0) as val1
                FROM Accoding_stock s 
                JOIN uct_waste_cate c ON s.FItemID = c.id 
                ORDER BY c.branch_id, COALESCE(s.FQty, 0) DESC
            ) as rows
            CROSS JOIN LATERAL (
                SELECT CASE WHEN temp_data_val = rows.data_val THEN rank + 1 ELSE 1 END as rank,
                       rows.data_val as temp_data_val
            ) as temp_data
        ) as res
        WHERE res.rank < 21;



        INSERT INTO lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,stat_code,group1,group2,val1,val2,val3,data_val) 
        SELECT 
            rows.time_dims,
            rows.time_val,
            rows.begin_time,
            rows.end_time,
            rows.data_dims,
            rows.stat_code,
            rows.group1,
            rows.group2,
            rows.val1,
            rows.val2,
            CASE WHEN classname = rows.data_val THEN rank + 1 ELSE 1 END as rank,
            classname as data_val
        FROM (
            SELECT 
                'D' as time_dims,
                DATE_SUB(_test_date, INTERVAL 1 DAY) as time_val,
                CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) as begin_time,
                CAST(CAST(_test_date AS DATE) AS DATETIME) as end_time,
                '分部' as data_dims,
                a.branch_id as data_val,
                'warehouse-daily-report' as stat_code,
                'performance-commission-weight' as group1,
                a.nickname as group2,
                round(sum(COALESCE(mt.TalForth,0)),2) as val1,
                round(sum(COALESCE(mt.TalFQty,0)),2) as val2
            FROM Trans_main_table mt  
            RIGHT JOIN uct_admin a ON cast(a.id as char) = mt.FEmpID AND mt.FCancellation = 1 AND mt.FSaleStyle = 0 AND mt.FTranType = 'SOR' AND mt.FDate = DATE_SUB(_test_date, INTERVAL 1 DAY)
            JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42
            GROUP BY a.id
            ORDER BY a.branch_id, round(sum(COALESCE(mt.TalFQty,0)),2) DESC
        ) as rows;



        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, stat_code, group1, group2, val1, val2, val3, data_val) 
        SELECT * FROM (
            SELECT 
                rows.time_dims,
                rows.time_val,
                rows.begin_time,
                rows.end_time,
                rows.data_dims,
                rows.stat_code,
                rows.group1,
                rows.group2,
                rows.val1,
                rows.val2,
                CASE WHEN temp_data_val = rows.data_val THEN rank + 1 ELSE 1 END as rank,
                temp_data_val as data_val
            FROM (
                SELECT 
                    'D' as time_dims,
                    DATE_SUB(_test_date, INTERVAL 1 DAY) as time_val,
                    CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) as begin_time,
                    CAST(CAST(_test_date AS DATE) AS DATETIME) as end_time,
                    '分部' as data_dims,
                    a.branch_id as data_val,
                    'warehouse-daily-report' as stat_code,
                    'performance-valuable-unvaluable' as group1,
                    a.nickname as group2,
                    sum(CASE WHEN at.value_type = 'valuable' THEN COALESCE(at.FQty, 0) ELSE 0 END) as val1,
                    sum(CASE WHEN at.value_type = 'unvaluable' THEN COALESCE(at.FQty, 0) ELSE 0 END) as val2
                FROM Trans_main_table mt  
                JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND at.FTranType = mt.FTranType AND at.FTranType = 'SOR'  
                RIGHT JOIN uct_admin a ON cast(a.id as char) = mt.FEmpID AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND date_format(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date, INTERVAL 1 DAY)  
                JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42  
                GROUP BY a.id
                ORDER BY a.branch_id, round(sum(COALESCE(mt.TalFQty, 0)), 2) DESC
            ) as rows
            CROSS JOIN LATERAL (
                SELECT CASE WHEN temp_data_val = rows.data_val THEN rank + 1 ELSE 1 END as rank,
                       rows.data_val as temp_data_val
            ) as temp_data
        ) as res;
		
		
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, stat_code, group1, group2, val1, val2, val3, data_val) 
        SELECT 
            rows.time_dims,
            rows.time_val,
            rows.begin_time,
            rows.end_time,
            rows.data_dims,
            rows.stat_code,
            rows.group1,
            rows.group2,
            rows.val1,
            rows.val2,
            CASE WHEN temp_data_val = rows.data_val THEN rank + 1 ELSE 1 END as rank,
            temp_data_val as data_val
        FROM (
            SELECT 
                'D' as time_dims,
                DATE_SUB(_test_date, INTERVAL 1 DAY) as time_val,
                CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) as begin_time,
                CAST(CAST(_test_date AS DATE) AS DATETIME) as end_time,
                '分部' as data_dims,
                a.branch_id as data_val,
                'warehouse-daily-report' as stat_code,
                'performance-sorting-weighing' as group1,
                a.nickname as group2,
                sum(CASE WHEN at.disposal_way = 'sorting' THEN COALESCE(at.FQty, 0) ELSE 0 END) as val1,
                sum(CASE WHEN at.disposal_way = 'weighing' THEN COALESCE(at.FQty, 0) ELSE 0 END) as val2
            FROM Trans_main_table mt  
            JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND at.FTranType = mt.FTranType AND at.FTranType = 'SOR'  
            RIGHT JOIN uct_admin a ON cast(a.id as char) = mt.FEmpID AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND date_format(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date, INTERVAL 1 DAY)  
            JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42  
            GROUP BY a.id
            ORDER BY a.branch_id, round(sum(COALESCE(mt.TalFQty, 0)), 2) DESC
        ) as rows;		
		
		
		
        -- 递增日期
        _test_date := _test_date + INTERVAL '1 day';
    END LOOP;

    COMMIT;
END;
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."wall_report";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."wall_report"(IN "region_type" varchar(20)) 
LANGUAGE plpgsql AS $$
DECLARE
    nowdate date DEFAULT CURRENT_DATE;
    adcode_where varchar(100);
    customer_where varchar(100);
    customer_group_field varchar(100);
    factory_group_field varchar(100);
    factory_where varchar(100);
    sql_statement text; -- 使用 text 数据类型声明 SQL 语句变量
BEGIN
    -- 将日期赋值给 nowdate 变量
    nowdate := TO_CHAR(CURRENT_DATE - INTERVAL '1 day', '%Y-%m-%d');

    -- 根据需要设置其他变量的值，省略部分代码

    -- 构建第一个 SQL 语句
    sql_statement := 
        'INSERT INTO uct_day_wall_report(adcode, weight, availability, rubbish, rdf, carbon, box, customer_num, report_date) ' ||
        'SELECT ad.adcode, COALESCE(weight, 0) as weight, COALESCE(availability, 0) as availability, COALESCE(rubbish, 0) as rubbish, ' ||
        'COALESCE(rdf, 0) as rdf, COALESCE(carbon, 0) as carbon, COALESCE(box, 0) as box, COALESCE(customer.customer_num, 0) as customer_num, ' ||
        '''' || nowdate || ''' as report_date ' ||
        'FROM uct_adcode ad LEFT JOIN ' ||
        '(SELECT ad.adcode, round(sum(FQty), 2) as weight, round(sum(if(c.name = ''低值废弃物'', FQty, 0))/sum(FQty), 2) as availability, ' ||
        'round(sum(if(c.name = ''低值废弃物'', FQty, 0)), 2) as rubbish, round(sum(if(c.name = ''低值废弃物'', FQty, 0))/sum(FQty)*4.2, 2) as rdf, ' ||
        'round(sum(FQty*c2.carbon_parm), 2) as carbon, box.box ' ||
        'FROM Trans_main_table mt JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND ' ||
        'date_format(mt2.FDate, ''%Y-%m-%d'') > ''2018-09-30'' AND date_format(mt2.FDate, ''%Y-%m-%d'') = TO_CHAR(''' || nowdate || ''', ''%Y-%m-%d'') ' ||
        'JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id ' ||
        'JOIN uct_adcode ad ON ad.name =  ' || factory_where || ' JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType ' ||
        'JOIN uct_waste_cate c ON c.id = at.FItemID JOIN uct_waste_cate c2 ON c.parent_id = c2.id ' ||
        'LEFT JOIN (SELECT ad.adcode,sum(FUseCount) as box FROM Trans_main_table mt JOIN uct_waste_purchase p ON mt.FInterID = p.id ' ||
        'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id JOIN uct_adcode ad ON ad.name =  ' || factory_where || ' JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID ' ||
        'JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType IN (''PUR'', ''SOR'') AND materiel2.name = ''分类箱'' ' ||
        'WHERE date_format(mt.FDate, ''%Y-%m-%d'') > ''2018-09-30'' AND mt.FTranType = ''PUR'' AND mt.FSaleStyle IN (''0'', ''1'') ' ||
        'AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 ' ||
        'GROUP BY ' || factory_group_field || ' ORDER BY cf.area) box ON box.adcode = ad.adcode ' ||
        'WHERE mt.FTranType IN (''SOR'', ''SEL'') AND mt.FSaleStyle IN (''0'', ''1'') AND mt.FCorrent = ''1'' ' ||
        'AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 ' ||
        'GROUP BY ' || factory_group_field || ') data ON ad.adcode = data.adcode ' ||
        'LEFT JOIN (SELECT ad.adcode, count(*) as customer_num FROM uct_up up ' ||
        'JOIN uct_adcode ad ON ' || customer_where || ' = ad.name  ' ||
        'GROUP BY ' || customer_group_field || ') customer ON customer.adcode = ad.adcode ' ||
        'WHERE ' || adcode_where;

    -- 执行第一个 SQL 语句
    EXECUTE sql_statement;

    -- 构建第二个 SQL 语句
    sql_statement :='
        UPDATE uct_accumulate_wall_report report
        JOIN (
            SELECT ad.adcode, COALESCE(weight,0) as weight, COALESCE(availability,0) as availability, COALESCE(rubbish,0) as rubbish,
            COALESCE(rdf,0) as rdf, COALESCE(carbon,0) as carbon, COALESCE(box,0) as box, COALESCE(customer.customer_num,0) as customer_num
            FROM uct_adcode ad
            LEFT JOIN (
                -- 第一个 SQL 查询的内容
            ) data ON ad.adcode = data.adcode
            LEFT JOIN (
                -- 第二个 SQL 查询的内容
            ) customer ON customer.adcode = ad.adcode
            WHERE ' || adcode_where || '
        ) data ON report.adcode = data.adcode
        SET report.weight = data.weight, report.availability = data.availability, report.rubbish = data.rubbish,
            report.rdf = data.rdf, report.carbon = data.carbon, report.box = data.box, report.customer_num = data.customer_num';
    
 

    -- 执行第二个 SQL 语句
    EXECUTE sql_statement;

END; $$;




DROP PROCEDURE IF EXISTS "test_lvhuan"."update_station_task";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."update_station_task"(in p_line_id varchar(20),
 in p_station_id    varchar(20),
 in p_device_id     varchar(20),
 in p_device_label  varchar(20),
 in p_cate_id       integer,
 in p_cate_name     varchar(20),
 in p_package_no    varchar(20),
 in p_leader        integer,
 INOUT o_rv           integer,
 INOUT o_err          varchar(200)) 
LANGUAGE plpgsql AS $$
DECLARE
    v_cate_id integer;
    v_task_id integer;
    v_package_no varchar(20);
    is_exists_package_no integer;
    is_close_package integer;
    is_active_package_no integer;
BEGIN
    -- 设置 v_cate_id, v_task_id, 和 v_package_no 以及其他变量的初始值
    
    BEGIN
        select id, cate_id, package_no
          into v_task_id, v_cate_id, v_package_no
          from uct_sorting_tasks
         where active = 1
           and line_id    = p_line_id
           and station_id = p_station_id
           and device_id  = p_device_id
         limit 1;

         
        select count(1) into is_exists_package_no
          from uct_sorting_tasks
         where package_no = p_package_no;

        
        select count(1) into is_close_package
          from uct_sorting_packings
         where package_no = p_package_no
           and status = 'close';

        
        if v_task_id is null and is_exists_package_no = 0 and is_close_package = 0 then

            insert into uct_sorting_tasks
                        (  line_id,   station_id,   device_id,   device_label,   cate_id,   cate_name, active,   leader,   package_no)
                  value (p_line_id, p_station_id, p_device_id, p_device_label, p_cate_id, p_cate_name,      1, p_leader, p_package_no);
            insert into uct_sorting_packings
                        ( package_no,    station_id,   device_id,   cate_id, begin_time, status)
                  value (p_package_no, p_station_id, p_device_id, p_cate_id,      now(), 'open');

            commit;

            set o_rv = 200;
            set o_err = '已建立新的任务.';
            RETURN;
        end if;


        
        if v_task_id is not null and  v_cate_id = p_cate_id and v_package_no = p_package_no then
            set o_rv = 201;
            set o_err = '提交的数据无变化,未更新.';
            RETURN;
        end if;

        
        if is_close_package > 0 then
            set o_rv = 502;
            set o_err = '这个包装编号已封包了,无法使用了.';
            RETURN;
        end if;

        
        select count(1) into is_active_package_no
          from uct_sorting_tasks
         where active = 1
           and package_no = p_package_no;

         
        if is_exists_package_no > 0  and is_active_package_no > 0 then
            set o_rv = 501;
            set o_err = '这个包装编号正在被使用.';
            RETURN;
        end if;
        
        if is_exists_package_no > 0  and is_active_package_no = 0 then
            insert into uct_sorting_tasks
                        (  line_id,   station_id,   device_id,   device_label,   cate_id,   cate_name, active,   leader,   package_no)
                  value (p_line_id, p_station_id, p_device_id, p_device_label, p_cate_id, p_cate_name,      2, p_leader, p_package_no);

            update uct_sorting_tasks
               set active = active - 1
             where line_id = p_line_id
               and station_id = p_station_id
               and device_id  = p_device_id
               and active > 0;

            commit;

            set o_rv = 200;
            set o_err = '已建立新的任务.';
            RETURN;
        end if;

      insert into uct_sorting_tasks
                (  line_id,   station_id,   device_id,   device_label,   cate_id,   cate_name, active,   leader,   package_no)
          value (p_line_id, p_station_id, p_device_id, p_device_label, p_cate_id, p_cate_name,      2, p_leader, p_package_no);

    update uct_sorting_tasks
       set active = active - 1
     where line_id = p_line_id
       and station_id = p_station_id
       and device_id  = p_device_id
       and active > 0;

    insert into uct_sorting_packings
                (  package_no,   station_id,   device_id,   cate_id, begin_time, status)
          value (p_package_no, p_station_id, p_device_id, p_cate_id,      now(), 'open');
    commit;

        set o_rv = 200;
        set o_err = '任务已更新.';
        RETURN;

    END;
END; $$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."uct_main_effective_table_insert";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."uct_main_effective_table_insert"() 
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO uct_main_effective_table (FBillNo, FCorrent, FDate)
    SELECT FBillNo, SUM(FCorrent) as FCorrent, MAX(FDate) AS FDate
    FROM Trans_main_table
    WHERE FSaleStyle <> 2 
    GROUP BY FBillNo
    HAVING SUM(FCorrent) = 2 AND MAX(FDate) BETWEEN '2020-01-01 00:00:00' AND now()
    ON CONFLICT (FBillNo) DO UPDATE
    SET FCorrent = excluded.FCorrent, FDate = excluded.FDate;
END; $$;





DROP PROCEDURE IF EXISTS "test_lvhuan"."trigger_error_210104";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."trigger_error_210104"() 
LANGUAGE plpgsql AS $$
DECLARE
    order_cancel_row RECORD;
    id_field int;
    order_id_field int;
    order_num_field varchar(50);
    type_field varchar(5);
    hand_mouth_data_field int;
    corrent_field int;
    handle_field int;
    order_type varchar(10);
BEGIN
    FOR order_cancel_row IN (SELECT id, order_id, order_num, type, hand_mouth_data, corrent, handle 
                             FROM uct_order_cancel 
                             GROUP BY order_id, type, hand_mouth_data) 
    LOOP
        id_field := order_cancel_row.id;
        order_id_field := order_cancel_row.order_id;
        order_num_field := order_cancel_row.order_num;
        type_field := order_cancel_row.type;
        hand_mouth_data_field := order_cancel_row.hand_mouth_data;
        corrent_field := order_cancel_row.corrent;
        handle_field := order_cancel_row.handle;
        
        order_type := 'PUR,SOR';
        
        IF type_field = 'SEL' THEN
            order_type := 'SEL';
        END IF;
        
        id_field := 0;
        SELECT FInterID INTO id_field FROM Trans_fee_table WHERE FIND_IN_SET(FTranType, order_type) AND FInterID = order_id_field LIMIT 1;
        
        IF id_field > 0 THEN
            DELETE FROM Trans_fee_table WHERE FIND_IN_SET(FTranType, order_type) AND FInterID = order_id_field;
            INSERT INTO Trans_fee_table SELECT *, NULL, 0, 0 FROM Trans_fee WHERE FIND_IN_SET(FTranType, order_type) AND FInterID = order_id_field;
        END IF;
        
        id_field := 0;
        SELECT FInterID INTO id_field FROM Trans_assist_table WHERE FIND_IN_SET(FTranType, order_type) AND FInterID = order_id_field LIMIT 1;
        
        IF id_field > 0 THEN
            DELETE FROM Trans_assist_table WHERE FIND_IN_SET(FTranType, order_type) AND FInterID = order_id_field;
            INSERT INTO Trans_assist_table SELECT *, NULL, 0, 0 FROM Trans_assist WHERE FIND_IN_SET(FTranType, order_type) AND FInterID = order_id_field;
        END IF;
        
        -- 其他操作同上...
		
      set id_field = 0;
       
    select FInterID into id_field from Trans_assist_table where find_in_set(FTranType,order_type) and FInterID = order_id_field limit 1;
        if id_field > 0 then
        delete from Trans_assist_table where find_in_set(FTranType,order_type) and FInterID = order_id_field;
        insert into Trans_assist_table select *,NULL,0,0 from Trans_assist where find_in_set(FTranType,order_type) and FInterID = order_id_field;
        end if;

        select order_id_field;

        
        set id_field = 0;
    select FInterID into id_field from Trans_materiel_table where find_in_set(FTranType,order_type) and FInterID = order_id_field limit 1;
        if id_field > 0 then
        delete from Trans_materiel_table where find_in_set(FTranType,order_type) and FInterID = order_id_field;
        insert into Trans_materiel_table select *,NULL,0,0 from Trans_materiel where find_in_set(FTranType,order_type) and FInterID = order_id_field;
        end if;
        
        
        set id_field = 0;
    select FInterID into id_field from Trans_log_table where find_in_set(FTranType,order_type) and FInterID = order_id_field limit 1;
        if id_field > 0 then
        delete from Trans_log_table where find_in_set(FTranType,order_type) and FInterID = order_id_field;
        insert into Trans_log_table select * from Trans_log where find_in_set(FTranType,order_type) and FInterID = order_id_field;
        end if;

        
        set id_field = 0;
    select FInterID into id_field from Trans_log_table where find_in_set(FTranType,order_type) and FInterID = order_id_field limit 1;
        if id_field > 0 then
        delete from Trans_main_table where find_in_set(FTranType,order_type) and FInterID = order_id_field;
        insert into Trans_main_table select *,0,0,0,0,null from Trans_main where find_in_set(FTranType,order_type) and FInterID = order_id_field;
        end if;
        
        SET done = 0; 


		
		
		
    END LOOP;
END;
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_sl";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_sl"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Trans_fee_table WHERE FTranType = 'SEL' AND Ffeesence = 'SL' AND FInterID = id;
    INSERT INTO Trans_fee_table 
    SELECT "uct_waste_sell_other_price"."sell_id" AS "FInterID", 
           'SEL' AS "FTranType", 
           'SL' AS "Ffeesence", 
           "uct_waste_sell_other_price"."id" AS "FEntryID", 
           "uct_waste_sell_other_price"."usage" AS "FFeeID",
           "uct_waste_sell_other_price"."type" AS "FFeeType", 
           "uct_waste_sell_other_price"."receiver" AS "FFeePerson", 
           "uct_waste_sell_other_price"."remark" AS "FFeeExplain", 
           "uct_waste_sell_other_price"."price" AS "FFeeAmount", 
           '' AS "FFeebaseAmount",
           '' AS "Ftaxrate", 
           '' AS "Fbasetax", 
           '' AS "Fbasetaxamount", 
           '' AS "FPriceRef",
           TO_CHAR(TO_TIMESTAMP("uct_waste_sell_other_price"."createtime"), 'YYYY-MM-DD HH24:MI:SS') AS "FFeetime", 
           NULL AS "red_ink_time", 
           0 AS "is_hedge", 
           0, 
           0
    FROM "uct_waste_sell_other_price" 
    WHERE "uct_waste_sell_other_price"."sell_id" = id;
END;
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_assist_sel";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_assist_sel"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Trans_assist_table WHERE FTranType = 'SEL' AND FInterID = id;
    INSERT INTO Trans_assist_table 
    SELECT "uct_waste_sell_cargo"."sell_id" AS "FInterID", 
           'SEL' AS "FTranType", 
           "uct_waste_sell_cargo"."id" AS "FEntryID", 
           "uct_waste_sell_cargo"."cate_id" AS "FItemID", 
           '1' AS "FUnitID",
           "uct_waste_sell_cargo"."net_weight" AS "FQty",
           "uct_waste_sell_cargo"."unit_price" AS "FPrice",
           ROUND("uct_waste_sell_cargo"."unit_price" * "uct_waste_sell_cargo"."net_weight", 2) AS "FAmount",
           'sorting' AS "disposal_way",
           'valuable' AS "value_type",
           '' AS "FbasePrice", 
           '' AS "FbaseAmount", 
           '' AS "Ftaxrate", 
           '' AS "Fbasetax", 
           '' AS "Fbasetaxamount",
           '' AS "FPriceRef", 
           TO_CHAR(TO_TIMESTAMP("uct_waste_sell_cargo"."updatetime"), 'YYYY-MM-DD HH24:MI:SS') AS "FDCTime",
           CASE WHEN "uct_waste_sell"."purchase_id" > 0 THEN "uct_waste_sell"."purchase_id" ELSE NULL END AS "FSourceInterID",
           CASE WHEN "uct_waste_sell"."purchase_id" > 0 THEN 'PUR' ELSE NULL END AS "FSourceTranType",
           NULL AS "red_ink_time", 
           0 AS "is_hedge",
           0,
           0
    FROM "uct_waste_sell_cargo"
    JOIN "uct_waste_sell"
    ON "uct_waste_sell_cargo"."sell_id" = "uct_waste_sell"."id" 
    WHERE "uct_waste_sell"."id" = id;
END;
$$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_materiel_sel";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_materiel_sel"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Trans_materiel_table WHERE FTranType = 'SEL' AND FInterID = id;
    INSERT INTO Trans_materiel_table 
    SELECT "uct_waste_sell_materiel"."sell_id" AS "FInterID", 
           'SEL' AS "FTranType", 
           "uct_waste_sell_materiel"."id" AS "FEntryID", 
           "uct_waste_sell_materiel"."materiel_id" AS "FMaterielID", 
           "uct_waste_sell_materiel"."pick_amount" AS "FUseCount",
           "uct_waste_sell_materiel"."unit_price" AS "FPrice",
           ROUND("uct_waste_sell_materiel"."pick_amount" * "uct_waste_sell_materiel"."unit_price", 2) AS "FMeterielAmount",
           TO_TIMESTAMP("uct_waste_sell_materiel"."updatetime") AS "FMeterieltime",
           NULL AS "red_ink_time", 
           0 AS "is_hedge",
           0,
           0
    FROM "uct_waste_sell_materiel"
    WHERE "uct_waste_sell_materiel"."sell_id" = id;
END;
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_log_pur_hand";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_log_pur_hand"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Trans_log_table WHERE FTranType = 'PUR' AND FInterID = id;
    INSERT INTO Trans_log_table
    SELECT "Plog"."purchase_id" AS "FInterID", 
           'PUR' AS "FTranType", 
           MAX(CASE "Plog"."state_value"
               WHEN 'draft' THEN "Plog"."createtime"
           END) AS "TCreate",
           MAX(CASE "Plog"."state_value"
               WHEN 'draft' THEN "Plog"."admin_id"
           END) AS "TCreatePerson",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_allot' THEN '1'
               ELSE '0'
           END) AS "TallotOver",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_allot' THEN "Plog"."admin_id"
           END) AS "TallotPerson",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_allot' THEN "Plog"."createtime"
           END) AS "Tallot",
           MAX(CASE "Slog"."state_value"
               WHEN 'wait_commit_order' THEN '1'
               ELSE '0'
           END) AS "TgetorderOver",
           MAX(CASE "Slog"."state_value"
               WHEN 'wait_commit_order' THEN "Slog"."admin_id"
           END) AS "TgetorderPerson",
           MAX(CASE "Slog"."state_value"
               WHEN 'wait_commit_order' THEN "Slog"."createtime"
           END) AS "Tgetorder",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_receive_order' THEN '1'
               ELSE '0'
           END) AS "TmaterialOver",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_receive_order' THEN "Plog"."admin_id"
           END) AS "TmaterialPerson",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_receive_order' THEN "Plog"."createtime"
           END) AS "Tmaterial",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_pick_cargo' THEN '1'
               ELSE '0'
           END) AS "TpurchaseOver",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_pick_cargo' THEN "Plog"."admin_id"
               ELSE NULL
           END) AS "TpurchasePerson",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_pick_cargo' THEN "Plog"."createtime"
               ELSE NULL
           END) AS "Tpurchase",
           MAX(CASE "Slog"."state_value"
               WHEN 'wait_pay' THEN '1'
               ELSE '0'
           END) AS "TpayOver",
           MAX(CASE "Slog"."state_value"
               WHEN 'wait_pay' THEN "Slog"."admin_id"
               ELSE NULL
           END) AS "TpayPerson",
           MAX(CASE "Slog"."state_value"
               WHEN 'wait_pay' THEN "Slog"."createtime"
               ELSE NULL
           END) AS "Tpay",
           MAX(CASE "Slog"."state_value"
               WHEN 'finish' THEN '1'
               ELSE '0'
           END) AS "TchangeOver",
           MAX(CASE "Slog"."state_value"
               WHEN 'finish' THEN "Slog"."admin_id"
           END) AS "TchangePerson",
           MAX(CASE "Slog"."state_value"
               WHEN 'finish' THEN "Slog"."createtime"
           END) AS "Tchange",
           NULL AS "TexpenseOver",
           NULL AS "TexpensePerson",
           NULL AS "Texpense",
           NULL AS "TsortOver",
           NULL AS "TsortPerson",
           NULL AS "Tsort",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_return_fee' THEN '1'
               ELSE '0'
           END) AS "TallowOver",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_return_fee' THEN "Plog"."admin_id"
           END) AS "TallowPerson",
           MAX(CASE "Plog"."state_value"
               WHEN 'wait_return_fee' THEN "Plog"."createtime"
           END) AS "Tallow",
           MAX(CASE "Plog"."state_value"
               WHEN 'finish' THEN '1'
               ELSE '0'
           END) AS "TcheckOver",
           MAX(CASE "Plog"."state_value"
               WHEN 'finish' THEN "Plog"."admin_id"
               ELSE NULL
           END) AS "TcheckPerson",
           MAX(CASE "Plog"."state_value"
               WHEN 'finish' THEN "Plog"."createtime"
               ELSE '0'
           END) AS "Tcheck",
           "P"."state" AS "State"
    FROM "uct_waste_sell" "S"
    JOIN "uct_waste_sell_log" "Slog" ON "S"."id" = "Slog"."sell_id"
    JOIN "uct_waste_purchase" "P" ON "S"."order_id" = "P"."order_id"
    JOIN "uct_waste_purchase_log" "Plog" ON "P"."id" = "Plog"."purchase_id"
    WHERE ("Slog"."is_timeline_data" = '1' AND "P"."id" = id)
    GROUP BY "P"."order_id";
END;
$$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_main_sel_hand";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_main_sel_hand"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Trans_main_table WHERE FTranType = 'SEL' AND FInterID = id;
    INSERT INTO Trans_main_table
    SELECT "uct_waste_sell"."branch_id" AS "FRelateBrID", 
           "uct_waste_sell"."id" AS "FInterID", 
           'SEL' AS "FTranType",
           CASE "Trans_log_table"."TallowOver"
               WHEN '0' THEN date_format(from_unixtime(0), '%Y-%m-%d %H:%i:%S')
               ELSE date_format(from_unixtime("Trans_log_table"."Tallow"), '%Y-%m-%d %H:%i:%S')
           END AS "FDate",
           TO_CHAR(FROM_UNIXTIME("uct_waste_sell".createtime), '%Y-%m-%d %H:%i:%s') as createtime,
           CASE "Trans_log_table"."TallowOver"
               WHEN '0' THEN date_format(from_unixtime(0), '%Y-%m-%d')
               ELSE date_format(from_unixtime("Trans_log_table"."Tallow"), '%Y-%m-%d')
           END AS "Date",
           "uct_waste_purchase"."train_number" AS "FTrainNum", 
           "uct_waste_sell"."order_id" AS "FBillNo", 
           "uct_waste_sell"."customer_id" AS "FSupplyID", 
           '' AS "Fbusiness",
           concat('DC', "uct_waste_sell"."customer_id") AS "FDCStockID",
           CASE WHEN "uct_waste_sell"."purchase_id" IS NOT NULL = 0 THEN concat('LH', "uct_waste_sell"."warehouse_id") 
                ELSE concat('AD', "uct_waste_purchase"."purchase_incharge") 
           END AS "FSCStockID",
           CASE "uct_waste_sell"."state"
               WHEN 'cancel' THEN '0'
               ELSE '1'
           END AS "FCancellation", 
           '0' AS "FROB", 
           "Trans_log_table"."TallowOver" AS "FCorrent", 
           "Trans_log_table"."TcheckOver" AS "FStatus", 
           '0' AS "FUpStockWhenSave",
           '' AS "FExplanation", 
           '4' AS "FDeptID", 
           "uct_waste_sell"."seller_id" AS "FEmpID", 
           "Trans_log_table"."TcheckPerson" AS "FCheckerID",
           CASE "Trans_log_table"."TcheckOver"
               WHEN '0' THEN 'null'
               ELSE date_format(from_unixtime("Trans_log_table"."Tcheck"), '%Y-%m-%d %H:%i:%S')
           END AS "FCheckDate", 
           "uct_waste_sell"."customer_linkman_id" AS "FFManagerID", 
           "uct_waste_sell"."customer_linkman_id" AS "FSManagerID", 
           "uct_waste_sell"."seller_id" AS "FBillerID", 
           '1' AS "FCurrencyID",
           "Trans_log_table"."state" AS "FNowState",
           CASE WHEN "uct_waste_sell"."purchase_id" IS NOT NULL = 1 THEN '1' ELSE '2' END AS "FSaleStyle",
           '' AS "FPOStyle", 
           '' AS "FPOPrecent", 
           round("uct_waste_sell"."cargo_weight", 1) AS "TalFQty",
           round("uct_waste_sell"."cargo_price", 2) AS "TalFAmount", 
           "uct_waste_sell"."materiel_price" AS "TalFeeFrist",
           "uct_waste_sell"."other_price" AS "TalFeeSecond", 
           0 AS "TalFeeThird", 
           0 AS "TalFeeForth",
           0 AS "TalFeeFifth",
           0,
           0,
           0,
           0,
           NULL
    FROM "uct_waste_sell"
    JOIN "uct_waste_customer"
    JOIN "Trans_log_table"
    JOIN "uct_waste_purchase"
    WHERE (("uct_waste_sell"."customer_id" = "uct_waste_customer"."id")
    AND ("uct_waste_sell"."purchase_id" = "Trans_log_table"."FInterID")
    AND ("Trans_log_table"."FTranType" = 'PUR')
    AND ("uct_waste_sell"."purchase_id" = "uct_waste_purchase"."id")
    AND ("uct_waste_sell"."order_id" > 201806300000000000)
    AND ("uct_waste_sell"."id" = id));
END;
$$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_materiel_pur";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_materiel_pur"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Trans_materiel_table WHERE FTranType = 'PUR' AND FInterID = id;
    INSERT INTO Trans_materiel_table
    SELECT "uct_waste_purchase_materiel"."purchase_id" AS "FInterID", 
           'PUR' AS "FTranType", 
           "uct_waste_purchase_materiel"."id" AS "FEntryID", 
           "uct_waste_purchase_materiel"."materiel_id" AS "FMaterielID",
           CAST("uct_waste_purchase_materiel"."storage_amount" AS signed) AS "FUseCount",
           ROUND("uct_waste_purchase_materiel"."inside_price", 2) AS "FPrice",
           ROUND(CAST("uct_waste_purchase_materiel"."storage_amount" AS signed) * ROUND("uct_waste_purchase_materiel"."inside_price", 2), 2) AS "FMeterielAmount",
           "uct_waste_purchase_materiel"."updatetime" AS "FMeterieltime",
           NULL AS "red_ink_time",
           0 AS "is_hedge",
           0,
           0
    FROM "uct_waste_purchase_materiel"
    WHERE "uct_waste_purchase_materiel"."use_type" = 0 AND "uct_waste_purchase_materiel"."purchase_id" = id;
END;
$$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."sel_add";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."sel_add"(in "id" int,in "pur_id" int) 
LANGUAGE plpgsql AS $$
DECLARE 
    move INT DEFAULT 0;
BEGIN
    IF pur_id IS NOT NULL THEN 
        CALL Trans_fee_sl(id);
        CALL Trans_assist_sel(id);
        CALL Trans_materiel_sel(id);
        CALL Trans_log_pur_hand(pur_id);
        CALL Trans_main_sel_hand(id);
        CALL Trans_materiel_pur(pur_id);
    ELSE 
        SELECT "is_move" INTO move FROM uct_waste_sell AS s WHERE s.id = id;
        IF move = 1 THEN
            CALL Trans_assist_sel(id);
        END IF;

        CALL Trans_materiel_sel(id);
        CALL Trans_log_sel(id);
        CALL Trans_main_sel(id);
    END IF;
END;
$$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."sel_commit_order";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."sel_commit_order"(in "id" int,in "pur_id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    CALL Trans_log_pur_hand(pur_id);
    CALL Trans_main_sel_hand(id);
END;
$$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."sel_confirm_gather";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."sel_confirm_gather"(in "id" int, in "pur_id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    IF pur_id IS NOT NULL THEN
        CALL Trans_log_pur_hand(pur_id);
        CALL Trans_main_sel_hand(id);
    ELSE
        CALL Trans_log_sel(id);
        UPDATE Trans_main_table SET FNowState = 'finish' WHERE FInterID = id AND FTranType = 'SEL';
    END IF;
END;
$$;

DROP PROCEDURE IF EXISTS "test_lvhuan"."sel_confirm_order";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."sel_confirm_order"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    CALL Trans_log_sel(id);
    CALL Trans_main_sel(id);
END;
$$;

DROP PROCEDURE IF EXISTS "test_lvhuan"."sel_weigh";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."sel_weigh"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    CALL Trans_materiel_sel(id);
    CALL Trans_assist_sel(id);
    CALL Trans_fee_sl(id);
    CALL Trans_log_sel(id);
    CALL Trans_main_sel(id);
END;
$$;






DROP PROCEDURE IF EXISTS "test_lvhuan"."sorting-daily-report";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."sorting-daily-report"() 
LANGUAGE plpgsql AS $$
DECLARE
    _test_date DATE := '2020-01-01';
    rank INT := 0;

BEGIN
    START TRANSACTION;

    WHILE _test_date < CURRENT_DATE LOOP
	
insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'sorting-daily-report' as stat_code , 'weight' as group1 ,  round(sum(COALESCE(at.FQty,0)),2) as val1, round(sum(COALESCE(at.FQty,0)),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(at.FQty,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 from Trans_assist_table at join Trans_main_table mt on mt.FInterID = at.FinterID and mt.FTranType = at.FTranType and mt.FCancellation = '1' and mt.FSaleStyle = '0' and mt.FTranType = 'SOR' and date_format(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)
right join lh_dw.data_statistics_results as r on  r.data_val = mt.FEmpID  right join uct_admin a on cast(a.id as char) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'sorting-daily-report' and r.group1 = 'weight' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id = 42  group by a.id;	
	
	
	

        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3, val4)
        SELECT rows.*, rank + 1
        FROM (
            SELECT 'D' as time_dims, DATE_SUB(_test_date, INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY) AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE) AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val, 'sorting-daily-report' as stat_code, 'weight-by-waste-structure' as group1, 'RW' as group2, ROUND(SUM(COALESCE(at.FQty, 0)), 2) as val1, ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0) as val2, COALESCE(ROUND((ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 as val3
            FROM Trans_assist_table at
            JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND DATE_FORMAT(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date, INTERVAL 1 DAY)
            RIGHT JOIN lh_dw.data_statistics_results AS r ON r.data_val = mt.FEmpID AND at.value_type = 'valuable'
            RIGHT JOIN uct_admin a ON CAST(a.id AS CHAR) = r.data_val AND r.time_dims = 'D' AND r.time_val = FROM_UNIXTIME(UNIX_TIMESTAMP(_test_date) - 60 * 60 * 48, '%Y-%m-%d') AND r.data_dims = '角色' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight-by-waste-structure' AND r.group2 = 'RW'
            JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42
            GROUP BY a.id
            ORDER BY ROUND(SUM(COALESCE(at.FQty, 0)), 2) DESC
        ) AS rows;


        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3, val4)
        SELECT rows.*, rank + 1
        FROM (
            SELECT 'D' as time_dims, DATE_SUB(_test_date, INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val , 'sorting-daily-report' as stat_code, 'weight-by-waste-structure' as group1, 'LW' as group2,  round(sum(COALESCE(at.FQty,0)),2) as val1, round(sum(COALESCE(at.FQty,0)),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(at.FQty,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3
            FROM Trans_assist_table at 
            JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND date_format(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)
            RIGHT JOIN lh_dw.data_statistics_results as r ON  r.data_val = mt.FEmpID AND at.value_type = 'unvaluable' 
            RIGHT JOIN uct_admin a ON cast(a.id as char) = r.data_val AND r.time_dims = 'D' AND r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') AND r.data_dims = '角色' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight-by-waste-structure' AND r.group2 = 'LW' 
            JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42  
            GROUP BY a.id  
            ORDER BY round(sum(COALESCE(at.FQty,0)),2)  desc
        ) as rows;
		

INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3, val4)
SELECT rows.*, rank + 1
FROM (
    SELECT 'D' as time_dims, DATE_SUB(_test_date, INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val , 'sorting-daily-report' as stat_code , 'weight-by-waste-sorting' as group1, 'sorting' as group2, round(sum(COALESCE(at.FQty,0)),2) as val1, round(sum(COALESCE(at.FQty,0)),2) - COALESCE(r.val1,0) as val2, COALESCE(round((round(sum(COALESCE(at.FQty,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3
    FROM Trans_assist_table at 
    JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND date_format(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)
    RIGHT JOIN lh_dw.data_statistics_results as r ON  r.data_val = mt.FEmpID AND at.disposal_way = 'sorting' 
    RIGHT JOIN uct_admin a ON cast(a.id as char) = r.data_val AND   r.time_dims = 'D' AND r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') AND r.data_dims = '角色' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight-by-waste-sorting' AND r.group2 = 'sorting' 
    JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42  
    GROUP BY a.id  
    ORDER BY round(sum(COALESCE(at.FQty,0)),2)  DESC
) as rows;



        INSERT INTO lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2,val3,val4)  
        SELECT 
            'D' as time_dims, 
            DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, 
            CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, 
            CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, 
            '角色' as data_dims, 
            a.id as data_val, 
            'sorting-daily-report' as stat_code, 
            'weight-by-waste-sorting' as group1, 
            'weigh' as group2, 
            round(sum(COALESCE(at.FQty,0)),2) as val1, 
            round(sum(COALESCE(at.FQty,0)),2) - COALESCE(r.val1,0) as val2, 
            COALESCE(round((round(sum(COALESCE(at.FQty,0)),2) - COALESCE(r.val1,0))/COALESCE(r.val1,0),2),0)*100 as val3 
        FROM Trans_assist_table at 
        JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' 
                                    AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' 
                                    AND date_format(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)
        RIGHT JOIN lh_dw.data_statistics_results AS r ON r.data_val = mt.FEmpID AND at.disposal_way = 'weighing'  
        RIGHT JOIN uct_admin a ON CAST(a.id AS CHAR) = r.data_val 
        JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42  
        WHERE r.time_dims = 'D' AND r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') 
            AND r.data_dims = '角色' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight-by-waste-sorting' AND r.group2 = 'weigh'
        GROUP BY a.id  
        ORDER BY round(sum(COALESCE(at.FQty,0)),2) DESC;
		


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2,val3) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val , 'sorting-daily-report' as stat_code , 'commission' as group1,  round(sum(COALESCE(mt.TalForth,0)),2) as val1 , round(sum(COALESCE(mt.TalForth,0)),2) - COALESCE(r.val1,0) as val2 ,  COALESCE(round((sum(COALESCE(mt.TalForth,0)) - COALESCE(r.val1,0)) / COALESCE(r.val1,0),2),0)*100 as val3 from  Trans_main_table mt  right join lh_dw.data_statistics_results as r on  r.data_val = mt.FEmpID and mt.FCancellation = '1' and mt.FCorrent = '1' and mt.FSaleStyle = '0' and mt.FTranType = 'SOR' and mt.Date = DATE_SUB(_test_date,INTERVAL 1 DAY) right join uct_admin a on cast(a.id as char) = r.data_val and   r.time_dims = 'D' and r.time_val = from_unixtime(UNIX_TIMESTAMP(_test_date)-60*60*48,'%Y-%m-%d') and r.data_dims = '角色' and r.stat_code = 'sorting-daily-report' and  r.group1 = 'commission' join uct_auth_group_access ga on ga.uid = a.id and ga.group_id = 42  group by a.id;  


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,val1,val2) select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims , d1.admin_id as data_val, 'sorting-daily-report' as stat_code , 'order-count' as group1 , d1.num as val1, d2.num as val2 from 
(select a.id as admin_id, count(lt.FInterID) as num from  Trans_main_table mt join Trans_log_table lt on mt.FInterID = lt.FInterID and lt.TsortOver = '1' and lt.FTranType = 'PUR'  and mt.FCancellation = '1'  and mt.FSaleStyle = '0' and mt.FTranType = 'SOR' and from_unixtime(lt.Tsort, '%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY) right join uct_admin a on a.id = mt.FEmpID  join uct_auth_group_access ga on ga.uid = a.id and ga.group_id = 42  group by a.id) as d1  
join 
(select a.id as admin_id, count(lt.FInterID) as num from  Trans_main_table mt join Trans_log_table lt on mt.FInterID = lt.FInterID and lt.TsortOver != '1' and lt.FTranType = 'PUR'  and mt.FCancellation = '1'  and mt.FSaleStyle = '0' and mt.FTranType = 'SOR'  right join uct_admin a on a.id = mt.FEmpID  join uct_auth_group_access ga on ga.uid = a.id and ga.group_id = 42  group by a.id) as d2 
on d1.admin_id = d2.admin_id; 


insert into lh_dw.data_statistics_results(time_dims,time_val,begin_time,end_time,data_dims,data_val,stat_code,group1,group2,val1,val2) 
select 'D' as time_dims, DATE_SUB(_test_date,INTERVAL 1 DAY) as time_val, CAST((CAST(_test_date AS DATE) - INTERVAL 1 DAY)AS DATETIME) as begin_time, CAST(CAST(_test_date AS DATE)AS DATETIME) as end_time, '角色' as data_dims, a.id as data_val , 'sorting-daily-report' as stat_code , 'order-detail-list' as group1 , mt.FBillNo as group2,  sum(if(at.value_type='valuable',at.FQty,0)) as val1, sum(if(at.value_type='unvaluable',at.FQty,0)) val2 from  Trans_assist_table at join Trans_main_table mt on mt.FInterID = at.FinterID and mt.FTranType = at.FTranType and mt.FCancellation = '1' and mt.FSaleStyle = '0' and mt.FTranType = 'SOR' and date_format(at.FDCTime, '%Y-%m-%d') = DATE_SUB(_test_date,INTERVAL 1 DAY)  join uct_admin a on a.id = mt.FEmpID  join uct_waste_customer c on  c.id = mt.FSupplyID  group by mt.FinterID; 



        rank := rank + 1;
        _test_date := _test_date + INTERVAL '1 day';
    END LOOP;

    COMMIT;
END;
$$;




-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."sorting_end_and_edit";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."sorting_end_and_edit"(in p_line_id varchar(20),
in p_po varchar(20),
INOUT o_rv integer,
INOUT o_err varchar(200)) 
LANGUAGE plpgsql AS $$
DECLARE
    v_id integer;
    v_leader integer;
    v_priority integer;
    v_num integer;
    v_number integer;
    v_pur_id integer;
    v_sub_id integer;
    v_check_id integer;
    v_old_weight float;
    v_old_money float;
    v_now_weight float;
    v_now_money float;
    v_total_weight float;
    v_total_money float;
    v_sort_height float;
    v_sort_low float;
    v_weight_height float;
    v_weight_low float;
    v_sort_cargo_price float;
    v_weight_cargo_price float;
    v_sort_labor_price float;
    v_weight_labor_price float;
    v_commission float;
    v_artificial float;
    errno int;
BEGIN
    -- 异常处理块
    BEGIN
        START TRANSACTION;

        -- 主块开始
        select id, leader, priority into v_id, v_leader, v_priority
        from uct_sorting_jobs
        where (status = 'startup' or status = 'waiting')
            and line_id = p_line_id
            and purchase_order_no = p_po
        limit 1;

        if v_id is null then
            set o_rv = 400;
            set o_err = '获取任务表id失败.';
            RETURN;
        end if;

        select count(1) into v_sub_id
        from uct_sorting_commit
        where line_id = p_line_id
            and purchase_order_no = p_po
            and process = 'pending';

        if v_sub_id > 0 then
            set o_rv = 400;
            set o_err = '请对这个批次的所有数据进行确认后，再点击批次完成.';
            RETURN;
        end if;

        select COALESCE(MAX(revision), 0) + 1 into v_num
        from uct_sorting_job_logs
        where line_id = p_line_id
            and purchase_order_no = p_po;

        if v_num is null then
            set o_rv = 400;
            set o_err = '获取最大的版本号失败.';
            RETURN;
        end if;

        select id, COALESCE(storage_weight, 0), COALESCE(storage_cargo_price, 0) 
        into v_pur_id, v_old_weight, v_old_money
        from uct_waste_purchase
        where order_id = p_po;

        if v_pur_id is null then
            set o_rv = 400;
            set o_err = '获取订单表的自增id失败.';
            RETURN;
        end if;

        select count(1), COALESCE(SUM(net_weight * presell_price), 0), COALESCE(SUM(net_weight), 0)
        into v_check_id, v_now_money, v_now_weight
        from uct_sorting_commit
        where sub_time = 0
            and process = 'passed'
            and line_id = p_line_id
            and purchase_order_no = p_po;

        v_total_weight := v_old_weight + v_now_weight;
        v_total_money := v_old_money + v_now_money;

        select count(id) into v_number
        from uct_sorting_jobs
        where priority > v_priority
            and line_id = p_line_id;

        select COALESCE(SUM(a.net_weight), 0) into v_sort_height
        from uct_sorting_commit as a
        left join uct_waste_cate as b
        on a.cate_id = b.id
        where a.process = 'passed'
            and a.disposal_way = 'sorting'
            and a.sub_time = 0
            and b.value_type = 'valuable'
            and a.purchase_order_no = p_po
            and a.line_id = p_line_id;

        select COALESCE(SUM(a.net_weight), 0) into v_sort_low
        from uct_sorting_commit as a
        left join uct_waste_cate as b
        on a.cate_id = b.id
        where a.process = 'passed'
            and a.disposal_way = 'sorting'
            and a.sub_time = 0
            and b.value_type = 'unvaluable'
            and a.purchase_order_no = p_po
            and a.line_id = p_line_id;

        select COALESCE(SUM(a.net_weight), 0) into v_weight_height
        from uct_sorting_commit as a
        left join uct_waste_cate as b
        on a.cate_id = b.id
        where a.process = 'passed'
            and a.disposal_way = 'weighing'
            and a.sub_time = 0
            and b.value_type = 'valuable'
            and a.purchase_order_no = p_po
            and a.line_id = p_line_id;

        select COALESCE(SUM(a.net_weight), 0) into v_weight_low
        from uct_sorting_commit as a
        left join uct_waste_cate as b
        on a.cate_id = b.id
        where a.process = 'passed'
            and a.disposal_way = 'weighing'
            and a.sub_time = 0
            and b.value_type = 'unvaluable'
            and a.purchase_order_no = p_po
            and a.line_id = p_line_id;

        select b.sorting_unit_cargo_price,
               b.weigh_unit_cargo_price,
               b.sorting_unit_labor_price,
               b.weigh_unit_labor_price
        into v_sort_cargo_price,
             v_weight_cargo_price,
             v_sort_labor_price,
             v_weight_labor_price
        from uct_waste_purchase as a
        left join uct_branch as b
        on a.branch_id = b.setting_key
        where a.order_id = p_po;

        v_commission := (v_sort_height * v_sort_cargo_price + v_weight_height * v_weight_cargo_price) / 1000;
        v_artificial := ((v_sort_height + v_sort_low) * v_sort_labor_price + (v_weight_height + v_weight_low) * v_weight_labor_price) / 1000;

        update uct_sorting_jobs set status = 'finish', priority = 0 where id = v_id;

        if v_priority > 0 and v_number > 0 then
            update uct_sorting_jobs set priority = priority - 1 where priority > v_priority;
        end if;

        insert into uct_sorting_job_logs
        (line_id,
        purchase_order_no,
        status,
        revision,
        leader)
        values (p_line_id,
        p_po,
        'finish',
        v_num,
        v_leader);

        update uct_bas_station set status = 'stand-by' where status = 'working' and line_id = p_line_id;

        update uct_waste_purchase set
            storage_weight = v_total_weight,
            storage_cargo_price = v_total_money,
            sorting_valuable_weight = COALESCE((sorting_valuable_weight), 0) + v_sort_height,
            sorting_unvaluable_weight = COALESCE((sorting_unvaluable_weight), 0) + v_sort_low,
            weigh_valuable_weight = COALESCE((weigh_valuable_weight), 0) + v_weight_height,
            weigh_unvaluable_weight = COALESCE((weigh_unvaluable_weight), 0) + v_weight_low,
            total_cargo_price = COALESCE((total_cargo_price), 0) + v_commission,
            total_labor_price = COALESCE((total_labor_price), 0) + v_artificial
        where id = v_pur_id;

        insert into uct_waste_storage_sort
        (purchase_id, cargo_sort, total_weight, net_weight, rough_weight,
        presell_price, sort_time, createtime, disposal_way, value_type)
        select v_pur_id,
        a.cate_id,
        SUM(a.net_weight) as weight,
        SUM(a.net_weight) as weight,
        0,
        min(a.presell_price),
        UNIX_TIMESTAMP(max(a.end_time)),
        UNIX_TIMESTAMP(now()),
        a.disposal_way,
        b.value_type
        from uct_sorting_commit as a
        left join uct_waste_cate as b
        on a.cate_id = b.id
        where a.process = 'passed'
        and a.sub_time = 0
        and a.line_id = p_line_id
        and a.purchase_order_no = p_po
        group by a.cate_id;

        update uct_sorting_commit
        set sub_time = UNIX_TIMESTAMP(now())
        where sub_time = 0
        and purchase_order_no = p_po
        and line_id = p_line_id;

        COMMIT;

        set o_rv = 200;
        set o_err = '批次完成处理成功.';
    EXCEPTION
        WHEN others THEN
            ROLLBACK;
            set o_rv = 400;
            set o_err = '批次完成处理失败.';
    END;
END; $$;



-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."sorting_end_and_edit_once";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."sorting_end_and_edit_once"(in  p_line_id varchar(20),
in  p_po      varchar(20),
INOUT o_rv      integer,
INOUT o_err     varchar(200)) 
LANGUAGE plpgsql AS $$
DECLARE
    v_id            integer;
    v_leader        integer;
    v_priority      integer;
    v_num           integer;
    v_number        integer;
    v_pur_id        integer;
    v_sub_id        integer;
    v_check_id      integer;
    v_sum_id        integer;
    v_old_weight    float;
    v_old_money     float;
    v_now_weight    float;
    v_now_money     float;
    v_total_weight  float;
    v_total_money   float;
    v_sort_height   float;
    v_sort_low      float;
    v_weight_height float;
    v_weight_low    float;
    v_sort_cargo_price      float;
    v_weight_cargo_price    float;
    v_sort_labor_price      float;
    v_weight_labor_price    float;
    v_commission    float;
    v_artificial    float;
    errno           int;
BEGIN
    -- 异常处理块
    BEGIN
        START TRANSACTION;

        -- 主块开始
        select id, leader, priority into v_id, v_leader, v_priority
        from uct_sorting_jobs
        where line_id = p_line_id
            and purchase_order_no = p_po
        limit 1;

        if v_id is null then
            set o_rv = 400;
            set o_err = '获取任务表id失败.';
            RETURN;
        end if;

        select count(1) into v_sum_id
        from uct_sorting_commit
        where sub_time = 0
            and line_id = p_line_id
            and purchase_order_no = p_po;

        if v_sum_id < 1 then
            set o_rv = 400;
            set o_err = '没有可以入库的数据.';
            RETURN;
        end if;

        select count(1) into v_sub_id
        from uct_sorting_commit
        where sub_time = 0
            and line_id = p_line_id
            and purchase_order_no = p_po
            and process = 'pending';

        if v_sub_id > 0 then
            set o_rv = 400;
            set o_err = '请对这个批次的所有数据进行确认后，再点击单次入库.';
            RETURN;
        end if;

        select COALESCE(MAX(revision), 0) + 1 into v_num
        from uct_sorting_job_logs
        where line_id = p_line_id
            and purchase_order_no = p_po;

        if v_num is null then
            set o_rv = 400;
            set o_err = '获取最大的版本号失败.';
            RETURN;
        end if;

        select id, COALESCE(storage_weight, 0), COALESCE(storage_cargo_price, 0)
        into v_pur_id, v_old_weight, v_old_money
        from uct_waste_purchase
        where order_id = p_po;

        if v_pur_id is null then
            set o_rv = 400;
            set o_err = '获取订单表的自增id失败.';
            RETURN;
        end if;

        select count(1), COALESCE(SUM(net_weight * presell_price), 0), COALESCE(SUM(net_weight), 0)
        into v_check_id, v_now_money, v_now_weight
        from uct_sorting_commit
        where sub_time = 0
            and process = 'passed'
            and line_id = p_line_id
            and purchase_order_no = p_po;

        if v_check_id < 1 then
            set o_rv = 400;
            set o_err = '获取单次总重量或总金额失败.';
            RETURN;
        end if;

        v_total_weight := v_old_weight + v_now_weight;
        v_total_money  := v_old_money + v_now_money;

        select COALESCE(SUM(a.net_weight), 0) into v_sort_height
        from uct_sorting_commit as a
        left join uct_waste_cate as b
        on a.cate_id = b.id
        where a.process = 'passed'
            and a.disposal_way = 'sorting'
            and a.sub_time = 0
            and b.value_type = 'valuable'
            and a.purchase_order_no = p_po
            and a.line_id = p_line_id;

        select COALESCE(SUM(a.net_weight), 0) into v_sort_low
        from uct_sorting_commit as a
        left join uct_waste_cate as b
        on a.cate_id = b.id
        where a.process = 'passed'
            and a.disposal_way = 'sorting'
            and a.sub_time = 0
            and b.value_type = 'unvaluable'
            and a.purchase_order_no = p_po
            and a.line_id = p_line_id;

        select COALESCE(SUM(a.net_weight), 0) into v_weight_height
        from uct_sorting_commit as a
        left join uct_waste_cate as b
        on a.cate_id = b.id
        where a.process = 'passed'
            and a.disposal_way = 'weighing'
            and a.sub_time = 0
            and b.value_type = 'valuable'
            and a.purchase_order_no = p_po
            and a.line_id = p_line_id;

        select COALESCE(SUM(a.net_weight), 0) into v_weight_low
        from uct_sorting_commit as a
        left join uct_waste_cate as b
        on a.cate_id = b.id
        where a.process = 'passed'
            and a.disposal_way = 'weighing'
            and a.sub_time = 0
            and b.value_type = 'unvaluable'
            and a.purchase_order_no = p_po
            and a.line_id = p_line_id;

        select b.sorting_unit_cargo_price,
               b.weigh_unit_cargo_price,
               b.sorting_unit_labor_price,
               b.weigh_unit_labor_price
        into v_sort_cargo_price,
               v_weight_cargo_price,
               v_sort_labor_price,
               v_weight_labor_price
        from uct_waste_purchase as a
        left join uct_branch as b
        on a.branch_id = b.setting_key
        where a.order_id = p_po;

        v_commission := (v_sort_height * v_sort_cargo_price + v_weight_height * v_weight_cargo_price) / 1000;
        v_artificial := ((v_sort_height + v_sort_low) * v_sort_labor_price + (v_weight_height + v_weight_low) * v_weight_labor_price) / 1000;

        update uct_waste_purchase set
            storage_weight = v_total_weight,
            storage_cargo_price = v_total_money,
            sorting_valuable_weight = COALESCE((sorting_valuable_weight), 0) + v_sort_height,
            sorting_unvaluable_weight = COALESCE((sorting_unvaluable_weight), 0) + v_sort_low,
            weigh_valuable_weight = COALESCE((weigh_valuable_weight), 0) + v_weight_height,
            weigh_unvaluable_weight = COALESCE((weigh_unvaluable_weight), 0) + v_weight_low,
            total_cargo_price = COALESCE((total_cargo_price), 0) + v_commission,
            total_labor_price = COALESCE((total_labor_price), 0) + v_artificial
        where id = v_pur_id;

        insert into uct_waste_storage_sort
        (purchase_id,
        cargo_sort,
        total_weight,
        net_weight,
        rough_weight,
        presell_price,
        sort_time,
        createtime,
        disposal_way,
        value_type)
        select v_pur_id,
        a.cate_id,
        SUM(a.net_weight) as weight,
        SUM(a.net_weight) as weight,
        0,
        min(a.presell_price) ,
        UNIX_TIMESTAMP(max(a.end_time)),
        UNIX_TIMESTAMP(now()),
        a.disposal_way,
        b.value_type
        from uct_sorting_commit as a
        left join uct_waste_cate as b
        on a.cate_id = b.id
        where a.process = 'passed'
        and a.sub_time = 0
        and a.line_id = p_line_id
        and a.purchase_order_no = p_po
        group by a.cate_id;

        update uct_sorting_commit
        set sub_time = UNIX_TIMESTAMP(now())
        where sub_time = 0
        and purchase_order_no = p_po
        and line_id = p_line_id;

        COMMIT;

        set o_rv = 200;
        set o_err = '单次入库处理成功.';
    EXCEPTION
        WHEN others THEN
            ROLLBACK;
            set o_rv = 400;
            set o_err = '单次入库处理失败.';
    END;
END; $$;


-- 删除存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."star_history";

-- 创建存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."star_history"(in "start_time" date, in "end_time" date) 
LANGUAGE plpgsql AS $$
DECLARE
    nowdate date;
BEGIN
    nowdate := end_time;
    START TRANSACTION;
    WHILE nowdate >= start_time LOOP
        -- 这里可以执行您需要的操作
        -- 例如：SELECT nowdate;
        nowdate := nowdate - interval '1 month';
    END LOOP;
    COMMIT;
END;
$$;



CREATE OR REPLACE PROCEDURE "test_lvhuan"."test"(IN "customer_id" int) 
LANGUAGE plpgsql AS $$
DECLARE
    name text;
    company_address text;
    FRelateBrID integer;
    startSevr date;
    countSevr bigint;
    sumTalWaste numeric;
BEGIN
    SELECT
        cus.name, 
        cus.company_address, 
        main."FRelateBrID", 
        MIN(main."Date"),
        COUNT(main."FBillNo"),
        SUM(main."TalFQty")
    INTO
        name, 
        company_address, 
        FRelateBrID, 
        startSevr, 
        countSevr, 
        sumTalWaste
    FROM 
        "Trans_main_table" main
    JOIN 
        "uct_waste_customer" cus ON cus.id = main."FSupplyID"
    WHERE 
        main."FTranType" = 'PUR'
        AND main."FCorrent" = 1
        AND main."FCancellation" = 1
        AND cus.id = main."FSupplyID"
        AND main."FDate" BETWEEN '2021-01-01 00:00:00' AND '2021-12-31 23:59:59'
        AND main."FSupplyID" = "customer_id"
    GROUP BY 
        cus.name, 
        cus.company_address, 
        main."FRelateBrID";
    
    -- 在这里可以使用获取到的变量 name, company_address, FRelateBrID, startSevr, countSevr, sumTalWaste 进行后续操作

END;
$$;



DROP PROCEDURE IF EXISTS "test_lvhuan"."test1";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."test1"() 
LANGUAGE plpgsql AS $$
DECLARE
    l_int int;
BEGIN
    l_int := 5;
    RAISE NOTICE 'The value of l_int is %', l_int;
END;
$$;


DROP PROCEDURE IF EXISTS "test_lvhuan"."test20210105";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."test20210105"() 
LANGUAGE plpgsql AS $$
BEGIN
    SELECT count(*) FROM uct_waste_purchase;
    -- Removed sleep function for PostgreSQL
END;
$$;


-- 删除名为 "Trans_assist_pur" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_assist_pur";

-- 创建名为 "Trans_assist_pur" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_assist_pur"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 DELETE 语句删除数据
    DELETE FROM "Trans_assist_table" WHERE "FTranType" = 'PUR' AND "FInterID" = id;
    
    -- 使用 INSERT INTO 语句将数据插入 "Trans_assist_table" 表
    INSERT INTO "Trans_assist_table" ("FInterID", "FTranType", "FEntryID", "FItemID", "FUnitID", "FQty", "FPrice", "FAmount", "disposal_way", "value_type", "FDCTime", "FSourceInterID", "FSourceTranType", "red_ink_time", "is_hedge")
    SELECT 
        "uct_waste_purchase_cargo"."purchase_id" AS "FInterID", 
        'PUR' AS "FTranType", 
        "uct_waste_purchase_cargo"."id" AS "FEntryID", 
        "uct_waste_purchase_cargo"."cate_id" AS "FItemID", 
        '1' AS "FUnitID", 
        "uct_waste_purchase_cargo"."net_weight" AS "FQty", 
        "uct_waste_purchase_cargo"."unit_price" AS "FPrice", 
        ROUND("uct_waste_purchase_cargo"."total_price", 2) AS "FAmount",
        'sorting' AS "disposal_way",
        "uct_waste_cate"."value_type" AS "value_type",
        TO_TIMESTAMP("uct_waste_purchase_cargo"."createtime") AS "FDCTime",
        NULL AS "FSourceInterID",
        NULL AS "FSourceTranType",
        NULL AS "red_ink_time",
        0 AS "is_hedge",
        0,
        0
    FROM 
        "uct_waste_purchase_cargo" 
    JOIN 
        "uct_waste_cate" ON "uct_waste_cate"."id" = "uct_waste_purchase_cargo"."cate_id"  
    WHERE 
        "uct_waste_purchase_cargo"."purchase_id" = id;
END;
$$;

-- 删除名为 "Trans_assist_sor" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_assist_sor";

-- 创建名为 "Trans_assist_sor" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_assist_sor"(in "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 DELETE 语句删除数据
    DELETE FROM "Trans_assist_table" WHERE "FTranType" = 'SOR' AND "FInterID" = id;
    
    -- 使用 INSERT INTO 语句将数据插入 "Trans_assist_table" 表
    INSERT INTO "Trans_assist_table" ("FInterID", "FTranType", "FEntryID", "FItemID", "FUnitID", "FQty", "FPrice", "FAmount", "disposal_way", "value_type", "FDCTime", "FSourceInterID", "FSourceTranType", "red_ink_time", "is_hedge")
    SELECT 
        "uct_waste_storage_sort"."purchase_id" AS "FInterID", 
        'SOR' AS "FTranType", 
        "uct_waste_storage_sort"."id" AS "FEntryID", 
        "uct_waste_storage_sort"."cargo_sort" AS "FItemID", 
        '1' AS "FUnitID", 
        "uct_waste_storage_sort"."net_weight" AS "FQty", 
        "uct_waste_storage_sort"."presell_price" AS "FPrice", 
        ROUND("uct_waste_storage_sort"."presell_price" * "uct_waste_storage_sort"."net_weight", 2) AS "FAmount",
        "uct_waste_storage_sort"."disposal_way" AS "disposal_way",
        "uct_waste_storage_sort"."value_type" AS "value_type",
        CASE
            WHEN "uct_waste_storage_sort"."sort_time" > "uct_waste_storage_sort"."createtime" THEN TO_TIMESTAMP("uct_waste_storage_sort"."sort_time")
            ELSE TO_TIMESTAMP("uct_waste_storage_sort"."createtime")
        END AS "FDCTime",
        "uct_waste_storage_sort"."purchase_id" AS "FSourceInterID",
        'PUR' AS "FSourceTranType",
        NULL AS "red_ink_time",
        0 AS "is_hedge",
        0,
        0
    FROM 
        "uct_waste_storage_sort" 
    WHERE 
        "uct_waste_storage_sort"."purchase_id" = id;
END;
$$;



-- 删除名为 "Trans_fee_pc" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_pc";

-- 创建名为 "Trans_fee_pc" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_pc"(IN "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 DELETE 语句删除数据
    DELETE FROM "Trans_fee_table" WHERE "FTranType" = 'PUR' AND "Ffeesence" = 'PC' AND "FInterID" = id;
    
    -- 使用 INSERT INTO 语句将数据插入 "Trans_fee_table" 表
    INSERT INTO "Trans_fee_table" ("FInterID", "FTranType", "Ffeesence", "FEntryID", "FFeeID", "FFeeType", "FFeePerson", "FFeeExplain", "FFeeAmount", "FFeebaseAmount", "Ftaxrate", "Fbasetax", "Fbasetaxamount", "FPriceRef", "FFeetime", "red_ink_time", "is_hedge")
    SELECT 
        "uct_waste_purchase_expense"."purchase_id" AS "FInterID", 
        'PUR' AS "FTranType", 
        'PC' AS "Ffeesence", 
        "uct_waste_purchase_expense"."id" AS "FEntryID", 
        "uct_waste_purchase_expense"."usage" AS "FFeeID", 
        "uct_waste_purchase_expense"."type" AS "FFeeType", 
        "uct_waste_purchase_expense"."receiver" AS "FFeePerson", 
        "uct_waste_purchase_expense"."remark" AS "FFeeExplain", 
        "uct_waste_purchase_expense"."price" AS "FFeeAmount", 
        '' AS "FFeebaseAmount", 
        '' AS "Ftaxrate", 
        '' AS "Fbasetax", 
        '' AS "Fbasetaxamount", 
        '' AS "FPriceRef", 
        TO_TIMESTAMP("uct_waste_purchase_expense"."createtime") AS "FFeetime", 
        NULL AS "red_ink_time", 
        0 AS "is_hedge", 
        0, 
        0
    FROM 
        "uct_waste_purchase_expense" 
    WHERE 
        "uct_waste_purchase_expense"."purchase_id" = id;
END;
$$;


-- 删除名为 "Trans_fee_pur" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_pur";

-- 创建名为 "Trans_fee_pur" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_pur"(IN "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 SELECT 语句查询数据
    SELECT 
        "uct_waste_purchase_cargo"."purchase_id" AS "FInterID", 
        'PUR' AS "FTranType", 
        "uct_waste_purchase_cargo"."id" AS "FEntryID", 
        "uct_waste_purchase_cargo"."cate_id" AS "FItemID", 
        '1' AS "FUnitID", 
        "uct_waste_purchase_cargo"."net_weight" AS "FQty", 
        "uct_waste_purchase_cargo"."unit_price" AS "FPrice", 
        round("uct_waste_purchase_cargo"."total_price", 2) AS "FAmount", 
        '' AS "FbasePrice", 
        '' AS "FbaseAmount", 
        '' AS "Ftaxrate", 
        '' AS "Fbasetax", 
        '' AS "Fbasetaxamount", 
        '' AS "FPriceRef", 
        TO_TIMESTAMP("uct_waste_purchase_cargo"."createtime") AS "FDCTime", 
        '' AS "FSourceInterID", 
        '' AS "FSourceTranType"
    FROM 
        "uct_waste_purchase_cargo" 
    WHERE 
        "uct_waste_purchase_cargo"."purchase_id" = id;
END;
$$;

-- 删除名为 "Trans_fee_rf" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_rf";

-- 创建名为 "Trans_fee_rf" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_rf"(IN "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 DELETE 语句删除数据
    DELETE FROM "Trans_fee_table" WHERE "FTranType" = 'PUR' AND "Ffeesence" = 'RF' AND "FInterID" = id;
    
    -- 使用 INSERT INTO 语句将数据插入 "Trans_fee_table" 表
    INSERT INTO "Trans_fee_table" ("FInterID", "FTranType", "Ffeesence", "FEntryID", "FFeeID", "FFeeType", "FFeePerson", "FFeeExplain", "FFeeAmount", "FFeebaseAmount", "Ftaxrate", "Fbasetax", "Fbasetaxamount", "FPriceRef", "FFeetime", "red_ink_time", "is_hedge")
    SELECT 
        "uct_waste_storage_return_fee"."purchase_id" AS "FInterID", 
        'PUR' AS "FTranType", 
        'RF' AS "Ffeesence", 
        "uct_waste_storage_return_fee"."id" AS "FEntryID", 
        "uct_waste_storage_return_fee"."usage" AS "FFeeID", 
        'out' AS "FFeeType", 
        "uct_waste_storage_return_fee"."receiver" AS "FFeePerson", 
        "uct_waste_storage_return_fee"."remark" AS "FFeeExplain", 
        "uct_waste_storage_return_fee"."price" AS "FFeeAmount", 
        '' AS "FFeebaseAmount", 
        '' AS "Ftaxrate", 
        '' AS "Fbasetax", 
        '' AS "Fbasetaxamount", 
        '' AS "FPriceRef", 
        TO_TIMESTAMP("uct_waste_storage_return_fee"."createtime") AS "FFeetime", 
        NULL AS "red_ink_time", 
        0 AS "is_hedge", 
        0, 
        0
    FROM 
        "uct_waste_storage_return_fee" 
    WHERE 
        "uct_waste_storage_return_fee"."purchase_id" = id;
END;
$$;

-- 删除名为 "Trans_fee_sel" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_sel";

-- 创建名为 "Trans_fee_sel" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_sel"(IN "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 SELECT 语句查询数据
    SELECT 
        "uct_waste_sell_cargo"."sell_id" AS "FInterID", 
        'SEL' AS "FTranType", 
        "uct_waste_sell_cargo"."id" AS "FEntryID", 
        "uct_waste_sell_cargo"."cate_id" AS "FItemID", 
        '1' AS "FUnitID", 
        CASE 
            WHEN "uct_waste_sell"."purchase_id" > 0 THEN "uct_waste_sell_cargo"."plan_sell_weight"
            ELSE "uct_waste_sell_cargo"."net_weight"
        END AS "FQty", 
        "uct_waste_sell_cargo"."unit_price" AS "FPrice", 
        round("uct_waste_sell_cargo"."unit_price" * 
        CASE 
            WHEN "uct_waste_sell"."purchase_id" > 0 THEN "uct_waste_sell_cargo"."plan_sell_weight"
            ELSE "uct_waste_sell_cargo"."net_weight"
        END, 2) AS "FAmount", 
        '' AS "FbasePrice", 
        '' AS "FbaseAmount", 
        '' AS "Ftaxrate", 
        '' AS "Fbasetax", 
        '' AS "Fbasetaxamount", 
        '' AS "FPriceRef", 
        TO_TIMESTAMP("uct_waste_sell_cargo"."createtime") AS "FDCTime", 
        CASE 
            WHEN "uct_waste_sell"."purchase_id" > 0 THEN "uct_waste_sell"."purchase_id"
            ELSE ''
        END AS "FSourceInterID", 
        CASE 
            WHEN "uct_waste_sell"."purchase_id" > 0 THEN 'PUR'
            ELSE ''
        END AS "FSourceTranType"
    FROM 
        "uct_waste_sell_cargo" 
    JOIN 
        "uct_waste_sell" 
    ON 
        "uct_waste_sell_cargo"."sell_id" = "uct_waste_sell"."id" 
    WHERE 
        "uct_waste_sell"."id" = id;
END;
$$;



-- 删除名为 "Trans_fee_pur" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_pur";

-- 创建名为 "Trans_fee_pur" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_pur"(IN "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 SELECT 语句查询数据
    SELECT 
        "uct_waste_purchase_cargo"."purchase_id" AS "FInterID", 
        'PUR' AS "FTranType", 
        "uct_waste_purchase_cargo"."id" AS "FEntryID", 
        "uct_waste_purchase_cargo"."cate_id" AS "FItemID", 
        '1' AS "FUnitID", 
        "uct_waste_purchase_cargo"."net_weight" AS "FQty", 
        "uct_waste_purchase_cargo"."unit_price" AS "FPrice", 
        round("uct_waste_purchase_cargo"."total_price", 2) AS "FAmount", 
        '' AS "FbasePrice", 
        '' AS "FbaseAmount", 
        '' AS "Ftaxrate", 
        '' AS "Fbasetax", 
        '' AS "Fbasetaxamount", 
        '' AS "FPriceRef", 
        TO_TIMESTAMP("uct_waste_purchase_cargo"."createtime") AS "FDCTime", 
        '' AS "FSourceInterID", 
        '' AS "FSourceTranType"
    FROM 
        "uct_waste_purchase_cargo" 
    WHERE 
        "uct_waste_purchase_cargo"."purchase_id" = id;
END;
$$;

-- 删除名为 "Trans_fee_rf" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_rf";

-- 创建名为 "Trans_fee_rf" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_rf"(IN "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 DELETE 语句删除数据
    DELETE FROM "Trans_fee_table" WHERE "FTranType" = 'PUR' AND "Ffeesence" = 'RF' AND "FInterID" = id;
    
    -- 使用 INSERT INTO 语句将数据插入 "Trans_fee_table" 表
    INSERT INTO "Trans_fee_table" ("FInterID", "FTranType", "Ffeesence", "FEntryID", "FFeeID", "FFeeType", "FFeePerson", "FFeeExplain", "FFeeAmount", "FFeebaseAmount", "Ftaxrate", "Fbasetax", "Fbasetaxamount", "FPriceRef", "FFeetime", "red_ink_time", "is_hedge")
    SELECT 
        "uct_waste_storage_return_fee"."purchase_id" AS "FInterID", 
        'PUR' AS "FTranType", 
        'RF' AS "Ffeesence", 
        "uct_waste_storage_return_fee"."id" AS "FEntryID", 
        "uct_waste_storage_return_fee"."usage" AS "FFeeID", 
        'out' AS "FFeeType", 
        "uct_waste_storage_return_fee"."receiver" AS "FFeePerson", 
        "uct_waste_storage_return_fee"."remark" AS "FFeeExplain", 
        "uct_waste_storage_return_fee"."price" AS "FFeeAmount", 
        '' AS "FFeebaseAmount", 
        '' AS "Ftaxrate", 
        '' AS "Fbasetax", 
        '' AS "Fbasetaxamount", 
        '' AS "FPriceRef", 
        TO_TIMESTAMP("uct_waste_storage_return_fee"."createtime") AS "FFeetime", 
        NULL AS "red_ink_time", 
        0 AS "is_hedge", 
        0, 
        0
    FROM 
        "uct_waste_storage_return_fee" 
    WHERE 
        "uct_waste_storage_return_fee"."purchase_id" = id;
END;
$$;

-- 删除名为 "Trans_fee_sel" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_sel";

-- 创建名为 "Trans_fee_sel" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_sel"(IN "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 SELECT 语句查询数据
    SELECT 
        "uct_waste_sell_cargo"."sell_id" AS "FInterID", 
        'SEL' AS "FTranType", 
        "uct_waste_sell_cargo"."id" AS "FEntryID", 
        "uct_waste_sell_cargo"."cate_id" AS "FItemID", 
        '1' AS "FUnitID", 
        CASE 
            WHEN "uct_waste_sell"."purchase_id" > 0 THEN "uct_waste_sell_cargo"."plan_sell_weight"
            ELSE "uct_waste_sell_cargo"."net_weight"
        END AS "FQty", 
        "uct_waste_sell_cargo"."unit_price" AS "FPrice", 
        round("uct_waste_sell_cargo"."unit_price" * 
        CASE 
            WHEN "uct_waste_sell"."purchase_id" > 0 THEN "uct_waste_sell_cargo"."plan_sell_weight"
            ELSE "uct_waste_sell_cargo"."net_weight"
        END, 2) AS "FAmount", 
        '' AS "FbasePrice", 
        '' AS "FbaseAmount", 
        '' AS "Ftaxrate", 
        '' AS "Fbasetax", 
        '' AS "Fbasetaxamount", 
        '' AS "FPriceRef", 
        TO_TIMESTAMP("uct_waste_sell_cargo"."createtime") AS "FDCTime", 
        CASE 
            WHEN "uct_waste_sell"."purchase_id" > 0 THEN "uct_waste_sell"."purchase_id"
            ELSE ''
        END AS "FSourceInterID", 
        CASE 
            WHEN "uct_waste_sell"."purchase_id" > 0 THEN 'PUR'
            ELSE ''
        END AS "FSourceTranType"
    FROM 
        "uct_waste_sell_cargo" 
    JOIN 
        "uct_waste_sell" 
    ON 
        "uct_waste_sell_cargo"."sell_id" = "uct_waste_sell"."id" 
    WHERE 
        "uct_waste_sell"."id" = id;
END;
$$;


-- 删除名为 "Trans_fee_ss" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_fee_ss";

-- 创建名为 "Trans_fee_ss" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_fee_ss"(IN "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 DELETE 语句删除数据
    DELETE FROM "Trans_fee_table" WHERE "FTranType" = 'SOR' AND "Ffeesence" = 'SS' AND "FInterID" = id;
    
    -- 使用 INSERT INTO 语句将数据插入 "Trans_fee_table" 表
    INSERT INTO "Trans_fee_table" ("FInterID", "FTranType", "Ffeesence", "FEntryID", "FFeeID", "FFeeType", "FFeePerson", "FFeeExplain", "FFeeAmount", "FFeebaseAmount", "Ftaxrate", "Fbasetax", "Fbasetaxamount", "FPriceRef", "FFeetime", "red_ink_time", "is_hedge")
    SELECT 
        "uct_waste_storage_sort_expense"."purchase_id" AS "FInterID", 
        'SOR' AS "FTranType", 
        'SS' AS "Ffeesence", 
        "uct_waste_storage_sort_expense"."id" AS "FEntryID", 
        "uct_waste_storage_sort_expense"."usage" AS "FFeeID", 
        'out' AS "FFeeType", 
        "uct_waste_storage_sort_expense"."receiver" AS "FFeePerson", 
        "uct_waste_storage_sort_expense"."remark" AS "FFeeExplain", 
        "uct_waste_storage_sort_expense"."price" AS "FFeeAmount", 
        '' AS "FFeebaseAmount", 
        '' AS "Ftaxrate", 
        '' AS "Fbasetax", 
        '' AS "Fbasetaxamount", 
        '' AS "FPriceRef", 
        TO_TIMESTAMP("uct_waste_storage_sort_expense"."createtime") AS "FFeetime", 
        NULL AS "red_ink_time", 
        0 AS "is_hedge", 
        0, 
        0
    FROM 
        "uct_waste_storage_sort_expense" 
    WHERE 
        "uct_waste_storage_sort_expense"."purchase_id" = id;
END;
$$;


-- 删除名为 "Trans_log_pur" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_log_pur";

-- 创建名为 "Trans_log_pur" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_log_pur"(IN "id" int) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 DELETE 语句删除数据
    DELETE FROM "Trans_log_table" WHERE "FTranType" = 'PUR' AND "FInterID" = id;
    
    -- 使用 INSERT INTO 语句将数据插入 "Trans_log_table" 表
    INSERT INTO "Trans_log_table" ("FInterID", "FTranType", "TCreate", "TCreatePerson", "TallotOver", "TallotPerson", "Tallot", "TgetorderOver", "TgetorderPerson", "Tgetorder", "TmaterialOver", "TmaterialPerson", "Tmaterial", "TpurchaseOver", "TpurchasePerson", "Tpurchase", "TpayOver", "TpayPerson", "Tpay", "TchangeOver", "TchangePerson", "Tchange", "TexpenseOver", "TexpensePerson", "Texpense", "TsortOver", "TsortPerson", "Tsort", "TallowOver", "TallowPerson", "Tallow", "TcheckOver", "TcheckPerson", "Tcheck", "State")
    SELECT 
        "log"."purchase_id" AS "FInterID", 
        'PUR' AS "FTranType", 
        MAX(CASE "log"."state_value" WHEN 'draft' THEN "log"."createtime" END) AS "TCreate", 
        MAX(CASE "log"."state_value" WHEN 'draft' THEN "log"."admin_id" END) AS "TCreatePerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_allot' THEN '1' ELSE '0' END) AS "TallotOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_allot' THEN "log"."admin_id" ELSE NULL END) AS "TallotPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_allot' THEN "log"."createtime" ELSE NULL END) AS "Tallot", 
        MAX(CASE "log"."state_value" WHEN 'wait_receive_order' THEN '1' ELSE '0' END) AS "TgetorderOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_receive_order' THEN "log"."admin_id" ELSE NULL END) AS "TgetorderPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_receive_order' THEN "log"."createtime" ELSE NULL END) AS "Tgetorder", 
        MAX(CASE "log"."state_value" WHEN 'wait_signin_materiel' THEN '1' ELSE '0' END) AS "TmaterialOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_signin_materiel' THEN "log"."admin_id" ELSE NULL END) AS "TmaterialPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_signin_materiel' THEN "log"."createtime" ELSE NULL END) AS "Tmaterial", 
        MAX(CASE "log"."state_value" WHEN 'wait_pick_cargo' THEN '1' ELSE '0' END) AS "TpurchaseOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_pick_cargo' THEN "log"."admin_id" ELSE NULL END) AS "TpurchasePerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_pick_cargo' THEN "log"."createtime" ELSE NULL END) AS "Tpurchase", 
        MAX(CASE "log"."state_value" WHEN 'wait_pay' THEN '1' ELSE '0' END) AS "TpayOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_pay' THEN "log"."admin_id" ELSE NULL END) AS "TpayPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_pay' THEN "log"."createtime" ELSE NULL END) AS "Tpay", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect' THEN '1' ELSE '0' END) AS "TchangeOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect' THEN "log"."admin_id" ELSE NULL END) AS "TchangePerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect' THEN "log"."createtime" ELSE NULL END) AS "Tchange", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect_confirm' THEN '1' ELSE '0' END) AS "TexpenseOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect_confirm' THEN "log"."admin_id" ELSE NULL END) AS "TexpensePerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect_confirm' THEN "log"."createtime" ELSE NULL END) AS "Texpense", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_sort' THEN '1' ELSE '0' END) AS "TsortOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_sort' THEN "log"."admin_id" ELSE NULL END) AS "TsortPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_sort' THEN "log"."createtime" ELSE NULL END) AS "Tsort", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_confirm' THEN '1' ELSE '0' END) AS "TallowOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_confirm' THEN "log"."admin_id" ELSE NULL END) AS "TallowPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_confirm' THEN "log"."createtime" ELSE NULL END) AS "Tallow", 
        MAX(CASE "log"."state_value" WHEN 'finish' THEN '1' ELSE '0' END) AS "TcheckOver", 
        MAX(CASE "log"."state_value" WHEN 'finish' THEN "log"."admin_id" ELSE NULL END) AS "TcheckPerson", 
        MAX(CASE "log"."state_value" WHEN 'finish' THEN "log"."createtime" ELSE '0' END) AS "Tcheck", 
        "uct_waste_purchase"."state" AS "State"
    FROM 
        "uct_waste_purchase"
    JOIN 
        "uct_waste_purchase_log" "log"
    ON 
        ("uct_waste_purchase"."id" = "log"."purchase_id")
    WHERE 
        ("uct_waste_purchase"."hand_mouth_data" = '0')
        AND ("uct_waste_purchase"."give_frame" = '0')
        AND ("uct_waste_purchase"."id" = id)
    GROUP BY 
        "uct_waste_purchase"."id";
END;
$$;


-- 删除名为 "Trans_log_pur_give" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_log_pur_give" (int);

-- 创建名为 "Trans_log_pur_give" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_log_pur_give" (IN "id" int) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 DELETE 语句删除数据
    DELETE FROM "Trans_log_table" WHERE "FTranType" = 'PUR' AND "FInterID" = id;

    -- 使用 INSERT INTO 语句将数据插入 "Trans_log_table" 表
    INSERT INTO "Trans_log_table" ("FInterID", "FTranType", "TCreate", "TCreatePerson", "TallotOver", "TallotPerson", "Tallot", "TgetorderOver", "TgetorderPerson", "Tgetorder", "TmaterialOver", "TmaterialPerson", "Tmaterial", "TpurchaseOver", "TpurchasePerson", "Tpurchase", "TpayOver", "TpayPerson", "Tpay", "TchangeOver", "TchangePerson", "Tchange", "TexpenseOver", "TexpensePerson", "Texpense", "TsortOver", "TsortPerson", "Tsort", "TallowOver", "TallowPerson", "Tallow", "TcheckOver", "TcheckPerson", "Tcheck", "State")
    SELECT 
        "log"."purchase_id" AS "FInterID", 
        'PUR' AS "FTranType", 
        MAX(CASE "log"."state_value" WHEN 'draft' THEN "log"."createtime" END) AS "TCreate", 
        MAX(CASE "log"."state_value" WHEN 'draft' THEN "log"."admin_id" END) AS "TCreatePerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_allot' THEN '1' ELSE '0' END) AS "TallotOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_allot' THEN "log"."admin_id" ELSE NULL END) AS "TallotPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_allot' THEN "log"."createtime" ELSE NULL END) AS "Tallot", 
        MAX(CASE "log"."state_value" WHEN 'wait_receive_order' THEN '1' ELSE '0' END) AS "TgetorderOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_receive_order' THEN "log"."admin_id" ELSE NULL END) AS "TgetorderPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_receive_order' THEN "log"."createtime" ELSE NULL END) AS "Tgetorder", 
        MAX(CASE "log"."state_value" WHEN 'wait_signin_materiel' THEN '1' ELSE '0' END) AS "TmaterialOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_signin_materiel' THEN "log"."admin_id" ELSE NULL END) AS "TmaterialPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_signin_materiel' THEN "log"."createtime" ELSE NULL END) AS "Tmaterial", 
        MAX(CASE "log"."state_value" WHEN 'wait_pick_cargo' THEN '1' ELSE '0' END) AS "TpurchaseOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_pick_cargo' THEN "log"."admin_id" ELSE NULL END) AS "TpurchasePerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_pick_cargo' THEN "log"."createtime" ELSE NULL END) AS "Tpurchase", 
        MAX(CASE "log"."state_value" WHEN 'wait_pay' THEN '1' ELSE '0' END) AS "TpayOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_pay' THEN "log"."admin_id" ELSE NULL END) AS "TpayPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_pay' THEN "log"."createtime" ELSE NULL END) AS "Tpay", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect' THEN '1' ELSE '0' END) AS "TchangeOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect' THEN "log"."admin_id" ELSE NULL END) AS "TchangePerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect' THEN "log"."createtime" ELSE NULL END) AS "Tchange", 
        NULL AS "TexpenseOver", NULL AS "TexpensePerson", NULL AS "Texpense", NULL AS "TsortOver", NULL AS "TsortPerson", NULL AS "Tsort", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect_confirm' THEN '1' ELSE '0' END) AS "TallowOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect_confirm' THEN "log"."admin_id" ELSE NULL END) AS "TallowPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_storage_connect_confirm' THEN "log"."createtime" ELSE NULL END) AS "Tallow", 
        MAX(CASE "log"."state_value" WHEN 'finish' THEN '1' ELSE '0' END) AS "TcheckOver", 
        MAX(CASE "log"."state_value" WHEN 'finish' THEN "log"."admin_id" ELSE NULL END) AS "TcheckPerson", 
        MAX(CASE "log"."state_value" WHEN 'finish' THEN "log"."createtime" ELSE '0' END) AS "Tcheck", 
        "uct_waste_purchase"."state" AS "State"
    FROM 
        "uct_waste_purchase"
    JOIN 
        "uct_waste_purchase_log" "log"
    ON 
        ("uct_waste_purchase"."id" = "log"."purchase_id")
    WHERE 
        ("uct_waste_purchase"."hand_mouth_data" = '0')
        AND ("uct_waste_purchase"."give_frame" = '1')
        AND ("uct_waste_purchase"."id" = id)
    GROUP BY 
        "uct_waste_purchase"."id";
END;
$$;



-- 删除名为 "Trans_log_sel" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_log_sel" (int);

-- 创建名为 "Trans_log_sel" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_log_sel" (IN "id" int) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- 在 PL/pgSQL 中使用 DELETE 语句删除数据
    DELETE FROM "Trans_log_table" WHERE "FTranType" = 'SEL' AND "FInterID" = id;

    -- 使用 INSERT INTO 语句将数据插入 "Trans_log_table" 表
    INSERT INTO "Trans_log_table" ("FInterID", "FTranType", "TCreate", "TCreatePerson", "TallotOver", "TallotPerson", "Tallot", "TgetorderOver", "TgetorderPerson", "Tgetorder", "TmaterialOver", "TmaterialPerson", "Tmaterial", "TpurchaseOver", "TpurchasePerson", "Tpurchase", "TpayOver", "TpayPerson", "Tpay", "TchangeOver", "TchangePerson", "Tchange", "TexpenseOver", "TexpensePerson", "Texpense", "TsortOver", "TsortPerson", "Tsort", "TallowOver", "TallowPerson", "Tallow", "TcheckOver", "TcheckPerson", "Tcheck", "State")
    SELECT 
        "log"."sell_id" AS "FInterID", 
        'SEL' AS "FTranType", 
        MAX(CASE "log"."state_value" WHEN 'draft' THEN "log"."createtime" END) AS "TCreate", 
        MAX(CASE "log"."state_value" WHEN 'draft' THEN "log"."admin_id" END) AS "TCreatePerson", 
        NULL AS "TallotOver", NULL AS "TallotPerson", NULL AS "Tallot", NULL AS "TgetorderOver", NULL AS "TgetorderPerson", NULL AS "Tgetorder", 
        NULL AS "TmaterialOver", NULL AS "TmaterialPerson", NULL AS "Tmaterial", 
        MAX(CASE "log"."state_value" WHEN 'wait_weigh' THEN '1' ELSE '0' END) AS "TpurchaseOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_weigh' THEN "log"."admin_id" ELSE NULL END) AS "TpurchasePerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_weigh' THEN "log"."createtime" ELSE NULL END) AS "Tpurchase", 
        NULL AS "TpayOver", NULL AS "TpayPerson", NULL AS "Tpay", NULL AS "TchangeOver", NULL AS "TchangePerson", NULL AS "Tchange", 
        NULL AS "TexpenseOver", NULL AS "TexpensePerson", NULL AS "Texpense", NULL AS "TsortOver", NULL AS "TsortPerson", NULL AS "Tsort", 
        MAX(CASE "log"."state_value" WHEN 'wait_confirm_order' THEN '1' ELSE '0' END) AS "TallowOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_confirm_order' THEN "log"."admin_id" ELSE NULL END) AS "TallowPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_confirm_order' THEN "log"."createtime" ELSE NULL END) AS "Tallow", 
        MAX(CASE "log"."state_value" WHEN 'wait_pay' THEN '1' ELSE '0' END) AS "TcheckOver", 
        MAX(CASE "log"."state_value" WHEN 'wait_pay' THEN "log"."admin_id" ELSE NULL END) AS "TcheckPerson", 
        MAX(CASE "log"."state_value" WHEN 'wait_pay' THEN "log"."createtime" ELSE '0' END) AS "Tcheck", 
        "uct_waste_sell"."state" AS "State"
    FROM 
        "uct_waste_sell"
    JOIN 
        "uct_waste_sell_log" "log"
    ON 
        "uct_waste_sell"."id" = "log"."sell_id"
    WHERE 
        isnull("uct_waste_sell"."purchase_id")
        AND "uct_waste_sell"."id" = id
    GROUP BY 
        "uct_waste_sell"."id";
END;
$$;


-- 删除名为 "Trans_main_0" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_main_0" (int);

-- 创建名为 "Trans_main_0" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_main_0" (IN "id" int) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- 使用 SELECT 语句获取数据并插入到目标表
    INSERT INTO "目标表名称" ("FRelateBrID", "FInterID", "FTranType", "FDate", "FTrainNum", "FBillNo", "FSupplyID", "Fbusiness", "FDCStockID", "FSCStockID", "FCancellation", "FROB", "FCorrent", "FStatus", "FUpStockWhenSave", "FExplanation", "FDeptID", "FEmpID", "FCheckerID", "FCheckDate", "FFManagerID", "FSManagerID", "FBillerID", "FCurrencyID", "FNowState", "FSaleStyle", "FPOStyle", "FPOPrecent", "TalFQty", "TalFAmount", "TalFeeFrist", "TalFeeSecond", "TalFeeThird", "TalFeeForth")
    SELECT
        "uctoo_lvhuan"."uct_waste_purchase"."branch_id" AS "FRelateBrID",
        "uctoo_lvhuan"."uct_waste_purchase"."id" AS "FInterID",
        'PUR' AS "FTranType",
        CASE "uctoo_lvhuan"."Trans_log_table"."TpurchaseOver"
            WHEN '0' THEN date_format('1970-01-01 00:00:00', '%Y-%m-%d %H:%i:%S')
            ELSE date_format(from_unixtime("uctoo_lvhuan"."Trans_log_table"."Tpurchase"), '%Y-%m-%d %H:%i:%S')
        END AS "FDate",
        "uctoo_lvhuan"."uct_waste_purchase"."train_number" AS "FTrainNum",
        "uctoo_lvhuan"."uct_waste_purchase"."order_id" AS "FBillNo",
        "uctoo_lvhuan"."uct_waste_purchase"."customer_id" AS "FSupplyID",
        "uctoo_lvhuan"."uct_waste_purchase"."manager_id" AS "Fbusiness",
        concat('AD', "uctoo_lvhuan"."uct_waste_purchase"."purchase_incharge") AS "FDCStockID",
        concat('CU', "uctoo_lvhuan"."uct_waste_purchase"."customer_id") AS "FSCStockID",
        CASE "uctoo_lvhuan"."uct_waste_purchase"."state"
            WHEN 'cancel' THEN '0'
            ELSE '1'
        END AS "FCancellation",
        '0' AS "FROB",
        "uctoo_lvhuan"."Trans_log_table"."TallowOver" AS "FCorrent",
        "uctoo_lvhuan"."Trans_log_table"."TcheckOver" AS "FStatus",
        '' AS "FUpStockWhenSave",
        '' AS "FExplanation",
        "uctoo_lvhuan"."uct_waste_customer"."service_department" AS "FDeptID",
        "uctoo_lvhuan"."uct_waste_purchase"."purchase_incharge" AS "FEmpID",
        "uctoo_lvhuan"."Trans_log_table"."TcheckPerson" AS "FCheckerID",
        CASE "uctoo_lvhuan"."Trans_log_table"."TcheckOver"
            WHEN '0' THEN 'null'
            ELSE date_format(from_unixtime("uctoo_lvhuan"."Trans_log_table"."Tcheck"), '%Y-%m-%d %H:%i:%S')
        END AS "FCheckDate",
        "uctoo_lvhuan"."uct_waste_purchase"."purchase_incharge" AS "FFManagerID",
        "uctoo_lvhuan"."uct_waste_purchase"."purchase_incharge" AS "FSManagerID",
        "uctoo_lvhuan"."uct_waste_purchase"."purchase_incharge" AS "FBillerID",
        '1' AS "FCurrencyID",
        "uctoo_lvhuan"."Trans_log_table"."state" AS "FNowState",
        CASE "uctoo_lvhuan"."uct_waste_purchase"."hand_mouth_data"
            WHEN '1' THEN '1'
            ELSE '0'
        END + CASE "uctoo_lvhuan"."uct_waste_purchase"."give_frame"
            WHEN '1' THEN '3'
            ELSE '0'
        END AS "FSaleStyle",
        "uctoo_lvhuan"."uct_waste_customer"."settle_way" AS "FPOStyle",
        "uctoo_lvhuan"."uct_waste_customer"."back_percent" AS "FPOPrecent",
        round("uctoo_lvhuan"."uct_waste_purchase"."cargo_weight", 1) AS "TalFQty",
        round("uctoo_lvhuan"."uct_waste_purchase"."cargo_price", 2) AS "TalFAmount",
        "uctoo_lvhuan"."uct_waste_purchase"."purchase_expense" AS "TalFeeFrist",
        "Trans_total_fee_rf"."car_fee" AS "TalFeeSecond",
        "Trans_total_fee_rf"."man_fee" AS "TalFeeThird",
        "Trans_total_fee_rf"."other_return_fee" AS "TalFeeForth"
    FROM
        "uctoo_lvhuan"."uct_waste_purchase"
    JOIN
        "uctoo_lvhuan"."uct_waste_customer"
    ON
        "uctoo_lvhuan"."uct_waste_purchase"."customer_id" = "uctoo_lvhuan"."uct_waste_customer"."id"
    JOIN
        "uctoo_lvhuan"."Trans_log_table"
    ON
        "uctoo_lvhuan"."uct_waste_purchase"."id" = "uctoo_lvhuan"."Trans_log_table"."FInterID"
    LEFT JOIN
        "uctoo_lvhuan"."Trans_total_fee_rf"
    ON
        "Trans_total_fee_rf"."purchase_id" = "uctoo_lvhuan"."uct_waste_purchase"."id"
    WHERE
        "uctoo_lvhuan"."uct_waste_purchase"."order_id" > 201806300000000000
        AND "uctoo_lvhuan"."uct_waste_purchase"."id" = id;
END;
$$;


-- 删除名为 "Trans_main_pur" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_main_pur" (int);

-- 创建名为 "Trans_main_pur" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_main_pur" (IN "id" int) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- 删除符合条件的数据
    DELETE FROM "Trans_main_table" WHERE "FTranType" = 'PUR' AND "FInterID" = "id";
    
    -- 插入符合条件的数据
    INSERT INTO "Trans_main_table" ("FRelateBrID", "FInterID", "FTranType", "FDate", "createtime", "Date", "FTrainNum", "FBillNo", "FSupplyID", "Fbusiness", "FDCStockID", "FSCStockID", "FCancellation", "FROB", "FCorrent", "FStatus", "FUpStockWhenSave", "FExplanation", "FDeptID", "FEmpID", "FCheckerID", "FCheckDate", "FFManagerID", "FSManagerID", "FBillerID", "FCurrencyID", "FNowState", "FSaleStyle", "FPOStyle", "FPOPrecent", "TalFQty", "TalFAmount", "TalFeeFrist", "TalFeeSecond", "TalFeeThird", "TalFeeForth", "TalFeeFifth", "col1", "col2", "col3", "col4", "col5", "col6")
    SELECT
        "uct_waste_purchase"."branch_id" AS "FRelateBrID",
        "uct_waste_purchase"."id" AS "FInterID",
        'PUR' AS "FTranType",
        CASE "Trans_log_table"."TpurchaseOver"
            WHEN '0' THEN TO_TIMESTAMP(0)
            ELSE TO_TIMESTAMP("Trans_log_table"."Tpurchase")
        END AS "FDate",
        TO_TIMESTAMP("uct_waste_purchase".createtime),
        CASE "Trans_log_table"."TpurchaseOver"
            WHEN '0' THEN TO_DATE(TO_TIMESTAMP(0), 'YYYY-MM-DD')
            ELSE TO_DATE(TO_TIMESTAMP("Trans_log_table"."Tpurchase"), 'YYYY-MM-DD')
        END AS "Date",
        "uct_waste_purchase"."train_number" AS "FTrainNum",
        "uct_waste_purchase"."order_id" AS "FBillNo",
        "uct_waste_purchase"."customer_id" AS "FSupplyID",
        "uct_waste_purchase"."manager_id" AS "Fbusiness",
        concat('AD', "uct_waste_purchase"."purchase_incharge") AS "FDCStockID",
        concat('CU', "uct_waste_purchase"."customer_id") AS "FSCStockID",
        CASE "uct_waste_purchase"."state"
            WHEN 'cancel' THEN '0'
            ELSE '1'
        END AS "FCancellation",
        '0' AS "FROB",
        CASE 
            WHEN "Trans_log_table"."TpurchaseOver" = 1 AND "Trans_log_table"."FTranType" = 'PUR' THEN 1
            ELSE 0
        END AS "FCorrent",
        "Trans_log_table"."TcheckOver" AS "FStatus",
        '' AS "FUpStockWhenSave",
        '' AS "FExplanation",
        "uct_waste_customer"."service_department" AS "FDeptID",
        "uct_waste_purchase"."purchase_incharge" AS "FEmpID",
        "Trans_log_table"."TcheckPerson" AS "FCheckerID",
        CASE "Trans_log_table"."TcheckOver"
            WHEN '0' THEN NULL
            ELSE TO_TIMESTAMP("Trans_log_table"."Tcheck")
        END AS "FCheckDate",
        "uct_waste_purchase"."purchase_incharge" AS "FFManagerID",
        "uct_waste_purchase"."purchase_incharge" AS "FSManagerID",
        "uct_waste_purchase"."purchase_incharge" AS "FBillerID",
        '1' AS "FCurrencyID",
        "Trans_log_table"."state" AS "FNowState",
        CASE "uct_waste_purchase"."hand_mouth_data"
            WHEN '1' THEN '1'
            ELSE '0'
        END + CASE "uct_waste_purchase"."give_frame"
            WHEN '1' THEN '3'
            ELSE '0'
        END AS "FSaleStyle",
        "uct_waste_customer"."settle_way" AS "FPOStyle",
        "uct_waste_customer"."back_percent" AS "FPOPrecent",
        round("uct_waste_purchase"."cargo_weight", 1) AS "TalFQty",
        round("uct_waste_purchase"."cargo_price", 2) AS "TalFAmount",
        "uct_waste_purchase"."purchase_expense" AS "TalFeeFrist",
        "Trans_total_fee_rf"."car_fee" AS "TalFeeSecond",
        "Trans_total_fee_rf"."man_fee" AS "TalFeeThird",
        "Trans_total_fee_rf"."other_return_fee" AS "TalFeeForth",
        0 AS "TalFeeFifth",
        0 AS "col1",
        0 AS "col2",
        0 AS "col3",
        0 AS "col4",
        0 AS "col5",
        NULL AS "col6"
    FROM
        "uct_waste_purchase"
    JOIN
        "uct_waste_customer"
    ON
        "uct_waste_purchase"."customer_id" = "uct_waste_customer"."id"
    JOIN
        "Trans_log_table"
    ON
        "uct_waste_purchase"."id" = "Trans_log_table"."FInterID"
    LEFT JOIN
        "Trans_total_fee_rf"
    ON
        "Trans_total_fee_rf"."purchase_id" = "uct_waste_purchase"."id"
    WHERE
        "uct_waste_purchase"."order_id" > 201806300000000000
        AND "uct_waste_purchase"."id" = "id";
END;
$$;


-- 删除名为 "Trans_main_sel" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_main_sel" (int);

-- 创建名为 "Trans_main_sel" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_main_sel" (IN "id" int) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- 删除符合条件的数据
    DELETE FROM "Trans_main_table" WHERE "FTranType" = 'SEL' AND "FInterID" = "id";
    
    -- 插入符合条件的数据
    INSERT INTO "Trans_main_table" ("FRelateBrID", "FInterID", "FTranType", "FDate", "createtime", "Date", "FTrainNum", "FBillNo", "FSupplyID", "Fbusiness", "FDCStockID", "FSCStockID", "FCancellation", "FROB", "FCorrent", "FStatus", "FUpStockWhenSave", "FExplanation", "FDeptID", "FEmpID", "FCheckerID", "FCheckDate", "FFManagerID", "FSManagerID", "FBillerID", "FCurrencyID", "FNowState", "FSaleStyle", "FPOStyle", "FPOPrecent", "TalFQty", "TalFAmount", "TalFeeFrist", "TalFeeSecond", "TalFeeThird", "TalFeeForth", "TalFeeFifth", "col1", "col2", "col3", "col4", "col5", "col6")
    SELECT
        "uct_waste_sell"."branch_id" AS "FRelateBrID",
        "uct_waste_sell"."id" AS "FInterID",
        'SEL' AS "FTranType",
        CASE "Trans_log_table"."TallowOver"
            WHEN '0' THEN TO_TIMESTAMP(0)
            ELSE TO_TIMESTAMP("Trans_log_table"."Tallow")
        END AS "FDate",
        TO_TIMESTAMP("uct_waste_sell".createtime),
        CASE "Trans_log_table"."TallowOver"
            WHEN '0' THEN TO_DATE(TO_TIMESTAMP(0), 'YYYY-MM-DD')
            ELSE TO_DATE(TO_TIMESTAMP("Trans_log_table"."Tallow"), 'YYYY-MM-DD')
        END AS "Date",
        '1' AS "FTrainNum",
        "uct_waste_sell"."order_id" AS "FBillNo",
        "uct_waste_sell"."customer_id" AS "FSupplyID",
        '' AS "Fbusiness",
        concat('DC', "uct_waste_sell"."customer_id") AS "FDCStockID",
        CASE WHEN "uct_waste_sell"."purchase_id" IS NOT NULL THEN concat('LH', "uct_waste_sell"."warehouse_id") ELSE '' END AS "FSCStockID",
        CASE "uct_waste_sell"."state"
            WHEN 'cancel' THEN '0'
            ELSE '1'
        END AS "FCancellation",
        '0' AS "FROB",
        "Trans_log_table"."TallowOver" AS "FCorrent",
        "Trans_log_table"."TcheckOver" AS "FStatus",
        "Trans_log_table"."TallowOver" AS "FUpStockWhenSave",
        '' AS "FExplanation",
        '4' AS "FDeptID",
        "uct_waste_sell"."seller_id" AS "FEmpID",
        "Trans_log_table"."TcheckPerson" AS "FCheckerID",
        CASE "Trans_log_table"."TcheckOver"
            WHEN '0' THEN NULL
            ELSE TO_TIMESTAMP("Trans_log_table"."Tcheck")
        END AS "FCheckDate",
        "uct_waste_sell"."customer_linkman_id" AS "FFManagerID",
        "uct_waste_sell"."customer_linkman_id" AS "FSManagerID",
        "uct_waste_sell"."seller_id" AS "FBillerID",
        '1' AS "FCurrencyID",
        "Trans_log_table"."state" AS "FNowState",
        CASE WHEN "uct_waste_sell"."purchase_id" IS NOT NULL THEN '1' ELSE '2' END AS "FSaleStyle",
        '' AS "FPOStyle",
        '' AS "FPOPrecent",
        round("uct_waste_sell"."cargo_weight", 1) AS "TalFQty",
        round("uct_waste_sell"."cargo_price", 2) AS "TalFAmount",
        "uct_waste_sell"."materiel_price" AS "TalFeeFrist",
        "uct_waste_sell"."other_price" AS "TalFeeSecond",
        0 AS "TalFeeThird",
        0 AS "TalFeeForth",
        0 AS "TalFeeFifth",
        0 AS "col1",
        0 AS "col2",
        0 AS "col3",
        0 AS "col4",
        0 AS "col5",
        NULL AS "col6"
    FROM
        "uct_waste_sell"
    JOIN
        "uct_waste_customer"
    ON
        "uct_waste_sell"."customer_id" = "uct_waste_customer"."id"
    JOIN
        "Trans_log_table"
    ON
        "uct_waste_sell"."id" = "Trans_log_table"."FInterID"
    WHERE
        "uct_waste_sell"."purchase_id" IS NOT NULL = 0
        AND "uct_waste_sell"."order_id" > 201806300000000000
        AND "uct_waste_sell"."id" = "id";
END;
$$;


-- 删除名为 "Trans_main_sor" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_main_sor" (int);

-- 创建名为 "Trans_main_sor" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_main_sor" (IN "id" int) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- 删除符合条件的数据
    DELETE FROM "Trans_main_table" WHERE "FTranType" = 'SOR' AND "FInterID" = "id";
    
    -- 插入符合条件的数据
    INSERT INTO "Trans_main_table" ("FRelateBrID", "FInterID", "FTranType", "FDate", "createtime", "Date", "FTrainNum", "FBillNo", "FSupplyID", "Fbusiness", "FDCStockID", "FSCStockID", "FCancellation", "FROB", "FCorrent", "FStatus", "FUpStockWhenSave", "FExplanation", "FDeptID", "FEmpID", "FCheckerID", "FCheckDate", "FFManagerID", "FSManagerID", "FBillerID", "FCurrencyID", "FNowState", "FSaleStyle", "FPOStyle", "FPOPrecent", "TalFQty", "TalFAmount", "TalFeeFrist", "TalFeeSecond", "TalFeeThird", "TalFeeForth", "TalFeeFifth", "col1", "col2", "col3", "col4", "col5", "col6")
    SELECT
        "uct_waste_purchase"."branch_id" AS "FRelateBrID",
        "uct_waste_purchase"."id" AS "FInterID",
        'SOR' AS "FTranType",
        CASE "Trans_log_table"."TallowOver"
            WHEN '0' THEN TO_TIMESTAMP(0)
            ELSE TO_TIMESTAMP("Trans_log_table"."Tallow")
        END AS "FDate",
        TO_TIMESTAMP("uct_waste_purchase".createtime),
        CASE "Trans_log_table"."TallowOver"
            WHEN '0' THEN TO_DATE(TO_TIMESTAMP(0), 'YYYY-MM-DD')
            ELSE TO_DATE(TO_TIMESTAMP("Trans_log_table"."Tallow"), 'YYYY-MM-DD')
        END AS "Date",
        "uct_waste_purchase"."train_number" AS "FTrainNum",
        "uct_waste_purchase"."order_id" AS "FBillNo",
        "uct_waste_purchase"."customer_id" AS "FSupplyID",
        "uct_waste_purchase"."manager_id" AS "Fbusiness",
        concat('LH', "uct_waste_warehouse"."parent_id") AS "FDCStockID",
        concat('AD', "uct_waste_purchase"."purchase_incharge") AS "FSCStockID",
        CASE "uct_waste_purchase"."state"
            WHEN 'cancel' THEN '0'
            ELSE '1'
        END AS "FCancellation",
        '0' AS "FROB",
        "Trans_log_table"."TallowOver" AS "FCorrent",
        "Trans_log_table"."TcheckOver" AS "FStatus",
        "Trans_log_table"."TsortOver" AS "FUpStockWhenSave",
        '' AS "FExplanation",
        '4' AS "FDeptID",
        "uct_waste_warehouse"."admin_id" AS "FEmpID",
        "Trans_log_table"."TcheckPerson" AS "FCheckerID",
        CASE "Trans_log_table"."TcheckOver"
            WHEN '0' THEN NULL
            ELSE TO_TIMESTAMP("Trans_log_table"."Tcheck")
        END AS "FCheckDate",
        "uct_waste_purchase"."purchase_incharge" AS "FFManagerID",
        "uct_waste_warehouse"."admin_id" AS "FSManagerID",
        "uct_waste_warehouse"."admin_id" AS "FBillerID",
        '1' AS "FCurrencyID",
        "Trans_log_table"."state" AS "FNowState",
        '0' + CASE "uct_waste_purchase"."give_frame"
            WHEN '1' THEN '3'
            ELSE '0'
        END AS "FSaleStyle",
        "uct_waste_customer"."settle_way" AS "FPOStyle",
        "uct_waste_customer"."back_percent" AS "FPOPrecent",
        round("uct_waste_purchase"."storage_weight", 1) AS "TalFQty",
        round("uct_waste_purchase"."storage_cargo_price", 2) AS "TalFAmount",
        "Trans_total_fee_sg"."sort_fee" AS "TalFeeFrist",
        "Trans_total_fee_sg"."materiel_fee" AS "TalFeeSecond",
        "Trans_total_fee_sg"."other_sort_fee" AS "TalFeeThird",
        "uct_waste_purchase"."total_cargo_price" AS "TalFeeForth",
        "uct_waste_purchase"."total_labor_price" AS "TalFeeFifth",
        0 AS "col1",
        0 AS "col2",
        0 AS "col3",
        0 AS "col4",
        0 AS "col5",
        NULL AS "col6"
    FROM
        "uct_waste_purchase"
    JOIN
        "uct_waste_customer"
    ON
        "uct_waste_purchase"."customer_id" = "uct_waste_customer"."id"
    JOIN
        "Trans_log_table"
    ON
        "uct_waste_purchase"."id" = "Trans_log_table"."FInterID"
    JOIN
        "uct_waste_warehouse"
    ON
        "uct_waste_warehouse"."id" = "uct_waste_purchase"."sort_point"
    LEFT JOIN
        "Trans_total_fee_sg"
    ON
        "Trans_total_fee_sg"."purchase_id" = "uct_waste_purchase"."id"
    WHERE
        "uct_waste_purchase"."customer_id" = "uct_waste_customer"."id"
        AND "uct_waste_purchase"."id" = "Trans_log_table"."FInterID"
        AND "Trans_log_table"."FTranType" = 'SOR'
        AND "uct_waste_warehouse"."id" = "uct_waste_purchase"."sort_point"
        AND "uct_waste_purchase"."order_id" > 201806300000000000
        AND "uct_waste_purchase"."id" = "id";
END;
$$;


-- 删除名为 "Trans_materiel_sor" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."Trans_materiel_sor" (int);

-- 创建名为 "Trans_materiel_sor" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."Trans_materiel_sor" (IN "id" int) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- 删除符合条件的数据
    DELETE FROM "Trans_materiel_table" WHERE "FTranType" = 'SOR' AND "FInterID" = "id";
    
    -- 插入符合条件的数据
    INSERT INTO "Trans_materiel_table" ("FInterID", "FTranType", "FEntryID", "FMaterielID", "FUseCount", "FPrice", "FMeterielAmount", "FMeterieltime", "red_ink_time", "is_hedge", "col1", "col2")
    SELECT
        "uct_waste_purchase_materiel"."purchase_id" AS "FInterID",
        'SOR' AS "FTranType",
        "uct_waste_purchase_materiel"."id" AS "FEntryID",
        "uct_waste_purchase_materiel"."materiel_id" AS "FMaterielID",
        CAST("uct_waste_purchase_materiel"."pick_amount" AS SIGNED) - CAST("uct_waste_purchase_materiel"."storage_amount" AS SIGNED) AS "FUseCount",
        "uct_waste_purchase_materiel"."inside_price" AS "FPrice",
        ROUND((CAST("uct_waste_purchase_materiel"."pick_amount" AS SIGNED) - CAST("uct_waste_purchase_materiel"."storage_amount" AS SIGNED)) * ROUND("uct_waste_purchase_materiel"."inside_price", 2), 2) AS "FMeterielAmount",
        "uct_waste_purchase_materiel"."updatetime" AS "FMeterieltime",
        NULL AS "red_ink_time",
        0 AS "is_hedge",
        0 AS "col1",
        0 AS "col2"
    FROM
        "uct_waste_purchase_materiel"
    WHERE
        "uct_waste_purchase_materiel"."use_type" = 1
        AND "uct_waste_purchase_materiel"."purchase_id" = "id";
END;
$$;







