-- Create Table Statements

CREATE TABLE raw.marketing (
    ID INTEGER PRIMARY KEY, 
    Customer_Age INTEGER, 
    Year_Birth SMALLINT,
    Education VARCHAR(20),
    Marital_Status VARCHAR(10),
    Income DECIMAL(10, 2),
    Kiddhoge SMALLINT,
    Teenhome SMALLINT,
    Dt_Customers DATE,
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
    Response SMALLINT,
    Complain SMALLINT,
    Count_success INTEGER,
    Country VARCHAR(20)
);

CREATE TABLE raw.advertisement (
    ID INTEGER PRIMARY KEY, 
    Bulkmail_ad SMALLINT,
    Twitter_ad SMALLINT,
    Instagram_ad SMALLINT, 
    Facebook_ad SMALLINT, 
    Brochure_ad SMALLINT
);

-- Schema staging

CREATE VIEW staging.stg_marketing AS
SELECT
    ID,
    Customer_Age, 
    Year_Birth,
    Education,
    Marital_Status,
    Income,
    Kiddhoge,
    Teenhome,
    Dt_Customers,
    Regency,
    Amtliq,
    AmtVege, 
    AmtMeat,
    AmtPes,
    AmtChocolates, 
    AmtComm,
    NumDeals,
    NumWebBuy,
    NumWalkinPur, 
    NumVisits,
    Response,
    Complain,
    Count_success,
    Country,
    Amtliq + AmtVege + AmtMeat + AmtPes + AmtChocolates + AmtComm AS Total_customer_spending,
    CASE 
        WHEN Customer_Age BETWEEN 27 AND 44 THEN 'Adults'
        WHEN Customer_Age BETWEEN 45 AND 59 THEN 'Middle Age Adults'
        WHEN Customer_Age >= 60 THEN 'Old Adults'
        ELSE 'Unknown'
    END AS customer_group_age,
    CASE
        WHEN Teenhome > 0 THEN 'Teenagers'
        WHEN Kiddhoge > 0 THEN 'Children'
        ELSE 'No Children or Teens'    
    END AS household_type
FROM raw.marketing;

-- Transform numeric to categorical data, creating Income Bins. 
ALTER TABLE raw.marketing
ADD COLUMN Income_Range VARCHAR(20);

UPDATE raw.marketing
SET Income_Range = CASE 
        WHEN Income <= 10000 THEN '$0 - $10,000'
        WHEN Income <= 20000 THEN '$10,001 - $20,000'
        WHEN Income <= 30000 THEN '$20,001 - $30,000'
        WHEN Income <= 40000 THEN '$30,001 - $40,000'
        WHEN Income <= 50000 THEN '$40,001 - $50,000'
        WHEN Income <= 60000 THEN '$50,001 - $60,000'
        WHEN Income <= 70000 THEN '$60,001 - $70,000'
        WHEN Income <= 80000 THEN '$70,001 - $80,000'
        WHEN Income <= 90000 THEN '$80,001 - $90,000'
        WHEN Income <= 100000 THEN '$90,001 - $100,000'
        ELSE '$100,001 and above'
    END;

-- Add customer group age for segmentation
ALTER TABLE raw.marketing
ADD COLUMN customer_group_age VARCHAR(50);

UPDATE raw.marketing
SET customer_group_age = CASE 
    WHEN Customer_Age BETWEEN 27 AND 44 THEN 'Adults'
    WHEN Customer_Age BETWEEN 45 AND 59 THEN 'Middle Age Adults'
    WHEN Customer_Age >= 60 THEN 'Old Adults'
    ELSE 'Unknown'
END;

-- Transform column names to aid interpretation

ALTER TABLE staging.stg_marketing
RENAME COLUMN Kiddhoge TO Kid_home;

ALTER TABLE staging.stg_marketing
RENAME COLUMN Dt_Customers TO customer_joindate;

ALTER TABLE staging.stg_marketing
RENAME COLUMN NumWebBuy TO num_web_pur;

ALTER TABLE staging.stg_marketing
RENAME COLUMN NumWalkinPur TO num_store_pur;

ALTER TABLE staging.stg_marketing
RENAME COLUMN NumVisits TO num_month_webvisits;

ALTER TABLE staging.stg_marketing
RENAME COLUMN Count_success TO total_numleadconv;

-- Analysis Queries 

-- Total spend per country

SELECT Country, SUM(Total_customer_spending) AS total_spending
FROM staging.stg_marketing
GROUP BY Country
ORDER BY total_spending DESC;

-- Avg spend per country 
SELECT Country, SUM(Total_customer_spending) AS total_spend, ROUND(AVG(Total_customer_spending), 2) AS avg_total_spend
FROM staging.stg_marketing
GROUP BY Country
ORDER BY total_spend DESC;


-- Avg Income by country
SELECT 
    m.country,
    AVG(m.income) AS avg_income
FROM 
    raw.marketing m
GROUP BY 
    m.country
ORDER BY 
    avg_income DESC;


-- Correlation Between Income and Total Spending
SELECT 
    corr(CAST(REPLACE(Income, ',', '') AS FLOAT), Total_customer_spending) AS income_spending_correlation
FROM 
    staging.stg_marketing;

-- Calculate total spend per product and country

SELECT Country,
       SUM(AmtVege) AS vege_spend,
       SUM(AmtMeat) AS meat_spend,
       SUM(Amtliq) AS liq_spend,
       SUM(AmtPes) AS fish_spend,
       SUM(AmtComm) AS comm_spend,
       SUM(AmtChocolates) AS choc_spend
FROM staging.stg_marketing
GROUP BY Country;

-- Determine which products are the most popular in each country

SELECT Country,
    CASE
        WHEN SUM(AmtVege) >= SUM(AmtMeat) AND SUM(AmtVege) >= SUM(Amtliq) AND SUM(AmtVege) >= SUM(AmtPes) AND SUM(AmtVege) >= SUM(AmtChocolates) THEN 'Vegetables'
        WHEN SUM(AmtMeat) >= SUM(AmtVege) AND SUM(AmtMeat) >= SUM(Amtliq) AND SUM(AmtMeat) >= SUM(AmtPes) AND SUM(AmtMeat) >= SUM(AmtChocolates) THEN 'Meat'
        WHEN SUM(Amtliq) >= SUM(AmtVege) AND SUM(Amtliq) >= SUM(AmtMeat) AND SUM(Amtliq) >= SUM(AmtPes) AND SUM(Amtliq) >= SUM(AmtChocolates) THEN 'Liquor'
        WHEN SUM(AmtPes) >= SUM(AmtVege) AND SUM(AmtPes) >= SUM(AmtMeat) AND SUM(AmtPes) >= SUM(Amtliq) AND SUM(AmtPes) >= SUM(AmtChocolates) THEN 'Fish'
        WHEN SUM(AmtChocolates) >= SUM(AmtVege) AND SUM(AmtChocolates) >= SUM(AmtMeat) AND SUM(AmtChocolates) >= SUM(Amtliq) AND SUM(AmtChocolates) >= SUM(AmtPes) THEN 'Chocolates'
        ELSE 'Commodities'
    END AS most_popular_product
FROM staging.stg_marketing
GROUP BY Country;


-- Most popular product based on the average spending for each customer age group.
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
             AVG("amtliq") >= AVG("amtchocolates") THEN 'Liquor'
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
	
	
	
-- Spending on different product categories based on marital status
SELECT 
    "marital_status",
    SUM("amtvege") AS vege_spend,
    SUM("amtmeat") AS meat_spend,
    SUM("amtliq") AS liq_spend,
    SUM("amtpes") AS fish_spend,
    SUM("amtcomm") AS comm_spend,
    SUM("amtchocolates") AS choc_spend
FROM 
    staging.stg_marketing
GROUP BY 
    "marital_status";

-- Most popular products based on household type
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


-- Average Spending by Household Type
SELECT 
    household_type,
    AVG(Total_customer_spending) AS avg_spending
FROM 
    staging.stg_marketing
GROUP BY 
    household_type
ORDER BY 
    avg_spending DESC;

-- Add Social media success column 
SELECT 
    CASE
        WHEN "twitter_ad" > 0 THEN 'twitter_success'
        WHEN "facebook_ad" > 0 THEN 'facebook_success'
        WHEN "instagram_ad" > 0 THEN 'instagram_success'
        ELSE 'no_success'
    END AS social_media_type
FROM 
    raw.advertisement;

-- Social media success type by country 
    m.country,
    CASE
        WHEN "twitter_ad" > 0 THEN 'twitter_success'
        WHEN "facebook_ad" > 0 THEN 'facebook_success'
        WHEN "instagram_ad" > 0 THEN 'instagram_success'
        ELSE 'no_success'
    END AS social_media_type
FROM 
    raw.marketing m
LEFT JOIN 
    raw.adchannels ad ON m."id" = ad."id"
GROUP BY 
    m.country;

-- 5. Total social media success by country
SELECT 
    m.country,
    SUM(a.Instagram_ad) AS instagram_success,
    SUM(a.Twitter_ad) AS twitter_success,
    SUM(a.Facebook_ad) AS facebook_success
FROM 
    raw.marketing m
LEFT JOIN 
    raw.advertisement a ON m.id = a.id
GROUP BY 
    m.country;

--  Most effective social platform by country (based on lead conversions)
SELECT 
    m.country,
    CASE
        WHEN SUM(a.twitter_ad) >= SUM(a.facebook_ad) AND
             SUM(a.twitter_ad) >= SUM(a.instagram_ad) THEN 'Twitter'
        WHEN SUM(a.facebook_ad) >= SUM(a.twitter_ad) AND
             SUM(a.facebook_ad) >= SUM(a.instagram_ad) THEN 'Facebook'
        ELSE 'Instagram'
    END AS most_effective_social
FROM 
    raw.marketing m
LEFT JOIN 
    raw.advertisement a ON m.id = a.id
GROUP BY 
    m.country;

--  Most effective social platform by marital status (based on lead conversions)
SELECT 
    m.marital_status,
    CASE
        WHEN SUM(a.twitter_ad) >= SUM(a.facebook_ad) AND
             SUM(a.twitter_ad) >= SUM(a.instagram_ad) THEN 'Twitter'
        WHEN SUM(a.facebook_ad) >= SUM(a.twitter_ad) AND
             SUM(a.facebook_ad) >= SUM(a.instagram_ad) THEN 'Facebook'
        ELSE 'Instagram'
    END AS most_effective_social
FROM 
    raw.marketing m
LEFT JOIN 
    raw.advertisement a ON m.id = a.id
GROUP BY 
    m.marital_status;

-- 8. Correlation between age group and success of ads across platforms
SELECT
    corr(m."customer_group_age", a."twitter_ad") AS twitter_correlation,
    corr(m."customer_group_age", a."instagram_ad") AS instagram_correlation,
    corr(m."customer_group_age", a."facebook_ad") AS facebook_correlation,
    m."customer_group_age"
FROM
    staging.stg_marketing AS m
LEFT JOIN
    staging.stg_advertisement AS a ON m."id" = a."id"
GROUP BY 
    m."customer_group_age";

--  Total spending and social media ad effectiveness by country
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
	
	
