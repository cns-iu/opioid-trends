-- Load Source Database --

ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;
-- ATTACH DATABASE ':memory:' AS src;
-- .restore 'src' 'raw-data/original/box-health/R2767_Data.db';


-- (O)pioid related events --

DROP TABLE IF EXISTS "LABS_AGG";
CREATE TABLE "LABS_AGG" AS
    SELECT DISTINCT
        LAB_CODE_TYPE,
        STUDY_ID,
        COUNT(LAB_CODE_TYPE) as LAB_COUNT
    FROM src.LABS
    GROUP BY LAB_CODE_TYPE
    ORDER BY LAB_COUNT DESC;

-- DROP TABLE IF EXISTS "FILL_DATES";
-- CREATE TABLE "FILL_DATES" AS
--   SELECT
--     STUDY_ID AS "ID",
--     julianday(FILL_DATE) AS "DATE"
--   FROM src.FILLS
--   WHERE DRUG_TYPE = 'OPIOID'
--   ORDER BY DATE;

-- This query could use some optimization!
-- DROP TABLE IF EXISTS "CHRONIC";
-- CREATE TABLE "CHRONIC" AS
--   SELECT
--     DISTINCT f1.ID AS "ID"
--   FROM FILL_DATES AS f1
--   JOIN FILL_DATES AS f2 ON f1.ID = f2.ID AND f1.DATE < f2.DATE
--   JOIN FILL_DATES AS f3 ON f1.ID = f3.ID AND f2.DATE < f3.DATE
--   WHERE abs(f3.DATE - f1.DATE) <= 120;

-- DROP TABLE IF EXISTS "CHRONIC_LABS_AGG";
-- CREATE TABLE "CHRONIC_LABS_AGG" AS
--     SELECT * FROM (
--         SELECT *
--         FROM CHRONIC
--     LEFT JOIN LABS_AGG
--     ON CHRONIC.STUDY_ID = LABS_AGG.STUDY_ID
--     )