USE gm_reports;

set sql_safe_updates=0;
UPDATE gm_country_code_mapping SET account = 'Kuwait' where country_code = 9;

DROP PROCEDURE IF EXISTS gm_sms_undelivered_report;

DELIMITER $$
CREATE  PROCEDURE `gm_sms_undelivered_report`(IN in_start_date varchar(50), IN in_end_date varchar(50)
, IN in_account_id VARCHAR(50))
    COMMENT 'gm_sms_undelivered_report_new'
BEGIN
  
  
  
  
  
  
  
  
  
  

   
   DECLARE date_duration VARCHAR(50);
   DECLARE start_date VARCHAR(50);

    SET start_date:= CAST(in_start_date AS date);
    
  SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-2020);
   
    
    
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
   
  
  
   DROP TABLE IF EXISTS temp_cdr_sms_undelivered_return_table;
   CREATE TEMPORARY TABLE temp_cdr_sms_undelivered_return_table
   SELECT 
  report_metadata.ICCID as ICCID,
  report_metadata.MSISDN as MSISDN,
  report_metadata.IMSI as IMSI,
 

   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   
  @TEMP_BILLING_CYCLE_DATE AS BILLING_CYCLE_DATE,
  cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
  
  temp_wholesale_plan_history.plan AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else NULL end AS SERVING_SWITCH,
    cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
  cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
    
  
    LEFT(report_metadata.MSISDN,6) as OPERATOR_NETWORK,
    CASE WHEN cdr_sms_details.REASON IN ('null','NULL') OR cdr_sms_details.REASON IS NULL THEN 6 ELSE REASON END AS CALL_TERMINATIONS_REASON
   -- cdr_sms_details.REASON AS CALL_TERMINATIONS_REASON
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_Date and temp_wholesale_plan_history.end_date))  
   WHERE date(cdr_sms_details.FINAL_TIME)=start_date
   and UPPER(cdr_sms_details.SMS_STATUS) NOT IN ('SUCCESS')
   and report_metadata.ENT_ACCOUNTID=in_account_id
   AND case when cdr_sms_details.SMS_TYPE='MO' then length(cdr_sms_details.DESTINATION) = 5
  when cdr_sms_details.SMS_TYPE='MT' then length(cdr_sms_details.SOURCE)=5 END;
  
    
  SELECT temp_cdr_sms_undelivered_return_table.*,
  CASE WHEN ICCID IS NULL OR MSISDN IS NULL OR IMSI IS NULL OR SUPPLIER_ACCOUNT_ID IS NULL
      OR BILLING_CYCLE_DATE IS NULL OR CALL_DIRECTION IS NULL OR PLAN IS NULL OR ORIGINATION_DATE IS NULL
      OR SERVING_SWITCH IS NULL OR ORIGINATION_ADDRESS IS NULL OR DESTINATION_ADDRESS IS NULL 
            OR OPERATOR_NETWORK IS NULL OR CALL_TERMINATIONS_REASON IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_cdr_sms_undelivered_return_table
  WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
   
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS gm_mobile_number_reconciliation_report;
DELIMITER $$
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
  case when SIM_STATE='Warm' then 'Shipped'
   when SIM_STATE='' or SIM_STATE is NULL or SIM_STATE ='NULL'  then 'UnSoldNew' 
   when SIM_STATE='Active' then 'Subscribed' 
   when SIM_STATE='Suspend' then 'Dormant' 
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
      OR `COMMUNCATION_PLAN` IS NULL OR `ICCID_ACTIVATION_DATE` IS NULL OR `BOOTSTRAP_ICCID` IS NULL
      THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_mobile_reconciliation_data_return_table ORDER BY MANDATORY_COL_NULL DESC;
  
  
	UPDATE temp_mobile_reconciliation_data_return_table_new
    SET MANDATORY_COL_NULL=0 WHERE UPPER(SIM_STATE_GT) = 'WARM';
	
    SELECT * FROM temp_mobile_reconciliation_data_return_table_new
    ORDER BY MANDATORY_COL_NULL DESC;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS gm_data_report;
DELIMITER $$
CREATE PROCEDURE `gm_data_report`(
  IN `in_start_date` varchar(50),
  IN `in_end_date` varchar(50),
  IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_data_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_data_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
   -- Modified by : Rahul Panwar
  -- Date: JUne, 2020 
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is used to returns cdr data on the basis of 
  -- the served imsi and STOP_TIME
  
  -- Description: Procedure returns the report genarted 
  -- **********************************************************************

  -- Declaration of the variables 
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);
  
   -- typecasting for start_date
   SET start_date:= CAST(in_start_date AS DATEtime);
   
  SET @TEMP_BILLING_CYCLE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - 2020);

  -- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  -- select concat(@temp_date ,' - ',date_duration);

    -- setting the row number to 0
    -- creating the wholesale table
  SET @row_number = 0;
  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

  -- creating the wholesale table with id - 1
  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

  -- adding index on temporary wholesale table
  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
    -- adding index on temporary wholesale table
  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
  
    -- creating the temp complete wholesale table
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
            
      -- creating index on imsi column of wholesale table
  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

  -- storing the value for checking the case of null or empty value
  DROP TABLE IF EXISTS temp_cdr_data_return_table;
    CREATE TEMPORARY TABLE temp_cdr_data_return_table
  SELECT 
  report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
--  report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
  -- concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
  @TEMP_BILLING_CYCLE AS BILLING_CYCLE_DATE,
--  report_metadata.WHOLE_SALE_NAME AS PLAN,
  temp_wholesale_plan_history.plan AS PLAN,
   cdr_data_details_vw.START_TIME AS ORIGINATION_DATE,
   sum(cdr_data_details_vw.UPLINK_BYTES) AS TRANSMIT_BYTE,
   sum(cdr_data_details_vw.DOWNLINK_BYTES) AS RECEIVE_BYTES,
  sum(cdr_data_details_vw.TOTAL_BYTES) AS DATAUSAGE,
  -- sum(cdr_data_details_vw.TOTAL_BYTES * rounded_config ) AS DATAUSAGE_ROUNDING,
   cdr_data_details_vw.APN_ID AS APN,
  cdr_data_details_vw.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
  LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK,
  -- concat(cdr_data_details_vw.ULI_MCC,case when CHAR_LENGTH(cdr_data_details_vw.ULI_MNC)=1 then  concat('0',cdr_data_details_vw.ULI_MNC) else cdr_data_details_vw.ULI_MNC end ) AS OPERATOR_NETWORK,
  cdr_data_details_vw.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
  sum(cdr_data_details_vw.DURATION_SEC) AS SESSION_DURATION,
   -- pgw_svc_data.SERVICE_DATA_FLOW_ID  ,
  cdr_data_details_vw.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
    cdr_data_details_vw.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    -- 6 PARAMTER MISING     
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
      date(cdr_data_details_vw.STOP_TIME) = date(start_date)
     and report_metadata.ENT_ACCOUNTID=in_account_id
  group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID,cdr_data_details_vw.SERVICE_DATA_FLOW_ID;


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
    CEIL(DATAUSAGE/1024) AS DATAUSAGE_ROUNDED FROM temp_cdr_data_return_table
   WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
END$$
DELIMITER ;
