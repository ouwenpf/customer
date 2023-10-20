-- 删除名为 "lh_dw_month_report" 的存储过程
DROP PROCEDURE IF EXISTS "test_lvhuan"."lh_dw_month_report"(VARCHAR(50), INOUT INTEGER, INOUT VARCHAR(200));

-- 创建名为 "lh_dw_month_report" 的存储过程
CREATE OR REPLACE PROCEDURE "test_lvhuan"."lh_dw_month_report"(IN "p_day" VARCHAR(50), INOUT io_rv INTEGER, INOUT io_err VARCHAR(200))
LANGUAGE plpgsql AS $$
DECLARE
    v_new_day VARCHAR(50);
BEGIN
    -- 初始化 io_rv
    io_rv := 0;

    -- 获取下一个月的日期
    SELECT TO_CHAR(DATE_TRUNC('MONTH', p_day::date) + INTERVAL '1 MONTH', 'YYYY-MM-DD') INTO v_new_day;

    -- 如果获取的日期为空，则设置错误信息并返回
    IF v_new_day IS NULL THEN
        io_rv := 400;
        io_err := '获取月份失败.';
        RETURN;
    END IF;

    -- 开始事务
    BEGIN

set errno=1000;

insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
select base.time_dims, base.time_val, 
       FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
       base.data_dims, main.FSupplyID as data_val, 
       base.stat_code,  base.group1, null as group2, null as txt1,
       sum(main.TalFAmount) as val1
  from Trans_main_table as main,
       (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
               UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
               TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
               'M' as time_dims, 
               '客户' as data_dims,
               'customer-monthly-report' as stat_code,
               'revenue' as group1
       ) as base
 where UNIX_TIMESTAMP(main.FDate) > base.begin_time
   and UNIX_TIMESTAMP(main.FDate) < base.end_time 
   and main.FCancellation = 1 
   and main.FTranType = 'PUR' 
GROUP BY main.FSupplyID;

set errno=1001;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
  select base.time_dims, base.time_val, 
         FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
         base.data_dims, main.FSupplyID as data_val, 
         base.stat_code,  base.group1, null as group2, null as txt1,
         sum(main.TalFQty) as val1
    from Trans_main_table as main,
         (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                 UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                 TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                 'M' as time_dims, 
                 '客户' as data_dims,
                 'customer-monthly-report' as stat_code,
                 'weight' as group1
         ) as base
   where UNIX_TIMESTAMP(main.FDate) > base.begin_time
     and UNIX_TIMESTAMP(main.FDate) < base.end_time 
     and main.FCancellation = 1 
     and main.FTranType = 'PUR' 
 GROUP BY main.FSupplyID;
 
 set errno=1002;
 
 
  insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3) 
          select det.time_dims, det.time_val,det.begin_time, det.end_time, det.data_dims, det.data_val, det.stat_code, det.group1,
               det.m1 as val1,(det.m1 - det.m2) as val2,((case when det.m2 = 0 then 0 else round((m1 - m2)/m2,4) end) * 100) as val3
          from (select A.time_dims, A.time_val,FROM_UNIXTIME(A.begin_time) as begin_time, FROM_UNIXTIME(A.end_time) as end_time, A.data_dims, A.data_val, A.stat_code, A.group1,
                         COALESCE((select SUM(TalFAmount) from Trans_main_table where FCancellation = 1 and FTranType = 'PUR' and UNIX_TIMESTAMP(FDate) > 1546272000 
                                   and UNIX_TIMESTAMP(FDate) < A.end_time and FSupplyID = A.data_val),0) as m1, 
                         COALESCE((select SUM(TalFAmount) from Trans_main_table where FCancellation = 1 and FTranType = 'PUR' and UNIX_TIMESTAMP(FDate) > 1546272000 
                                   and UNIX_TIMESTAMP(FDate) < (A.begin_time - 1) and FSupplyID = A.data_val),0) as m2 
                    from (select base.time_dims, base.time_val, base.time_val2,base.begin_time, base.end_time,base.data_dims, main.FSupplyID as data_val, 
                                   base.stat_code,  base.group1
                              from Trans_main_table as main,
                                   (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                        UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                        TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                        TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                        'M' as time_dims, 
                                        '客户' as data_dims,
                                        'customer-monthly-report' as stat_code,
                                        'cumulative-revenue' as group1
                                   ) as base
                         where UNIX_TIMESTAMP(main.FDate) > base.begin_time
                              and UNIX_TIMESTAMP(main.FDate) < base.end_time 
                              and main.FCancellation = 1 
                              and main.FTranType = 'PUR' 
                         GROUP BY main.FSupplyID
                         ) as A
               ) as det;
 
set errno=1003;
 
  
insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3) 
          select det.time_dims, det.time_val,det.begin_time, det.end_time, det.data_dims, det.data_val, det.stat_code, det.group1,
                 det.m1 as val1,(det.m1 - det.m2) as val2,((case when det.m2 = 0 then 0 else round((m1 - m2)/m2,4) end) * 100) as val3
            from (select A.time_dims, A.time_val,FROM_UNIXTIME(A.begin_time) as begin_time, FROM_UNIXTIME(A.end_time) as end_time, A.data_dims, A.data_val, A.stat_code, A.group1,
                         COALESCE((select SUM(TalFQty) from Trans_main_table where FCancellation = 1 and FTranType = 'PUR' and UNIX_TIMESTAMP(FDate) > 1546272000 
                                   and UNIX_TIMESTAMP(FDate) < A.end_time and FSupplyID = A.data_val),0) as m1, 
                         COALESCE((select SUM(TalFQty) from Trans_main_table where FCancellation = 1 and FTranType = 'PUR' and UNIX_TIMESTAMP(FDate) > 1546272000 
                                   and UNIX_TIMESTAMP(FDate) < (A.begin_time - 1) and FSupplyID = A.data_val),0) as m2 
                    from (select base.time_dims, base.time_val, base.time_val2,base.begin_time, base.end_time,base.data_dims, main.FSupplyID as data_val, 
                                   base.stat_code,  base.group1
                              from Trans_main_table as main,
                                   (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                        UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                        TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                        TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                        'M' as time_dims, 
                                        '客户' as data_dims,
                                        'customer-monthly-report' as stat_code,
                                        'cumulative-weight' as group1
                                   ) as base
                         where UNIX_TIMESTAMP(main.FDate) > base.begin_time
                              and UNIX_TIMESTAMP(main.FDate) < base.end_time 
                              and main.FCancellation = 1 
                              and main.FTranType = 'PUR' 
                         GROUP BY main.FSupplyID
                         ) as A
                 ) as det;
 
set errno=1004; 
 


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1) 
          select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, 
                 base.data_dims, main.FSupplyID as data_val, base.stat_code, base.group1, base.group2,
                    COALESCE((select SUM(oldAssist.FQty) 
                              from Trans_main_table as oldMain
                         left join Trans_assist_table as oldAssist
                              on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
                         where (oldMain.FTranType = 'SOR' or oldMain.FTranType = 'SEL')
                              and oldMain.FCancellation = 1 
                              and oldMain.FCorrent = 1
                              and oldMain.FSaleStyle in (0,1) 
                              and UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
                              and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
                              and oldAssist.value_type = 'valuable'
                              and oldMain.FSupplyID = main.FSupplyID),0) as val1
            from Trans_main_table as main,
                 (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                         'M' as time_dims, 
                         '客户' as data_dims,
                         'customer-monthly-report' as stat_code,
                         'weight-by-waste-structure' as group1,
                         'recyclable-waste' as group2
                 ) as base
           where UNIX_TIMESTAMP(main.FDate) > base.begin_time
             and UNIX_TIMESTAMP(main.FDate) < base.end_time 
             and main.FCancellation = 1 
             and main.FTranType = 'PUR' 
          GROUP BY main.FSupplyID;

set errno=1005; 


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
          select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, 
                 base.data_dims, main.FSupplyID as data_val, base.stat_code, base.group1, base.group2,
                    COALESCE((select SUM(oldAssist.FQty) 
                              from Trans_main_table as oldMain
                         left join Trans_assist_table as oldAssist
                              on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
                         where (oldMain.FTranType = 'SOR' or oldMain.FTranType = 'SEL')
                              and oldMain.FCancellation = 1 
                              and oldMain.FCorrent = 1
                              and oldMain.FSaleStyle in (0,1) 
                              and UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
                              and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
                              and oldAssist.value_type = 'unvaluable'
                              and oldMain.FSupplyID = main.FSupplyID),0) as val1
            from Trans_main_table as main,
                 (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                         'M' as time_dims, 
                         '客户' as data_dims,
                         'customer-monthly-report' as stat_code,
                         'weight-by-waste-structure' as group1,
                         'low-value-waste' as group2
                 ) as base
           where UNIX_TIMESTAMP(main.FDate) > base.begin_time
             and UNIX_TIMESTAMP(main.FDate) < base.end_time 
             and main.FCancellation = 1 
             and main.FTranType = 'PUR' 
          GROUP BY main.FSupplyID;

set errno=1006; 


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1) 
          select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, 
                 base.data_dims, main.FSupplyID as data_val, base.stat_code, base.group1, base.group2,
                    COALESCE((select SUM(oldAssist.FQty) 
                              from Trans_main_table as oldMain
                         left join Trans_assist_table as oldAssist
                              on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
                         where (oldMain.FTranType = 'SOR' or oldMain.FTranType = 'SEL')
                              and oldMain.FCancellation = 1 
                              and oldMain.FCorrent = 1
                              and oldMain.FSaleStyle in (0,1) 
                              and UNIX_TIMESTAMP(oldMain.FDate) > base.begin_time
                              and UNIX_TIMESTAMP(oldMain.FDate) < base.end_time 
                              and oldAssist.value_type = 'dangerous'
                              and oldMain.FSupplyID = main.FSupplyID),0) as val1
            from Trans_main_table as main,
                 (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                         'M' as time_dims, 
                         '客户' as data_dims,
                         'customer-monthly-report' as stat_code,
                         'weight-by-waste-structure' as group1,
                         'hazardous-waste' as group2
                 ) as base
           where UNIX_TIMESTAMP(main.FDate) > base.begin_time
             and UNIX_TIMESTAMP(main.FDate) < base.end_time 
             and main.FCancellation = 1 
             and main.FTranType = 'PUR' 
          GROUP BY main.FSupplyID;

set errno=1007;


update 
     lh_dw.data_statistics_results as main,
                  (select res.data_val, 
                          base.data_dims,
                          base.time_val,
                          base.time_dims,
                          base.stat_code,
                          base.group1,
                          base.group2,
                          sum(if(res.time_val = base.time_val,res.val1,0)) as m1, 
                          sum(if(res.time_val = base.time_val2,res.val1,0)) as m2         
                     from lh_dw.data_statistics_results as res,
                                          (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                                  UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                                  TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                                  TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                                  'M' as time_dims, 
                                                  '客户' as data_dims,
                                                  'customer-monthly-report' as stat_code,
                                                  'weight-by-waste-structure' as group1,
                                                  'recyclable-waste' as group2
                                          ) as base
                    where (res.time_val = base.time_val or res.time_val = base.time_val2) 
                      and res.stat_code = base.stat_code
                      and res.group2 = base.group2
                      and res.data_dims = base.data_dims
                 group by res.data_val,
                          base.data_dims,
                          base.time_val,
                          base.time_dims,
                          base.stat_code,
                          base.group1,
                          base.group2) as cal
    set main.val2 = if(cal.m2=0, 0, cal.m1-cal.m2)      
  where main.time_val = cal.time_val
    and main.stat_code= cal.stat_code
    and main.group2 = cal.group2
    and main.data_dims = cal.data_dims 
    and main.data_val = cal.data_val;

set errno=1008;


update 
     lh_dw.data_statistics_results as main,
                  (select res.data_val, 
                          base.data_dims,
                          base.time_val,
                          base.time_dims,
                          base.stat_code,
                          base.group1,
                          base.group2,
                          sum(if(res.time_val = base.time_val,res.val1,0)) as m1, 
                          sum(if(res.time_val = base.time_val2,res.val1,0)) as m2         
                     from lh_dw.data_statistics_results as res,
                                          (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                                  UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                                  TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                                  TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                                  'M' as time_dims, 
                                                  '客户' as data_dims,
                                                  'customer-monthly-report' as stat_code,
                                                  'weight-by-waste-structure' as group1,
                                                  'low-value-waste' as group2
                                          ) as base
                    where (res.time_val = base.time_val or res.time_val = base.time_val2) 
                      and res.stat_code = base.stat_code
                      and res.group2 = base.group2
                      and res.data_dims = base.data_dims
                 group by res.data_val,
                          base.data_dims,
                          base.time_val,
                          base.time_dims,
                          base.stat_code,
                          base.group1,
                          base.group2) as cal
    set main.val2 = if(cal.m2=0, 0, cal.m1-cal.m2)      
  where main.time_val = cal.time_val
    and main.stat_code= cal.stat_code
    and main.group2 = cal.group2
    and main.data_dims = cal.data_dims 
    and main.data_val = cal.data_val;

set errno=1009;


update 
     lh_dw.data_statistics_results as main,
                  (select res.data_val, 
                          base.data_dims,
                          base.time_val,
                          base.time_dims,
                          base.stat_code,
                          base.group1,
                          base.group2,
                          sum(if(res.time_val = base.time_val,res.val1,0)) as m1, 
                          sum(if(res.time_val = base.time_val2,res.val1,0)) as m2         
                     from lh_dw.data_statistics_results as res,
                                          (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                                  UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                                  TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                                  TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                                  'M' as time_dims, 
                                                  '客户' as data_dims,
                                                  'customer-monthly-report' as stat_code,
                                                  'weight-by-waste-structure' as group1,
                                                  'hazardous-waste' as group2
                                          ) as base
                    where (res.time_val = base.time_val or res.time_val = base.time_val2) 
                      and res.stat_code = base.stat_code
                      and res.group2 = base.group2
                      and res.data_dims = base.data_dims
                 group by res.data_val,
                          base.data_dims,
                          base.time_val,
                          base.time_dims,
                          base.stat_code,
                          base.group1,
                          base.group2) as cal
    set main.val2 = if(cal.m2=0, 0, cal.m1-cal.m2)      
  where main.time_val = cal.time_val
    and main.stat_code= cal.stat_code
    and main.group2 = cal.group2
    and main.data_dims = cal.data_dims 
    and main.data_val = cal.data_val;

set errno=1010;


update 
     lh_dw.data_statistics_results as main,
                        (select A.id,A.data_val,A.val1,B.weight,(case when B.weight = 0 then 0 else round((A.val1/B.weight),4) end) as rate,B.time_val,B.time_dims,B.group1
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


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
    select main.time_dims, main.time_val,FROM_UNIXTIME(main.begin_time) as begin_time, FROM_UNIXTIME(main.end_time) as end_time,
           main.data_dims,main.data_val,main.stat_code,main.group1, main.group2, left((MIN(det.FDate)),10) as txt1, main.val1  
      from (select base.time_dims, base.time_val,base.begin_time, base.end_time,
                   base.data_dims,A.FSupplyID as data_val,base.stat_code,base.group1, null as group2,  null as val1  
              from Trans_main_table as A,
                   (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           'M' as time_dims, 
                           '客户' as data_dims,
                           'customer-monthly-report' as stat_code,
                           'first-service-time' as group1
                   ) as base
             where A.FCancellation = 1 
               and UNIX_TIMESTAMP(A.FDate) > base.begin_time
               and UNIX_TIMESTAMP(A.FDate) < base.end_time
               and A.FTranType = 'PUR' 
             group by A.FSupplyID
           ) as main
 left join Trans_main_table as det
        on main.data_val = det.FSupplyID
       and UNIX_TIMESTAMP(det.FDate) < main.end_time
       and UNIX_TIMESTAMP(det.FDate) > 1546272000
       and det.FCancellation = 1
       and det.FTranType = 'PUR' 
       group by det.FSupplyID;
 
set errno=1012;

  
insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1, val2) 
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims,A.FSupplyID as data_val,base.stat_code,base.group1, null as group2, null as txt1, count(distinct A.FBillNo) as val1,
           (select COALESCE(SUM(Y.train_number),0) as num from Trans_main_table as X left join uct_waste_purchase as Y on X.FBillNo = Y.order_id 
                     where X.FCancellation = 1  and X.FTranType = 'PUR' and UNIX_TIMESTAMP(X.FDate) > base.begin_time 
                    and UNIX_TIMESTAMP(X.FDate) < base.end_time  and X.FSupplyID = A.FSupplyID) as val2  
      from Trans_main_table as A,
           (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'service-times' as group1
           ) as base
     where A.FCancellation = 1 
       and UNIX_TIMESTAMP(A.FDate) > base.begin_time
       and UNIX_TIMESTAMP(A.FDate) < base.end_time
       and A.FTranType = 'PUR' 
  group by A.FSupplyID;

set errno=1013;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
            select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time, base.data_dims, 
                   cus.id as data_val, base.stat_code, base.group1,main.m1 as val1, main.m2 as val2,
                   ((case when main.m2 = 0 then 0 else round((main.m1 - main.m2)/main.m2,4) end) * 100) as val3
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                           'M' as time_dims, 
                           '客户' as data_dims,
                           'customer-monthly-report' as stat_code,
                           'cumulative-service-times' as group1
                   ) as base,
                   uct_waste_customer as cus 
         left join (select count(distinct if(UNIX_TIMESTAMP(FDate) < base.end_time, FBillNo, null)) as m1,
                           count(distinct if(UNIX_TIMESTAMP(FDate) < (base.begin_time - 1), FBillNo, null)) as m2,
                           FSupplyID
                      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(now(), INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(now(), INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time
                           ) as base,
                           Trans_main_table 
                     where FCancellation = 1 
                       and FTranType = 'PUR' 
                       and UNIX_TIMESTAMP(FDate) > 1546272000
                       group by FSupplyID
                    ) as main
                on main.FSupplyID = cus.id
             where cus.customer_type = 'up'
             GROUP BY cus.id;

set errno=1014;


update 
          lh_dw.data_statistics_results as main,
                         (select A.time_dims,A.time_val,A.group1,A.data_val,(case when A.m1 = 0 then 0 else round((A.val1 - A.m1)/A.m1,3) end) as val2, (A.val1 - A.m1) as val3
                            from (select main.val1, main.time_dims, main.data_val ,main.time_val,  base.time_val2, main.group1, 
                                         COALESCE((select val1 
                                                   from lh_dw.data_statistics_results 
                                                   where time_dims = base.time_dims 
                                                   and time_val = base.time_val2
                                                   and group1 = base.group1
                                                   and data_val = main.data_val),0) as m1
                                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                              UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                              TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                              TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                              'M' as time_dims, 
                                              '客户' as data_dims,
                                              'customer-monthly-report' as stat_code,
                                              'cumulative-service-times' as group1
                                         ) as base,
                                         lh_dw.data_statistics_results as main
                                   where main.time_dims = base.time_dims 
                                     and main.time_val = base.time_val
                                     and main.group1 = base.group1) as A
                         ) as detail
     set main.val2 = detail.val2 * 100,
         main.val3 = detail.val3
   where main.time_val = detail.time_val
     and main.time_dims= detail.time_dims
     and main.group1 = detail.group1 
     and main.data_val = detail.data_val;
 
set errno=1015; 

  
insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims,A.FSupplyID as data_val,base.stat_code,base.group1, base.group2, null as txt1, 
           round(MIN(B.Tallot-B.Tcreate)/3600,1) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'order-response-time' as group1,
                   'fastest-resp-time' as group2
           ) as base,
           Trans_main_table as A
 left join Trans_log_table as B
        on A.FInterID = B.FInterID and A.FTranType = B.FTranType
     where A.FCancellation = 1 
       and UNIX_TIMESTAMP(A.FDate) > base.begin_time
       and UNIX_TIMESTAMP(A.FDate) < base.end_time
       and A.FTranType = 'PUR' 
       and B.TallotOver = 1
  group by A.FSupplyID;

set errno=1016;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims,A.FSupplyID as data_val,base.stat_code,base.group1, base.group2, null as txt1, 
           round(AVG(B.Tallot-B.Tcreate)/3600,1) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'order-response-time' as group1,
                   'average-resp-time' as group2
           ) as base,
           Trans_main_table as A
 left join Trans_log_table as B
        on A.FInterID = B.FInterID and A.FTranType = B.FTranType
     where A.FCancellation = 1 
       and UNIX_TIMESTAMP(A.FDate) > base.begin_time
       and UNIX_TIMESTAMP(A.FDate) < base.end_time
       and A.FTranType = 'PUR' 
       and B.TallotOver = 1
  group by A.FSupplyID;

set errno=1017;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims,A.FSupplyID as data_val,base.stat_code,base.group1, base.group2, null as txt1, 
           round(MAX(B.Tallot-B.Tcreate)/3600,1) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'order-response-time' as group1,
                   'slowest-resp-time' as group2
           ) as base,
           Trans_main_table as A
 left join Trans_log_table as B
        on A.FInterID = B.FInterID and A.FTranType = B.FTranType
     where A.FCancellation = 1 
       and UNIX_TIMESTAMP(A.FDate) > base.begin_time
       and UNIX_TIMESTAMP(A.FDate) < base.end_time
       and A.FTranType = 'PUR' 
       and B.TallotOver = 1
  group by A.FSupplyID;

set errno=1018;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims,A.FSupplyID as data_val,base.stat_code,base.group1, base.group2, null as txt1, 
           round((AVG(B.Tallot-B.Tcreate)+((MAX(B.Tallot-B.Tcreate)+MIN(B.Tallot-B.Tcreate)+4*AVG(B.Tallot-B.Tcreate))/3))/3600,1) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'order-response-time' as group1,
                   'plan-resp-time' as group2
           ) as base,
           Trans_main_table as A
 left join Trans_log_table as B
        on A.FInterID = B.FInterID and A.FTranType = B.FTranType
     where A.FCancellation = 1 
       and UNIX_TIMESTAMP(A.FDate) > base.begin_time
       and UNIX_TIMESTAMP(A.FDate) < base.end_time
       and A.FTranType = 'PUR' 
       and B.TallotOver = 1
  group by A.FSupplyID;

set errno=1019;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims,A.FSupplyID as data_val,base.stat_code,base.group1, base.group2, null as txt1, 
           round(MIN(B.Tpurchase-B.Tcreate)/3600,1) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'disposal-response-time' as group1,
                   'fastest-resp-time' as group2
           ) as base,
           Trans_main_table as A
 left join Trans_log_table as B
        on A.FInterID = B.FInterID and A.FTranType = B.FTranType
     where A.FCancellation = 1 
       and UNIX_TIMESTAMP(A.FDate) > base.begin_time
       and UNIX_TIMESTAMP(A.FDate) < base.end_time
       and A.FTranType = 'PUR' 
       and B.TallotOver = 1
  group by A.FSupplyID;

set errno=1020;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims,A.FSupplyID as data_val,base.stat_code,base.group1, base.group2, null as txt1, 
           round(AVG(B.Tpurchase-B.Tcreate)/3600,1) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'disposal-response-time' as group1,
                   'average-resp-time' as group2
           ) as base,
           Trans_main_table as A
 left join Trans_log_table as B
        on A.FInterID = B.FInterID and A.FTranType = B.FTranType
     where A.FCancellation = 1 
       and UNIX_TIMESTAMP(A.FDate) > base.begin_time
       and UNIX_TIMESTAMP(A.FDate) < base.end_time
       and A.FTranType = 'PUR' 
       and B.TallotOver = 1
  group by A.FSupplyID;

set errno=1021;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims,A.FSupplyID as data_val,base.stat_code,base.group1, base.group2, null as txt1, 
           round(MAX(B.Tpurchase-B.Tcreate)/3600,1) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'disposal-response-time' as group1,
                   'slowest-resp-time' as group2
           ) as base,
           Trans_main_table as A
 left join Trans_log_table as B
        on A.FInterID = B.FInterID and A.FTranType = B.FTranType
     where A.FCancellation = 1 
       and UNIX_TIMESTAMP(A.FDate) > base.begin_time
       and UNIX_TIMESTAMP(A.FDate) < base.end_time
       and A.FTranType = 'PUR' 
       and B.TallotOver = 1
  group by A.FSupplyID;

set errno=1022;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
    select base.time_dims, base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
           base.data_dims,A.FSupplyID as data_val,base.stat_code,base.group1, base.group2, null as txt1, 
           round((AVG(B.Tpurchase-B.Tcreate)+((MAX(B.Tpurchase-B.Tcreate)+MIN(B.Tpurchase-B.Tcreate)+4*AVG(B.Tpurchase-B.Tcreate))/3))/3600,1) as val1
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'disposal-response-time' as group1,
                   'plan-resp-time' as group2
           ) as base,
           Trans_main_table as A
 left join Trans_log_table as B
        on A.FInterID = B.FInterID and A.FTranType = B.FTranType
     where A.FCancellation = 1 
       and UNIX_TIMESTAMP(A.FDate) > base.begin_time
       and UNIX_TIMESTAMP(A.FDate) < base.end_time
       and A.FTranType = 'PUR' 
       and B.TallotOver = 1
  group by A.FSupplyID;

set errno=1023;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, txt1, val1, val2) 
    select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time,FROM_UNIXTIME(base.end_time) as end_time,base.data_dims,
           main.FSupplyID as data_val,base.stat_code,base.group1,cat.name,sum(det.FAmount) as money,sum(det.FQty) as weight
      from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                   'M' as time_dims, 
                   '客户' as data_dims,
                   'customer-monthly-report' as stat_code,
                   'revenue-by-waste-cate' as group1
           ) as base,
           Trans_main_table as main
 left join Trans_assist_table as det
        on main.FInterID = det.FinterID and main.FTranType = det.FTranType
 left join uct_waste_cate as cat
        on det.FItemID = cat.id
     where UNIX_TIMESTAMP(main.FDate) > base.begin_time
       and UNIX_TIMESTAMP(main.FDate) < base.end_time 
       and main.FCancellation = 1 
       and main.FTranType = 'PUR' 
       and det.value_type = 'valuable'
     GROUP BY main.FSupplyID,det.FItemID;
 

        set errno=1024;
  
        UPDATE lh_dw.data_statistics_results as a
        INNER JOIN (
            SELECT main.id, main.data_val, main.val1,
            CASE 
                WHEN curGroup=main.data_val THEN row = row + 1 
                WHEN curGroup<>main.data_val THEN row = 1 
            END AS urank,
            curGroup= main.data_val, preAge= main.val1
            FROM (
                SELECT 
                    0 as curGroup,
                    0 as preAge,
                    0 as row,
                    'revenue-by-waste-cate' as group1,
                    TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                    '客户' as data_dims
                ) as base,
                lh_dw.data_statistics_results as main
            WHERE main.group1 = base.group1
            AND main.time_val = base.time_val
            AND main.data_dims = base.data_dims
            ORDER BY main.data_val ASC, main.val1 DESC
        ) b 
        ON a.id=b.id
        SET a.val3=b.urank;
		

        set errno=1025;

        UPDATE lh_dw.data_statistics_results as a
        INNER JOIN (
            SELECT main.id, main.data_val, main.val2, 
                              CASE WHEN curGroup=main.data_val THEN row = row + 1 WHEN curGroup<>main.data_val THEN row=1 END urank,
                              curGroup= main.data_val, preAge= main.val2
                         FROM (select 0 as curGroup,
                                        0 as preAge,
                                        0 as row,
                                        'revenue-by-waste-cate' as group1,
                                        TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                        '客户' as data_dims
                              ) as base,
                              lh_dw.data_statistics_results as main
                    WHERE main.group1 = base.group1
                         AND main.time_val = base.time_val
                         AND main.data_dims = base.data_dims
                    ORDER BY main.data_val ASC, main.val2 DESC
                    ) b 
               ON a.id=b.id
        SET a.val4=b.urank;

        set errno=1026;

        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1,  val1, val2, val3) 
        SELECT base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
            base.data_dims,main.FSupplyID as data_val, base.stat_code, base.group1, 
            SUM(CASE WHEN assist.value_type IN ('valuable','unvaluable') THEN assist.FQty ELSE 0 END) as val1,
            SUM(CASE WHEN assist.value_type = 'valuable' THEN assist.FQty ELSE 0 END) as val2,
            SUM(CASE WHEN assist.value_type = 'unvaluable' THEN assist.FQty ELSE 0 END) as val3
        FROM (
            SELECT 
                UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                'M' as time_dims, 
                '客户' as data_dims,
                'customer-monthly-report' as stat_code,
                'purchase-weight' as group1
        ) as base
        JOIN Trans_main_table as main
        ON UNIX_TIMESTAMP(main.FDate) > base.begin_time
        AND UNIX_TIMESTAMP(main.FDate) < base.end_time 
        AND main.FTranType = 'PUR'
        AND main.FCancellation = 1 
        LEFT JOIN Trans_assist_table as assist
        ON main.FInterID = assist.FinterID
        AND main.FTranType = assist.FTranType
        GROUP BY base.time_dims, base.time_val, base.begin_time, base.end_time,
            base.data_dims, main.FSupplyID, base.stat_code, base.group1;

		
set errno=1027;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3, val4, val5) 
     select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
               base.data_dims,main.FSupplyID as data_val, base.stat_code, base.group1,   
               SUM(assist.FAmount) as val1,
               SUM(if(assist.FTranType = 'SOR' and assist.disposal_way = 'sorting',assist.FAmount,0)) as val2,
               SUM(if(((assist.FTranType = 'SOR' and assist.disposal_way = 'weighing') or (assist.FTranType = 'SEL')),assist.FAmount,0)) as val3,
               SUM(if(assist.FTranType = 'SOR' and assist.disposal_way = 'sorting',assist.FQty,0)) as val4,
               SUM(if(((assist.FTranType = 'SOR' and assist.disposal_way = 'weighing') or (assist.FTranType = 'SEL')),assist.FQty,0)) as val5
       from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                         'M' as time_dims, 
                         '客户' as data_dims,
                         'customer-monthly-report' as stat_code,
                         'inventory-analysis' as group1
               ) as base,
               Trans_main_table as main
   left join Trans_assist_table as assist
          on main.FInterID = assist.FinterID and main.FTranType = assist.FTranType
       where UNIX_TIMESTAMP(main.FDate) > base.begin_time
         and UNIX_TIMESTAMP(main.FDate) < base.end_time 
         and main.FCancellation = 1
         and main.FCorrent = 1  
     group by main.FSupplyID;
 
set errno=1028;

  
insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1, val2, val3) 
          select A.time_dims,A.time_val,A.begin_time, A.end_time,A.data_dims, A.data_val, A.stat_code, A.group1, A.group2, null as txt1, 
                 ((select output_value from lh_dw.data_statistics_value_interval where vice_code = 'sorting_accounted' and start_value <= A.val2 and end_value > A.val2) + 
                  (select output_value from lh_dw.data_statistics_value_interval where vice_code = 'the_unit_price' and start_value <= A.val3 and end_value > A.val3)
                 ) as val1,A.val2,A.val3
            from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, main.data_val, base.stat_code, base.group1, base.group2, null as txt1,
                         COALESCE(round((select IFNULL(val4,0)  from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'inventory-analysis' and data_val = main.data_val)/
                                      (select val1 from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'weight' and data_val = main.data_val),3),0) as val2,
                         COALESCE(round((select IFNULL(val2,0) from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'inventory-analysis' and data_val = main.data_val)/
                                      (select val4 from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'inventory-analysis' and data_val = main.data_val),3),0) as val3
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                 UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                 TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                 'M' as time_dims, 
                                 '客户' as data_dims,
                                 'customer-monthly-report' as stat_code,
                                 'customer-index' as group1,
                                 'sorting-cost' as group2
                         ) as base,
                         lh_dw.data_statistics_results as main
                   where main.time_val = base.time_val
                     and main.stat_code = 'customer-monthly-report'
                     and main.group1 = 'weight') as A;
					 
 
set errno=1029;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1, val2, val3) 
          select A.time_dims,A.time_val,A.begin_time, A.end_time,A.data_dims, A.data_val, A.stat_code, A.group1, A.group2, null as txt1, 
                 ((select output_value from lh_dw.data_statistics_value_interval where vice_code = 'first_order_time' and start_value <= A.val2 and end_value > A.val2) + 
                  (select output_value from lh_dw.data_statistics_value_interval where vice_code = 'month_output' and start_value <= A.val3 and end_value > A.val3)
                 ) as val1,A.val2,A.val3
            from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, main.data_val, base.stat_code, base.group1, base.group2, null as txt1,
                         round((UNIX_TIMESTAMP(v_new_day) - (select UNIX_TIMESTAMP(txt1) as first from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'first-service-time' and data_val = main.data_val))/86400,3) as val2,
                         (select val1 from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'weight' and data_val = main.data_val) as val3
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                 UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                 TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                 'M' as time_dims, 
                                 '客户' as data_dims,
                                 'customer-monthly-report' as stat_code,
                                 'customer-index' as group1,
                                 'trust-index' as group2
                         ) as base,
                         lh_dw.data_statistics_results as main
                   where main.time_val = base.time_val
                     and main.stat_code = 'customer-monthly-report'
                     and main.group1 = 'weight') as A;
 
set errno=1030;

insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1, val2)
     select A.time_dims,A.time_val,A.begin_time, A.end_time,A.data_dims, A.data_val, A.stat_code, A.group1, A.group2, null as txt1, 
            (select output_value from lh_dw.data_statistics_value_interval where main_code = 'service-effect' and start_value <= A.val2 and end_value > A.val2) as val1,
            A.val2
       from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                    base.data_dims, main.data_val, base.stat_code, base.group1, base.group2, null as txt1,
                    round((select  COALESCE((SUM(G.sign_out_time-G.sign_in_time)/count(E.FCancellation)),0) as num from Trans_main_table as E left join uct_waste_purchase as F on E.FBillNo = F.order_id 
                                   left join uct_purchase_sign_in_out as G on F.id = G.purchase_id where E.FCancellation = 1 and UNIX_TIMESTAMP(E.FDate) > base.begin_time 
                                   and UNIX_TIMESTAMP(E.FDate) < base.end_time and E.FTranType = 'PUR' and G.sign_in_time > 0 and G.sign_out_time > 0 and E.FSupplyID = main.data_val
                    ),2) as val2
               from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                            UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                            TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                            'M' as time_dims, 
                            '客户' as data_dims,
                            'customer-monthly-report' as stat_code,
                            'customer-index' as group1,
                            'service-effect' as group2
                    ) as base,
                    lh_dw.data_statistics_results as main
              where main.time_val = base.time_val
                and main.stat_code = 'customer-monthly-report'
                and main.group1 = 'weight') as A;

set errno=1031;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1, val2)
          select A.time_dims,A.time_val,A.begin_time, A.end_time,A.data_dims, A.data_val, A.stat_code, A.group1, A.group2, null as txt1, 
                 (select output_value from lh_dw.data_statistics_value_interval where main_code = 'load-factor' and start_value <= A.val2 and end_value > A.val2) as val1,
                 A.val2
            from (select det.time_dims,det.time_val,det.begin_time, det.end_time,det.data_dims, det.data_val, det.stat_code, det.group1, 
                         det.group2, det.txt1 as txt1,(case when det.m2 = 0 then 0 else round((m1/m2),2) end) as val2
                    from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                                 base.data_dims, main.data_val, base.stat_code, base.group1, base.group2, null as txt1,
                                 COALESCE((select val1 from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'weight' 
                                   and data_val = main.data_val),0) as m1,
                                 COALESCE((select val1 from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'service-times' 
                                   and data_val = main.data_val),0) as m2
                            from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                         'M' as time_dims, 
                                         '客户' as data_dims,
                                         'customer-monthly-report' as stat_code,
                                         'customer-index' as group1,
                                         'load-factor' as group2
                                 ) as base,
                                 lh_dw.data_statistics_results as main
                           where main.time_val = base.time_val
                             and main.stat_code = 'customer-monthly-report'
                             and main.group1 = 'weight'
                         ) as det
                 ) as A;
 
set errno=1032;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1, val2, val3) 
          select A.time_dims,A.time_val,A.begin_time, A.end_time,A.data_dims, A.data_val, A.stat_code, A.group1, A.group2, null as txt1, 
                    ((select output_value from lh_dw.data_statistics_value_interval where vice_code = 'sorting_accounted' and start_value <= A.val2 and end_value > A.val2) + 
                    (select output_value from lh_dw.data_statistics_value_interval where vice_code = 'the_unit_price' and start_value <= A.val3 and end_value > A.val3)
                    ) as val1,A.val2,A.val3
               from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, main.data_val, base.stat_code, base.group1, base.group2, null as txt1,
                         COALESCE(round((select IFNULL(val3,0)  from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'purchase-weight' and data_val = main.data_val)/
                                        (select val1 from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'weight' and data_val = main.data_val),3),0) as val2,
                         COALESCE(round((select val1 from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'purchase-weight' and data_val = main.data_val)/
                                        (select val1 from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'purchase-weight' and data_val = main.data_val),3),0) as val3
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                   'M' as time_dims, 
                                   '客户' as data_dims,
                                   'customer-monthly-report' as stat_code,
                                   'customer-index' as group1,
                                   'waste-structure' as group2
                         ) as base,
                         lh_dw.data_statistics_results as main
                    where main.time_val = base.time_val
                         and main.stat_code = 'customer-monthly-report'
                         and main.group1 = 'weight') as A;
set errno=1033;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1, val2) 
          select A.time_dims,A.time_val,A.begin_time, A.end_time,A.data_dims, A.data_val, A.stat_code, A.group1, A.group2, null as txt1, 
                    (select output_value from lh_dw.data_statistics_value_interval where main_code = 'industry-ranking' and start_value <= A.val2 and end_value >= A.val2)  as val1,A.val2
               from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, main.data_val, base.stat_code, base.group1, base.group2, null as txt1,
                         COALESCE((select SUM(val1) from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'customer-index' and data_val = main.data_val),0) as val2
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                   'M' as time_dims, 
                                   '客户' as data_dims,
                                   'customer-monthly-report' as stat_code,
                                   'customer-index' as group1,
                                   'industry-ranking' as group2
                         ) as base,
                         lh_dw.data_statistics_results as main
                    where main.time_val = base.time_val
                         and main.stat_code = 'customer-monthly-report'
                         and main.group1 = 'weight') as A;
set errno=1034;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
          select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                 base.data_dims, main.data_val, base.stat_code, base.group1, base.group2, null as txt1,
                 COALESCE((select SUM(val1) from lh_dw.data_statistics_results where time_val = base.time_val and group1 = 'customer-index' and data_val = main.data_val),0) as val1
            from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                         'M' as time_dims, 
                         '客户' as data_dims,
                         'customer-monthly-report' as stat_code,
                         'customer-index' as group1,
                         'the_overall_score' as group2
                 ) as base,
                 lh_dw.data_statistics_results as main
           where main.time_val = base.time_val
             and main.stat_code = 'customer-monthly-report'
             and main.group1 = 'weight';
 
set errno=1035;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
          select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                 base.data_dims, secondary.FSupplyID, base.stat_code, base.group1, base.group2, null as txt1, 0 as val1
            from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                         'M' as time_dims, 
                         '客户' as data_dims,
                         'customer-monthly-report' as stat_code,
                         'weight-by-waste-class' as group1,
                         'glass' as group2
                 ) as base,
                 Trans_main_table as secondary
           where UNIX_TIMESTAMP(secondary.FDate) > base.begin_time
             and UNIX_TIMESTAMP(secondary.FDate) < base.end_time 
             and secondary.FCancellation = 1 
             and secondary.FTranType = 'PUR' 
        GROUP BY secondary.FSupplyID;

set errno=1036;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
          select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                 base.data_dims, secondary.FSupplyID, base.stat_code, base.group1, base.group2, null as txt1,
                  COALESCE((select SUM(assist.FQty) from Trans_main_table as main
                       left join Trans_assist_table as assist
                              on main.FInterID = assist.FinterID and main.FTranType = assist.FTranType
                       left join uct_waste_cate as cate
                              on assist.FItemID = cate.id
                           where UNIX_TIMESTAMP(main.FDate) > base.begin_time
                             and UNIX_TIMESTAMP(main.FDate) < base.end_time 
                             and main.FCancellation = 1
                             and main.FCorrent = 1  
                             and ((main.FTranType = 'SOR') or (main.FTranType = 'SEL' and main.FSaleStyle = 1))
                             and cate.top_class = 'metal'
                             and main.FSupplyID = secondary.FSupplyID),0) as val1
            from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                         'M' as time_dims, 
                         '客户' as data_dims,
                         'customer-monthly-report' as stat_code,
                         'weight-by-waste-class' as group1,
                         'metal' as group2
                  ) as base,
                    Trans_main_table as secondary
           where UNIX_TIMESTAMP(secondary.FDate) > base.begin_time
             and UNIX_TIMESTAMP(secondary.FDate) < base.end_time 
             and secondary.FCancellation = 1 
             and secondary.FTranType = 'PUR' 
          GROUP BY secondary.FSupplyID;

set errno=1037;


 insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
          select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                 base.data_dims, secondary.FSupplyID, base.stat_code, base.group1, base.group2, null as txt1,
                  COALESCE((select SUM(assist.FQty) from Trans_main_table as main
                       left join Trans_assist_table as assist
                              on main.FInterID = assist.FinterID and main.FTranType = assist.FTranType
                       left join uct_waste_cate as cate
                              on assist.FItemID = cate.id
                           where UNIX_TIMESTAMP(main.FDate) > base.begin_time
                             and UNIX_TIMESTAMP(main.FDate) < base.end_time 
                             and main.FCancellation = 1
                             and main.FCorrent = 1  
                             and ((main.FTranType = 'SOR') or (main.FTranType = 'SEL' and main.FSaleStyle = 1))
                             and cate.top_class = 'plastic'
                             and main.FSupplyID = secondary.FSupplyID),0) as val1
            from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                         'M' as time_dims, 
                         '客户' as data_dims,
                         'customer-monthly-report' as stat_code,
                         'weight-by-waste-class' as group1,
                         'plastic' as group2
                 ) as base,
                 Trans_main_table as secondary
           where UNIX_TIMESTAMP(secondary.FDate) > base.begin_time
             and UNIX_TIMESTAMP(secondary.FDate) < base.end_time 
             and secondary.FCancellation = 1 
             and secondary.FTranType = 'PUR' 
        GROUP BY secondary.FSupplyID;

set errno=1038;

insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
          select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                 base.data_dims, secondary.FSupplyID, base.stat_code, base.group1, base.group2, null as txt1,
                  COALESCE((select SUM(assist.FQty) from Trans_main_table as main
                       left join Trans_assist_table as assist
                              on main.FInterID = assist.FinterID and main.FTranType = assist.FTranType
                       left join uct_waste_cate as cate
                              on assist.FItemID = cate.id
                           where UNIX_TIMESTAMP(main.FDate) > base.begin_time
                             and UNIX_TIMESTAMP(main.FDate) < base.end_time 
                             and main.FCancellation = 1
                             and main.FCorrent = 1  
                             and ((main.FTranType = 'SOR') or (main.FTranType = 'SEL' and main.FSaleStyle = 1))
                             and cate.top_class = 'waste-paper'
                             and main.FSupplyID = secondary.FSupplyID),0) as val1
            from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                         'M' as time_dims, 
                         '客户' as data_dims,
                         'customer-monthly-report' as stat_code,
                         'weight-by-waste-class' as group1,
                         'waste-paper' as group2
                 ) as base,
                 Trans_main_table as secondary
           where UNIX_TIMESTAMP(secondary.FDate) > base.begin_time
             and UNIX_TIMESTAMP(secondary.FDate) < base.end_time 
             and secondary.FCancellation = 1 
             and secondary.FTranType = 'PUR' 
          GROUP BY secondary.FSupplyID;

set errno=1039;

update 
          lh_dw.data_statistics_results as main,
                              (select A.id,A.data_val,A.val1,B.weight,(case when B.weight = 0 then 0 else round((A.val1/B.weight),4) end) as rate,B.time_val,B.time_dims,B.group1
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
          select det.time_dims, det.time_val,det.begin_time, det.end_time, det.data_dims, det.data_val, det.stat_code, det.group1,
                 round((det.m1/1000)*1,1) as val1
            from (select A.time_dims, A.time_val,FROM_UNIXTIME(A.begin_time) as begin_time, FROM_UNIXTIME(A.end_time) as end_time, 
                         A.data_dims, A.data_val, A.stat_code, A.group1,
                           COALESCE((select SUM(oldAssist.FQty) 
                                     from Trans_main_table as oldMain 
                                left join Trans_assist_table as oldAssist 
                                       on oldMain.FInterID = oldAssist.FinterID and oldMain.FTranType = oldAssist.FTranType
                                    where oldMain.FCancellation = 1 
                                      and oldMain.FCorrent = 1
                                      and oldMain.FSaleStyle in (0,1)
                                      and (oldMain.FTranType = 'SOR' or oldMain.FTranType = 'SEL') 
                                      and UNIX_TIMESTAMP(oldMain.FDate) > 1546272000 
                                      and UNIX_TIMESTAMP(oldMain.FDate) < A.end_time 
                                      and oldMain.FSupplyID = A.data_val),0) as m1
                      from (select base.time_dims, base.time_val, base.time_val2,base.begin_time, base.end_time,base.data_dims, main.FSupplyID as data_val, 
                                     base.stat_code,  base.group1
                                from Trans_main_table as main,
                                     (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                          UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                          'M' as time_dims, 
                                          '客户' as data_dims,
                                          'customer-monthly-report' as stat_code,
                                          'green-coin' as group1
                                     ) as base
                           where UNIX_TIMESTAMP(main.FDate) > base.begin_time
                                and UNIX_TIMESTAMP(main.FDate) < base.end_time 
                                and main.FCancellation = 1 
                                and main.FTranType = 'PUR' 
                           GROUP BY main.FSupplyID
                           ) as A
                 ) as det;
 
 
set errno=1041;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1,  val1, val2)  
          select main.time_dims,main.time_val,main.begin_time, main.end_time,main.data_dims, main.data_val, main.stat_code, main.group1, main.val1,
               (case when main.val3 = 0 then 0 else (round((main.val1 - main.val3)/val3,3)) end) as val2
          from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, A.data_val, base.stat_code, base.group1, (round((A.val1/1000)*4.2,3)) as val1, 
                         COALESCE((select val1 
                                   from lh_dw.data_statistics_results
                                   where time_val = base.time_val2
                                   and time_dims = base.time_dims
                                   and group1 = base.group1
                                   and data_val = A.data_val),0) as val3    
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                   'M' as time_dims, 
                                   '客户' as data_dims,
                                   'customer-monthly-report' as stat_code,
                                   'rdf-value' as group1
                         ) as base,
                         lh_dw.data_statistics_results as A
                    where A.time_val = base.time_val
                    and A.time_dims = base.time_dims
                    and A.group1 = 'weight-by-waste-structure'
                    and A.group2 = 'low-value-waste'
               ) as main;
 
set errno=1042;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1)  
          select main.time_dims,main.time_val,main.begin_time, main.end_time,main.data_dims, main.data_val, main.stat_code, main.group1, main.group2, main.val1
            from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, A.data_val, base.stat_code, base.group1, base.group2, (round((COALESCE(A.val1,0)/1000)*0,3)) as val1  
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                   'M' as time_dims, 
                                   '客户' as data_dims,
                                   'customer-monthly-report' as stat_code,
                                   'cers-by-waste-class' as group1,
                                   'low-value-waste' as group2
                         ) as base,
                         lh_dw.data_statistics_results as A
                   where A.time_val = base.time_val
                     and A.time_dims = base.time_dims
                     and A.group1 = 'weight-by-waste-structure'
                     and A.group2 = 'low-value-waste'
                 ) as main;

set errno=1043;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1)  
          select main.time_dims,main.time_val,main.begin_time, main.end_time,main.data_dims, main.data_val, main.stat_code, main.group1,main.group2, main.val1
            from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, A.data_val, base.stat_code, base.group1,base.group2, (round((COALESCE(A.val1,0)/1000)*0,3)) as val1  
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                   'M' as time_dims, 
                                   '客户' as data_dims,
                                   'customer-monthly-report' as stat_code,
                                   'cers-by-waste-class' as group1,
                                   'glass' as group2
                         ) as base,
                         lh_dw.data_statistics_results as A
                   where A.time_val = base.time_val
                     and A.time_dims = base.time_dims
                     and A.group1 = 'weight-by-waste-class'
                     and A.group2 = 'glass'
                 ) as main;
 
set errno=1044;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1)  
          select main.time_dims,main.time_val,main.begin_time, main.end_time,main.data_dims, main.data_val, main.stat_code, main.group1,main.group2, main.val1
            from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, A.data_val, base.stat_code, base.group1, base.group2,(round((COALESCE(A.val1,0)/1000)*4.77,3)) as val1  
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                   'M' as time_dims, 
                                   '客户' as data_dims,
                                   'customer-monthly-report' as stat_code,
                                   'cers-by-waste-class' as group1,
                                   'metal' as group2
                         ) as base,
                         lh_dw.data_statistics_results as A
                    where A.time_val = base.time_val
                    and A.time_dims = base.time_dims
                    and A.group1 = 'weight-by-waste-class'
                    and A.group2 = 'metal'
                 ) as main;
 
set errno=1045;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1)  
          select main.time_dims,main.time_val,main.begin_time, main.end_time,main.data_dims, main.data_val, main.stat_code, main.group1,main.group2, main.val1
            from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, A.data_val, base.stat_code, base.group1,base.group2, (round((COALESCE(A.val1,0)/1000)*2.37,3)) as val1  
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                   'M' as time_dims, 
                                   '客户' as data_dims,
                                   'customer-monthly-report' as stat_code,
                                   'cers-by-waste-class' as group1,
                                   'plastic' as group2
                         ) as base,
                         lh_dw.data_statistics_results as A
                    where A.time_val = base.time_val
                    and A.time_dims = base.time_dims
                    and A.group1 = 'weight-by-waste-class'
                    and A.group2 = 'plastic'
                 ) as main;
 
set errno=1046;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2,  val1)  
          select main.time_dims,main.time_val,main.begin_time, main.end_time,main.data_dims, main.data_val, main.stat_code, main.group1,main.group2, main.val1
            from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, A.data_val, base.stat_code, base.group1,base.group2, (round((COALESCE(A.val1,0)/1000)*2.51,3)) as val1  
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                   UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                   TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                   'M' as time_dims, 
                                   '客户' as data_dims,
                                   'customer-monthly-report' as stat_code,
                                   'cers-by-waste-class' as group1,
                                   'waste-paper' as group2
                         ) as base,
                         lh_dw.data_statistics_results as A
                   where A.time_val = base.time_val
                     and A.time_dims = base.time_dims
                     and A.group1 = 'weight-by-waste-class'
                     and A.group2 = 'waste-paper'
                 ) as main;

set errno=1047;


  insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2) 
          select base.time_dims, base.time_val, FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                 base.data_dims, main.FSupplyID as data_val, base.stat_code,  base.group1, 0 as val1, 0 as val2
            from Trans_main_table as main,
                 (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                         UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                         TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                         'M' as time_dims, 
                         '客户' as data_dims,
                         'customer-monthly-report' as stat_code,
                         'certified-emission-reduction' as group1
                 ) as base
           where UNIX_TIMESTAMP(main.FDate) > base.begin_time
             and UNIX_TIMESTAMP(main.FDate) < base.end_time 
             and main.FCancellation = 1 
             and main.FTranType = 'PUR' 
          GROUP BY main.FSupplyID;

set errno=1048;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1) 
          select main.time_dims,main.time_val,main.begin_time, main.end_time,main.data_dims, main.data_val, main.stat_code, main.group1, main.val1
            from (select base.time_dims,base.time_val,FROM_UNIXTIME(base.begin_time) as begin_time, FROM_UNIXTIME(base.end_time) as end_time,
                         base.data_dims, main.FSupplyID as data_val, base.stat_code, base.group1,  
                         COALESCE((select sum(assist.FAmount) 
                                   from Trans_main_table as mainOld
                              left join Trans_assist_table as assist
                                     on mainOld.FInterID = assist.FinterID and mainOld.FTranType = assist.FTranType
                                  where UNIX_TIMESTAMP(mainOld.FDate) > base.begin_time
                                    and UNIX_TIMESTAMP(mainOld.FDate) < base.end_time
                                    and assist.value_type = 'unvaluable'
                                    and mainOld.FCancellation = 1 
                                    and mainOld.FCorrent = 1
                                    and mainOld.FSaleStyle in (0,1)
                                    and (mainOld.FTranType = 'SOR' or mainOld.FTranType = 'SEL')
                                    and mainOld.FSupplyID = main.FSupplyID),0) as val1    
                    from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                 UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                 TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                 TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                 'M' as time_dims, 
                                 '客户' as data_dims,
                                 'customer-monthly-report' as stat_code,
                                 'lw-disposal-cost' as group1
                         ) as base,
                         Trans_main_table as main
                   where UNIX_TIMESTAMP(main.FDate) > base.begin_time
                     and UNIX_TIMESTAMP(main.FDate) < base.end_time 
                     and main.FCancellation = 1 
                     and main.FTranType = 'PUR' 
                    GROUP BY main.FSupplyID 
                 ) as main;
 
set errno=1049;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
     select B.time_dims,B.time_val,FROM_UNIXTIME(B.begin_time) as begin_time, FROM_UNIXTIME(B.end_time) as end_time,
            B.data_dims,B.data_val,B.stat_code,B.group1,B.group2,null as txt1,SUM(B.val1) as val1
       from (select base.time_dims,base.data_dims,base.stat_code,base.group1,base.group2,base.time_val,
                    base.begin_time,base.end_time,A.FBillNo, A.FSupplyID as data_val,
                           MAX(CASE A."FTranType" WHEN 'SOR' THEN A."FDate"
                                                  WHEN 'SEL' THEN A."FDate"
                                                  ELSE '1970-01-01 00:00:00'
                                                  END) AS maxDate,
                    sum(case A.FTranType when 'PUR' then A.TalThird else '0' end) as val1,
                    sum(case A.FTranType when 'PUR' then A.TalSecond else '0' end) as val2,
                    sum(case A.FTranType when 'SOR' then A.TalSecond else '0' end) as val3,
                    sum(case A.FTranType when 'SOR' then A.TalThird else '0' end) as val4
               from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                            UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                            TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                            'M' as time_dims, 
                            '客户' as data_dims,
                            'customer-monthly-report' as stat_code,
                            'service-cost' as group1,
                            'disposal-cost' as group2
                    ) as base,
                    Trans_main_table as A
              where A.FCancellation = 1
                and A.FCorrent = 1
                and A.FSaleStyle <> '2'
           group by A.FBillNo
             having UNIX_TIMESTAMP(maxDate) > base.begin_time
                and UNIX_TIMESTAMP(maxDate) < base.end_time
            ) as B   
   group by B.data_val;
 
 set errno=1050;
 
 
 update 
     lh_dw.data_statistics_results as main,
                  (select A.data_val,A.data_dims,A.time_val,A.time_dims,A.stat_code,A.group1,A.group2,A.val1 as m1, (if(B.val1 > 0,B.val1,0)) as m2,
                          (if(B.val1 > 0,round((A.val1 - B.val1),3),0)) as val2
                     from (select res.data_val,base.data_dims,base.time_val,base.time_val2,
                                  base.time_dims,base.stat_code,base.group1,base.group2,res.val1         
                             from lh_dw.data_statistics_results as res,
                                  (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                          UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                          'M' as time_dims, 
                                          '客户' as data_dims,
                                          'customer-monthly-report' as stat_code,
                                          'service-cost' as group1,
                                          'disposal-cost' as group2
                                  ) as base
                            where res.time_val = base.time_val  
                              and res.stat_code = base.stat_code
                              and res.group2 = base.group2
                              and res.data_dims = base.data_dims
                         group by res.data_val
                           ) as A
                left join lh_dw.data_statistics_results as B
                       on A.data_val = B.data_val
                      and B.time_val = A.time_val2
                      and B.stat_code= A.stat_code
                      and B.group2 = A.group2
                      and B.data_dims = A.data_dims 
                      and B.data_val = A.data_val
                      group by A.data_val
                 ) as cal
    set main.val2 = cal.val2      
  where main.time_val = cal.time_val
    and main.stat_code= cal.stat_code
    and main.group2 = cal.group2
    and main.data_dims = cal.data_dims 
    and main.data_val = cal.data_val;

set errno=1051;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
     select B.time_dims,B.time_val,FROM_UNIXTIME(B.begin_time) as begin_time, FROM_UNIXTIME(B.end_time) as end_time,
            B.data_dims,B.data_val,B.stat_code,B.group1,B.group2,null as txt1,SUM(B.val2) as val1
       from (select base.time_dims,base.data_dims,base.stat_code,base.group1,base.group2,base.time_val,
                    base.begin_time,base.end_time,A.FBillNo, A.FSupplyID as data_val,
                           MAX(CASE A."FTranType" WHEN 'SOR' THEN A."FDate"
                                                  WHEN 'SEL' THEN A."FDate"
                                                  ELSE '1970-01-01 00:00:00'
                                                  END) AS maxDate,
                    sum(case A.FTranType when 'PUR' then A.TalThird else '0' end) as val1,
                    sum(case A.FTranType when 'PUR' then A.TalSecond else '0' end) as val2,
                    sum(case A.FTranType when 'SOR' then A.TalSecond else '0' end) as val3,
                    sum(case A.FTranType when 'SOR' then A.TalThird else '0' end) as val4
               from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                            UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                            TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                            'M' as time_dims, 
                            '客户' as data_dims,
                            'customer-monthly-report' as stat_code,
                            'service-cost' as group1,
                            'transport-cost' as group2
                    ) as base,
                    Trans_main_table as A
              where A.FCancellation = 1
                and A.FCorrent = 1
                and A.FSaleStyle <> '2'
           group by A.FBillNo
             having UNIX_TIMESTAMP(maxDate) > base.begin_time
                and UNIX_TIMESTAMP(maxDate) < base.end_time
            ) as B   
   group by B.data_val;
 
set errno=1052;


update 
     lh_dw.data_statistics_results as main,
                  (select A.data_val,A.data_dims,A.time_val,A.time_dims,A.stat_code,A.group1,A.group2,A.val1 as m1, (if(B.val1 > 0,B.val1,0)) as m2,
                          (if(B.val1 > 0,round((A.val1 - B.val1),3),0)) as val2
                     from (select res.data_val,base.data_dims,base.time_val,base.time_val2,
                                  base.time_dims,base.stat_code,base.group1,base.group2,res.val1         
                             from lh_dw.data_statistics_results as res,
                                  (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                          UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                          'M' as time_dims, 
                                          '客户' as data_dims,
                                          'customer-monthly-report' as stat_code,
                                          'service-cost' as group1,
                                          'transport-cost' as group2
                                  ) as base
                            where res.time_val = base.time_val  
                              and res.stat_code = base.stat_code
                              and res.group2 = base.group2
                              and res.data_dims = base.data_dims
                         group by res.data_val
                           ) as A
                left join lh_dw.data_statistics_results as B
                       on A.data_val = B.data_val
                      and B.time_val = A.time_val2
                      and B.stat_code= A.stat_code
                      and B.group2 = A.group2
                      and B.data_dims = A.data_dims 
                      and B.data_val = A.data_val
                      group by A.data_val
                 ) as cal
    set main.val2 = cal.val2      
  where main.time_val = cal.time_val
    and main.stat_code= cal.stat_code
    and main.group2 = cal.group2
    and main.data_dims = cal.data_dims 
    and main.data_val = cal.data_val;

set errno=1053;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
     select B.time_dims,B.time_val,FROM_UNIXTIME(B.begin_time) as begin_time, FROM_UNIXTIME(B.end_time) as end_time,
            B.data_dims,B.data_val,B.stat_code,B.group1,B.group2,null as txt1,SUM(B.val3) as val1
       from (select base.time_dims,base.data_dims,base.stat_code,base.group1,base.group2,base.time_val,
                    base.begin_time,base.end_time,A.FBillNo, A.FSupplyID as data_val,
                           MAX(CASE A."FTranType" WHEN 'SOR' THEN A."FDate"
                                                  WHEN 'SEL' THEN A."FDate"
                                                  ELSE '1970-01-01 00:00:00'
                                                  END) AS maxDate,
                    sum(case A.FTranType when 'PUR' then A.TalThird else '0' end) as val1,
                    sum(case A.FTranType when 'PUR' then A.TalSecond else '0' end) as val2,
                    sum(case A.FTranType when 'SOR' then A.TalSecond else '0' end) as val3,
                    sum(case A.FTranType when 'SOR' then A.TalThird else '0' end) as val4
               from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                            UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                            TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                            'M' as time_dims, 
                            '客户' as data_dims,
                            'customer-monthly-report' as stat_code,
                            'service-cost' as group1,
                            'consumables-cost' as group2
                    ) as base,
                    Trans_main_table as A
              where A.FCancellation = 1
                and A.FCorrent = 1
                and A.FSaleStyle <> '2'
           group by A.FBillNo
             having UNIX_TIMESTAMP(maxDate) > base.begin_time
                and UNIX_TIMESTAMP(maxDate) < base.end_time
            ) as B   
   group by B.data_val;
 
set errno=1054;


update 
     lh_dw.data_statistics_results as main,
                  (select A.data_val,A.data_dims,A.time_val,A.time_dims,A.stat_code,A.group1,A.group2,A.val1 as m1, (if(B.val1 > 0,B.val1,0)) as m2,
                          (if(B.val1 > 0,round((A.val1 - B.val1),3),0)) as val2
                     from (select res.data_val,base.data_dims,base.time_val,base.time_val2,
                                  base.time_dims,base.stat_code,base.group1,base.group2,res.val1         
                             from lh_dw.data_statistics_results as res,
                                  (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                          UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                          'M' as time_dims, 
                                          '客户' as data_dims,
                                          'customer-monthly-report' as stat_code,
                                          'service-cost' as group1,
                                          'consumables-cost' as group2
                                  ) as base
                            where res.time_val = base.time_val  
                              and res.stat_code = base.stat_code
                              and res.group2 = base.group2
                              and res.data_dims = base.data_dims
                         group by res.data_val
                           ) as A
                left join lh_dw.data_statistics_results as B
                       on A.data_val = B.data_val
                      and B.time_val = A.time_val2
                      and B.stat_code= A.stat_code
                      and B.group2 = A.group2
                      and B.data_dims = A.data_dims 
                      and B.data_val = A.data_val
                      group by A.data_val
                 ) as cal
    set main.val2 = cal.val2      
  where main.time_val = cal.time_val
    and main.stat_code= cal.stat_code
    and main.group2 = cal.group2
    and main.data_dims = cal.data_dims 
    and main.data_val = cal.data_val;

set errno=1055;


insert into lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
    select B.time_dims,B.time_val,FROM_UNIXTIME(B.begin_time) as begin_time, FROM_UNIXTIME(B.end_time) as end_time,
           B.data_dims,B.data_val,B.stat_code,B.group1,B.group2,null as txt1,SUM(B.val4) as val1
      from (select base.time_dims,base.data_dims,base.stat_code,base.group1,base.group2,base.time_val,
                   base.begin_time,base.end_time,A.FBillNo, A.FSupplyID as data_val,
                           MAX(CASE A."FTranType" WHEN 'SOR' THEN A."FDate"
                                                  WHEN 'SEL' THEN A."FDate"
                                                  ELSE '1970-01-01 00:00:00'
                                                  END) AS maxDate,
                   sum(case A.FTranType when 'PUR' then A.TalThird else '0' end) as val1,
                   sum(case A.FTranType when 'PUR' then A.TalSecond else '0' end) as val2,
                   sum(case A.FTranType when 'SOR' then A.TalSecond else '0' end) as val3,
                   sum(case A.FTranType when 'SOR' then A.TalThird else '0' end) as val4
              from (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                           UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                           TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                           'M' as time_dims, 
                           '客户' as data_dims,
                           'customer-monthly-report' as stat_code,
                           'service-cost' as group1,
                           'sorting-cost' as group2
                   ) as base,
                   Trans_main_table as A
             where A.FCancellation = 1
               and A.FCorrent = 1
               and A.FSaleStyle <> '2'
          group by A.FBillNo
            having UNIX_TIMESTAMP(maxDate) > base.begin_time
               and UNIX_TIMESTAMP(maxDate) < base.end_time
           ) as B   
  group by B.data_val;

set errno=1056;


update 
     lh_dw.data_statistics_results as main,
                  (select A.data_val,A.data_dims,A.time_val,A.time_dims,A.stat_code,A.group1,A.group2,A.val1 as m1, (if(B.val1 > 0,B.val1,0)) as m2,
                          (if(B.val1 > 0,round((A.val1 - B.val1),3),0)) as val2
                     from (select res.data_val,base.data_dims,base.time_val,base.time_val2,
                                  base.time_dims,base.stat_code,base.group1,base.group2,res.val1         
                             from lh_dw.data_statistics_results as res,
                                  (select UNIX_TIMESTAMP(TO_CHAR(DATE_SUB(v_new_day, INTERVAL 1 MONTH), '%Y-%m-01 00:00:00')) as begin_time,
                                          UNIX_TIMESTAMP(TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m-%d 23:59:59')) as end_time,
                                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 1 MONTH)), '%Y-%m') as time_val,
                                          TO_CHAR(LAST_DAY(DATE_SUB(v_new_day, INTERVAL 2 MONTH)), '%Y-%m') as time_val2,
                                          'M' as time_dims, 
                                          '客户' as data_dims,
                                          'customer-monthly-report' as stat_code,
                                          'service-cost' as group1,
                                          'sorting-cost' as group2
                                  ) as base
                            where res.time_val = base.time_val  
                              and res.stat_code = base.stat_code
                              and res.group2 = base.group2
                              and res.data_dims = base.data_dims
                         group by res.data_val
                           ) as A
                left join lh_dw.data_statistics_results as B
                       on A.data_val = B.data_val
                      and B.time_val = A.time_val2
                      and B.stat_code= A.stat_code
                      and B.group2 = A.group2
                      and B.data_dims = A.data_dims 
                      and B.data_val = A.data_val
                      group by A.data_val
                 ) as cal
    set main.val2 = cal.val2      
  where main.time_val = cal.time_val
    and main.stat_code= cal.stat_code
    and main.group2 = cal.group2
    and main.data_dims = cal.data_dims 
    and main.data_val = cal.data_val;

set errno=1057;


 
 
 

        COMMIT;

        -- 设置成功的消息
        IF  errno = 1057 THEN
            io_rv := 200;
            io_err := '月报表数据生成成功.';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            -- 如果出现异常，回滚事务
            ROLLBACK;

            -- 获取异常的消息
            io_err := SQLERRM;
    END;
END;
$$;
