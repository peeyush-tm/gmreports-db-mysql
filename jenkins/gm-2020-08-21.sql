/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


USE `gm_reports`;


ALTER TABLE plan ADD COLUMN plan_name VARCHAR(256);

-- Dumping structure for procedure gm_reports.gm_mobile_network_registration_failure_daily_report
DROP PROCEDURE IF EXISTS `gm_mobile_network_registration_failure_daily_report`;
DELIMITER //
CREATE PROCEDURE `gm_mobile_network_registration_failure_daily_report`(
  IN `in_start_date` INT,
  IN `in_end_date` INT,
  IN `in_account_id` INT
)
BEGIN

  SELECT 
  report_metadata.IMSI AS IMSI,
  report_metadata.ICCID AS ICCID,
  network_failure.create_date,
  network_failure.VALUE AS `Network Error TYPE`,
  network_failure.service AS `Error Source (host)`,
  network_registration_failure_code.code AS `Error Code`
   FROM network_registration_failure_data network_failure
  INNER JOIN report_metadata ON report_metadata.IMSI=network_failure.imsi
  LEFT JOIN network_registration_failure_code ON network_registration_failure_code.value=network_failure.VALUE
  WHERE (network_failure.create_date BETWEEN in_start_date AND in_end_date)
  AND report_metadata.MNO_ACCOUNTID=in_account_id;



END//
DELIMITER ;

-- Dumping structure for procedure gm_reports.gm_retail_revenue_monthly
DROP PROCEDURE IF EXISTS `gm_retail_revenue_monthly`;
DELIMITER //
CREATE PROCEDURE `gm_retail_revenue_monthly`(
  IN `in_start_date` VARCHAR(50),
  IN `in_end_date` VARCHAR(50),
  IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_retail_revenue_monthly'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_retail_revenue_monthly
  -- Author: Parul Shrivastava
  -- Date: feb 12, 2020
  -- Description: Procedure is returned  the prepared data from the table 
  
  -- Input paramter: in_start_date,in_end_date
  -- Output : procedure is used to return the total usage on the basis of the
  --          imsi and FLOW id 

  -- **********************************************************************


  -- Declaration of the variables 
  DECLARE start_date varchar(50);
  DECLARE end_date varchar(50);
  
  -- consersion of date to datetime
   SET start_date:= CAST(in_start_date AS DATETIME);
   SET end_date:= CAST(in_end_date AS DATETIME);
  
  

  -- Preparing the query for fetching the data for the retail_revenue report 
  SELECT 
  -- report_metadata.IMSI AS 'IMSI',
  report_metadata.MSISDN AS 'MSISDN',
  report_metadata.ICCID AS 'ICCID',
  -- report_metadata.ACCOUNT_NAME AS 'SUPPLIER ACCOUNT ID',
  gm_country_code_mapping.country_Code AS 'SUPPLIER ACCOUNT ID' ,
  -- concat(start_date ,' - ',end_date) AS 'BILLING CYCLE DATE',
  '5' AS 'BILLING CYCLE DATE',
  retail_revenue_share.START_DATE AS 'START DATE',
  retail_revenue_share.DATA_USED AS 'DATA USED',
  retail_revenue_share.CREDIT_AMOUNT AS 'CREDIT AMOUNT',
  -- retail_revenue_share.PACKAGE_CODE AS 'PACKAGE CODE',
  -- plan.gm_plan_id AS 'PACKAGE CODE',
    plan.plan_name AS 'PACKAGE NAME',
  retail_revenue_share.ORDER_ID AS 'ORDER ID',
  retail_revenue_share.UUID_IMSI AS 'UUID IMSI',
  report_metadata.IMSI AS 'IMSI'
  FROM retail_revenue_share 
  INNER JOIN report_metadata
  on report_metadata.IMSI = retail_revenue_share.IMSI
  INNER JOIN plan ON plan.bss_plan_id=retail_revenue_share.PACKAGE_CODE
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE report_metadata.MNO_ACCOUNTID=in_account_id and (date(START_DATE) BETWEEN  start_date AND end_date)
  GROUP BY date(START_DATE);

  


END//
DELIMITER ;

-- Dumping structure for table gm_reports.network_registration_failure_code
DROP TABLE IF EXISTS `network_registration_failure_code`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_code` (
  `id` int(11) DEFAULT NULL,
  `node` varchar(50) DEFAULT NULL,
  `kpi_name` varchar(50) DEFAULT NULL,
  `code` varchar(50) DEFAULT NULL,
  `value` varchar(50) DEFAULT NULL,
  `createdat` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table which store network registration failure for level 1.';


-- Dumping structure for table gm_reports.network_registration_failure_data
DROP TABLE IF EXISTS `network_registration_failure_data`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `imsi` varchar(250) DEFAULT NULL,
  `service` varchar(250) DEFAULT NULL,
  `data_source` varchar(250) DEFAULT NULL,
  `VALUE` varchar(250) DEFAULT NULL,
  `create_date` bigint(20) DEFAULT NULL,
  `report_level` varchar(250) DEFAULT 'Level_4',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Dumping structure for table gm_reports.network_registration_failure_level_1
DROP TABLE IF EXISTS `network_registration_failure_level_1`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_level_1` (
  `id` int(11) DEFAULT NULL,
  `level_name` varchar(50) DEFAULT NULL,
  `level_alias` varchar(50) DEFAULT NULL,
  `createdat` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table which store network registration failure for level 1.';


-- Dumping structure for table gm_reports.network_registration_failure_level_2
DROP TABLE IF EXISTS `network_registration_failure_level_2`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_level_2` (
  `id` int(11) DEFAULT NULL,
  `level_name` varchar(50) DEFAULT NULL,
  `level_alias` varchar(50) DEFAULT NULL,
  `createdat` datetime DEFAULT NULL,
  `level_one_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table which store network registration failure for level 1.';


-- Dumping structure for table gm_reports.network_registration_failure_level_3
DROP TABLE IF EXISTS `network_registration_failure_level_3`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_level_3` (
  `id` int(11) DEFAULT NULL,
  `level_name` varchar(50) DEFAULT NULL,
  `level_alias` varchar(50) DEFAULT NULL,
  `createdat` datetime DEFAULT NULL,
  `level_two_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table which store network registration failure for level 1.';


-- Dumping structure for table gm_reports.network_registration_failure_level_4
DROP TABLE IF EXISTS `network_registration_failure_level_4`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_level_4` (
  `id` int(11) DEFAULT NULL,
  `level_name` varchar(50) DEFAULT NULL,
  `level_alias` varchar(50) DEFAULT NULL,
  `createdat` datetime DEFAULT NULL,
  `level_three_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table which store network registration failure for level 1.';


-- Dumping structure for table gm_reports.retail_revenue_share
DROP TABLE IF EXISTS `retail_revenue_share`;
CREATE TABLE IF NOT EXISTS `retail_revenue_share` (
  `ID` bigint(50) NOT NULL AUTO_INCREMENT,
  `START_DATE` varchar(50) DEFAULT NULL,
  `DATA_USED` varchar(50) DEFAULT NULL,
  `CREDIT_AMOUNT` varchar(50) DEFAULT NULL,
  `PACKAGE_CODE` varchar(50) DEFAULT NULL,
  `ORDER_ID` varchar(50) DEFAULT NULL,
  `UUID_IMSI` varchar(50) DEFAULT NULL,
  `IMSI` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='reatails revenue table store the data from the BSS API''s';


-- Dumping structure for view gm_reports.vw_network_registration_failure_level
DROP VIEW IF EXISTS `vw_network_registration_failure_level`;
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vw_network_registration_failure_level` (
  `level_1` VARCHAR(50) NULL COLLATE 'utf8_general_ci',
  `level_alias_1` VARCHAR(50) NULL COLLATE 'utf8_general_ci',
  `level_2` VARCHAR(50) NULL COLLATE 'utf8_general_ci',
  `level_alias_2` VARCHAR(50) NULL COLLATE 'utf8_general_ci',
  `level_3` VARCHAR(50) NULL COLLATE 'utf8_general_ci',
  `level_alias_3` VARCHAR(50) NULL COLLATE 'utf8_general_ci',
  `level_4` VARCHAR(50) NULL COLLATE 'utf8_general_ci',
  `level_alias_4` VARCHAR(50) NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;


INSERT INTO `report_data_details` (`ID`, `DATA_NODE`, `REPORT_NODE`, `DATA_PROCESSING_DATE`, `IS_PROCESSED`) VALUES ('9', 'retail_revenue_share', 'retail_revenue_share', '2020-05-28 06:35:56', '1');
INSERT INTO `report_data_details` (`ID`, `DATA_NODE`, `REPORT_NODE`, `DATA_PROCESSING_DATE`, `IS_PROCESSED`) VALUES ('11', 'registration_failure', 'network', '2020-07-14 09:57:10', '1');

INSERT INTO `report_generation_details` (`id`, `REPORT_ID`, `START_DATE`, `END_DATE`, `LAST_EXECUTION_TIME`, `REPORT_FILE_PATH`) VALUES ('7', '7', '2019-06-29 00:00:00', '2019-10-31 00:00:00', '2020-08-20', 'E:\\palak_project\\GMReports_Client\\/reports_test\\Gcontrol_20200820_RetailRevShare_2_1597925359121.csv');
INSERT INTO `report_generation_details` (`id`, `REPORT_ID`, `START_DATE`, `END_DATE`, `LAST_EXECUTION_TIME`, `REPORT_FILE_PATH`) VALUES ('8', '8', '2019-06-29 00:00:00', '2019-10-31 00:00:00', '2020-07-14', 'E:\\palak_project\\GMReports_Client\\/reports_test\\Gcontrol_20200703_network_registration_failure_2_1593779123736.csv');

INSERT INTO `reports` (`ID`, `NAME`, `INTERVAL_VALUE`, `INTERVAL_UNIT`, `REMARKS`) VALUES ('7', 'gm_retail_revenue_share_report', '1', 'Monthly', 'gm_retail_revenue_share_report');
INSERT INTO `reports` (`ID`, `NAME`, `INTERVAL_VALUE`, `INTERVAL_UNIT`, `REMARKS`) VALUES ('8', 'gm_mobile_network_registration_failure_daily_report', '1', 'Daily', 'gm_mobile_network_registration_failure_daily_report');

INSERT INTO `report_mapping` (`REPORT_ID`, `NODE_ID`) VALUES (8,11);
INSERT INTO `report_mapping` (`REPORT_ID`, `NODE_ID`) VALUES (7,9);

-- Dumping structure for view gm_reports.vw_network_registration_failure_level
DROP VIEW IF EXISTS `vw_network_registration_failure_level`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vw_network_registration_failure_level`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_network_registration_failure_level` AS select `fl1`.`level_name` AS `level_1`,`fl1`.`level_alias` AS `level_alias_1`,`fl2`.`level_name` AS `level_2`,`fl2`.`level_alias` AS `level_alias_2`,`fl3`.`level_name` AS `level_3`,`fl3`.`level_alias` AS `level_alias_3`,`fl4`.`level_name` AS `level_4`,`fl4`.`level_alias` AS `level_alias_4` from (((`network_registration_failure_level_1` `fl1` join `network_registration_failure_level_2` `fl2` on((`fl1`.`id` = `fl2`.`level_one_id`))) join `network_registration_failure_level_3` `fl3` on((`fl2`.`id` = `fl3`.`level_two_id`))) join `network_registration_failure_level_4` `fl4` on((`fl3`.`id` = `fl4`.`level_three_id`)));



/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
