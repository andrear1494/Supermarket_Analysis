-- Create a table 

CREATE TABLE raw.marketing(
ID Integer PRIMARY KEY, 
Customer_Age Integer, 
Year_Birth SMALLINT,
Education Char(20),
Marital_Status Char(10),
Income Varchar (50),
Kiddhoge SMALLINT,
Teenhome SMALLINT,
Dt_Customers Date,
Regency SMALLINT,
Amtliq INTEGER,
AmtVege INTEGER, 
AmtMeat INTEGER,
AmtPes INTEGER,
AmtChocolates INTEGER, 
AmtComm INTEGER,
NumDeals SMALLINT,
NumWebBuy INTEGER,
NumWalkinPur INTEGER, 
NumVisits INTEGER,
Response smallint,
Complain smallint,
Count_success Integer,
Country Char(20));



Create table raw.advertisement(
ID Integer Primary Key, 
Bulkmail_ad smallint,
Twitter_ad smallint,
Instagram_ad smallint, 
Facebook_ad smallint, 
Brochure_ad smallint);



-- Schema staging

Create view staging.stg_marketing AS
SELECT (*)
FROM raw.marketing;
    "id", 
    Customer_Age, 
    Year_Birth,
    Education,
    Marital_Status,
    Income,
    Kiddhoge,
    Teenhome,
    Dt_Customers,
    Regency,
    amtliq,
    amtVege, 
    amtMeat,
    amtPes,
    amtChocolates, 
    amtComm,
    NumDeals,
    NumWebBuy,
    NumWalkinPur, 
    NumVisits,
    Response,
    Complain,
    Count_success,
    Country,
    amtliq + amtvege + amtmeat + amtpes + amtchocolates + amtcomm AS Total_customer_spending,
    CASE 
        WHEN Customer_Age BETWEEN 27 AND 44 THEN 'Adults'
        WHEN Customer_Age BETWEEN 45 AND 59 THEN 'Middle Age Adults'
        WHEN Customer_Age >= 60 THEN 'Old Adults'
        ELSE 'Unknown'
    END AS customer_group_age,
    CASE
        WHEN "teenhome" > 0 THEN 'Teenagers'
        WHEN "kiddhoge" > 0 THEN 'Children'
        ELSE 'No Children or Teens'	
    END AS household_type
FROM raw.marketing;


-- Transform numeric to categorical data, creating Income Bins. 
	CASE 
        WHEN Income <= 10.000 THEN '$0 - $10,000'
        WHEN Income <= 20.000 THEN '$10,001 - $20,000'
        WHEN Income <= 30.000 THEN '$20,001 - $30,000'
        WHEN Income <= 40.000 THEN '$30,001 - $40,000'
        WHEN Income <= 50.000 THEN '$40,001 - $50,000'
        WHEN Income <= 60.000 THEN '$50,001 - $60,000'
        WHEN Income <= 70.000 THEN '$60,001 - $70,000'
        WHEN Income <= 80.000 THEN '$70,001 - $80,000'
        WHEN Income <= 90.000 THEN '$80,001 - $90,000'
        WHEN Income <= 100.000 THEN '$90,001 - $100,000'
        ELSE '$100,001 and above'
    END AS Income_Range,



-- Add column 
ALTER TABLE raw.marketing
ADD COLUMN consumer_group_age VARCHAR(50);

-- Segment group age to aid analysis 
UPDATE raw.marketing
SET customer_group_age = 
    CASE 
        WHEN customer_age BETWEEN 26 AND 44 THEN 'Adults'
        WHEN customer_age BETWEEN 45 AND 59 THEN 'Middle Age Adults'
        WHEN customer_age >= 60 THEN 'Old Adults'
        ELSE 'Unknown'
    END;
	

-- Transform column names to aid interpretation

ALTER TABLE staging.stg_marketing
RENAME COLUMN "kiddhoge" TO "Kid_home"

ALTER TABLE staging.stg_marketing
RENAME COLUMN "dt_customers" TO "customer_joindate"

ALTER TABLE staging.stg_marketing
RENAME COLUMN "numwebbuy" TO "num_web_Pur",

ALTER TABLE staging.stg_marketing
RENAME COLUMN "numwalkinpur" TO "num_store_pur"

ALTER TABLE staging.stg_marketing
RENAME COLUMN "numvisits" TO "num_month_webvisits"

ALTER TABLE staging.stg_marketing
RENAME COLUMN count_success TO "total_numleadconv

-- Analysis 


-- Total spend per country

SELECT "country", SUM("customer_spending") AS total_spending
FROM staging.stg_marketing
GROUP BY "country"
ORDER BY total_spend DESC;

-- Avg spend per country 
SELECT "country", SUM("customer_spend") AS total_spend, ROUND(AVG("customer_spend"), 2) AS avg_total_spend
FROM staging.stg_marketing
GROUP BY "country"
ORDER BY total_spend DESC;


-- Calculate total spend per product and country

SELECT "country",
       SUM("amtvege") AS vege_spend,
       SUM("amtmeat") AS meat_spend,
       SUM("amtliq") AS liq_spend,
       SUM("amtpes") AS fish_spend,
       SUM("amtcomm") AS comm_spend,
       SUM ("amtchocolates") AS choc_spend
FROM staging.stg_marketing
GROUP BY "country";

-- Calculate avg spend per product and country
 
SELECT "country",
 ROUND(AVG("amtvege"), 2) AS vege_spend,
 ROUND(AVG("amtmeat"), 2) AS meat_spend,
 ROUND(AVG("amtliq"), 2) AS liq_spend,
 ROUND(AVG("amtpes"), 2) AS fish_spend,
 ROUND(AVG("amtcomm"), 2) AS comm_spend,
 ROUND (AVG("amtchocolates"),2) AS choc_spend
FROM staging.stg_marketing
GROUP BY "country";



-- Determine which products are the most popular in each country

SELECT
    "country",
    CASE
        WHEN SUM("amtvege") >= SUM("amtmeat") AND
             SUM("amtvege") >= SUM("amtliq") AND
             SUM("amtvege") >= SUM("amtpes") AND
             SUM("amtvege") >= SUM("amtchocolates") THEN 'Vegetables'
        WHEN SUM("amtmeat") >= SUM("amtvege") AND
             SUM("amtmeat") >= SUM("amtliq") AND
             SUM("amtmeat") >= SUM("amtpes") AND
             SUM("amtmeat") >= SUM("amtchocolates") THEN 'Meat'
        WHEN SUM("amtliq") >= SUM("amtvege") AND
             SUM("amtliq") >= SUM("amtmeat") AND
             SUM("amtliq") >= SUM("amtpes") AND
             SUM("amtliq") >= SUM("amtchocolates") THEN 'Liquor'
        WHEN SUM("amtpes") >= SUM("amtvege") AND
             SUM("amtpes") >= SUM("amtmeat") AND
             SUM("amtpes") >= SUM("amtliq") AND
             SUM("amtpes") >= SUM("amtchocolates") THEN 'Fish'
        WHEN SUM("amtchocolates") >= SUM("amtvege") AND
             SUM("amtchocolates") >= SUM("amtmeat") AND
             SUM("amtchocolates") >= SUM("amtliq") AND
             SUM("amtchocolates") >= SUM("amtpes") THEN 'Chocolates'
        ELSE 'Commodities'
    END AS most_popular_product
FROM
    staging.stg_marketing
GROUP BY
    "country";


-- Determine the most popular product category for each customer age group 
SELECT 
 "customer_group_age",
    CASE
        WHEN AVG("amtvege") >= AVG("amtmeat") AND
             AVG("amtvege") >= AVG("amtliq") AND
             AVG("amtvege") >= AVG("amtpes") AND
             AVG("amtvege") >= AVG("amtchocolates") THEN 'Vegetables'
        WHEN AVG("amtmeat") >= AVG("amtvege") AND
             AVG("amtmeat") >= AVG("amtliq") AND
             AVG("amtmeat") >= AVG("amtpes") AND
             AVG("amtmeat") >= AVG("amtchocolates") THEN 'Meat'
        WHEN AVG("amtliq") >= AVG("amtvege") AND
             AVG("amtliq") >= AVG("amtmeat") AND
             AVG("amtliq") >= AVG("amtpes") AND
             AVG("amtliq") >= AVG("amtchocolates") THEN 'Liquors'
        WHEN AVG("amtpes") >= AVG("amtvege") AND
             AVG("amtpes") >= AVG("amtmeat") AND
             AVG("amtpes") >= AVG("amtliq") AND
             AVG("amtpes") >= AVG("amtchocolates") THEN 'Fish'
        WHEN AVG("amtchocolates") >= AVG("amtvege") AND
             AVG("amtchocolates") >= AVG("amtmeat") AND
             AVG("amtchocolates") >= AVG("amtliq") AND
             AVG("amtchocolates") >= AVG("amtpes") THEN 'Chocolates'
        ELSE 'Commodities'
    END AS most_popular_product
FROM
    staging.stg_marketing
GROUP BY
    "customer_group_age";






-- Determine which products are the most popular based on marital status

SELECT "marital_status",
       SUM("amtvege") AS vege_spend,
       SUM("amtmeat") AS meat_spend,
       SUM("amtliq") AS liq_spend,
       SUM("amtpes") AS fish_spend,
       SUM("amtcomm") AS comm_spend,
       SUM("amtchocolates") AS choc_spend
FROM staging.stg_marketing
GROUP BY "marital_status"



-- Determine most popular products based on household type

SELECT
    CASE
        WHEN "teenhome" > 0 THEN 'Teenagers'
        WHEN "Kid_home" > 0 THEN 'Children'
        ELSE 'No Children or Teens'	
    END AS household_type,
    SUM(amtvege) AS vege_spend,
    SUM(amtmeat) AS meat_spend,
    SUM(amtliq) AS liq_spend,
    SUM(amtpes) AS fish_spend,
    SUM(amtcomm) AS comm_spend,
    SUM(amtchocolates) AS choc_spend
FROM
    staging.stg_marketing
GROUP BY
    household_type;



-- Determine success metric for social media channels 

SELECT CASE
    WHEN "twitter_ad" > 0 THEN twitter_success
    WHEN "facebook_ad" > 0 THEN facebook_success
    WHEN "instagram_ad" > 0 THEN instagram_success
    ELSE no_success
END AS social_media_type
FROM  raw.advertisement;



-- Join tables 

sintax to join tables: SELECT
    m.*,
    a.*
FROM
    raw.marketing m
LEFT JOIN
    raw.adchannels a
ON
    m."id" = a."id";



SELECT 
    m.country, 
    CASE
        WHEN ad."twitter_ad" > 0 THEN ad.twitter_success
        WHEN ad."facebook_ad" > 0 THEN ad.facebook_success
        WHEN ad."instagram_ad" > 0 THEN ad.instagram_success
        ELSE 'no_success'
    END AS social_media_type
FROM 
    raw.marketing m
LEFT JOIN 
    raw.adchannels ad 
ON 
    m."id" = ad."id"
GROUP BY 
    m.country, social_media_type;


-- total social media success by country 

SELECT m.country,
       SUM(a.Instagram_ad) AS instagram_success,
       SUM(a.Twitter_ad) AS twitter_success,
       SUM(a.Facebook_ad) AS facebook_success
FROM raw.marketing m
LEFT JOIN raw.advertisement a ON m.id = a.id
GROUP BY m.country;



-- Calculate the most effective social platform by country 
-- (the total number of lead conversions will be considered a measure of effectiveness).

SELECT m.country,
    CASE
        WHEN SUM(a.twitter_ad) >= SUM(a.facebook_ad) AND
             SUM(a.twitter_ad) >= SUM(a.instagram_ad) THEN 'Twitter'
        WHEN SUM(a.facebook_ad) >= SUM(a.twitter_ad) AND
             SUM(a.facebook_ad) >= SUM(a.instagram_ad) THEN 'Facebook'
        ELSE 'Instagram'
    END AS most_effective_social
FROM raw.marketing m
LEFT JOIN raw.advertisement a
ON m.id = a.id
GROUP BY m.country;



-- Calculate which social media platform is the most effective method of advertising based on marital status

SELECT m.marital_status,
    CASE
        WHEN SUM(a.twitter_ad) >= SUM(a.facebook_ad) AND
             SUM(a.twitter_ad) >= SUM(a.instagram_ad) THEN 'Twitter'
        WHEN SUM(a.facebook_ad) >= SUM(a.twitter_ad) AND
             SUM(a.facebook_ad) >= SUM(a.instagram_ad) THEN 'Facebook'
        ELSE 'Instagram'
    END AS most_effective_social
FROM raw.marketing m
LEFT JOIN raw.advertisement a
ON m.id = a.id
GROUP BY m.marital_status;


-- Explore correlation between age and social media platform lead conversion
correlation: SELECT
    corr(m."customer_group_age", a."twitter_ad") AS twitter_correlation,
    corr(m."customer_group_age", a."instagram_ad") AS instagram_correlation,
    corr(m."customer_group_age", a."facebook_ad") AS facebook_correlation,
    m."customer_group_age"
FROM
    staging.stg_marketing AS m
LEFT JOIN
    staging.stg_advertisement AS a
ON
    m."id" = a."_id"
GROUP BY
    m."customer_group_age";



-- Most effective ads. channel by country

SELECT 
    m.country,
    SUM("amtvege") AS vege_spend,
    SUM("amtmeat") AS meat_spend,
    SUM("amtliq") AS liq_spend,
    SUM("amtpes") AS fish_spend,
    SUM("amtcomm") AS comm_spend,
    SUM("amtchocolates") AS choc_spend,
    SUM(a.twitter_ad) AS total_twitter_ad,
    SUM(a.facebook_ad) AS total_facebook_ad,
    SUM(a.instagram_ad) AS total_instagram_ad,
    SUM("amtchocolates") + SUM("amtcomm") + SUM("amtpes") + SUM("amtliq") + SUM("amtmeat") + SUM("amtvege") AS total_spending
FROM 
    raw.marketing m
LEFT JOIN 
    raw.advertisement a ON m.id = a.id
GROUP BY 
    m.country
ORDER BY 
    m.country DESC;
