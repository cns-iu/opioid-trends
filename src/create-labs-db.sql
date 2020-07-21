-- Load Source Database --

ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;



-- (O)pioid related events --
DROP TABLE IF EXISTS "LABS_COUNT";
CREATE TABLE "LABS_COUNT" AS
    SELECT
        strftime('%Y', TEST_DATE) || CASE 
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        COUNT(*) AS TOTAL_COUNT
    FROM src.LABS
    GROUP BY PERIOD;

DROP TABLE IF EXISTS "PRE_LABS_ALL";
CREATE TABLE "PRE_LABS_ALL" AS
    SELECT
        strftime('%Y', TEST_DATE) || CASE 
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        LAB_CODE_TYPE
    FROM src.LABS;

DROP TABLE IF EXISTS "LABS_ALL";
CREATE TABLE "LABS_ALL" AS
    SELECT
        PERIOD,
        LAB_CODE_TYPE,
        COUNT(LAB_CODE_TYPE) as LAB_COUNT,
        TOTAL_COUNT
    FROM PRE_LABS_ALL
    JOIN LABS_COUNT USING(PERIOD)
    GROUP BY PERIOD, LAB_CODE_TYPE
    ORDER BY PERIOD, LAB_CODE_TYPE;

DROP TABLE IF EXISTS "PRE_LABS_CHRONIC";
CREATE TABLE "PRE_LABS_CHRONIC" AS
    SELECT
        strftime('%Y', TEST_DATE) || CASE 
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        LAB_CODE_TYPE
    FROM src.LABS
    JOIN CHRONIC USING(STUDY_ID)
    WHERE IS_CHRONIC = 1;

DROP TABLE IF EXISTS "LABS_CHRONIC";
CREATE TABLE "LABS_CHRONIC" AS
    SELECT
        PERIOD,
        LAB_CODE_TYPE,
        COUNT(LAB_CODE_TYPE) as LAB_COUNT,
        TOTAL_COUNT
    FROM PRE_LABS_CHRONIC
    JOIN LABS_COUNT USING(PERIOD)
    GROUP BY PERIOD, LAB_CODE_TYPE
    ORDER BY PERIOD, LAB_CODE_TYPE;

DROP TABLE IF EXISTS "PRE_LABS_OTHER";
CREATE TABLE "PRE_LABS_OTHER" AS
    SELECT
        strftime('%Y', TEST_DATE) || CASE 
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
            WHEN cast(strftime('%m', TEST_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
            ELSE '-10-01'
            END AS "PERIOD", -- Quarterly Period
        LAB_CODE_TYPE
    FROM src.LABS
    JOIN CHRONIC USING(STUDY_ID)
    WHERE IS_CHRONIC = 1;

DROP TABLE IF EXISTS "LABS_OTHER";
CREATE TABLE "LABS_OTHER" AS
    SELECT
        PERIOD,
        LAB_CODE_TYPE,
        COUNT(LAB_CODE_TYPE) as LAB_COUNT,
        TOTAL_COUNT
    FROM PRE_LABS_OTHER
    JOIN LABS_COUNT USING(PERIOD)
    GROUP BY PERIOD, LAB_CODE_TYPE
    ORDER BY PERIOD, LAB_CODE_TYPE;

DROP TABLE IF EXISTS "LABS_AGG";
CREATE TABLE "LABS_AGG" AS
    SELECT * FROM (
        SELECT
            PERIOD,
            LAB_CODE_TYPE,
            LAB_COUNT,
            TOTAL_COUNT,
            "ALL" AS "COHORT"
        FROM LABS_ALL
    UNION ALL
        SELECT
            PERIOD,
            LAB_CODE_TYPE,
            LAB_COUNT,
            TOTAL_COUNT,
            "CHRONIC" AS "COHORT"
        FROM LABS_CHRONIC
    UNION ALL
        SELECT
            PERIOD,
            LAB_CODE_TYPE,
            LAB_COUNT,
            TOTAL_COUNT,
            "OTHER" AS "COHORT"
        FROM LABS_OTHER
    )
ORDER BY COHORT, PERIOD, LAB_CODE_TYPE