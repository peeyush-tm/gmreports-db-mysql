-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table gm_reports.report_metadata
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
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;



-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table gm_reports.wholesale_plan_history
DROP TABLE IF EXISTS `wholesale_plan_history`;
CREATE TABLE IF NOT EXISTS `wholesale_plan_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `MESSAGE` varchar(200) DEFAULT '0',
  `OLD_VALUE` varchar(50) DEFAULT '0',
  `NEW_VALUE` varchar(50) DEFAULT '0',
  `RESULT` varchar(50) DEFAULT '0',
  `CREATE_DATE` varchar(50) DEFAULT '0',
  `ASSET_ID` varchar(50) DEFAULT '0',
  `ATTRIBUTE` varchar(50) DEFAULT '0',
  `ICCID` varchar(50) DEFAULT '0',
  `IMSI` varchar(50) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;


-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table gm_reports.gm_country_code_mapping
DROP TABLE IF EXISTS `gm_country_code_mapping`;
CREATE TABLE IF NOT EXISTS `gm_country_code_mapping` (
  `account` varchar(50) DEFAULT '0',
  `country_Code` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table gm_reports.gm_country_code_mapping: ~11 rows (approximately)
DELETE FROM `gm_country_code_mapping`;
/*!40000 ALTER TABLE `gm_country_code_mapping` DISABLE KEYS */;
INSERT INTO `gm_country_code_mapping` (`account`, `country_Code`) VALUES
  ('GT MVNO', 2),
  ('GLOBAL', 3),
  ('Saudi Arabia', 7),
  ('Netherlands', 5),
  ('Australia', 4),
  ('United Arab Emirates', 8),
  ('KUWAIT', 9),
  ('Qatar', 10),
  ('Koria', 6),
  ('Globetouch', 1),
  ('Bahrain', 11);
/*!40000 ALTER TABLE `gm_country_code_mapping` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;


-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table gm_reports.cdr_voice_incompleted
DROP TABLE IF EXISTS `cdr_voice_incompleted`;
CREATE TABLE IF NOT EXISTS `cdr_voice_incompleted` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `CALLID` varchar(50) NOT NULL DEFAULT '0',
  `EVENTSRECD` bigint(20) DEFAULT NULL,
  `IAMRECDAT` datetime DEFAULT NULL,
  `ANMRECDAT` datetime DEFAULT NULL,
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
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;


-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table gm_reports.cdr_voice_completed
DROP TABLE IF EXISTS `cdr_voice_completed`;
CREATE TABLE IF NOT EXISTS `cdr_voice_completed` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `CALLID` varchar(50) DEFAULT '0',
  `EVENTSRECD` bigint(20) DEFAULT NULL,
  `IAMRECDAT` datetime DEFAULT NULL,
  `ANMRECDAT` datetime DEFAULT NULL,
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
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;


-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table gm_reports.cdr_data_details_vw
DROP TABLE IF EXISTS `cdr_data_details_vw`;
CREATE TABLE IF NOT EXISTS `cdr_data_details_vw` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `SERVED_IMSI` varchar(20) NOT NULL,
  `SERVED_MSISDN` varchar(20) NOT NULL,
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


-- Dumping structure for table gm_reports.cdr_sms_details
DROP TABLE IF EXISTS `cdr_sms_details`;
CREATE TABLE IF NOT EXISTS `cdr_sms_details` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `SMS_TYPE` varchar(256) DEFAULT NULL,
  `SOURCE` varchar(256) DEFAULT NULL,
  `DESTINATION` varchar(256) DEFAULT NULL,
  `SENT_TIME` datetime DEFAULT NULL,
  `FINAL_TIME` datetime DEFAULT NULL,
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
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;


-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure gm_reports.gm_data_report
DROP PROCEDURE IF EXISTS `gm_data_report`;
DELIMITER //
CREATE  PROCEDURE `gm_data_report`(IN `in_start_date` varchar(50), IN `in_end_date` varchar(50)
, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_data_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_data_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
   
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is used to returns cdr data on the basis of 
  -- the served imsi and STOP_TIME
  
  -- Description: Procedure returns the report genarted 
  -- **********************************************************************

  -- Declaration of the variables 
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);

  -- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  -- select concat(@temp_date ,' - ',date_duration);
   
  -- prepare the data report with the multiple tables joins 
  SELECT 
  report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
--  report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
  -- concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
  '5' AS BILLING_CYCLE_DATE,
  report_metadata.WHOLE_SALE_NAME AS PLAN,
   cdr_data_details.START_TIME AS ORIGINATION_DATE,
   cdr_data_details.UPLINK_BYTES AS TRANSMIT_BYTE,
   cdr_data_details.DOWNLINK_BYTES AS RECEIVE_BYTES,
  cdr_data_details.TOTAL_BYTES AS DATAUSAGE,
  -- sum(cdr_data_details.TOTAL_BYTES * rounded_config ) AS DATAUSAGE_ROUNDING,
   cdr_data_details.APN_ID AS APN,
  cdr_data_details.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
   cdr_data_details.SERVED_IMSI AS OPERATOR_NETWORK,
   concat(cdr_data_details.ULI_MCC,',',cdr_data_details.ULI_MNC) AS OPERATOR_NETWORK,
  cdr_data_details.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
  cdr_data_details.DURATION_SEC AS SESSION_DURATION,
   -- pgw_svc_data.SERVICE_DATA_FLOW_ID  ,
  cdr_data_details.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
    pgw_svc_data.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    -- 6 PARAMTER MISING     
   cdr_data_details.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   case when cdr_data_details.RAT_TYPE=1 then 'UTRAN - 3G' when cdr_data_details.RAT_TYPE=6 then 'EUTRAN - 4G' when cdr_data_details.RAT_TYPE=2 then 'GERAN - 2G' else cdr_data_details.RAT_TYPE end  AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details.PGW_ADDRESS AS GGSN_IP_ADDRESS,
   cdr_data_details.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number
  from  ((report_metadata
  INNER JOIN cdr_data_details
  ON report_metadata.IMSI = cdr_data_details.SERVED_IMSI
  INNER JOIN pgw_svc_data
  ON 
  -- pgw_svc_data.SERVED_IMSI= report_metadata.IMSI
--  and 
  pgw_svc_data.SERVED_IMSI= cdr_data_details.SERVED_IMSI
  and pgw_svc_data.CHARGING_ID =cdr_data_details.CHARGING_ID)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account)
      WHERE date(cdr_data_details.STOP_TIME) = date(start_date)
      and report_metadata.MNO_ACCOUNTID=in_account_id
  group by cdr_data_details.SERVED_IMSI, pgw_svc_data.CHARGING_ID;
  /*
  FROM ((report_metadata
  INNER JOIN cdr_data_details
  ON report_metadata.IMSI = cdr_data_details.SERVED_IMSI)
  INNER JOIN pgw_svc_data
  ON pgw_svc_data.SERVED_IMSI= cdr_data_details.SERVED_IMSI
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account)
  WHERE date(cdr_data_details.STOP_TIME) = date(start_date)
  group by cdr_data_details.SERVED_IMSI, pgw_svc_data.CHARGING_ID;
*/

END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_mobile_number_reconciliation_report
DROP PROCEDURE IF EXISTS `gm_mobile_number_reconciliation_report`;
DELIMITER //
CREATE  PROCEDURE `gm_mobile_number_reconciliation_report`(IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_mobile_number_reconciliation_report'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_mobile_number_reconciliation_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
  
  -- Output : Returns the updated status of the mobile report
  -- Description: Procedure is use to generate the Mobile Number Reconciliation  report according to the creation date  
  --  *****************************************************************************************************
   
  -- prepare the data from the updated meta data tables of gc data
    SELECT ICCID ,
    MSISDN , 
    IMSI ,
    gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID,
    SIM_STATE as SIM_STATE_GT,
    case when SIM_STATE='Warm' then 'Device Shipped'
   when SIM_STATE='' or SIM_STATE is null then 'UnSoldNewVehicle' 
   when SIM_STATE='Active' then 'Subscribed' 
   when SIM_STATE='Suspend' then 'Dormant' 
   else SIM_STATE end as SIM_STATE_GM,
    RATE_PLAN_NAME AS PRICING_PLAN,
    RATE_PLAN_NAME AS COMMUNCATION_PLAN,
    ACTIVATION_DATE AS ICCID_ACTIVATION_DATE,
    ICCID as BOOTSTRAP_ICCID
    FROM report_metadata
   left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
   where report_metadata.MNO_ACCOUNTID=in_account_id;
   

END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_sms_delivered_report
DROP PROCEDURE IF EXISTS `gm_sms_delivered_report`;
DELIMITER //
CREATE  PROCEDURE `gm_sms_delivered_report`(IN `in_start_date` varchar(50), IN `in_end_date` varchar(50)




















, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_sms_delivered_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_sms_delivered_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is returns the delivered sms report on the basis
  -- of the final time and sms status 
  -- Description: Procedure returns the sms delivered report genarted 
  -- **********************************************************************
  
   -- Declaring the variables 
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);
   
 

  -- Preparing the billing dates
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  -- select concat(@temp_date ,' - ',date_duration);
  
  -- preparing the reports data from the different table on the basis of the SMS type and time 
  SELECT 
    report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   -- report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
   -- concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
   '5' AS BILLING_CYCLE_DATE,
  cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
  -- report_metadata.WHOLE_SALE_NAME AS PLAN,
   wholesale_plan_history.NEW_VALUE AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else cdr_sms_details.ORIGINATION_GT end AS SERVING_SWITCH,
  case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.SOURCE
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION
  else cdr_sms_details.SOURCE end  AS ORIGINATION_ADDRESS ,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.DESTINATION
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.SOURCE
  else cdr_sms_details.DESTINATION end AS DESTINATION_ADDRESS,
    -- cdr_sms_details.DESTINATION_GT,
    case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT
  else cdr_sms_details.DESTINATION end  AS OPERATOR_NETWORK
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join wholesale_plan_history on wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_sms_details.FINAL_TIME between  wholesale_plan_history.CREATE_DATE and wholesale_plan_history.CREATE_DATE))  
   WHERE date(cdr_sms_details.FINAL_TIME)=date(start_date)
  and cdr_sms_details.SMS_STATUS = 'Success'
  and report_metadata.MNO_ACCOUNTID=in_account_id
  GROUP BY IMSI,MSISDN ,CALL_DIRECTION ,ORIGINATION_DATE ;


END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_sms_undelivered_report
DROP PROCEDURE IF EXISTS `gm_sms_undelivered_report`;
DELIMITER //
CREATE  PROCEDURE `gm_sms_undelivered_report`(IN `in_start_date` varchar(50), IN `in_end_date` varchar(50)















, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_sms_undelivered_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_sms_undelivered_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is returns the undelivered sms report on the basis
  -- of the final time and sms status 
  -- Description: Procedure returns the sms undelivered report genarted 
  -- **********************************************************************

   -- Declaring the variables 
   DECLARE date_duration VARCHAR(50);
   DECLARE start_date VARCHAR(50);

    SET start_date:= CAST(in_start_date AS date);
   

   -- preparing the billing dates 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
   -- select concat(@temp_date ,' - ',date_duration);
  
  -- preparing the reports data from the different table on the basis of the SMS type and time 
   SELECT 
  report_metadata.ICCID as ICCID,
  report_metadata.MSISDN as MSISDN,
  report_metadata.IMSI as IMSI,
 --  report_metadata.MNO_ACCOUNTID as SUPPLIER_ACCOUNT_ID ,
--  concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   '5' AS BILLING_CYCLE_DATE,
  cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
  report_metadata.WHOLE_SALE_NAME AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   /*cdr_sms_details.ORIGINATION_GT AS SERVING_SWITCH,
  cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
   cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
  cdr_sms_details.SUBSCRIBER_IMSI AS OPERATOR_NETWORK,*/
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else cdr_sms_details.ORIGINATION_GT end AS SERVING_SWITCH,
  case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.SOURCE
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION
  else cdr_sms_details.SOURCE end  AS ORIGINATION_ADDRESS ,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.DESTINATION
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.SOURCE
  else cdr_sms_details.DESTINATION end AS DESTINATION_ADDRESS,
    -- cdr_sms_details.DESTINATION_GT,
    case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT
  else cdr_sms_details.DESTINATION end  AS OPERATOR_NETWORK,
   cdr_sms_details.REASON AS CALL_TERMINATIONS_REASON
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account)  
   WHERE date(cdr_sms_details.FINAL_TIME)=start_date
   and cdr_sms_details.SMS_STATUS ='Failed'
   and report_metadata.MNO_ACCOUNTID=in_account_id
   GROUP BY IMSI,MSISDN ,CALL_DIRECTION ,  ORIGINATION_DATE ;
   
END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_voice_report
DROP PROCEDURE IF EXISTS `gm_voice_report`;
DELIMITER //
CREATE  PROCEDURE `gm_voice_report`(IN `in_start_date` varchar(50)
, IN `in_end_date` varchar(50)

















, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_voice_report_new'
BEGIN
 -- **********************************************************************
  -- Procedure: gm_voice_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
   
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is used to returns voice data  on the basis of 
  -- the served imsi and served flow id and ANMRECDAT
 
  -- Description: Procedure is use to generate the voice report according to the creation date  
  -- **********************************************************************
  
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);

  -- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  -- select concat(@temp_date ,' - ',date_duration);
   
  -- generate a table to fetch the data from the incomplete voice table   
  DROP  TEMPORARY TABLE if EXISTS temp_voice_complete;
  CREATE TEMPORARY TABLE temp_voice_complete
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
  gm_country_code_mapping.country_Code AS COUNTRY_CODE
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON report_metadata.IMSI = cdr_voice_incompleted.CALLEDNUMBER
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date
  and report_metadata.MNO_ACCOUNTID=in_account_id;
      
  -- generate a table to fetch the data from the complete voice table 
  DROP  TEMPORARY TABLE if EXISTS temp_voice_incomplete;
  CREATE TEMPORARY TABLE temp_voice_incomplete
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
  gm_country_code_mapping.country_Code AS COUNTRY_CODE
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON report_metadata.IMSI = cdr_voice_completed.CALLEDNUMBER
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_completed.ANMRECDAT) = start_date
  and report_metadata.MNO_ACCOUNTID=in_account_id;

  -- preparing the data from merging the both table complete and incomplete 
  DROP  TEMPORARY TABLE if EXISTS temp_voice;
  CREATE TEMPORARY TABLE temp_voice
  SELECT * FROM temp_voice_complete                         
  UNION ALL 
  SELECT * FROM   temp_voice_incomplete;

  -- final result report of the voice data 
  SELECT 
  ICCID  AS 'ICCID',
  IMSI AS 'IMSI',
  MSISDN AS 'MSISDN',
  -- WHOLESALE_PLAN_ID AS 'ACCOUNT ID',
  COUNTRY_CODE AS 'ACCOUNT ID',
  MNO_ACCOUNTID AS 'ACCOUNT ID',
  -- concat(@temp_date ,' - ',date_duration) AS 'BILLING CYCLE DATE',
  '5' AS 'BILLING CYCLE DATE',
  CALLINGNUMBER AS 'CALLING PARTY NUMBER',
  CALLEDNUMBER AS 'CALLED',
  CALLDURATION AS 'ANSWER DURATION',
  CAST(CALLDURATION/60 AS INT)*60+60 as 'ANSWER DURATION ROUNDED',
  ANMRECDAT AS 'ORIGINATION DATE',
  (MCC+MNC) AS 'OPERATOR NETWORK',
  -- CAUSEINDCAUSEVALUE AS 'CALL TERMINATION REASON',
  case when MOCALL=0 and (CALLDURATION is null or CALLDURATION =0) 
      then 
      case 
           when LASTERBCSM = 13 
              then 'Busy'   
           when LASTERBCSM = 14 
              then 'Not answered'   
           when LASTERBCSM = 18 
              then 'Abandoned i.e. Caller cut the call'
           when LASTERBCSM = 13 
              then 'Busy'      
      end 
       when MOCALL=1 and (CALLDURATION is null or CALLDURATION =0) 
      then 
      case  when LASTERBCSM = 4
              then 'Route selection failure' 
          when LASTERBCSM = 5 
              then 'Busy'
          when LASTERBCSM = 6
              then 'Not answered'
          when LASTERBCSM = 10
              then 'Abandoned i.e. Caller cut the call'
      end
  end AS 'CALL TERMINATION REASON',
  'Circuit Switched' as 'CALL TYPE',
  case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION'
  FROM temp_voice
  GROUP BY IMSI,'ANSWER DURATION','ORIGINATION DATE';

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
