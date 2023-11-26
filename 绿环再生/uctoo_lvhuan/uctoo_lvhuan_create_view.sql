CREATE  FUNCTION pg_catalog.substring_index(varchar, varchar, integer)
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



CREATE  FUNCTION pg_catalog.text_numeric_gt (text, numeric) RETURNS bool AS 'select $1 > $2::text' LANGUAGE sql IMMUTABLE STRICT PARALLEL safe;
CREATE  OPERATOR pg_catalog.>     (LEFTARG = text, RIGHTARG = numeric, PROCEDURE = text_numeric_gt, COMMUTATOR = '<=' );



DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_all_materiel`;
CREATE VIEW `uctoo_lvhuan`.`accoding_all_materiel` as select `wh`.`name` AS `仓库归属`,`ad`.`nickname` AS `申请人`,`mat`.`name` AS `辅材类型`,sum((case `main`.`mate_type` when 'm_out' then `detail`.`material_num` else '0' end)) AS `领出数量`,sum((case `main`.`mate_type` when 'm_in' then `detail`.`material_num` else '0' end)) AS `返还数量` from ((((`uctoo_lvhuan`.`uct_auxy_material_warehouse` `main` join `uctoo_lvhuan`.`uct_waste_warehouse` `wh`) join `uctoo_lvhuan`.`uct_admin` `ad`) join `uctoo_lvhuan`.`uct_auxy_material_warehouse_detail` `detail`) join `uctoo_lvhuan`.`uct_materiel` `mat`) where ((`wh`.`id` = `main`.`ware_id`) and (`ad`.`id` = `main`.`apply_id`) and (`main`.`id` = `detail`.`main_id`) and (`mat`.`id` = `detail`.`material_id`) and (`main`.`mate_state` = 'processed') and (`main`.`update_time` between '2021-01-01 00:00:00' and '2021-03-31 23:59:59')) group by `main`.`apply_id`,`detail`.`material_id`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_all_materiel_order`;
create view `uctoo_lvhuan`.`accoding_all_materiel_order` as select `main`.`FBillNo` AS `订单号`,`main`.`nickname` AS `租户`,sum((case `main`.`name` when '分类箱' then `main`.`FUseCount` else '0' end)) AS `分类箱个数`,sum((case `main`.`name` when '编织袋' then `main`.`FUseCount` else '0' end)) AS `编织袋个数`,sum((case `main`.`name` when '太空包' then `main`.`FUseCount` else '0' end)) AS `太空包个数`,sum((case `main`.`name` when '分类箱' then (`main`.`FUseCount` * `main`.`inside_price`) when '编织袋' then (`main`.`FUseCount` * `main`.`inside_price`) when '太空包' then (`main`.`FUseCount` * `main`.`inside_price`) else '0' end)) AS `租金合计` from (select `ad`.`nickname` AS `nickname`,`mate`.`name` AS `name`,concat(`cus`.`name`,'#',`mat`.`FBillNo`) AS `FBillNo`,`mat`.`FUseCount` AS `FUseCount`,`mate`.`inside_price` AS `inside_price` from ((((((select `main`.`FBillNo` AS `FBillNo`,`mat`.`FMaterielID` AS `FMaterielID`,`mat`.`FUseCount` AS `FUseCount` from (`uctoo_lvhuan`.`trans_main_table` `main` join `uctoo_lvhuan`.`trans_materiel_table` `mat`) where ((`main`.`FInterID` = `mat`.`FInterID`) and (`main`.`FTranType` = `mat`.`FTranType`) and (`main`.`FBillNo` >= '202002010000000000')))) `mat` join (select `main`.`FBillNo` AS `FBillNo`,max((case `main`.`FTranType` when 'PUR' then `main`.`FEmpID` else '0' end)) AS `FEmpID`,max((case `main`.`FTranType` when 'PUR' then `main`.`FSupplyID` else '0' end)) AS `FSupplyID` from `uctoo_lvhuan`.`trans_main_table` `main` where ((`main`.`FCancellation` = 1) and (`main`.`FSaleStyle` not in ('1','2')) and (`main`.`FBillNo` >= '202002010000000000')) group by `main`.`FBillNo` having ((sum(`main`.`FCorrent`) = 2) and (max((case `main`.`FTranType` when 'SOR' then `main`.`FDate` when 'SEL' then `main`.`FDate` else '1970-01-01 00:00:00' end)) between '2021-01-01 00:00:00' and '2021-03-31 23:59:59'))) `main`) join `uctoo_lvhuan`.`uct_admin` `ad`) join `uctoo_lvhuan`.`uct_materiel` `mate`) join `uctoo_lvhuan`.`uct_waste_customer` `cus`) where ((`mat`.`FBillNo` = `main`.`FBillNo`) and (`ad`.`id` = `main`.`FEmpID`) and (`mate`.`id` = `mat`.`FMaterielID`) and (`cus`.`id` = `main`.`FSupplyID`))) `main` group by `main`.`FBillNo`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_all_pur`;
create view `uctoo_lvhuan`.`accoding_all_pur` as select `uctoo_lvhuan`.`uct_branch`.`name` AS `分部归属`,concat(`uctoo_lvhuan`.`uct_waste_customer`.`name`,'#',`er`.`FBillNo`) AS `订单号`,`er`.`FDate` AS `采购日期`,if((`er`.`FinDate` like '1970-01-01%'),'-',`er`.`FinDate`) AS `确认日期`,(case `er`.`FSaleStyle` when '1' then '直销' when '0' then '采购回库' end) AS `采购方式`,`uctoo_lvhuan`.`uct_admin`.`nickname` AS `采购负责人`,`er`.`pur_FQty` AS `采购净重`,round(`er`.`pur_TalFAmount`,2) AS `采购金额`,round(`er`.`pur_expense`,2) AS `采购费用`,`er`.`sor_FQty` AS `入库净重`,round(`er`.`profit`,2) AS `毛利润`,(case `er`.`FCancellation` when '1' then '正常' when '0' then '已取消' end) AS `有效状态`,(case `er`.`FCorrent` when '1' then '已完成' when '0' then '未完成' end) AS `订单状态` from (((((select max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FDate` else '1970-01-01 00:00:00' end)) AS `FDate`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`FDate` when 'SEL' then `uctoo_lvhuan`.`trans_main_table`.`FDate` else '1970-01-01 00:00:00' end)) AS `FinDate`,`uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FBillNo` AS `FBillNo`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FSupplyID` else '0' end)) AS `FSupplyID`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` AS `FSaleStyle`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FEmpID` else '0' end)) AS `FEmpID`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `pur_FQty`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFAmount` else '0' end)) AS `pur_TalFAmount`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFrist` else '0' end)) AS `pur_expense`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` when 'SEL' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `sor_FQty`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`FCorrent` when 'SEL' then `uctoo_lvhuan`.`trans_main_table`.`FCorrent` else '0' end)) AS `FCorrent`,`uctoo_lvhuan`.`trans_main_table`.`FCancellation` AS `FCancellation`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then ((((-(ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalFAmount`,0)) - ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalFrist`,0)) - ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalSecond`,0)) - ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalThird`,0)) - ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalForth`,0)) when 'SOR' then (((ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalFAmount`,0) - ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalFrist`,0)) - ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalSecond`,0)) - ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalThird`,0)) when 'SEL' then ((ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalFAmount`,0) + ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalFrist`,0)) + ifnull(`uctoo_lvhuan`.`trans_main_table`.`TalSecond`,0)) else '0' end)) AS `profit` from `uctoo_lvhuan`.`trans_main_table` where (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> 2) group by `uctoo_lvhuan`.`trans_main_table`.`FBillNo`)) `er` join `uctoo_lvhuan`.`uct_branch`) join `uctoo_lvhuan`.`uct_waste_customer`) join `uctoo_lvhuan`.`uct_admin`) where ((`uctoo_lvhuan`.`uct_branch`.`setting_key` = `er`.`FRelateBrID`) and (`uctoo_lvhuan`.`uct_waste_customer`.`id` = `er`.`FSupplyID`) and (`uctoo_lvhuan`.`uct_admin`.`id` = `er`.`FEmpID`) and (`er`.`FBillNo` like '20%') and (`er`.`FRelateBrID` <> 7));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_all_pur_bak`;
create view `uctoo_lvhuan`.`accoding_all_pur_bak` as select `uctoo_lvhuan`.`uct_branch`.`name` AS `分部归属`,concat(`uctoo_lvhuan`.`uct_waste_customer`.`name`,'#',`er`.`FBillNo`) AS `订单号`,`er`.`FDate` AS `采购日期`,(case `er`.`FSaleStyle` when '1' then '直销' when '0' then '采购回库' when '3' then '送框' end) AS `采购类型`,`uctoo_lvhuan`.`uct_admin`.`nickname` AS `采购负责人`,`er`.`pur_FQty` AS `采购总净重`,round(`er`.`pur_TalFAmount`,2) AS `采购货款`,round(`er`.`pur_expense`,2) AS `采购费用`,`er`.`sor_FQty` AS `分拣总净重`,round(`er`.`prefit`,2) AS `毛利润`,(case `er`.`FCorrent` when '1' then '已完成' when '0' then '未完成' end) AS `订单状态`,(case `er`.`FCancellation` when '1' then '正常' when '0' then '已取消' end) AS `有效状态` from (((((select max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FDate` else '0' end)) AS `FDate`,`uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FBillNo` AS `FBillNo`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FSupplyID` else '0' end)) AS `FSupplyID`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` AS `FSaleStyle`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FEmpID` else '0' end)) AS `FEmpID`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `pur_FQty`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFAmount` else '0' end)) AS `pur_TalFAmount`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFrist` else '0' end)) AS `pur_expense`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` when 'SEL' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `sor_FQty`,`uctoo_lvhuan`.`trans_main_table`.`FCorrent` AS `FCorrent`,`uctoo_lvhuan`.`trans_main_table`.`FCancellation` AS `FCancellation`,sum(if((`uctoo_lvhuan`.`trans_main_table`.`FCorrent` = '1'),(case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then ((((-(`uctoo_lvhuan`.`trans_main_table`.`TalFAmount`) - `uctoo_lvhuan`.`trans_main_table`.`TalFrist`) - `uctoo_lvhuan`.`trans_main_table`.`TalSecond`) - `uctoo_lvhuan`.`trans_main_table`.`TalThird`) - `uctoo_lvhuan`.`trans_main_table`.`TalForth`) when 'SOR' then (((`uctoo_lvhuan`.`trans_main_table`.`TalFAmount` - `uctoo_lvhuan`.`trans_main_table`.`TalFrist`) - `uctoo_lvhuan`.`trans_main_table`.`TalSecond`) - `uctoo_lvhuan`.`trans_main_table`.`TalThird`) when 'SEL' then ((`uctoo_lvhuan`.`trans_main_table`.`TalFAmount` + if(isnull(`uctoo_lvhuan`.`trans_main_table`.`TalFrist`),0,`uctoo_lvhuan`.`trans_main_table`.`TalFrist`)) + `uctoo_lvhuan`.`trans_main_table`.`TalSecond`) else '0' end),'0')) AS `prefit` from `uctoo_lvhuan`.`trans_main_table` where (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> 2) group by `uctoo_lvhuan`.`trans_main_table`.`FBillNo`)) `er` join `uctoo_lvhuan`.`uct_branch`) join `uctoo_lvhuan`.`uct_waste_customer`) join `uctoo_lvhuan`.`uct_admin`) where ((`uctoo_lvhuan`.`uct_branch`.`setting_key` = `er`.`FRelateBrID`) and (`uctoo_lvhuan`.`uct_waste_customer`.`id` = `er`.`FSupplyID`) and (`uctoo_lvhuan`.`uct_admin`.`id` = `er`.`FEmpID`) and (`er`.`FDate` like '2020-12%') and (`er`.`FRelateBrID` <> 7));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_all_sel`;
create view `uctoo_lvhuan`.`accoding_all_sel` as select `branch`.`name` AS `分部归属`,if((`main`.`FDate` like '1970%'),'-',`main`.`FDate`) AS `销售日期`,concat(`cum`.`name`,'#',`main`.`FBillNo`) AS `订单号`,`admin`.`nickname` AS `销售负责人`,'销售出库' AS `销售方式`,`main`.`TalFQty` AS `销售总净重`,`main`.`TalFAmount` AS `销售总金额`,ifnull(`main`.`TalFrist`,0) AS `太空包费用`,ifnull(`main`.`TalSecond`,0) AS `其他收支`,(case `main`.`FCancellation` when '1' then '正常' when '0' then '已取消' end) AS `有效状态`,(case `main`.`FCorrent` when '1' then '已完成' when '0' then '未完成' end) AS `订单状态` from ((((`uctoo_lvhuan`.`uct_waste_sell_log` `sellog` left join `uctoo_lvhuan`.`trans_main_table` `main` on(((`main`.`FInterID` = `sellog`.`sell_id`) and (`sellog`.`state_value` = 'wait_pay')))) join `uctoo_lvhuan`.`uct_branch` `branch`) join `uctoo_lvhuan`.`uct_waste_customer` `cum`) join `uctoo_lvhuan`.`uct_admin` `admin`) where ((`main`.`FTranType` = 'SEL') and (date_format(from_unixtime(`sellog`.`createtime`),'%Y-%m-%d %H:%i:%s') between '2021-01-01 00:00:00' and '2021-01-31 23:59:59') and (`main`.`FRelateBrID` = `branch`.`setting_key`) and (`main`.`FSupplyID` = `cum`.`id`) and (`main`.`FSaleStyle` = 2) and (`admin`.`id` = `main`.`FEmpID`) and (`main`.`FRelateBrID` <> 7)) union all select `branch`.`name` AS `分部归属`,if((`main`.`FDate` like '1970%'),'-',`main`.`FDate`) AS `销售日期`,concat(`cum`.`name`,'#',`main`.`FBillNo`) AS `订单号`,`admin`.`nickname` AS `销售负责人`,'直销' AS `销售方式`,`main`.`TalFQty` AS `销售总净重`,`main`.`TalFAmount` AS `销售总金额`,ifnull(`main`.`TalFrist`,0) AS `太空包费用`,ifnull(`main`.`TalSecond`,0) AS `其他收支`,(case `main`.`FCancellation` when '1' then '正常' when '0' then '已取消' end) AS `有效状态`,(case `main`.`FCorrent` when '1' then '已完成' when '0' then '未完成' end) AS `订单状态` from ((((`uctoo_lvhuan`.`uct_waste_sell_log` `sellog` left join `uctoo_lvhuan`.`trans_main_table` `main` on(((`main`.`FInterID` = `sellog`.`sell_id`) and (`sellog`.`state_value` = 'wait_pay')))) join `uctoo_lvhuan`.`uct_branch` `branch`) join `uctoo_lvhuan`.`uct_waste_customer` `cum`) join `uctoo_lvhuan`.`uct_admin` `admin`) where ((`main`.`FRelateBrID` = `branch`.`setting_key`) and (date_format(from_unixtime(`sellog`.`createtime`),'%Y-%m-%d %H:%i:%s') between '2021-01-01 00:00:00' and '2021-01-31 23:59:59') and (`main`.`FSupplyID` = `cum`.`id`) and (`admin`.`id` = `main`.`FEmpID`) and (`main`.`FTranType` = 'SEL') and (`main`.`FRelateBrID` <> 7) and (`main`.`FSaleStyle` = '1') and (`main`.`FBillNo` like '20%'));





























DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_fee_list`;
create view  `uctoo_lvhuan`.`accoding_fee_list` as select `uctoo_lvhuan`.`trans_main_table`.`FBillNo` AS `FBillNo`,`uctoo_lvhuan`.`trans_fee_table`.`FFeeID` AS `FFeeID`,`uctoo_lvhuan`.`trans_fee_table`.`FFeeType` AS `FFeeType`,`uctoo_lvhuan`.`trans_fee_table`.`FFeePerson` AS `FFeePerson`,`uctoo_lvhuan`.`trans_fee_table`.`FFeeAmount` AS `FFeeAmount` from (`uctoo_lvhuan`.`trans_main_table` join `uctoo_lvhuan`.`trans_fee_table`) where ((`uctoo_lvhuan`.`trans_main_table`.`FInterID` = `uctoo_lvhuan`.`trans_fee_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_main_table`.`FTranType` = `uctoo_lvhuan`.`trans_fee_table`.`FTranType`)) union all select `uctoo_lvhuan`.`trans_main_table`.`FBillNo` AS `FBillNo`,(case `uctoo_lvhuan`.`uct_materiel`.`name` when '太空包' then '耗材费-太空包' when '编织袋' then '耗材费-编织袋' end) AS `FFeeID`,'out' AS `FFeeType`,'公司' AS `FFeePerson`,sum(`uctoo_lvhuan`.`trans_materiel_table`.`FMeterielAmount`) AS `FFeeAmount` from ((`uctoo_lvhuan`.`trans_main_table` join `uctoo_lvhuan`.`trans_materiel_table`) join `uctoo_lvhuan`.`uct_materiel`) where ((`uctoo_lvhuan`.`trans_main_table`.`FTranType` = 'PUR') and (`uctoo_lvhuan`.`trans_materiel_table`.`FTranType` = 'PUR') and (`uctoo_lvhuan`.`trans_main_table`.`FInterID` = `uctoo_lvhuan`.`trans_materiel_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_materiel_table`.`FMaterielID` = `uctoo_lvhuan`.`uct_materiel`.`id`) and ((`uctoo_lvhuan`.`uct_materiel`.`name` = '太空包') or (`uctoo_lvhuan`.`uct_materiel`.`name` = '编织袋'))) group by `uctoo_lvhuan`.`trans_materiel_table`.`FInterID`,`uctoo_lvhuan`.`trans_materiel_table`.`FMaterielID`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_pur_cargo`;
create view `uctoo_lvhuan`.`accoding_pur_cargo` as select concat(`cus`.`name`,'#',`main`.`FBillNo`) AS `订单号`,`ad`.`nickname` AS `订单负责人`,(case `main`.`FTranType` when 'PUR' then '采购' when 'SOR' then '入库' else '' end) AS `订单类型`,`cate`.`name` AS `品名`,`ass`.`FQty` AS `净重`,`ass`.`FPrice` AS `单价`,`ass`.`FAmount` AS `金额` from ((((`uctoo_lvhuan`.`trans_main_table` `main` join `uctoo_lvhuan`.`trans_assist_table` `ass`) join `uctoo_lvhuan`.`uct_waste_cate` `cate`) join `uctoo_lvhuan`.`uct_waste_customer` `cus`) join `uctoo_lvhuan`.`uct_admin` `ad`) where ((`cate`.`id` = `ass`.`FItemID`) and (`main`.`FInterID` = `ass`.`FinterID`) and (`main`.`FTranType` = `ass`.`FTranType`) and (`main`.`FDate` >= '2019-11-01 00:00:00') and (`main`.`FDate` <= '2020-02-01 00:00:00') and (`main`.`FRelateBrID` = 21) and (`main`.`FCancellation` = 1) and (`main`.`FSupplyID` = `cus`.`id`) and (`main`.`FEmpID` = `ad`.`id`) and (`main`.`FSaleStyle` = 0)) order by `main`.`FBillNo` desc;



















DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_stock_cate`;
create view `uctoo_lvhuan`.`accoding_stock_cate` as select `c2`.`branch_id` AS `FRelateBrID`,concat('LH',`w`.`id`) AS `FStockID`,`c2`.`id` AS `FItemID`,(case `c2`.`state` when '1' then `c2`.`name` when '0' then concat('【禁用】',`c2`.`name`) end) AS `name` from (`uctoo_lvhuan`.`uct_waste_cate` `c2` join `uctoo_lvhuan`.`uct_waste_warehouse` `w`) where ((not(`c2`.`parent_id` in (select `c`.`id` AS `id` from `uctoo_lvhuan`.`uct_waste_cate` `c` where (`c`.`parent_id` = 0)))) and (`c2`.`parent_id` <> 0) and (`w`.`branch_id` = `c2`.`branch_id`) and (`w`.`parent_id` = 0) and (`w`.`state` = 1));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_stock_dif`;
create view `uctoo_lvhuan`.`accoding_stock_dif` as select `acc_base`.`FRelateBrID` AS `FRelateBrID`,concat('LH',`acc_base`.`FStockID`) AS `FStockID`,`acc_base`.`cate_id` AS `FItemID`,`uctoo_lvhuan`.`uct_cate_account`.`account_num` AS `FdifQty`,date_format(from_unixtime(`acc_base`.`FdifTime`),'%Y-%m-%d %H:%i:%s') AS `FdifTime` from (((select `uctoo_lvhuan`.`uct_cate_account`.`branch_id` AS `FRelateBrID`,`uctoo_lvhuan`.`uct_cate_account`.`warehouse_id` AS `FStockID`,`uctoo_lvhuan`.`uct_cate_account`.`cate_id` AS `cate_id`,max(`uctoo_lvhuan`.`uct_cate_account`.`createtime`) AS `FdifTime` from `uctoo_lvhuan`.`uct_cate_account` group by `uctoo_lvhuan`.`uct_cate_account`.`cate_id`,`uctoo_lvhuan`.`uct_cate_account`.`warehouse_id`)) `acc_base` join `uctoo_lvhuan`.`uct_cate_account`) where ((`uctoo_lvhuan`.`uct_cate_account`.`cate_id` = `acc_base`.`cate_id`) and (`uctoo_lvhuan`.`uct_cate_account`.`createtime` = `acc_base`.`FdifTime`) and (`uctoo_lvhuan`.`uct_cate_account`.`warehouse_id` = `acc_base`.`FStockID`));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_stock_dif_bak`;
create view `uctoo_lvhuan`.`accoding_stock_dif_bak` as select `acc_base`.`FRelateBrID` AS `FRelateBrID`,concat('LH',`acc_base`.`FStockID`) AS `FStockID`,`acc_base`.`cate_id` AS `FItemID`,`uctoo_lvhuan`.`uct_cate_account`.`account_num` AS `FdifQty`,date_format(from_unixtime(`acc_base`.`FdifTime`),'%Y-%m-%d %H:%i:%s') AS `FdifTime` from (((select `uctoo_lvhuan`.`uct_cate_account`.`branch_id` AS `FRelateBrID`,`uctoo_lvhuan`.`uct_cate_account`.`warehouse_id` AS `FStockID`,`uctoo_lvhuan`.`uct_cate_account`.`cate_id` AS `cate_id`,max(`uctoo_lvhuan`.`uct_cate_account`.`createtime`) AS `FdifTime` from `uctoo_lvhuan`.`uct_cate_account` group by `uctoo_lvhuan`.`uct_cate_account`.`cate_id`,`uctoo_lvhuan`.`uct_cate_account`.`warehouse_id`)) `acc_base` join `uctoo_lvhuan`.`uct_cate_account`) where ((`uctoo_lvhuan`.`uct_cate_account`.`cate_id` = `acc_base`.`cate_id`) and (`uctoo_lvhuan`.`uct_cate_account`.`createtime` = `acc_base`.`FdifTime`) and (`uctoo_lvhuan`.`uct_cate_account`.`warehouse_id` = `acc_base`.`FStockID`));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_stock_iod`;
create view `uctoo_lvhuan`.`accoding_stock_iod` as select `uctoo_lvhuan`.`uct_waste_cate`.`branch_id` AS `FRelateBrID`,concat('LH',`uctoo_lvhuan`.`uct_waste_warehouse`.`id`) AS `FStockID`,`uctoo_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,round(ifnull((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else 0 end),0),1) AS `FDCQty`,round(ifnull((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SEL' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else 0 end),0),1) AS `FSCQty`,'0' AS `FdifQty`,date_format(`uctoo_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d %H:%i:%s') AS `FDCTime` from (((`uctoo_lvhuan`.`trans_assist_table` join `uctoo_lvhuan`.`trans_main_table`) join `uctoo_lvhuan`.`uct_waste_cate`) join `uctoo_lvhuan`.`uct_waste_warehouse`) where ((`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> 1) and (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1) and (`uctoo_lvhuan`.`trans_assist_table`.`FinterID` = `uctoo_lvhuan`.`trans_main_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = `uctoo_lvhuan`.`trans_main_table`.`FTranType`) and (`uctoo_lvhuan`.`trans_assist_table`.`FDCTime` >= curdate()) and (`uctoo_lvhuan`.`trans_assist_table`.`FItemID` = `uctoo_lvhuan`.`uct_waste_cate`.`id`) and (`uctoo_lvhuan`.`uct_waste_cate`.`branch_id` = `uctoo_lvhuan`.`uct_waste_warehouse`.`branch_id`) and (`uctoo_lvhuan`.`uct_waste_warehouse`.`parent_id` = 0) and (`uctoo_lvhuan`.`uct_waste_warehouse`.`state` = 1)) union all select `uctoo_lvhuan`.`uct_cate_account`.`branch_id` AS `FRelateBrID`,concat('LH',`uctoo_lvhuan`.`uct_cate_account`.`warehouse_id`) AS `FStockID`,`uctoo_lvhuan`.`uct_cate_account`.`cate_id` AS `FItemID`,'0' AS `FDCQty`,'0' AS `FSCQty`,(`uctoo_lvhuan`.`uct_cate_account`.`before_account_num` - `uctoo_lvhuan`.`uct_cate_account`.`account_num`) AS `FdifQty`,date_format(from_unixtime(`uctoo_lvhuan`.`uct_cate_account`.`createtime`),'%Y-%m-%d %H:%i:%s') AS `FDCTime` from `uctoo_lvhuan`.`uct_cate_account` where (date_format(from_unixtime(`uctoo_lvhuan`.`uct_cate_account`.`createtime`),'%Y-%m-%d %H:%i:%s') > curdate()) union all select `uctoo_lvhuan`.`accoding_stock_history`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`accoding_stock_history`.`FStockID` AS `FStockID`,`uctoo_lvhuan`.`accoding_stock_history`.`FItemID` AS `FItemID`,`uctoo_lvhuan`.`accoding_stock_history`.`FDCQty` AS `FDCQty`,`uctoo_lvhuan`.`accoding_stock_history`.`FSCQty` AS `FSCQty`,`uctoo_lvhuan`.`accoding_stock_history`.`FdifQty` AS `FdifQty`,`uctoo_lvhuan`.`accoding_stock_history`.`FDCTime` AS `FDCTime` from `uctoo_lvhuan`.`accoding_stock_history`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_wh_materiel`;
create view `uctoo_lvhuan`.`accoding_wh_materiel` as select concat('#',`matmain`.`mate_order_id`) AS `辅材申请单ID`,`wh`.`name` AS `所属仓库`,`ad1`.`nickname` AS `申请人`,`ad2`.`nickname` AS `执行人`,(case `matmain`.`mate_type` when 'm_out' then '领取辅材' when 'm_in' then '返还辅材' else '' end) AS `申请类型`,`mat`.`name` AS `辅材类型`,`matdt`.`material_num` AS `辅材数量`,`matmain`.`update_time` AS `领取／返还时间` from (((((`uctoo_lvhuan`.`uct_auxy_material_warehouse_detail` `matdt` join `uctoo_lvhuan`.`uct_auxy_material_warehouse` `matmain`) join `uctoo_lvhuan`.`uct_materiel` `mat`) join `uctoo_lvhuan`.`uct_waste_warehouse` `wh`) join `uctoo_lvhuan`.`uct_admin` `ad1`) join `uctoo_lvhuan`.`uct_admin` `ad2`) where ((`matdt`.`main_id` = `matmain`.`id`) and (`matdt`.`material_id` = `mat`.`id`) and (`matmain`.`mate_state` = 'processed') and (`wh`.`id` = `matmain`.`ware_id`) and (`ad1`.`id` = `matmain`.`apply_id`) and (`ad2`.`id` = `matmain`.`receive_id`));



















DROP VIEW IF EXISTS `uctoo_lvhuan`.`acconding_total`;
create view `uctoo_lvhuan`.`acconding_total` as select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FBillNo` AS `FBillNo`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FSupplyID` else '0' end)) AS `FSupplyID`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FDate` else '0' end)) AS `FDate`,if((max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FCorrent` else 0 end)) = 1),4,if((max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`FUpStockWhenSave` when 'SEL' then `uctoo_lvhuan`.`trans_main_table`.`FCorrent` else 0 end)) = 1),3,count(`uctoo_lvhuan`.`trans_main_table`.`FTranType`))) AS `FNowState`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `PUR_TalFQty`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFAmount` else '0' end)) AS `PUR_TalFAmount`,sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SOR0' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` when 'SEL1' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `SOR_TalFQty`,sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SOR0' then `uctoo_lvhuan`.`trans_main_table`.`TalFAmount` when 'SEL1' then `uctoo_lvhuan`.`trans_main_table`.`TalFAmount` else '0' end)) AS `SOR_TalFAmount`,(sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else 0 end)) - sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SOR0' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` when 'SEL1' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else 0 end))) AS `weight_loss`,round(((((((((((sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SOR0' then `uctoo_lvhuan`.`trans_main_table`.`TalFAmount` when 'SEL1' then `uctoo_lvhuan`.`trans_main_table`.`TalFAmount` else 0 end)) - sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFAmount` else 0 end))) - sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalSecond` else 0 end))) - sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalThird` else 0 end))) - sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SOR0' then `uctoo_lvhuan`.`trans_main_table`.`TalFrist` else 0 end))) - sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SOR0' then `uctoo_lvhuan`.`trans_main_table`.`TalSecond` else 0 end))) - sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalForth` else 0 end))) - sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SOR0' then `uctoo_lvhuan`.`trans_main_table`.`TalThird` else 0 end))) + sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SEL1' then `uctoo_lvhuan`.`trans_main_table`.`TalFrist` else 0 end))) + sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SEL1' then `uctoo_lvhuan`.`trans_main_table`.`TalSecond` else 0 end))) + sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then -(`uctoo_lvhuan`.`trans_main_table`.`TalFrist`) else 0 end))),3) AS `Total_profit`,round(sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFrist` else 0 end)),3) AS `purchase_expense`,round(sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalSecond` else 0 end)),3) AS `car_fee`,round(sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalThird` else 0 end)),3) AS `man_fee`,round(sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SOR0' then `uctoo_lvhuan`.`trans_main_table`.`TalFrist` else 0 end)),3) AS `sort_fee`,round(sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SOR0' then `uctoo_lvhuan`.`trans_main_table`.`TalSecond` else 0 end)),3) AS `materiel_fee`,round(sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalForth` else 0 end)),3) AS `other_return_fee`,round(sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SOR0' then `uctoo_lvhuan`.`trans_main_table`.`TalThird` else 0 end)),3) AS `other_sort_fee`,round(sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SEL1' then `uctoo_lvhuan`.`trans_main_table`.`TalFrist` else 0 end)),3) AS `materiel_price`,round(sum((case concat(`uctoo_lvhuan`.`trans_main_table`.`FTranType`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle`) when 'SEL1' then `uctoo_lvhuan`.`trans_main_table`.`TalSecond` else 0 end)),3) AS `other_price`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`Fbusiness` else '0' end)) AS `Fbusiness`,`uctoo_lvhuan`.`trans_main_table`.`FDeptID` AS `FDeptID`,`uctoo_lvhuan`.`trans_main_table`.`FEmpID` AS `FEmpID`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` AS `FSaleStyle` from `uctoo_lvhuan`.`trans_main_table` where (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> '2') group by `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FBillNo` order by `uctoo_lvhuan`.`trans_main_table`.`FBillNo` desc;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`check_orderdata`;
create view `uctoo_lvhuan`.`check_orderdata` as select `main`.`FRelateBrID` AS `FRelateBrID`,`main`.`FInterID` AS `FInterID`,`main`.`FTranType` AS `FTranType`,`main`.`FDate` AS `FDate`,concat('#',`main`.`FBillNo`) AS `FBillNo`,`main`.`FDCStockID` AS `FDCStockID`,`main`.`FSCStockID` AS `FSCStockID`,`main`.`FFManagerID` AS `FFManagerID`,`main`.`FSaleStyle` AS `FSaleStyle`,`main`.`FPOStyle` AS `FPOStyle`,`main`.`FPOPrecent` AS `FPOPrecent`,`main`.`TalFQty` AS `TalFQty`,`main`.`TalFAmount` AS `TalFAmount`,`main`.`TalFrist` AS `TalFrist`,`main`.`TalSecond` AS `TalSecond`,`main`.`TalThird` AS `TalThird`,`main`.`TalForth` AS `TalForth` from (((select `main`.`FBillNo` AS `FBillNo` from `uctoo_lvhuan`.`trans_main_table` `main` where ((`main`.`FDate` like '2019-06-04%') and ((`main`.`FTranType` = 'SOR') or (`main`.`FTranType` = 'SEL')) and (`main`.`FRelateBrID` = 1) and (`main`.`FCancellation` = 1)))) `ord` join `uctoo_lvhuan`.`trans_main_table` `main`) where (`ord`.`FBillNo` = `main`.`FBillNo`);









DROP VIEW IF EXISTS `uctoo_lvhuan`.`check_queruturn`;
create view  `uctoo_lvhuan`.`check_queruturn` as select `cq`.`id` AS `id`,`cq`.`admin_id` AS `admin_id`,`cq`.`branch_id` AS `branch_id`,`cq`.`company_name` AS `company_name`,`cq`.`liasion` AS `liasion`,`cq`.`location_name` AS `location_name`,`cq`.`position` AS `position`,`cq`.`createtime` AS `createtime`,`cq`.`updatetime` AS `updatetime` from (select `cq`.`id` AS `id`,`cq`.`admin_id` AS `admin_id`,`cq`.`branch_id` AS `branch_id`,`cq`.`company_name` AS `company_name`,`cq`.`phone` AS `phone`,`cq`.`liasion` AS `liasion`,max(`cq`.`location_name`) AS `location_name`,`cq`.`position` AS `position`,`cq`.`createtime` AS `createtime`,`cq`.`updatetime` AS `updatetime` from `uctoo_lvhuan`.`uct_customer_question` `cq` where ((`cq`.`branch_id` <> 7) and (`cq`.`branch_id` <> 0)) group by `cq`.`phone` having (max(`cq`.`location_name`) = '')) `cq` where (not(`cq`.`id` in (select `uctoo_lvhuan`.`uct_customer_question_item`.`question_id` from `uctoo_lvhuan`.`uct_customer_question_item`)));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`cuplus_select`;
create view `uctoo_lvhuan`.`cuplus_select` as select `tst`.`id` AS `id`,concat('#',`pur`.`order_id`) AS `order_id`,`pur`.`branch_id` AS `branch_id` from (`uctoo_lvhuan`.`table_selecttool` `tst` join `uctoo_lvhuan`.`uct_waste_purchase` `pur`) where (`tst`.`id` = `pur`.`id`);









DROP VIEW IF EXISTS `uctoo_lvhuan`.`customer_item_analyse`;
create view `uctoo_lvhuan`.`customer_item_analyse` as select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FSupplyID` AS `FSupplyID`,date_format(`uctoo_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m') AS `FDate`,`uctoo_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,sum(`uctoo_lvhuan`.`trans_assist_table`.`FQty`) AS `FQty`,sum(`uctoo_lvhuan`.`trans_assist_table`.`FAmount`) AS `FAmount` from (`uctoo_lvhuan`.`trans_main_table` join `uctoo_lvhuan`.`trans_assist_table`) where ((`uctoo_lvhuan`.`trans_main_table`.`FCorrent` = '1') and (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = '1') and (`uctoo_lvhuan`.`trans_assist_table`.`FinterID` = `uctoo_lvhuan`.`trans_main_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = `uctoo_lvhuan`.`trans_main_table`.`FTranType`) and (`uctoo_lvhuan`.`trans_main_table`.`FTranType` <> 'PUR') and (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> '2') and (not((`uctoo_lvhuan`.`trans_main_table`.`FDate` like '1970%')))) group by date_format(`uctoo_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m'),`uctoo_lvhuan`.`trans_main_table`.`FSupplyID`,`uctoo_lvhuan`.`trans_assist_table`.`FItemID`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`customer_month_analyse`;
create view `uctoo_lvhuan`.`customer_month_analyse` as select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FSupplyID` AS `FSupplyID`,date_format(`uctoo_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m') AS `Month`,count(`uctoo_lvhuan`.`trans_main_table`.`FInterID`) AS `OrderNum`,sum(`uctoo_lvhuan`.`trans_main_table`.`TalFQty`) AS `TalFQty`,sum(`uctoo_lvhuan`.`trans_main_table`.`TalFAmount`) AS `TalFAmount` from `uctoo_lvhuan`.`trans_main_table` where ((`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> '2') and (`uctoo_lvhuan`.`trans_main_table`.`FTranType` <> 'PUR') and (not((`uctoo_lvhuan`.`trans_main_table`.`FDate` like '1970%'))) and (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = '1') and (`uctoo_lvhuan`.`trans_main_table`.`FCorrent` = '1')) group by `uctoo_lvhuan`.`trans_main_table`.`FSupplyID`,date_format(`uctoo_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m');









DROP VIEW IF EXISTS `uctoo_lvhuan`.`datawall_carbonparm`;
create view `uctoo_lvhuan`.`datawall_carbonparm` as select `aa`.`branch_id` AS `branch_id`,round((sum((`aa`.`FQty` * `uctoo_lvhuan`.`uct_waste_cate`.`carbon_parm`)) / 1000),3) AS `carbon_parm`,date_format(`aa`.`FDCTime`,'%Y-%m-%d') AS `FDCTime` from (((select `uctoo_lvhuan`.`uct_waste_cate`.`branch_id` AS `branch_id`,`uctoo_lvhuan`.`uct_waste_cate`.`parent_id` AS `parent_id`,`uctoo_lvhuan`.`trans_assist_table`.`FQty` AS `FQty`,`uctoo_lvhuan`.`trans_assist_table`.`FDCTime` AS `FDCTime` from (`uctoo_lvhuan`.`trans_assist_table` join `uctoo_lvhuan`.`uct_waste_cate`) where ((`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = 'SOR') and (`uctoo_lvhuan`.`trans_assist_table`.`FItemID` = `uctoo_lvhuan`.`uct_waste_cate`.`id`)))) `aa` join `uctoo_lvhuan`.`uct_waste_cate`) where ((`uctoo_lvhuan`.`uct_waste_cate`.`id` = `aa`.`parent_id`) and (date_format(`aa`.`FDCTime`,'%Y-%m-%d') >= (curdate() - interval 6 day))) group by date_format(`aa`.`FDCTime`,'%Y-%m-%d'),`aa`.`branch_id`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`datawall_conitem`;
create view `uctoo_lvhuan`.`datawall_conitem` as select `conitem`.`branch_id` AS `FRelateBrID`,`conitem`.`parent_id` AS `parent_id`,round(sum(`conitem`.`FQty`),1) AS `conTalFQty` from (select `c`.`branch_id` AS `branch_id`,`c`.`parent_id` AS `parent_id`,`a`.`FQty` AS `FQty` from ((`uctoo_lvhuan`.`trans_assist_table` `a` join `uctoo_lvhuan`.`uct_waste_cate` `c`) join `uctoo_lvhuan`.`trans_main_table` `m`) where ((`a`.`FItemID` = `c`.`id`) and (`a`.`FTranType` = 'SOR') and (`a`.`FTranType` = `m`.`FTranType`) and (`a`.`FinterID` = `m`.`FInterID`) and (date_format(`m`.`FDate`,'%Y%m%d') >= (curdate() - 30)))) `conitem` group by `conitem`.`parent_id`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`datawall_contrash`;
create view `uctoo_lvhuan`.`datawall_contrash` as select `trax`.`FRelateBrID` AS `FRelateBrID`,`trax`.`TalFQty` AS `TalFQty`,`tray`.`TraFQty` AS `TraFQty`,`trax`.`FDate` AS `FDate` from (((select `m`.`FRelateBrID` AS `FRelateBrID`,sum(`m`.`TalFQty`) AS `TalFQty`,date_format(`m`.`FDate`,'%Y-%m-%d') AS `FDate` from (`uctoo_lvhuan`.`trans_main_table` `m` join `uctoo_lvhuan`.`trans_assist_table` `a`) where ((`m`.`FInterID` = `a`.`FinterID`) and (`m`.`FTranType` = `a`.`FTranType`) and (date_format(`m`.`FDate`,'%Y%m%d') >= (curdate() - 7)) and (`m`.`FTranType` = 'SOR')) group by `m`.`FRelateBrID`,date_format(`m`.`FDate`,'%Y-%m-%d'))) `trax` join (select `m`.`FRelateBrID` AS `FRelateBrID`,sum(`a`.`FQty`) AS `TraFQty`,date_format(`m`.`FDate`,'%Y-%m-%d') AS `FDate` from ((`uctoo_lvhuan`.`trans_main_table` `m` join `uctoo_lvhuan`.`trans_assist_table` `a`) join (select `uctoo_lvhuan`.`uct_waste_cate`.`id` AS `id` from `uctoo_lvhuan`.`uct_waste_cate` where (`uctoo_lvhuan`.`uct_waste_cate`.`name` = '垃圾')) `trash`) where ((`m`.`FInterID` = `a`.`FinterID`) and (`m`.`FTranType` = `a`.`FTranType`) and (date_format(`m`.`FDate`,'%Y%m%d') >= (curdate() - 7)) and (`m`.`FTranType` = 'SOR') and (`trash`.`id` = `a`.`FItemID`)) group by `m`.`FRelateBrID`,date_format(`m`.`FDate`,'%Y-%m-%d')) `tray`) where ((`trax`.`FRelateBrID` = `tray`.`FRelateBrID`) and (`trax`.`FDate` = `tray`.`FDate`));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`datawall_pss`;
create view `uctoo_lvhuan`.`datawall_pss` as select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else 0 end)) AS `PUR_tal`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else 0 end)) AS `SOR_tal`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SEL' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else 0 end)) AS `SEL_tal`,date_format(`uctoo_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m-%d') AS `FDate` from `uctoo_lvhuan`.`trans_main_table` where (date_format(`uctoo_lvhuan`.`trans_main_table`.`FDate`,'%Y%m%d') >= (curdate() - 7)) group by date_format(`uctoo_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m-%d'),`uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`datawall_topcate_date`;
create view `uctoo_lvhuan`.`datawall_topcate_date` as select `tca`.`FRelateBrID` AS `FRelateBrID`,`tca`.`FItemID` AS `FItemID`,`tca`.`name` AS `name`,date_format(`mai`.`FDate`,'%Y-%m') AS `FDate`,round(sum((case `mai`.`FTranType` when 'PUR' then `ass`.`FQty` else 0 end)),1) AS `PUR_FQty`,round(sum((case `mai`.`FTranType` when 'SOR' then `ass`.`FQty` else 0 end)),1) AS `SOR_FQty`,round(sum((case `mai`.`FTranType` when 'SEl' then `ass`.`FQty` else 0 end)),1) AS `SEL_FQty` from ((`uctoo_lvhuan`.`datawall_topcate` `tca` join `uctoo_lvhuan`.`trans_assist_table` `ass`) join `uctoo_lvhuan`.`trans_main_table` `mai`) where ((`mai`.`FInterID` = `ass`.`FinterID`) and (`mai`.`FTranType` = `ass`.`FTranType`) and (`mai`.`FCorrent` = '1') and (`mai`.`FCancellation` = '1') and (`mai`.`FSaleStyle` <> '2') and (`tca`.`FItemID` = `ass`.`FItemID`)) group by `tca`.`FRelateBrID`,`tca`.`FItemID`,date_format(`mai`.`FDate`,'%Y-%m');









DROP VIEW IF EXISTS `uctoo_lvhuan`.`save_mysqlorder_1`;
create view `uctoo_lvhuan`.`save_mysqlorder_1` as select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,(case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`FDCStockID` when 'SEL' then `uctoo_lvhuan`.`trans_main_table`.`FSCStockID` else NULL end) AS `FStockID`,`uctoo_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,round(ifnull((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else 0 end),0),1) AS `FDCQty`,round(ifnull((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SEL' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else 0 end),0),1) AS `FSCQty`,'0' AS `FdifQty`,date_format(`uctoo_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d %H:%i:%s') AS `FDCTime` from (`uctoo_lvhuan`.`trans_assist_table` join `uctoo_lvhuan`.`trans_main_table`) where ((`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> 1) and (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1) and (`uctoo_lvhuan`.`trans_assist_table`.`FinterID` = `uctoo_lvhuan`.`trans_main_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = `uctoo_lvhuan`.`trans_main_table`.`FTranType`) and (`uctoo_lvhuan`.`trans_assist_table`.`FDCTime` >= curdate())) union all select `uctoo_lvhuan`.`uct_cate_account`.`branch_id` AS `FRelateBrID`,concat('LH',`uctoo_lvhuan`.`uct_cate_account`.`warehouse_id`) AS `FStockID`,`uctoo_lvhuan`.`uct_cate_account`.`cate_id` AS `FItemID`,'0' AS `FDCQty`,'0' AS `FSCQty`,(`uctoo_lvhuan`.`uct_cate_account`.`before_account_num` - `uctoo_lvhuan`.`uct_cate_account`.`account_num`) AS `FdifQty`,date_format(from_unixtime(`uctoo_lvhuan`.`uct_cate_account`.`createtime`),'%Y-%m-%d %H:%i:%s') AS `FDCTime` from `uctoo_lvhuan`.`uct_cate_account` union all select `base`.`FRelateBrID` AS `FRelateBrID`,`base`.`FStockID` AS `FStockID`,`base`.`FItemID` AS `FItemID`,round(sum(ifnull(`base`.`FDCQty`,0)),1) AS `FDCQty`,round(sum(ifnull(`base`.`FSCQty`,0)),1) AS `FSCQty`,'0' AS `FdifQty`,date_format(concat(date_format(`base`.`FDCTime`,'%Y-%m-%d'),' 23:59:59'),'%Y-%m-%d %H:%i:%s') AS `FDCTime` from (select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,(case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`FDCStockID` when 'SEL' then `uctoo_lvhuan`.`trans_main_table`.`FSCStockID` else NULL end) AS `FStockID`,`uctoo_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,(case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else 0 end) AS `FDCQty`,(case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SEL' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else 0 end) AS `FSCQty`,`uctoo_lvhuan`.`trans_assist_table`.`FDCTime` AS `FDCTime` from (`uctoo_lvhuan`.`trans_assist_table` join `uctoo_lvhuan`.`trans_main_table`) where ((`uctoo_lvhuan`.`trans_assist_table`.`FinterID` = `uctoo_lvhuan`.`trans_main_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = `uctoo_lvhuan`.`trans_main_table`.`FTranType`) and (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> 1) and (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1) and (`uctoo_lvhuan`.`trans_assist_table`.`FDCTime` < curdate()))) `base` group by `base`.`FStockID`,`base`.`FItemID`,date_format(`base`.`FDCTime`,'%Y-%m-%d') having (`base`.`FStockID` is not null);









DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_1`;
create view `uctoo_lvhuan`.`test_1` as select `send`.`branch_id` AS `branch_id`,`send`.`send_count` AS `send_count`,ifnull(`get`.`get_count`,0) AS `get_count`,ifnull(`get`.`item1`,0) AS `item1`,ifnull(`get`.`item2`,0) AS `item2`,ifnull(`get`.`item3`,0) AS `item3`,ifnull(`get`.`item4`,0) AS `item4`,ifnull(`get`.`item5`,0) AS `item5`,ifnull(`get`.`item6`,0) AS `item6`,ifnull(`get`.`item7`,0) AS `item7`,ifnull(`get`.`csi`,0) AS `CSI` from (((select `cq`.`branch_id` AS `branch_id`,count(distinct `cq`.`phone`) AS `send_count` from `uctoo_lvhuan`.`uct_customer_question` `cq` where ((`cq`.`branch_id` <> 7) and (`cq`.`branch_id` <> 0)) group by `cq`.`branch_id`)) `send` left join ((select `cq`.`branch_id` AS `branch_id`,count(distinct `cq`.`phone`) AS `get_count`,round((sum(`cqg`.`item1`) / count(`cqg`.`question_id`)),2) AS `item1`,round((sum(`cqg`.`item2`) / count(`cqg`.`question_id`)),2) AS `item2`,round((sum(`cqg`.`item3`) / count(`cqg`.`question_id`)),2) AS `item3`,round((sum(`cqg`.`item4`) / count(`cqg`.`question_id`)),2) AS `item4`,round((sum(`cqg`.`item5`) / count(`cqg`.`question_id`)),2) AS `item5`,round((sum(`cqg`.`item6`) / count(`cqg`.`question_id`)),2) AS `item6`,round((sum(`cqg`.`item7`) / count(`cqg`.`question_id`)),2) AS `item7`,round((sum(`cqg`.`csi`) / count(`cqg`.`question_id`)),2) AS `csi` from ((`uctoo_lvhuan`.`uct_customer_question` `cq` join `uctoo_lvhuan`.`uct_customer_question_item` `cqi`) join `uctoo_lvhuan`.`uct_customer_question_grade` `cqg`) where ((`cq`.`branch_id` <> 7) and (`cq`.`branch_id` <> 0) and (`cq`.`id` = `cqi`.`question_id`) and (`cq`.`id` = `cqg`.`question_id`)) group by `cq`.`branch_id`)) `get` on((`send`.`branch_id` = `get`.`branch_id`)));



















DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_11`;
create view  `uctoo_lvhuan`.`test_11` as select `uctoo_lvhuan`.`uct_waste_purchase_materiel`.`purchase_id` AS `purchase_id`,((case `uctoo_lvhuan`.`uct_waste_purchase_materiel`.`use_type` when '1' then cast(`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`pick_amount` as signed) when '0' then cast(`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`storage_amount` as signed) else 0 end) * `uctoo_lvhuan`.`uct_waste_purchase_materiel`.`inside_price`) AS `materiel_price` from `uctoo_lvhuan`.`uct_waste_purchase_materiel`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_12`;
create view `uctoo_lvhuan`.`test_12` as select concat('#',`main`.`FBillNo`) AS `订单号`,max((case `main`.`FTranType` when 'SEL' then `main`.`FDate` else '1970-01-01 00:00:00' end)) AS `确认时间`,`cate`.`name` AS `品名`,count(distinct (case `main`.`FTranType` when 'PUR' then `ass`.`FPrice` else NULL end)) AS `采购单价种类数`,count(distinct (case `main`.`FTranType` when 'SEL' then `ass`.`FPrice` else NULL end)) AS `销售单价种类数` from ((`uctoo_lvhuan`.`trans_main_table` `main` join `uctoo_lvhuan`.`trans_assist_table` `ass`) join `uctoo_lvhuan`.`uct_waste_cate` `cate`) where ((`main`.`FInterID` = `ass`.`FinterID`) and (`main`.`FTranType` = `ass`.`FTranType`) and (`main`.`FSaleStyle` = 1) and (`main`.`FCorrent` = 1) and (`main`.`FCancellation` = 1) and (`cate`.`id` = `ass`.`FItemID`)) group by `main`.`FBillNo`,`ass`.`FItemID`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_13`;
create view `uctoo_lvhuan`.`test_13` as select `uctoo_lvhuan`.`uct_branch`.`name` AS `分部归属`,concat(`uctoo_lvhuan`.`uct_waste_customer`.`customer_code`,'#',`er`.`FBillNo`) AS `订单号`,`er`.`FDate` AS `采购日期`,(case `er`.`FSaleStyle` when '1' then '直销' when '0' then '采购回库' when '3' then '送框' end) AS `采购类型`,`ad1`.`nickname` AS `采购负责人`,`er`.`pur_FQty` AS `采购总净重`,`er`.`sor_FQty` AS `分拣总净重`,(case `er`.`FCorrent` when '1' then '已完成' when '0' then '未完成' end) AS `订单状态`,(case `er`.`FNowState` when 'draft' then '草稿' when 'wait_allot' then '待分配' when 'wait_receive_order' then '待接单' when 'wait_apply_materiel' then '待申请辅材' when 'wait_pick_materiel' then '待提取辅材' when 'wait_signin_materiel' then '待签收辅材' when 'wait_pick_cargo' then '待提货' when 'wait_pay' then '待付款' when 'wait_storage_connect' then '待入库交接' when 'wait_storage_connect_confirm' then '待确认交接' when 'wait_storage_sort' then '待分拣入库' when 'wait_storage_confirm' then '待入库确认' when 'wait_return_fee' then '待订单报销' when 'wait_confirm_return_fee' then '待审核订单' when 'finish' then '交易完成' end) AS `订单具体状态`,(case `er`.`FNowState` when 'wait_receive_order' then `ad1`.`nickname` when 'wait_apply_materiel' then `ad1`.`nickname` when 'wait_signin_materiel' then `ad1`.`nickname` when 'wait_pick_cargo' then `ad1`.`nickname` when 'wait_storage_connect_confirm' then `ad1`.`nickname` when 'wait_storage_confirm' then `ad1`.`nickname` when 'wait_return_fee' then `ad1`.`nickname` when 'wait_storage_connect' then '仓库主管' when 'wait_pick_materiel' then '仓库主管' when 'wait_confirm_return_fee' then '财务' when 'wait_storage_sort' then `ad2`.`nickname` else '' end) AS `责任部门／人` from ((((((select max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FDate` else '1970-01-01' end)) AS `FDate`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`FDate` else '1970-01-01' end)) AS `FDate2`,`uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FBillNo` AS `FBillNo`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FSupplyID` else '0' end)) AS `FSupplyID`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` AS `FSaleStyle`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FEmpID` else '0' end)) AS `FEmpID`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`FEmpID` else '0' end)) AS `FSmpID`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `pur_FQty`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFAmount` else '0' end)) AS `pur_TalFAmount`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFrist` else '0' end)) AS `pur_expense`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` when 'SEL' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `sor_FQty`,`uctoo_lvhuan`.`trans_main_table`.`FCorrent` AS `FCorrent`,`uctoo_lvhuan`.`trans_main_table`.`FCancellation` AS `FCancellation`,`uctoo_lvhuan`.`trans_main_table`.`FNowState` AS `FNowState` from `uctoo_lvhuan`.`trans_main_table` where (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> 2) group by `uctoo_lvhuan`.`trans_main_table`.`FBillNo`)) `er` join `uctoo_lvhuan`.`uct_branch`) join `uctoo_lvhuan`.`uct_waste_customer`) join `uctoo_lvhuan`.`uct_admin` `ad1`) left join `uctoo_lvhuan`.`uct_admin` `ad2` on((`ad2`.`id` = `er`.`FSmpID`))) where ((`uctoo_lvhuan`.`uct_branch`.`centre_branch_id` = 9) and (`er`.`FRelateBrID` = `uctoo_lvhuan`.`uct_branch`.`setting_key`) and (`uctoo_lvhuan`.`uct_waste_customer`.`id` = `er`.`FSupplyID`) and (`ad1`.`id` = `er`.`FEmpID`) and ((`uctoo_lvhuan`.`uct_branch`.`centre_switch` = 0) or ((`uctoo_lvhuan`.`uct_branch`.`centre_switch` = 1) and (`er`.`FDate` >= convert(date_format(from_unixtime(`uctoo_lvhuan`.`uct_branch`.`updatetime`),'%Y-%m-%d %H:%i:%s') using utf8)))) and (((`er`.`FCorrent` = 1) and (`er`.`FDate2` >= curdate())) or (`er`.`FCorrent` = 0)) and (`er`.`FCancellation` = 1)) order by `er`.`FCorrent` desc,`er`.`FNowState`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_14`;
create view `uctoo_lvhuan`.`test_14` as select `branch`.`name` AS `运营分部归属`,`branch2`.`name` AS `中央仓库归属`,concat(`cu`.`name`,'#',`main`.`FBillNo`) AS `订单号`,`main`.`FDate` AS `订单确认日期`,`main`.`TalFQty` AS `入库量`,`fee`.`FFeeAmount` AS `仓库运营费` from (((((`uctoo_lvhuan`.`trans_main_table` `main` join `uctoo_lvhuan`.`trans_fee_table` `fee`) join `uctoo_lvhuan`.`uct_branch` `branch`) join `uctoo_lvhuan`.`uct_waste_warehouse` `ware`) join `uctoo_lvhuan`.`uct_branch` `branch2`) join `uctoo_lvhuan`.`uct_waste_customer` `cu`) where ((`main`.`FInterID` = `fee`.`FInterID`) and (`main`.`FTranType` = `fee`.`FTranType`) and (`fee`.`FFeeID` = '仓储成本') and (`main`.`FCorrent` = 1) and (`main`.`FCancellation` = 1) and (`main`.`FTranType` = 'SOR') and (`main`.`FDate` like '2020-12%') and (`main`.`FRelateBrID` = `branch`.`setting_key`) and (substr(`main`.`FDCStockID`,3) = `ware`.`id`) and (`ware`.`branch_id` = `branch2`.`setting_key`) and (`main`.`FSupplyID` = `cu`.`id`));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_15`;
create view `uctoo_lvhuan`.`test_15` as select `bra`.`name` AS `branch_id`,sum((case when ((`p`.`state` = 'draft') or (`p`.`state` = 'wait_allot')) then 1 else 0 end)) AS `wait`,sum((case when ((`p`.`state` = 'draft') or (`p`.`state` = 'wait_allot') or (`p`.`state` = 'wait_confirm_return_fee') or (`p`.`state` = 'finish')) then 0 else 1 end)) AS `doing`,sum((case when ((`p`.`state` = 'wait_confirm_return_fee') or (`p`.`state` = 'finish')) then 1 else 0 end)) AS `finish` from (`uctoo_lvhuan`.`uct_waste_purchase` `p` join `uctoo_lvhuan`.`uct_branch` `bra`) where ((`p`.`terminal_type` = 2) and (`p`.`order_id` like '202009%') and (`bra`.`setting_key` = `p`.`branch_id`) and (`bra`.`setting_key` <> 7)) group by `p`.`branch_id` order by count(distinct `p`.`order_id`) desc;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_16`;
create view `uctoo_lvhuan`.`test_16` as select `branch`.`name` AS `仓库归属`,`ad`.`nickname` AS `分拣小组`,count(distinct `main`.`FInterID`) AS `当月已确认订单`,round(sum((case `sort`.`value_type` when 'valuable' then (case `sort`.`disposal_way` when 'sorting' then `ass`.`FQty` else '0' end) else '0' end)),1) AS `有价分拣入库量`,round(sum((case `sort`.`value_type` when 'valuable' then (case `sort`.`disposal_way` when 'weighing' then `ass`.`FQty` else '0' end) else '0' end)),1) AS `有价过磅入库量`,round((sum((case `sort`.`disposal_way` when 'sorting' then (`ass`.`FQty` * `branch`.`sorting_unit_cargo_price`) when 'weighing' then (`ass`.`FQty` * `branch`.`weigh_unit_cargo_price`) else '0' end)) / 1000),2) AS `小组提成金额总计` from ((((((`uctoo_lvhuan`.`trans_main_table` `main` join `uctoo_lvhuan`.`trans_assist_table` `ass`) join `uctoo_lvhuan`.`uct_admin` `ad`) join `uctoo_lvhuan`.`uct_waste_warehouse` `ware`) join `uctoo_lvhuan`.`uct_branch` `branch`) join `uctoo_lvhuan`.`uct_waste_storage_sort` `sort`) join `uctoo_lvhuan`.`uct_waste_cate` `cate`) where ((`main`.`FCorrent` = 1) and (`main`.`FCancellation` = 1) and (`main`.`FTranType` = 'SOR') and (`main`.`FTranType` = `ass`.`FTranType`) and (`main`.`FInterID` = `ass`.`FinterID`) and (`main`.`FEmpID` = `ad`.`id`) and (substr(`main`.`FDCStockID`,3) = `ware`.`id`) and (`ware`.`branch_id` = `branch`.`setting_key`) and (`main`.`FDate` like '2022-05%') and (`sort`.`id` = `ass`.`FEntryID`) and (`ass`.`FItemID` = `cate`.`id`) and (not((`cate`.`name` like '%废弃物%')))) group by `main`.`FEmpID`,`main`.`FDCStockID` order by `main`.`FDCStockID`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_18`;
create view `uctoo_lvhuan`.`test_18` as select concat(`cus`.`name`,'#',`main`.`FBillNo`) AS `订单号`,`ad`.`nickname` AS `分拣组长`,(case `ass`.`disposal_way` when 'sorting' then '分拣' when 'weighing' then '过磅' end) AS `分拣属性`,(case `ass`.`value_type` when 'valuable' then '有价' when 'unvaluable' then '低值' end) AS `价值属性`,sum(`ass`.`FQty`) AS `净重` from (((`uctoo_lvhuan`.`trans_main_table` `main` join `uctoo_lvhuan`.`trans_assist_table` `ass`) join `uctoo_lvhuan`.`uct_admin` `ad`) join `uctoo_lvhuan`.`uct_waste_customer` `cus`) where ((`main`.`FInterID` = `ass`.`FinterID`) and (`main`.`FTranType` = `ass`.`FTranType`) and (`main`.`FTranType` = 'SOR') and (`main`.`FCorrent` = '1') and (`main`.`FCancellation` = '1') and (`ad`.`id` = `main`.`FSManagerID`) and (`main`.`FDate` like '2022-05%') and (`main`.`FSupplyID` in ('2567','973','247')) and (`cus`.`id` = `main`.`FSupplyID`)) group by `ass`.`disposal_way`,`ass`.`value_type`,`main`.`FSManagerID`,`main`.`FBillNo`;






DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_5`;
create view `uctoo_lvhuan`.`test_5` as select `uctoo_lvhuan`.`uct_branch`.`name` AS `分部归属`,concat(`uctoo_lvhuan`.`uct_waste_customer`.`name`,'#',`er`.`FBillNo`) AS `订单号`,`er`.`FDate` AS `采购日期`,(case `er`.`FSaleStyle` when '1' then '直销' when '0' then '采购回库' when '3' then '送框' end) AS `采购类型`,`uctoo_lvhuan`.`uct_admin`.`nickname` AS `采购负责人`,`er`.`pur_FQty` AS `采购总净重`,round(`er`.`pur_TalFAmount`,2) AS `采购货款`,round(`er`.`pur_expense`,2) AS `采购费用`,`er`.`sor_FQty` AS `分拣总净重`,round(`er`.`prefit`,2) AS `毛利润`,(case `er`.`FCorrent` when '1' then '已完成' when '0' then '未完成' end) AS `订单状态`,(case `er`.`FCancellation` when '1' then '正常' when '0' then '已取消' end) AS `有效状态` from (((((select max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FDate` else '0' end)) AS `FDate`,`uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FBillNo` AS `FBillNo`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FSupplyID` else '0' end)) AS `FSupplyID`,`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` AS `FSaleStyle`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`FEmpID` else '0' end)) AS `FEmpID`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `pur_FQty`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFAmount` else '0' end)) AS `pur_TalFAmount`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then `uctoo_lvhuan`.`trans_main_table`.`TalFrist` else '0' end)) AS `pur_expense`,max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` when 'SEL' then `uctoo_lvhuan`.`trans_main_table`.`TalFQty` else '0' end)) AS `sor_FQty`,`uctoo_lvhuan`.`trans_main_table`.`FCorrent` AS `FCorrent`,`uctoo_lvhuan`.`trans_main_table`.`FCancellation` AS `FCancellation`,sum(if((`uctoo_lvhuan`.`trans_main_table`.`FCorrent` = '1'),(case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then ((((-(`uctoo_lvhuan`.`trans_main_table`.`TalFAmount`) - `uctoo_lvhuan`.`trans_main_table`.`TalFrist`) - `uctoo_lvhuan`.`trans_main_table`.`TalSecond`) - `uctoo_lvhuan`.`trans_main_table`.`TalThird`) - `uctoo_lvhuan`.`trans_main_table`.`TalForth`) when 'SOR' then (((`uctoo_lvhuan`.`trans_main_table`.`TalFAmount` - `uctoo_lvhuan`.`trans_main_table`.`TalFrist`) - `uctoo_lvhuan`.`trans_main_table`.`TalSecond`) - `uctoo_lvhuan`.`trans_main_table`.`TalThird`) when 'SEL' then ((`uctoo_lvhuan`.`trans_main_table`.`TalFAmount` + `uctoo_lvhuan`.`trans_main_table`.`TalFrist`) + `uctoo_lvhuan`.`trans_main_table`.`TalSecond`) else '0' end),'0')) AS `prefit` from `uctoo_lvhuan`.`trans_main_table` where (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> 2) group by `uctoo_lvhuan`.`trans_main_table`.`FBillNo`)) `er` join `uctoo_lvhuan`.`uct_branch`) join `uctoo_lvhuan`.`uct_waste_customer`) join `uctoo_lvhuan`.`uct_admin`) where ((`uctoo_lvhuan`.`uct_branch`.`setting_key` = `er`.`FRelateBrID`) and (`uctoo_lvhuan`.`uct_waste_customer`.`id` = `er`.`FSupplyID`) and (`uctoo_lvhuan`.`uct_admin`.`id` = `er`.`FEmpID`) and (`er`.`FDate` >= '2020-01-01 00:00:00') and (`er`.`FDate` <= '2020-07-01 00:00:00') and (`er`.`FRelateBrID` <> 7));






DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_6`;
create view `uctoo_lvhuan`.`test_6` as select `uctoo_lvhuan`.`uct_waste_purchase`.`id` AS `id`,'武汉蔡甸分部' AS `分部归属`,concat('#',`uctoo_lvhuan`.`uct_waste_purchase`.`order_id`) AS `订单号`,`uctoo_lvhuan`.`uct_waste_customer`.`name` AS `客户名称`,date_format(from_unixtime(`log`.`Tpurchase`),'%Y-%m-%d') AS `采购时间`,(case `uctoo_lvhuan`.`uct_waste_purchase`.`hand_mouth_data` when '1' then '直销' when '0' then '采购回库' end) AS `采购形式`,(case `uctoo_lvhuan`.`uct_waste_purchase`.`give_frame` when '1' then '送框' when '0' then '采购回库' end) AS `送框形式`,`uctoo_lvhuan`.`uct_admin`.`nickname` AS `采购负责人`,(case `uctoo_lvhuan`.`uct_waste_purchase`.`state` when 'draft' then '草稿' when 'wait_allot' then '待分配' when 'wait_receive_order' then '待接单' when 'wait_apply_materiel' then '待申请辅材' when 'wait_pick_materiel' then '待提取辅材' when 'wait_signin_materiel' then '待签收辅材' when 'wait_pick_cargo' then '待提货' when 'wait_pay' then '待付款' when 'wait_storage_connect' then '待入库交接' when 'wait_storage_connect_confirm' then '待确认交接' when 'wait_storage_sort' then '待分拣入库' when 'wait_storage_confirm' then '待入库确认' when 'wait_return_fee' then '待订单报销' end) AS `订单状态`,'' AS `原因说明`,'' AS `是否取消订单` from (((`uctoo_lvhuan`.`uct_waste_purchase` join `uctoo_lvhuan`.`uct_waste_customer`) join `uctoo_lvhuan`.`uct_admin`) join (select `uctoo_lvhuan`.`trans_log_table`.`FInterID` AS `FInterID`,`uctoo_lvhuan`.`trans_log_table`.`FTranType` AS `FTranType`,`uctoo_lvhuan`.`trans_log_table`.`TpurchaseOver` AS `TpurchaseOver`,`uctoo_lvhuan`.`trans_log_table`.`TpurchasePerson` AS `TpurchasePerson`,`uctoo_lvhuan`.`trans_log_table`.`Tpurchase` AS `Tpurchase` from `uctoo_lvhuan`.`trans_log_table` where (`uctoo_lvhuan`.`trans_log_table`.`FTranType` = 'PUR')) `log`) where ((`uctoo_lvhuan`.`uct_waste_purchase`.`branch_id` = '16') and (`uctoo_lvhuan`.`uct_waste_purchase`.`state` <> 'finish') and (`uctoo_lvhuan`.`uct_waste_purchase`.`customer_id` = `uctoo_lvhuan`.`uct_waste_customer`.`id`) and (`uctoo_lvhuan`.`uct_waste_purchase`.`purchase_incharge` = `uctoo_lvhuan`.`uct_admin`.`id`) and (`uctoo_lvhuan`.`uct_waste_purchase`.`state` <> 'cancel') and (`log`.`FInterID` = `uctoo_lvhuan`.`uct_waste_purchase`.`id`) and (`uctoo_lvhuan`.`uct_waste_purchase`.`state` <> 'wait_confirm_return_fee') and ((`log`.`Tpurchase` > '1554047999') or (`log`.`TpurchaseOver` = '0'))) order by `log`.`Tpurchase`;







DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_7`;
create view `uctoo_lvhuan`.`test_7` as select `ma`.`FDate` AS `FDate`,(case `ma`.`FRelateBrID` when '1' then '深圳宝安分部' when '2' then '成都崇州分部' when '3' then '昆山张浦分部' when '4' then '厦门翔安分部' when '5' then '东莞黄江分部' when '8' then '东莞横沥分部' when '9' then '东莞大岭山分部' when '10' then '东莞凤岗分部' when '13' then '苏州常熟分部' when '16' then '武汉蔡甸分部' when '17' then '深圳龙华分部' when '18' then '重庆永川分部' when '19' then '苏州园区分部' when '15' then '贵阳贵安分部' when '6' then '第一项目组' when '20' then '低废业务部' when '21' then '第二项目组' end) AS `branch`,-(sum(ifnull(`ass`.`FAmount`,0))) AS `rb_count`,'低值废弃物预售' AS `type` from ((((select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FInterID` AS `FInterID`,date_format(max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`FDate` else '1970-01-01' end)),'%Y-%m-%d') AS `FDate` from `uctoo_lvhuan`.`trans_main_table` where ((`uctoo_lvhuan`.`trans_main_table`.`FCorrent` = 1) and (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1) and (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` = 0)) group by `uctoo_lvhuan`.`trans_main_table`.`FBillNo`)) `ma` join `uctoo_lvhuan`.`trans_assist_table` `ass`) join `uctoo_lvhuan`.`uct_waste_cate` `ca`) where ((`ma`.`FInterID` = `ass`.`FinterID`) and (`ass`.`FTranType` = 'SOR') and (`ca`.`id` = `ass`.`FItemID`) and (`ca`.`name` = '低值废弃物') and (`ma`.`FDate` >= '2020-01-31')) group by `ma`.`FRelateBrID`,`ma`.`FDate` union all select `ma`.`FDate` AS `FDate`,(case `ma`.`FRelateBrID` when '1' then '深圳宝安分部' when '2' then '成都崇州分部' when '3' then '昆山张浦分部' when '4' then '厦门翔安分部' when '5' then '东莞黄江分部' when '8' then '东莞横沥分部' when '9' then '东莞大岭山分部' when '10' then '东莞凤岗分部' when '13' then '苏州常熟分部' when '16' then '武汉蔡甸分部' when '17' then '深圳龙华分部' when '18' then '重庆永川分部' when '19' then '苏州园区分部' when '15' then '贵阳贵安分部' when '6' then '第一项目组' when '20' then '低废业务部' when '21' then '第二项目组' end) AS `branch`,sum(ifnull(`fe`.`FFeeAmount`,0)) AS `rb_fee`,'供应商垃圾补助费' AS `type` from (((select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FInterID` AS `FInterID`,date_format(max((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_main_table`.`FDate` else '1970-01-01' end)),'%Y-%m-%d') AS `FDate` from `uctoo_lvhuan`.`trans_main_table` where ((`uctoo_lvhuan`.`trans_main_table`.`FCorrent` = 1) and (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1) and (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` = 0)) group by `uctoo_lvhuan`.`trans_main_table`.`FBillNo`)) `ma` join `uctoo_lvhuan`.`trans_fee_table` `fe`) where ((`ma`.`FInterID` = `fe`.`FInterID`) and (`fe`.`FTranType` = 'PUR') and (`fe`.`FFeeID` = '供应商垃圾补助费') and (`ma`.`FDate` >= '2020-01-31')) group by `ma`.`FRelateBrID`,`ma`.`FDate`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_8`;
create view  `uctoo_lvhuan`.`test_8` as select `uctoo_lvhuan`.`uct_branch`.`name` AS `name`,`uctoo_lvhuan`.`uct_sms`.`mobile` AS `mobile`,date_format(max(`uctoo_lvhuan`.`uct_sms`.`createtime`),'%Y-%m') AS `createtime` from ((`uctoo_lvhuan`.`uct_sms` join `uctoo_lvhuan`.`uct_admin`) join `uctoo_lvhuan`.`uct_branch`) where ((`uctoo_lvhuan`.`uct_sms`.`event` = 'register') and (`uctoo_lvhuan`.`uct_admin`.`mobile` = `uctoo_lvhuan`.`uct_sms`.`mobile`) and (`uctoo_lvhuan`.`uct_branch`.`setting_key` = `uctoo_lvhuan`.`uct_admin`.`branch_id`) and (`uctoo_lvhuan`.`uct_branch`.`setting_key` <> 7)) group by `uctoo_lvhuan`.`uct_sms`.`mobile`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_9`;
create view `uctoo_lvhuan`.`test_9` as select `bra`.`name` AS `分部归属`,concat('#',`p`.`order_id`) AS `订单号`,`cu`.`name` AS `客户名称`,`ad`.`nickname` AS `采购负责人`,`ev`.`remove_fast_star` AS `清运及时评分`,`ev`.`remove_level_star` AS `清运程度评分`,`ev`.`service_attitude_star` AS `服务态度评分`,`ev`.`content` AS `评价留言`,`io`.`img_in_url` AS `签到图片`,`io`.`img_out_url` AS `签退图片` from (((((`uctoo_lvhuan`.`uct_waste_purchase` `p` left join `uctoo_lvhuan`.`uct_purchase_sign_in_out` `io` on((`p`.`id` = `io`.`purchase_id`))) left join `uctoo_lvhuan`.`uct_waste_purchase_evaluate` `ev` on((`ev`.`purchase_id` = `p`.`id`))) left join `uctoo_lvhuan`.`uct_admin` `ad` on((`ad`.`id` = `p`.`purchase_incharge`))) join `uctoo_lvhuan`.`uct_waste_customer` `cu`) join `uctoo_lvhuan`.`uct_branch` `bra`) where ((`p`.`terminal_type` = 2) and (`p`.`state` <> 'cancel') and (`cu`.`id` = `p`.`customer_id`) and (`p`.`order_id` between '202205010000000000' and '202205312359599999') and (`bra`.`setting_key` = `p`.`branch_id`));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_user`;
create view `uctoo_lvhuan`.`test_user` as select `uctoo_lvhuan`.`uct_waste_customer`.`name` AS `name`,`uctoo_lvhuan`.`uct_admin`.`nickname` AS `nickname`,`uctoo_lvhuan`.`uct_admin`.`username` AS `username`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_id` AS `customer_id`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `customer_linkman_id`,from_unixtime(max(`uctoo_lvhuan`.`uct_waste_sell`.`createtime`)) AS `createtime` from ((`uctoo_lvhuan`.`uct_waste_sell` join `uctoo_lvhuan`.`uct_waste_customer`) join `uctoo_lvhuan`.`uct_admin`) where ((`uctoo_lvhuan`.`uct_waste_customer`.`id` = `uctoo_lvhuan`.`uct_waste_sell`.`customer_id`) and (`uctoo_lvhuan`.`uct_waste_sell`.`customer_linkman_id` = `uctoo_lvhuan`.`uct_admin`.`id`)) group by `uctoo_lvhuan`.`uct_waste_sell`.`customer_id`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`tran_total_cargo_pc`;
create view `uctoo_lvhuan`.`tran_total_cargo_pc` as select `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `FInterID`,sum(`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`net_weight`) AS `FQtyTotal`,round(sum(`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`total_price`),2) AS `FAmountTotal`,'' AS `FSourceInterId`,'' AS `FSourceTranType` from `uctoo_lvhuan`.`uct_waste_purchase_cargo` group by `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`;




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_constitute_forcustomer`;
create view `uctoo_lvhuan`.`trans_constitute_forcustomer` as select `kk`.`FRelateBrID` AS `FRelateBrID`,`kk`.`FSupplyID` AS `FSupplyID`,`kk`.`Fbusiness` AS `Fbusiness`,`kk`.`parent_id` AS `parent_id`,round(sum(`kk`.`FQty`),2) AS `FQty`,`uctoo_lvhuan`.`uct_waste_cate`.`carbon_parm` AS `carbon_parm` from (((select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FSupplyID` AS `FSupplyID`,`uctoo_lvhuan`.`trans_main_table`.`Fbusiness` AS `Fbusiness`,`uctoo_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,`uctoo_lvhuan`.`uct_waste_cate`.`parent_id` AS `parent_id`,`uctoo_lvhuan`.`trans_assist_table`.`FQty` AS `FQty` from ((`uctoo_lvhuan`.`trans_main_table` join `uctoo_lvhuan`.`trans_assist_table`) join `uctoo_lvhuan`.`uct_waste_cate`) where ((`uctoo_lvhuan`.`trans_main_table`.`FInterID` = `uctoo_lvhuan`.`trans_assist_table`.`FinterID`) and (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = 'PUR') and (`uctoo_lvhuan`.`trans_main_table`.`FTranType` = 'PUR') and (`uctoo_lvhuan`.`uct_waste_cate`.`id` = `uctoo_lvhuan`.`trans_assist_table`.`FItemID`) and (`uctoo_lvhuan`.`trans_main_table`.`FStatus` = 1) and (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1)))) `kk` join `uctoo_lvhuan`.`uct_waste_cate`) where (`uctoo_lvhuan`.`uct_waste_cate`.`id` = `kk`.`parent_id`) group by `kk`.`FSupplyID`,`kk`.`parent_id`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_daily_invfordep`;
create view `uctoo_lvhuan`.`trans_daily_invfordep` as select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FDeptID` AS `FDeptID`,(case `uctoo_lvhuan`.`uct_waste_cate`.`name` when '垃圾' then '1' else '0' end) AS `trash_is`,round(sum((case `uctoo_lvhuan`.`trans_assist_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else '0' end)),1) AS `input`,round(sum((case `uctoo_lvhuan`.`trans_assist_table`.`FTranType` when 'SEL' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else '0' end)),1) AS `output`,max(date_format(`uctoo_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d')) AS `FDCTime` from ((`uctoo_lvhuan`.`trans_assist_table` join `uctoo_lvhuan`.`trans_main_table`) join `uctoo_lvhuan`.`uct_waste_cate`) where ((`uctoo_lvhuan`.`trans_assist_table`.`FinterID` = `uctoo_lvhuan`.`trans_main_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = `uctoo_lvhuan`.`trans_main_table`.`FTranType`) and (`uctoo_lvhuan`.`trans_assist_table`.`FItemID` = `uctoo_lvhuan`.`uct_waste_cate`.`id`) and (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> '1') and (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` <> 'PUR') and (date_format(`uctoo_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d') = curdate()) and (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1)) group by date_format(`uctoo_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d'),`uctoo_lvhuan`.`trans_main_table`.`FDeptID`,`uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`,(case `uctoo_lvhuan`.`uct_waste_cate`.`name` when '垃圾' then '1' else '0' end);



DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_fee`;
create view `uctoo_lvhuan`.`trans_fee` as select `uctoo_lvhuan`.`uct_waste_purchase_expense`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,'PC' AS `Ffeesence`,`uctoo_lvhuan`.`uct_waste_purchase_expense`.`id` AS `FEntryID`,`uctoo_lvhuan`.`uct_waste_purchase_expense`.`usage` AS `FFeeID`,`uctoo_lvhuan`.`uct_waste_purchase_expense`.`type` AS `FFeeType`,`uctoo_lvhuan`.`uct_waste_purchase_expense`.`receiver` AS `FFeePerson`,`uctoo_lvhuan`.`uct_waste_purchase_expense`.`remark` AS `FFeeExplain`,`uctoo_lvhuan`.`uct_waste_purchase_expense`.`price` AS `FFeeAmount`,'' AS `FFeebaseAmount`,'' AS `Ftaxrate`,'' AS `Fbasetax`,'' AS `Fbasetaxamount`,'' AS `FPriceRef`,date_format(from_unixtime(`uctoo_lvhuan`.`uct_waste_purchase_expense`.`createtime`),'%Y-%m-%d %H:%i:%S') AS `FFeetime` from `uctoo_lvhuan`.`uct_waste_purchase_expense` union all select `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,'RF' AS `Ffeesence`,`uctoo_lvhuan`.`uct_waste_storage_return_fee`.`id` AS `FEntryID`,`uctoo_lvhuan`.`uct_waste_storage_return_fee`.`usage` AS `FFeeID`,'out' AS `FFeeType`,`uctoo_lvhuan`.`uct_waste_storage_return_fee`.`receiver` AS `FFeePerson`,`uctoo_lvhuan`.`uct_waste_storage_return_fee`.`remark` AS `FFeeExplain`,`uctoo_lvhuan`.`uct_waste_storage_return_fee`.`price` AS `FFeeAmount`,'' AS `FFeebaseAmount`,'' AS `Ftaxrate`,'' AS `Fbasetax`,'' AS `Fbasetaxamount`,'' AS `FPriceRef`,date_format(from_unixtime(`uctoo_lvhuan`.`uct_waste_storage_return_fee`.`createtime`),'%Y-%m-%d %H:%i:%S') AS `FFeetime` from `uctoo_lvhuan`.`uct_waste_storage_return_fee` union all select `uctoo_lvhuan`.`uct_waste_storage_expense`.`purchase_id` AS `FInterID`,'SOR' AS `FTranType`,'SO' AS `Ffeesence`,`uctoo_lvhuan`.`uct_waste_storage_expense`.`id` AS `FEntryID`,`uctoo_lvhuan`.`uct_waste_storage_expense`.`usage` AS `FFeeID`,'out' AS `FFeeType`,`uctoo_lvhuan`.`uct_waste_storage_expense`.`receiver` AS `FFeePerson`,`uctoo_lvhuan`.`uct_waste_storage_expense`.`remark` AS `FFeeExplain`,`uctoo_lvhuan`.`uct_waste_storage_expense`.`price` AS `FFeeAmount`,'' AS `FFeebaseAmount`,'' AS `Ftaxrate`,'' AS `Fbasetax`,'' AS `Fbasetaxamount`,'' AS `FPriceRef`,date_format(from_unixtime(`uctoo_lvhuan`.`uct_waste_storage_expense`.`createtime`),'%Y-%m-%d %H:%i:%S') AS `FFeetime` from `uctoo_lvhuan`.`uct_waste_storage_expense` union all select `uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`purchase_id` AS `FInterID`,'SOR' AS `FTranType`,'SS' AS `Ffeesence`,`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`id` AS `FEntryID`,`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`usage` AS `FFeeID`,'out' AS `FFeeType`,`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`receiver` AS `FFeePerson`,`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`remark` AS `FFeeExplain`,`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`price` AS `FFeeAmount`,'' AS `FFeebaseAmount`,'' AS `Ftaxrate`,'' AS `Fbasetax`,'' AS `Fbasetaxamount`,'' AS `FPriceRef`,date_format(from_unixtime(`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`createtime`),'%Y-%m-%d %H:%i:%S') AS `FFeetime` from `uctoo_lvhuan`.`uct_waste_storage_sort_expense` union all select `uctoo_lvhuan`.`uct_waste_sell_other_price`.`sell_id` AS `FInterID`,'SEL' AS `FTranType`,'SL' AS `Ffeesence`,`uctoo_lvhuan`.`uct_waste_sell_other_price`.`id` AS `FEntryID`,`uctoo_lvhuan`.`uct_waste_sell_other_price`.`usage` AS `FFeeID`,`uctoo_lvhuan`.`uct_waste_sell_other_price`.`type` AS `FFeeType`,`uctoo_lvhuan`.`uct_waste_sell_other_price`.`receiver` AS `FFeePerson`,`uctoo_lvhuan`.`uct_waste_sell_other_price`.`remark` AS `FFeeExplain`,`uctoo_lvhuan`.`uct_waste_sell_other_price`.`price` AS `FFeeAmount`,'' AS `FFeebaseAmount`,'' AS `Ftaxrate`,'' AS `Fbasetax`,'' AS `Fbasetaxamount`,'' AS `FPriceRef`,date_format(from_unixtime(`uctoo_lvhuan`.`uct_waste_sell_other_price`.`createtime`),'%Y-%m-%d %H:%i:%S') AS `FFeetime` from `uctoo_lvhuan`.`uct_waste_sell_other_price`;




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_forcustomer`;
create view  `uctoo_lvhuan`.`trans_forcustomer` as select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FSupplyID` AS `FSupplyID`,`uctoo_lvhuan`.`trans_main_table`.`Fbusiness` AS `Fbusiness`,`uctoo_lvhuan`.`trans_main_table`.`TalFQty` AS `total_weight`,`uctoo_lvhuan`.`trans_main_table`.`TalFAmount` AS `total_profit`,sum((case `uctoo_lvhuan`.`uct_waste_cate`.`name` when '垃圾' then 0 else `taltrash`.`trash_weight` end)) AS `trash_weight`,round((sum(`taltrash`.`trash_weight`) * `uctoo_lvhuan`.`uct_waste_cate`.`carbon_parm`),3) AS `carbon_parmTal`,date_format(`uctoo_lvhuan`.`trans_main_table`.`FDate`,'%Y-%m-%d') AS `FDate` from ((`uctoo_lvhuan`.`trans_main_table` join (select `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `FInterID`,`uctoo_lvhuan`.`uct_waste_cate`.`parent_id` AS `cate_id`,sum(`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`net_weight`) AS `trash_weight` from (`uctoo_lvhuan`.`uct_waste_purchase_cargo` join `uctoo_lvhuan`.`uct_waste_cate`) where (`uctoo_lvhuan`.`uct_waste_cate`.`id` = `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`cate_id`) group by `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`,`uctoo_lvhuan`.`uct_waste_cate`.`parent_id`) `taltrash`) join `uctoo_lvhuan`.`uct_waste_cate`) where ((`uctoo_lvhuan`.`trans_main_table`.`FTranType` = 'PUR') and (`taltrash`.`FInterID` = `uctoo_lvhuan`.`trans_main_table`.`FInterID`) and (`uctoo_lvhuan`.`uct_waste_cate`.`id` = `taltrash`.`cate_id`) and (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1)) group by `uctoo_lvhuan`.`trans_main_table`.`FInterID`;





DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_fororder`;
create view `uctoo_lvhuan`.`trans_fororder` as select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FDeptID` AS `FDeptID`,sum((case `uctoo_lvhuan`.`trans_main_table`.`FTranType` when 'PUR' then '1' when 'SEL' then '1' else '0' end)) AS `order_count` from `uctoo_lvhuan`.`trans_main_table` group by `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FDeptID`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_log`;
create view `uctoo_lvhuan`.`trans_log` as select `log`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,max((case `log`.`state_value` when 'draft' then `log`.`createtime` end)) AS `TCreate`,max((case `log`.`state_value` when 'draft' then `log`.`admin_id` end)) AS `TCreatePerson`,max((case `log`.`state_value` when 'wait_allot' then '1' else '0' end)) AS `TallotOver`,max((case `log`.`state_value` when 'wait_allot' then `log`.`admin_id` else NULL end)) AS `TallotPerson`,max((case `log`.`state_value` when 'wait_allot' then `log`.`createtime` else NULL end)) AS `Tallot`,max((case `log`.`state_value` when 'wait_receive_order' then '1' else '0' end)) AS `TgetorderOver`,max((case `log`.`state_value` when 'wait_receive_order' then `log`.`admin_id` else NULL end)) AS `TgetorderPerson`,max((case `log`.`state_value` when 'wait_receive_order' then `log`.`createtime` else NULL end)) AS `Tgetorder`,max((case `log`.`state_value` when 'wait_signin_materiel' then '1' else '0' end)) AS `TmaterialOver`,max((case `log`.`state_value` when 'wait_signin_materiel' then `log`.`admin_id` else NULL end)) AS `TmaterialPerson`,max((case `log`.`state_value` when 'wait_signin_materiel' then `log`.`createtime` else NULL end)) AS `Tmaterial`,max((case `log`.`state_value` when 'wait_pick_cargo' then '1' else '0' end)) AS `TpurchaseOver`,max((case `log`.`state_value` when 'wait_pick_cargo' then `log`.`admin_id` else NULL end)) AS `TpurchasePerson`,max((case `log`.`state_value` when 'wait_pick_cargo' then `log`.`createtime` else NULL end)) AS `Tpurchase`,max((case `log`.`state_value` when 'wait_pay' then '1' else '0' end)) AS `TpayOver`,max((case `log`.`state_value` when 'wait_pay' then `log`.`admin_id` else NULL end)) AS `TpayPerson`,max((case `log`.`state_value` when 'wait_pay' then `log`.`createtime` else NULL end)) AS `Tpay`,max((case `log`.`state_value` when 'wait_storage_connect' then '1' else '0' end)) AS `TchangeOver`,max((case `log`.`state_value` when 'wait_storage_connect' then `log`.`admin_id` else NULL end)) AS `TchangePerson`,max((case `log`.`state_value` when 'wait_storage_connect' then `log`.`createtime` else NULL end)) AS `Tchange`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then '1' else '0' end)) AS `TexpenseOver`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then `log`.`admin_id` else NULL end)) AS `TexpensePerson`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then `log`.`createtime` else NULL end)) AS `Texpense`,max((case `log`.`state_value` when 'wait_storage_sort' then '1' else '0' end)) AS `TsortOver`,max((case `log`.`state_value` when 'wait_storage_sort' then `log`.`admin_id` else NULL end)) AS `TsortPerson`,max((case `log`.`state_value` when 'wait_storage_sort' then `log`.`createtime` else NULL end)) AS `Tsort`,max((case `log`.`state_value` when 'wait_storage_confirm' then '1' else '0' end)) AS `TallowOver`,max((case `log`.`state_value` when 'wait_storage_confirm' then `log`.`admin_id` else NULL end)) AS `TallowPerson`,max((case `log`.`state_value` when 'wait_storage_confirm' then `log`.`createtime` else NULL end)) AS `Tallow`,max((case `log`.`state_value` when 'finish' then '1' else '0' end)) AS `TcheckOver`,max((case `log`.`state_value` when 'finish' then `log`.`admin_id` else NULL end)) AS `TcheckPerson`,max((case `log`.`state_value` when 'finish' then `log`.`createtime` else '0' end)) AS `Tcheck`,`uctoo_lvhuan`.`uct_waste_purchase`.`state` AS `State` from (`uctoo_lvhuan`.`uct_waste_purchase` join `uctoo_lvhuan`.`uct_waste_purchase_log` `log`) where ((`uctoo_lvhuan`.`uct_waste_purchase`.`id` = `log`.`purchase_id`) and (`uctoo_lvhuan`.`uct_waste_purchase`.`hand_mouth_data` = '0') and (`uctoo_lvhuan`.`uct_waste_purchase`.`give_frame` = '0')) group by `uctoo_lvhuan`.`uct_waste_purchase`.`id` union all select `log`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,max((case `log`.`state_value` when 'draft' then `log`.`createtime` end)) AS `TCreate`,max((case `log`.`state_value` when 'draft' then `log`.`admin_id` end)) AS `TCreatePerson`,max((case `log`.`state_value` when 'wait_allot' then '1' else '0' end)) AS `TallotOver`,max((case `log`.`state_value` when 'wait_allot' then `log`.`admin_id` else NULL end)) AS `TallotPerson`,max((case `log`.`state_value` when 'wait_allot' then `log`.`createtime` else NULL end)) AS `Tallot`,max((case `log`.`state_value` when 'wait_receive_order' then '1' else '0' end)) AS `TgetorderOver`,max((case `log`.`state_value` when 'wait_receive_order' then `log`.`admin_id` else NULL end)) AS `TgetorderPerson`,max((case `log`.`state_value` when 'wait_receive_order' then `log`.`createtime` else NULL end)) AS `Tgetorder`,max((case `log`.`state_value` when 'wait_signin_materiel' then '1' else '0' end)) AS `TmaterialOver`,max((case `log`.`state_value` when 'wait_signin_materiel' then `log`.`admin_id` else NULL end)) AS `TmaterialPerson`,max((case `log`.`state_value` when 'wait_signin_materiel' then `log`.`createtime` else NULL end)) AS `Tmaterial`,max((case `log`.`state_value` when 'wait_pick_cargo' then '1' else '0' end)) AS `TpurchaseOver`,max((case `log`.`state_value` when 'wait_pick_cargo' then `log`.`admin_id` else NULL end)) AS `TpurchasePerson`,max((case `log`.`state_value` when 'wait_pick_cargo' then `log`.`createtime` else NULL end)) AS `Tpurchase`,max((case `log`.`state_value` when 'wait_pay' then '1' else '0' end)) AS `TpayOver`,max((case `log`.`state_value` when 'wait_pay' then `log`.`admin_id` else NULL end)) AS `TpayPerson`,max((case `log`.`state_value` when 'wait_pay' then `log`.`createtime` else NULL end)) AS `Tpay`,max((case `log`.`state_value` when 'wait_storage_connect' then '1' else '0' end)) AS `TchangeOver`,max((case `log`.`state_value` when 'wait_storage_connect' then `log`.`admin_id` else NULL end)) AS `TchangePerson`,max((case `log`.`state_value` when 'wait_storage_connect' then `log`.`createtime` else NULL end)) AS `Tchange`,NULL AS `TexpenseOver`,NULL AS `TexpensePerson`,NULL AS `Texpense`,NULL AS `TsortOver`,NULL AS `TsortPerson`,NULL AS `Tsort`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then '1' else '0' end)) AS `TallowOver`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then `log`.`admin_id` else NULL end)) AS `TallowPerson`,max((case `log`.`state_value` when 'wait_storage_connect_confirm' then `log`.`createtime` else NULL end)) AS `Tallow`,max((case `log`.`state_value` when 'finish' then '1' else '0' end)) AS `TcheckOver`,max((case `log`.`state_value` when 'finish' then `log`.`admin_id` else NULL end)) AS `TcheckPerson`,max((case `log`.`state_value` when 'finish' then `log`.`createtime` else '0' end)) AS `Tcheck`,`uctoo_lvhuan`.`uct_waste_purchase`.`state` AS `State` from (`uctoo_lvhuan`.`uct_waste_purchase` join `uctoo_lvhuan`.`uct_waste_purchase_log` `log`) where ((`uctoo_lvhuan`.`uct_waste_purchase`.`id` = `log`.`purchase_id`) and (`uctoo_lvhuan`.`uct_waste_purchase`.`hand_mouth_data` = '0') and (`uctoo_lvhuan`.`uct_waste_purchase`.`give_frame` = '1')) group by `uctoo_lvhuan`.`uct_waste_purchase`.`id` union all select `log`.`sell_id` AS `FInterID`,'SEL' AS `FTranType`,max((case `log`.`state_value` when 'draft' then `log`.`createtime` end)) AS `TCreate`,max((case `log`.`state_value` when 'draft' then `log`.`admin_id` end)) AS `TCreatePerson`,NULL AS `TallotOver`,NULL AS `TallotPerson`,NULL AS `Tallot`,NULL AS `TgetorderOver`,NULL AS `TgetorderPerson`,NULL AS `Tgetorder`,NULL AS `TmaterialOver`,NULL AS `TmaterialPerson`,NULL AS `Tmaterial`,max((case `log`.`state_value` when 'wait_weigh' then '1' else '0' end)) AS `TpurchaseOver`,max((case `log`.`state_value` when 'wait_weigh' then `log`.`admin_id` else NULL end)) AS `TpurchasePerson`,max((case `log`.`state_value` when 'wait_weigh' then `log`.`createtime` else NULL end)) AS `Tpurchase`,NULL AS `TpayOver`,NULL AS `TpayPerson`,NULL AS `Tpay`,NULL AS `TchangeOver`,NULL AS `TchangePerson`,NULL AS `Tchange`,NULL AS `TexpenseOver`,NULL AS `TexpensePerson`,NULL AS `Texpense`,NULL AS `TsortOver`,NULL AS `TsortPerson`,NULL AS `Tsort`,max((case `log`.`state_value` when 'wait_confirm_order' then '1' else '0' end)) AS `TallowOver`,max((case `log`.`state_value` when 'wait_confirm_order' then `log`.`admin_id` else NULL end)) AS `TallowPerson`,max((case `log`.`state_value` when 'wait_confirm_order' then `log`.`createtime` else NULL end)) AS `Tallow`,max((case `log`.`state_value` when 'wait_pay' then '1' else '0' end)) AS `TcheckOver`,max((case `log`.`state_value` when 'wait_pay' then `log`.`admin_id` else NULL end)) AS `TcheckPerson`,max((case `log`.`state_value` when 'wait_pay' then `log`.`createtime` else '0' end)) AS `Tcheck`,`uctoo_lvhuan`.`uct_waste_sell`.`state` AS `State` from (`uctoo_lvhuan`.`uct_waste_sell` join `uctoo_lvhuan`.`uct_waste_sell_log` `log`) where ((`uctoo_lvhuan`.`uct_waste_sell`.`id` = `log`.`sell_id`) and isnull(`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id`)) group by `uctoo_lvhuan`.`uct_waste_sell`.`id` union all select `plog`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,max((case `plog`.`state_value` when 'draft' then `plog`.`createtime` end)) AS `TCreate`,max((case `plog`.`state_value` when 'draft' then `plog`.`admin_id` end)) AS `TCreatePerson`,max((case `plog`.`state_value` when 'wait_allot' then '1' else '0' end)) AS `TallotOver`,max((case `plog`.`state_value` when 'wait_allot' then `plog`.`admin_id` end)) AS `TallotPerson`,max((case `plog`.`state_value` when 'wait_allot' then `plog`.`createtime` end)) AS `Tallot`,max((case `slog`.`state_value` when 'wait_commit_order' then '1' else '0' end)) AS `TgetorderOver`,max((case `slog`.`state_value` when 'wait_commit_order' then `slog`.`admin_id` end)) AS `TgetorderPerson`,max((case `slog`.`state_value` when 'wait_commit_order' then `slog`.`createtime` end)) AS `Tgetorder`,max((case `plog`.`state_value` when 'wait_receive_order' then '1' else '0' end)) AS `TmaterialOver`,max((case `plog`.`state_value` when 'wait_receive_order' then `plog`.`admin_id` end)) AS `TmaterialPerson`,max((case `plog`.`state_value` when 'wait_receive_order' then `plog`.`createtime` end)) AS `Tmaterial`,max((case `plog`.`state_value` when 'wait_pick_cargo' then '1' else '0' end)) AS `TpurchaseOver`,max((case `plog`.`state_value` when 'wait_pick_cargo' then `plog`.`admin_id` else NULL end)) AS `TpurchasePerson`,max((case `plog`.`state_value` when 'wait_pick_cargo' then `plog`.`createtime` else NULL end)) AS `Tpurchase`,max((case `slog`.`state_value` when 'wait_pay' then '1' else '0' end)) AS `TpayOver`,max((case `slog`.`state_value` when 'wait_pay' then `slog`.`admin_id` else NULL end)) AS `TpayPerson`,max((case `slog`.`state_value` when 'wait_pay' then `slog`.`createtime` else NULL end)) AS `Tpay`,max((case `slog`.`state_value` when 'finish' then '1' else '0' end)) AS `TchangeOver`,max((case `slog`.`state_value` when 'finish' then `slog`.`admin_id` end)) AS `TchangePerson`,max((case `slog`.`state_value` when 'finish' then `slog`.`createtime` end)) AS `Tchange`,NULL AS `TexpenseOver`,NULL AS `TexpensePerson`,NULL AS `Texpense`,NULL AS `TsortOver`,NULL AS `TsortPerson`,NULL AS `Tsort`,max((case `plog`.`state_value` when 'wait_return_fee' then '1' else '0' end)) AS `TallowOver`,max((case `plog`.`state_value` when 'wait_return_fee' then `plog`.`admin_id` end)) AS `TallowPerson`,max((case `plog`.`state_value` when 'wait_return_fee' then `plog`.`createtime` end)) AS `Tallow`,max((case `plog`.`state_value` when 'finish' then '1' else '0' end)) AS `TcheckOver`,max((case `plog`.`state_value` when 'finish' then `plog`.`admin_id` else NULL end)) AS `TcheckPerson`,max((case `plog`.`state_value` when 'finish' then `plog`.`createtime` else '0' end)) AS `Tcheck`,`p`.`state` AS `State` from (((`uctoo_lvhuan`.`uct_waste_sell` `s` join `uctoo_lvhuan`.`uct_waste_sell_log` `slog`) join `uctoo_lvhuan`.`uct_waste_purchase` `p`) join `uctoo_lvhuan`.`uct_waste_purchase_log` `plog`) where ((`s`.`id` = `slog`.`sell_id`) and (`s`.`order_id` = `p`.`order_id`) and (`p`.`id` = `plog`.`purchase_id`) and (`slog`.`is_timeline_data` = '1')) group by `p`.`order_id`;





DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_materiel`;
create view `uctoo_lvhuan`.`trans_materiel` as select `mel`.`FInterID` AS `FInterID`,`mel`.`FTranType` AS `FTranType`,`mel`.`FEntryID` AS `FEntryID`,`mel`.`FMaterielID` AS `FMaterielID`,`mel`.`FUseCount` AS `FUseCount`,round(`mel`.`FPrice`,2) AS `FPrice`,round((`mel`.`FUseCount` * `mel`.`FPrice`),2) AS `FMeterielAmount`,`mel`.`FMeterieltime` AS `FMeterieltime` from (select `uctoo_lvhuan`.`uct_waste_purchase_materiel`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`id` AS `FEntryID`,`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`materiel_id` AS `FMaterielID`,cast(`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`storage_amount` as signed) AS `FUseCount`,`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`inside_price` AS `FPrice`,`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`updatetime` AS `FMeterieltime` from `uctoo_lvhuan`.`uct_waste_purchase_materiel` where (`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`use_type` = 0) union all select `uctoo_lvhuan`.`uct_waste_purchase_materiel`.`purchase_id` AS `FInterID`,'SOR' AS `FTranType`,`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`id` AS `FEntryID`,`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`materiel_id` AS `FMaterielID`,(cast(`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`pick_amount` as signed) - cast(`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`storage_amount` as signed)) AS `FUseCount`,`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`inside_price` AS `FPrice`,`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`updatetime` AS `FMeterieltime` from `uctoo_lvhuan`.`uct_waste_purchase_materiel` where (`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`use_type` = 1) union all select `uctoo_lvhuan`.`uct_waste_sell_materiel`.`sell_id` AS `FInterID`,'SEL' AS `FTranType`,`uctoo_lvhuan`.`uct_waste_sell_materiel`.`id` AS `FEntryID`,`uctoo_lvhuan`.`uct_waste_sell_materiel`.`materiel_id` AS `FMaterielID`,`uctoo_lvhuan`.`uct_waste_sell_materiel`.`pick_amount` AS `FUseCount`,`uctoo_lvhuan`.`uct_waste_sell_materiel`.`unit_price` AS `FPrice`,`uctoo_lvhuan`.`uct_waste_sell_materiel`.`updatetime` AS `FMeterieltime` from `uctoo_lvhuan`.`uct_waste_sell_materiel`) `mel` group by `mel`.`FInterID`,`mel`.`FTranType`,`mel`.`FMaterielID`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_materiel_total`;
create view `uctoo_lvhuan`.`trans_materiel_total` as select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,sum((case `uctoo_lvhuan`.`uct_materiel`.`name` when '分类箱' then `uctoo_lvhuan`.`trans_materiel_table`.`FUseCount` else 0 end)) AS `FUseCount_flx`,sum((case `uctoo_lvhuan`.`uct_materiel`.`name` when '太空包' then `uctoo_lvhuan`.`trans_materiel_table`.`FUseCount` else 0 end)) AS `FUseCount_tkb`,sum((case `uctoo_lvhuan`.`uct_materiel`.`name` when '编织袋' then `uctoo_lvhuan`.`trans_materiel_table`.`FUseCount` else 0 end)) AS `FUseCount_bzd`,date_format(from_unixtime(`uctoo_lvhuan`.`trans_materiel_table`.`FMeterieltime`),'%Y-%m-%d') AS `FMeterieltime` from ((`uctoo_lvhuan`.`trans_materiel_table` join `uctoo_lvhuan`.`trans_main_table`) join `uctoo_lvhuan`.`uct_materiel`) where ((`uctoo_lvhuan`.`trans_materiel_table`.`FInterID` = `uctoo_lvhuan`.`trans_main_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_materiel_table`.`FMaterielID` = `uctoo_lvhuan`.`uct_materiel`.`id`)) group by `uctoo_lvhuan`.`trans_materiel_table`.`FInterID`;








DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_month_invforcargo`;
create view `uctoo_lvhuan`.`trans_month_invforcargo` as select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,(case `uctoo_lvhuan`.`uct_waste_cate`.`name` when '垃圾' then '1' else '0' end) AS `trash_is`,sum((case `uctoo_lvhuan`.`trans_assist_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else '0' end)) AS `input`,sum((case `uctoo_lvhuan`.`trans_assist_table`.`FTranType` when 'SEL' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else '0' end)) AS `output`,max(date_format(`uctoo_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d')) AS `FDCTime` from ((`uctoo_lvhuan`.`trans_assist_table` join `uctoo_lvhuan`.`trans_main_table`) join `uctoo_lvhuan`.`uct_waste_cate`) where ((`uctoo_lvhuan`.`trans_assist_table`.`FinterID` = `uctoo_lvhuan`.`trans_main_table`.`FInterID`) and (convert(`uctoo_lvhuan`.`trans_assist_table`.`FTranType` using utf8) = convert(`uctoo_lvhuan`.`trans_main_table`.`FTranType` using utf8)) and (`uctoo_lvhuan`.`trans_assist_table`.`FItemID` = `uctoo_lvhuan`.`uct_waste_cate`.`id`) and (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` = '0') and (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` <> 'PUR') and (`uctoo_lvhuan`.`trans_main_table`.`FStatus` = 1)) group by `uctoo_lvhuan`.`trans_assist_table`.`FItemID`,date_format(`uctoo_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d');









DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_month_invfordep`;
create view `uctoo_lvhuan`.`trans_month_invfordep` as select `minvfdep`.`FRelateBrID` AS `FRelateBrID`,`minvfdep`.`FDeptID` AS `FDeptID`,`minvfdep`.`trash_is` AS `trash_is`,`minvfdep`.`input` AS `input`,`minvfdep`.`output` AS `output`,`minvfdep`.`FDCTime` AS `FDCTime` from (select `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,`uctoo_lvhuan`.`trans_main_table`.`FDeptID` AS `FDeptID`,(case `uctoo_lvhuan`.`uct_waste_cate`.`name` when '垃圾' then '1' else '0' end) AS `trash_is`,round(sum((case `uctoo_lvhuan`.`trans_assist_table`.`FTranType` when 'SOR' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else '0' end)),1) AS `input`,round(sum((case `uctoo_lvhuan`.`trans_assist_table`.`FTranType` when 'SEL' then `uctoo_lvhuan`.`trans_assist_table`.`FQty` else '0' end)),1) AS `output`,max(date_format(`uctoo_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d')) AS `FDCTime` from ((`uctoo_lvhuan`.`trans_assist_table` join `uctoo_lvhuan`.`trans_main_table`) join `uctoo_lvhuan`.`uct_waste_cate`) where ((`uctoo_lvhuan`.`trans_assist_table`.`FinterID` = `uctoo_lvhuan`.`trans_main_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = `uctoo_lvhuan`.`trans_main_table`.`FTranType`) and (`uctoo_lvhuan`.`trans_assist_table`.`FItemID` = `uctoo_lvhuan`.`uct_waste_cate`.`id`) and (`uctoo_lvhuan`.`trans_main_table`.`FSaleStyle` <> '1') and (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` <> 'PUR') and (`uctoo_lvhuan`.`trans_main_table`.`FCorrent` = 1)) group by date_format(`uctoo_lvhuan`.`trans_assist_table`.`FDCTime`,'%Y-%m-%d'),`uctoo_lvhuan`.`trans_main_table`.`FDeptID`,`uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`,(case `uctoo_lvhuan`.`uct_waste_cate`.`name` when '垃圾' then '1' else '0' end)) `minvfdep` where ((isnull(`minvfdep`.`FDCTime`) = 0) and (not(`minvfdep`.`FDCTime` in (select `uctoo_lvhuan`.`trans_month_invfordep_table`.`FDCTime` from `uctoo_lvhuan`.`trans_month_invfordep_table`))));



DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_purchase_cargo`;
create view `uctoo_lvhuan`.`trans_purchase_cargo` as select `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `purchase_id`,`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`cate_id` AS `cate_id`,`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`net_weight` AS `sum(net_weight)`,`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`unit_price` AS `unit_price` from `uctoo_lvhuan`.`uct_waste_purchase_cargo` group by `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`,`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`unit_price`;





DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_cargo_pc`;
create view `uctoo_lvhuan`.`trans_total_cargo_pc` as select `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `FInterID`,'PUR' AS `FTranType`,sum(`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`net_weight`) AS `FQtyTotal`,round(sum(`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`total_price`),2) AS `FAmountTotal`,'' AS `FSourceInterId`,'' AS `FSourceTranType` from `uctoo_lvhuan`.`uct_waste_purchase_cargo` group by `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_cargo_sc`;
create view `uctoo_lvhuan`.`trans_total_cargo_sc` as select `uctoo_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `FInterID`,'SOR' AS `FTranType`,sum(`uctoo_lvhuan`.`uct_waste_storage_sort`.`net_weight`) AS `FQtyTotal`,round(sum((`uctoo_lvhuan`.`uct_waste_storage_sort`.`net_weight` * `uctoo_lvhuan`.`uct_waste_storage_sort`.`presell_price`)),2) AS `FAmountTotal`,`uctoo_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `FSourceInterId`,'PUR' AS `FSourceTranType` from `uctoo_lvhuan`.`uct_waste_storage_sort` group by `uctoo_lvhuan`.`uct_waste_storage_sort`.`purchase_id`;






DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_fee_osf`;
create view `uctoo_lvhuan`.`trans_total_fee_osf` as select `uctoo_lvhuan`.`uct_waste_sell_other_price`.`sell_id` AS `sell_id`,sum((case `uctoo_lvhuan`.`uct_waste_sell_other_price`.`type` when 'in' then `uctoo_lvhuan`.`uct_waste_sell_other_price`.`price` else 0 end)) AS `sell_profit`,sum((case `uctoo_lvhuan`.`uct_waste_sell_other_price`.`type` when 'out' then `uctoo_lvhuan`.`uct_waste_sell_other_price`.`price` else 0 end)) AS `sell_fee` from `uctoo_lvhuan`.`uct_waste_sell_other_price` group by `uctoo_lvhuan`.`uct_waste_sell_other_price`.`sell_id`;





DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_fee_pf`;
create view `uctoo_lvhuan`.`trans_total_fee_pf` as select `uctoo_lvhuan`.`uct_waste_purchase_expense`.`purchase_id` AS `purchase_id`,sum((case `uctoo_lvhuan`.`uct_waste_purchase_expense`.`usage` when '供应商垃圾补助费' then `uctoo_lvhuan`.`uct_waste_purchase_expense`.`price` when '供应商车辆补助费' then `uctoo_lvhuan`.`uct_waste_purchase_expense`.`price` when '供应商人工补助费' then `uctoo_lvhuan`.`uct_waste_purchase_expense`.`price` else 0 end)) AS `customer_profit`,sum((case `uctoo_lvhuan`.`uct_waste_purchase_expense`.`usage` when '其他收入' then `uctoo_lvhuan`.`uct_waste_purchase_expense`.`price` else 0 end)) AS `other_profit`,sum((case `uctoo_lvhuan`.`uct_waste_purchase_expense`.`type` when 'out' then `uctoo_lvhuan`.`uct_waste_purchase_expense`.`price` else 0 end)) AS `pick_fee` from `uctoo_lvhuan`.`uct_waste_purchase_expense` group by `uctoo_lvhuan`.`uct_waste_purchase_expense`.`purchase_id`;








DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_fee_rf`;
create view `uctoo_lvhuan`.`trans_total_fee_rf` as select `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`purchase_id` AS `purchase_id`,sum((case `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`usage` when '外请车费' then `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`price` when '公司车费' then `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`price` else 0 end)) AS `car_fee`,sum((case `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`usage` when '拉货专员人工' then `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`price` when '外请人工' then `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`price` when '拉货助理人工' then `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`price` else 0 end)) AS `man_fee`,sum((case `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`usage` when '外请车费' then 0 when '公司车费' then 0 when '拉货专员人工' then 0 when '外请人工' then 0 when '拉货助理人工' then 0 else `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`price` end)) AS `other_return_fee` from `uctoo_lvhuan`.`uct_waste_storage_return_fee` group by `uctoo_lvhuan`.`uct_waste_storage_return_fee`.`purchase_id`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_fee_sf`;
create view `uctoo_lvhuan`.`trans_total_fee_sf` as select `uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` AS `purchase_id`,sum((case `uctoo_lvhuan`.`uct_waste_sell_other_price`.`type` when 'in' then `uctoo_lvhuan`.`uct_waste_sell_other_price`.`price` else 0 end)) AS `sell_profit`,sum((case `uctoo_lvhuan`.`uct_waste_sell_other_price`.`type` when 'out' then `uctoo_lvhuan`.`uct_waste_sell_other_price`.`price` else 0 end)) AS `sell_fee` from ((`uctoo_lvhuan`.`uct_waste_sell_other_price` join `uctoo_lvhuan`.`uct_waste_sell`) join `uctoo_lvhuan`.`uct_waste_purchase`) where ((`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` > 0) and (`uctoo_lvhuan`.`uct_waste_sell_other_price`.`sell_id` = `uctoo_lvhuan`.`uct_waste_sell`.`id`) and (`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` = `uctoo_lvhuan`.`uct_waste_purchase`.`id`)) group by `uctoo_lvhuan`.`uct_waste_sell`.`purchase_id`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_fee_sg`;
create view `uctoo_lvhuan`.`trans_total_fee_sg` as select `sfr`.`purchase_id` AS `purchase_id`,sum((case `sfr`.`usage` when '资源池分拣人工' then `sfr`.`price` when '临时工分拣人工' then `sfr`.`price` when '拉货人分拣人工' then `sfr`.`price` else 0 end)) AS `sort_fee`,sum((case `sfr`.`usage` when '耗材费-太空包' then `sfr`.`price` when '耗材费-编织袋' then `sfr`.`price` else 0 end)) AS `materiel_fee`,sum((case `sfr`.`usage` when '资源池分拣人工' then 0 when '临时工分拣人工' then 0 when '耗材费-太空包' then 0 when '耗材费-编织袋' then 0 when '拉货人分拣人工' then 0 else `sfr`.`price` end)) AS `other_sort_fee` from ((select `uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`purchase_id` AS `purchase_id`,`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`usage` AS `usage`,`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`price` AS `price` from `uctoo_lvhuan`.`uct_waste_storage_sort_expense`) union all (select `uctoo_lvhuan`.`uct_waste_storage_expense`.`purchase_id` AS `purchase_id`,`uctoo_lvhuan`.`uct_waste_storage_expense`.`usage` AS `usage`,`uctoo_lvhuan`.`uct_waste_storage_expense`.`price` AS `price` from `uctoo_lvhuan`.`uct_waste_storage_expense`) union all (select `mtr`.`purchase_id` AS `purchase_id`,'耗材费-太空包' AS `usage`,sum(`mtr`.`materiel_price`) AS `price` from (select `uctoo_lvhuan`.`uct_waste_purchase_materiel`.`purchase_id` AS `purchase_id`,((case `uctoo_lvhuan`.`uct_waste_purchase_materiel`.`use_type` when '1' then cast(`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`pick_amount` as signed) when '0' then cast(`uctoo_lvhuan`.`uct_waste_purchase_materiel`.`storage_amount` as signed) else 0 end) * `uctoo_lvhuan`.`uct_waste_purchase_materiel`.`inside_price`) AS `materiel_price` from `uctoo_lvhuan`.`uct_waste_purchase_materiel`) `mtr` group by `mtr`.`purchase_id`)) `sfr` group by `sfr`.`purchase_id`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_cargo_collect`;
create view `uctoo_lvhuan`.`view_cargo_collect` as select if((`p`.`FTranType` = 'SEL'),`p`.`FSourceInterId`,`p`.`FinterID`) AS `FInterID`,`p`.`FItemID` AS `FItemID`,ifnull(group_concat((case `p`.`FTranType` when 'PUR' then concat('采购净重 ',`p`.`FQty`,', ','采购价 ',ifnull(round(`p`.`FPrice`,2),0.00)) else NULL end) separator ','),'') AS `PUR_log`,round(sum(if((`p`.`FTranType` = 'PUR'),`p`.`FQty`,0)),1) AS `PUR_FQty`,round(sum(if((`p`.`FTranType` = 'PUR'),`p`.`FAmount`,0)),2) AS `PUR_FAmount`,ifnull(group_concat((case `p`.`FTranType` when 'SOR' then concat('入库净重 ',`p`.`FQty`,', ','预售价 ',ifnull(round(`p`.`FPrice`,2),0.00)) when 'SEL' then concat('销售重量 ',`p`.`FQty`,', ','销售价 ',ifnull(round(`p`.`FPrice`,2),0.00)) else NULL end) separator ','),'') AS `SOR_log`,round(sum(if((`p`.`FTranType` = 'PUR'),0,`p`.`FQty`)),1) AS `SOR_FQty`,ifnull(round(sum(if((`p`.`FTranType` = 'PUR'),0,`p`.`FAmount`)),2),0.00) AS `SOR_FAmount`,date_format(max(if((`p`.`FTranType` = 'PUR'),NULL,`p`.`FDCTime`)),'%Y-%m-%d') AS `FDCTime` from `uctoo_lvhuan`.`trans_assist_table` `p` where (if((`p`.`FTranType` = 'SEL'),(`p`.`FSourceInterId` <> ''),TRUE) and (`p`.`FItemID` <> 0)) group by if((`p`.`FTranType` = 'SEL'),`p`.`FSourceInterId`,`p`.`FinterID`),`p`.`FItemID`;







DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_cargofile_first`;
create view `uctoo_lvhuan`.`view_cargofile_first` as select `uctoo_lvhuan`.`uct_waste_cate`.`id` AS `id`,`uctoo_lvhuan`.`uct_waste_cate`.`name` AS `name` from `uctoo_lvhuan`.`uct_waste_cate` where (`uctoo_lvhuan`.`uct_waste_cate`.`parent_id` = 0);





DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_cargofile_second`;
create view `uctoo_lvhuan`.`view_cargofile_second` as select `view_change_sort`.`id` AS `id`,`view_change_sort`.`parent_id` AS `parent_id`,`view_change_sort`.`name` AS `name` from (select `uctoo_lvhuan`.`uct_waste_cate`.`id` AS `id`,`uctoo_lvhuan`.`uct_waste_cate`.`parent_id` AS `parent_id`,`uctoo_lvhuan`.`uct_waste_cate`.`name` AS `name` from `uctoo_lvhuan`.`uct_waste_cate` where (`uctoo_lvhuan`.`uct_waste_cate`.`parent_id` <> 0)) `view_change_sort` where exists(select `view_cargofile_first`.`id` from `uctoo_lvhuan`.`view_cargofile_first` where (`view_cargofile_first`.`id` = `view_change_sort`.`parent_id`));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_cargofile_third`;
create view `uctoo_lvhuan`.`view_cargofile_third` as select `view_change_sort`.`id` AS `id`,`view_change_sort`.`parent_id` AS `parent_id`,`view_change_sort`.`name` AS `name`,`view_change_sort`.`branch_id` AS `branch_id` from (select `uctoo_lvhuan`.`uct_waste_cate`.`id` AS `id`,`uctoo_lvhuan`.`uct_waste_cate`.`parent_id` AS `parent_id`,`uctoo_lvhuan`.`uct_waste_cate`.`name` AS `name`,`uctoo_lvhuan`.`uct_waste_cate`.`branch_id` AS `branch_id` from `uctoo_lvhuan`.`uct_waste_cate` where (`uctoo_lvhuan`.`uct_waste_cate`.`parent_id` <> 0)) `view_change_sort` where (not(exists(select `view_cargofile_first`.`id` from `uctoo_lvhuan`.`view_cargofile_first` where (`view_cargofile_first`.`id` = `view_change_sort`.`parent_id`))));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_customer`;
create view `uctoo_lvhuan`.`view_customer` as select `uctoo_lvhuan`.`uct_admin`.`nickname` AS `第一负责人`,`uctoo_lvhuan`.`uct_admin`.`mobile` AS `第一负责人电话`,`bb`.`分部归属` AS `分部归属`,`bb`.`公司名称` AS `公司名称`,`bb`.`业务员` AS `业务员`,`bb`.`部门归属` AS `部门归属` from (((select substring_index(`uctoo_lvhuan`.`uct_waste_customer`.`admin_id`,',',-(1)) AS `admin_id1`,(case `uctoo_lvhuan`.`uct_waste_customer`.`branch_id` when 1 then '深圳宝安分部' when 2 then '成都崇州分部' when 3 then '昆山张浦分部' when 4 then '厦门翔安分部' when 5 then '东莞黄江分部' when 8 then '东莞横沥分部' when 9 then '东莞大岭山分部' when 10 then '东莞凤岗分部' else '' end) AS `分部归属`,`uctoo_lvhuan`.`uct_waste_customer`.`name` AS `公司名称`,`uctoo_lvhuan`.`uct_admin`.`nickname` AS `业务员`,(case `uctoo_lvhuan`.`uct_waste_customer`.`service_department` when '1' then '客服部' when '2' then '企服部' end) AS `部门归属` from (`uctoo_lvhuan`.`uct_waste_customer` join `uctoo_lvhuan`.`uct_admin`) where ((`uctoo_lvhuan`.`uct_waste_customer`.`customer_type` = 'up') and (`uctoo_lvhuan`.`uct_waste_customer`.`manager_id` = `uctoo_lvhuan`.`uct_admin`.`id`) and (`uctoo_lvhuan`.`uct_waste_customer`.`state` = 'enabled')))) `bb` join `uctoo_lvhuan`.`uct_admin`) where (`bb`.`admin_id1` = `uctoo_lvhuan`.`uct_admin`.`id`);






DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_excel_customer`;
create view `uctoo_lvhuan`.`view_excel_customer` as select `uctoo_lvhuan`.`uct_admin`.`id` AS `id`,`uctoo_lvhuan`.`uct_admin`.`nickname` AS `nickname` from `uctoo_lvhuan`.`uct_admin` where (`uctoo_lvhuan`.`uct_admin`.`id` > 1826);









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_excel_sell`;
create view `uctoo_lvhuan`.`view_excel_sell` as select `uctoo_lvhuan`.`uct_waste_sell`.`id` AS `id`,`uctoo_lvhuan`.`uct_waste_sell`.`branch_id` AS `branch_id`,`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` AS `purchase_id`,`uctoo_lvhuan`.`uct_waste_sell`.`order_id` AS `order_id`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_id` AS `customer_id`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `customer_linkman_id`,`uctoo_lvhuan`.`uct_waste_sell`.`seller_id` AS `seller_id`,`uctoo_lvhuan`.`uct_waste_sell`.`seller_remark` AS `seller_remark`,`uctoo_lvhuan`.`uct_waste_sell`.`warehouse_id` AS `warehouse_id`,`uctoo_lvhuan`.`uct_waste_sell`.`cargo_pick_time` AS `cargo_pick_time`,`uctoo_lvhuan`.`uct_waste_sell`.`car_number` AS `car_number`,`uctoo_lvhuan`.`uct_waste_sell`.`car_weight` AS `car_weight`,`uctoo_lvhuan`.`uct_waste_sell`.`cargo_price` AS `cargo_price`,`uctoo_lvhuan`.`uct_waste_sell`.`materiel_price` AS `materiel_price`,`uctoo_lvhuan`.`uct_waste_sell`.`other_price` AS `other_price`,`uctoo_lvhuan`.`uct_waste_sell`.`cargo_out_remark` AS `cargo_out_remark`,`uctoo_lvhuan`.`uct_waste_sell`.`pay_way_id` AS `pay_way_id`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_evaluate_data` AS `customer_evaluate_data`,`uctoo_lvhuan`.`uct_waste_sell`.`seller_evaluate_data` AS `seller_evaluate_data`,`uctoo_lvhuan`.`uct_waste_sell`.`state` AS `state`,`uctoo_lvhuan`.`uct_waste_sell`.`createtime` AS `createtime`,`uctoo_lvhuan`.`uct_waste_sell`.`updatetime` AS `updatetime` from `uctoo_lvhuan`.`uct_waste_sell` where (`uctoo_lvhuan`.`uct_waste_sell`.`createtime` > 1541030400);








DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_repair_getid`;
create view `uctoo_lvhuan`.`view_repair_getid` as select `uctoo_lvhuan`.`table_repair`.`order_code` AS `order_id`,`uctoo_lvhuan`.`uct_waste_purchase`.`id` AS `id` from (`uctoo_lvhuan`.`table_repair` join `uctoo_lvhuan`.`uct_waste_purchase`) where ((right(`uctoo_lvhuan`.`table_repair`.`order_code`,6) = right(`uctoo_lvhuan`.`uct_waste_purchase`.`order_id`,6)) and (`uctoo_lvhuan`.`uct_waste_purchase`.`order_id` >= '201907000000000000'));







DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_shenguan_check`;
create view `uctoo_lvhuan`.`view_shenguan_check` as select `uctoo_lvhuan`.`uct_waste_purchase_log`.`purchase_id` AS `purchase_id`,date_format(from_unixtime(`uctoo_lvhuan`.`uct_waste_purchase_log`.`createtime`),'%Y-%m-%d') AS `check_time`,`uctoo_lvhuan`.`uct_admin`.`nickname` AS `nickname` from (`uctoo_lvhuan`.`uct_waste_purchase_log` join `uctoo_lvhuan`.`uct_admin`) where ((`uctoo_lvhuan`.`uct_waste_purchase_log`.`state_value` = 'finish') and (`uctoo_lvhuan`.`uct_admin`.`id` = `uctoo_lvhuan`.`uct_waste_purchase_log`.`admin_id`) and (`uctoo_lvhuan`.`uct_waste_purchase_log`.`createtime` >= '1542902400'));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_shenguan_presell`;
create view `uctoo_lvhuan`.`view_shenguan_presell` as select `uctoo_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `purchase_id`,round(sum((`uctoo_lvhuan`.`uct_waste_storage_sort`.`net_weight` * `uctoo_lvhuan`.`uct_waste_storage_sort`.`presell_price`)),2) AS `total_presell` from `uctoo_lvhuan`.`uct_waste_storage_sort` group by `uctoo_lvhuan`.`uct_waste_storage_sort`.`purchase_id`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_sort_expense`;
create view `uctoo_lvhuan`.`view_sort_expense` as select `uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`purchase_id` AS `purchase_id`,sum(if((`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`usage` = '资源池分拣人工'),`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`price`,0)) AS `sort_expense`,sum(if((`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`usage` like '耗材费%'),`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`price`,0)) AS `materal_expense`,sum(`uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`price`) AS `total_expense` from `uctoo_lvhuan`.`uct_waste_storage_sort_expense` group by `uctoo_lvhuan`.`uct_waste_storage_sort_expense`.`purchase_id`;






DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_test`;
create view `uctoo_lvhuan`.`view_test` as select `uctoo_lvhuan`.`trans_month_sor_table`.`FRelateBrID` AS `FRelateBrID`,concat('#',`uctoo_lvhuan`.`uct_waste_purchase`.`order_id`) AS `order_id`,`uctoo_lvhuan`.`trans_month_sor_table`.`FDate` AS `FDate`,`uctoo_lvhuan`.`trans_month_sor_table`.`FSupplyID` AS `FSupplyID`,`uctoo_lvhuan`.`trans_month_sor_table`.`Fbusiness` AS `Fbusiness`,`uctoo_lvhuan`.`trans_month_sor_table`.`FDeptID` AS `FDeptID`,`uctoo_lvhuan`.`trans_month_sor_table`.`FEmpID` AS `FEmpID`,`uctoo_lvhuan`.`trans_month_sor_table`.`FPOStyle` AS `FPOStyle`,`uctoo_lvhuan`.`trans_month_sor_table`.`FPOPrecent` AS `FPOPrecent`,`uctoo_lvhuan`.`trans_month_sor_table`.`profit` AS `profit`,`uctoo_lvhuan`.`trans_month_sor_table`.`weight` AS `weight`,`uctoo_lvhuan`.`trans_month_sor_table`.`transport_pay` AS `transport_pay`,`uctoo_lvhuan`.`trans_month_sor_table`.`classify_pay` AS `classify_pay`,`uctoo_lvhuan`.`trans_month_sor_table`.`material_pay` AS `material_pay`,`uctoo_lvhuan`.`trans_month_sor_table`.`total_pay` AS `total_pay` from (`uctoo_lvhuan`.`trans_month_sor_table` join `uctoo_lvhuan`.`uct_waste_purchase`) where (`uctoo_lvhuan`.`trans_month_sor_table`.`FInterID` = `uctoo_lvhuan`.`uct_waste_purchase`.`id`);







DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_test_2`;
create view `uctoo_lvhuan`.`view_test_2` as select date_format(`main`.`FDate`,'%m-%d') AS `date`,`cus`.`name` AS `cus`,'' AS `item`,'' AS `weight`,'' AS `price`,'' AS `amount`,'' AS `bag`,sum((case `fee`.`FFeeID` when '叉车费' then `fee`.`FFeeAmount` else '0' end)) AS `forklife`,sum((case `fee`.`FFeeID` when '磅费' then `fee`.`FFeeAmount` else '0' end)) AS `metage` from ((`uctoo_lvhuan`.`trans_main_table` `main` join `uctoo_lvhuan`.`uct_waste_customer` `cus`) join `uctoo_lvhuan`.`trans_fee_table` `fee`) where ((`main`.`FSaleStyle` = 2) and (`main`.`FTranType` = 'SEL') and (`main`.`FRelateBrID` = 18) and (`main`.`FDate` >= '2020-08-01 00:00:00') and (`main`.`FDate` <= '2020-11-01 00:00:00') and (`main`.`FCorrent` = 1) and (`main`.`FCancellation` = 1) and (`main`.`FSupplyID` = `cus`.`id`) and (`main`.`FInterID` = `fee`.`FInterID`) and (`main`.`FTranType` = `fee`.`FTranType`)) group by `main`.`FBillNo`;









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_test_3`;
create view `uctoo_lvhuan`.`view_test_3` as select `cate`.`name` AS `FItemID`,`ass`.`FUnitID` AS `FUnitID`,`ass`.`FQty` AS `FQty`,`ass`.`FPrice` AS `FPrice`,`ass`.`FAmount` AS `FAmount`,`ass`.`revise_state` AS `revise_state` from ((`uctoo_lvhuan`.`trans_main_table` `main` join `uctoo_lvhuan`.`trans_assist_table` `ass`) join `uctoo_lvhuan`.`uct_waste_cate` `cate`) where ((`main`.`FInterID` = `ass`.`FinterID`) and (`main`.`FTranType` = `ass`.`FTranType`) and (`main`.`FBillNo` = '202006271710424769') and (`cate`.`id` = `ass`.`FItemID`));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_test_4`;
create view `uctoo_lvhuan`.`view_test_4` as select round(sum(`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`net_weight`),1) AS `sum(net_weight)`,round(sum((`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`net_weight` * `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`unit_price`)),3) AS `sum(net_weight*unit_price)` from `uctoo_lvhuan`.`uct_waste_purchase_cargo` where (`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` = 22264);









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_valid_purchase`;
create view `uctoo_lvhuan`.`view_valid_purchase` as select `m`.`FRelateBrID` AS `FRelateBrID`,`m`.`FInterID` AS `FInterID`,date_format(`m`.`FDate`,'%Y-%m-%d') AS `FDate`,`m`.`FBillNo` AS `FBillNo`,`m`.`FSupplyID` AS `FSupplyID`,`m`.`Fbusiness` AS `Fbusiness`,`m`.`FEmpID` AS `FEmpID`,`m`.`FSaleStyle` AS `FSaleStyle`,`m`.`FCancellation` AS `FCancellation` from (`uctoo_lvhuan`.`trans_main_table` `m` join (select `m1`.`FBillNo` AS `FBillNo` from `uctoo_lvhuan`.`trans_main_table` `m1` where ((`m1`.`FCorrent` = 1) and (`m1`.`FTranType` = 'SOR')) union all select `m2`.`FBillNo` AS `FBillNo` from `uctoo_lvhuan`.`trans_main_table` `m2` where ((`m2`.`FStatus` = 1) and (`m2`.`FTranType` = 'SEL') and (`m2`.`FSaleStyle` = 1))) `s`) where ((`m`.`FTranType` = 'PUR') and (`m`.`FBillNo` = `s`.`FBillNo`));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_valid_sell`;
create view `uctoo_lvhuan`.`view_valid_sell` as select `uctoo_lvhuan`.`uct_waste_sell_log`.`sell_id` AS `sell_id` from `uctoo_lvhuan`.`uct_waste_sell_log` where ((`uctoo_lvhuan`.`uct_waste_sell_log`.`state_value` = 'wait_confirm_order') and (`uctoo_lvhuan`.`uct_waste_sell_log`.`state_text` = '待付款'));









DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_warehouse_collect`;
create view `uctoo_lvhuan`.`view_warehouse_collect` as select `uctoo_lvhuan`.`uct_waste_warehouse`.`id` AS `id`,`uctoo_lvhuan`.`uct_waste_warehouse`.`name` AS `name` from `uctoo_lvhuan`.`uct_waste_warehouse` where (`uctoo_lvhuan`.`uct_waste_warehouse`.`parent_id` = 0);




DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_stock`;
CREATE OR REPLACE VIEW `uctoo_lvhuan`.`accoding_stock` AS
SELECT
    stoc.FRelateBrID AS FRelateBrID,
    stoc.FStockID AS FStockID,
    stoc.FItemID AS FItemID,
    stoc.name AS name,
    CASE
        WHEN COALESCE(EXTRACT(EPOCH FROM stodif.FdifTime), 0) > EXTRACT(EPOCH FROM NOW()) THEN
            (((COALESCE(stodif.FdifQty, 0) - COALESCE(SUM(stoiod.FDCQty), 0)) + COALESCE(SUM(stoiod.FSCQty), 0)) + COALESCE(SUM(stoiod.FdifQty), 0))
        ELSE
            ((COALESCE(stodif.FdifQty, 0) + COALESCE(SUM(stoiod.FDCQty), 0)) - COALESCE(SUM(stoiod.FSCQty), 0))
    END AS FQty,
    COALESCE(EXTRACT(EPOCH FROM stodif.FdifTime), 0) AS Fdiftime
FROM
    uctoo_lvhuan.accoding_stock_cate stoc
LEFT JOIN
    uctoo_lvhuan.accoding_stock_dif stodif ON (stoc.FStockID = stodif.FStockID AND stoc.FItemID = stodif.FItemID)
LEFT JOIN
    uctoo_lvhuan.accoding_stock_iod stoiod ON (
        CONVERT(stoc.FStockID USING utf8) = stoiod.FStockID
        AND stoc.FItemID = stoiod.FItemID
        AND (
            (COALESCE(EXTRACT(EPOCH FROM stodif.FdifTime), 0) > EXTRACT(EPOCH FROM NOW()) AND EXTRACT(EPOCH FROM stoiod.FDCTime) BETWEEN (EXTRACT(EPOCH FROM NOW()) + 1) AND COALESCE(EXTRACT(EPOCH FROM stodif.FdifTime), 0))
            OR (EXTRACT(EPOCH FROM stoiod.FDCTime) BETWEEN COALESCE((EXTRACT(EPOCH FROM stodif.FdifTime) + 1), 0) AND EXTRACT(EPOCH FROM NOW()))
        )
    )
GROUP BY
    stoc.FStockID, stoc.FItemID, stoc.FRelateBrID;







DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_10`;
CREATE  VIEW `uctoo_lvhuan`.`test_10` AS
SELECT 
    "change_info"."订单分部归属" AS "订单分部归属",
    "change_info"."订单号" AS "订单号",
    "change_info"."申请人" AS "申请人",
    "change_info"."修改单据" AS "修改单据",
    "change_info"."记录类型" AS "记录类型",
    "change_info"."修改类型" AS "修改类型",
    "change_info"."关联" AS "关联",
    "change_info"."数量" AS "数量",
    "change_info"."单价" AS "单价",
    "change_info"."金额" AS "金额",
    "change_info"."申请时间" AS "申请时间",
    "change_info"."通过时间" AS "通过时间"
FROM (
    -- First Union Query
    SELECT 
        bra.name AS "订单分部归属",
        concat('#', main.FBillNo) AS "订单号",
        ad.nickname AS "申请人",
        CASE main.FTranType
            WHEN 'PUR' THEN '采购单'
            WHEN 'SOR' THEN '入库单'
            WHEN 'SEL' THEN '销售单'
        END AS "修改单据",
        CASE 
            WHEN ass.FEntryID = '0' THEN '新增记录'
            ELSE '修改后记录'
        END AS "记录类型",
        '货品' AS "修改类型",
        ca.name AS "关联",
        round(ass.FQty, 1) AS "数量",
        round(ass.FPrice, 3) AS "单价",
        round(ass.FAmount, 2) AS "金额",
        order_au.createtime AS "申请时间",
        order_au.updatetime AS "通过时间"
    FROM 
        uctoo_lvhuan.uct_modify_order_audit order_au
        JOIN uctoo_lvhuan.trans_main_table main ON main.FInterID = order_au.order_id AND main.FTranType = upper(substr(order_au.field_list, 3, 3))
        JOIN uctoo_lvhuan.uct_admin ad ON order_au.admin_id = ad.id
        JOIN uctoo_lvhuan.trans_assist_table ass ON ass.FInterID = main.FInterID AND ass.FTranType = main.FTranType AND ass.revise_state >= 1
        JOIN uctoo_lvhuan.uct_waste_cate ca ON ca.id = ass.FItemID
        JOIN uctoo_lvhuan.uct_branch bra ON bra.setting_key = main.FRelateBrID

    UNION ALL

    -- Second Union Query
    SELECT 
        bra.name AS "订单分部归属",
        concat('#', main.FBillNo) AS "订单号",
        ad.nickname AS "申请人",
        CASE main.FTranType
            WHEN 'PUR' THEN '采购单'
            WHEN 'SOR' THEN '入库单'
            WHEN 'SEL' THEN '销售单'
        END AS "修改单据",
        CASE 
            WHEN fee.FEntryID = '0' THEN '新增记录'
            ELSE '修改后记录'
        END AS "记录类型",
        fee.FFeeID AS "修改类型",
        COALESCE(fee.FFeePerson, '') AS "关联",
        NULL AS "数量",
        NULL AS "单价",
        round(fee.FFeeAmount, 2) AS "金额",
        order_au.createtime AS "申请时间",
        order_au.updatetime AS "通过时间"
    FROM 
        uctoo_lvhuan.uct_modify_order_audit order_au
        JOIN uctoo_lvhuan.trans_main_table main ON main.FInterID = order_au.order_id AND main.FTranType = upper(substr(order_au.field_list, 3, 3))
        JOIN uctoo_lvhuan.uct_admin ad ON order_au.admin_id = ad.id
        JOIN uctoo_lvhuan.trans_fee_table fee ON fee.FInterID = main.FInterID AND fee.FTranType = main.FTranType AND fee.revise_state >= 1
        JOIN uctoo_lvhuan.uct_branch bra ON bra.setting_key = main.FRelateBrID

    UNION ALL

    -- Third Union Query
    SELECT 
        bra.name AS "订单分部归属",
        concat('#', main.FBillNo) AS "订单号",
        ad.nickname AS "申请人",
        CASE main.FTranType
            WHEN 'PUR' THEN '采购单'
            WHEN 'SOR' THEN '入库单'
            WHEN 'SEL' THEN '销售单'
        END AS "修改单据",
        CASE 
            WHEN mat_org.FEntryID = '0' THEN '新增记录'
            ELSE '修改后记录'
        END AS "记录类型",
        '辅材' AS "修改类型",
        ma.name AS "关联",
        round(mat_org.FUseCount, 0) AS "数量",
        round(mat_org.FPrice, 3) AS "单价",
        round(mat_org.FMeterielAmount, 2) AS "金额",
        order_au.createtime AS "申请时间",
        order_au.updatetime AS "通过时间"
    FROM 
        uctoo_lvhuan.uct_modify_order_audit order_au
        JOIN uctoo_lvhuan.trans_main_table main ON main.FInterID = order_au.order_id AND main.FTranType = upper(substr(order_au.field_list, 3, 3))
        JOIN uctoo_lvhuan.uct_admin ad ON order_au.admin_id = ad.id
        JOIN uctoo_lvhuan.uct_branch bra ON bra.setting_key = main.FRelateBrID
        JOIN uctoo_lvhuan.trans_materiel_table mat_org ON mat_org.FInterID = main.FInterID AND convert(mat_org.FTranType USING utf8) = main.FTranType
        JOIN uctoo_lvhuan.uct_materiel ma ON mat_org.FMaterielID = ma.id

        -- Here, we should not have a direct JOIN to mat table.
        -- The FInterID and FTranType are already part of mat_org.
        
        WHERE mat_org.revise_state >= 1 
          AND NOT EXISTS (
            SELECT 1 
            FROM uctoo_lvhuan.trans_materiel_table mat 
            WHERE mat_org.FInterID = mat.FInterID 
              AND convert(mat_org.FTranType USING utf8) = mat.FTranType 
              AND mat.revise_state = 0 
              AND mat.FEntryID > '0'
          )
) AS "change_info" 
ORDER BY "change_info"."订单号", "change_info"."通过时间";







DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_17`;
CREATE VIEW `uctoo_lvhuan`.`test_17` AS
SELECT
    `main`.`Date` AS `Date`,
    `cus`.`name` AS `cusName`,
    CONCAT(E'\'', main.FBillNo, E'\'') AS FBillNo,
    `cate`.`name` AS `cateName`,
    `ass`.`FQty` AS `FQty`,
    `ass`.`FPrice` AS `FPrice`,
    `ass`.`FAmount` AS `FAmount`,
    '' AS `Amount`,
    `ad`.`nickname` AS `nickname`
FROM
    (
        (
            (
                (
                    `uctoo_lvhuan`.`trans_main_table` `main`
                    JOIN `uctoo_lvhuan`.`trans_assist_table` `ass`
                )
                JOIN `uctoo_lvhuan`.`uct_waste_customer` `cus`
            )
            JOIN `uctoo_lvhuan`.`uct_waste_cate` `cate`
        )
        JOIN `uctoo_lvhuan`.`uct_admin` `ad`
    )
WHERE
    (
        (`main`.`FInterID` = `ass`.`FinterID`)
        AND (`main`.`FTranType` = `ass`.`FTranType`)
        AND (`main`.`FTranType` = 'PUR')
        AND (`main`.`FSupplyID` = `cus`.`id`)
        AND (`cus`.`name` = '广东盈兴智能科技有限公司')
        AND (`ass`.`FItemID` = `cate`.`id`)
        AND (`main`.`FEmpID` = `ad`.`id`)
        AND (`main`.`FCancellation` = 1)
        AND (`ass`.`is_hedge` = 0)
    )
UNION ALL
SELECT
    `main`.`Date` AS `Date`,
    `cus`.`name` AS `cusName`,
    CONCAT(E'\'', main.FBillNo, E'\'') AS FBillNo,
    `fee`.`FFeeID` AS `cateName`,
    '' AS `FQty`,
    '' AS `FPrice`,
    -(`fee`.`FFeeAmount`) AS `FAmount`,
    '' AS `Amount`,
    `ad`.`nickname` AS `nickname`
FROM
    (
        (
            `uctoo_lvhuan`.`trans_main_table` `main`
            JOIN `uctoo_lvhuan`.`trans_fee_table` `fee`
        )
        JOIN `uctoo_lvhuan`.`uct_waste_customer` `cus`
    )
    JOIN `uctoo_lvhuan`.`uct_admin` `ad`
WHERE
    (
        (`main`.`FInterID` = `fee`.`FInterID`)
        AND (`main`.`FTranType` = `fee`.`FTranType`)
        AND (`main`.`FTranType` = 'PUR')
        AND (`fee`.`Ffeesence` = 'PC')
        AND (`main`.`FSupplyID` = `cus`.`id`)
        AND (`cus`.`name` = '广东盈兴智能科技有限公司')
        AND (`main`.`FEmpID` = `ad`.`id`)
        AND (`main`.`FCancellation` = 1)
        AND (`fee`.`is_hedge` = 0)
    );






DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_4`;
CREATE VIEW `uctoo_lvhuan`.`test_4` AS
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
    `item`.`extend_service` AS `extend_service`,
    `item`.`propose` AS `propose`
FROM
    (
        (
            `uctoo_lvhuan`.`uct_customer_question_item` `item`
            JOIN `uctoo_lvhuan`.`uct_customer_question` `cus`
            ON (`item`.`question_id` = `cus`.`id`)
        )
        JOIN `uctoo_lvhuan`.`uct_customer_question_grade` `gra`
        ON (`gra`.`question_id` = `cus`.`id`)
    )
WHERE
    (
        (`cus`.`branch_id` <> 7)
        AND (`cus`.`branch_id` <> 0)
    )
GROUP BY
    `cus`.`phone`;





DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_daily_sel`;
CREATE VIEW `uctoo_lvhuan`.`trans_daily_sel` AS
SELECT
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
    GROUP_CONCAT(DISTINCT `uctoo_lvhuan`.`trans_assist_table`.`FItemID` SEPARATOR ',') AS `FItemID`,
    ROUND(SUM(`uctoo_lvhuan`.`trans_assist_table`.`FQty`), 1) AS `total_weight`,
    ROUND(SUM(`uctoo_lvhuan`.`trans_assist_table`.`FAmount`), 2) AS `total_price`,
    COUNT(DISTINCT `uctoo_lvhuan`.`trans_assist_table`.`FinterID`) AS `count_order`,
    DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') AS `FDate`
FROM
    (`uctoo_lvhuan`.`trans_main_table`
    JOIN `uctoo_lvhuan`.`trans_assist_table`)
WHERE
    ((`uctoo_lvhuan`.`trans_main_table`.`FTranType` = 'SEL')
    AND (`uctoo_lvhuan`.`trans_main_table`.`FInterID` = `uctoo_lvhuan`.`trans_assist_table`.`FinterID`)
    AND (DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') > 0)
    AND (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = 'SEL')
    AND (DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') = CURDATE())
    AND (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1))
GROUP BY
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`,
    DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d');





DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_assist`;
CREATE VIEW `uctoo_lvhuan`.`trans_assist` AS 
SELECT 
    uctoo_lvhuan.uct_waste_purchase_cargo.purchase_id AS FInterID,
    'PUR' AS FTranType,
    uctoo_lvhuan.uct_waste_purchase_cargo.id AS FEntryID,
    uctoo_lvhuan.uct_waste_purchase_cargo.cate_id AS FItemID,
    '1' AS FUnitID,
    uctoo_lvhuan.uct_waste_purchase_cargo.net_weight AS FQty,
    uctoo_lvhuan.uct_waste_purchase_cargo.unit_price AS FPrice,
    ROUND(uctoo_lvhuan.uct_waste_purchase_cargo.total_price, 2) AS FAmount,
    '' AS disposal_way,
    uctoo_lvhuan.uct_waste_cate.value_type AS value_type,
    '' AS FbasePrice,
    '' AS FbaseAmount,
    '' AS Ftaxrate,
    '' AS Fbasetax,
    '' AS Fbasetaxamount,
    '' AS FPriceRef,
    TO_CHAR(TO_TIMESTAMP(uctoo_lvhuan.uct_waste_purchase_cargo.createtime), 'YYYY-MM-DD HH24:MI:SS') AS FDCTime,
    NULL AS FSourceInterID,
    NULL AS FSourceTranType
FROM 
    uctoo_lvhuan.uct_waste_purchase_cargo 
JOIN 
    uctoo_lvhuan.uct_waste_cate 
ON 
    uctoo_lvhuan.uct_waste_purchase_cargo.cate_id = uctoo_lvhuan.uct_waste_cate.id

UNION ALL

SELECT 
    uctoo_lvhuan.uct_waste_storage_sort.purchase_id AS FInterID,
    'SOR' AS FTranType,
    uctoo_lvhuan.uct_waste_storage_sort.id AS FEntryID,
    uctoo_lvhuan.uct_waste_storage_sort.cargo_sort AS FItemID,
    '1' AS FUnitID,
    uctoo_lvhuan.uct_waste_storage_sort.net_weight AS FQty,
    uctoo_lvhuan.uct_waste_storage_sort.presell_price AS FPrice,
    ROUND((uctoo_lvhuan.uct_waste_storage_sort.presell_price * uctoo_lvhuan.uct_waste_storage_sort.net_weight), 2) AS FAmount,
    uctoo_lvhuan.uct_waste_storage_sort.disposal_way AS disposal_way,
    uctoo_lvhuan.uct_waste_storage_sort.value_type AS value_type,
    '' AS FbasePrice,
    '' AS FbaseAmount,
    '' AS Ftaxrate,
    '' AS Fbasetax,
    '' AS Fbasetaxamount,
    '' AS FPriceRef,
    TO_CHAR(
        CASE WHEN uctoo_lvhuan.uct_waste_storage_sort.sort_time > uctoo_lvhuan.uct_waste_storage_sort.createtime
        THEN TO_TIMESTAMP(uctoo_lvhuan.uct_waste_storage_sort.sort_time)
        ELSE TO_TIMESTAMP(uctoo_lvhuan.uct_waste_storage_sort.createtime)
        END, 'YYYY-MM-DD HH24:MI:SS'
    ) AS FDCTime,
    uctoo_lvhuan.uct_waste_storage_sort.purchase_id AS FSourceInterID,
    'PUR' AS FSourceTranType
FROM 
    uctoo_lvhuan.uct_waste_storage_sort

UNION ALL

SELECT 
    uctoo_lvhuan.uct_waste_sell_cargo.sell_id AS FInterID,
    'SEL' AS FTranType,
    uctoo_lvhuan.uct_waste_sell_cargo.id AS FEntryID,
    uctoo_lvhuan.uct_waste_sell_cargo.cate_id AS FItemID,
    '1' AS FUnitID,
    uctoo_lvhuan.uct_waste_sell_cargo.net_weight AS FQty,
    uctoo_lvhuan.uct_waste_sell_cargo.unit_price AS FPrice,
    ROUND((uctoo_lvhuan.uct_waste_sell_cargo.unit_price * uctoo_lvhuan.uct_waste_sell_cargo.net_weight), 2) AS FAmount,
    '' AS disposal_way,
    uctoo_lvhuan.uct_waste_cate.value_type AS value_type,
    '' AS FbasePrice,
    '' AS FbaseAmount,
    '' AS Ftaxrate,
    '' AS Fbasetax,
    '' AS Fbasetaxamount,
    '' AS FPriceRef,
    TO_CHAR(TO_TIMESTAMP(uctoo_lvhuan.uct_waste_sell_cargo.createtime), 'YYYY-MM-DD HH24:MI:SS') AS FDCTime,
    CASE WHEN uctoo_lvhuan.uct_waste_sell.purchase_id > 0
    THEN CAST(uctoo_lvhuan.uct_waste_sell.purchase_id AS VARCHAR)
    ELSE NULL
    END AS FSourceInterID,
    CASE WHEN uctoo_lvhuan.uct_waste_sell.purchase_id > 0
    THEN 'PUR'
    ELSE NULL
    END AS FSourceTranType
FROM 
    uctoo_lvhuan.uct_waste_sell_cargo
JOIN 
    uctoo_lvhuan.uct_waste_sell
ON 
    uctoo_lvhuan.uct_waste_sell_cargo.sell_id = uctoo_lvhuan.uct_waste_sell.id
JOIN 
    uctoo_lvhuan.uct_waste_cate
ON 
    uctoo_lvhuan.uct_waste_cate.id = uctoo_lvhuan.uct_waste_sell_cargo.cate_id;




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_daily_wh_profit`;
CREATE VIEW `uctoo_lvhuan`.`trans_daily_wh_profit` AS
SELECT
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
    `uctoo_lvhuan`.`trans_fee_table`.`FFeeID` AS `FFeeID`,
    `uctoo_lvhuan`.`trans_fee_table`.`FFeeType` AS `FFeeType`,
    `uctoo_lvhuan`.`trans_fee_table`.`FFeePerson` AS `FFeePerson`,
    SUM(`uctoo_lvhuan`.`trans_fee_table`.`FFeeAmount`) AS `FFeeAmount`,
    `uctoo_lvhuan`.`trans_fee_table`.`FFeebaseAmount` AS `FFeebaseAmount`,
    `uctoo_lvhuan`.`trans_fee_table`.`Ftaxrate` AS `Ftaxrate`,
    `uctoo_lvhuan`.`trans_fee_table`.`Fbasetax` AS `Fbasetax`,
    `uctoo_lvhuan`.`trans_fee_table`.`Fbasetaxamount` AS `Fbasetaxamount`,
    `uctoo_lvhuan`.`trans_fee_table`.`FPriceRef` AS `FPriceRef`,
    DATE_FORMAT(`uctoo_lvhuan`.`trans_fee_table`.`FFeetime`, '%Y-%m-%d') AS `FFeetime`
FROM
    (`uctoo_lvhuan`.`trans_fee_table`
    JOIN `uctoo_lvhuan`.`trans_main_table`)
WHERE
    ((`uctoo_lvhuan`.`trans_fee_table`.`FFeeID` = '资源池分拣人工')
    AND (`uctoo_lvhuan`.`trans_main_table`.`FTranType` = 'SOR')
    AND (`uctoo_lvhuan`.`trans_fee_table`.`FInterID` = `uctoo_lvhuan`.`trans_main_table`.`FInterID`)
    AND (DATE_FORMAT(`uctoo_lvhuan`.`trans_fee_table`.`FFeetime`, '%Y-%m-%d') = CURDATE())
    AND (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1))
GROUP BY
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`,
    `uctoo_lvhuan`.`trans_fee_table`.`FFeePerson`,
    DATE_FORMAT(`uctoo_lvhuan`.`trans_fee_table`.`FFeetime`, '%Y-%m-%d');





DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_daily_sor`;
CREATE VIEW `uctoo_lvhuan`.`trans_daily_sor` AS
SELECT
    "dsor"."FRelateBrID" AS "FRelateBrID",
    "dsor"."FInterID" AS "FInterID",
    "dsor"."FDate" AS "FDate",
    "dsor"."FSupplyID" AS "FSupplyID",
    "dsor"."Fbusiness" AS "Fbusiness",
    "dsor"."FDeptID" AS "FDeptID",
    "dsor"."FEmpID" AS "FEmpID",
    "dsor"."FPOStyle" AS "FPOStyle",
    "dsor"."FPOPrecent" AS "FPOPrecent",
    "dsor"."profit" AS "profit",
    "dsor"."weight" AS "weight",
    "dsor"."transport_pay" AS "transport_pay",
    "dsor"."classify_fee" AS "classify_fee",
    "dsor"."material_pay" AS "material_pay",
    "dsor"."total_pay" AS "total_pay"
FROM
    (
        SELECT
            "uctoo_lvhuan"."trans_main_table"."FRelateBrID" AS "FRelateBrID",
            MAX(
                CASE
                    WHEN "uctoo_lvhuan"."trans_main_table"."FTranType" = 'PUR' THEN "uctoo_lvhuan"."trans_main_table"."FInterID"
                    ELSE 0
                END
            ) AS "FInterID",
            MAX(
                CASE
                    WHEN "uctoo_lvhuan"."trans_main_table"."FTranType" = 'SOR' THEN "uctoo_lvhuan"."trans_main_table"."FDate"
                    WHEN "uctoo_lvhuan"."trans_main_table"."FTranType" = 'SEL' THEN "uctoo_lvhuan"."trans_main_table"."FDate"
                    ELSE NULL
                END
            ) AS "FDate",
            MAX(
                CASE
                    WHEN "uctoo_lvhuan"."trans_main_table"."FTranType" = 'PUR' THEN "uctoo_lvhuan"."trans_main_table"."FSupplyID"
                    ELSE 0
                END
            ) AS "FSupplyID",
            "uctoo_lvhuan"."trans_main_table"."Fbusiness" AS "Fbusiness",
            "uctoo_lvhuan"."trans_main_table"."FDeptID" AS "FDeptID",
            "uctoo_lvhuan"."trans_main_table"."FEmpID" AS "FEmpID",
            "uctoo_lvhuan"."trans_main_table"."FPOStyle" AS "FPOStyle",
            "uctoo_lvhuan"."trans_main_table"."FPOPrecent" AS "FPOPrecent",
            ROUND(
                (
                    (
                        (
                            (
                                (
                                    (
                                        (
                                            (
                                                (
                                                    (
                                                        SUM(
                                                            CASE
                                                                CONCAT("uctoo_lvhuan"."trans_main_table"."FTranType", "uctoo_lvhuan"."trans_main_table"."FSaleStyle")
                                                                WHEN 'SOR0' THEN "uctoo_lvhuan"."trans_main_table"."TalFAmount"
                                                                WHEN 'SEL1' THEN "uctoo_lvhuan"."trans_main_table"."TalFAmount"
                                                                ELSE 0
                                                            END
                                                        ) - SUM(
                                                            CASE
                                                                "uctoo_lvhuan"."trans_main_table"."FTranType"
                                                                WHEN 'PUR' THEN "uctoo_lvhuan"."trans_main_table"."TalFAmount"
                                                                ELSE 0
                                                            END
                                                        )
                                                    ) - SUM(
                                                        CASE
                                                            "uctoo_lvhuan"."trans_main_table"."FTranType"
                                                            WHEN 'PUR' THEN "uctoo_lvhuan"."trans_main_table"."TalSecond"
                                                            ELSE 0
                                                        END
                                                    )
                                                ) - SUM(
                                                    CASE
                                                        "uctoo_lvhuan"."trans_main_table"."FTranType"
                                                        WHEN 'PUR' THEN "uctoo_lvhuan"."trans_main_table"."TalThird"
                                                        ELSE 0
                                                    END
                                                )
                                            ) - SUM(
                                                CASE
                                                    CONCAT("uctoo_lvhuan"."trans_main_table"."FTranType", "uctoo_lvhuan"."trans_main_table"."FSaleStyle")
                                                    WHEN 'SOR0' THEN "uctoo_lvhuan"."trans_main_table"."TalFrist"
                                                    ELSE 0
                                                END
                                            )
                                        ) - SUM(
                                            CASE
                                                CONCAT("uctoo_lvhuan"."trans_main_table"."FTranType", "uctoo_lvhuan"."trans_main_table"."FSaleStyle")
                                                WHEN 'SOR0' THEN "uctoo_lvhuan"."trans_main_table"."TalSecond"
                                                ELSE 0
                                            END
                                        )
                                    ) - SUM(
                                        CASE
                                            "uctoo_lvhuan"."trans_main_table"."FTranType"
                                            WHEN 'PUR' THEN "uctoo_lvhuan"."trans_main_table"."TalForth"
                                            ELSE 0
                                        END
                                    )
                                ) - SUM(
                                    CASE
                                        CONCAT("uctoo_lvhuan"."trans_main_table"."FTranType", "uctoo_lvhuan"."trans_main_table"."FSaleStyle")
                                        WHEN 'SOR0' THEN "uctoo_lvhuan"."trans_main_table"."TalThird"
                                        ELSE 0
                                    END
                                )
                            ) + SUM(
                                CASE
                                    CONCAT("uctoo_lvhuan"."trans_main_table"."FTranType", "uctoo_lvhuan"."trans_main_table"."FSaleStyle")
                                    WHEN 'SEL1' THEN "uctoo_lvhuan"."trans_main_table"."TalFrist"
                                    ELSE 0
                                END
                            )
                        ) + SUM(
                            CASE
                                CONCAT("uctoo_lvhuan"."trans_main_table"."FTranType", "uctoo_lvhuan"."trans_main_table"."FSaleStyle")
                                WHEN 'SEL1' THEN "uctoo_lvhuan"."trans_main_table"."TalSecond"
                                ELSE 0
                            END
                        )
                    ) + SUM(
                        CASE
                            "uctoo_lvhuan"."trans_main_table"."FTranType"
                            WHEN 'PUR' THEN "uctoo_lvhuan"."trans_main_table"."TalFrist"
                            ELSE 0
                        END
                    )
                ),
                3
            ) AS "profit",
            SUM(
                CASE
                    CONCAT("uctoo_lvhuan"."trans_main_table"."FTranType", "uctoo_lvhuan"."trans_main_table"."FSaleStyle")
                    WHEN 'SOR0' THEN "uctoo_lvhuan"."trans_main_table"."TalFQty"
                    WHEN 'SEL1' THEN "uctoo_lvhuan"."trans_main_table"."TalFQty"
                    ELSE 0
                END
            ) AS "weight",
            ROUND(
                SUM(
                    CASE
                        "uctoo_lvhuan"."trans_main_table"."FTranType"
                        WHEN 'PUR' THEN "uctoo_lvhuan"."trans_main_table"."TalSecond"
                        ELSE 0
                    END
                ),
                3
            ) AS "transport_pay",
            ROUND(
                SUM(
                    CASE
                        CONCAT("uctoo_lvhuan"."trans_main_table"."FTranType", "uctoo_lvhuan"."trans_main_table"."FSaleStyle")
                        WHEN 'SOR0' THEN "uctoo_lvhuan"."trans_main_table"."TalFrist"
                        ELSE 0
                    END
                ),
                3
            ) AS "classify_fee",
            ROUND(
                SUM(
                    CASE
                        CONCAT("uctoo_lvhuan"."trans_main_table"."FTranType", "uctoo_lvhuan"."trans_main_table"."FSaleStyle")
                        WHEN 'SOR0' THEN "uctoo_lvhuan"."trans_main_table"."TalSecond"
                        ELSE 0
                    END
                ),
                3
            ) AS "material_pay",
            SUM(
                CASE
                    "uctoo_lvhuan"."trans_main_table"."FTranType"
                    WHEN 'PUR' THEN (("uctoo_lvhuan"."trans_main_table"."TalSecond" + "uctoo_lvhuan"."trans_main_table"."TalThird") + "uctoo_lvhuan"."trans_main_table"."TalForth")
                    WHEN 'SOR' THEN (("uctoo_lvhuan"."trans_main_table"."TalFrist" + "uctoo_lvhuan"."trans_main_table"."TalSecond") + "uctoo_lvhuan"."trans_main_table"."TalThird")
                    WHEN 'SEL' THEN "uctoo_lvhuan"."trans_main_table"."TalSecond"
                    ELSE 0
                END
            ) AS "total_pay"
        FROM
            "uctoo_lvhuan"."trans_main_table"
        WHERE
            ("uctoo_lvhuan"."trans_main_table"."FSaleStyle" <> '2')
            AND ("uctoo_lvhuan"."trans_main_table"."FCorrent" = 1)
            AND ("uctoo_lvhuan"."trans_main_table"."FCancellation" = 1)
        GROUP BY
            "uctoo_lvhuan"."trans_main_table"."FRelateBrID",
            "uctoo_lvhuan"."trans_main_table"."FBillNo"
    ) "dsor"
WHERE
    (DATE_FORMAT("dsor"."FDate", '%Y%m%d') = CURRENT_DATE);




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_finishcount`;
CREATE VIEW `uctoo_lvhuan`.`trans_finishcount` AS
SELECT
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
    `uctoo_lvhuan`.`trans_main_table`.`FDeptID` AS `FDeptID`,
    `uctoo_lvhuan`.`trans_main_table`.`FEmpID` AS `FEmpID`,
    (SUM(`uctoo_lvhuan`.`trans_main_table`.`FCancellation`) - SUM(`uctoo_lvhuan`.`trans_main_table`.`FCorrent`)) AS `Unfinished`
FROM
    `uctoo_lvhuan`.`trans_main_table`
WHERE
    (
        DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') >= DATE_FORMAT('2019-01-01', '%Y-%m-%d')
        AND `uctoo_lvhuan`.`trans_main_table`.`FTranType` = 'PUR'
    )
GROUP BY
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`,
    `uctoo_lvhuan`.`trans_main_table`.`FDeptID`,
    `uctoo_lvhuan`.`trans_main_table`.`FEmpID`

UNION ALL

SELECT
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
    '3' AS `FDeptID`,
    '-' AS `FEmpID`,
    (SUM(`uctoo_lvhuan`.`trans_main_table`.`FCancellation`) - SUM(`uctoo_lvhuan`.`trans_main_table`.`FUpStockWhenSave`)) AS `Unfinished`
FROM
    `uctoo_lvhuan`.`trans_main_table`
WHERE
    (
        `uctoo_lvhuan`.`trans_main_table`.`FTranType` = 'SOR'
        AND `uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1
    )
GROUP BY
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`;





DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_main`;
CREATE VIEW `uctoo_lvhuan`.`trans_main` AS select `uctoo_lvhuan`.`uct_waste_purchase`.`branch_id` AS `FRelateBrID`,`uctoo_lvhuan`.`uct_waste_purchase`.`id` AS `FInterID`,'PUR' AS `FTranType`,(case `uctoo_lvhuan`.`trans_log_table`.`TpurchaseOver` when '0' then date_format(from_unixtime(1),'%Y-%m-%d %H:%i:%S') else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tpurchase`),'%Y-%m-%d %H:%i:%S') end) AS `FDate`,(case `uctoo_lvhuan`.`trans_log_table`.`TpurchaseOver` when '0' then date_format(from_unixtime(1),'%Y-%m-%d') else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tpurchase`),'%Y-%m-%d') end) AS `Date`,`uctoo_lvhuan`.`uct_waste_purchase`.`train_number` AS `FTrainNum`,`uctoo_lvhuan`.`uct_waste_purchase`.`order_id` AS `FBillNo`,`uctoo_lvhuan`.`uct_waste_purchase`.`customer_id` AS `FSupplyID`,`uctoo_lvhuan`.`uct_waste_purchase`.`manager_id`::text AS `Fbusiness`,concat('AD',`uctoo_lvhuan`.`uct_waste_purchase`.`purchase_incharge`) AS `FDCStockID`,concat('CU',`uctoo_lvhuan`.`uct_waste_purchase`.`customer_id`) AS `FSCStockID`,(case `uctoo_lvhuan`.`uct_waste_purchase`.`state` when 'cancel' then '0' else '1' end) AS `FCancellation`,'0' AS `FROB`,`uctoo_lvhuan`.`trans_log_table`.`TallowOver` AS `FCorrent`,`uctoo_lvhuan`.`trans_log_table`.`TcheckOver` AS `FStatus`,'' AS `FUpStockWhenSave`,'' AS `FExplanation`,`uctoo_lvhuan`.`uct_waste_customer`.`service_department` AS `FDeptID`,`uctoo_lvhuan`.`uct_waste_purchase`.`purchase_incharge` AS `FEmpID`,`uctoo_lvhuan`.`trans_log_table`.`TcheckPerson` AS `FCheckerID`,(case `uctoo_lvhuan`.`trans_log_table`.`TcheckOver` when '0' then 'null' else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tcheck`),'%Y-%m-%d %H:%i:%S') end) AS `FCheckDate`,`uctoo_lvhuan`.`uct_waste_purchase`.`purchase_incharge` AS `FFManagerID`,`uctoo_lvhuan`.`uct_waste_purchase`.`purchase_incharge` AS `FSManagerID`,`uctoo_lvhuan`.`uct_waste_purchase`.`purchase_incharge` AS `FBillerID`,'1' AS `FCurrencyID`,`uctoo_lvhuan`.`trans_log_table`.`state` AS `FNowState`,((case `uctoo_lvhuan`.`uct_waste_purchase`.`hand_mouth_data` when '1' then '1' else '0' end) + (case `uctoo_lvhuan`.`uct_waste_purchase`.`give_frame` when '1' then '3' else 0 end)) AS `FSaleStyle`,`uctoo_lvhuan`.`uct_waste_customer`.`settle_way`::text AS `FPOStyle`,`uctoo_lvhuan`.`uct_waste_customer`.`back_percent`::text AS `FPOPrecent`,round(`uctoo_lvhuan`.`uct_waste_purchase`.`cargo_weight`,1) AS `TalFQty`,round(`uctoo_lvhuan`.`uct_waste_purchase`.`cargo_price`,2) AS `TalFAmount`,`uctoo_lvhuan`.`uct_waste_purchase`.`purchase_expense` AS `TalFeeFrist`,`trans_total_fee_rf`.`car_fee` AS `TalFeeSecond`,`trans_total_fee_rf`.`man_fee` AS `TalFeeThird`,`trans_total_fee_rf`.`other_return_fee` AS `TalFeeForth`,0 AS `TalFeeFifth` from (((`uctoo_lvhuan`.`uct_waste_purchase` join `uctoo_lvhuan`.`uct_waste_customer`) join `uctoo_lvhuan`.`trans_log_table`) left join `uctoo_lvhuan`.`trans_total_fee_rf` on((`trans_total_fee_rf`.`purchase_id` = `uctoo_lvhuan`.`uct_waste_purchase`.`id`))) where ((`uctoo_lvhuan`.`uct_waste_purchase`.`customer_id` = `uctoo_lvhuan`.`uct_waste_customer`.`id`) and (`uctoo_lvhuan`.`uct_waste_purchase`.`id` = `uctoo_lvhuan`.`trans_log_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_log_table`.`FTranType` = 'PUR') and (`uctoo_lvhuan`.`uct_waste_purchase`.`order_id` > 201806300000000000)) union all select `uctoo_lvhuan`.`uct_waste_sell`.`branch_id` AS `FRelateBrID`,`uctoo_lvhuan`.`uct_waste_sell`.`id` AS `FInterID`,'SEL' AS `FTranType`,(case `uctoo_lvhuan`.`trans_log_table`.`TallowOver` when '0' then date_format(from_unixtime(1),'%Y-%m-%d %H:%i:%S') else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tallow`),'%Y-%m-%d %H:%i:%S') end) AS `FDate`,(case `uctoo_lvhuan`.`trans_log_table`.`TallowOver` when '0' then date_format(from_unixtime(1),'%Y-%m-%d') else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tallow`),'%Y-%m-%d') end) AS `Date`,`uctoo_lvhuan`.`uct_waste_purchase`.`train_number` AS `FTrainNum`,`uctoo_lvhuan`.`uct_waste_sell`.`order_id` AS `FBillNo`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_id` AS `FSupplyID`,'' AS `Fbusiness`,concat('DC',`uctoo_lvhuan`.`uct_waste_sell`.`customer_id`) AS `FDCStockID`,if(((`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` is not null) = 0),concat('LH',`uctoo_lvhuan`.`uct_waste_sell`.`warehouse_id`),concat('AD',`uctoo_lvhuan`.`uct_waste_purchase`.`purchase_incharge`)) AS `FSCStockID`,(case `uctoo_lvhuan`.`uct_waste_sell`.`state` when 'cancel' then '0' else '1' end) AS `FCancellation`,'0' AS `FROB`,`uctoo_lvhuan`.`trans_log_table`.`TallowOver` AS `FCorrent`,`uctoo_lvhuan`.`trans_log_table`.`TcheckOver` AS `FStatus`,'0' AS `FUpStockWhenSave`,'' AS `FExplanation`,'4' AS `FDeptID`,`uctoo_lvhuan`.`uct_waste_sell`.`seller_id` AS `FEmpID`,`uctoo_lvhuan`.`trans_log_table`.`TcheckPerson` AS `FCheckerID`,(case `uctoo_lvhuan`.`trans_log_table`.`TcheckOver` when '0' then 'null' else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tcheck`),'%Y-%m-%d %H:%i:%S') end) AS `FCheckDate`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `FFManagerID`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `FSManagerID`,`uctoo_lvhuan`.`uct_waste_sell`.`seller_id` AS `FBillerID`,'1' AS `FCurrencyID`,`uctoo_lvhuan`.`trans_log_table`.`state` AS `FNowState`,if(((`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` is not null) = 1),'1','2') AS `FSaleStyle`,'' AS `FPOStyle`,'' AS `FPOPrecent`,round(`uctoo_lvhuan`.`uct_waste_sell`.`cargo_weight`,1) AS `TalFQty`,round(`uctoo_lvhuan`.`uct_waste_sell`.`cargo_price`,2) AS `TalFAmount`,`uctoo_lvhuan`.`uct_waste_sell`.`materiel_price` AS `TalFeeFrist`,`uctoo_lvhuan`.`uct_waste_sell`.`other_price` AS `TalFeeSecond`,0 AS `TalFeeThird`,0 AS `TalFeeForth`,0 AS `TalFeeFifth` from (((`uctoo_lvhuan`.`uct_waste_sell` join `uctoo_lvhuan`.`uct_waste_customer`) join `uctoo_lvhuan`.`trans_log_table`) join `uctoo_lvhuan`.`uct_waste_purchase`) where ((`uctoo_lvhuan`.`uct_waste_sell`.`customer_id` = `uctoo_lvhuan`.`uct_waste_customer`.`id`) and (`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` = `uctoo_lvhuan`.`trans_log_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_log_table`.`FTranType` = 'PUR') and (`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` = `uctoo_lvhuan`.`uct_waste_purchase`.`id`) and (`uctoo_lvhuan`.`uct_waste_sell`.`order_id` > 201806300000000000)) union all select `uctoo_lvhuan`.`uct_waste_sell`.`branch_id` AS `FRelateBrID`,`uctoo_lvhuan`.`uct_waste_sell`.`id` AS `FInterID`,'SEL' AS `FTranType`,(case `uctoo_lvhuan`.`trans_log_table`.`TallowOver` when '0' then date_format(from_unixtime(1),'%Y-%m-%d %H:%i:%S') else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tallow`),'%Y-%m-%d %H:%i:%S') end) AS `FDate`,(case `uctoo_lvhuan`.`trans_log_table`.`TallowOver` when '0' then date_format(from_unixtime(1),'%Y-%m-%d') else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tallow`),'%Y-%m-%d') end) AS `Date`,'1' AS `FTrainNum`,`uctoo_lvhuan`.`uct_waste_sell`.`order_id` AS `FBillNo`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_id` AS `FSupplyID`,'' AS `Fbusiness`,concat('DC',`uctoo_lvhuan`.`uct_waste_sell`.`customer_id`) AS `FDCStockID`,if(((`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` is not null) = 0),concat('LH',`uctoo_lvhuan`.`uct_waste_sell`.`warehouse_id`),'') AS `FSCStockID`,(case `uctoo_lvhuan`.`uct_waste_sell`.`state` when 'cancel' then '0' else '1' end) AS `FCancellation`,'0' AS `FROB`,`uctoo_lvhuan`.`trans_log_table`.`TallowOver` AS `FCorrent`,`uctoo_lvhuan`.`trans_log_table`.`TcheckOver` AS `FStatus`,`uctoo_lvhuan`.`trans_log_table`.`TallowOver` AS `FUpStockWhenSave`,'' AS `FExplanation`,'4' AS `FDeptID`,`uctoo_lvhuan`.`uct_waste_sell`.`seller_id` AS `FEmpID`,`uctoo_lvhuan`.`trans_log_table`.`TcheckPerson` AS `FCheckerID`,(case `uctoo_lvhuan`.`trans_log_table`.`TcheckOver` when '0' then 'null' else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tcheck`),'%Y-%m-%d %H:%i:%S') end) AS `FCheckDate`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `FFManagerID`,`uctoo_lvhuan`.`uct_waste_sell`.`customer_linkman_id` AS `FSManagerID`,`uctoo_lvhuan`.`uct_waste_sell`.`seller_id` AS `FBillerID`,'1' AS `FCurrencyID`,`uctoo_lvhuan`.`trans_log_table`.`state` AS `FNowState`,if(((`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` is not null) = 1),'1','2') AS `FSaleStyle`,'' AS `FPOStyle`,'' AS `FPOPrecent`,round(`uctoo_lvhuan`.`uct_waste_sell`.`cargo_weight`,1) AS `TalFQty`,round(`uctoo_lvhuan`.`uct_waste_sell`.`cargo_price`,2) AS `TalFAmount`,`uctoo_lvhuan`.`uct_waste_sell`.`materiel_price` AS `TalFeeFrist`,`uctoo_lvhuan`.`uct_waste_sell`.`other_price` AS `TalFeeSecond`,0 AS `TalFeeThird`,0 AS `TalFeeForth`,0 AS `TalFeeFifth` from ((`uctoo_lvhuan`.`uct_waste_sell` join `uctoo_lvhuan`.`uct_waste_customer`) join `uctoo_lvhuan`.`trans_log_table`) where ((`uctoo_lvhuan`.`uct_waste_sell`.`customer_id` = `uctoo_lvhuan`.`uct_waste_customer`.`id`) and (`uctoo_lvhuan`.`uct_waste_sell`.`id` = `uctoo_lvhuan`.`trans_log_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_log_table`.`FTranType` = 'SEL') and ((`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id` is not null) = 0) and (`uctoo_lvhuan`.`uct_waste_sell`.`order_id` > 201806300000000000)) union all select `uctoo_lvhuan`.`uct_waste_purchase`.`branch_id` AS `FRelateBrID`,`uctoo_lvhuan`.`uct_waste_purchase`.`id` AS `FInterID`,'SOR' AS `FTranType`,(case `uctoo_lvhuan`.`trans_log_table`.`TallowOver` when '0' then date_format(from_unixtime(1),'%Y-%m-%d %H:%i:%S') else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tallow`),'%Y-%m-%d %H:%i:%S') end) AS `FDate`,(case `uctoo_lvhuan`.`trans_log_table`.`TallowOver` when '0' then date_format(from_unixtime(1),'%Y-%m-%d') else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tallow`),'%Y-%m-%d') end) AS `Date`,`uctoo_lvhuan`.`uct_waste_purchase`.`train_number` AS `FTrainNum`,`uctoo_lvhuan`.`uct_waste_purchase`.`order_id` AS `FBillNo`,`uctoo_lvhuan`.`uct_waste_purchase`.`customer_id` AS `FSupplyID`,`uctoo_lvhuan`.`uct_waste_purchase`.`manager_id` AS `Fbusiness`,concat('LH',`uctoo_lvhuan`.`uct_waste_warehouse`.`parent_id`) AS `FDCStockID`,concat('AD',`uctoo_lvhuan`.`uct_waste_purchase`.`purchase_incharge`) AS `FSCStockID`,(case `uctoo_lvhuan`.`uct_waste_purchase`.`state` when 'cancel' then '0' else '1' end) AS `FCancellation`,'0' AS `FROB`,`uctoo_lvhuan`.`trans_log_table`.`TallowOver` AS `FCorrent`,`uctoo_lvhuan`.`trans_log_table`.`TcheckOver` AS `FStatus`,`uctoo_lvhuan`.`trans_log_table`.`TsortOver` AS `FUpStockWhenSave`,'' AS `FExplanation`,`uctoo_lvhuan`.`uct_waste_customer`.`service_department` AS `FDeptID`,`uctoo_lvhuan`.`uct_waste_warehouse`.`admin_id` AS `FEmpID`,`uctoo_lvhuan`.`trans_log_table`.`TcheckPerson` AS `FCheckerID`,(case `uctoo_lvhuan`.`trans_log_table`.`TcheckOver` when '0' then 'null' else date_format(from_unixtime(`uctoo_lvhuan`.`trans_log_table`.`Tcheck`),'%Y-%m-%d %H:%i:%S') end) AS `FCheckDate`,`uctoo_lvhuan`.`uct_waste_purchase`.`purchase_incharge` AS `FFManagerID`,`uctoo_lvhuan`.`uct_waste_warehouse`.`admin_id` AS `FSManagerID`,`uctoo_lvhuan`.`uct_waste_warehouse`.`admin_id` AS `FBillerID`,'1' AS `FCurrencyID`,`uctoo_lvhuan`.`trans_log_table`.`state` AS `FNowState`,('0' + (case `uctoo_lvhuan`.`uct_waste_purchase`.`give_frame` when '1' then '3' else 0 end)) AS `FSaleStyle`,`uctoo_lvhuan`.`uct_waste_customer`.`settle_way` AS `FPOStyle`,`uctoo_lvhuan`.`uct_waste_customer`.`back_percent` AS `FPOPrecent`,round(`uctoo_lvhuan`.`uct_waste_purchase`.`storage_weight`,1) AS `TalFQty`,round(`uctoo_lvhuan`.`uct_waste_purchase`.`storage_cargo_price`,2) AS `TalFAmount`,`trans_total_fee_sg`.`sort_fee` AS `TalFeeFrist`,`trans_total_fee_sg`.`materiel_fee` AS `TalFeeSecond`,`trans_total_fee_sg`.`other_sort_fee` AS `TalFeeThird`,`uctoo_lvhuan`.`uct_waste_purchase`.`total_cargo_price` AS `TalFeeForth`,`uctoo_lvhuan`.`uct_waste_purchase`.`total_labor_price` AS `TalFeeFifth` from ((((`uctoo_lvhuan`.`uct_waste_purchase` join `uctoo_lvhuan`.`uct_waste_customer`) join `uctoo_lvhuan`.`trans_log_table`) join `uctoo_lvhuan`.`uct_waste_warehouse`) left join `uctoo_lvhuan`.`trans_total_fee_sg` on((`trans_total_fee_sg`.`purchase_id` = `uctoo_lvhuan`.`uct_waste_purchase`.`id`))) where ((`uctoo_lvhuan`.`uct_waste_purchase`.`customer_id` = `uctoo_lvhuan`.`uct_waste_customer`.`id`) and (`uctoo_lvhuan`.`uct_waste_purchase`.`id` = `uctoo_lvhuan`.`trans_log_table`.`FInterID`) and (`uctoo_lvhuan`.`trans_log_table`.`FTranType` = 'PUR') and (`uctoo_lvhuan`.`uct_waste_warehouse`.`id` = `uctoo_lvhuan`.`uct_waste_purchase`.`sort_point`) and (`uctoo_lvhuan`.`uct_waste_purchase`.`order_id` > 201806300000000000));



    
    
    
    

DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_month_customer`;
CREATE VIEW `uctoo_lvhuan`.`trans_month_customer` AS 
SELECT 
    trans_main.FRelateBrID AS FRelateBrID,
    trans_main.FSupplyID AS FSupplyID,
    trans_main.Fbusiness AS Fbusiness,
    trans_main.TalFQty AS total_weight,
    trans_main.TalFAmount AS total_profit,
    taltrash.trash_weight AS trash_weight,
    trans_main.FDate AS FDate
FROM 
    uctoo_lvhuan.trans_main
JOIN 
    (
        SELECT 
            uctoo_lvhuan.uct_waste_purchase_cargo.purchase_id AS FInterID,
            SUM(CASE uctoo_lvhuan.uct_waste_purchase_cargo.cargo_name 
                WHEN '垃圾' THEN uctoo_lvhuan.uct_waste_purchase_cargo.net_weight 
                ELSE 0 
            END) AS trash_weight
        FROM 
            uctoo_lvhuan.uct_waste_purchase_cargo
        GROUP BY 
            uctoo_lvhuan.uct_waste_purchase_cargo.purchase_id
    ) AS taltrash
ON 
    taltrash.FInterID = trans_main.FInterID
WHERE 
    trans_main.FTranType = 'PUR';





DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_month_sel`;    
CREATE VIEW `uctoo_lvhuan`.`trans_month_sel` AS
SELECT
    `monsel`.`FRelateBrID` AS `FRelateBrID`,
    `monsel`.`FItemID` AS `FItemID`,
    `monsel`.`total_weight` AS `total_weight`,
    `monsel`.`total_price` AS `total_price`,
    `monsel`.`count_order` AS `count_order`,
    `monsel`.`FDate` AS `FDate`
FROM
    (SELECT
        `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
        GROUP_CONCAT(DISTINCT `uctoo_lvhuan`.`trans_assist_table`.`FItemID` SEPARATOR ',') AS `FItemID`,
        ROUND(SUM(`uctoo_lvhuan`.`trans_assist_table`.`FQty`), 1) AS `total_weight`,
        ROUND(SUM(`uctoo_lvhuan`.`trans_assist_table`.`FAmount`), 2) AS `total_price`,
        COUNT(DISTINCT `uctoo_lvhuan`.`trans_assist_table`.`FinterID`) AS `count_order`,
        DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') AS `FDate`
    FROM
        (`uctoo_lvhuan`.`trans_main_table`
        JOIN `uctoo_lvhuan`.`trans_assist_table`)
    WHERE
        ((`uctoo_lvhuan`.`trans_main_table`.`FTranType` = 'SEL')
        AND (`uctoo_lvhuan`.`trans_main_table`.`FInterID` = `uctoo_lvhuan`.`trans_assist_table`.`FinterID`)
        AND (DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') > 0)
        AND (`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = 'SEL')
        AND (`uctoo_lvhuan`.`trans_main_table`.`FStatus` = 1)
        AND (`uctoo_lvhuan`.`trans_main_table`.`FCancellation` = 1))
    GROUP BY
        `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`,
        DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d')) `monsel`
WHERE
    (NOT (`monsel`.`FDate` IN (SELECT `uctoo_lvhuan`.`trans_month_sel_table`.`FDate` FROM `uctoo_lvhuan`.`trans_month_sel_table`)));







DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_month_sel_rank`;
CREATE VIEW `uctoo_lvhuan`.`trans_month_sel_rank` AS select `sel_rank`.`FRelateBrID` AS `FRelateBrID`,`sel_rank`.`FItemID` AS `FItemID`,`sel_rank`.`total_weight` AS `total_weight`,`sel_rank`.`total_price` AS `total_price`,`sel_rank`.`FDate` AS `FDate` from (select `trans_main`.`FRelateBrID` AS `FRelateBrID`,`trans_assist`.`FItemID` AS `FItemID`,round(sum(`trans_assist`.`FQty`),1) AS `total_weight`,round(sum(`trans_assist`.`FAmount`),2) AS `total_price`,date_format(`trans_main`.`FDate`,'%Y-%m-%d') AS `FDate` from (`uctoo_lvhuan`.`trans_main` join `uctoo_lvhuan`.`trans_assist`) where ((`trans_main`.`FTranType` = 'SEL') and (`trans_main`.`FInterID` = `trans_assist`.`FInterID`) and (date_format(`trans_main`.`FDate`,'%Y-%m-%d') > 0) and (`trans_assist`.`FTranType` = 'SEL') and (`trans_main`.`FStatus` = 1)) group by `trans_main`.`FRelateBrID`,date_format(`trans_main`.`FDate`,'%Y-%m-%d'),`trans_assist`.`FItemID`) `sel_rank` where (not(`sel_rank`.`FDate` in (select `uctoo_lvhuan`.`trans_month_sel_rank_table`.`FDate` from `uctoo_lvhuan`.`trans_month_sel_rank_table`)));




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_month_sor`;
CREATE VIEW `uctoo_lvhuan`.`trans_month_sor` AS
SELECT
    trans_main_table.FRelateBrID AS FRelateBrID,
    trans_main_table.FBillNo AS FInterID,
    trans_main_table.FDate AS FDate,
    trans_main_table.FSupplyID AS FSupplyID,
    trans_main_table.Fbusiness AS Fbusiness,
    trans_main_table.FDeptID AS FDeptID,
    trans_main_table.FEmpID AS FEmpID,
    trans_main_table.FPOStyle AS FPOStyle,
    trans_main_table.FPOPrecent AS FPOPrecent,
    ROUND(
        SUM(
            CASE 
                WHEN CONCAT(FTranType, FSaleStyle) IN ('SOR0', 'SEL1') THEN TalFAmount
                WHEN FTranType = 'PUR' THEN -TalFAmount
                ELSE 0
            END
        ) - SUM(
            CASE 
                WHEN FTranType = 'PUR' THEN TalSecond
                ELSE 0
            END
        ) - SUM(
            CASE 
                WHEN FTranType = 'PUR' THEN TalThird
                ELSE 0
            END
        ) - SUM(
            CASE 
                WHEN CONCAT(FTranType, FSaleStyle) = 'SOR0' THEN TalFrist
                ELSE 0
            END
        ) - SUM(
            CASE 
                WHEN CONCAT(FTranType, FSaleStyle) = 'SOR0' THEN TalSecond
                ELSE 0
            END
        ) - SUM(
            CASE 
                WHEN FTranType = 'PUR' THEN TalForth
                ELSE 0
            END
        ) - SUM(
            CASE 
                WHEN CONCAT(FTranType, FSaleStyle) = 'SOR0' THEN TalThird
                ELSE 0
            END
        ) + SUM(
            CASE 
                WHEN CONCAT(FTranType, FSaleStyle) = 'SEL1' THEN TalFrist
                ELSE 0
            END
        ) + SUM(
            CASE 
                WHEN CONCAT(FTranType, FSaleStyle) = 'SEL1' THEN TalSecond
                ELSE 0
            END
        ) - SUM(
            CASE 
                WHEN FTranType = 'PUR' THEN TalFrist
                ELSE 0
            END
        ), 
        3
    ) AS profit,
    SUM(
        CASE 
            WHEN CONCAT(FTranType, FSaleStyle) IN ('SOR0', 'SEL1') THEN TalFQty
            ELSE 0
        END
    ) AS total_weight,
    ROUND(
        SUM(
            CASE 
                WHEN FTranType = 'PUR' THEN (TalSecond + TalThird + TalForth)
                WHEN FTranType = 'SOR' THEN (TalFrist + TalSecond + TalThird)
                WHEN CONCAT(FTranType, FSaleStyle) = 'SEL1' THEN TalSecond
                ELSE 0
            END
        ) - SUM(
            CASE 
                WHEN CONCAT(FTranType, FSaleStyle) IN ('SOR0', 'SEL1') THEN TalFQty
                ELSE 0
            END
        ),
        3
    ) AS transport_pay,
    ROUND(
        SUM(
            CASE 
                WHEN CONCAT(FTranType, FSaleStyle) IN ('SOR0', 'SEL1') THEN TalFrist
                ELSE 0
            END
        ),
        3
    ) AS classify_fee,
    ROUND(
        SUM(
            CASE 
                WHEN CONCAT(FTranType, FSaleStyle) IN ('SOR0', 'SEL1') THEN TalSecond
                ELSE 0
            END
        ),
        3
    ) AS material_pay,
    SUM(
        CASE 
            WHEN FTranType = 'PUR' THEN (TalSecond + TalThird + TalForth)
            WHEN FTranType = 'SOR' THEN (TalFrist + TalSecond + TalThird)
            WHEN CONCAT(FTranType, FSaleStyle) = 'SEL1' THEN TalSecond
            ELSE 0
        END
    ) AS total_pay
FROM uctoo_lvhuan.trans_main_table
WHERE FSaleStyle <> '2' AND FCorrent = 1
GROUP BY FRelateBrID, FBillNo, FDate, FSupplyID, Fbusiness, FDeptID, FEmpID, FPOStyle, FPOPrecent;




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_month_wh_profit`;
CREATE VIEW `uctoo_lvhuan`.`trans_month_wh_profit` AS
SELECT
    `whprofit`.`FRelateBrID` AS `FRelateBrID`,
    `whprofit`.`FFeeID` AS `FFeeID`,
    `whprofit`.`FFeeType` AS `FFeeType`,
    `whprofit`.`FFeePerson` AS `FFeePerson`,
    `whprofit`.`FFeeAmount` AS `FFeeAmount`,
    `whprofit`.`FFeebaseAmount` AS `FFeebaseAmount`,
    `whprofit`.`Ftaxrate` AS `Ftaxrate`,
    `whprofit`.`Fbasetax` AS `Fbasetax`,
    `whprofit`.`Fbasetaxamount` AS `Fbasetaxamount`,
    `whprofit`.`FPriceRef` AS `FPriceRef`,
    `whprofit`.`FFeetime` AS `FFeetime`
FROM
    (
        SELECT
            `trans_main`.`FRelateBrID` AS `FRelateBrID`,
            `trans_fee`.`FFeeID` AS `FFeeID`,
            `trans_fee`.`FFeeType` AS `FFeeType`,
            `trans_fee`.`FFeePerson` AS `FFeePerson`,
            SUM(`trans_fee`.`FFeeAmount`) AS `FFeeAmount`,
            `trans_fee`.`FFeebaseAmount` AS `FFeebaseAmount`,
            `trans_fee`.`Ftaxrate` AS `Ftaxrate`,
            `trans_fee`.`Fbasetax` AS `Fbasetax`,
            `trans_fee`.`Fbasetaxamount` AS `Fbasetaxamount`,
            `trans_fee`.`FPriceRef` AS `FPriceRef`,
            DATE_FORMAT(`trans_fee`.`FFeetime`, '%Y-%m-%d') AS `FFeetime`
        FROM
            (`uctoo_lvhuan`.`trans_fee`
            JOIN `uctoo_lvhuan`.`trans_main`)
        WHERE
            ((`trans_fee`.`FFeeID` = '资源池分拣人工')
            AND (`trans_main`.`FTranType` = 'SOR')
            AND (`trans_fee`.`FInterID` = `trans_main`.`FInterID`)
            AND (`trans_main`.`FCorrent` = 1))
        GROUP BY
            `trans_main`.`FRelateBrID`,
            `trans_fee`.`FFeePerson`,
            DATE_FORMAT(`trans_fee`.`FFeetime`, '%Y-%m-%d')
    ) `whprofit`
WHERE
    (NOT (`whprofit`.`FFeetime` IN (SELECT `uctoo_lvhuan`.`trans_month_wh_profit_table`.`FFeetime` FROM `uctoo_lvhuan`.`trans_month_wh_profit_table`)));




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_ordercount`;
CREATE VIEW `uctoo_lvhuan`.`trans_ordercount` AS
SELECT
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
    `uctoo_lvhuan`.`trans_main_table`.`FDeptID` AS `FDeptID`,
    `uctoo_lvhuan`.`trans_main_table`.`FEmpID` AS `FEmpID`,
    COUNT(`uctoo_lvhuan`.`trans_main_table`.`FBillNo`) AS `orderCount`,
    DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') AS `FDate`
FROM
    `uctoo_lvhuan`.`trans_main_table`
WHERE
    `uctoo_lvhuan`.`trans_main_table`.`FTranType` = 'PUR'
GROUP BY
    DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d'),
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`,
    `uctoo_lvhuan`.`trans_main_table`.`FDeptID`,
    `uctoo_lvhuan`.`trans_main_table`.`FEmpID`
HAVING
    DATE_FORMAT(`FDate`, '%Y-%m-%d') >= DATE_FORMAT('2018-07-01', '%Y-%m-%d')
UNION ALL
SELECT
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID` AS `FRelateBrID`,
    NULL AS `FDeptID`,
    NULL AS `FEmpID`, -- Use NULL instead of '-'
    COUNT(`uctoo_lvhuan`.`trans_main_table`.`FBillNo`) AS `orderCount`,
    DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d') AS `FDate`
FROM
    `uctoo_lvhuan`.`trans_main_table`
WHERE
    `uctoo_lvhuan`.`trans_main_table`.`FTranType` = 'SOR'
GROUP BY
    DATE_FORMAT(`uctoo_lvhuan`.`trans_main_table`.`FDate`, '%Y-%m-%d'),
    `uctoo_lvhuan`.`trans_main_table`.`FRelateBrID`
HAVING
    DATE_FORMAT(`FDate`, '%Y-%m-%d') >= DATE_FORMAT('2018-07-01', '%Y-%m-%d');




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_cargo`;
CREATE VIEW `uctoo_lvhuan`.`trans_total_cargo` AS
SELECT
    `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id` AS `FInterID`,
    'PUR' AS `FTranType`,
    SUM(`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`net_weight`) AS `FQtyTotal`,
    ROUND(SUM(`uctoo_lvhuan`.`uct_waste_purchase_cargo`.`total_price`), 2) AS `FAmountTotal`,
    NULL AS `FSourceInterId`, -- Use NULL instead of ''
    NULL AS `FSourceTranType` -- Use NULL instead of ''
FROM
    `uctoo_lvhuan`.`uct_waste_purchase_cargo`
GROUP BY
    `uctoo_lvhuan`.`uct_waste_purchase_cargo`.`purchase_id`
UNION ALL
SELECT
    `uctoo_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `FInterID`,
    'SOR' AS `FTranType`,
    SUM(`uctoo_lvhuan`.`uct_waste_storage_sort`.`net_weight`) AS `FQtyTotal`,
    ROUND(SUM((`uctoo_lvhuan`.`uct_waste_storage_sort`.`net_weight` * `uctoo_lvhuan`.`uct_waste_storage_sort`.`presell_price`)), 2) AS `FAmountTotal`,
    `uctoo_lvhuan`.`uct_waste_storage_sort`.`purchase_id` AS `FSourceInterId`,
    'PUR' AS `FSourceTranType`
FROM
    `uctoo_lvhuan`.`uct_waste_storage_sort`
GROUP BY
    `uctoo_lvhuan`.`uct_waste_storage_sort`.`purchase_id`
UNION ALL
SELECT
    `uctoo_lvhuan`.`uct_waste_sell_cargo`.`sell_id` AS `FInterID`,
    'SEL' AS `FTranType`,
    SUM(`uctoo_lvhuan`.`uct_waste_sell_cargo`.`net_weight`) AS `FQtyTotal`,
    ROUND(SUM((`uctoo_lvhuan`.`uct_waste_sell_cargo`.`net_weight` * `uctoo_lvhuan`.`uct_waste_sell_cargo`.`unit_price`)), 2) AS `FAmountTotal`,
    IF(ISNULL(`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id`), NULL, `uctoo_lvhuan`.`uct_waste_sell`.`purchase_id`) AS `FSourceInterId`,
    IF(ISNULL(`uctoo_lvhuan`.`uct_waste_sell`.`purchase_id`), NULL, 'PUR') AS `FSourceTranType`
FROM
    (`uctoo_lvhuan`.`uct_waste_sell_cargo`
    JOIN `uctoo_lvhuan`.`uct_waste_sell` ON `uctoo_lvhuan`.`uct_waste_sell`.`id` = `uctoo_lvhuan`.`uct_waste_sell_cargo`.`sell_id`)
GROUP BY
    `uctoo_lvhuan`.`uct_waste_sell_cargo`.`sell_id`;




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_cargo_ch`;
CREATE VIEW `uctoo_lvhuan`.`trans_total_cargo_ch` AS select `tctable`.`FInterID` AS `FInterID`,`tctable`.`FQtyTotal` AS `PUR_FQtyTotal`,`tctable`.`FAmountTotal` AS `PUR_FAmountTotal`,`innercargo`.`FQtyTotal` AS `SS_FQtyTotal`,`innercargo`.`FAmountTotal` AS `SS_FAmountTotal` from (`uctoo_lvhuan`.`trans_total_cargo_table` `tctable` join (select `tctable`.`FSourceInterID` AS `FInterID`,`tctable`.`FQtyTotal` AS `FQtyTotal`,`tctable`.`FAmountTotal` AS `FAmountTotal` from `uctoo_lvhuan`.`trans_total_cargo_table` `tctable` where ((`tctable`.`FTranType` = 'SEL') and (`tctable`.`FSourceInterID` > 0)) union all select `tctable`.`FInterID` AS `FInterID`,`tctable`.`FQtyTotal` AS `FQtyTotal`,`tctable`.`FAmountTotal` AS `FAmountTotal` from `uctoo_lvhuan`.`trans_total_cargo_table` `tctable` where (`tctable`.`FTranType` = 'SOR')) `innercargo`) where ((`tctable`.`FTranType` = 'PUR') and (`tctable`.`FInterID` = `innercargo`.`FInterID`));




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_cargo_sec`;
CREATE VIEW `uctoo_lvhuan`.`trans_total_cargo_sec` AS
SELECT
    uctoo_lvhuan.uct_waste_sell_cargo.sell_id AS FInterID,
    'SEL' AS FTranType,
    SUM(uctoo_lvhuan.uct_waste_sell_cargo.net_weight) AS FQtyTotal,
    ROUND(SUM(uctoo_lvhuan.uct_waste_sell_cargo.net_weight * uctoo_lvhuan.uct_waste_sell_cargo.unit_price), 2) AS FAmountTotal,
    CASE 
        WHEN uctoo_lvhuan.uct_waste_sell.purchase_id ~ E'^\\d+$' THEN uctoo_lvhuan.uct_waste_sell.purchase_id::INTEGER 
        ELSE NULL 
    END AS FSourceInterId,
    CASE 
        WHEN uctoo_lvhuan.uct_waste_sell.purchase_id ~ E'^\\d+$' THEN 'PUR' 
        ELSE '' 
    END AS FSourceTranType
FROM
    uctoo_lvhuan.uct_waste_sell_cargo
LEFT JOIN uctoo_lvhuan.uct_waste_sell ON uctoo_lvhuan.uct_waste_sell.id = uctoo_lvhuan.uct_waste_sell_cargo.sell_id
GROUP BY
    uctoo_lvhuan.uct_waste_sell_cargo.sell_id, uctoo_lvhuan.uct_waste_sell.purchase_id;




DROP VIEW IF EXISTS `uctoo_lvhuan`.`trans_total_fee`;
CREATE VIEW `uctoo_lvhuan`.`trans_total_fee` AS
SELECT
    `basep`.`id` AS `FInterID`,
    'PUR' AS `FTranType`,
    IFNULL(`pf`.`customer_profit`, '') AS `CustomerProfit`,
    IFNULL(`pf`.`other_profit`, '') AS `OtherProfit`,
    IFNULL(`pf`.`pick_fee`, '') AS `PickFee`,
    IFNULL(`rf`.`car_fee`, '') AS `CarFee`,
    IFNULL(`rf`.`man_fee`, '') AS `ManFee`,
    IFNULL(`rf`.`other_return_fee`, '') AS `OtherReturnfee`,
    IFNULL(`sg`.`sort_fee`, '') AS `SortFee`,
    ROUND((IFNULL(`sg`.`materiel_fee`, '') + IFNULL(`basep`.`materiel_price`, '')), 2) AS `MaterielFee`,
    IFNULL(`sg`.`other_sort_fee`, '') AS `OtherSortfee`,
    IFNULL(`sf`.`sell_profit`, '') AS `SellProfit`,
    IFNULL(`sf`.`sell_fee`, '') AS `SellFee`
FROM
    (
        (
            (
                (
                    (
                        `uctoo_lvhuan`.`uct_waste_purchase` `basep`
                        LEFT JOIN `uctoo_lvhuan`.`trans_total_fee_rf` `rf`
                        ON (`basep`.`id` = `rf`.`purchase_id`)
                    )
                    LEFT JOIN `uctoo_lvhuan`.`trans_total_fee_sg` `sg`
                    ON (`basep`.`id` = `sg`.`purchase_id`)
                )
                LEFT JOIN `uctoo_lvhuan`.`trans_total_fee_pf` `pf`
                ON (`basep`.`id` = `pf`.`purchase_id`)
            )
            LEFT JOIN `uctoo_lvhuan`.`trans_total_fee_sf` `sf`
            ON (`basep`.`id` = `sf`.`purchase_id`)
        )
    )
UNION ALL
SELECT
    `osf`.`sell_id` AS `FInterID`,
    'SEL' AS `FTranType`,
    '' AS `CustomerProfit`,
    '' AS `OtherProfit`,
    '' AS `PickFee`,
    '' AS `CarFee`,
    '' AS `ManFee`,
    '' AS `OtherReturnfee`,
    '' AS `SortFee`,
    '' AS `MaterielFee`,
    '' AS `OtherSortfee`,
    IFNULL(`osf`.`sell_profit`, '') AS `SellProfit`,
    IFNULL(`osf`.`sell_fee`, '') AS `SellFee`
FROM
    `uctoo_lvhuan`.`trans_total_fee_osf` `osf`;

    
    
    
    
DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_cargofile_collect`;
CREATE VIEW `uctoo_lvhuan`.`view_cargofile_collect` AS select `view_cargofile_third`.`id` AS `id`,`view_cargofile_first`.`name` AS `first_sort`,`view_cargofile_second`.`name` AS `second_sort`,`view_cargofile_third`.`name` AS `sort_name`,`view_cargofile_third`.`branch_id` AS `branch_id` from ((`uctoo_lvhuan`.`view_cargofile_third` join `uctoo_lvhuan`.`view_cargofile_second`) join `uctoo_lvhuan`.`view_cargofile_first`) where ((`view_cargofile_third`.`parent_id` = `view_cargofile_second`.`id`) and (`view_cargofile_second`.`parent_id` = `view_cargofile_first`.`id`));
   
    
    
    


DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_purchase_expense_collect`;
CREATE VIEW `uctoo_lvhuan`.`view_purchase_expense_collect` AS 
SELECT 
    uctoo_lvhuan.uct_waste_purchase_expense.purchase_id AS purchase_id,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '供应商人工补助费' THEN uctoo_lvhuan.uct_waste_purchase_expense.price ELSE 0 END), 2) AS 供应商人工补助,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '供应商车辆补助费' THEN uctoo_lvhuan.uct_waste_purchase_expense.price ELSE 0 END), 2) AS 供应商车辆补助,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '供应商垃圾补助费' THEN uctoo_lvhuan.uct_waste_purchase_expense.price ELSE 0 END), 2) AS 供应商垃圾补助,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '叉车费' THEN uctoo_lvhuan.uct_waste_purchase_expense.price ELSE 0 END), 2) AS 叉车费,
    CASE 
        WHEN SUM(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '叉车费' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '叉车费' THEN uctoo_lvhuan.uct_waste_purchase_expense.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '叉车费' THEN uctoo_lvhuan.uct_waste_purchase_expense.receiver || CAST(uctoo_lvhuan.uct_waste_purchase_expense.price AS VARCHAR) ELSE '' END, '')
    END AS 叉车司机,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '其他收入' THEN uctoo_lvhuan.uct_waste_purchase_expense.price ELSE 0 END), 2) AS 其他提货收入,
    CASE 
        WHEN SUM(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '其他收入' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '其他收入' THEN uctoo_lvhuan.uct_waste_purchase_expense.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '其他收入' THEN uctoo_lvhuan.uct_waste_purchase_expense.receiver || CAST(uctoo_lvhuan.uct_waste_purchase_expense.price AS VARCHAR) ELSE '' END, '')
    END AS 其他提货收入收款人,
    STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '其他收入' THEN uctoo_lvhuan.uct_waste_purchase_expense.remark ELSE '' END, '') AS 其他提货收入说明,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '其他支出' THEN uctoo_lvhuan.uct_waste_purchase_expense.price ELSE 0 END), 2) AS 其他提货支出,
    CASE 
        WHEN SUM(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '其他支出' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '其他支出' THEN uctoo_lvhuan.uct_waste_purchase_expense.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '其他支出' THEN uctoo_lvhuan.uct_waste_purchase_expense.receiver || CAST(uctoo_lvhuan.uct_waste_purchase_expense.price AS VARCHAR) ELSE '' END, '')
    END AS 其他提货支出收款人,
    STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_purchase_expense.usage = '其他支出' THEN uctoo_lvhuan.uct_waste_purchase_expense.remark ELSE '' END, '') AS 其他提货支出说明
FROM 
    uctoo_lvhuan.uct_waste_purchase_expense 
GROUP BY 
    uctoo_lvhuan.uct_waste_purchase_expense.purchase_id;



DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_reimbursement_expense_collect`;
CREATE VIEW `uctoo_lvhuan`.`view_reimbursement_expense_collect` AS 
SELECT 
    uctoo_lvhuan.uct_waste_storage_return_fee.purchase_id AS purchase_id,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '外请车费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 外请车辆,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '公司车费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 公司车辆,
    STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage IN ('外请车费', '公司车费') THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver ELSE '' END, '') AS 司机,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '拉货专员人工' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 拉货专员人工,
    CASE 
        WHEN SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '拉货专员人工' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '拉货专员人工' THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '拉货专员人工' THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver || CAST(uctoo_lvhuan.uct_waste_storage_return_fee.price AS VARCHAR) ELSE '' END, '')
    END AS 拉货专员姓名,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '拉货助理人工' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 拉货助理人工,
    CASE 
        WHEN SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '拉货助理人工' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '拉货助理人工' THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '拉货助理人工' THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver || CAST(uctoo_lvhuan.uct_waste_storage_return_fee.price AS VARCHAR) ELSE '' END, '')
    END AS 拉货助理姓名,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '外请人工' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 外请人工,
    CASE 
        WHEN SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '外请人工' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '外请人工' THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '外请人工' THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver || CAST(uctoo_lvhuan.uct_waste_storage_return_fee.price AS VARCHAR) ELSE '' END, '')
    END AS 外请人工姓名,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '叉车费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 叉车费,
    CASE 
        WHEN SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '叉车费' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '叉车费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '叉车费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver || CAST(uctoo_lvhuan.uct_waste_storage_return_fee.price AS VARCHAR) ELSE '' END, '')
    END AS 叉车司机,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '停车费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 停车费,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '过路费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 过路费,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '磅费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 磅费,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '水费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 水费,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '餐费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 餐费,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '交通费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 交通费,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '住宿费' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 住宿费,
    ROUND(SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '其他' THEN uctoo_lvhuan.uct_waste_storage_return_fee.price ELSE 0 END), 2) AS 其他报销费用,
    CASE 
        WHEN SUM(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '其他' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '其他' THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '其他' THEN uctoo_lvhuan.uct_waste_storage_return_fee.receiver || CAST(uctoo_lvhuan.uct_waste_storage_return_fee.price AS VARCHAR) ELSE '' END, '')
    END AS 其他报销费用收款人,
    STRING_AGG(CASE WHEN uctoo_lvhuan.uct_waste_storage_return_fee.usage = '其他' THEN uctoo_lvhuan.uct_waste_storage_return_fee.remark ELSE '' END, '') AS 其他报销费用说明
FROM 
    uctoo_lvhuan.uct_waste_storage_return_fee 
GROUP BY 
    uctoo_lvhuan.uct_waste_storage_return_fee.purchase_id;
    
    
    

DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_sort_expense_collect`;
CREATE VIEW `uctoo_lvhuan`.`view_sort_expense_collect` AS 
SELECT 
    view_sec.purchase_id AS purchase_id,
    ROUND(SUM(CASE WHEN view_sec.usage = '资源池分拣人工' THEN view_sec.price ELSE 0 END), 2) AS 仓库分拣人工,
    CASE 
        WHEN SUM(CASE WHEN view_sec.usage = '资源池分拣人工' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN view_sec.usage = '资源池分拣人工' THEN view_sec.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN view_sec.usage = '资源池分拣人工' THEN view_sec.receiver || CAST(view_sec.price AS VARCHAR) ELSE '' END, '')
    END AS 仓库分拣人工姓名,
    ROUND(SUM(CASE WHEN view_sec.usage = '拉货人分拣人工' THEN view_sec.price ELSE 0 END), 2) AS 拉货人分拣人工,
    CASE 
        WHEN SUM(CASE WHEN view_sec.usage = '拉货人分拣人工' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN view_sec.usage = '拉货人分拣人工' THEN view_sec.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN view_sec.usage = '拉货人分拣人工' THEN view_sec.receiver || CAST(view_sec.price AS VARCHAR) ELSE '' END, '')
    END AS 拉货人分拣人工姓名,
    ROUND(SUM(CASE WHEN view_sec.usage = '临时工分拣人工' THEN view_sec.price ELSE 0 END), 2) AS 外请临时工分拣,
    CASE 
        WHEN SUM(CASE WHEN view_sec.usage = '临时工分拣人工' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN view_sec.usage = '临时工分拣人工' THEN view_sec.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN view_sec.usage = '临时工分拣人工' THEN view_sec.receiver || CAST(view_sec.price AS VARCHAR) ELSE '' END, '')
    END AS 外请临时工姓名,
    ROUND(SUM(CASE WHEN view_sec.usage = '耗材费-太空包' THEN view_sec.price ELSE 0 END), 2) AS 耗材（太空袋费）,
    ROUND(SUM(CASE WHEN view_sec.usage = '耗材费-编织袋' THEN view_sec.price ELSE 0 END), 2) AS 耗材（编织袋费）,
    ROUND(SUM(CASE WHEN view_sec.usage = '其他' THEN view_sec.price ELSE 0 END), 2) AS 其他入库费用,
    CASE 
        WHEN SUM(CASE WHEN view_sec.usage = '其他' THEN 1 ELSE 0 END) = 1
        THEN STRING_AGG(CASE WHEN view_sec.usage = '其他' THEN view_sec.receiver ELSE '' END, '') 
        ELSE STRING_AGG(CASE WHEN view_sec.usage = '其他' THEN view_sec.receiver || CAST(view_sec.price AS VARCHAR) ELSE '' END, '')
    END AS 其他入库费用收款人,
    STRING_AGG(CASE WHEN view_sec.usage = '其他' THEN view_sec.remark ELSE '' END, '') AS 其他入库费用说明 
FROM 
    (
    SELECT 
        uctoo_lvhuan.uct_waste_storage_expense.id AS id,
        uctoo_lvhuan.uct_waste_storage_expense.purchase_id AS purchase_id,
        uctoo_lvhuan.uct_waste_storage_expense.type AS type,
        uctoo_lvhuan.uct_waste_storage_expense.usage AS usage,
        uctoo_lvhuan.uct_waste_storage_expense.remark AS remark,
        uctoo_lvhuan.uct_waste_storage_expense.price AS price,
        uctoo_lvhuan.uct_waste_storage_expense.receiver AS receiver,
        uctoo_lvhuan.uct_waste_storage_expense.createtime AS createtime,
        uctoo_lvhuan.uct_waste_storage_expense.updatetime AS updatetime 
    FROM 
        uctoo_lvhuan.uct_waste_storage_expense 
    UNION ALL 
    SELECT 
        uctoo_lvhuan.uct_waste_storage_sort_expense.id AS id,
        uctoo_lvhuan.uct_waste_storage_sort_expense.purchase_id AS purchase_id,
        uctoo_lvhuan.uct_waste_storage_sort_expense.type AS type,
        uctoo_lvhuan.uct_waste_storage_sort_expense.usage AS usage,
        uctoo_lvhuan.uct_waste_storage_sort_expense.remark AS remark,
        uctoo_lvhuan.uct_waste_storage_sort_expense.price AS price,
        uctoo_lvhuan.uct_waste_storage_sort_expense.receiver AS receiver,
        uctoo_lvhuan.uct_waste_storage_sort_expense.createtime AS createtime,
        uctoo_lvhuan.uct_waste_storage_sort_expense.updatetime AS updatetime 
    FROM 
        uctoo_lvhuan.uct_waste_storage_sort_expense
    ) AS view_sec 
GROUP BY 
    view_sec.purchase_id;











DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_cargo_in`;
create view `uctoo_lvhuan`.`accoding_cargo_in` as select `wh`.`branch_id` AS `branch_id`,concat(`c`.`customer_code`,'#',`p`.`order_id`) AS `order_id`,`uctoo_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,`ac`.`name` AS `name`,`uctoo_lvhuan`.`trans_assist_table`.`disposal_way` AS `disposal_way`,`uctoo_lvhuan`.`trans_assist_table`.`FQty` AS `FQty`,`uctoo_lvhuan`.`trans_assist_table`.`FPrice` AS `FPrice`,`uctoo_lvhuan`.`trans_assist_table`.`FAmount` AS `FAmount`,`uctoo_lvhuan`.`trans_assist_table`.`FDCTime` AS `FDCTime` from ((((`uctoo_lvhuan`.`trans_assist_table` join `uctoo_lvhuan`.`uct_waste_purchase` `p`) join `uctoo_lvhuan`.`uct_waste_customer` `c`) join `uctoo_lvhuan`.`accoding_stock_cate` `ac`) join `uctoo_lvhuan`.`uct_waste_warehouse` `wh`) where ((`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = 'SOR') and (`uctoo_lvhuan`.`trans_assist_table`.`FinterID` = `p`.`id`) and (`p`.`customer_id` = `c`.`id`) and (`ac`.`FItemID` = `uctoo_lvhuan`.`trans_assist_table`.`FItemID`) and (`p`.`branch_id` <> 7) and (`p`.`state` <> 'cancel') and (`p`.`sort_point` = `wh`.`id`));




DROP VIEW IF EXISTS `uctoo_lvhuan`.`accoding_cargo_out`;
create view `uctoo_lvhuan`.`accoding_cargo_out` as select `p`.`branch_id` AS `branch_id`,concat(`c`.`customer_code`,'#',`p`.`order_id`) AS `order_id`,`uctoo_lvhuan`.`trans_assist_table`.`FItemID` AS `FItemID`,`ac`.`name` AS `name`,`uctoo_lvhuan`.`trans_assist_table`.`FQty` AS `FQty`,`uctoo_lvhuan`.`trans_assist_table`.`FPrice` AS `FPrice`,`uctoo_lvhuan`.`trans_assist_table`.`FAmount` AS `FAmount`,`uctoo_lvhuan`.`trans_assist_table`.`FDCTime` AS `FDCTime` from (((`uctoo_lvhuan`.`trans_assist_table` join `uctoo_lvhuan`.`uct_waste_sell` `p`) join `uctoo_lvhuan`.`uct_waste_customer` `c`) join `uctoo_lvhuan`.`accoding_stock_cate` `ac`) where ((`uctoo_lvhuan`.`trans_assist_table`.`FTranType` = 'SEL') and (`uctoo_lvhuan`.`trans_assist_table`.`FinterID` = `p`.`id`) and (`p`.`customer_id` = `c`.`id`) and (`ac`.`FItemID` = `uctoo_lvhuan`.`trans_assist_table`.`FItemID`) and (`p`.`branch_id` <> 7) and isnull(length(`p`.`purchase_id`)) and (`p`.`state` <> 'cancel'));


DROP VIEW IF EXISTS `uctoo_lvhuan`.`view_sell_time`;
create view `uctoo_lvhuan`.`view_sell_time` as select `uctoo_lvhuan`.`uct_waste_sell_log`.`sell_id` AS `sell_id`,date_format(from_unixtime(`uctoo_lvhuan`.`uct_waste_sell_log`.`createtime`),'%Y-%m-%d') AS `sell_time` from (`uctoo_lvhuan`.`uct_waste_sell_log` join `uctoo_lvhuan`.`view_valid_sell`) where ((`uctoo_lvhuan`.`uct_waste_sell_log`.`state_value` = 'wait_confirm_order') and (`view_valid_sell`.`sell_id` = `uctoo_lvhuan`.`uct_waste_sell_log`.`sell_id`));



DROP VIEW IF EXISTS `uctoo_lvhuan`.`test_3`;
CREATE VIEW `uctoo_lvhuan`.`test_3` AS select `bra`.`name` AS `braName`,`stock`.`name` AS `name`,`stock`.`FQty` AS `cateName` from (`uctoo_lvhuan`.`accoding_stock` `stock` join `uctoo_lvhuan`.`uct_branch` `bra`) where (`bra`.`setting_key` = `stock`.`FRelateBrID`);



DROP VIEW IF EXISTS `uctoo_lvhuan`.`acconding_cargo_list`;
CREATE VIEW `uctoo_lvhuan`.`acconding_cargo_list` AS select `view_valid_purchase`.`FRelateBrID` AS `FRelateBrID`,`view_valid_purchase`.`FBillNo` AS `FBillNo`,`view_valid_purchase`.`FSupplyID` AS `FSupplyID`,`view_cargo_collect`.`FItemID` AS `FItemID`,`view_cargo_collect`.`PUR_log` AS `PUR_log`,`view_cargo_collect`.`PUR_FQty` AS `PUR_FQty`,`view_cargo_collect`.`PUR_FAmount` AS `PUR_FAmount`,`view_cargo_collect`.`SOR_log` AS `SOR_log`,`view_cargo_collect`.`SOR_FQty` AS `SOR_FQty`,`view_cargo_collect`.`SOR_FAmount` AS `SOR_FAmount`,(`view_cargo_collect`.`PUR_FQty` - `view_cargo_collect`.`SOR_FQty`) AS `weight_loss`,`view_valid_purchase`.`FDate` AS `purchase_time`,`view_cargo_collect`.`FDCTime` AS `sort_time`,`view_valid_purchase`.`Fbusiness` AS `Fbusiness`,`view_valid_purchase`.`FEmpID` AS `FEmpID`,`view_valid_purchase`.`FSaleStyle` AS `FSaleStyle` from (`uctoo_lvhuan`.`view_valid_purchase` join `uctoo_lvhuan`.`view_cargo_collect`) where (`view_valid_purchase`.`FInterID` = `view_cargo_collect`.`FInterID`);


