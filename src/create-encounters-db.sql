-- Load Source Database --
ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;

DROP TABLE IF EXISTS "ENCOUNTERS_COUNT";
CREATE TABLE "ENCOUNTERS_COUNT" AS
    SELECT
        COUNT(*) AS ENCOUNTERS_TOTAL
    FROM src.DEMOGRAPHICS;

DROP TABLE IF EXISTS "ENCOUNTERS_COUNT_CHRONIC";
CREATE TABLE "ENCOUNTERS_COUNT_CHRONIC" AS
    SELECT
        COUNT(*) AS ENCOUNTERS_TOTAL
    FROM src.DEMOGRAPHICS
    WHERE THREE_FILL_FLAG IS 1;

DROP TABLE IF EXISTS "ENCOUNTERS_COUNT_OTHER";
CREATE TABLE "ENCOUNTERS_COUNT_OTHER" AS
    SELECT
        COUNT(*) AS ENCOUNTERS_TOTAL
    FROM src.DEMOGRAPHICS
    WHERE ONE_PER_YEAR_FLAG IS 1;

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
    JOIN ENCOUNTERS_COUNT_CHRONIC AS ENCOUNTERS
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
    JOIN ENCOUNTERS_COUNT_OTHER AS ENCOUNTERS
    ORDER BY PERIOD, PRE.CATEGORY;

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

DROP TABLE IF EXISTS "INSURANCE_COUNTS_ROW_BASED";
CREATE TABLE "INSURANCE_COUNTS_ROW_BASED" AS
    SELECT * FROM (
    -- AVERAGE ENCOUNTERS
    -- All Cohort
        SELECT
            PERIOD,
            "Avg. # Emergency Encounters" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "Avg. # Inpatient Encounters" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "Avg. # Outpatient Encounters" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "O"
    UNION ALL
    -- Chronic Cohort
        SELECT
            PERIOD,
            "Avg. # Emergency Encounters" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "Avg. # Inpatient Encounters" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "Avg. # Outpatient Encounters" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "O"
    UNION ALL
    -- Non-Chronic Cohort
        SELECT
            PERIOD,
            "Avg. # Emergency Encounters" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "Avg. # Inpatient Encounters" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "Avg. # Outpatient Encounters" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            1.0 * CATEGORY_TOTAL / UNIQUE_STUDY_IDS AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "O"

    -- PERCENTAGE ENCOUNTERS
    -- All Cohort
    UNION ALL
        SELECT
            PERIOD,
            "% with Emergency Encounters" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "% with Inpatient Encounters" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "% with Outpatient Encounters" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_ALL
        WHERE CATEGORY IS "O"
    UNION ALL
    -- Chronic Cohort
        SELECT
            PERIOD,
            "% with Emergency Encounters" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "% with Inpatient Encounters" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "% with Outpatient Encounters" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_CHRONIC
        WHERE CATEGORY IS "O"
    UNION ALL
    -- Non-Chronic Cohort
        SELECT
            PERIOD,
            "% with Emergency Encounters" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "E"
    UNION ALL
        SELECT
            PERIOD,
            "% with Inpatient Encounters" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "I"
    UNION ALL
        SELECT
            PERIOD,
            "% with Outpatient Encounters" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            CATEGORY_TOTAL AS "TOOLTIP",
            100.0 * CATEGORY_TOTAL / ENCOUNTERS_TOTAL AS "VALUE"
        FROM CATEGORY_COUNTS_OTHER
        WHERE CATEGORY IS "O"
    
    -- PERCENTAGE INSURANCES
    -- All Cohort
    UNION ALL
        SELECT
            PERIOD,
            "% Commercial Insurance" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * COMMERCIAL / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "% Other Gov. Insurance" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * OTHER_GOV / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "% Self Pay" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * SELF_PAY / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "% Workers Comp. Insurance" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * WORKERS_COMP / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "% Institutionalized Insurance" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * INSTITUTIONALIZED / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "% Charity Insurance" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * CHARITY / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "% Medicare Insurance" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * MEDICARE / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "% Medicaid Insurance" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * MEDICAID / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
        SELECT
            PERIOD,
            "% No Insurance Data" AS "DATA_VARIABLE",
            "ALL" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * NO_DATA / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_ALL
    UNION ALL
    -- Chronic Cohort
        SELECT
            PERIOD,
            "% Commercial Insurance" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * COMMERCIAL / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "% Other Gov. Insurance" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * OTHER_GOV / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "% Self Pay" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * SELF_PAY / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "% Workers Comp. Insurance" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * WORKERS_COMP / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "% Institutionalized Insurance" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * INSTITUTIONALIZED / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "% Charity Insurance" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * CHARITY / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "% Medicare Insurance" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * MEDICARE / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "% Medicaid Insurance" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * MEDICAID / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            "% No Insurance Data" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * NO_DATA / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_CHRONIC
    UNION ALL
    -- Non-Chronic Cohort
        SELECT
            PERIOD,
            "% Commercial Insurance" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * COMMERCIAL / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "% Other Gov. Insurance" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * OTHER_GOV / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "% Self Pay" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * SELF_PAY / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "% Workers Comp. Insurance" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * WORKERS_COMP / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "% Institutionalized Insurance" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * INSTITUTIONALIZED / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "% Charity Insurance" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * CHARITY / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "% Medicare Insurance" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * MEDICARE / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "% Medicaid Insurance" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * MEDICAID / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    UNION ALL
        SELECT
            PERIOD,
            "% No Insurance Data" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            TOTAL AS "TOOLTIP",
            100.0 * NO_DATA / TOTAL AS "VALUE"
        FROM INSURANCE_COUNTS_OTHER
    )
    ORDER BY DATA_VARIABLE, PERIOD;