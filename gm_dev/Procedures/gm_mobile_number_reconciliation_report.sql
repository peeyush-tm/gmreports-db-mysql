-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure gm_reports.gm_mobile_number_reconciliation_report
DELIMITER //
CREATE  PROCEDURE `gm_mobile_number_reconciliation_report`(IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_mobile_number_reconciliation_report'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_mobile_number_reconciliation_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
  
  -- Output : Returns the updated status of the mobile report
  -- Description: Procedure is use to generate the Mobile Number Reconciliation  report according to the creation date  
  --  *****************************************************************************************************
   
  -- prepare the data from the updated meta data tables of gc data
    SELECT ICCID ,
    MSISDN , 
    IMSI ,
    gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID,
    SIM_STATE as SIM_STATE_GT,
    case when SIM_STATE='Warm' then 'Device Shipped'
	 when SIM_STATE='' or SIM_STATE is null then 'UnSoldNewVehicle' 
	 when SIM_STATE='Active' then 'Subscribed' 
	 when SIM_STATE='Suspend' then 'Dormant' 
	 else SIM_STATE end as SIM_STATE_GM,
    RATE_PLAN_NAME AS PRICING_PLAN,
    RATE_PLAN_NAME AS COMMUNCATION_PLAN,
    ACTIVATION_DATE AS ICCID_ACTIVATION_DATE,
    ICCID as BOOTSTRAP_ICCID
    FROM report_metadata
	 left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	 where report_metadata.MNO_ACCOUNTID=in_account_id;
	 

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
