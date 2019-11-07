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

-- Dumping structure for procedure gm_data_report
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
