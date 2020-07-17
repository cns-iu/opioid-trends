-- Load Source Database --

ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;
-- ATTACH DATABASE ':memory:' AS src;
-- .restore 'src' 'raw-data/original/box-health/R2767_Data.db';


-- (O)pioid related events --

DROP TABLE IF EXISTS "DIAGNOSES_DISTINCT";
CREATE TABLE "DIAGNOSES_DISTINCT" AS
  SELECT
    DISTINCT STUDY_ID,
    DX_DATE,
    DX_CODE_TYPE
  FROM src.DIAGNOSES
  WHERE DRUG_TYPE = 'OPIOID'
  GROUP BY STUDY_ID;

DROP TABLE IF EXISTS "FILLS_DISTINCT";
CREATE TABLE "FILLS_DISTINCT" AS
  SELECT
    DISTINCT STUDY_ID,
    FILL_DATE,
    DRUG_TYPE
  FROM src.FILLS
  WHERE DRUG_TYPE = 'OPIOID'
  GROUP BY STUDY_ID;

DROP TABLE IF EXISTS "FILLS_AGG";
CREATE TABLE "FILLS_AGG" AS
  SELECT
    -- date(FILL_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', FILL_DATE) || CASE 
      WHEN cast(strftime('%m', FILL_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', FILL_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', FILL_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(*) AS "N_OPIOID_PRESCRIPTIONS", -- O1 # opioid prescriptions
    count(DISTINCT STUDY_ID) AS "N_OPIOID_PRESCRIBERS", -- O2 # individuals with opioid prescriptions
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_OPIOID_PRESCRIBERS_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_OPIOID_PRESCRIBERS_NONCHRONIC"
  FROM FILLS_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE drug_type = 'OPIOID' AND tract_5 IS NOT NULL
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_OPIOID";
CREATE TABLE "DIAGNOSES_AGG_OPIOID" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_OPIOID_DIAGNOSED", -- O4 # individuals diagnosed with opioid misuse
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_OPIOID_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_OPIOID_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'OPIOID_USE_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_OPIOID_POISONING";
CREATE TABLE "DIAGNOSES_AGG_OPIOID_POISONING" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_OPIOID_POISONING_DIAGNOSED",
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_OPIOID_POISONING_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_OPIOID_POISONING_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'OPIOID_POISONING_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;

-- (C)omorbid events or comparison data elements --

DROP TABLE IF EXISTS "DIAGNOSES_AGG_STD";
CREATE TABLE "DIAGNOSES_AGG_STD" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_STD_DIAGNOSED", -- C1 # individuals diagnosed with sexually transmitted diseases
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_STD_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_STD_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'STD_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_HIV";
CREATE TABLE "DIAGNOSES_AGG_HIV" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_HIV_DIAGNOSED", -- C3 # individuals diagnosed with HIV/AIDS
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_HIV_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_HIV_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT INNER JOIN src.LABS USING (STUDY_ID)
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'HIV_DX' AND LAB_CODE_TYPE == 'HIV LAB'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_MENTAL_DX";
CREATE TABLE "DIAGNOSES_AGG_MENTAL_DX" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_MENTAL_DIAGNOSED", -- C4 # individuals diagnosed with mental health disorders
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_MENTAL_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_MENTAL_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'ENCOUNTER_MENTAL_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_SUD";
CREATE TABLE "DIAGNOSES_AGG_SUD" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_SUD_DIAGNOSED", -- C5 # individuals diagnosed with substance abuse diagnoses
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_SUD_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_SUD_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'SUBSTANCE_USE_DISORDER'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;

DROP TABLE IF EXISTS "DIAGNOSES_AGG_ALCOHOL";
CREATE TABLE "DIAGNOSES_AGG_ALCOHOL" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_ALCOHOL_DIAGNOSED",
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_ALCOHOL_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_ALCOHOL_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'ALCOHOL_POISONING_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_BENZO";
CREATE TABLE "DIAGNOSES_AGG_BENZO" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_BENZO_DIAGNOSED",
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_BENZO_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_BENZO_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'BENZO_POISONING_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;

DROP TABLE IF EXISTS "DIAGNOSES_AGG_DRUG";
CREATE TABLE "DIAGNOSES_AGG_DRUG" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_DRUG_DIAGNOSED",
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_DRUG_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_DRUG_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'ILLICIT_DRUG_POISONING_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;

DROP TABLE IF EXISTS "DIAGNOSES_AGG_OTHER";
CREATE TABLE "DIAGNOSES_AGG_OTHER" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_OTHER_DIAGNOSED",
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_OTHER_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_OTHER_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'OTHER_POISONING_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;

DROP TABLE IF EXISTS "DIAGNOSES_AGG_OVERDOSE";
CREATE TABLE "DIAGNOSES_AGG_OVERDOSE" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_OVERDOSE_DIAGNOSED",
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_OVERDOSE_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_OVERDOSE_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'OVERDOSE'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;

DROP TABLE IF EXISTS "DIAGNOSES_AGG_STIMULANT";
CREATE TABLE "DIAGNOSES_AGG_STIMULANT" AS
  SELECT
    -- date(DX_DATE, 'start of month') AS "PERIOD", -- Monthly Period
    strftime('%Y', DX_DATE) || CASE 
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', DX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS "PERIOD", -- Quarterly Period
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(DISTINCT STUDY_ID) AS "N_STIMULANT_DIAGNOSED",
    count(CASE WHEN IS_CHRONIC == 1 THEN 1 ELSE NULL END) AS "N_STIMULANT_DIAGNOSED_CHRONIC",
    count(CASE WHEN IS_CHRONIC == 0 THEN 1 ELSE NULL END) AS "N_STIMULANT_DIAGNOSED_NONCHRONIC"
  FROM DIAGNOSES_DISTINCT
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
    JOIN CHRONIC USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'STIMULANT_POISONING_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;

-- Aggregate view
DROP TABLE IF EXISTS "ALL_AGGREGATES";
CREATE TABLE "ALL_AGGREGATES" AS
  SELECT *
  FROM
    -- (O)pioid related events --
    FILLS_AGG AS F
    LEFT JOIN DIAGNOSES_AGG_OPIOID USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_OPIOID_POISONING USING(tract_5, period)
    -- (C)omorbid events or comparison data elements --
    LEFT JOIN DIAGNOSES_AGG_STD USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_HIV USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_MENTAL_DX USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_SUD USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_ALCOHOL USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_BENZO USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_DRUG USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_OTHER USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_OVERDOSE USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_STIMULANT USING(tract_5, period)
  WHERE cast(strftime('%Y', F.period) as integer) >= 2009
  ORDER BY F.period, F.tract_5;

-- DROP TABLE IF EXISTS "ALL_AGGREGATES_ROW_BASED";
-- CREATE TABLE "ALL_AGGREGATES_ROW_BASED" AS
--   SELECT * FROM (
--   -- FILLS_AGG
--     SELECT
--       PERIOD, TRACT_5,
--       'N_OPIOID_PRESCRIPTIONS' AS "DATA_VARIABLE",
--       N_OPIOID_PRESCRIPTIONS AS "VALUE"
--     FROM FILLS_AGG
--   UNION ALL
--     SELECT
--       PERIOD, TRACT_5,
--       'N_OPIOID_PRESCRIBERS' AS "DATA_VARIABLE",
--       N_OPIOID_PRESCRIBERS AS "VALUE"
--     FROM FILLS_AGG
--   UNION ALL
--     SELECT
--       PERIOD, TRACT_5,
--       'N_OPIOID_OVERDOSERS' AS "DATA_VARIABLE",
--       N_OPIOID_OVERDOSERS AS "VALUE"
--     FROM ENCOUNTERS_AGG
--   UNION ALL
--     -- DIAGNOSES_AGG_OPIOID
--     SELECT
--       PERIOD, TRACT_5,
--       'N_OPIOID_DX' AS "DATA_VARIABLE",
      
--       N_OPIOID_DX AS "VALUE"
--     FROM DIAGNOSES_AGG_OPIOID
--   UNION ALL
--     SELECT
--       PERIOD, TRACT_5,
--       'N_OPIOID_DX' AS "DATA_VARIABLE",
      
--       N_OPIOID_DX AS "VALUE"
--     FROM DIAGNOSES_AGG_OPIOID
--   UNION ALL
--     SELECT
--       PERIOD, TRACT_5,
--       'N_OPIOID_DIAGNOSED' AS "DATA_VARIABLE",
--       N_OPIOID_DIAGNOSED AS "VALUE"
--     FROM DIAGNOSES_AGG_OPIOID
--   UNION ALL
--     -- PILL_IN_AGG
--     SELECT
--       PERIOD, TRACT_5,
--       'N_PILLS_ISSUED' AS "DATA_VARIABLE",
--       N_PILLS_ISSUED AS "VALUE"
--     FROM PILL_IN_AGG
--   UNION ALL
--     -- EMS_AGG
--     SELECT
--       PERIOD, TRACT_5,
--       'N_NARCAN_RUNS' AS "DATA_VARIABLE",
--       N_NARCAN_RUNS AS "VALUE"
--     FROM EMS_AGG
--   UNION ALL
--     SELECT
--       PERIOD, TRACT_5,
--       'N_NARCAN_INCIDENTS' AS "DATA_VARIABLE",
--       N_NARCAN_INCIDENTS AS "VALUE"
--     FROM EMS_AGG
--   UNION ALL
--     -- DIAGNOSES_AGG_STD
--     SELECT
--       PERIOD, TRACT_5,
--       'N_STD_DX' AS "DATA_VARIABLE",
--       N_STD_DX AS "VALUE"
--     FROM DIAGNOSES_AGG_STD
--   UNION ALL
--     SELECT
--       PERIOD, TRACT_5,
--       'N_STD_DIAGNOSED' AS "DATA_VARIABLE",
--       N_STD_DIAGNOSED AS "VALUE"
--     FROM DIAGNOSES_AGG_STD
--   UNION ALL
--     -- DIAGNOSES_AGG_HIV
--     SELECT
--       PERIOD, TRACT_5,
--       'N_HIV_DX' AS "DATA_VARIABLE",
--       N_HIV_DX AS "VALUE"
--     FROM DIAGNOSES_AGG_HIV
--   UNION ALL
--     SELECT
--       PERIOD, TRACT_5,
--       'N_HIV_DIAGNOSED' AS "DATA_VARIABLE",
--       N_HIV_DIAGNOSED AS "VALUE"
--     FROM DIAGNOSES_AGG_HIV
--   UNION ALL
--     -- DIAGNOSES_AGG_MENTAL_DX
--     SELECT
--       PERIOD, TRACT_5,
--       'N_MENTAL_DX' AS "DATA_VARIABLE",
--       N_MENTAL_DX AS "VALUE"
--     FROM DIAGNOSES_AGG_MENTAL_DX
--   UNION ALL
--     SELECT
--       PERIOD, TRACT_5,
--       'N_MENTAL_DIAGNOSED' AS "DATA_VARIABLE",
--       N_MENTAL_DIAGNOSED AS "VALUE"
--     FROM DIAGNOSES_AGG_MENTAL_DX
--   UNION ALL
--     -- DIAGNOSES_AGG_SUD
--     SELECT
--       PERIOD, TRACT_5,
--       'N_SUD_DX' AS "DATA_VARIABLE",
--       N_SUD_DX AS "VALUE"
--     FROM DIAGNOSES_AGG_SUD
--   UNION ALL
--     SELECT
--       PERIOD, TRACT_5,
--       'N_SUD_DIAGNOSED' AS "DATA_VARIABLE",
--       N_SUD_DIAGNOSED AS "VALUE"
--     FROM DIAGNOSES_AGG_SUD
--   ) AS A
--   WHERE cast(strftime('%Y', period) as integer) >= 2009
--   ORDER BY data_variable, period, tract_5;