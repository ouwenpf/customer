-- 创建归档章权限按钮
CREATE TABLE t_arch_seal (
  id bigint(20) NOT NULL COMMENT '主键ID',
  arch_type tinyint(5) DEFAULT NULL COMMENT '类型1=案卷层级，2=文件层级',
  seal_name varchar(100) DEFAULT NULL COMMENT '名称',
  seal_content varchar(1000) DEFAULT NULL COMMENT '构成内容',
  font_size tinyint(2) DEFAULT NULL COMMENT '字体大小',
  font_color varchar(10) DEFAULT NULL COMMENT '字体颜色16进制',
  position tinyint(2) DEFAULT NULL COMMENT '位置1=左上，2=中上，3=右上',
  if_head tinyint(2) DEFAULT NULL COMMENT '是否包含表头',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE t_cate_seal (
  cate_id bigint(20) NOT NULL COMMENT '分类ID',
  seal_id bigint(20) NOT NULL COMMENT '归档章ID',
  PRIMARY KEY (`cate_id`,`seal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='分类与归档章关联表';

-- 所有附件表增加是否加盖归档章标识
ALTER TABLE t_w1_file ADD COLUMN IF_ADD_SEAL TINYINT(2) DEFAULT 0 COMMENT '是否加盖归档章0=未加盖,1=已加盖';
ALTER TABLE t_w1_fileconvert ADD COLUMN IF_ADD_SEAL TINYINT(2) DEFAULT 0 COMMENT '是否加盖归档章0=未加盖,1=已加盖';

-- 增加是否为头像字段
ALTER TABLE t_collect_fld ADD COLUMN if_head_field TINYINT(2) DEFAULT 0 COMMENT '是否为头像字段0=否,1=是';
ALTER TABLE t_templates ADD COLUMN if_vol_head_field TINYINT(2) DEFAULT 0 COMMENT '案卷是否配置头像字段0=否,1=是';
ALTER TABLE t_templates ADD COLUMN if_volin_head_field TINYINT(2) DEFAULT 0 COMMENT '案卷是否配置头像字段0=否,1=是';
ALTER TABLE t_templates ADD COLUMN if_doc_head_field TINYINT(2) DEFAULT 0 COMMENT '案卷是否配置头像字段0=否,1=是';
-- 用户管理增加权限复制 权限按钮

-- 著录界面字段表
ALTER TABLE t_query_fld ADD COLUMN cate_code varchar(50) DEFAULT null COMMENT '分类代码';
ALTER TABLE t_collect_fld ADD COLUMN cate_code VARCHAR(50) DEFAULT NULL COMMENT '分类代码';
ALTER TABLE t_temp_view ADD COLUMN cate_code VARCHAR(50) DEFAULT NULL COMMENT '分类代码';
ALTER TABLE t_arch_eep_fld ADD COLUMN cate_code VARCHAR(50) DEFAULT NULL COMMENT '分类代码';
ALTER TABLE t_search_fld ADD COLUMN cate_code VARCHAR(50) DEFAULT NULL COMMENT '分类代码';

ALTER TABLE t_query_fld ADD COLUMN if_sort_field smallint(1) DEFAULT 0 COMMENT '排序字段0=默认,1=升序,2=降序';

CREATE TABLE `t_query_sort_fld` (
  `id` bigint(20) NOT NULL COMMENT '主键ID',
  `temp_id` bigint(20) DEFAULT NULL COMMENT '模板ID',
  `oth_type` smallint(2) DEFAULT NULL COMMENT '档案类型1=案卷，2=卷内，3=单件',
  `cate_code` varchar(50) DEFAULT NULL COMMENT '分类代码',
  `fld_name` varchar(50) DEFAULT NULL COMMENT '字段名称',
  `sort_type` smallint(2) DEFAULT NULL COMMENT '排序类型1=升序,2=降序',
  `sort_sql` varchar(1000) DEFAULT NULL COMMENT '自定义排序sql语句',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- 20230916
ALTER TABLE b_regist_apply ADD COLUMN default_password VARCHAR(50) DEFAULT null COMMENT '默认密码';

--20231012
CREATE TABLE `sys_data_compile` (
  `id` BIGINT(20) NOT NULL COMMENT '主键ID',
  `contextstr` LONGTEXT COMMENT '内容',
  `title` VARCHAR(255) DEFAULT NULL COMMENT '标题',
  `type` TINYINT(5) DEFAULT NULL COMMENT '类型1=查档指南，2=关于我们，3=政策法规',
  `status` VARCHAR(3) DEFAULT NULL COMMENT '状态 0=已发布 1=草稿 ',
  `release_time` DATETIME DEFAULT NULL COMMENT '发布时间',
  `excute_time` VARCHAR(20) DEFAULT NULL COMMENT '实施时间',
  `create_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME DEFAULT NULL COMMENT '修改时间',
  `create_user` VARCHAR(32) DEFAULT NULL COMMENT '创建人',
  `update_user` VARCHAR(32) DEFAULT NULL COMMENT '修改人',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备用字段',
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='材料编撰';
-- 新建材料编撰权限按钮