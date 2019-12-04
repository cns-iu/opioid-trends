-- Load Source Database --

ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;
-- ATTACH DATABASE ':memory:' AS src;
-- .restore 'src' 'raw-data/original/box-health/R2767_Data.db';


-- (O)pioid related events --

DROP TABLE IF EXISTS "FILLS_AGG";
CREATE TABLE "FILLS_AGG" AS
  SELECT
    date(FILL_DATE, 'start of month') AS "PERIOD",
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(*) AS "N_OPIOID_PRESCRIPTIONS", -- O1 # opioid prescriptions
    count(DISTINCT STUDY_ID) AS "N_OPIOID_PRESCRIBERS" -- O2 # individuals with opioid prescriptions
  FROM src.FILLS
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
  WHERE drug_type = 'OPIOID'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "ENCOUNTERS_AGG";
CREATE TABLE "ENCOUNTERS_AGG" AS
  SELECT
    date(ADMIT_TIME, 'start of month') AS "PERIOD",
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(*) AS "N_OPIOID_OVERDOSES", -- O3 # opioid overdoses
    count(DISTINCT STUDY_ID) AS "N_OPIOID_OVERDOSERS" -- 03 # individuals that had opioid overdoses
  FROM src.ENCOUNTERS
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
  WHERE OPIOID_OD == 1
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_OPIOID";
CREATE TABLE "DIAGNOSES_AGG_OPIOID" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(*) AS "N_OPIOID_DX", -- O4 # opioid misuse diagnoses
    count(DISTINCT STUDY_ID) AS "N_OPIOID_DIAGNOSED" -- O4 # individuals diagnosed with opioid misuse
  FROM src.DIAGNOSES
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'OPIOID_USE_DX' --! OR DX_CODE_TYPE == 'SUBSTANCE_USE_DISORDER'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "PILL_IN_AGG";
CREATE TABLE "PILL_IN_AGG" AS
  SELECT
    date(TRANSACTION_DATE, 'start of month') AS "PERIOD",
    BUYER_TRACT_5 AS "TRACT_5", --! OR Reporter County?
    sum(QUANTITY) AS "N_PILLS_ISSUED" -- O5 # of pills issued
    --! count(DISTINCT (BUYER_NAME || BUYER_COUNTY)) AS "N_PILL_BUYERS" -- O5 # of pill buyers
  FROM src.PILL_IN
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "EMS_AGG";
CREATE TABLE "EMS_AGG" AS
  SELECT
    date(INC_INCIDENTDATE, 'start of month') AS "PERIOD",
    INC_TRACT_5 AS "TRACT_5",
    count(*) AS "N_NARCAN_RUNS", -- O6 # of Narcan runs
    count(DISTINCT INC_INCIDENTID) AS "N_NARCAN_INCIDENTS" -- O6 # of ems runs which administered Narcan
  FROM src.EMS
  WHERE NARCANRUN == 'Y'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


-- (C)omorbid events or comparison data elements --

DROP TABLE IF EXISTS "DIAGNOSES_AGG_STD";
CREATE TABLE "DIAGNOSES_AGG_STD" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(*) AS "N_STD_DX", -- C1 # of sexually transmitted diseases 
    count(DISTINCT STUDY_ID) AS "N_STD_DIAGNOSED" -- C1 # individuals diagnosed with sexually transmitted diseases 
  FROM src.DIAGNOSES
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'STD_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_HEPC";
CREATE TABLE "DIAGNOSES_AGG_HEPC" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(*) AS "N_HEPC_DX", -- C2 # of Hep C diagnoses
    count(DISTINCT STUDY_ID) AS "N_HEPC_DIAGNOSED" -- C2 # individuals diagnosed with Hep C
  FROM src.DIAGNOSES INNER JOIN src.LABS USING (STUDY_ID)
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'STD_DX' AND LAB_CODE_TYPE == 'HEP C LAB'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_HIV";
CREATE TABLE "DIAGNOSES_AGG_HIV" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(*) AS "N_HIV_DX", -- C3 # of HIV/AIDS diagnoses
    count(DISTINCT STUDY_ID) AS "N_HIV_DIAGNOSED" -- C3 # individuals diagnosed with HIV/AIDS
  FROM src.DIAGNOSES INNER JOIN src.LABS USING (STUDY_ID)
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'HIV_DX' AND LAB_CODE_TYPE == 'HIV LAB'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_MENTAL_DX";
CREATE TABLE "DIAGNOSES_AGG_MENTAL_DX" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(*) AS "N_MENTAL_DX", -- C4 # of mental health diagnoses
    count(DISTINCT STUDY_ID) AS "N_MENTAL_DIAGNOSED" -- C4 # individuals diagnosed with mental health disorders 
  FROM src.DIAGNOSES
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'ENCOUNTER_MENTAL_DX'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_SUD";
CREATE TABLE "DIAGNOSES_AGG_SUD" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    substr(TRACT_11, 0, 6) AS "TRACT_5",
    count(*) AS "N_SUD_DX", -- C5 # substance abuse diagnoses
    count(DISTINCT STUDY_ID) AS "N_SUD_DIAGNOSED" -- C5 # individuals diagnosed with substance abuse diagnoses
  FROM src.DIAGNOSES
    INNER JOIN src.DEMOGRAPHICS USING(STUDY_ID)
  WHERE DX_CODE_TYPE == 'SUBSTANCE_USE_DISORDER'
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


-- (D)emographic Data --

DROP TABLE IF EXISTS "ACS_AGG";
CREATE TABLE "ACS_AGG" AS
  SELECT
    date(cast(year as int) || '-01-01') AS "PERIOD",
    TRACT_5 AS "TRACT_5",
    sum(total_population) AS "TOTAL_POPULATION", -- D1
    sum(total_male) AS "TOTAL_MALE", -- D2
    sum(total_female) AS "TOTAL_FEMALE", -- D3
    sum(median_age) AS "MEDIAN_AGE", -- D4 
    sum(income_below_poverty_12month) AS "INCOME_BELOW_POVERTY_12MONTH", -- D5
    sum(cash_assistance_or_snap) AS "CASH_ASSISTANCE_OR_SNAP", -- D6
    sum(not_in_labor_force) AS "NOT_IN_LABOR_FORCE" -- D7
  FROM src.ACS
  GROUP BY tract_5, period
  ORDER BY period, tract_5;


-- Aggregate view
DROP TABLE IF EXISTS "ALL_AGGREGATES";
CREATE TABLE "ALL_AGGREGATES" AS
  SELECT *
  FROM
    -- (O)pioid related events --
    FILLS_AGG F
    LEFT JOIN ENCOUNTERS_AGG USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_OPIOID USING(tract_5, period)
    LEFT JOIN PILL_IN_AGG USING(tract_5, period)
    LEFT JOIN EMS_AGG USING(tract_5, period)
    -- (C)omorbid events or comparison data elements --
    LEFT JOIN DIAGNOSES_AGG_STD USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_HEPC USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_HIV USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_MENTAL_DX USING(tract_5, period)
    LEFT JOIN DIAGNOSES_AGG_SUD USING(tract_5, period)
    -- (D)emographic Data --
    LEFT JOIN ACS_AGG USING(tract_5, period)
  ORDER BY F.period, F.tract_5;
