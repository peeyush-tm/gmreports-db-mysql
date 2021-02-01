-- --------------------------------------------------------
-- Host:                         10.221.67.55
-- Server version:               5.7.27 - MySQL Community Server (GPL)
-- Server OS:                    Linux
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

use stc_report;

-- Dumping structure for table stc_report.apn_billing_cycle_aggregation
DROP TABLE IF EXISTS `apn_billing_cycle_aggregation`;
CREATE TABLE IF NOT EXISTS `apn_billing_cycle_aggregation` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `APN` varchar(100) DEFAULT NULL,
  `SERVED_IMSI` varchar(100) DEFAULT NULL,
  `FLOW_ID` varchar(100) DEFAULT NULL,
  `DATA_USAGE` varchar(100) DEFAULT NULL,
  `CREATE_DATE` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='apn billing cycle table is used  to  store the data of the aggregated table ';

-- Data exporting was unselected.

-- Dumping structure for event stc_report.apn_details_aggregation
DROP EVENT IF EXISTS `apn_details_aggregation`;
DELIMITER //
CREATE EVENT `apn_details_aggregation` ON SCHEDULE EVERY 1 DAY STARTS '2019-11-26 23:59:59' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'apn_details_aggregation' DO BEGIN

  
  
  
   
  
  
  

  
   CALL `gm_utility_apn_aggregation_monthly`(CURRENT_DATE());

  
  
END//
DELIMITER ;

-- Dumping structure for table stc_report.cdr_data_details
DROP TABLE IF EXISTS `cdr_data_details`;
CREATE TABLE IF NOT EXISTS `cdr_data_details` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `SERVED_IMSI` varchar(20) NOT NULL,
  `RECORD_OPENING_TIME` datetime NOT NULL,
  `DURATION_SEC` int(11) NOT NULL,
  `CAUSE_FOR_CLOSING` int(11) NOT NULL,
  `SERVING_NODE_IPADDR` varchar(200) NOT NULL,
  `RAT_TYPE` int(11) NOT NULL,
  `PGW_ADDRESS` varchar(50) NOT NULL,
  `APN_ID` varchar(128) NOT NULL,
  `SERVED_PDP_ADDRESS` varchar(50) NOT NULL,
  `START_TIME` datetime NOT NULL,
  `STOP_TIME` datetime NOT NULL,
  `DOWNLINK_BYTES` bigint(20) NOT NULL,
  `UPLINK_BYTES` bigint(20) NOT NULL,
  `TOTAL_BYTES` bigint(20) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `SERVED_IMSI` (`SERVED_IMSI`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='This table is used for storing the cdr data records of the IMSI ';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.cdr_data_details_vw
DROP TABLE IF EXISTS `cdr_data_details_vw`;
CREATE TABLE IF NOT EXISTS `cdr_data_details_vw` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `SERVED_IMSI` varchar(255) NOT NULL,
  `SERVED_MSISDN` varchar(255) NOT NULL,
  `RECORD_OPENING_TIME` datetime(6) DEFAULT NULL,
  `DURATION_SEC` int(11) NOT NULL,
  `CAUSE_FOR_CLOSING` int(11) NOT NULL,
  `SERVING_NODE_IPADDR` varchar(200) NOT NULL,
  `RAT_TYPE` int(11) NOT NULL,
  `PGW_ADDRESS` varchar(50) NOT NULL,
  `APN_ID` varchar(128) NOT NULL,
  `SERVED_PDP_ADDRESS` varchar(50) NOT NULL,
  `START_TIME` datetime(6) DEFAULT NULL,
  `STOP_TIME` datetime(6) DEFAULT NULL,
  `DOWNLINK_BYTES` bigint(20) NOT NULL,
  `UPLINK_BYTES` bigint(20) NOT NULL,
  `TOTAL_BYTES` bigint(20) NOT NULL,
  `LOCAL_SEQUENCE_NUMBER` bigint(20) NOT NULL,
  `ULI_MCC` bigint(20) NOT NULL,
  `ULI_MNC` bigint(20) NOT NULL,
  `CHARGING_ID` bigint(20) NOT NULL,
  `SERVICE_DATA_FLOW_ID` bigint(20) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `SERVED_IMSI` (`SERVED_IMSI`),
  KEY `STOP_TIME` (`STOP_TIME`),
  KEY `CHARGING_ID` (`CHARGING_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='This table is used for storing the cdr data records of the IMSI ';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.cdr_data_details_vw_bkp_21dec2020
DROP TABLE IF EXISTS `cdr_data_details_vw_bkp_21dec2020`;
CREATE TABLE IF NOT EXISTS `cdr_data_details_vw_bkp_21dec2020` (
  `ID` int(11) NOT NULL DEFAULT '0',
  `SERVED_IMSI` varchar(255) CHARACTER SET utf8 NOT NULL,
  `SERVED_MSISDN` varchar(255) CHARACTER SET utf8 NOT NULL,
  `RECORD_OPENING_TIME` datetime(6) DEFAULT NULL,
  `DURATION_SEC` int(11) NOT NULL,
  `CAUSE_FOR_CLOSING` int(11) NOT NULL,
  `SERVING_NODE_IPADDR` varchar(200) CHARACTER SET utf8 NOT NULL,
  `RAT_TYPE` int(11) NOT NULL,
  `PGW_ADDRESS` varchar(50) CHARACTER SET utf8 NOT NULL,
  `APN_ID` varchar(128) CHARACTER SET utf8 NOT NULL,
  `SERVED_PDP_ADDRESS` varchar(50) CHARACTER SET utf8 NOT NULL,
  `START_TIME` datetime(6) DEFAULT NULL,
  `STOP_TIME` datetime(6) DEFAULT NULL,
  `DOWNLINK_BYTES` bigint(20) NOT NULL,
  `UPLINK_BYTES` bigint(20) NOT NULL,
  `TOTAL_BYTES` bigint(20) NOT NULL,
  `LOCAL_SEQUENCE_NUMBER` bigint(20) NOT NULL,
  `ULI_MCC` bigint(20) NOT NULL,
  `ULI_MNC` bigint(20) NOT NULL,
  `CHARGING_ID` bigint(20) NOT NULL,
  `SERVICE_DATA_FLOW_ID` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

-- Dumping structure for table stc_report.cdr_data_details_vw_jan6th2021
DROP TABLE IF EXISTS `cdr_data_details_vw_jan6th2021`;
CREATE TABLE IF NOT EXISTS `cdr_data_details_vw_jan6th2021` (
  `ID` int(11) NOT NULL DEFAULT '0',
  `SERVED_IMSI` varchar(255) CHARACTER SET utf8 NOT NULL,
  `SERVED_MSISDN` varchar(255) CHARACTER SET utf8 NOT NULL,
  `RECORD_OPENING_TIME` datetime(6) DEFAULT NULL,
  `DURATION_SEC` int(11) NOT NULL,
  `CAUSE_FOR_CLOSING` int(11) NOT NULL,
  `SERVING_NODE_IPADDR` varchar(200) CHARACTER SET utf8 NOT NULL,
  `RAT_TYPE` int(11) NOT NULL,
  `PGW_ADDRESS` varchar(50) CHARACTER SET utf8 NOT NULL,
  `APN_ID` varchar(128) CHARACTER SET utf8 NOT NULL,
  `SERVED_PDP_ADDRESS` varchar(50) CHARACTER SET utf8 NOT NULL,
  `START_TIME` datetime(6) DEFAULT NULL,
  `STOP_TIME` datetime(6) DEFAULT NULL,
  `DOWNLINK_BYTES` bigint(20) NOT NULL,
  `UPLINK_BYTES` bigint(20) NOT NULL,
  `TOTAL_BYTES` bigint(20) NOT NULL,
  `LOCAL_SEQUENCE_NUMBER` bigint(20) NOT NULL,
  `ULI_MCC` bigint(20) NOT NULL,
  `ULI_MNC` bigint(20) NOT NULL,
  `CHARGING_ID` bigint(20) NOT NULL,
  `SERVICE_DATA_FLOW_ID` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

-- Dumping structure for table stc_report.cdr_sms_details
DROP TABLE IF EXISTS `cdr_sms_details`;
CREATE TABLE IF NOT EXISTS `cdr_sms_details` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `SMS_TYPE` varchar(256) DEFAULT NULL,
  `SOURCE` varchar(256) DEFAULT NULL,
  `DESTINATION` varchar(256) DEFAULT NULL,
  `SENT_TIME` datetime(6) DEFAULT NULL,
  `FINAL_TIME` datetime(6) DEFAULT NULL,
  `SMS_STATUS` varchar(256) DEFAULT NULL,
  `ATTEMPTS` bigint(20) DEFAULT NULL,
  `REASON` varchar(256) DEFAULT NULL,
  `ORIGINATION_GT` varchar(256) DEFAULT NULL,
  `DESTINATION_GT` varchar(256) DEFAULT NULL,
  `SUBSCRIBER_IMSI` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `SOURCE` (`SOURCE`(255)),
  KEY `DESTINATION` (`DESTINATION`(255)),
  KEY `ID` (`ID`),
  KEY `FINAL_TIME` (`FINAL_TIME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='This table is used for storing the sms cdr records of the IMSI ';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.cdr_voice_completed
DROP TABLE IF EXISTS `cdr_voice_completed`;
CREATE TABLE IF NOT EXISTS `cdr_voice_completed` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `CALLID` varchar(50) DEFAULT '0',
  `EVENTSRECD` bigint(20) DEFAULT NULL,
  `IAMRECDAT` datetime(6) DEFAULT NULL,
  `ANMRECDAT` datetime(6) DEFAULT NULL,
  `CALLREFERENCE` varchar(256) DEFAULT NULL,
  `CALLEDNUMBER` varchar(256) DEFAULT NULL,
  `MSRNNAI` bigint(20) DEFAULT NULL,
  `MSRNNPI` bigint(20) DEFAULT NULL,
  `CALLINGNUMBER` varchar(256) DEFAULT NULL,
  `MCC` varchar(256) DEFAULT NULL,
  `MNC` varchar(256) DEFAULT NULL,
  `CAUSEINDCAUSEVALUE` bigint(20) DEFAULT NULL,
  `CELLID` varchar(256) DEFAULT NULL,
  `CALLDURATION` bigint(20) DEFAULT NULL,
  `MOCALL` int(11) DEFAULT NULL,
  `LASTERBCSM` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `ANMRECDAT` (`ANMRECDAT`),
  KEY `CALLEDNUMBER` (`CALLEDNUMBER`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table stc_report.cdr_voice_incompleted
DROP TABLE IF EXISTS `cdr_voice_incompleted`;
CREATE TABLE IF NOT EXISTS `cdr_voice_incompleted` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `CALLID` varchar(50) NOT NULL DEFAULT '0',
  `EVENTSRECD` bigint(20) DEFAULT NULL,
  `IAMRECDAT` datetime(6) DEFAULT NULL,
  `ANMRECDAT` datetime(6) DEFAULT NULL,
  `CALLREFERENCE` varchar(256) DEFAULT NULL,
  `CALLEDNUMBER` varchar(256) DEFAULT NULL,
  `MSRNNAI` bigint(20) DEFAULT NULL,
  `MSRNNPI` bigint(20) DEFAULT NULL,
  `CALLINGNUMBER` varchar(256) DEFAULT NULL,
  `MCC` varchar(256) DEFAULT NULL,
  `MNC` varchar(256) DEFAULT NULL,
  `CAUSEINDCAUSEVALUE` bigint(20) DEFAULT NULL,
  `CELLID` varchar(256) DEFAULT NULL,
  `CALLDURATION` bigint(20) DEFAULT NULL,
  `MOCALL` int(11) DEFAULT NULL,
  `LASTERBCSM` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `ANMRECDAT` (`ANMRECDAT`),
  KEY `CALLEDNUMBER` (`CALLEDNUMBER`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table stc_report.cdr_voice_tadig_codes
DROP TABLE IF EXISTS `cdr_voice_tadig_codes`;
CREATE TABLE IF NOT EXISTS `cdr_voice_tadig_codes` (
  `TC_TADIG_CODE` varchar(256) CHARACTER SET utf8 NOT NULL,
  `TC_NETWORK_ID` bigint(20) NOT NULL,
  `TC_MCC` varchar(256) CHARACTER SET utf8 DEFAULT '0',
  `TC_MNC` varchar(256) CHARACTER SET utf8 DEFAULT '0',
  `TC_REC_CHANGED_AT` datetime DEFAULT NULL,
  `TC_REC_CHANGED_BY` varchar(256) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

-- Dumping structure for table stc_report.cdr_voice_tadig_codes_bkp_28dec
DROP TABLE IF EXISTS `cdr_voice_tadig_codes_bkp_28dec`;
CREATE TABLE IF NOT EXISTS `cdr_voice_tadig_codes_bkp_28dec` (
  `TC_TADIG_CODE` varchar(256) NOT NULL,
  `TC_NETWORK_ID` bigint(20) NOT NULL,
  `TC_MCC` varchar(256) DEFAULT '0',
  `TC_MNC` varchar(256) DEFAULT '0',
  `TC_REC_CHANGED_AT` datetime DEFAULT NULL,
  `TC_REC_CHANGED_BY` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='cdr_voice_tadig_codes';

-- Data exporting was unselected.

-- Dumping structure for procedure stc_report.gm_apn_billing_cycle_report
DROP PROCEDURE IF EXISTS `gm_apn_billing_cycle_report`;
DELIMITER //
CREATE PROCEDURE `gm_apn_billing_cycle_report`(
	IN `in_start_date` VARCHAR(50),
	IN `in_end_date` VARCHAR(50)







)
    COMMENT 'gm_apn_billing_cycle_report'
BEGIN
  
  
  
  
  
  
  
  
  

  

	
	DECLARE start_date varchar(50);
	DECLARE end_date varchar(50);
	
	
   SET start_date:= CAST(in_start_date AS DATEtime);
   SET end_date:= CAST(in_end_date AS DATEtime);
	
	
	SELECT APN ,
		FLOW_ID AS 'Flow ID',
		SUM(DATA_USAGE) AS 'Total usage'
	FROM apn_billing_cycle_aggregation 
	INNER JOIN report_metadata
	on report_metadata.IMSI = apn_billing_cycle_aggregation.SERVED_IMSI
	WHERE CREATE_DATE BETWEEN  start_date AND end_date;



END//
DELIMITER ;

-- Dumping structure for table stc_report.gm_country_code_mapping
DROP TABLE IF EXISTS `gm_country_code_mapping`;
CREATE TABLE IF NOT EXISTS `gm_country_code_mapping` (
  `account` varchar(50) DEFAULT '0',
  `country_Code` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for procedure stc_report.gm_data_report
DROP PROCEDURE IF EXISTS `gm_data_report`;
DELIMITER //
CREATE PROCEDURE `gm_data_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_data_report_new'
BEGIN
 
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);
  
   
   SET start_date:= CAST(in_start_date AS DATEtime);
   
  SET @TEMP_BILLING_CYCLE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - 2020);

  
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  

    
    
  SET @row_number = 0;
  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

  
  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

  
  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
    
  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
  
    
  DROP TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE temp_wholesale_plan_history
  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
      COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
      COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
      COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
  FROM temp_first_wholesale_plan_history 
  LEFT JOIN temp_second_wholesale_plan_history
    ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
      AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI;
            
      
  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

  
  DROP TABLE IF EXISTS temp_cdr_data_return_table;
    CREATE TEMPORARY TABLE temp_cdr_data_return_table
  SELECT 
  report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,

   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
  
  @TEMP_BILLING_CYCLE AS BILLING_CYCLE_DATE,

  case when temp_wholesale_plan_history.IMSI=report_metadata.IMSI then  temp_wholesale_plan_history.plan ELSE report_metadata.WHOLE_SALE_NAME END AS PLAN,
   cdr_data_details_vw.START_TIME AS ORIGINATION_DATE,
   sum(cdr_data_details_vw.UPLINK_BYTES) AS TRANSMIT_BYTE,
   sum(cdr_data_details_vw.DOWNLINK_BYTES) AS RECEIVE_BYTES,
  sum(cdr_data_details_vw.TOTAL_BYTES) AS DATAUSAGE,
  
   cdr_data_details_vw.APN_ID AS APN,
  cdr_data_details_vw.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
  LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK,
  
  cdr_data_details_vw.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
  sum(cdr_data_details_vw.DURATION_SEC) AS SESSION_DURATION,
   
  cdr_data_details_vw.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
    cdr_data_details_vw.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    
   cdr_data_details_vw.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   case when cdr_data_details_vw.RAT_TYPE=1 then '3' when cdr_data_details_vw.RAT_TYPE=6 then '4' when cdr_data_details_vw.RAT_TYPE=2 then '2' else cdr_data_details_vw.RAT_TYPE end  AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details_vw.PGW_ADDRESS AS GGSN_IP_ADDRESS,
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number
  from  ((report_metadata
  INNER JOIN cdr_data_details_vw
  ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_data_details_vw.START_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)))
     WHERE 
      date(cdr_data_details_vw.START_TIME) = date(start_date)
     and report_metadata.ENT_ACCOUNTID=in_account_id
  group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID,cdr_data_details_vw.SERVICE_DATA_FLOW_ID;


  SELECT temp_cdr_data_return_table.*,CASE WHEN ICCID IS NULL 
        OR MSISDN IS NULL
                OR IMSI IS NULL
                OR SUPPLIER_ACCOUNT_ID IS NULL
                OR BILLING_CYCLE_DATE IS NULL
                OR PLAN IS NULL
                OR ORIGINATION_DATE IS NULL
                OR TRANSMIT_BYTE IS NULL
                OR RECEIVE_BYTES IS NULL 
                OR DATAUSAGE IS NULL
                OR APN IS NULL
                OR DEVICE_IP_ADDRESS IS NULL
        OR OPERATOR_NETWORK IS NULL
        OR ORIGINATION_PLAN_DATE IS NULL
        OR SESSION_DURATION IS NULL
        OR CALL_TERMINATION_REASON IS NULL
        OR RATING_STREAM_ID IS NULL
        OR SERVING_SWITCH IS NULL
        OR CALL_TECHNOLOGY_TYPE IS NULL 
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL,
    CEIL(DATAUSAGE/1024) AS DATAUSAGE_ROUNDED FROM temp_cdr_data_return_table
   WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_get_mno_account_id
DROP PROCEDURE IF EXISTS `gm_get_mno_account_id`;
DELIMITER //
CREATE PROCEDURE `gm_get_mno_account_id`(
IN in_account_id INT
)
    COMMENT 'This procedure is used to return the MNO account id '
BEGIN
 
  SELECT MNO_ACCOUNTID FROM report_metadata WHERE ENT_ACCOUNTID = in_account_id LIMIT 1;

END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_get_supplier_account_id
DROP PROCEDURE IF EXISTS `gm_get_supplier_account_id`;
DELIMITER //
CREATE PROCEDURE `gm_get_supplier_account_id`(
IN in_account_id INT
)
    COMMENT 'This procedure is used to return the supplier account id '
BEGIN
 

	SELECT CASE WHEN in_account_id = 7 THEN 8
				WHEN in_account_id = 10 THEN 9
                WHEN in_account_id = 11 THEN 11
			ELSE in_account_id END AS country_ode ;
END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_mobile_network_registration_failure_daily_report
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

-- Dumping structure for procedure stc_report.gm_mobile_number_reconciliation_report
DROP PROCEDURE IF EXISTS `gm_mobile_number_reconciliation_report`;
DELIMITER //
CREATE PROCEDURE `gm_mobile_number_reconciliation_report`(
  IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_mobile_number_reconciliation_report'
BEGIN
  
  
  
  
  
  
  
  
   
  
  DROP TABLE IF EXISTS temp_mobile_reconciliation_data_return_table;
CREATE TEMPORARY TABLE temp_mobile_reconciliation_data_return_table
SELECT ICCID ,
IMSI ,
MSISDN ,
gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID,
case when SIM_STATE='Warm' then 'Shipped'
when SIM_STATE='' or SIM_STATE is NULL or SIM_STATE ='NULL' then 'UnSoldNew'
when SIM_STATE='Active' then 'Subscribed'
when SIM_STATE='Suspend' then 'Dormant'
else SIM_STATE end as SIM_STATE_GM,
SIM_STATE as SIM_STATE_GT,

 CASE WHEN WHOLE_SALE_NAME ='null' THEN NULL ELSE WHOLE_SALE_NAME END AS PRICING_PLAN,
0 AS COMMUNCATION_PLAN,
CASE WHEN ACTIVATION_DATE ='null' THEN NULL ELSE ACTIVATION_DATE END AS ICCID_ACTIVATION_DATE,
CASE WHEN BOOTSTRAP_ICCID ='null' THEN NULL ELSE BOOTSTRAP_ICCID END AS BOOTSTRAP_ICCID
FROM report_metadata
left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
where report_metadata.ENT_ACCOUNTID=in_account_id;

DROP TABLE IF EXISTS temp_mobile_reconciliation_data_return_table_new;
CREATE TEMPORARY TABLE temp_mobile_reconciliation_data_return_table_new
SELECT temp_mobile_reconciliation_data_return_table.*,
CASE WHEN `ICCID` IS NULL OR `MSISDN` IS NULL OR `IMSI` IS NULL
OR `SUPPLIER_ACCOUNT_ID` IS NULL OR `SIM_STATE_GT` IS NULL OR `SIM_STATE_GM` IS NULL OR `PRICING_PLAN` IS NULL
OR `COMMUNCATION_PLAN` IS NULL OR `ICCID_ACTIVATION_DATE` IS NULL
THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
FROM temp_mobile_reconciliation_data_return_table ORDER BY MANDATORY_COL_NULL DESC;

UPDATE temp_mobile_reconciliation_data_return_table_new
SET MANDATORY_COL_NULL=0 WHERE UPPER(SIM_STATE_GT) = 'WARM';
SELECT * FROM temp_mobile_reconciliation_data_return_table_new where PRICING_PLAN is not null
ORDER BY MANDATORY_COL_NULL DESC;

END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_retail_revenue_monthly
DROP PROCEDURE IF EXISTS `gm_retail_revenue_monthly`;
DELIMITER //
CREATE PROCEDURE `gm_retail_revenue_monthly`(
  IN `in_start_date` VARCHAR(50),
  IN `in_end_date` VARCHAR(50),
  IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_retail_revenue_monthly'
BEGIN
  
  
  
  
  
  
  
  
  

  


  
  DECLARE start_date varchar(50);
  DECLARE end_date varchar(50);
  
  
   SET start_date:= CAST(in_start_date AS DATETIME);
   SET end_date:= CAST(in_end_date AS DATETIME);
  
  

  
  SELECT 
  
  report_metadata.MSISDN AS 'MSISDN',
  report_metadata.ICCID AS 'ICCID',
  
  gm_country_code_mapping.country_Code AS 'SUPPLIER ACCOUNT ID' ,
  
  '5' AS 'BILLING CYCLE DATE',
  retail_revenue_share.START_DATE AS 'START DATE',
  retail_revenue_share.DATA_USED AS 'DATA USED',
  retail_revenue_share.CREDIT_AMOUNT AS 'CREDIT AMOUNT',
  
  
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

-- Dumping structure for procedure stc_report.gm_sms_delivered_report
DROP PROCEDURE IF EXISTS `gm_sms_delivered_report`;
DELIMITER //
CREATE PROCEDURE `gm_sms_delivered_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_sms_delivered_report_new'
BEGIN
  
  
  
  
  
  
  
  
  
  
  
   
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);
   
  SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-2020);
  
    
    
  SET @row_number = 0;
  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

  
  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

  
  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
    
  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
  
    
  DROP TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE temp_wholesale_plan_history
  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
      COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
      COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
      COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
  FROM temp_first_wholesale_plan_history 
  LEFT JOIN temp_second_wholesale_plan_history
    ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
      AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI;
            
      
  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

  
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  
  
  
  DROP TABLE IF EXISTS temp_cdr_sms_delivered_return_table;
    CREATE TEMPORARY TABLE temp_cdr_sms_delivered_return_table
    SELECT 
    report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   
   @TEMP_BILLING_CYCLE_DATE AS BILLING_CYCLE_DATE,
   
  cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
  case when temp_wholesale_plan_history.IMSI=report_metadata.IMSI then  temp_wholesale_plan_history.plan ELSE report_metadata.WHOLE_SALE_NAME END AS PLAN,
   -- temp_wholesale_plan_history.plan AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else NULL end AS SERVING_SWITCH,
  cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
  cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
    
  
    LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date))  
   WHERE date(cdr_sms_details.FINAL_TIME)=date(start_date)
  and UPPER(cdr_sms_details.SMS_STATUS) = 'SUCCESS'
  and report_metadata.ENT_ACCOUNTID=in_account_id
   AND case when cdr_sms_details.SMS_TYPE='MO' then length(cdr_sms_details.DESTINATION) = 5
   when cdr_sms_details.SMS_TYPE='MT' then length(cdr_sms_details.SOURCE)=5 END;
  
   

  SELECT temp_cdr_sms_delivered_return_table.*,
  CASE WHEN ICCID IS NULL OR MSISDN IS NULL OR IMSI IS NULL OR SUPPLIER_ACCOUNT_ID IS NULL
      OR BILLING_CYCLE_DATE IS NULL OR CALL_DIRECTION IS NULL OR PLAN IS NULL OR ORIGINATION_DATE IS NULL
      OR SERVING_SWITCH IS NULL OR ORIGINATION_ADDRESS IS NULL OR DESTINATION_ADDRESS IS NULL 
            OR OPERATOR_NETWORK IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_cdr_sms_delivered_return_table
    WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_sms_undelivered_report
DROP PROCEDURE IF EXISTS `gm_sms_undelivered_report`;
DELIMITER //
CREATE PROCEDURE `gm_sms_undelivered_report`(
  IN `in_start_date` varchar(50),
  IN `in_end_date` varchar(50),
  IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_sms_undelivered_report_new'
BEGIN
  
  
  
  
  
  
  
  
  
  

   
   DECLARE date_duration VARCHAR(50);
   DECLARE start_date VARCHAR(50);

    SET start_date:= CAST(in_start_date AS date);
    
  SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-2020);
   
    
    
  SET @row_number = 0;
  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

  
  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

  
  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
    
  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
  
    
  DROP TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE temp_wholesale_plan_history
  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
      COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
      COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
      COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
  FROM temp_first_wholesale_plan_history 
  LEFT JOIN temp_second_wholesale_plan_history
    ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
      AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI;
            
      
  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

   
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
   
  
  
   DROP TABLE IF EXISTS temp_cdr_sms_undelivered_return_table;
   CREATE TEMPORARY TABLE temp_cdr_sms_undelivered_return_table
   SELECT 
  report_metadata.ICCID as ICCID,
  report_metadata.MSISDN as MSISDN,
  report_metadata.IMSI as IMSI,
 

   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   
  @TEMP_BILLING_CYCLE_DATE AS BILLING_CYCLE_DATE,
  cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
  case when temp_wholesale_plan_history.IMSI=report_metadata.IMSI then  temp_wholesale_plan_history.plan ELSE report_metadata.WHOLE_SALE_NAME END AS PLAN,
 -- temp_wholesale_plan_history.plan AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else NULL end AS SERVING_SWITCH,
    cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
  cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
    
  
    LEFT(report_metadata.MSISDN,6) as OPERATOR_NETWORK,
    CASE WHEN cdr_sms_details.REASON IN ('null','NULL') OR cdr_sms_details.REASON IS NULL THEN 6 ELSE REASON END AS CALL_TERMINATIONS_REASON
   
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_Date and temp_wholesale_plan_history.end_date))  
   WHERE date(cdr_sms_details.FINAL_TIME)=start_date
   and UPPER(cdr_sms_details.SMS_STATUS) NOT IN ('SUCCESS')
   and report_metadata.ENT_ACCOUNTID=in_account_id
   AND case when cdr_sms_details.SMS_TYPE='MO' then length(cdr_sms_details.DESTINATION) = 5
  when cdr_sms_details.SMS_TYPE='MT' then length(cdr_sms_details.SOURCE)=5 END;
  
    
  SELECT temp_cdr_sms_undelivered_return_table.*,
  CASE WHEN ICCID IS NULL OR MSISDN IS NULL OR IMSI IS NULL OR SUPPLIER_ACCOUNT_ID IS NULL
      OR BILLING_CYCLE_DATE IS NULL OR CALL_DIRECTION IS NULL OR PLAN IS NULL OR ORIGINATION_DATE IS NULL
      OR SERVING_SWITCH IS NULL OR ORIGINATION_ADDRESS IS NULL OR DESTINATION_ADDRESS IS NULL 
            OR OPERATOR_NETWORK IS NULL OR CALL_TERMINATIONS_REASON IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_cdr_sms_undelivered_return_table
  WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
   
END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_utility_apn_aggregation_monthly
DROP PROCEDURE IF EXISTS `gm_utility_apn_aggregation_monthly`;
DELIMITER //
CREATE PROCEDURE `gm_utility_apn_aggregation_monthly`(
	IN `in_process_date` VARCHAR(50)















)
    COMMENT 'gm_utility_apn_aggregation_monthly '
BEGIN
  
  
  
  
   
  
  
  
  
  

	
    DROP TEMPORARY TABLE if EXISTS temp_monthly_aggregation;
 	 CREATE TEMPORARY TABLE temp_monthly_aggregation
	 SELECT  cdr_data_details.APN_ID ,
	 pgw_svc_data.SERVED_IMSI,
		pgw_svc_data.SERVICE_DATA_FLOW_ID ,
		sum(cdr_data_details.TOTAL_BYTES) AS TOTAL_BYTES
	 FROM ((
	 report_metadata
	 INNER JOIN 
	 cdr_data_details
	 ON report_metadata.IMSI = cdr_data_details.SERVED_IMSI)
	 INNER JOIN pgw_svc_data
	 ON pgw_svc_data.SERVED_IMSI= cdr_data_details.SERVED_IMSI)
	 WHERE cdr_data_details.START_TIME = in_process_date
	 GROUP BY pgw_svc_data.SERVICE_DATA_FLOW_ID ,pgw_svc_data.SERVED_IMSI;
	
	
	
	INSERT INTO apn_billing_cycle_aggregation(APN,SERVED_IMSI,FLOW_ID,DATA_USAGE)
	SELECT APN_ID,SERVED_IMSI,SERVICE_DATA_FLOW_ID,TOTAL_BYTES FROM temp_monthly_aggregation;
END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_utility_get__wholesale_plan_history
DROP PROCEDURE IF EXISTS `gm_utility_get__wholesale_plan_history`;
DELIMITER //
CREATE PROCEDURE `gm_utility_get__wholesale_plan_history`(IN `in_start_date` DATE)
BEGIN
Set @temp_start_date=concat(in_start_date ,' 00:00:00');

 Set @IMSI_count=(select count(distinct IMSI) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date));


 
     DROP TEMPORARY TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE  temp_wholesale_plan_history
    (imsi varchar(20),
    start_date datetime,
    end_date datetime,
	 plan varchar(20));
 
 
  
   SET @j =0;
   loop_loop_1: LOOP
   Set @temp_start_date=concat(in_start_date ,' 00:00:00'); 
     IF @j+1 <= @IMSI_count THEN

     
     
     
      
      
      SET @sql_statement = concat("set @temp_imsi_list=(select Distinct IMSI  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') order by CREATE_DATE limit 1 offset ", @j,");");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
      SET @j = @j + 1;
     
     
   Set @recored_count=(select count(*) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date)  and IMSI = @temp_imsi_list);
 
   SET @i =0;
   loop_loop: LOOP
     IF @i+1 <= @recored_count THEN
     
       IF @i+2 <= @recored_count THEN
        SET @sql_statement = concat("set @temp_end_date=(select  CREATE_DATE  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i+1,");");
    
      prepare stmt1 from @sql_statement;
      execute stmt1;
      deallocate prepare stmt1;
      else 
      set @temp_end_date=concat(in_start_date,' 23:59:59');
      end if;
      
      
      SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, CREATE_DATE as start_date,'",@temp_end_date,"' as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"' order by CREATE_DATE limit 1 offset ", @i,";");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
	   SET @sql_statement = concat("set @temp_start_date=(select  date_add(CREATE_DATE, interval 1 second)  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i,");");
    
      prepare stmt1 from @sql_statement;
    execute stmt1;
      deallocate prepare stmt1;
     SET @i = @i + 1;
     
       
       ITERATE loop_loop;
     END IF;
     LEAVE loop_loop;
   END LOOP loop_loop;
       
	
		  ITERATE loop_loop_1;
     END IF;
     LEAVE loop_loop_1;
   END LOOP loop_loop_1;


END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_utility_last_report_generated
DROP PROCEDURE IF EXISTS `gm_utility_last_report_generated`;
DELIMITER //
CREATE PROCEDURE `gm_utility_last_report_generated`(
	IN `in_report_type` VARCHAR(250),
	IN `in_report_date` varchar(50)
)
    COMMENT 'return the date of last report generated '
BEGIN
  
  
  
  
  
  
  

	
	SET @report_id = (SELECT reports.ID FROM reports WHERE NAME = in_report_type limit 1); 
	SELECT LAST_EXECUTION_TIME 
	FROM report_generation_details 
	WHERE REPORT_ID = @report_id  LIMIT 1;

END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_utility_update_data_details
DROP PROCEDURE IF EXISTS `gm_utility_update_data_details`;
DELIMITER //
CREATE PROCEDURE `gm_utility_update_data_details`(
	IN `in_data_node` varchar(100),
	IN `in_isprocess_value` int(10)



)
BEGIN
  
  
  
  
  
  
  
	
   
    IF (in_data_node = 'SMS')
    THEN
		UPDATE report_data_details
		SET DATA_PROCESSING_DATE =current_timestamp,
		IS_PROCESSED = in_isprocess_value
		WHERE DATA_NODE = 'SMS(Delivered)'
		OR DATA_NODE = 'SMS(Undelivered)'
		;
    ELSE
		
		UPDATE report_data_details
		SET DATA_PROCESSING_DATE = current_timestamp(),
		IS_PROCESSED = in_isprocess_value
		where DATA_NODE = in_data_node;
    
    END IF;
    

END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_utility_update_last_execution_date
DROP PROCEDURE IF EXISTS `gm_utility_update_last_execution_date`;
DELIMITER //
CREATE PROCEDURE `gm_utility_update_last_execution_date`(
	IN `in_report_type` varchar(100),
	IN `in_last_executed_date` varchar(50)

,
	IN `in_path` TEXT






)
BEGIN
 
  
  
  
  
  
  

	
	UPDATE report_generation_details
	INNER JOIN reports 
	ON report_generation_details.report_id = reports.ID
	SET LAST_EXECUTION_TIME = in_last_executed_date,
	REPORT_FILE_PATH = in_path
	WHERE  
	reports.NAME = in_report_type;

END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_voice_report
DROP PROCEDURE IF EXISTS `gm_voice_report`;
DELIMITER //
CREATE PROCEDURE `gm_voice_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_voice_report_new'
BEGIN
 
  
  
  
   
  
  
  
 
  
  
  
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);
  
  
  SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-2020);

  
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  
   
  
  DROP  TEMPORARY TABLE if EXISTS temp_voice_incomplete;
  CREATE TEMPORARY TABLE temp_voice_incomplete
  SELECT 
  report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_incompleted.CALLINGNUMBER,
  cdr_voice_incompleted.CALLEDNUMBER,
  cdr_voice_incompleted.CALLDURATION,
  cdr_voice_incompleted.ANMRECDAT ,
  cdr_voice_incompleted.EVENTSRECD,
  cdr_voice_incompleted.MCC,
  cdr_voice_incompleted.MNC ,
  cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
  cdr_voice_incompleted.MOCALL,
  cdr_voice_incompleted.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER
  or report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date
  and report_metadata.ENT_ACCOUNTID=in_account_id;
      
  
  DROP  TEMPORARY TABLE if EXISTS temp_voice_complete;
  CREATE TEMPORARY TABLE temp_voice_complete
  SELECT report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_completed.CALLINGNUMBER,
  cdr_voice_completed.CALLEDNUMBER,
  cdr_voice_completed.CALLDURATION,
  cdr_voice_completed.ANMRECDAT ,
  cdr_voice_completed.EVENTSRECD ,
  cdr_voice_completed.MCC,
  cdr_voice_completed.MNC ,
  cdr_voice_completed.CAUSEINDCAUSEVALUE,
  cdr_voice_completed.MOCALL,
  cdr_voice_completed.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER
    or report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_completed.ANMRECDAT) = start_date
  and report_metadata.ENT_ACCOUNTID=in_account_id;
  

    
    
  SET @row_number = 0;
  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

  
  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

  
  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
    
  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
  
    
  DROP TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE temp_wholesale_plan_history
  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
      COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
      COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
      COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
  FROM temp_first_wholesale_plan_history 
  LEFT JOIN temp_second_wholesale_plan_history
    ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
      AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI
  WHERE temp_first_wholesale_plan_history.CREATE_DATE <= in_end_date;
            
      
  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

  
  DROP  TEMPORARY TABLE if EXISTS temp_voice;
  CREATE TEMPORARY TABLE temp_voice
  SELECT * FROM temp_voice_complete                         
  UNION ALL 
  SELECT * FROM   temp_voice_incomplete;

  
  DROP TABLE IF EXISTS temp_voice_data_return_table;
    CREATE TEMPORARY TABLE temp_voice_data_return_table
    SELECT DISTINCT
  temp_voice.ICCID  AS 'ICCID',
  temp_voice.IMSI AS 'IMSI',
  temp_voice.MSISDN AS 'MSISDN',
  
  COUNTRY_CODE AS 'ACCOUNT ID',
  
  @TEMP_BILLING_CYCLE_DATE AS 'BILLING CYCLE DATE',
    
  CALLINGNUMBER AS 'CALLING PARTY NUMBER',
  CALLEDNUMBER AS 'CALLED',
  CALLDURATION AS 'ANSWER DURATION',
  CEILING(CALLDURATION/60) as 'ANSWER DURATION ROUNDED',
 -- case when CALLDURATION=0  then CALLDURATION else CAST(CALLDURATION/60 AS UNSIGNED)*60 end as 'ANSWER DURATION ROUNDED',
  ANMRECDAT AS 'ORIGINATION DATE',
    LEFT(MSISDN,6) AS 'OPERATOR NETWORK',
  
  
  case when MOCALL=0 OR MOCALL IS NULL 
      then LASTERBCSM
       when MOCALL=1 
      then COALESCE(LASTERBCSM,0)
  end AS 'CALL TERMINATION REASON',
  1 as 'CALL TYPE',
  case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION',
 case when temp_wholesale_plan_history.IMSI=temp_voice.IMSI then  temp_wholesale_plan_history.plan ELSE temp_voice.WHOLE_SALE_NAME END AS PLAN,
 -- temp_wholesale_plan_history.plan AS PLAN,
  cdr_voice_tadig_codes.TC_TADIG_CODE as TAP_CODE
  FROM temp_voice
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=temp_voice.IMSI
  and (ANMRECDAT between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)
  left join cdr_voice_tadig_codes on temp_voice.MCC=cdr_voice_tadig_codes.TC_MCC
  and case when CHAR_LENGTH(temp_voice.MNC)=1 then  concat('0',temp_voice.MNC) else temp_voice.MNC END = case when CHAR_LENGTH(cdr_voice_tadig_codes.TC_MNC)=1 then  concat('0',cdr_voice_tadig_codes.TC_MNC) else cdr_voice_tadig_codes.TC_MNC end ;

  
   
  SELECT temp_voice_data_return_table.*,CASE WHEN ICCID IS NULL OR IMSI IS NULL OR MSISDN IS NULL OR `ACCOUNT ID` IS NULL OR `BILLING CYCLE DATE` IS NULL
    OR `CALLING PARTY NUMBER` IS NULL OR `CALLED` IS NULL OR `ANSWER DURATION` IS NULL OR `ANSWER DURATION ROUNDED` IS NULL 
        OR `ORIGINATION DATE` IS NULL OR `OPERATOR NETWORK` IS NULL OR `CALL TERMINATION REASON` IS NULL OR `CALL TYPE` IS NULL
    OR `CALL DIRECTION` IS NULL OR PLAN IS NULL OR TAP_CODE IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_voice_data_return_table 
  WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
  ORDER BY MANDATORY_COL_NULL DESC;



END//
DELIMITER ;

-- Dumping structure for table stc_report.network_registration_failure_code
DROP TABLE IF EXISTS `network_registration_failure_code`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_code` (
  `id` int(11) DEFAULT NULL,
  `node` varchar(50) DEFAULT NULL,
  `kpi_name` varchar(50) DEFAULT NULL,
  `code` varchar(50) DEFAULT NULL,
  `value` varchar(50) DEFAULT NULL,
  `createdat` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table which store network registration failure for level 1.';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.network_registration_failure_data
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

-- Data exporting was unselected.

-- Dumping structure for table stc_report.network_registration_failure_level_1
DROP TABLE IF EXISTS `network_registration_failure_level_1`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_level_1` (
  `id` int(11) DEFAULT NULL,
  `level_name` varchar(50) DEFAULT NULL,
  `level_alias` varchar(50) DEFAULT NULL,
  `createdat` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table which store network registration failure for level 1.';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.network_registration_failure_level_2
DROP TABLE IF EXISTS `network_registration_failure_level_2`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_level_2` (
  `id` int(11) DEFAULT NULL,
  `level_name` varchar(50) DEFAULT NULL,
  `level_alias` varchar(50) DEFAULT NULL,
  `createdat` datetime DEFAULT NULL,
  `level_one_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table which store network registration failure for level 1.';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.network_registration_failure_level_3
DROP TABLE IF EXISTS `network_registration_failure_level_3`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_level_3` (
  `id` int(11) DEFAULT NULL,
  `level_name` varchar(50) DEFAULT NULL,
  `level_alias` varchar(50) DEFAULT NULL,
  `createdat` datetime DEFAULT NULL,
  `level_two_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table which store network registration failure for level 1.';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.network_registration_failure_level_4
DROP TABLE IF EXISTS `network_registration_failure_level_4`;
CREATE TABLE IF NOT EXISTS `network_registration_failure_level_4` (
  `id` int(11) DEFAULT NULL,
  `level_name` varchar(50) DEFAULT NULL,
  `level_alias` varchar(50) DEFAULT NULL,
  `createdat` datetime DEFAULT NULL,
  `level_three_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table which store network registration failure for level 1.';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.pgw_svc_data
DROP TABLE IF EXISTS `pgw_svc_data`;
CREATE TABLE IF NOT EXISTS `pgw_svc_data` (
  `SERVED_IMSI` varchar(256) NOT NULL,
  `CHARGING_ID` bigint(20) NOT NULL,
  `TIME_OF_REPORT` datetime DEFAULT NULL,
  `AF_CHARGING_ID` bigint(20) DEFAULT NULL,
  `CHARGING_RULEBASE_NAME` varchar(256) DEFAULT NULL,
  `DOWNLINK_BYTES` bigint(20) DEFAULT NULL,
  `DOWNLINK_PACKETS` bigint(20) DEFAULT NULL,
  `UPLINK_BYTES` bigint(20) DEFAULT NULL,
  `UPLINK_PACKETS` bigint(20) DEFAULT NULL,
  `LOCAL_SEQUENCE_NUMBER` bigint(20) DEFAULT NULL,
  `QOS_CLASS_ID` bigint(20) DEFAULT NULL,
  `QOS_UPLINK_MBR` bigint(20) DEFAULT NULL,
  `QOS_DOWNLINK_MBR` bigint(20) DEFAULT NULL,
  `QOS_UPLINK_GBR` bigint(20) DEFAULT NULL,
  `QOS_DOWNLINK_GBR` bigint(20) DEFAULT NULL,
  `QOS_BEARER_ID` varchar(256) DEFAULT NULL,
  `ARP_PRIORITY_LEVEL` bigint(20) DEFAULT NULL,
  `ARP_P_EMPTION_CAPABILITY` bigint(20) DEFAULT NULL,
  `ARP_P_EMPTION_VULNERABILITY` bigint(20) DEFAULT NULL,
  `QOS_APN_UPLINK_AMBR` bigint(20) DEFAULT NULL,
  `QOS_APN_DOWNLINK_AMBR` bigint(20) DEFAULT NULL,
  `RATING_GROUP_QUOTA_ID` bigint(20) DEFAULT NULL,
  `CHANGE_TIME` datetime DEFAULT NULL,
  `SERVICE_DATA_FLOW_ID` varchar(50) DEFAULT NULL,
  `SERVICE_SPECIFIC_INFO` varchar(256) DEFAULT NULL,
  `SGSN_ADDRESS` varchar(256) DEFAULT NULL,
  `SERVING_NODE_ADDRESS` varchar(256) DEFAULT NULL,
  `TIME_OF_FIRST_USAGE` datetime DEFAULT NULL,
  `TIME_OF_LAST_USAGE` datetime DEFAULT NULL,
  `DURATION_SEC` bigint(20) DEFAULT NULL,
  `CHANGE_CONDITION` bigint(20) DEFAULT NULL,
  `USER_LOCATION_INFO` varchar(256) DEFAULT NULL,
  KEY `SERVED_IMSI` (`SERVED_IMSI`(255)),
  KEY `CHARGING_ID` (`CHARGING_ID`),
  KEY `SERVICE_DATA_FLOW_ID` (`SERVICE_DATA_FLOW_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table stc_report.plan
DROP TABLE IF EXISTS `plan`;
CREATE TABLE IF NOT EXISTS `plan` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Auto incremented id',
  `gm_plan_id` varchar(256) DEFAULT NULL COMMENT 'plan id of gm',
  `bss_plan_id` varchar(256) DEFAULT NULL COMMENT 'plan id of bss',
  `plan_name` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table is used to store plan details of bss and gm.';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.reports
DROP TABLE IF EXISTS `reports`;
CREATE TABLE IF NOT EXISTS `reports` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(256) NOT NULL DEFAULT '0' COMMENT 'reports names',
  `INTERVAL_VALUE` int(11) NOT NULL DEFAULT '0' COMMENT 'Frequency  value ',
  `INTERVAL_UNIT` varchar(50) NOT NULL DEFAULT '0' COMMENT 'Frequency  type',
  `REMARKS` varchar(256) NOT NULL DEFAULT '0' COMMENT 'description',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains details about the reports';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.report_data_details
DROP TABLE IF EXISTS `report_data_details`;
CREATE TABLE IF NOT EXISTS `report_data_details` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `DATA_NODE` varchar(256) DEFAULT NULL,
  `REPORT_NODE` varchar(100) DEFAULT NULL,
  `DATA_PROCESSING_DATE` datetime NOT NULL,
  `IS_PROCESSED` tinyint(4) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains details of data fetched from gcontrol and mediation database.';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.report_generation_details
DROP TABLE IF EXISTS `report_generation_details`;
CREATE TABLE IF NOT EXISTS `report_generation_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `REPORT_ID` int(11) NOT NULL DEFAULT '0',
  `START_DATE` datetime DEFAULT NULL,
  `END_DATE` datetime DEFAULT NULL,
  `LAST_EXECUTION_TIME` date DEFAULT NULL,
  `REPORT_FILE_PATH` text,
  PRIMARY KEY (`id`),
  KEY `fk_reports` (`REPORT_ID`),
  CONSTRAINT `fk_reports` FOREIGN KEY (`REPORT_ID`) REFERENCES `reports` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains genration details of every reports in reports table.';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.report_mapping
DROP TABLE IF EXISTS `report_mapping`;
CREATE TABLE IF NOT EXISTS `report_mapping` (
  `REPORT_ID` int(11) DEFAULT NULL,
  `NODE_ID` int(11) DEFAULT NULL,
  KEY `REPORT_ID` (`REPORT_ID`),
  KEY `NODE_ID` (`NODE_ID`),
  CONSTRAINT `NODE_ID` FOREIGN KEY (`NODE_ID`) REFERENCES `report_data_details` (`ID`),
  CONSTRAINT `REPORT_ID` FOREIGN KEY (`REPORT_ID`) REFERENCES `reports` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='this table is used to generate the mapping between reports and respective tables  ';

-- Data exporting was unselected.

-- Dumping structure for table stc_report.report_metadata
DROP TABLE IF EXISTS `report_metadata`;
CREATE TABLE IF NOT EXISTS `report_metadata` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ICCID` varchar(20) DEFAULT NULL,
  `MSISDN` varchar(255) DEFAULT NULL,
  `IMSI` varchar(255) DEFAULT NULL,
  `MNO_ACCOUNTID` bigint(20) DEFAULT NULL,
  `ENT_ACCOUNTID` bigint(20) DEFAULT NULL,
  `RATE_PLAN_ID` bigint(20) DEFAULT NULL,
  `BILLING_CYCLE` bigint(3) DEFAULT NULL,
  `WHOLESALE_PLAN_ID` bigint(20) DEFAULT NULL,
  `SERVICE_PLAN_ID` bigint(20) DEFAULT '1',
  `ACCOUNT_NAME` varchar(1000) DEFAULT NULL,
  `RATE_PLAN_NAME` varchar(50) DEFAULT NULL,
  `WHOLE_SALE_NAME` varchar(50) DEFAULT NULL,
  `SERVICE_PLAN_NAME` varchar(255) DEFAULT NULL,
  `SIM_STATE` varchar(45) DEFAULT NULL,
  `ACTIVATION_DATE` varchar(45) DEFAULT NULL,
  `ACCOUNT_COUNTRIE` varchar(45) DEFAULT NULL,
  `BOOTSTRAP_ICCID` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `IMSI` (`IMSI`),
  KEY `ACCOUNT_COUNTRIE` (`ACCOUNT_COUNTRIE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table stc_report.retail_revenue_share
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

-- Data exporting was unselected.

-- Dumping structure for view stc_report.vw_network_registration_failure_level
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

-- Dumping structure for table stc_report.wholesale_plan_history
DROP TABLE IF EXISTS `wholesale_plan_history`;
CREATE TABLE IF NOT EXISTS `wholesale_plan_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `MESSAGE` varchar(200) DEFAULT '0',
  `OLD_VALUE` varchar(50) DEFAULT '0',
  `NEW_VALUE` varchar(50) DEFAULT '0',
  `RESULT` varchar(50) DEFAULT '0',
  `CREATE_DATE` datetime DEFAULT NULL,
  `ASSET_ID` varchar(50) DEFAULT '0',
  `ATTRIBUTE` varchar(50) DEFAULT '0',
  `ICCID` varchar(50) DEFAULT '0',
  `IMSI` varchar(50) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for view stc_report.vw_network_registration_failure_level
DROP VIEW IF EXISTS `vw_network_registration_failure_level`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vw_network_registration_failure_level`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_network_registration_failure_level` AS select `fl1`.`level_name` AS `level_1`,`fl1`.`level_alias` AS `level_alias_1`,`fl2`.`level_name` AS `level_2`,`fl2`.`level_alias` AS `level_alias_2`,`fl3`.`level_name` AS `level_3`,`fl3`.`level_alias` AS `level_alias_3`,`fl4`.`level_name` AS `level_4`,`fl4`.`level_alias` AS `level_alias_4` from (((`network_registration_failure_level_1` `fl1` join `network_registration_failure_level_2` `fl2` on((`fl1`.`id` = `fl2`.`level_one_id`))) join `network_registration_failure_level_3` `fl3` on((`fl2`.`id` = `fl3`.`level_two_id`))) join `network_registration_failure_level_4` `fl4` on((`fl3`.`id` = `fl4`.`level_three_id`)));


-- Dumping structure for procedure stc_report.gm_mobile_number_reconciliation_report
DROP PROCEDURE IF EXISTS `gm_mobile_number_reconciliation_report`;
DELIMITER //
CREATE PROCEDURE `gm_mobile_number_reconciliation_report`(
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_mobile_number_reconciliation_report'
BEGIN
  
  
  
  
  
  
  
  
   
/*  
DROP TABLE IF EXISTS temp_mobile_reconciliation_data_return_table;
CREATE TEMPORARY TABLE temp_mobile_reconciliation_data_return_table
SELECT ICCID ,
IMSI ,
MSISDN ,
gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID,
case when SIM_STATE='Warm' then 'Shipped'
when SIM_STATE='' or SIM_STATE is NULL or SIM_STATE ='NULL' then 'UnSoldNew'
when SIM_STATE='Active' then 'Subscribed'
when SIM_STATE='Suspend' then 'Dormant'
else SIM_STATE end as SIM_STATE_GM,
SIM_STATE as SIM_STATE_GT,

 CASE WHEN WHOLE_SALE_NAME ='null' THEN NULL ELSE WHOLE_SALE_NAME END AS PRICING_PLAN,
0 AS COMMUNCATION_PLAN,
CASE WHEN ACTIVATION_DATE ='null' THEN NULL ELSE ACTIVATION_DATE END AS ICCID_ACTIVATION_DATE,
CASE WHEN BOOTSTRAP_ICCID ='null' THEN NULL ELSE BOOTSTRAP_ICCID END AS BOOTSTRAP_ICCID
FROM report_metadata
left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
where report_metadata.ENT_ACCOUNTID=in_account_id;
*/

DROP TABLE IF EXISTS temp_mobile_reconciliation_data_return_table;
CREATE TEMPORARY TABLE temp_mobile_reconciliation_data_return_table
SELECT ICCID ,
IMSI ,
MSISDN ,
gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID,
case when (SIM_STATE='Warm' OR SIM_STATE='Activated') AND WHOLE_SALE_NAME LIKE 'GLOBAL_FACTORY%' then 'Shipped'
when (SIM_STATE='Warm' OR SIM_STATE='Activated') AND WHOLE_SALE_NAME LIKE '%FACTORY_RatePlan%' AND WHOLE_SALE_NAME NOT LIKE 'GLOBAL_FACTORY%' then 'UnSoldNew'
when (SIM_STATE='Warm' OR SIM_STATE='Activated') AND WHOLE_SALE_NAME LIKE '%1KB_RatePlan' then 'Subscribed'
when (SIM_STATE !='Warm' OR SIM_STATE !='Activated' OR SIM_STATE='Suspend' OR SIM_STATE='Deactivated' OR SIM_STATE ='NULL') AND (WHOLE_SALE_NAME IS NULL OR WHOLE_SALE_NAME ='' OR WHOLE_SALE_NAME ='NULL') then 'Dormant'
else SIM_STATE end as SIM_STATE_GM,
SIM_STATE as SIM_STATE_GT,

 CASE WHEN WHOLE_SALE_NAME ='null' THEN NULL ELSE WHOLE_SALE_NAME END AS PRICING_PLAN,
0 AS COMMUNCATION_PLAN,
CASE WHEN ACTIVATION_DATE ='null' THEN NULL ELSE ACTIVATION_DATE END AS ICCID_ACTIVATION_DATE,
CASE WHEN BOOTSTRAP_ICCID ='null' THEN NULL ELSE BOOTSTRAP_ICCID END AS BOOTSTRAP_ICCID
FROM report_metadata
left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
where report_metadata.ENT_ACCOUNTID=in_account_id;


DROP TABLE IF EXISTS temp_mobile_reconciliation_data_return_table_new;
CREATE TEMPORARY TABLE temp_mobile_reconciliation_data_return_table_new
SELECT temp_mobile_reconciliation_data_return_table.*,
CASE WHEN `ICCID` IS NULL OR `MSISDN` IS NULL OR `IMSI` IS NULL
OR `SUPPLIER_ACCOUNT_ID` IS NULL OR `SIM_STATE_GT` IS NULL OR `SIM_STATE_GM` IS NULL OR `PRICING_PLAN` IS NULL
OR `COMMUNCATION_PLAN` IS NULL OR `ICCID_ACTIVATION_DATE` IS NULL
THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
FROM temp_mobile_reconciliation_data_return_table ORDER BY MANDATORY_COL_NULL DESC;

UPDATE temp_mobile_reconciliation_data_return_table_new
SET MANDATORY_COL_NULL=0 WHERE UPPER(SIM_STATE_GT) = 'WARM';
SELECT * FROM temp_mobile_reconciliation_data_return_table_new where PRICING_PLAN is not null
ORDER BY MANDATORY_COL_NULL DESC;

END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_truncate_row_data
DROP PROCEDURE IF EXISTS `gm_truncate_row_data`;
DELIMITER //
CREATE PROCEDURE `gm_truncate_row_data`()
BEGIN

   TRUNCATE TABLE cdr_data_details_vw;
   TRUNCATE TABLE cdr_sms_details;
   TRUNCATE TABLE cdr_voice_completed;
   TRUNCATE TABLE cdr_voice_incompleted;
END//
DELIMITER ;

ALTER TABLE `report_metadata` ADD COLUMN `ACCOUNT_NOTES` VARCHAR(45) NULL DEFAULT NULL AFTER `BOOTSTRAP_ICCID`;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
