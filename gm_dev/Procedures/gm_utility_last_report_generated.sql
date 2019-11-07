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

-- Dumping structure for procedure gm_utility_last_report_generated
DROP PROCEDURE IF EXISTS `gm_utility_last_report_generated`;
DELIMITER //
CREATE  PROCEDURE `gm_utility_last_report_generated`(
	IN `in_report_type` VARCHAR(50),
	IN `in_report_date` varchar(50)

)
    COMMENT 'return the date of last report generated '
BEGIN
  -- **********************************************************************
  -- Procedure: gm_utility_last_report_generated
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Description: Utility returns the last executed process report 
  -- **********************************************************************

	DECLARE last_sanity_date varchar(255);
   DECLARE last_execution_date varchar(255);
   
	SET last_sanity_date= (SELECT data_processing_date FROM report_data_details where data_node =in_report_type  LIMIT 1);
	SET last_execution_date = (SELECT last_execution_time FROM report_genration_details where report_id = 1  LIMIT 1);
    
	IF(last_execution_date <= last_sanity_date)
	THEN 
	SELECT max(last_execution_time) as Last_Report_date
	FROM 
	report_genration_details
	INNER JOIN report_data_details 
	ON (report_data_details.id = report_genration_details.report_id)
	WHERE report_data_details.data_node =  in_report_type
    AND report_data_details.is_processed = 1
	GROUP BY (report_id);
    ELSE
		select "wrong date selection ";
    END IF;


END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
