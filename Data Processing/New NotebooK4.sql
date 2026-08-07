-- Databricks notebook source
--This code is to check what my data holds--
SELECT*
FROM brighttv.tvschema.userprofile4
LIMIT 50;
----------------------------------------------------
--Checking for duplicates--
SELECT COUNT(*),
  UserID
  FROM brighttv.tvschema.userprofile4
  GROUP BY UserID
  HAVING COUNT(*)>1;

  SELECT COUNT(DISTINCT Userid)
  FROM brighttv.tvschema.userprofile4;
  -----------------------------------------
  --Gender Checks--
  SELECT DISTINCT gender
  FROM brighttv.tvschema.userprofile4;
--------------------------------------------
--Gender Cleaning--
SELECT DISTINCT
    CASE
    WHEN Gender = 'None' THEN 'Unknown'
    WHEN Gender = ' ' THEN 'Unknown'
    WHEN Gender = NULL THEN 'Unknown'
    ELSE Gender
    END AS Gender
    FROM brighttv.tvschema.userprofile4;
    -----------------------------------------
    --RACE Checks--
    SELECT DISTINCT Race
    FROM brighttv.tvschema.userprofile4;
    --Race Cleaning--

    SELECT COUNT(DISTINCT UserID) AS subs,
          CASE 
          WHEN Race = 'None' THEN 'Unknown'
          WHEN Race = ' ' THEN 'Unknown'
          WHEN Race = 'other' THEN 'Unknown'
          WHEN Race IS NULL THEN 'Unknown'
           ELSE Race 
           END AS Ethnicity
           FROM  brighttv.tvschema.userprofile4
           GROUP BY Ethnicity;
-----------------------------------------------------
--Province Checks--
SELECT DISTINCT province
FROM brighttv.tvschema.userprofile4;
--Province Cleaning--
SELECT DISTINCT
     CASE 
      WHEN Province = 'None' THEN 'Unknown'
      WHEN Province =' ' THEN 'Unknown'
      WHEN Province IS NULL THEN 'Unknown'
      ELSE Province
      END AS Region
      FROM brighttv.tvschema.userprofile4;
      ------------------------------------------------
      --Age Checks--
      SELECT MIN(Age) AS min_age,
      MAX(Age) AS max_age,
      AVG(Age) AS avg_age
      FROM brighttv.tvschema.userprofile4;
      ---Age Cleaning--
      SELECT DISTINCT 
         CASE
         WHEN Age =0 THEN 'Infant'
         WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
         WHEN Age BETWEEN 13 AND 17 THEN 'Youth'
         WHEN Age BETWEEN 18 AND 35 THEN 'Young Youth'
         WHEN Age BETWEEN 36 and 50 THEN 'Adult'
         WHEN Age >50 AND Age<=60 THEN 'Elder'
         WHEN Age >60 THEN 'Pensioner'
         END AS Age_group
         FROM brighttv.tvschema.userprofile4;

         --------------------------------------------------------------------------------------------
         CREATE OR REPLACE TEMPORARY VIEW Processed AS(
          SELECT userID,
          CASE 
          WHEN (EMAIL IS NOT NULL) OR (EMAIL<> '') OR (EMAIL NOT IN ('None','other')) THEN 1
          ELSE 0
          END AS email_flag,
          CASE 
          WHEN (`Social Media Handle` IS NOT NULL) OR (`Social Media Handle` <> '') OR (`Social Media Handle` NOT IN ('None','other')) THEN 1
          ELSE 0
          END AS socialmedia_flag,

          CASE
          WHEN gender = 'None' THEN 'Unknown'
          WHEN gender = '' THEN 'Unknown'
          WHEN gender IS NULL THEN 'Unknown'
          ELSE  gender
          END AS sex,

          CASE
          WHEN Race = 'None' THEN 'Unknown'
          WHEN Race = ' ' THEN 'Unknown'
          WHEN Race = 'other' THEN 'Unknown'
          WHEN Race IS NULL THEN 'Unknown'
           ELSE Race 
           END AS Ethnicity,

           CASE 
           WHEN Province = 'None' THEN 'Unknown'
            WHEN Province =' ' THEN 'Unknown'
            WHEN Province IS NULL THEN 'Unknown'
            ELSE Province
            END AS Region,

            Age,
             CASE
    
         WHEN Age =0 THEN '01.Infant'
         WHEN Age BETWEEN 1 AND 12 THEN '02.Kids'
         WHEN Age BETWEEN 13 AND 17 THEN '03.Youth'
         WHEN Age BETWEEN 18 AND 35 THEN '04.Young Youth'
         WHEN Age BETWEEN 36 and 50 THEN '05.Adult'
         WHEN Age >50 AND Age<=60 THEN '06.Elder'
         WHEN Age >60 THEN 'Pensioner'
         END AS Age_group
         FROM brighttv.tvschema.userprofile4);

         --Checking for duplicates--
         SELECT COUNT(*)AS count,
         userid
         FROM processed
         GROUP BY userid
         HAVING COUNT(*)>1;

        SELECT* FROM processed;
         --------------------------------------------------------

CREATE OR REPLACE TEMPORARY TABLE viewership_transformed AS(
  SELECT 
COALESCE(userID0,userid4)AS userID, --combining two user ids into one
FROM_UTC_Timestamp(RecordDate2,'Africa/Johannesburg')AS RecordDate_SAST, --converting timestamp to SAtime--

TO_DATE(RecordDate_SAST) AS watch_date,--Convert a string into a date YYYY-MM-
DAYNAME(TO_DATE(RecordDate_SAST)) AS day_name,--Extract day name--
MONTHNAME(TO_DATE(RecordDate_SAST))AS month_name,--Extracts month_name
YEAR(TO_DATE(RecordDate_SAST)) AS Event_year,--Extracts the year value
DAY(TO_DATE(RecordDate_SAST)) AS event_day,--Extracting the day name
HOUR(RecordDate_SAST)AS hour_of_day,--Extracts hour if day

CASE 
WHEN DAYNAME(TO_DATE(RecordDate_SAST)) IN ('Sat','Sun') THEN 'weekend'
ELSE 'weekday'
END AS day_classification,

CASE
WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport','Supertsport Live Events','Supersport Blitz','Dstv Events 1')THEN 'Live Events'
ELSE Channel2
END AS Tv_channel,

date_format(RecordDate_SAST, 'HH:mm:ss') AS watch_time,--converting date format to time
CASE
WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01.Mitnight'
WHEN watch_time  BETWEEN '06:00:00' AND '11:59:59' THEN '02.Morning'
WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03.Afternoon'
WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04.Eveving'
END AS time_of_day,

DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,--converting duration onto time format--
(
HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))+
MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))/60.0+--converting minutes to seconds
SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))/3600.0--converting seconds to minutes
) AS Duration_hours,
(
  HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))*3600+ --cornverting hours to seconds
  MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))*60+ --converting minutes to seconds
  SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))
)AS Duration_seconds,
CASE
WHEN Duration_seconds BETWEEN 300 AND 1800 THEN '01.Low Usage (<30 min)'
WHEN Duration_seconds BETWEEN 1801 AND 3599 THEN '02.Med Usage (<60 min)'
WHEN Duration_seconds >= 3600 THEN '03.High Usage (>60 min)'
ELSE '04.No Usage'
END AS screen_time_bucket

FROM brighttv.tvschema.viewership4);


SELECT *
FROM viewership_transformed;
SELECT Coalesce(A.userid,B.userid)AS sub_id,
email_flag,
socialmedia_flag,
Sex,
Ethnicity,
Region,
Age_group,
RecordDate_SAST,
watch_date,
day_name,
event_year,
event_day,
month_name,
hour_of_day,
watch_time,
duration,
Duration_hours,
Duration_seconds,
day_classification,
Tv_channel,
time_of_day,
screen_time_bucket
FROM viewership_transformed AS A 
LEFT JOIN Processed AS B
ON A.userid=B.userid;


--Checking all the column in the viewership table--

SELECT *
FROM brighttv.tvschema.viewership4;
-------------------------------------------------------------
--Checking for NULL Columns--
SELECT *
FROM brighttv.tvschema.viewership4
WHERE UserID0 IS NULL 
OR UserID4 IS NULL
OR Channel2 = 'None'
OR RecordDate2 IS NULL
OR `Duration 2` IS NULL
OR UserID0 <> userid4;
--------------------------------------------------------------
--Checking for duplicates--
SELECT COUNT(*),
UserID0,RecordDate2
FROM brighttv.tvschema.viewership4
GROUP BY UserID0,RecordDate2
HAVING COUNT (*)>1;
--no duplicates--
---------------------------------------------------------------
SELECT UserID0,
TO_DATE(RecordDate2)AS watch_time,
date_format(RecordDate2,'HH:mm:ss')AS watch_time,
date_format(`Duration 2`,'HH:mm:ss')AS duration,
Channel2
FROM brighttv.tvschema.viewership4
WHERE UserID0=810044;

 SELECT COUNT(DISTINCT UserID0)
  FROM brighttv.tvschema.viewership4;
------------------------------------------------------------

WITH cleaned_userprofile AS(
  SELECT UserID,
  CASE 
  WHEN (EMAIL IS NOT NULL) OR (EMAIL<> '') OR (EMAIL NOT IN ('None','other')) THEN 1
  ELSE 0
  END AS email_flag,
  CASE 
  WHEN (`Social Media Handle` IS NOT NULL) OR (`Social Media Handle` <> '') OR (`Social Media Handle` NOT IN ('None','other')) THEN 1
  ELSE 0
  END AS socialmedia_flag,

  CASE
  WHEN gender = 'None' THEN 'Unknown'
  WHEN gender = '' THEN 'Unknown'
  WHEN gender IS NULL THEN 'Unknown'
  ELSE  gender
  END AS Sex,

  CASE
  WHEN Race = 'None' THEN 'Unknown'
  WHEN Race = ' ' THEN 'Unknown'
  WHEN Race = 'other' THEN 'Unknown'
  WHEN Race IS NULL THEN 'Unknown'
   ELSE Race 
   END AS Ethnicity,

   CASE 
   WHEN Province = 'None' THEN 'Unknown'
    WHEN Province =' ' THEN 'Unknown'
    WHEN Province IS NULL THEN 'Unknown'
    ELSE Province
    END AS Region,

    Age,
     CASE
    
 WHEN Age =0 THEN '01.Infant'
 WHEN Age BETWEEN 1 AND 12 THEN '02.Kids'
 WHEN Age BETWEEN 13 AND 17 THEN '03.Youth'
 WHEN Age BETWEEN 18 AND 35 THEN '04.Young Youth'
 WHEN Age BETWEEN 36 and 50 THEN '05.Adult'
 WHEN Age >50 AND Age<=60 THEN '06.Elder'
 WHEN Age >60 THEN 'Pensioner'
 END AS Age_group
 FROM brighttv.tvschema.userprofile4),

 viewership AS(
  SELECT 
COALESCE(userID0,userid4)AS userID,
FROM_UTC_Timestamp(RecordDate2,'Africa/Johannesburg')AS RecordDate_SAST,
TO_DATE(RecordDate_SAST) AS watch_date,
DAYNAME(TO_DATE(RecordDate_SAST))AS day_name,
MONTHNAME(TO_DATE(RecordDate_SAST))AS month_name,
YEAR(TO_DATE(RecordDate_SAST))AS Event_year,
DAY(TO_DATE(RecordDate_SAST))AS event_day,
HOUR(RecordDate_SAST)AS hour_of_day,

CASE 
WHEN DAYNAME(TO_DATE(RecordDate_SAST)) IN ('Sat','Sun') THEN 'Weekend'
ELSE 'Weekday'
END AS day_classification,

CASE
WHEN Channel2 IN ('SeeSaw','Sawsee') THEN 'SawSee'
WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport','Supersport Live Events','SuperSport Blitz','Dstv Events 1') THEN 'Live_Events' 
 ELSE Channel2
 END AS Tv_channel,

 date_format(RecordDate_SAST, 'HH:mm:ss') AS watch_time,
 
 CASE 
 WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN 'midnight'
 WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN 'morning'
 WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN 'afternoon'
 WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN 'evening'
 END AS Time_of_day,

 DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,
 HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))+
MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))/60.0+
SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))/3600.0 AS Duration_hours,

 HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 +
   MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 +
    SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) AS Duration_seconds,

 CASE
 WHEN Duration_seconds  BETWEEN 300 AND 1800 THEN '01.Low Usage (<30 min)'
 WHEN Duration_seconds  BETWEEN 1801 AND 3599 THEN '02.Med Usage (<60 min)'
 WHEN Duration_seconds >=3600  THEN '03.High Usage (>60 min)'
 ELSE '04.No Usage'
 END AS screen_time_bucket
 FROM brighttv.tvschema.viewership4)

SELECT 
COALESCE(A.userid,B.userid)AS sub_id,
B.email_flag,
B.socialmedia_flag,
B.Sex,
B.Ethnicity,
B.Region,
B.Age_group,
A.RecordDate_SAST,
A.watch_date,
A.day_name,
A.Event_year,
A.event_day,
A.month_name,
A.hour_of_day,
A.watch_time,
A.duration,
A.Duration_hours,
A.Duration_seconds,
A.day_classification,
A.Tv_channel,
A.Time_of_day,
A.screen_time_bucket
FROM viewership AS A 
LEFT JOIN cleaned_userprofile AS B
ON A.userid=B.userid;




