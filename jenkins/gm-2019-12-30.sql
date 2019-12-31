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

-- Dumping structure for procedure gm_reports.gm_data_report
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
	WHERE date(cdr_data_details.STOP_TIME) = date(start_date)
	group by cdr_data_details.SERVED_IMSI, pgw_svc_data.CHARGING_ID;


END//
DELIMITER ;

-- Dumping structure for procedure gm_reports.gm_sms_delivered_report
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
	ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
	OR report_metadata.MSISDN = cdr_sms_details.DESTINATION)	
   WHERE date(cdr_sms_details.FINAL_TIME)=start_date
	and cdr_sms_details.SMS_STATUS = 'Success'
	GROUP BY IMSI,MSISDN ,CALL_DIRECTION ,ORIGINATION_DATE ;


END//
DELIMITER ;

-- Dumping structure for procedure gm_reports.gm_sms_undelivered_report
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
	cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
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
	ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
	OR report_metadata.MSISDN = cdr_sms_details.DESTINATION)	
   WHERE date(cdr_sms_details.FINAL_TIME)=start_date
   and cdr_sms_details.SMS_STATUS ='Failed'
   GROUP BY IMSI,MSISDN ,CALL_DIRECTION ,  ORIGINATION_DATE ;
   
END//
DELIMITER ;

-- Dumping structure for procedure gm_reports.gm_voice_report
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
	ON report_metadata.IMSI = cdr_voice_incompleted.CALLEDNUMBER
	WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date;
	    
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
	ON report_metadata.IMSI = cdr_voice_completed.CALLEDNUMBER
	WHERE date(cdr_voice_completed.ANMRECDAT) = start_date;

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
	FROM temp_voice
	GROUP BY IMSI,'ANSWER DURATION','ORIGINATION DATE';

END//
DELIMITER ;





ALTER TABLE cdr_voice_incompleted ADD INDEX ANMRECDAT (ANMRECDAT);

ALTER TABLE cdr_voice_incompleted ADD INDEX CALLEDNUMBER (CALLEDNUMBER(255));

ALTER TABLE cdr_voice_completed ADD INDEX ANMRECDAT (ANMRECDAT);

ALTER TABLE cdr_voice_completed ADD INDEX CALLEDNUMBER (CALLEDNUMBER(255));


/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
