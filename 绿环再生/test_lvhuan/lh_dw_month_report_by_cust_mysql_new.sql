DROP PROCEDURE IF EXISTS "test_lvhuan"."lh_dw_month_report_by_cust_mysql_new";

CREATE OR REPLACE PROCEDURE "test_lvhuan"."lh_dw_month_report_by_cust_mysql_new"(
    IN "p_day" VARCHAR(50),
    IN "p_cust_id" INTEGER,
    INOUT "o_rv_err" VARCHAR(200)
)
LANGUAGE plpgsql AS $$
DECLARE
    "v_new_day" VARCHAR(50);
    errno INT;
BEGIN
    -- 初始化 o_rv_err
    "o_rv_err" := NULL;

    -- 处理异常
    BEGIN
        -- 主过程
        SELECT TO_CHAR(DATE_ADD("p_day"::DATE, INTERVAL '1 MONTH'), 'YYYY-MM-DD') INTO "v_new_day";

        IF "v_new_day" IS NULL THEN
            "o_rv_err" := '获取月份失败.';
            RETURN;
        END IF;

        -- 开始事务
        START TRANSACTION;

set errno=1000;

   insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code,  base.group1, 
           COALESCE(main.m1,0) as val1, COALESCE(main.m2,0) as val2, 
           COALESCE((case when main.m2 = 0 then 0 else round((main.m1 - main.m2)/main.m2,4) end),0)*100 as val3
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'revenue' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select tmt.FSupplyID,
                   sum((case when UNIX_TIMESTAMP(tmt.FDate) > base.begin_time and UNIX_TIMESTAMP(tmt.FDate) < base.end_time then tmt.TalFAmount else 0 end)) as m1,
                   sum((case when UNIX_TIMESTAMP(tmt.FDate) > base.begin_time2 and UNIX_TIMESTAMP(tmt.FDate) < base.end_time2 then tmt.TalFAmount else 0 end)) as m2 
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 2 MONTH), '%Y-%m-01 00:00:00')) as begin_time2,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m-%d 23:59:59')) as end_time2
                   ) as base,
                   Trans_main_table as tmt
             where tmt.FCancellation = 1 
               and tmt.FTranType = 'PUR'
             group by tmt.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1001;


  insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code,  base.group1, 
           COALESCE(main.m1,0) as val1, COALESCE(main.m2,0) as val2, 
           COALESCE((case when main.m2 = 0 then 0 else round((main.m1 - main.m2)/main.m2,4) end),0)*100 as val3
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'weight' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select tmt.FSupplyID,
                   sum((case when UNIX_TIMESTAMP(tmt.FDate) > base.begin_time and UNIX_TIMESTAMP(tmt.FDate) < base.end_time then tmt.TalFQty else 0 end)) as m1,
                   sum((case when UNIX_TIMESTAMP(tmt.FDate) > base.begin_time2 and UNIX_TIMESTAMP(tmt.FDate) < base.end_time2 then tmt.TalFQty else 0 end)) as m2 
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 2 MONTH), '%Y-%m-01 00:00:00')) as begin_time2,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m-%d 23:59:59')) as end_time2
                   ) as base,
                   Trans_main_table as tmt
             where tmt.FCancellation = 1 
               and tmt.FTranType = 'PUR'
             group by tmt.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
 set errno=1002;
 
 
      insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, base.data_dims, 
           cus.id as data_val, base.stat_code, base.group1,
           COALESCE(main.m1,0) as val1,COALESCE((main.m1 - main.m2),0) as val2,
           (COALESCE((case when main.m2 = 0 then 0 else round((main.m1 - main.m2)/main.m2,4) end),0) * 100) as val3
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'cumulative-revenue' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select tmt.FSupplyID, 
                   SUM((case when UNIX_TIMESTAMP(tmt.FDate) < base.end_time then tmt.TalFAmount else 0 end)) as m1,
                   SUM((case when UNIX_TIMESTAMP(tmt.FDate) < (base.begin_time - 1) then tmt.TalFAmount else 0 end)) as m2
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as tmt
             where tmt.FCancellation = 1 
               and UNIX_TIMESTAMP(tmt.FDate) > 1546272000 
               and tmt.FTranType = 'PUR'
             group by tmt.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1003;
 
  
    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, base.data_dims, 
           cus.id as data_val, base.stat_code, base.group1,
           COALESCE(main.m1,0) as val1,COALESCE((main.m1 - main.m2),0) as val2,
           (COALESCE((case when main.m2 = 0 then 0 else round((main.m1 - main.m2)/main.m2,4) end),0) * 100) as val3
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'cumulative-weight' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select tmt.FSupplyID, 
                   SUM((case when UNIX_TIMESTAMP(tmt.FDate) < base.end_time then tmt.TalFQty else 0 end)) as m1,
                   SUM((case when UNIX_TIMESTAMP(tmt.FDate) < (base.begin_time - 1) then tmt.TalFQty else 0 end)) as m2
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as tmt
             where tmt.FCancellation = 1 
               and UNIX_TIMESTAMP(tmt.FDate) > 1546272000 
               and tmt.FTranType = 'PUR'
             group by tmt.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1004; 
 


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1)
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, base.data_dims, 
           cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.total_w,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                    UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                    TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                    TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                    'M' as time_dims, 
                    '客户' as data_dims,
                    'customer-monthly-report' as stat_code,
                    'weight-by-waste-structure' as group1,
                    'recyclable-waste' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID,COALESCE(SUM(oldAssist.FQty),0) as total_w
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_assist_table as oldAssist
                on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
             where (oldMain.FTranType = 'SOR' or oldMain.FTranType = 'SEL')
               and oldMain.FCancellation = 1 
               and oldMain.FCorrent = 1
               and oldMain.FSaleStyle in (0,1) 
               and UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldAssist.value_type = 'valuable'
             group by oldMain.FSupplyID) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up' 
   and cus.id = p_cust_id
  GROUP BY cus.id;

set errno=1005; 


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1)
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, base.data_dims, 
           cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.total_w,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                    UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                    TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                    TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                    'M' as time_dims, 
                    '客户' as data_dims,
                    'customer-monthly-report' as stat_code,
                    'weight-by-waste-structure' as group1,
                    'low-value-waste' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID,COALESCE(SUM(oldAssist.FQty),0) as total_w
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_assist_table as oldAssist
                on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
             where (oldMain.FTranType = 'SOR' or oldMain.FTranType = 'SEL')
               and oldMain.FCancellation = 1 
               and oldMain.FCorrent = 1
               and oldMain.FSaleStyle in (0,1) 
               and UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldAssist.value_type = 'unvaluable'
             group by oldMain.FSupplyID) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up' 
   and cus.id = p_cust_id
  GROUP BY cus.id;

set errno=1006; 


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1)
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, base.data_dims, 
           cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.total_w,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                    UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                    TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                    TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                    'M' as time_dims, 
                    '客户' as data_dims,
                    'customer-monthly-report' as stat_code,
                    'weight-by-waste-structure' as group1,
                    'hazardous-waste' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID,COALESCE(SUM(oldAssist.FQty),0) as total_w
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_assist_table as oldAssist
                on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
             where (oldMain.FTranType = 'SOR' or oldMain.FTranType = 'SEL')
               and oldMain.FCancellation = 1 
               and oldMain.FCorrent = 1
               and oldMain.FSaleStyle in (0,1) 
               and UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldAssist.value_type = 'dangerous'
             group by oldMain.FSupplyID) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up' 
   and cus.id = p_cust_id
  GROUP BY cus.id;

set errno=1007;



update lh_dw.data_statistics_results as main,
            (select A.id,A.data_val,A.val1,B.weight,(case when B.weight = 0 then 0 else round((A.val1/B.weight),4) end) as rate,
                    B.time_val,B.time_dims,B.group1
               from lh_dw.data_statistics_results as A
          left join (select data_val,SUM(val1) as weight,base.time_val,base.time_dims,base.group1  
                       from lh_dw.data_statistics_results as C,
                            (select TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                    'M' as time_dims, 
                                    'weight-by-waste-structure' as group1
                            ) as base 
                      where C.time_dims = base.time_dims 
                        and C.time_val = base.time_val 
                        and C.group1 = base.group1 
                      group by C.data_val
                    ) as B
                 on A.data_val = B.data_val
              where A.time_dims = B.time_dims 
                and A.time_val = B.time_val 
                and A.group1 = B.group1 
              order by  A.data_val
            ) as detail
        set main.val3 = detail.rate * 100
      where main.time_dims = detail.time_dims
        and main.time_val = detail.time_val
        and main.group1 = detail.group1
        and main.id = detail.id;

set errno=1011;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, txt1)
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code,  base.group1, COALESCE(main.txt1,'2019-01-01') as txt1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'first-service-time' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select FSupplyID,left((MIN(FDate)),10) as txt1 
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table 
             where UNIX_TIMESTAMP(FDate) > 1546272000
               and UNIX_TIMESTAMP(FDate) < base.end_time 
               and FCancellation = 1 
               and FTranType = 'PUR'
               group by FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1012;

  
    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1)
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code,  base.group1, 
           COALESCE(main.num,0) as val1 
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'service-times' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select FSupplyID,count(distinct FBillNo) as num
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table 
             where UNIX_TIMESTAMP(FDate) > base.begin_time
               and UNIX_TIMESTAMP(FDate) < base.end_time 
               and FCancellation = 1 
               and FTranType = 'PUR'
               group by FSupplyID
           ) as main
        on cus.id = main.FSupplyID
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1013;


        insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
    select det.time_dims, det.time_val,det.begin_time, det.end_time, det.data_dims, det.data_val, det.stat_code, det.group1,
           det.m1 as val1,det.m2 as val2,((case when det.m2 = 0 then 0 else round((det.m1 - det.m2)/det.m2,4) end) * 100) as val3
      from (select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, base.data_dims, 
                   cus.id as data_val, base.stat_code, base.group1,
                   COALESCE((select count(distinct FBillNo) from Trans_main_table where FCancellation = 1 and FTranType = 'PUR' and UNIX_TIMESTAMP(FDate) > 1546272000 
                      and UNIX_TIMESTAMP(FDate) < base.end_time and FSupplyID = cus.id),0) as m1, 
                   COALESCE((select count(distinct FBillNo) from Trans_main_table where FCancellation = 1 and FTranType = 'PUR' and UNIX_TIMESTAMP(FDate) > 1546272000 
                      and UNIX_TIMESTAMP(FDate) < (base.begin_time - 1) and FSupplyID = cus.id),0) as m2
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB('2020-09-01', INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB('2020-09-01', INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB('2020-09-01', INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           TO_CHAR(LAST_DAY(DATE_SUB('2020-09-01', INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                           'M' as time_dims, 
                           '客户' as data_dims,
                           'customer-monthly-report' as stat_code,
                           'cumulative-service-times' as group1
                   ) as base,
                   uct_waste_customer as cus 
         left join (select * 
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB('2020-09-01', INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB('2020-09-01', INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                           ) as base,
                           Trans_main_table 
                     where UNIX_TIMESTAMP(FDate) > base.begin_time
                       and UNIX_TIMESTAMP(FDate) < base.end_time 
                       and FCancellation = 1 
                       and FTranType = 'PUR') as main
                on cus.id = main.FSupplyID 
             where cus.customer_type = 'up'
   and cus.id = p_cust_id
             GROUP BY cus.id
           ) as det;

set errno=1014;



  
    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'order-response-time' as group1,
                   'fastest-resp-time' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, round(MIN(oldLog.Tallot-oldLog.Tcreate)/3600,2) as val1
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_log_table as oldLog
                on oldMain.FInterID = oldLog.FinterID and oldMain.FTranType = oldLog.FTranType
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FTranType = 'PUR'  
               and oldLog.TallotOver = 1
            group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1016;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'order-response-time' as group1,
                   'average-resp-time' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, round(AVG(oldLog.Tallot-oldLog.Tcreate)/3600,2) as val1
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_log_table as oldLog
                on oldMain.FInterID = oldLog.FinterID and oldMain.FTranType = oldLog.FTranType
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FTranType = 'PUR'  
               and oldLog.TallotOver = 1
            group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1017;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1)    
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'order-response-time' as group1,
                   'slowest-resp-time' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, round(MAX(oldLog.Tallot-oldLog.Tcreate)/3600,2) as val1
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_log_table as oldLog
                on oldMain.FInterID = oldLog.FinterID and oldMain.FTranType = oldLog.FTranType
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FTranType = 'PUR'  
               and oldLog.TallotOver = 1
            group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1018;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'order-response-time' as group1,
                   'plan-resp-time' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, round((AVG(oldLog.Tallot-oldLog.Tcreate)+((MAX(oldLog.Tallot-oldLog.Tcreate)+
                                             MIN(oldLog.Tallot-oldLog.Tcreate)+4*AVG(oldLog.Tallot-oldLog.Tcreate))/3))/3600,1) as val1
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_log_table as oldLog
                on oldMain.FInterID = oldLog.FinterID and oldMain.FTranType = oldLog.FTranType
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FTranType = 'PUR'  
               and oldLog.TallotOver = 1
            group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1019;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1)      
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'disposal-response-time' as group1,
                   'fastest-resp-time' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, round(MIN(oldLog.Tpurchase-oldLog.Tcreate)/3600,2) as val1
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_log_table as oldLog
                on oldMain.FInterID = oldLog.FinterID and oldMain.FTranType = oldLog.FTranType
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FTranType = 'PUR'  
               and oldLog.TallotOver = 1
            group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1020;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1)      
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'disposal-response-time' as group1,
                   'average-resp-time' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, round(AVG(oldLog.Tpurchase-oldLog.Tcreate)/3600,2) as val1
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_log_table as oldLog
                on oldMain.FInterID = oldLog.FinterID and oldMain.FTranType = oldLog.FTranType
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FTranType = 'PUR'  
               and oldLog.TallotOver = 1
            group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1021;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1)      
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'disposal-response-time' as group1,
                   'slowest-resp-time' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, round(MAX(oldLog.Tpurchase-oldLog.Tcreate)/3600,2) as val1
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_log_table as oldLog
                on oldMain.FInterID = oldLog.FinterID and oldMain.FTranType = oldLog.FTranType
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FTranType = 'PUR'  
               and oldLog.TallotOver = 1
            group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1022;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'disposal-response-time' as group1,
                   'plan-resp-time' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, round((AVG(oldLog.Tpurchase-oldLog.Tcreate)+((MAX(oldLog.Tpurchase-oldLog.Tcreate)+
                                             MIN(oldLog.Tpurchase-oldLog.Tcreate)+4*AVG(oldLog.Tpurchase-oldLog.Tcreate))/3))/3600,1) as val1
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_log_table as oldLog
                on oldMain.FInterID = oldLog.FinterID and oldMain.FTranType = oldLog.FTranType
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FTranType = 'PUR'  
               and oldLog.TallotOver = 1
            group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1023;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, txt1, val1, val2)  
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1,  
           COALESCE(main.name,'无品名') as txt1, COALESCE(main.money,0) as val1, COALESCE(main.weight,0) as val2
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'revenue-by-waste-cate' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, cate.name, sum(oldAssist.FAmount) as money, sum(oldAssist.FQty) as weight
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_assist_table as oldAssist
                on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
         left join uct_waste_cate as cate
                on oldAssist.FItemID = cate.id
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FTranType = 'PUR'  
               and oldAssist.value_type = 'valuable'
             group by oldMain.FSupplyID, cate.name
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id, main.name;


set errno=1024;

  
            UPDATE lh_dw.data_statistics_results as a
            SET a.val3 = b.urank
            FROM (
                SELECT main.id, main.data_val, main.val1,
                       ROW_NUMBER() OVER (PARTITION BY main.data_val ORDER BY main.val1 DESC) AS urank
                FROM (
                    SELECT
                        lh_dw.data_statistics_results.id,
                        lh_dw.data_statistics_results.data_val,
                        lh_dw.data_statistics_results.val1
                    FROM
                        lh_dw.data_statistics_results
                    WHERE
                        lh_dw.data_statistics_results.group1 = 'revenue-by-waste-cate'
                        AND lh_dw.data_statistics_results.time_val = TO_CHAR(LAST_DAY(DATE_SUB("v_new_day"::DATE, INTERVAL '1 MONTH')), 'YYYY-MM')
                        AND lh_dw.data_statistics_results.data_dims = '客户'
                ) AS main
            ) b
            WHERE a.id = b.id;

set errno=1025;


            UPDATE lh_dw.data_statistics_results as a
            SET a.val4 = b.urank
            FROM (
                SELECT main.id, main.data_val, main.val2,
                       ROW_NUMBER() OVER (PARTITION BY main.data_val ORDER BY main.val2 DESC) AS urank
                FROM (
                    SELECT
                        lh_dw.data_statistics_results.id,
                        lh_dw.data_statistics_results.data_val,
                        lh_dw.data_statistics_results.val2
                    FROM
                        lh_dw.data_statistics_results
                    WHERE
                        lh_dw.data_statistics_results.group1 = 'revenue-by-waste-cate'
                        AND lh_dw.data_statistics_results.time_val = TO_CHAR(LAST_DAY(DATE_SUB("v_new_day"::DATE, INTERVAL '1 MONTH')), 'YYYY-MM')
                        AND lh_dw.data_statistics_results.data_dims = '客户'
                ) AS main
            ) b
            WHERE a.id = b.id;


set errno=1026;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1,  val1, val2, val3) 
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, base.data_dims, 
           cus.id as data_val, base.stat_code, base.group1, COALESCE(m1,0) as val1, COALESCE(m2,0) as val2, COALESCE(m3,0) as val3
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'purchase-weight' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID,
                   SUM(if(oldAssist.value_type in ('valuable','unvaluable'),oldAssist.FQty,0)) as m1,
                   SUM(if(oldAssist.value_type = 'valuable',oldAssist.FQty,0)) as m2,
                   SUM(if(oldAssist.value_type = 'unvaluable',oldAssist.FQty,0)) as m3
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_assist_table as oldAssist
                on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType 
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1 
               and oldMain.FTranType = 'PUR'
             group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1027;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3, val4, val5)
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, base.data_dims, 
           cus.id as data_val, base.stat_code, base.group1, COALESCE(m1,0) as val1, COALESCE(m2,0) as val2, COALESCE(m3,0) as val3,
           COALESCE(m4,0) as val4, COALESCE(m5,0) as val5
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'inventory-analysis' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID,
                   SUM(oldAssist.FAmount) as m1,
                   SUM(if(oldAssist.FTranType = 'SOR' and oldAssist.disposal_way = 'sorting',oldAssist.FAmount,0)) as m2,
                   SUM(if(((oldAssist.FTranType = 'SOR' and oldAssist.disposal_way = 'weighing') or (oldAssist.FTranType = 'SEL')),oldAssist.FAmount,0)) as m3,
                   SUM(if(oldAssist.FTranType = 'SOR' and oldAssist.disposal_way = 'sorting',oldAssist.FQty,0)) as m4,
                   SUM(if(((oldAssist.FTranType = 'SOR' and oldAssist.disposal_way = 'weighing') or (oldAssist.FTranType = 'SEL')),oldAssist.FQty,0)) as m5
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_assist_table as oldAssist
                on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType 
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1 
               and oldMain.FCorrent = 1
             group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1028;

  
    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1, val2, val3) 
    select det.time_dims, det.time_val, det.begin_time, det.end_time, det.data_dims, det.data_val, det.stat_code, det.group1, det.group2,  
           ((select (case when det.val2 = 0 then 0 else output_value end) from lh_dw.data_statistics_value_interval where vice_code = 'sorting_accounted' 
                 and start_value <= det.val2 and end_value > det.val2) + 
            (select (case when det.val3 = 0 then 0 else output_value end) from lh_dw.data_statistics_value_interval where vice_code = 'the_unit_price' 
                 and start_value <= det.val3 and end_value > det.val3)
           ) as val1, det.val2, det.val3
      from (select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                   base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, 
                    (case when inv.val1 = 0 then 0 else round((inv.val4/inv.val1),3) end) as val2,
                    (case when inv.val4 = 0 then 0 else round((inv.val2/inv.val4),3) end) as val3
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           'M' as time_dims, 
                           '客户' as data_dims,
                           'customer-monthly-report' as stat_code,
                           'customer-index' as group1,
                           'sorting-cost' as group2
                   ) as base,
                   uct_waste_customer as cus
         left join (select rest.data_val,  
                           sum((case when rest.group1 = 'inventory-analysis' then rest.val4 else 0 end)) as val4,
                           sum((case when rest.group1 = 'inventory-analysis' then rest.val2 else 0 end)) as val2, 
                           sum((case when rest.group1 = 'weight' then rest.val1  else 0 end)) as val1
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val
                           ) as base,
                           lh_dw.data_statistics_results as rest 
                     where rest.time_val = base.time_val
                       and rest.time_dims = 'M'
                       and rest.group1 in ('inventory-analysis','weight')
                       group by rest.data_val
                   ) as inv
                on cus.id = inv.data_val 
             where cus.customer_type = 'up'
   and cus.id = p_cust_id
             GROUP BY cus.id
           ) as det;
 
set errno=1029;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1, val2, val3) 
    select det.time_dims, det.time_val, det.begin_time, det.end_time, det.data_dims, det.data_val, det.stat_code, det.group1, det.group2,
           ((select (case when det.val2 = 0 then 0 else output_value end) from lh_dw.data_statistics_value_interval where vice_code = 'first_order_time' 
                and start_value <= det.val2 and end_value > det.val2) + 
            (select (case when det.val3 = 0 then 0 else output_value end) from lh_dw.data_statistics_value_interval where vice_code = 'month_output' 
                and start_value <= det.val3 and end_value > det.val3)
           ) as val1, det.val2, det.val3  
      from (select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                   base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2,
                    round((base.end_time - inv.m1)/86400,3) as val2, inv.m2 as val3
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           'M' as time_dims, 
                           '客户' as data_dims,
                           'customer-monthly-report' as stat_code,
                           'customer-index' as group1,
                           'trust-index' as group2
                   ) as base,
                   uct_waste_customer as cus 
         left join (select rest.data_val, 
                           sum((case when rest.group1 = 'first-service-time' then UNIX_TIMESTAMP(rest.txt1) else 0 end)) as m1, 
                           sum((case when rest.group1 = 'weight' then rest.val1  else 0 end)) as m2
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val
                           ) as base,
                           lh_dw.data_statistics_results as rest 
                     where rest.time_val = base.time_val
                       and rest.time_dims = 'M'
                       and rest.group1 in ('first-service-time','weight')
                      group by rest.data_val
                   ) as inv
                on cus.id = inv.data_val 
             where cus.customer_type = 'up'
   and cus.id = p_cust_id
             GROUP BY cus.id
           ) as det;
 
set errno=1030;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1, val2)
    select det.time_dims, det.time_val, det.begin_time, det.end_time, det.data_dims, det.data_val, det.stat_code, det.group1, det.group2,
           (select (case when det.val2 = 0 then 0 else output_value end) from lh_dw.data_statistics_value_interval where main_code = 'service-effect' 
               and start_value <= det.val2 and end_value > det.val2) as val1, det.val2 
      from (select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                   base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2,
                   COALESCE((case when inv.m2 = 0 then 0 else round(inv.m1/inv.m2,3) end),0) as val2
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                           'M' as time_dims, 
                           '客户' as data_dims,
                           'customer-monthly-report' as stat_code,
                           'customer-index' as group1,
                           'service-effect' as group2
                   ) as base,
                   uct_waste_customer as cus 
         left join (select E.FSupplyID, COALESCE(SUM(G.sign_out_time-G.sign_in_time),0) as m1, COALESCE(count(E.FCancellation),0) as m2 
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time     
                           ) as base,
                           Trans_main_table as E 
                 left join uct_waste_purchase as F 
                        on E.FBillNo = F.order_id 
                 left join uct_purchase_sign_in_out as G 
                        on F.id = G.purchase_id 
                     where E.FCancellation = 1 
                       and UNIX_TIMESTAMP(E.FDate) > base.begin_time 
                       and UNIX_TIMESTAMP(E.FDate) < base.end_time 
                       and E.FTranType = 'PUR' 
                       and G.sign_in_time > 0 
                       and G.sign_out_time > 0  
                     group by E.FSupplyID
                   ) as inv
                on cus.id = inv.FSupplyID 
             where cus.customer_type = 'up'
   and cus.id = p_cust_id
             GROUP BY cus.id
           ) as det;

set errno=1031;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1, val2)
    select det.time_dims, det.time_val, det.begin_time, det.end_time, det.data_dims, det.data_val, det.stat_code, det.group1, det.group2,
           (select (case when det.val2 = 0 then 0 else output_value end) from lh_dw.data_statistics_value_interval where main_code = 'load-factor' 
               and start_value <= det.val2 and end_value > det.val2) as val1, det.val2 
      from (select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                   base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2,
                   (case when inv.m2 = 0 then 0 else round((inv.m1/inv.m2),2) end) as val2
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                           'M' as time_dims, 
                           '客户' as data_dims,
                           'customer-monthly-report' as stat_code,
                           'customer-index' as group1,
                           'load-factor' as group2
                   ) as base,
                   uct_waste_customer as cus 
         left join (select rest.data_val,
                           sum((case when rest.group1 = 'weight' then rest.val1  else 0 end)) as m1,
                           sum((case when rest.group1 = 'service-times' then rest.val1 else 0 end)) as m2 
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val     
                           ) as base,
                           lh_dw.data_statistics_results as rest
                     where rest.time_dims = 'M'
                       and rest.time_val = base.time_val
                       and rest.group1 in ('service-times','weight')   
                     group by rest.data_val
                   ) as inv
                on cus.id = inv.data_val 
             where cus.customer_type = 'up'
   and cus.id = p_cust_id
             GROUP BY cus.id       
           ) as det;
 
set errno=1032;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1, val2, val3)    
    select det.time_dims, det.time_val, det.begin_time, det.end_time, det.data_dims, det.data_val, det.stat_code, det.group1, det.group2,
           ((select (case when det.val2 = 0 then 0 else output_value end) from lh_dw.data_statistics_value_interval where vice_code = 'sorting_accounted' 
                and start_value <= det.val2 and end_value > det.val2) + 
            (select (case when det.val3 = 0 then 0 else output_value end) from lh_dw.data_statistics_value_interval where vice_code = 'the_unit_price' 
                and start_value <= det.val3 and end_value > det.val3)
           ) as val1, det.val2, det.val3
      from (select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                   base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2,
                   COALESCE((case when inv.m1 = 0 then 0  else round((inv.m4/inv.m1),3) end),0) as val2,
                   COALESCE((case when inv.m2 = 0 then 0  else round((inv.m3/inv.m2),3) end),0) as val3 
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                           'M' as time_dims, 
                           '客户' as data_dims,
                           'customer-monthly-report' as stat_code,
                           'customer-index' as group1,
                           'waste-structure' as group2
                   ) as base,
                   uct_waste_customer as cus 
         left join (select rest.data_val, 
                           sum((case when rest.group1 = 'weight' then rest.val1  else 0 end)) as m1,
                           sum((case when rest.group1 = 'purchase-weight' then rest.val1 else 0 end)) as m2,
                           sum((case when rest.group1 = 'purchase-weight' then rest.val2 else 0 end)) as m3,
                           sum((case when rest.group1 = 'purchase-weight' then rest.val3 else 0 end)) as m4
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val 
                           ) as base,
                           lh_dw.data_statistics_results as rest
                     where rest.time_dims = 'M' 
                       and rest.time_val = base.time_val
                       and rest.group1 in ('purchase-weight','weight') 
                     group by rest.data_val
                   ) as inv
                on cus.id = inv.data_val 
             where cus.customer_type = 'up'
   and cus.id = p_cust_id
             GROUP BY cus.id
           ) as det;
set errno=1033;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1, val2) 
    select det.time_dims, det.time_val, det.begin_time, det.end_time, det.data_dims, det.data_val, det.stat_code, det.group1, det.group2,
           (select (case when det.val2 = 0 then 0 else output_value end) from lh_dw.data_statistics_value_interval where main_code = 'industry-ranking' 
               and start_value <= det.val2 and end_value >= det.val2) as val1, det.val2
      from (select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                   base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2,
                   COALESCE(inv.num,0) as val2
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                           'M' as time_dims, 
                           '客户' as data_dims,
                           'customer-monthly-report' as stat_code,
                           'customer-index' as group1,
                           'industry-ranking' as group2
                   ) as base,
                   uct_waste_customer as cus 
         left join (select rest.data_val,SUM(rest.val1) as num
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val 
                           ) as base,
                           lh_dw.data_statistics_results as rest
                     where rest.time_dims = 'M' 
                       and rest.time_val = base.time_val 
                       and rest.group1 = 'customer-index' 
                       and rest.group2 in ('sorting-cost','trust-index','service-effect','load-factor','waste-structure')
                     group by rest.data_val
                   ) as inv
                on cus.id = inv.data_val 
             where cus.customer_type = 'up'
   and cus.id = p_cust_id
             GROUP BY cus.id
           ) as det;
set errno=1034;


   insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1)
   select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
          base.data_dims, rest.data_val as data_val, base.stat_code, base.group1, base.group2,COALESCE(SUM(val1),0) as val1
     from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                  UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                  TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                  TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                  'M' as time_dims, 
                  '客户' as data_dims,
                  'customer-monthly-report' as stat_code,
                  'customer-index' as group1,
                  'the_overall_score' as group2
          ) as base,
          lh_dw.data_statistics_results as rest 
    where rest.time_dims = base.time_dims
      and rest.time_val = base.time_val
      and rest.group1 = base.group1
    GROUP BY rest.data_val;
 
set errno=1035;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, 0 as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'weight-by-waste-class' as group1,
                   'glass' as group2
           ) as base,
           uct_waste_customer as cus 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1036;


     insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
     select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
            base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.weight,0) as val1
       from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                    UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                    TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                    TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                    'M' as time_dims, 
                    '客户' as data_dims,
                    'customer-monthly-report' as stat_code,
                    'weight-by-waste-class' as group1,
                    'metal' as group2
            ) as base,
            uct_waste_customer as cus 
  left join (select oldMain.FSupplyID, SUM(oldAssist.FQty) as weight
               from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                            UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                    ) as base,
                    Trans_main_table as oldMain
          left join Trans_assist_table as oldAssist
                 on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
          left join uct_waste_cate as cate
                 on oldAssist.FItemID = cate.id
              where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
                and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
                and oldMain.FCancellation = 1
                and oldMain.FCorrent = 1  
                and ((oldMain.FTranType = 'SOR') or (oldMain.FTranType = 'SEL' and oldMain.FSaleStyle = 1))
                and cate.top_class = 'metal'
                group by oldMain.FSupplyID
            ) as main
         on cus.id = main.FSupplyID 
      where cus.customer_type = 'up'
  and cus.id = p_cust_id
      GROUP BY cus.id;

set errno=1037;


       insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
      select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
             base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.weight,0) as val1
        from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                     UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                     TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                     TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                     'M' as time_dims, 
                     '客户' as data_dims,
                     'customer-monthly-report' as stat_code,
                     'weight-by-waste-class' as group1,
                     'plastic' as group2
             ) as base,
             uct_waste_customer as cus 
   left join (select oldMain.FSupplyID, SUM(oldAssist.FQty) as weight
                from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                             UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                     ) as base,
                     Trans_main_table as oldMain
           left join Trans_assist_table as oldAssist
                  on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
           left join uct_waste_cate as cate
                  on oldAssist.FItemID = cate.id
               where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
                 and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
                 and oldMain.FCancellation = 1
                 and oldMain.FCorrent = 1  
                 and ((oldMain.FTranType = 'SOR') or (oldMain.FTranType = 'SEL' and oldMain.FSaleStyle = 1))
                 and cate.top_class = 'plastic'
                 group by oldMain.FSupplyID
             ) as main
          on cus.id = main.FSupplyID 
       where cus.customer_type = 'up'
   and cus.id = p_cust_id
       GROUP BY cus.id;

set errno=1038;

       insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
       select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
              base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.weight,0) as val1
         from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                      UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                      TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                      TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                      'M' as time_dims, 
                      '客户' as data_dims,
                      'customer-monthly-report' as stat_code,
                      'weight-by-waste-class' as group1,
                      'waste-paper' as group2
              ) as base,
              uct_waste_customer as cus 
    left join (select oldMain.FSupplyID, SUM(oldAssist.FQty) as weight
                 from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                              UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                      ) as base,
                      Trans_main_table as oldMain
            left join Trans_assist_table as oldAssist
                   on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
            left join uct_waste_cate as cate
                   on oldAssist.FItemID = cate.id
                where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
                  and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
                  and oldMain.FCancellation = 1
                  and oldMain.FCorrent = 1  
                  and ((oldMain.FTranType = 'SOR') or (oldMain.FTranType = 'SEL' and oldMain.FSaleStyle = 1))
                  and cate.top_class = 'waste-paper'
                  group by oldMain.FSupplyID
              ) as main
           on cus.id = main.FSupplyID 
        where cus.customer_type= 'up'
  and cus.id = p_cust_id
        GROUP BY cus.id;

set errno=1039;

update lh_dw.data_statistics_results as main,
           (select A.id,A.data_val,A.val1,B.weight,(case when B.weight = 0 then 0 else round((A.val1/B.weight),4) end) as rate,
                   B.time_val,B.time_dims,B.group1
              from lh_dw.data_statistics_results as A
         left join (select data_val,SUM(val1) as weight,base.time_val,base.time_dims,base.group1  
                      from lh_dw.data_statistics_results as C,
                           (select TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                   'M' as time_dims, 
                                   'weight-by-waste-class' as group1
                           ) as base 
                     where C.time_dims = base.time_dims 
                       and C.time_val = base.time_val 
                       and C.group1 = base.group1 
                     group by C.data_val
                   ) as B
                on A.data_val = B.data_val
             where A.time_dims = B.time_dims 
               and A.time_val = B.time_val 
               and A.group1 = B.group1 
             order by  A.data_val
           ) as detail
       set main.val2 = detail.rate * 100
     where main.time_dims = detail.time_dims
       and main.time_val = detail.time_val
       and main.group1 = detail.group1
       and main.id = detail.id;

set errno=1040;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1,  val1)
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, COALESCE(round((main.weight/1000)*1,1),0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'green-coin' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, SUM(oldAssist.FQty) as weight
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_assist_table as oldAssist
                on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
             where UNIX_TIMESTAMP(oldMain.FDate) > 1546272000
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FCorrent = 1  
               and oldMain.FSaleStyle in (0,1)
               and (oldMain.FTranType = 'SOR' or oldMain.FTranType = 'SEL')  
             group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
 
set errno=1041;


     insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1,  val1, val2) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, 
           (round(COALESCE(main.m1/1000,0)*4.2,3)) as val1, 
           COALESCE((case when main.m2 = 0 then 0 else (round((main.m1 - main.m2)/main.m2,3)) end),0) *100 as val2
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'rdf-value' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select rest.data_val,
                   sum((case when rest.time_val = base.time_val then val1 else 0 end)) as m1,
                   sum((case when rest.time_val = base.time_val2 then val1 else 0 end)) as m2
              from (select TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2   
                   ) as base,
                   lh_dw.data_statistics_results as rest
             where rest.time_dims = 'M'
               and rest.group1 = 'weight-by-waste-structure' 
               and rest.group2 = 'low-value-waste'
             group by rest.data_val
           ) as main
        on cus.id = main.data_val 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1042;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2,
           round(COALESCE(main.val1,0)/1000,3)*0 as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'cers-by-waste-class' as group1,
                   'low-value-waste' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldRes.data_val, oldRes.val1 
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val
                   ) as base,
                   lh_dw.data_statistics_results  as oldRes
             where oldRes.time_val = base.time_val 
               and oldRes.time_dims = 'M'
               and oldRes.group1 = 'weight-by-waste-structure' 
               and oldRes.group2 = 'low-value-waste' 
               group by oldRes.data_val
           ) as main
        on cus.id = main.data_val 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1043;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2,
           round(COALESCE(main.val1,0)/1000,3)*0 as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'cers-by-waste-class' as group1,
                   'glass' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldRes.data_val,oldRes.val1 
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val
                   ) as base,
                   lh_dw.data_statistics_results as oldRes
             where oldRes.time_val = base.time_val 
               and oldRes.time_dims = 'M'
               and oldRes.group1 = 'weight-by-waste-class' 
               and oldRes.group2 = 'glass' 
             group by oldRes.data_val
           ) as main
        on cus.id = main.data_val 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1044;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2,
           round(COALESCE(main.val1,0)/1000,3)*4.77 as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'cers-by-waste-class' as group1,
                   'metal' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldRes.data_val,oldRes.val1 
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val
                   ) as base,
                   lh_dw.data_statistics_results as oldRes
             where oldRes.time_val = base.time_val 
               and oldRes.time_dims = 'M'
               and oldRes.group1 = 'weight-by-waste-class' 
               and oldRes.group2 = 'metal' 
             group by oldRes.data_val
           ) as main
        on cus.id = main.data_val 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1045;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2,
           round(COALESCE(main.val1,0)/1000,3)*2.37 as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'cers-by-waste-class' as group1,
                   'plastic' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldRes.data_val,oldRes.val1 
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val
                   ) as base,
                   lh_dw.data_statistics_results as oldRes
             where oldRes.time_val = base.time_val 
               and oldRes.time_dims = 'M'
               and oldRes.group1 = 'weight-by-waste-class' 
               and oldRes.group2 = 'plastic' 
             group by oldRes.data_val
           ) as main
        on cus.id = main.data_val 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1046;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2,
           round(COALESCE(main.val1,0)/1000,3)*2.51 as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'cers-by-waste-class' as group1,
                   'waste-paper' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select oldRes.data_val,oldRes.val1 
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val
                   ) as base,
                   lh_dw.data_statistics_results as oldRes
             where oldRes.time_val = base.time_val 
               and oldRes.time_dims = 'M'
               and oldRes.group1 = 'weight-by-waste-class' 
               and oldRes.group2 = 'waste-paper' 
             group by oldRes.data_val
           ) as main
        on cus.id = main.data_val 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1047;


      insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2) 
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1,  0 as val1, 0 as val2
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'certified-emission-reduction' as group1
           ) as base,
           uct_waste_customer as cus 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1048;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1)
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, COALESCE(main.money,0) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'lw-disposal-cost' as group1
           ) as base,
           uct_waste_customer as cus 
 left join (select oldMain.FSupplyID, SUM(oldAssist.FAmount) as money
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                   ) as base,
                   Trans_main_table as oldMain
         left join Trans_assist_table as oldAssist
                on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
             where UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
               and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
               and oldMain.FCancellation = 1
               and oldMain.FCorrent = 1  
               and oldMain.FSaleStyle in (0,1)
               and (oldMain.FTranType = 'SOR' or oldMain.FTranType = 'SEL')  
               and oldAssist.value_type = 'unvaluable'
             group by oldMain.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1049;


    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2)    
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1,
           COALESCE((main.val1 - last.val1),0) as val2
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'service-cost' as group1,
                   'disposal-cost' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select detail.FSupplyID, SUM(detail.val1) as  val1
              from (select oldMain.FBillNo,oldMain.FSupplyID, base.begin_time, base.end_time, 
                           MAX(CASE oldMain."FTranType" WHEN 'SOR' THEN oldMain."FDate"
                                                WHEN 'SEL' THEN oldMain."FDate"
                                                ELSE '1970-01-01 00:00:00'
                                                END) AS maxDate,
                           COALESCE(sum(case oldMain.FTranType when 'PUR' then oldMain.TalThird else '0' end),0) as val1
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                           ) as base,
                           Trans_main_table as oldMain
                     where oldMain.FCancellation = 1
                       and oldMain.FCorrent = 1
                     group by oldMain.FBillNo
                    having UNIX_TIMESTAMP(maxDate) > base.begin_time
                       and UNIX_TIMESTAMP(maxDate) < base.end_time
                   ) as detail
             group by detail.FSupplyID
           ) as main
        on cus.id = main.FSupplyID
 left join (select rest.data_val, rest.val1 
              from (select TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2
                   ) as base,
                   lh_dw.data_statistics_results as rest
             where rest.time_dims = 'M' 
               and rest.time_val = base.time_val2 
               and rest.group1 = 'service-cost' 
               and rest.group2 = 'disposal-cost'
               group by rest.data_val
           ) as last  
        on cus.id = last.data_val 
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
 set errno=1050;
 



    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2)    
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1,
           COALESCE((main.val1 - last.val1),0) as val2
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'service-cost' as group1,
                   'transport-cost' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select detail.FSupplyID, SUM(detail.val1) as  val1
              from (select oldMain.FBillNo,oldMain.FSupplyID, base.begin_time, base.end_time, 
                           MAX(CASE oldMain."FTranType" WHEN 'SOR' THEN oldMain."FDate"
                                                WHEN 'SEL' THEN oldMain."FDate"
                                                ELSE '1970-01-01 00:00:00'
                                                END) AS maxDate,
                           COALESCE(sum(case oldMain.FTranType when 'PUR' then oldMain.TalSecond else '0' end),0) as val1
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                           ) as base,
                           Trans_main_table as oldMain
                     where oldMain.FCancellation = 1
                       and oldMain.FCorrent = 1
                     group by oldMain.FBillNo
                    having UNIX_TIMESTAMP(maxDate) > base.begin_time
                       and UNIX_TIMESTAMP(maxDate) < base.end_time
                   ) as detail
             group by detail.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
 left join (select rest.data_val, rest.val1 
              from (select TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2
                   ) as base,
                   lh_dw.data_statistics_results as rest
             where rest.time_dims = 'M' 
               and rest.time_val = base.time_val2 
               and rest.group1 = 'service-cost' 
               and rest.group2 = 'transport-cost'
             group by rest.data_val
           ) as last  
        on cus.id = last.data_val
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1052;




    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2)    
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1,
           COALESCE((main.val1 - last.val1),0) as val2
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'service-cost' as group1,
                   'consumables-cost' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select detail.FSupplyID, SUM(detail.val1) as  val1
              from (select oldMain.FBillNo,oldMain.FSupplyID, base.begin_time, base.end_time, 
                           MAX(CASE oldMain."FTranType" WHEN 'SOR' THEN oldMain."FDate"
                                                WHEN 'SEL' THEN oldMain."FDate"
                                                ELSE '1970-01-01 00:00:00'
                                                END) AS maxDate,
                           COALESCE(sum(case oldMain.FTranType when 'SOR' then oldMain.TalSecond else '0' end),0) as val1
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                           ) as base,
                           Trans_main_table as oldMain
                     where oldMain.FCancellation = 1
                       and oldMain.FCorrent = 1
                     group by oldMain.FBillNo
                    having UNIX_TIMESTAMP(maxDate) > base.begin_time
                       and UNIX_TIMESTAMP(maxDate) < base.end_time
                   ) as detail
             group by detail.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
 left join (select rest.data_val, rest.val1 
             from (select TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2
                  ) as base,
                  lh_dw.data_statistics_results as rest
            where rest.time_dims = 'M' 
              and rest.time_val = base.time_val2 
              and rest.group1 = 'service-cost' 
              and rest.group2 = 'consumables-cost'
            group by rest.data_val
           ) as last  
        on cus.id = last.data_val
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;
 
set errno=1054;




    insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2)    
    select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims, cus.id as data_val, base.stat_code, base.group1, base.group2, COALESCE(main.val1,0) as val1,
           COALESCE((main.val1 - last.val1),0) as val2
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'service-cost' as group1,
                   'sorting-cost' as group2
           ) as base,
           uct_waste_customer as cus 
 left join (select detail.FSupplyID, SUM(detail.val1) as  val1
              from (select oldMain.FBillNo,oldMain.FSupplyID, base.begin_time, base.end_time, 
                           MAX(CASE oldMain."FTranType" WHEN 'SOR' THEN oldMain."FDate"
                                                WHEN 'SEL' THEN oldMain."FDate"
                                                ELSE '1970-01-01 00:00:00'
                                                END) AS maxDate,
                           COALESCE(sum(case oldMain.FTranType when 'SOR' then oldMain.TalThird else '0' end),0) as val1
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                           ) as base,
                           Trans_main_table as oldMain
                     where oldMain.FCancellation = 1
                       and oldMain.FCorrent = 1
                     group by oldMain.FBillNo
                    having UNIX_TIMESTAMP(maxDate) > base.begin_time
                       and UNIX_TIMESTAMP(maxDate) < base.end_time
                   ) as detail
             group by detail.FSupplyID
           ) as main
        on cus.id = main.FSupplyID 
 left join (select rest.data_val, rest.val1 
              from (select TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2
                   ) as base,
                   lh_dw.data_statistics_results as rest
             where rest.time_dims = 'M' 
               and rest.time_val = base.time_val2 
               and rest.group1 = 'service-cost' 
               and rest.group2 = 'sorting-cost'
             group by rest.data_val
           ) as last  
        on cus.id = last.data_val
     where cus.customer_type = 'up'
   and cus.id = p_cust_id
     GROUP BY cus.id;

set errno=1057;




        COMMIT;

        IF errno = 1057 THEN
            "o_rv_err" := '月报表数据生成成功.';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            GET STACKED DIAGNOSTICS errno = PG_EXCEPTION_DETAIL;
            "o_rv_err" := '月报表数据生成失败: ' || SQLERRM;
    END;

END;
$$;
