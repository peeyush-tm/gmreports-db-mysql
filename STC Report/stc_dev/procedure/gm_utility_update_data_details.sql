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

-- Dumping structure for procedure stc_report.gm_utility_update_data_details
DROP PROCEDURE IF EXISTS `gm_utility_update_data_details`;
DELIMITER //
CREATE PROCEDURE `gm_utility_update_data_details`(
	IN `in_data_node` varchar(100),
	IN `in_isprocess_value` int(10)



)
BEGIN
  
  
  
  
  
  
  
	
   
    IF (in_data_node = 'SMS')
    THEN
		UPDATE report_data_details
		SET DATA_PROCESSING_DATE =current_timestamp,
		IS_PROCESSED = in_isprocess_value
		WHERE DATA_NODE = 'SMS(Delivered)'
		OR DATA_NODE = 'SMS(Undelivered)'
		;
    ELSE
		
		UPDATE report_data_details
		SET DATA_PROCESSING_DATE = current_timestamp(),
		IS_PROCESSED = in_isprocess_value
		where DATA_NODE = in_data_node;
    
    END IF;
    

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
