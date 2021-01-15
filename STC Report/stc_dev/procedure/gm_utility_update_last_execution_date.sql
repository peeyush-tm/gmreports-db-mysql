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

-- Dumping structure for procedure stc_report.gm_utility_update_last_execution_date
DROP PROCEDURE IF EXISTS `gm_utility_update_last_execution_date`;
DELIMITER //
CREATE PROCEDURE `gm_utility_update_last_execution_date`(
	IN `in_report_type` varchar(100),
	IN `in_last_executed_date` varchar(50)

,
	IN `in_path` TEXT






)
BEGIN
 
  
  
  
  
  
  

	
	UPDATE report_generation_details
	INNER JOIN reports 
	ON report_generation_details.report_id = reports.ID
	SET LAST_EXECUTION_TIME = in_last_executed_date,
	REPORT_FILE_PATH = in_path
	WHERE  
	reports.NAME = in_report_type;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
