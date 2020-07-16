-- Load Source Database --

ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;

DROP TABLE IF EXISTS "CHRONIC";
CREATE TABLE "CHRONIC" AS
  SELECT
    DISTINCT STUDY_ID,
    ifnull(mindiff(julianday(FILL_DATE), 3) <= 120, 0) AS "CHRONIC"
  FROM src.FILLS
  WHERE DRUG_TYPE = 'OPIOID'
  GROUP BY STUDY_ID;
