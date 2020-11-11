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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
