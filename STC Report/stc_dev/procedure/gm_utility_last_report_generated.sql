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

-- Dumping structure for procedure stc_report.gm_utility_last_report_generated
DROP PROCEDURE IF EXISTS `gm_utility_last_report_generated`;
DELIMITER //
CREATE PROCEDURE `gm_utility_last_report_generated`(
	IN `in_report_type` VARCHAR(250),
	IN `in_report_date` varchar(50)
)
    COMMENT 'return the date of last report generated '
BEGIN
  
  
  
  
  
  
  

	
	SET @report_id = (SELECT reports.ID FROM reports WHERE NAME = in_report_type limit 1); 
	SELECT LAST_EXECUTION_TIME 
	FROM report_generation_details 
	WHERE REPORT_ID = @report_id  LIMIT 1;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
