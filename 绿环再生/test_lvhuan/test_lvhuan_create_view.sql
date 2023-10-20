CREATE OR REPLACE FUNCTION substring_index(varchar, varchar, integer)
RETURNS varchar AS $$
DECLARE
tokens varchar[];
length integer ;
indexnum integer;
BEGIN
tokens := pg_catalog.string_to_array($1, $2);
length := pg_catalog.array_upper(tokens, 1);
indexnum := length - ($3 * -1) + 1;
IF $3 >= 0 THEN
RETURN pg_catalog.array_to_string(tokens[1:$3], $2);
ELSE
RETURN pg_catalog.array_to_string(tokens[indexnum:length], $2);
END IF;
END;
$$ IMMUTABLE STRICT LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION sysdate() RETURNS timestamp AS 
$$ 
BEGIN
    RETURN current_timestamp;
END;
$$ 
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_catalog.sysdate() RETURNS timestamp AS $$ select timeofday()::timestamp(0) ; $$ LANGUAGE sql VOLATILE PARALLEL SAFE;



CREATE OR REPLACE FUNCTION pg_catalog.text_numeric_gt (text, numeric) RETURNS bool AS 'select $1 > $2::text' LANGUAGE sql IMMUTABLE STRICT PARALLEL safe;
CREATE  OPERATOR pg_catalog.>     (LEFTARG = text, RIGHTARG = numeric, PROCEDURE = text_numeric_gt, COMMUTATOR = '<=' );


DROP VIEW IF EXISTS `test_lvhuan`.`accoding_all_sel`;
CREATE VIEW `test_lvhuan`.`accoding_all_sel` as select `branch`.`name` AS `分部归属`,if((`main`.`FDate` like '1970%'),'-',`main`.`FDate`) AS `销售日期`,concat(`cum`.`name`,'#',`main`.`FBillNo`) AS `订单号`,`admin`.`nickname` AS `销售负责人`,'销售出库' AS `销售方式`,`main`.`TalFQty` AS `销售总净重`,`main`.`TalFAmount` AS `销售总金额`,ifnull(`main`.`TalFrist`,0) AS `太空包费用`,ifnull(`main`.`TalSecond`,0) AS `其他收支`,(case `main`.`FCancellation` when '1' then '正常' when '0' then '已取消' end) AS `有效状态`,(case `main`.`FCorrent` when '1' then '已完成' when '0' then '未完成' end) AS `订单状态` from (((`test_lvhuan`.`trans_main_table` `main` join `test_lvhuan`.`uct_branch` `branch`) join `test_lvhuan`.`uct_waste_customer` `cum`) join `test_lvhuan`.`uct_admin` `admin`) where ((`main`.`FTranType` = 'SEL') and (`main`.`FBillNo` like '20%') and (`main`.`FRelateBrID` = `branch`.`setting_key`) and (`main`.`FSupplyID` = `cum`.`id`) and (`main`.`FSaleStyle` = 2) and (`admin`.`id` = `main`.`FEmpID`) and (`main`.`FRelateBrID` <> 7)) union all select `branch`.`name` AS `分部归属`,if((`main`.`FDate` like '1970%'),'-',`main`.`FDate`) AS `销售日期`,concat(`cum`.`name`,'#',`main`.`FBillNo`) AS `订单号`,`admin`.`nickname` AS `销售负责人`,'直销' AS `销售方式`,`main`.`TalFQty` AS `销售总净重`,`main`.`TalFAmount` AS `销售总金额`,ifnull(`main`.`TalFrist`,0) AS `太空包费用`,ifnull(`main`.`TalSecond`,0) AS `其他收支`,(case `main`.`FCancellation` when '1' then '正常' when '0' then '已取消' end) AS `有效状态`,(case `main`.`FCorrent` when '1' then '已完成' when '0' then '未完成' end) AS `订单状态` from (((`test_lvhuan`.`trans_main_table` `main` join `test_lvhuan`.`uct_branch` `branch`) join `test_lvhuan`.`uct_waste_customer` `cum`) join `test_lvhuan`.`uct_admin` `admin`) where ((`main`.`FRelateBrID` = `branch`.`setting_key`) and (`main`.`FSupplyID` = `cum`.`id`) and (`admin`.`id` = `main`.`FEmpID`) and (`main`.`FTranType` = 'SEL') and (`main`.`FRelateBrID` <> 7) and (`main`.`FSaleStyle` = '1') and (`main`.`FBillNo` like '20%'));


DROP VIEW IF EXISTS `test_lvhuan`.`accoding_stock_cate`;
CREATE VIEW `test_lvhuan`.`accoding_stock_cate` as select `c2`.`branch_id` AS `FRelateBrID`,concat('LH',`w`.`id`) AS `FStockID`,`c2`.`id` AS `FItemID`,(case `c2`.`state` when '1' then `c2`.`name` when '0' then concat('【禁用】',`c2`.`name`) end) AS `name` from (`test_lvhuan`.`uct_waste_cate` `c2` join `test_lvhuan`.`uct_waste_warehouse` `w`) where ((not(`c2`.`parent_id` in (select `c`.`id` AS `id` from `test_lvhuan`.`uct_waste_cate` `c` where (`c`.`parent_id` = 0)))) and (`c2`.`parent_id` <> 0) and (`w`.`branch_id` = `c2`.`branch_id`) and (`w`.`parent_id` = 0) and (`w`.`state` = 1));


DROP VIEW IF EXISTS `test_lvhuan`.`accoding_cargo_in`;
CREATE VIEW `test_lvhuan`.`accoding_cargo_in` as select `p`.`branch_id` AS `branch_id`,concat(`c`.`name`,'#',`p`.`order_id`) AS `order_id`,`test_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,`ac`.`name` AS `name`,`test_lvhuan`.`trans_assist_table`.`disposal_way` AS `disposal_way`,`test_lvhuan`.`trans_assist_table`.`FQty` AS `FQty`,`test_lvhuan`.`trans_assist_table`.`FPrice` AS `FPrice`,`test_lvhuan`.`trans_assist_table`.`FAmount` AS `FAmount`,`test_lvhuan`.`trans_assist_table`.`FDCTime` AS `FDCTime` from (((`test_lvhuan`.`trans_assist_table` join `test_lvhuan`.`uct_waste_purchase` `p`) join `test_lvhuan`.`uct_waste_customer` `c`) join `test_lvhuan`.`accoding_stock_cate` `ac`) where ((`test_lvhuan`.`trans_assist_table`.`FTranType` = 'SOR') and (`test_lvhuan`.`trans_assist_table`.`FDCTime` like '%2019%') and (`test_lvhuan`.`trans_assist_table`.`FinterID` = `p`.`id`) and (`p`.`customer_id` = `c`.`id`) and (`ac`.`FItemID` = `test_lvhuan`.`trans_assist_table`.`FItemID`) and (`p`.`branch_id` <> 7));

DROP VIEW IF EXISTS `test_lvhuan`.`accoding_cargo_out`;
CREATE VIEW `test_lvhuan`.`accoding_cargo_out` as select `p`.`branch_id` AS `branch_id`,concat(`c`.`name`,'#',`p`.`order_id`) AS `order_id`,`test_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,`ac`.`name` AS `name`,`test_lvhuan`.`trans_assist_table`.`FQty` AS `FQty`,`test_lvhuan`.`trans_assist_table`.`FPrice` AS `FPrice`,`test_lvhuan`.`trans_assist_table`.`FAmount` AS `FAmount`,`test_lvhuan`.`trans_assist_table`.`FDCTime` AS `FDCTime` from (((`test_lvhuan`.`trans_assist_table` join `test_lvhuan`.`uct_waste_sell` `p`) join `test_lvhuan`.`uct_waste_customer` `c`) join `test_lvhuan`.`accoding_stock_cate` `ac`) where ((`test_lvhuan`.`trans_assist_table`.`FTranType` = 'SEL') and (`test_lvhuan`.`trans_assist_table`.`FDCTime` like '%2019%') and (`test_lvhuan`.`trans_assist_table`.`FinterID` = `p`.`id`) and (`p`.`customer_id` = `c`.`id`) and (`ac`.`FItemID` = `test_lvhuan`.`trans_assist_table`.`FItemID`) and (`p`.`branch_id` <> 7) and isnull(length(`p`.`purchase_id`)) and (`p`.`state` <> 'cancel'));


DROP VIEW IF EXISTS `test_lvhuan`.`accoding_stock_dif`;
CREATE VIEW `test_lvhuan`.`accoding_stock_dif` as select `acc_base`.`FRelateBrID` AS `FRelateBrID`,concat('LH',`acc_base`.`FStockID`) AS `FStockID`,`acc_base`.`cate_id` AS `FItemID`,`test_lvhuan`.`uct_cate_account`.`account_num` AS `FdifQty`,date_format(from_unixtime(`acc_base`.`FdifTime`),'%Y-%m-%d %H:%i:%s') AS `FdifTime` from (((select `test_lvhuan`.`uct_cate_account`.`branch_id` AS `FRelateBrID`,`test_lvhuan`.`uct_cate_account`.`warehouse_id` AS `FStockID`,`test_lvhuan`.`uct_cate_account`.`cate_id` AS `cate_id`,max(`test_lvhuan`.`uct_cate_account`.`createtime`) AS `FdifTime` from `test_lvhuan`.`uct_cate_account` group by `test_lvhuan`.`uct_cate_account`.`cate_id`,`test_lvhuan`.`uct_cate_account`.`warehouse_id`)) `acc_base` join `test_lvhuan`.`uct_cate_account`) where ((`test_lvhuan`.`uct_cate_account`.`cate_id` = `acc_base`.`cate_id`) and (`test_lvhuan`.`uct_cate_account`.`createtime` = `acc_base`.`FdifTime`) and (`test_lvhuan`.`uct_cate_account`.`warehouse_id` = `acc_base`.`FStockID`));


DROP VIEW IF EXISTS `test_lvhuan`.`accoding_stock_iod`;
CREATE VIEW `test_lvhuan`.`accoding_stock_iod` as select `test_lvhuan`.`uct_waste_cate`.`branch_id` AS `FRelateBrID`,concat('LH',`test_lvhuan`.`uct_waste_warehouse`.`id`) AS `FStockID`,`test_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,round(ifnull((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_assist_table`.`FQty` else 0 end),0),1) AS `FDCQty`,round(ifnull((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SEL' then `test_lvhuan`.`trans_assist_table`.`FQty` else 0 end),0),1) AS `FSCQty`,'0' AS `FdifQty`,date_format(`test_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d %H:%i:%s') AS `FDCTime` from (((`test_lvhuan`.`trans_assist_table` join `test_lvhuan`.`trans_main_table`) join `test_lvhuan`.`uct_waste_cate`) join `test_lvhuan`.`uct_waste_warehouse`) where ((`test_lvhuan`.`trans_main_table`.`FSaleStyle` <> 1) and (`test_lvhuan`.`trans_main_table`.`FCancellation` = 1) and (`test_lvhuan`.`trans_assist_table`.`FinterID` = `test_lvhuan`.`trans_main_table`.`FInterID`) and (`test_lvhuan`.`trans_assist_table`.`FTranType` = `test_lvhuan`.`trans_main_table`.`FTranType`) and ((`test_lvhuan`.`trans_assist_table`.`FDCTime` >= curdate()) or (`test_lvhuan`.`trans_assist_table`.`red_ink_time` >= curdate())) and (`test_lvhuan`.`trans_assist_table`.`FItemID` = `test_lvhuan`.`uct_waste_cate`.`id`) and (`test_lvhuan`.`uct_waste_cate`.`branch_id` = `test_lvhuan`.`uct_waste_warehouse`.`branch_id`) and (`test_lvhuan`.`uct_waste_warehouse`.`parent_id` = 0) and (`test_lvhuan`.`uct_waste_warehouse`.`state` = 1)) union all select `test_lvhuan`.`uct_cate_account`.`branch_id` AS `FRelateBrID`,concat('LH',`test_lvhuan`.`uct_cate_account`.`warehouse_id`) AS `FStockID`,`test_lvhuan`.`uct_cate_account`.`cate_id` AS `FItemID`,'0' AS `FDCQty`,'0' AS `FSCQty`,(`test_lvhuan`.`uct_cate_account`.`before_account_num` - `test_lvhuan`.`uct_cate_account`.`account_num`) AS `FdifQty`,date_format(from_unixtime(`test_lvhuan`.`uct_cate_account`.`createtime`),'%Y-%m-%d %H:%i:%s') AS `FDCTime` from `test_lvhuan`.`uct_cate_account` where (date_format(from_unixtime(`test_lvhuan`.`uct_cate_account`.`createtime`),'%Y-%m-%d %H:%i:%s') > curdate()) union all select `test_lvhuan`.`accoding_stock_history`.`FRelateBrID` AS `FRelateBrID`,`test_lvhuan`.`accoding_stock_history`.`FStockID` AS `FStockID`,`test_lvhuan`.`accoding_stock_history`.`FItemID` AS `FItemID`,`test_lvhuan`.`accoding_stock_history`.`FDCQty` AS `FDCQty`,`test_lvhuan`.`accoding_stock_history`.`FSCQty` AS `FSCQty`,`test_lvhuan`.`accoding_stock_history`.`FdifQty` AS `FdifQty`,`test_lvhuan`.`accoding_stock_history`.`FDCTime` AS `FDCTime` from `test_lvhuan`.`accoding_stock_history`;

DROP VIEW IF EXISTS `test_lvhuan`.`accoding_stock_cur`;
CREATE VIEW `test_lvhuan`.`accoding_stock_cur` as select `stoc`.`FRelateBrID` AS `FRelateBrID`,`stoc`.`FStockID` AS `FStockID`,`stoc`.`FItemID` AS `FItemID`,`stoc`.`name` AS `name`,ifnull(`stoiod`.`FDCQty`,0) AS `FDCQty`,ifnull(`stoiod`.`FSCQty`,0) AS `FSCQty` from (`test_lvhuan`.`accoding_stock_cate` `stoc` left join `test_lvhuan`.`accoding_stock_iod` `stoiod` on(((convert(`stoc`.`FStockID` using utf8) = `stoiod`.`FStockID`) and (`stoc`.`FItemID` = `stoiod`.`FItemID`) and (date_format(`stoiod`.`FDCTime`,'%Y-%m-%d') = '2019-03-29')))) group by `stoc`.`FStockID`,`stoc`.`FItemID`;


DROP VIEW IF EXISTS `test_lvhuan`.`check_orderdata`;
CREATE VIEW `test_lvhuan`.`check_orderdata` as select `main`.`FRelateBrID` AS `FRelateBrID`,`main`.`FInterID` AS `FInterID`,`main`.`FTranType` AS `FTranType`,`main`.`FDate` AS `FDate`,concat('#',`main`.`FBillNo`) AS `FBillNo`,`main`.`FDCStockID` AS `FDCStockID`,`main`.`FSCStockID` AS `FSCStockID`,`main`.`FFManagerID` AS `FFManagerID`,`main`.`FSaleStyle` AS `FSaleStyle`,`main`.`FPOStyle` AS `FPOStyle`,`main`.`FPOPrecent` AS `FPOPrecent`,`main`.`TalFQty` AS `TalFQty`,`main`.`TalFAmount` AS `TalFAmount`,`main`.`TalFrist` AS `TalFrist`,`main`.`TalSecond` AS `TalSecond`,`main`.`TalThird` AS `TalThird`,`main`.`TalForth` AS `TalForth` from (((select `main`.`FBillNo` AS `FBillNo` from `test_lvhuan`.`trans_main_table` `main` where ((`main`.`FDate` like '2019-06-04%') and ((`main`.`FTranType` = 'SOR') or (`main`.`FTranType` = 'SEL')) and (`main`.`FRelateBrID` = 1) and (`main`.`FCancellation` = 1)))) `ord` join `test_lvhuan`.`trans_main_table` `main`) where (`ord`.`FBillNo` = `main`.`FBillNo`);


DROP VIEW IF EXISTS `test_lvhuan`.`check_queruturn`;
CREATE VIEW `test_lvhuan`.`check_queruturn` as select `cq`.`id` AS `id`,`cq`.`admin_id` AS `admin_id`,`cq`.`branch_id` AS `branch_id`,`cq`.`company_name` AS `company_name`,`cq`.`liasion` AS `liasion`,`cq`.`location_name` AS `location_name`,`cq`.`position` AS `position`,`cq`.`createtime` AS `createtime`,`cq`.`updatetime` AS `updatetime` from (select `cq`.`id` AS `id`,`cq`.`admin_id` AS `admin_id`,`cq`.`branch_id` AS `branch_id`,`cq`.`company_name` AS `company_name`,`cq`.`phone` AS `phone`,`cq`.`liasion` AS `liasion`,max(`cq`.`location_name`) AS `location_name`,`cq`.`position` AS `position`,`cq`.`createtime` AS `createtime`,`cq`.`updatetime` AS `updatetime` from `test_lvhuan`.`uct_customer_question` `cq` where ((`cq`.`branch_id` <> 7) and (`cq`.`branch_id` <> 0)) group by `cq`.`phone` having (max(`cq`.`location_name`) = '')) `cq` where (not(`cq`.`id` in (select `test_lvhuan`.`uct_customer_question_item`.`question_id` from `test_lvhuan`.`uct_customer_question_item`)));



DROP VIEW IF EXISTS `test_lvhuan`.`customer_item_analyse`;
CREATE VIEW `test_lvhuan`.`customer_item_analyse` as select `test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`test_lvhuan`.`trans_main_table`.`FSupplyID` AS `FSupplyID`,date_format(`test_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m') AS `FDate`,`test_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,sum(`test_lvhuan`.`trans_assist_table`.`FQty`) AS `FQty`,sum(`test_lvhuan`.`trans_assist_table`.`FAmount`) AS `FAmount` from (`test_lvhuan`.`trans_main_table` join `test_lvhuan`.`trans_assist_table`) where ((`test_lvhuan`.`trans_main_table`.`FCorrent` = '1') and (`test_lvhuan`.`trans_main_table`.`FCancellation` = '1') and (`test_lvhuan`.`trans_assist_table`.`FinterID` = `test_lvhuan`.`trans_main_table`.`FInterID`) and (`test_lvhuan`.`trans_assist_table`.`FTranType` = `test_lvhuan`.`trans_main_table`.`FTranType`) and (`test_lvhuan`.`trans_main_table`.`FTranType` <> 'PUR') and (`test_lvhuan`.`trans_main_table`.`FSaleStyle` <> '2') and (not((`test_lvhuan`.`trans_main_table`.`FDate` like '1970%')))) group by date_format(`test_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m'),`test_lvhuan`.`trans_main_table`.`FSupplyID`,`test_lvhuan`.`trans_assist_table`.`FItemID`;


DROP VIEW IF EXISTS `test_lvhuan`.`customer_month_analyse`;
CREATE VIEW `test_lvhuan`.`customer_month_analyse` as select `test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`test_lvhuan`.`trans_main_table`.`FSupplyID` AS `FSupplyID`,date_format(`test_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m') AS `Month`,count(`test_lvhuan`.`trans_main_table`.`FInterID`) AS `OrderNum`,sum(`test_lvhuan`.`trans_main_table`.`TalFQty`) AS `TalFQty`,sum(`test_lvhuan`.`trans_main_table`.`TalFAmount`) AS `TalFAmount` from `test_lvhuan`.`trans_main_table` where ((`test_lvhuan`.`trans_main_table`.`FSaleStyle` <> '2') and (`test_lvhuan`.`trans_main_table`.`FTranType` <> 'PUR') and (not((`test_lvhuan`.`trans_main_table`.`FDate` like '1970%'))) and (`test_lvhuan`.`trans_main_table`.`FCancellation` = '1') and (`test_lvhuan`.`trans_main_table`.`FCorrent` = '1')) group by `test_lvhuan`.`trans_main_table`.`FSupplyID`,date_format(`test_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m');


DROP VIEW IF EXISTS `test_lvhuan`.`datawall_carbonparm`;
CREATE VIEW `test_lvhuan`.`datawall_carbonparm` as select `aa`.`branch_id` AS `branch_id`,round((sum((`aa`.`FQty` * `test_lvhuan`.`uct_waste_cate`.`carbon_parm`)) / 1000),3) AS `carbon_parm`,date_format(`aa`.`FDCTime`,'%Y-%m-%d') AS `FDCTime` from (((select `test_lvhuan`.`uct_waste_cate`.`branch_id` AS `branch_id`,`test_lvhuan`.`uct_waste_cate`.`parent_id` AS `parent_id`,`test_lvhuan`.`trans_assist_table`.`FQty` AS `FQty`,`test_lvhuan`.`trans_assist_table`.`FDCTime` AS `FDCTime` from (`test_lvhuan`.`trans_assist_table` join `test_lvhuan`.`uct_waste_cate`) where ((`test_lvhuan`.`trans_assist_table`.`FTranType` = 'SOR') and (`test_lvhuan`.`trans_assist_table`.`FItemID` = `test_lvhuan`.`uct_waste_cate`.`id`)))) `aa` join `test_lvhuan`.`uct_waste_cate`) where ((`test_lvhuan`.`uct_waste_cate`.`id` = `aa`.`parent_id`) and (date_format(`aa`.`FDCTime`,'%Y-%m-%d') >= (curdate() - interval 6 day))) group by date_format(`aa`.`FDCTime`,'%Y-%m-%d'),`aa`.`branch_id`;


DROP VIEW IF EXISTS `test_lvhuan`.`save_mysqlorder_1`;
CREATE VIEW `test_lvhuan`.`save_mysqlorder_1` as select `test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,(case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_main_table`.`FDCStockID` when 'SEL' then `test_lvhuan`.`trans_main_table`.`FSCStockID` else NULL end) AS `FStockID`,`test_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,round(ifnull((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_assist_table`.`FQty` else 0 end),0),1) AS `FDCQty`,round(ifnull((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SEL' then `test_lvhuan`.`trans_assist_table`.`FQty` else 0 end),0),1) AS `FSCQty`,'0' AS `FdifQty`,date_format(`test_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d %H:%i:%s') AS `FDCTime` from (`test_lvhuan`.`trans_assist_table` join `test_lvhuan`.`trans_main_table`) where ((`test_lvhuan`.`trans_main_table`.`FSaleStyle` <> 1) and (`test_lvhuan`.`trans_main_table`.`FCancellation` = 1) and (`test_lvhuan`.`trans_assist_table`.`FinterID` = `test_lvhuan`.`trans_main_table`.`FInterID`) and (`test_lvhuan`.`trans_assist_table`.`FTranType` = `test_lvhuan`.`trans_main_table`.`FTranType`) and (`test_lvhuan`.`trans_assist_table`.`FDCTime` >= curdate())) union all select `test_lvhuan`.`uct_cate_account`.`branch_id` AS `FRelateBrID`,concat('LH',`test_lvhuan`.`uct_cate_account`.`warehouse_id`) AS `FStockID`,`test_lvhuan`.`uct_cate_account`.`cate_id` AS `FItemID`,'0' AS `FDCQty`,'0' AS `FSCQty`,(`test_lvhuan`.`uct_cate_account`.`before_account_num` - `test_lvhuan`.`uct_cate_account`.`account_num`) AS `FdifQty`,date_format(from_unixtime(`test_lvhuan`.`uct_cate_account`.`createtime`),'%Y-%m-%d %H:%i:%s') AS `FDCTime` from `test_lvhuan`.`uct_cate_account` union all select `base`.`FRelateBrID` AS `FRelateBrID`,`base`.`FStockID` AS `FStockID`,`base`.`FItemID` AS `FItemID`,round(sum(ifnull(`base`.`FDCQty`,0)),1) AS `FDCQty`,round(sum(ifnull(`base`.`FSCQty`,0)),1) AS `FSCQty`,'0' AS `FdifQty`,date_format(concat(date_format(`base`.`FDCTime`,'%Y-%m-%d'),' 23:59:59'),'%Y-%m-%d %H:%i:%s') AS `FDCTime` from (select `test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,(case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_main_table`.`FDCStockID` when 'SEL' then `test_lvhuan`.`trans_main_table`.`FSCStockID` else NULL end) AS `FStockID`,`test_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,(case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_assist_table`.`FQty` else 0 end) AS `FDCQty`,(case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SEL' then `test_lvhuan`.`trans_assist_table`.`FQty` else 0 end) AS `FSCQty`,`test_lvhuan`.`trans_assist_table`.`FDCTime` AS `FDCTime` from (`test_lvhuan`.`trans_assist_table` join `test_lvhuan`.`trans_main_table`) where ((`test_lvhuan`.`trans_assist_table`.`FinterID` = `test_lvhuan`.`trans_main_table`.`FInterID`) and (`test_lvhuan`.`trans_assist_table`.`FTranType` = `test_lvhuan`.`trans_main_table`.`FTranType`) and (`test_lvhuan`.`trans_main_table`.`FSaleStyle` <> 1) and (`test_lvhuan`.`trans_main_table`.`FCancellation` = 1) and (`test_lvhuan`.`trans_assist_table`.`FDCTime` < curdate()))) `base` group by `base`.`FStockID`,`base`.`FItemID`,date_format(`base`.`FDCTime`,'%Y-%m-%d') having (`base`.`FStockID` is not null);


DROP VIEW IF EXISTS `test_lvhuan`.`test_1`;
CREATE VIEW `test_lvhuan`.`test_1` as select `send`.`branch_id` AS `branch_id`,`send`.`send_count` AS `send_count`,ifnull(`get`.`get_count`,0) AS `get_count`,ifnull(`get`.`item1`,0) AS `item1`,ifnull(`get`.`item2`,0) AS `item2`,ifnull(`get`.`item3`,0) AS `item3`,ifnull(`get`.`item4`,0) AS `item4`,ifnull(`get`.`item5`,0) AS `item5`,ifnull(`get`.`item6`,0) AS `item6`,ifnull(`get`.`item7`,0) AS `item7`,ifnull(`get`.`csi`,0) AS `CSI` from (((select `cq`.`branch_id` AS `branch_id`,count(distinct `cq`.`phone`) AS `send_count` from `test_lvhuan`.`uct_customer_question` `cq` where ((`cq`.`branch_id` <> 7) and (`cq`.`branch_id` <> 0)) group by `cq`.`branch_id`)) `send` left join ((select `cq`.`branch_id` AS `branch_id`,count(distinct `cq`.`phone`) AS `get_count`,round((sum(`cqg`.`item1`) / count(`cqg`.`question_id`)),2) AS `item1`,round((sum(`cqg`.`item2`) / count(`cqg`.`question_id`)),2) AS `item2`,round((sum(`cqg`.`item3`) / count(`cqg`.`question_id`)),2) AS `item3`,round((sum(`cqg`.`item4`) / count(`cqg`.`question_id`)),2) AS `item4`,round((sum(`cqg`.`item5`) / count(`cqg`.`question_id`)),2) AS `item5`,round((sum(`cqg`.`item6`) / count(`cqg`.`question_id`)),2) AS `item6`,round((sum(`cqg`.`item7`) / count(`cqg`.`question_id`)),2) AS `item7`,round((sum(`cqg`.`csi`) / count(`cqg`.`question_id`)),2) AS `csi` from ((`test_lvhuan`.`uct_customer_question` `cq` join `test_lvhuan`.`uct_customer_question_item` `cqi`) join `test_lvhuan`.`uct_customer_question_grade` `cqg`) where ((`cq`.`branch_id` <> 7) and (`cq`.`branch_id` <> 0) and (`cq`.`id` = `cqi`.`question_id`) and (`cq`.`id` = `cqg`.`question_id`)) group by `cq`.`branch_id`)) `get` on((`send`.`branch_id` = `get`.`branch_id`)));

DROP VIEW IF EXISTS `test_lvhuan`.`test_3`;
CREATE VIEW `test_lvhuan`.`test_3` as select `cq`.`id` AS `id`,`cq`.`admin_id` AS `admin_id`,`cq`.`branch_id` AS `branch_id`,`cq`.`company_name` AS `company_name`,`cq`.`liasion` AS `liasion`,`cq`.`location_name` AS `location_name`,`cq`.`position` AS `position`,`cq`.`createtime` AS `createtime`,`cq`.`updatetime` AS `updatetime` from (((select `cq`.`id` AS `id`,`cq`.`admin_id` AS `admin_id`,`cq`.`branch_id` AS `branch_id`,`cq`.`company_name` AS `company_name`,`cq`.`phone` AS `phone`,`cq`.`liasion` AS `liasion`,max(`cq`.`location_name`) AS `location_name`,`cq`.`position` AS `position`,`cq`.`createtime` AS `createtime`,`cq`.`updatetime` AS `updatetime` from `test_lvhuan`.`uct_customer_question` `cq` where ((`cq`.`branch_id` <> 7) and (`cq`.`branch_id` <> 0)) group by `cq`.`phone`)) `cq` join `test_lvhuan`.`uct_customer_question_item` `item`) where (`cq`.`id` = `item`.`question_id`);


CREATE VIEW `test_lvhuan`.`accoding_stock` AS
SELECT
    `stoc`.`FRelateBrID` AS `FRelateBrID`,
    `stoc`.`FStockID` AS `FStockID`,
    `stoc`.`FItemID` AS `FItemID`,
    `stoc`.`name` AS `name`,
    IF(
        (IFNULL(UNIX_TIMESTAMP(`stodif`.`FdifTime`), '0') > UNIX_TIMESTAMP(NOW())),
        (
            (
                (
                    (IFNULL(`stodif`.`FdifQty`, 0) - IFNULL(SUM(`stoiod`.`FDCQty`), 0))
                    + IFNULL(SUM(`stoiod`.`FSCQty`), 0)
                )
                + IFNULL(SUM(`stoiod`.`FdifQty`), 0)
            )
        ),
        (
            (IFNULL(`stodif`.`FdifQty`, 0) + IFNULL(SUM(`stoiod`.`FDCQty`), 0))
            - IFNULL(SUM(`stoiod`.`FSCQty`), 0)
        )
    ) AS `FQty`,
    IFNULL(`stodif`.`FdifTime`, 0) AS `Fdiftime`
FROM
    (
        (`test_lvhuan`.`accoding_stock_cate` `stoc`
        LEFT JOIN `test_lvhuan`.`accoding_stock_dif` `stodif`
        ON ((`stoc`.`FStockID` = `stodif`.`FStockID`) AND (`stoc`.`FItemID` = `stodif`.`FItemID`))
        )
        LEFT JOIN `test_lvhuan`.`accoding_stock_iod` `stoiod`
        ON (
            (CONVERT(`stoc`.`FStockID` USING utf8) = `stoiod`.`FStockID`)
            AND (`stoc`.`FItemID` = `stoiod`.`FItemID`)
            AND IF(
                (IFNULL(UNIX_TIMESTAMP(`stodif`.`FdifTime`), '0') > UNIX_TIMESTAMP(NOW())),
                (
                    UNIX_TIMESTAMP(`stoiod`.`FDCTime`)
                    BETWEEN (UNIX_TIMESTAMP(NOW()) + 1)
                    AND IFNULL(UNIX_TIMESTAMP(`stodif`.`FdifTime`), '0')
                ),
                (
                    UNIX_TIMESTAMP(`stoiod`.`FDCTime`)
                    BETWEEN IFNULL((UNIX_TIMESTAMP(`stodif`.`FdifTime`) + 1), '0')
                    AND UNIX_TIMESTAMP(NOW())
                )
            )
        )
    )
GROUP BY `stoc`.`FStockID`, `stoc`.`FItemID`;



DROP VIEW IF EXISTS `test_lvhuan`.`test_5`;
CREATE VIEW `test_lvhuan`.`test_5` as select `main`.`FRelateBrID` AS `FRelateBrID`,max((case `main`.`FTranType` when 'SOR' then `main`.`FDate` when 'SEL' then `main`.`FDate` else '1970-01-01 00:00:00' end)) AS `FDate`,`main`.`FBillNo` AS `FBillNo`,max((case `main`.`FTranType` when 'PUR' then `main`.`FSupplyID` else '0' end)) AS `FSupplyID`,max((case `main`.`FTranType` when 'PUR' then `main`.`FDeptID` else '0' end)) AS `FDeptID`,max((case `main`.`FTranType` when 'PUR' then `main`.`FEmpID` else '0' end)) AS `FEmpID`,sum((case `main`.`FTranType` when 'PUR' then '0' else `main`.`TalFQty` end)) AS `TalFQty`,sum((case `main`.`FTranType` when 'PUR' then ((((-(`main`.`TalFAmount`) - `main`.`TalFrist`) - `main`.`TalSecond`) - `main`.`TalThird`) - `main`.`TalForth`) when 'SOR' then (((`main`.`TalFAmount` - `main`.`TalFrist`) - `main`.`TalSecond`) - `main`.`TalThird`) when 'SEL' then ((`main`.`TalFAmount` - `main`.`TalFrist`) - `main`.`TalSecond`) else '0' end)) AS `TalProfit` from `test_lvhuan`.`trans_main_table` `main` where ((`main`.`FCancellation` = 1) and (`main`.`FCorrent` = 1) and (`main`.`FSaleStyle` <> 2)) group by `main`.`FBillNo`;


DROP VIEW IF EXISTS `test_lvhuan`.`test_7`;
CREATE VIEW `test_lvhuan`.`test_7` AS
SELECT
    `ad`.`id` AS `id`,
    `ad`.`crmid` AS `crmid`,
    `ad`.`username` AS `username`,
    `ad`.`nickname` AS `nickname`,
    `cus`.`name` AS `name`
FROM (
    (SELECT `test_lvhuan`.`uct_admin`.`id` AS `id`,
            `test_lvhuan`.`uct_admin`.`crmid` AS `crmid`,
            `test_lvhuan`.`uct_admin`.`username` AS `username`,
            `test_lvhuan`.`uct_admin`.`nickname` AS `nickname`
     FROM `test_lvhuan`.`uct_admin`) `ad`
    JOIN
    (SELECT `test_lvhuan`.`uct_waste_customer`.`id` AS `id`,
            CAST(`test_lvhuan`.`uct_waste_customer`.`admin_id` AS bigint) AS `admin_id`,  -- 这里进行了类型转换
            `test_lvhuan`.`uct_waste_customer`.`name` AS `name`,
            `test_lvhuan`.`uct_waste_customer`.`customer_type` AS `customer_type`
     FROM `test_lvhuan`.`uct_waste_customer`) `cus`
) 
WHERE (`ad`.`id` = `cus`.`admin_id`::bigint)  -- 这里也进行了类型转换
AND (`cus`.`customer_type` = 'up');



DROP VIEW IF EXISTS `test_lvhuan`.`test_8`;
CREATE VIEW `test_lvhuan`.`test_8` as select `pur`.`branch_id` AS `branch_id`,`pur`.`hand_mouth_data` AS `hand_mouth_data`,`pur`.`order_id` AS `order_id`,`pur`.`purchase_incharge` AS `purchase_incharge` from (`test_lvhuan`.`uct_waste_purchase` `pur` join `test_lvhuan`.`trans_log_table` `log`) where ((`pur`.`id` = `log`.`FInterID`) and ((`log`.`TpurchaseOver` - `log`.`TpayOver`) >= '1'));


DROP VIEW IF EXISTS `test_lvhuan`.`test_9`;
CREATE VIEW `test_lvhuan`.`test_9` as select `test_lvhuan`.`uct_branch`.`name` AS `分部归属`,concat(`test_lvhuan`.`uct_waste_customer`.`customer_code`,'#',`er`.`FBillNo`) AS `订单号`,`er`.`FDate` AS `采购日期`,(case `er`.`FSaleStyle` when '1' then '直销' when '0' then '采购回库' when '3' then '送框' end) AS `采购类型`,`ad1`.`nickname` AS `采购负责人`,`er`.`pur_FQty` AS `采购总净重`,`er`.`sor_FQty` AS `分拣总净重`,(case `er`.`FCorrent` when '1' then '已完成' when '0' then '未完成' end) AS `订单状态`,(case `er`.`FNowState` when 'draft' then '草稿' when 'wait_allot' then '待分配' when 'wait_receive_order' then '待接单' when 'wait_apply_materiel' then '待申请辅材' when 'wait_pick_materiel' then '待提取辅材' when 'wait_signin_materiel' then '待签收辅材' when 'wait_pick_cargo' then '待提货' when 'wait_pay' then '待付款' when 'wait_storage_connect' then '待入库交接' when 'wait_storage_connect_confirm' then '待确认交接' when 'wait_storage_sort' then '待分拣入库' when 'wait_storage_confirm' then '待入库确认' when 'wait_return_fee' then '待订单报销' when 'wait_confirm_return_fee' then '待审核订单' when 'finish' then '交易完成' end) AS `订单具体状态`,(case `er`.`FNowState` when 'wait_receive_order' then `ad1`.`nickname` when 'wait_apply_materiel' then `ad1`.`nickname` when 'wait_signin_materiel' then `ad1`.`nickname` when 'wait_pick_cargo' then `ad1`.`nickname` when 'wait_storage_connect_confirm' then `ad1`.`nickname` when 'wait_storage_confirm' then `ad1`.`nickname` when 'wait_return_fee' then `ad1`.`nickname` when 'wait_storage_connect' then '仓库主管' when 'wait_pick_materiel' then '仓库主管' when 'wait_confirm_return_fee' then '财务' when 'wait_storage_sort' then `ad2`.`nickname` else '' end) AS `责任部门／人` from ((((((select max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`FDate` else '1970-01-01' end)) AS `FDate`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_main_table`.`FDate` else '1970-01-01' end)) AS `FDate2`,`test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`test_lvhuan`.`trans_main_table`.`FBillNo` AS `FBillNo`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`FSupplyID` else '0' end)) AS `FSupplyID`,`test_lvhuan`.`trans_main_table`.`FSaleStyle` AS `FSaleStyle`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`FEmpID` else '0' end)) AS `FEmpID`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_main_table`.`FEmpID` else '0' end)) AS `FSmpID`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `pur_FQty`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`TalFAmount` else '0' end)) AS `pur_TalFAmount`,sum((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`TalFrist` else '0' end)) AS `pur_expense`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_main_table`.`TalFQty` when 'SEL' then `test_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `sor_FQty`,`test_lvhuan`.`trans_main_table`.`FCorrent` AS `FCorrent`,`test_lvhuan`.`trans_main_table`.`FCancellation` AS `FCancellation`,`test_lvhuan`.`trans_main_table`.`FNowState` AS `FNowState` from `test_lvhuan`.`trans_main_table` where (`test_lvhuan`.`trans_main_table`.`FSaleStyle` <> 2) group by `test_lvhuan`.`trans_main_table`.`FBillNo`)) `er` join `test_lvhuan`.`uct_branch`) join `test_lvhuan`.`uct_waste_customer`) join `test_lvhuan`.`uct_admin` `ad1`) left join `test_lvhuan`.`uct_admin` `ad2` on((`ad2`.`id` = `er`.`FSmpID`))) where ((`test_lvhuan`.`uct_branch`.`centre_branch_id` = 2) and (`er`.`FRelateBrID` = `test_lvhuan`.`uct_branch`.`setting_key`) and (`test_lvhuan`.`uct_waste_customer`.`id` = `er`.`FSupplyID`) and (`ad1`.`id` = `er`.`FEmpID`) and ((`test_lvhuan`.`uct_branch`.`centre_switch` = 0) or ((`test_lvhuan`.`uct_branch`.`centre_switch` = 1) and (`er`.`FDate` >= convert(date_format('2018-01-01 00:00:00','%Y-%m-%d %H:%i:%s') using utf8)))) and ((`er`.`FCorrent` = 1) or (`er`.`FCorrent` = 0)) and (`er`.`FCancellation` = 1)) order by `er`.`FCorrent` desc,`er`.`FNowState`;


DROP VIEW IF EXISTS `test_lvhuan`.`trans_total_fee_rf`;
CREATE VIEW `test_lvhuan`.`trans_total_fee_rf` as select `test_lvhuan`.`uct_waste_storage_return_fee`.`purchase_id` AS `purchase_id`,sum((case `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` when '外请车费' then `test_lvhuan`.`uct_waste_storage_return_fee`.`price` when '公司车费' then `test_lvhuan`.`uct_waste_storage_return_fee`.`price` else 0 end)) AS `car_fee`,sum((case `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` when '拉货专员人工' then `test_lvhuan`.`uct_waste_storage_return_fee`.`price` when '外请人工' then `test_lvhuan`.`uct_waste_storage_return_fee`.`price` when '拉货助理人工' then `test_lvhuan`.`uct_waste_storage_return_fee`.`price` else 0 end)) AS `man_fee`,sum((case `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` when '外请车费' then 0 when '公司车费' then 0 when '拉货专员人工' then 0 when '外请人工' then 0 when '拉货助理人工' then 0 else `test_lvhuan`.`uct_waste_storage_return_fee`.`price` end)) AS `other_return_fee` from `test_lvhuan`.`uct_waste_storage_return_fee` group by `test_lvhuan`.`uct_waste_storage_return_fee`.`purchase_id`;


DROP VIEW IF EXISTS `test_lvhuan`.`trans_total_fee_sg`;
CREATE VIEW `test_lvhuan`.`trans_total_fee_sg` as select `sfr`.`purchase_id` AS `purchase_id`,sum((case `sfr`.`usage` when '资源池分拣人工' then `sfr`.`price` when '临时工分拣人工' then `sfr`.`price` when '拉货人分拣人工' then `sfr`.`price` else 0 end)) AS `sort_fee`,sum((case `sfr`.`usage` when '耗材费-太空包' then `sfr`.`price` when '耗材费-编织袋' then `sfr`.`price` else 0 end)) AS `materiel_fee`,sum((case `sfr`.`usage` when '资源池分拣人工' then 0 when '临时工分拣人工' then 0 when '耗材费-太空包' then 0 when '耗材费-编织袋' then 0 when '拉货人分拣人工' then 0 else `sfr`.`price` end)) AS `other_sort_fee` from ((select `test_lvhuan`.`uct_waste_storage_sort_expense`.`purchase_id` AS `purchase_id`,`test_lvhuan`.`uct_waste_storage_sort_expense`.`usage` AS `usage`,`test_lvhuan`.`uct_waste_storage_sort_expense`.`price` AS `price` from `test_lvhuan`.`uct_waste_storage_sort_expense`) union all (select `test_lvhuan`.`uct_waste_storage_expense`.`purchase_id` AS `purchase_id`,`test_lvhuan`.`uct_waste_storage_expense`.`usage` AS `usage`,`test_lvhuan`.`uct_waste_storage_expense`.`price` AS `price` from `test_lvhuan`.`uct_waste_storage_expense`) union all (select `mtr`.`purchase_id` AS `purchase_id`,'耗材费-太空包' AS `usage`,sum(`mtr`.`materiel_price`) AS `price` from (select `test_lvhuan`.`uct_waste_purchase_materiel`.`purchase_id` AS `purchase_id`,((case `test_lvhuan`.`uct_waste_purchase_materiel`.`use_type` when '1' then cast(`test_lvhuan`.`uct_waste_purchase_materiel`.`pick_amount` as signed) when '0' then cast(`test_lvhuan`.`uct_waste_purchase_materiel`.`storage_amount` as signed) else 0 end) * `test_lvhuan`.`uct_waste_purchase_materiel`.`inside_price`) AS `materiel_price` from `test_lvhuan`.`uct_waste_purchase_materiel`) `mtr` group by `mtr`.`purchase_id`)) `sfr` group by `sfr`.`purchase_id`;

DROP VIEW IF EXISTS `test_lvhuan`.`trans_total_fee_pf`;
CREATE VIEW `test_lvhuan`.`trans_total_fee_pf` as select `test_lvhuan`.`uct_waste_purchase_expense`.`purchase_id` AS `purchase_id`,sum((case `test_lvhuan`.`uct_waste_purchase_expense`.`usage` when '供应商垃圾补助费' then `test_lvhuan`.`uct_waste_purchase_expense`.`price` when '供应商车辆补助费' then `test_lvhuan`.`uct_waste_purchase_expense`.`price` when '供应商人工补助费' then `test_lvhuan`.`uct_waste_purchase_expense`.`price` else 0 end)) AS `customer_profit`,sum((case `test_lvhuan`.`uct_waste_purchase_expense`.`usage` when '其他收入' then `test_lvhuan`.`uct_waste_purchase_expense`.`price` else 0 end)) AS `other_profit`,sum((case `test_lvhuan`.`uct_waste_purchase_expense`.`type` when 'out' then `test_lvhuan`.`uct_waste_purchase_expense`.`price` else 0 end)) AS `pick_fee` from `test_lvhuan`.`uct_waste_purchase_expense` group by `test_lvhuan`.`uct_waste_purchase_expense`.`purchase_id`;


DROP VIEW IF EXISTS `test_lvhuan`.`test_test_1`;
CREATE VIEW `test_lvhuan`.`test_test_1` as select `main`.`FRelateBrID` AS `分部id`,`bra`.`name` AS `分部名称`,`main`.`FBillNo` AS `订单号`,`main`.`Date` AS `年月日`,`fee`.`FFeeID` AS `费用种类`,`fee`.`FFeeAmount` AS `费用金额`,`main`.`TalFQty` AS `货品合计净重`,`main`.`TalFAmount` AS `货品合计金额` from ((`test_lvhuan`.`trans_main_table` `main` join `test_lvhuan`.`trans_fee_table` `fee`) join `test_lvhuan`.`uct_branch` `bra`) where ((`main`.`FInterID` = `fee`.`FInterID`) and (`main`.`FRelateBrID` = `bra`.`id`) and (`main`.`FTranType` = `fee`.`FTranType`)) group by `main`.`FBillNo`;

DROP VIEW IF EXISTS `test_lvhuan`.`test_user`;
CREATE VIEW `test_lvhuan`.`test_user` as select `test_lvhuan`.`uct_waste_customer`.`name` AS `name`,count(`test_lvhuan`.`uct_waste_customer`.`id`) AS `count(id)`,`test_lvhuan`.`uct_waste_customer`.`id` AS `id`,`test_lvhuan`.`uct_waste_customer`.`admin_id` AS `admin_id` from `test_lvhuan`.`uct_waste_customer` where (`test_lvhuan`.`uct_waste_customer`.`customer_type` = 'down') group by `test_lvhuan`.`uct_waste_customer`.`name` having (count(`test_lvhuan`.`uct_waste_customer`.`id`) > 1);


DROP VIEW IF EXISTS `test_lvhuan`.`accoding_all_pur`;
CREATE VIEW `test_lvhuan`.`accoding_all_pur` as select `test_lvhuan`.`uct_branch`.`name` AS `分部归属`,concat(`test_lvhuan`.`uct_waste_customer`.`name`,'#',`er`.`FBillNo`) AS `订单号`,`er`.`FDate` AS `采购日期`,if((`er`.`FinDate` like '1970-01-01%'),'-',`er`.`FinDate`) AS `确认日期`,(case `er`.`FSaleStyle` when '1' then '直销' when '0' then '采购回库' end) AS `采购方式`,`test_lvhuan`.`uct_admin`.`nickname` AS `采购负责人`,`er`.`pur_FQty` AS `采购净重`,round(`er`.`pur_TalFAmount`,2) AS `采购金额`,round(`er`.`pur_expense`,2) AS `采购费用`,`er`.`sor_FQty` AS `入库净重`,round(`er`.`profit`,2) AS `毛利润`,(case `er`.`FCancellation` when '1' then '正常' when '0' then '已取消' end) AS `有效状态`,(case `er`.`FCorrent` when '1' then '已完成' when '0' then '未完成' end) AS `订单状态` from (((((select max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`FDate` else '1970-01-01 00:00:00' end)) AS `FDate`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_main_table`.`FDate` when 'SEL' then `test_lvhuan`.`trans_main_table`.`FDate` else '1970-01-01 00:00:00' end)) AS `FinDate`,`test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`test_lvhuan`.`trans_main_table`.`FBillNo` AS `FBillNo`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`FSupplyID` else '0' end)) AS `FSupplyID`,`test_lvhuan`.`trans_main_table`.`FSaleStyle` AS `FSaleStyle`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`FEmpID` else '0' end)) AS `FEmpID`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `pur_FQty`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`TalFAmount` else '0' end)) AS `pur_TalFAmount`,sum((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `test_lvhuan`.`trans_main_table`.`TalFrist` else '0' end)) AS `pur_expense`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_main_table`.`TalFQty` when 'SEL' then `test_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `sor_FQty`,max((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `test_lvhuan`.`trans_main_table`.`FCorrent` when 'SEL' then `test_lvhuan`.`trans_main_table`.`FCorrent` else '0' end)) AS `FCorrent`,`test_lvhuan`.`trans_main_table`.`FCancellation` AS `FCancellation`,sum((case `test_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then ((((-(ifnull(`test_lvhuan`.`trans_main_table`.`TalFAmount`,0)) - ifnull(`test_lvhuan`.`trans_main_table`.`TalFrist`,0)) - ifnull(`test_lvhuan`.`trans_main_table`.`TalSecond`,0)) - ifnull(`test_lvhuan`.`trans_main_table`.`TalThird`,0)) - ifnull(`test_lvhuan`.`trans_main_table`.`TalForth`,0)) when 'SOR' then (((ifnull(`test_lvhuan`.`trans_main_table`.`TalFAmount`,0) - ifnull(`test_lvhuan`.`trans_main_table`.`TalFrist`,0)) - ifnull(`test_lvhuan`.`trans_main_table`.`TalSecond`,0)) - ifnull(`test_lvhuan`.`trans_main_table`.`TalThird`,0)) when 'SEL' then ((ifnull(`test_lvhuan`.`trans_main_table`.`TalFAmount`,0) + ifnull(`test_lvhuan`.`trans_main_table`.`TalFrist`,0)) + ifnull(`test_lvhuan`.`trans_main_table`.`TalSecond`,0)) else '0' end)) AS `profit` from `test_lvhuan`.`trans_main_table` where (`test_lvhuan`.`trans_main_table`.`FSaleStyle` <> 2) group by `test_lvhuan`.`trans_main_table`.`FBillNo`)) `er` join `test_lvhuan`.`uct_branch`) join `test_lvhuan`.`uct_waste_customer`) join `test_lvhuan`.`uct_admin`) where ((`test_lvhuan`.`uct_branch`.`setting_key` = `er`.`FRelateBrID`) and (`test_lvhuan`.`uct_waste_customer`.`id` = `er`.`FSupplyID`) and (`test_lvhuan`.`uct_admin`.`id` = `er`.`FEmpID`) and (`er`.`FBillNo` like '2021%') and (`er`.`FRelateBrID` <> 7));


DROP VIEW IF EXISTS `test_lvhuan`.`tran_total_cargo_pc`;
CREATE VIEW `test_lvhuan`.`tran_total_cargo_pc` as select `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `FInterID`,sum(`test_lvhuan`.`uct_waste_purchase_cargo`.`net_weight`) AS `FQtyTotal`,round(sum(`test_lvhuan`.`uct_waste_purchase_cargo`.`total_price`),2) AS `FAmountTotal`,'' AS `FSourceInterId`,'' AS `FSourceTranType` from `test_lvhuan`.`uct_waste_purchase_cargo` group by `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`;


DROP VIEW IF EXISTS `test_lvhuan`.`trans_fee`;
CREATE VIEW `test_lvhuan`.`trans_fee` as select `test_lvhuan`.`uct_waste_purchase_expense`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,'PC' AS `Ffeesence`,`test_lvhuan`.`uct_waste_purchase_expense`.`id` AS `FEntryID`,`test_lvhuan`.`uct_waste_purchase_expense`.`usage` AS `FFeeID`,`test_lvhuan`.`uct_waste_purchase_expense`.`type` AS `FFeeType`,`test_lvhuan`.`uct_waste_purchase_expense`.`receiver` AS `FFeePerson`,`test_lvhuan`.`uct_waste_purchase_expense`.`remark` AS `FFeeExplain`,`test_lvhuan`.`uct_waste_purchase_expense`.`price` AS `FFeeAmount`,'' AS `FFeebaseAmount`,'' AS `Ftaxrate`,'' AS `Fbasetax`,'' AS `Fbasetaxamount`,'' AS `FPriceRef`,date_format(from_unixtime(`test_lvhuan`.`uct_waste_purchase_expense`.`createtime`),'%Y-%m-%d %H:%i:%S') AS `FFeetime` from `test_lvhuan`.`uct_waste_purchase_expense` union all select `test_lvhuan`.`uct_waste_storage_return_fee`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,'RF' AS `Ffeesence`,`test_lvhuan`.`uct_waste_storage_return_fee`.`id` AS `FEntryID`,`test_lvhuan`.`uct_waste_storage_return_fee`.`usage` AS `FFeeID`,'out' AS `FFeeType`,`test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` AS `FFeePerson`,`test_lvhuan`.`uct_waste_storage_return_fee`.`remark` AS `FFeeExplain`,`test_lvhuan`.`uct_waste_storage_return_fee`.`price` AS `FFeeAmount`,'' AS `FFeebaseAmount`,'' AS `Ftaxrate`,'' AS `Fbasetax`,'' AS `Fbasetaxamount`,'' AS `FPriceRef`,date_format(from_unixtime(`test_lvhuan`.`uct_waste_storage_return_fee`.`createtime`),'%Y-%m-%d %H:%i:%S') AS `FFeetime` from `test_lvhuan`.`uct_waste_storage_return_fee` union all select `test_lvhuan`.`uct_waste_storage_expense`.`purchase_id` AS `FInterID`,'SOR' AS `FTranType`,'SO' AS `Ffeesence`,`test_lvhuan`.`uct_waste_storage_expense`.`id` AS `FEntryID`,`test_lvhuan`.`uct_waste_storage_expense`.`usage` AS `FFeeID`,'out' AS `FFeeType`,`test_lvhuan`.`uct_waste_storage_expense`.`receiver` AS `FFeePerson`,`test_lvhuan`.`uct_waste_storage_expense`.`remark` AS `FFeeExplain`,`test_lvhuan`.`uct_waste_storage_expense`.`price` AS `FFeeAmount`,'' AS `FFeebaseAmount`,'' AS `Ftaxrate`,'' AS `Fbasetax`,'' AS `Fbasetaxamount`,'' AS `FPriceRef`,date_format(from_unixtime(`test_lvhuan`.`uct_waste_storage_expense`.`createtime`),'%Y-%m-%d %H:%i:%S') AS `FFeetime` from `test_lvhuan`.`uct_waste_storage_expense` union all select `test_lvhuan`.`uct_waste_storage_sort_expense`.`purchase_id` AS `FInterID`,'SOR' AS `FTranType`,'SS' AS `Ffeesence`,`test_lvhuan`.`uct_waste_storage_sort_expense`.`id` AS `FEntryID`,`test_lvhuan`.`uct_waste_storage_sort_expense`.`usage` AS `FFeeID`,'out' AS `FFeeType`,`test_lvhuan`.`uct_waste_storage_sort_expense`.`receiver` AS `FFeePerson`,`test_lvhuan`.`uct_waste_storage_sort_expense`.`remark` AS `FFeeExplain`,`test_lvhuan`.`uct_waste_storage_sort_expense`.`price` AS `FFeeAmount`,'' AS `FFeebaseAmount`,'' AS `Ftaxrate`,'' AS `Fbasetax`,'' AS `Fbasetaxamount`,'' AS `FPriceRef`,date_format(from_unixtime(`test_lvhuan`.`uct_waste_storage_sort_expense`.`createtime`),'%Y-%m-%d %H:%i:%S') AS `FFeetime` from `test_lvhuan`.`uct_waste_storage_sort_expense` union all select `test_lvhuan`.`uct_waste_sell_other_price`.`sell_id` AS `FInterID`,'SEL' AS `FTranType`,'SL' AS `Ffeesence`,`test_lvhuan`.`uct_waste_sell_other_price`.`id` AS `FEntryID`,`test_lvhuan`.`uct_waste_sell_other_price`.`usage` AS `FFeeID`,`test_lvhuan`.`uct_waste_sell_other_price`.`type` AS `FFeeType`,`test_lvhuan`.`uct_waste_sell_other_price`.`receiver` AS `FFeePerson`,`test_lvhuan`.`uct_waste_sell_other_price`.`remark` AS `FFeeExplain`,`test_lvhuan`.`uct_waste_sell_other_price`.`price` AS `FFeeAmount`,'' AS `FFeebaseAmount`,'' AS `Ftaxrate`,'' AS `Fbasetax`,'' AS `Fbasetaxamount`,'' AS `FPriceRef`,date_format(from_unixtime(`test_lvhuan`.`uct_waste_sell_other_price`.`createtime`),'%Y-%m-%d %H:%i:%S') AS `FFeetime` from `test_lvhuan`.`uct_waste_sell_other_price`;


DROP VIEW IF EXISTS `test_lvhuan`.`trans_log`;
CREATE VIEW `test_lvhuan`.`trans_log` as select `log`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,max((case `log`.`state_value` when 'draft' then `log`.`createtime` end)) AS `TCreate`,max((case `log`.`state_value` when 'draft' then `log`.`admin_id` end)) AS `TCreatePerson`,max((case `log`.`state_value` when 'wait_allot' then '1' else '0' end)) AS `TallotOver`,max((case `log`.`state_value` when 'wait_allot' then `log`.`admin_id` else NULL end)) AS `TallotPerson`,max((case `log`.`state_value` when 'wait_allot' then `log`.`createtime` else NULL end)) AS `Tallot`,max((case `log`.`state_value` when 'wait_receive_order' then '1' else '0' end)) AS `TgetorderOver`,max((case `log`.`state_value` when 'wait_receive_order' then `log`.`admin_id` else NULL end)) AS `TgetorderPerson`,max((case `log`.`state_value` when 'wait_receive_order' then `log`.`createtime` else NULL end)) AS `Tgetorder`,max((case `log`.`state_value` when 'wait_signin_materiel' then '1' else '0' end)) AS `TmaterialOver`,max((case `log`.`state_value` when 'wait_signin_materiel' then `log`.`admin_id` else NULL end)) AS `TmaterialPerson`,max((case `log`.`state_value` when 'wait_signin_materiel' then `log`.`createtime` else NULL end)) AS `Tmaterial`,max((case `log`.`state_value` when 'wait_pick_cargo' then '1' else '0' end)) AS `TpurchaseOver`,max((case `log`.`state_value` when 'wait_pick_cargo' then `log`.`admin_id` else NULL end)) AS `TpurchasePerson`,max((case `log`.`state_value` when 'wait_pick_cargo' then `log`.`createtime` else NULL end)) AS `Tpurchase`,max((case `log`.`state_value` when 'wait_pay' then '1' else '0' end)) AS `TpayOver`,max((case `log`.`state_value` when 'wait_pay' then `log`.`admin_id` else NULL end)) AS `TpayPerson`,max((case `log`.`state_value` when 'wait_pay' then `log`.`createtime` else NULL end)) AS `Tpay`,max((case `log`.`state_value` when 'wait_storage_connect' then '1' else '0' end)) AS `TchangeOver`,max((case `log`.`state_value` when 'wait_storage_connect' then `log`.`admin_id` else NULL end)) AS `TchangePerson`,max((case `log`.`state_value` when 'wait_storage_connect' then `log`.`createtime` else NULL end)) AS `Tchange`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then '1' else '0' end)) AS `TexpenseOver`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then `log`.`admin_id` else NULL end)) AS `TexpensePerson`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then `log`.`createtime` else NULL end)) AS `Texpense`,max((case `log`.`state_value` when 'wait_storage_sort' then '1' else '0' end)) AS `TsortOver`,max((case `log`.`state_value` when 'wait_storage_sort' then `log`.`admin_id` else NULL end)) AS `TsortPerson`,max((case `log`.`state_value` when 'wait_storage_sort' then `log`.`createtime` else NULL end)) AS `Tsort`,max((case `log`.`state_value` when 'wait_storage_confirm' then '1' else '0' end)) AS `TallowOver`,max((case `log`.`state_value` when 'wait_storage_confirm' then `log`.`admin_id` else NULL end)) AS `TallowPerson`,max((case `log`.`state_value` when 'wait_storage_confirm' then `log`.`createtime` else NULL end)) AS `Tallow`,max((case `log`.`state_value` when 'finish' then '1' else '0' end)) AS `TcheckOver`,max((case `log`.`state_value` when 'finish' then `log`.`admin_id` else NULL end)) AS `TcheckPerson`,max((case `log`.`state_value` when 'finish' then `log`.`createtime` else '0' end)) AS `Tcheck`,`test_lvhuan`.`uct_waste_purchase`.`state` AS `State` from (`test_lvhuan`.`uct_waste_purchase` join `test_lvhuan`.`uct_waste_purchase_log` `log`) where ((`test_lvhuan`.`uct_waste_purchase`.`id` = `log`.`purchase_id`) and (`test_lvhuan`.`uct_waste_purchase`.`hand_mouth_data` = '0') and (`test_lvhuan`.`uct_waste_purchase`.`give_frame` = '0')) group by `test_lvhuan`.`uct_waste_purchase`.`id` union all select `log`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,max((case `log`.`state_value` when 'draft' then `log`.`createtime` end)) AS `TCreate`,max((case `log`.`state_value` when 'draft' then `log`.`admin_id` end)) AS `TCreatePerson`,max((case `log`.`state_value` when 'wait_allot' then '1' else '0' end)) AS `TallotOver`,max((case `log`.`state_value` when 'wait_allot' then `log`.`admin_id` else NULL end)) AS `TallotPerson`,max((case `log`.`state_value` when 'wait_allot' then `log`.`createtime` else NULL end)) AS `Tallot`,max((case `log`.`state_value` when 'wait_receive_order' then '1' else '0' end)) AS `TgetorderOver`,max((case `log`.`state_value` when 'wait_receive_order' then `log`.`admin_id` else NULL end)) AS `TgetorderPerson`,max((case `log`.`state_value` when 'wait_receive_order' then `log`.`createtime` else NULL end)) AS `Tgetorder`,max((case `log`.`state_value` when 'wait_signin_materiel' then '1' else '0' end)) AS `TmaterialOver`,max((case `log`.`state_value` when 'wait_signin_materiel' then `log`.`admin_id` else NULL end)) AS `TmaterialPerson`,max((case `log`.`state_value` when 'wait_signin_materiel' then `log`.`createtime` else NULL end)) AS `Tmaterial`,max((case `log`.`state_value` when 'wait_pick_cargo' then '1' else '0' end)) AS `TpurchaseOver`,max((case `log`.`state_value` when 'wait_pick_cargo' then `log`.`admin_id` else NULL end)) AS `TpurchasePerson`,max((case `log`.`state_value` when 'wait_pick_cargo' then `log`.`createtime` else NULL end)) AS `Tpurchase`,max((case `log`.`state_value` when 'wait_pay' then '1' else '0' end)) AS `TpayOver`,max((case `log`.`state_value` when 'wait_pay' then `log`.`admin_id` else NULL end)) AS `TpayPerson`,max((case `log`.`state_value` when 'wait_pay' then `log`.`createtime` else NULL end)) AS `Tpay`,max((case `log`.`state_value` when 'wait_storage_connect' then '1' else '0' end)) AS `TchangeOver`,max((case `log`.`state_value` when 'wait_storage_connect' then `log`.`admin_id` else NULL end)) AS `TchangePerson`,max((case `log`.`state_value` when 'wait_storage_connect' then `log`.`createtime` else NULL end)) AS `Tchange`,NULL AS `TexpenseOver`,NULL AS `TexpensePerson`,NULL AS `Texpense`,NULL AS `TsortOver`,NULL AS `TsortPerson`,NULL AS `Tsort`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then '1' else '0' end)) AS `TallowOver`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then `log`.`admin_id` else NULL end)) AS `TallowPerson`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then `log`.`createtime` else NULL end)) AS `Tallow`,max((case `log`.`state_value` when 'finish' then '1' else '0' end)) AS `TcheckOver`,max((case `log`.`state_value` when 'finish' then `log`.`admin_id` else NULL end)) AS `TcheckPerson`,max((case `log`.`state_value` when 'finish' then `log`.`createtime` else '0' end)) AS `Tcheck`,`test_lvhuan`.`uct_waste_purchase`.`state` AS `State` from (`test_lvhuan`.`uct_waste_purchase` join `test_lvhuan`.`uct_waste_purchase_log` `log`) where ((`test_lvhuan`.`uct_waste_purchase`.`id` = `log`.`purchase_id`) and (`test_lvhuan`.`uct_waste_purchase`.`hand_mouth_data` = '0') and (`test_lvhuan`.`uct_waste_purchase`.`give_frame` = '1')) group by `test_lvhuan`.`uct_waste_purchase`.`id` union all select `log`.`sell_id` AS `FInterID`,'SEL' AS `FTranType`,max((case `log`.`state_value` when 'draft' then `log`.`createtime` end)) AS `TCreate`,max((case `log`.`state_value` when 'draft' then `log`.`admin_id` end)) AS `TCreatePerson`,NULL AS `TallotOver`,NULL AS `TallotPerson`,NULL AS `Tallot`,NULL AS `TgetorderOver`,NULL AS `TgetorderPerson`,NULL AS `Tgetorder`,NULL AS `TmaterialOver`,NULL AS `TmaterialPerson`,NULL AS `Tmaterial`,max((case `log`.`state_value` when 'wait_weigh' then '1' else '0' end)) AS `TpurchaseOver`,max((case `log`.`state_value` when 'wait_weigh' then `log`.`admin_id` else NULL end)) AS `TpurchasePerson`,max((case `log`.`state_value` when 'wait_weigh' then `log`.`createtime` else NULL end)) AS `Tpurchase`,NULL AS `TpayOver`,NULL AS `TpayPerson`,NULL AS `Tpay`,NULL AS `TchangeOver`,NULL AS `TchangePerson`,NULL AS `Tchange`,NULL AS `TexpenseOver`,NULL AS `TexpensePerson`,NULL AS `Texpense`,NULL AS `TsortOver`,NULL AS `TsortPerson`,NULL AS `Tsort`,max((case `log`.`state_value` when 'wait_confirm_order' then '1' else '0' end)) AS `TallowOver`,max((case `log`.`state_value` when 'wait_confirm_order' then `log`.`admin_id` else NULL end)) AS `TallowPerson`,max((case `log`.`state_value` when 'wait_confirm_order' then `log`.`createtime` else NULL end)) AS `Tallow`,max((case `log`.`state_value` when 'wait_pay' then '1' else '0' end)) AS `TcheckOver`,max((case `log`.`state_value` when 'wait_pay' then `log`.`admin_id` else NULL end)) AS `TcheckPerson`,max((case `log`.`state_value` when 'wait_pay' then `log`.`createtime` else '0' end)) AS `Tcheck`,`test_lvhuan`.`uct_waste_sell`.`state` AS `State` from (`test_lvhuan`.`uct_waste_sell` join `test_lvhuan`.`uct_waste_sell_log` `log`) where ((`test_lvhuan`.`uct_waste_sell`.`id` = `log`.`sell_id`) and isnull(`test_lvhuan`.`uct_waste_sell`.`purchase_id`)) group by `test_lvhuan`.`uct_waste_sell`.`id` union all select `plog`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,max((case `plog`.`state_value` when 'draft' then `plog`.`createtime` end)) AS `TCreate`,max((case `plog`.`state_value` when 'draft' then `plog`.`admin_id` end)) AS `TCreatePerson`,max((case `plog`.`state_value` when 'wait_allot' then '1' else '0' end)) AS `TallotOver`,max((case `plog`.`state_value` when 'wait_allot' then `plog`.`admin_id` end)) AS `TallotPerson`,max((case `plog`.`state_value` when 'wait_allot' then `plog`.`createtime` end)) AS `Tallot`,max((case `slog`.`state_value` when 'wait_commit_order' then '1' else '0' end)) AS `TgetorderOver`,max((case `slog`.`state_value` when 'wait_commit_order' then `slog`.`admin_id` end)) AS `TgetorderPerson`,max((case `slog`.`state_value` when 'wait_commit_order' then `slog`.`createtime` end)) AS `Tgetorder`,max((case `plog`.`state_value` when 'wait_receive_order' then '1' else '0' end)) AS `TmaterialOver`,max((case `plog`.`state_value` when 'wait_receive_order' then `plog`.`admin_id` end)) AS `TmaterialPerson`,max((case `plog`.`state_value` when 'wait_receive_order' then `plog`.`createtime` end)) AS `Tmaterial`,max((case `plog`.`state_value` when 'wait_pick_cargo' then '1' else '0' end)) AS `TpurchaseOver`,max((case `plog`.`state_value` when 'wait_pick_cargo' then `plog`.`admin_id` else NULL end)) AS `TpurchasePerson`,max((case `plog`.`state_value` when 'wait_pick_cargo' then `plog`.`createtime` else NULL end)) AS `Tpurchase`,max((case `slog`.`state_value` when 'wait_pay' then '1' else '0' end)) AS `TpayOver`,max((case `slog`.`state_value` when 'wait_pay' then `slog`.`admin_id` else NULL end)) AS `TpayPerson`,max((case `slog`.`state_value` when 'wait_pay' then `slog`.`createtime` else NULL end)) AS `Tpay`,max((case `slog`.`state_value` when 'finish' then '1' else '0' end)) AS `TchangeOver`,max((case `slog`.`state_value` when 'finish' then `slog`.`admin_id` end)) AS `TchangePerson`,max((case `slog`.`state_value` when 'finish' then `slog`.`createtime` end)) AS `Tchange`,NULL AS `TexpenseOver`,NULL AS `TexpensePerson`,NULL AS `Texpense`,NULL AS `TsortOver`,NULL AS `TsortPerson`,NULL AS `Tsort`,max((case `plog`.`state_value` when 'wait_return_fee' then '1' else '0' end)) AS `TallowOver`,max((case `plog`.`state_value` when 'wait_return_fee' then `plog`.`admin_id` end)) AS `TallowPerson`,max((case `plog`.`state_value` when 'wait_return_fee' then `plog`.`createtime` end)) AS `Tallow`,max((case `plog`.`state_value` when 'finish' then '1' else '0' end)) AS `TcheckOver`,max((case `plog`.`state_value` when 'finish' then `plog`.`admin_id` else NULL end)) AS `TcheckPerson`,max((case `plog`.`state_value` when 'finish' then `plog`.`createtime` else '0' end)) AS `Tcheck`,`p`.`state` AS `State` from (((`test_lvhuan`.`uct_waste_sell` `s` join `test_lvhuan`.`uct_waste_sell_log` `slog`) join `test_lvhuan`.`uct_waste_purchase` `p`) join `test_lvhuan`.`uct_waste_purchase_log` `plog`) where ((`s`.`id` = `slog`.`sell_id`) and (`s`.`order_id` = `p`.`order_id`) and (`p`.`id` = `plog`.`purchase_id`) and (`slog`.`is_timeline_data` = '1')) group by `p`.`order_id`;


DROP VIEW IF EXISTS `test_lvhuan`.`trans_materiel`;
CREATE VIEW `test_lvhuan`.`trans_materiel` as select `mel`.`FInterID` AS `FInterID`,`mel`.`FTranType` AS `FTranType`,`mel`.`FEntryID` AS `FEntryID`,`mel`.`FMaterielID` AS `FMaterielID`,`mel`.`FUseCount` AS `FUseCount`,round(`mel`.`FPrice`,2) AS `FPrice`,round((`mel`.`FUseCount` * `mel`.`FPrice`),2) AS `FMeterielAmount`,`mel`.`FMeterieltime` AS `FMeterieltime` from (select `test_lvhuan`.`uct_waste_purchase_materiel`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,`test_lvhuan`.`uct_waste_purchase_materiel`.`id` AS `FEntryID`,`test_lvhuan`.`uct_waste_purchase_materiel`.`materiel_id` AS `FMaterielID`,cast(`test_lvhuan`.`uct_waste_purchase_materiel`.`storage_amount` as signed) AS `FUseCount`,`test_lvhuan`.`uct_waste_purchase_materiel`.`inside_price` AS `FPrice`,`test_lvhuan`.`uct_waste_purchase_materiel`.`updatetime` AS `FMeterieltime` from `test_lvhuan`.`uct_waste_purchase_materiel` where (`test_lvhuan`.`uct_waste_purchase_materiel`.`use_type` = 0) union all select `test_lvhuan`.`uct_waste_purchase_materiel`.`purchase_id` AS `FInterID`,'SOR' AS `FTranType`,`test_lvhuan`.`uct_waste_purchase_materiel`.`id` AS `FEntryID`,`test_lvhuan`.`uct_waste_purchase_materiel`.`materiel_id` AS `FMaterielID`,(cast(`test_lvhuan`.`uct_waste_purchase_materiel`.`pick_amount` as signed) - cast(`test_lvhuan`.`uct_waste_purchase_materiel`.`storage_amount` as signed)) AS `FUseCount`,`test_lvhuan`.`uct_waste_purchase_materiel`.`inside_price` AS `FPrice`,`test_lvhuan`.`uct_waste_purchase_materiel`.`updatetime` AS `FMeterieltime` from `test_lvhuan`.`uct_waste_purchase_materiel` where (`test_lvhuan`.`uct_waste_purchase_materiel`.`use_type` = 1) union all select `test_lvhuan`.`uct_waste_sell_materiel`.`sell_id` AS `FInterID`,'SEL' AS `FTranType`,`test_lvhuan`.`uct_waste_sell_materiel`.`id` AS `FEntryID`,`test_lvhuan`.`uct_waste_sell_materiel`.`materiel_id` AS `FMaterielID`,`test_lvhuan`.`uct_waste_sell_materiel`.`pick_amount` AS `FUseCount`,`test_lvhuan`.`uct_waste_sell_materiel`.`unit_price` AS `FPrice`,`test_lvhuan`.`uct_waste_sell_materiel`.`updatetime` AS `FMeterieltime` from `test_lvhuan`.`uct_waste_sell_materiel`) `mel` group by `mel`.`FInterID`,`mel`.`FTranType`,`mel`.`FMaterielID`;



DROP VIEW IF EXISTS `test_lvhuan`.`trans_materiel_total`;
CREATE VIEW `test_lvhuan`.`trans_materiel_total` as select `test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,sum((case `test_lvhuan`.`uct_materiel`.`name` when '分类箱' then `test_lvhuan`.`trans_materiel_table`.`FUseCount` else 0 end)) AS `FUseCount_flx`,sum((case `test_lvhuan`.`uct_materiel`.`name` when '太空包' then `test_lvhuan`.`trans_materiel_table`.`FUseCount` else 0 end)) AS `FUseCount_tkb`,sum((case `test_lvhuan`.`uct_materiel`.`name` when '编织袋' then `test_lvhuan`.`trans_materiel_table`.`FUseCount` else 0 end)) AS `FUseCount_bzd`,date_format(from_unixtime(`test_lvhuan`.`trans_materiel_table`.`FMeterieltime`),'%Y-%m-%d') AS `FMeterieltime` from ((`test_lvhuan`.`trans_materiel_table` join `test_lvhuan`.`trans_main_table`) join `test_lvhuan`.`uct_materiel`) where ((`test_lvhuan`.`trans_materiel_table`.`FInterID` = `test_lvhuan`.`trans_main_table`.`FInterID`) and (`test_lvhuan`.`trans_materiel_table`.`FMaterielID` = `test_lvhuan`.`uct_materiel`.`id`)) group by `test_lvhuan`.`trans_materiel_table`.`FInterID`;


DROP VIEW IF EXISTS `test_lvhuan`.`view_warehouse_collect`;
CREATE VIEW `test_lvhuan`.`view_warehouse_collect` as select `test_lvhuan`.`uct_waste_warehouse`.`id` AS `id`,`test_lvhuan`.`uct_waste_warehouse`.`name` AS `name` from `test_lvhuan`.`uct_waste_warehouse` where (`test_lvhuan`.`uct_waste_warehouse`.`parent_id` = 0);

DROP VIEW IF EXISTS `test_lvhuan`.`view_valid_sell`;
CREATE VIEW `test_lvhuan`.`view_valid_sell` as select `test_lvhuan`.`uct_waste_sell_log`.`sell_id` AS `sell_id` from `test_lvhuan`.`uct_waste_sell_log` where ((`test_lvhuan`.`uct_waste_sell_log`.`state_value` = 'wait_confirm_order') and (`test_lvhuan`.`uct_waste_sell_log`.`state_text` = '待付款'));


DROP VIEW IF EXISTS `test_lvhuan`.`view_valid_purchase`;
CREATE VIEW `test_lvhuan`.`view_valid_purchase` as select `m`.`FRelateBrID` AS `FRelateBrID`,`m`.`FInterID` AS `FInterID`,date_format(`m`.`FDate`,'%Y-%m-%d') AS `FDate`,`m`.`FBillNo` AS `FBillNo`,`m`.`FSupplyID` AS `FSupplyID`,`m`.`Fbusiness` AS `Fbusiness`,`m`.`FEmpID` AS `FEmpID`,`m`.`FSaleStyle` AS `FSaleStyle`,`m`.`FCancellation` AS `FCancellation` from (`test_lvhuan`.`trans_main_table` `m` join (select `m1`.`FBillNo` AS `FBillNo` from `test_lvhuan`.`trans_main_table` `m1` where ((`m1`.`FCorrent` = 1) and (`m1`.`FTranType` = 'SOR')) union all select `m2`.`FBillNo` AS `FBillNo` from `test_lvhuan`.`trans_main_table` `m2` where ((`m2`.`FStatus` = 1) and (`m2`.`FTranType` = 'SEL') and (`m2`.`FSaleStyle` = 1))) `s`) where ((`m`.`FTranType` = 'PUR') and (`m`.`FBillNo` = `s`.`FBillNo`));

DROP VIEW IF EXISTS `test_lvhuan`.`view_first_sort`;
CREATE VIEW `test_lvhuan`.`view_first_sort` as select `test_lvhuan`.`uct_waste_cate`.`id` AS `id`,`test_lvhuan`.`uct_waste_cate`.`name` AS `name` from `test_lvhuan`.`uct_waste_cate` where (`test_lvhuan`.`uct_waste_cate`.`parent_id` = 0);



DROP VIEW IF EXISTS `test_lvhuan`.`view_third_sort`;
CREATE VIEW `test_lvhuan`.`view_third_sort` as select `view_change_sort`.`id` AS `id`,`view_change_sort`.`parent_id` AS `parent_id`,`view_change_sort`.`name` AS `name`,`view_change_sort`.`branch_id` AS `branch_id` from (select `test_lvhuan`.`uct_waste_cate`.`id` AS `id`,`test_lvhuan`.`uct_waste_cate`.`parent_id` AS `parent_id`,`test_lvhuan`.`uct_waste_cate`.`name` AS `name`,`test_lvhuan`.`uct_waste_cate`.`branch_id` AS `branch_id` from `test_lvhuan`.`uct_waste_cate` where (`test_lvhuan`.`uct_waste_cate`.`parent_id` <> 0)) `view_change_sort` where (not(exists(select `view_first_sort`.`id` from `test_lvhuan`.`view_first_sort` where (`view_first_sort`.`id` = `view_change_sort`.`parent_id`))));


DROP VIEW IF EXISTS `test_lvhuan`.`view_test_4`;
CREATE VIEW `test_lvhuan`.`view_test_4` as select round(sum(`test_lvhuan`.`uct_waste_purchase_cargo`.`net_weight`),1) AS `sum(net_weight)`,round(sum((`test_lvhuan`.`uct_waste_purchase_cargo`.`net_weight` * `test_lvhuan`.`uct_waste_purchase_cargo`.`unit_price`)),3) AS `sum(net_weight*unit_price)` from `test_lvhuan`.`uct_waste_purchase_cargo` where (`test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` = 22264);

DROP VIEW IF EXISTS `test_lvhuan`.`view_test_3`;
CREATE VIEW `test_lvhuan`.`view_test_3` as select sum(`test_lvhuan`.`uct_waste_storage_sort`.`net_weight`) AS `sum(``uct_waste_storage_sort``.``net_weight``)`,sum((round(`test_lvhuan`.`uct_waste_storage_sort`.`net_weight`,1) * round(`test_lvhuan`.`uct_waste_storage_sort`.`presell_price`,3))) AS `sum(net_weight*presell_price)` from `test_lvhuan`.`uct_waste_storage_sort` where (`test_lvhuan`.`uct_waste_storage_sort`.`purchase_id` = 22362);


DROP VIEW IF EXISTS `test_lvhuan`.`view_test`;
CREATE VIEW `test_lvhuan`.`view_test` as select `test_lvhuan`.`trans_month_sor_table`.`FRelateBrID` AS `FRelateBrID`,concat('#',`test_lvhuan`.`uct_waste_purchase`.`order_id`) AS `order_id`,`test_lvhuan`.`trans_month_sor_table`.`FDate` AS `FDate`,`test_lvhuan`.`trans_month_sor_table`.`FSupplyID` AS `FSupplyID`,`test_lvhuan`.`trans_month_sor_table`.`Fbusiness` AS `Fbusiness`,`test_lvhuan`.`trans_month_sor_table`.`FDeptID` AS `FDeptID`,`test_lvhuan`.`trans_month_sor_table`.`FEmpID` AS `FEmpID`,`test_lvhuan`.`trans_month_sor_table`.`FPOStyle` AS `FPOStyle`,`test_lvhuan`.`trans_month_sor_table`.`FPOPrecent` AS `FPOPrecent`,`test_lvhuan`.`trans_month_sor_table`.`profit` AS `profit`,`test_lvhuan`.`trans_month_sor_table`.`weight` AS `weight`,`test_lvhuan`.`trans_month_sor_table`.`transport_pay` AS `transport_pay`,`test_lvhuan`.`trans_month_sor_table`.`classify_pay` AS `classify_pay`,`test_lvhuan`.`trans_month_sor_table`.`material_pay` AS `material_pay`,`test_lvhuan`.`trans_month_sor_table`.`total_pay` AS `total_pay` from (`test_lvhuan`.`trans_month_sor_table` join `test_lvhuan`.`uct_waste_purchase`) where (`test_lvhuan`.`trans_month_sor_table`.`FInterID` = `test_lvhuan`.`uct_waste_purchase`.`id`);


DROP VIEW IF EXISTS `test_lvhuan`.`view_sort_time`;
CREATE VIEW `test_lvhuan`.`view_sort_time` as select `test_lvhuan`.`uct_waste_purchase_log`.`purchase_id` AS `purchase_id`,date_format(from_unixtime(`test_lvhuan`.`uct_waste_purchase_log`.`createtime`),'%Y-%m-%d') AS `createtime` from `test_lvhuan`.`uct_waste_purchase_log` where (`test_lvhuan`.`uct_waste_purchase_log`.`state_text` = '待入库确认');


DROP VIEW IF EXISTS `test_lvhuan`.`view_sort_expense`;
CREATE VIEW `test_lvhuan`.`view_sort_expense` as select `test_lvhuan`.`uct_waste_storage_sort_expense`.`purchase_id` AS `purchase_id`,sum(if((`test_lvhuan`.`uct_waste_storage_sort_expense`.`usage` = '资源池分拣人工'),`test_lvhuan`.`uct_waste_storage_sort_expense`.`price`,0)) AS `sort_expense`,sum(if((`test_lvhuan`.`uct_waste_storage_sort_expense`.`usage` like '耗材费%'),`test_lvhuan`.`uct_waste_storage_sort_expense`.`price`,0)) AS `materal_expense`,sum(`test_lvhuan`.`uct_waste_storage_sort_expense`.`price`) AS `total_expense` from `test_lvhuan`.`uct_waste_storage_sort_expense` group by `test_lvhuan`.`uct_waste_storage_sort_expense`.`purchase_id`;

DROP VIEW IF EXISTS `test_lvhuan`.`view_shenguan_presell`;
CREATE VIEW `test_lvhuan`.`view_shenguan_presell` as select `test_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `purchase_id`,round(sum((`test_lvhuan`.`uct_waste_storage_sort`.`net_weight` * `test_lvhuan`.`uct_waste_storage_sort`.`presell_price`)),2) AS `total_presell` from `test_lvhuan`.`uct_waste_storage_sort` group by `test_lvhuan`.`uct_waste_storage_sort`.`purchase_id`;


DROP VIEW IF EXISTS `test_lvhuan`.`view_second_sort`;
CREATE VIEW `test_lvhuan`.`view_second_sort` as select `view_change_sort`.`id` AS `id`,`view_change_sort`.`parent_id` AS `parent_id`,`view_change_sort`.`name` AS `name` from (select `test_lvhuan`.`uct_waste_cate`.`id` AS `id`,`test_lvhuan`.`uct_waste_cate`.`parent_id` AS `parent_id`,`test_lvhuan`.`uct_waste_cate`.`name` AS `name` from `test_lvhuan`.`uct_waste_cate` where (`test_lvhuan`.`uct_waste_cate`.`parent_id` <> 0)) `view_change_sort` where exists(select `view_first_sort`.`id` from `test_lvhuan`.`view_first_sort` where (`view_first_sort`.`id` = `view_change_sort`.`parent_id`));


DROP VIEW IF EXISTS `test_lvhuan`.`view_sell_time`;
CREATE VIEW `test_lvhuan`.`view_sell_time` as select `test_lvhuan`.`uct_waste_sell_log`.`sell_id` AS `sell_id`,date_format(from_unixtime(`test_lvhuan`.`uct_waste_sell_log`.`createtime`),'%Y-%m-%d') AS `sell_time` from (`test_lvhuan`.`uct_waste_sell_log` join `test_lvhuan`.`view_valid_sell`) where ((`test_lvhuan`.`uct_waste_sell_log`.`state_value` = 'wait_confirm_order') and (`view_valid_sell`.`sell_id` = `test_lvhuan`.`uct_waste_sell_log`.`sell_id`));


DROP VIEW IF EXISTS `test_lvhuan`.`view_shenguan_check`;
CREATE VIEW `test_lvhuan`.`view_shenguan_check` as select `test_lvhuan`.`uct_waste_purchase_log`.`purchase_id` AS `purchase_id`,date_format(from_unixtime(`test_lvhuan`.`uct_waste_purchase_log`.`createtime`),'%Y-%m-%d') AS `check_time`,`test_lvhuan`.`uct_admin`.`nickname` AS `nickname` from (`test_lvhuan`.`uct_waste_purchase_log` join `test_lvhuan`.`uct_admin`) where ((`test_lvhuan`.`uct_waste_purchase_log`.`state_value` = 'finish') and (`test_lvhuan`.`uct_admin`.`id` = `test_lvhuan`.`uct_waste_purchase_log`.`admin_id`) and (`test_lvhuan`.`uct_waste_purchase_log`.`createtime` >= '1542902400'));



DROP VIEW IF EXISTS `test_lvhuan`.`view_reimbursement_expense`;
CREATE VIEW `test_lvhuan`.`view_reimbursement_expense` as select `test_lvhuan`.`uct_waste_purchase_expense`.`purchase_id` AS `purchase_id`,round(sum((case `test_lvhuan`.`uct_waste_purchase_expense`.`usage` when '拉货助理人工' then `test_lvhuan`.`uct_waste_purchase_expense`.`price` else '0' end)),2) AS `拉货助理人工` from `test_lvhuan`.`uct_waste_purchase_expense` group by `test_lvhuan`.`uct_waste_purchase_expense`.`purchase_id`,`test_lvhuan`.`uct_waste_purchase_expense`.`usage`;



DROP VIEW IF EXISTS `test_lvhuan`.`view_order_unfinished_all`;
CREATE VIEW `test_lvhuan`.`view_order_unfinished_all` as select `test_lvhuan`.`trans_main_table`.`FInterID` AS `FInterID`,`test_lvhuan`.`trans_main_table`.`FDate` AS `FDate`,`test_lvhuan`.`trans_main_table`.`FBillNo` AS `FBillNo`,`test_lvhuan`.`trans_main_table`.`FPOPrecent` AS `FPOPrecent`,`test_lvhuan`.`trans_main_table`.`TalFQty` AS `TalFQty`,`test_lvhuan`.`trans_main_table`.`TalFAmount` AS `TalFAmount`,`test_lvhuan`.`trans_main_table`.`FEmpID` AS `FEmpID`,`test_lvhuan`.`trans_main_table`.`FSupplyID` AS `FSupplyID`,`test_lvhuan`.`trans_fee_table`.`FFeeID` AS `FFeeID`,`test_lvhuan`.`trans_fee_table`.`FFeeAmount` AS `FFeeAmount`,`test_lvhuan`.`trans_fee_table`.`FFeePerson` AS `FFeePerson` from (`test_lvhuan`.`trans_fee_table` join `test_lvhuan`.`trans_main_table`) where ((`test_lvhuan`.`trans_fee_table`.`FInterID` = `test_lvhuan`.`trans_main_table`.`FInterID`) and (`test_lvhuan`.`trans_main_table`.`FTranType` = 'PUR') and (`test_lvhuan`.`trans_main_table`.`FCancellation` = '1') and (`test_lvhuan`.`trans_main_table`.`FDate` <> '1970-01-01 08:00:00') and ((`test_lvhuan`.`trans_fee_table`.`FFeeID` = '供应商人工补助费') or (`test_lvhuan`.`trans_fee_table`.`FFeeID` = '供应商车辆补助费') or (`test_lvhuan`.`trans_fee_table`.`FFeeID` = '供应商垃圾补助费'))) group by `test_lvhuan`.`trans_main_table`.`FBillNo`;


DROP VIEW IF EXISTS `test_lvhuan`.`view_purchase_expense`;
CREATE VIEW `test_lvhuan`.`view_purchase_expense` as select `test_lvhuan`.`uct_waste_purchase_expense`.`purchase_id` AS `purchase_id`,round(sum((case `test_lvhuan`.`uct_waste_purchase_expense`.`usage` when '供应商垃圾补助费' then `test_lvhuan`.`uct_waste_purchase_expense`.`price` else '0' end)),2) AS `供应商垃圾补助费` from `test_lvhuan`.`uct_waste_purchase_expense` group by `test_lvhuan`.`uct_waste_purchase_expense`.`purchase_id`,`test_lvhuan`.`uct_waste_purchase_expense`.`usage`;




DROP VIEW IF EXISTS `test_lvhuan`.`view_excel_sell`;
CREATE VIEW `test_lvhuan`.`view_excel_sell` as select `test_lvhuan`.`uct_waste_sell`.`id` AS `id`,`test_lvhuan`.`uct_waste_sell`.`branch_id` AS `branch_id`,`test_lvhuan`.`uct_waste_sell`.`purchase_id` AS `purchase_id`,`test_lvhuan`.`uct_waste_sell`.`order_id` AS `order_id`,`test_lvhuan`.`uct_waste_sell`.`customer_id` AS `customer_id`,`test_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `customer_linkman_id`,`test_lvhuan`.`uct_waste_sell`.`seller_id` AS `seller_id`,`test_lvhuan`.`uct_waste_sell`.`seller_remark` AS `seller_remark`,`test_lvhuan`.`uct_waste_sell`.`warehouse_id` AS `warehouse_id`,`test_lvhuan`.`uct_waste_sell`.`cargo_pick_time` AS `cargo_pick_time`,`test_lvhuan`.`uct_waste_sell`.`car_number` AS `car_number`,`test_lvhuan`.`uct_waste_sell`.`car_weight` AS `car_weight`,`test_lvhuan`.`uct_waste_sell`.`cargo_price` AS `cargo_price`,`test_lvhuan`.`uct_waste_sell`.`materiel_price` AS `materiel_price`,`test_lvhuan`.`uct_waste_sell`.`other_price` AS `other_price`,`test_lvhuan`.`uct_waste_sell`.`cargo_out_remark` AS `cargo_out_remark`,`test_lvhuan`.`uct_waste_sell`.`pay_way_id` AS `pay_way_id`,`test_lvhuan`.`uct_waste_sell`.`customer_evaluate_data` AS `customer_evaluate_data`,`test_lvhuan`.`uct_waste_sell`.`seller_evaluate_data` AS `seller_evaluate_data`,`test_lvhuan`.`uct_waste_sell`.`state` AS `state`,`test_lvhuan`.`uct_waste_sell`.`createtime` AS `createtime`,`test_lvhuan`.`uct_waste_sell`.`updatetime` AS `updatetime` from `test_lvhuan`.`uct_waste_sell` where (`test_lvhuan`.`uct_waste_sell`.`createtime` > 1541030400);



DROP VIEW IF EXISTS `test_lvhuan`.`view_excel_customer`;
CREATE VIEW `test_lvhuan`.`view_excel_customer` as select `test_lvhuan`.`uct_admin`.`id` AS `id`,`test_lvhuan`.`uct_admin`.`nickname` AS `nickname` from `test_lvhuan`.`uct_admin` where (`test_lvhuan`.`uct_admin`.`id` > 1826);


DROP VIEW IF EXISTS `test_lvhuan`.`view_cargofile_first`;
CREATE VIEW `test_lvhuan`.`view_cargofile_first` as select `test_lvhuan`.`uct_waste_cate`.`id` AS `id`,`test_lvhuan`.`uct_waste_cate`.`name` AS `name` from `test_lvhuan`.`uct_waste_cate` where (`test_lvhuan`.`uct_waste_cate`.`parent_id` = 0);


DROP VIEW IF EXISTS `test_lvhuan`.`view_cargofile_second`;
CREATE VIEW `test_lvhuan`.`view_cargofile_second` as select `view_change_sort`.`id` AS `id`,`view_change_sort`.`parent_id` AS `parent_id`,`view_change_sort`.`name` AS `name` from (select `test_lvhuan`.`uct_waste_cate`.`id` AS `id`,`test_lvhuan`.`uct_waste_cate`.`parent_id` AS `parent_id`,`test_lvhuan`.`uct_waste_cate`.`name` AS `name` from `test_lvhuan`.`uct_waste_cate` where (`test_lvhuan`.`uct_waste_cate`.`parent_id` <> 0)) `view_change_sort` where exists(select `view_cargofile_first`.`id` from `test_lvhuan`.`view_cargofile_first` where (`view_cargofile_first`.`id` = `view_change_sort`.`parent_id`));


DROP VIEW IF EXISTS `test_lvhuan`.`view_cargofile_third`;
CREATE VIEW `test_lvhuan`.`view_cargofile_third` as select `view_change_sort`.`id` AS `id`,`view_change_sort`.`parent_id` AS `parent_id`,`view_change_sort`.`name` AS `name`,`view_change_sort`.`branch_id` AS `branch_id` from (select `test_lvhuan`.`uct_waste_cate`.`id` AS `id`,`test_lvhuan`.`uct_waste_cate`.`parent_id` AS `parent_id`,`test_lvhuan`.`uct_waste_cate`.`name` AS `name`,`test_lvhuan`.`uct_waste_cate`.`branch_id` AS `branch_id` from `test_lvhuan`.`uct_waste_cate` where (`test_lvhuan`.`uct_waste_cate`.`parent_id` <> 0)) `view_change_sort` where (not(exists(select `view_cargofile_first`.`id` from `test_lvhuan`.`view_cargofile_first` where (`view_cargofile_first`.`id` = `view_change_sort`.`parent_id`))));


DROP VIEW IF EXISTS `test_lvhuan`.`view_cargo_collect`;
CREATE VIEW `test_lvhuan`.`view_cargo_collect` as select if((`p`.`FTranType` = 'SEL'),`p`.`FSourceInterId`,`p`.`FinterID`) AS `FInterID`,`p`.`FItemID` AS `FItemID`,ifnull(group_concat((case `p`.`FTranType` when 'PUR' then concat('采购净重 ',`p`.`FQty`,', ','采购价 ',ifnull(round(`p`.`FPrice`,2),0.00)) else NULL end) separator ','),'') AS `PUR_log`,round(sum(if((`p`.`FTranType` = 'PUR'),`p`.`FQty`,0)),1) AS `PUR_FQty`,round(sum(if((`p`.`FTranType` = 'PUR'),`p`.`FAmount`,0)),2) AS `PUR_FAmount`,ifnull(group_concat((case `p`.`FTranType` when 'SOR' then concat('入库净重 ',`p`.`FQty`,', ','预售价 ',ifnull(round(`p`.`FPrice`,2),0.00)) when 'SEL' then concat('销售重量 ',`p`.`FQty`,', ','销售价 ',ifnull(round(`p`.`FPrice`,2),0.00)) else NULL end) separator ','),'') AS `SOR_log`,round(sum(if((`p`.`FTranType` = 'PUR'),0,`p`.`FQty`)),1) AS `SOR_FQty`,ifnull(round(sum(if((`p`.`FTranType` = 'PUR'),0,`p`.`FAmount`)),2),0.00) AS `SOR_FAmount`,date_format(max(if((`p`.`FTranType` = 'PUR'),NULL,`p`.`FDCTime`)),'%Y-%m-%d') AS `FDCTime` from `test_lvhuan`.`trans_assist_table` `p` where (if((`p`.`FTranType` = 'SEL'),(`p`.`FSourceInterId` <> ''),TRUE) and (`p`.`FItemID` <> 0)) group by if((`p`.`FTranType` = 'SEL'),`p`.`FSourceInterId`,`p`.`FinterID`),`p`.`FItemID`;


DROP VIEW IF EXISTS `test_lvhuan`.`view_cargofile_collect`;
CREATE VIEW `test_lvhuan`.`view_cargofile_collect` as select `view_cargofile_third`.`id` AS `id`,`view_cargofile_first`.`name` AS `first_sort`,`view_cargofile_second`.`name` AS `second_sort`,`view_cargofile_third`.`name` AS `sort_name`,`view_cargofile_third`.`branch_id` AS `branch_id` from ((`test_lvhuan`.`view_cargofile_third` join `test_lvhuan`.`view_cargofile_second`) join `test_lvhuan`.`view_cargofile_first`) where ((`view_cargofile_third`.`parent_id` = `view_cargofile_second`.`id`) and (`view_cargofile_second`.`parent_id` = `view_cargofile_first`.`id`));

DROP VIEW IF EXISTS `test_lvhuan`.`view_accounting_purchase_cargo`;
CREATE VIEW `test_lvhuan`.`view_accounting_purchase_cargo` as select `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `purchase_id`,`test_lvhuan`.`uct_waste_purchase_cargo`.`cate_id` AS `cate_id`,sum(`test_lvhuan`.`uct_waste_purchase_cargo`.`net_weight`) AS `net_weight`,`test_lvhuan`.`uct_waste_purchase_cargo`.`unit_price` AS `unit_price`,`test_lvhuan`.`uct_waste_purchase_cargo`.`createtime` AS `createtime` from `test_lvhuan`.`uct_waste_purchase_cargo` group by `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`,`test_lvhuan`.`uct_waste_purchase_cargo`.`cate_id`,`test_lvhuan`.`uct_waste_purchase_cargo`.`unit_price`;


DROP VIEW IF EXISTS `test_lvhuan`.`view_accounting_sort_cargo`;
CREATE VIEW `test_lvhuan`.`view_accounting_sort_cargo` as select `test_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `purchase_id`,`test_lvhuan`.`uct_waste_storage_sort`.`cargo_sort` AS `cate_id`,sum(`test_lvhuan`.`uct_waste_storage_sort`.`net_weight`) AS `net_weight`,`test_lvhuan`.`uct_waste_storage_sort`.`presell_price` AS `presell_price`,`test_lvhuan`.`uct_waste_storage_sort`.`createtime` AS `createtime` from `test_lvhuan`.`uct_waste_storage_sort` group by `test_lvhuan`.`uct_waste_storage_sort`.`purchase_id`,`test_lvhuan`.`uct_waste_storage_sort`.`cargo_sort`;


DROP VIEW IF EXISTS `test_lvhuan`.`trans_total_fee_osf`;
CREATE VIEW `test_lvhuan`.`trans_total_fee_osf` as select `test_lvhuan`.`uct_waste_sell_other_price`.`sell_id` AS `sell_id`,sum((case `test_lvhuan`.`uct_waste_sell_other_price`.`type` when 'in' then `test_lvhuan`.`uct_waste_sell_other_price`.`price` else 0 end)) AS `sell_profit`,sum((case `test_lvhuan`.`uct_waste_sell_other_price`.`type` when 'out' then `test_lvhuan`.`uct_waste_sell_other_price`.`price` else 0 end)) AS `sell_fee` from `test_lvhuan`.`uct_waste_sell_other_price` group by `test_lvhuan`.`uct_waste_sell_other_price`.`sell_id`;





DROP VIEW IF EXISTS `test_lvhuan`.`trans_total_fee_sf`;
CREATE VIEW `test_lvhuan`.`trans_total_fee_sf` as select `test_lvhuan`.`uct_waste_sell`.`purchase_id` AS `purchase_id`,sum((case `test_lvhuan`.`uct_waste_sell_other_price`.`type` when 'in' then `test_lvhuan`.`uct_waste_sell_other_price`.`price` else 0 end)) AS `sell_profit`,sum((case `test_lvhuan`.`uct_waste_sell_other_price`.`type` when 'out' then `test_lvhuan`.`uct_waste_sell_other_price`.`price` else 0 end)) AS `sell_fee` from ((`test_lvhuan`.`uct_waste_sell_other_price` join `test_lvhuan`.`uct_waste_sell`) join `test_lvhuan`.`uct_waste_purchase`) where ((`test_lvhuan`.`uct_waste_sell`.`purchase_id` > 0) and (`test_lvhuan`.`uct_waste_sell_other_price`.`sell_id` = `test_lvhuan`.`uct_waste_sell`.`id`) and (`test_lvhuan`.`uct_waste_sell`.`purchase_id` = `test_lvhuan`.`uct_waste_purchase`.`id`)) group by `test_lvhuan`.`uct_waste_sell`.`purchase_id`;



DROP VIEW IF EXISTS `test_lvhuan`.`trans_total_cargo_sc`;
CREATE VIEW `test_lvhuan`.`trans_total_cargo_sc` as select `test_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `FInterID`,'SOR' AS `FTranType`,sum(`test_lvhuan`.`uct_waste_storage_sort`.`net_weight`) AS `FQtyTotal`,round(sum((`test_lvhuan`.`uct_waste_storage_sort`.`net_weight` * `test_lvhuan`.`uct_waste_storage_sort`.`presell_price`)),2) AS `FAmountTotal`,`test_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `FSourceInterId`,'PUR' AS `FSourceTranType` from `test_lvhuan`.`uct_waste_storage_sort` group by `test_lvhuan`.`uct_waste_storage_sort`.`purchase_id`;

DROP VIEW IF EXISTS `test_lvhuan`.`trans_total_cargo_pc`;
CREATE VIEW `test_lvhuan`.`trans_total_cargo_pc` as select `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,sum(`test_lvhuan`.`uct_waste_purchase_cargo`.`net_weight`) AS `FQtyTotal`,round(sum(`test_lvhuan`.`uct_waste_purchase_cargo`.`total_price`),2) AS `FAmountTotal`,'' AS `FSourceInterId`,'' AS `FSourceTranType` from `test_lvhuan`.`uct_waste_purchase_cargo` group by `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`;

DROP VIEW IF EXISTS `test_lvhuan`.`trans_purchase_cargo`;
CREATE VIEW `test_lvhuan`.`trans_purchase_cargo` as select `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `purchase_id`,`test_lvhuan`.`uct_waste_purchase_cargo`.`cate_id` AS `cate_id`,`test_lvhuan`.`uct_waste_purchase_cargo`.`net_weight` AS `sum(net_weight)`,`test_lvhuan`.`uct_waste_purchase_cargo`.`unit_price` AS `unit_price` from `test_lvhuan`.`uct_waste_purchase_cargo` group by `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`,`test_lvhuan`.`uct_waste_purchase_cargo`.`unit_price`;



DROP VIEW IF EXISTS `test_lvhuan`.`trans_order_unfinished`;
CREATE VIEW `test_lvhuan`.`trans_order_unfinished` as select date_format(`main`.`FDate`,'%Y-%m-%d') AS `PUR_Date`,`main`.`FSupplyID` AS `FSupplyID`,`main`.`FBillNo` AS `FBillNo`,(case `main`.`FPOPrecent` when '999' then '1' when '0' then '0' else (`main`.`FPOPrecent` / 100) end) AS `FPOPrecent`,`main`.`FEmpID` AS `FEmpID`,`main`.`FTrainNum` AS `train_number`,`main`.`TalFQty` AS `TalFQty`,`main`.`TalFAmount` AS `TalFAmount`,round((case `main`.`FPOPrecent` when '999' then (`main`.`TalFAmount` * 1) when '0' then 0 else ((`main`.`TalFAmount` * cast(`main`.`FPOPrecent` as signed)) / 100) end),3) AS `real_pay`,sum((case `fee`.`FFeeID` when '供应商人工补助费' then `fee`.`FFeeAmount` when '供应商车辆补助费' then `fee`.`FFeeAmount` when '供应商垃圾补助费' then `fee`.`FFeeAmount` else 0 end)) AS `back_fee`,(round((case `main`.`FPOPrecent` when '999' then (`main`.`TalFAmount` * 1) when '0' then 0 else ((`main`.`TalFAmount` * cast(`main`.`FPOPrecent` as signed)) / 100) end),3) - sum((case `fee`.`FFeeID` when '供应商人工补助费' then `fee`.`FFeeAmount` when '供应商车辆补助费' then `fee`.`FFeeAmount` when '供应商垃圾补助费' then `fee`.`FFeeAmount` else 0 end))) AS `really_pay`,sum((case `fee`.`FFeeID` when '拉货专员人工' then `fee`.`FFeeAmount` else 0 end)) AS `fee_zy`,group_concat((case `fee`.`FFeeID` when '拉货专员人工' then `fee`.`FFeePerson` else NULL end) separator ',') AS `Person_zy`,sum((case `fee`.`FFeeID` when '拉货助理人工' then `fee`.`FFeeAmount` else 0 end)) AS `fee_zl`,group_concat((case `fee`.`FFeeID` when '拉货助理人工' then `fee`.`FFeePerson` else NULL end) separator ',') AS `Person_zl` from (`test_lvhuan`.`trans_main_table` `main` join `test_lvhuan`.`trans_fee_table` `fee`) where ((`main`.`FTranType` = 'PUR') and (`main`.`FCancellation` = '1') and (`main`.`FDate` <> '1970-01-01 08:00:00') and (`main`.`FInterID` = `fee`.`FInterID`) and (`main`.`FCorrent` = 0)) group by `main`.`FBillNo` order by `main`.`FDate` desc;





---------------------------------------------------------------------------------------
DROP VIEW IF EXISTS `test_lvhuan`.`trans_main`;

CREATE VIEW `test_lvhuan`.`trans_main` AS 
SELECT 
    `test_lvhuan`.`uct_waste_purchase`.`branch_id` AS `FRelateBrID`,
    `test_lvhuan`.`uct_waste_purchase`.`id` AS `FInterID`,
    'PUR' AS `FTranType`,
    (CASE 
        `test_lvhuan`.`trans_log_table`.`TpurchaseOver` 
        WHEN '0' THEN DATE_FORMAT(FROM_UNIXTIME(1), '%Y-%m-%d %H:%i:%S') 
        ELSE DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`trans_log_table`.`Tpurchase`), '%Y-%m-%d %H:%i:%S') 
    END) AS `FDate`,
    (CASE 
        `test_lvhuan`.`trans_log_table`.`TpurchaseOver` 
        WHEN '0' THEN DATE_FORMAT(FROM_UNIXTIME(1), '%Y-%m-%d') 
        ELSE DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`trans_log_table`.`Tpurchase`), '%Y-%m-%d') 
    END) AS `Date`,
    `test_lvhuan`.`uct_waste_purchase`.`train_number` AS `FTrainNum`,
    `test_lvhuan`.`uct_waste_purchase`.`order_id` AS `FBillNo`,
    `test_lvhuan`.`uct_waste_purchase`.`customer_id` AS `FSupplyID`,
    `test_lvhuan`.`uct_waste_purchase`.`manager_id`::text AS `Fbusiness`,
    CONCAT('AD', `test_lvhuan`.`uct_waste_purchase`.`purchase_incharge`) AS `FDCStockID`,
    CONCAT('CU', `test_lvhuan`.`uct_waste_purchase`.`customer_id`) AS `FSCStockID`,
    (CASE 
        `test_lvhuan`.`uct_waste_purchase`.`state` 
        WHEN 'cancel' THEN '0'
        ELSE '1'
    END) AS `FCancellation`,
    '0' AS `FROB`,
    `test_lvhuan`.`trans_log_table`.`TallowOver` AS `FCorrent`,
    `test_lvhuan`.`trans_log_table`.`TcheckOver` AS `FStatus`,
    '' AS `FUpStockWhenSave`,
    '' AS `FExplanation`,
    `test_lvhuan`.`uct_waste_customer`.`service_department` AS `FDeptID`,
    `test_lvhuan`.`uct_waste_purchase`.`purchase_incharge` AS `FEmpID`,
    `test_lvhuan`.`trans_log_table`.`TcheckPerson` AS `FCheckerID`,
    (CASE 
        `test_lvhuan`.`trans_log_table`.`TcheckOver` 
        WHEN '0' THEN 'null' 
        ELSE DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`trans_log_table`.`Tcheck`), '%Y-%m-%d %H:%i:%S') 
    END) AS `FCheckDate`,
    `test_lvhuan`.`uct_waste_purchase`.`purchase_incharge` AS `FFManagerID`,
    `test_lvhuan`.`uct_waste_purchase`.`purchase_incharge` AS `FSManagerID`,
    `test_lvhuan`.`uct_waste_purchase`.`purchase_incharge` AS `FBillerID`,
    '1' AS `FCurrencyID`,
    `test_lvhuan`.`trans_log_table`.`state` AS `FNowState`,
    ((CASE 
        `test_lvhuan`.`uct_waste_purchase`.`hand_mouth_data` 
        WHEN '1' THEN '1' 
        ELSE '0' 
    END) + (CASE 
        `test_lvhuan`.`uct_waste_purchase`.`give_frame` 
        WHEN '1' THEN '3' 
        ELSE 0 
    END)) AS `FSaleStyle`,
    `test_lvhuan`.`uct_waste_customer`.`settle_way`::text AS `FPOStyle`,
    `test_lvhuan`.`uct_waste_customer`.`back_percent`::text AS `FPOPrecent`,
    ROUND(`test_lvhuan`.`uct_waste_purchase`.`cargo_weight`, 1) AS `TalFQty`,
    ROUND(`test_lvhuan`.`uct_waste_purchase`.`cargo_price`, 2) AS `TalFAmount`,
    `test_lvhuan`.`uct_waste_purchase`.`purchase_expense` AS `TalFeeFrist`,
    `trans_total_fee_rf`.`car_fee` AS `TalFeeSecond`,
    `trans_total_fee_rf`.`man_fee` AS `TalFeeThird`,
    `trans_total_fee_rf`.`other_return_fee` AS `TalFeeForth`,
    0 AS `TalFeeFifth`
FROM 
    (((`test_lvhuan`.`uct_waste_purchase` 
    JOIN `test_lvhuan`.`uct_waste_customer`) 
    JOIN `test_lvhuan`.`trans_log_table`) 
    LEFT JOIN `test_lvhuan`.`trans_total_fee_rf` 
        ON ((`trans_total_fee_rf`.`purchase_id` = `test_lvhuan`.`uct_waste_purchase`.`id`))) 
WHERE 
    ((`test_lvhuan`.`uct_waste_purchase`.`customer_id` = `test_lvhuan`.`uct_waste_customer`.`id`) 
    AND (`test_lvhuan`.`uct_waste_purchase`.`id` = `test_lvhuan`.`trans_log_table`.`FInterID`) 
    AND (`test_lvhuan`.`trans_log_table`.`FTranType` = 'PUR') 
    AND (`test_lvhuan`.`uct_waste_purchase`.`order_id` > 201806300000000000)) 
UNION ALL 
SELECT 
    `test_lvhuan`.`uct_waste_sell`.`branch_id` AS `FRelateBrID`,
    `test_lvhuan`.`uct_waste_sell`.`id` AS `FInterID`,
    'SEL' AS `FTranType`,
    (CASE 
        `test_lvhuan`.`trans_log_table`.`TallowOver` 
        WHEN '0' THEN DATE_FORMAT(FROM_UNIXTIME(1), '%Y-%m-%d %H:%i:%S') 
        ELSE DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`trans_log_table`.`Tallow`), '%Y-%m-%d %H:%i:%S') 
    END) AS `FDate`,
    (CASE 
        `test_lvhuan`.`trans_log_table`.`TallowOver` 
        WHEN '0' THEN DATE_FORMAT(FROM_UNIXTIME(1), '%Y-%m-%d') 
        ELSE DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`trans_log_table`.`Tallow`), '%Y-%m-%d') 
    END) AS `Date`,
    `test_lvhuan`.`uct_waste_purchase`.`train_number` AS `FTrainNum`,
    `test_lvhuan`.`uct_waste_sell`.`order_id` AS `FBillNo`,
    `test_lvhuan`.`uct_waste_sell`.`customer_id` AS `FSupplyID`,
    '' AS `Fbusiness`,
    CONCAT('DC', `test_lvhuan`.`uct_waste_sell`.`customer_id`) AS `FDCStockID`,
    IF (
        ((`test_lvhuan`.`uct_waste_sell`.`purchase_id` IS NOT NULL) = 0), 
        CONCAT('LH', `test_lvhuan`.`uct_waste_sell`.`warehouse_id`), 
        CONCAT('AD', `test_lvhuan`.`uct_waste_purchase`.`purchase_incharge`)
    ) AS `FSCStockID`,
    (CASE 
        `test_lvhuan`.`uct_waste_sell`.`state` 
        WHEN 'cancel' THEN '0'::bigint 
        ELSE '1'::bigint 
    END) AS `FCancellation`,
    '0' AS `FROB`,
    `test_lvhuan`.`trans_log_table`.`TallowOver` AS `FCorrent`,
    `test_lvhuan`.`trans_log_table`.`TcheckOver` AS `FStatus`,
    '0' AS `FUpStockWhenSave`,
    '' AS `FExplanation`,
    '4' AS `FDeptID`,
    `test_lvhuan`.`uct_waste_sell`.`seller_id` AS `FEmpID`,
    `test_lvhuan`.`trans_log_table`.`TcheckPerson` AS `FCheckerID`,
    (CASE 
        `test_lvhuan`.`trans_log_table`.`TcheckOver` 
        WHEN '0' THEN 'null' 
        ELSE DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`trans_log_table`.`Tcheck`), '%Y-%m-%d %H:%i:%S') 
    END) AS `FCheckDate`,
    `test_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `FFManagerID`,
    `test_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `FSManagerID`,
    `test_lvhuan`.`uct_waste_sell`.`seller_id` AS `FBillerID`,
    '1' AS `FCurrencyID`,
    `test_lvhuan`.`trans_log_table`.`state` AS `FNowState`,
    IF (
        ((`test_lvhuan`.`uct_waste_sell`.`purchase_id` IS NOT NULL) = 1),
        '1',
        '2'
    ) AS `FSaleStyle`,
    '' AS `FPOStyle`,
    '' AS `FPOPrecent`,
    ROUND(`test_lvhuan`.`uct_waste_sell`.`cargo_weight`, 1) AS `TalFQty`,
    ROUND(`test_lvhuan`.`uct_waste_sell`.`cargo_price`, 2) AS `TalFAmount`,
    `test_lvhuan`.`uct_waste_sell`.`materiel_price` AS `TalFeeFrist`,
    `test_lvhuan`.`uct_waste_sell`.`other_price` AS `TalFeeSecond`,
    0 AS `TalFeeThird`,
    0 AS `TalFeeForth`,
    0 AS `TalFeeFifth`
FROM 
    (((`test_lvhuan`.`uct_waste_sell` 
    JOIN `test_lvhuan`.`uct_waste_customer`) 
    JOIN `test_lvhuan`.`trans_log_table`) 
    JOIN `test_lvhuan`.`uct_waste_purchase`) 
WHERE 
    ((`test_lvhuan`.`uct_waste_sell`.`customer_id` = `test_lvhuan`.`uct_waste_customer`.`id`) 
    AND (`test_lvhuan`.`uct_waste_sell`.`purchase_id` = `test_lvhuan`.`trans_log_table`.`FInterID`) 
    AND (`test_lvhuan`.`trans_log_table`.`FTranType` = 'PUR') 
    AND (`test_lvhuan`.`uct_waste_sell`.`purchase_id` = `test_lvhuan`.`uct_waste_purchase`.`id`) 
    AND (`test_lvhuan`.`uct_waste_sell`.`order_id` > 201806300000000000)) 
UNION ALL 
SELECT 
    `test_lvhuan`.`uct_waste_sell`.`branch_id` AS `FRelateBrID`,
    `test_lvhuan`.`uct_waste_sell`.`id` AS `FInterID`,
    'SEL' AS `FTranType`,
    (CASE 
        `test_lvhuan`.`trans_log_table`.`TallowOver` 
        WHEN '0' THEN DATE_FORMAT(FROM_UNIXTIME(1), '%Y-%m-%d %H:%i:%S') 
        ELSE DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`trans_log_table`.`Tallow`), '%Y-%m-%d %H:%i:%S') 
    END) AS `FDate`,
    (CASE 
        `test_lvhuan`.`trans_log_table`.`TallowOver` 
        WHEN '0' THEN DATE_FORMAT(FROM_UNIXTIME(1), '%Y-%m-%d') 
        ELSE DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`trans_log_table`.`Tallow`), '%Y-%m-%d') 
    END) AS `Date`,
    '1' AS `FTrainNum`,
    `test_lvhuan`.`uct_waste_sell`.`order_id` AS `FBillNo`,
    `test_lvhuan`.`uct_waste_sell`.`customer_id` AS `FSupplyID`,
    '' AS `Fbusiness`,
    CONCAT('DC', `test_lvhuan`.`uct_waste_sell`.`customer_id`) AS `FDCStockID`,
    IF (
        ((`test_lvhuan`.`uct_waste_sell`.`purchase_id` IS NOT NULL) = 0),
        CONCAT('LH', `test_lvhuan`.`uct_waste_sell`.`warehouse_id`),
        ''
    ) AS `FSCStockID`,
    (CASE 
        `test_lvhuan`.`uct_waste_sell`.`state` 
        WHEN 'cancel' THEN '0'::bigint 
        ELSE '1'::bigint 
    END) AS `FCancellation`,
    '0' AS `FROB`,
    `test_lvhuan`.`trans_log_table`.`TallowOver` AS `FCorrent`,
    `test_lvhuan`.`trans_log_table`.`TcheckOver` AS `FStatus`,
    `test_lvhuan`.`trans_log_table`.`TallowOver` AS `FUpStockWhenSave`,
    '' AS `FExplanation`,
    '4' AS `FDeptID`,
    `test_lvhuan`.`uct_waste_sell`.`seller_id` AS `FEmpID`,
    `test_lvhuan`.`trans_log_table`.`TcheckPerson` AS `FCheckerID`,
    (CASE 
        `test_lvhuan`.`trans_log_table`.`TcheckOver` 
        WHEN '0' THEN 'null' 
        ELSE DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`trans_log_table`.`Tcheck`), '%Y-%m-%d %H:%i:%S') 
    END) AS `FCheckDate`,
    `test_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `FFManagerID`,
    `test_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `FSManagerID`,
    `test_lvhuan`.`uct_waste_sell`.`seller_id` AS `FBillerID`,
    '1' AS `FCurrencyID`,
    `test_lvhuan`.`trans_log_table`.`state` AS `FNowState`,
    IF (
        ((`test_lvhuan`.`uct_waste_sell`.`purchase_id` IS NOT NULL) = 1),
        '1',
        '2'
    ) AS `FSaleStyle`,
    '' AS `FPOStyle`,
    '' AS `FPOPrecent`,
    ROUND(`test_lvhuan`.`uct_waste_sell`.`cargo_weight`, 1) AS `TalFQty`,
    ROUND(`test_lvhuan`.`uct_waste_sell`.`cargo_price`, 2) AS `TalFAmount`,
    `test_lvhuan`.`uct_waste_sell`.`materiel_price` AS `TalFeeFrist`,
    `test_lvhuan`.`uct_waste_sell`.`other_price` AS `TalFeeSecond`,
    0 AS `TalFeeThird`,
    0 AS `TalFeeForth`,
    0 AS `TalFeeFifth`
FROM 
    ((`test_lvhuan`.`uct_waste_sell` 
    JOIN `test_lvhuan`.`uct_waste_customer`) 
    JOIN `test_lvhuan`.`trans_log_table`) 
WHERE 
    ((`test_lvhuan`.`uct_waste_sell`.`customer_id` = `test_lvhuan`.`uct_waste_customer`.`id`) 
    AND (`test_lvhuan`.`uct_waste_sell`.`id` = `test_lvhuan`.`trans_log_table`.`FInterID`) 
    AND (`test_lvhuan`.`trans_log_table`.`FTranType` = 'SEL') 
    AND ((`test_lvhuan`.`uct_waste_sell`.`purchase_id` IS NOT NULL) = 0) 
    AND (`test_lvhuan`.`uct_waste_sell`.`order_id` > 201806300000000000));
	
	
DROP VIEW IF EXISTS `test_lvhuan`.`trans_month_customer`;
CREATE VIEW `test_lvhuan`.`trans_month_customer` as select `trans_main`.`FRelateBrID` AS `FRelateBrID`,`trans_main`.`FSupplyID` AS `FSupplyID`,`trans_main`.`Fbusiness` AS `Fbusiness`,`trans_main`.`TalFQty` AS `total_weight`,`trans_main`.`TalFAmount` AS `total_profit`,`taltrash`.`trash_weight` AS `trash_weight`,`trans_main`.`FDate` AS `FDate` from (`test_lvhuan`.`trans_main` join (select `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `FInterID`,sum((case `test_lvhuan`.`uct_waste_purchase_cargo`.`cargo_name` when '垃圾' then `test_lvhuan`.`uct_waste_purchase_cargo`.`net_weight` else 0 end)) AS `trash_weight` from `test_lvhuan`.`uct_waste_purchase_cargo` group by `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`) `taltrash`) where ((`trans_main`.`FTranType` = 'PUR') and (`taltrash`.`FInterID` = `trans_main`.`FInterID`));



DROP VIEW IF EXISTS `test_lvhuan`.`test_4`;
CREATE VIEW `test_lvhuan`.`test_4` AS
SELECT
    `cus`.`branch_id` AS `branch_id`,
    `cus`.`company_name` AS `company_name`,
    `cus`.`liasion` AS `liasion`,
    `item`.`shipment_ask` AS `shipment_ask`,
    `item`.`shipment_answer` AS `shipment_answer`,
    `item`.`staff_cooperate` AS `staff_cooperate`,
    `item`.`civilized_operation` AS `civilized_operation`,
    `item`.`customer_stipulate` AS `customer_stipulate`,
    `item`.`now_settle` AS `now_settle`,
    `item`.`settle_accuracy` AS `settle_accuracy`,
    `item`.`handle_rationality` AS `handle_rationality`,
    `item`.`receipts_timeliness` AS `receipts_timeliness`,
    `item`.`report_accuracy` AS `report_accuracy`,
    `item`.`communicate_smooth` AS `communicate_smooth`,
    `item`.`complaint_timeliness` AS `complaint_timeliness`,
    `item`.`verify_track` AS `verify_track`,
    `item`.`regular_visits` AS `regular_visits`,
    `item`.`report_to_duty` AS `report_to_duty`,
    `item`.`working_attitude` AS `working_attitude`,
    `item`.`packaging_work` AS `packaging_work`,
    `item`.`shipshape` AS `shipshape`,
    `item`.`qualifications_update` AS `qualifications_update`,
    `item`.`assess_support` AS `assess_support`,
    `item`.`emergency_container` AS `emergency_container`,
    `item`.`environmental_consultation` AS `environmental_consultation`,
    `gra`.`item1` AS `item1`,
    `gra`.`item2` AS `item2`,
    `gra`.`item3` AS `item3`,
    `gra`.`item4` AS `item4`,
    `gra`.`item5` AS `item5`,
    `gra`.`item6` AS `item6`,
    `gra`.`item7` AS `item7`,
    `gra`.`csi` AS `csi`,
    `item`.`extend_service` COLLATE "default" AS `extend_service`,
    `item`.`propose` COLLATE "default" AS `propose`
FROM
    (
        (`test_lvhuan`.`uct_customer_question_item` `item`
        JOIN `test_lvhuan`.`uct_customer_question` `cus`)
        JOIN `test_lvhuan`.`uct_customer_question_grade` `gra`
    )
WHERE
    (
        (`item`.`question_id` = `cus`.`id`)
        AND (`cus`.`branch_id` <> 7)
        AND (`cus`.`branch_id` <> 0)
        AND (`gra`.`question_id` = `cus`.`id`)
    )
GROUP BY `cus`.`phone`;




DROP VIEW IF EXISTS "test_lvhuan"."test_2";
CREATE VIEW "test_lvhuan"."test_2" AS
SELECT
    "a"."id" AS "id",
    "a"."branch_id" AS "branch_id",
    "a"."crmid" AS "crmid",
    "a"."username" AS "username",
    "a"."nickname" AS "nickname",
    "a"."password" AS "password",
    "a"."salt" AS "salt",
    "a"."avatar" AS "avatar",
    "a"."mobile" AS "mobile",
    "a"."email" AS "email",
    "a"."loginfailure" AS "loginfailure",
    "a"."logintime" AS "logintime",
    "a"."createtime" AS "createtime",
    "a"."updatetime" AS "updatetime",
    "a"."token" AS "token",
    "a"."last_appletid" AS "last_appletid",
    "a"."status" AS "status"
FROM
    "test_lvhuan"."uct_admin" "a"
JOIN
    "test_lvhuan"."uct_waste_customer" "w"
ON
    "a"."id" = ANY(string_to_array("w"."admin_id", ',')::int[])
WHERE
    "w"."customer_type" = 'up';


DROP VIEW IF EXISTS `test_lvhuan`.`test`;
CREATE VIEW `test_lvhuan`.`test` AS
SELECT
    `plog`.`purchase_id` AS `FInterID`,
    'PUR' AS `FTranType`,
    MAX(CASE `plog`.`state_value` WHEN 'draft' THEN `plog`.`createtime` END) AS `TCreate`,
    MAX(CASE `plog`.`state_value` WHEN 'draft' THEN `plog`.`admin_id` END) AS `TCreatePerson`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_allot' THEN '1' ELSE '0' END) AS `TallotOver`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_allot' THEN `plog`.`admin_id` END) AS `TallotPerson`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_allot' THEN `plog`.`createtime` END) AS `Tallot`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_commit_order' THEN '1' ELSE '0' END) AS `TgetorderOver`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_commit_order' THEN `slog`.`admin_id` ELSE NULL END) AS `TgetorderPerson`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_commit_order' THEN `slog`.`createtime` END) AS `Tgetorder`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_receive_order' THEN '1' ELSE '0' END) AS `TmaterialOver`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_receive_order' THEN `plog`.`admin_id` END) AS `TmaterialPerson`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_receive_order' THEN `plog`.`createtime` END) AS `Tmaterial`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pick_cargo' THEN '1' ELSE '0' END) AS `TpurchaseOver`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pick_cargo' THEN `slog`.`admin_id` ELSE NULL END) AS `TpurchasePerson`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pick_cargo' THEN `slog`.`createtime` ELSE NULL END) AS `Tpurchase`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pay' THEN '1' ELSE '0' END) AS `TpayOver`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pay' THEN `slog`.`admin_id` ELSE NULL END) AS `TpayPerson`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pay' THEN `slog`.`createtime` ELSE NULL END) AS `Tpay`,
    MAX(CASE `slog`.`state_value` WHEN 'finish' THEN '1' ELSE '0' END) AS `TchangeOver`,
    MAX(CASE `slog`.`state_value` WHEN 'finish' THEN `slog`.`admin_id` END) AS `TchangePerson`,
    MAX(CASE `slog`.`state_value` WHEN 'finish' THEN `slog`.`createtime` END) AS `Tchange`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_return_fee' THEN '1' ELSE '0' END) AS `TexpenseOver`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_return_fee' THEN `plog`.`admin_id` END) AS `TexpensePerson`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_return_fee' THEN `plog`.`createtime` END) AS `Texpense`,
    NULL AS `TsortOver`,
    NULL AS `TsortPerson`,
    NULL AS `Tsort`,
    NULL AS `TallowOver`,
    NULL AS `TallowPerson`,
    NULL AS `Tallow`,
    MAX(CASE `plog`.`state_value` WHEN 'finish' THEN '1' ELSE '0' END) AS `TcheckOver`,
    MAX(CASE `plog`.`state_value` WHEN 'finish' THEN `plog`.`admin_id` ELSE NULL END) AS `TcheckPerson`,
    MAX(CASE `plog`.`state_value` WHEN 'finish' THEN `plog`.`createtime` ELSE NULL END) AS `Tcheck`,
    `p`.`state` AS `NowState`
FROM
    (
        (
            (`test_lvhuan`.`uct_waste_sell` `s`
            JOIN `test_lvhuan`.`uct_waste_sell_log` `slog`)
            JOIN `test_lvhuan`.`uct_waste_purchase` `p`
        )
        JOIN `test_lvhuan`.`uct_waste_purchase_log` `plog`
    )
WHERE
    (
        (`s`.`id` = `slog`.`sell_id`)
        AND (`s`.`order_id` = `p`.`order_id`)
        AND (`p`.`id` = `plog`.`purchase_id`)
        AND (`slog`.`is_timeline_data` = '1')
    )
GROUP BY `p`.`order_id`;


DROP VIEW IF EXISTS `test_lvhuan`.`test_6`;
CREATE VIEW `test_lvhuan`.`test_6` AS
SELECT
    `test_lvhuan`.`uct_waste_customer`.`id` AS `id`,
    `test_lvhuan`.`uct_waste_customer`.`admin_id` AS `admin_id`,
    `test_lvhuan`.`uct_waste_customer`.`branch_id` AS `branch_id`,
    `test_lvhuan`.`uct_waste_customer`.`name` AS `name`,
    STRING_AGG(DISTINCT `test_lvhuan`.`uct_waste_purchase`.`seller_id`, ',') AS `admin_user`,
    MAX(`test_lvhuan`.`uct_waste_purchase`.`createtime`) AS `new_time`
FROM
    (
        `test_lvhuan`.`uct_waste_customer`
        JOIN `test_lvhuan`.`uct_waste_purchase`
    )
WHERE
    (
        (`test_lvhuan`.`uct_waste_customer`.`customer_type` = 'up')
        AND (`test_lvhuan`.`uct_waste_customer`.`state` = 'enabled')
        AND (`test_lvhuan`.`uct_waste_purchase`.`customer_id` = `test_lvhuan`.`uct_waste_customer`.`id`)
        AND (`test_lvhuan`.`uct_waste_customer`.`branch_id` <> 7)
        AND (`test_lvhuan`.`uct_waste_customer`.`branch_id` <> 11)
        AND (`test_lvhuan`.`uct_waste_customer`.`branch_id` <> 14)
        AND (`test_lvhuan`.`uct_waste_customer`.`branch_id` <> 12)
        AND (`test_lvhuan`.`uct_waste_customer`.`branch_id` <> 6)
    )
GROUP BY `test_lvhuan`.`uct_waste_customer`.`id`;



DROP VIEW IF EXISTS `test_lvhuan`.`trans_assist`;
CREATE VIEW `test_lvhuan`.`trans_assist` AS
SELECT
    `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `FInterID`,
    'PUR' AS `FTranType`,
    `test_lvhuan`.`uct_waste_purchase_cargo`.`id` AS `FEntryID`,
    `test_lvhuan`.`uct_waste_purchase_cargo`.`cate_id` AS `FItemID`,
    '1' AS `FUnitID`,
    `test_lvhuan`.`uct_waste_purchase_cargo`.`net_weight` AS `FQty`,
    `test_lvhuan`.`uct_waste_purchase_cargo`.`unit_price` AS `FPrice`,
    ROUND(`test_lvhuan`.`uct_waste_purchase_cargo`.`total_price`, 2) AS `FAmount`,
    '' AS `disposal_way`,
    `test_lvhuan`.`uct_waste_cate`.`value_type` AS `value_type`,
    NULL AS `FbasePrice`,
    NULL AS `FbaseAmount`,
    NULL AS `Ftaxrate`,
    NULL AS `Fbasetax`,
    NULL AS `Fbasetaxamount`,
    NULL AS `FPriceRef`,
    DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`uct_waste_purchase_cargo`.`createtime`), '%Y-%m-%d %H:%i:%S') AS `FDCTime`,
    NULL AS `FSourceInterID`,
    NULL AS `FSourceTranType`
FROM
    (`test_lvhuan`.`uct_waste_purchase_cargo`
    JOIN `test_lvhuan`.`uct_waste_cate`) 
WHERE
    (`test_lvhuan`.`uct_waste_purchase_cargo`.`cate_id` = `test_lvhuan`.`uct_waste_cate`.`id`)
UNION ALL
SELECT
    `test_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `FInterID`,
    'SOR' AS `FTranType`,
    `test_lvhuan`.`uct_waste_storage_sort`.`id` AS `FEntryID`,
    `test_lvhuan`.`uct_waste_storage_sort`.`cargo_sort` AS `FItemID`,
    '1' AS `FUnitID`,
    `test_lvhuan`.`uct_waste_storage_sort`.`net_weight` AS `FQty`,
    `test_lvhuan`.`uct_waste_storage_sort`.`presell_price` AS `FPrice`,
    ROUND((`test_lvhuan`.`uct_waste_storage_sort`.`presell_price` * `test_lvhuan`.`uct_waste_storage_sort`.`net_weight`), 2) AS `FAmount`,
    `test_lvhuan`.`uct_waste_storage_sort`.`disposal_way` AS `disposal_way`,
    `test_lvhuan`.`uct_waste_storage_sort`.`value_type` AS `value_type`,
    NULL AS `FbasePrice`,
    NULL AS `FbaseAmount`,
    NULL AS `Ftaxrate`,
    NULL AS `Fbasetax`,
    NULL AS `Fbasetaxamount`,
    NULL AS `FPriceRef`,
    DATE_FORMAT(FROM_UNIXTIME(IF((`test_lvhuan`.`uct_waste_storage_sort`.`sort_time` > `test_lvhuan`.`uct_waste_storage_sort`.`createtime`), `test_lvhuan`.`uct_waste_storage_sort`.`sort_time`, `test_lvhuan`.`uct_waste_storage_sort`.`createtime`)), '%Y-%m-%d %H:%i:%S') AS `FDCTime`,
    NULL AS `FSourceInterID`,
    NULL AS `FSourceTranType`
FROM
    `test_lvhuan`.`uct_waste_storage_sort`
UNION ALL
SELECT
    `test_lvhuan`.`uct_waste_sell_cargo`.`sell_id` AS `FInterID`,
    'SEL' AS `FTranType`,
    `test_lvhuan`.`uct_waste_sell_cargo`.`id` AS `FEntryID`,
    `test_lvhuan`.`uct_waste_sell_cargo`.`cate_id` AS `FItemID`,
    '1' AS `FUnitID`,
    `test_lvhuan`.`uct_waste_sell_cargo`.`net_weight` AS `FQty`,
    `test_lvhuan`.`uct_waste_sell_cargo`.`unit_price` AS `FPrice`,
    ROUND((`test_lvhuan`.`uct_waste_sell_cargo`.`unit_price` * `test_lvhuan`.`uct_waste_sell_cargo`.`net_weight`), 2) AS `FAmount`,
    '' AS `disposal_way`,
    `test_lvhuan`.`uct_waste_cate`.`value_type` AS `value_type`,
    NULL AS `FbasePrice`,
    NULL AS `FbaseAmount`,
    NULL AS `Ftaxrate`,
    NULL AS `Fbasetax`,
    NULL AS `Fbasetaxamount`,
    NULL AS `FPriceRef`,
    DATE_FORMAT(FROM_UNIXTIME(`test_lvhuan`.`uct_waste_sell_cargo`.`createtime`), '%Y-%m-%d %H:%i:%S') AS `FDCTime`,
    NULL AS `FSourceInterID`,
    NULL AS `FSourceTranType`
FROM
    ((`test_lvhuan`.`uct_waste_sell_cargo`
    JOIN `test_lvhuan`.`uct_waste_sell`)
    JOIN `test_lvhuan`.`uct_waste_cate`)
WHERE
    (`test_lvhuan`.`uct_waste_sell_cargo`.`sell_id` = `test_lvhuan`.`uct_waste_sell`.`id`);



DROP VIEW IF EXISTS `test_lvhuan`.`trans_month_sel_rank`;
CREATE VIEW `test_lvhuan`.`trans_month_sel_rank` as select `sel_rank`.`FRelateBrID` AS `FRelateBrID`,`sel_rank`.`FItemID` AS `FItemID`,`sel_rank`.`total_weight` AS `total_weight`,`sel_rank`.`total_price` AS `total_price`,`sel_rank`.`FDate` AS `FDate` from (select `trans_main`.`FRelateBrID` AS `FRelateBrID`,`trans_assist`.`FItemID` AS `FItemID`,round(sum(`trans_assist`.`FQty`),1) AS `total_weight`,round(sum(`trans_assist`.`FAmount`),2) AS `total_price`,date_format(`trans_main`.`FDate`,'%Y-%m-%d') AS `FDate` from (`test_lvhuan`.`trans_main` join `test_lvhuan`.`trans_assist`) where ((`trans_main`.`FTranType` = 'SEL') and (`trans_main`.`FInterID` = `trans_assist`.`FInterID`) and (date_format(`trans_main`.`FDate`,'%Y-%m-%d') > 0) and (`trans_assist`.`FTranType` = 'SEL') and (`trans_main`.`FStatus` = 1)) group by `trans_main`.`FRelateBrID`,date_format(`trans_main`.`FDate`,'%Y-%m-%d'),`trans_assist`.`FItemID`) `sel_rank` where (not(`sel_rank`.`FDate` in (select `test_lvhuan`.`trans_month_sel_rank_table`.`FDate` from `test_lvhuan`.`trans_month_sel_rank_table`)));


DROP VIEW IF EXISTS `test_lvhuan`.`view_test_cargo_list`;
CREATE VIEW `test_lvhuan`.`view_test_cargo_list` AS 
SELECT 
    `trans_assist`.`FInterID` AS `FInterID`,
    `trans_assist`.`FItemID` AS `FItemID`,
    GROUP_CONCAT(
        CONCAT_WS(
            '', 
            (CASE `trans_assist`.`FTranType` WHEN 'PUR' THEN CONCAT('采购净重', `trans_assist`.`FQty`) END),
            (CASE `trans_assist`.`FTranType` WHEN 'PUR' THEN CONCAT('采购价', `trans_assist`.`FPrice`) END)
        ) SEPARATOR E'\r\n'
    ) AS `PUR_log`,
    ROUND(SUM(CASE `trans_assist`.`FTranType` WHEN 'PUR' THEN `trans_assist`.`FQty` ELSE 0 END), 1) AS `PUR_FQty`,
    ROUND(SUM(CASE `trans_assist`.`FTranType` WHEN 'PUR' THEN `trans_assist`.`FAmount` ELSE 0 END), 2) AS `PUR_FAmount`
FROM `test_lvhuan`.`trans_assist` 
WHERE `trans_assist`.`FTranType` = 'PUR';


CREATE VIEW `test_lvhuan`.`test_fee_view` AS
SELECT
    `basep`.`id` AS `FInterID`,
    COALESCE(`pf`.`pick_fee`, NULL) AS `PickFee`,
    COALESCE(`rf`.`car_fee`, NULL) AS `CarFee`,
    COALESCE(`rf`.`man_fee`, NULL) AS `ManFee`,
    COALESCE(`sg`.`sort_fee`, NULL) AS `SortFee`,
    COALESCE(`sg`.`other_sort_fee`, NULL) AS `OtherSortFee`
FROM
    (
        (`test_lvhuan`.`uct_waste_purchase` `basep`
        LEFT JOIN `test_lvhuan`.`trans_total_fee_rf` `rf` ON (`basep`.`id` = `rf`.`purchase_id`))
        LEFT JOIN `test_lvhuan`.`trans_total_fee_sg` `sg` ON (`basep`.`id` = `sg`.`purchase_id`)
    )
    LEFT JOIN `test_lvhuan`.`trans_total_fee_pf` `pf` ON (`basep`.`id` = `pf`.`purchase_id`);



DROP VIEW IF EXISTS `test_lvhuan`.`test_views`;
CREATE VIEW `test_lvhuan`.`test_views` AS
SELECT
    `pe`.`purchase_id` AS `purchase_id`,
    COALESCE(`pe`.`usage`, NULL) AS `usage`,
    COALESCE(`pe`.`price`, NULL) AS `price`,
    COALESCE(`p`.`purchase_time`, NULL) AS `purchase_time`,
    COALESCE(`p`.`cargo_price`, NULL) AS `cargo_price`,
    COALESCE(`p`.`cargo_weight`, NULL) AS `cargo_weight`,
    COALESCE(`p`.`sort_expense`, NULL) AS `sort_expense`
FROM
    (`test_lvhuan`.`uct_waste_purchase_expense` `pe`
    LEFT JOIN `test_lvhuan`.`uct_waste_purchase` `p` ON (`pe`.`purchase_id` = `p`.`purchase_id`));


DROP VIEW IF EXISTS `test_lvhuan`.`trans_finishcount`;
CREATE VIEW `test_lvhuan`.`trans_finishcount` AS
SELECT
    `test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
    `test_lvhuan`.`trans_main_table`.`FDeptID` AS `FDeptID`,
    CAST('-' AS VARCHAR) AS `FEmpID`,
    (SUM(`test_lvhuan`.`trans_main_table`.`FCancellation`) - SUM(`test_lvhuan`.`trans_main_table`.`FCorrent`)) AS `Unfinished`
FROM
    `test_lvhuan`.`trans_main_table`
WHERE
    (DATE_FORMAT(`test_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') >= DATE_FORMAT('2019-01-01', '%Y-%m-%d'))
    AND (`test_lvhuan`.`trans_main_table`.`FTranType` = 'PUR')
GROUP BY
    `test_lvhuan`.`trans_main_table`.`FRelateBrID`,
    `test_lvhuan`.`trans_main_table`.`FDeptID`,
    `FEmpID`
UNION ALL
SELECT
    `test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
    '3' AS `FDeptID`,
    CAST('-' AS VARCHAR) AS `FEmpID`,
    (SUM(`test_lvhuan`.`trans_main_table`.`FCancellation`) - SUM(`test_lvhuan`.`trans_main_table`.`FUpStockWhenSave`)) AS `Unfinished`
FROM
    `test_lvhuan`.`trans_main_table`
WHERE
    (`test_lvhuan`.`trans_main_table`.`FTranType` = 'SOR')
    AND (`test_lvhuan`.`trans_main_table`.`FCancellation` = 1)
GROUP BY
    `test_lvhuan`.`trans_main_table`.`FRelateBrID`;



DROP VIEW IF EXISTS `test_lvhuan`.`view_sort_expense_collect`;
CREATE VIEW `test_lvhuan`.`view_sort_expense_collect` AS
SELECT
    `view_sec`.`purchase_id` AS `purchase_id`,
    ROUND(SUM(CASE `view_sec`.`usage` WHEN '资源池分拣人工' THEN `view_sec`.`price` ELSE 0 END), 2) AS `仓库分拣人工`,
    -- 其它列的类似修复...
    GROUP_CONCAT(CASE `view_sec`.`usage` WHEN '其他' THEN `view_sec`.`remark` ELSE '' END SEPARATOR '') AS `其他入库费用说明`
FROM (
    SELECT
        `test_lvhuan`.`uct_waste_storage_expense`.`id` AS `id`,
        `test_lvhuan`.`uct_waste_storage_expense`.`purchase_id` AS `purchase_id`,
        `test_lvhuan`.`uct_waste_storage_expense`.`type` AS `type`,
        `test_lvhuan`.`uct_waste_storage_expense`.`usage` AS `usage`,
        `test_lvhuan`.`uct_waste_storage_expense`.`remark` AS `remark`,
        `test_lvhuan`.`uct_waste_storage_expense`.`price` AS `price`,
        `test_lvhuan`.`uct_waste_storage_expense`.`receiver` AS `receiver`,
        `test_lvhuan`.`uct_waste_storage_expense`.`createtime` AS `createtime`,
        `test_lvhuan`.`uct_waste_storage_expense`.`updatetime` AS `updatetime`
    FROM `test_lvhuan`.`uct_waste_storage_expense`
    UNION ALL
    SELECT
        `test_lvhuan`.`uct_waste_storage_sort_expense`.`id` AS `id`,
        `test_lvhuan`.`uct_waste_storage_sort_expense`.`purchase_id` AS `purchase_id`,
        `test_lvhuan`.`uct_waste_storage_sort_expense`.`type` AS `type`,
        `test_lvhuan`.`uct_waste_storage_sort_expense`.`usage` AS `usage`,
        `test_lvhuan`.`uct_waste_storage_sort_expense`.`remark` AS `remark`,
        `test_lvhuan`.`uct_waste_storage_sort_expense`.`price` AS `price`,
        `test_lvhuan`.`uct_waste_storage_sort_expense`.`receiver` AS `receiver`,
        `test_lvhuan`.`uct_waste_storage_sort_expense`.`createtime` AS `createtime`,
        `test_lvhuan`.`uct_waste_storage_sort_expense`.`updatetime` AS `updatetime`
    FROM `test_lvhuan`.`uct_waste_storage_sort_expense`
) `view_sec`
GROUP BY `view_sec`.`purchase_id`;



DROP VIEW IF EXISTS `test_lvhuan`.`view_customer`;
CREATE VIEW `test_lvhuan`.`view_customer` AS
SELECT
    `test_lvhuan`.`uct_admin`.`nickname` AS `第一负责人`,
    `test_lvhuan`.`uct_admin`.`mobile` AS `第一负责人电话`,
    `bb`.`分部归属` AS `分部归属`,
    `bb`.`公司名称` AS `公司名称`,
    `bb`.`业务员` AS `业务员`,
    `bb`.`部门归属` AS `部门归属`
FROM
    (
        (
            (
                SELECT
                    SUBSTRING_INDEX(`test_lvhuan`.`uct_waste_customer`.`admin_id`, ',', -(1)) AS `admin_id1`,
                    (
                        CASE `test_lvhuan`.`uct_waste_customer`.`branch_id`
                            WHEN 1 THEN '深圳宝安分部'
                            WHEN 2 THEN '成都崇州分部'
                            WHEN 3 THEN '昆山张浦分部'
                            WHEN 4 THEN '厦门翔安分部'
                            WHEN 5 THEN '东莞黄江分部'
                            WHEN 8 THEN '东莞横沥分部'
                            WHEN 9 THEN '东莞大岭山分部'
                            WHEN 10 THEN '东莞凤岗分部'
                            ELSE ''
                        END
                    ) AS `分部归属`,
                    `test_lvhuan`.`uct_waste_customer`.`name` AS `公司名称`,
                    `test_lvhuan`.`uct_admin`.`nickname` AS `业务员`,
                    (
                        CASE `test_lvhuan`.`uct_waste_customer`.`service_department`
                            WHEN '1' THEN '客服部'
                            WHEN '2' THEN '企服部'
                        END
                    ) AS `部门归属`
                FROM
                    (
                        `test_lvhuan`.`uct_waste_customer`
                        JOIN `test_lvhuan`.`uct_admin`
                    )
                WHERE
                    (
                        (`test_lvhuan`.`uct_waste_customer`.`customer_type` = 'up')
                        AND (`test_lvhuan`.`uct_waste_customer`.`manager_id` = `test_lvhuan`.`uct_admin`.`id`)
                        AND (`test_lvhuan`.`uct_waste_customer`.`state` = 'enabled')
                    )
            )
        ) `bb`
        JOIN `test_lvhuan`.`uct_admin`
    )
WHERE
    (`bb`.`admin_id1` = `test_lvhuan`.`uct_admin`.`id`);
	
	
	
DROP VIEW IF EXISTS `test_lvhuan`.`trans_total_fee`;
CREATE VIEW `test_lvhuan`.`trans_total_fee` AS
SELECT
    `basep`.`id` AS `FInterID`,
    'PUR' AS `FTranType`,
    CASE WHEN `pf`.`customer_profit` IS NULL THEN 0 ELSE `pf`.`customer_profit` END AS `CustomerProfit`,
    CASE WHEN `pf`.`other_profit` IS NULL THEN 0 ELSE `pf`.`other_profit` END AS `OtherProfit`,
    CASE WHEN `pf`.`pick_fee` IS NULL THEN 0 ELSE `pf`.`pick_fee` END AS `PickFee`,
    CASE WHEN `rf`.`car_fee` IS NULL THEN 0 ELSE `rf`.`car_fee` END AS `CarFee`,
    CASE WHEN `rf`.`man_fee` IS NULL THEN 0 ELSE `rf`.`man_fee` END AS `ManFee`,
    CASE WHEN `rf`.`other_return_fee` IS NULL THEN 0 ELSE `rf`.`other_return_fee` END AS `OtherReturnfee`,
    CASE WHEN `sg`.`sort_fee` IS NULL THEN 0 ELSE `sg`.`sort_fee` END AS `SortFee`,
    ROUND(
        CASE WHEN `sg`.`materiel_fee` IS NULL THEN 0 ELSE `sg`.`materiel_fee` END
        + CASE WHEN `basep`.`materiel_price` IS NULL THEN 0 ELSE `basep`.`materiel_price` END, 2
    ) AS `MaterielFee`,
    CASE WHEN `sg`.`other_sort_fee` IS NULL THEN 0 ELSE `sg`.`other_sort_fee` END AS `OtherSortfee`,
    CASE WHEN `sf`.`sell_profit` IS NULL THEN 0 ELSE `sf`.`sell_profit` END AS `SellProfit`,
    CASE WHEN `sf`.`sell_fee` IS NULL THEN 0 ELSE `sf`.`sell_fee` END AS `SellFee`
FROM
    (
        (
            (
                (
                    (
                        `test_lvhuan`.`uct_waste_purchase` `basep`
                        LEFT JOIN `test_lvhuan`.`trans_total_fee_rf` `rf`
                        ON (`basep`.`id` = `rf`.`purchase_id`)
                    )
                    LEFT JOIN `test_lvhuan`.`trans_total_fee_sg` `sg`
                    ON (`basep`.`id` = `sg`.`purchase_id`)
                )
                LEFT JOIN `test_lvhuan`.`trans_total_fee_pf` `pf`
                ON (`basep`.`id` = `pf`.`purchase_id`)
            )
            LEFT JOIN `test_lvhuan`.`trans_total_fee_sf` `sf`
            ON (`basep`.`id` = `sf`.`purchase_id`)
        )
    )
UNION ALL
SELECT
    `osf`.`sell_id` AS `FInterID`,
    'SEL' AS `FTranType`,
    0 AS `CustomerProfit`,
    0 AS `OtherProfit`,
    0 AS `PickFee`,
    0 AS `CarFee`,
    0 AS `ManFee`,
    0 AS `OtherReturnfee`,
    0 AS `SortFee`,
    0 AS `MaterielFee`,
    0 AS `OtherSortfee`,
    CASE WHEN `osf`.`sell_profit` IS NULL THEN 0 ELSE `osf`.`sell_profit` END AS `SellProfit`,
    CASE WHEN `osf`.`sell_fee` IS NULL THEN 0 ELSE `osf`.`sell_fee` END AS `SellFee`
FROM
    `test_lvhuan`.`trans_total_fee_osf` `osf`;



DROP VIEW IF EXISTS `test_lvhuan`.`trans_ordercount`;
CREATE VIEW `test_lvhuan`.`trans_ordercount` AS
SELECT
    `test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
    `test_lvhuan`.`trans_main_table`.`FDeptID` AS `FDeptID`,
    `test_lvhuan`.`trans_main_table`.`FEmpID` AS `FEmpID`,
    COUNT(`test_lvhuan`.`trans_main_table`.`FBillNo`) AS `orderCount`,
    DATE_FORMAT(`test_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') AS `FDate`
FROM
    `test_lvhuan`.`trans_main_table`
WHERE
    (`test_lvhuan`.`trans_main_table`.`FTranType` = 'PUR')
GROUP BY
    DATE_FORMAT(`test_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d'),
    `test_lvhuan`.`trans_main_table`.`FRelateBrID`,
    `test_lvhuan`.`trans_main_table`.`FDeptID`,
    `test_lvhuan`.`trans_main_table`.`FEmpID`
HAVING
    (DATE_FORMAT(`FDate`, '%Y-%m-%d') >= DATE_FORMAT('2018-07-01', '%Y-%m-%d'))
UNION ALL
SELECT
    `test_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
    '3' AS `FDeptID`,
    0 AS `FEmpID`, -- Replace '-' with 0 or another integer
    COUNT(`test_lvhuan`.`trans_main_table`.`FBillNo`) AS `orderCount`,
    DATE_FORMAT(`test_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') AS `FDate`
FROM
    `test_lvhuan`.`trans_main_table`
WHERE
    (`test_lvhuan`.`trans_main_table`.`FTranType` = 'SOR')
GROUP BY
    DATE_FORMAT(`test_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d'),
    `test_lvhuan`.`trans_main_table`.`FRelateBrID`
HAVING
    (DATE_FORMAT(`FDate`, '%Y-%m-%d') >= DATE_FORMAT('2018-07-01', '%Y-%m-%d'));



DROP VIEW IF EXISTS `test_lvhuan`.`trans_total_cargo`;
CREATE VIEW `test_lvhuan`.`trans_total_cargo` AS
SELECT
    `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `FInterID`,
    'PUR' AS `FTranType`,
    SUM(`test_lvhuan`.`uct_waste_purchase_cargo`.`net_weight`) AS `FQtyTotal`,
    ROUND(SUM(`test_lvhuan`.`uct_waste_purchase_cargo`.`total_price`), 2) AS `FAmountTotal`,
    NULL AS `FSourceInterId`,
    NULL AS `FSourceTranType`
FROM
    `test_lvhuan`.`uct_waste_purchase_cargo`
GROUP BY
    `test_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`
UNION ALL
SELECT
    `test_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `FInterID`,
    'SOR' AS `FTranType`,
    SUM(`test_lvhuan`.`uct_waste_storage_sort`.`net_weight`) AS `FQtyTotal`,
    ROUND(SUM(`test_lvhuan`.`uct_waste_storage_sort`.`net_weight` * `test_lvhuan`.`uct_waste_storage_sort`.`presell_price`), 2) AS `FAmountTotal`,
    `test_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `FSourceInterId`,
    'PUR' AS `FSourceTranType`
FROM
    `test_lvhuan`.`uct_waste_storage_sort`
GROUP BY
    `test_lvhuan`.`uct_waste_storage_sort`.`purchase_id`
UNION ALL
SELECT
    `test_lvhuan`.`uct_waste_sell_cargo`.`sell_id` AS `FInterID`,
    'SEL' AS `FTranType`,
    SUM(`test_lvhuan`.`uct_waste_sell_cargo`.`net_weight`) AS `FQtyTotal`,
    ROUND(SUM(`test_lvhuan`.`uct_waste_sell_cargo`.`net_weight` * `test_lvhuan`.`uct_waste_sell_cargo`.`unit_price`), 2) AS `FAmountTotal`,
    COALESCE(`test_lvhuan`.`uct_waste_sell`.`purchase_id`, NULL) AS `FSourceInterId`,
    'PUR' AS `FSourceTranType`
FROM
    (`test_lvhuan`.`uct_waste_sell_cargo`
    JOIN `test_lvhuan`.`uct_waste_sell`)
WHERE
    (`test_lvhuan`.`uct_waste_sell`.`id` = `test_lvhuan`.`uct_waste_sell_cargo`.`sell_id`)
GROUP BY
    `test_lvhuan`.`uct_waste_sell_cargo`.`sell_id`;


DROP VIEW IF EXISTS `test_lvhuan`.`trans_total_cargo_sec`;
CREATE VIEW `test_lvhuan`.`trans_total_cargo_sec` AS
SELECT
    `test_lvhuan`.`uct_waste_sell_cargo`.`sell_id` AS `FInterID`,
    'SEL' AS `FTranType`,
    SUM(`test_lvhuan`.`uct_waste_sell_cargo`.`net_weight`) AS `FQtyTotal`,
    ROUND(SUM(`test_lvhuan`.`uct_waste_sell_cargo`.`net_weight` * `test_lvhuan`.`uct_waste_sell_cargo`.`unit_price`), 2) AS `FAmountTotal`,
    COALESCE(`test_lvhuan`.`uct_waste_sell`.`purchase_id`, NULL) AS `FSourceInterId`,
    COALESCE(`test_lvhuan`.`uct_waste_sell`.`purchase_id`, NULL) AS `FSourceTranType`
FROM
    (`test_lvhuan`.`uct_waste_sell_cargo`
    JOIN `test_lvhuan`.`uct_waste_sell`)
WHERE
    (`test_lvhuan`.`uct_waste_sell`.`id` = `test_lvhuan`.`uct_waste_sell_cargo`.`sell_id`)
GROUP BY
    `test_lvhuan`.`uct_waste_sell_cargo`.`sell_id`;


DROP VIEW IF EXISTS `test_lvhuan`.`view_purchase_expense_collect`;
CREATE VIEW `test_lvhuan`.`view_purchase_expense_collect` AS
SELECT
    `test_lvhuan`.`uct_waste_purchase_expense`.`purchase_id` AS `purchase_id`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '供应商人工补助费' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END), 2) AS `供应商人工补助`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '供应商车辆补助费' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END), 2) AS `供应商车辆补助`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '供应商垃圾补助费' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END), 2) AS `供应商垃圾补助`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END), 2) AS `叉车费`,
    IF(SUM(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END) = MAX(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END),
        COALESCE(GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`receiver` ELSE NULL END SEPARATOR ''), ''),
        COALESCE(GROUP_CONCAT(CONCAT_WS('', CONVERT(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END USING utf8), CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`receiver` ELSE NULL END) SEPARATOR ''), '')) AS `叉车司机`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他收入' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END), 2) AS `其他提货收入`,
    IF(SUM(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他收入' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END) = MAX(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他收入' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END),
        COALESCE(GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他收入' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`receiver` ELSE NULL END SEPARATOR ''), ''),
        COALESCE(GROUP_CONCAT(CONCAT_WS('', CONVERT(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他收入' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END USING utf8), CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他收入' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`receiver` ELSE NULL END) SEPARATOR ''), '')) AS `其他提货收入收款人`,
    COALESCE(GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他收入' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`remark` ELSE NULL END SEPARATOR ''), '') AS `其他提货收入说明`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他支出' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END), 2) AS `其他提货支出`,
    IF(SUM(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他支出' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END) = MAX(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他支出' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END),
        COALESCE(GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他支出' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`receiver` ELSE NULL END SEPARATOR ''), ''),
        COALESCE(GROUP_CONCAT(CONCAT_WS('', CONVERT(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他支出' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`price` ELSE 0 END USING utf8), CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他支出' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`receiver` ELSE NULL END) SEPARATOR ''), '')) AS `其他提货支出收款人`,
    COALESCE(GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_purchase_expense`.`usage` WHEN '其他支出' THEN `test_lvhuan`.`uct_waste_purchase_expense`.`remark` ELSE NULL END SEPARATOR ''), '')
FROM `test_lvhuan`.`uct_waste_purchase_expense`
GROUP BY `test_lvhuan`.`uct_waste_purchase_expense`.`purchase_id`;



DROP VIEW IF EXISTS `test_lvhuan`.`view_reimbursement_expense_collect`;

CREATE VIEW `test_lvhuan`.`view_reimbursement_expense_collect` as
SELECT
    `test_lvhuan`.`uct_waste_storage_return_fee`.`purchase_id` AS `purchase_id`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '外请车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `外请车辆`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '公司车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `公司车辆`,
    GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage`
        WHEN '外请车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver`
        WHEN '公司车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver`
        ELSE ''
    END SEPARATOR '') AS `司机`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货专员人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `拉货专员人工`,
    IF(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货专员人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END) = MAX(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货专员人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END),
        GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货专员人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` ELSE '' END SEPARATOR ''),
        GROUP_CONCAT(CONCAT_WS('', CONVERT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货专员人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END USING utf8),
                         CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货专员人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` ELSE '' END) SEPARATOR '')
    ) AS `拉货专员姓名`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货助理人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `拉货助理人工`,
    IF(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货助理人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END) = MAX(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货助理人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END),
        GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货助理人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` ELSE '' END SEPARATOR ''),
        GROUP_CONCAT(CONCAT_WS('', CONVERT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货助理人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END USING utf8),
                         CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '拉货助理人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` ELSE '' END) SEPARATOR '')
    ) AS `拉货助理姓名`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '外请人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `外请人工`,
    IF(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '外请人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END) = MAX(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '外请人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END),
        GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '外请人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` ELSE '' END SEPARATOR ''),
        GROUP_CONCAT(CONCAT_WS('', CONVERT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '外请人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END USING utf8),
                         CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '外请人工' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` ELSE '' END) SEPARATOR '')
    ) AS `外请人工姓名`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `叉车费`,
    IF(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END) = MAX(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END),
        GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` ELSE '' END SEPARATOR ''),
        GROUP_CONCAT(CONCAT_WS('', CONVERT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END USING utf8),
                         CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '叉车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` ELSE '' END) SEPARATOR '')
    ) AS `叉车司机`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '停车费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `停车费`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '过路费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `过路费`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '磅费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `磅费`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '水费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `水费`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '餐费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `餐费`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '交通费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `交通费`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '住宿费' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `住宿费`,
    ROUND(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '其他' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END), 2) AS `其他报销费用`,
    IF(SUM(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '其他' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END) = MAX(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '其他' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END),
        GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '其他' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` ELSE '' END SEPARATOR ''),
        GROUP_CONCAT(CONCAT_WS('', CONVERT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '其他' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`price` ELSE 0 END USING utf8),
                         CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '其他' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`receiver` ELSE '' END) SEPARATOR '')
    ) AS `其他报销费用收款人`,
    GROUP_CONCAT(CASE `test_lvhuan`.`uct_waste_storage_return_fee`.`usage` WHEN '其他' THEN `test_lvhuan`.`uct_waste_storage_return_fee`.`remark` ELSE '' END SEPARATOR '') AS `其他报销费用说明`
FROM `test_lvhuan`.`uct_waste_storage_return_fee`
GROUP BY `test_lvhuan`.`uct_waste_storage_return_fee`.`purchase_id`;



DROP VIEW IF EXISTS `test_lvhuan`.`trans_log_new`;

CREATE VIEW `test_lvhuan`.`trans_log_new` AS
SELECT
    `log`.`purchase_id` AS `FInterID`,
    'PUR' AS `FTranType`,
    MAX(CASE `log`.`state_value` WHEN 'draft' THEN `log`.`createtime` END) AS `TCreate`,
    MAX(CASE `log`.`state_value` WHEN 'draft' THEN `log`.`admin_id` END) AS `TCreatePerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_allot' THEN '1' ELSE '0' END) AS `TallotOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_allot' THEN `log`.`admin_id` ELSE 0 END) AS `TallotPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_allot' THEN `log`.`createtime` ELSE 0 END) AS `Tallot`,
    MAX(CASE `log`.`state_value` WHEN 'wait_receive_order' THEN '1' ELSE '0' END) AS `TgetorderOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_receive_order' THEN `log`.`admin_id` ELSE 0 END) AS `TgetorderPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_receive_order' THEN `log`.`createtime` ELSE 0 END) AS `Tgetorder`,
    MAX(CASE `log`.`state_value` WHEN 'wait_signin_materiel' THEN '1' ELSE '0' END) AS `TmaterialOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_signin_materiel' THEN `log`.`admin_id` ELSE 0 END) AS `TmaterialPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_signin_materiel' THEN `log`.`createtime` ELSE 0 END) AS `Tmaterial`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pick_cargo' THEN '1' ELSE '0' END) AS `TpurchaseOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pick_cargo' THEN `log`.`admin_id` ELSE 0 END) AS `TpurchasePerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pick_cargo' THEN `log`.`createtime` ELSE 0 END) AS `Tpurchase`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pay' THEN '1' ELSE '0' END) AS `TpayOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pay' THEN `log`.`admin_id` ELSE 0 END) AS `TpayPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pay' THEN `log`.`createtime` ELSE 0 END) AS `Tpay`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect' THEN '1' ELSE '0' END) AS `TchangeOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect' THEN `log`.`admin_id` ELSE 0 END) AS `TchangePerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect' THEN `log`.`createtime` ELSE 0 END) AS `Tchange`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect_confirm' THEN '1' ELSE '0' END) AS `TexpenseOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect_confirm' THEN `log`.`admin_id` ELSE 0 END) AS `TexpensePerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect_confirm' THEN `log`.`createtime` ELSE 0 END) AS `Texpense`,
    0 AS `TsortOver`,
    0 AS `TsortPerson`,
    0 AS `Tsort`,
    0 AS `TallowOver`,
    0 AS `TallowPerson`,
    MAX(CASE `log`.`state_value` WHEN 'finish' THEN '1' ELSE '0' END) AS `TcheckOver`,
    MAX(CASE `log`.`state_value` WHEN 'finish' THEN `log`.`admin_id` ELSE 0 END) AS `TcheckPerson`,
    MAX(CASE `log`.`state_value` WHEN 'finish' THEN `log`.`createtime` ELSE 0 END) AS `Tcheck`,
    `test_lvhuan`.`uct_waste_purchase`.`state` AS `NowState`
FROM (`test_lvhuan`.`uct_waste_purchase` JOIN `test_lvhuan`.`uct_waste_purchase_log` `log`)
WHERE (
    `test_lvhuan`.`uct_waste_purchase`.`id` = `log`.`purchase_id`
    AND `test_lvhuan`.`uct_waste_purchase`.`hand_mouth_data` = '0'
    AND `test_lvhuan`.`uct_waste_purchase`.`give_frame` = '0'
)
GROUP BY `test_lvhuan`.`uct_waste_purchase`.`id`

UNION ALL

SELECT
    `log`.`purchase_id` AS `FInterID`,
    'PUR' AS `FTranType`,
    MAX(CASE `log`.`state_value` WHEN 'draft' THEN `log`.`createtime` END) AS `TCreate`,
    MAX(CASE `log`.`state_value` WHEN 'draft' THEN `log`.`admin_id` END) AS `TCreatePerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_allot' THEN '1' ELSE '0' END) AS `TallotOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_allot' THEN `log`.`admin_id` ELSE 0 END) AS `TallotPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_allot' THEN `log`.`createtime` ELSE 0 END) AS `Tallot`,
    MAX(CASE `log`.`state_value` WHEN 'wait_receive_order' THEN '1' ELSE '0' END) AS `TgetorderOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_receive_order' THEN `log`.`admin_id` ELSE 0 END) AS `TgetorderPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_receive_order' THEN `log`.`createtime` ELSE 0 END) AS `Tgetorder`,
    MAX(CASE `log`.`state_value` WHEN 'wait_signin_materiel' THEN '1' ELSE '0' END) AS `TmaterialOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_signin_materiel' THEN `log`.`admin_id` ELSE 0 END) AS `TmaterialPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_signin_materiel' THEN `log`.`createtime` ELSE 0 END) AS `Tmaterial`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pick_cargo' THEN '1' ELSE '0' END) AS `TpurchaseOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pick_cargo' THEN `log`.`admin_id` ELSE 0 END) AS `TpurchasePerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pick_cargo' THEN `log`.`createtime` ELSE 0 END) AS `Tpurchase`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pay' THEN '1' ELSE '0' END) AS `TpayOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pay' THEN `log`.`admin_id` ELSE 0 END) AS `TpayPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pay' THEN `log`.`createtime` ELSE 0 END) AS `Tpay`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect' THEN '1' ELSE '0' END) AS `TchangeOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect' THEN `log`.`admin_id` ELSE 0 END) AS `TchangePerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect' THEN `log`.`createtime` ELSE 0 END) AS `Tchange`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect_confirm' THEN '1' ELSE '0' END) AS `TexpenseOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect_confirm' THEN `log`.`admin_id` ELSE 0 END) AS `TexpensePerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_storage_connect_confirm' THEN `log`.`createtime` ELSE 0 END) AS `Texpense`,
    0 AS `TsortOver`,
    0 AS `TsortPerson`,
    0 AS `Tsort`,
    0 AS `TallowOver`,
    0 AS `TallowPerson`,
    MAX(CASE `log`.`state_value` WHEN 'finish' THEN '1' ELSE '0' END) AS `TcheckOver`,
    MAX(CASE `log`.`state_value` WHEN 'finish' THEN `log`.`admin_id` ELSE 0 END) AS `TcheckPerson`,
    MAX(CASE `log`.`state_value` WHEN 'finish' THEN `log`.`createtime` ELSE 0 END) AS `Tcheck`,
    `test_lvhuan`.`uct_waste_purchase`.`state` AS `NowState`
FROM (`test_lvhuan`.`uct_waste_purchase` JOIN `test_lvhuan`.`uct_waste_purchase_log` `log`)
WHERE (
    `test_lvhuan`.`uct_waste_purchase`.`id` = `log`.`purchase_id`
    AND `test_lvhuan`.`uct_waste_purchase`.`hand_mouth_data` = '0'
    AND `test_lvhuan`.`uct_waste_purchase`.`give_frame` = '1'
)
GROUP BY `test_lvhuan`.`uct_waste_purchase`.`id`

UNION ALL

SELECT
    `log`.`sell_id` AS `FInterID`,
    'SEL' AS `FTranType`,
    MAX(CASE `log`.`state_value` WHEN 'draft' THEN `log`.`createtime` END) AS `TCreate`,
    MAX(CASE `log`.`state_value` WHEN 'draft' THEN `log`.`admin_id` END) AS `TCreatePerson`,
    0 AS `TallotOver`,
    0 AS `TallotPerson`,
    0 AS `Tallot`,
    0 AS `TgetorderOver`,
    0 AS `TgetorderPerson`,
    0 AS `Tgetorder`,
    0 AS `TmaterialOver`,
    0 AS `TmaterialPerson`,
    0 AS `Tmaterial`,
    MAX(CASE `log`.`state_value` WHEN 'wait_weigh' THEN '1' ELSE '0' END) AS `TpurchaseOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_weigh' THEN `log`.`admin_id` ELSE 0 END) AS `TpurchasePerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_weigh' THEN `log`.`createtime` ELSE 0 END) AS `Tpurchase`,
    MAX(CASE `log`.`state_value` WHEN 'wait_confirm_order' THEN '1' ELSE '0' END) AS `TpayOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_confirm_order' THEN `log`.`admin_id` ELSE 0 END) AS `TpayPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_confirm_order' THEN `log`.`createtime` ELSE 0 END) AS `Tpay`,
    0 AS `TchangeOver`,
    0 AS `TchangePerson`,
    0 AS `Tchange`,
    0 AS `TexpenseOver`,
    0 AS `TexpensePerson`,
    0 AS `Texpense`,
    0 AS `TsortOver`,
    0 AS `TsortPerson`,
    0 AS `Tsort`,
    0 AS `TallowOver`,
    0 AS `TallowPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pay' THEN '1' ELSE '0' END) AS `TcheckOver`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pay' THEN `log`.`admin_id` ELSE 0 END) AS `TcheckPerson`,
    MAX(CASE `log`.`state_value` WHEN 'wait_pay' THEN `log`.`createtime` ELSE 0 END) AS `Tcheck`,
    `test_lvhuan`.`uct_waste_sell`.`state` AS `NowState`
FROM (`test_lvhuan`.`uct_waste_sell` JOIN `test_lvhuan`.`uct_waste_sell_log` `log`)
WHERE (
    `test_lvhuan`.`uct_waste_sell`.`id` = `log`.`sell_id`
    AND ISNULL(`test_lvhuan`.`uct_waste_sell`.`purchase_id`)
)
GROUP BY `test_lvhuan`.`uct_waste_sell`.`id`

UNION ALL

SELECT
    `plog`.`purchase_id` AS `FInterID`,
    'PUR' AS `FTranType`,
    MAX(CASE `plog`.`state_value` WHEN 'draft' THEN `plog`.`createtime` END) AS `TCreate`,
    MAX(CASE `plog`.`state_value` WHEN 'draft' THEN `plog`.`admin_id` END) AS `TCreatePerson`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_allot' THEN '1' ELSE '0' END) AS `TallotOver`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_allot' THEN `plog`.`admin_id` END) AS `TallotPerson`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_allot' THEN `plog`.`createtime` END) AS `Tallot`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_commit_order' THEN '1' ELSE '0' END) AS `TgetorderOver`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_commit_order' THEN `slog`.`admin_id` END) AS `TgetorderPerson`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_commit_order' THEN `slog`.`createtime` END) AS `Tgetorder`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_receive_order' THEN '1' ELSE '0' END) AS `TmaterialOver`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_receive_order' THEN `plog`.`admin_id` END) AS `TmaterialPerson`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_receive_order' THEN `plog`.`createtime` END) AS `Tmaterial`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pick_cargo' THEN '1' ELSE '0' END) AS `TpurchaseOver`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pick_cargo' THEN `slog`.`admin_id` ELSE 0 END) AS `TpurchasePerson`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pick_cargo' THEN `slog`.`createtime` ELSE 0 END) AS `Tpurchase`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pay' THEN '1' ELSE '0' END) AS `TpayOver`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pay' THEN `slog`.`admin_id` ELSE 0 END) AS `TpayPerson`,
    MAX(CASE `slog`.`state_value` WHEN 'wait_pay' THEN `slog`.`createtime` ELSE 0 END) AS `Tpay`,
    MAX(CASE `slog`.`state_value` WHEN 'finish' THEN '1' ELSE '0' END) AS `TchangeOver`,
    MAX(CASE `slog`.`state_value` WHEN 'finish' THEN `slog`.`admin_id` END) AS `TchangePerson`,
    MAX(CASE `slog`.`state_value` WHEN 'finish' THEN `slog`.`createtime` END) AS `Tchange`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_return_fee' THEN '1' ELSE '0' END) AS `TexpenseOver`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_return_fee' THEN `plog`.`admin_id` END) AS `TexpensePerson`,
    MAX(CASE `plog`.`state_value` WHEN 'wait_return_fee' THEN `plog`.`createtime` END) AS `Texpense`,
    0 AS `TsortOver`,
    0 AS `TsortPerson`,
    0 AS `Tsort`,
    0 AS `TallowOver`,
    0 AS `TallowPerson`,
    MAX(CASE `plog`.`state_value` WHEN 'finish' THEN '1' ELSE '0' END) AS `TcheckOver`,
    MAX(CASE `plog`.`state_value` WHEN 'finish' THEN `plog`.`admin_id` ELSE 0 END) AS `TcheckPerson`,
    MAX(CASE `plog`.`state_value` WHEN 'finish' THEN `plog`.`createtime` ELSE 0 END) AS `Tcheck`,
    `p`.`state` AS `NowState`
FROM (((`test_lvhuan`.`uct_waste_sell` `s` JOIN `test_lvhuan`.`uct_waste_sell_log` `slog`) JOIN `test_lvhuan`.`uct_waste_purchase` `p`) JOIN `test_lvhuan`.`uct_waste_purchase_log` `plog`)
WHERE (
    `s`.`id` = `slog`.`sell_id`
    AND `s`.`order_id` = `p`.`order_id`
    AND `p`.`id` = `plog`.`purchase_id`
    AND `slog`.`is_timeline_data` = '1'
)
GROUP BY `p`.`order_id`;


