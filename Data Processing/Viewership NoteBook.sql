-- Databricks notebook source
---------------------------------------------------
--Checking all the columns in the userprofile4 table
---------------------------------------------------

SELECT*
FROM brighttv.tvschema.userprofile4
LIMIT 100;
------------------------------------------------
--checking if there is any row where coloumn userid is empty
-----------------------------------------------------------
SELECT *
FROM  brighttv.tvschema.userprofile4
WHERE UserID IS Null;
----------------------------------------------
--Checking for duplicates
---------------------------------------------
SELECT COUNT(*),UserID
FROM  brighttv.tvschema.userprofile4
GROUP BY UserID
HAVING COUNT(*)>1;

SELECT 
    UserID,
    COUNT(*) AS duplicate_count
    FROM brighttv.tvschema.userprofile4
    GROUP BY UserID
    HAVING COUNT(*)>1
    ORDER BY duplicate_count DESC; 

-------------------------------------------
SELECT UserID,
       Name,
       Surname,
       Email
       FROM brighttv.tvschema.userprofile4
       WHERE UserID=810044;

-- COMMAND ----------

-- DBTITLE 1,List all tables in brighttv catalog
-- List all tables in brighttv catalog with their schemas
SELECT 
    table_catalog,
    table_schema,
    table_name,
    table_type
FROM system.information_schema.tables
WHERE table_catalog = 'brighttv'
ORDER BY table_name, table_schema;

-- COMMAND ----------

-- DBTITLE 1,Drop duplicate tables
-- Drop all tables except userprofile4 and viewership4
DROP TABLE IF EXISTS brighttv.default.`1782214138464_bright_tv_dataset_4`;
DROP TABLE IF EXISTS brighttv.default.bright_tv_data;
DROP TABLE IF EXISTS brighttv.default.user_profiles;
DROP TABLE IF EXISTS brighttv.default.viewership;

-- COMMAND ----------

-- DBTITLE 1,Compare table row counts
-- Compare row counts of remaining tables
SELECT 'user_profiles (default)' AS table_name, COUNT(*) AS row_count FROM brighttv.default.user_profiles
UNION ALL
SELECT 'viewership (default)', COUNT(*) FROM brighttv.default.viewership
UNION ALL
SELECT 'viewershipt (tvschema)', COUNT(*) FROM brighttv.tvschema.viewershipt;