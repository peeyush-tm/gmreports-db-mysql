/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP PROCEDURE IF EXISTS `gm_data_report_v1`;
DELIMITER //
CREATE PROCEDURE `gm_data_report_v1`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_data_report_rahul_new'
BEGIN
 
  /*DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);
  
   -- SELECT NOW() AS time_1;
     SET start_date:= CAST(in_start_date AS DATEtime);
   

     SET @TEMP_BILLING_CYCLE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - case when YEAR(in_start_date) < year(NOW()) then YEAR(in_start_date) ELSE YEAR(NOW()) END);

  
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  

    */
    
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
-- SELECT NOW() AS time_2;
   
	DROP TABLE IF EXISTS temp_cdr_data_return_table;
    CREATE TEMPORARY TABLE temp_cdr_data_return_table
  SELECT 
  report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
  LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK,
   cdr_data_details_vw.START_TIME AS ORIGINATION_DATE,
   sum(cdr_data_details_vw.UPLINK_BYTES) AS TRANSMIT_BYTE,
   sum(cdr_data_details_vw.DOWNLINK_BYTES) AS RECEIVE_BYTES,
  sum(cdr_data_details_vw.TOTAL_BYTES) AS DATAUSAGE,
  cdr_data_details_vw.APN_ID AS APN,
  cdr_data_details_vw.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
  cdr_data_details_vw.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
  sum(cdr_data_details_vw.DURATION_SEC) AS SESSION_DURATION,
  cdr_data_details_vw.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
    cdr_data_details_vw.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    cdr_data_details_vw.START_TIME AS START_TIME,
   cdr_data_details_vw.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   case when cdr_data_details_vw.RAT_TYPE=1 then '3' when cdr_data_details_vw.RAT_TYPE=6 then '4' when cdr_data_details_vw.RAT_TYPE=2 then '2' else cdr_data_details_vw.RAT_TYPE end  AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details_vw.PGW_ADDRESS AS GGSN_IP_ADDRESS,
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number,
   report_metadata.WHOLE_SALE_NAME AS WHOLE_SALE_NAME,
   report_metadata.ACCOUNT_COUNTRIE AS ACCOUNT_COUNTRIE
   FROM report_metadata
  INNER JOIN cdr_data_details_vw ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
-- LEFT JOIN gm_country_code_mapping ON report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
-- LEFT JOIN temp_wholesale_plan_history ON temp_wholesale_plan_history.IMSI=report_metadata.IMSI 
-- AND (cdr_data_details_vw.START_TIME BETWEEN temp_wholesale_plan_history.start_date AND temp_wholesale_plan_history.end_date)
   WHERE 
   cdr_data_details_vw.STOP_TIME  BETWEEN CAST(CONCAT(in_start_date, ' 00:00:00') AS DATETIME) AND CAST(CONCAT(in_start_date, ' 23:59:59') AS DATETIME)
   and  report_metadata.ENT_ACCOUNTID=in_account_id
  group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID,cdr_data_details_vw.SERVICE_DATA_FLOW_ID;

--  SELECT CONCAT(in_start_date, ' 00:00:00') , CONCAT(in_start_date, ' 23:59:59');
  
  /*
  
  DROP TABLE IF EXISTS temp_cdr_data_return_table;
    CREATE TEMPORARY TABLE temp_cdr_data_return_table
  SELECT 
  report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,

   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
  
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
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number
  from  ((report_metadata
  INNER JOIN cdr_data_details_vw
  ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_data_details_vw.START_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)))
     WHERE 
 --     date(cdr_data_details_vw.STOP_TIME) = date(start_date)
   --  and 
	  report_metadata.ENT_ACCOUNTID=in_account_id LIMIT 10;
 -- group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID,cdr_data_details_vw.SERVICE_DATA_FLOW_ID;
  */
 --  SELECT NOW() AS time_3;
  
  /*
  DROP TABLE IF EXISTS temp_cdr_data_return_table;
    CREATE TEMPORARY TABLE temp_cdr_data_return_table
  SELECT 
  report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,

   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
  
  @TEMP_BILLING_CYCLE AS BILLING_CYCLE_DATE,

  case when temp_wholesale_plan_history.IMSI=report_metadata.IMSI then  temp_wholesale_plan_history.plan ELSE report_metadata.WHOLE_SALE_NAME END AS PLAN,
   cdr_data_details_vw.START_TIME AS ORIGINATION_DATE,
  -- sum(cdr_data_details_vw.UPLINK_BYTES) AS TRANSMIT_BYTE,
 -- sum(cdr_data_details_vw.DOWNLINK_BYTES) AS RECEIVE_BYTES,
 -- sum(cdr_data_details_vw.TOTAL_BYTES) AS DATAUSAGE,
    '43523' AS TRANSMIT_BYTE,
  '5435435' AS RECEIVE_BYTES,
  '5435435' AS DATAUSAGE,
   cdr_data_details_vw.APN_ID AS APN,
  cdr_data_details_vw.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
  LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK,
  
  cdr_data_details_vw.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
 -- sum(cdr_data_details_vw.DURATION_SEC) 
 '5432' AS SESSION_DURATION,
   
  cdr_data_details_vw.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
    cdr_data_details_vw.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    
   cdr_data_details_vw.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   case when cdr_data_details_vw.RAT_TYPE=1 then '3' when cdr_data_details_vw.RAT_TYPE=6 then '4' when cdr_data_details_vw.RAT_TYPE=2 then '2' else cdr_data_details_vw.RAT_TYPE end  AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details_vw.PGW_ADDRESS AS GGSN_IP_ADDRESS,
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number
  from  report_metadata
  INNER JOIN cdr_data_details_vw
  ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_data_details_vw.START_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)
     WHERE 
 --     date(cdr_data_details_vw.STOP_TIME) = date(start_date)
   --  and 
	  report_metadata.ENT_ACCOUNTID=4;
 -- group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID,cdr_data_details_vw.SERVICE_DATA_FLOW_ID;
  
 
 

  SELECT temp_cdr_data_return_table.*,CASE WHEN ICCID IS NULL 
        OR MSISDN IS NULL
                OR IMSI IS NULL
                OR SUPPLIER_ACCOUNT_ID IS NULL
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
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL,
    CEIL(DATAUSAGE/1024) AS DATAUSAGE_RUNDED FROM temp_cdr_data_return_table
   WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
    
    
    */
    
  SELECT `ICCID`,
 `MSISDN`, 
 `IMSI`,
 `SUPPLIER_ACCOUNT_ID`,
 `BILLING_CYCLE_DATE`,
 `PLAN`,
 `ORIGINATION_DATE`,
 `TRANSMIT_BYTE`,
 `RECEIVE_BYTES`,
 `DATAUSAGE`,
 `APN`,
  `DEVICE_IP_ADDRESS`,
  `OPERATOR_NETWORK`, 
  `ORIGINATION_PLAN_DATE`,
  `SESSION_DURATION`, 
  `CALL_TERMINATION_REASON`,
  `RATING_STREAM_ID`,
  `SERVING_SWITCH`,
   `CALL_TECHNOLOGY_TYPE`,
    `GGSN_IP_ADDRESS`, 
	`Record_Sequence_Number`,CASE WHEN ICCID IS NULL 
        OR MSISDN IS NULL
                OR IMSI IS NULL
                OR SUPPLIER_ACCOUNT_ID IS NULL
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
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL,
    CEIL(DATAUSAGE/1024) AS DATAUSAGE_ROUNDED FROM (
	 SELECT temp_cdr_data_return_table.*,
	  gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID,
	   @TEMP_BILLING_CYCLE AS BILLING_CYCLE_DATE, 
		CASE WHEN temp_wholesale_plan_history.IMSI=temp_cdr_data_return_table.IMSI THEN temp_wholesale_plan_history.plan ELSE temp_cdr_data_return_table.WHOLE_SALE_NAME END AS PLAN
 FROM (temp_cdr_data_return_table
    LEFT JOIN gm_country_code_mapping ON temp_cdr_data_return_table.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
    LEFT JOIN temp_wholesale_plan_history ON temp_wholesale_plan_history.IMSI=temp_cdr_data_return_table.IMSI 
 AND (temp_cdr_data_return_table.START_TIME BETWEEN temp_wholesale_plan_history.start_date AND temp_wholesale_plan_history.end_date))
  -- WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
	 )temp_cdr_data_return_table
   WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC; 
    /*
    SET @st1=CONCAT("SELECT temp_cdr_data_return_table.*,CASE WHEN ICCID IS NULL         OR MSISDN IS NULL                OR IMSI IS NULL                OR SUPPLIER_ACCOUNT_ID IS NULL                OR BILLING_CYCLE_DATE IS NULL                OR PLAN IS NULL                OR ORIGINATION_DATE IS NULL                OR TRANSMIT_BYTE IS NULL                OR RECEIVE_BYTES IS NULL                 OR DATAUSAGE IS NULL                OR APN IS NULL                OR DEVICE_IP_ADDRESS IS NULL        OR OPERATOR_NETWORK IS NULL        OR ORIGINATION_PLAN_DATE IS NULL        OR SESSION_DURATION IS NULL        OR CALL_TERMINATION_REASON IS NULL        OR RATING_STREAM_ID IS NULL        OR SERVING_SWITCH IS NULL        OR CALL_TECHNOLOGY_TYPE IS NULL     THEN 1 ELSE 0 END AS MANDATORY_COL_NULL,    CEIL(DATAUSAGE/1024) AS DATAUSAGE_ROUNDED FROM (	 SELECT temp_cdr_data_return_table.*,	  gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID,	   @TEMP_BILLING_CYCLE AS BILLING_CYCLE_DATE, 		CASE WHEN temp_wholesale_plan_history.IMSI=temp_cdr_data_return_table.IMSI THEN temp_wholesale_plan_history.plan ELSE temp_cdr_data_return_table.WHOLE_SALE_NAME END AS PLAN FROM (temp_cdr_data_return_table    LEFT JOIN gm_country_code_mapping ON temp_cdr_data_return_table.ACCOUNT_COUNTRIE=gm_country_code_mapping.account    LEFT JOIN temp_wholesale_plan_history ON temp_wholesale_plan_history.IMSI=temp_cdr_data_return_table.IMSI  AND (temp_cdr_data_return_table.START_TIME BETWEEN temp_wholesale_plan_history.start_date AND temp_wholesale_plan_history.end_date)) )temp_cdr_data_return_table   WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')    ORDER BY MANDATORY_COL_NULL DESC");
    PREPARE stmt FROM @st1;
	 EXECUTE stmt;
	 DEALLOCATE PREPARE stmt;*/
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS `gm_mobile_number_reconciliation_report`;
DELIMITER //
CREATE PROCEDURE `gm_mobile_number_reconciliation_report`(
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_mobile_number_reconciliation_report'
BEGIN
  
  
  
  
  
  
  
  
   


DROP TABLE IF EXISTS temp_mobile_reconciliation_data_return_table;
CREATE TEMPORARY TABLE temp_mobile_reconciliation_data_return_table
SELECT ICCID ,
IMSI ,
MSISDN ,
gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID,
case when (SIM_STATE='Warm' OR SIM_STATE='Activated') AND WHOLE_SALE_NAME LIKE 'GLOBAL_FACTORY%' then 'Shipped'
when (SIM_STATE='Warm' OR SIM_STATE='Activated') AND WHOLE_SALE_NAME LIKE '%FACTORY_RatePlan%' AND WHOLE_SALE_NAME NOT LIKE 'GLOBAL_FACTORY%' then 'UnSoldNew'
when (SIM_STATE='Warm' OR SIM_STATE='Activated') AND WHOLE_SALE_NAME LIKE '%1KB_RatePlan' then 'Subscribed'
when (SIM_STATE !='Warm' OR SIM_STATE !='Activated' OR SIM_STATE='Suspend' OR SIM_STATE='Deactivated' OR SIM_STATE ='NULL') AND (WHOLE_SALE_NAME IS NULL OR WHOLE_SALE_NAME ='' OR WHOLE_SALE_NAME ='NULL') then 'Dormant'
else SIM_STATE end as SIM_STATE_GM,
SIM_STATE as SIM_STATE_GT,

 CASE WHEN WHOLE_SALE_NAME ='null' THEN NULL ELSE WHOLE_SALE_NAME END AS PRICING_PLAN,
0 AS COMMUNCATION_PLAN,
CASE WHEN ACTIVATION_DATE ='null' THEN NULL ELSE ACTIVATION_DATE END AS ICCID_ACTIVATION_DATE,
CASE WHEN BOOTSTRAP_ICCID ='null' THEN NULL ELSE BOOTSTRAP_ICCID END AS BOOTSTRAP_ICCID
FROM report_metadata
left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
where report_metadata.ENT_ACCOUNTID=in_account_id;


DROP TABLE IF EXISTS temp_mobile_reconciliation_data_return_table_new;
CREATE TEMPORARY TABLE temp_mobile_reconciliation_data_return_table_new
SELECT temp_mobile_reconciliation_data_return_table.*,
CASE WHEN `ICCID` IS NULL OR `MSISDN` IS NULL OR `IMSI` IS NULL
OR `SUPPLIER_ACCOUNT_ID` IS NULL OR `SIM_STATE_GT` IS NULL OR `SIM_STATE_GM` IS NULL OR `PRICING_PLAN` IS NULL
OR `COMMUNCATION_PLAN` IS NULL OR `ICCID_ACTIVATION_DATE` IS NULL
THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
FROM temp_mobile_reconciliation_data_return_table ORDER BY MANDATORY_COL_NULL DESC;

UPDATE temp_mobile_reconciliation_data_return_table_new
SET MANDATORY_COL_NULL=0 WHERE UPPER(SIM_STATE_GT) = 'WARM';
SELECT * FROM temp_mobile_reconciliation_data_return_table_new where PRICING_PLAN is not null
ORDER BY MANDATORY_COL_NULL DESC;

END//
DELIMITER ;

DROP PROCEDURE IF EXISTS `gm_sms_delivered_report_v1`;
DELIMITER //
CREATE PROCEDURE `gm_sms_delivered_report_v1`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_sms_delivered_report_rahul_new'
BEGIN
  
  
  
  
  
  
  
  
  
  
  
   
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);
   
  
   SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - case when YEAR(in_start_date) < year(NOW()) then YEAR(in_start_date) ELSE YEAR(NOW()) END);

    
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

  
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  
  
     
      
/*  DROP TABLE IF EXISTS temp_cdr_sms_delivered_return_table;
    CREATE TEMPORARY TABLE temp_cdr_sms_delivered_return_table
    SELECT 
    report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   
   @TEMP_BILLING_CYCLE_DATE AS BILLING_CYCLE_DATE,
   
  cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
  case when temp_wholesale_plan_history.IMSI=report_metadata.IMSI then  temp_wholesale_plan_history.plan ELSE report_metadata.WHOLE_SALE_NAME END AS PLAN,
   
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else NULL end AS SERVING_SWITCH,
  cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
  cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
  LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date))  
   WHERE date(cdr_sms_details.FINAL_TIME)=date(start_date)
  and UPPER(cdr_sms_details.SMS_STATUS) = 'SUCCESS'
  and report_metadata.ENT_ACCOUNTID=in_account_id
    AND case when cdr_sms_details.SMS_TYPE='MO' then length(cdr_sms_details.DESTINATION) = 5
  when cdr_sms_details.SMS_TYPE='MT' then length(cdr_sms_details.SOURCE)=5 END;
*/  
      
/*
  SELECT temp_cdr_sms_delivered_return_table.*,
  CASE WHEN ICCID IS NULL OR MSISDN IS NULL OR IMSI IS NULL OR SUPPLIER_ACCOUNT_ID IS NULL
      OR BILLING_CYCLE_DATE IS NULL OR CALL_DIRECTION IS NULL OR PLAN IS NULL OR ORIGINATION_DATE IS NULL
      OR SERVING_SWITCH IS NULL OR ORIGINATION_ADDRESS IS NULL OR DESTINATION_ADDRESS IS NULL 
            OR OPERATOR_NETWORK IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_cdr_sms_delivered_return_table
    WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
    
    */
    
    
      SELECT 
		`ICCID`,
 `MSISDN`,
 `IMSI`,
 `SUPPLIER_ACCOUNT_ID`,
 `BILLING_CYCLE_DATE`,
 `CALL_DIRECTION`,
 `PLAN`, 
 `ORIGINATION_DATE`,
 `SERVING_SWITCH`,
 `ORIGINATION_ADDRESS`,
 `DESTINATION_ADDRESS`,
 `OPERATOR_NETWORK`,
      CASE WHEN ICCID IS NULL OR MSISDN IS NULL OR IMSI IS NULL OR SUPPLIER_ACCOUNT_ID IS NULL
      OR BILLING_CYCLE_DATE IS NULL OR CALL_DIRECTION IS NULL OR PLAN IS NULL OR ORIGINATION_DATE IS NULL
      OR SERVING_SWITCH IS NULL OR ORIGINATION_ADDRESS IS NULL OR DESTINATION_ADDRESS IS NULL 
            OR OPERATOR_NETWORK IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM (
  
 SELECT 
  temp_cdr_sms_delivered_return_table.*,
   case when temp_wholesale_plan_history.IMSI=temp_cdr_sms_delivered_return_table.IMSI then  temp_wholesale_plan_history.plan ELSE temp_cdr_sms_delivered_return_table.WHOLE_SALE_NAME END AS PLAN
   from
  (
   SELECT 
   cdr_sms_details.ID AS ID,
    report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
  report_metadata.WHOLE_SALE_NAME AS WHOLE_SALE_NAME,
  
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   
   @TEMP_BILLING_CYCLE_DATE AS BILLING_CYCLE_DATE,
   
  cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
  -- case when temp_wholesale_plan_history.IMSI=report_metadata.IMSI then  temp_wholesale_plan_history.plan ELSE report_metadata.WHOLE_SALE_NAME END AS PLAN,
   
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else NULL end AS SERVING_SWITCH,
  cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
  cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
  cdr_sms_details.FINAL_TIME AS FINAL_TIME,
  LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE AND cdr_sms_details.SMS_TYPE='MO'
--  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
 -- left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
 -- and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date))  
  ) WHERE cdr_sms_details.FINAL_TIME BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
  and UPPER(cdr_sms_details.SMS_STATUS) = 'SUCCESS'
  and report_metadata.ENT_ACCOUNTID=in_account_id
    AND case when cdr_sms_details.SMS_TYPE='MO' then length(cdr_sms_details.DESTINATION) = 5
  when cdr_sms_details.SMS_TYPE='MT' then length(cdr_sms_details.SOURCE)=5 END
  UNION ALL 
   SELECT 
      cdr_sms_details.ID AS ID,
    report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
    report_metadata.WHOLE_SALE_NAME AS WHOLE_SALE_NAME,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   
   @TEMP_BILLING_CYCLE_DATE AS BILLING_CYCLE_DATE,
   
  cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
 -- case when temp_wholesale_plan_history.IMSI=report_metadata.IMSI then  temp_wholesale_plan_history.plan ELSE report_metadata.WHOLE_SALE_NAME END AS PLAN,
   
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else NULL end AS SERVING_SWITCH,
  cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
  cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
  cdr_sms_details.FINAL_TIME AS FINAL_TIME,
  LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON
  --  report_metadata.MSISDN = cdr_sms_details.SOURCE 
  -- OR
   report_metadata.MSISDN = cdr_sms_details.DESTINATION AND cdr_sms_details.SMS_TYPE='MT'
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
--  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
--  and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date))  
 )  WHERE cdr_sms_details.FINAL_TIME BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
  and UPPER(cdr_sms_details.SMS_STATUS) = 'SUCCESS'
  and report_metadata.ENT_ACCOUNTID=in_account_id
    AND case when cdr_sms_details.SMS_TYPE='MO' then length(cdr_sms_details.DESTINATION) = 5
  when cdr_sms_details.SMS_TYPE='MT' then length(cdr_sms_details.SOURCE)=5 END
 
  ) temp_cdr_sms_delivered_return_table left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=temp_cdr_sms_delivered_return_table.IMSI
  and (temp_cdr_sms_delivered_return_table.FINAL_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)  
 )temp_cdr_sms_delivered_return_table
    WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    GROUP BY temp_cdr_sms_delivered_return_table.ID
    ORDER BY MANDATORY_COL_NULL DESC;
    
  
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS `gm_truncate_row_data`;
DELIMITER //
CREATE PROCEDURE `gm_truncate_row_data`()
BEGIN

   TRUNCATE TABLE cdr_data_details_vw;
   TRUNCATE TABLE cdr_sms_details;
   TRUNCATE TABLE cdr_voice_completed;
   TRUNCATE TABLE cdr_voice_incompleted;
  -- TRUNCATE TABLE wholesale_plan_history;
 
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS `gm_voice_report_v1`;
DELIMITER //
CREATE PROCEDURE `gm_voice_report_v1`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_voice_report_rahul_new'
BEGIN
 
  
  
  
   
  
  
  
 
  
  
  
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);
  
  

 SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - case when YEAR(in_start_date) < year(NOW()) then YEAR(in_start_date) ELSE YEAR(NOW()) END);
  
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  
   
  
  /*DROP  TEMPORARY TABLE if EXISTS temp_voice_incomplete;
  CREATE TEMPORARY TABLE temp_voice_incomplete*/
/* SELECT 
  report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_incompleted.CALLINGNUMBER,
  cdr_voice_incompleted.CALLEDNUMBER,
  cdr_voice_incompleted.CALLDURATION,
  cdr_voice_incompleted.ANMRECDAT ,
  cdr_voice_incompleted.EVENTSRECD,
  cdr_voice_incompleted.MCC,
  cdr_voice_incompleted.MNC ,
  cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
  cdr_voice_incompleted.MOCALL,
  cdr_voice_incompleted.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER)
 -- or report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_incompleted.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and
   report_metadata.ENT_ACCOUNTID=in_account_id
	UNION all
	 SELECT 
  report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_incompleted.CALLINGNUMBER,
  cdr_voice_incompleted.CALLEDNUMBER,
  cdr_voice_incompleted.CALLDURATION,
  cdr_voice_incompleted.ANMRECDAT ,
  cdr_voice_incompleted.EVENTSRECD,
  cdr_voice_incompleted.MCC,
  cdr_voice_incompleted.MNC ,
  cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
  cdr_voice_incompleted.MOCALL,
  cdr_voice_incompleted.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON -- (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER)
  report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_incompleted.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and
   report_metadata.ENT_ACCOUNTID=in_account_id;
 */
 /* SELECT 
  report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_incompleted.CALLINGNUMBER,
  cdr_voice_incompleted.CALLEDNUMBER,
  cdr_voice_incompleted.CALLDURATION,
  cdr_voice_incompleted.ANMRECDAT ,
  cdr_voice_incompleted.EVENTSRECD,
  cdr_voice_incompleted.MCC,
  cdr_voice_incompleted.MNC ,
  cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
  cdr_voice_incompleted.MOCALL,
  cdr_voice_incompleted.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER
  or report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date
  and report_metadata.ENT_ACCOUNTID=in_account_id;
  */
      
      
    -- SELECT NOW() AS time_0_1;  
  /*
  DROP  TEMPORARY TABLE if EXISTS temp_voice_complete;
  CREATE TEMPORARY TABLE temp_voice_complete
   SELECT report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_completed.CALLINGNUMBER,
  cdr_voice_completed.CALLEDNUMBER,
  cdr_voice_completed.CALLDURATION,
  cdr_voice_completed.ANMRECDAT ,
  cdr_voice_completed.EVENTSRECD ,
  cdr_voice_completed.MCC,
  cdr_voice_completed.MNC ,
  cdr_voice_completed.CAUSEINDCAUSEVALUE,
  cdr_voice_completed.MOCALL,
  cdr_voice_completed.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER)
   -- or report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_completed.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and report_metadata.ENT_ACCOUNTID=in_account_id
	UNION all
	SELECT report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_completed.CALLINGNUMBER,
  cdr_voice_completed.CALLEDNUMBER,
  cdr_voice_completed.CALLDURATION,
  cdr_voice_completed.ANMRECDAT ,
  cdr_voice_completed.EVENTSRECD ,
  cdr_voice_completed.MCC,
  cdr_voice_completed.MNC ,
  cdr_voice_completed.CAUSEINDCAUSEVALUE,
  cdr_voice_completed.MOCALL,
  cdr_voice_completed.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON 
  -- (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER)
   (report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_completed.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and report_metadata.ENT_ACCOUNTID=in_account_id;
  
  */
  /*SELECT report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_completed.CALLINGNUMBER,
  cdr_voice_completed.CALLEDNUMBER,
  cdr_voice_completed.CALLDURATION,
  cdr_voice_completed.ANMRECDAT ,
  cdr_voice_completed.EVENTSRECD ,
  cdr_voice_completed.MCC,
  cdr_voice_completed.MNC ,
  cdr_voice_completed.CAUSEINDCAUSEVALUE,
  cdr_voice_completed.MOCALL,
  cdr_voice_completed.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER
    or report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_completed.ANMRECDAT) = start_date
  and report_metadata.ENT_ACCOUNTID=in_account_id;
  */
-- SELECT NOW() AS time_1;
    
    
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
      AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI
  WHERE temp_first_wholesale_plan_history.CREATE_DATE <= in_end_date;
            
      
  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);
-- SELECT NOW() AS time_2;
  
/*  DROP  TEMPORARY TABLE if EXISTS temp_voice;
  CREATE TEMPORARY TABLE temp_voice
  SELECT * FROM temp_voice_complete                         
  UNION ALL 
  SELECT * FROM   temp_voice_incomplete;
  */
  
  
  /*  DROP  TEMPORARY TABLE if EXISTS temp_voice;
  CREATE TEMPORARY TABLE temp_voice
  SELECT * FROM (SELECT 
  report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_incompleted.CALLINGNUMBER,
  cdr_voice_incompleted.CALLEDNUMBER,
  cdr_voice_incompleted.CALLDURATION,
  cdr_voice_incompleted.ANMRECDAT ,
  cdr_voice_incompleted.EVENTSRECD,
  cdr_voice_incompleted.MCC,
  cdr_voice_incompleted.MNC ,
  cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
  cdr_voice_incompleted.MOCALL,
  cdr_voice_incompleted.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER)
 -- or report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_incompleted.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and
   report_metadata.ENT_ACCOUNTID=in_account_id
	UNION all
	 SELECT 
  report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_incompleted.CALLINGNUMBER,
  cdr_voice_incompleted.CALLEDNUMBER,
  cdr_voice_incompleted.CALLDURATION,
  cdr_voice_incompleted.ANMRECDAT ,
  cdr_voice_incompleted.EVENTSRECD,
  cdr_voice_incompleted.MCC,
  cdr_voice_incompleted.MNC ,
  cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
  cdr_voice_incompleted.MOCALL,
  cdr_voice_incompleted.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON -- (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER)
  report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_incompleted.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and
   report_metadata.ENT_ACCOUNTID=in_account_id)temp_voice_complete                         
  UNION ALL 
  SELECT * FROM   ( SELECT report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_completed.CALLINGNUMBER,
  cdr_voice_completed.CALLEDNUMBER,
  cdr_voice_completed.CALLDURATION,
  cdr_voice_completed.ANMRECDAT ,
  cdr_voice_completed.EVENTSRECD ,
  cdr_voice_completed.MCC,
  cdr_voice_completed.MNC ,
  cdr_voice_completed.CAUSEINDCAUSEVALUE,
  cdr_voice_completed.MOCALL,
  cdr_voice_completed.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER)
   -- or report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_completed.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and report_metadata.ENT_ACCOUNTID=in_account_id
	UNION all
	SELECT report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_completed.CALLINGNUMBER,
  cdr_voice_completed.CALLEDNUMBER,
  cdr_voice_completed.CALLDURATION,
  cdr_voice_completed.ANMRECDAT ,
  cdr_voice_completed.EVENTSRECD ,
  cdr_voice_completed.MCC,
  cdr_voice_completed.MNC ,
  cdr_voice_completed.CAUSEINDCAUSEVALUE,
  cdr_voice_completed.MOCALL,
  cdr_voice_completed.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON 
  -- (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER)
   (report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_completed.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and report_metadata.ENT_ACCOUNTID=in_account_id)temp_voice_incomplete;
  */
--  SELECT NOW() AS time_3;
  
/*  DROP TABLE IF EXISTS temp_voice_data_return_table;
    CREATE TEMPORARY TABLE temp_voice_data_return_table
    SELECT DISTINCT
  temp_voice.ICCID  AS 'ICCID',
  temp_voice.IMSI AS 'IMSI',
  temp_voice.MSISDN AS 'MSISDN',
  
  COUNTRY_CODE AS 'ACCOUNT ID',
  
  @TEMP_BILLING_CYCLE_DATE AS 'BILLING CYCLE DATE',
    
  CALLINGNUMBER AS 'CALLING PARTY NUMBER',
  CALLEDNUMBER AS 'CALLED',
  CALLDURATION AS 'ANSWER DURATION',
  CEILING(CALLDURATION/60) as 'ANSWER DURATION ROUNDED',
 
  ANMRECDAT AS 'ORIGINATION DATE',
    LEFT(MSISDN,6) AS 'OPERATOR NETWORK',
  
  
  case when MOCALL=0 OR MOCALL IS NULL 
      then LASTERBCSM
       when MOCALL=1 
      then COALESCE(LASTERBCSM,0)
  end AS 'CALL TERMINATION REASON',
  1 as 'CALL TYPE',
  case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION',
 case when temp_wholesale_plan_history.IMSI=temp_voice.IMSI then  temp_wholesale_plan_history.plan ELSE temp_voice.WHOLE_SALE_NAME END AS PLAN,
  cdr_voice_tadig_codes.TC_TADIG_CODE as TAP_CODE
  FROM temp_voice
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=temp_voice.IMSI
  and (ANMRECDAT between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)
  left join cdr_voice_tadig_codes on temp_voice.MCC=cdr_voice_tadig_codes.TC_MCC
  and case when CHAR_LENGTH(temp_voice.MNC)=1 then  concat('0',temp_voice.MNC) else temp_voice.MNC END = case when CHAR_LENGTH(cdr_voice_tadig_codes.TC_MNC)=1 then  concat('0',cdr_voice_tadig_codes.TC_MNC) else cdr_voice_tadig_codes.TC_MNC end ;

*/


--  CREATE TEMPORARY TABLE temp_voice_data_return_table
    SELECT temp_voice_data_return_table.*,CASE WHEN ICCID IS NULL OR IMSI IS NULL OR MSISDN IS NULL OR `ACCOUNT ID` IS NULL OR `BILLING CYCLE DATE` IS NULL
    OR `CALLING PARTY NUMBER` IS NULL OR `CALLED` IS NULL OR `ANSWER DURATION` IS NULL OR `ANSWER DURATION ROUNDED` IS NULL 
        OR `ORIGINATION DATE` IS NULL OR `OPERATOR NETWORK` IS NULL OR `CALL TERMINATION REASON` IS NULL OR `CALL TYPE` IS NULL
    OR `CALL DIRECTION` IS NULL OR PLAN IS NULL OR TAP_CODE IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM (
	SELECT DISTINCT
  temp_voice.ICCID  AS 'ICCID',
  temp_voice.IMSI AS 'IMSI',
  temp_voice.MSISDN AS 'MSISDN',
  
  COUNTRY_CODE AS 'ACCOUNT ID',
  
  @TEMP_BILLING_CYCLE_DATE AS 'BILLING CYCLE DATE',
    
  CALLINGNUMBER AS 'CALLING PARTY NUMBER',
  CALLEDNUMBER AS 'CALLED',
  CALLDURATION AS 'ANSWER DURATION',
  CEILING(CALLDURATION/60) as 'ANSWER DURATION ROUNDED',
 
  ANMRECDAT AS 'ORIGINATION DATE',
    LEFT(MSISDN,6) AS 'OPERATOR NETWORK',
  
  
  case when MOCALL=0 OR MOCALL IS NULL 
      then LASTERBCSM
       when MOCALL=1 
      then COALESCE(LASTERBCSM,0)
  end AS 'CALL TERMINATION REASON',
  1 as 'CALL TYPE',
  case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION',
 case when temp_wholesale_plan_history.IMSI=temp_voice.IMSI then  temp_wholesale_plan_history.plan ELSE temp_voice.WHOLE_SALE_NAME END AS PLAN,
  cdr_voice_tadig_codes.TC_TADIG_CODE as TAP_CODE
  FROM ( SELECT * FROM (SELECT 
  report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_incompleted.CALLINGNUMBER,
  cdr_voice_incompleted.CALLEDNUMBER,
  cdr_voice_incompleted.CALLDURATION,
  cdr_voice_incompleted.ANMRECDAT ,
  cdr_voice_incompleted.EVENTSRECD,
  cdr_voice_incompleted.MCC,
  cdr_voice_incompleted.MNC ,
  cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
  cdr_voice_incompleted.MOCALL,
  cdr_voice_incompleted.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER)
 -- or report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_incompleted.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and
   report_metadata.ENT_ACCOUNTID=in_account_id
	UNION all
	 SELECT 
  report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_incompleted.CALLINGNUMBER,
  cdr_voice_incompleted.CALLEDNUMBER,
  cdr_voice_incompleted.CALLDURATION,
  cdr_voice_incompleted.ANMRECDAT ,
  cdr_voice_incompleted.EVENTSRECD,
  cdr_voice_incompleted.MCC,
  cdr_voice_incompleted.MNC ,
  cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
  cdr_voice_incompleted.MOCALL,
  cdr_voice_incompleted.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON -- (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER)
  report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_incompleted.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and
   report_metadata.ENT_ACCOUNTID=in_account_id)temp_voice_complete                         
  UNION ALL 
  SELECT * FROM   ( SELECT report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_completed.CALLINGNUMBER,
  cdr_voice_completed.CALLEDNUMBER,
  cdr_voice_completed.CALLDURATION,
  cdr_voice_completed.ANMRECDAT ,
  cdr_voice_completed.EVENTSRECD ,
  cdr_voice_completed.MCC,
  cdr_voice_completed.MNC ,
  cdr_voice_completed.CAUSEINDCAUSEVALUE,
  cdr_voice_completed.MOCALL,
  cdr_voice_completed.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER)
   -- or report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_completed.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and report_metadata.ENT_ACCOUNTID=in_account_id
	UNION all
	SELECT report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_completed.CALLINGNUMBER,
  cdr_voice_completed.CALLEDNUMBER,
  cdr_voice_completed.CALLDURATION,
  cdr_voice_completed.ANMRECDAT ,
  cdr_voice_completed.EVENTSRECD ,
  cdr_voice_completed.MCC,
  cdr_voice_completed.MNC ,
  cdr_voice_completed.CAUSEINDCAUSEVALUE,
  cdr_voice_completed.MOCALL,
  cdr_voice_completed.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON 
  -- (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER)
   (report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE cdr_voice_completed.ANMRECDAT  BETWEEN CONCAT(in_start_date, ' 00:00:00') AND CONCAT(in_start_date, ' 23:59:59')
   and report_metadata.ENT_ACCOUNTID=in_account_id)temp_voice_incomplete)temp_voice
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=temp_voice.IMSI
  and (ANMRECDAT between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)
  left join cdr_voice_tadig_codes on temp_voice.MCC=cdr_voice_tadig_codes.TC_MCC
  and case when CHAR_LENGTH(temp_voice.MNC)=1 then  concat('0',temp_voice.MNC) else temp_voice.MNC END = case when CHAR_LENGTH(cdr_voice_tadig_codes.TC_MNC)=1 then  concat('0',cdr_voice_tadig_codes.TC_MNC) else cdr_voice_tadig_codes.TC_MNC end 
  )temp_voice_data_return_table 
  WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
  ORDER BY MANDATORY_COL_NULL DESC;


-- SELECT NOW() AS time_4;
  /*
   
  SELECT temp_voice_data_return_table.*,CASE WHEN ICCID IS NULL OR IMSI IS NULL OR MSISDN IS NULL OR `ACCOUNT ID` IS NULL OR `BILLING CYCLE DATE` IS NULL
    OR `CALLING PARTY NUMBER` IS NULL OR `CALLED` IS NULL OR `ANSWER DURATION` IS NULL OR `ANSWER DURATION ROUNDED` IS NULL 
        OR `ORIGINATION DATE` IS NULL OR `OPERATOR NETWORK` IS NULL OR `CALL TERMINATION REASON` IS NULL OR `CALL TYPE` IS NULL
    OR `CALL DIRECTION` IS NULL OR PLAN IS NULL OR TAP_CODE IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_voice_data_return_table 
  WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
  ORDER BY MANDATORY_COL_NULL DESC;

*/

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
