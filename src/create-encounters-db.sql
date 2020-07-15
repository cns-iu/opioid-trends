-- Load Source Database --

ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;
-- ATTACH DATABASE ':memory:' AS src;
-- .restore 'src' 'raw-data/original/box-health/R2767_Data.db';


-- (O)pioid related events --

-- DROP TABLE IF EXISTS "ENCOUNTER_CATEGORY_COUNT";
-- CREATE TABLE "ENCOUNTER_CATEGORY_COUNT" AS
--     SELECT DISTINCT
--         CARE_SETTING_CATEGORY AS CARE_TYPE,
--         COUNT(ENCOUNTER_ID) AS ENCOUNTER_COUNT,
--         COUNT(CARE_SETTING_CATEGORY) AS CATEGORY_COUNT,
--         CATEGORY_COUNT / ENCOUNTER_COUNT AS CATEGORY_PERCENT
--     FROM src.ENCOUNTERS
--     GROUP BY CARE_SETTING_CATEGORY
--     ORDER BY CATEGORY_PERCENT;

-- DROP TABLE IF EXISTS "EMERGENCY_CATEGORY_PERCENT";
-- CREATE TABLE "ENCOUNTER_CATEGORY_PERCENTS"
--     SELECT
--         STUDY_ID,
--         COUNT(ENCOUNTER_ID) AS ENCOUNTER_COUNT,

--     WHERE
--         ENCOUNTER_ID IS 'E'

DROP TABLE IF EXISTS "ENCOUNTER_COUNT";
CREATE TABLE "ENCOUNTER_COUNT" AS
    SELECT
        COUNT(*)
    FROM src.ENCOUNTERS;

DROP TABLE IF EXISTS "CATEGORY_COUNTS";
CREATE TABLE "CATEGORY_COUNTS" AS
    SELECT
        CARE_SETTING_CATEGORY AS CATEGORY,
        COUNT(DISTINCT STUDY_ID) AS UNIQUE_STUDY_IDS,
        COUNT(*) AS CATEGORY_TOTAL,
        COUNT(*) / CAST(COUNT(DISTINCT STUDY_ID) AS REAL) AS CATEGORY_AVERAGE
    FROM src.ENCOUNTERS
    GROUP BY CARE_SETTING_CATEGORY
    ORDER BY UNIQUE_STUDY_IDS;