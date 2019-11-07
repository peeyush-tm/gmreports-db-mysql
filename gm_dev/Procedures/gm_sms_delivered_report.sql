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

-- Dumping structure for procedure gm_sms_delivered_report
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
