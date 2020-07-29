-- Load Source Database --

ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;



-- (O)pioid related events --

DROP TABLE IF EXISTS "ALL_LABS_COUNT";
CREATE TABLE "ALL_LABS_COUNT" AS
    SELECT
        COUNT(DISTINCT STUDY_ID) AS TOTAL_COUNT
    FROM src.DEMOGRAPHICS;

DROP TABLE IF EXISTS "CHRONIC_LABS_COUNT";
CREATE TABLE "CHRONIC_LABS_COUNT" AS
    SELECT
        COUNT(DISTINCT STUDY_ID) AS TOTAL_COUNT
    FROM src.DEMOGRAPHICS
    WHERE THREE_FILL_FLAG IS 1;

DROP TABLE IF EXISTS "OTHER_LABS_COUNT";
CREATE TABLE "OTHER_LABS_COUNT" AS
    SELECT
        COUNT(DISTINCT STUDY_ID) AS TOTAL_COUNT
    FROM src.DEMOGRAPHICS
    WHERE ONE_PER_YEAR_FLAG IS 1;


DROP TABLE IF EXISTS "LABS_ADD_FLAGS";
CREATE TABLE "LABS_ADD_FLAGS" AS
    SELECT
        STUDY_ID,
        TEST_DATE,
        LAB_CODE_TYPE,
        THREE_FILL_FLAG,
        ONE_PER_YEAR_FLAG
    FROM src.LABS
    LEFT JOIN src.DEMOGRAPHICS
    USING(STUDY_ID);

DROP TABLE IF EXISTS "LABS_ALL";
CREATE TABLE "LABS_ALL" AS
    SELECT
        strftime('%Y', TEST_DATE) || CASE 
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        LAB_CODE_TYPE,
        COUNT(LAB_CODE_TYPE) AS LAB_TYPE_COUNT,
        TOTAL_COUNT
    FROM LABS_ADD_FLAGS
    JOIN ALL_LABS_COUNT
    GROUP BY PERIOD, LAB_CODE_TYPE
    ORDER BY PERIOD, LAB_CODE_TYPE;

DROP TABLE IF EXISTS "LABS_CHRONIC";
CREATE TABLE "LABS_CHRONIC" AS
    SELECT
        strftime('%Y', TEST_DATE) || CASE 
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        LAB_CODE_TYPE,
        COUNT(LAB_CODE_TYPE) AS LAB_TYPE_COUNT,
        TOTAL_COUNT
    FROM LABS_ADD_FLAGS
    JOIN CHRONIC_LABS_COUNT
    WHERE THREE_FILL_FLAG IS 1
    GROUP BY PERIOD, LAB_CODE_TYPE
    ORDER BY PERIOD, LAB_CODE_TYPE;

DROP TABLE IF EXISTS "LABS_OTHER";
CREATE TABLE "LABS_OTHER" AS
    SELECT
        strftime('%Y', TEST_DATE) || CASE 
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        LAB_CODE_TYPE,
        COUNT(LAB_CODE_TYPE) AS LAB_TYPE_COUNT,
        TOTAL_COUNT
    FROM LABS_ADD_FLAGS
    JOIN OTHER_LABS_COUNT
    WHERE ONE_PER_YEAR_FLAG IS 1
    GROUP BY PERIOD, LAB_CODE_TYPE
    ORDER BY PERIOD, LAB_CODE_TYPE;

-- DROP TABLE IF EXISTS "LABS_AGG";
-- CREATE TABLE "LABS_AGG" AS
--     SELECT * FROM (
--         SELECT
--             PERIOD,
--             LAB_CODE_TYPE,
--             LAB_TYPE_COUNT,
--             TOTAL_COUNT,
--             "ALL" AS "COHORT"
--         FROM LABS_ALL
--     UNION ALL
--         SELECT
--             PERIOD,
--             LAB_CODE_TYPE,
--             LAB_TYPE_COUNT,
--             TOTAL_COUNT,
--             "CHRONIC" AS "COHORT"
--         FROM LABS_CHRONIC
--     UNION ALL
--         SELECT
--             PERIOD,
--             LAB_CODE_TYPE,
--             LAB_TYPE_COUNT,
--             TOTAL_COUNT,
--             "OTHER" AS "COHORT"
--         FROM LABS_OTHER
--     )
-- ORDER BY COHORT, PERIOD, LAB_CODE_TYPE

DROP TABLE IF EXISTS "LABS_ROW_BASED";
CREATE TABLE "LABS_ROW_BASED" AS
    SELECT * FROM (
    -- All Cohort
        SELECT
            PERIOD,
            "% Hepatitus Lab Completed" AS "DATA_VARIABLE",
            "All" AS "COHORT",
            100.0 * LAB_TYPE_COUNT / TOTAL_COUNT AS "VALUE",
            LAB_TYPE_COUNT AS "TOOLTIP"
        FROM LABS_ALL
        WHERE LAB_CODE_TYPE IS "HEP C LAB"
    UNION ALL
        SELECT
            PERIOD,
            "% Tox Screen Lab Completed" AS "DATA_VARIABLE",
            "All" AS "COHORT",
            100.0 * LAB_TYPE_COUNT / TOTAL_COUNT AS "VALUE",
            LAB_TYPE_COUNT AS "TOOLTIP"
        FROM LABS_ALL
        WHERE LAB_CODE_TYPE IS "TOX LAB"
    UNION ALL
        SELECT
            PERIOD,
            "% HIV Lab Completed" AS "DATA_VARIABLE",
            "All" AS "COHORT",
            100.0 * LAB_TYPE_COUNT / TOTAL_COUNT AS "VALUE",
            LAB_TYPE_COUNT AS "TOOLTIP"
        FROM LABS_ALL
        WHERE LAB_CODE_TYPE IS "HIV LAB"
    UNION ALL

    -- Chronic Cohort
        SELECT
            PERIOD,
            "% Hepatitus Lab Completed" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            100.0 * LAB_TYPE_COUNT / TOTAL_COUNT AS "VALUE",
            LAB_TYPE_COUNT AS "TOOLTIP"
        FROM LABS_CHRONIC
        WHERE LAB_CODE_TYPE IS "HEP C LAB"
    UNION ALL
        SELECT
            PERIOD,
            "% Tox Screen Lab Completed" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            100.0 * LAB_TYPE_COUNT / TOTAL_COUNT AS "VALUE",
            LAB_TYPE_COUNT AS "TOOLTIP"
        FROM LABS_CHRONIC
        WHERE LAB_CODE_TYPE IS "TOX LAB"
    UNION ALL
        SELECT
            PERIOD,
            "% HIV Lab Completed" AS "DATA_VARIABLE",
            "Chronic" AS "COHORT",
            100.0 * LAB_TYPE_COUNT / TOTAL_COUNT AS "VALUE",
            LAB_TYPE_COUNT AS "TOOLTIP"
        FROM LABS_CHRONIC
        WHERE LAB_CODE_TYPE IS "HIV LAB"
    UNION ALL

    -- Non-chronic Cohort
        SELECT
            PERIOD,
            "% Hepatitus Lab Completed" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            100.0 * LAB_TYPE_COUNT / TOTAL_COUNT AS "VALUE",
            LAB_TYPE_COUNT AS "TOOLTIP"
        FROM LABS_OTHER
        WHERE LAB_CODE_TYPE IS "HEP C LAB"
    UNION ALL
        SELECT
            PERIOD,
            "% Tox Screen Lab Completed" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            100.0 * LAB_TYPE_COUNT / TOTAL_COUNT AS "VALUE",
            LAB_TYPE_COUNT AS "TOOLTIP"
        FROM LABS_OTHER
        WHERE LAB_CODE_TYPE IS "TOX LAB"
    UNION ALL
        SELECT
            PERIOD,
            "% HIV Lab Completed" AS "DATA_VARIABLE",
            "Non-chronic" AS "COHORT",
            100.0 * LAB_TYPE_COUNT / TOTAL_COUNT AS "VALUE",
            LAB_TYPE_COUNT AS "TOOLTIP"
        FROM LABS_OTHER
        WHERE LAB_CODE_TYPE IS "HIV LAB"
    )
ORDER BY DATA_VARIABLE, PERIOD, COHORT