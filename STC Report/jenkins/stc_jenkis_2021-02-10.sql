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

-- Dumping structure for procedure stc_report.gm_data_report
DROP PROCEDURE IF EXISTS `gm_data_report`;
DELIMITER //
CREATE PROCEDURE `gm_data_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_data_report_new'
BEGIN
 
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);
  
   
   SET start_date:= CAST(in_start_date AS DATEtime);
   
  SET @TEMP_BILLING_CYCLE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - YEAR(NOW()));

  
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  

    
    
  SET @row_number = 0;
  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

  
  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

  
  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
    
  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
  
    
  DROP TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE temp_wholesale_plan_history
  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
      COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
      COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
      COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
  FROM temp_first_wholesale_plan_history 
  LEFT JOIN temp_second_wholesale_plan_history
    ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
      AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI;
            
      
  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

  
  DROP TABLE IF EXISTS temp_cdr_data_return_table;
    CREATE TEMPORARY TABLE temp_cdr_data_return_table
  SELECT 
  report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
  report_metadata.ACCOUNT_NOTES AS CONTRACT_ID,

  -- gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
  
  @TEMP_BILLING_CYCLE AS BILLING_CYCLE_DATE,

  case when temp_wholesale_plan_history.IMSI=report_metadata.IMSI then  temp_wholesale_plan_history.plan ELSE report_metadata.WHOLE_SALE_NAME END AS PLAN,
   cdr_data_details_vw.START_TIME AS ORIGINATION_DATE,
   sum(cdr_data_details_vw.UPLINK_BYTES) AS TRANSMIT_BYTE,
   sum(cdr_data_details_vw.DOWNLINK_BYTES) AS RECEIVE_BYTES,
  sum(cdr_data_details_vw.TOTAL_BYTES) AS DATAUSAGE,
  
   cdr_data_details_vw.APN_ID AS APN,
  cdr_data_details_vw.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
  LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK,
  
  cdr_data_details_vw.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
  sum(cdr_data_details_vw.DURATION_SEC) AS SESSION_DURATION,
   
  cdr_data_details_vw.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
    cdr_data_details_vw.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    
   cdr_data_details_vw.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   case when cdr_data_details_vw.RAT_TYPE=1 then '3' when cdr_data_details_vw.RAT_TYPE=6 then '4' when cdr_data_details_vw.RAT_TYPE=2 then '2' else cdr_data_details_vw.RAT_TYPE end  AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details_vw.PGW_ADDRESS AS GGSN_IP_ADDRESS,
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number,
   -- concat(cdr_data_details_vw.ULI_MCC,cdr_data_details_vw.ULI_MNC) AS PLNMID
   CASE when CHAR_LENGTH(cdr_data_details_vw.ULI_MNC)=1 then CONCAT(cdr_data_details_vw.ULI_MCC,'0',cdr_data_details_vw.ULI_MNC) ELSE CONCAT(cdr_data_details_vw.ULI_MCC,cdr_data_details_vw.ULI_MNC) END AS PLNMID
  from  ((report_metadata
  INNER JOIN cdr_data_details_vw
  ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_data_details_vw.START_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)))
     WHERE 
      date(cdr_data_details_vw.START_TIME) = date(start_date)
  group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID,cdr_data_details_vw.SERVICE_DATA_FLOW_ID;


  SELECT temp_cdr_data_return_table.*,CASE WHEN ICCID IS NULL 
        OR MSISDN IS NULL
                OR IMSI IS NULL
                OR BILLING_CYCLE_DATE IS NULL
                OR PLAN IS NULL
                OR ORIGINATION_DATE IS NULL
                OR TRANSMIT_BYTE IS NULL
                OR RECEIVE_BYTES IS NULL 
                OR DATAUSAGE IS NULL
                OR APN IS NULL
                OR DEVICE_IP_ADDRESS IS NULL
        OR OPERATOR_NETWORK IS NULL
        OR ORIGINATION_PLAN_DATE IS NULL
        OR SESSION_DURATION IS NULL
        OR CALL_TERMINATION_REASON IS NULL
        OR RATING_STREAM_ID IS NULL
        OR SERVING_SWITCH IS NULL
        OR CALL_TECHNOLOGY_TYPE IS NULL
		  OR PLNMID IS NULL 
		  OR CONTRACT_ID IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL,
    CEIL(DATAUSAGE/1024) AS DATAUSAGE_ROUNDED FROM temp_cdr_data_return_table
   WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
