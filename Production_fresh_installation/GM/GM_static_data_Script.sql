-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table .cdr_data_details
DROP TABLE IF EXISTS `cdr_data_details`;
CREATE TABLE IF NOT EXISTS `cdr_data_details` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `SERVED_IMSI` varchar(20) NOT NULL,
  `RECORD_OPENING_TIME` datetime NOT NULL,
  `DURATION_SEC` int(11) NOT NULL,
  `CAUSE_FOR_CLOSING` int(11) NOT NULL,
  `SERVING_NODE_IPADDR` varchar(200) NOT NULL,
  `RAT_TYPE` int(11) NOT NULL,
  `SERVICE_DATA_FLOW_ID` varchar(100) NOT NULL,
  `PGW_ADDRESS` varchar(50) NOT NULL,
  `APN_ID` varchar(128) NOT NULL,
  `SERVED_PDP_ADDRESS` varchar(50) NOT NULL,
  `START_TIME` datetime NOT NULL,
  `STOP_TIME` datetime NOT NULL,
  `DOWNLINK_BYTES` bigint(20) NOT NULL,
  `UPLINK_BYTES` bigint(20) NOT NULL,
  `TOTAL_BYTES` bigint(20) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table .cdr_sms_details
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table .cdr_voice_completed
DROP TABLE IF EXISTS `cdr_voice_completed`;
CREATE TABLE IF NOT EXISTS `cdr_voice_completed` (
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
  `CALLDURATION` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table .cdr_voice_details
DROP TABLE IF EXISTS `cdr_voice_details`;
CREATE TABLE IF NOT EXISTS `cdr_voice_details` (
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
  `CALLDURATION` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table .cdr_voice_incompleted
DROP TABLE IF EXISTS `cdr_voice_incompleted`;
CREATE TABLE IF NOT EXISTS `cdr_voice_incompleted` (
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
  `CALLDURATION` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for procedure .gm_data_report
DROP PROCEDURE IF EXISTS `gm_data_report`;
DELIMITER //
CREATE  PROCEDURE `gm_data_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50)


)
BEGIN
  -- **********************************************************************
  -- Procedure: gm_data_report
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Description: Procedure returns the report genarted 
  -- **********************************************************************

	SELECT 
	report_metadata.ICCID,
	report_metadata.MSISDN,
	report_metadata.IMSI,
	report_metadata.RATE_PLAN_NAME,
	cdr_data_details.START_TIME,
	cdr_data_details.STOP_TIME,
	cdr_data_details.DOWNLINK_BYTES,
	cdr_data_details.UPLINK_BYTES,
	cdr_data_details.TOTAL_BYTES,
	cdr_data_details.APN_ID,
	cdr_data_details.SERVED_PDP_ADDRESS,
	cdr_data_details.RECORD_OPENING_TIME,
	-- cdr_data_details.CURATION_SEC,
	cdr_data_details.CAUSE_FOR_CLOSING,
	cdr_data_details.SERVICE_DATA_FLOW_ID
	FROM (report_metadata
	INNER JOIN cdr_data_details
	ON report_metadata.ID = cdr_data_details.ID)
	WHERE cdr_data_details.STOP_TIME=in_start_date;


END//
DELIMITER ;

-- Dumping structure for procedure .gm_sms_delivered_report
DROP PROCEDURE IF EXISTS `gm_sms_delivered_report`;
DELIMITER //
CREATE  PROCEDURE `gm_sms_delivered_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50)




)
BEGIN
  -- **********************************************************************
  -- Procedure: gm_sms_delivered_report
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Description: Procedure returns the sms delivered report genarted 
  -- **********************************************************************

	SELECT 
    report_metadata.ICCID as ICCID,
	report_metadata.MSISDN as MSISDN,
	report_metadata.IMSI as IMSI,
    report_metadata.MNO_ACCOUNTID as SUPPLIER_ACCOUNT_ID ,
	report_metadata.BILLING_CYCLE AS BILLING_CYCLE_DATE,
	cdr_sms_details.SMS_TYPE AS CALL_DIRACTION,
	report_metadata.RATE_PLAN_NAME AS PLAN,
    cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
    cdr_sms_details.ORIGINATION_GT AS SERVING_SWITCH,
	cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
    cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
    cdr_sms_details.DESTINATION_GT,
	cdr_sms_details.SUBSCRIBER_IMSI AS OPERATOR_NETWORK
	FROM (report_metadata
	INNER JOIN cdr_sms_details
	ON report_metadata.ID = cdr_sms_details.ID)
	WHERE cdr_sms_details.FINAL_TIME=in_start_date
	and cdr_sms_details.SMS_STATUS = 'Success';

END//
DELIMITER ;

-- Dumping structure for procedure .gm_sms_undelivered_report
DROP PROCEDURE IF EXISTS `gm_sms_undelivered_report`;
DELIMITER //
CREATE  PROCEDURE `gm_sms_undelivered_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50)




)
BEGIN
  -- **********************************************************************
  -- Procedure: gm_sms_undelivered_report
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Description: Procedure returns the sms undelivered report genarted 
  -- **********************************************************************

	SELECT 
        report_metadata.ICCID as ICCID,
	report_metadata.MSISDN as MSISDN,
	report_metadata.IMSI as IMSI,
    report_metadata.MNO_ACCOUNTID as SUPPLIER_ACCOUNT_ID ,
	report_metadata.BILLING_CYCLE AS BILLING_CYCLE_DATE,
	cdr_sms_details.SMS_TYPE AS CALL_DIRACTION,
	report_metadata.RATE_PLAN_NAME AS PLAN,
    cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
    cdr_sms_details.ORIGINATION_GT AS SERVING_SWITCH,
	cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
    cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
    cdr_sms_details.DESTINATION_GT,
	cdr_sms_details.SUBSCRIBER_IMSI AS OPERATOR_NETWORK,
    cdr_sms_details.REASON AS CALL_TERMINATIONS_REASON
	FROM (report_metadata
	INNER JOIN cdr_sms_details
	ON report_metadata.ID = cdr_sms_details.ID)
	WHERE cdr_sms_details.FINAL_TIME=in_start_date
    and cdr_sms_details.SMS_STATUS ='Failure';
END//
DELIMITER ;

-- Dumping structure for procedure .gm_utility_last_report_generated
DROP PROCEDURE IF EXISTS `gm_utility_last_report_generated`;
DELIMITER //
CREATE  PROCEDURE `gm_utility_last_report_generated`(
	IN `in_report_type` VARCHAR(50),
	IN `in_report_date` varchar(50)

)
    COMMENT 'return the date of last report generated '
BEGIN
  -- **********************************************************************
  -- Procedure: gm_utility_last_report_generated
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Description: Utility returns the last executed process report 
  -- **********************************************************************

	DECLARE last_sanity_date varchar(255);
   DECLARE last_execution_date varchar(255);
   
	SET last_sanity_date= (SELECT data_processing_date FROM report_data_details where data_node =in_report_type  LIMIT 1);
	SET last_execution_date = (SELECT last_execution_time FROM report_genration_details where report_id = 1  LIMIT 1);
    
	IF(last_execution_date <= last_sanity_date)
	THEN 
	SELECT max(last_execution_time) as Last_Report_date
	FROM 
	report_genration_details
	INNER JOIN report_data_details 
	ON (report_data_details.id = report_genration_details.report_id)
	WHERE report_data_details.data_node =  in_report_type
    AND report_data_details.is_processed = 1
	GROUP BY (report_id);
    ELSE
		select "wrong date selection ";
    END IF;


END//
DELIMITER ;

-- Dumping structure for procedure .gm_utility_update_data_details
DROP PROCEDURE IF EXISTS `gm_utility_update_data_details`;
DELIMITER //
CREATE  PROCEDURE `gm_utility_update_data_details`(
IN `in_data_node` varchar(100),
IN `in_isprocess_value` int(10))
BEGIN
  -- **********************************************************************
  -- Procedure: gm_utility_update_data_details
  -- Author: Parul Shrivastava
  -- Date: Nov 4, 2019
  
  -- Description: Utility to update the data_details values according to filters 
  -- **********************************************************************
	
    IF (in_data_node = 'SMS')
    THEN
		update report_data_details
		set data_processing_date =current_timestamp,
		is_processed = in_isprocess_value
		where data_node = 'SMS(Delivered)'
		or data_node = 'SMS(Undelivered)'
		;
    else
		update report_data_details
		set data_processing_date =current_timestamp(),
		is_processed = in_isprocess_value
		where data_node = in_data_node;
    
    END IF;
    

END//
DELIMITER ;

-- Dumping structure for procedure .gm_voice_report
DROP PROCEDURE IF EXISTS `gm_voice_report`;
DELIMITER //
CREATE  PROCEDURE `gm_voice_report`(
	IN `in_start_date` varchar(50)
,
	IN `in_end_date` varchar(50)
)
BEGIN
 -- **********************************************************************
  -- Procedure: gm_voice_report
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
  
  -- Description: Procedure is use to generate the voicce report according to the creation date  
  -- **********************************************************************
	SELECT 
    report_metadata.ICCID,
	report_metadata.MSISDN,
	report_metadata.IMSI,
	report_metadata.RATE_PLAN_NAME,
    cdr_voice_details.START_TIME,
	cdr_voice_details.CALLINGNUMBER,
	cdr_voice_details.CALLEDNUMBER,
	cdr_voice_details.CALLDURATION,
	cdr_voice_details.ANMRECDAT
	FROM (report_metadata
	INNER JOIN cdr_voice_rw_completed_calls_archive
    INNER JOIN cdr_voice_rw_incompleted_calls_archive
	ON report_metadata.ID = cdr_voice_rw_completed_calls_archive.ID
    and report_metadata.ID = cdr_voice_rw_incompleted_calls_archive.ID)
	WHERE IAMRECDAT >= to_date(in_start_date, 'YYYY-MM-DD HH24:MI:SS')
    AND  IAMRECDAT <= to_date(in_start_date, 'YYYY-MM-DD HH24:MI:SS'); 

END//
DELIMITER ;

-- Dumping structure for table .reports
DROP TABLE IF EXISTS `reports`;
CREATE TABLE IF NOT EXISTS `reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(256) NOT NULL DEFAULT '0' COMMENT 'reports names',
  `interval_value` int(11) NOT NULL DEFAULT '0' COMMENT 'Frequency  value ',
  `interval_unit` varchar(50) NOT NULL DEFAULT '0' COMMENT 'Frequency  type',
  `remarks` varchar(256) NOT NULL DEFAULT '0' COMMENT 'description',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains details about the reports';

-- Data exporting was unselected.

-- Dumping structure for table .report_data_details
DROP TABLE IF EXISTS `report_data_details`;
CREATE TABLE IF NOT EXISTS `report_data_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_node` varchar(256) NOT NULL,
  `data_processing_date` datetime NOT NULL,
  `is_processed` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains details of data fetched from gcontrol and mediation database.';

-- Data exporting was unselected.

-- Dumping structure for table .report_genration_details
DROP TABLE IF EXISTS `report_genration_details`;
CREATE TABLE IF NOT EXISTS `report_genration_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) NOT NULL DEFAULT '0',
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `last_execution_time` date NOT NULL,
  `report_file_path` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_reports` (`report_id`),
  CONSTRAINT `fk_reports` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains genration details of every reports in reports table.';

-- Data exporting was unselected.

-- Dumping structure for table .report_metadata
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
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
