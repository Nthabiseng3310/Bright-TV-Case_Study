-- Databricks notebook source
--This code is to check what my data contains--
SELECT * 
FROM `dbacademy`.`default`.`user_profiles` 
limit 100;
---------------------------------------
--CHECKING FOR DUPLICATE ID/User_Names
------------------------------------------
SELECT COUNT (*),
  userid
  FROM `dbacademy`.`default`.`user_profiles`
  GROUP BY UserID
  HAVING COUNT(*)>1;

------------------------------
--GENDER CHECKS--
--------------------------------
SELECT GENDER,COUNT(*) AS count
FROM `dbacademy`.`default`.`user_profiles` 
GROUP BY Gender
ORDER BY  count DESC;
--------------------------------
--GENDER CLEANING--
--------------------------------
SELECT DISTINCT gender,
      CASE
      WHEN gender='none' THEN 'unknown'
      WHEN gender= ' 'THEN 'unknown'
      WHEN gender IS NULL THEN 'unknown'
      ELSE gender
      END AS gender_clean
FROM `dbacademy`.`default`.`user_profiles`;
-------------------------------------------
--RACE CHECKS--
------------------------------------------
SELECT Race,COUNT(*)AS count
FROM `dbacademy`.`default`.`user_profiles`
GROUP BY Race
ORDER BY count ASC;
---------------------------------------
--RACE CLEANING--
---------------------------------------
SELECT DISTINCT Race,
      CASE 
      WHEN Race='other' THEN 'unknown'
      WHEN Race=' ' THEN 'unknown'
      WHEN Race IS NULL THEN 'unknown'
      WHEN Race='None' THEN 'unknown'
      ELSE Race
      END AS Ethnicity
      FROM `dbacademy`.`default`.`user_profiles`;
      ---------------------------------------------
      --PROVINCE CHECKS--
      ---------------------------------------------
      SELECT Province,COUNT(*)AS count
      FROM `dbacademy`.`default`.`user_profiles`
      GROUP BY Province
      ORDER BY COUNT ASC;
      -----------------------------------------
      --PROVINCE CLEANING--
      -----------------------------------------
      SELECT DISTINCT Province,
          CASE 
          WHEN Province= ' ' THEN 'Uncategorized'
          WHEN Province= 'None' THEN 'Uncategorized'
          WHEN Province IS NULL THEN 'Uncategorized'
          WHEN Province= 'other' THEN 'Uncategorized'
          ELSE Province
          END AS Region
          FROM `dbacademy`.`default`.`user_profiles`;
          -------------------------------------------
          --AGE CHECKS--
          ------------------------------------------
          SELECT Age,COUNT(*)AS count
          FROM `dbacademy`.`default`.`user_profiles`
          GROUP BY Age
          ORDER BY Age ASC;
---------------------------------------------------
--AGE CATEGORAZATION--
-------------------------------------------------
SELECT MIN(Age) AS min_age,
    MAX(Age) AS max_age,
    AVG(Age) AS mean_age
    FROM `dbacademy`.`default`.`user_profiles`;

    SELECT
    CASE
       WHEN Age = 0 THEN 'infant'
       WHEN Age BETWEEN 1 AND 12 THEN 'kids'
       WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
       WHEN Age BETWEEN 18 AND 35 THEN 'young Adult' 
       WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
       WHEN Age >50 AND AGE<=60 THEN 'Elder'
        WHEN Age >60 THEN 'Pensioner'
       ELSE 'unknown'
       END AS Age_group
       FROM `dbacademy`.`default`.`user_profiles`;
       --------------------------------------------
       WITH user_profiles AS (
        SELECT userid,

        CASE
          WHEN Province= ' ' THEN 'Uncategorized'
          WHEN Province= 'None' THEN 'Uncategorized'
          WHEN Province IS NULL THEN 'Uncategorized'
          WHEN Province= 'other' THEN 'Uncategorized'
          ELSE Province
          END AS Region,

          Age,
          CASE
       WHEN Age = 0 THEN 'infant'
       WHEN Age BETWEEN 1 AND 12 THEN 'kids'
       WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
       WHEN Age BETWEEN 18 AND 35 THEN 'young Adult' 
       WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
       WHEN Age >50 AND AGE<=60 THEN 'Elder'
        WHEN Age >60 THEN 'Pensioner'
       ELSE 'unknown'
       END AS Age_group,

       CASE 
        WHEN Email IS NOT NULL OR Email=' ' OR Email NOT IN 'None' THEN 1
        ELSE 0
        END AS Email_flag,

        CASE 
        WHEN Social media Handle IS NOT NULL OR Social media Hndle=' 'OR Social Media Handle NOT IN ('None') THEN 1
        ELSE 0
        END AS sm_flag,

        CASE
        WHEN Race ='other' THEN 'None'
        WHEN Race='' THEN 'None'
        ELSE Race
        END AS Ethnicity,

        CASE
        WHEN gender=' ' THEN 'None'
        ELSE gender
        END AS Gender

         FROM `dbacademy`.`default`.`user_profiles`);


         CREATE OR REPLACE TEMPORARY TABLE
         
          viewership AS (
            SELECT 
            COALESCE (UserID0,userid4) AS Userid,
            DATE_FORMAT(RecordDate2,'yyyyMM') AS month_id,
            TO_DATE(RecordDate2) AS watch_date,
            --TIME(RecordDate2)AS watch_time,
            DATE_FORMAT(RecordDate2,'dd') AS day_of_the_week,
            DAYNAME(RecordDate2) AS day_name,

            CASE
            WHEN day_name IN ('sat','sun') THEN 'weekend'
            ELSE 'weekday'
            END AS day_classification,
            MONTHNAME(RecordDate2) AS month_name,

         CASE
        WHEN Channel2 IN ('SawSee','SawSee') THEN 'SawSee'
        WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport','SuperSport Live Events','Dstv Events1') THEN 'Live Events'
        ELSE Channel2
        END AS Tv_Channel2,

        DATE_FORMAT(RecordDate2,'HH:mm:ss') AS watch_time,
        CASE
        WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss') BETWEEN '00:00:00' AND '05:59:59' THEN '01.Midnight'
        WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss') BETWEEN '06:00:00' AND '11:59:59' THEN '02.Morning'
        WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03.Afternoon'
        WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss') BETWEEN '17:00:00' AND '23:59:59' THEN '04.Evening'
        END AS time_of_day,

        DATE_FORMAT(`Duration 2`,'HH:mm:ss') AS duration,
        CASE
        WHEN DATE_FORMAT(`Duration 2`,'HH:mm:ss') BETWEEN '00:05:00' AND '00:30:00' THEN '01.Low Usage:<30min'
        WHEN DATE_FORMAT(`Duration 2`,'HH:mm:ss') BETWEEN '00:30:01' AND '00:59:59' THEN '02.Med Usage:<60min'
        WHEN DATE_FORMAT(`Duration 2`,'HH:mm:ss') > '00:59:59' THEN '03.High Usage:>60min'
        ELSE '04.NoUsage'
        END AS Screen_time_bucket,

        HOUR(RecordDate2) AS hour_of_day
        FROM brighttv.default.viewership);

        CREATE OR REPLACE TEMPORARY TABLE

        SELECT Coalesce(A.Userid,B.Userid)AS sub_id,
        month_id,
        watch_date,
        day_of_week,
        day_name,
        day_classification,
        month_name,
        Tv_channel,
        time_of_day,
        hour_of_day,
        screen_time_bucket,
        --user_flag,
        duration,
        region,
        age_groups,
        email_flag,
        sm_flag,
        ethnicity,
        gender
        FROM brighttv.default.viewership AS A
        LEFT JOIN `dbacademy`.`default`.`user_profiles` AS B
        ON A.Userid=B.Userid;