-- ============================================================
-- 民事法律助手 · 全套建表语句
-- 数据库: legal_assistant  字符集: utf8mb4
-- ============================================================
CREATE DATABASE IF NOT EXISTS `legal_assistant` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `legal_assistant`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 用户表
-- ----------------------------
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `phone`           VARCHAR(20)     NOT NULL COMMENT '手机号',
  `password_hash`   VARCHAR(128)    DEFAULT NULL COMMENT '密码哈希',
  `nickname`        VARCHAR(50)     DEFAULT NULL COMMENT '昵称',
  `avatar`          VARCHAR(255)    DEFAULT NULL COMMENT '头像URL',
  `real_name`       VARCHAR(50)     DEFAULT NULL COMMENT '真实姓名',
  `id_card_no`      VARCHAR(64)     DEFAULT NULL COMMENT '身份证号(加密存储)',
  `gender`          TINYINT         NOT NULL DEFAULT 0 COMMENT '性别 0未知 1男 2女',
  `user_type`       TINYINT         NOT NULL DEFAULT 1 COMMENT '用户类型 1个人 2企业',
  `role`            VARCHAR(20)     NOT NULL DEFAULT 'user' COMMENT '角色 user普通用户 admin管理员',
  `status`          TINYINT         NOT NULL DEFAULT 1 COMMENT '状态 0禁用 1正常',
  `last_login_at`   DATETIME        DEFAULT NULL COMMENT '最后登录时间',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`         TINYINT         NOT NULL DEFAULT 0 COMMENT '逻辑删除 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_status` (`status`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ----------------------------
-- 2. 用户案件档案表
-- ----------------------------
DROP TABLE IF EXISTS `t_case_file`;
CREATE TABLE `t_case_file` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '案件档案ID',
  `user_id`         BIGINT UNSIGNED NOT NULL COMMENT '所属用户ID',
  `case_no`         VARCHAR(64)     DEFAULT NULL COMMENT '案件编号',
  `title`           VARCHAR(128)    NOT NULL COMMENT '案件标题',
  `case_type`       VARCHAR(50)     DEFAULT NULL COMMENT '案件类型(借款/合同/劳动等)',
  `summary`         TEXT            COMMENT '案情摘要',
  `amount`          DECIMAL(15,2)   DEFAULT NULL COMMENT '争议金额',
  `plaintiff`       VARCHAR(100)    DEFAULT NULL COMMENT '原告',
  `defendant`       VARCHAR(100)    DEFAULT NULL COMMENT '被告',
  `occur_date`      DATE            DEFAULT NULL COMMENT '事件发生日期',
  `limitation_date` DATE            DEFAULT NULL COMMENT '诉讼时效到期日',
  `evidence_score`  TINYINT         DEFAULT NULL COMMENT '证据完整度评分',
  `readiness_score` TINYINT         DEFAULT NULL COMMENT '案件准备度评分',
  `risk_level`      TINYINT         NOT NULL DEFAULT 0 COMMENT '风险等级 0未知 1低 2中 3高',
  `stage`           TINYINT         NOT NULL DEFAULT 0 COMMENT '阶段 0诊断 1准备 2立案 3审理 4结案',
  `status`          TINYINT         NOT NULL DEFAULT 1 COMMENT '状态 0关闭 1进行中',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`         TINYINT         NOT NULL DEFAULT 0 COMMENT '逻辑删除 0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_case_type` (`case_type`),
  KEY `idx_stage` (`stage`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户案件档案表';

-- ----------------------------
-- 3. 证据文件表
-- ----------------------------
DROP TABLE IF EXISTS `t_evidence_file`;
CREATE TABLE `t_evidence_file` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '证据ID',
  `case_id`         BIGINT UNSIGNED NOT NULL COMMENT '所属案件ID',
  `user_id`         BIGINT UNSIGNED NOT NULL COMMENT '上传用户ID',
  `name`            VARCHAR(128)    NOT NULL COMMENT '证据名称',
  `evidence_type`   VARCHAR(50)     DEFAULT NULL COMMENT '证据类型(借条/转账/聊天等)',
  `file_url`        VARCHAR(255)    DEFAULT NULL COMMENT '文件存储路径',
  `file_format`     VARCHAR(50)     DEFAULT NULL COMMENT '文件格式 image/pdf/audio',
  `file_size`       BIGINT UNSIGNED DEFAULT NULL COMMENT '文件大小(字节)',
  `ocr_content`     TEXT            COMMENT 'OCR识别文本内容',
  `key_info`        JSON            DEFAULT NULL COMMENT 'AI提取关键信息(日期/金额等)',
  `proof_power`     TINYINT         DEFAULT NULL COMMENT '证明力评分',
  `evidence_date`   DATE            DEFAULT NULL COMMENT '证据形成日期',
  `status`          TINYINT         NOT NULL DEFAULT 1 COMMENT '状态 0缺失 1已上传 2待收集',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`         TINYINT         NOT NULL DEFAULT 0 COMMENT '逻辑删除 0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_case_id` (`case_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_evidence_type` (`evidence_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='证据文件表';

-- ----------------------------
-- 4. 法律文书记录表
-- ----------------------------
DROP TABLE IF EXISTS `t_legal_document`;
CREATE TABLE `t_legal_document` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '文书记录ID',
  `case_id`         BIGINT UNSIGNED DEFAULT NULL COMMENT '所属案件ID',
  `user_id`         BIGINT UNSIGNED NOT NULL COMMENT '所属用户ID',
  `template_id`     BIGINT UNSIGNED DEFAULT NULL COMMENT '使用的模板ID',
  `doc_type`        VARCHAR(50)     NOT NULL COMMENT '文书类型(起诉状/答辩状/催款函等)',
  `title`           VARCHAR(128)    NOT NULL COMMENT '文书标题',
  `content`         LONGTEXT        COMMENT '文书正文内容',
  `is_ai_generated` TINYINT         NOT NULL DEFAULT 1 COMMENT '是否AI生成 0否 1是',
  `version`         INT             NOT NULL DEFAULT 1 COMMENT '版本号',
  `export_url`      VARCHAR(255)    DEFAULT NULL COMMENT '导出文件路径',
  `status`          TINYINT         NOT NULL DEFAULT 0 COMMENT '状态 0草稿 1定稿 2已提交',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`         TINYINT         NOT NULL DEFAULT 0 COMMENT '逻辑删除 0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_case_id` (`case_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_doc_type` (`doc_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='法律文书记录表';

-- ----------------------------
-- 5. 法律法条库表
-- ----------------------------
DROP TABLE IF EXISTS `t_law_article`;
CREATE TABLE `t_law_article` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '法条ID',
  `law_name`        VARCHAR(128)    NOT NULL COMMENT '法律名称(如:民法典)',
  `category`        VARCHAR(50)     DEFAULT NULL COMMENT '法律分类(民事/刑事/行政等)',
  `article_no`      VARCHAR(50)     NOT NULL COMMENT '条款编号(如:第667条)',
  `chapter`         VARCHAR(128)    DEFAULT NULL COMMENT '章节',
  `title`           VARCHAR(255)    DEFAULT NULL COMMENT '条款标题',
  `content`         TEXT            NOT NULL COMMENT '条款正文',
  `interpretation`  TEXT            COMMENT '法条解读',
  `keywords`        VARCHAR(255)    DEFAULT NULL COMMENT '关键词(逗号分隔)',
  `effective_date`  DATE            DEFAULT NULL COMMENT '生效日期',
  `status`          TINYINT         NOT NULL DEFAULT 1 COMMENT '状态 0废止 1有效',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_law_article` (`law_name`, `article_no`),
  KEY `idx_law_name` (`law_name`),
  KEY `idx_category` (`category`),
  KEY `idx_article_no` (`article_no`),
  FULLTEXT KEY `ft_content` (`content`, `keywords`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='法律法条库表';

-- ----------------------------
-- 6. 诉讼流程表
-- ----------------------------
DROP TABLE IF EXISTS `t_lawsuit_process`;
CREATE TABLE `t_lawsuit_process` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '流程节点ID',
  `case_id`         BIGINT UNSIGNED NOT NULL COMMENT '所属案件ID',
  `user_id`         BIGINT UNSIGNED NOT NULL COMMENT '所属用户ID',
  `step_no`         INT             NOT NULL COMMENT '步骤序号',
  `step_name`       VARCHAR(100)    NOT NULL COMMENT '步骤名称(整理证据/递交起诉等)',
  `description`     TEXT            COMMENT '步骤说明',
  `status`          TINYINT         NOT NULL DEFAULT 0 COMMENT '状态 0待完成 1进行中 2已完成',
  `plan_date`       DATE            DEFAULT NULL COMMENT '计划完成日期',
  `finish_date`     DATE            DEFAULT NULL COMMENT '实际完成日期',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_case_id` (`case_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='诉讼流程表';

-- ----------------------------
-- 7. 文书模板表
-- ----------------------------
DROP TABLE IF EXISTS `t_document_template`;
CREATE TABLE `t_document_template` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `name`            VARCHAR(128)    NOT NULL COMMENT '模板名称',
  `doc_type`        VARCHAR(50)     NOT NULL COMMENT '文书类型(起诉状/答辩状等)',
  `category`        VARCHAR(50)     DEFAULT NULL COMMENT '适用案件分类',
  `content`         LONGTEXT        NOT NULL COMMENT '模板内容(含占位符)',
  `variables`       JSON            DEFAULT NULL COMMENT '可替换变量定义',
  `usage_count`     INT             NOT NULL DEFAULT 0 COMMENT '使用次数',
  `sort_order`      INT             NOT NULL DEFAULT 0 COMMENT '排序权重',
  `status`          TINYINT         NOT NULL DEFAULT 1 COMMENT '状态 0下架 1启用',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_doc_type` (`doc_type`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文书模板表';

-- ----------------------------
-- 8. 判例表
-- ----------------------------
DROP TABLE IF EXISTS `t_precedent`;
CREATE TABLE `t_precedent` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '判例ID',
  `case_no`         VARCHAR(64)     DEFAULT NULL COMMENT '裁判文书案号',
  `title`           VARCHAR(255)    NOT NULL COMMENT '判例标题',
  `court`           VARCHAR(128)    DEFAULT NULL COMMENT '审理法院',
  `case_type`       VARCHAR(50)     DEFAULT NULL COMMENT '案件类型',
  `trial_level`     VARCHAR(20)     DEFAULT NULL COMMENT '审级(一审/二审/再审)',
  `judge_date`      DATE            DEFAULT NULL COMMENT '裁判日期',
  `cause`           VARCHAR(128)    DEFAULT NULL COMMENT '案由',
  `summary`         TEXT            COMMENT '裁判摘要',
  `full_text`       LONGTEXT        COMMENT '裁判文书全文',
  `judge_result`    TEXT            COMMENT '判决结果',
  `related_laws`    VARCHAR(500)    DEFAULT NULL COMMENT '引用法条',
  `keywords`        VARCHAR(255)    DEFAULT NULL COMMENT '关键词',
  `status`          TINYINT         NOT NULL DEFAULT 1 COMMENT '状态 0隐藏 1公开',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_case_no` (`case_no`),
  KEY `idx_case_type` (`case_type`),
  KEY `idx_cause` (`cause`),
  FULLTEXT KEY `ft_text` (`title`, `summary`, `keywords`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='判例表';

-- ----------------------------
-- 9. 企业体检记录表
-- ----------------------------
DROP TABLE IF EXISTS `t_enterprise_report`;
CREATE TABLE `t_enterprise_report` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '体检记录ID',
  `user_id`         BIGINT UNSIGNED NOT NULL COMMENT '所属用户ID',
  `enterprise_name` VARCHAR(128)    NOT NULL COMMENT '企业名称',
  `credit_code`     VARCHAR(32)     DEFAULT NULL COMMENT '统一社会信用代码',
  `health_score`    TINYINT         DEFAULT NULL COMMENT '法治健康度评分',
  `risk_items`      JSON            DEFAULT NULL COMMENT '风险项明细',
  `contract_count`  INT             NOT NULL DEFAULT 0 COMMENT '审查合同数',
  `report_content`  LONGTEXT        COMMENT '体检报告内容',
  `suggestion`      TEXT            COMMENT 'AI整改建议',
  `report_date`     DATE            DEFAULT NULL COMMENT '体检日期',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`         TINYINT         NOT NULL DEFAULT 0 COMMENT '逻辑删除 0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_credit_code` (`credit_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='企业体检记录表';

-- ----------------------------
-- 10. 律师信息表
-- ----------------------------
DROP TABLE IF EXISTS `t_lawyer`;
CREATE TABLE `t_lawyer` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '律师ID',
  `name`            VARCHAR(50)     NOT NULL COMMENT '律师姓名',
  `avatar`          VARCHAR(255)    DEFAULT NULL COMMENT '头像URL',
  `license_no`      VARCHAR(64)     DEFAULT NULL COMMENT '执业证号',
  `law_firm`        VARCHAR(128)    DEFAULT NULL COMMENT '所属律所',
  `specialties`     VARCHAR(255)    DEFAULT NULL COMMENT '擅长领域(民间借贷/婚姻等)',
  `practice_years`  INT             DEFAULT NULL COMMENT '执业年限',
  `city`            VARCHAR(50)     DEFAULT NULL COMMENT '所在城市',
  `address`         VARCHAR(255)    DEFAULT NULL COMMENT '律所地址',
  `longitude`       DECIMAL(10,7)   DEFAULT NULL COMMENT '经度',
  `latitude`        DECIMAL(10,7)   DEFAULT NULL COMMENT '纬度',
  `phone`           VARCHAR(20)     DEFAULT NULL COMMENT '联系电话',
  `rating`          DECIMAL(2,1)    DEFAULT NULL COMMENT '评分',
  `recommend_index` TINYINT         DEFAULT NULL COMMENT 'AI推荐指数',
  `consult_fee`     DECIMAL(10,2)   DEFAULT NULL COMMENT '咨询费(元/小时)',
  `intro`           TEXT            COMMENT '律师简介',
  `status`          TINYINT         NOT NULL DEFAULT 1 COMMENT '状态 0停用 1正常',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_city` (`city`),
  KEY `idx_specialties` (`specialties`),
  KEY `idx_rating` (`rating`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='律师信息表';

-- ----------------------------
-- 11. AI对话日志表
-- ----------------------------
DROP TABLE IF EXISTS `t_ai_chat_log`;
CREATE TABLE `t_ai_chat_log` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '对话日志ID',
  `user_id`         BIGINT UNSIGNED DEFAULT NULL COMMENT '所属用户ID',
  `case_id`         BIGINT UNSIGNED DEFAULT NULL COMMENT '关联案件ID',
  `session_id`      VARCHAR(64)     NOT NULL COMMENT '会话ID',
  `scene`           VARCHAR(50)     DEFAULT NULL COMMENT '场景(案件诊断/法律体检/模拟法庭等)',
  `role`            VARCHAR(20)     NOT NULL COMMENT '角色 user/assistant/system',
  `content`         LONGTEXT        COMMENT '对话内容',
  `input_type`      VARCHAR(20)     DEFAULT 'text' COMMENT '输入类型 text/image/voice',
  `tokens`          INT             DEFAULT NULL COMMENT '消耗token数',
  `model`           VARCHAR(50)     DEFAULT NULL COMMENT '使用模型',
  `emotion`         VARCHAR(30)     DEFAULT NULL COMMENT '情绪识别结果',
  `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_case_id` (`case_id`),
  KEY `idx_session_id` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI对话日志表';

SET FOREIGN_KEY_CHECKS = 1;
