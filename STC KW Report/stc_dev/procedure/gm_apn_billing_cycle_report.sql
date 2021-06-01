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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
