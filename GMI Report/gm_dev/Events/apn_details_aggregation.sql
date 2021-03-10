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

-- Dumping structure for event gm_reports.apn_details_aggregation
DROP EVENT IF EXISTS `apn_details_aggregation`;
DELIMITER //
CREATE  EVENT `apn_details_aggregation` ON SCHEDULE EVERY 1 DAY STARTS '2019-11-26 23:59:59' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'apn_details_aggregation' DO BEGIN
-- **********************************************************************
  -- Procedure: apn_details_aggregation
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
   
  -- Description: Event is used to generat the aggregation on daily
  --  basis interval  
  -- **********************************************************************

	-- call the utility to generate the data monthly 
   CALL `gm_utility_apn_aggregation_monthly`(CURRENT_DATE());

 	
	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
