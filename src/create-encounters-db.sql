-- Load Source Database --

ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;

DROP TABLE IF EXISTS "ENCOUNTERS_COUNT";
CREATE TABLE "ENCOUNTERS_COUNT" AS
    SELECT
        strftime('%Y', ADMIT_TIME) || CASE 
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        COUNT(*) AS ENCOUNTERS_TOTAL
    FROM src.ENCOUNTERS
    GROUP BY PERIOD;

DROP TABLE IF EXISTS "PRE_CATEGORY_COUNTS_ALL";
CREATE TABLE "PRE_CATEGORY_COUNTS_ALL" AS
    SELECT
        strftime('%Y', ADMIT_TIME) || CASE 
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        CARE_SETTING_CATEGORY AS CATEGORY,
        COUNT(DISTINCT STUDY_ID) AS UNIQUE_STUDY_IDS,
        COUNT(*) AS CATEGORY_TOTAL
    FROM src.ENCOUNTERS
    GROUP BY PERIOD, CARE_SETTING_CATEGORY
    ORDER BY PERIOD;

DROP TABLE IF EXISTS "CATEGORY_COUNTS_ALL";
CREATE TABLE "CATEGORY_COUNTS_ALL" AS
    SELECT
        PERIOD,
        PRE.CATEGORY,
        PRE.UNIQUE_STUDY_IDS,
        PRE.CATEGORY_TOTAL,
        ENCOUNTERS.ENCOUNTERS_TOTAL
    FROM PRE_CATEGORY_COUNTS_ALL AS PRE
    JOIN ENCOUNTERS_COUNT AS ENCOUNTERS
    USING(PERIOD)
    ORDER BY PERIOD, PRE.CATEGORY;

DROP TABLE IF EXISTS "PRE_CATEGORY_COUNTS_CHRONIC";
CREATE TABLE "PRE_CATEGORY_COUNTS_CHRONIC" AS
    SELECT
        strftime('%Y', ADMIT_TIME) || CASE 
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        CARE_SETTING_CATEGORY AS CATEGORY,
        COUNT(DISTINCT STUDY_ID) AS UNIQUE_STUDY_IDS,
        COUNT(*) AS CATEGORY_TOTAL
    FROM src.ENCOUNTERS
    JOIN CHRONIC USING(STUDY_ID)
    WHERE IS_CHRONIC = 1
    GROUP BY PERIOD, CARE_SETTING_CATEGORY
    ORDER BY PERIOD;

DROP TABLE IF EXISTS "CATEGORY_COUNTS_CHRONIC";
CREATE TABLE "CATEGORY_COUNTS_CHRONIC" AS
    SELECT
        PERIOD,
        PRE.CATEGORY,
        PRE.UNIQUE_STUDY_IDS,
        PRE.CATEGORY_TOTAL,
        ENCOUNTERS.ENCOUNTERS_TOTAL
    FROM PRE_CATEGORY_COUNTS_CHRONIC AS PRE
    JOIN ENCOUNTERS_COUNT AS ENCOUNTERS USING(PERIOD)
    ORDER BY PERIOD, PRE.CATEGORY;

DROP TABLE IF EXISTS "PRE_CATEGORY_COUNTS_OTHER";
CREATE TABLE "PRE_CATEGORY_COUNTS_OTHER" AS
    SELECT
        strftime('%Y', ADMIT_TIME) || CASE 
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        CARE_SETTING_CATEGORY AS CATEGORY,
        COUNT(DISTINCT STUDY_ID) AS UNIQUE_STUDY_IDS,
        COUNT(*) AS CATEGORY_TOTAL
    FROM src.ENCOUNTERS
    JOIN CHRONIC USING(STUDY_ID)
    WHERE IS_CHRONIC = 0
    GROUP BY PERIOD, CARE_SETTING_CATEGORY
    ORDER BY PERIOD;

DROP TABLE IF EXISTS "CATEGORY_COUNTS_OTHER";
CREATE TABLE "CATEGORY_COUNTS_OTHER" AS
    SELECT
        PERIOD,
        PRE.CATEGORY,
        PRE.UNIQUE_STUDY_IDS,
        PRE.CATEGORY_TOTAL,
        ENCOUNTERS.ENCOUNTERS_TOTAL
    FROM PRE_CATEGORY_COUNTS_OTHER AS PRE
    JOIN ENCOUNTERS_COUNT AS ENCOUNTERS USING(PERIOD)
    ORDER BY PERIOD, PRE.CATEGORY;

DROP TABLE IF EXISTS "CATEGORY_AGG";
CREATE TABLE "CATEGORY_AGG" AS
    SELECT * FROM (
        SELECT
            PERIOD,
            CATEGORY,
            UNIQUE_STUDY_IDS,
            CATEGORY_TOTAL,
            ENCOUNTERS_TOTAL,
            "ALL" AS "COHORT"
        FROM CATEGORY_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            CATEGORY,
            UNIQUE_STUDY_IDS,
            CATEGORY_TOTAL,
            ENCOUNTERS_TOTAL,
            "OPIOID_CHRONIC" AS "COHORT"
        FROM CATEGORY_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            CATEGORY,
            UNIQUE_STUDY_IDS,
            CATEGORY_TOTAL,
            ENCOUNTERS_TOTAL,
            "OPIOID_OTHER" AS "COHORT"
        FROM CATEGORY_COUNTS_OTHER
    ) AS AGG
    ORDER BY COHORT, PERIOD;

DROP TABLE IF EXISTS "INSURANCE_COUNTS_ALL";
CREATE TABLE "INSURANCE_COUNTS_ALL" AS
    SELECT
        strftime('%Y', ADMIT_TIME) || CASE 
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        COUNT(*) AS TOTAL,
        SUM(COMMERCIAL_FLAG) AS COMMERCIAL,
        SUM(OTHERGOV_FLAG) AS OTHER_GOV,
        SUM(SELFPAY_FLAG) AS SELF_PAY,
        SUM(WORKERSCOMP_FLAG) AS WORKERS_COMP,
        SUM(INSTITUTIONALIZED_FLAG) AS INSTITUTIONALIZED,
        SUM(CHARITY_FLAG) AS CHARITY,
        SUM(MEDICARE_FLAG) AS MEDICARE,
        SUM(MEDICAID_FLAG) AS MEDICAID,
        SUM(NODATA_FLAG) AS NO_DATA
    FROM src.ENCOUNTERS
    GROUP BY PERIOD
    ORDER BY PERIOD;

DROP TABLE IF EXISTS "INSURANCE_COUNTS_CHRONIC";
CREATE TABLE "INSURANCE_COUNTS_CHRONIC" AS
    SELECT
        strftime('%Y', ADMIT_TIME) || CASE 
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        COUNT(*) AS TOTAL,
        SUM(COMMERCIAL_FLAG) AS COMMERCIAL,
        SUM(OTHERGOV_FLAG) AS OTHER_GOV,
        SUM(SELFPAY_FLAG) AS SELF_PAY,
        SUM(WORKERSCOMP_FLAG) AS WORKERS_COMP,
        SUM(INSTITUTIONALIZED_FLAG) AS INSTITUTIONALIZED,
        SUM(CHARITY_FLAG) AS CHARITY,
        SUM(MEDICARE_FLAG) AS MEDICARE,
        SUM(MEDICAID_FLAG) AS MEDICAID,
        SUM(NODATA_FLAG) AS NO_DATA
    FROM src.ENCOUNTERS
    JOIN CHRONIC USING(STUDY_ID)
    WHERE IS_CHRONIC = 1
    GROUP BY PERIOD
    ORDER BY PERIOD;

DROP TABLE IF EXISTS "INSURANCE_COUNTS_OTHER";
CREATE TABLE "INSURANCE_COUNTS_OTHER" AS
    SELECT
        strftime('%Y', ADMIT_TIME) || CASE 
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', ADMIT_TIME) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        COUNT(*) AS TOTAL,
        SUM(COMMERCIAL_FLAG) AS COMMERCIAL,
        SUM(OTHERGOV_FLAG) AS OTHER_GOV,
        SUM(SELFPAY_FLAG) AS SELF_PAY,
        SUM(WORKERSCOMP_FLAG) AS WORKERS_COMP,
        SUM(INSTITUTIONALIZED_FLAG) AS INSTITUTIONALIZED,
        SUM(CHARITY_FLAG) AS CHARITY,
        SUM(MEDICARE_FLAG) AS MEDICARE,
        SUM(MEDICAID_FLAG) AS MEDICAID,
        SUM(NODATA_FLAG) AS NO_DATA
    FROM src.ENCOUNTERS
    JOIN CHRONIC USING(STUDY_ID)
    WHERE IS_CHRONIC = 0
    GROUP BY PERIOD
    ORDER BY PERIOD;


DROP TABLE IF EXISTS "INSURANCE_COUNTS_AGG";
CREATE TABLE "INSURANCE_COUNTS_AGG" AS
    SELECT * FROM (
        SELECT
            PERIOD,
            TOTAL,
            COMMERCIAL,
            OTHER_GOV,
            SELF_PAY,
            WORKERS_COMP,
            INSTITUTIONALIZED,
            CHARITY,
            MEDICARE,
            MEDICAID,
            NO_DATA,
            "ALL" AS "COHORT"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            TOTAL,
            COMMERCIAL,
            OTHER_GOV,
            SELF_PAY,
            WORKERS_COMP,
            INSTITUTIONALIZED,
            CHARITY,
            MEDICARE,
            MEDICAID,
            NO_DATA,
            "OPIOID_CHRONIC" AS "COHORT"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            TOTAL,
            COMMERCIAL,
            OTHER_GOV,
            SELF_PAY,
            WORKERS_COMP,
            INSTITUTIONALIZED,
            CHARITY,
            MEDICARE,
            MEDICAID,
            NO_DATA,
            "OPIOID_OTHER" AS "COHORT"
        FROM INSURANCE_COUNTS_OTHER
    ) AS AGG
    ORDER BY COHORT, PERIOD;