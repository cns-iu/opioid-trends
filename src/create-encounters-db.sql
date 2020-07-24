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
    LEFT JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    WHERE THREE_FILL_FLAG IS 1
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
    LEFT JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    WHERE ONE_PER_YEAR_FLAG IS 1
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

-- DROP TABLE IF EXISTS "CATEGORY_AGG";
-- CREATE TABLE "CATEGORY_AGG" AS
--     SELECT * FROM (
--         SELECT
--             PERIOD,
--             CATEGORY,
--             UNIQUE_STUDY_IDS,
--             CATEGORY_TOTAL,
--             ENCOUNTERS_TOTAL,
--             "ALL" AS "COHORT"
--         FROM CATEGORY_COUNTS_ALL
--     UNION ALL
--         SELECT
--             PERIOD,
--             CATEGORY,
--             UNIQUE_STUDY_IDS,
--             CATEGORY_TOTAL,
--             ENCOUNTERS_TOTAL,
--             "OPIOID_CHRONIC" AS "COHORT"
--         FROM CATEGORY_COUNTS_CHRONIC
--     UNION ALL
--         SELECT
--             PERIOD,
--             CATEGORY,
--             UNIQUE_STUDY_IDS,
--             CATEGORY_TOTAL,
--             ENCOUNTERS_TOTAL,
--             "OPIOID_OTHER" AS "COHORT"
--         FROM CATEGORY_COUNTS_OTHER
--     ) AS AGG
--     ORDER BY COHORT, PERIOD;

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
    LEFT JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    WHERE THREE_FILL_FLAG IS 1
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
    LEFT JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    WHERE ONE_PER_YEAR_FLAG IS 1
    GROUP BY PERIOD
    ORDER BY PERIOD;


-- DROP TABLE IF EXISTS "INSURANCE_COUNTS_AGG";
-- CREATE TABLE "INSURANCE_COUNTS_AGG" AS
--     SELECT * FROM (
--         SELECT
--             PERIOD,
--             TOTAL,
--             COMMERCIAL,
--             OTHER_GOV,
--             SELF_PAY,
--             WORKERS_COMP,
--             INSTITUTIONALIZED,
--             CHARITY,
--             MEDICARE,
--             MEDICAID,
--             NO_DATA,
--             "ALL" AS "COHORT"
--         FROM INSURANCE_COUNTS_ALL
--     UNION ALL
--         SELECT
--             PERIOD,
--             TOTAL,
--             COMMERCIAL,
--             OTHER_GOV,
--             SELF_PAY,
--             WORKERS_COMP,
--             INSTITUTIONALIZED,
--             CHARITY,
--             MEDICARE,
--             MEDICAID,
--             NO_DATA,
--             "OPIOID_CHRONIC" AS "COHORT"
--         FROM INSURANCE_COUNTS_CHRONIC
--     UNION ALL
--         SELECT
--             PERIOD,
--             TOTAL,
--             COMMERCIAL,
--             OTHER_GOV,
--             SELF_PAY,
--             WORKERS_COMP,
--             INSTITUTIONALIZED,
--             CHARITY,
--             MEDICARE,
--             MEDICAID,
--             NO_DATA,
--             "OPIOID_OTHER" AS "COHORT"
--         FROM INSURANCE_COUNTS_OTHER
--     ) AS AGG
--     ORDER BY COHORT, PERIOD;

DROP TABLE IF EXISTS "INSURANCE_COUNTS_ROW_BASED";
CREATE TABLE "INSURANCE_COUNTS_ROW_BASED" AS
    SELECT * FROM (
    -- AVERAGE ENCOUNTERS
        SELECT
            PERIOD,
            "AVERAGE_EMERGENCY_ENCOUNTERS" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "ALL_AVERAGE_EMERGENCY_ENCOUNTERS" AS "DV_COHORT",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "AVERAGE_INPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "ALL_AVERAGE_INPATIENT_ENCOUNTERS" AS "DV_COHORT",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "AVERAGE_OUTPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "ALL_AVERAGE_OUTPATIENT_ENCOUNTERS" AS "DV_COHORT",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "O"
    UNION ALL

        SELECT
            PERIOD,
            "AVERAGE_EMERGENCY_ENCOUNTERS" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "CHRONIC_AVERAGE_EMERGENCY_ENCOUNTERS" AS "DV_COHORT",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "AVERAGE_INPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "CHRONIC_AVERAGE_INPATIENT_ENCOUNTERS" AS "DV_COHORT",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "AVERAGE_OUTPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "CHRONIC_AVERAGE_OUTPATIENT_ENCOUNTERS" AS "DV_COHORT",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "O"
    UNION ALL

        SELECT
            PERIOD,
            "AVERAGE_EMERGENCY_ENCOUNTERS" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "OTHER_AVERAGE_EMERGENCY_ENCOUNTERS" AS "DV_COHORT",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "AVERAGE_INPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "OTHER_AVERAGE_INPATIENT_ENCOUNTERS" AS "DV_COHORT",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "AVERAGE_OUTPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "OTHER_AVERAGE_OUTPATIENT_ENCOUNTERS" AS "DV_COHORT",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "O"

    -- PERCENTAGE ENCOUNTERS
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_EMERGENCY_ENCOUNTERS" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "ALL_EMERGENCY_ENCOUNTERS" AS "DV_COHORT",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_INPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "ALL_INPATIENT_ENCOUNTERS" AS "DV_COHORT",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_OUTPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "ALL_OUTPATIENT_ENCOUNTERS" AS "DV_COHORT",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "O"
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_EMERGENCY_ENCOUNTERS" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "CHRONIC_EMERGENCY_ENCOUNTERS" AS "DV_COHORT",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_INPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "CHRONIC_INPATIENT_ENCOUNTERS" AS "DV_COHORT",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_OUTPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "CHRONIC_OUTPATIENT_ENCOUNTERS" AS "DV_COHORT",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "O"
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_EMERGENCY_ENCOUNTERS" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "OTHER_EMERGENCY_ENCOUNTERS" AS "DV_COHORT",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_INPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "OTHER_INPATIENT_ENCOUNTERS" AS "DV_COHORT",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_OUTPATIENT_ENCOUNTERS" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "OTHER_OUTPATIENT_ENCOUNTERS" AS "DV_COHORT",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "O"
    
    -- PERCENTAGE INSURANCES
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_COMMERCIAL_INSURANCE" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "PERCENT_ALL_COMMERCIAL_INSURANCE" AS "DV_COHORT",
            COMMERCIAL/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_OTHER_GOV_INSURANCE" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "PERCENT_ALL_OTHER_GOV_INSURANCE" AS "DV_COHORT",
            OTHER_GOV/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_SELF_PAY_INSURANCE" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "PERCENT_ALL_SELF_PAY_INSURANCE" AS "DV_COHORT",
            SELF_PAY/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_WORKERS_COMP_INSURANCE" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "PERCENT_ALL_WORKERS_COMP_INSURANCE" AS "DV_COHORT",
            WORKERS_COMP/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_INSTITUTIONALIZED_INSURANCE" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "PERCENT_ALL_INSTITUTIONALIZED_INSURANCE" AS "DV_COHORT",
            INSTITUTIONALIZED/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_CHARITY_INSURANCE" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "PERCENT_ALL_CHARITY_INSURANCE" AS "DV_COHORT",
            CHARITY/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_MEDICARE_INSURANCE" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "PERCENT_ALL_MEDICARE_INSURANCE" AS "DV_COHORT",
            MEDICARE/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_MEDICAID_INSURANCE" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "PERCENT_ALL_MEDICAID_INSURANCE" AS "DV_COHORT",
            MEDICAID/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_NO_DATA_INSURANCE" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            "PERCENT_ALL_NO_DATA_INSURANCE" AS "DV_COHORT",
            NO_DATA/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_COMMERCIAL_INSURANCE" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "PERCENT_CHRONIC_COMMERCIAL_INSURANCE" AS "DV_COHORT",
            COMMERCIAL/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_GOV_INSURANCE" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "PERCENT_CHRONIC_OTHER_GOV_INSURANCE" AS "DV_COHORT",
            OTHER_GOV/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_SELF_PAY_INSURANCE" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "PERCENT_CHRONIC_SELF_PAY_INSURANCE" AS "DV_COHORT",
            SELF_PAY/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_WORKERS_COMP_INSURANCE" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "PERCENT_CHRONIC_WORKERS_COMP_INSURANCE" AS "DV_COHORT",
            WORKERS_COMP/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_INSTITUTIONALIZED_INSURANCE" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "PERCENT_CHRONIC_INSTITUTIONALIZED_INSURANCE" AS "DV_COHORT",
            INSTITUTIONALIZED/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_CHARITY_INSURANCE" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "PERCENT_CHRONIC_CHARITY_INSURANCE" AS "DV_COHORT",
            CHARITY/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_MEDICARE_INSURANCE" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "PERCENT_CHRONIC_MEDICARE_INSURANCE" AS "DV_COHORT",
            MEDICARE/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_MEDICAID_INSURANCE" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "PERCENT_CHRONIC_MEDICAID_INSURANCE" AS "DV_COHORT",
            MEDICAID/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_NO_DATA_INSURANCE" AS "DATA_VARIABLE",
            "CHRONIC" AS "COHORT",
            "PERCENT_CHRONIC_NO_DATA_INSURANCE" AS "DV_COHORT",
            NO_DATA/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_COMMERCIAL_INSURANCE" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "PERCENT_OTHER_COMMERCIAL_INSURANCE" AS "DV_COHORT",
            COMMERCIAL/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_OTHER_GOV_INSURANCE" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "PERCENT_OTHER_OTHER_GOV_INSURANCE" AS "DV_COHORT",
            OTHER_GOV/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_SELF_PAY_INSURANCE" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "PERCENT_OTHER_SELF_PAY_INSURANCE" AS "DV_COHORT",
            SELF_PAY/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_WORKERS_COMP_INSURANCE" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "PERCENT_OTHER_WORKERS_COMP_INSURANCE" AS "DV_COHORT",
            WORKERS_COMP/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_INSTITUTIONALIZED_INSURANCE" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "PERCENT_OTHER_INSTITUTIONALIZED_INSURANCE" AS "DV_COHORT",
            INSTITUTIONALIZED/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_CHARITY_INSURANCE" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "PERCENT_OTHER_CHARITY_INSURANCE" AS "DV_COHORT",
            CHARITY/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_MEDICARE_INSURANCE" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "PERCENT_OTHER_MEDICARE_INSURANCE" AS "DV_COHORT",
            MEDICARE/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_MEDICAID_INSURANCE" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "PERCENT_OTHER_MEDICAID_INSURANCE" AS "DV_COHORT",
            MEDICAID/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
        -- HERE
    UNION ALL
        SELECT
            PERIOD,
            "PERCENT_NO_DATA_INSURANCE" AS "DATA_VARIABLE",
            "OTHER" AS "COHORT",
            "PERCENT_OTHER_NO_DATA_INSURANCE" AS "DV_COHORT",
            NO_DATA/CAST(TOTAL AS REAL)*100 AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    )
    ORDER BY DATA_VARIABLE, PERIOD;