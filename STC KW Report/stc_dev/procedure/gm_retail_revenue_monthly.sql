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

-- Dumping structure for procedure stc_report.gm_retail_revenue_monthly
DROP PROCEDURE IF EXISTS `gm_retail_revenue_monthly`;
DELIMITER //
CREATE PROCEDURE `gm_retail_revenue_monthly`(
  IN `in_start_date` VARCHAR(50),
  IN `in_end_date` VARCHAR(50),
  IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_retail_revenue_monthly'
BEGIN
  
  
  
  
  
  
  
  
  

  


  
  DECLARE start_date varchar(50);
  DECLARE end_date varchar(50);
  
  
   SET start_date:= CAST(in_start_date AS DATETIME);
   SET end_date:= CAST(in_end_date AS DATETIME);
  
  

  
  SELECT 
  
  report_metadata.MSISDN AS 'MSISDN',
  report_metadata.ICCID AS 'ICCID',
  
  gm_country_code_mapping.country_Code AS 'SUPPLIER ACCOUNT ID' ,
  
  '5' AS 'BILLING CYCLE DATE',
  retail_revenue_share.START_DATE AS 'START DATE',
  retail_revenue_share.DATA_USED AS 'DATA USED',
  retail_revenue_share.CREDIT_AMOUNT AS 'CREDIT AMOUNT',
  
  
    plan.plan_name AS 'PACKAGE NAME',
  retail_revenue_share.ORDER_ID AS 'ORDER ID',
  retail_revenue_share.UUID_IMSI AS 'UUID IMSI',
  report_metadata.IMSI AS 'IMSI'
  FROM retail_revenue_share 
  INNER JOIN report_metadata
  on report_metadata.IMSI = retail_revenue_share.IMSI
  INNER JOIN plan ON plan.bss_plan_id=retail_revenue_share.PACKAGE_CODE
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE report_metadata.MNO_ACCOUNTID=in_account_id and (date(START_DATE) BETWEEN  start_date AND end_date)
  GROUP BY date(START_DATE);

  


END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
