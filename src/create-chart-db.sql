-- Load Source Database --

ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;
-- ATTACH DATABASE ':memory:' AS src;
-- .restore 'src' 'raw-data/original/box-health/R2767_Data.db';


-- (O)pioid related events --

DROP TABLE IF EXISTS "FILLS_AGG";
CREATE TABLE "FILLS_AGG" AS
  SELECT
    date(FILL_DATE, 'start of month') AS "PERIOD",
    count(*) AS "N_OPIOID_PRESCRIPTIONS", -- O1 # opioid prescriptions
    count(DISTINCT STUDY_ID) AS "N_OPIOID_PRESCRIBERS" -- O2 # individuals with opioid prescriptions
  FROM src.FILLS
  WHERE drug_type = 'OPIOID'
  GROUP BY period
  ORDER BY period;


DROP TABLE IF EXISTS "ENCOUNTERS_AGG";
CREATE TABLE "ENCOUNTERS_AGG" AS
  SELECT
    date(ADMIT_TIME, 'start of month') AS "PERIOD",
    count(*) AS "N_OPIOID_OVERDOSES", -- O3 # opioid overdoses
    count(DISTINCT STUDY_ID) AS "N_OPIOID_OVERDOSERS" -- 03 # individuals that had opioid overdoses
  FROM src.ENCOUNTERS
  WHERE OPIOID_OD == 1
  GROUP BY period
  ORDER BY period;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_OPIOID";
CREATE TABLE "DIAGNOSES_AGG_OPIOID" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    count(*) AS "N_OPIOID_DX", -- O4 # opioid misuse diagnoses
    count(DISTINCT STUDY_ID) AS "N_OPIOID_DIAGNOSED" -- O4 # individuals diagnosed with opioid misuse
  FROM src.DIAGNOSES
  WHERE DX_CODE_TYPE == 'OPIOID_USE_DX' --! OR DX_CODE_TYPE == 'SUBSTANCE_USE_DISORDER'
  GROUP BY period
  ORDER BY period;


DROP TABLE IF EXISTS "PILL_IN_AGG";
CREATE TABLE "PILL_IN_AGG" AS
  SELECT
    date(TRANSACTION_DATE, 'start of month') AS "PERIOD",
    sum(QUANTITY) AS "N_PILLS_ISSUED" -- O5 # of pills issued
    --! count(DISTINCT (BUYER_NAME || BUYER_COUNTY)) AS "N_PILL_BUYERS" -- O5 # of pill buyers
  FROM src.PILL_IN
  GROUP BY period
  ORDER BY period;


DROP TABLE IF EXISTS "EMS_AGG";
CREATE TABLE "EMS_AGG" AS
  SELECT
    date(INC_INCIDENTDATE, 'start of month') AS "PERIOD",
    count(*) AS "N_NARCAN_RUNS", -- O6 # of Narcan runs
    count(DISTINCT INC_INCIDENTID) AS "N_NARCAN_INCIDENTS" -- O6 # of ems runs which administered Narcan
  FROM src.EMS
  WHERE NARCANRUN == 'Y'
  GROUP BY period
  ORDER BY period;


-- (C)omorbid events or comparison data elements --

DROP TABLE IF EXISTS "DIAGNOSES_AGG_STD";
CREATE TABLE "DIAGNOSES_AGG_STD" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    count(*) AS "N_STD_DX", -- C1 # of sexually transmitted diseases
    count(DISTINCT STUDY_ID) AS "N_STD_DIAGNOSED" -- C1 # individuals diagnosed with sexually transmitted diseases
  FROM src.DIAGNOSES
  WHERE DX_CODE_TYPE == 'STD_DX'
  GROUP BY period
  ORDER BY period;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_HEPC";
CREATE TABLE "DIAGNOSES_AGG_HEPC" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    count(*) AS "N_HEPC_DX", -- C2 # of Hep C diagnoses
    count(DISTINCT STUDY_ID) AS "N_HEPC_DIAGNOSED" -- C2 # individuals diagnosed with Hep C
  FROM src.DIAGNOSES INNER JOIN src.LABS USING (STUDY_ID)
  WHERE DX_CODE_TYPE == 'STD_DX' AND LAB_CODE_TYPE == 'HEP C LAB'
  GROUP BY period
  ORDER BY period;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_HIV";
CREATE TABLE "DIAGNOSES_AGG_HIV" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    count(*) AS "N_HIV_DX", -- C3 # of HIV/AIDS diagnoses
    count(DISTINCT STUDY_ID) AS "N_HIV_DIAGNOSED" -- C3 # individuals diagnosed with HIV/AIDS
  FROM src.DIAGNOSES INNER JOIN src.LABS USING (STUDY_ID)
  WHERE DX_CODE_TYPE == 'HIV_DX' AND LAB_CODE_TYPE == 'HIV LAB'
  GROUP BY period
  ORDER BY period;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_MENTAL_DX";
CREATE TABLE "DIAGNOSES_AGG_MENTAL_DX" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    count(*) AS "N_MENTAL_DX", -- C4 # of mental health diagnoses
    count(DISTINCT STUDY_ID) AS "N_MENTAL_DIAGNOSED" -- C4 # individuals diagnosed with mental health disorders
  FROM src.DIAGNOSES
  WHERE DX_CODE_TYPE == 'ENCOUNTER_MENTAL_DX'
  GROUP BY period
  ORDER BY period;


DROP TABLE IF EXISTS "DIAGNOSES_AGG_SUD";
CREATE TABLE "DIAGNOSES_AGG_SUD" AS
  SELECT
    date(DX_DATE, 'start of month') AS "PERIOD",
    count(*) AS "N_SUD_DX", -- C5 # substance abuse diagnoses
    count(DISTINCT STUDY_ID) AS "N_SUD_DIAGNOSED" -- C5 # individuals diagnosed with substance abuse diagnoses
  FROM src.DIAGNOSES
  WHERE DX_CODE_TYPE == 'SUBSTANCE_USE_DISORDER'
  GROUP BY period
  ORDER BY period;


-- (D)emographic Data --

DROP TABLE IF EXISTS "ACS_AGG";
CREATE TABLE "ACS_AGG" AS
  SELECT
    date(cast(year as int) || '-01-01') as "PERIOD",
    sum(total_population) AS "TOTAL_POPULATION", -- D1
    sum(total_male) AS "TOTAL_MALE", -- D2
    sum(total_female) AS "TOTAL_FEMALE", -- D3
    sum(median_age) AS "MEDIAN_AGE", -- D4
    sum(income_below_poverty_12month) AS "INCOME_BELOW_POVERTY_12MONTH", -- D5
    sum(cash_assistance_or_snap) AS "CASH_ASSISTANCE_OR_SNAP", -- D6
    sum(not_in_labor_force) AS "NOT_IN_LABOR_FORCE" -- D7
  FROM src.ACS
  GROUP BY period
  ORDER BY period;


-- Aggregate view
DROP TABLE IF EXISTS "ALL_AGGREGATES";
CREATE TABLE "ALL_AGGREGATES" AS
  SELECT *
  FROM
    -- (O)pioid related events --
    FILLS_AGG AS F
    LEFT JOIN ENCOUNTERS_AGG USING(period)
    LEFT JOIN DIAGNOSES_AGG_OPIOID USING(period)
    LEFT JOIN PILL_IN_AGG USING(period)
    LEFT JOIN EMS_AGG USING(period)
    -- (C)omorbid events or comparison data elements --
    LEFT JOIN DIAGNOSES_AGG_STD USING(period)
    LEFT JOIN DIAGNOSES_AGG_HEPC USING(period)
    LEFT JOIN DIAGNOSES_AGG_HIV USING(period)
    LEFT JOIN DIAGNOSES_AGG_MENTAL_DX USING(period)
    LEFT JOIN DIAGNOSES_AGG_SUD USING(period)
    -- (D)emographic Data --
    LEFT JOIN ACS_AGG USING(period)
  ORDER BY F.period;

DROP TABLE IF EXISTS "ALL_AGGREGATES_ROW_BASED";
CREATE TABLE "ALL_AGGREGATES_ROW_BASED" AS
    SELECT
      PERIOD,
      'N_OPIOID_PRESCRIPTIONS' AS "VARIABLE",
      N_OPIOID_PRESCRIPTIONS AS "VALUE"
    FROM FILLS_AGG
  UNION ALL
    SELECT
      PERIOD,
      'N_OPIOID_PRESCRIBERS' AS "VARIABLE",
      N_OPIOID_PRESCRIBERS AS "VALUE"
    FROM FILLS_AGG
  UNION ALL
    SELECT
      PERIOD,
      'N_OPIOID_OVERDOSES' AS "VARIABLE",
      N_OPIOID_OVERDOSES AS "VALUE"
    FROM ENCOUNTERS_AGG
  UNION ALL
    SELECT
      PERIOD,
      'N_OPIOID_OVERDOSERS' AS "VARIABLE",
      N_OPIOID_OVERDOSERS AS "VALUE"
    FROM ENCOUNTERS_AGG
  UNION ALL
    SELECT
      PERIOD,
      'N_OPIOID_DX' AS "VARIABLE",
      N_OPIOID_DX AS "VALUE"
    FROM DIAGNOSES_AGG_OPIOID
  UNION ALL
    SELECT
      PERIOD,
      'N_OPIOID_DIAGNOSED' AS "VARIABLE",
      N_OPIOID_DIAGNOSED AS "VALUE"
    FROM DIAGNOSES_AGG_OPIOID
  UNION ALL
    SELECT
      PERIOD,
      'N_PILLS_ISSUED' AS "VARIABLE",
      N_PILLS_ISSUED AS "VALUE"
    FROM PILL_IN_AGG
  UNION ALL
    SELECT
      PERIOD,
      'N_NARCAN_RUNS' AS "VARIABLE",
      N_NARCAN_RUNS AS "VALUE"
    FROM EMS_AGG
  UNION ALL
    SELECT
      PERIOD,
      'N_NARCAN_INCIDENTS' AS "VARIABLE",
      N_NARCAN_INCIDENTS AS "VALUE"
    FROM EMS_AGG
  UNION ALL
    SELECT
      PERIOD,
      'N_STD_DX' AS "VARIABLE",
      N_STD_DX AS "VALUE"
    FROM DIAGNOSES_AGG_STD
  UNION ALL
    SELECT
      PERIOD,
      'N_STD_DIAGNOSED' AS "VARIABLE",
      N_STD_DIAGNOSED AS "VALUE"
    FROM DIAGNOSES_AGG_STD
  UNION ALL
    SELECT
      PERIOD,
      'N_HEPC_DX' AS "VARIABLE",
      N_HEPC_DX AS "VALUE"
    FROM DIAGNOSES_AGG_HEPC
  UNION ALL
    SELECT
      PERIOD,
      'N_HEPC_DIAGNOSED' AS "VARIABLE",
      N_HEPC_DIAGNOSED AS "VALUE"
    FROM DIAGNOSES_AGG_HEPC
  UNION ALL
    SELECT
      PERIOD,
      'N_HIV_DX' AS "VARIABLE",
      N_HIV_DX AS "VALUE"
    FROM DIAGNOSES_AGG_HIV
  UNION ALL
    SELECT
      PERIOD,
      'N_HIV_DIAGNOSED' AS "VARIABLE",
      N_HIV_DIAGNOSED AS "VALUE"
    FROM DIAGNOSES_AGG_HIV
  UNION ALL
    SELECT
      PERIOD,
      'N_MENTAL_DX' AS "VARIABLE",
      N_MENTAL_DX AS "VALUE"
    FROM DIAGNOSES_AGG_MENTAL_DX
  UNION ALL
    SELECT
      PERIOD,
      'N_MENTAL_DIAGNOSED' AS "VARIABLE",
      N_MENTAL_DIAGNOSED AS "VALUE"
    FROM DIAGNOSES_AGG_MENTAL_DX
  UNION ALL
    SELECT
      PERIOD,
      'N_SUD_DX' AS "VARIABLE",
      N_SUD_DX AS "VALUE"
    FROM DIAGNOSES_AGG_SUD
  UNION ALL
    SELECT
      PERIOD,
      'N_SUD_DIAGNOSED' AS "VARIABLE",
      N_SUD_DIAGNOSED AS "VALUE"
    FROM DIAGNOSES_AGG_SUD
  ORDER BY variable, period;
