-- --------------------------------------------------------
-- Host:                         192.168.1.231
-- Server version:               5.7.27 - MySQL Community Server (GPL)
-- Server OS:                    linux-glibc2.12
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
