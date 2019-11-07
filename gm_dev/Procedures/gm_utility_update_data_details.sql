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

-- Dumping structure for procedure gm_utility_update_data_details
DROP PROCEDURE IF EXISTS `gm_utility_update_data_details`;
DELIMITER //
CREATE  PROCEDURE `gm_utility_update_data_details`(
IN `in_data_node` varchar(100),
IN `in_isprocess_value` int(10))
BEGIN
  -- **********************************************************************
  -- Procedure: gm_utility_update_data_details
  -- Author: Parul Shrivastava
  -- Date: Nov 4, 2019
  
  -- Description: Utility to update the data_details values according to filters 
  -- **********************************************************************
	
    IF (in_data_node = 'SMS')
    THEN
		update report_data_details
		set data_processing_date =current_timestamp,
		is_processed = in_isprocess_value
		where data_node = 'SMS(Delivered)'
		or data_node = 'SMS(Undelivered)'
		;
    else
		update report_data_details
		set data_processing_date =current_timestamp(),
		is_processed = in_isprocess_value
		where data_node = in_data_node;
    
    END IF;
    

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
