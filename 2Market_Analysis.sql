 TO "customer_joindate";

ALTER TABLE staging.stg_marketing
RENAME COLUMN "numwebbuy" TO "num_web_pur";

ALTER TABLE staging.stg_marketing
RENAME COLUMN "numwalkinpur" TO "num_store_pur";

ALTER TABLE staging.stg_marketing
RENAME COLUMN "numvisits" TO "num_month_webvisits";

ALTER TABLE staging.stg_marketing
RENAME COLUMN "count_success" TO "total_numleadconv";

-- ## Step 4: Analysis Queries

-- Total spend per country
SELECT "country", SUM("Total_customer_spending") AS total_spending
FROM staging.stg_marketing
GROUP BY "country"
ORDER BY total_spending DESC;

-- Average spend per country
SELECT "country", SUM("Total_customer_spending") AS total_spend, ROUND(AVG("Total_customer_spending"), 2) AS avg_total_spend
FROM staging.stg_marketing
GROUP BY "country"
ORDER BY total_spend DESC;

-- Total spend per product and country
SELECT "country",
       SUM("AmtVege") AS vege_spend,
       SUM("AmtMeat") AS meat_spend,
       SUM("Amtliq") AS liq_spend,
       SUM("AmtPes") AS fish_spend,
       SUM("AmtComm") AS comm_spend,
       SUM("AmtChocolates") AS choc_spend
FROM staging.stg_marketing
GROUP BY "country";

-- Average spend per product and country
SELECT "country",
 ROUND(AVG("AmtVege"), 2) AS vege_spend,
 ROUND(AVG("AmtMeat"), 2) AS meat_spend,
 ROUND(AVG("Amtliq"), 2) AS liq_spend,
 ROUND(AVG("AmtPes"), 2) AS fish_spend,
 ROUND(AVG("AmtComm"), 2) AS comm_spend,
 ROUND(AVG("AmtChocolates"), 2) AS choc_spend
FROM staging.stg_marketing
GROUP BY "country";

-- Determine the most popular products in each country
SELECT
    "country",
    CASE
        WHEN SUM("AmtVege") >= GREATEST(SUM("AmtMeat"), SUM("Amtliq"), SUM("AmtPes"), SUM("AmtChocolates")) THEN 'Vegetables'
        WHEN SUM("AmtMeat") >= GREATEST(SUM("AmtVege"), SUM("Amtliq"), SUM("AmtPes"), SUM("AmtChocolates")) THEN 'Meat'
        WHEN SUM("Amtliq") >= GREATEST(SUM("AmtVege"), SUM("AmtMeat"), SUM("AmtPes"), SUM("AmtChocolates")) THEN 'Liquor'
        WHEN SUM("AmtPes") >= GREATEST(SUM("AmtVege"), SUM("AmtMeat"), SUM("Amtliq"), SUM("AmtChocolates")) THEN 'Fish'
        ELSE 'Chocolates'
    END AS most_popular_product
FROM
    staging.stg_marketing
GROUP BY
    "country";

-- Determine the most popular product category for each customer age group
SELECT 
 "customer_group_age",
    CASE
        WHEN AVG("AmtVege") >= GREATEST(AVG("AmtMeat"), AVG("Amtliq"), AVG("AmtPes"), AVG("AmtChocolates")) THEN 'Vegetables'
        WHEN AVG("AmtMeat") >= GREATEST(AVG("AmtVege"), AVG("Amtliq"), AVG("AmtPes"), AVG("AmtChocolates")) THEN 'Meat'
        WHEN AVG("Amtliq") >= GREATEST(AVG("AmtVege"), AVG("AmtMeat"), AVG("AmtPes"), AVG("AmtChocolates")) THEN 'Liquor'
        WHEN AVG("AmtPes") >= GREATEST(AVG("AmtVege"), AVG("AmtMeat"), AVG("Amtliq"), AVG("AmtChocolates")) THEN 'Fish'
        ELSE 'Chocolates'
    END AS most_popular_product
FROM
    staging.stg_marketing
GROUP BY
    "customer_group_age";

-- Determine success metrics for social media channels
SELECT 
    m.country, 
    CASE
        WHEN ad."Twitter_ad" > 0 THEN 'Twitter'
        WHEN ad."Facebook_ad" > 0 THEN 'Facebook'
        WHEN ad."Instagram_ad" > 0 THEN 'Instagram'
        ELSE 'No Success'
    END AS social_media_type
FROM 
    raw.marketing m
LEFT JOIN 
    raw.advertisement ad 
ON 
    m.id = ad.id
GROUP BY 
    m.country, social_media_type;

-- Calculate the most effective social platform by country
SELECT m.country,
    CASE
        WHEN SUM(a.Twitter_ad) >= GREATEST(SUM(a.Facebook_ad), SUM(a.Instagram_ad)) THEN 'Twitter'
        WHEN SUM(a.Facebook_ad) >= GREATEST(SUM(a.Twitter_ad), SUM(a.Instagram_ad)) THEN 'Facebook'
        ELSE 'Instagram'
    END AS most_effective_social
FROM raw.marketing m
LEFT JOIN raw.advertisement a
ON m.id = a.id
GROUP





