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
  
  -- Description: Utility returns the last executed process report date
  -- **********************************************************************

	-- Declaring the variables 
   DECLARE last_execution_date varchar(255);

	-- Set the variables for the check the data 
	SET @report_id = (SELECT reports.ID FROM reports WHERE NAME = in_report_type limit 1);
   set @temp_node_id = (select GROUP_CONCAT(NODE_ID) from report_mapping where REPORT_ID = @report_id  );
	SET last_execution_date = (SELECT LAST_EXECUTION_TIME FROM report_generation_details WHERE REPORT_ID = @report_id  LIMIT 1);							
	
	-- select last_sanity_date,last_execution_date ,@report_id;
	SET @count_mapping_id = (select COUNT(NODE_ID) from report_mapping 
  								where REPORT_ID = @report_id  );
  								
	-- select @temp_node_id, @COUNT_ID;
	-- checking the last snity date for the last execution date o fthe report   
	SET @count_report_id = (SELECT COUNT(ID)  FROM report_data_details
						WHERE FIND_IN_SET(ID,@temp_node_id) 
						and DATA_PROCESSING_DATE >= DATE(last_execution_date)
						AND  IS_PROCESSED = 1 );
	
	  -- check the condition for the sanity last update report of the data 
	IF(@count_mapping_id = @count_report_id )
	THEN 
		SELECT LAST_EXECUTION_TIME 
		FROM report_generation_details 
		WHERE REPORT_ID = @report_id  LIMIT 1;
	ELSE 
		SELECT 'Data is not available for this report';
	
	END IF;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
