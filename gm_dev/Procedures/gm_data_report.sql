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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
