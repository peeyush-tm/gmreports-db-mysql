USE gm_reports;

DROP PROCEDURE IF EXISTS gm_mobile_number_reconciliation_report;

DELIMITER $$
CREATE  PROCEDURE `gm_mobile_number_reconciliation_report`(
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
      OR `COMMUNCATION_PLAN` IS NULL OR `ICCID_ACTIVATION_DATE` IS NULL
      THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_mobile_reconciliation_data_return_table ORDER BY MANDATORY_COL_NULL DESC;
  
  
	UPDATE temp_mobile_reconciliation_data_return_table_new
    SET MANDATORY_COL_NULL=0 WHERE UPPER(SIM_STATE_GT) = 'WARM';
	
    SELECT * FROM temp_mobile_reconciliation_data_return_table_new
    ORDER BY MANDATORY_COL_NULL DESC;
END$$
DELIMITER ;
