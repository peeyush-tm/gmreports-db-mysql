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

-- Dumping structure for table apn_billing_cycle_aggregation
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

-- Dumping structure for event apn_details_aggregation
DROP EVENT IF EXISTS `apn_details_aggregation`;
DELIMITER //
CREATE  EVENT `apn_details_aggregation` ON SCHEDULE EVERY 1 DAY STARTS '2019-11-26 23:59:59' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'apn_details_aggregation' DO BEGIN
-- **********************************************************************
  -- Procedure: apn_details_aggregation
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
   
  -- Description: Event is used to generat the aggregation on daily
  --  basis interval  
  -- **********************************************************************

	-- call the utility to generate the data monthly 
   CALL `gm_utility_apn_aggregation_monthly`(CURRENT_DATE());

 	
	
END//
DELIMITER ;

-- Dumping structure for table cdr_data_details
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

-- Dumping structure for table cdr_sms_details
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

-- Dumping structure for table cdr_voice_completed
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
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table cdr_voice_incompleted
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
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table cdr_voice_tadig_codes
DROP TABLE IF EXISTS `cdr_voice_tadig_codes`;
CREATE TABLE IF NOT EXISTS `cdr_voice_tadig_codes` (
  `TC_TADIG_CODE` varchar(256) NOT NULL,
  `TC_NETWORK_ID` bigint(20) NOT NULL,
  `TC_MCC` varchar(256) DEFAULT '0',
  `TC_MNC` varchar(256) DEFAULT '0',
  `TC_REC_CHANGED_AT` datetime DEFAULT NULL,
  `TC_REC_CHANGED_BY` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='cdr_voice_tadig_codes';

-- Data exporting was unselected.

-- Dumping structure for procedure gm_apn_billing_cycle_report
DROP PROCEDURE IF EXISTS `gm_apn_billing_cycle_report`;
DELIMITER //
CREATE  PROCEDURE `gm_apn_billing_cycle_report`(
	IN `in_start_date` VARCHAR(50),
	IN `in_end_date` VARCHAR(50)







)
    COMMENT 'gm_apn_billing_cycle_report'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_apn_billing_cycle_report
  -- Author: Parul Shrivastava
  -- Date: Nov 21, 2019
  -- Description: Procedure is returned  the prepared data from the table 
  
  -- Input paramter: in_start_date,in_end_date
  -- Output : procedure is used to return the total usage on the basis of the
  --          served imsi and served_flow_id

  -- **********************************************************************

	-- Declaration of the variables 
	DECLARE start_date varchar(50);
	DECLARE end_date varchar(50);
	
	-- consersion of date to datetime
   SET start_date:= CAST(in_start_date AS DATEtime);
   SET end_date:= CAST(in_end_date AS DATEtime);
	
	-- Preparing the query for fetching the data for the APN billing report 
	SELECT APN ,
		FLOW_ID AS 'Flow ID',
		SUM(DATA_USAGE) AS 'Total usage'
	FROM apn_billing_cycle_aggregation 
	INNER JOIN report_metadata
	on report_metadata.IMSI = apn_billing_cycle_aggregation.SERVED_IMSI
	WHERE CREATE_DATE BETWEEN  start_date AND end_date;



END//
DELIMITER ;

-- Dumping structure for procedure gm_data_report
DROP PROCEDURE IF EXISTS `gm_data_report`;
DELIMITER //
CREATE  PROCEDURE `gm_data_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50)








)
    COMMENT 'gm_data_report'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_data_report
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
    report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
	concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
	report_metadata.WHOLE_SALE_NAME AS PLAN,
   cdr_data_details.START_TIME AS ORIGINATION_DATE,
   cdr_data_details.UPLINK_BYTES AS TRANSMIT_BYTE,
   cdr_data_details.DOWNLINK_BYTES AS RECEIVE_BYTES,
	cdr_data_details.TOTAL_BYTES AS DATAUSAGE,
	-- sum(cdr_data_details.TOTAL_BYTES * rounded_config ) AS DATAUSAGE_ROUNDING,
   cdr_data_details.APN_ID AS APN,
	cdr_data_details.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
   cdr_data_details.SERVED_IMSI AS OPERATOR_NETWORK,
	cdr_data_details.RECORD_OPENING_TIME AS ORIGINATION_DATE,
	cdr_data_details.DURATION_SEC AS SESSION_DURATION,
   -- pgw_svc_data.SERVICE_DATA_FLOW_ID  ,
	cdr_data_details.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
  	pgw_svc_data.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    -- 6 PARAMTER MISING 
    
   cdr_data_details.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   cdr_data_details.RAT_TYPE AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details.PGW_ADDRESS AS GGSN_IP_ADDRESS
	FROM ((report_metadata
	INNER JOIN cdr_data_details
	ON report_metadata.IMSI = cdr_data_details.SERVED_IMSI)
	INNER JOIN pgw_svc_data
	ON pgw_svc_data.SERVED_IMSI= cdr_data_details.SERVED_IMSI)
	WHERE date(cdr_data_details.STOP_TIME) = date(start_date);


END//
DELIMITER ;

-- Dumping structure for procedure gm_mobile_number_reconciliation_report
DROP PROCEDURE IF EXISTS `gm_mobile_number_reconciliation_report`;
DELIMITER //
CREATE  PROCEDURE `gm_mobile_number_reconciliation_report`()
    COMMENT 'gm_mobile_number_reconciliation_report'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_mobile_number_reconciliation_report
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
  
  -- Output : Returns the updated status of the mobile report
  -- Description: Procedure is use to generate the Mobile Number Reconciliation  report according to the creation date  
  --  *****************************************************************************************************
   
  -- prepare the data from the updated meta data tables of gc data
    SELECT ICCID ,
    MSISDN , 
    IMSI ,
    ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID,
    SIM_STATE ,
    RATE_PLAN_NAME AS PLAN,
    ACTIVATION_DATE AS ICCID_ACTIVATION_DATE
    FROM report_metadata;
	 

END//
DELIMITER ;

-- Dumping structure for procedure gm_sms_delivered_report
DROP PROCEDURE IF EXISTS `gm_sms_delivered_report`;
DELIMITER //
CREATE  PROCEDURE `gm_sms_delivered_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50)















)
    COMMENT 'gm_sms_delivered_report'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_sms_delivered_report
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
   report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
	concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
	cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
	report_metadata.WHOLE_SALE_NAME AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   cdr_sms_details.ORIGINATION_GT AS SERVING_SWITCH,
	cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
   cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
    -- cdr_sms_details.DESTINATION_GT,
	cdr_sms_details.SUBSCRIBER_IMSI AS OPERATOR_NETWORK
	FROM (report_metadata
	INNER JOIN cdr_sms_details
	ON report_metadata.ID = cdr_sms_details.ID)
	WHERE date(cdr_sms_details.FINAL_TIME)=start_date
	and cdr_sms_details.SMS_STATUS = 'Success';

END//
DELIMITER ;

-- Dumping structure for procedure gm_sms_undelivered_report
DROP PROCEDURE IF EXISTS `gm_sms_undelivered_report`;
DELIMITER //
CREATE  PROCEDURE `gm_sms_undelivered_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50)










)
    COMMENT 'gm_sms_undelivered_report'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_sms_undelivered_report
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is returns the undelivered sms report on the basis
  -- of the final time and sms status 
  -- Description: Procedure returns the sms undelivered report genarted 
  -- **********************************************************************

	 -- Declaring the variables 
 	 DECLARE date_duration VARCHAR(50);
 	 DECLARE start_date varchar(50);

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
    report_metadata.MNO_ACCOUNTID as SUPPLIER_ACCOUNT_ID ,
	concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
	cdr_sms_details.SMS_TYPE AS CALL_DIRACTION,
	report_metadata.WHOLE_SALE_NAME AS PLAN,
    cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
    cdr_sms_details.ORIGINATION_GT AS SERVING_SWITCH,
	cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
    cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
    -- cdr_sms_details.DESTINATION_GT,
	cdr_sms_details.SUBSCRIBER_IMSI AS OPERATOR_NETWORK,
    cdr_sms_details.REASON AS CALL_TERMINATIONS_REASON
	FROM (report_metadata
	INNER JOIN cdr_sms_details
	ON report_metadata.ID = cdr_sms_details.ID)
	WHERE date(cdr_sms_details.FINAL_TIME)= start_date
    and cdr_sms_details.SMS_STATUS ='Failed';
END//
DELIMITER ;

-- Dumping structure for procedure gm_utility_apn_aggregation_monthly
DROP PROCEDURE IF EXISTS `gm_utility_apn_aggregation_monthly`;
DELIMITER //
CREATE  PROCEDURE `gm_utility_apn_aggregation_monthly`(
	IN `in_process_date` VARCHAR(50)















)
    COMMENT 'gm_utility_apn_aggregation_monthly '
BEGIN
  -- **********************************************************************
  -- Procedure: gm_utility_apn_aggregation_monthly
  -- Author: Parul Shrivastava
  -- Date: Nov 26, 2019
   
  -- Inputs: in_process_date
  -- Output: This utility is used to generat the monthly aggregated data
  
  -- Description: Procedure returns the aggregated data  
  -- **********************************************************************

	-- temporary table to store the data on basis of current date 
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
	
	-- select * from temp; 
	-- insert into APN billing table 
	INSERT INTO apn_billing_cycle_aggregation(APN,SERVED_IMSI,FLOW_ID,DATA_USAGE)
	SELECT APN_ID,SERVED_IMSI,SERVICE_DATA_FLOW_ID,TOTAL_BYTES FROM temp_monthly_aggregation;
END//
DELIMITER ;

-- Dumping structure for procedure gm_utility_last_report_generated
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
  
  -- Description: Utility returns the last executed process report date
  -- **********************************************************************

	-- Declaring the variables 
   DECLARE last_execution_date varchar(255);

	-- Set the variables for the check the data 
	SET @report_id = (SELECT reports.ID FROM reports WHERE NAME = in_report_type limit 1);
   set @temp_node_id = (select GROUP_CONCAT(NODE_ID) from report_mapping where REPORT_ID = @report_id  );
	SET last_execution_date = (SELECT LAST_EXECUTION_TIME FROM report_generation_details WHERE REPORT_ID = @report_id  LIMIT 1);							
	
	-- select last_sanity_date,last_execution_date ,@report_id;
	SET @count_mapping_id = (select COUNT(NODE_ID) from report_mapping 
  								where REPORT_ID = @report_id  );
  								
	-- select @temp_node_id, @COUNT_ID;
	-- checking the last snity date for the last execution date o fthe report   
	SET @count_report_id = (SELECT COUNT(ID)  FROM report_data_details
						WHERE FIND_IN_SET(ID,@temp_node_id) 
						and DATA_PROCESSING_DATE >= DATE(last_execution_date)
						AND  IS_PROCESSED = 1 );
	
	  -- check the condition for the sanity last update report of the data 
	IF(@count_mapping_id = @count_report_id )
	THEN 
		SELECT LAST_EXECUTION_TIME 
		FROM report_generation_details 
		WHERE REPORT_ID = @report_id  LIMIT 1;
	ELSE 
		SELECT 'Data is not available for this report';
	
	END IF;

END//
DELIMITER ;

-- Dumping structure for procedure gm_utility_update_data_details
DROP PROCEDURE IF EXISTS `gm_utility_update_data_details`;
DELIMITER //
CREATE  PROCEDURE `gm_utility_update_data_details`(
	IN `in_data_node` varchar(100),
	IN `in_isprocess_value` int(10)



)
BEGIN
  -- **********************************************************************
  -- Procedure: gm_utility_update_data_details
  -- Author: Parul Shrivastava
  -- Date: Nov 4, 2019
  
  -- Description: Utility to update the data_details values according to filters 
  -- **********************************************************************
	
   -- update the table last process data date into the table 
    IF (in_data_node = 'SMS')
    THEN
		UPDATE report_data_details
		SET DATA_PROCESSING_DATE =current_timestamp,
		IS_PROCESSED = in_isprocess_value
		WHERE DATA_NODE = 'SMS(Delivered)'
		OR DATA_NODE = 'SMS(Undelivered)'
		;
    ELSE
		-- update the table last process data date into the table 
		UPDATE report_data_details
		SET DATA_PROCESSING_DATE = current_timestamp(),
		IS_PROCESSED = in_isprocess_value
		where DATA_NODE = in_data_node;
    
    END IF;
    

END//
DELIMITER ;

-- Dumping structure for procedure gm_utility_update_last_execution_date
DROP PROCEDURE IF EXISTS `gm_utility_update_last_execution_date`;
DELIMITER //
CREATE  PROCEDURE `gm_utility_update_last_execution_date`(
	IN `in_report_type` varchar(100),
	IN `in_last_executed_date` varchar(50)

,
	IN `in_path` TEXT






)
BEGIN
 -- **********************************************************************
  -- Procedure: gm_utility_update_last_execution_date
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Description: Utility update the last successfully generated reprot date 
  -- **********************************************************************

	-- updating the last generated report into the generation_details table with the report path 
	UPDATE report_generation_details
	INNER JOIN reports 
	ON report_generation_details.report_id = reports.ID
	SET LAST_EXECUTION_TIME = in_last_executed_date,
	REPORT_FILE_PATH = in_path
	WHERE  
	reports.NAME = in_report_type;

END//
DELIMITER ;

-- Dumping structure for procedure gm_voice_report
DROP PROCEDURE IF EXISTS `gm_voice_report`;
DELIMITER //
CREATE  PROCEDURE `gm_voice_report`(
	IN `in_start_date` varchar(50)
,
	IN `in_end_date` varchar(50)













)
    COMMENT 'gm_voice_report'
BEGIN
 -- **********************************************************************
  -- Procedure: gm_voice_report
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
	cdr_voice_incompleted.CAUSEINDCAUSEVALUE
	FROM cdr_voice_incompleted 
	INNER JOIN report_metadata 
	ON report_metadata.ID = cdr_voice_incompleted.ID
	WHERE date(ANMRECDAT) =start_date;
	    
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
	cdr_voice_completed.CAUSEINDCAUSEVALUE
	FROM cdr_voice_completed 
	INNER JOIN report_metadata 
	ON report_metadata.ID = cdr_voice_completed.ID
	WHERE date(ANMRECDAT) = start_date;

	-- preparing the data from merging the both table complete and incomplete	
	DROP  TEMPORARY TABLE if EXISTS temp_voice;
	CREATE TEMPORARY TABLE temp_voice
	SELECT * FROM temp_voice_complete                         
	UNION ALL 
	SELECT * FROM 	temp_voice_incomplete;

	-- final result report of the voice data 
	SELECT 
	ICCID  AS 'ICCID',
	IMSI AS 'IMSI',
	MSISDN AS 'MSISDN',
	WHOLESALE_PLAN_ID AS 'ACCOUNT ID',
	MNO_ACCOUNTID AS 'ACCOUNT ID',
	concat(@temp_date ,' - ',date_duration) AS 'BILLING CYCLE DATE',
	CALLINGNUMBER AS 'CALLING PARTY NUMBER',
	CALLEDNUMBER AS 'CALLED',
	CALLDURATION AS 'ANSWER DURATION',
	ANMRECDAT AS 'ORIGINATION DATE',
	(MCC+MNC) AS 'OPERATOR NETWORK',
	CAUSEINDCAUSEVALUE AS 'CALL TERMINATION REASON'
	FROM temp_voice;

END//
DELIMITER ;

-- Dumping structure for table pgw_svc_data
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

-- Dumping structure for table reports
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

-- Dumping structure for table report_data_details
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

-- Dumping structure for table report_generation_details
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
  CONSTRAINT `fk_reports` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains genration details of every reports in reports table.';

-- Data exporting was unselected.

-- Dumping structure for table report_mapping
DROP TABLE IF EXISTS `report_mapping`;
CREATE TABLE IF NOT EXISTS `report_mapping` (
  `REPORT_ID` int(11) DEFAULT NULL,
  `NODE_ID` int(11) DEFAULT NULL,
  KEY `REPORT_ID` (`REPORT_ID`),
  KEY `NODE_ID` (`NODE_ID`),
  CONSTRAINT `NODE_ID` FOREIGN KEY (`NODE_ID`) REFERENCES `report_data_details` (`ID`),
  CONSTRAINT `REPORT_ID` FOREIGN KEY (`REPORT_ID`) REFERENCES `reports` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='this table is used to generate the mapping between reports and respective tables  ';

-- Data exporting was unselected.

-- Dumping structure for table report_metadata
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
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




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


-- Dumping structure for table gm_reports.gm_country_code_mapping
DROP TABLE IF EXISTS `gm_country_code_mapping`;
CREATE TABLE IF NOT EXISTS `gm_country_code_mapping` (
  `account` varchar(50) DEFAULT '0',
  `country_Code` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



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

Set @temp_start_date=concat(in_start_date ,' 00:00:00');
--  Set @recored_count=(select count(*) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00'));
 Set @IMSI_count=(select count(distinct IMSI) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date));
-- select @recored_count;
-- select * from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00') limit 1 offset 3;
 
     DROP TEMPORARY TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE  temp_wholesale_plan_history
    (imsi varchar(20),
    start_date datetime,
    end_date datetime,
   plan varchar(20));
 -- DECLARE  temp_start_date datetime;
 
  
   SET @j =0;
   loop_loop_1: LOOP
   Set @temp_start_date=concat(in_start_date ,' 00:00:00'); 
     IF @j+1 <= @IMSI_count THEN
--       SELECT @i,CAST(@i AS INT);
     -- SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, '",@temp_start_date,"' as start_date,CREATE_DATE as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') order by CREATE_DATE limit 1 offset ", @i,";");
     -- prepare stmt1 from @sql_statement;
     --  execute stmt1;
      -- deallocate prepare stmt1;
      
      SET @sql_statement = concat("set @temp_imsi_list=(select Distinct IMSI  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') order by CREATE_DATE limit 1 offset ", @j,");");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
      SET @j = @j + 1;
     -- select @temp_imsi_list;
     --  Set @temp_start_date=concat(in_start_date ,' 00:00:00');    
   Set @recored_count=(select count(*) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date)  and IMSI = @temp_imsi_list);
 --  select @recored_count;
   SET @i =0;
   loop_loop: LOOP
     IF @i+1 <= @recored_count THEN
     
       IF @i+2 <= @recored_count THEN
        SET @sql_statement = concat("set @temp_end_date=(select  CREATE_DATE  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i+1,");");
    -- select @sql_statement;
      prepare stmt1 from @sql_statement;
      execute stmt1;
      deallocate prepare stmt1;
      else 
      set @temp_end_date=concat(in_start_date,' 23:59:59');
      end if;
      -- SELECT @i,CAST(@i AS INT);
      -- SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, '",@temp_start_date,"' as start_date,CREATE_DATE as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"' order by CREATE_DATE limit 1 offset ", @i,";");
      SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, CREATE_DATE as start_date,'",@temp_end_date,"' as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"' order by CREATE_DATE limit 1 offset ", @i,";");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
     SET @sql_statement = concat("set @temp_start_date=(select  date_add(CREATE_DATE, interval 1 second)  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i,");");
    -- select @sql_statement;
      prepare stmt1 from @sql_statement;
    execute stmt1;
      deallocate prepare stmt1;
     SET @i = @i + 1;
     -- select @sql_statement ;
       -- select * from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00') limit 1 offset CAST(@i AS INT);
       ITERATE loop_loop;
     END IF;
     LEAVE loop_loop;
   END LOOP loop_loop;
       
  
      ITERATE loop_loop_1;
     END IF;
     LEAVE loop_loop_1;
   END LOOP loop_loop_1;



  
  
  SELECT 
  report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
--  report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
  -- concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
  '5' AS BILLING_CYCLE_DATE,
--  report_metadata.WHOLE_SALE_NAME AS PLAN,
  temp_wholesale_plan_history.plan AS PLAN,
   cdr_data_details_vw.START_TIME AS ORIGINATION_DATE,
   sum(cdr_data_details_vw.UPLINK_BYTES) AS TRANSMIT_BYTE,
   sum(cdr_data_details_vw.DOWNLINK_BYTES) AS RECEIVE_BYTES,
  sum(cdr_data_details_vw.TOTAL_BYTES) AS DATAUSAGE,
  -- sum(cdr_data_details_vw.TOTAL_BYTES * rounded_config ) AS DATAUSAGE_ROUNDING,
   cdr_data_details_vw.APN_ID AS APN,
  cdr_data_details_vw.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
--   cdr_data_details_vw.SERVED_IMSI AS OPERATOR_NETWORK,
   concat(cdr_data_details_vw.ULI_MCC,case when CHAR_LENGTH(cdr_data_details_vw.ULI_MNC)=1 then  concat('0',cdr_data_details_vw.ULI_MNC) else cdr_data_details_vw.ULI_MNC end ) AS OPERATOR_NETWORK,
  cdr_data_details_vw.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
  sum(cdr_data_details_vw.DURATION_SEC) AS SESSION_DURATION,
   -- pgw_svc_data.SERVICE_DATA_FLOW_ID  ,
  cdr_data_details_vw.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
    cdr_data_details_vw.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    -- 6 PARAMTER MISING     
   cdr_data_details_vw.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   case when cdr_data_details_vw.RAT_TYPE=1 then 'UTRAN - 3G' when cdr_data_details_vw.RAT_TYPE=6 then 'EUTRAN - 4G' when cdr_data_details_vw.RAT_TYPE=2 then 'GERAN - 2G' else cdr_data_details_vw.RAT_TYPE end  AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details_vw.PGW_ADDRESS AS GGSN_IP_ADDRESS,
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number
  from  ((report_metadata
  INNER JOIN cdr_data_details_vw
  ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_data_details_vw.START_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)))
     WHERE 
      date(cdr_data_details_vw.STOP_TIME) = date(start_date)
     and report_metadata.MNO_ACCOUNTID=in_account_id
  group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID,cdr_data_details_vw.SERVICE_DATA_FLOW_ID;
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
   when SIM_STATE='' or SIM_STATE is NULL or SIM_STATE ='NULL'  then 'UnSoldNewVehicle' 
   when SIM_STATE='Active' then 'Subscribed' 
   when SIM_STATE='Suspend' then 'Dormant' 
   else SIM_STATE end as SIM_STATE_GM,
    RATE_PLAN_NAME AS PRICING_PLAN,
    RATE_PLAN_NAME AS COMMUNCATION_PLAN,
    ACTIVATION_DATE AS ICCID_ACTIVATION_DATE,
    -- ICCID as BOOTSTRAP_ICCID
    BOOTSTRAP_ICCID
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
   
  CALL `gm_utility_get__wholesale_plan_history`(in_start_date);

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
   temp_wholesale_plan_history.plan AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else NULL end AS SERVING_SWITCH,
  case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.SOURCE
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION
  else NULL end  AS ORIGINATION_ADDRESS ,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.DESTINATION
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.SOURCE
  else NULL end AS DESTINATION_ADDRESS,
    -- cdr_sms_details.DESTINATION_GT,
    case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT
  else NULL end  AS OPERATOR_NETWORK
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date))  
   WHERE date(cdr_sms_details.FINAL_TIME)=date(start_date)
  and cdr_sms_details.SMS_STATUS = 'Success'
  and report_metadata.MNO_ACCOUNTID=in_account_id;
  -- GROUP BY IMSI,MSISDN ,CALL_DIRECTION ,ORIGINATION_DATE ;


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
   
    CALL `gm_utility_get__wholesale_plan_history`(in_start_date);
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
  -- report_metadata.WHOLE_SALE_NAME AS PLAN,
  temp_wholesale_plan_history.plan AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   /*cdr_sms_details.ORIGINATION_GT AS SERVING_SWITCH,
  cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
   cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
  cdr_sms_details.SUBSCRIBER_IMSI AS OPERATOR_NETWORK,*/
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else NULL end AS SERVING_SWITCH,
  case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.SOURCE
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION
  else NULL end  AS ORIGINATION_ADDRESS ,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.DESTINATION
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.SOURCE
  else NULL end AS DESTINATION_ADDRESS,
    -- cdr_sms_details.DESTINATION_GT,
    case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT
  else NULL end  AS OPERATOR_NETWORK,
   cdr_sms_details.REASON AS CALL_TERMINATIONS_REASON
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_Date and temp_wholesale_plan_history.end_date))  
   WHERE date(cdr_sms_details.FINAL_TIME)=start_date
   and cdr_sms_details.SMS_STATUS ='Failed'
   and report_metadata.MNO_ACCOUNTID=in_account_id;
--   GROUP BY IMSI,MSISDN ,CALL_DIRECTION ,  ORIGINATION_DATE ;
   
END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_utility_get__wholesale_plan_history
DROP PROCEDURE IF EXISTS `gm_utility_get__wholesale_plan_history`;
DELIMITER //
CREATE  PROCEDURE `gm_utility_get__wholesale_plan_history`(IN `in_start_date` DATE)
BEGIN
Set @temp_start_date=concat(in_start_date ,' 00:00:00');
--  Set @recored_count=(select count(*) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00'));
 Set @IMSI_count=(select count(distinct IMSI) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date));
-- select @recored_count;
-- select * from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00') limit 1 offset 3;
 
     DROP TEMPORARY TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE  temp_wholesale_plan_history
    (imsi varchar(20),
    start_date datetime,
    end_date datetime,
   plan varchar(20));
 -- DECLARE  temp_start_date datetime;
 
  
   SET @j =0;
   loop_loop_1: LOOP
   Set @temp_start_date=concat(in_start_date ,' 00:00:00'); 
     IF @j+1 <= @IMSI_count THEN
--       SELECT @i,CAST(@i AS INT);
     -- SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, '",@temp_start_date,"' as start_date,CREATE_DATE as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') order by CREATE_DATE limit 1 offset ", @i,";");
     -- prepare stmt1 from @sql_statement;
     --  execute stmt1;
      -- deallocate prepare stmt1;
      
      SET @sql_statement = concat("set @temp_imsi_list=(select Distinct IMSI  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') order by CREATE_DATE limit 1 offset ", @j,");");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
      SET @j = @j + 1;
     -- select @temp_imsi_list;
     --  Set @temp_start_date=concat(in_start_date ,' 00:00:00');    
   Set @recored_count=(select count(*) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date)  and IMSI = @temp_imsi_list);
 --  select @recored_count;
   SET @i =0;
   loop_loop: LOOP
     IF @i+1 <= @recored_count THEN
     
       IF @i+2 <= @recored_count THEN
        SET @sql_statement = concat("set @temp_end_date=(select  CREATE_DATE  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i+1,");");
    -- select @sql_statement;
      prepare stmt1 from @sql_statement;
      execute stmt1;
      deallocate prepare stmt1;
      else 
      set @temp_end_date=concat(in_start_date,' 23:59:59');
      end if;
      -- SELECT @i,CAST(@i AS INT);
      -- SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, '",@temp_start_date,"' as start_date,CREATE_DATE as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"' order by CREATE_DATE limit 1 offset ", @i,";");
      SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, CREATE_DATE as start_date,'",@temp_end_date,"' as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"' order by CREATE_DATE limit 1 offset ", @i,";");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
     SET @sql_statement = concat("set @temp_start_date=(select  date_add(CREATE_DATE, interval 1 second)  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i,");");
    -- select @sql_statement;
      prepare stmt1 from @sql_statement;
    execute stmt1;
      deallocate prepare stmt1;
     SET @i = @i + 1;
     -- select @sql_statement ;
       -- select * from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00') limit 1 offset CAST(@i AS INT);
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
  ON (report_metadata.IMSI = cdr_voice_incompleted.CALLEDNUMBER
  or report_metadata.IMSI = cdr_voice_incompleted.CALLINGNUMBER)
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
  ON (report_metadata.IMSI = cdr_voice_completed.CALLEDNUMBER
    or report_metadata.IMSI = cdr_voice_completed.CALLINGNUMBER)
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
  case when CALLDURATION=0  then CALLDURATION else CAST(CALLDURATION/60 AS INT)*60+60 end as 'ANSWER DURATION ROUNDED',
  ANMRECDAT AS 'ORIGINATION DATE',
  concat(MCC,case when CHAR_LENGTH(MNC)=1 then  concat('0',MNC) else MNC end ) AS 'OPERATOR NETWORK',
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
  FROM temp_voice;
--  GROUP BY IMSI,'ANSWER DURATION','ORIGINATION DATE';

END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_voice_report
DROP PROCEDURE IF EXISTS `gm_voice_report`;
DELIMITER //
CREATE PROCEDURE `gm_voice_report`(IN `in_start_date` varchar(50)
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
  ON (report_metadata.IMSI = cdr_voice_incompleted.CALLEDNUMBER
  or report_metadata.IMSI = cdr_voice_incompleted.CALLINGNUMBER)
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
  ON (report_metadata.IMSI = cdr_voice_completed.CALLEDNUMBER
    or report_metadata.IMSI = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_completed.ANMRECDAT) = start_date
  and report_metadata.MNO_ACCOUNTID=in_account_id;
  

  CALL `gm_utility_get__wholesale_plan_history`(in_start_date);

  -- preparing the data from merging the both table complete and incomplete 
  DROP  TEMPORARY TABLE if EXISTS temp_voice;
  CREATE TEMPORARY TABLE temp_voice
  SELECT * FROM temp_voice_complete                         
  UNION ALL 
  SELECT * FROM   temp_voice_incomplete;

  -- final result report of the voice data 
  SELECT 
  temp_voice.ICCID  AS 'ICCID',
  temp_voice.IMSI AS 'IMSI',
  temp_voice.MSISDN AS 'MSISDN',
  -- WHOLESALE_PLAN_ID AS 'ACCOUNT ID',
  COUNTRY_CODE AS 'ACCOUNT ID',
  -- MNO_ACCOUNTID AS 'ACCOUNT ID',
  -- concat(@temp_date ,' - ',date_duration) AS 'BILLING CYCLE DATE',
  '5' AS 'BILLING CYCLE DATE',
  CALLINGNUMBER AS 'CALLING PARTY NUMBER',
  CALLEDNUMBER AS 'CALLED',
  CALLDURATION AS 'ANSWER DURATION',
  case when CALLDURATION=0  then CALLDURATION else CAST(CALLDURATION/60 AS INT)*60 end as 'ANSWER DURATION ROUNDED',
  ANMRECDAT AS 'ORIGINATION DATE',
  concat(MCC,case when CHAR_LENGTH(MNC)=1 then  concat('0',MNC) else MNC end ) AS 'OPERATOR NETWORK',
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
  case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION',
  temp_wholesale_plan_history.plan AS PLAN,
  cdr_voice_tadig_codes.TC_TADIG_CODE as TAP_CODE
  FROM temp_voice
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=temp_voice.IMSI
  and (ANMRECDAT between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)
  left join cdr_voice_tadig_codes on temp_voice.MCC=cdr_voice_tadig_codes.TC_MCC
  and case when CHAR_LENGTH(temp_voice.MNC)=1 then  concat('0',temp_voice.MNC) else temp_voice.MNC end = cdr_voice_tadig_codes.TC_MNC ;
--  GROUP BY IMSI,'ANSWER DURATION','ORIGINATION DATE';
  




END//
DELIMITER ;


-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
