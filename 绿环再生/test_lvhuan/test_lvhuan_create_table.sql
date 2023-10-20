CREATE TABLE `202203160705` (
  `审批编号` varchar(255) DEFAULT NULL,
  `标题` varchar(255) DEFAULT NULL,
  `发起时间` varchar(255) DEFAULT NULL,
  `完成时间` varchar(255) DEFAULT NULL,
  `耗时(时:分:秒)` varchar(255) DEFAULT NULL,
  `发起人姓名` varchar(255) DEFAULT NULL,
  `发起人部门` varchar(255) DEFAULT NULL,
  `历史审批人姓名` varchar(255) DEFAULT NULL,
  `当前处理人姓名` varchar(255) DEFAULT NULL,
  `批次号` varchar(255) DEFAULT NULL,
  `申请人` varchar(255) DEFAULT NULL,
  `是否包含临时计划` varchar(255) DEFAULT NULL,
  `销售计划明细` varchar(255) DEFAULT NULL,
  `销售计划编号` varchar(255) DEFAULT NULL,
  `销售客户` varchar(255) DEFAULT NULL,
  `重点关注客户` varchar(255) DEFAULT NULL,
  `销售货品` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `无标题` (
  `FinterID` varchar(255) DEFAULT NULL,
  `FTranType` varchar(255) DEFAULT NULL,
  `FEntryID` varchar(255) DEFAULT NULL,
  `FItemID` varchar(255) DEFAULT NULL,
  `FUnitID` varchar(255) DEFAULT NULL,
  `FQty` varchar(255) DEFAULT NULL,
  `FPrice` varchar(255) DEFAULT NULL,
  `FAmount` varchar(255) DEFAULT NULL,
  `disposal_way` varchar(255) DEFAULT NULL,
  `value_type` varchar(255) DEFAULT NULL,
  `FbasePrice` varchar(255) DEFAULT NULL,
  `FbaseAmount` varchar(255) DEFAULT NULL,
  `Ftaxrate` varchar(255) DEFAULT NULL,
  `Fbasetax` varchar(255) DEFAULT NULL,
  `Fbasetaxamount` varchar(255) DEFAULT NULL,
  `FPriceRef` varchar(255) DEFAULT NULL,
  `FDCTime` varchar(255) DEFAULT NULL,
  `FSourceInterId` varchar(255) DEFAULT NULL,
  `FSourceTranType` varchar(255) DEFAULT NULL,
  `red_ink_time` varchar(255) DEFAULT NULL,
  `is_hedge` varchar(255) DEFAULT NULL,
  `revise_state` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `accoding_fee_list` (
  `FBillNo` varchar(50) DEFAULT NULL,
  `FFeeID` varchar(50) DEFAULT NULL,
  `FFeeType` varchar(3) DEFAULT NULL,
  `FFeePerson` varchar(50) DEFAULT NULL,
  `FFeeAmount` float(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `accoding_stock_history` (
  `FRelateBrID` int(11) NOT NULL COMMENT '分部id',
  `FStockID` varchar(20) NOT NULL COMMENT '仓库id',
  `FItemID` int(11) NOT NULL COMMENT '废料id',
  `FDCQty` decimal(10,1) NOT NULL,
  `FSCQty` decimal(10,1) NOT NULL,
  `FdifQty` int(11) NOT NULL,
  `FDCTime` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `accoding_stock_iod_table` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL COMMENT '分部ID',
  `FStockID` varchar(13) DEFAULT NULL,
  `FItemID` int(11) unsigned DEFAULT NULL COMMENT '物料ID',
  `FDCQty` double DEFAULT NULL COMMENT '入库重量',
  `FSCQty` double DEFAULT NULL COMMENT '出库重量',
  `FdifQty` double DEFAULT NULL COMMENT '调账重量',
  `FDCTime` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `accoding_stock_snapshot` (
  `time_dims` varchar(20) NOT NULL COMMENT '时间维度',
  `time_val` varchar(20) NOT NULL COMMENT '时间数值',
  `begin_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `FRelateBrID` int(10) NOT NULL COMMENT '分部id',
  `FStockID` varchar(50) NOT NULL COMMENT '仓库id',
  `FItemID` int(10) NOT NULL COMMENT '品类id',
  `FDCQty` decimal(10,1) NOT NULL DEFAULT '0.0' COMMENT '入库重量',
  `FSCQty` decimal(10,1) NOT NULL DEFAULT '0.0' COMMENT '出库重量',
  `FinventoryQty` decimal(10,1) NOT NULL DEFAULT '0.0' COMMENT '库存重量',
  `FdifQty` decimal(10,1) NOT NULL DEFAULT '0.0' COMMENT '调账重量',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updata_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY `idx_id` (`FRelateBrID`,`FStockID`,`FItemID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库的出入库的结存数据（月、星期、年、季度）';
CREATE TABLE `acconding_cargo_list` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FBillNo` varchar(50) DEFAULT NULL,
  `FSupplyID` int(11) unsigned DEFAULT NULL,
  `FItemID` int(11) unsigned DEFAULT NULL,
  `PUR_log` text,
  `PUR_FQty` double(18,1) DEFAULT NULL,
  `PUR_FAmount` double(19,2) DEFAULT NULL,
  `SOR_log` text,
  `SOR_FQty` double(18,1) DEFAULT NULL,
  `SOR_FAmount` double(19,2) DEFAULT NULL,
  `weight_loss` double(18,1) DEFAULT NULL,
  `purchase_time` varchar(10) DEFAULT NULL,
  `sort_time` varchar(10) DEFAULT NULL,
  `Fbusiness` varchar(11) DEFAULT NULL,
  `FEmpID` int(11) unsigned DEFAULT NULL,
  `FSaleStyle` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `acconding_total` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FBillNo` varchar(50) DEFAULT NULL,
  `FSupplyID` varchar(11) DEFAULT NULL,
  `FDate` varchar(24) DEFAULT NULL,
  `FNowState` varchar(28) DEFAULT NULL,
  `PUR_TalFQty` double DEFAULT NULL,
  `PUR_TalFAmount` double DEFAULT NULL,
  `SOR_TalFQty` double DEFAULT NULL,
  `SOR_TalFAmount` double DEFAULT NULL,
  `weight_loss` double(18,1) DEFAULT NULL,
  `Total_profit` double(20,3) DEFAULT NULL,
  `purchase_expense` double(20,3) DEFAULT NULL,
  `car_fee` double(20,3) DEFAULT NULL,
  `man_fee` double(20,3) DEFAULT NULL,
  `sort_fee` double(20,3) DEFAULT NULL,
  `materiel_fee` double(20,3) DEFAULT NULL,
  `other_return_fee` double(20,3) DEFAULT NULL,
  `other_sort_fee` double(20,3) DEFAULT NULL,
  `materiel_price` double(20,3) DEFAULT NULL,
  `other_price` double(20,3) DEFAULT NULL,
  `Fbusiness` varchar(11) DEFAULT NULL,
  `FDeptID` int(11) DEFAULT NULL,
  `FEmpID` int(11) unsigned DEFAULT NULL,
  `FSaleStyle` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `cs_aaa` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `month` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `cus_null_createtime` (
  `cus_id` int(11) NOT NULL,
  `createtime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `datawall_conitem` (
  `FRelateBrID` int(10) unsigned DEFAULT NULL,
  `parent_id` int(10) unsigned DEFAULT NULL,
  `conTalFQty` double(18,1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `datawall_contrash` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `TalFQty` double(18,1) DEFAULT NULL,
  `TraFQty` double DEFAULT NULL,
  `FDate` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `datawall_pss` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `PUR_tal` double(18,1) DEFAULT NULL,
  `SOR_tal` double(18,1) DEFAULT NULL,
  `SEL_tal` double(18,1) DEFAULT NULL,
  `FDate` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `demo_using` (
  `id` int(11) NOT NULL,
  `psw` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `age` tinyint(4) DEFAULT NULL,
  `sex` tinyint(4) DEFAULT NULL,
  `create_time` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `dingtalk_application_info` (
  `agentid` varchar(20) NOT NULL COMMENT '钉钉应用id',
  `corpid` varchar(50) NOT NULL COMMENT '企业群组关联id',
  `appkey` varchar(50) NOT NULL COMMENT '钉钉应用主键',
  `appsecret` varchar(100) NOT NULL COMMENT '钉钉应用密钥',
  `token` varchar(10) NOT NULL COMMENT '钉钉回调凭证',
  `aeskey` varchar(50) NOT NULL COMMENT '钉钉回调密钥',
  `url` varchar(128) NOT NULL COMMENT '应用回调地址',
  `call_back_tap` varchar(100) NOT NULL COMMENT '应用回调事件',
  `status` enum('enabled','disabled') NOT NULL,
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`agentid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `dingtalk_book_dep_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dep_id` int(11) DEFAULT NULL COMMENT '部门id',
  `parent_id` int(11) DEFAULT NULL COMMENT '父id',
  `name` varchar(30) DEFAULT NULL COMMENT '部门名称',
  `state` int(5) DEFAULT '0' COMMENT '状态：0--中间结点  1--叶子结点  2--删除结点',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dep_id` (`dep_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COMMENT='通讯录的部门表';
CREATE TABLE `dingtalk_book_user_info` (
  `userid` bigint(50) NOT NULL COMMENT '员工的userid',
  `unionid` varchar(50) DEFAULT NULL COMMENT '员工在当前开发者企业账号范围内的唯一标识。',
  `wechat_id` varchar(50) DEFAULT NULL COMMENT '员工的企业微信id',
  `admin_id_group` varchar(50) DEFAULT '0' COMMENT '员工的admin_id组',
  `dept_id` int(11) DEFAULT NULL COMMENT '部门id',
  `parent_id` int(11) DEFAULT NULL COMMENT '父部门id',
  `top_dept` int(11) DEFAULT NULL COMMENT '顶级部门id',
  `name` varchar(20) DEFAULT NULL COMMENT '员工的姓名',
  `mobile` bigint(20) NOT NULL COMMENT '员工的手机号',
  `user_data` varchar(4096) DEFAULT NULL COMMENT '员工的json数据',
  `state` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态: 1--正常使用  0--离职',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`userid`) USING BTREE,
  UNIQUE KEY `unionid` (`unionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='钉钉的通讯录用户的信息';
CREATE TABLE `dingtalk_exterpayment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `process_id` varchar(25) NOT NULL COMMENT '审批单号',
  `apply_branch` varchar(50) DEFAULT NULL COMMENT '申请部门',
  `apply_type` varchar(50) DEFAULT NULL COMMENT '付款方式',
  `payment_type` varchar(50) DEFAULT NULL COMMENT '付款事项',
  `pay_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '付款金额',
  `reason` text COMMENT '付款理由',
  `recipient` varchar(20) DEFAULT NULL COMMENT '支付对象',
  `process_state` varchar(20) DEFAULT NULL COMMENT '审批状态',
  `process_result` varchar(20) DEFAULT NULL COMMENT '审批结果',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `process_id` (`process_id`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8;
CREATE TABLE `dingtalk_failed_to_push_list` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `call_back_tag` varchar(100) NOT NULL COMMENT '失败回调事件tag',
  `corpid` varchar(50) NOT NULL COMMENT '回调失败数据所属corpid',
  `agentid` int(10) NOT NULL DEFAULT '0' COMMENT 'agent_id',
  `event_time` bigint(13) NOT NULL COMMENT '事件的时间戳',
  `state` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态: 0--失败的回调   1--成功的回调    2-再次回调失败',
  `event_json` varchar(8192) NOT NULL COMMENT '推送失败事件的json',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建的时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改的时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=154 DEFAULT CHARSET=utf8mb4 COMMENT='推送失败的事件列表';
CREATE TABLE `dingtalk_process_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agentid` varchar(20) NOT NULL COMMENT '应用关联ID',
  `processtype` varchar(32) NOT NULL COMMENT '审批实例类型',
  `processcode` varchar(100) NOT NULL COMMENT '审批实例模版ID',
  `status` enum('enabled','disabled') NOT NULL,
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8;
CREATE TABLE `dingtalk_process_log` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `process_id` varchar(25) NOT NULL COMMENT '审批单号',
  `process_type` varchar(20) NOT NULL COMMENT '审批类型',
  `applicant_dingtalk_id` varchar(20) NOT NULL COMMENT '申请人钉钉ID',
  `applicant` varchar(20) NOT NULL COMMENT '申请人姓名',
  `data` text COMMENT '关键信息',
  `precess_result` varchar(10) NOT NULL COMMENT '审批结果',
  `process_createTime` varchar(24) NOT NULL COMMENT '审批生成时间',
  `process_finishTime` varchar(24) NOT NULL COMMENT '审批完成时间',
  `remark` varchar(100) NOT NULL COMMENT '审批原因说明',
  `createAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=563 DEFAULT CHARSET=utf8;
CREATE TABLE `dingtalk_resource_info` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `agentid` varchar(20) NOT NULL COMMENT '应用关联ID',
  `resourcetype` varchar(20) NOT NULL COMMENT '钉钉资源类型',
  `resourcecode` varchar(100) NOT NULL COMMENT '钉钉资源编码',
  `status` enum('enabled','disabled') NOT NULL COMMENT '状态',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
CREATE TABLE `dingtalk_visual_dept_num` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) DEFAULT NULL COMMENT '分部ID',
  `dept_id` int(11) DEFAULT NULL COMMENT '部门的钉钉id',
  `dept_child_id` varchar(100) DEFAULT NULL COMMENT '子部门的钉钉id',
  `dept_name` varchar(100) DEFAULT NULL COMMENT '部门的名称',
  `user_num` int(11) DEFAULT NULL COMMENT '部门员工的数量',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COMMENT='绿环固废信息化管理平台---可视化大数据---钉钉部门成员数量表';
CREATE TABLE `ec_admin` (
  `userId` varchar(25) DEFAULT NULL,
  `deptId` varchar(25) DEFAULT NULL,
  `userName` varchar(12) DEFAULT NULL,
  `account` varchar(15) DEFAULT NULL,
  `title` varchar(15) DEFAULT NULL,
  `discard` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `ec_down_customer` (
  `crmId` bigint(20) NOT NULL DEFAULT '0' COMMENT '客户crmid',
  `name` varchar(20) DEFAULT NULL COMMENT '客户姓名',
  `mobile` varchar(20) DEFAULT NULL COMMENT '手机号码',
  `company` varchar(255) DEFAULT NULL COMMENT '客户公司名称',
  `follow_crmid` varchar(255) DEFAULT NULL COMMENT 'crmid',
  `follow_id` int(11) DEFAULT NULL COMMENT '业务归属人id',
  `follow_nickname` varchar(255) DEFAULT NULL COMMENT '业务归属人昵称'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `ec_up_customer` (
  `crmId` bigint(20) NOT NULL DEFAULT '0' COMMENT '客户crmid',
  `name` varchar(20) DEFAULT NULL COMMENT '客户姓名',
  `mobile` varchar(20) DEFAULT NULL COMMENT '手机号码',
  `company` varchar(255) DEFAULT NULL COMMENT '客户公司名称',
  `follow_crmid` varchar(255) DEFAULT NULL COMMENT 'crmid',
  `follow_id` int(11) DEFAULT NULL COMMENT '业务归属人id',
  `branch_name` varchar(255) DEFAULT NULL COMMENT '分部名称',
  `service_department` varchar(255) DEFAULT NULL COMMENT '部门',
  `follow_nickname` varchar(255) DEFAULT NULL COMMENT '业务归属人昵称'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `pdman_db_version` (
  `DB_VERSION` varchar(256) DEFAULT NULL,
  `VERSION_DESC` varchar(1024) DEFAULT NULL,
  `CREATED_TIME` varchar(32) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `performance_result_admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) NOT NULL COMMENT '分部归属',
  `userid` varchar(50) DEFAULT NULL COMMENT '钉钉userid',
  `period` varchar(20) DEFAULT NULL COMMENT '考核周期',
  `level` varchar(20) DEFAULT NULL COMMENT '绩效层级',
  `performance_id` int(11) DEFAULT NULL COMMENT '指标ID',
  `weight` tinyint(4) DEFAULT NULL COMMENT '权重',
  `baseline` decimal(10,3) DEFAULT NULL COMMENT '基准值',
  `varDaily` text COMMENT '日变动',
  `reference` decimal(10,3) DEFAULT NULL COMMENT '参考值',
  `actualize` decimal(10,3) DEFAULT NULL COMMENT '实际值',
  `score` tinyint(4) DEFAULT NULL COMMENT '分值',
  `status` enum('running','finish') DEFAULT 'running' COMMENT '考核状态',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `performance_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class` varchar(20) NOT NULL COMMENT '模板类型',
  `name` varchar(20) NOT NULL COMMENT '指标名称',
  `unit` varchar(20) NOT NULL COMMENT '单位',
  `create time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `table_replace` (
  `FInterID` int(11) NOT NULL DEFAULT '0',
  `FTranType` varchar(3) NOT NULL,
  `FFeeAmount` float(10,2) DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `test_table` (
  `FRelateBrID` varchar(20) NOT NULL,
  `FBillNo` varchar(20) NOT NULL,
  `FItemID` int(11) NOT NULL,
  `FQty` float(10,1) NOT NULL,
  `FPrice` float(10,2) NOT NULL,
  `FAmount` float(10,3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `tool_distribute_detail` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `distribute_id` int(10) NOT NULL COMMENT '分发记录ID',
  `task_id` varchar(20) NOT NULL COMMENT '企业微信任务ID',
  `receivePersonID` varchar(50) NOT NULL COMMENT '接收人ERP_ID',
  `receivePerson` varchar(10) NOT NULL COMMENT '接收人姓名',
  `receivePersonWechat` varchar(50) NOT NULL COMMENT '接收人企业微信ID',
  `receiveFile_url` varchar(512) NOT NULL COMMENT '分发文件的路径',
  `dataRows` int(10) NOT NULL COMMENT '分发文件的记录行数',
  `sendActStatus` tinyint(3) NOT NULL DEFAULT '0' COMMENT '发送状态',
  `feedbackStatus` tinyint(3) NOT NULL DEFAULT '0' COMMENT '回复状态',
  `feedbackTime` datetime DEFAULT NULL COMMENT '回复时间',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=296 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `tool_distribute_main` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sendPersonID` varchar(50) NOT NULL COMMENT '发送人ID',
  `sendPerson` varchar(10) NOT NULL COMMENT '发送人姓名',
  `file_name` varchar(50) NOT NULL COMMENT '文件名',
  `file_url` varchar(512) NOT NULL COMMENT '文件路径',
  `dataRows` int(10) NOT NULL COMMENT '记录行数',
  `receiveTotal` int(10) NOT NULL COMMENT '接收人数',
  `sendActTotal` int(10) NOT NULL DEFAULT '0' COMMENT '发送数',
  `feedbackTotal` int(10) NOT NULL DEFAULT '0' COMMENT '回复数',
  `distributeTime` datetime DEFAULT NULL COMMENT '分发时间',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `trans_assist_table` (
  `FinterID` int(11) unsigned NOT NULL DEFAULT '0',
  `FTranType` varchar(3) DEFAULT '',
  `FEntryID` int(11) unsigned DEFAULT '0',
  `FItemID` int(11) unsigned DEFAULT NULL,
  `FUnitID` varchar(1) DEFAULT '',
  `FQty` float DEFAULT NULL,
  `FPrice` float DEFAULT NULL,
  `FAmount` double(19,2) DEFAULT NULL,
  `disposal_way` varchar(20) DEFAULT 'sorting' COMMENT '分拣属性： weighing -- 称重  sorting -- 分拣  correction -- 调账',
  `value_type` varchar(20) DEFAULT 'valuable' COMMENT '价值类型',
  `FbasePrice` char(1) DEFAULT '',
  `FbaseAmount` char(1) DEFAULT '',
  `Ftaxrate` char(1) DEFAULT '',
  `Fbasetax` char(1) DEFAULT '',
  `Fbasetaxamount` char(1) DEFAULT '',
  `FPriceRef` char(1) DEFAULT '',
  `FDCTime` varchar(24) DEFAULT NULL,
  `FSourceInterId` varchar(11) DEFAULT NULL,
  `FSourceTranType` varchar(3) DEFAULT '',
  `red_ink_time` timestamp NULL DEFAULT NULL,
  `is_hedge` tinyint(4) DEFAULT '0' COMMENT '是否为对冲数据：0-否 1-是',
  `revise_state` tinyint(4) DEFAULT '0' COMMENT '0:常规状态  1:被修改状态  2:新增状态 ',
  `bill_state` tinyint(4) DEFAULT '0' COMMENT '结算状态 0待结算 1已结算',
  KEY `FinterID` (`FinterID`) USING BTREE,
  KEY `FTranType` (`FTranType`) USING BTREE,
  KEY `FinterID_2` (`FinterID`,`FTranType`,`FItemID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_assist_table_bak` (
  `FinterID` varchar(255) DEFAULT NULL,
  `FTranType` varchar(255) DEFAULT NULL,
  `FEntryID` varchar(255) DEFAULT NULL,
  `FItemID` varchar(255) DEFAULT NULL,
  `FUnitID` varchar(255) DEFAULT NULL,
  `FQty` varchar(255) DEFAULT NULL,
  `FPrice` varchar(255) DEFAULT NULL,
  `FAmount` varchar(255) DEFAULT NULL,
  `disposal_way` varchar(255) DEFAULT NULL,
  `value_type` varchar(255) DEFAULT NULL,
  `FbasePrice` varchar(255) DEFAULT NULL,
  `FbaseAmount` varchar(255) DEFAULT NULL,
  `Ftaxrate` varchar(255) DEFAULT NULL,
  `Fbasetax` varchar(255) DEFAULT NULL,
  `Fbasetaxamount` varchar(255) DEFAULT NULL,
  `FPriceRef` varchar(255) DEFAULT NULL,
  `FDCTime` varchar(255) DEFAULT NULL,
  `FSourceInterId` varchar(255) DEFAULT NULL,
  `FSourceTranType` varchar(255) DEFAULT NULL,
  `red_ink_time` varchar(255) DEFAULT NULL,
  `is_hedge` varchar(255) DEFAULT NULL,
  `revise_state` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `trans_constitute_forcustomer` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FSupplyID` int(11) unsigned DEFAULT NULL,
  `Fbusiness` varchar(11) DEFAULT NULL,
  `parent_id` int(10) unsigned DEFAULT NULL,
  `FQty` double(19,2) DEFAULT NULL,
  `carbon_parm` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_constitute_forcustomer_table` (
  `FRelateBrID` int(11) NOT NULL DEFAULT '0' COMMENT '分部ID',
  `FSupplyD` int(11) DEFAULT NULL COMMENT '客户ID',
  `Fbusiness` varchar(11) DEFAULT NULL COMMENT '业务归属人',
  `parent_id` int(10) NOT NULL DEFAULT '0' COMMENT '二级分类ID',
  `FQty` double(19,2) DEFAULT NULL COMMENT '重量',
  `FCarbon` float NOT NULL COMMENT '碳减排参数'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_daily_invfordep` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FDeptID` varchar(11) DEFAULT NULL,
  `trash_is` varchar(1) DEFAULT NULL,
  `input` double(18,1) DEFAULT NULL,
  `output` double(18,1) DEFAULT NULL,
  `FDCTime` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_daily_invfordep_table` (
  `FRelateBrID` int(11) NOT NULL,
  `FDeptID` varchar(11) DEFAULT NULL,
  `trash_is` varchar(1) NOT NULL,
  `input` double(18,1) DEFAULT NULL,
  `output` double(18,1) DEFAULT NULL,
  `FDCTime` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_daily_sel` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FItemID` text,
  `total_weight` double(18,1) DEFAULT NULL,
  `total_price` double(19,2) DEFAULT NULL,
  `count_order` bigint(21) DEFAULT NULL,
  `FDate` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_daily_sel_table` (
  `FRelateBrID` int(11) NOT NULL DEFAULT '0',
  `FItemID` text,
  `total_weight` double(18,1) DEFAULT NULL,
  `total_price` double(19,2) DEFAULT NULL,
  `count_order` bigint(21) NOT NULL DEFAULT '0',
  `FDate` varchar(24) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_daily_sor` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FInterID` int(11) unsigned DEFAULT NULL,
  `FDate` varchar(24) DEFAULT NULL,
  `FSupplyID` int(11) unsigned DEFAULT NULL,
  `Fbusiness` varchar(11) DEFAULT NULL,
  `FDeptID` varchar(11) DEFAULT NULL,
  `FEmpID` int(11) unsigned DEFAULT NULL,
  `FPOStyle` varchar(11) DEFAULT NULL,
  `FPOPrecent` varchar(11) DEFAULT NULL,
  `profit` double(19,2) DEFAULT NULL,
  `weight` double(18,1) DEFAULT NULL,
  `transport_pay` double(19,2) DEFAULT NULL,
  `classify_pay` double(19,2) DEFAULT NULL,
  `material_pay` double(19,2) DEFAULT NULL,
  `total_pay` double(19,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_daily_sor_table` (
  `FRelateBrID` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '分部ID',
  `FInterID` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '订单内码',
  `FDate` varchar(24) DEFAULT NULL COMMENT '订单日期',
  `FSupplyID` int(11) unsigned DEFAULT NULL COMMENT '客户内码',
  `Fbusiness` varchar(11) DEFAULT NULL COMMENT '业务归属人',
  `FDeptID` varchar(11) DEFAULT NULL COMMENT '部门内码',
  `FEmpID` int(11) unsigned DEFAULT NULL COMMENT '采购负责人',
  `FPOStyle` varchar(11) DEFAULT NULL COMMENT '结算方式',
  `FPOPrecent` varchar(11) DEFAULT NULL COMMENT '结算比例',
  `profit` double(19,2) DEFAULT NULL COMMENT '毛利润',
  `weight` double(18,1) DEFAULT NULL COMMENT '总净重',
  `transport_pay` double(19,2) DEFAULT NULL COMMENT '运输支出',
  `classify_pay` double(19,2) DEFAULT NULL COMMENT '分拣支出',
  `material_pay` double(19,2) DEFAULT NULL COMMENT '耗材支出',
  `total_pay` double(19,2) DEFAULT NULL COMMENT '合计支出'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_daily_wh_profit` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FFeeID` varchar(50) DEFAULT NULL,
  `FFeeType` varchar(3) DEFAULT NULL,
  `FFeePerson` varchar(50) DEFAULT NULL,
  `FFeeAmount` double(19,2) DEFAULT NULL,
  `FFeebaseAmount` char(0) DEFAULT NULL,
  `Ftaxrate` char(0) DEFAULT NULL,
  `Fbasetax` char(0) DEFAULT NULL,
  `Fbasetaxamount` char(0) DEFAULT NULL,
  `FPriceRef` char(0) DEFAULT NULL,
  `FFeetime` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_daily_wh_profit_table` (
  `FRelateBrID` int(11) unsigned NOT NULL DEFAULT '0',
  `FFeeID` varchar(50) NOT NULL,
  `FFeeType` varchar(3) DEFAULT NULL,
  `FFeePerson` varchar(50) NOT NULL,
  `FFeeAmount` double(19,2) DEFAULT NULL,
  `FFeebaseAmount` char(0) NOT NULL,
  `Ftaxrate` char(0) NOT NULL,
  `Fbasetax` char(0) NOT NULL,
  `Fbasetaxamount` char(0) NOT NULL,
  `FPriceRef` char(0) NOT NULL,
  `FFeetime` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_fee_table` (
  `FInterID` int(11) unsigned NOT NULL DEFAULT '0',
  `FTranType` varchar(3) DEFAULT '',
  `Ffeesence` varchar(2) DEFAULT '',
  `FEntryID` int(11) unsigned DEFAULT '0',
  `FFeeID` varchar(50) DEFAULT '',
  `FFeeType` varchar(8) DEFAULT NULL,
  `FFeePerson` varchar(50) DEFAULT '',
  `FFeeExplain` varchar(255) DEFAULT '',
  `FFeeAmount` float(10,2) DEFAULT '0.00',
  `FFeebaseAmount` char(1) DEFAULT '',
  `Ftaxrate` char(1) DEFAULT '',
  `Fbasetax` char(1) DEFAULT '',
  `Fbasetaxamount` char(1) DEFAULT '',
  `FPriceRef` char(1) DEFAULT '',
  `FFeetime` varchar(24) DEFAULT NULL,
  `red_ink_time` timestamp NULL DEFAULT NULL,
  `is_hedge` tinyint(4) DEFAULT '0' COMMENT '是否为对冲数据 0否 1是',
  `revise_state` tinyint(4) DEFAULT '0' COMMENT '0:常规状态  1:被修改状态  2:新增状态',
  `bill_state` tinyint(4) DEFAULT '0' COMMENT '结算状态 0待结算 1已结算',
  KEY `FInterID` (`FInterID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_forcustomer` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FSupplyID` int(11) unsigned DEFAULT NULL,
  `Fbusiness` varchar(11) DEFAULT NULL,
  `total_weight` double(18,1) DEFAULT NULL,
  `total_profit` double(19,2) DEFAULT NULL,
  `FDate` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_forcustomer_table` (
  `FRelateBrID` int(11) unsigned NOT NULL DEFAULT '0',
  `FSupplyID` int(11) unsigned DEFAULT NULL,
  `Fbusiness` varchar(11) DEFAULT NULL,
  `total_weight` double(18,1) DEFAULT NULL,
  `total_profit` double(19,2) DEFAULT NULL,
  `FDate` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_fororder` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FDeptID` varchar(11) DEFAULT NULL,
  `order_count` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_log_table` (
  `FInterID` int(11) unsigned NOT NULL DEFAULT '0',
  `FTranType` varchar(3) NOT NULL DEFAULT '',
  `TCreate` int(20) unsigned DEFAULT NULL,
  `TCreatePerson` int(20) unsigned DEFAULT NULL,
  `TallotOver` varchar(10) DEFAULT NULL,
  `TallotPerson` varchar(20) DEFAULT NULL,
  `Tallot` varchar(20) DEFAULT NULL,
  `TgetorderOver` varchar(10) DEFAULT NULL,
  `TgetorderPerson` varchar(20) DEFAULT NULL,
  `Tgetorder` varchar(20) DEFAULT NULL,
  `TmaterialOver` varchar(10) DEFAULT NULL,
  `TmaterialPerson` varchar(20) DEFAULT NULL,
  `Tmaterial` varchar(20) DEFAULT NULL,
  `TpurchaseOver` varchar(10) DEFAULT NULL,
  `TpurchasePerson` varchar(10) DEFAULT NULL,
  `Tpurchase` varchar(10) DEFAULT NULL,
  `TpayOver` varchar(10) DEFAULT NULL,
  `TpayPerson` varchar(10) DEFAULT NULL,
  `Tpay` varchar(10) DEFAULT NULL,
  `TchangeOver` varchar(10) DEFAULT NULL,
  `TchangePerson` varchar(20) DEFAULT NULL,
  `Tchange` varchar(20) DEFAULT NULL,
  `TexpenseOver` varchar(10) DEFAULT NULL,
  `TexpensePerson` varchar(10) DEFAULT NULL,
  `Texpense` varchar(10) DEFAULT NULL,
  `TsortOver` varchar(10) DEFAULT NULL,
  `TsortPerson` varchar(10) DEFAULT NULL,
  `Tsort` varchar(10) DEFAULT NULL,
  `TallowOver` varchar(10) DEFAULT NULL,
  `TallowPerson` varchar(20) DEFAULT NULL,
  `Tallow` varchar(20) DEFAULT NULL,
  `TcheckOver` varchar(10) DEFAULT NULL,
  `TcheckPerson` varchar(10) DEFAULT NULL,
  `Tcheck` varchar(10) DEFAULT NULL,
  `state` varchar(28) NOT NULL DEFAULT '',
  KEY `FInterID_FTranType` (`FInterID`,`FTranType`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_main_table` (
  `FRelateBrID` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '分部ID',
  `FInterID` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '订单内码ID',
  `FTranType` varchar(3) NOT NULL DEFAULT '' COMMENT '订单类型',
  `FDate` varchar(24) DEFAULT NULL COMMENT '订单生成日期',
  `createtime` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `Date` date DEFAULT NULL COMMENT '年月日',
  `FTrainNum` varchar(10) DEFAULT NULL COMMENT '车次',
  `FBillNo` varchar(50) NOT NULL DEFAULT '' COMMENT '订单号',
  `FSupplyID` int(11) unsigned DEFAULT NULL COMMENT '客户ID',
  `Fbusiness` varchar(11) DEFAULT NULL COMMENT '业务归属ID',
  `FDCStockID` varchar(12) DEFAULT NULL COMMENT '出库库房',
  `FSCStockID` varchar(12) DEFAULT NULL COMMENT '入库库房',
  `FCancellation` varchar(3) NOT NULL DEFAULT '' COMMENT '取消状态 0取消 1正常',
  `FROB` char(1) NOT NULL DEFAULT '' COMMENT '红蓝单',
  `FCorrent` varchar(1) NOT NULL DEFAULT '' COMMENT '可修改状态  0订单未完成 1订单完成',
  `FStatus` int(11) NOT NULL COMMENT '审核状态',
  `FUpStockWhenSave` varchar(1) DEFAULT NULL COMMENT '更新库存',
  `FExplanation` varchar(100) NOT NULL DEFAULT '' COMMENT '备注',
  `FDeptID` int(11) NOT NULL COMMENT '部门ID',
  `FEmpID` int(11) unsigned DEFAULT NULL COMMENT '订单负责人ID',
  `FCheckerID` varchar(10) DEFAULT NULL COMMENT '单据审核人ID',
  `FCheckDate` varchar(24) NOT NULL DEFAULT '' COMMENT '审核时间',
  `FFManagerID` int(11) unsigned DEFAULT NULL,
  `FSManagerID` int(11) unsigned DEFAULT NULL,
  `FBillerID` int(11) unsigned DEFAULT NULL,
  `FCurrencyID` varchar(1) NOT NULL DEFAULT '',
  `FNowState` varchar(28) NOT NULL DEFAULT '' COMMENT '当前订单状态',
  `FSaleStyle` varchar(1) DEFAULT NULL COMMENT '销售方式',
  `FPOStyle` varchar(11) DEFAULT NULL COMMENT '结算方式',
  `FPOPrecent` varchar(11) DEFAULT NULL COMMENT '结算比例',
  `TalFQty` double(18,1) unsigned DEFAULT NULL COMMENT '合计净重',
  `TalFAmount` double(19,2) DEFAULT NULL COMMENT '合计金额',
  `TalFrist` double DEFAULT NULL COMMENT '费用统计类别一',
  `TalSecond` double DEFAULT NULL COMMENT '费用统计类别二',
  `TalThird` double DEFAULT NULL COMMENT '费用统计类别三',
  `TalForth` double DEFAULT NULL COMMENT '费用统计类别四',
  `TalFeeFifth` decimal(10,3) DEFAULT '0.000' COMMENT '费用统计类别五',
  `account_year` smallint(6) NOT NULL DEFAULT '0' COMMENT '结账年份',
  `account_month` tinyint(4) NOT NULL DEFAULT '0' COMMENT '结账月份',
  `account_state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '调账状态 0未结账 1结账完成',
  `is_hedge` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否包含红冲',
  `red_ink_time` timestamp NULL DEFAULT NULL COMMENT '红冲时间',
  KEY `FBillNo_FTranType` (`FBillNo`(11),`FTranType`) USING BTREE,
  KEY `FInterID` (`FInterID`) USING BTREE,
  KEY `Date_FTranType_FSaleStyle_FCancellation_FCorrent` (`Date`,`FTranType`,`FSaleStyle`,`FCancellation`,`FCorrent`) USING BTREE,
  KEY `FRelateBrID_FTranType_FDCStockID` (`FRelateBrID`,`FTranType`,`FDCStockID`) USING BTREE,
  KEY `FEmpID_Date` (`FEmpID`,`Date`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_main_table1` (
  `FRelateBrID` varchar(255) DEFAULT NULL,
  `FInterID` varchar(255) DEFAULT NULL,
  `FTranType` varchar(255) DEFAULT NULL,
  `FDate` varchar(255) DEFAULT NULL,
  `Date` varchar(255) DEFAULT NULL,
  `FTrainNum` varchar(255) DEFAULT NULL,
  `FBillNo` varchar(255) DEFAULT NULL,
  `FSupplyID` varchar(255) DEFAULT NULL,
  `Fbusiness` varchar(255) DEFAULT NULL,
  `FDCStockID` varchar(255) DEFAULT NULL,
  `FSCStockID` varchar(255) DEFAULT NULL,
  `FCancellation` varchar(255) DEFAULT NULL,
  `FROB` varchar(255) DEFAULT NULL,
  `FCorrent` varchar(255) DEFAULT NULL,
  `FStatus` varchar(255) DEFAULT NULL,
  `FUpStockWhenSave` varchar(255) DEFAULT NULL,
  `FExplanation` varchar(255) DEFAULT NULL,
  `FDeptID` varchar(255) DEFAULT NULL,
  `FEmpID` varchar(255) DEFAULT NULL,
  `FCheckerID` varchar(255) DEFAULT NULL,
  `FCheckDate` varchar(255) DEFAULT NULL,
  `FFManagerID` varchar(255) DEFAULT NULL,
  `FSManagerID` varchar(255) DEFAULT NULL,
  `FBillerID` varchar(255) DEFAULT NULL,
  `FCurrencyID` varchar(255) DEFAULT NULL,
  `FNowState` varchar(255) DEFAULT NULL,
  `FSaleStyle` varchar(255) DEFAULT NULL,
  `FPOStyle` varchar(255) DEFAULT NULL,
  `FPOPrecent` varchar(255) DEFAULT NULL,
  `TalFQty` varchar(255) DEFAULT NULL,
  `TalFAmount` varchar(255) DEFAULT NULL,
  `TalFrist` varchar(255) DEFAULT NULL,
  `TalSecond` varchar(255) DEFAULT NULL,
  `TalThird` varchar(255) DEFAULT NULL,
  `TalForth` varchar(255) DEFAULT NULL,
  `TalFeeFifth` varchar(255) DEFAULT NULL,
  `account_year` varchar(255) DEFAULT NULL,
  `account_month` varchar(255) DEFAULT NULL,
  `account_state` varchar(255) DEFAULT NULL,
  `is_hedge` varchar(255) DEFAULT NULL,
  `red_ink_time` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `trans_main_table_bak1` (
  `FRelateBrID` varchar(255) DEFAULT NULL COMMENT '分部ID',
  `FInterID` varchar(255) DEFAULT NULL COMMENT '订单内码ID',
  `FTranType` varchar(255) DEFAULT NULL COMMENT '订单类型',
  `FDate` varchar(255) DEFAULT NULL COMMENT '订单生成日期',
  `Date` varchar(255) DEFAULT NULL COMMENT '年月日',
  `FTrainNum` varchar(255) DEFAULT NULL COMMENT '车次',
  `FBillNo` varchar(255) DEFAULT NULL COMMENT '订单号',
  `FSupplyID` varchar(255) DEFAULT NULL COMMENT '客户ID',
  `Fbusiness` varchar(255) DEFAULT NULL COMMENT '业务归属ID',
  `FDCStockID` varchar(255) DEFAULT NULL COMMENT '出库库房',
  `FSCStockID` varchar(255) DEFAULT NULL COMMENT '入库库房',
  `FCancellation` varchar(255) DEFAULT NULL COMMENT '取消状态 0取消 1正常',
  `FROB` varchar(255) DEFAULT NULL COMMENT '红蓝单',
  `FCorrent` varchar(255) DEFAULT NULL COMMENT '可修改状态  0订单未完成 1订单完成',
  `FStatus` varchar(255) DEFAULT NULL COMMENT '审核状态',
  `FUpStockWhenSave` varchar(255) DEFAULT NULL COMMENT '更新库存',
  `FExplanation` varchar(255) DEFAULT NULL COMMENT '备注',
  `FDeptID` varchar(255) DEFAULT NULL COMMENT '部门ID',
  `FEmpID` varchar(255) DEFAULT NULL COMMENT '订单负责人ID',
  `FCheckerID` varchar(255) DEFAULT NULL COMMENT '单据审核人ID',
  `FCheckDate` varchar(255) DEFAULT NULL COMMENT '审核时间',
  `FFManagerID` varchar(255) DEFAULT NULL,
  `FSManagerID` varchar(255) DEFAULT NULL,
  `FBillerID` varchar(255) DEFAULT NULL,
  `FCurrencyID` varchar(255) DEFAULT NULL,
  `FNowState` varchar(255) DEFAULT NULL COMMENT '当前订单状态',
  `FSaleStyle` varchar(255) DEFAULT NULL COMMENT '销售方式',
  `FPOStyle` varchar(255) DEFAULT NULL COMMENT '结算方式',
  `FPOPrecent` varchar(255) DEFAULT NULL COMMENT '结算比例',
  `TalFQty` varchar(255) DEFAULT NULL COMMENT '合计净重',
  `TalFAmount` varchar(255) DEFAULT NULL COMMENT '合计金额',
  `TalFrist` varchar(255) DEFAULT NULL COMMENT '费用统计类别一',
  `TalSecond` varchar(255) DEFAULT NULL COMMENT '费用统计类别二',
  `TalThird` varchar(255) DEFAULT NULL COMMENT '费用统计类别三',
  `TalForth` varchar(255) DEFAULT NULL COMMENT '费用统计类别四',
  `TalFeeFifth` varchar(255) DEFAULT NULL COMMENT '费用统计类别五',
  `account_year` varchar(255) DEFAULT NULL COMMENT '结账年份',
  `account_month` varchar(255) DEFAULT NULL COMMENT '结账月份',
  `account_state` varchar(255) DEFAULT NULL COMMENT '调账状态 0未结账 1结账完成',
  `is_hedge` varchar(255) DEFAULT NULL COMMENT '是否包含红冲',
  `red_ink_time` varchar(255) DEFAULT NULL COMMENT '红冲时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `trans_materiel_table` (
  `FInterID` int(11) unsigned NOT NULL DEFAULT '0',
  `FTranType` varchar(3) DEFAULT '',
  `FEntryID` int(11) unsigned DEFAULT '0',
  `FMaterielID` int(11) unsigned DEFAULT NULL,
  `FUseCount` bigint(20) DEFAULT NULL,
  `FPrice` double(19,2) DEFAULT NULL,
  `FMeterielAmount` double(19,2) DEFAULT NULL,
  `FMeterieltime` int(11) unsigned DEFAULT NULL,
  `red_ink_time` timestamp NULL DEFAULT NULL,
  `is_hedge` tinyint(4) unsigned DEFAULT '0' COMMENT '是否为对冲数据 0否 1是',
  `revise_state` tinyint(3) unsigned DEFAULT '0' COMMENT '0:常规状态  1:被修改状态  2:新增状态',
  `bill_state` tinyint(3) unsigned DEFAULT '0' COMMENT '结算状态 0待结算 1已结算',
  KEY `FInterID` (`FInterID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_month_invforcargo` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FItemID` int(11) unsigned DEFAULT NULL,
  `trash_is` varchar(1) DEFAULT NULL,
  `input` double DEFAULT NULL,
  `output` double DEFAULT NULL,
  `FDCTime` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_month_invfordep` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FDeptID` varchar(11) DEFAULT NULL,
  `trash_is` varchar(1) DEFAULT NULL,
  `input` double(18,1) DEFAULT NULL,
  `output` double(18,1) DEFAULT NULL,
  `FDCTime` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_month_invfordep_table` (
  `FRelateBrID` int(11) NOT NULL DEFAULT '0' COMMENT '分部ID',
  `FDeptID` varchar(11) DEFAULT NULL COMMENT '部门ID（1=客服，2=企服，4=销售）',
  `trash_is` varchar(1) NOT NULL COMMENT '垃圾判断（1=是，0=不是）',
  `input` double(18,1) DEFAULT NULL COMMENT '入库量',
  `output` double(18,1) DEFAULT NULL COMMENT '出库量',
  `FDCTime` varchar(10) DEFAULT NULL COMMENT '出入库时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_month_sel` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FItemID` text,
  `total_weight` double(18,1) DEFAULT NULL,
  `total_price` double(19,2) DEFAULT NULL,
  `count_order` bigint(21) DEFAULT NULL,
  `FDate` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_month_sel_rank_table` (
  `FRalateBrID` int(11) unsigned NOT NULL DEFAULT '0',
  `FItemID` int(11) unsigned DEFAULT NULL,
  `total_weight` double(18,1) DEFAULT NULL,
  `total_price` double(19,2) DEFAULT NULL,
  `FDate` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_month_sel_table` (
  `FRelateBrID` int(11) NOT NULL DEFAULT '0' COMMENT '分部ID',
  `FItemID` text COMMENT '货品ID',
  `total_weight` double(18,1) DEFAULT NULL COMMENT '销售总净重',
  `total_price` double(19,2) DEFAULT NULL COMMENT '销售总金额',
  `count_order` bigint(21) NOT NULL DEFAULT '0' COMMENT '累计订单数',
  `FDate` varchar(10) DEFAULT NULL COMMENT '统计日期'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_month_sor` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FInterID` int(11) unsigned DEFAULT NULL,
  `FDate` varchar(24) DEFAULT NULL,
  `FSupplyID` int(11) unsigned DEFAULT NULL,
  `Fbusiness` varchar(11) DEFAULT NULL,
  `FDeptID` varchar(11) DEFAULT NULL,
  `FEmpID` int(11) unsigned DEFAULT NULL,
  `FPOStyle` varchar(11) DEFAULT NULL,
  `FPOPrecent` varchar(11) DEFAULT NULL,
  `profit` double(19,2) DEFAULT NULL,
  `weight` double(18,1) DEFAULT NULL,
  `transport_pay` double(19,2) DEFAULT NULL,
  `classify_pay` double(19,2) DEFAULT NULL,
  `material_pay` double(19,2) DEFAULT NULL,
  `total_pay` double(19,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_month_sor_table` (
  `FRelateBrID` int(11) unsigned NOT NULL DEFAULT '0',
  `FInterID` int(11) unsigned NOT NULL DEFAULT '0',
  `FDate` varchar(24) DEFAULT NULL,
  `FSupplyID` int(11) unsigned DEFAULT NULL,
  `Fbusiness` varchar(11) DEFAULT NULL,
  `FDeptID` varchar(11) DEFAULT NULL,
  `FEmpID` int(11) unsigned DEFAULT NULL,
  `FPOStyle` varchar(11) DEFAULT NULL,
  `FPOPrecent` varchar(11) DEFAULT NULL,
  `profit` double(19,2) DEFAULT NULL,
  `weight` double(18,1) DEFAULT NULL,
  `transport_pay` double(19,2) DEFAULT NULL,
  `classify_pay` double(19,2) DEFAULT NULL,
  `material_pay` double(19,2) DEFAULT NULL,
  `total_pay` double(19,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_month_wh_profit` (
  `FRelateBrID` int(11) unsigned DEFAULT NULL,
  `FFeeID` varchar(50) DEFAULT NULL,
  `FFeeType` varchar(3) DEFAULT NULL,
  `FFeePerson` varchar(50) DEFAULT NULL,
  `FFeeAmount` double(19,2) DEFAULT NULL,
  `FFeebaseAmount` char(0) DEFAULT NULL,
  `Ftaxrate` char(0) DEFAULT NULL,
  `Fbasetax` char(0) DEFAULT NULL,
  `Fbasetaxamount` char(0) DEFAULT NULL,
  `FPriceRef` char(0) DEFAULT NULL,
  `FFeetime` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_month_wh_profit_table` (
  `FRelateBrID` int(11) unsigned NOT NULL DEFAULT '0',
  `FFeeID` varchar(50) NOT NULL,
  `FFeeType` varchar(3) DEFAULT NULL,
  `FFeePerson` varchar(50) NOT NULL,
  `FFeeAmount` double(19,2) DEFAULT NULL,
  `FFeebaseAmount` char(0) NOT NULL,
  `Ftaxrate` char(0) NOT NULL,
  `Fbasetax` char(0) NOT NULL,
  `Fbasetaxamount` char(0) NOT NULL,
  `FPriceRef` char(0) NOT NULL,
  `FFeetime` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `trans_valid_purchase_table` (
  `FRelateBrID` int(11) unsigned NOT NULL DEFAULT '0',
  `FInterID` int(11) unsigned NOT NULL DEFAULT '0',
  `FDate` varchar(10) DEFAULT NULL,
  `FBillNo` varchar(50) NOT NULL DEFAULT '',
  `FSupplyID` int(11) unsigned DEFAULT NULL,
  `Fbusiness` varchar(11) DEFAULT NULL,
  `FEmpID` int(11) unsigned DEFAULT NULL,
  `FSaleStyle` varchar(1) DEFAULT NULL,
  `FCancellation` varchar(3) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `uct_accumulate_wall_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `adcode` int(11) NOT NULL DEFAULT '0' COMMENT '行政区域编码 1省 2市 3区',
  `weight` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '采购重量',
  `availability` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '可利用率',
  `rubbish` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '低值废弃物产生量',
  `rdf` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'rdf排放量',
  `carbon` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '碳排放量',
  `box` int(11) NOT NULL DEFAULT '0' COMMENT '分类箱',
  `customer_num` int(11) NOT NULL DEFAULT '0' COMMENT '服务客户数量',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `adcode` (`adcode`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9312 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_actual_add_order` (
  `actual_log_id` int(11) NOT NULL COMMENT '审核id',
  `order_id` varchar(50) NOT NULL COMMENT '订单id',
  `admin_id` int(11) NOT NULL COMMENT '负责人id',
  `customer_id` int(11) NOT NULL COMMENT '客户id',
  `order_num` varchar(50) NOT NULL COMMENT '订单号',
  `selldate` date NOT NULL COMMENT '销售时间',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`actual_log_id`,`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_actual_tag` (
  `tag_name` varchar(50) NOT NULL COMMENT '标签名',
  `tag_text` varchar(50) NOT NULL COMMENT '标签文本',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`tag_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实际销售订单标签表';
CREATE TABLE `uct_adcode` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(100) NOT NULL DEFAULT '0' COMMENT '区域名称',
  `adcode` int(11) NOT NULL DEFAULT '0' COMMENT '行政区域码',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `name_adcode` (`name`,`adcode`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3538 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_adcode_main` (
  `code` varchar(255) DEFAULT NULL,
  `parent` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `level` varchar(255) DEFAULT NULL,
  `rank` varchar(255) DEFAULT NULL,
  `adcode` varchar(255) DEFAULT NULL,
  `post_code` varchar(255) DEFAULT NULL,
  `area_code` varchar(255) DEFAULT NULL,
  `ur_code` varchar(255) DEFAULT NULL,
  `municipality` varchar(255) DEFAULT NULL,
  `virtual` varchar(255) DEFAULT NULL,
  `dummy` varchar(255) DEFAULT NULL,
  `longitude` varchar(255) DEFAULT NULL,
  `latitude` varchar(255) DEFAULT NULL,
  `center` varchar(255) DEFAULT NULL,
  `province` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `county` varchar(255) DEFAULT NULL,
  `town` varchar(255) DEFAULT NULL,
  `village` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_admin` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `branch_id` int(10) unsigned DEFAULT NULL COMMENT '分部ID',
  `ec_userid` bigint(20) unsigned DEFAULT '0' COMMENT 'ec员工id',
  `crmid` bigint(20) unsigned DEFAULT '0' COMMENT 'ec系统id',
  `ec_linkid` varchar(100) DEFAULT '0' COMMENT 'ec系统联系人id',
  `staff_accid` varchar(100) DEFAULT '0' COMMENT '互客系统员工id',
  `cus_accid` varchar(100) DEFAULT '0' COMMENT '互客系统客户id',
  `link_accid` varchar(100) DEFAULT '0' COMMENT '互客系统客户联系人id',
  `userid` varchar(25) DEFAULT NULL COMMENT '钉钉id',
  `wechat_id` varchar(50) DEFAULT NULL COMMENT '企业微信id',
  `username` varchar(20) NOT NULL DEFAULT '' COMMENT '用户名',
  `nickname` varchar(50) NOT NULL DEFAULT '' COMMENT '昵称',
  `password` varchar(32) NOT NULL DEFAULT '' COMMENT '密码',
  `salt` varchar(30) NOT NULL DEFAULT '' COMMENT '密码盐',
  `avatar` varchar(100) NOT NULL DEFAULT '' COMMENT '头像',
  `mobile` varchar(30) DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) NOT NULL DEFAULT '' COMMENT '电子邮箱',
  `loginfailure` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '失败次数',
  `logintime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '登录时间',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `token` varchar(59) NOT NULL DEFAULT '' COMMENT 'Session标识',
  `last_appletid` varchar(50) DEFAULT NULL COMMENT '最近操作的应用标识',
  `status` varchar(30) NOT NULL DEFAULT 'normal' COMMENT '状态 normal正常  hidden隐藏',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9581 DEFAULT CHARSET=utf8 COMMENT='管理员表';
CREATE TABLE `uct_admin_customer_mapping` (
  `admin_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户id',
  `up_customer_ids` varchar(500) NOT NULL DEFAULT '' COMMENT '上游客户列表',
  `down_customer_ids` varchar(500) NOT NULL DEFAULT '' COMMENT '下游客户列表',
  PRIMARY KEY (`admin_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6566 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_admin_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '管理员ID',
  `username` varchar(30) NOT NULL DEFAULT '' COMMENT '管理员名字',
  `url` varchar(100) NOT NULL DEFAULT '' COMMENT '操作页面',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '日志标题',
  `content` text NOT NULL COMMENT '内容',
  `ip` varchar(50) NOT NULL DEFAULT '' COMMENT 'IP',
  `useragent` varchar(255) NOT NULL DEFAULT '' COMMENT 'User-Agent',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `name` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9227 DEFAULT CHARSET=utf8 COMMENT='管理员日志表';
CREATE TABLE `uct_agent_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL DEFAULT '' COMMENT '姓名',
  `mobile` varchar(12) NOT NULL DEFAULT '' COMMENT '手机',
  `email` varchar(50) NOT NULL DEFAULT '' COMMENT '邮箱',
  `branch_id` int(11) DEFAULT NULL COMMENT '分部',
  `role_id` int(11) DEFAULT NULL COMMENT '角色id',
  `customer_id` int(11) DEFAULT NULL COMMENT '客户id',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '审核状态',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=360 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_apply_for_material_temp` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `FInterID` int(11) DEFAULT NULL COMMENT '订单内码ID',
  `order_id` varchar(20) CHARACTER SET utf8 NOT NULL COMMENT '订单号',
  `meta_id` int(10) DEFAULT NULL COMMENT '辅料的id',
  `number` int(10) NOT NULL COMMENT '数量',
  `meta_price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  `meta_amount` decimal(10,2) DEFAULT NULL COMMENT '总值',
  `ware_id` int(11) DEFAULT NULL COMMENT '仓库id',
  `state` tinyint(1) DEFAULT '0' COMMENT '处理状态：0--未处理  1--处理完成   2--等待处理  3--其他情况',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=137 DEFAULT CHARSET=utf16 COMMENT='1--2月补录辅材的临时表';
CREATE TABLE `uct_apply_for_order_temp` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `FInterID` int(10) DEFAULT NULL COMMENT '订单内码ID',
  `order_id` varchar(20) DEFAULT NULL COMMENT '订单号',
  `FTranName` varchar(20) DEFAULT NULL COMMENT '订单类型名称',
  `FTranType` varchar(20) DEFAULT NULL COMMENT '订单类型',
  `metaName` varchar(30) DEFAULT NULL COMMENT '物料名称',
  `metaID` int(10) DEFAULT NULL COMMENT '物料id',
  `net_weight` decimal(10,2) DEFAULT NULL COMMENT '修改后的净重',
  `price` decimal(10,2) DEFAULT NULL COMMENT '修改后的单价',
  `state` tinyint(2) DEFAULT '0' COMMENT '处理状态：0--未处理  1--处理完成   2--等待处理  3--其他情况',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COMMENT='修改订单（修改红冲数据）的临时表';
CREATE TABLE `uct_appointments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户id',
  `mobile` varchar(12) NOT NULL DEFAULT '' COMMENT '手机号',
  `type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '预约类型 1大数据 2废料评测',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_area` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `pid` int(10) DEFAULT NULL COMMENT '父id',
  `shortname` varchar(100) DEFAULT NULL COMMENT '简称',
  `name` varchar(100) DEFAULT NULL COMMENT '名称',
  `mergename` varchar(255) DEFAULT NULL COMMENT '全称',
  `level` tinyint(4) DEFAULT NULL COMMENT '层级 0 1 2 省市区县',
  `pinyin` varchar(100) DEFAULT NULL COMMENT '拼音',
  `code` varchar(100) DEFAULT NULL COMMENT '长途区号',
  `zip` varchar(100) DEFAULT NULL COMMENT '邮编',
  `first` varchar(50) DEFAULT NULL COMMENT '首字母',
  `lng` varchar(100) DEFAULT NULL COMMENT '经度',
  `lat` varchar(100) DEFAULT NULL COMMENT '纬度',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `pid` (`pid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3749 DEFAULT CHARSET=utf8 COMMENT='地区表';
CREATE TABLE `uct_attachment` (
  `id` int(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `url` varchar(255) NOT NULL DEFAULT '' COMMENT '物理路径',
  `imagewidth` varchar(30) NOT NULL DEFAULT '' COMMENT '宽度',
  `imageheight` varchar(30) NOT NULL DEFAULT '' COMMENT '高度',
  `imagetype` varchar(30) NOT NULL DEFAULT '' COMMENT '图片类型',
  `imageframes` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '图片帧数',
  `filesize` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '文件大小',
  `mimetype` varchar(100) NOT NULL DEFAULT '' COMMENT 'mime类型',
  `extparam` varchar(255) NOT NULL DEFAULT '' COMMENT '透传数据',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建日期',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `uploadtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '上传时间',
  `storage` enum('local','upyun','qiniu') NOT NULL DEFAULT 'local' COMMENT '存储位置',
  `sha1` varchar(40) NOT NULL DEFAULT '' COMMENT '文件 sha1编码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5510 DEFAULT CHARSET=utf8 COMMENT='附件表';
CREATE TABLE `uct_auth_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '父组别',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '组名',
  `rules` text NOT NULL COMMENT '规则ID',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `status` varchar(30) NOT NULL DEFAULT '' COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8 COMMENT='分组表';
CREATE TABLE `uct_auth_group_access` (
  `uid` int(10) unsigned NOT NULL COMMENT '会员ID',
  `group_id` int(10) unsigned NOT NULL COMMENT '级别ID',
  KEY `uid_group_id` (`uid`,`group_id`) USING BTREE,
  KEY `group_id` (`group_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='权限分组表';
CREATE TABLE `uct_auth_group_bak` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '父组别',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '组名',
  `rules` text NOT NULL COMMENT '规则ID',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `status` varchar(30) NOT NULL DEFAULT '' COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8 COMMENT='分组表';
CREATE TABLE `uct_auth_rule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` enum('menu','file') NOT NULL DEFAULT 'file' COMMENT 'menu为菜单,file为权限节点',
  `pid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '父ID',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '规则名称',
  `title` varchar(50) NOT NULL DEFAULT '' COMMENT '规则名称',
  `icon` varchar(50) NOT NULL DEFAULT '' COMMENT '图标',
  `ant_url` varchar(50) NOT NULL DEFAULT '' COMMENT '蚂蚁路径',
  `ant_icon` varchar(50) NOT NULL DEFAULT '' COMMENT '蚂蚁图标',
  `client_icon` varchar(100) NOT NULL DEFAULT '' COMMENT '客户端图标',
  `condition` varchar(255) NOT NULL DEFAULT '' COMMENT '条件',
  `message` varchar(50) NOT NULL DEFAULT '' COMMENT '消息通知红点',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `ismenu` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '是否为菜单',
  `isclient` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '是否为客户端的菜单',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `status` varchar(30) NOT NULL DEFAULT '' COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `pid` (`pid`) USING BTREE,
  KEY `weigh` (`weigh`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=825 DEFAULT CHARSET=utf8 COMMENT='节点表';
CREATE TABLE `uct_auth_rule_bak` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` enum('menu','file') NOT NULL DEFAULT 'file' COMMENT 'menu为菜单,file为权限节点',
  `pid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '父ID',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '规则名称',
  `title` varchar(50) NOT NULL DEFAULT '' COMMENT '规则名称',
  `icon` varchar(50) NOT NULL DEFAULT '' COMMENT '图标',
  `ant_url` varchar(50) NOT NULL DEFAULT '' COMMENT '蚂蚁路径',
  `ant_icon` varchar(50) NOT NULL DEFAULT '' COMMENT '蚂蚁图标',
  `client_icon` varchar(100) NOT NULL DEFAULT '' COMMENT '客户端图标',
  `condition` varchar(255) NOT NULL DEFAULT '' COMMENT '条件',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `ismenu` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '是否为菜单',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `status` varchar(30) NOT NULL DEFAULT '' COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `name` (`name`) USING BTREE,
  KEY `pid` (`pid`) USING BTREE,
  KEY `weigh` (`weigh`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=729 DEFAULT CHARSET=utf8 COMMENT='节点表';
CREATE TABLE `uct_auxy_material_warehouse` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ware_id` int(10) DEFAULT NULL COMMENT '仓库id',
  `mate_order_id` varchar(32) CHARACTER SET utf8 NOT NULL DEFAULT '' COMMENT '辅材单号',
  `apply_id` int(10) NOT NULL DEFAULT '0' COMMENT '申请人id',
  `receive_id` int(10) DEFAULT NULL COMMENT '发放人id/接收人id',
  `mate_type` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT 'out' COMMENT '辅材单类型:''m_out''--出库单    ''m_in''--入库单',
  `mate_state` varchar(30) CHARACTER SET utf8 NOT NULL DEFAULT 'dispose' COMMENT '辅材单状态: ''dispose''--待发放/待接收    ''processed''--已处理/已接收   ''repeal''--已撤销',
  `memo` varchar(255) DEFAULT NULL COMMENT '留言',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COMMENT='辅材的出入库表';
CREATE TABLE `uct_auxy_material_warehouse_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `main_id` int(10) NOT NULL COMMENT '主表id',
  `material_id` int(10) NOT NULL COMMENT '辅材id',
  `material_num` int(10) NOT NULL COMMENT '辅材数量',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb4 COMMENT='辅材出入库详情表';
CREATE TABLE `uct_auxy_material_warehouse_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ware_id` int(10) DEFAULT NULL COMMENT '仓库id',
  `admin_id` int(10) NOT NULL COMMENT '操作人',
  `mate_order_id` varchar(32) CHARACTER SET utf8 NOT NULL COMMENT '单号',
  `mate_type` varchar(32) DEFAULT NULL COMMENT '辅材单类型:''m_out''--出库单    ''m_in''--入库单',
  `mate_state` varchar(32) DEFAULT NULL COMMENT '辅材单状态: ''dispose''--待发放/待接收    ''processed''--已处理/已接收   ''repeal''--已撤销',
  `content` varchar(500) CHARACTER SET utf8 NOT NULL COMMENT '操作内容',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_auxy_material_warehouse_query` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ware_id` int(10) NOT NULL COMMENT '仓库id',
  `mate_order_id` varchar(32) CHARACTER SET utf8 NOT NULL COMMENT '辅材单号',
  `apply_id` int(10) NOT NULL COMMENT '申请人id',
  `receive_id` int(10) DEFAULT NULL COMMENT '发放人id/接收人id',
  `mate_type` varchar(32) NOT NULL COMMENT '辅材单类型',
  `mate_state` varchar(32) NOT NULL COMMENT '辅材单状态',
  `material_id` int(10) NOT NULL COMMENT '辅材id',
  `material_name` varchar(32) CHARACTER SET utf8 DEFAULT NULL COMMENT '辅材的名称',
  `material_num` int(10) NOT NULL COMMENT '辅材数量',
  `dispose_time` int(10) NOT NULL COMMENT '处置时间',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_bas_device` (
  `station_id` varchar(20) NOT NULL COMMENT '工站ID, 表示这个装置所属的工站',
  `item_no` int(11) NOT NULL COMMENT '序号, 表示在工站中的排列顺序, 范围 1~n',
  `device_id` varchar(20) DEFAULT '' COMMENT '装置ID, 一个唯一的编号',
  `device_tty` varchar(255) DEFAULT '' COMMENT '终端号, 表示在工站中系统挂载的标识,例: /dev/ttyUSB0',
  `device_use` varchar(20) DEFAULT 'large-cate' COMMENT '装置用途: [ small-cate 小品类 / large-cate 大品类 / low-value-waster 低值废弃物  | no-sorting-cate 免拣品类]',
  `device_label` varchar(50) DEFAULT '' COMMENT '装置的标签名,例: 1号磅称',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`station_id`,`item_no`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `uct_bas_line` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `line_id` varchar(20) NOT NULL DEFAULT '' COMMENT '分拣线ID',
  `branch_id` int(11) DEFAULT '0' COMMENT '分部ID, 表示所属的分部',
  `storage_id` int(11) DEFAULT '0' COMMENT '仓库ID, 表示所属分部的所属仓库',
  `name` varchar(255) DEFAULT '' COMMENT '分拣线名称',
  `leader` int(11) DEFAULT '0' COMMENT '分拣线长',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `auto_confirm_flag` int(11) DEFAULT '0' COMMENT '自动确认通过开关, 0 表示 关闭, 1 启动开启.',
  `auto_priority_flag` tinyint(1) DEFAULT '0' COMMENT '启用优先级开关, 0 表示 关闭, 1 启动开启',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8 COMMENT='分拣线信息表  分拣线ID编码格式:          分部编号[二位缩写]+仓号[1~9 A~F]+线体编号[1~9 A~F]   例: BA11  宝安分部-1号仓-1号分拣线      LH12  龙华分部-1号仓-2号分拣线';
CREATE TABLE `uct_bas_logistics_equipment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) DEFAULT NULL COMMENT '编码',
  `name` varchar(50) DEFAULT NULL COMMENT '容器名称',
  `category` varchar(20) DEFAULT 'container',
  `type` varchar(20) DEFAULT 'transfer-box' COMMENT '容器类型',
  `tare` decimal(6,2) DEFAULT '0.00' COMMENT '皮重',
  `weight_unit` varchar(5) NOT NULL DEFAULT 'kg',
  `volume` decimal(6,2) DEFAULT NULL COMMENT '体积占用空间',
  `volume_unit` varchar(5) NOT NULL DEFAULT 'm3',
  `capacity` decimal(6,2) DEFAULT NULL COMMENT '可装载容量',
  `lenght` decimal(6,2) DEFAULT NULL COMMENT '长度',
  `width` decimal(6,2) DEFAULT NULL COMMENT '宽度',
  `height` decimal(6,2) DEFAULT NULL COMMENT '高度',
  `length_unit` varchar(5) NOT NULL DEFAULT 'm',
  `stackable_qty` int(11) DEFAULT '0' COMMENT '可堆叠层数',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_bas_station` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `station_id` varchar(20) NOT NULL DEFAULT '' COMMENT '工站ID',
  `station_type` varchar(20) DEFAULT 'sorting' COMMENT '工站类型: [ weigh 称重装置 / rfid 读RFID编码 ]',
  `line_id` varchar(20) DEFAULT '' COMMENT '分拣线ID, 表示工站所属的分拣线',
  `max_mount_num` int(11) DEFAULT '0' COMMENT '装置最大可挂载数量',
  `status` varchar(20) DEFAULT 'setup' COMMENT '工站状态:  [ setup 配置 / stand-by 待命 / working 工作 ]',
  `serail_number` varchar(20) DEFAULT '' COMMENT '系列号',
  `model` varchar(255) DEFAULT '' COMMENT '机型',
  `screen_direction` varchar(20) NOT NULL DEFAULT 'normal' COMMENT '屏幕显示方向',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=194 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_branch` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ec_id` int(11) DEFAULT NULL COMMENT 'ec对应的id',
  `branch_code` varchar(20) DEFAULT '',
  `adcode` int(11) DEFAULT '0',
  `ec_customer_id` int(11) DEFAULT NULL COMMENT 'ec客户表对应id',
  `setting_key` int(11) DEFAULT NULL COMMENT '对应配置表的值',
  `name` varchar(50) DEFAULT NULL COMMENT '分部名称',
  `print_title` varchar(100) DEFAULT '深圳绿环再生资源' COMMENT '打印抬头',
  `company_name` varchar(100) DEFAULT '深圳绿环再生资源公司' COMMENT '公司名',
  `position` text COMMENT '坐标',
  `branch_detail` text COMMENT '分部介绍',
  `branch_img_url` varchar(255) DEFAULT '' COMMENT '分部介绍图片路径',
  `switch` tinyint(4) NOT NULL DEFAULT '1' COMMENT '开关 1:开 0关',
  `receivable_switch` tinyint(4) NOT NULL DEFAULT '0' COMMENT '小额收款开关',
  `presell_switch` tinyint(4) NOT NULL DEFAULT '1' COMMENT '预提销售单价开关',
  `actual_switch` tinyint(4) NOT NULL DEFAULT '1' COMMENT '实际销售单价开关',
  `sign_switch` tinyint(4) NOT NULL DEFAULT '0' COMMENT '现场签到开关',
  `sorting_switch` tinyint(4) NOT NULL DEFAULT '0' COMMENT '分拣人工开关',
  `centre_switch` tinyint(4) NOT NULL DEFAULT '0' COMMENT '中央开关',
  `centre_warehouse_id` tinyint(4) DEFAULT NULL COMMENT '中央仓储id',
  `centre_branch_id` tinyint(4) DEFAULT NULL COMMENT '中央分部id',
  `sorting_unit_cargo_price` float(8,2) NOT NULL DEFAULT '0.00' COMMENT '有价分拣提成单价',
  `weigh_unit_cargo_price` float(8,2) NOT NULL DEFAULT '0.00' COMMENT '有价过磅提成单价',
  `sorting_unit_labor_price` float(8,2) NOT NULL DEFAULT '0.00' COMMENT '分拣基础人工单价',
  `weigh_unit_labor_price` float(8,2) NOT NULL DEFAULT '0.00' COMMENT '过磅基础人工单价',
  `standard_price` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '基准仓库处置单价/吨',
  `overdue_time` int(10) NOT NULL DEFAULT '0' COMMENT '过期时间',
  `evaluate_value` float NOT NULL DEFAULT '0' COMMENT '评分基准',
  `cargo_commission_list` varchar(200) NOT NULL DEFAULT '0' COMMENT '货品提成列表选项',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8 COMMENT='分部表';
CREATE TABLE `uct_branch_bak` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ec_id` int(11) DEFAULT NULL COMMENT 'ec对应的id',
  `branch_code` varchar(20) DEFAULT '',
  `adcode` int(11) DEFAULT '0',
  `ec_customer_id` int(11) DEFAULT NULL COMMENT 'ec客户表对应id',
  `setting_key` int(11) DEFAULT NULL COMMENT '对应配置表的值',
  `name` varchar(50) DEFAULT NULL COMMENT '分部名称',
  `print_title` varchar(50) DEFAULT '深圳绿环再生资源' COMMENT '客户单据抬头',
  `company_name` varchar(50) DEFAULT '深圳绿环再生资源' COMMENT '公司名称',
  `position` text COMMENT '坐标',
  `switch` tinyint(4) NOT NULL DEFAULT '1' COMMENT '开关 1:开 0关',
  `presell_switch` tinyint(4) NOT NULL DEFAULT '1' COMMENT '预提销售单价开关',
  `actual_switch` tinyint(4) NOT NULL DEFAULT '1' COMMENT '实际销售单价开关',
  `sign_switch` tinyint(4) NOT NULL DEFAULT '1' COMMENT '现场签到开关',
  `sorting_switch` tinyint(4) NOT NULL DEFAULT '0' COMMENT '分拣人工开关',
  `centre_switch` tinyint(4) NOT NULL DEFAULT '0' COMMENT '中央开关',
  `centre_warehouse_id` tinyint(4) DEFAULT NULL COMMENT '中央仓储id',
  `centre_branch_id` tinyint(4) DEFAULT NULL COMMENT '中央分部id',
  `sorting_unit_cargo_price` float(8,2) NOT NULL DEFAULT '0.00' COMMENT '有价分拣提成单价',
  `weigh_unit_cargo_price` float(8,2) NOT NULL DEFAULT '0.00' COMMENT '有价过磅提成单价',
  `sorting_unit_labor_price` float(8,2) NOT NULL DEFAULT '0.00' COMMENT '分拣基础人工单价',
  `weigh_unit_labor_price` float(8,2) NOT NULL DEFAULT '0.00' COMMENT '过磅基础人工单价',
  `standard_price` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '基准仓库处置单价/吨',
  `cargo_commission_list` varchar(200) NOT NULL DEFAULT '0.00' COMMENT '货品提成列表选项',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COMMENT='分部表';
CREATE TABLE `uct_branch_related_down` (
  `id` tinyint(4) NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) NOT NULL DEFAULT '0' COMMENT '分部id',
  `customer_id` int(11) NOT NULL DEFAULT '0' COMMENT '下游客户ids',
  `prod_type` varchar(20) DEFAULT NULL COMMENT '加工类型',
  `prod_name` varchar(50) DEFAULT NULL COMMENT '加工企业名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COMMENT='下游客户加工类型表';
CREATE TABLE `uct_cate` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(10) NOT NULL DEFAULT '0' COMMENT '父级id',
  `pid` int(10) NOT NULL COMMENT '索引id',
  `top_class` varchar(20) DEFAULT NULL COMMENT '编码',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '品名',
  `image` varchar(100) DEFAULT NULL COMMENT '图片地址',
  `updatetime` int(10) DEFAULT NULL COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8 COMMENT='品类名称表';
CREATE TABLE `uct_cate_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` varchar(50) DEFAULT NULL COMMENT '订单id',
  `branch_id` int(11) DEFAULT NULL COMMENT '分部id',
  `warehouse_id` int(11) DEFAULT NULL COMMENT '仓库id',
  `cate_id` int(11) DEFAULT NULL COMMENT '物料id',
  `admin_id` int(11) DEFAULT NULL COMMENT '操作人id',
  `before_account_num` float(20,2) NOT NULL DEFAULT '0.00' COMMENT '调账前库存值',
  `account_num` float(20,2) NOT NULL DEFAULT '0.00' COMMENT '调账数量',
  `today_stock` float(20,2) NOT NULL DEFAULT '0.00' COMMENT '今天出入库合计',
  `account_reason` text NOT NULL COMMENT '调账原因',
  `createtime` int(11) DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '父ID',
  `type` varchar(30) NOT NULL DEFAULT '' COMMENT '栏目类型',
  `name` varchar(30) NOT NULL DEFAULT '',
  `nickname` varchar(50) NOT NULL DEFAULT '',
  `flag` set('hot','index','recommend') NOT NULL DEFAULT '',
  `image` varchar(100) NOT NULL DEFAULT '' COMMENT '图片',
  `keywords` varchar(255) NOT NULL DEFAULT '' COMMENT '关键字',
  `description` varchar(255) NOT NULL DEFAULT '' COMMENT '描述',
  `diyname` varchar(30) NOT NULL DEFAULT '' COMMENT '自定义名称',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `status` varchar(30) NOT NULL DEFAULT '' COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `weigh` (`weigh`,`id`) USING BTREE,
  KEY `pid` (`pid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COMMENT='分类表';
CREATE TABLE `uct_centre_storage` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `branch_id` int(11) NOT NULL COMMENT '分部id',
  `centre_branch_id` int(11) NOT NULL COMMENT '中央分部',
  `centre_warehouse_id` int(11) NOT NULL COMMENT '中央仓库',
  `warehouse_unit_cost` float NOT NULL COMMENT '仓储成本单价',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_client_banner` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '名称',
  `describe` text COMMENT '描述',
  `img` varchar(255) DEFAULT '' COMMENT '图片',
  `type` varchar(50) NOT NULL DEFAULT 'home_page' COMMENT 'home_page为首页 profile_page 个人页',
  `skip` int(11) NOT NULL DEFAULT '0' COMMENT '跳转id',
  `priority` int(11) NOT NULL DEFAULT '0' COMMENT '优先度',
  `status` varchar(50) NOT NULL DEFAULT 'normal' COMMENT '状态  normal-正常 hidden-隐藏',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_client_feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户id',
  `theme` tinyint(4) NOT NULL DEFAULT '1' COMMENT '主题 1质量  2价格  3服务',
  `remove_fast_star` tinyint(4) NOT NULL DEFAULT '0' COMMENT '清运及时度',
  `remove_level_star` tinyint(4) NOT NULL DEFAULT '0' COMMENT '清运效果',
  `service_attitude_star` tinyint(4) NOT NULL DEFAULT '0' COMMENT '服务态度',
  `content` varchar(500) NOT NULL DEFAULT '' COMMENT '留言',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_client_rule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pid` int(11) NOT NULL DEFAULT '0' COMMENT '父级id',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '名称',
  `path` varchar(200) NOT NULL COMMENT '路径',
  `icon` varchar(255) NOT NULL DEFAULT '' COMMENT '图片路径',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT '权重',
  `message` varchar(30) NOT NULL DEFAULT '' COMMENT '消息类型',
  `status` varchar(30) NOT NULL DEFAULT 'normal' COMMENT 'normal 正常 hidden 隐藏',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_common_cate` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `branch_id` int(11) DEFAULT NULL COMMENT '分部id',
  `cate_id` int(11) DEFAULT NULL COMMENT '品名id',
  `cate_name` varchar(50) DEFAULT NULL COMMENT '品名-名称',
  `src_type` tinyint(4) DEFAULT NULL COMMENT '数据源type(0=PUR,1=SOR,2=SEL,3=others)',
  `weight` int(11) DEFAULT NULL COMMENT '重量',
  `frequency` int(11) DEFAULT NULL COMMENT '频率',
  `date_unix` int(11) DEFAULT NULL COMMENT '时间标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1253 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL DEFAULT '' COMMENT '变量名',
  `group` varchar(30) NOT NULL DEFAULT '' COMMENT '分组',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '变量标题',
  `tip` varchar(100) NOT NULL DEFAULT '' COMMENT '变量描述',
  `type` varchar(30) NOT NULL DEFAULT '' COMMENT '类型:string,text,int,bool,array,datetime,date,file',
  `value` text NOT NULL COMMENT '变量值',
  `content` text NOT NULL COMMENT '变量字典数据',
  `rule` varchar(100) NOT NULL DEFAULT '' COMMENT '验证规则',
  `extend` varchar(255) NOT NULL DEFAULT '' COMMENT '扩展属性',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8 COMMENT='系统配置';
CREATE TABLE `uct_crm_erp_map` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `crm` varchar(10) NOT NULL DEFAULT 'ec' COMMENT '系统名称',
  `type` varchar(5) NOT NULL DEFAULT 'up' COMMENT '客户类型',
  `field_map` text NOT NULL,
  `crm_to_erp` text NOT NULL,
  `erp_to_crm` text NOT NULL,
  `field_map_link` text NOT NULL,
  `crm_to_erp_link` text NOT NULL,
  `erp_to_crm_link` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_crontab` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `type` varchar(10) NOT NULL DEFAULT '' COMMENT '事件类型',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '事件标题',
  `content` text NOT NULL COMMENT '事件内容',
  `schedule` varchar(100) NOT NULL DEFAULT '' COMMENT 'Crontab格式',
  `sleep` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '延迟秒数执行',
  `maximums` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最大执行次数 0为不限',
  `executes` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '已经执行的次数',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `begintime` int(10) NOT NULL DEFAULT '0' COMMENT '开始时间',
  `endtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '结束时间',
  `executetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最后执行时间',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `status` enum('completed','expired','hidden','normal') NOT NULL DEFAULT 'normal' COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='定时任务表';
CREATE TABLE `uct_customer_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rela_voucher_id` int(11) NOT NULL DEFAULT '0' COMMENT '凭证id',
  `rela_voucher_no` varchar(50) NOT NULL DEFAULT '' COMMENT '关联审批单号',
  `order_id` int(11) NOT NULL DEFAULT '0' COMMENT '订单id',
  `no` varchar(50) NOT NULL COMMENT '受理单号',
  `audit_id` varchar(50) NOT NULL DEFAULT '' COMMENT '钉钉审核订单号',
  `task_id` varchar(50) NOT NULL DEFAULT '' COMMENT '钉钉任务id',
  `cus_id` int(11) NOT NULL COMMENT '客户id',
  `cus_type` varchar(10) NOT NULL DEFAULT '' COMMENT '客户类型',
  `branch_id` int(11) NOT NULL DEFAULT '0' COMMENT '分部id',
  `branch_text` varchar(50) NOT NULL DEFAULT '' COMMENT '分部名',
  `use` varchar(50) NOT NULL COMMENT '用途  保证金收款pledge_in   保证金退款pledge_out   定金收款deposit_in   定金退款deposit_out   收付款抵扣deposit_ded    现结cash    订单金额order_amount',
  `amount` double NOT NULL DEFAULT '0' COMMENT '金额',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0待审核 1审核通过 2拒绝',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=435 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_customer_allot_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `before_admin_id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=161 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_customer_annual_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `year` int(4) NOT NULL,
  `version` varchar(20) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `data` json NOT NULL,
  `is_checkout` tinyint(4) NOT NULL DEFAULT '0',
  `share_times` tinyint(4) NOT NULL DEFAULT '0',
  `status` enum('enabled','disabled','unfollow') NOT NULL,
  `create time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_customer_behave_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL COMMENT '客户ID',
  `admin_id` int(11) DEFAULT NULL COMMENT '用户ID',
  `behave_type` varchar(50) DEFAULT NULL COMMENT '行为类型',
  `detail` varchar(100) DEFAULT NULL COMMENT '行为说明',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=425 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_customer_materiel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `purchase_id` int(11) NOT NULL COMMENT '订单id',
  `purchase_incharge` int(11) NOT NULL COMMENT '采购负责人id',
  `seller_id` int(11) NOT NULL COMMENT '客户存放人id',
  `materiel_id` int(11) NOT NULL COMMENT '辅材id',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '辅材名称',
  `storage_amount` int(11) NOT NULL COMMENT '存放辅材',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=267 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_customer_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL DEFAULT '0' COMMENT 'admin_id',
  `branch_id` int(11) NOT NULL DEFAULT '0' COMMENT '分部id',
  `company_name` varchar(255) NOT NULL DEFAULT '' COMMENT '公司名',
  `phone` varchar(20) NOT NULL DEFAULT '' COMMENT '联系方式',
  `liasion` varchar(30) NOT NULL DEFAULT '' COMMENT '联系人',
  `location_name` varchar(30) NOT NULL DEFAULT '' COMMENT '位置名称',
  `position` varchar(255) NOT NULL DEFAULT '' COMMENT '定位坐标点',
  `createtime` int(11) NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(11) NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_customer_question_grade` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL COMMENT '问券id',
  `item1` float(3,2) NOT NULL DEFAULT '0.00' COMMENT '清运服务',
  `item2` float(3,2) NOT NULL DEFAULT '0.00' COMMENT '服务态度',
  `item3` float(3,2) NOT NULL DEFAULT '0.00' COMMENT '结算',
  `item4` float(3,2) NOT NULL DEFAULT '0.00' COMMENT '处置与报告',
  `item5` float(3,2) NOT NULL DEFAULT '0.00' COMMENT '沟通与投诉',
  `item6` float(3,2) NOT NULL DEFAULT '0.00' COMMENT '服务点员工',
  `item7` float(3,2) NOT NULL DEFAULT '0.00' COMMENT '其它',
  `csi` float(4,2) NOT NULL DEFAULT '0.00' COMMENT 'csi评分',
  `createtime` int(11) NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(11) NOT NULL DEFAULT '0' COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_customer_question_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL COMMENT '关联的问券表id',
  `shipment_ask` tinyint(4) NOT NULL DEFAULT '0' COMMENT '清运要求',
  `shipment_answer` tinyint(4) NOT NULL DEFAULT '0' COMMENT '应急清运响应',
  `staff_cooperate` tinyint(4) NOT NULL DEFAULT '0' COMMENT '现场员工协作',
  `civilized_operation` tinyint(4) NOT NULL DEFAULT '0' COMMENT '文明作业',
  `customer_stipulate` tinyint(4) NOT NULL DEFAULT '0' COMMENT '遵守客户方规定',
  `now_settle` tinyint(4) NOT NULL DEFAULT '0' COMMENT '目前的结算方式',
  `settle_accuracy` tinyint(4) NOT NULL DEFAULT '0' COMMENT '结算方式准确性',
  `handle_rationality` tinyint(4) NOT NULL DEFAULT '0' COMMENT '废料处置合理性',
  `receipts_timeliness` tinyint(4) NOT NULL DEFAULT '0' COMMENT '转移单据开具的及时性',
  `report_accuracy` tinyint(4) NOT NULL DEFAULT '0' COMMENT '处置情况报告准确性',
  `communicate_smooth` tinyint(4) NOT NULL DEFAULT '0' COMMENT '双方沟通渠道的畅顺性',
  `complaint_timeliness` tinyint(4) NOT NULL DEFAULT '0' COMMENT '对投诉回应的及时性',
  `verify_track` tinyint(4) NOT NULL DEFAULT '0' COMMENT '对处理的验证跟踪',
  `regular_visits` tinyint(4) NOT NULL DEFAULT '0' COMMENT '定期走访',
  `report_to_duty` tinyint(4) NOT NULL DEFAULT '0' COMMENT '员工到岗',
  `working_attitude` tinyint(4) NOT NULL DEFAULT '0' COMMENT '工作态度',
  `packaging_work` tinyint(4) NOT NULL DEFAULT '0' COMMENT '包装工作',
  `shipshape` tinyint(4) NOT NULL DEFAULT '0' COMMENT '整洁情况',
  `qualifications_update` tinyint(4) NOT NULL DEFAULT '0' COMMENT '资质的及时更新',
  `assess_support` tinyint(4) NOT NULL DEFAULT '0' COMMENT '对相关方评审的支持',
  `emergency_container` tinyint(4) NOT NULL DEFAULT '0' COMMENT '应急容器的提供',
  `environmental_consultation` tinyint(4) NOT NULL DEFAULT '0' COMMENT '环保咨询',
  `extend_service` text COMMENT '延伸服务',
  `propose` text COMMENT '建议',
  `createtime` int(11) NOT NULL DEFAULT '0' COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_customer_report` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cus_id` int(11) NOT NULL COMMENT '客户id',
  `cus_name` varchar(50) NOT NULL DEFAULT '' COMMENT '客户名称',
  `time_label` varchar(50) NOT NULL COMMENT '时间',
  `time_dim` varchar(10) NOT NULL COMMENT '时间类型: Y-年，M-月，D-日，Q-季度，W-星期',
  `begin_time` int(10) DEFAULT NULL COMMENT '开始时间',
  `end_time` int(10) DEFAULT NULL COMMENT '结束时间',
  `group1` varchar(50) DEFAULT NULL COMMENT '类型1',
  `cate_name1` varchar(100) DEFAULT NULL COMMENT '物料名称1',
  `group2` varchar(50) DEFAULT NULL COMMENT '类型2',
  `cate_name2` varchar(100) NOT NULL COMMENT '物料名称2',
  `item_no` int(10) DEFAULT '0' COMMENT '排序',
  `value1` varchar(30) NOT NULL DEFAULT '0.00' COMMENT '值1',
  `unit1` varchar(10) DEFAULT '' COMMENT '单位1',
  `value2` varchar(30) DEFAULT '0.0' COMMENT '值2',
  `unit2` varchar(10) DEFAULT '0' COMMENT '单位2',
  `value3` varchar(30) DEFAULT NULL COMMENT '值3',
  `unit3` varchar(10) DEFAULT NULL COMMENT '单位3',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2022 DEFAULT CHARSET=utf8 COMMENT='月数据报表';
CREATE TABLE `uct_customer_report_memo` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `cus_id` int(10) NOT NULL COMMENT '客户id',
  `cus_name` varchar(50) NOT NULL COMMENT '客户名称',
  `time_label` varchar(50) NOT NULL COMMENT '时间',
  `time_dim` varchar(10) NOT NULL COMMENT '时间类型: Y-年，M-月，D-日，Q-季度，W-星期',
  `begin_time` int(10) DEFAULT NULL COMMENT '开始时间',
  `end_time` int(10) DEFAULT NULL COMMENT '结束时间',
  `group1` varchar(100) NOT NULL COMMENT '类型1',
  `group2` varchar(100) NOT NULL COMMENT '类型2',
  `cate_name2` varchar(100) NOT NULL COMMENT '项名称2',
  `item_no` int(10) NOT NULL COMMENT '排序',
  `value1` varchar(800) NOT NULL COMMENT '描述',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updata_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=266 DEFAULT CHARSET=utf8 COMMENT='月数据报表的描述表';
CREATE TABLE `uct_customer_servinfo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL COMMENT '用户ID',
  `name_cn` varchar(20) NOT NULL COMMENT '中文名',
  `name_en` varchar(50) NOT NULL COMMENT '英文名',
  `position_cn` varchar(20) NOT NULL COMMENT '中文职位',
  `position_en` varchar(50) NOT NULL COMMENT '英文职位',
  `introduce_cn` varchar(100) NOT NULL COMMENT '中文介绍',
  `introduce_en` varchar(200) NOT NULL COMMENT '英文介绍',
  `img` text NOT NULL COMMENT '职业头像url',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COMMENT='年度报告人员关联表';
CREATE TABLE `uct_day_wall_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `adcode` int(11) NOT NULL DEFAULT '0' COMMENT '区域行政编码 省 市 区',
  `weight` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '采购重量',
  `availability` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '可利用率',
  `rubbish` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '低值废弃物产生量',
  `rdf` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'rdf排放量',
  `carbon` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '碳排放量',
  `box` int(11) NOT NULL DEFAULT '0' COMMENT '分类箱',
  `customer_num` int(11) NOT NULL DEFAULT '0' COMMENT '服务客户数量',
  `report_date` date DEFAULT NULL COMMENT '日期',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `key1` (`adcode`,`report_date`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2638452 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_dictionaries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `group` varchar(50) NOT NULL COMMENT '组',
  `code` varchar(50) NOT NULL DEFAULT '' COMMENT '代号',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '名称',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updata_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8 COMMENT='数据字典';
CREATE TABLE `uct_ec_trajectory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL COMMENT '客户id',
  `user_nickname` varchar(30) NOT NULL DEFAULT '' COMMENT '操作人id',
  `trajectory_code` int(11) DEFAULT NULL COMMENT '轨迹类型',
  `content` text COMMENT '内容',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15799 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_ec_trajectory_code` (
  `code` int(11) NOT NULL COMMENT 'ec代码',
  `p_code` int(11) NOT NULL DEFAULT '0' COMMENT '父代码',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '轨迹类型',
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ec轨迹';
CREATE TABLE `uct_economic_circle` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(30) DEFAULT NULL COMMENT '经济圈的名称',
  `state` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否使用： 0--不使用  1--使用',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updata_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COMMENT='经济圈板块';
CREATE TABLE `uct_economic_circle_branch` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `cire_id` int(10) DEFAULT NULL COMMENT '经济板块表的ID',
  `branch_id` int(11) DEFAULT NULL COMMENT '分部id',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updata_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COMMENT='经济圈板块对应的分部';
CREATE TABLE `uct_erp_tool` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) NOT NULL COMMENT '工具类型',
  `text` varchar(255) NOT NULL COMMENT '工具名称',
  `value` varchar(255) NOT NULL,
  `status` tinyint(1) NOT NULL COMMENT '状态',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_erp_tool_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `type` varchar(50) NOT NULL COMMENT '工具类型',
  `group_id` int(11) NOT NULL COMMENT '角色id',
  `rules` varchar(255) NOT NULL COMMENT '权限id集',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_feedback` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `conf_id` int(10) NOT NULL COMMENT '反馈类型ID',
  `feedback_content` varchar(255) NOT NULL COMMENT '反馈详情',
  `feedback_tel` char(12) DEFAULT NULL COMMENT '手机号',
  `create_time` int(10) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COMMENT='反馈内容记录表';
CREATE TABLE `uct_feedback_conf` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `conf_name` varchar(30) NOT NULL COMMENT '配置字段',
  `create_time` int(10) NOT NULL COMMENT '生成时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='反馈类型配置表';
CREATE TABLE `uct_finance_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `way` varchar(20) NOT NULL,
  `name` varchar(200) NOT NULL COMMENT '户名',
  `account` varchar(50) NOT NULL COMMENT '账号',
  `bank_name` varchar(200) NOT NULL DEFAULT '' COMMENT '开户名',
  `title` varchar(200) NOT NULL DEFAULT '' COMMENT '拼接字符串',
  `state` varchar(200) NOT NULL DEFAULT 'normal' COMMENT 'normal 正常 hidden 隐藏',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_finance_applet` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(200) DEFAULT '' COMMENT '应用名称',
  `appid` varchar(200) DEFAULT '' COMMENT '应用id',
  `appsecret` varchar(200) DEFAULT '' COMMENT '应用密钥',
  `referer_list` varchar(200) NOT NULL DEFAULT '' COMMENT '来源列表',
  `access_token` varchar(200) NOT NULL DEFAULT '' COMMENT '令牌',
  `expires_time` int(11) NOT NULL DEFAULT '0' COMMENT '令牌过期时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_fzt_application` (
  `cus_id` int(11) NOT NULL DEFAULT '0',
  `appid` char(32) NOT NULL DEFAULT '',
  `secret` char(32) NOT NULL DEFAULT '',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_fzt_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) NOT NULL COMMENT '绿环订单id',
  `fzt_id` bigint(20) NOT NULL COMMENT '废纸通id',
  `type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0完善订单 1单次录入 2完成录入 3修改录入',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_fzt_order` (
  `order_id` bigint(20) NOT NULL COMMENT '绿环id',
  `fzt_id` bigint(20) NOT NULL COMMENT '废纸通id',
  `sort_state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '分拣状态',
  `type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1一口价结算 2分拣后结算',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '关联时间',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_fzt_sort` (
  `id` bigint(20) NOT NULL,
  `order_id` bigint(20) NOT NULL COMMENT '绿环订单id',
  `fzt_id` bigint(20) NOT NULL COMMENT '废纸通id',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '货品名称',
  `total_weight` double NOT NULL DEFAULT '0' COMMENT '总重',
  `tare_weight` double NOT NULL DEFAULT '0' COMMENT '皮重',
  `net_weight` double NOT NULL DEFAULT '0' COMMENT '净重',
  `price` double NOT NULL DEFAULT '0' COMMENT '单价',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_hazardous_waste_admin` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `apt_id` varchar(50) NOT NULL DEFAULT '' COMMENT '预约号',
  `page_code` varchar(20) NOT NULL COMMENT '页面code',
  `page_name` varchar(30) NOT NULL COMMENT '页面名称',
  `cus_nickname` varchar(30) NOT NULL COMMENT '用户呢称',
  `cus_tel` varchar(11) NOT NULL COMMENT '用户手机号',
  `customer_id` int(11) DEFAULT NULL COMMENT '客户id',
  `state` varchar(50) DEFAULT NULL COMMENT '状态',
  `company_name` varchar(100) DEFAULT '' COMMENT '公司名称',
  `company_contact` varchar(50) DEFAULT '' COMMENT '公司联系人',
  `company_address` varchar(500) DEFAULT '' COMMENT '公司地址',
  `deal_time` datetime DEFAULT NULL COMMENT '预约处理时间',
  `img_address` varchar(500) DEFAULT NULL COMMENT '预约时候的图片',
  `apt_type` tinyint(1) DEFAULT '0' COMMENT '预约状态：0--初始状态  1--预约中  2--已确认  3--已取消',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '确认预约时间',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=159 DEFAULT CHARSET=utf8 COMMENT='危费六个页面的登录人员信息';
CREATE TABLE `uct_hazardous_waste_admin_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `main_id` int(10) NOT NULL COMMENT '主表的id',
  `sub_type` varchar(20) NOT NULL DEFAULT '' COMMENT '预约的方式(gfcz--固废处置 wfpp--危废匹配  hjpg--环境评估)',
  `sub_name` varchar(50) NOT NULL DEFAULT '' COMMENT '预约物料名称',
  `sub_num` int(10) NOT NULL COMMENT '预约的数量（单位吨）',
  `sub_unit` varchar(50) NOT NULL DEFAULT '' COMMENT '预约的的打包方式（框/桶）',
  `is_use` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否使用：0--不使用  1--使用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预约的时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8 COMMENT='新环保管家的固废、危废预约的详情';
CREATE TABLE `uct_hazardous_waste_disposal` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cus_name` varchar(50) NOT NULL DEFAULT '' COMMENT '企业的全称',
  `goods_address` varchar(150) NOT NULL DEFAULT '' COMMENT '危废出货点的详细地址',
  `position` varchar(150) DEFAULT NULL COMMENT '位置（经纬度）',
  `goods_memo` varchar(255) DEFAULT '' COMMENT '危废明细',
  `expect_time` tinyint(1) DEFAULT NULL COMMENT '预期危废出货时间: 1-一周内 2-二周内 3-三周内 4-四周内',
  `goods_img` varchar(255) DEFAULT '' COMMENT '图片',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updata_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COMMENT='危废匹配（引导客户页面）';
CREATE TABLE `uct_hazardous_waste_env` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `env_type` varchar(30) DEFAULT '' COMMENT '环境类型：1-环保方案编制(环评. 应急预案. 管理计划等)\r\n2-危险废弃物签约(机油. 活性炭. 乳化液等)\r\n3-环保工程治理(废水. 废气. 噪声. 土壤修复等)\r\n4-排放检测验收(竣工验收. 水气检测. 在线监测等)',
  `env_memo` varchar(255) DEFAULT '' COMMENT '环境详细信息',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updata_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8 COMMENT='环境评估（引导客户页面）';
CREATE TABLE `uct_huke` (
  `name` varchar(100) NOT NULL DEFAULT '',
  `type` varchar(100) NOT NULL DEFAULT 'up',
  `crm_type` varchar(100) NOT NULL DEFAULT 'huke',
  `appkey` varchar(100) NOT NULL DEFAULT '',
  `appsecret` varchar(100) NOT NULL DEFAULT '',
  `cid` varchar(100) NOT NULL DEFAULT '',
  `status` varchar(100) NOT NULL DEFAULT 'enable' COMMENT 'enable 启用  disable 禁用'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_inventory_reconciliation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `admin_id` int(10) DEFAULT NULL COMMENT '调账申请人id',
  `nickname` varchar(50) DEFAULT NULL COMMENT '申请人',
  `userid` varchar(25) DEFAULT NULL COMMENT '钉钉id',
  `branch_id` int(11) DEFAULT NULL COMMENT '仓库id',
  `branch_name` varchar(50) DEFAULT NULL COMMENT '仓库名称',
  `audit_id` varchar(100) DEFAULT NULL COMMENT '审批内码',
  `processCode` varchar(50) DEFAULT NULL COMMENT '审批的单号',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  `exam_status` varchar(10) DEFAULT 'draft' COMMENT '"draft" -- "草稿","submit" -- "审批中","pass" -- "审批通过","reject" -- "审批拒绝","cancel" -- "删除"',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COMMENT='库存调账的主表';
CREATE TABLE `uct_inventory_reconciliation_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `main_id` int(11) DEFAULT NULL COMMENT '主表ID',
  `cate_id` int(11) DEFAULT NULL COMMENT '品类id',
  `cate_name` varchar(50) DEFAULT NULL COMMENT '品类名称',
  `ori_stock` decimal(10,2) DEFAULT NULL COMMENT '原来的库存重量',
  `cur_stock` decimal(10,2) DEFAULT NULL COMMENT '现在的库存重量',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COMMENT='库存调账的详情表';
CREATE TABLE `uct_jobs_plan` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` int(10) NOT NULL DEFAULT '0' COMMENT '分部id',
  `sortage_id` varchar(100) DEFAULT '' COMMENT '仓库',
  `line_id` varchar(20) DEFAULT '' COMMENT '线体',
  `plan_type` varchar(50) NOT NULL DEFAULT '' COMMENT '计划状态：weight - 过磅 /  sorting - 分拣 / packing - 包装',
  `plan_begin_time` datetime(6) DEFAULT NULL COMMENT '预估开始时间',
  `plan_end_time` datetime(6) DEFAULT NULL COMMENT '预估结束时间',
  `plan_work_time` decimal(10,1) DEFAULT NULL COMMENT '预估分拣时间(小时)',
  `relation_order_id` int(11) DEFAULT NULL COMMENT '关联订单id',
  `relation_order_num` varchar(50) DEFAULT '' COMMENT '关联订单号',
  `real_begin_time` datetime(6) DEFAULT NULL COMMENT '实际开始时间',
  `real_end_time` datetime(6) DEFAULT NULL COMMENT '实际结束时间',
  `real_use_time` decimal(10,1) DEFAULT '0.0' COMMENT '实际分拣时间(小时)',
  `planner` int(10) NOT NULL COMMENT '计划人',
  `assign_to` int(255) DEFAULT NULL COMMENT '指派给一个人员',
  `status` varchar(50) DEFAULT 'plan' COMMENT '状态：plan - 计划, open - 开始, close - 结束',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updata_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='工作计划表';
CREATE TABLE `uct_label` (
  `label_sn` varchar(36) NOT NULL COMMENT '唯一辨识码',
  `lot_num` int(11) DEFAULT NULL COMMENT '批次号',
  `status` int(11) DEFAULT '0' COMMENT '0 - 未绑定， 1 - 已绑定',
  `order_no` varchar(32) DEFAULT NULL COMMENT '订单号',
  `category_id` int(11) DEFAULT NULL COMMENT '品类id',
  `category_type` varchar(20) DEFAULT NULL,
  `category_name` varchar(100) DEFAULT NULL COMMENT '品类名',
  `AW` int(11) DEFAULT '0' COMMENT '总重*100',
  `NW` int(11) DEFAULT '0' COMMENT '净重*100',
  `TW` int(11) DEFAULT '0' COMMENT '皮重*100',
  `weight_unit` varchar(10) DEFAULT 'kg' COMMENT '重量单位',
  `price` int(11) DEFAULT '0' COMMENT '成交价格*1000',
  `price_unit` varchar(10) DEFAULT '元' COMMENT '价格单位',
  `item_no` int(11) DEFAULT '0' COMMENT '批次内序列号',
  `position` varchar(100) DEFAULT NULL COMMENT '经纬度定位',
  `create_user` int(11) DEFAULT NULL COMMENT '创建人id',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_user` int(11) DEFAULT NULL COMMENT '更新人id',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`label_sn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_label_lot` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `begin_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `end_time` timestamp NULL DEFAULT NULL,
  `create_user` int(11) DEFAULT NULL COMMENT '创建人id',
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=383 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_main_effective_table` (
  `FBillNo` varchar(50) NOT NULL COMMENT '订单ID',
  `FCorrent` int(10) DEFAULT NULL,
  `FDate` datetime DEFAULT NULL COMMENT '日期',
  `create_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`FBillNo`) USING BTREE,
  KEY `idx_met_01` (`FBillNo`,`FCorrent`,`FDate`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='有效订单表（运营月度看板使用）';
CREATE TABLE `uct_map` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `admin_id` int(11) DEFAULT NULL COMMENT '用户id',
  `map_trail` text COMMENT '地图轨迹',
  `createtime` int(11) DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(11) DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='地图表';
CREATE TABLE `uct_materiel` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `branch_id` int(10) unsigned NOT NULL COMMENT '分部id',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '辅材的品名',
  `number` int(11) NOT NULL DEFAULT '0' COMMENT '库存',
  `purchase_price` float(10,2) NOT NULL DEFAULT '0.00' COMMENT '采购价格',
  `inside_price` float(10,2) NOT NULL DEFAULT '0.00' COMMENT '内部销售价',
  `outside_price` float(10,2) NOT NULL DEFAULT '0.00' COMMENT '外部销售价',
  `remark` varchar(100) DEFAULT '' COMMENT '备注',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `state` enum('1','0') NOT NULL DEFAULT '1' COMMENT '状态:1=启用,0=禁用',
  `createtime` int(11) DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(11) DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1505 DEFAULT CHARSET=utf8 COMMENT='辅材管理表';
CREATE TABLE `uct_materiel_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `admin_id` int(10) unsigned DEFAULT NULL COMMENT '管理员id',
  `materiel_id` int(10) unsigned NOT NULL COMMENT '辅材id',
  `entering_number` int(10) unsigned NOT NULL COMMENT '出入库数量',
  `number` int(11) NOT NULL COMMENT '现有库存',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `type` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT '出库:0; 入库:1;',
  `ip` varchar(255) NOT NULL COMMENT 'ip',
  `createtime` int(11) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1052 DEFAULT CHARSET=utf8 COMMENT='辅材出入库日志';
CREATE TABLE `uct_modify_order_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL COMMENT '订单id',
  `dd_audit_id` varchar(100) DEFAULT NULL COMMENT '对应的钉钉审核id',
  `order_type` int(11) NOT NULL COMMENT '订单类型 0采购 1现买现卖 2销售 3送框',
  `tran_type` char(3) NOT NULL DEFAULT '' COMMENT '订单类型 PUR采购 SOR入库 SEL销售',
  `is_diff` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否金额差异 0否 1是',
  `admin_id` int(11) NOT NULL COMMENT '发起人',
  `field_list` text COMMENT '字段列表',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态  1待分部经理审核  2待运营经理审核  3待财务助理审核  4拒绝  5通过   ',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `createtime` (`createtime`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=273 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_modify_order_audit_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `audit_id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `operate` tinyint(4) NOT NULL DEFAULT '1' COMMENT '操作',
  `remark` varchar(200) NOT NULL DEFAULT '' COMMENT '留言',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=467 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_news_record` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `new_title` varchar(200) NOT NULL COMMENT '标题',
  `new_time` date NOT NULL COMMENT '发文时间',
  `title_url` varchar(255) DEFAULT NULL COMMENT '标题图地址',
  `title_url_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '图片的状态:1=正方形,2=长方形',
  `new_describe` varchar(800) NOT NULL COMMENT '描述',
  `new_url` varchar(255) DEFAULT NULL COMMENT '链接',
  `new_states` tinyint(1) NOT NULL DEFAULT '0' COMMENT '新闻状态:0=未发表,1=已发布',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启用:1=启用,0=禁用',
  `create_time` int(10) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 COMMENT='新闻信息记录表';
CREATE TABLE `uct_one_level_accumulate_wall_report` (
  `adcode` int(11) NOT NULL DEFAULT '0' COMMENT '行政区域编码',
  `name` varchar(30) NOT NULL COMMENT '品类名称',
  `weight` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '采购重量',
  `carbon` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '碳排放量',
  PRIMARY KEY (`adcode`,`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='累计品类处置表';
CREATE TABLE `uct_one_level_day_wall_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adcode` int(11) NOT NULL DEFAULT '0' COMMENT '行政编码',
  `name` varchar(30) DEFAULT '' COMMENT '一级品类名',
  `weight` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '采购重量',
  `carbon` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '碳排放',
  `report_date` date DEFAULT NULL COMMENT '报表日期',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `key1` (`adcode`,`report_date`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8 COMMENT='每日一级品类处置表';
CREATE TABLE `uct_order_account` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `branch_id` int(10) unsigned DEFAULT NULL COMMENT '分部id',
  `admin_id` int(10) unsigned DEFAULT NULL COMMENT '结账操作人',
  `pur_num` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '采购订单数量',
  `sel_num` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '销售订单数量',
  `account_year` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '结账年份',
  `account_month` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '结账月份',
  `createtime` int(11) NOT NULL DEFAULT '0' COMMENT '结账时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `branch_id` (`branch_id`,`account_year`,`account_month`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=142 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_order_account_history` (
  `order_id` int(11) NOT NULL COMMENT '订单id',
  `order_type` varchar(5) NOT NULL COMMENT '订单类型',
  `account_year` int(11) NOT NULL COMMENT '审核年份',
  `account_month` int(11) NOT NULL COMMENT '审核月份'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `uct_order_bill` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `order_id` int(11) NOT NULL COMMENT '订单id',
  `audit_id` varchar(100) DEFAULT NULL,
  `order_no` varchar(50) DEFAULT NULL COMMENT '订单号',
  `type` char(3) NOT NULL COMMENT '订单类型',
  `pay_way` varchar(20) DEFAULT 'bank' COMMENT '银行转账bank   微信支付wechat',
  `account` varchar(50) NOT NULL DEFAULT '' COMMENT '账号',
  `settle_type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1-现结，2-月结, 3-抵扣.4-现付+抵扣',
  `cash` double DEFAULT '0' COMMENT '现结金额',
  `amount` decimal(8,3) DEFAULT '0.000' COMMENT '结算金额',
  `url` varchar(2000) DEFAULT NULL COMMENT '水单图片',
  `bank_bill_url` varchar(2000) DEFAULT NULL COMMENT '银行流水',
  `audit_remark` varchar(255) NOT NULL DEFAULT '' COMMENT '财务系统审核备注',
  `upload_remark` varchar(255) NOT NULL DEFAULT '' COMMENT '上传水单备注',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `audittime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '审核时间',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态  0拒绝 1审核中 2审核通过',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=653 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_order_cancel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `order_num` varchar(50) NOT NULL,
  `type` varchar(5) NOT NULL COMMENT '订单类型 PUR采购 SEL销售',
  `hand_mouth_data` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否现买现卖 ',
  `corrent` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0未完成 1完成',
  `handle` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0未处理 1已处理',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=190 DEFAULT CHARSET=utf8mb4 COMMENT='订单取消';
CREATE TABLE `uct_page` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `category_id` int(10) NOT NULL DEFAULT '0' COMMENT '分类ID',
  `title` varchar(50) NOT NULL DEFAULT '' COMMENT '标题',
  `keywords` varchar(255) NOT NULL DEFAULT '' COMMENT '关键字',
  `flag` set('hot','index','recommend') NOT NULL DEFAULT '' COMMENT '标志',
  `image` varchar(255) NOT NULL DEFAULT '' COMMENT '头像',
  `content` text NOT NULL COMMENT '内容',
  `icon` varchar(50) NOT NULL DEFAULT '' COMMENT '图标',
  `views` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '点击',
  `comments` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '评论',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `status` varchar(30) NOT NULL DEFAULT '' COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='单页表';
CREATE TABLE `uct_password_reset` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nickname` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=355 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_potential_customer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL COMMENT '姓名',
  `mobile` varchar(15) DEFAULT NULL COMMENT '手机号',
  `company_name` varchar(100) NOT NULL DEFAULT '' COMMENT '公司名',
  `industry` varchar(100) NOT NULL DEFAULT '' COMMENT '所属行业',
  `scale` varchar(100) NOT NULL DEFAULT '0' COMMENT '公司规模',
  `city` varchar(100) NOT NULL DEFAULT '' COMMENT '城市',
  `type` varchar(100) NOT NULL DEFAULT '' COMMENT '废料类型',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_print_setting` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `client_id` varchar(20) DEFAULT NULL COMMENT '应用ID',
  `client_secret` varchar(50) DEFAULT NULL COMMENT '应用密钥',
  `access_token` varchar(50) DEFAULT NULL COMMENT '访问令牌',
  `refresh_token` varchar(50) DEFAULT NULL COMMENT '更新令牌',
  `token_time` int(10) unsigned DEFAULT NULL COMMENT '令牌获取时间',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='打印配置表';
CREATE TABLE `uct_purchase_overdue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL COMMENT '专员id',
  `order_id` int(11) NOT NULL COMMENT '订单id',
  `overdue_time` int(11) NOT NULL COMMENT '到期时间',
  `overdue_second` int(11) NOT NULL COMMENT '延期秒数',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=329 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_purchase_sign_in_out` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `purchase_incharge` int(10) DEFAULT NULL COMMENT '操作员id',
  `purchase_id` int(10) DEFAULT NULL COMMENT '采购id',
  `sign_in_type` tinyint(1) DEFAULT '0' COMMENT '签到的状态：0-未签到   1-已签到',
  `img_in_url` varchar(255) DEFAULT '' COMMENT '签到图片的地址',
  `img_in_type` tinyint(1) DEFAULT '0' COMMENT '签到图片的状态： 0-现场拍摄 1-选择的图片',
  `position_in` varchar(100) DEFAULT '' COMMENT '签到的位置座标',
  `address_in` varchar(200) DEFAULT NULL COMMENT '签到的地址',
  `sign_in_time` int(10) DEFAULT NULL COMMENT '签到的时间',
  `sign_out_type` tinyint(1) DEFAULT '0' COMMENT '签退的状态：0-未签退   1-已签退',
  `img_out_url` varchar(255) DEFAULT '' COMMENT '签退图片的地址',
  `img_out_type` tinyint(1) DEFAULT '0' COMMENT '签退的图片的状态： 0-现场拍摄 1-选择的图片',
  `position_out` varchar(100) DEFAULT '' COMMENT '签退的位置座标',
  `address_out` varchar(200) DEFAULT NULL COMMENT '签退的地址',
  `sign_out_time` int(10) DEFAULT NULL COMMENT '签退的时间',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建的时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改的时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=311 DEFAULT CHARSET=utf8 COMMENT='操作员拉货签到和签退';
CREATE TABLE `uct_quotation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `main_id` int(10) DEFAULT NULL COMMENT '样品表主表id',
  `wor_id` int(10) NOT NULL COMMENT '业务员id',
  `audit_code` varchar(18) NOT NULL COMMENT '审核code',
  `cus_id` int(10) NOT NULL COMMENT '客户ID',
  `first_wor_id` int(10) NOT NULL DEFAULT '0',
  `first_exa_time` int(10) NOT NULL DEFAULT '0' COMMENT '初审时间',
  `first_memo` varchar(100) DEFAULT '' COMMENT '初审备注',
  `last_wor_id` int(10) NOT NULL DEFAULT '0',
  `last_exa_time` int(10) NOT NULL DEFAULT '0' COMMENT '终审时间',
  `last_memo` varchar(100) NOT NULL DEFAULT '' COMMENT '终审备注',
  `exa_result` int(10) NOT NULL DEFAULT '1' COMMENT '审批结果: 1-待报价 2-待审核 3-初审通过 4-初审不通过 5-终审通过 6-终审不通过',
  `create_time` int(10) NOT NULL DEFAULT '0' COMMENT '生成时间',
  `change_time` int(10) NOT NULL COMMENT '修改的时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8 COMMENT='报价单主表';
CREATE TABLE `uct_quotation_details` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `quota_id` int(10) NOT NULL COMMENT '报价单ID',
  `material_id` int(10) NOT NULL COMMENT '物料ID',
  `img_url` varchar(800) NOT NULL COMMENT '图片地址',
  `pur_price` decimal(10,3) NOT NULL COMMENT '参考采购价',
  `create_time` int(10) NOT NULL COMMENT '生成时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8 COMMENT='报价项目表';
CREATE TABLE `uct_qywx_btn_event` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `corpid` varchar(50) NOT NULL COMMENT '企业corpid',
  `btn_key` varchar(50) NOT NULL COMMENT '按钮key值',
  `from_user` varchar(100) NOT NULL COMMENT '来源',
  `event_type` varchar(30) CHARACTER SET utf8 DEFAULT 'taskcard_click' COMMENT '事件类型',
  `task_id` varchar(30) NOT NULL COMMENT '任务id',
  `agentId` int(10) NOT NULL COMMENT '企业应用的id',
  `msg_type` varchar(255) CHARACTER SET utf8 DEFAULT 'event' COMMENT '消息类型，此时固定为：event',
  `event_time` int(10) NOT NULL COMMENT '事件的时间',
  `status` int(1) DEFAULT '0' COMMENT '是否处理； 0-未处理   1-已处理',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COMMENT='企业微信的任务卡片消息的按钮点击事件的内容';
CREATE TABLE `uct_recycling_data` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `route_id` int(11) NOT NULL COMMENT '路线id',
  `station_id` int(11) NOT NULL COMMENT '站点id',
  `cate_id` int(10) DEFAULT '0' COMMENT '物料id',
  `cate_name` varchar(30) CHARACTER SET utf8 DEFAULT '0' COMMENT '物料名称',
  `serial_number` bigint(32) DEFAULT '0' COMMENT '流水号',
  `rfid` varchar(24) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `net_weight` decimal(10,3) DEFAULT '0.000' COMMENT '净重',
  `tare_weight` decimal(10,3) DEFAULT '0.000' COMMENT '皮重',
  `price` decimal(10,2) DEFAULT '0.00' COMMENT '单价',
  `sub_total` decimal(10,3) DEFAULT '0.000' COMMENT '小计',
  `status` tinyint(4) DEFAULT '1' COMMENT '是否有效： 1--正常   0--无效',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=391 DEFAULT CHARSET=utf8mb4 COMMENT='移动箱体项目的箱体称重数据表';
CREATE TABLE `uct_recycling_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `log_type` varchar(30) NOT NULL COMMENT '类型:route-路线  station-站点  order-数据',
  `admin_id` int(11) NOT NULL COMMENT '操作员id',
  `title` varchar(255) DEFAULT NULL COMMENT '标题',
  `operation` varchar(255) DEFAULT NULL COMMENT '操作内容',
  `describe` varchar(255) DEFAULT NULL COMMENT '描述',
  `ip` varchar(50) DEFAULT NULL COMMENT '操作者ip',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建的时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1885 DEFAULT CHARSET=utf8mb4 COMMENT='移动收集箱体项目的路线和站点操作的日志表';
CREATE TABLE `uct_recycling_routes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `route_code` varchar(50) NOT NULL COMMENT '路线code',
  `carriage_code` varchar(50) NOT NULL COMMENT '箱体code',
  `carriage_name` varchar(50) DEFAULT NULL COMMENT '箱体名称',
  `hw_sn` varchar(100) DEFAULT NULL COMMENT 'sn',
  `hw_ble_model_no` varchar(50) NOT NULL DEFAULT '' COMMENT '蓝牙名称',
  `hw_ble_mac_address` varchar(255) NOT NULL DEFAULT '' COMMENT '蓝牙地址',
  `purchase_incharge` int(10) NOT NULL COMMENT '采购负责人id',
  `purchase_name` varchar(50) DEFAULT NULL COMMENT '采购负责人姓名',
  `driver_id` int(10) NOT NULL COMMENT '司机的id',
  `driver_name` varchar(50) DEFAULT NULL COMMENT '司机的姓名',
  `plate_number` varchar(50) NOT NULL COMMENT '车牌号',
  `cate_id` int(11) DEFAULT NULL COMMENT '物料id',
  `cate_name` varchar(50) DEFAULT NULL COMMENT '物料名称',
  `branch_id` int(11) DEFAULT NULL COMMENT '分部id',
  `branch_name` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '分部名称',
  `weight` decimal(10,2) DEFAULT NULL COMMENT '采购重量',
  `capacity` decimal(10,2) DEFAULT NULL COMMENT '容量',
  `status` varchar(30) DEFAULT NULL COMMENT '状态:waiting-进行中 finish-完成',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建的时间',
  `input_flag` int(255) DEFAULT '0' COMMENT '手工输入标志',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb4 COMMENT='移动收集箱体项目的路线表';
CREATE TABLE `uct_recycling_server_account` (
  `branch_id` int(11) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `auto_commit_flag` varchar(255) DEFAULT 'PUR,SEL'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_recycling_station` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `route_id` int(10) unsigned NOT NULL COMMENT '路线表id',
  `route_code` varchar(30) DEFAULT NULL COMMENT '路线code',
  `station_num` int(11) DEFAULT NULL COMMENT '站点的序号',
  `station_code` varchar(30) DEFAULT NULL COMMENT '站点的code',
  `station_name` varchar(30) DEFAULT NULL COMMENT '站点的名称',
  `station_type` varchar(20) DEFAULT 'PUR' COMMENT '站点的状态:PUR-采购  SEL-销售',
  `FInterID` int(10) DEFAULT '0' COMMENT '订单表的自增id',
  `order_id` varchar(30) DEFAULT '0' COMMENT '订单号',
  `order_type` varchar(50) DEFAULT '''0''' COMMENT '订单状态:''wait_pick_cargo''--待提货   ‘wait_storage_connect''--待入库  ''wait_confirm_return_fee''--已入库  ''wait_confirm_gather''--待销售   ''finish''--已销售',
  `customer_id` int(11) DEFAULT '0' COMMENT '客户id',
  `customer_name` varchar(255) DEFAULT '0' COMMENT '客户名称',
  `company_address` varchar(255) DEFAULT '' COMMENT '企业地址',
  `factory_id` int(10) DEFAULT '0' COMMENT '客户工厂id',
  `manager_id` int(10) DEFAULT '0' COMMENT '业务负责人ID',
  `manager_name` varchar(20) DEFAULT '' COMMENT '业务经理',
  `branch_id` int(11) DEFAULT '0' COMMENT '分部id',
  `branch_name` varchar(20) DEFAULT '0' COMMENT '分部名称',
  `price` decimal(10,3) DEFAULT '0.000' COMMENT '单价',
  `presell_price` decimal(10,3) DEFAULT '0.000' COMMENT '预提销售单价',
  `weight` decimal(10,2) DEFAULT '0.00' COMMENT '总重',
  `sales_weight` double(10,2) DEFAULT '0.00' COMMENT '销售总重',
  `capacity` decimal(10,2) DEFAULT '0.00' COMMENT '容量',
  `sales_total` decimal(10,3) DEFAULT '0.000' COMMENT '销售货款合计',
  `subs_total` decimal(10,3) DEFAULT '0.000' COMMENT '销售补助合计',
  `presell_total` decimal(10,3) DEFAULT '0.000' COMMENT '入库预提合计',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改的时间',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建的时间',
  `job_status` varchar(50) DEFAULT 'waiting' COMMENT '作业状态："waiting"--"等待","start"--"开始","finish"--"完成","abort"--"终止","print"--"打印"',
  `act_status` varchar(50) DEFAULT 'waiting' COMMENT '行动状态："waiting"--"等待","set-out"--"出发","arrived"--"到达","abort"--"终止","sticky-post"--"置顶"',
  `reason_code` varchar(50) DEFAULT NULL COMMENT '问题代码',
  `reason_text` varchar(100) DEFAULT NULL COMMENT '问题描述',
  `act_begin_time` timestamp NULL DEFAULT NULL COMMENT '出发时间',
  `act_end_time` timestamp NULL DEFAULT NULL COMMENT '到达和终止时间',
  `job_begin_time` timestamp NULL DEFAULT NULL COMMENT '作业开始时间',
  `job_end_time` timestamp NULL DEFAULT NULL COMMENT '作业结束时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=412 DEFAULT CHARSET=utf8mb4 COMMENT='移动收集箱体项目的站点表';
CREATE TABLE `uct_red_point` (
  `admin_id` int(11) NOT NULL AUTO_INCREMENT,
  `order_msg` int(11) NOT NULL DEFAULT '0' COMMENT '订单通知',
  `question_msg` int(11) NOT NULL DEFAULT '0' COMMENT '问卷通知',
  PRIMARY KEY (`admin_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `uct_report_params` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `role_ids` varchar(20) NOT NULL DEFAULT '' COMMENT '角色ids',
  `report_name` varchar(50) NOT NULL DEFAULT '' COMMENT '报表名称',
  `data_dims` varchar(20) NOT NULL DEFAULT '' COMMENT '参数粒度',
  `field_name` varchar(20) NOT NULL DEFAULT '' COMMENT '字段名',
  `data_val` varchar(20) NOT NULL DEFAULT '' COMMENT '参数值',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_review` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cus_id` int(10) NOT NULL COMMENT '客户的id',
  `wor_id` int(10) NOT NULL COMMENT '评测人id',
  `create_time` int(10) NOT NULL COMMENT '评测时间',
  `report_time` int(10) DEFAULT NULL COMMENT '报告时间',
  `deletetime` int(10) DEFAULT NULL COMMENT '删除时间',
  `status` tinyint(1) NOT NULL COMMENT '评测的状态：0-草稿 1-待报告 2-待审核 3-完成发布',
  `chang_time` int(10) DEFAULT NULL COMMENT '修改的时间',
  `type_json` json DEFAULT NULL COMMENT '品类和价格的json',
  `begin_ratio` float NOT NULL DEFAULT '0' COMMENT '改善前废料可回收率',
  `last_ratio` float NOT NULL DEFAULT '0' COMMENT '改善后废料可回收率',
  `earnings` float NOT NULL DEFAULT '0' COMMENT '预计改善后增加的收益',
  `change_memo` text COMMENT '预期改善效果',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=211 DEFAULT CHARSET=utf8 COMMENT='废料评测主表';
CREATE TABLE `uct_review_audit` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `review_id` int(10) NOT NULL COMMENT '评测主表的id',
  `audit_id` int(10) NOT NULL COMMENT '审核人id',
  `audit_result` tinyint(1) NOT NULL COMMENT '审核结果: 0-不通过 1- 通过',
  `memo` text NOT NULL COMMENT '审核备注',
  `create_time` int(10) NOT NULL COMMENT '审核时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=22 DEFAULT CHARSET=utf8 COMMENT='评测审核表';
CREATE TABLE `uct_review_auth` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(10) NOT NULL COMMENT '父级id',
  `auth_name` varchar(40) NOT NULL COMMENT '鉴定项目的名称',
  `type` int(10) NOT NULL DEFAULT '1' COMMENT '格式类型',
  `deletetime` int(10) DEFAULT NULL COMMENT '删除时间',
  `rank` int(10) DEFAULT '0' COMMENT '排序',
  `is_show` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否显示：0=不显示  1-显示',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8 COMMENT='鉴定项目配置表';
CREATE TABLE `uct_review_branch` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `branch_name` varchar(30) NOT NULL COMMENT '分支的名称',
  `deletetime` int(10) DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='评测分支配置表';
CREATE TABLE `uct_review_details` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `main_id` int(10) NOT NULL COMMENT '主表的id',
  `auth_id` varchar(20) NOT NULL COMMENT '鉴定项目id',
  `auth_attr` text COMMENT '鉴定项目的属性的json',
  `version` int(10) DEFAULT NULL COMMENT '版本',
  `attr_type` int(10) DEFAULT NULL COMMENT '属性的状态；0-暂存 1-正式内容',
  `img_url` varchar(800) NOT NULL COMMENT '图片的地址',
  `memo` text COMMENT '备注',
  `create_time` int(10) NOT NULL DEFAULT '0' COMMENT '数据生成时间',
  `changes_time` int(10) NOT NULL DEFAULT '0' COMMENT '数据修改的时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=405 DEFAULT CHARSET=utf8 COMMENT='评测的详情表';
CREATE TABLE `uct_sample_collect` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cus_id` int(10) NOT NULL COMMENT '客户ID',
  `wor_id` int(10) NOT NULL COMMENT '采样人id',
  `create_time` int(10) NOT NULL COMMENT '创建时间',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '样品的状态：0-草稿 1-待报价 2-待审核 3-初审通过 4-初审不通过 5-终审通过 6-终审不通过',
  `chang_time` int(10) NOT NULL DEFAULT '0' COMMENT '改变的时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COMMENT='废料评测的样品采集表';
CREATE TABLE `uct_sample_collect_details` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `collect_id` int(11) NOT NULL COMMENT '主表id',
  `collect_code` varchar(30) NOT NULL COMMENT '样品编码',
  `img_url` varchar(800) NOT NULL COMMENT '多图片的地址',
  `memo` varchar(100) DEFAULT NULL COMMENT '备注',
  `create_time` int(10) NOT NULL COMMENT '生成的时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8 COMMENT='废料评测的样品采集详情表';
CREATE TABLE `uct_sell_tax_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cus_id` int(11) NOT NULL COMMENT '客户id',
  `before` decimal(5,2) NOT NULL,
  `after` decimal(5,2) NOT NULL,
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_sign_company` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license` varchar(100) NOT NULL DEFAULT '' COMMENT '营业执照编号',
  `name` varchar(100) NOT NULL COMMENT '公司全称',
  `addr` varchar(100) NOT NULL COMMENT '详细地址',
  `legal_person` varchar(100) NOT NULL COMMENT '法人代表',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_sim_card_main` (
  `iccid` varchar(50) NOT NULL COMMENT 'SIM卡的iccid',
  `msisdn` varchar(50) DEFAULT NULL COMMENT 'MSISDN',
  `carrier` varchar(50) DEFAULT NULL COMMENT '服务商代号',
  `provider` varchar(50) DEFAULT NULL COMMENT '服务提供商名称',
  `packge` varchar(50) DEFAULT NULL COMMENT '套餐名称',
  `register_time` datetime DEFAULT NULL COMMENT '注册时间',
  `activation_time` varchar(32) DEFAULT NULL COMMENT '激活时间',
  `service_end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `capacity` decimal(20,2) DEFAULT NULL COMMENT '总⽤量(MB)',
  `current_usage` decimal(20,2) DEFAULT NULL COMMENT '已使⽤量(MB)',
  `current_cycle_begin` datetime DEFAULT NULL COMMENT '当前周期⽤量⽣效时间',
  `current_cycle_end` datetime DEFAULT NULL COMMENT '当前周期⽤量失效时间',
  `life_cycle` int(10) DEFAULT NULL COMMENT '卡的生命周期的代号:   0-库存,   1-沉默期,  2-可用,    3-待续期订购, 4-待销卡,    5-已销卡',
  `net_status` int(10) DEFAULT NULL COMMENT '卡的网络状态:  0-正常,    1-强制断网,       2-客户断网,    3-超套停,    4-服务结束,  5-提请销卡,  6-销卡',
  `active` blob COMMENT '激活状态:  false-表示没有激活，true-表示激活',
  `online` blob COMMENT '在线状态: false-表示不在线，true-表示在线',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updata_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`iccid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备上面的卡的信息（IOE、北京讯众）';
CREATE TABLE `uct_sms` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `event` varchar(30) NOT NULL DEFAULT 'register' COMMENT '事件',
  `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
  `code` varchar(10) NOT NULL DEFAULT '' COMMENT '验证码',
  `times` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '验证次数',
  `ip` varchar(30) NOT NULL DEFAULT '' COMMENT 'IP',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `createtime` (`createtime`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8 COMMENT='短信验证码表';
CREATE TABLE `uct_sort_line_station` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(50) NOT NULL,
  `line_id` int(11) NOT NULL COMMENT '线别id',
  `device_num` int(11) NOT NULL DEFAULT '0' COMMENT '磅秤数',
  `createtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `states` varchar(20) DEFAULT 'normal' COMMENT '显示状态 hidden normal',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `uct_sorting_cate` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` int(11) DEFAULT NULL COMMENT '父键',
  `creater_id` int(11) DEFAULT NULL COMMENT '创建者id',
  `name` varchar(50) COLLATE utf8_bin DEFAULT NULL COMMENT '品类名称',
  `description` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '详细描述性息',
  `imgpath` varchar(100) COLLATE utf8_bin DEFAULT NULL COMMENT '默认图片路径',
  `order_str` varchar(50) COLLATE utf8_bin DEFAULT NULL COMMENT '查询键位',
  `create_at` varchar(50) COLLATE utf8_bin DEFAULT NULL COMMENT '创建时间',
  `update_at` varchar(50) COLLATE utf8_bin DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=756 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
CREATE TABLE `uct_sorting_commit` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `task_id` int(11) DEFAULT NULL COMMENT '任务表id',
  `line_id` varchar(20) DEFAULT NULL COMMENT '线体id',
  `station_id` varchar(20) NOT NULL COMMENT '分拣工站ID',
  `device_id` varchar(20) DEFAULT NULL COMMENT '装置ID',
  `purchase_order_no` varchar(20) DEFAULT NULL COMMENT '采购单号',
  `cate_id` int(11) DEFAULT NULL COMMENT '品类ID',
  `presell_price` decimal(10,3) DEFAULT NULL COMMENT '预提单价(元/kg)',
  `package_no` varchar(20) DEFAULT NULL COMMENT '包装编号',
  `item_no` int(11) DEFAULT NULL COMMENT '序号',
  `net_weight` decimal(6,2) DEFAULT NULL COMMENT '净重',
  `gross_weight` decimal(6,2) DEFAULT NULL COMMENT '总重',
  `tare_memo` varchar(800) DEFAULT NULL COMMENT '过磅皮重详情',
  `weight_unit` varchar(3) DEFAULT 'kg' COMMENT '重量单位',
  `sub_time` int(10) DEFAULT '0' COMMENT '提交数据的时间',
  `sorter` int(11) DEFAULT NULL COMMENT '分拣人',
  `control_station_id` varchar(30) DEFAULT NULL COMMENT '控制工站id',
  `controler` int(10) DEFAULT NULL COMMENT '控制工站登录人id',
  `begin_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
  `end_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '结束时间',
  `use_time` int(11) DEFAULT NULL COMMENT '耗时,按秒记',
  `process` varchar(20) DEFAULT 'pending' COMMENT '处理状态: [pending  待确认 / passed 确认通过 / rejected 拒绝]',
  `disposal_way` varchar(20) DEFAULT 'sorting' COMMENT '处理方式: [sorting  分拣 / weighing  过磅]',
  `is_pack` tinyint(1) DEFAULT '0' COMMENT '是否封包: [0  不更换太空包 / 1  更换太空包]',
  `leader` varchar(20) DEFAULT NULL,
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=494 DEFAULT CHARSET=utf8 COMMENT='分拣提交记录表,   1. 在什么位置     - 线体      - 工站    - 磅称 2. 是什么物    - 品类    - 包装ID    - 重量    - 单位 3. 是什么人    - 包装者    - 线长 4. 在什么时候    - 开始时间    - 结束时间 5. 是什么事     -提交分拣结果     -处理状态 ';
CREATE TABLE `uct_sorting_container` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sn` varchar(20) NOT NULL,
  `csn` varchar(20) DEFAULT NULL,
  `state` tinyint(1) DEFAULT '1',
  `weight` decimal(6,2) DEFAULT NULL,
  `weight_unit` varchar(5) NOT NULL DEFAULT 'kg',
  `last_calibration_at` datetime DEFAULT NULL,
  `hw_info` json DEFAULT NULL,
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `IDX_CON_SN_UNIQUE` (`sn`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_sorting_job_logs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `line_id` varchar(20) NOT NULL COMMENT '分拣线ID',
  `purchase_order_no` varchar(20) NOT NULL COMMENT '采购单号',
  `revision` int(11) NOT NULL COMMENT '订修号',
  `status` varchar(20) DEFAULT 'startup' COMMENT '分拣状态: [startup 开始分拣 / stop 停止分拣 / finish 分拣完成]',
  `leader` varchar(20) DEFAULT NULL COMMENT '分拣线长',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=593 DEFAULT CHARSET=utf8 COMMENT='批次分拣的历史记录表';
CREATE TABLE `uct_sorting_jobs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `line_id` varchar(20) NOT NULL COMMENT '分拣线ID',
  `order_id` int(10) NOT NULL COMMENT '订单表的自增id',
  `purchase_order_no` varchar(20) NOT NULL COMMENT '采购单号',
  `status` varchar(20) DEFAULT 'startup' COMMENT '分拣状态: [waiting 等待分拣 / startup 开始分拣 / stop 停止分拣 / finish 分拣完成]',
  `leader` varchar(20) DEFAULT NULL COMMENT '分拣线长',
  `priority` int(10) DEFAULT NULL COMMENT '优先级',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `finish_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '完成时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8 COMMENT='当前批次分拣表';
CREATE TABLE `uct_sorting_line` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增长id',
  `warehouse_id` int(11) NOT NULL DEFAULT '0' COMMENT '仓库id',
  `station_num` int(11) NOT NULL DEFAULT '0' COMMENT '工位号',
  `line_num` int(11) NOT NULL DEFAULT '0' COMMENT '线别号',
  `order_id` varchar(50) NOT NULL DEFAULT '0' COMMENT '订单id',
  `cate_id` int(11) NOT NULL DEFAULT '0' COMMENT '物料id',
  `sort_man` int(11) NOT NULL DEFAULT '0' COMMENT '分拣人id',
  `materiel_num` varchar(100) NOT NULL DEFAULT '' COMMENT '包装编码',
  `net_weight` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '入库净重',
  `presell_price` decimal(10,3) NOT NULL DEFAULT '0.000' COMMENT '预提销售单价',
  `storage_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入库时间',
  `start_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始分拣时间',
  `end_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '结束分拣时间',
  `createtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_sorting_line_manage` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '分拣线id号',
  `uuid` varchar(50) NOT NULL COMMENT '分拣线唯一识别码',
  `admin_id` int(11) NOT NULL COMMENT '负责人',
  `branch_id` int(11) NOT NULL COMMENT '分部id',
  `warehouse_id` int(11) NOT NULL COMMENT '仓库',
  `line_name` varchar(200) NOT NULL COMMENT '线别名称',
  `createtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `states` varchar(20) DEFAULT 'normal' COMMENT '显示状态 hidden normal',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `uct_sorting_packings` (
  `package_no` varchar(20) NOT NULL COMMENT '包装编号',
  `station_id` varchar(20) NOT NULL COMMENT '工站ID',
  `device_id` varchar(20) DEFAULT NULL COMMENT '磅秤ID',
  `cate_id` int(11) DEFAULT NULL COMMENT '品类ID',
  `total_net_weight` decimal(6,2) DEFAULT NULL COMMENT '净重',
  `weight_unit` varchar(3) DEFAULT 'kg' COMMENT '重量单位',
  `packer` int(255) DEFAULT NULL,
  `begin_time` timestamp NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` timestamp NULL DEFAULT NULL COMMENT '结束时间',
  `use_time` int(11) DEFAULT NULL COMMENT '耗时,按秒记',
  `status` varchar(10) DEFAULT 'open' COMMENT '包装状态: [open  / close ]',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`package_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `uct_sorting_rfid` (
  `rfid` varchar(24) NOT NULL COMMENT ' RFID EPC 20位 全大写',
  `sn` varchar(20) DEFAULT NULL COMMENT '设备系列号 20位',
  `state` int(11) DEFAULT '0' COMMENT '状态： 0 未使用，1 绑定设备， 2 已失效',
  `create_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_sorting_sop` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'SOP主键',
  `state` tinyint(4) DEFAULT '1' COMMENT '利用int值-控制sop状态(0-待激活，1-激活，2-关闭)',
  `key_id` int(11) NOT NULL COMMENT '关联表键--版本主键',
  `creater_id` int(11) DEFAULT NULL COMMENT '创建者外键',
  `version` int(11) DEFAULT '1' COMMENT '版本号',
  `name` varchar(50) COLLATE utf8_bin DEFAULT NULL COMMENT 'sop名称/',
  `description` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'sop-内容明细',
  `imgpath` varchar(100) COLLATE utf8_bin DEFAULT NULL COMMENT '默认图片路径',
  `create_at` int(11) DEFAULT NULL COMMENT '创建时间',
  `update_at` int(11) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
CREATE TABLE `uct_sorting_task_template` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `template_name` varchar(50) NOT NULL COMMENT '模板名称',
  `branch_id` int(10) DEFAULT '0' COMMENT '分部id',
  `sortage_id` int(10) DEFAULT '0' COMMENT '仓库id',
  `line_id` varchar(10) DEFAULT '0' COMMENT '线体id',
  `supplier_code` varchar(100) DEFAULT '' COMMENT '供应商code',
  `active` tinyint(1) DEFAULT '1' COMMENT '是否生效：0-失效  1-有效',
  `wor_id` int(10) DEFAULT '0' COMMENT '添加模板人id',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COMMENT=' 设置每个线体中各个磅秤物料的模板表';
CREATE TABLE `uct_sorting_task_template_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `temp_id` int(10) NOT NULL COMMENT '模板主表id',
  `station_id` varchar(50) DEFAULT '' COMMENT '工站id',
  `device_id` varchar(50) DEFAULT '' COMMENT '磅秤id',
  `cate_id` int(10) DEFAULT '0' COMMENT '物料id',
  `cate_name` varchar(100) DEFAULT '' COMMENT '物料名称',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8 COMMENT='工位物料设置模板的详情表';
CREATE TABLE `uct_sorting_tasks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `line_id` varchar(20) NOT NULL,
  `station_id` varchar(20) DEFAULT NULL COMMENT '工站ID',
  `device_id` varchar(20) DEFAULT NULL COMMENT '装置ID',
  `device_label` varchar(50) DEFAULT NULL COMMENT '装置标签',
  `cate_id` int(11) DEFAULT NULL COMMENT '品类ID',
  `cate_name` varchar(50) DEFAULT NULL COMMENT '品类名称',
  `active` int(11) DEFAULT '2' COMMENT '活激标志: 0 失效, 1 有效, 2 待生效',
  `leader` int(11) DEFAULT NULL COMMENT '分拣线长',
  `po_no` varchar(20) DEFAULT NULL COMMENT '[备用]指定一个采购单PO',
  `assign_no` int(11) DEFAULT NULL COMMENT '[备用]分配给某个指定的分拣员',
  `package_no` varchar(20) DEFAULT NULL COMMENT '指定一个包装编号',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=612 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_special_settle` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_no` varchar(30) NOT NULL,
  `audit_id` varchar(50) NOT NULL DEFAULT '' COMMENT '钉钉审核id',
  `stop_audit_id` varchar(50) NOT NULL DEFAULT '' COMMENT '终止钉钉审核id',
  `cus_id` int(11) NOT NULL COMMENT '客户id',
  `crmid` varchar(15) NOT NULL DEFAULT '' COMMENT 'crm系统id',
  `cus_name` varchar(100) NOT NULL DEFAULT '' COMMENT '客户名称',
  `apply_id` int(11) NOT NULL COMMENT '申请人',
  `apply_name` varchar(100) NOT NULL DEFAULT '' COMMENT '申请人名称',
  `settle_type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '结算方式 1半月结 2月结',
  `is_publice` tinyint(4) NOT NULL DEFAULT '1' COMMENT '是否对公 1 是 2否',
  `tax` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '税率',
  `sign_company_id` int(11) NOT NULL DEFAULT '0' COMMENT '签约公司',
  `sign_company_name` varchar(100) NOT NULL DEFAULT '' COMMENT '签约公司名称',
  `bill_order` tinyint(4) NOT NULL DEFAULT '0' COMMENT '票款顺序 0非对公  1是先付款后开票,2先开票后付款',
  `begin_date` date NOT NULL COMMENT '开始日期',
  `end_date` date NOT NULL COMMENT '结束日期',
  `sync_tax` tinyint(4) NOT NULL DEFAULT '1' COMMENT '是否同步 1是 2否',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态 1审批中 2生效中 3已失效',
  `stop_status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '终止申请状态  1未申请  2审核中 3终止',
  `audittime` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '审核时间',
  `stoptime` timestamp NULL DEFAULT NULL COMMENT '终止时间',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_special_settle_remark` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `special_settle_id` int(11) NOT NULL COMMENT '特殊结算id',
  `type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '类型 1新增 2审核通过 3终止',
  `remark` varchar(100) NOT NULL DEFAULT '' COMMENT '备注文本',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_spi_customer_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `month` varchar(50) NOT NULL COMMENT '月份',
  `branch_id` int(11) DEFAULT NULL COMMENT '分部',
  `cust_id` int(11) DEFAULT NULL COMMENT '客户id',
  `cust_name` varchar(255) DEFAULT NULL COMMENT '客户名称',
  `cust_type` varchar(20) DEFAULT NULL COMMENT '客户类型:up=上游客户,down=下游客户',
  `star_level` int(11) DEFAULT '1' COMMENT '客户星级',
  `create_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3439 DEFAULT CHARSET=utf8mb4 COMMENT='客户上个月的星级';
CREATE TABLE `uct_spi_level` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `level1` decimal(10,2) NOT NULL COMMENT '等级1',
  `level2` decimal(10,2) DEFAULT NULL COMMENT '等级2',
  `create_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='spi的等级';
CREATE TABLE `uct_spi_target` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `time_dims` varchar(10) NOT NULL COMMENT '时间维度',
  `time_val` varchar(30) DEFAULT NULL COMMENT '时间标签',
  `begin_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `data_dims` varchar(30) DEFAULT NULL COMMENT '数据颗粒度',
  `data_val` varchar(100) DEFAULT NULL COMMENT '数据值',
  `dept_name` varchar(100) DEFAULT NULL COMMENT '所属部门名称',
  `parent_id` varchar(100) DEFAULT '0' COMMENT '父数据值',
  `owner` varchar(50) DEFAULT NULL COMMENT '所有人',
  `target_dims` varchar(30) DEFAULT NULL COMMENT '目标维度',
  `target_val` decimal(10,2) DEFAULT NULL COMMENT '目标值',
  `target_unit` varchar(20) DEFAULT NULL COMMENT '目标单位',
  `create_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1012 DEFAULT CHARSET=utf8mb4 COMMENT='绩效目标表';
CREATE TABLE `uct_statements_action_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `main_id` int(10) DEFAULT NULL COMMENT '主表的id',
  `action_type` varchar(20) DEFAULT NULL COMMENT '动作:''apply''--申请,''check''--检查,''make''--生成,''redo''--重做,''submit''--提交,''approval''--审核,''sent''--推送,''cancel''--作废,''feedback''--反馈',
  `identity` varchar(10) DEFAULT '服务人员' COMMENT '操作人的身份（''系统'',''客户'',''服务人员''）',
  `identity_id` int(10) DEFAULT NULL COMMENT '操作人的id',
  `content` varchar(255) DEFAULT NULL COMMENT '操作内容',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='对账单的动作日志';
CREATE TABLE `uct_statements_basic_data` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` int(10) DEFAULT '0' COMMENT '客户id',
  `customer_name` varchar(100) DEFAULT NULL COMMENT '客户名称',
  `stas_type` int(10) DEFAULT '1' COMMENT '对账单类型：1--收付款项凭证  2--往来账务核对',
  `stas_way` varchar(20) DEFAULT NULL COMMENT '对账方式：''分成''    ''常规采购''',
  `way_ratio` decimal(10,3) DEFAULT '0.000' COMMENT '分成比率',
  `is_tax` tinyint(2) DEFAULT '0' COMMENT '是否含税：0--不含税   1--含税',
  `tax_ratio` decimal(10,3) DEFAULT NULL COMMENT '税率',
  `status` tinyint(2) DEFAULT '0' COMMENT '使用状态： 0--刚刚生成  1--正常使用     2--过期',
  `start_time` int(10) DEFAULT NULL COMMENT '开始时间',
  `end_time` int(10) DEFAULT NULL COMMENT '结束时间',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COMMENT='各个客户的对账单的基础数据';
CREATE TABLE `uct_statements_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `main_id` int(11) DEFAULT NULL COMMENT '主表的id',
  `version` int(10) DEFAULT '0' COMMENT '版本',
  `FInterID` int(11) DEFAULT NULL COMMENT '订单内码ID',
  `order_id` varchar(20) DEFAULT NULL COMMENT '订单号',
  `order_type` int(10) NOT NULL DEFAULT '1' COMMENT '订单状态：1--待付款  2--已付款',
  `pick_goods_time` datetime DEFAULT NULL COMMENT '提货的时间',
  `purchase_incharge` int(10) DEFAULT NULL COMMENT '采购负责人ID',
  `purchase_name` varchar(30) DEFAULT NULL COMMENT '采购负责人姓名',
  `total_net_weight` decimal(10,3) DEFAULT NULL COMMENT '合计净重',
  `total_amount` decimal(10,3) DEFAULT NULL COMMENT '合计金额',
  `memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `material_json` json DEFAULT NULL COMMENT '订单所属物料的json数据',
  `detail_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态： 0--删除  1--正常  ',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COMMENT='客户对账单的详情表';
CREATE TABLE `uct_statements_main` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stas_id` varchar(30) CHARACTER SET utf8 NOT NULL COMMENT '对账单id',
  `customer_id` int(11) DEFAULT NULL COMMENT '客户id',
  `stas_from` varchar(10) DEFAULT 'services' COMMENT '申请来源：''system''--系统触发   ''customer''--客户申请  ''services''--服务人员申请',
  `customer_name` varchar(100) DEFAULT NULL COMMENT '客户名称',
  `purchase_incharge` int(10) DEFAULT NULL COMMENT '客户对应的采购负责人id',
  `purchase_name` varchar(20) DEFAULT NULL COMMENT '客户对应的采购负责人名称',
  `purchase_tel` bigint(20) DEFAULT NULL COMMENT '客户对应的采购负责人联系电话',
  `stas_start_time` int(10) DEFAULT NULL COMMENT '对账的开始日期',
  `stas_end_time` int(10) DEFAULT NULL COMMENT '对账的结束日期',
  `pur_company` varchar(200) DEFAULT NULL COMMENT '购货单位',
  `pur_people` varchar(30) DEFAULT NULL COMMENT '购货单位负责人',
  `pur_tel` varchar(15) DEFAULT NULL COMMENT '购货单位负责人电话',
  `stas_type` varchar(10) DEFAULT 'payment' COMMENT '对账单类型：''payment''--收付款项凭证  ''history''--往来账务核对',
  `stas_way` varchar(50) DEFAULT 'general' COMMENT '对账方式：''general''--"常规采购"   ''profit_sharing''--"利润分成"',
  `way_ratio` decimal(10,3) DEFAULT NULL COMMENT '分成比率',
  `is_tax` tinyint(1) DEFAULT NULL COMMENT '是否含税：0--不含税   1--含税',
  `tax_ratio` decimal(10,3) DEFAULT NULL COMMENT '税率',
  `stas_state` varchar(10) DEFAULT 'new' COMMENT '对账单状态: ''new''--新申请,''generated''--已生成,''submitted''--已提交,''approved''--已审核,''rejected''--已拒绝,''TBC''--待确认,''confirmed''--已确认,''failure''--确认失败,''canceled''--已做废,''expired''--已过期',
  `detail_version` int(10) DEFAULT '0' COMMENT '版本',
  `pur_total_net_weight` decimal(10,3) DEFAULT '0.000' COMMENT '合计采购净重',
  `pur_total_amount` decimal(10,3) DEFAULT '0.000' COMMENT '合计采购金额',
  `tax_total_amount` decimal(10,3) DEFAULT '0.000' COMMENT '含税采购金额',
  `pay_divided_amount` decimal(10,3) DEFAULT '0.000' COMMENT '应付分成金额',
  `stas_memo` varchar(255) DEFAULT NULL COMMENT '备注',
  `appr_num` varchar(50) DEFAULT NULL COMMENT '审批单号',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `confirmed_time` int(10) DEFAULT NULL COMMENT '确认时间',
  `send_time` int(10) DEFAULT NULL COMMENT '推送时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COMMENT='客户的对账单主表';
CREATE TABLE `uct_statements_main_feedback` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `main_id` int(10) NOT NULL COMMENT '对账单的主表id',
  `feed_name` varchar(20) CHARACTER SET utf8 DEFAULT NULL COMMENT '反馈人的姓名',
  `msg_type` tinyint(2) DEFAULT '1' COMMENT '类型： 1--反馈内容   2--图片地址',
  `content` text CHARACTER SET utf8 COMMENT '反馈的内容',
  `img_url` varchar(100) CHARACTER SET utf8 DEFAULT NULL COMMENT '图片的地址',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COMMENT='对账单客户的反馈信息/图片的信息';
CREATE TABLE `uct_testmodule_test` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) NOT NULL COMMENT '管理员ID',
  `category_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '分类ID(单选)',
  `category_ids` varchar(100) NOT NULL COMMENT '分类ID(多选)',
  `week` enum('monday','tuesday','wednesday') NOT NULL COMMENT '星期(单选):monday=星期一,tuesday=星期二,wednesday=星期三',
  `flag` set('hot','index','recommend') NOT NULL DEFAULT '' COMMENT '标志(多选):hot=热门,index=首页,recommend=推荐',
  `genderdata` enum('male','female') NOT NULL DEFAULT 'male' COMMENT '性别(单选):male=男,female=女',
  `hobbydata` set('music','reading','swimming') NOT NULL COMMENT '爱好(多选):music=音乐,reading=读书,swimming=游泳',
  `title` varchar(50) NOT NULL DEFAULT '' COMMENT '标题',
  `content` text NOT NULL COMMENT '内容',
  `image` varchar(100) NOT NULL DEFAULT '' COMMENT '图片',
  `images` varchar(1500) NOT NULL DEFAULT '' COMMENT '图片组',
  `attachfile` varchar(100) NOT NULL DEFAULT '' COMMENT '附件',
  `keywords` varchar(100) NOT NULL DEFAULT '' COMMENT '关键字',
  `description` varchar(255) NOT NULL DEFAULT '' COMMENT '描述',
  `city` varchar(100) NOT NULL DEFAULT '' COMMENT '省市',
  `price` float(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '价格',
  `views` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '点击',
  `startdate` date DEFAULT NULL COMMENT '开始日期',
  `activitytime` datetime DEFAULT NULL COMMENT '活动时间(datetime)',
  `year` year(4) DEFAULT NULL COMMENT '年',
  `times` time DEFAULT NULL COMMENT '时间',
  `refreshtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '刷新时间(int)',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `switch` tinyint(1) NOT NULL DEFAULT '0' COMMENT '开关',
  `status` enum('normal','hidden') NOT NULL DEFAULT 'normal' COMMENT '状态',
  `state` enum('0','1','2') NOT NULL DEFAULT '1' COMMENT '状态值:0=禁用,1=正常,2=推荐',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='测试表';
CREATE TABLE `uct_third` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '会员ID',
  `platform` enum('weibo','wechat','qq') NOT NULL COMMENT '第三方应用',
  `openid` varchar(50) NOT NULL DEFAULT '' COMMENT '第三方唯一ID',
  `openname` varchar(50) NOT NULL DEFAULT '' COMMENT '第三方会员昵称',
  `access_token` varchar(100) NOT NULL DEFAULT '',
  `refresh_token` varchar(100) NOT NULL DEFAULT '',
  `expires_in` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '有效期',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `logintime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '登录时间',
  `expiretime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '过期时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `platform` (`platform`,`openid`) USING BTREE,
  KEY `user_id` (`user_id`,`platform`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='第三方登录表';
CREATE TABLE `uct_trans_revise_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) DEFAULT NULL COMMENT '操作者id',
  `order_id` int(11) DEFAULT NULL COMMENT '订单id',
  `type` int(11) DEFAULT '0' COMMENT '订单类型 0 采购流程 1现买现卖 2销售订单',
  `revise_item` text COMMENT '修改事项',
  `createtime` int(11) DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=423 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_up` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `crmid` varchar(20) DEFAULT NULL COMMENT 'crmid',
  `name` varchar(20) DEFAULT NULL COMMENT '姓名',
  `mobile` varchar(20) DEFAULT NULL COMMENT '手机',
  `company_province` varchar(20) DEFAULT NULL COMMENT '省',
  `company_city` varchar(20) DEFAULT NULL COMMENT '市',
  `company_region` varchar(20) DEFAULT NULL COMMENT '区',
  `company_addr` varchar(250) DEFAULT NULL COMMENT '详细地址',
  `first_business_time` varchar(255) DEFAULT NULL COMMENT '第一次交易时间',
  `position` varchar(20) NOT NULL DEFAULT '0,0' COMMENT '经纬度',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2913 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_up2` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT '自增长id',
  `crmId` varchar(25) DEFAULT NULL COMMENT 'crmid',
  `followUserId` varchar(25) DEFAULT NULL COMMENT '跟随id',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `mobile` varchar(25) DEFAULT NULL COMMENT '手机号',
  `phone` varchar(25) DEFAULT NULL COMMENT '手机号',
  `title` varchar(50) DEFAULT NULL COMMENT '职位',
  `fax` varchar(50) DEFAULT NULL COMMENT '传真',
  `qq` varchar(50) DEFAULT NULL COMMENT 'qq',
  `email` varchar(25) DEFAULT NULL COMMENT 'email地址',
  `company` text COMMENT '客户公司名称',
  `company_addr` text COMMENT '公司地址',
  `company_url` text COMMENT '公司网址',
  `company_country` text COMMENT '公司国家',
  `call` text COMMENT '称呼',
  `memo` text COMMENT '备注',
  `gender` int(11) DEFAULT NULL COMMENT '客户性别0无/1/男/2女',
  `company_province` varchar(30) DEFAULT NULL COMMENT '公司所在省份',
  `company_city` varchar(30) DEFAULT NULL COMMENT '公司所在市',
  `company_region` varchar(30) DEFAULT NULL COMMENT '公司所在镇',
  `vocation` varchar(30) DEFAULT NULL COMMENT '客户行业',
  `modifyTime` varchar(100) DEFAULT NULL COMMENT '客户最近动态更新时间',
  `contactTime` varchar(100) DEFAULT NULL COMMENT '客户最近动态更新时间',
  `createTime` varchar(100) DEFAULT NULL COMMENT '客户创建时间',
  `lastFollowUserId` varchar(25) DEFAULT NULL COMMENT '最后跟进人id',
  `step` int(11) DEFAULT NULL COMMENT '客户阶段',
  `channelId` varchar(25) DEFAULT NULL COMMENT '渠道ID',
  `corpId` varchar(25) DEFAULT NULL COMMENT '公司ID',
  `createUserId` varchar(25) DEFAULT NULL COMMENT '创建人ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1303 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_up_modify_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) NOT NULL DEFAULT '' COMMENT '订单号',
  `customer_id` int(11) NOT NULL COMMENT '客户id',
  `type` smallint(6) NOT NULL DEFAULT '0' COMMENT '审核类型',
  `crmid` bigint(20) unsigned NOT NULL COMMENT '客户crmid',
  `accid` varchar(50) NOT NULL DEFAULT '' COMMENT '客户accid',
  `cus_type` varchar(50) NOT NULL DEFAULT 'up' COMMENT '客户类型',
  `crm_type` varchar(50) NOT NULL DEFAULT 'huke' COMMENT 'crm系统平台类型',
  `field_list` text COMMENT '修改字段',
  `opinion` varchar(100) DEFAULT '' COMMENT '意见',
  `manager_id` int(11) DEFAULT NULL COMMENT '业务负责人',
  `state` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态  1待审核 2审核通过 3审核不通过',
  `audittime` timestamp NULL DEFAULT NULL COMMENT '审核时间',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `sync_flag` varchar(10) DEFAULT 'waiting' COMMENT '同步标志',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) unsigned DEFAULT NULL COMMENT '后台用户ID',
  `appletid` varchar(50) NOT NULL COMMENT '应用ID',
  `openid` varchar(50) NOT NULL COMMENT '用户openid',
  `unionid` varchar(50) NOT NULL DEFAULT '' COMMENT '用户unionid',
  `session_key` varchar(255) NOT NULL DEFAULT '' COMMENT '小程序会话密钥',
  `username` varchar(32) NOT NULL DEFAULT '' COMMENT '用户名',
  `nickname` varchar(50) NOT NULL DEFAULT '' COMMENT '昵称',
  `subscribe` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1已关注 0未关注',
  `sex` tinyint(1) unsigned DEFAULT NULL COMMENT '1男 2女',
  `language` varchar(32) NOT NULL DEFAULT '' COMMENT '客户端语言',
  `city` varchar(50) NOT NULL DEFAULT '' COMMENT '城市',
  `province` varchar(50) NOT NULL DEFAULT '' COMMENT '省份',
  `country` varchar(50) NOT NULL DEFAULT '' COMMENT '国家',
  `password` varchar(32) NOT NULL DEFAULT '' COMMENT '密码',
  `salt` varchar(30) NOT NULL DEFAULT '' COMMENT '密码盐',
  `email` varchar(100) NOT NULL DEFAULT '' COMMENT '电子邮箱',
  `mobile` varchar(11) NOT NULL DEFAULT '' COMMENT '手机号',
  `avatar` varchar(255) NOT NULL DEFAULT '' COMMENT '头像',
  `level` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '等级',
  `gender` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '性别',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `score` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积分',
  `prevtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '上次登录时间',
  `loginfailure` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '失败次数',
  `logintime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '登录时间',
  `loginip` varchar(50) NOT NULL DEFAULT '' COMMENT '登录IP',
  `joinip` varchar(50) NOT NULL DEFAULT '' COMMENT '加入IP',
  `jointime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '加入时间',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `token` varchar(50) NOT NULL DEFAULT '' COMMENT 'Token',
  `status` varchar(30) NOT NULL DEFAULT '' COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `username` (`username`) USING BTREE,
  KEY `email` (`email`) USING BTREE,
  KEY `mobile` (`mobile`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=437 DEFAULT CHARSET=utf8 COMMENT='会员表';
CREATE TABLE `uct_vehicle` (
  `vehicle_id` varchar(36) DEFAULT NULL COMMENT '车辆ID',
  `plate_number` varchar(20) DEFAULT NULL COMMENT '车牌号',
  `pass_number` varchar(20) DEFAULT NULL COMMENT '行驶证',
  `model` varchar(20) DEFAULT NULL COMMENT '车辆类型',
  `status` varchar(20) DEFAULT NULL COMMENT '车辆状态',
  `vehicle_weight` double DEFAULT NULL COMMENT '车辆重量（单位：吨）',
  `vehicle_load_weight` double DEFAULT NULL COMMENT '车辆荷载（单位：吨）',
  `manufacturer` varchar(255) DEFAULT NULL COMMENT '生产厂家',
  `license_plate_color` varchar(50) DEFAULT NULL COMMENT '车牌颜色',
  `engine_no` varchar(50) DEFAULT NULL COMMENT '发动机号',
  `engine_number` varchar(50) DEFAULT NULL COMMENT '车架号',
  `container_sn` varchar(50) DEFAULT NULL COMMENT '车厢编号',
  `tem_id` varchar(50) DEFAULT NULL COMMENT '终端号',
  `remark` text COMMENT '备注',
  `org_id` varchar(36) DEFAULT NULL COMMENT '所属组织',
  `create_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `create_user_id` int(11) DEFAULT NULL COMMENT '创建人ID',
  `update_at` timestamp NULL DEFAULT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_voucher` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `no` varchar(30) NOT NULL COMMENT '订单号',
  `audit_id` varchar(50) NOT NULL DEFAULT '' COMMENT '钉钉审核订单号',
  `task_id` varchar(50) NOT NULL DEFAULT '' COMMENT '钉钉任务id',
  `branch_id` int(11) NOT NULL DEFAULT '0' COMMENT '分部id',
  `branch_text` varchar(50) NOT NULL DEFAULT '' COMMENT '分部名称',
  `place_order_name` varchar(50) NOT NULL COMMENT '下单人昵称',
  `place_order_id` int(11) NOT NULL COMMENT '下单人id',
  `place_order_mobile` varchar(15) NOT NULL DEFAULT '' COMMENT '下单人手机号',
  `cus_linkman_name` varchar(50) NOT NULL DEFAULT '' COMMENT '客户对接人',
  `cus_id` int(11) NOT NULL COMMENT '客户id',
  `cus_name` varchar(100) NOT NULL DEFAULT '' COMMENT '客户公司',
  `cus_code` varchar(50) NOT NULL DEFAULT '' COMMENT '客户编码',
  `cus_type` varchar(50) NOT NULL DEFAULT 'down' COMMENT '客户类型  up上游 down下游',
  `pay_use` varchar(50) NOT NULL DEFAULT 'deposit' COMMENT '支付用途   deposit定金   pledge保证金  refund退款',
  `pay_way` varchar(50) NOT NULL DEFAULT 'wechat' COMMENT '支付方式',
  `collect_bank_account` varchar(50) NOT NULL DEFAULT '' COMMENT '到账银行账号',
  `account_num` varchar(50) NOT NULL DEFAULT '' COMMENT '客户银行账号',
  `bank` varchar(50) NOT NULL DEFAULT '' COMMENT '开户行(上游)',
  `bank_address` varchar(50) NOT NULL DEFAULT '' COMMENT '开户地址(上游)',
  `wechat_name` varchar(50) NOT NULL DEFAULT '' COMMENT '微信名称',
  `cash` double NOT NULL DEFAULT '0' COMMENT '现结金额',
  `amount` double NOT NULL DEFAULT '0' COMMENT '金额',
  `surplus` double NOT NULL DEFAULT '0' COMMENT '剩余金额',
  `cause` varchar(200) NOT NULL DEFAULT '' COMMENT '付款原因(上游)',
  `images` varchar(200) NOT NULL DEFAULT '' COMMENT '图片列表',
  `qc` tinyint(4) NOT NULL DEFAULT '0' COMMENT '1为期初单',
  `status` varchar(20) NOT NULL DEFAULT 'untreated' COMMENT '状态 untreated未受理  act_ refuse会计审核拒绝   act_accept会计审核通过   refuse拒绝   uncleared未结清   cleared已结清',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_voucher_remark` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `voucher_id` int(11) NOT NULL COMMENT '凭证id',
  `admin_id` int(11) NOT NULL DEFAULT '0' COMMENT '留言人id',
  `nickname` varchar(50) NOT NULL DEFAULT '' COMMENT '留言人昵称',
  `remark` varchar(200) NOT NULL DEFAULT '' COMMENT '留言',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=222 DEFAULT CHARSET=utf8mb4;
CREATE TABLE `uct_waste_cate` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `branch_id` int(10) unsigned NOT NULL COMMENT '分部ID',
  `parent_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '父级ID',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '名称',
  `top_class` varchar(20) DEFAULT '' COMMENT '所属大类(null--初始状态  glass--玻璃    metal--金属 plastic--塑料    waste-paper--纸  semi-finished--半成品  wood--木材  comprehensive--综合类  material--辅材  other--其他类别)',
  `standard_price` float(10,2) DEFAULT NULL COMMENT '标准报价(元/kg)',
  `presell_price` float(10,3) DEFAULT '0.000' COMMENT '预提单价(元/kg)',
  `risk_cost` float(10,2) DEFAULT NULL COMMENT '风险成本(元/kg)',
  `image` varchar(100) DEFAULT NULL COMMENT '图片',
  `value_type` varchar(20) DEFAULT 'valuable' COMMENT '价值类型  valuable有价  unvaluable 无价',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `state` enum('1','0') NOT NULL DEFAULT '1' COMMENT '状态:1=启用,0=禁用',
  `carbon_parm` float NOT NULL DEFAULT '0' COMMENT '碳减排参数',
  `start_time` bigint(20) DEFAULT NULL COMMENT '开始时间',
  `end_time` bigint(20) DEFAULT NULL COMMENT '结束时间',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  `direction` int(11) DEFAULT NULL COMMENT '重定向位置',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `uct_waste_cate_idx_002` (`parent_id`) USING BTREE,
  KEY `uct_waste_cate_idx_001` (`branch_id`) USING BTREE,
  KEY `id_name_branch_id` (`id`,`name`,`branch_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13346 DEFAULT CHARSET=utf8 COMMENT='废料分类表';
CREATE TABLE `uct_waste_cate_actual` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) NOT NULL COMMENT '分部id',
  `customer_id` int(11) unsigned NOT NULL COMMENT '客户id',
  `cate_id` int(10) unsigned NOT NULL COMMENT '废料id',
  `expect_sale` int(10) unsigned DEFAULT NULL COMMENT '预计销售量',
  `standard_value` float(10,2) DEFAULT NULL COMMENT '标准销售报价',
  `actual_value` float(10,2) DEFAULT NULL COMMENT '实际销售单价',
  `start_time` int(10) unsigned NOT NULL COMMENT '开始时间',
  `end_time` int(10) unsigned NOT NULL COMMENT '结束时间',
  `createtime` int(10) unsigned NOT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=utf8 COMMENT='有效销售计划表';
CREATE TABLE `uct_waste_cate_actual_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `order_id` varchar(50) NOT NULL DEFAULT '' COMMENT '审批单号',
  `audit_id` varchar(50) NOT NULL DEFAULT '' COMMENT '钉钉审批id',
  `branch_id` int(10) unsigned NOT NULL COMMENT '分部id',
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发起者管理员id',
  `examine_remark` varchar(255) DEFAULT NULL COMMENT '销售专员说明',
  `branch_remark` varchar(255) DEFAULT NULL COMMENT '分部说明',
  `hq_remark` varchar(255) DEFAULT NULL COMMENT '总部说明',
  `hq_examine_time` int(10) unsigned DEFAULT NULL COMMENT '总部审核时间',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT '申请状态 1:分部审核中; 2:待总部审核;3:分部审核不通过;4总部审核不通过;5总部审核通过',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=279 DEFAULT CHARSET=utf8 COMMENT='销售计划审核日志表';
CREATE TABLE `uct_waste_cate_actual_log_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) NOT NULL COMMENT '分部id',
  `actual_log_id` int(11) NOT NULL COMMENT '发起审核id',
  `customer_id` int(11) NOT NULL COMMENT '客户id',
  `cate_id` int(11) NOT NULL COMMENT '废料id',
  `expect_sale` int(11) DEFAULT NULL COMMENT '预计销售量',
  `presell_price` float(10,3) DEFAULT NULL COMMENT '标准报价',
  `actual_value` float(10,3) DEFAULT NULL COMMENT '实际销售单价',
  `state` int(10) DEFAULT '1' COMMENT '审核状态  0不通过   1审核通过',
  `level` varchar(50) DEFAULT 'standard' COMMENT '质量等级',
  `images` varchar(500) DEFAULT '' COMMENT '图片列表',
  `remark` varchar(50) DEFAULT '' COMMENT '备注',
  `start_time` int(10) unsigned DEFAULT NULL COMMENT '开始时间',
  `end_time` int(10) unsigned DEFAULT NULL COMMENT '结束时间',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `state` (`state`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=330 DEFAULT CHARSET=utf8 COMMENT='销售计划记录日志表';
CREATE TABLE `uct_waste_cate_expect_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `admin_id` int(10) unsigned DEFAULT NULL COMMENT '发起审核管理员id',
  `branch_id` int(10) unsigned DEFAULT NULL COMMENT '分部id',
  `file_name` varchar(255) DEFAULT NULL COMMENT '审批文件名称',
  `examine_remark` varchar(255) DEFAULT NULL COMMENT '审核说明',
  `branch_remark` varchar(255) DEFAULT NULL COMMENT '分部审核说明',
  `hq_remark` varchar(255) DEFAULT NULL COMMENT '总部审核说明',
  `hq_examine_time` int(10) unsigned DEFAULT NULL COMMENT '总部审核时间',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT '申请状态 1:分部审核中; 2:待总部审核;3:分部审核不通过;4总部审核不通过;5总部审核通过',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1174 DEFAULT CHARSET=utf8 COMMENT='预提销售单价';
CREATE TABLE `uct_waste_cate_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '操作者ID',
  `cate_id` int(10) unsigned NOT NULL COMMENT '废料分类ID',
  `type` enum('standard_price','presell_price','risk_cost') NOT NULL COMMENT '类型:standard_price=标准报价(元/kg),presell_price=预售价(元/kg),risk_cost=风险成本(元/kg)',
  `before_value` float(10,3) DEFAULT NULL COMMENT '变化前的值',
  `value` float(10,3) DEFAULT NULL COMMENT '变化后的值',
  `ip` varchar(50) NOT NULL DEFAULT '' COMMENT '操作者IP',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `createtime` (`createtime`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2686 DEFAULT CHARSET=utf8 COMMENT='废料分类记录表';
CREATE TABLE `uct_waste_cate_overdue` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) DEFAULT NULL COMMENT '分部ID',
  `ware_id` int(11) DEFAULT NULL COMMENT '仓库ID',
  `cate_id` int(11) NOT NULL COMMENT '品类ID',
  `cate_name` varchar(100) DEFAULT NULL COMMENT '品类名称',
  `state` enum('1','0') NOT NULL DEFAULT '1' COMMENT '状态:1=启用,0=禁用',
  `create_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updata_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=310 DEFAULT CHARSET=utf8mb4 COMMENT='需要查询的超期品类表（仓库指标月度看板使用）';
CREATE TABLE `uct_waste_customer` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `cus_accid` varchar(100) NOT NULL DEFAULT '0' COMMENT '互客系统id',
  `crmid` varchar(100) NOT NULL DEFAULT '0' COMMENT 'crmid',
  `admin_id` varchar(100) DEFAULT NULL COMMENT '客户账号ID',
  `branch_id` int(10) unsigned DEFAULT NULL COMMENT '分部ID',
  `internal` int(10) unsigned DEFAULT '0' COMMENT '内部客户 0否 1是',
  `green_coin` int(10) unsigned DEFAULT '0' COMMENT '绿币',
  `customer_type` enum('up','down') NOT NULL DEFAULT 'up' COMMENT '客户类型:up=上游客户,down=下游客户',
  `customer_code` varchar(100) NOT NULL DEFAULT '' COMMENT '客户编码',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '企业全称',
  `agre_expire` date DEFAULT NULL COMMENT '合同到期时间',
  `sign_company` varchar(100) NOT NULL DEFAULT '' COMMENT '签约公司',
  `print_title_id` int(11) NOT NULL DEFAULT '1' COMMENT '客户单据打印id',
  `name_en` varchar(100) NOT NULL DEFAULT '' COMMENT '企业全称(英文)',
  `allot_id` int(11) NOT NULL DEFAULT '0' COMMENT '指定的分配人',
  `manager_id` int(10) unsigned DEFAULT NULL COMMENT '业务负责人ID',
  `server_id` int(10) unsigned DEFAULT NULL COMMENT '服务负责人ID',
  `seller_incharge` int(10) unsigned DEFAULT NULL COMMENT '销售负责人ID',
  `service_department` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '服务部门 1 客服 2企服',
  `incharge` varchar(50) NOT NULL DEFAULT '' COMMENT '客户负责人',
  `juridical_person` varchar(50) NOT NULL DEFAULT '' COMMENT '公司法人',
  `class_a` varchar(20) NOT NULL DEFAULT '' COMMENT '客户类别a  A1 A2 A3 A4',
  `class_b` varchar(20) NOT NULL DEFAULT '' COMMENT '客户类别b  B1 B2 B3 B4',
  `trade_type` varchar(5) DEFAULT NULL COMMENT '行业类型   1模切、涂布类 = M 特钢类 = T 隔膜类 = G 车废类 = C 其他类 = Q',
  `mobile` char(15) NOT NULL DEFAULT '' COMMENT '联系电话',
  `waste_type` varchar(100) NOT NULL DEFAULT '' COMMENT '废料种类',
  `level` int(10) unsigned DEFAULT NULL COMMENT '客户级别',
  `company_address` varchar(255) DEFAULT NULL COMMENT '企业地址',
  `company_position` text COMMENT '企业坐标',
  `company_adcode` bigint(20) DEFAULT NULL COMMENT '行政区编码(adcode)',
  `company_region` varchar(255) DEFAULT NULL COMMENT '行政区名称',
  `adcode_status` tinyint(1) DEFAULT '1' COMMENT '是否地址修改：0--正常  1--更新',
  `industry` int(10) unsigned DEFAULT NULL COMMENT '行业类别',
  `website` varchar(50) DEFAULT NULL COMMENT '官网',
  `sales_area` varchar(50) DEFAULT NULL COMMENT '销售区域',
  `annual_waste` float unsigned DEFAULT NULL COMMENT '年度废料量',
  `detail` varchar(500) DEFAULT NULL COMMENT '详情描述',
  `tax_cert` varchar(50) DEFAULT NULL COMMENT '税务登记证号',
  `trading_cert` varchar(50) DEFAULT NULL COMMENT '营业执照号',
  `company_nature` int(10) unsigned DEFAULT NULL COMMENT '企业性质',
  `tax_type` int(10) unsigned DEFAULT NULL COMMENT '税票类型',
  `settle_way` int(10) unsigned DEFAULT NULL COMMENT '结算方式',
  `back_percent` int(10) unsigned DEFAULT NULL COMMENT '分成比例(%)',
  `month_receivable` int(10) unsigned DEFAULT '0' COMMENT '月结算服务 1是 0不是',
  `statements_json` json DEFAULT NULL COMMENT '客户的结算基础资料（json格式）',
  `is_hide_zero` tinyint(1) NOT NULL DEFAULT '0' COMMENT '对账单是否屏蔽为零的项：0--不屏蔽     1--屏蔽',
  `is_separate` tinyint(1) NOT NULL DEFAULT '0' COMMENT '对账单是否收付款分离： 0--不分离    1--分离',
  `black_state` int(10) DEFAULT '0' COMMENT '重点关注客户',
  `sign_company_id` int(10) DEFAULT '0' COMMENT '签约公司id',
  `tax` decimal(5,2) DEFAULT '0.00' COMMENT '税率',
  `state` enum('black','consult','draft','enabled') NOT NULL DEFAULT 'draft' COMMENT '状态:black=黑名单,consult=客户咨询,draft=草稿,enabled=已提交',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4749 DEFAULT CHARSET=utf8 COMMENT='客户表';
CREATE TABLE `uct_waste_customer_factory` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `customer_id` int(10) unsigned NOT NULL COMMENT '客户ID',
  `province` varchar(50) NOT NULL DEFAULT '' COMMENT '省份',
  `city` varchar(50) NOT NULL DEFAULT '' COMMENT '城市',
  `area` varchar(50) NOT NULL DEFAULT '' COMMENT '区域',
  `detail_address` varchar(255) NOT NULL DEFAULT '' COMMENT '详细地址',
  `linkman` varchar(50) NOT NULL DEFAULT '' COMMENT '联系人',
  `job` varchar(50) NOT NULL DEFAULT '' COMMENT '职务',
  `mobile` char(15) NOT NULL DEFAULT '' COMMENT '联系电话',
  `email` varchar(50) NOT NULL DEFAULT '' COMMENT '邮箱',
  `adcode` int(11) NOT NULL DEFAULT '0' COMMENT '行政区域编码',
  `position` varchar(255) NOT NULL DEFAULT '0,0' COMMENT '坐标点',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2072 DEFAULT CHARSET=utf8 COMMENT='客户工厂表';
CREATE TABLE `uct_waste_customer_gathering` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `customer_id` int(10) unsigned NOT NULL COMMENT '客户ID',
  `ec_linkid` varchar(50) NOT NULL DEFAULT '' COMMENT 'ec联系人id',
  `index` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '顺序',
  `receiver` varchar(50) DEFAULT NULL COMMENT '收款人',
  `bank_account` varchar(50) DEFAULT NULL COMMENT '银行账号',
  `deposit_bank` varchar(100) DEFAULT NULL COMMENT '开户银行',
  `deposit_address` varchar(255) DEFAULT '' COMMENT '开户地址',
  `type` varchar(10) DEFAULT 'public',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  `status` varchar(30) DEFAULT 'normal' COMMENT '状态 normal正常  hidden隐藏',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1070 DEFAULT CHARSET=utf8 COMMENT='客户收款信息表';
CREATE TABLE `uct_waste_customer_linkman` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `customer_id` int(10) unsigned NOT NULL COMMENT '客户ID',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '姓名',
  `job` varchar(50) NOT NULL DEFAULT '' COMMENT '职务',
  `mobile` char(15) NOT NULL DEFAULT '' COMMENT '联系电话',
  `email` varchar(50) NOT NULL DEFAULT '' COMMENT '邮箱',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=819 DEFAULT CHARSET=utf8 COMMENT='客户联系人表';
CREATE TABLE `uct_waste_customer_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '操作者ID',
  `customer_id` int(10) unsigned NOT NULL COMMENT '客户ID',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '标题',
  `state_value` varchar(50) NOT NULL DEFAULT '' COMMENT '状态值',
  `state_text` varchar(50) NOT NULL DEFAULT '' COMMENT '状态文字',
  `ip` varchar(50) NOT NULL DEFAULT '' COMMENT '操作者IP',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1268 DEFAULT CHARSET=utf8 COMMENT='客户状态记录表';
CREATE TABLE `uct_waste_evaluate` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `customer_id` int(10) unsigned NOT NULL COMMENT '客户ID',
  `incharge` varchar(50) NOT NULL DEFAULT '' COMMENT '客户负责人',
  `mobile` char(15) NOT NULL DEFAULT '' COMMENT '联系电话',
  `salesman_id` int(10) unsigned NOT NULL COMMENT '业务员ID',
  `fillin_date` date DEFAULT NULL COMMENT '填写日期',
  `waste_type` int(10) unsigned DEFAULT NULL COMMENT '废料类型ID',
  `is_mix_stack` enum('1','0') DEFAULT NULL COMMENT '是否混堆:1=是,0=否',
  `mix_stack_detail` varchar(500) DEFAULT NULL COMMENT '混堆情况',
  `impurity` varchar(100) DEFAULT NULL COMMENT '杂质情况',
  `third_test` enum('1','0') DEFAULT NULL COMMENT '第三方检测:1=需要,0=不需要',
  `test_fee` enum('1','0') DEFAULT NULL COMMENT '检测费用:1=承担,0=不承担',
  `stack_area` float unsigned DEFAULT NULL COMMENT '堆放面积(平方)',
  `daily_waste` float unsigned DEFAULT NULL COMMENT '日均排废量(吨/天)',
  `low_monthly_waste` float unsigned DEFAULT NULL COMMENT '淡季月均处理量(吨/月)',
  `high_monthly_waste` float unsigned DEFAULT NULL COMMENT '旺季月均处理量(吨/月)',
  `detail_type` varchar(500) DEFAULT NULL COMMENT '详细种类',
  `physical_state` varchar(100) DEFAULT NULL COMMENT '物理状态',
  `weigh_tool` varchar(100) DEFAULT NULL COMMENT '计量工具',
  `weigh_detail` varchar(500) DEFAULT NULL COMMENT '客户计量方法详情',
  `produce_deal` varchar(255) DEFAULT NULL COMMENT '产生部门处理方式',
  `collect_deal` varchar(255) DEFAULT NULL COMMENT '收集部门处理方式',
  `sell_deal` varchar(255) DEFAULT NULL COMMENT '售出部门处理方式',
  `loading_scene` varchar(100) DEFAULT NULL COMMENT '装卸现场',
  `loading_help` varchar(100) DEFAULT NULL COMMENT '能提供的装卸协助',
  `transport_way` varchar(100) DEFAULT NULL COMMENT '运输方式',
  `danger_item` varchar(100) DEFAULT NULL COMMENT '危险品',
  `operate_risk` varchar(100) DEFAULT NULL COMMENT '操作安全风险',
  `scene_images` varchar(1500) DEFAULT NULL COMMENT '现场图片',
  `secretout_risk` varchar(500) DEFAULT NULL COMMENT '泄密风险点',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='废料评测表';
CREATE TABLE `uct_waste_hazardous_cate` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `creater_id` int(10) DEFAULT NULL COMMENT '创建者id',
  `code` varchar(10) DEFAULT '' COMMENT '危废的code',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '危废的名称',
  `description` varchar(255) DEFAULT '' COMMENT '描述',
  `is_use` tinyint(1) DEFAULT '1' COMMENT '是否使用(1--使用  0--禁用)',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='危废的名称';
CREATE TABLE `uct_waste_message` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `from_user` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送者ID',
  `to_user` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '接收者ID',
  `type` enum('default','purchase','sell','customer','evaluate','report') NOT NULL DEFAULT 'default' COMMENT '类型:default=默认,purchase=采购,sell=销售,customer=客户,evaluate=废料评测,report=评测报告',
  `target_id` int(10) unsigned DEFAULT NULL COMMENT '目标ID',
  `level` enum('info','warning') NOT NULL DEFAULT 'info' COMMENT '等级:info=提醒,warning=警告',
  `content` varchar(500) NOT NULL DEFAULT '' COMMENT '通知内容',
  `is_read` enum('1','0') NOT NULL DEFAULT '0' COMMENT '状态:1=已读,0=未读',
  `readtime` int(10) unsigned DEFAULT NULL COMMENT '阅读时间',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=56947 DEFAULT CHARSET=utf8 COMMENT='废料通知表';
CREATE TABLE `uct_waste_prestock` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `cate_id` int(10) unsigned NOT NULL COMMENT '废料分类ID',
  `prestock_weigh` int(15) unsigned NOT NULL COMMENT '期初库存量',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='期初库存表';
CREATE TABLE `uct_waste_prestock_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '操作人ID',
  `cate_id` int(10) unsigned NOT NULL COMMENT '废料分类ID',
  `regulation` enum('1','0') NOT NULL COMMENT '增减状态(1=增加，0=减少）',
  `reconcilie_weigh` int(10) unsigned NOT NULL COMMENT '调帐重量',
  `ip` varchar(50) NOT NULL COMMENT '操作人IP',
  `create time` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='期初库存修改记录表';
CREATE TABLE `uct_waste_printer` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `type` int(11) DEFAULT '0' COMMENT '打印类型(0 无类型，1 财务打印销售信息)',
  `key_id` int(11) NOT NULL DEFAULT '0' COMMENT '外键 id',
  `key_active` tinyint(1) DEFAULT '1' COMMENT '记录激活状态，1为激活，0 为关闭状态',
  `key_status` tinyint(1) DEFAULT '0' COMMENT '打印记录 ( 0 仅记录 1 仅发送 2 others )',
  `key_img` varchar(255) DEFAULT NULL COMMENT '图片地址',
  `key_others` varchar(255) DEFAULT NULL COMMENT '其他备注',
  `create_time` int(11) DEFAULT NULL COMMENT '请求时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_waste_purchase` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `branch_id` int(10) unsigned NOT NULL COMMENT '分部ID',
  `order_id` varchar(50) NOT NULL COMMENT '单号',
  `customer_id` int(10) unsigned NOT NULL COMMENT '客户ID',
  `seller_id` int(10) unsigned NOT NULL COMMENT '下单人ID',
  `seller_remark` varchar(255) DEFAULT NULL COMMENT '下单人留言',
  `factory_id` int(10) unsigned DEFAULT NULL COMMENT '工厂地址ID',
  `cargo_sort_data` enum('1','0') NOT NULL DEFAULT '0' COMMENT '货品分拣情况:1=已分拣,0=未分拣',
  `cargo_type` varchar(255) DEFAULT NULL COMMENT '货品类型',
  `cargo_count` int(10) unsigned DEFAULT NULL COMMENT '货品总数',
  `cargo_images` varchar(1500) DEFAULT NULL COMMENT '货品堆放情况',
  `cargo_pick_date` datetime DEFAULT NULL COMMENT '提货日期',
  `manager_id` int(10) unsigned DEFAULT NULL COMMENT '业务经理ID',
  `is_move` tinyint(3) unsigned DEFAULT '0' COMMENT '是否移动采购',
  `hand_mouth_data` enum('1','0') DEFAULT '0' COMMENT '是否现买现卖:1=是,0=否',
  `give_frame` enum('1','0') DEFAULT '0' COMMENT '是否送框流程:1=是,0=否',
  `purchase_id` int(10) unsigned DEFAULT NULL COMMENT '关联的采购订单ID',
  `locale_sort_data` enum('1','0') DEFAULT NULL COMMENT '是否现场分拣:1=是,0=否',
  `purchase_incharge` int(10) unsigned DEFAULT NULL COMMENT '采购负责人ID',
  `sell_incharge` int(10) unsigned DEFAULT NULL COMMENT '销售负责人ID',
  `purchase_time` datetime DEFAULT NULL COMMENT '采购时间',
  `floater_ids` varchar(100) DEFAULT NULL COMMENT '临时工IDS',
  `ofld_ids` varchar(100) DEFAULT NULL COMMENT '拉货助理ids',
  `driver_id` int(10) unsigned DEFAULT NULL COMMENT '司机ID',
  `map_trail` text COMMENT '地图轨迹',
  `car_type` int(10) unsigned DEFAULT NULL COMMENT '车辆类型',
  `plate_number` varchar(255) DEFAULT NULL COMMENT '车牌号码',
  `train_number` float(10,2) DEFAULT '1.00' COMMENT '车次',
  `allot_remark` varchar(255) DEFAULT NULL COMMENT '分配留言',
  `apply_materiel_picktime` datetime DEFAULT NULL COMMENT '申请提取辅材时间',
  `apply_materiel_warehouse` int(10) unsigned DEFAULT NULL COMMENT '申请辅材仓库分点',
  `apply_materiel_remark` varchar(255) DEFAULT NULL COMMENT '申请辅材留言',
  `pick_materiel_remark` varchar(255) DEFAULT NULL COMMENT '提取辅材留言',
  `materiel_price` float(10,2) NOT NULL DEFAULT '0.00' COMMENT '辅材费用',
  `cargo_pick_remark` varchar(255) DEFAULT NULL COMMENT '提货留言',
  `cargo_pick_images` varchar(1500) DEFAULT NULL COMMENT '提货图片',
  `cargo_price` float(10,3) DEFAULT NULL COMMENT '货品费用(元)',
  `cargo_weight` float unsigned DEFAULT NULL COMMENT '货品净重(kg)',
  `purchase_expense` float(10,2) DEFAULT NULL COMMENT '采购开支(元)',
  `is_cash_pay` tinyint(1) unsigned DEFAULT NULL COMMENT '是否现付:1=是,0=否',
  `is_sorting` tinyint(1) unsigned DEFAULT '1' COMMENT '是否上分拣线:1=是,0=否',
  `terminal_type` tinyint(1) unsigned DEFAULT '1' COMMENT '1为erp下单  2为客户端下单',
  `gathering_id` int(10) unsigned DEFAULT NULL COMMENT '收款信息ID',
  `is_evaluate_data` enum('1','0') DEFAULT '0' COMMENT '是否已评价:1=是,0=否',
  `sort_point` int(10) unsigned DEFAULT NULL COMMENT '分拣点',
  `storage_price` float(10,2) DEFAULT NULL COMMENT '入库交接费用(元)',
  `connect_weight` float(10,2) DEFAULT '0.00' COMMENT '交接总重',
  `connect_tare` float(10,2) DEFAULT '0.00' COMMENT '交接皮重',
  `storage_remark` varchar(255) DEFAULT NULL COMMENT '入库留言',
  `connect_remark` varchar(255) DEFAULT NULL COMMENT '确认交接留言',
  `return_fee` float(10,2) DEFAULT NULL COMMENT '报销费用(元)',
  `sort_man` varchar(50) DEFAULT NULL COMMENT '分拣人员',
  `sort_remark` varchar(255) DEFAULT NULL COMMENT '分拣留言',
  `sort_expense` float(10,2) DEFAULT NULL COMMENT '分拣费用(元)',
  `cargo_commission` decimal(5,2) DEFAULT '0.00' COMMENT '货品提成单价',
  `storage_weight` float unsigned DEFAULT NULL COMMENT '入库净重(kg)',
  `sorting_valuable_weight` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '分拣有价废弃物',
  `weigh_valuable_weight` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '过磅有价废弃物',
  `sorting_unvaluable_weight` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '分拣无价废弃物',
  `weigh_unvaluable_weight` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '过磅无价废弃物',
  `sorting_unit_cargo_price` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '有价分拣提成单价',
  `weigh_unit_cargo_price` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '有价过磅提成单价',
  `sorting_unit_labor_price` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '分拣基础人工单价',
  `weigh_unit_labor_price` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '过磅基础人工单价',
  `warehouse_unit_cost` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '仓储成本单价',
  `total_cargo_price` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '有价提成总价',
  `total_labor_price` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '基础人工总价',
  `warehouse_cost` decimal(10,3) unsigned DEFAULT '0.000' COMMENT '仓储成本',
  `storage_cargo_price` float(20,3) DEFAULT NULL COMMENT '入库货品净重',
  `storage_confirm_remark` varchar(255) DEFAULT NULL COMMENT '入库确认留言',
  `tags` varchar(20) DEFAULT '' COMMENT '订单标签 3未匹配 2逾期 1客诉',
  `overdue_time` int(10) DEFAULT NULL COMMENT '逾期时间',
  `state` enum('draft','wait_allot','wait_receive_order','wait_apply_materiel','wait_pick_materiel','wait_signin_materiel','wait_pick_cargo','wait_pay','wait_storage_connect','wait_storage_connect_confirm','wait_storage_sort','wait_storage_confirm','wait_return_fee','wait_confirm_return_fee','finish','cancel','receivable') NOT NULL DEFAULT 'draft' COMMENT '状态:draft=草稿,wait_allot=待分配,wait_receive_order=待接单,wait_apply_materiel=待申请辅材,wait_pick_materiel=待提取辅材,wait_signin_materiel=待签收辅材,wait_pick_cargo=待提货,wait_pay=待付款,wait_storage_connect=待入库交接,wait_storage_connect_confirm=待确认交接,wait_storage_sort=待分拣入库,wait_storage_confirm=待入库确认,wait_confirm_return_fee=待审核订单,finish=交易完成,cancel=订单取消',
  `audit_state` enum('draft','waiting','review','finish') DEFAULT 'draft' COMMENT '入库审核状态： draft = 初始状态， waiting = 待审核状态，review = 审核中， finish = 审核完成 ',
  `bill_state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '水单状态 0=待上传水单  1=待钉钉审核  2=待付款  3=完成 ',
  `prop_ratio` decimal(10,3) unsigned NOT NULL DEFAULT '1.000' COMMENT '对账单的分成比率',
  `print_num` int(11) NOT NULL DEFAULT '0' COMMENT '打印次数',
  `forensics_time` int(10) DEFAULT NULL COMMENT '取证的时间',
  `forensics_info` json DEFAULT NULL COMMENT '取证的内容',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `order_id` (`order_id`) USING BTREE,
  KEY `branch_id` (`branch_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=139474 DEFAULT CHARSET=utf8 COMMENT='采购订单表';
CREATE TABLE `uct_waste_purchase_cargo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` int(10) unsigned NOT NULL COMMENT '采购ID',
  `cate_id` int(10) unsigned DEFAULT NULL COMMENT '废料分类ID',
  `cargo_name` varchar(50) NOT NULL DEFAULT '' COMMENT '品名',
  `total_weight` float unsigned DEFAULT NULL COMMENT '总重(kg)',
  `rough_weight` float unsigned DEFAULT NULL COMMENT '毛重(kg)',
  `net_weight` float unsigned DEFAULT NULL COMMENT '净重(kg)',
  `storage_net_weight` float unsigned DEFAULT NULL COMMENT '入库净重(kg)  交接净重',
  `unit_price` float(10,3) DEFAULT NULL COMMENT '成交报价(元/kg)',
  `total_price` float(10,3) DEFAULT NULL COMMENT '总价(元)',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10341 DEFAULT CHARSET=utf8 COMMENT='采购货品表';
CREATE TABLE `uct_waste_purchase_evaluate` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` int(10) unsigned NOT NULL COMMENT '采购ID',
  `content` varchar(500) NOT NULL DEFAULT '' COMMENT '评价内容',
  `remove_fast_star` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '清运及时评分',
  `remove_level_star` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '清运程度评分',
  `service_attitude_star` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '服务态度评分',
  `linktime` date DEFAULT NULL COMMENT '联系时间',
  `cause` varchar(50) NOT NULL DEFAULT '' COMMENT '原因',
  `cause_resume` text COMMENT '原因简述',
  `conclusion` text COMMENT '沟通结果',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `purchase_id` (`purchase_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2324 DEFAULT CHARSET=utf8 COMMENT='采购评价表';
CREATE TABLE `uct_waste_purchase_expense` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` int(10) unsigned NOT NULL COMMENT '采购ID',
  `type` enum('in','out') DEFAULT NULL COMMENT '类型:in=收入,out=支出',
  `usage` varchar(50) NOT NULL DEFAULT '' COMMENT '用途',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `price` float(10,2) NOT NULL DEFAULT '0.00' COMMENT '价格(元)',
  `receiver` varchar(50) NOT NULL DEFAULT '' COMMENT '领款人',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=560 DEFAULT CHARSET=utf8 COMMENT='采购开支表';
CREATE TABLE `uct_waste_purchase_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '操作者ID',
  `purchase_id` int(10) unsigned NOT NULL COMMENT '采购ID',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '标题',
  `state_value` varchar(50) NOT NULL DEFAULT '' COMMENT '状态值',
  `state_text` varchar(50) NOT NULL DEFAULT '' COMMENT '状态文字',
  `is_timeline_data` enum('1','0') DEFAULT NULL COMMENT '是否在时间轴展示:1=是,0=否',
  `ip` varchar(50) NOT NULL DEFAULT '' COMMENT '操作者IP',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `state_value_2` (`state_value`,`createtime`) USING BTREE,
  KEY `purchase_id` (`purchase_id`,`state_value`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=25475 DEFAULT CHARSET=utf8 COMMENT='采购状态记录表';
CREATE TABLE `uct_waste_purchase_materiel` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` int(10) unsigned NOT NULL COMMENT '采购ID',
  `materiel_id` int(10) unsigned DEFAULT NULL COMMENT '辅材id',
  `type` varchar(50) NOT NULL DEFAULT '' COMMENT '类型',
  `amount` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '数量',
  `inside_price` float(19,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '辅材单价',
  `pick_amount` int(10) unsigned DEFAULT NULL COMMENT '出库数量',
  `storage_amount` int(10) unsigned DEFAULT '0' COMMENT '入库数量',
  `pick_materiel_number` text COMMENT '出库物料编码',
  `storage_materiel_number` text COMMENT '入库物料编码',
  `use_type` tinyint(3) unsigned DEFAULT '0' COMMENT '0:采购,1:分拣入库使用',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `purchase_id` (`purchase_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5894 DEFAULT CHARSET=utf8 COMMENT='采购订单辅材表';
CREATE TABLE `uct_waste_purchase_payment_voucher` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` int(10) NOT NULL COMMENT '采购ID',
  `pay_from` varchar(20) NOT NULL COMMENT 'bank-transfer: 银行转账, wx-native: 微信扫码支付, wx-micropay:微信付款码支付',
  `payment_amount` decimal(6,2) NOT NULL COMMENT '付款金额',
  `payment_voucher` json DEFAULT NULL COMMENT '付款凭证, 银行转账记水单图片上传url, 微信记录支付单号',
  `createtime` int(10) DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
CREATE TABLE `uct_waste_quote_prices_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `create_day` varchar(30) DEFAULT NULL COMMENT '日期',
  `cate_type` varchar(30) DEFAULT '' COMMENT '类型',
  `region` varchar(30) DEFAULT '' COMMENT '地区',
  `cate_name` varchar(100) DEFAULT '' COMMENT '品名',
  `max_price` decimal(50,2) DEFAULT '0.00' COMMENT '最高价',
  `min_price` decimal(50,2) DEFAULT '0.00' COMMENT '最低价',
  `rise_fall` varchar(50) DEFAULT '' COMMENT '涨跌',
  `memo` varchar(255) DEFAULT '' COMMENT '备注',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=666 DEFAULT CHARSET=utf8 COMMENT='报价行情指数表';
CREATE TABLE `uct_waste_report` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `customer_id` int(10) unsigned NOT NULL COMMENT '客户ID',
  `evaluate_id` int(10) unsigned NOT NULL COMMENT '废料评测ID',
  `evaluate_info` text COMMENT '评测详情',
  `stack_problem` varchar(500) DEFAULT NULL COMMENT '堆放问题点描述',
  `stack_standard` varchar(500) DEFAULT NULL COMMENT '最佳堆放标准',
  `stack_standard_images` varchar(1500) DEFAULT NULL COMMENT '堆放标准图片',
  `detail_type` text COMMENT '种类详情',
  `weigh_problem` varchar(1000) DEFAULT NULL COMMENT '计量问题描述',
  `weigh_standard` varchar(1000) DEFAULT NULL COMMENT '计量标准',
  `produce_deal_problem` varchar(1000) DEFAULT NULL COMMENT '产生部门处理方式的问题',
  `collect_deal_problem` varchar(1000) DEFAULT NULL COMMENT '收集部门处理方式的问题',
  `sell_deal_problem` varchar(1000) DEFAULT NULL COMMENT '售出部门处理方式的问题',
  `deal_standard_images` varchar(1500) DEFAULT NULL COMMENT '处理标准图片',
  `secret_promise` varchar(1000) DEFAULT NULL COMMENT '保密承诺',
  `third_test_company` varchar(100) DEFAULT NULL COMMENT '第三方检测公司',
  `test_fee` float(10,2) unsigned DEFAULT NULL COMMENT '检测费用',
  `test_purity` float unsigned DEFAULT NULL COMMENT '检测含量',
  `changed_recovery` float unsigned DEFAULT NULL COMMENT '整改后回收率估算',
  `problem_summary` varchar(1000) DEFAULT NULL COMMENT '问题点综述',
  `improve_way` varchar(1000) DEFAULT NULL COMMENT '改善措施',
  `improved_expect` varchar(1000) DEFAULT NULL COMMENT '改善预计',
  `audit_opinion` varchar(500) NOT NULL DEFAULT '' COMMENT '领导意见',
  `is_latest` enum('1','0') NOT NULL DEFAULT '1' COMMENT '是否最新:1=是,0=否',
  `state` enum('draft','wait_audit','un_audit','audited') NOT NULL DEFAULT 'draft' COMMENT '状态:draft=草稿,wait_audit=待审核,un_audit=审核未通过,audited=审核通过',
  `submittime` int(10) unsigned DEFAULT NULL COMMENT '提交时间',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='评测报告表';
CREATE TABLE `uct_waste_report_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '操作者ID',
  `report_id` int(10) unsigned NOT NULL COMMENT '评测报告ID',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '标题',
  `state_value` varchar(50) NOT NULL DEFAULT '' COMMENT '状态值',
  `state_text` varchar(50) NOT NULL DEFAULT '' COMMENT '状态文字',
  `ip` varchar(50) NOT NULL DEFAULT '' COMMENT '操作者IP',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='评测报告状态记录表';
CREATE TABLE `uct_waste_sell` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `branch_id` int(10) unsigned NOT NULL COMMENT '分部ID',
  `purchase_id` int(10) unsigned DEFAULT NULL COMMENT '采购ID',
  `is_move` tinyint(3) unsigned DEFAULT '0' COMMENT '是否移动',
  `move_purchase_incharge` int(10) unsigned DEFAULT '0' COMMENT '采购负责人',
  `order_id` varchar(50) NOT NULL COMMENT '单号',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT '客户ID',
  `customer_linkman_id` int(10) unsigned DEFAULT NULL COMMENT '客户对接人ID',
  `seller_id` int(10) unsigned NOT NULL COMMENT '下单人ID',
  `seller_remark` varchar(255) DEFAULT NULL COMMENT '下单人留言',
  `warehouse_id` int(10) unsigned DEFAULT NULL COMMENT '出货仓库ID',
  `cargo_pick_time` datetime DEFAULT NULL COMMENT '提货时间',
  `car_number` varchar(50) DEFAULT NULL COMMENT '车牌号',
  `car_weight` float unsigned DEFAULT NULL COMMENT '车辆皮重(吨)',
  `cargo_price` float(10,3) DEFAULT NULL COMMENT '货品费用(元)',
  `cargo_weight` float(11,3) DEFAULT NULL COMMENT '货品重量(kg)',
  `materiel_price` float(10,2) DEFAULT NULL COMMENT '辅材费用(元)',
  `other_price` float(10,2) DEFAULT NULL COMMENT '其他费用(元)',
  `cargo_out_remark` varchar(255) DEFAULT NULL COMMENT '出货留言',
  `pay_way_id` int(10) unsigned DEFAULT NULL COMMENT '打款方式ID',
  `customer_evaluate_data` enum('1','0') DEFAULT NULL COMMENT '客户是否已评价:1=是,0=否',
  `seller_evaluate_data` enum('1','0') DEFAULT NULL COMMENT '销售是否已评价:1=是,0=否',
  `state` enum('wait_commit_order','draft','wait_weigh','wait_confirm_order','wait_pay','wait_confirm_gather','finish','cancel') NOT NULL DEFAULT 'draft' COMMENT '状态:wait_commit_order=待提交订单,draft=草稿,wait_weigh=待称重,wait_confirm_order=待确认订单,wait_pay=待付款,wait_confirm_gather=待确认收款,finish=交易完成,cancel订单取消',
  `bill_state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '水单状态 0=待上传水单  1=待付款  3=完成',
  `fzt_state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '废纸通关联状态 0未管理 1关联',
  `print_num` int(11) NOT NULL DEFAULT '0' COMMENT '打印次数',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `order_id` (`order_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=28624 DEFAULT CHARSET=utf8 COMMENT='销售订单表';
CREATE TABLE `uct_waste_sell_cargo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `sell_id` int(10) unsigned NOT NULL COMMENT '销售ID',
  `cate_id` int(10) unsigned DEFAULT NULL COMMENT '废品分类ID',
  `plan_sell_weight` float unsigned DEFAULT NULL COMMENT '预售出货重量(kg)',
  `total_weight` float unsigned DEFAULT NULL COMMENT '出货总重(kg)',
  `rough_weight` float unsigned DEFAULT NULL COMMENT '出货毛重(kg)',
  `net_weight` float unsigned DEFAULT NULL COMMENT '出货净重(kg)',
  `unit_price` float(10,3) DEFAULT NULL COMMENT '单价(元/kg)',
  `level` varchar(50) DEFAULT 'standard' COMMENT '等级',
  `images` varchar(500) DEFAULT '' COMMENT '图片列表',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1706 DEFAULT CHARSET=utf8 COMMENT='销售货品表';
CREATE TABLE `uct_waste_sell_customer_evaluate` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `sell_id` int(10) unsigned NOT NULL COMMENT '销售ID',
  `content` varchar(500) NOT NULL DEFAULT '' COMMENT '评价内容',
  `remove_fast_star` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '清运及时评分',
  `remove_level_star` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '清运程度评分',
  `service_attitude_star` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '服务态度评分',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='销售订单客户评价表';
CREATE TABLE `uct_waste_sell_evidence_voucher` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '付款凭证ID',
  `sell_id` int(11) DEFAULT NULL COMMENT '销售号ID',
  `img_url` json DEFAULT NULL COMMENT '付款凭证图片URL',
  `active` tinyint(2) DEFAULT '1' COMMENT '有效标志',
  `print_flag` tinyint(2) DEFAULT '0' COMMENT '打印标志',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间戳',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间戳',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `sell_id` (`sell_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=266 DEFAULT CHARSET=utf8 COMMENT='销售付款凭证记录表';
CREATE TABLE `uct_waste_sell_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '操作者ID',
  `sell_id` int(10) unsigned NOT NULL COMMENT '销售ID',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '标题',
  `state_value` varchar(50) NOT NULL DEFAULT '' COMMENT '状态值',
  `state_text` varchar(50) NOT NULL DEFAULT '' COMMENT '状态文字',
  `is_timeline_data` enum('1','0') DEFAULT NULL COMMENT '是否在时间轴展示:1=是,0=否',
  `ip` varchar(50) NOT NULL DEFAULT '' COMMENT '操作者IP',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6051 DEFAULT CHARSET=utf8 COMMENT='销售状态记录表';
CREATE TABLE `uct_waste_sell_materiel` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `sell_id` int(10) unsigned NOT NULL COMMENT '销售ID',
  `materiel_id` int(10) unsigned DEFAULT NULL COMMENT '辅材id',
  `type` varchar(50) NOT NULL DEFAULT '' COMMENT '类型',
  `pick_amount` int(10) unsigned DEFAULT NULL COMMENT '出库数量',
  `unit_price` float(10,2) DEFAULT NULL COMMENT '实际外部销售单价(元/kg)',
  `outside_price` float(10,2) DEFAULT '0.00' COMMENT '外部销售单价',
  `materiel_number` text COMMENT '物料编码',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=470 DEFAULT CHARSET=utf8 COMMENT='销售订单辅材表';
CREATE TABLE `uct_waste_sell_other_price` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `sell_id` int(10) unsigned NOT NULL COMMENT '销售ID',
  `type` enum('in','out','inout') DEFAULT NULL COMMENT '类型:in=收入,out=支出,inout下游支出',
  `usage` varchar(50) NOT NULL DEFAULT '' COMMENT '用途',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `price` float(10,2) NOT NULL DEFAULT '0.00' COMMENT '价格(元)',
  `receiver` varchar(50) NOT NULL DEFAULT '' COMMENT '领款人',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1049 DEFAULT CHARSET=utf8 COMMENT='销售订单其他费用表';
CREATE TABLE `uct_waste_sell_seller_evaluate` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `sell_id` int(10) unsigned NOT NULL COMMENT '销售ID',
  `content` varchar(500) NOT NULL DEFAULT '' COMMENT '评价内容',
  `remove_fast_star` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '清运及时评分',
  `remove_level_star` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '清运程度评分',
  `service_attitude_star` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '服务态度评分',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='销售订单销售评价表';
CREATE TABLE `uct_waste_settings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `group` varchar(50) DEFAULT NULL COMMENT '分组',
  `setting_key` int(10) unsigned DEFAULT NULL COMMENT '配置键',
  `setting_value` varchar(50) NOT NULL DEFAULT '' COMMENT '配置值',
  `image` varchar(100) DEFAULT NULL COMMENT '图片',
  `remark` varchar(100) DEFAULT NULL COMMENT '备注',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `state` enum('1','0') NOT NULL DEFAULT '1' COMMENT '状态:1=启用,0=禁用',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `group` (`group`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=341 DEFAULT CHARSET=utf8 COMMENT='废料配置表';
CREATE TABLE `uct_waste_settings_bak` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `group` varchar(50) DEFAULT NULL COMMENT '分组',
  `setting_key` int(10) unsigned DEFAULT NULL COMMENT '配置键',
  `setting_value` varchar(50) NOT NULL DEFAULT '' COMMENT '配置值',
  `image` varchar(100) DEFAULT NULL COMMENT '图片',
  `remark` varchar(100) DEFAULT NULL COMMENT '备注',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `state` enum('1','0') NOT NULL DEFAULT '1' COMMENT '状态:1=启用,0=禁用',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=218 DEFAULT CHARSET=utf8 COMMENT='废料配置表';
CREATE TABLE `uct_waste_storage` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `branch_id` int(10) unsigned NOT NULL COMMENT '分部ID',
  `cate_id` int(10) unsigned NOT NULL COMMENT '废料分类ID',
  `storage_weight` float NOT NULL DEFAULT '0' COMMENT '库存总重(kg)',
  `purchase_price` float(10,2) NOT NULL DEFAULT '0.00' COMMENT '回收均价(元)',
  `recent_sell_weight` float unsigned DEFAULT NULL COMMENT '最近出货量(kg)',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=442 DEFAULT CHARSET=utf8 COMMENT='库存信息表';
CREATE TABLE `uct_waste_storage_audit` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ware_id` int(11) DEFAULT NULL COMMENT '仓库ID',
  `branch_id` int(11) DEFAULT NULL COMMENT '分部ID',
  `FInterID` int(11) DEFAULT NULL COMMENT '订单内码ID',
  `order_id` varchar(20) NOT NULL COMMENT '订单号',
  `cate_id` int(11) DEFAULT NULL COMMENT '品类ID',
  `issue` varchar(255) DEFAULT NULL COMMENT '异常问题',
  `related` varchar(100) DEFAULT NULL COMMENT '相关的项目',
  `state` enum('start','canceled','pending','resolved') NOT NULL DEFAULT 'start' COMMENT '修正状态：  ''start'' -- 开始状态，''canceled'' -- 取消， ''pending'' -- 待处理，''resolved'' -- 已解决',
  `create_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updata_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8 COMMENT='数据员进销存审批物料详情 （入库数据差异的审批）  详情表';
CREATE TABLE `uct_waste_storage_expense` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` int(10) unsigned NOT NULL COMMENT '采购ID',
  `type` enum('in','out') DEFAULT NULL COMMENT '类型:in=收入,out=支出',
  `usage` varchar(50) NOT NULL DEFAULT '' COMMENT '用途',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `price` float(10,2) NOT NULL DEFAULT '0.00' COMMENT '价格(元)',
  `receiver` varchar(50) NOT NULL DEFAULT '' COMMENT '领款人',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=164 DEFAULT CHARSET=utf8 COMMENT='入库费用表';
CREATE TABLE `uct_waste_storage_return_fee` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` int(10) unsigned NOT NULL COMMENT '采购ID',
  `type` enum('in','out') DEFAULT NULL COMMENT '类型:in=收入,out=支出',
  `usage` varchar(50) NOT NULL DEFAULT '' COMMENT '用途',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `price` float(10,2) NOT NULL DEFAULT '0.00' COMMENT '价格(元)',
  `receiver` varchar(50) NOT NULL DEFAULT '' COMMENT '领款人',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2709 DEFAULT CHARSET=utf8 COMMENT='入库报销表';
CREATE TABLE `uct_waste_storage_sort` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` int(10) unsigned NOT NULL COMMENT '采购ID',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '货品分拣备注',
  `cargo_sort` int(10) unsigned DEFAULT NULL COMMENT '品类id',
  `materiel_number` varchar(50) NOT NULL DEFAULT '' COMMENT '物料编码',
  `total_weight` float unsigned DEFAULT NULL COMMENT '总重(kg)',
  `rough_weight` float unsigned DEFAULT NULL COMMENT '毛重(kg)',
  `net_weight` float unsigned DEFAULT NULL COMMENT '入库净重(kg)',
  `presell_price` float(10,2) DEFAULT NULL COMMENT '预提销售单价(元/kg)',
  `disposal_way` varchar(20) DEFAULT 'sorting' COMMENT '处理方式: [sorting  分拣 / weighing  过磅]',
  `value_type` varchar(20) DEFAULT 'valuable' COMMENT '价值类型  valuable有价  unvaluable 无价',
  `sort_time` int(10) unsigned DEFAULT NULL COMMENT '分拣时间',
  `createtime` int(10) DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=12567 DEFAULT CHARSET=utf8 COMMENT='分拣入库表';
CREATE TABLE `uct_waste_storage_sort_expense` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` int(10) unsigned NOT NULL COMMENT '采购ID',
  `type` enum('in','out') DEFAULT NULL COMMENT '类型:in=收入,out=支出',
  `usage` varchar(50) NOT NULL DEFAULT '' COMMENT '用途',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `price` float(10,2) NOT NULL DEFAULT '0.00' COMMENT '价格(元)',
  `receiver` varchar(50) NOT NULL DEFAULT '' COMMENT '领款人',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2801 DEFAULT CHARSET=utf8 COMMENT='分拣费用表';
CREATE TABLE `uct_waste_storage_sort_out_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` int(10) unsigned NOT NULL COMMENT '采购ID',
  `usage` varchar(50) NOT NULL DEFAULT '' COMMENT '用途',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `weight` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '价格(元)',
  `receiver` varchar(50) NOT NULL DEFAULT '' COMMENT '领款人',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='分拣费用表';
CREATE TABLE `uct_waste_warehouse` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) unsigned DEFAULT NULL COMMENT '负责人ID',
  `ids` varchar(50) DEFAULT '' COMMENT '负责人id列表',
  `parent_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '仓库ID',
  `branch_id` int(10) unsigned NOT NULL COMMENT '分部ID',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '名称',
  `province` varchar(50) NOT NULL DEFAULT '' COMMENT '省份',
  `capacity` decimal(10,2) DEFAULT NULL COMMENT '仓库容量',
  `city` varchar(50) NOT NULL DEFAULT '' COMMENT '城市',
  `area` varchar(50) NOT NULL DEFAULT '' COMMENT '区域',
  `detail_address` varchar(255) NOT NULL DEFAULT '' COMMENT '详细地址',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  `state` enum('1','0') NOT NULL DEFAULT '1' COMMENT '状态:1=启用,0=禁用',
  `createtime` int(10) unsigned DEFAULT NULL COMMENT '创建时间',
  `updatetime` int(10) unsigned DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `uct_waste_warehouse_idx_001` (`parent_id`) USING BTREE,
  KEY `uct_waste_warehouse_idx_002` (`branch_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8 COMMENT='绿环仓库和分拣点表';
CREATE TABLE `uct_wechat_applet` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `admin_id` int(10) NOT NULL COMMENT '管理员ID',
  `appletid` varchar(50) NOT NULL COMMENT '微应用标识',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '应用名称',
  `typedata` enum('serv_account','miniapp','sub_account') NOT NULL DEFAULT 'serv_account' COMMENT '应用类型:serv_account=服务号,miniapp=小程序,sub_account=订阅号',
  `token` varchar(100) NOT NULL DEFAULT '' COMMENT 'Token',
  `appid` varchar(255) NOT NULL DEFAULT '' COMMENT 'AppID',
  `appsecret` varchar(255) DEFAULT NULL COMMENT 'AppSecret',
  `aeskey` varchar(255) DEFAULT NULL COMMENT 'EncodingAESKey',
  `mchid` varchar(50) DEFAULT NULL COMMENT '商户号',
  `mchkey` varchar(50) DEFAULT NULL COMMENT '商户支付密钥',
  `notify_url` varchar(255) DEFAULT NULL COMMENT '微信支付异步通知',
  `principal` varchar(100) DEFAULT NULL COMMENT '主体名称',
  `original` varchar(50) DEFAULT NULL COMMENT '原始ID',
  `wechat` varchar(50) DEFAULT NULL COMMENT '微信号',
  `headface_image` varchar(255) DEFAULT NULL COMMENT '头像',
  `qrcode_image` varchar(255) DEFAULT NULL COMMENT '二维码图片',
  `signature` text COMMENT '账号介绍',
  `city` varchar(50) DEFAULT NULL COMMENT '省市',
  `state` enum('enable','disable','unaudit') NOT NULL DEFAULT 'enable' COMMENT '状态:enable=启用,disable=禁用,unaudit=未审核',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `deletetime` int(10) unsigned DEFAULT NULL COMMENT '删除时间',
  `weigh` int(10) NOT NULL DEFAULT '0' COMMENT '权重',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COMMENT='微应用表';
CREATE TABLE `uct_wechat_autoreply` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `appletid` varchar(50) NOT NULL COMMENT '所属应用标识',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '标题',
  `text` varchar(100) NOT NULL DEFAULT '' COMMENT '触发文本',
  `eventkey` varchar(50) NOT NULL DEFAULT '' COMMENT '响应事件',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '添加时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `status` varchar(30) NOT NULL DEFAULT '' COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='微信自动回复表';
CREATE TABLE `uct_wechat_config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `appletid` varchar(50) NOT NULL COMMENT '所属应用标识',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '配置名称',
  `title` varchar(50) NOT NULL DEFAULT '' COMMENT '配置标题',
  `value` text NOT NULL COMMENT '配置值',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COMMENT='微信配置表';
CREATE TABLE `uct_wechat_context` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `openid` varchar(64) NOT NULL DEFAULT '',
  `type` varchar(30) NOT NULL DEFAULT '' COMMENT '类型',
  `eventkey` varchar(64) NOT NULL DEFAULT '',
  `command` varchar(64) NOT NULL DEFAULT '',
  `message` varchar(255) NOT NULL DEFAULT '' COMMENT '内容',
  `refreshtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最后刷新时间',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `openid` (`openid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='微信上下文表';
CREATE TABLE `uct_wechat_response` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `appletid` varchar(50) NOT NULL COMMENT '所属应用标识',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '资源名',
  `eventkey` varchar(128) NOT NULL DEFAULT '' COMMENT '事件',
  `type` enum('text','image','news','voice','video','music','link','app') NOT NULL DEFAULT 'text' COMMENT '类型',
  `content` text NOT NULL COMMENT '内容',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `createtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
  `updatetime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  `status` varchar(30) NOT NULL DEFAULT '' COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `event` (`eventkey`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COMMENT='微信资源表';
CREATE TABLE `yunwei_record_table` (
  `create_time` varchar(24) DEFAULT NULL COMMENT '发生时间',
  `address` enum('总部','深圳低废运营部','东莞凤岗运营部','深圳光明运营部','苏州昆山仓储中心','深圳中央仓储中心','东莞大岭山仓储中心','苏州昆山运营部','成都崇州分部','北京大兴运营组','深圳龙华运营部','深圳沙井运营部','江西绿蚁','江西樟树','其他分部') DEFAULT NULL COMMENT '地点，只能选（总部、深圳分部、东莞分部、珠海分部、苏州分部、其他分部）',
  `feedback_person` varchar(30) NOT NULL COMMENT '反馈人',
  `problem_good` varchar(50) DEFAULT NULL COMMENT '故障物，填软硬件名称',
  `soft_hardware` enum('软件','硬件') DEFAULT NULL COMMENT '软硬件类型，只能选(软件、硬件、其他)',
  `problem_explain` varchar(255) NOT NULL COMMENT '问题简述',
  `handled_person` varchar(30) NOT NULL COMMENT '处理人',
  `assist_person` varchar(30) DEFAULT '' COMMENT '协助人',
  `methods_explain` varchar(255) NOT NULL COMMENT '解决方法',
  `handled_progress` enum('处理中','独立完成','协助完成') DEFAULT NULL COMMENT '处理进度，只能选(处理中、独立完成、协助完成)',
  `finish_time` varchar(24) DEFAULT NULL COMMENT '结束时间',
  `record_person` varchar(30) DEFAULT '' COMMENT '记录人',
  `remarks` varchar(255) DEFAULT '' COMMENT '备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
