-- Databricks notebook source
---------------------------------------------------
--Checking all the columns in the viewership table
---------------------------------------------------
SELECT*
FROM brighttv.default.viewership;
------------------------------------------------
--checking if there is any row where coloumn userid is empty
-----------------------------------------------------------
SELECT *
FROM  brighttv.default.viewership
WHERE UserID0 IS Null
OR userid4 IS Null;
-----------------------------------------
SELECT *
FROM  brighttv.default.viewership
WHERE userid0 <> userid4;
----------------------------------------------
--Checking for duplicates
---------------------------------------------
SELECT COUNT(*),Userid0,RecordDate2
FROM  brighttv.default.viewership
GROUP BY Userid0,RecordDate2
HAVING COUNT(*)>1;

SELECT 
    UserID0,
    RecordDate2,
    COUNT(*) AS duplicate_count
    FROM  brighttv.default.viewership
    GROUP BY UserId0, RecordDate2
    HAVING COUNT(*)>1
    ORDER BY duplicate_count DESC; 

-------------------------------------------
SELECT UserID0,
       TO_DATE(RecordDate2) AS Watch_date,
       date_format(RecordDate2,'HH:mm:ss') AS Watch_time,
       date_format(`Duration 2`,'HH:mm:ss') AS duration,
       Channel2
       FROM  brighttv.default.viewership
       WHERE userid0=810044;
