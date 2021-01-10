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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
