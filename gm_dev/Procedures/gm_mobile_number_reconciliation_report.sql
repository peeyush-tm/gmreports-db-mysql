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

-- Dumping structure for procedure gm_mobile_number_reconciliation_report
DROP PROCEDURE IF EXISTS `gm_mobile_number_reconciliation_report`;
DELIMITER //
CREATE  PROCEDURE `gm_mobile_number_reconciliation_report`()
    COMMENT 'gm_mobile_number_reconciliation_report'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_mobile_number_reconciliation_report
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
  
  -- Output : Returns the updated status of the mobile report
  -- Description: Procedure is use to generate the Mobile Number Reconciliation  report according to the creation date  
  --  *****************************************************************************************************
   
  -- prepare the data from the updated meta data tables of gc data
    SELECT ICCID ,
    MSISDN , 
    IMSI ,
    ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID,
    SIM_STATE ,
    RATE_PLAN_NAME AS PLAN,
    ACTIVATION_DATE AS ICCID_ACTIVATION_DATE
    FROM report_metadata;
	 

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
