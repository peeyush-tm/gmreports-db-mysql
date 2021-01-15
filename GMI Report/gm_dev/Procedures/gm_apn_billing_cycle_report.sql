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

-- Dumping structure for procedure gm_apn_billing_cycle_report
DROP PROCEDURE IF EXISTS `gm_apn_billing_cycle_report`;
DELIMITER //
CREATE  PROCEDURE `gm_apn_billing_cycle_report`(
	IN `in_start_date` VARCHAR(50),
	IN `in_end_date` VARCHAR(50)







)
    COMMENT 'gm_apn_billing_cycle_report'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_apn_billing_cycle_report
  -- Author: Parul Shrivastava
  -- Date: Nov 21, 2019
  -- Description: Procedure is returned  the prepared data from the table 
  
  -- Input paramter: in_start_date,in_end_date
  -- Output : procedure is used to return the total usage on the basis of the
  --          served imsi and served_flow_id

  -- **********************************************************************

	-- Declaration of the variables 
	DECLARE start_date varchar(50);
	DECLARE end_date varchar(50);
	
	-- consersion of date to datetime
   SET start_date:= CAST(in_start_date AS DATEtime);
   SET end_date:= CAST(in_end_date AS DATEtime);
	
	-- Preparing the query for fetching the data for the APN billing report 
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
