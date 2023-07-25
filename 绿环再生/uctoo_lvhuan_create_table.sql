CREATE TABLE `accoding_sell_snapshot` (	
	`id` bigint not null,
	`time_dims` varchar(20) not null,
	`time_val` varchar(20) not null,
	`begin_time` timestamp without time zone ,
	`end_time` timestamp without time zone ,
	`branch_id` bigint not null,
	`ware_id` bigint ,
	`cate_id` bigint not null,
	`cate_name` varchar(100) not null,
	`sell_qty` decimal(10,2) ,
	`sell_amount` decimal(10,2) ,
	`start_price` decimal(10,2) ,
	`new_price` decimal(10,2) ,
	`avg_price` decimal(10,2) ,
	`last_price` decimal(10,2) ,
	`create_at` timestamp without time zone ,
	`updata_at` timestamp without time zone ,
	constraint accoding_sell_snapshot_pkey primary key ( id )
);

alter table accoding_sell_snapshot alter column id add auto_increment;



CREATE TABLE `accoding_stock_history` (	
	`frelatebrid` bigint not null,
	`fstockid` varchar(20) ,
	`fitemid` bigint ,
	`fdcqty` decimal(10,1) ,
	`fscqty` decimal(10,1) ,
	`fdifqty` bigint ,
	`fdctime` timestamp without time zone 

);




CREATE TABLE `accoding_stock_history_copy1` (	
	`frelatebrid` bigint not null,
	`fstockid` varchar(20) ,
	`fitemid` bigint ,
	`fdcqty` decimal(10,1) ,
	`fscqty` decimal(10,1) ,
	`fdifqty` bigint ,
	`fdctime` timestamp without time zone 

);




CREATE TABLE `accoding_stock_history_copy2` (	
	`frelatebrid` bigint not null,
	`fstockid` varchar(20) ,
	`fitemid` bigint ,
	`fdcqty` decimal(10,1) ,
	`fscqty` decimal(10,1) ,
	`fdifqty` bigint ,
	`fdctime` timestamp without time zone 

);




CREATE TABLE `accoding_stock_history_ori` (	
	`frelatebrid` bigint not null,
	`fstockid` varchar(20) ,
	`fitemid` bigint ,
	`fdcqty` decimal(10,1) ,
	`fscqty` decimal(10,1) ,
	`fdifqty` bigint ,
	`fdctime` timestamp without time zone 

);




CREATE TABLE `accoding_stock_snapshot` (	
	`time_dims` varchar(20) not null,
	`time_val` varchar(20) not null,
	`begin_time` timestamp without time zone not null,
	`end_time` timestamp without time zone not null,
	`frelatebrid` bigint not null,
	`fstockid` varchar(50) not null,
	`fitemid` bigint not null,
	`lastprice` decimal(10,2) ,
	`fdcqty` decimal(10,1) not null,
	`fscqty` decimal(10,1) not null,
	`finventoryqty` decimal(10,1) not null,
	`fdifqty` decimal(10,1) not null,
	`create_at` timestamp without time zone not null,
	`updata_at` timestamp without time zone not null

);

create index `accoding_stock_snapshot_idx_id` on `accoding_stock_snapshot` (
	`frelatebrid`,
	`fstockid`,
	`fitemid`
);
create index `accoding_stock_snapshot_idx_time` on `accoding_stock_snapshot` (
	`time_dims`,
	`time_val`
);



CREATE TABLE `accoding_stock_snapshot_copy1` (	
	`time_dims` varchar(20) not null,
	`time_val` varchar(20) not null,
	`begin_time` timestamp without time zone not null,
	`end_time` timestamp without time zone not null,
	`frelatebrid` bigint not null,
	`fstockid` varchar(50) not null,
	`fitemid` bigint not null,
	`lastprice` decimal(10,2) ,
	`fdcqty` decimal(10,1) not null,
	`fscqty` decimal(10,1) not null,
	`finventoryqty` decimal(10,1) not null,
	`fdifqty` decimal(10,1) not null,
	`create_at` timestamp without time zone not null,
	`updata_at` timestamp without time zone not null

);

create index `accoding_stock_snapshot_copy1_idx_id` on `accoding_stock_snapshot_copy1` (
	`frelatebrid`,
	`fstockid`,
	`fitemid`
);
create index `accoding_stock_snapshot_copy1_idx_time` on `accoding_stock_snapshot_copy1` (
	`time_dims`,
	`time_val`
);



CREATE TABLE `bal_close_accounts` (	
	`fbillinterid` bigint not null,
	`frelatebrid` bigint not null,
	`fyear` bigint not null,
	`fperiod` bigint not null,
	`fstockid` bigint not null,
	`fitemid` bigint not null,
	`fbatchno` bigint not null,
	`fbegqty` bigint not null,
	`freceive` bigint not null,
	`fsend` bigint not null,
	`fytdreceive` bigint not null,
	`fytdsend` bigint not null,
	`fendqty` bigint not null,
	`fbegbal` bigint not null,
	`fdebit` bigint not null,
	`fcredit` bigint not null,
	`fytddebit` bigint not null,
	`fytdcredit` bigint not null,
	`fendbal` bigint not null

);




CREATE TABLE `cus_null_createtime` (	
	`cus_id` bigint not null,
	`createtime` bigint not null

);




CREATE TABLE `cut_customer_sevrinfo` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`name_cn` varchar(20) not null,
	`name_en` varchar(50) not null,
	`position_cn` varchar(20) not null,
	`position_en` varchar(50) not null,
	`introduce_cn` varchar(100) not null,
	`introduce_en` varchar(500) not null,
	`img` bytea not null,
	constraint cut_customer_sevrinfo_pkey primary key ( id )
);

alter table cut_customer_sevrinfo alter column id add auto_increment;




CREATE TABLE `datawall_topcate` (	
	`frelatebrid` bigint not null,
	`fitemid` bigint not null,
	`name` varchar(100) not null

);




CREATE TABLE `dingtalk_application_info` (	
	`agentid` varchar(20) not null,
	`corpid` varchar(50) not null,
	`appkey` varchar(50) not null,
	`appsecret` varchar(100) not null,
	`token` varchar(10) not null,
	`aeskey` varchar(50) not null,
	`url` varchar(128) not null,
	`call_back_tap` varchar(100) not null,
	`status` varchar(256) not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint dingtalk_application_info_pkey primary key ( agentid )
);




CREATE TABLE `dingtalk_book_dep_info` (	
	`id` bigint not null,
	`dep_id` bigint ,
	`parent_id` bigint ,
	`name` varchar(30) ,
	`state` bigint ,
	`create_time` timestamp without time zone not null,
	`update_time` timestamp without time zone not null,
	constraint dingtalk_book_dep_info_pkey primary key ( id )
);

alter table dingtalk_book_dep_info alter column id add auto_increment;

alter table `dingtalk_book_dep_info` add constraint `dingtalk_book_dep_info_dep_id` unique (
	`dep_id`
);



CREATE TABLE `dingtalk_book_user_info` (	
	`userid` varchar(50) not null,
	`unionid` varchar(50) ,
	`wechat_id` varchar(50) ,
	`admin_id_group` varchar(50) not null,
	`dept_id` varchar(100) not null,
	`name` varchar(20) ,
	`mobile` varchar(11) ,
	`user_data` varchar(4096) ,
	`state` int not null,
	`create_time` timestamp without time zone not null,
	`update_time` timestamp without time zone not null,
	constraint dingtalk_book_user_info_pkey primary key ( userid )
);

alter table `dingtalk_book_user_info` add constraint `dingtalk_book_user_info_unionid` unique (
	`unionid`
);



CREATE TABLE `dingtalk_failed_to_push_list` (	
	`id` bigint not null,
	`call_back_tag` varchar(100) not null,
	`corpid` varchar(50) not null,
	`agentid` bigint not null,
	`event_time` bigint not null,
	`state` int not null,
	`event_json` varchar(8192) not null,
	`create_time` timestamp without time zone not null,
	`update_time` timestamp without time zone not null,
	constraint dingtalk_failed_to_push_list_pkey primary key ( id )
);

alter table dingtalk_failed_to_push_list alter column id add auto_increment;




CREATE TABLE `dingtalk_process_info` (	
	`id` bigint not null,
	`agentid` varchar(20) not null,
	`processtype` varchar(32) not null,
	`processcode` varchar(100) not null,
	`status` varchar(256) not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint dingtalk_process_info_pkey primary key ( id )
);

alter table dingtalk_process_info alter column id add auto_increment;




CREATE TABLE `dingtalk_process_log` (	
	`id` bigint not null,
	`process_id` varchar(25) not null,
	`process_type` varchar(20) not null,
	`applicant_dingtalk_id` varchar(20) not null,
	`applicant` varchar(20) not null,
	`data` bytea ,
	`precess_result` varchar(10) not null,
	`process_createtime` varchar(24) not null,
	`process_finishtime` varchar(24) not null,
	`remark` bytea not null,
	`createat` timestamp without time zone not null,
	constraint dingtalk_process_log_pkey primary key ( id )
);

alter table dingtalk_process_log alter column id add auto_increment;




CREATE TABLE `dingtalk_resource_info` (	
	`id` bigint not null,
	`agentid` varchar(20) not null,
	`resourcetype` varchar(20) not null,
	`resourcecode` varchar(100) not null,
	`status` varchar(256) not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint dingtalk_resource_info_pkey primary key ( id )
);

alter table dingtalk_resource_info alter column id add auto_increment;




CREATE TABLE `dingtalk_visual_dept_num` (	
	`id` bigint not null,
	`branch_id` bigint ,
	`dept_id` bigint ,
	`dept_child_id` varchar(10000) ,
	`dept_name` varchar(100) ,
	`user_num` bigint ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint dingtalk_visual_dept_num_pkey primary key ( id )
);

alter table dingtalk_visual_dept_num alter column id add auto_increment;




CREATE TABLE `ec_admin` (	
	`userid` varchar(25) ,
	`deptid` varchar(25) ,
	`username` varchar(12) ,
	`account` varchar(15) ,
	`title` varchar(15) ,
	`discard` bigint 

);




CREATE TABLE `ec_down_customer` (	
	`crmid` bigint not null,
	`name` varchar(20) ,
	`mobile` varchar(20) ,
	`company` varchar(255) ,
	`follow_crmid` varchar(255) ,
	`follow_id` bigint ,
	`follow_nickname` varchar(255) 

);




CREATE TABLE `ec_up_customer` (	
	`crmid` bigint not null,
	`name` varchar(20) ,
	`mobile` varchar(20) ,
	`company` varchar(255) ,
	`follow_crmid` varchar(255) ,
	`follow_id` bigint ,
	`branch_name` varchar(255) ,
	`service_department` varchar(255) ,
	`follow_nickname` varchar(255) ,
	`createtime` timestamp without time zone 

);




CREATE TABLE `performance_result_admin` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`userid` varchar(50) ,
	`period` varchar(20) ,
	`level` varchar(20) ,
	`performance_id` bigint ,
	`weight` int ,
	`baseline` decimal(10,3) ,
	`vardaily` json ,
	`reference` decimal(10,3) ,
	`actualize` decimal(10,3) ,
	`score` int ,
	`status` varchar(256) ,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint performance_result_admin_pkey primary key ( id )
);

alter table performance_result_admin alter column id add auto_increment;




CREATE TABLE `performance_template` (	
	`id` bigint not null,
	`class` varchar(20) not null,
	`name` varchar(20) not null,
	`unit` varchar(20) not null,
	`createtime` timestamp without time zone not null,
	constraint performance_template_pkey primary key ( id )
);

alter table performance_template alter column id add auto_increment;




CREATE TABLE `qc` (	
	`id` bigint not null,
	`cus_id` varchar(50) not null,
	`branch_id` int not null,
	`cus_name` varchar(100) not null,
	`cus_type` varchar(10) not null,
	`amount` NUMERIC not null,
	`num` int not null,
	`state` int not null,
	constraint qc_pkey primary key ( id )
);

alter table qc alter column id add auto_increment;




CREATE TABLE `save_sellimit` (	
	`fstockid` varchar(12) ,
	`fitemid` bigint not null

);




CREATE TABLE `table_repair` (	
	`order_code` varchar(20) not null

);




CREATE TABLE `table_replace` (	
	`name` varchar(50) not null,
	`wechat_id` varchar(50) 

);




CREATE TABLE `table_selecttool` (	
	`id` bigint not null

);




CREATE TABLE `tool_distribute_detail` (	
	`id` bigint not null,
	`distribute_id` bigint not null,
	`task_id` varchar(20) not null,
	`receivepersonid` bigint not null,
	`receiveperson` varchar(10) not null,
	`receivepersonwechat` varchar(50) not null,
	`receivefile_url` varchar(512) not null,
	`datarows` bigint not null,
	`sendactstatus` int not null,
	`feedbackstatus` int not null,
	`feedbacktime` timestamp without time zone ,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint tool_distribute_detail_pkey primary key ( id )
);

alter table tool_distribute_detail alter column id add auto_increment;




CREATE TABLE `tool_distribute_main` (	
	`id` bigint not null,
	`sendpersonid` varchar(10) not null,
	`sendperson` varchar(10) not null,
	`file_name` varchar(50) not null,
	`file_url` varchar(512) not null,
	`datarows` bigint not null,
	`receivetotal` bigint not null,
	`sendacttotal` bigint not null,
	`feedbacktotal` bigint not null,
	`distributetime` timestamp without time zone ,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint tool_distribute_main_pkey primary key ( id )
);

alter table tool_distribute_main alter column id add auto_increment;




CREATE TABLE `tool_transorder` (	
	`ordercode` varchar(11) not null,
	`customer` varchar(20) not null,
	`area` varchar(20) not null,
	`areacode` varchar(4) not null,
	`catecode` varchar(2) not null,
	`code` bigint not null,
	`createtime` timestamp without time zone not null

);




CREATE TABLE `trans_assist_table` (	
	`finterid` bigint not null,
	`ftrantype` varchar(3) ,
	`fentryid` bigint ,
	`fitemid` bigint ,
	`funitid` varchar(1) ,
	`fqty` double precision ,
	`fprice` double precision ,
	`famount` NUMERIC(19,2) ,
	`disposal_way` varchar(20) ,
	`value_type` varchar(20) ,
	`fbaseprice` char(1) ,
	`fbaseamount` char(1) ,
	`ftaxrate` char(1) ,
	`fbasetax` char(1) ,
	`fbasetaxamount` char(1) ,
	`fpriceref` char(1) ,
	`fdctime` timestamp without time zone ,
	`fsourceinterid` varchar(11) ,
	`fsourcetrantype` varchar(3) ,
	`red_ink_time` timestamp without time zone ,
	`is_hedge` int ,
	`revise_state` int 

);

create index `trans_assist_table_FTranType` on `trans_assist_table` (
	`ftrantype`,
	`fitemid`,
	`fdctime`
);
create index `trans_assist_table_trans_assist_t_idx_001` on `trans_assist_table` (
	`finterid`,
	`ftrantype`,
	`fitemid`
);
create index `trans_assist_table_trans_assist_t_idx_003` on `trans_assist_table` (
	`fitemid`,
	`fsourceinterid`,
	`finterid`,
	`ftrantype`
);
create index `trans_assist_table_trans_assist_t_idx_004` on `trans_assist_table` (
	`value_type`
);
create index `trans_assist_table_trans_assist_t_idx_005` on `trans_assist_table` (
	`ftrantype`,
	`disposal_way`,
	`fdctime`,
	`red_ink_time`,
	`finterid`
);
create index `trans_assist_table_trans_assist_t_idx_006` on `trans_assist_table` (
	`finterid`,
	`ftrantype`,
	`disposal_way`,
	`fdctime`
);



CREATE TABLE `trans_assist_table_bak2` (	
	`finterid` bigint not null,
	`ftrantype` varchar(3) ,
	`fentryid` bigint ,
	`fitemid` bigint ,
	`funitid` varchar(1) ,
	`fqty` double precision ,
	`fprice` double precision ,
	`famount` NUMERIC(19,2) ,
	`disposal_way` varchar(20) ,
	`value_type` varchar(20) ,
	`fbaseprice` char(1) ,
	`fbaseamount` char(1) ,
	`ftaxrate` char(1) ,
	`fbasetax` char(1) ,
	`fbasetaxamount` char(1) ,
	`fpriceref` char(1) ,
	`fdctime` timestamp without time zone ,
	`fsourceinterid` varchar(11) ,
	`fsourcetrantype` varchar(3) ,
	`red_ink_time` timestamp without time zone ,
	`is_hedge` int ,
	`revise_state` int 

);

create index `trans_assist_table_bak2_FTranType` on `trans_assist_table_bak2` (
	`ftrantype`,
	`fitemid`,
	`fdctime`
);
create index `trans_assist_table_bak2_trans_assist_t_idx_001` on `trans_assist_table_bak2` (
	`finterid`,
	`ftrantype`,
	`fitemid`
);
create index `trans_assist_table_bak2_trans_assist_t_idx_003` on `trans_assist_table_bak2` (
	`fitemid`,
	`fsourceinterid`,
	`finterid`,
	`ftrantype`
);
create index `trans_assist_table_bak2_trans_assist_t_idx_004` on `trans_assist_table_bak2` (
	`value_type`
);



CREATE TABLE `trans_assist_table_bak3` (	
	`finterid` bigint not null,
	`ftrantype` varchar(3) ,
	`fentryid` bigint ,
	`fitemid` bigint ,
	`funitid` varchar(1) ,
	`fqty` double precision ,
	`fprice` double precision ,
	`famount` NUMERIC(19,2) ,
	`disposal_way` varchar(20) ,
	`value_type` varchar(20) ,
	`fbaseprice` char(1) ,
	`fbaseamount` char(1) ,
	`ftaxrate` char(1) ,
	`fbasetax` char(1) ,
	`fbasetaxamount` char(1) ,
	`fpriceref` char(1) ,
	`fdctime` timestamp without time zone ,
	`fsourceinterid` varchar(11) ,
	`fsourcetrantype` varchar(3) ,
	`red_ink_time` timestamp without time zone ,
	`is_hedge` int ,
	`revise_state` int 

);

create index `trans_assist_table_bak3_FTranType` on `trans_assist_table_bak3` (
	`ftrantype`,
	`fitemid`,
	`fdctime`
);
create index `trans_assist_table_bak3_trans_assist_t_idx_001` on `trans_assist_table_bak3` (
	`finterid`,
	`ftrantype`,
	`fitemid`
);
create index `trans_assist_table_bak3_trans_assist_t_idx_003` on `trans_assist_table_bak3` (
	`fitemid`,
	`fsourceinterid`,
	`finterid`,
	`ftrantype`
);
create index `trans_assist_table_bak3_trans_assist_t_idx_004` on `trans_assist_table_bak3` (
	`value_type`
);
create index `trans_assist_table_bak3_trans_assist_t_idx_005` on `trans_assist_table_bak3` (
	`ftrantype`,
	`disposal_way`,
	`fdctime`,
	`red_ink_time`,
	`finterid`
);
create index `trans_assist_table_bak3_trans_assist_t_idx_006` on `trans_assist_table_bak3` (
	`finterid`,
	`ftrantype`,
	`disposal_way`,
	`fdctime`
);



CREATE TABLE `trans_constitute_forcustomer_table` (	
	`frelatebrid` bigint not null,
	`fsupplyid` bigint ,
	`fbusiness` varchar(11) ,
	`parent_id` bigint not null,
	`fqty` NUMERIC(19,2) ,
	`carbon_parm` double precision not null

);

create index `trans_constitute_forcustomer_table_FRelateBrID` on `trans_constitute_forcustomer_table` (
	`frelatebrid`
);



CREATE TABLE `trans_daily_invfordep_table` (	
	`frelatebrid` bigint not null,
	`fdeptid` varchar(11) ,
	`trash_is` varchar(1) not null,
	`input` NUMERIC(18,1) ,
	`output` NUMERIC(18,1) ,
	`fdctime` varchar(10) 

);

create index `trans_daily_invfordep_table_FRelateBrID` on `trans_daily_invfordep_table` (
	`frelatebrid`
);



CREATE TABLE `trans_daily_sel_table` (	
	`frelatebrid` bigint not null,
	`fitemid` bytea ,
	`total_weight` NUMERIC(18,1) ,
	`total_price` NUMERIC(19,2) ,
	`count_order` bigint not null,
	`fdate` varchar(24) 

);

create index `trans_daily_sel_table_FRelateBrID` on `trans_daily_sel_table` (
	`frelatebrid`
);



CREATE TABLE `trans_daily_sor_table` (	
	`frelatebrid` bigint not null,
	`finterid` varchar(11) ,
	`fdate` varchar(24) ,
	`fsupplyid` varchar(11) ,
	`fbusiness` varchar(11) ,
	`fdeptid` bigint not null,
	`fempid` bigint ,
	`fpostyle` varchar(11) ,
	`fpoprecent` varchar(11) ,
	`profit` NUMERIC(20,3) ,
	`weight` NUMERIC ,
	`transport_pay` NUMERIC(20,3) ,
	`classify_pay` NUMERIC(20,3) ,
	`material_pay` NUMERIC(20,3) ,
	`total_pay` NUMERIC 

);

create index `trans_daily_sor_table_FRelateBrID` on `trans_daily_sor_table` (
	`frelatebrid`
);



CREATE TABLE `trans_daily_wh_profit_table` (	
	`frelatebrid` bigint not null,
	`ffeeid` varchar(50) not null,
	`ffeetype` varchar(3) ,
	`ffeeperson` varchar(50) not null,
	`ffeeamount` NUMERIC(19,2) ,
	`ffeebaseamount` char(1) not null,
	`ftaxrate` char(1) not null,
	`fbasetax` char(1) not null,
	`fbasetaxamount` char(1) not null,
	`fpriceref` char(1) not null,
	`ffeetime` varchar(10) 

);

create index `trans_daily_wh_profit_table_FRelateBrID` on `trans_daily_wh_profit_table` (
	`frelatebrid`
);



CREATE TABLE `trans_fee_table` (	
	`finterid` bigint not null,
	`ftrantype` varchar(3) ,
	`ffeesence` varchar(2) ,
	`fentryid` bigint ,
	`ffeeid` varchar(50) ,
	`ffeetype` varchar(8) ,
	`ffeeperson` varchar(50) ,
	`ffeeexplain` varchar(255) ,
	`ffeeamount` double precision ,
	`ffeebaseamount` char(1) ,
	`ftaxrate` char(1) ,
	`fbasetax` char(1) ,
	`fbasetaxamount` char(1) ,
	`fpriceref` char(1) ,
	`ffeetime` varchar(24) ,
	`red_ink_time` timestamp without time zone ,
	`is_hedge` int ,
	`revise_state` int 

);

create index `trans_fee_table_FInterID` on `trans_fee_table` (
	`finterid`
);



CREATE TABLE `trans_fee_table_copy` (	
	`finterid` bigint not null,
	`ftrantype` varchar(3) ,
	`ffeesence` varchar(2) ,
	`fentryid` bigint ,
	`ffeeid` varchar(50) ,
	`ffeetype` varchar(8) ,
	`ffeeperson` varchar(50) ,
	`ffeeexplain` varchar(255) ,
	`ffeeamount` double precision ,
	`ffeebaseamount` char(1) ,
	`ftaxrate` char(1) ,
	`fbasetax` char(1) ,
	`fbasetaxamount` char(1) ,
	`fpriceref` char(1) ,
	`ffeetime` varchar(24) ,
	`revise_state` int 

);

create index `trans_fee_table_copy_FInterID` on `trans_fee_table_copy` (
	`finterid`
);



CREATE TABLE `trans_forcustomer_table` (	
	`frelatebrid` bigint not null,
	`fsupplyid` bigint ,
	`fbusiness` varchar(11) ,
	`total_weight` NUMERIC(18,1) ,
	`total_profit` NUMERIC(19,2) ,
	`trash_weight` NUMERIC ,
	`carbon_parmtal` NUMERIC(20,3) ,
	`fdate` varchar(10) 

);

create index `trans_forcustomer_table_FRelateBrID` on `trans_forcustomer_table` (
	`frelatebrid`
);



CREATE TABLE `trans_log_table` (	
	`finterid` bigint not null,
	`ftrantype` varchar(3) not null,
	`tcreate` bigint ,
	`tcreateperson` bigint ,
	`tallotover` varchar(10) ,
	`tallotperson` varchar(20) ,
	`tallot` varchar(20) ,
	`tgetorderover` varchar(10) ,
	`tgetorderperson` varchar(20) ,
	`tgetorder` varchar(20) ,
	`tmaterialover` varchar(10) ,
	`tmaterialperson` varchar(20) ,
	`tmaterial` varchar(20) ,
	`tpurchaseover` varchar(10) ,
	`tpurchaseperson` varchar(10) ,
	`tpurchase` varchar(10) ,
	`tpayover` varchar(10) ,
	`tpayperson` varchar(10) ,
	`tpay` varchar(10) ,
	`tchangeover` varchar(10) ,
	`tchangeperson` varchar(20) ,
	`tchange` varchar(20) ,
	`texpenseover` varchar(10) ,
	`texpenseperson` varchar(10) ,
	`texpense` varchar(10) ,
	`tsortover` varchar(10) ,
	`tsortperson` varchar(10) ,
	`tsort` varchar(10) ,
	`tallowover` varchar(10) ,
	`tallowperson` varchar(20) ,
	`tallow` varchar(20) ,
	`tcheckover` varchar(10) ,
	`tcheckperson` varchar(10) ,
	`tcheck` varchar(10) ,
	`state` varchar(28) not null

);

create index `trans_log_table_FInterID_FTranType` on `trans_log_table` (
	`finterid`,
	`ftrantype`
);



CREATE TABLE `trans_main_table` (	
	`frelatebrid` bigint not null,
	`finterid` bigint not null,
	`ftrantype` varchar(3) not null,
	`fdate` varchar(24) ,
	`date` date ,
	`ftrainnum` varchar(10) ,
	`fbillno` varchar(50) not null,
	`fsupplyid` bigint ,
	`fbusiness` varchar(11) ,
	`fdcstockid` varchar(12) ,
	`fscstockid` varchar(12) ,
	`fcancellation` varchar(3) not null,
	`frob` char(1) not null,
	`fcorrent` varchar(1) not null,
	`fstatus` bigint not null,
	`fupstockwhensave` varchar(1) ,
	`fexplanation` varchar(100) not null,
	`fdeptid` bigint not null,
	`fempid` bigint ,
	`fcheckerid` varchar(10) ,
	`fcheckdate` varchar(24) not null,
	`ffmanagerid` bigint ,
	`fsmanagerid` bigint ,
	`fbillerid` bigint ,
	`fcurrencyid` varchar(1) not null,
	`fnowstate` varchar(28) not null,
	`fsalestyle` varchar(1) ,
	`fpostyle` varchar(11) ,
	`fpoprecent` varchar(11) ,
	`talfqty` NUMERIC(18,1) ,
	`talfamount` NUMERIC(19,2) ,
	`talfrist` NUMERIC ,
	`talsecond` NUMERIC ,
	`talthird` NUMERIC ,
	`talforth` NUMERIC ,
	`talfeefifth` decimal(10,3) ,
	`account_year` int not null,
	`account_month` int not null,
	`account_state` int not null,
	`is_hedge` int not null,
	`red_ink_time` timestamp without time zone 

);

create index `trans_main_table_Date_FTranType_FSaleStyle_FCancellation_FCorrent` on `trans_main_table` (
	`date`,
	`ftrantype`,
	`fsalestyle`,
	`fcancellation`,
	`fcorrent`
);
create index `trans_main_table_FRelateBrID_FTranType_FDCStockID` on `trans_main_table` (
	`frelatebrid`,
	`ftrantype`,
	`fdcstockid`
);
create index `trans_main_table_FBillNo_FTranType` on `trans_main_table` (
	`fbillno`,
	`ftrantype`
);
create index `trans_main_table_FInterID` on `trans_main_table` (
	`finterid`
);
create index `trans_main_table_FEmpID_Date` on `trans_main_table` (
	`fempid`,
	`date`
);
create index `trans_main_table_IDX_FInterID_FTranType_FSalesStyle_FCancellation` on `trans_main_table` (
	`finterid`,
	`ftrantype`,
	`fsalestyle`,
	`fcancellation`
);
create index `trans_main_table_IDX_FTranType_FCancellation` on `trans_main_table` (
	`ftrantype`,
	`fcancellation`
);
create index `trans_main_table_IDX_FTranType_FinterID` on `trans_main_table` (
	`finterid`,
	`ftrantype`,
	`fcancellation`,
	`fdcstockid`
);
create index `trans_main_table_IDX_FCancellation` on `trans_main_table` (
	`finterid`,
	`ftrantype`
);
create index `trans_main_table_IDX_REPORT` on `trans_main_table` (
	`frelatebrid`,
	`fbillno`,
	`fcancellation`,
	`fsalestyle`,
	`fsupplyid`,
	`fempid`
);



CREATE TABLE `trans_main_table_bak` (	
	`frelatebrid` bigint not null,
	`finterid` bigint not null,
	`ftrantype` varchar(3) not null,
	`fdate` varchar(24) ,
	`date` date ,
	`ftrainnum` varchar(10) ,
	`fbillno` varchar(50) not null,
	`fsupplyid` bigint ,
	`fbusiness` varchar(11) ,
	`fdcstockid` varchar(12) ,
	`fscstockid` varchar(12) ,
	`fcancellation` varchar(3) not null,
	`frob` char(1) not null,
	`fcorrent` varchar(1) not null,
	`fstatus` bigint not null,
	`fupstockwhensave` varchar(1) ,
	`fexplanation` varchar(100) not null,
	`fdeptid` bigint not null,
	`fempid` bigint ,
	`fcheckerid` varchar(10) ,
	`fcheckdate` varchar(24) not null,
	`ffmanagerid` bigint ,
	`fsmanagerid` bigint ,
	`fbillerid` bigint ,
	`fcurrencyid` varchar(1) not null,
	`fnowstate` varchar(28) not null,
	`fsalestyle` varchar(1) ,
	`fpostyle` varchar(11) ,
	`fpoprecent` varchar(11) ,
	`talfqty` NUMERIC(18,1) ,
	`talfamount` NUMERIC(19,2) ,
	`talfrist` NUMERIC ,
	`talsecond` NUMERIC ,
	`talthird` NUMERIC ,
	`talforth` NUMERIC ,
	`talfeefifth` decimal(10,3) ,
	`account_year` int not null,
	`account_month` int not null,
	`account_state` int not null,
	`is_hedge` int not null,
	`red_ink_time` timestamp without time zone 

);

create index `trans_main_table_bak_Date_FTranType_FSaleStyle_FCancellation_FCorrent` on `trans_main_table_bak` (
	`date`,
	`ftrantype`,
	`fsalestyle`,
	`fcancellation`,
	`fcorrent`
);
create index `trans_main_table_bak_FRelateBrID_FTranType_FDCStockID` on `trans_main_table_bak` (
	`frelatebrid`,
	`ftrantype`,
	`fdcstockid`
);
create index `trans_main_table_bak_FBillNo_FTranType` on `trans_main_table_bak` (
	`fbillno`,
	`ftrantype`
);
create index `trans_main_table_bak_FInterID` on `trans_main_table_bak` (
	`finterid`
);
create index `trans_main_table_bak_FEmpID_Date` on `trans_main_table_bak` (
	`fempid`,
	`date`
);
create index `trans_main_table_bak_IDX_FInterID_FTranType_FSalesStyle_FCancellation` on `trans_main_table_bak` (
	`finterid`,
	`ftrantype`,
	`fsalestyle`,
	`fcancellation`
);
create index `trans_main_table_bak_IDX_FTranType_FCancellation` on `trans_main_table_bak` (
	`ftrantype`,
	`fcancellation`
);



CREATE TABLE `trans_materiel_table` (	
	`finterid` bigint not null,
	`ftrantype` varchar(3) ,
	`fentryid` bigint ,
	`fmaterielid` bigint ,
	`fusecount` bigint ,
	`fprice` NUMERIC(19,2) ,
	`fmeterielamount` NUMERIC(19,2) ,
	`fmeterieltime` bigint ,
	`red_ink_time` timestamp without time zone ,
	`is_hedge` bigint ,
	`revise_state` int 

);

create index `trans_materiel_table_FInterID` on `trans_materiel_table` (
	`finterid`
);



CREATE TABLE `trans_month_invfordep_table` (	
	`frelatebrid` bigint not null,
	`fdeptid` varchar(11) ,
	`trash_is` varchar(1) not null,
	`input` NUMERIC(18,1) ,
	`output` NUMERIC(18,1) ,
	`fdctime` varchar(10) 

);




CREATE TABLE `trans_month_sel_rank_table` (	
	`frelatebrid` bigint not null,
	`fitemid` bigint ,
	`total_weight` NUMERIC(18,1) ,
	`total_price` NUMERIC(19,2) ,
	`fdate` varchar(10) 

);




CREATE TABLE `trans_month_sel_table` (	
	`frelatebrid` bigint not null,
	`fitemid` bytea ,
	`total_weight` NUMERIC(18,1) ,
	`total_price` NUMERIC(19,2) ,
	`count_order` bigint not null,
	`fdate` varchar(10) 

);




CREATE TABLE `trans_month_sor_table` (	
	`frelatebrid` bigint not null,
	`finterid` varchar(11) ,
	`fdate` varchar(24) ,
	`fsupplyid` varchar(11) ,
	`fbusiness` varchar(11) ,
	`fdeptid` bigint not null,
	`fempid` bigint ,
	`fpostyle` varchar(11) ,
	`fpoprecent` varchar(11) ,
	`profit` NUMERIC(20,3) ,
	`weight` NUMERIC ,
	`transport_pay` NUMERIC(20,3) ,
	`classify_pay` NUMERIC(20,3) ,
	`material_pay` NUMERIC(20,3) ,
	`total_pay` NUMERIC 

);

create index `trans_month_sor_table_FInterID` on `trans_month_sor_table` (
	`finterid`
);



CREATE TABLE `trans_month_wh_profit_table` (	
	`frelatebrid` bigint not null,
	`ffeeid` varchar(50) not null,
	`ffeetype` varchar(3) ,
	`ffeeperson` varchar(50) not null,
	`ffeeamount` NUMERIC(19,2) ,
	`ffeebaseamount` char(1) not null,
	`ftaxrate` char(1) not null,
	`fbasetax` char(1) not null,
	`fbasetaxamount` char(1) not null,
	`fpriceref` char(1) not null,
	`ffeetime` varchar(10) 

);




CREATE TABLE `trans_total_cargo_table` (	
	`finterid` bigint not null,
	`ftrantype` varchar(3) not null,
	`fqtytotal` NUMERIC ,
	`famounttotal` NUMERIC(19,2) ,
	`fsourceinterid` varchar(11) ,
	`fsourcetrantype` varchar(3) not null

);




CREATE TABLE `trans_total_fee_table` (	
	`finterid` bigint not null,
	`ftrantype` varchar(3) not null,
	`customerprofit` varchar(19) not null,
	`otherprofit` varchar(19) not null,
	`pickfee` varchar(19) not null,
	`carfee` varchar(19) not null,
	`manfee` varchar(19) not null,
	`otherreturnfee` varchar(19) not null,
	`sortfee` varchar(19) not null,
	`materielfee` varchar(19) not null,
	`othersortfee` varchar(19) not null,
	`sellprofit` varchar(19) not null,
	`sellfee` varchar(19) not null

);




CREATE TABLE `trans_valid_purchase_table` (	
	`frelatebrid` bigint not null,
	`finterid` bigint not null,
	`fdate` varchar(10) ,
	`fbillno` varchar(50) not null,
	`fsupplyid` bigint ,
	`fbusiness` varchar(11) ,
	`fempid` bigint ,
	`fsalestyle` varchar(1) ,
	`fcancellation` varchar(3) not null

);




CREATE TABLE `uct_accumulate_wall_report` (	
	`id` bigint not null,
	`adcode` bigint not null,
	`weight` decimal(13,2) not null,
	`availability` decimal(5,2) not null,
	`rubbish` decimal(12,2) not null,
	`rdf` decimal(12,2) not null,
	`carbon` decimal(12,2) not null,
	`box` bigint not null,
	`customer_num` bigint not null,
	constraint uct_accumulate_wall_report_pkey primary key ( id )
);

alter table uct_accumulate_wall_report alter column id add auto_increment;




CREATE TABLE `uct_actual_add_order` (	
	`actual_log_id` bigint not null,
	`order_id` varchar(50) not null,
	`admin_id` bigint not null,
	`customer_id` bigint not null,
	`order_num` varchar(50) not null,
	`selldate` date not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_actual_add_order_pkey primary key ( actual_log_id ,order_id )
);




CREATE TABLE `uct_actual_tag` (	
	`tag_name` varchar(50) not null,
	`tag_text` varchar(50) not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_actual_tag_pkey primary key ( tag_name )
);




CREATE TABLE `uct_adcode` (	
	`id` bigint not null,
	`name` varchar(100) not null,
	`adcode` bigint not null,
	constraint uct_adcode_pkey primary key ( id )
);

alter table uct_adcode alter column id add auto_increment;

create index `uct_adcode_name_adcode` on `uct_adcode` (
	`name`,
	`adcode`
);



CREATE TABLE `uct_admin` (	
	`id` bigint not null,
	`branch_id` bigint ,
	`ec_userid` bigint ,
	`crmid` bigint ,
	`ec_linkid` varchar(100) ,
	`staff_accid` varchar(100) ,
	`cus_accid` varchar(100) ,
	`link_accid` varchar(100) ,
	`old_cus_accid` varchar(100) ,
	`old_link_accid` varchar(100) ,
	`userid` varchar(25) ,
	`wechat_id` varchar(50) ,
	`username` varchar(20) not null,
	`nickname` varchar(50) not null,
	`password` varchar(32) not null,
	`salt` varchar(30) not null,
	`avatar` varchar(100) not null,
	`mobile` varchar(30) ,
	`email` varchar(100) not null,
	`loginfailure` int not null,
	`logintime` bigint not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`token` varchar(59) not null,
	`last_appletid` varchar(50) ,
	`status` varchar(30) not null,
	constraint uct_admin_pkey primary key ( id )
);

alter table uct_admin alter column id add auto_increment;

alter table `uct_admin` add constraint `uct_admin_username` unique (
	`username`
);



CREATE TABLE `uct_admin_bak` (	
	`id` bigint not null,
	`branch_id` bigint ,
	`crmid` bigint ,
	`staff_accid` varchar(100) ,
	`cus_accid` varchar(100) ,
	`link_accid` varchar(100) ,
	`userid` varchar(25) ,
	`wechat_id` varchar(50) ,
	`username` varchar(20) not null,
	`nickname` varchar(50) not null,
	`password` varchar(32) not null,
	`salt` varchar(30) not null,
	`avatar` varchar(100) not null,
	`mobile` varchar(30) ,
	`email` varchar(100) not null,
	`loginfailure` int not null,
	`logintime` bigint not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`token` varchar(59) not null,
	`last_appletid` varchar(50) ,
	`status` varchar(30) not null,
	constraint uct_admin_bak_pkey primary key ( id )
);

alter table uct_admin_bak alter column id add auto_increment;

alter table `uct_admin_bak` add constraint `uct_admin_bak_username` unique (
	`username`
);



CREATE TABLE `uct_admin_customer_mapping` (	
	`admin_id` bigint not null,
	`up_customer_ids` bytea not null,
	`down_customer_ids` bytea not null,
	constraint uct_admin_customer_mapping_pkey primary key ( admin_id )
);

alter table uct_admin_customer_mapping alter column admin_id add auto_increment;




CREATE TABLE `uct_admin_customer_mapping_bak` (	
	`admin_id` bigint not null,
	`up_customer_ids` varchar(500) not null,
	`down_customer_ids` varchar(500) not null,
	constraint uct_admin_customer_mapping_bak_pkey primary key ( admin_id )
);

alter table uct_admin_customer_mapping_bak alter column admin_id add auto_increment;




CREATE TABLE `uct_admin_log` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`username` varchar(30) not null,
	`url` varchar(100) not null,
	`title` varchar(100) not null,
	`content` bytea not null,
	`ip` varchar(50) not null,
	`useragent` varchar(255) not null,
	`createtime` bigint not null,
	constraint uct_admin_log_pkey primary key ( id )
);

alter table uct_admin_log alter column id add auto_increment;

create index `uct_admin_log_name` on `uct_admin_log` (
	`username`
);



CREATE TABLE `uct_agent_audit` (	
	`id` bigint not null,
	`name` varchar(30) not null,
	`mobile` varchar(12) not null,
	`email` varchar(50) not null,
	`branch_id` bigint ,
	`role_id` bigint ,
	`customer_id` bigint ,
	`status` int not null,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_agent_audit_pkey primary key ( id )
);

alter table uct_agent_audit alter column id add auto_increment;




CREATE TABLE `uct_apply_for_material_temp` (	
	`id` bigint not null,
	`finterid` bigint ,
	`order_id` varchar(20) not null,
	`meta_id` bigint ,
	`number` bigint not null,
	`meta_price` decimal(10,2) ,
	`meta_amount` decimal(10,2) ,
	`ware_id` bigint ,
	`state` int ,
	`create_time` timestamp without time zone not null,
	`update_time` timestamp without time zone not null,
	constraint uct_apply_for_material_temp_pkey primary key ( id )
);

alter table uct_apply_for_material_temp alter column id add auto_increment;




CREATE TABLE `uct_apply_for_order_temp` (	
	`id` bigint not null,
	`finterid` bigint ,
	`order_id` varchar(20) ,
	`ftranname` varchar(20) ,
	`ftrantype` varchar(20) ,
	`metaname` varchar(30) ,
	`metaid` bigint ,
	`net_weight` decimal(10,2) ,
	`price` decimal(10,2) ,
	`state` int ,
	`create_time` timestamp without time zone not null,
	`update_time` timestamp without time zone not null,
	constraint uct_apply_for_order_temp_pkey primary key ( id )
);

alter table uct_apply_for_order_temp alter column id add auto_increment;




CREATE TABLE `uct_appointments` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`mobile` varchar(12) not null,
	`type` int not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_appointments_pkey primary key ( id )
);

alter table uct_appointments alter column id add auto_increment;




CREATE TABLE `uct_area` (	
	`id` bigint not null,
	`pid` bigint ,
	`shortname` varchar(100) ,
	`name` varchar(100) ,
	`mergename` varchar(255) ,
	`level` int ,
	`pinyin` varchar(100) ,
	`code` varchar(100) ,
	`zip` varchar(100) ,
	`first` varchar(50) ,
	`lng` varchar(100) ,
	`lat` varchar(100) ,
	constraint uct_area_pkey primary key ( id )
);

alter table uct_area alter column id add auto_increment;

create index `uct_area_pid` on `uct_area` (
	`pid`
);



CREATE TABLE `uct_attachment` (	
	`id` bigint not null,
	`url` varchar(255) not null,
	`imagewidth` varchar(30) not null,
	`imageheight` varchar(30) not null,
	`imagetype` varchar(30) not null,
	`imageframes` bigint not null,
	`filesize` bigint not null,
	`mimetype` varchar(100) not null,
	`extparam` varchar(255) not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`uploadtime` bigint not null,
	`storage` varchar(256) not null,
	`sha1` varchar(40) not null,
	constraint uct_attachment_pkey primary key ( id )
);

alter table uct_attachment alter column id add auto_increment;




CREATE TABLE `uct_auth_group` (	
	`id` bigint not null,
	`pid` bigint not null,
	`name` varchar(100) not null,
	`rules` bytea not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`status` varchar(30) not null,
	constraint uct_auth_group_pkey primary key ( id )
);

alter table uct_auth_group alter column id add auto_increment;




CREATE TABLE `uct_auth_group_access` (	
	`uid` bigint not null,
	`group_id` bigint not null

);

alter table `uct_auth_group_access` add constraint `uct_auth_group_access_uid_group_id` unique (
	`uid`,
	`group_id`
);
create index `uct_auth_group_access_uid` on `uct_auth_group_access` (
	`uid`
);
create index `uct_auth_group_access_group_id` on `uct_auth_group_access` (
	`group_id`
);



CREATE TABLE `uct_auth_group_bak` (	
	`id` bigint not null,
	`pid` bigint not null,
	`name` varchar(100) not null,
	`rules` bytea not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`status` varchar(30) not null,
	constraint uct_auth_group_bak_pkey primary key ( id )
);

alter table uct_auth_group_bak alter column id add auto_increment;




CREATE TABLE `uct_auth_rule` (	
	`id` bigint not null,
	`type` varchar(256) not null,
	`pid` bigint not null,
	`name` varchar(100) not null,
	`title` varchar(50) not null,
	`icon` varchar(50) not null,
	`ant_url` varchar(50) not null,
	`ant_icon` varchar(50) not null,
	`client_icon` varchar(100) not null,
	`condition` varchar(255) not null,
	`message` varchar(50) not null,
	`remark` varchar(255) not null,
	`ismenu` int not null,
	`isclient` int not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`weigh` bigint not null,
	`status` varchar(30) not null,
	constraint uct_auth_rule_pkey primary key ( id )
);

alter table uct_auth_rule alter column id add auto_increment;

create index `uct_auth_rule_pid` on `uct_auth_rule` (
	`pid`
);
create index `uct_auth_rule_weigh` on `uct_auth_rule` (
	`weigh`
);



CREATE TABLE `uct_auth_rule_bak` (	
	`id` bigint not null,
	`type` varchar(256) not null,
	`pid` bigint not null,
	`name` varchar(100) not null,
	`title` varchar(50) not null,
	`icon` varchar(50) not null,
	`ant_url` varchar(50) not null,
	`ant_icon` varchar(50) not null,
	`client_icon` varchar(100) not null,
	`condition` varchar(255) not null,
	`message` varchar(50) not null,
	`remark` varchar(255) not null,
	`ismenu` int not null,
	`isclient` int not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`weigh` bigint not null,
	`status` varchar(30) not null,
	constraint uct_auth_rule_bak_pkey primary key ( id )
);

alter table uct_auth_rule_bak alter column id add auto_increment;

create index `uct_auth_rule_bak_pid` on `uct_auth_rule_bak` (
	`pid`
);
create index `uct_auth_rule_bak_weigh` on `uct_auth_rule_bak` (
	`weigh`
);



CREATE TABLE `uct_auxy_material_warehouse` (	
	`id` bigint not null,
	`ware_id` bigint ,
	`mate_order_id` varchar(32) not null,
	`apply_id` bigint not null,
	`receive_id` bigint ,
	`mate_type` varchar(20) not null,
	`mate_state` varchar(30) not null,
	`memo` varchar(255) ,
	`create_time` timestamp without time zone not null,
	`update_time` timestamp without time zone not null,
	constraint uct_auxy_material_warehouse_pkey primary key ( id )
);

alter table uct_auxy_material_warehouse alter column id add auto_increment;




CREATE TABLE `uct_auxy_material_warehouse_detail` (	
	`id` bigint not null,
	`main_id` bigint not null,
	`material_id` bigint not null,
	`material_num` bigint not null,
	`create_time` timestamp without time zone not null,
	`update_time` timestamp without time zone not null,
	constraint uct_auxy_material_warehouse_detail_pkey primary key ( id )
);

alter table uct_auxy_material_warehouse_detail alter column id add auto_increment;




CREATE TABLE `uct_auxy_material_warehouse_log` (	
	`id` bigint not null,
	`ware_id` bigint ,
	`admin_id` bigint not null,
	`mate_order_id` varchar(32) not null,
	`mate_type` varchar(32) ,
	`mate_state` varchar(32) ,
	`content` varchar(500) not null,
	`create_time` timestamp without time zone not null,
	constraint uct_auxy_material_warehouse_log_pkey primary key ( id )
);

alter table uct_auxy_material_warehouse_log alter column id add auto_increment;




CREATE TABLE `uct_auxy_material_warehouse_query` (	
	`id` bigint not null,
	`ware_id` bigint not null,
	`mate_order_id` varchar(32) not null,
	`apply_id` bigint not null,
	`receive_id` bigint ,
	`mate_type` varchar(32) not null,
	`mate_state` varchar(32) not null,
	`material_id` bigint not null,
	`material_name` varchar(32) ,
	`material_num` bigint not null,
	`dispose_time` bigint ,
	`create_time` timestamp without time zone not null,
	`update_time` timestamp without time zone not null,
	constraint uct_auxy_material_warehouse_query_pkey primary key ( id )
);

alter table uct_auxy_material_warehouse_query alter column id add auto_increment;




CREATE TABLE `uct_bas_device` (	
	`station_id` varchar(20) not null,
	`item_no` bigint not null,
	`device_id` varchar(20) ,
	`device_tty` varchar(255) ,
	`device_use` varchar(20) ,
	`device_label` varchar(50) ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_bas_device_pkey primary key ( station_id ,item_no )
);




CREATE TABLE `uct_bas_line` (	
	`id` bigint not null,
	`line_id` varchar(20) not null,
	`branch_id` bigint ,
	`storage_id` bigint ,
	`name` varchar(255) ,
	`leader` bigint ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	`auto_confirm_flag` bigint ,
	`auto_priority_flag` int ,
	constraint uct_bas_line_pkey primary key ( id )
);

alter table uct_bas_line alter column id add auto_increment;




CREATE TABLE `uct_bas_logistics_equipment` (	
	`id` bigint not null,
	`code` varchar(20) ,
	`name` varchar(50) ,
	`category` varchar(20) ,
	`type` varchar(20) ,
	`tare` decimal(6,2) ,
	`weight_unit` varchar(5) not null,
	`volume` decimal(6,2) ,
	`volume_unit` varchar(5) not null,
	`capacity` decimal(6,2) ,
	`lenght` decimal(6,2) ,
	`width` decimal(6,2) ,
	`height` decimal(6,2) ,
	`length_unit` varchar(5) not null,
	`stackable_qty` bigint ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_bas_logistics_equipment_pkey primary key ( id )
);

alter table uct_bas_logistics_equipment alter column id add auto_increment;




CREATE TABLE `uct_bas_station` (	
	`id` bigint not null,
	`station_id` varchar(20) not null,
	`station_type` varchar(20) ,
	`line_id` varchar(20) ,
	`max_mount_num` bigint ,
	`status` varchar(20) ,
	`serail_number` varchar(20) ,
	`model` varchar(255) ,
	`screen_direction` varchar(20) not null,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_bas_station_pkey primary key ( id )
);

alter table uct_bas_station alter column id add auto_increment;




CREATE TABLE `uct_branch` (	
	`id` bigint not null,
	`ec_id` bigint ,
	`branch_code` varchar(20) ,
	`adcode` bigint ,
	`ec_customer_id` bigint ,
	`accid` varchar(20) ,
	`setting_key` bigint ,
	`name` varchar(50) ,
	`print_title` varchar(100) ,
	`company_name` varchar(100) ,
	`position` bytea ,
	`branch_detail` bytea ,
	`branch_img_url` varchar(255) ,
	`switch` int not null,
	`receivable_switch` int not null,
	`presell_switch` int not null,
	`actual_switch` int not null,
	`sign_switch` int not null,
	`sorting_switch` int not null,
	`centre_switch` int not null,
	`centre_warehouse_id` int ,
	`centre_branch_id` int ,
	`sorting_unit_cargo_price` double precision not null,
	`weigh_unit_cargo_price` double precision not null,
	`sorting_unit_labor_price` double precision not null,
	`weigh_unit_labor_price` double precision not null,
	`standard_price` decimal(5,2) not null,
	`overdue_time` bigint not null,
	`evaluate_value` double precision not null,
	`cargo_commission_list` varchar(200) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_branch_pkey primary key ( id )
);

alter table uct_branch alter column id add auto_increment;




CREATE TABLE `uct_branch_related_down` (	
	`id` int not null,
	`branch_id` bigint not null,
	`customer_id` bigint not null,
	`prod_type` varchar(20) ,
	`prod_name` varchar(50) ,
	constraint uct_branch_related_down_pkey primary key ( id )
);

alter table uct_branch_related_down alter column id add auto_increment;




CREATE TABLE `uct_cate_account` (	
	`id` bigint not null,
	`account_id` varchar(50) ,
	`branch_id` bigint ,
	`warehouse_id` bigint ,
	`cate_id` bigint ,
	`admin_id` bigint ,
	`before_account_num` double precision not null,
	`account_num` double precision not null,
	`today_stock` double precision not null,
	`account_reason` bytea not null,
	`createtime` bigint ,
	constraint uct_cate_account_pkey primary key ( id )
);

alter table uct_cate_account alter column id add auto_increment;

create index `uct_cate_account_uct_cate_account_idx_001` on `uct_cate_account` (
	`createtime`
);
create index `uct_cate_account_uct_cate_account_idx_002` on `uct_cate_account` (
	`cate_id`,
	`warehouse_id`,
	`branch_id`,
	`createtime`
);



CREATE TABLE `uct_category` (	
	`id` bigint not null,
	`pid` bigint not null,
	`type` varchar(30) not null,
	`name` varchar(30) not null,
	`nickname` varchar(50) not null,
	`flag` varchar(256) not null,
	`image` varchar(100) not null,
	`keywords` varchar(255) not null,
	`description` varchar(255) not null,
	`diyname` varchar(30) not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`weigh` bigint not null,
	`status` varchar(30) not null,
	constraint uct_category_pkey primary key ( id )
);

alter table uct_category alter column id add auto_increment;

create index `uct_category_weigh` on `uct_category` (
	`weigh`,
	`id`
);
create index `uct_category_pid` on `uct_category` (
	`pid`
);



CREATE TABLE `uct_centre_storage` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`centre_branch_id` bigint not null,
	`centre_warehouse_id` bigint not null,
	`warehouse_unit_cost` double precision not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_centre_storage_pkey primary key ( id )
);

alter table uct_centre_storage alter column id add auto_increment;




CREATE TABLE `uct_client_banner` (	
	`id` bigint not null,
	`name` varchar(255) not null,
	`describe` bytea ,
	`img` varchar(255) ,
	`type` varchar(50) not null,
	`skip` bigint not null,
	`priority` bigint not null,
	`status` varchar(50) not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_client_banner_pkey primary key ( id )
);

alter table uct_client_banner alter column id add auto_increment;




CREATE TABLE `uct_client_feedback` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`theme` int not null,
	`remove_fast_star` int not null,
	`remove_level_star` int not null,
	`service_attitude_star` int not null,
	`content` varchar(500) not null,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_client_feedback_pkey primary key ( id )
);

alter table uct_client_feedback alter column id add auto_increment;




CREATE TABLE `uct_client_rule` (	
	`id` bigint not null,
	`pid` bigint not null,
	`name` varchar(100) not null,
	`path` varchar(200) not null,
	`icon` varchar(255) not null,
	`weigh` bigint not null,
	`message` varchar(30) not null,
	`status` varchar(30) not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_client_rule_pkey primary key ( id )
);

alter table uct_client_rule alter column id add auto_increment;




CREATE TABLE `uct_common_cate` (	
	`id` bigint not null,
	`branch_id` bigint ,
	`cate_id` bigint ,
	`cate_name` varchar(50) ,
	`src_type` int ,
	`weight` bigint ,
	`frequency` bigint ,
	`date_unix` bigint ,
	constraint uct_common_cate_pkey primary key ( id )
);

alter table uct_common_cate alter column id add auto_increment;




CREATE TABLE `uct_config` (	
	`id` bigint not null,
	`name` varchar(30) not null,
	`group` varchar(30) not null,
	`title` varchar(100) not null,
	`tip` varchar(100) not null,
	`type` varchar(30) not null,
	`value` bytea not null,
	`content` bytea not null,
	`rule` varchar(100) not null,
	`extend` varchar(255) not null,
	constraint uct_config_pkey primary key ( id )
);

alter table uct_config alter column id add auto_increment;

alter table `uct_config` add constraint `uct_config_name` unique (
	`name`
);



CREATE TABLE `uct_crm_erp_map` (	
	`id` bigint not null,
	`crm` varchar(10) not null,
	`type` varchar(5) not null,
	`field_map` bytea not null,
	`crm_to_erp` bytea not null,
	`erp_to_crm` bytea not null,
	`field_map_link` bytea not null,
	`crm_to_erp_link` bytea not null,
	`erp_to_crm_link` bytea not null,
	constraint uct_crm_erp_map_pkey primary key ( id )
);

alter table uct_crm_erp_map alter column id add auto_increment;




CREATE TABLE `uct_crontab` (	
	`id` bigint not null,
	`type` varchar(10) not null,
	`title` varchar(100) not null,
	`content` bytea not null,
	`schedule` varchar(100) not null,
	`sleep` int not null,
	`maximums` bigint not null,
	`executes` bigint not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`begintime` bigint not null,
	`endtime` bigint not null,
	`executetime` bigint not null,
	`weigh` bigint not null,
	`status` varchar(256) not null,
	constraint uct_crontab_pkey primary key ( id )
);

alter table uct_crontab alter column id add auto_increment;




CREATE TABLE `uct_customer_account` (	
	`id` bigint not null,
	`rela_voucher_id` bigint not null,
	`rela_voucher_no` varchar(50) not null,
	`order_id` bigint not null,
	`no` varchar(50) not null,
	`audit_id` varchar(50) not null,
	`task_id` varchar(50) not null,
	`cus_id` bigint not null,
	`cus_type` varchar(10) not null,
	`branch_id` bigint not null,
	`branch_text` varchar(50) not null,
	`use` varchar(50) not null,
	`amount` NUMERIC not null,
	`status` int not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_customer_account_pkey primary key ( id )
);

alter table uct_customer_account alter column id add auto_increment;




CREATE TABLE `uct_customer_allot_history` (	
	`id` bigint not null,
	`customer_id` bigint not null,
	`before_admin_id` bigint not null,
	`admin_id` bigint not null,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_customer_allot_history_pkey primary key ( id )
);

alter table uct_customer_allot_history alter column id add auto_increment;




CREATE TABLE `uct_customer_annual_data` (	
	`id` bigint not null,
	`year` bigint not null,
	`version` varchar(20) not null,
	`customer_id` bigint not null,
	`data` json not null,
	`is_checkout` int not null,
	`share_times` int not null,
	`status` varchar(256) not null,
	`createtime` timestamp without time zone not null,
	constraint uct_customer_annual_data_pkey primary key ( id )
);

alter table uct_customer_annual_data alter column id add auto_increment;

alter table `uct_customer_annual_data` add constraint `uct_customer_annual_data_customer_id` unique (
	`customer_id`
);



CREATE TABLE `uct_customer_behave_log` (	
	`id` bigint not null,
	`customer_id` bigint ,
	`admin_id` bigint ,
	`behave_type` varchar(50) ,
	`detail` varchar(100) ,
	`createtime` timestamp without time zone not null,
	constraint uct_customer_behave_log_pkey primary key ( id )
);

alter table uct_customer_behave_log alter column id add auto_increment;




CREATE TABLE `uct_customer_materiel` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`purchase_incharge` bigint not null,
	`seller_id` bigint not null,
	`materiel_id` bigint not null,
	`name` varchar(50) not null,
	`storage_amount` bigint not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_customer_materiel_pkey primary key ( id )
);

alter table uct_customer_materiel alter column id add auto_increment;




CREATE TABLE `uct_customer_question` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`branch_id` bigint not null,
	`company_name` varchar(255) not null,
	`phone` varchar(20) not null,
	`liasion` varchar(30) not null,
	`location_name` varchar(30) not null,
	`position` varchar(255) not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	constraint uct_customer_question_pkey primary key ( id )
);

alter table uct_customer_question alter column id add auto_increment;




CREATE TABLE `uct_customer_question_grade` (	
	`id` bigint not null,
	`question_id` bigint ,
	`item1` double precision not null,
	`item2` double precision not null,
	`item3` double precision not null,
	`item4` double precision not null,
	`item5` double precision not null,
	`item6` double precision not null,
	`item7` double precision not null,
	`csi` double precision not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	constraint uct_customer_question_grade_pkey primary key ( id )
);

alter table uct_customer_question_grade alter column id add auto_increment;




CREATE TABLE `uct_customer_question_item` (	
	`id` bigint not null,
	`question_id` bigint ,
	`shipment_ask` int not null,
	`shipment_answer` int not null,
	`staff_cooperate` int not null,
	`civilized_operation` int not null,
	`customer_stipulate` int not null,
	`now_settle` int not null,
	`settle_accuracy` int not null,
	`handle_rationality` int not null,
	`receipts_timeliness` int not null,
	`report_accuracy` int not null,
	`communicate_smooth` int not null,
	`complaint_timeliness` int not null,
	`verify_track` int not null,
	`regular_visits` int not null,
	`report_to_duty` int not null,
	`working_attitude` int not null,
	`packaging_work` int not null,
	`shipshape` int not null,
	`qualifications_update` int not null,
	`assess_support` int not null,
	`emergency_container` int not null,
	`environmental_consultation` int not null,
	`extend_service` bytea ,
	`propose` bytea ,
	`createtime` bigint not null,
	constraint uct_customer_question_item_pkey primary key ( id )
);

alter table uct_customer_question_item alter column id add auto_increment;




CREATE TABLE `uct_customer_report` (	
	`id` bigint not null,
	`cus_id` bigint not null,
	`cus_name` varchar(50) not null,
	`time_label` varchar(50) not null,
	`time_dim` varchar(10) not null,
	`begin_time` bigint ,
	`end_time` bigint ,
	`group1` varchar(50) ,
	`cate_name1` varchar(100) ,
	`group2` varchar(50) ,
	`cate_name2` varchar(100) not null,
	`item_no` bigint ,
	`value1` varchar(30) not null,
	`unit1` varchar(10) ,
	`value2` varchar(30) ,
	`unit2` varchar(10) ,
	`value3` varchar(30) ,
	`unit3` varchar(10) ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_customer_report_pkey primary key ( id )
);

alter table uct_customer_report alter column id add auto_increment;




CREATE TABLE `uct_customer_report_memo` (	
	`id` bigint not null,
	`cus_id` bigint not null,
	`cus_name` varchar(50) not null,
	`time_label` varchar(50) not null,
	`time_dim` varchar(10) not null,
	`begin_time` bigint ,
	`end_time` bigint ,
	`group1` varchar(100) not null,
	`group2` varchar(100) not null,
	`cate_name2` varchar(100) not null,
	`item_no` bigint not null,
	`value1` varchar(800) not null,
	`create_at` timestamp without time zone not null,
	`updata_at` timestamp without time zone not null,
	constraint uct_customer_report_memo_pkey primary key ( id )
);

alter table uct_customer_report_memo alter column id add auto_increment;




CREATE TABLE `uct_customer_servinfo` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`name_cn` varchar(20) not null,
	`name_en` varchar(50) not null,
	`position_cn` varchar(20) not null,
	`position_en` varchar(50) not null,
	`introduce_cn` varchar(100) not null,
	`introduce_en` varchar(500) not null,
	`img` bytea ,
	constraint uct_customer_servinfo_pkey primary key ( id )
);

alter table uct_customer_servinfo alter column id add auto_increment;




CREATE TABLE `uct_day_wall_report` (	
	`id` bigint not null,
	`adcode` bigint not null,
	`weight` decimal(12,2) not null,
	`availability` decimal(5,2) not null,
	`rubbish` decimal(10,2) not null,
	`rdf` decimal(10,2) not null,
	`carbon` decimal(10,2) not null,
	`box` bigint not null,
	`customer_num` bigint not null,
	`report_date` date ,
	constraint uct_day_wall_report_pkey primary key ( id )
);

alter table uct_day_wall_report alter column id add auto_increment;

create index `uct_day_wall_report_key1` on `uct_day_wall_report` (
	`adcode`,
	`report_date`
);



CREATE TABLE `uct_dictionaries` (	
	`id` bigint not null,
	`group` varchar(50) not null,
	`code` varchar(50) not null,
	`name` varchar(50) not null,
	`create_at` timestamp without time zone not null,
	`updata_at` timestamp without time zone not null,
	constraint uct_dictionaries_pkey primary key ( id )
);

alter table uct_dictionaries alter column id add auto_increment;




CREATE TABLE `uct_economic_circle` (	
	`id` bigint not null,
	`name` varchar(30) ,
	`state` int not null,
	`create_at` timestamp without time zone not null,
	`updata_at` timestamp without time zone not null,
	constraint uct_economic_circle_pkey primary key ( id )
);

alter table uct_economic_circle alter column id add auto_increment;




CREATE TABLE `uct_economic_circle_branch` (	
	`id` bigint not null,
	`cire_id` bigint ,
	`branch_id` bigint ,
	`create_at` timestamp without time zone not null,
	`updata_at` timestamp without time zone not null,
	constraint uct_economic_circle_branch_pkey primary key ( id )
);

alter table uct_economic_circle_branch alter column id add auto_increment;




CREATE TABLE `uct_erp_tool` (	
	`id` bigint not null,
	`type` varchar(50) not null,
	`text` varchar(255) not null,
	`value` varchar(255) not null,
	`status` int not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_erp_tool_pkey primary key ( id )
);

alter table uct_erp_tool alter column id add auto_increment;




CREATE TABLE `uct_erp_tool_group` (	
	`id` bigint not null,
	`type` varchar(50) not null,
	`group_id` bigint not null,
	`rules` varchar(255) not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_erp_tool_group_pkey primary key ( id )
);

alter table uct_erp_tool_group alter column id add auto_increment;




CREATE TABLE `uct_feedback` (	
	`id` bigint not null,
	`conf_id` bigint not null,
	`feedback_content` varchar(255) not null,
	`feedback_tel` char(12) ,
	`create_time` bigint not null,
	constraint uct_feedback_pkey primary key ( id )
);

alter table uct_feedback alter column id add auto_increment;




CREATE TABLE `uct_feedback_conf` (	
	`id` bigint not null,
	`conf_name` varchar(30) not null,
	`create_time` bigint not null,
	constraint uct_feedback_conf_pkey primary key ( id )
);

alter table uct_feedback_conf alter column id add auto_increment;




CREATE TABLE `uct_finance_account` (	
	`id` bigint not null,
	`way` varchar(20) not null,
	`name` varchar(200) not null,
	`account` varchar(50) not null,
	`bank_name` varchar(200) not null,
	`title` varchar(200) not null,
	`state` varchar(200) not null,
	constraint uct_finance_account_pkey primary key ( id )
);

alter table uct_finance_account alter column id add auto_increment;




CREATE TABLE `uct_finance_applet` (	
	`id` bigint not null,
	`name` varchar(200) ,
	`appid` varchar(200) ,
	`appsecret` varchar(200) ,
	`referer_list` varchar(200) not null,
	`access_token` varchar(200) not null,
	`expires_time` bigint not null,
	constraint uct_finance_applet_pkey primary key ( id )
);

alter table uct_finance_applet alter column id add auto_increment;




CREATE TABLE `uct_hazardous_waste_admin` (	
	`id` bigint not null,
	`apt_id` varchar(50) not null,
	`page_code` varchar(20) not null,
	`page_name` varchar(30) not null,
	`cus_nickname` varchar(30) not null,
	`cus_tel` varchar(11) not null,
	`customer_id` bigint ,
	`state` varchar(50) ,
	`company_name` varchar(100) ,
	`company_contact` varchar(50) ,
	`company_address` varchar(500) ,
	`deal_time` timestamp without time zone ,
	`img_address` varchar(500) ,
	`apt_type` int ,
	`update_at` timestamp without time zone not null,
	`create_at` timestamp without time zone not null,
	constraint uct_hazardous_waste_admin_pkey primary key ( id )
);

alter table uct_hazardous_waste_admin alter column id add auto_increment;




CREATE TABLE `uct_hazardous_waste_admin_detail` (	
	`id` bigint not null,
	`main_id` bigint not null,
	`sub_type` varchar(20) not null,
	`sub_name` varchar(50) not null,
	`sub_num` bigint not null,
	`sub_unit` varchar(50) not null,
	`is_use` int not null,
	`create_time` timestamp without time zone not null,
	constraint uct_hazardous_waste_admin_detail_pkey primary key ( id )
);

alter table uct_hazardous_waste_admin_detail alter column id add auto_increment;




CREATE TABLE `uct_hazardous_waste_disposal` (	
	`id` bigint not null,
	`cus_name` varchar(50) not null,
	`goods_address` varchar(150) not null,
	`position` varchar(150) ,
	`goods_memo` varchar(255) ,
	`expect_time` int ,
	`goods_img` varchar(255) ,
	`create_at` timestamp without time zone ,
	`updata_at` timestamp without time zone ,
	constraint uct_hazardous_waste_disposal_pkey primary key ( id )
);

alter table uct_hazardous_waste_disposal alter column id add auto_increment;




CREATE TABLE `uct_hazardous_waste_env` (	
	`id` bigint not null,
	`env_type` varchar(30) ,
	`env_memo` varchar(255) ,
	`create_at` timestamp without time zone ,
	`updata_at` timestamp without time zone ,
	constraint uct_hazardous_waste_env_pkey primary key ( id )
);

alter table uct_hazardous_waste_env alter column id add auto_increment;




CREATE TABLE `uct_huke` (	
	`name` varchar(100) not null,
	`type` varchar(100) not null,
	`crm_type` varchar(100) not null,
	`appkey` varchar(100) not null,
	`appsecret` varchar(100) not null,
	`cid` varchar(100) not null,
	`status` varchar(100) not null

);




CREATE TABLE `uct_inventory_reconciliation` (	
	`id` bigint not null,
	`admin_id` bigint ,
	`nickname` varchar(50) ,
	`userid` varchar(25) ,
	`branch_id` bigint ,
	`branch_name` varchar(50) ,
	`audit_id` varchar(100) ,
	`processcode` varchar(50) ,
	`remark` varchar(200) ,
	`exam_status` varchar(10) ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_inventory_reconciliation_pkey primary key ( id )
);

alter table uct_inventory_reconciliation alter column id add auto_increment;




CREATE TABLE `uct_inventory_reconciliation_detail` (	
	`id` bigint not null,
	`main_id` bigint ,
	`cate_id` bigint ,
	`cate_name` varchar(50) ,
	`ori_stock` decimal(10,2) ,
	`cur_stock` decimal(10,2) ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_inventory_reconciliation_detail_pkey primary key ( id )
);

alter table uct_inventory_reconciliation_detail alter column id add auto_increment;




CREATE TABLE `uct_jobs_plan` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`sortage_id` varchar(100) ,
	`line_id` varchar(20) ,
	`plan_type` varchar(50) not null,
	`plan_begin_time` timestamp without time zone ,
	`plan_end_time` timestamp without time zone ,
	`plan_work_time` decimal(10,1) ,
	`relation_order_id` bigint ,
	`relation_order_num` varchar(50) ,
	`real_begin_time` timestamp without time zone ,
	`real_end_time` timestamp without time zone ,
	`real_use_time` decimal(10,1) ,
	`planner` bigint not null,
	`assign_to` bigint ,
	`status` varchar(50) ,
	`create_at` timestamp without time zone ,
	`updata_at` timestamp without time zone ,
	constraint uct_jobs_plan_pkey primary key ( id )
);

alter table uct_jobs_plan alter column id add auto_increment;




CREATE TABLE `uct_label` (	
	`label_sn` varchar(36) not null,
	`lot_num` bigint ,
	`status` bigint ,
	`order_no` varchar(32) ,
	`category_id` bigint ,
	`category_type` varchar(20) ,
	`category_name` varchar(100) ,
	`aw` bigint ,
	`nw` bigint ,
	`tw` bigint ,
	`weight_unit` varchar(10) ,
	`price` bigint ,
	`price_unit` varchar(10) ,
	`item_no` bigint ,
	`position` varchar(100) ,
	`create_user` bigint ,
	`create_time` timestamp without time zone ,
	`update_user` bigint ,
	`update_time` timestamp without time zone ,
	constraint uct_label_pkey primary key ( label_sn )
);




CREATE TABLE `uct_label_lot` (	
	`num` bigint not null,
	`begin_time` timestamp without time zone ,
	`end_time` timestamp without time zone ,
	`create_user` bigint ,
	constraint uct_label_lot_pkey primary key ( num )
);

alter table uct_label_lot alter column num add auto_increment;




CREATE TABLE `uct_main_effective_table` (	
	`fbillno` varchar(50) not null,
	`fcorrent` bigint ,
	`fdate` timestamp without time zone ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_main_effective_table_pkey primary key ( fbillno )
);

create index `uct_main_effective_table_idx_met_01` on `uct_main_effective_table` (
	`fbillno`,
	`fcorrent`,
	`fdate`
);



CREATE TABLE `uct_map` (	
	`id` bigint not null,
	`admin_id` bigint ,
	`map_trail` bytea ,
	`createtime` bigint ,
	`starttime` timestamp without time zone ,
	`endtime` timestamp without time zone ,
	`updatetime` bigint ,
	constraint uct_map_pkey primary key ( id )
);

alter table uct_map alter column id add auto_increment;




CREATE TABLE `uct_materiel` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`name` varchar(255) not null,
	`number` bigint not null,
	`purchase_price` double precision not null,
	`inside_price` double precision not null,
	`outside_price` double precision not null,
	`remark` varchar(100) ,
	`weigh` bigint not null,
	`state` varchar(256) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_materiel_pkey primary key ( id )
);

alter table uct_materiel alter column id add auto_increment;




CREATE TABLE `uct_materiel_bak` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`name` varchar(255) not null,
	`number` bigint not null,
	`purchase_price` double precision not null,
	`inside_price` double precision not null,
	`outside_price` double precision not null,
	`remark` varchar(100) ,
	`weigh` bigint not null,
	`state` varchar(256) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_materiel_bak_pkey primary key ( id )
);

alter table uct_materiel_bak alter column id add auto_increment;




CREATE TABLE `uct_materiel_log` (	
	`id` bigint not null,
	`admin_id` bigint ,
	`materiel_id` bigint not null,
	`entering_number` bigint not null,
	`number` bigint not null,
	`remark` varchar(255) not null,
	`type` int not null,
	`ip` varchar(255) not null,
	`createtime` bigint not null,
	constraint uct_materiel_log_pkey primary key ( id )
);

alter table uct_materiel_log alter column id add auto_increment;




CREATE TABLE `uct_modify_order_audit` (	
	`id` bigint not null,
	`order_id` bigint not null,
	`dd_audit_id` varchar(100) ,
	`order_type` bigint not null,
	`admin_id` bigint not null,
	`field_list` bytea ,
	`status` int not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_modify_order_audit_pkey primary key ( id )
);

alter table uct_modify_order_audit alter column id add auto_increment;




CREATE TABLE `uct_modify_order_audit_log` (	
	`id` bigint not null,
	`audit_id` bigint not null,
	`admin_id` bigint not null,
	`operate` int not null,
	`remark` varchar(200) not null,
	`createtime` timestamp without time zone not null,
	constraint uct_modify_order_audit_log_pkey primary key ( id )
);

alter table uct_modify_order_audit_log alter column id add auto_increment;




CREATE TABLE `uct_news_record` (	
	`id` bigint not null,
	`new_title` varchar(200) not null,
	`new_time` date not null,
	`title_url` varchar(255) ,
	`title_url_type` int not null,
	`new_describe` varchar(800) not null,
	`new_url` varchar(255) ,
	`new_states` int not null,
	`status` int not null,
	`create_time` bigint not null,
	constraint uct_news_record_pkey primary key ( id )
);

alter table uct_news_record alter column id add auto_increment;




CREATE TABLE `uct_one_level_accumulate_wall_report` (	
	`adcode` bigint not null,
	`name` varchar(30) not null,
	`weight` decimal(12,2) not null,
	`carbon` decimal(12,2) not null,
	constraint uct_one_level_accumulate_wall_report_pkey primary key ( adcode ,name )
);




CREATE TABLE `uct_one_level_day_wall_report` (	
	`id` bigint not null,
	`adcode` bigint not null,
	`name` varchar(30) ,
	`weight` decimal(12,2) not null,
	`carbon` decimal(12,2) not null,
	`report_date` date ,
	constraint uct_one_level_day_wall_report_pkey primary key ( id )
);

alter table uct_one_level_day_wall_report alter column id add auto_increment;

create index `uct_one_level_day_wall_report_key1` on `uct_one_level_day_wall_report` (
	`adcode`,
	`report_date`
);



CREATE TABLE `uct_order_account` (	
	`id` bigint not null,
	`branch_id` bigint ,
	`admin_id` bigint ,
	`pur_num` bigint not null,
	`sel_num` bigint not null,
	`account_year` int not null,
	`account_month` int not null,
	`createtime` bigint not null,
	constraint uct_order_account_pkey primary key ( id )
);

alter table uct_order_account alter column id add auto_increment;

create index `uct_order_account_branch_id` on `uct_order_account` (
	`branch_id`,
	`account_year`,
	`account_month`
);



CREATE TABLE `uct_order_account_history` (	
	`order_id` bigint not null,
	`order_type` varchar(5) not null,
	`account_year` bigint not null,
	`account_month` bigint not null

);




CREATE TABLE `uct_order_bill` (	
	`id` bigint not null,
	`order_id` bigint not null,
	`audit_id` varchar(100) ,
	`order_no` varchar(50) ,
	`type` char(3) not null,
	`pay_way` varchar(20) ,
	`account` varchar(50) ,
	`settle_type` int ,
	`cash` NUMERIC ,
	`url` varchar(2000) ,
	`bank_bill_url` varchar(2000) ,
	`audit_remark` varchar(255) not null,
	`upload_remark` varchar(255) not null,
	`createtime` timestamp without time zone not null,
	`audittime` timestamp without time zone ,
	`status` int not null,
	constraint uct_order_bill_pkey primary key ( id )
);

alter table uct_order_bill alter column id add auto_increment;




CREATE TABLE `uct_order_cancel` (	
	`id` bigint not null,
	`order_id` bigint not null,
	`order_num` varchar(50) not null,
	`type` varchar(5) not null,
	`hand_mouth_data` int not null,
	`corrent` int not null,
	`handle` int not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_order_cancel_pkey primary key ( id )
);

alter table uct_order_cancel alter column id add auto_increment;




CREATE TABLE `uct_order_cancel_bak` (	
	`id` bigint not null,
	`order_id` bigint not null,
	`order_num` varchar(50) not null,
	`type` varchar(5) not null,
	`hand_mouth_data` int not null,
	`corrent` int not null,
	`handle` int not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_order_cancel_bak_pkey primary key ( id )
);

alter table uct_order_cancel_bak alter column id add auto_increment;




CREATE TABLE `uct_page` (	
	`id` bigint not null,
	`category_id` bigint not null,
	`title` varchar(50) not null,
	`keywords` varchar(255) not null,
	`flag` varchar(256) not null,
	`image` varchar(255) not null,
	`content` bytea not null,
	`icon` varchar(50) not null,
	`views` bigint not null,
	`comments` bigint not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`weigh` bigint not null,
	`status` varchar(30) not null,
	constraint uct_page_pkey primary key ( id )
);

alter table uct_page alter column id add auto_increment;




CREATE TABLE `uct_password_reset` (	
	`id` bigint not null,
	`nickname` varchar(50) not null,
	`username` varchar(50) not null,
	`password` varchar(50) not null,
	constraint uct_password_reset_pkey primary key ( id )
);

alter table uct_password_reset alter column id add auto_increment;




CREATE TABLE `uct_potential_customer` (	
	`id` bigint not null,
	`name` varchar(50) ,
	`mobile` varchar(15) ,
	`company_name` varchar(100) not null,
	`industry` varchar(100) not null,
	`scale` varchar(100) not null,
	`city` varchar(100) not null,
	`type` varchar(100) not null,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_potential_customer_pkey primary key ( id )
);

alter table uct_potential_customer alter column id add auto_increment;




CREATE TABLE `uct_print_setting` (	
	`id` bigint not null,
	`client_id` varchar(20) ,
	`client_secret` varchar(50) ,
	`access_token` varchar(50) ,
	`refresh_token` varchar(50) ,
	`token_time` bigint ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_print_setting_pkey primary key ( id )
);

alter table uct_print_setting alter column id add auto_increment;




CREATE TABLE `uct_purchase_sign_in_out` (	
	`id` bigint not null,
	`purchase_incharge` bigint ,
	`purchase_id` bigint ,
	`sign_in_type` int ,
	`img_in_url` varchar(255) ,
	`img_in_type` int ,
	`position_in` varchar(100) ,
	`address_in` varchar(200) ,
	`sign_in_time` bigint ,
	`sign_out_type` int ,
	`img_out_url` varchar(255) ,
	`img_out_type` int ,
	`position_out` varchar(100) ,
	`address_out` varchar(200) ,
	`sign_out_time` bigint ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_purchase_sign_in_out_pkey primary key ( id )
);

alter table uct_purchase_sign_in_out alter column id add auto_increment;




CREATE TABLE `uct_purchase_sign_in_out_bak` (	
	`id` bigint not null,
	`purchase_incharge` bigint ,
	`purchase_id` bigint ,
	`sign_in_type` int ,
	`img_in_url` varchar(255) ,
	`img_in_type` int ,
	`position_in` varchar(100) ,
	`address_in` varchar(200) ,
	`sign_in_time` bigint ,
	`sign_out_type` int ,
	`img_out_url` varchar(255) ,
	`img_out_type` int ,
	`position_out` varchar(100) ,
	`address_out` varchar(200) ,
	`sign_out_time` bigint ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_purchase_sign_in_out_bak_pkey primary key ( id )
);

alter table uct_purchase_sign_in_out_bak alter column id add auto_increment;




CREATE TABLE `uct_purchase_sign_in_out_bak2` (	
	`id` bigint not null,
	`purchase_incharge` bigint ,
	`purchase_id` bigint ,
	`sign_in_type` int ,
	`img_in_url` varchar(255) ,
	`img_in_type` int ,
	`position_in` varchar(100) ,
	`address_in` varchar(200) ,
	`sign_in_time` bigint ,
	`sign_out_type` int ,
	`img_out_url` varchar(255) ,
	`img_out_type` int ,
	`position_out` varchar(100) ,
	`address_out` varchar(200) ,
	`sign_out_time` bigint ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_purchase_sign_in_out_bak2_pkey primary key ( id )
);

alter table uct_purchase_sign_in_out_bak2 alter column id add auto_increment;




CREATE TABLE `uct_purchase_sign_in_out_bak3` (	
	`id` bigint not null,
	`purchase_incharge` bigint ,
	`purchase_id` bigint ,
	`sign_in_type` int ,
	`img_in_url` varchar(255) ,
	`img_in_type` int ,
	`position_in` varchar(100) ,
	`address_in` varchar(200) ,
	`sign_in_time` bigint ,
	`sign_out_type` int ,
	`img_out_url` varchar(255) ,
	`img_out_type` int ,
	`position_out` varchar(100) ,
	`address_out` varchar(200) ,
	`sign_out_time` bigint ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_purchase_sign_in_out_bak3_pkey primary key ( id )
);

alter table uct_purchase_sign_in_out_bak3 alter column id add auto_increment;




CREATE TABLE `uct_purchase_sign_in_out_demo` (	
	`id` bigint not null,
	`purchase_incharge` bigint ,
	`purchase_id` bigint ,
	`sign_in_type` int ,
	`img_in_url` varchar(255) ,
	`img_in_type` int ,
	`position_in` varchar(100) ,
	`address_in` varchar(200) ,
	`sign_in_time` bigint ,
	`sign_out_type` int ,
	`img_out_url` varchar(255) ,
	`img_out_type` int ,
	`position_out` varchar(100) ,
	`address_out` varchar(200) ,
	`sign_out_time` bigint ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_purchase_sign_in_out_demo_pkey primary key ( id )
);

alter table uct_purchase_sign_in_out_demo alter column id add auto_increment;




CREATE TABLE `uct_quotation` (	
	`id` bigint not null,
	`main_id` bigint ,
	`wor_id` bigint not null,
	`audit_code` varchar(18) not null,
	`cus_id` bigint not null,
	`first_wor_id` bigint not null,
	`first_exa_time` bigint not null,
	`first_memo` varchar(100) ,
	`last_wor_id` bigint not null,
	`last_exa_time` bigint not null,
	`last_memo` varchar(100) not null,
	`exa_result` bigint not null,
	`create_time` bigint not null,
	`change_time` bigint not null,
	constraint uct_quotation_pkey primary key ( id )
);

alter table uct_quotation alter column id add auto_increment;




CREATE TABLE `uct_quotation_details` (	
	`id` bigint not null,
	`quota_id` bigint not null,
	`material_id` bigint not null,
	`img_url` varchar(800) not null,
	`pur_price` decimal(10,3) not null,
	`create_time` bigint not null,
	constraint uct_quotation_details_pkey primary key ( id )
);

alter table uct_quotation_details alter column id add auto_increment;




CREATE TABLE `uct_recycling_data` (	
	`id` bigint not null,
	`route_id` bigint not null,
	`station_id` bigint not null,
	`cate_id` bigint ,
	`cate_name` varchar(30) ,
	`serial_number` bigint ,
	`rfid` varchar(24) ,
	`net_weight` decimal(10,3) ,
	`tare_weight` decimal(10,3) ,
	`price` decimal(10,2) ,
	`sub_total` decimal(10,3) ,
	`status` int ,
	`create_time` timestamp without time zone not null,
	constraint uct_recycling_data_pkey primary key ( id )
);

alter table uct_recycling_data alter column id add auto_increment;




CREATE TABLE `uct_recycling_log` (	
	`id` bigint not null,
	`log_type` varchar(30) not null,
	`admin_id` bigint not null,
	`title` varchar(255) ,
	`operation` varchar(255) ,
	`describe` varchar(255) ,
	`ip` varchar(50) ,
	`create_time` timestamp without time zone not null,
	constraint uct_recycling_log_pkey primary key ( id )
);

alter table uct_recycling_log alter column id add auto_increment;




CREATE TABLE `uct_recycling_routes` (	
	`id` bigint not null,
	`route_code` varchar(50) not null,
	`carriage_code` varchar(50) not null,
	`carriage_name` varchar(50) ,
	`hw_sn` varchar(100) ,
	`hw_ble_model_no` varchar(50) not null,
	`hw_ble_mac_address` varchar(255) not null,
	`purchase_incharge` bigint not null,
	`purchase_name` varchar(50) ,
	`driver_id` bigint not null,
	`driver_name` varchar(50) ,
	`plate_number` varchar(50) not null,
	`cate_id` bigint ,
	`cate_name` varchar(50) ,
	`branch_id` bigint ,
	`branch_name` varchar(255) ,
	`weight` decimal(10,2) ,
	`capacity` decimal(10,2) ,
	`status` varchar(30) ,
	`create_time` timestamp without time zone not null,
	`input_flag` bigint ,
	constraint uct_recycling_routes_pkey primary key ( id )
);

alter table uct_recycling_routes alter column id add auto_increment;




CREATE TABLE `uct_recycling_server_account` (	
	`branch_id` bigint ,
	`username` varchar(255) ,
	`password` varchar(255) ,
	`auto_commit_flag` varchar(255) 

);




CREATE TABLE `uct_recycling_station` (	
	`id` bigint not null,
	`route_id` bigint not null,
	`route_code` varchar(30) ,
	`station_num` bigint ,
	`station_code` varchar(30) ,
	`station_name` varchar(30) ,
	`station_type` varchar(20) ,
	`finterid` bigint ,
	`order_id` varchar(30) ,
	`order_type` varchar(50) ,
	`customer_id` bigint ,
	`customer_name` varchar(255) ,
	`company_address` varchar(255) ,
	`factory_id` bigint ,
	`manager_id` bigint ,
	`manager_name` varchar(20) ,
	`branch_id` bigint ,
	`branch_name` varchar(20) ,
	`price` decimal(10,3) ,
	`presell_price` decimal(10,3) ,
	`weight` decimal(10,2) ,
	`sales_weight` decimal(10,2) ,
	`capacity` decimal(10,2) ,
	`sales_total` decimal(10,3) ,
	`subs_total` decimal(10,3) ,
	`presell_total` decimal(10,3) ,
	`update_time` timestamp without time zone not null,
	`create_time` timestamp without time zone not null,
	`job_status` varchar(50) ,
	`act_status` varchar(50) ,
	`reason_code` varchar(50) ,
	`reason_text` varchar(100) ,
	`act_begin_time` timestamp without time zone ,
	`act_end_time` timestamp without time zone ,
	`job_begin_time` timestamp without time zone ,
	`job_end_time` timestamp without time zone ,
	constraint uct_recycling_station_pkey primary key ( id )
);

alter table uct_recycling_station alter column id add auto_increment;




CREATE TABLE `uct_report_params` (	
	`id` bigint not null,
	`role_ids` varchar(20) not null,
	`report_name` varchar(50) not null,
	`data_dims` varchar(20) not null,
	`field_name` varchar(20) not null,
	`data_val` varchar(20) not null,
	`create_at` timestamp without time zone not null,
	`updated_at` timestamp without time zone not null,
	constraint uct_report_params_pkey primary key ( id )
);

alter table uct_report_params alter column id add auto_increment;




CREATE TABLE `uct_review` (	
	`id` bigint not null,
	`cus_id` bigint not null,
	`wor_id` bigint not null,
	`create_time` bigint not null,
	`report_time` bigint ,
	`deletetime` bigint ,
	`status` int not null,
	`chang_time` bigint ,
	`type_json` json ,
	`begin_ratio` double precision not null,
	`last_ratio` double precision not null,
	`earnings` double precision not null,
	`change_memo` bytea ,
	constraint uct_review_pkey primary key ( id )
);

alter table uct_review alter column id add auto_increment;




CREATE TABLE `uct_review_audit` (	
	`id` bigint not null,
	`review_id` bigint not null,
	`audit_id` bigint not null,
	`audit_result` int not null,
	`memo` bytea not null,
	`create_time` bigint not null,
	constraint uct_review_audit_pkey primary key ( id )
);

alter table uct_review_audit alter column id add auto_increment;




CREATE TABLE `uct_review_auth` (	
	`id` bigint not null,
	`parent_id` bigint not null,
	`auth_name` varchar(40) not null,
	`type` bigint not null,
	`deletetime` bigint ,
	`rank` bigint ,
	`is_show` int not null,
	constraint uct_review_auth_pkey primary key ( id )
);

alter table uct_review_auth alter column id add auto_increment;




CREATE TABLE `uct_review_details` (	
	`id` bigint not null,
	`main_id` bigint not null,
	`auth_id` varchar(20) not null,
	`auth_attr` bytea ,
	`version` bigint ,
	`attr_type` bigint ,
	`img_url` varchar(800) not null,
	`memo` bytea ,
	`create_time` bigint not null,
	`changes_time` bigint not null,
	constraint uct_review_details_pkey primary key ( id )
);

alter table uct_review_details alter column id add auto_increment;




CREATE TABLE `uct_sample_collect` (	
	`id` bigint not null,
	`cus_id` bigint not null,
	`wor_id` bigint not null,
	`create_time` bigint not null,
	`status` int not null,
	`chang_time` bigint not null,
	constraint uct_sample_collect_pkey primary key ( id )
);

alter table uct_sample_collect alter column id add auto_increment;




CREATE TABLE `uct_sample_collect_details` (	
	`id` bigint not null,
	`collect_id` bigint not null,
	`collect_code` varchar(30) not null,
	`img_url` varchar(800) not null,
	`memo` varchar(100) ,
	`create_time` bigint not null,
	constraint uct_sample_collect_details_pkey primary key ( id )
);

alter table uct_sample_collect_details alter column id add auto_increment;




CREATE TABLE `uct_sms` (	
	`id` bigint not null,
	`event` varchar(30) not null,
	`mobile` varchar(20) not null,
	`code` varchar(10) not null,
	`times` bigint not null,
	`ip` varchar(30) not null,
	`createtime` timestamp without time zone not null,
	constraint uct_sms_pkey primary key ( id )
);

alter table uct_sms alter column id add auto_increment;

create index `uct_sms_createtime` on `uct_sms` (
	`createtime`
);



CREATE TABLE `uct_sorting_cate` (	
	`id` bigint not null,
	`parent_id` bigint ,
	`creater_id` bigint ,
	`name` varchar(50) ,
	`description` varchar(255) ,
	`imgpath` varchar(100) ,
	`order_str` varchar(50) ,
	`create_at` varchar(50) ,
	`update_at` varchar(50) ,
	constraint uct_sorting_cate_pkey primary key ( id )
);

alter table uct_sorting_cate alter column id add auto_increment;




CREATE TABLE `uct_sorting_commit` (	
	`id` bigint not null,
	`task_id` bigint ,
	`line_id` varchar(20) ,
	`station_id` varchar(20) not null,
	`device_id` varchar(20) ,
	`purchase_order_no` varchar(20) ,
	`cate_id` bigint ,
	`presell_price` decimal(10,3) ,
	`package_no` varchar(20) ,
	`item_no` bigint ,
	`net_weight` decimal(6,2) ,
	`gross_weight` decimal(6,2) ,
	`tare_memo` varchar(800) ,
	`weight_unit` varchar(3) ,
	`sub_time` bigint ,
	`sorter` bigint ,
	`control_station_id` varchar(30) ,
	`controler` bigint ,
	`begin_time` timestamp without time zone ,
	`end_time` timestamp without time zone not null,
	`use_time` bigint ,
	`process` varchar(20) ,
	`disposal_way` varchar(20) ,
	`is_pack` int ,
	`leader` varchar(20) ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_sorting_commit_pkey primary key ( id )
);

alter table uct_sorting_commit alter column id add auto_increment;




CREATE TABLE `uct_sorting_container` (	
	`id` bigint not null,
	`sn` varchar(20) not null,
	`csn` varchar(20) ,
	`state` int ,
	`weight` decimal(6,2) ,
	`weight_unit` varchar(5) not null,
	`last_calibration_at` timestamp without time zone ,
	`hw_info` json ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_sorting_container_pkey primary key ( id )
);

alter table uct_sorting_container alter column id add auto_increment;

alter table `uct_sorting_container` add constraint `uct_sorting_container_IDX_CON_SN_UNIQUE` unique (
	`sn`
);



CREATE TABLE `uct_sorting_job_logs` (	
	`id` bigint not null,
	`line_id` varchar(20) not null,
	`purchase_order_no` varchar(20) not null,
	`revision` bigint not null,
	`status` varchar(20) ,
	`leader` varchar(20) ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_sorting_job_logs_pkey primary key ( id )
);

alter table uct_sorting_job_logs alter column id add auto_increment;




CREATE TABLE `uct_sorting_jobs` (	
	`id` bigint not null,
	`line_id` varchar(20) not null,
	`order_id` bigint not null,
	`purchase_order_no` varchar(20) not null,
	`status` varchar(20) ,
	`leader` varchar(20) ,
	`priority` bigint ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	`finish_at` timestamp without time zone not null,
	constraint uct_sorting_jobs_pkey primary key ( id )
);

alter table uct_sorting_jobs alter column id add auto_increment;




CREATE TABLE `uct_sorting_line` (	
	`id` bigint not null,
	`warehouse_id` bigint not null,
	`station_num` bigint not null,
	`line_num` bigint not null,
	`order_id` varchar(50) not null,
	`cate_id` bigint not null,
	`sort_man` bigint not null,
	`materiel_num` varchar(100) not null,
	`net_weight` decimal(10,2) not null,
	`presell_price` decimal(10,3) not null,
	`storage_time` timestamp without time zone not null,
	`start_time` timestamp without time zone not null,
	`end_time` timestamp without time zone not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_sorting_line_pkey primary key ( id )
);

alter table uct_sorting_line alter column id add auto_increment;




CREATE TABLE `uct_sorting_line_manage` (	
	`id` bigint not null,
	`uuid` varchar(50) not null,
	`admin_id` bigint not null,
	`branch_id` bigint not null,
	`warehouse_id` bigint not null,
	`line_name` varchar(200) not null,
	`createtime` timestamp without time zone ,
	`updatetime` timestamp without time zone ,
	`states` varchar(20) ,
	constraint uct_sorting_line_manage_pkey primary key ( id )
);

alter table uct_sorting_line_manage alter column id add auto_increment;




CREATE TABLE `uct_sorting_packings` (	
	`package_no` varchar(20) not null,
	`station_id` varchar(20) not null,
	`device_id` varchar(20) ,
	`cate_id` bigint ,
	`total_net_weight` decimal(6,2) ,
	`weight_unit` varchar(3) ,
	`packer` bigint ,
	`begin_time` timestamp without time zone ,
	`end_time` timestamp without time zone ,
	`use_time` bigint ,
	`status` varchar(10) ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_sorting_packings_pkey primary key ( package_no )
);




CREATE TABLE `uct_sorting_sop` (	
	`id` bigint not null,
	`state` int ,
	`key_id` bigint not null,
	`creater_id` bigint ,
	`version` bigint ,
	`name` varchar(50) ,
	`description` varchar(255) not null,
	`imgpath` varchar(100) ,
	`create_at` bigint ,
	`update_at` bigint ,
	constraint uct_sorting_sop_pkey primary key ( id )
);

alter table uct_sorting_sop alter column id add auto_increment;




CREATE TABLE `uct_sorting_task_template` (	
	`id` bigint not null,
	`template_name` varchar(50) not null,
	`branch_id` bigint ,
	`sortage_id` bigint ,
	`line_id` varchar(10) ,
	`supplier_code` varchar(100) ,
	`active` int ,
	`wor_id` bigint ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_sorting_task_template_pkey primary key ( id )
);

alter table uct_sorting_task_template alter column id add auto_increment;




CREATE TABLE `uct_sorting_task_template_detail` (	
	`id` bigint not null,
	`temp_id` bigint not null,
	`station_id` varchar(50) ,
	`device_id` varchar(50) ,
	`cate_id` bigint ,
	`cate_name` varchar(100) ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_sorting_task_template_detail_pkey primary key ( id )
);

alter table uct_sorting_task_template_detail alter column id add auto_increment;




CREATE TABLE `uct_sorting_tasks` (	
	`id` bigint not null,
	`line_id` varchar(20) not null,
	`station_id` varchar(20) ,
	`device_id` varchar(20) ,
	`device_label` varchar(50) ,
	`cate_id` bigint ,
	`cate_name` varchar(50) ,
	`active` bigint ,
	`leader` bigint ,
	`po_no` varchar(20) ,
	`assign_no` bigint ,
	`package_no` varchar(20) ,
	`create_at` timestamp without time zone ,
	`update_at` timestamp without time zone ,
	constraint uct_sorting_tasks_pkey primary key ( id )
);

alter table uct_sorting_tasks alter column id add auto_increment;




CREATE TABLE `uct_spi_customer_history` (	
	`id` bigint not null,
	`month` varchar(50) not null,
	`branch_id` bigint ,
	`cust_id` bigint ,
	`cust_name` varchar(255) ,
	`cust_type` varchar(20) ,
	`star_level` bigint ,
	`create_at` timestamp without time zone ,
	`updated_at` timestamp without time zone ,
	constraint uct_spi_customer_history_pkey primary key ( id )
);

alter table uct_spi_customer_history alter column id add auto_increment;




CREATE TABLE `uct_spi_target` (	
	`id` bigint not null,
	`time_dims` varchar(10) not null,
	`time_val` varchar(30) ,
	`begin_time` timestamp without time zone ,
	`end_time` timestamp without time zone ,
	`data_dims` varchar(30) ,
	`data_val` varchar(100) ,
	`dept_name` varchar(100) ,
	`parent_id` varchar(100) ,
	`owner` varchar(50) ,
	`target_dims` varchar(30) ,
	`target_val` decimal(10,2) ,
	`target_unit` varchar(20) ,
	`create_at` timestamp without time zone ,
	`updated_at` timestamp without time zone ,
	constraint uct_spi_target_pkey primary key ( id )
);

alter table uct_spi_target alter column id add auto_increment;

create index `uct_spi_target_IDX_dims` on `uct_spi_target` (
	`time_dims`,
	`time_val`,
	`data_dims`,
	`target_dims`
);



CREATE TABLE `uct_testmodule_test` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`category_id` bigint not null,
	`category_ids` varchar(100) not null,
	`week` varchar(256) not null,
	`flag` varchar(256) not null,
	`genderdata` varchar(256) not null,
	`hobbydata` varchar(256) not null,
	`title` varchar(50) not null,
	`content` bytea not null,
	`image` varchar(100) not null,
	`images` varchar(1500) not null,
	`attachfile` varchar(100) not null,
	`keywords` varchar(100) not null,
	`description` varchar(255) not null,
	`city` varchar(100) not null,
	`price` double precision not null,
	`views` bigint not null,
	`startdate` date ,
	`activitytime` timestamp without time zone ,
	`year` int ,
	`times` time ,
	`refreshtime` bigint not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`weigh` bigint not null,
	`switch` int not null,
	`status` varchar(256) not null,
	`state` varchar(256) not null,
	constraint uct_testmodule_test_pkey primary key ( id )
);

alter table uct_testmodule_test alter column id add auto_increment;




CREATE TABLE `uct_third` (	
	`id` bigint not null,
	`user_id` bigint not null,
	`platform` varchar(256) not null,
	`openid` varchar(50) not null,
	`openname` varchar(50) not null,
	`access_token` varchar(100) not null,
	`refresh_token` varchar(100) not null,
	`expires_in` bigint not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`logintime` bigint not null,
	`expiretime` bigint not null,
	constraint uct_third_pkey primary key ( id )
);

alter table uct_third alter column id add auto_increment;

alter table `uct_third` add constraint `uct_third_platform` unique (
	`platform`,
	`openid`
);
create index `uct_third_user_id` on `uct_third` (
	`user_id`,
	`platform`
);



CREATE TABLE `uct_trans_revise_log` (	
	`id` bigint not null,
	`admin_id` bigint ,
	`order_id` bigint ,
	`type` bigint ,
	`revise_item` bytea ,
	`createtime` bigint ,
	constraint uct_trans_revise_log_pkey primary key ( id )
);

alter table uct_trans_revise_log alter column id add auto_increment;




CREATE TABLE `uct_up` (	
	`id` bigint not null,
	`crmid` varchar(20) ,
	`name` varchar(20) ,
	`mobile` varchar(20) ,
	`company_province` varchar(20) ,
	`company_city` varchar(20) ,
	`company_region` varchar(20) ,
	`company_addr` varchar(250) ,
	`first_business_time` varchar(255) ,
	`position` varchar(20) not null,
	constraint uct_up_pkey primary key ( id )
);

alter table uct_up alter column id add auto_increment;




CREATE TABLE `uct_up_modify_audit` (	
	`id` bigint not null,
	`order_id` varchar(50) not null,
	`customer_id` bigint not null,
	`type` int not null,
	`crmid` bigint not null,
	`accid` varchar(50) not null,
	`cus_type` varchar(50) not null,
	`crm_type` varchar(50) not null,
	`field_list` bytea ,
	`opinion` varchar(100) ,
	`manager_id` bigint ,
	`state` int not null,
	`audittime` timestamp without time zone ,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_up_modify_audit_pkey primary key ( id )
);

alter table uct_up_modify_audit alter column id add auto_increment;

create index `uct_up_modify_audit_createtime` on `uct_up_modify_audit` (
	`createtime`
);



CREATE TABLE `uct_user` (	
	`id` bigint not null,
	`admin_id` bigint ,
	`appletid` varchar(50) not null,
	`openid` varchar(50) not null,
	`unionid` varchar(50) not null,
	`session_key` varchar(255) not null,
	`username` varchar(32) not null,
	`nickname` varchar(50) not null,
	`subscribe` int not null,
	`sex` int ,
	`language` varchar(32) not null,
	`city` varchar(50) not null,
	`province` varchar(50) not null,
	`country` varchar(50) not null,
	`password` varchar(32) not null,
	`salt` varchar(30) not null,
	`email` varchar(100) not null,
	`mobile` varchar(11) not null,
	`avatar` varchar(255) not null,
	`level` int not null,
	`gender` int not null,
	`birthday` varchar(30) ,
	`score` bigint not null,
	`prevtime` bigint not null,
	`loginfailure` int not null,
	`logintime` bigint not null,
	`loginip` varchar(50) not null,
	`joinip` varchar(50) not null,
	`jointime` bigint not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`token` varchar(50) not null,
	`status` varchar(30) not null,
	constraint uct_user_pkey primary key ( id )
);

alter table uct_user alter column id add auto_increment;

create index `uct_user_username` on `uct_user` (
	`username`
);
create index `uct_user_email` on `uct_user` (
	`email`
);
create index `uct_user_mobile` on `uct_user` (
	`mobile`
);



CREATE TABLE `uct_vehicle` (	
	`vehicle_id` varchar(36) ,
	`plate_number` varchar(20) ,
	`pass_number` varchar(20) ,
	`model` varchar(20) ,
	`status` varchar(20) ,
	`vehicle_weight` NUMERIC ,
	`vehicle_load_weight` NUMERIC ,
	`manufacturer` varchar(255) ,
	`license_plate_color` varchar(50) ,
	`engine_no` varchar(50) ,
	`engine_number` varchar(50) ,
	`container_sn` varchar(50) ,
	`tem_id` varchar(50) ,
	`remark` bytea ,
	`org_id` varchar(36) ,
	`create_at` timestamp without time zone ,
	`create_user_id` bigint ,
	`update_at` timestamp without time zone 

);




CREATE TABLE `uct_voucher` (	
	`id` bigint not null,
	`no` varchar(30) not null,
	`audit_id` varchar(50) not null,
	`task_id` varchar(50) not null,
	`branch_id` bigint not null,
	`branch_text` varchar(50) not null,
	`place_order_name` varchar(50) not null,
	`place_order_id` bigint not null,
	`place_order_mobile` varchar(15) not null,
	`cus_linkman_name` varchar(50) not null,
	`cus_id` bigint not null,
	`cus_name` varchar(100) not null,
	`cus_code` varchar(50) not null,
	`cus_type` varchar(50) not null,
	`pay_use` varchar(50) not null,
	`pay_way` varchar(50) not null,
	`collect_bank_account` varchar(50) ,
	`account_num` varchar(50) ,
	`bank` varchar(50) ,
	`bank_address` varchar(50) ,
	`wechat_name` varchar(50) not null,
	`cash` NUMERIC not null,
	`amount` NUMERIC not null,
	`surplus` NUMERIC not null,
	`cause` varchar(200) not null,
	`images` varchar(200) not null,
	`qc` int not null,
	`status` varchar(20) not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_voucher_pkey primary key ( id )
);

alter table uct_voucher alter column id add auto_increment;




CREATE TABLE `uct_voucher_remark` (	
	`id` bigint not null,
	`voucher_id` bigint not null,
	`admin_id` bigint not null,
	`nickname` varchar(50) not null,
	`remark` varchar(200) not null,
	`createtime` timestamp without time zone not null,
	`updatetime` timestamp without time zone not null,
	constraint uct_voucher_remark_pkey primary key ( id )
);

alter table uct_voucher_remark alter column id add auto_increment;




CREATE TABLE `uct_waste_cate` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`parent_id` bigint not null,
	`name` varchar(100) not null,
	`top_class` varchar(20) ,
	`standard_price` double precision ,
	`presell_price` double precision ,
	`risk_cost` double precision ,
	`image` varchar(100) ,
	`value_type` varchar(20) ,
	`weigh` bigint not null,
	`state` varchar(256) not null,
	`carbon_parm` double precision not null,
	`start_time` bigint ,
	`end_time` bigint ,
	`createtime` bigint ,
	`updatetime` bigint ,
	`direction` bigint ,
	constraint uct_waste_cate_pkey primary key ( id )
);

alter table uct_waste_cate alter column id add auto_increment;

create index `uct_waste_cate_uct_waste_cate_idx_002` on `uct_waste_cate` (
	`parent_id`
);
create index `uct_waste_cate_uct_waste_cate_idx_001` on `uct_waste_cate` (
	`branch_id`
);



CREATE TABLE `uct_waste_cate_actual` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`cate_id` bigint not null,
	`customer_id` bigint not null,
	`expect_sale` bigint ,
	`standard_value` double precision ,
	`actual_value` double precision ,
	`start_time` bigint not null,
	`end_time` bigint not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	constraint uct_waste_cate_actual_pkey primary key ( id )
);

alter table uct_waste_cate_actual alter column id add auto_increment;




CREATE TABLE `uct_waste_cate_actual_log` (	
	`id` bigint not null,
	`order_id` varchar(50) not null,
	`audit_id` varchar(50) not null,
	`branch_id` bigint not null,
	`admin_id` bigint not null,
	`examine_remark` varchar(255) ,
	`branch_remark` varchar(255) ,
	`hq_remark` varchar(255) ,
	`hq_examine_time` bigint ,
	`status` int not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_cate_actual_log_pkey primary key ( id )
);

alter table uct_waste_cate_actual_log alter column id add auto_increment;

create index `uct_waste_cate_actual_log_IDX_id_branch_id` on `uct_waste_cate_actual_log` (
	`id`,
	`branch_id`
);



CREATE TABLE `uct_waste_cate_actual_log_item` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`actual_log_id` bigint not null,
	`customer_id` bigint not null,
	`cate_id` bigint not null,
	`expect_sale` bigint ,
	`presell_price` double precision ,
	`actual_value` double precision ,
	`state` bigint ,
	`level` varchar(50) ,
	`images` varchar(500) ,
	`remark` varchar(500) ,
	`start_time` bigint ,
	`end_time` bigint ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_cate_actual_log_item_pkey primary key ( id )
);

alter table uct_waste_cate_actual_log_item alter column id add auto_increment;

create index `uct_waste_cate_actual_log_item_cate_id_customer_id` on `uct_waste_cate_actual_log_item` (
	`cate_id`,
	`customer_id`
);
create index `uct_waste_cate_actual_log_item_IDX_state_start_time` on `uct_waste_cate_actual_log_item` (
	`actual_log_id`,
	`state`,
	`start_time`
);
create index `uct_waste_cate_actual_log_item_IDX_branch_state_start_time` on `uct_waste_cate_actual_log_item` (
	`branch_id`,
	`state`,
	`start_time`
);



CREATE TABLE `uct_waste_cate_bak` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`parent_id` bigint not null,
	`name` varchar(100) not null,
	`top_class` varchar(20) ,
	`standard_price` double precision ,
	`presell_price` double precision ,
	`risk_cost` double precision ,
	`image` varchar(100) ,
	`value_type` varchar(20) ,
	`weigh` bigint not null,
	`state` varchar(256) not null,
	`carbon_parm` double precision not null,
	`start_time` bigint ,
	`end_time` bigint ,
	`createtime` bigint ,
	`updatetime` bigint ,
	`direction` bigint ,
	constraint uct_waste_cate_bak_pkey primary key ( id )
);

alter table uct_waste_cate_bak alter column id add auto_increment;

create index `uct_waste_cate_bak_uct_waste_cate_idx_002` on `uct_waste_cate_bak` (
	`parent_id`
);
create index `uct_waste_cate_bak_uct_waste_cate_idx_001` on `uct_waste_cate_bak` (
	`branch_id`
);



CREATE TABLE `uct_waste_cate_expect_log` (	
	`id` bigint not null,
	`admin_id` bigint ,
	`branch_id` bigint ,
	`file_name` varchar(255) ,
	`examine_remark` varchar(255) ,
	`branch_remark` varchar(255) ,
	`hq_remark` varchar(255) ,
	`hq_examine_time` bigint ,
	`status` int not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_cate_expect_log_pkey primary key ( id )
);

alter table uct_waste_cate_expect_log alter column id add auto_increment;




CREATE TABLE `uct_waste_cate_log` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`cate_id` bigint not null,
	`type` varchar(256) not null,
	`before_value` double precision ,
	`value` varchar(20) ,
	`ip` varchar(50) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_cate_log_pkey primary key ( id )
);

alter table uct_waste_cate_log alter column id add auto_increment;




CREATE TABLE `uct_waste_cate_overdue` (	
	`id` bigint not null,
	`branch_id` bigint ,
	`ware_id` bigint ,
	`cate_id` bigint not null,
	`cate_name` varchar(100) ,
	`state` varchar(256) not null,
	`create_at` timestamp without time zone ,
	`updata_at` timestamp without time zone ,
	constraint uct_waste_cate_overdue_pkey primary key ( id )
);

alter table uct_waste_cate_overdue alter column id add auto_increment;




CREATE TABLE `uct_waste_customer` (	
	`id` bigint not null,
	`cus_accid` varchar(100) not null,
	`old_cus_accid` varchar(100) not null,
	`crmid` varchar(100) not null,
	`admin_id` varchar(100) ,
	`branch_id` bigint ,
	`internal` int ,
	`green_coin` bigint ,
	`customer_type` varchar(256) not null,
	`customer_code` varchar(100) not null,
	`name` varchar(100) not null,
	`agre_expire` varchar(20) ,
	`sign_company` varchar(100) not null,
	`print_title_id` bigint not null,
	`name_en` varchar(100) not null,
	`allot_id` bigint not null,
	`manager_id` bigint ,
	`server_id` bigint ,
	`seller_incharge` bigint ,
	`service_department` bigint not null,
	`incharge` varchar(50) not null,
	`juridical_person` varchar(50) not null,
	`class_a` varchar(20) not null,
	`class_b` varchar(20) not null,
	`trade_type` varchar(5) ,
	`mobile` char(15) not null,
	`waste_type` varchar(100) not null,
	`level` bigint ,
	`company_address` varchar(255) ,
	`company_position` bytea ,
	`company_adcode` bigint ,
	`company_region` varchar(255) ,
	`adcode_status` int ,
	`industry` bigint ,
	`website` varchar(50) ,
	`sales_area` varchar(50) ,
	`annual_waste` double precision ,
	`detail` varchar(500) ,
	`tax_cert` varchar(50) ,
	`trading_cert` varchar(50) ,
	`company_nature` bigint ,
	`tax_type` bigint ,
	`settle_way` bigint ,
	`back_percent` bigint ,
	`black_state` bigint ,
	`state` varchar(256) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_customer_pkey primary key ( id )
);

alter table uct_waste_customer alter column id add auto_increment;

create index `uct_waste_customer_customer_type_state` on `uct_waste_customer` (
	`customer_type`,
	`state`
);



CREATE TABLE `uct_waste_customer_bak` (	
	`id` bigint not null,
	`cus_accid` varchar(100) not null,
	`crmid` varchar(100) not null,
	`admin_id` varchar(100) ,
	`branch_id` bigint ,
	`internal` int ,
	`green_coin` bigint ,
	`customer_type` varchar(256) not null,
	`customer_code` varchar(100) not null,
	`name` varchar(100) not null,
	`agre_expire` varchar(20) ,
	`sign_company` varchar(100) not null,
	`print_title_id` bigint not null,
	`name_en` varchar(100) not null,
	`allot_id` bigint not null,
	`manager_id` bigint ,
	`server_id` bigint ,
	`seller_incharge` bigint ,
	`service_department` bigint not null,
	`incharge` varchar(50) not null,
	`juridical_person` varchar(50) not null,
	`class_a` varchar(20) not null,
	`class_b` varchar(20) not null,
	`trade_type` varchar(5) ,
	`mobile` char(15) not null,
	`waste_type` varchar(100) not null,
	`level` bigint ,
	`company_address` varchar(255) ,
	`company_position` bytea ,
	`industry` bigint ,
	`website` varchar(50) ,
	`sales_area` varchar(50) ,
	`annual_waste` double precision ,
	`detail` varchar(500) ,
	`tax_cert` varchar(50) ,
	`trading_cert` varchar(50) ,
	`company_nature` bigint ,
	`tax_type` bigint ,
	`settle_way` bigint ,
	`back_percent` bigint ,
	`black_state` bigint ,
	`state` varchar(256) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_customer_bak_pkey primary key ( id )
);

alter table uct_waste_customer_bak alter column id add auto_increment;

create index `uct_waste_customer_bak_customer_type_state` on `uct_waste_customer_bak` (
	`customer_type`,
	`state`
);



CREATE TABLE `uct_waste_customer_factory` (	
	`id` bigint not null,
	`customer_id` bigint not null,
	`province` varchar(50) not null,
	`city` varchar(50) not null,
	`area` varchar(50) not null,
	`detail_address` varchar(255) not null,
	`linkman` varchar(50) not null,
	`job` varchar(50) not null,
	`mobile` char(15) not null,
	`email` varchar(50) not null,
	`adcode` bigint not null,
	`position` varchar(255) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_customer_factory_pkey primary key ( id )
);

alter table uct_waste_customer_factory alter column id add auto_increment;




CREATE TABLE `uct_waste_customer_factory_bak` (	
	`id` bigint not null,
	`customer_id` bigint not null,
	`province` varchar(50) not null,
	`city` varchar(50) not null,
	`area` varchar(50) not null,
	`detail_address` varchar(255) not null,
	`linkman` varchar(50) not null,
	`job` varchar(50) not null,
	`mobile` char(15) not null,
	`email` varchar(50) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_customer_factory_bak_pkey primary key ( id )
);

alter table uct_waste_customer_factory_bak alter column id add auto_increment;




CREATE TABLE `uct_waste_customer_gathering` (	
	`id` bigint not null,
	`customer_id` bigint not null,
	`ec_linkid` varchar(50) not null,
	`index` int not null,
	`receiver` varchar(50) ,
	`bank_account` varchar(50) ,
	`deposit_bank` varchar(100) ,
	`deposit_address` varchar(255) ,
	`type` varchar(10) ,
	`createtime` bigint ,
	`updatetime` bigint ,
	`status` varchar(30) ,
	constraint uct_waste_customer_gathering_pkey primary key ( id )
);

alter table uct_waste_customer_gathering alter column id add auto_increment;




CREATE TABLE `uct_waste_customer_linkman` (	
	`id` bigint not null,
	`customer_id` bigint not null,
	`name` varchar(50) not null,
	`job` varchar(50) not null,
	`mobile` char(15) not null,
	`email` varchar(50) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_customer_linkman_pkey primary key ( id )
);

alter table uct_waste_customer_linkman alter column id add auto_increment;




CREATE TABLE `uct_waste_customer_log` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`customer_id` bigint not null,
	`title` varchar(100) not null,
	`state_value` varchar(50) not null,
	`state_text` varchar(50) not null,
	`ip` varchar(50) not null,
	`createtime` bigint ,
	constraint uct_waste_customer_log_pkey primary key ( id )
);

alter table uct_waste_customer_log alter column id add auto_increment;




CREATE TABLE `uct_waste_evaluate` (	
	`id` bigint not null,
	`customer_id` bigint not null,
	`incharge` varchar(50) not null,
	`mobile` char(15) not null,
	`salesman_id` bigint not null,
	`fillin_date` date ,
	`waste_type` bigint ,
	`is_mix_stack` varchar(256) ,
	`mix_stack_detail` varchar(500) ,
	`impurity` varchar(100) ,
	`third_test` varchar(256) ,
	`test_fee` varchar(256) ,
	`stack_area` double precision ,
	`daily_waste` double precision ,
	`low_monthly_waste` double precision ,
	`high_monthly_waste` double precision ,
	`detail_type` varchar(500) ,
	`physical_state` varchar(100) ,
	`weigh_tool` varchar(100) ,
	`weigh_detail` varchar(500) ,
	`produce_deal` varchar(255) ,
	`collect_deal` varchar(255) ,
	`sell_deal` varchar(255) ,
	`loading_scene` varchar(100) ,
	`loading_help` varchar(100) ,
	`transport_way` varchar(100) ,
	`danger_item` varchar(100) ,
	`operate_risk` varchar(100) ,
	`scene_images` varchar(1500) ,
	`secretout_risk` varchar(500) ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_evaluate_pkey primary key ( id )
);

alter table uct_waste_evaluate alter column id add auto_increment;




CREATE TABLE `uct_waste_hazardous_cate` (	
	`id` bigint not null,
	`creater_id` bigint ,
	`code` varchar(10) ,
	`name` varchar(100) not null,
	`description` varchar(255) ,
	`is_use` int ,
	`create_at` timestamp without time zone not null,
	constraint uct_waste_hazardous_cate_pkey primary key ( id )
);

alter table uct_waste_hazardous_cate alter column id add auto_increment;




CREATE TABLE `uct_waste_message` (	
	`id` bigint not null,
	`from_user` bigint not null,
	`to_user` bigint not null,
	`type` varchar(256) not null,
	`target_id` bigint ,
	`level` varchar(256) not null,
	`content` varchar(500) not null,
	`is_read` varchar(256) not null,
	`readtime` bigint ,
	`createtime` bigint ,
	constraint uct_waste_message_pkey primary key ( id )
);

alter table uct_waste_message alter column id add auto_increment;




CREATE TABLE `uct_waste_printer` (	
	`id` bigint not null,
	`type` bigint ,
	`key_id` bigint not null,
	`key_active` int ,
	`key_status` int ,
	`key_img` varchar(255) ,
	`key_others` varchar(255) ,
	`create_time` bigint ,
	constraint uct_waste_printer_pkey primary key ( id )
);

alter table uct_waste_printer alter column id add auto_increment;




CREATE TABLE `uct_waste_purchase` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`order_id` varchar(50) not null,
	`customer_id` bigint not null,
	`seller_id` bigint not null,
	`seller_remark` varchar(255) ,
	`factory_id` bigint ,
	`cargo_sort_data` varchar(256) not null,
	`cargo_type` varchar(255) ,
	`cargo_count` bigint ,
	`cargo_images` varchar(1500) ,
	`cargo_pick_date` date ,
	`manager_id` bigint ,
	`is_move` int ,
	`hand_mouth_data` varchar(256) ,
	`give_frame` varchar(256) ,
	`purchase_id` bigint ,
	`locale_sort_data` varchar(256) ,
	`purchase_incharge` bigint ,
	`sell_incharge` bigint ,
	`purchase_time` timestamp without time zone ,
	`floater_ids` varchar(100) ,
	`ofld_ids` varchar(100) ,
	`driver_id` bigint ,
	`map_trail` bytea ,
	`car_type` bigint ,
	`plate_number` varchar(255) ,
	`train_number` double precision ,
	`allot_remark` varchar(255) ,
	`apply_materiel_picktime` timestamp without time zone ,
	`apply_materiel_warehouse` bigint ,
	`apply_materiel_remark` varchar(255) ,
	`pick_materiel_remark` varchar(255) ,
	`materiel_price` double precision not null,
	`cargo_pick_remark` varchar(255) ,
	`cargo_pick_images` varchar(1500) ,
	`cargo_price` double precision ,
	`cargo_weight` double precision ,
	`purchase_expense` double precision ,
	`is_cash_pay` int ,
	`is_sorting` int ,
	`terminal_type` int ,
	`gathering_id` bigint ,
	`is_evaluate_data` varchar(256) ,
	`sort_point` bigint ,
	`storage_price` double precision ,
	`connect_weight` double precision ,
	`connect_tare` double precision ,
	`storage_remark` varchar(255) ,
	`connect_remark` varchar(255) ,
	`return_fee` double precision ,
	`sort_man` varchar(50) ,
	`sort_remark` varchar(255) ,
	`sort_expense` double precision ,
	`cargo_commission` decimal(5,2) ,
	`storage_weight` double precision ,
	`sorting_valuable_weight` decimal(10,3) ,
	`weigh_valuable_weight` decimal(10,3) ,
	`sorting_unvaluable_weight` decimal(10,3) ,
	`weigh_unvaluable_weight` decimal(10,3) ,
	`sorting_unit_cargo_price` decimal(10,3) ,
	`weigh_unit_cargo_price` decimal(10,3) ,
	`sorting_unit_labor_price` decimal(10,3) ,
	`weigh_unit_labor_price` decimal(10,3) ,
	`warehouse_unit_cost` decimal(10,3) ,
	`total_cargo_price` decimal(10,3) ,
	`total_labor_price` decimal(10,3) ,
	`warehouse_cost` decimal(10,3) ,
	`storage_cargo_price` double precision ,
	`storage_confirm_remark` varchar(255) ,
	`tags` varchar(20) ,
	`overdue_time` bigint ,
	`state` varchar(256) not null,
	`audit_state` varchar(256) ,
	`bill_state` int not null,
	`prop_ratio` decimal(10,3) not null,
	`print_num` bigint not null,
	`forensics_time` bigint ,
	`forensics_info` json ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_purchase_pkey primary key ( id )
);

alter table uct_waste_purchase alter column id add auto_increment;

alter table `uct_waste_purchase` add constraint `uct_waste_purchase_order_id` unique (
	`order_id`
);
create index `uct_waste_purchase_branch_id` on `uct_waste_purchase` (
	`branch_id`
);
create index `uct_waste_purchase_idx_state` on `uct_waste_purchase` (
	`state`,
	`createtime`
);



CREATE TABLE `uct_waste_purchase_cargo` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`cate_id` bigint ,
	`cargo_name` varchar(50) not null,
	`total_weight` double precision ,
	`rough_weight` double precision ,
	`net_weight` double precision ,
	`storage_net_weight` double precision ,
	`unit_price` double precision ,
	`total_price` double precision ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_purchase_cargo_pkey primary key ( id )
);

alter table uct_waste_purchase_cargo alter column id add auto_increment;

create index `uct_waste_purchase_cargo_purchase_id` on `uct_waste_purchase_cargo` (
	`purchase_id`
);



CREATE TABLE `uct_waste_purchase_evaluate` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`content` varchar(500) not null,
	`remove_fast_star` int not null,
	`remove_level_star` int not null,
	`service_attitude_star` int not null,
	`linktime` date ,
	`cause` varchar(50) not null,
	`cause_resume` bytea ,
	`conclusion` bytea ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_purchase_evaluate_pkey primary key ( id )
);

alter table uct_waste_purchase_evaluate alter column id add auto_increment;

create index `uct_waste_purchase_evaluate_purchase_id` on `uct_waste_purchase_evaluate` (
	`purchase_id`
);



CREATE TABLE `uct_waste_purchase_expense` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`type` varchar(256) ,
	`usage` varchar(50) not null,
	`remark` varchar(255) not null,
	`price` double precision not null,
	`receiver` varchar(50) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_purchase_expense_pkey primary key ( id )
);

alter table uct_waste_purchase_expense alter column id add auto_increment;




CREATE TABLE `uct_waste_purchase_log` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`purchase_id` bigint not null,
	`title` varchar(100) not null,
	`state_value` varchar(50) not null,
	`state_text` varchar(50) not null,
	`is_timeline_data` varchar(256) ,
	`ip` varchar(50) not null,
	`createtime` bigint ,
	constraint uct_waste_purchase_log_pkey primary key ( id )
);

alter table uct_waste_purchase_log alter column id add auto_increment;

create index `uct_waste_purchase_log_state_value_2` on `uct_waste_purchase_log` (
	`state_value`,
	`createtime`
);
create index `uct_waste_purchase_log_purchase_id_2` on `uct_waste_purchase_log` (
	`purchase_id`,
	`state_value`
);



CREATE TABLE `uct_waste_purchase_materiel` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`materiel_id` bigint ,
	`type` varchar(50) not null,
	`amount` bigint not null,
	`inside_price` double precision not null,
	`pick_amount` bigint ,
	`storage_amount` bigint ,
	`pick_materiel_number` bytea ,
	`storage_materiel_number` bytea ,
	`use_type` int ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_purchase_materiel_pkey primary key ( id )
);

alter table uct_waste_purchase_materiel alter column id add auto_increment;

create index `uct_waste_purchase_materiel_purchase_materiel_t_idx_001` on `uct_waste_purchase_materiel` (
	`purchase_id`,
	`pick_amount`,
	`storage_amount`,
	`inside_price`
);



CREATE TABLE `uct_waste_quote_prices_table` (	
	`id` bigint not null,
	`create_day` varchar(30) ,
	`cate_type` varchar(30) ,
	`region` varchar(30) ,
	`cate_name` varchar(100) ,
	`max_price` decimal(50,2) ,
	`min_price` decimal(50,2) ,
	`rise_fall` varchar(50) ,
	`memo` varchar(255) ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_waste_quote_prices_table_pkey primary key ( id )
);

alter table uct_waste_quote_prices_table alter column id add auto_increment;




CREATE TABLE `uct_waste_report` (	
	`id` bigint not null,
	`customer_id` bigint not null,
	`evaluate_id` bigint not null,
	`evaluate_info` bytea ,
	`stack_problem` varchar(500) ,
	`stack_standard` varchar(500) ,
	`stack_standard_images` varchar(1500) ,
	`detail_type` bytea ,
	`weigh_problem` varchar(1000) ,
	`weigh_standard` varchar(1000) ,
	`produce_deal_problem` varchar(1000) ,
	`collect_deal_problem` varchar(1000) ,
	`sell_deal_problem` varchar(1000) ,
	`deal_standard_images` varchar(1500) ,
	`secret_promise` varchar(1000) ,
	`third_test_company` varchar(100) ,
	`test_fee` double precision ,
	`test_purity` double precision ,
	`changed_recovery` double precision ,
	`problem_summary` varchar(1000) ,
	`improve_way` varchar(1000) ,
	`improved_expect` varchar(1000) ,
	`audit_opinion` varchar(500) not null,
	`is_latest` varchar(256) not null,
	`state` varchar(256) not null,
	`submittime` bigint ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_report_pkey primary key ( id )
);

alter table uct_waste_report alter column id add auto_increment;




CREATE TABLE `uct_waste_report_log` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`report_id` bigint not null,
	`title` varchar(100) not null,
	`state_value` varchar(50) not null,
	`state_text` varchar(50) not null,
	`ip` varchar(50) not null,
	`createtime` bigint ,
	constraint uct_waste_report_log_pkey primary key ( id )
);

alter table uct_waste_report_log alter column id add auto_increment;




CREATE TABLE `uct_waste_sell` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`purchase_id` bigint ,
	`is_move` int ,
	`move_purchase_incharge` bigint ,
	`order_id` varchar(50) not null,
	`customer_id` bigint ,
	`customer_linkman_id` bigint ,
	`seller_id` bigint not null,
	`seller_remark` varchar(255) ,
	`warehouse_id` bigint ,
	`cargo_pick_time` timestamp without time zone ,
	`car_number` varchar(50) ,
	`car_weight` double precision ,
	`cargo_price` double precision ,
	`cargo_weight` double precision ,
	`materiel_price` double precision ,
	`other_price` double precision ,
	`cargo_out_remark` varchar(255) ,
	`pay_way_id` bigint ,
	`customer_evaluate_data` varchar(256) ,
	`seller_evaluate_data` varchar(256) ,
	`state` varchar(256) not null,
	`bill_state` int not null,
	`fzt_state` int not null,
	`print_num` bigint not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_sell_pkey primary key ( id )
);

alter table uct_waste_sell alter column id add auto_increment;

alter table `uct_waste_sell` add constraint `uct_waste_sell_order_id` unique (
	`order_id`
);
create index `uct_waste_sell_branch_id` on `uct_waste_sell` (
	`branch_id`
);



CREATE TABLE `uct_waste_sell_cargo` (	
	`id` bigint not null,
	`sell_id` bigint not null,
	`cate_id` bigint ,
	`plan_sell_weight` double precision ,
	`total_weight` double precision ,
	`rough_weight` double precision ,
	`net_weight` double precision ,
	`unit_price` double precision ,
	`level` varchar(50) ,
	`images` varchar(500) ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_sell_cargo_pkey primary key ( id )
);

alter table uct_waste_sell_cargo alter column id add auto_increment;




CREATE TABLE `uct_waste_sell_customer_evaluate` (	
	`id` bigint not null,
	`sell_id` bigint not null,
	`content` varchar(500) not null,
	`remove_fast_star` int not null,
	`remove_level_star` int not null,
	`service_attitude_star` int not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_sell_customer_evaluate_pkey primary key ( id )
);

alter table uct_waste_sell_customer_evaluate alter column id add auto_increment;




CREATE TABLE `uct_waste_sell_evidence_voucher` (	
	`id` bigint not null,
	`sell_id` bigint ,
	`img_url` json ,
	`active` int ,
	`print_flag` int ,
	`create_at` timestamp without time zone not null,
	`update_at` timestamp without time zone not null,
	constraint uct_waste_sell_evidence_voucher_pkey primary key ( id )
);

alter table uct_waste_sell_evidence_voucher alter column id add auto_increment;




CREATE TABLE `uct_waste_sell_log` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`sell_id` bigint not null,
	`title` varchar(100) not null,
	`state_value` varchar(50) not null,
	`state_text` varchar(50) not null,
	`is_timeline_data` varchar(256) ,
	`ip` varchar(50) not null,
	`createtime` bigint ,
	constraint uct_waste_sell_log_pkey primary key ( id )
);

alter table uct_waste_sell_log alter column id add auto_increment;




CREATE TABLE `uct_waste_sell_materiel` (	
	`id` bigint not null,
	`materiel_id` bigint ,
	`sell_id` bigint not null,
	`type` varchar(50) not null,
	`pick_amount` bigint ,
	`unit_price` double precision ,
	`materiel_number` bytea ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_sell_materiel_pkey primary key ( id )
);

alter table uct_waste_sell_materiel alter column id add auto_increment;




CREATE TABLE `uct_waste_sell_other_price` (	
	`id` bigint not null,
	`sell_id` bigint not null,
	`type` varchar(256) ,
	`usage` varchar(50) not null,
	`remark` varchar(255) not null,
	`price` double precision not null,
	`receiver` varchar(50) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_sell_other_price_pkey primary key ( id )
);

alter table uct_waste_sell_other_price alter column id add auto_increment;




CREATE TABLE `uct_waste_sell_seller_evaluate` (	
	`id` bigint not null,
	`sell_id` bigint not null,
	`content` varchar(500) not null,
	`remove_fast_star` int not null,
	`remove_level_star` int not null,
	`service_attitude_star` int not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_sell_seller_evaluate_pkey primary key ( id )
);

alter table uct_waste_sell_seller_evaluate alter column id add auto_increment;




CREATE TABLE `uct_waste_settings` (	
	`id` bigint not null,
	`group` varchar(50) ,
	`setting_key` bigint ,
	`setting_value` varchar(50) not null,
	`image` varchar(100) ,
	`remark` varchar(100) ,
	`weigh` bigint not null,
	`state` varchar(256) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_settings_pkey primary key ( id )
);

alter table uct_waste_settings alter column id add auto_increment;

create index `uct_waste_settings_group` on `uct_waste_settings` (
	`group`
);



CREATE TABLE `uct_waste_storage` (	
	`id` bigint not null,
	`branch_id` bigint not null,
	`cate_id` bigint not null,
	`origin_storage` double precision not null,
	`storage_weight` double precision not null,
	`purchase_price` double precision not null,
	`recent_sell_weight` double precision not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_storage_pkey primary key ( id )
);

alter table uct_waste_storage alter column id add auto_increment;




CREATE TABLE `uct_waste_storage_audit` (	
	`id` bigint not null,
	`ware_id` bigint ,
	`branch_id` bigint ,
	`finterid` bigint ,
	`order_id` varchar(20) not null,
	`cate_id` bigint ,
	`issue` varchar(255) ,
	`related` varchar(100) ,
	`state` varchar(256) not null,
	`create_at` timestamp without time zone ,
	`updata_at` timestamp without time zone ,
	constraint uct_waste_storage_audit_pkey primary key ( id )
);

alter table uct_waste_storage_audit alter column id add auto_increment;




CREATE TABLE `uct_waste_storage_expense` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`type` varchar(256) ,
	`usage` varchar(50) not null,
	`remark` varchar(255) not null,
	`price` double precision not null,
	`receiver` varchar(50) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_storage_expense_pkey primary key ( id )
);

alter table uct_waste_storage_expense alter column id add auto_increment;




CREATE TABLE `uct_waste_storage_log` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`cate_id` bigint not null,
	`type` varchar(256) not null,
	`change` double precision ,
	`value` double precision ,
	`ip` varchar(50) not null,
	`createtime` bigint ,
	constraint uct_waste_storage_log_pkey primary key ( id )
);

alter table uct_waste_storage_log alter column id add auto_increment;




CREATE TABLE `uct_waste_storage_return_fee` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`type` varchar(256) ,
	`usage` varchar(50) not null,
	`remark` varchar(255) not null,
	`price` double precision not null,
	`receiver` varchar(50) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_storage_return_fee_pkey primary key ( id )
);

alter table uct_waste_storage_return_fee alter column id add auto_increment;

create index `uct_waste_storage_return_fee_storage_return_fee_t_idx_001` on `uct_waste_storage_return_fee` (
	`purchase_id`,
	`price`,
	`usage`
);



CREATE TABLE `uct_waste_storage_sort` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`remark` varchar(255) not null,
	`cargo_sort` bigint ,
	`materiel_number` varchar(50) not null,
	`total_weight` double precision ,
	`rough_weight` double precision ,
	`net_weight` double precision ,
	`presell_price` double precision ,
	`disposal_way` varchar(20) ,
	`value_type` varchar(20) ,
	`sort_time` bigint ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_storage_sort_pkey primary key ( id )
);

alter table uct_waste_storage_sort alter column id add auto_increment;




CREATE TABLE `uct_waste_storage_sort_bak` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`remark` varchar(255) not null,
	`cargo_sort` bigint ,
	`materiel_number` varchar(50) not null,
	`total_weight` double precision ,
	`rough_weight` double precision ,
	`net_weight` double precision ,
	`presell_price` double precision ,
	`sort_time` bigint ,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_storage_sort_bak_pkey primary key ( id )
);

alter table uct_waste_storage_sort_bak alter column id add auto_increment;




CREATE TABLE `uct_waste_storage_sort_expense` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`type` varchar(256) ,
	`usage` varchar(50) not null,
	`remark` varchar(255) not null,
	`price` double precision not null,
	`receiver` varchar(50) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_storage_sort_expense_pkey primary key ( id )
);

alter table uct_waste_storage_sort_expense alter column id add auto_increment;

create index `uct_waste_storage_sort_expense_storage_sort_expense_t_idx_001` on `uct_waste_storage_sort_expense` (
	`purchase_id`,
	`price`,
	`usage`
);



CREATE TABLE `uct_waste_storage_sort_out_group` (	
	`id` bigint not null,
	`purchase_id` bigint not null,
	`usage` varchar(50) not null,
	`remark` varchar(255) not null,
	`weight` decimal(10,2) not null,
	`receiver` varchar(50) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_storage_sort_out_group_pkey primary key ( id )
);

alter table uct_waste_storage_sort_out_group alter column id add auto_increment;




CREATE TABLE `uct_waste_warehouse` (	
	`id` bigint not null,
	`admin_id` bigint ,
	`ids` varchar(50) ,
	`parent_id` bigint not null,
	`branch_id` bigint not null,
	`name` varchar(100) not null,
	`province` varchar(50) not null,
	`city` varchar(50) not null,
	`area` varchar(50) not null,
	`detail_address` varchar(255) not null,
	`capacity` decimal(10,2) ,
	`weigh` bigint not null,
	`state` varchar(256) not null,
	`createtime` bigint ,
	`updatetime` bigint ,
	constraint uct_waste_warehouse_pkey primary key ( id )
);

alter table uct_waste_warehouse alter column id add auto_increment;

create index `uct_waste_warehouse_uct_waste_warehouse_idx_001` on `uct_waste_warehouse` (
	`parent_id`
);
create index `uct_waste_warehouse_uct_waste_warehouse_idx_002` on `uct_waste_warehouse` (
	`branch_id`
);



CREATE TABLE `uct_wechat_applet` (	
	`id` bigint not null,
	`admin_id` bigint not null,
	`appletid` varchar(50) not null,
	`name` varchar(100) not null,
	`typedata` varchar(256) not null,
	`token` varchar(100) not null,
	`appid` varchar(255) not null,
	`appsecret` varchar(255) ,
	`aeskey` varchar(255) ,
	`mchid` varchar(50) ,
	`mchkey` varchar(50) ,
	`notify_url` varchar(255) ,
	`principal` varchar(100) ,
	`original` varchar(50) ,
	`wechat` varchar(50) ,
	`headface_image` varchar(255) ,
	`qrcode_image` varchar(255) ,
	`signature` bytea ,
	`city` varchar(50) ,
	`state` varchar(256) not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`deletetime` bigint ,
	`weigh` bigint not null,
	constraint uct_wechat_applet_pkey primary key ( id )
);

alter table uct_wechat_applet alter column id add auto_increment;




CREATE TABLE `uct_wechat_autoreply` (	
	`id` bigint not null,
	`appletid` varchar(50) not null,
	`title` varchar(100) not null,
	`text` varchar(100) not null,
	`eventkey` varchar(50) not null,
	`remark` varchar(255) not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`status` varchar(30) not null,
	constraint uct_wechat_autoreply_pkey primary key ( id )
);

alter table uct_wechat_autoreply alter column id add auto_increment;




CREATE TABLE `uct_wechat_config` (	
	`id` bigint not null,
	`appletid` varchar(50) not null,
	`name` varchar(50) not null,
	`title` varchar(50) not null,
	`value` bytea not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	constraint uct_wechat_config_pkey primary key ( id )
);

alter table uct_wechat_config alter column id add auto_increment;




CREATE TABLE `uct_wechat_context` (	
	`id` bigint not null,
	`openid` varchar(64) not null,
	`type` varchar(30) not null,
	`eventkey` varchar(64) not null,
	`command` varchar(64) not null,
	`message` varchar(255) not null,
	`refreshtime` bigint not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	constraint uct_wechat_context_pkey primary key ( id )
);

alter table uct_wechat_context alter column id add auto_increment;

create index `uct_wechat_context_openid` on `uct_wechat_context` (
	`openid`
);



CREATE TABLE `uct_wechat_response` (	
	`id` bigint not null,
	`appletid` varchar(50) not null,
	`title` varchar(100) not null,
	`eventkey` varchar(128) not null,
	`type` varchar(256) not null,
	`content` bytea not null,
	`remark` varchar(255) not null,
	`createtime` bigint not null,
	`updatetime` bigint not null,
	`status` varchar(30) not null,
	constraint uct_wechat_response_pkey primary key ( id )
);

alter table uct_wechat_response alter column id add auto_increment;

alter table `uct_wechat_response` add constraint `uct_wechat_response_event` unique (
	`eventkey`
);



