-- Load Source Database --

ATTACH DATABASE 'raw-data/original/box-health/R2767_Data.db' AS src;

-- Utility tables
DROP TABLE IF EXISTS AGE_GROUPS;
CREATE TABLE AGE_GROUPS AS
  WITH RECURSIVE
    CNT(X) AS (
      SELECT 1
      UNION ALL
      SELECT X + 1
      FROM CNT
      LIMIT 120
    )
  SELECT
    X AS AGE,
    cast(X / 5 AS integer) AS AGE_GROUP,
    CASE
      WHEN X >= 90 THEN '90+'
      WHEN X < 5 THEN '1-4'
      ELSE (5 * cast(X / 5 AS integer)) || '-' || (5 * (cast(X / 5 AS integer) + 1) - 1)
    END AS AGE_GROUP_NAME
  FROM CNT;


-- Normalized demographics data
DROP TABLE IF EXISTS DEMOGRAPHICS_AND_CHRONIC;
CREATE TABLE DEMOGRAPHICS_AND_CHRONIC AS
  SELECT
    strftime('%Y', OPIOID_FILL_INDEX_DATE) || CASE
      WHEN cast(strftime('%m', OPIOID_FILL_INDEX_DATE) as integer) BETWEEN 1 AND 3 THEN '-01-01'
      WHEN cast(strftime('%m', OPIOID_FILL_INDEX_DATE) as integer) BETWEEN 4 and 6 THEN '-04-01'
      WHEN cast(strftime('%m', OPIOID_FILL_INDEX_DATE) as integer) BETWEEN 7 and 9 THEN '-07-01'
      ELSE '-10-01'
    END AS PERIOD, -- Quarterly Period
    STUDY_ID,
    AGE_AT_INDEX_FILL AS AGE,
    AGE_GROUP,
    AGE_GROUP_NAME,
    CASE GENDER
      WHEN 'F' THEN 'Female'
      WHEN 'M' THEN 'Male'
      ELSE 'Gender Unspecified'
    END AS GENDER,
    CASE
      WHEN RACE IS NULL OR RACE = '' OR RACE = 'OTHER' THEN 'Other Race'
      ELSE RACE
    END AS RACE,
    ifnull(THREE_FILL_FLAG, 0) AS IS_CHRONIC
  FROM DEMOGRAPHICS
  JOIN AGE_GROUPS ON cast(AGE_AT_INDEX_FILL as integer) = AGE
  ORDER BY PERIOD;

DROP INDEX IF EXISTS IDX_DEMOGRAPHICS_AND_CHRONIC;
CREATE INDEX IDX_DEMOGRAPHICS_AND_CHRONIC ON DEMOGRAPHICS_AND_CHRONIC(PERIOD);


-- Aggregate tables

-- General demographics
DROP TABLE IF EXISTS DEMOGRAPHICS_AGG;
CREATE TABLE DEMOGRAPHICS_AGG AS
  SELECT
    PERIOD,
    COUNT(DISTINCT STUDY_ID) AS N_PERSONS
  FROM DEMOGRAPHICS_AND_CHRONIC
  GROUP BY PERIOD;

DROP INDEX IF EXISTS IDX_DEMOGRAPHICS_AGG;
CREATE INDEX IDX_DEMOGRAPHICS_AGG ON DEMOGRAPHICS_AGG(PERIOD);

DROP TABLE IF EXISTS DEMOGRAPHICS_AGG_CHRONIC;
CREATE TABLE DEMOGRAPHICS_AGG_CHRONIC AS
  SELECT
    PERIOD,
    COUNT(DISTINCT STUDY_ID) AS N_PERSONS_CHRONIC
  FROM DEMOGRAPHICS_AND_CHRONIC
  WHERE IS_CHRONIC = 1
  GROUP BY PERIOD;

DROP INDEX IF EXISTS IDX_DEMOGRAPHICS_AGG_CHRONIC;
CREATE INDEX IDX_DEMOGRAPHICS_AGG_CHRONIC ON DEMOGRAPHICS_AGG_CHRONIC(PERIOD);

DROP TABLE IF EXISTS DEMOGRAPHICS_AGG_NON_CHRONIC;
CREATE TABLE DEMOGRAPHICS_AGG_NON_CHRONIC AS
  SELECT
    PERIOD,
    COUNT(DISTINCT STUDY_ID) AS N_PERSONS_NON_CHRONIC
  FROM DEMOGRAPHICS_AND_CHRONIC
  WHERE IS_CHRONIC = 0
  GROUP BY PERIOD;

DROP INDEX IF EXISTS IDX_DEMOGRAPHICS_AGG_NON_CHRONIC;
CREATE INDEX IDX_DEMOGRAPHICS_AGG_NON_CHRONIC ON DEMOGRAPHICS_AGG_NON_CHRONIC(PERIOD);


-- Age demographics
DROP TABLE IF EXISTS AGE_AGG;
CREATE TABLE AGE_AGG AS
  SELECT
    PERIOD,
    AGE_GROUP,
    AGE_GROUP_NAME,
    count(DISTINCT STUDY_ID) AS N_AGE
  FROM DEMOGRAPHICS_AND_CHRONIC
  GROUP BY PERIOD, AGE_GROUP;

DROP INDEX IF EXISTS IDX_AGE_AGG;
CREATE INDEX IDX_AGE_AGG ON AGE_AGG(PERIOD, AGE_GROUP);

DROP TABLE IF EXISTS AGE_AGG_CHRONIC;
CREATE TABLE AGE_AGG_CHRONIC AS
  SELECT
    PERIOD,
    AGE_GROUP,
    count(DISTINCT STUDY_ID) AS N_AGE_CHRONIC
  FROM DEMOGRAPHICS_AND_CHRONIC
  WHERE IS_CHRONIC = 1
  GROUP BY PERIOD, AGE_GROUP;

DROP INDEX IF EXISTS IDX_AGE_AGG_CHRONIC;
CREATE INDEX IDX_AGE_AGG_CHRONIC ON AGE_AGG_CHRONIC(PERIOD, AGE_GROUP);

DROP TABLE IF EXISTS AGE_AGG_NON_CHRONIC;
CREATE TABLE AGE_AGG_NON_CHRONIC AS
  SELECT
    PERIOD,
    AGE_GROUP,
    count(DISTINCT STUDY_ID) AS N_AGE_NON_CHRONIC
  FROM DEMOGRAPHICS_AND_CHRONIC
  WHERE IS_CHRONIC = 0
  GROUP BY PERIOD, AGE_GROUP;

DROP INDEX IF EXISTS IDX_AGE_AGG_NON_CHRONIC;
CREATE INDEX IDX_AGE_AGG_NON_CHRONIC ON AGE_AGG_NON_CHRONIC(PERIOD, AGE_GROUP);


-- Gender demographics
DROP TABLE IF EXISTS GENDER_AGG;
CREATE TABLE GENDER_AGG AS
  SELECT
    PERIOD,
    GENDER,
    count(DISTINCT STUDY_ID) AS N_GENDER
  FROM DEMOGRAPHICS_AND_CHRONIC
  GROUP BY PERIOD, GENDER;

DROP INDEX IF EXISTS IDX_GENDER_AGG;
CREATE INDEX IDX_GENDER_AGG ON GENDER_AGG(PERIOD, GENDER);

DROP TABLE IF EXISTS GENDER_AGG_CHRONIC;
CREATE TABLE GENDER_AGG_CHRONIC AS
  SELECT
    PERIOD,
    GENDER,
    count(DISTINCT STUDY_ID) AS N_GENDER_CHRONIC
  FROM DEMOGRAPHICS_AND_CHRONIC
  WHERE IS_CHRONIC = 1
  GROUP BY PERIOD, GENDER;

DROP INDEX IF EXISTS IDX_GENDER_AGG_CHRONIC;
CREATE INDEX IDX_GENDER_AGG_CHRONIC ON GENDER_AGG_CHRONIC(PERIOD, GENDER);

DROP TABLE IF EXISTS GENDER_AGG_NON_CHRONIC;
CREATE TABLE GENDER_AGG_NON_CHRONIC AS
  SELECT
    PERIOD,
    GENDER,
    count(DISTINCT STUDY_ID) AS N_GENDER_NON_CHRONIC
  FROM DEMOGRAPHICS_AND_CHRONIC
  WHERE IS_CHRONIC = 0
  GROUP BY PERIOD, GENDER;

DROP INDEX IF EXISTS IDX_GENDER_AGG_NON_CHRONIC;
CREATE INDEX IDX_GENDER_AGG_NON_CHRONIC ON GENDER_AGG_NON_CHRONIC(PERIOD, GENDER);


-- Race demographics
DROP TABLE IF EXISTS RACE_AGG;
CREATE TABLE RACE_AGG AS
  SELECT
    PERIOD,
    RACE,
    count(DISTINCT STUDY_ID) AS N_RACE
  FROM DEMOGRAPHICS_AND_CHRONIC
  GROUP BY PERIOD, RACE;

DROP INDEX IF EXISTS IDX_RACE_AGG;
CREATE INDEX IDX_RACE_AGG ON RACE_AGG(PERIOD, RACE);

DROP TABLE IF EXISTS RACE_AGG_CHRONIC;
CREATE TABLE RACE_AGG_CHRONIC AS
  SELECT
    PERIOD,
    RACE,
    count(DISTINCT STUDY_ID) AS N_RACE_CHRONIC
  FROM DEMOGRAPHICS_AND_CHRONIC
  WHERE IS_CHRONIC = 1
  GROUP BY PERIOD, RACE;

DROP INDEX IF EXISTS IDX_RACE_AGG_CHRONIC;
CREATE INDEX IDX_RACE_AGG_CHRONIC ON RACE_AGG_CHRONIC(PERIOD, RACE);

DROP TABLE IF EXISTS RACE_AGG_NON_CHRONIC;
CREATE TABLE RACE_AGG_NON_CHRONIC AS
  SELECT
    PERIOD,
    RACE,
    count(DISTINCT STUDY_ID) AS N_RACE_NON_CHRONIC
  FROM DEMOGRAPHICS_AND_CHRONIC
  WHERE IS_CHRONIC = 0
  GROUP BY PERIOD, RACE;

DROP INDEX IF EXISTS IDX_RACE_AGG_NON_CHRONIC;
CREATE INDEX IDX_RACE_AGG_NON_CHRONIC ON RACE_AGG_NON_CHRONIC(PERIOD, RACE);


-- Helper tables
DROP TABLE IF EXISTS ALL_AGE_AGGREGATES;
CREATE TABLE ALL_AGE_AGGREGATES AS
  SELECT *
  FROM
    AGE_AGG
    LEFT JOIN AGE_AGG_CHRONIC USING(PERIOD, AGE_GROUP)
    LEFT JOIN AGE_AGG_NON_CHRONIC USING(PERIOD, AGE_GROUP);

DROP TABLE IF EXISTS ALL_GENDER_AGGREGATES;
CREATE TABLE ALL_GENDER_AGGREGATES AS
  SELECT *
  FROM
    GENDER_AGG
    LEFT JOIN GENDER_AGG_CHRONIC USING(PERIOD, GENDER)
    LEFT JOIN GENDER_AGG_NON_CHRONIC USING(PERIOD, GENDER);

DROP TABLE IF EXISTS ALL_RACE_AGGREGATES;
CREATE TABLE ALL_RACE_AGGREGATES AS
  SELECT *
  FROM
    RACE_AGG
    LEFT JOIN RACE_AGG_CHRONIC USING(PERIOD, RACE)
    LEFT JOIN RACE_AGG_NON_CHRONIC USING(PERIOD, RACE);


-- Result tables
DROP TABLE IF EXISTS ALL_AGGREGATES;
CREATE TABLE ALL_AGGREGATES AS
  SELECT *
  FROM
    DEMOGRAPHICS_AGG
    LEFT JOIN DEMOGRAPHICS_AGG_CHRONIC USING(PERIOD)
    LEFT JOIN DEMOGRAPHICS_AGG_NON_CHRONIC USING(PERIOD)
    LEFT JOIN ALL_AGE_AGGREGATES USING(PERIOD)
    LEFT JOIN ALL_GENDER_AGGREGATES USING(PERIOD)
    LEFT JOIN ALL_RACE_AGGREGATES USING(PERIOD)
  WHERE cast(strftime('%Y', PERIOD) AS integer) BETWEEN 2009 AND 2018;

DROP TABLE IF EXISTS ALL_AGGREGATES_ROW_BASED;
CREATE TABLE ALL_AGGREGATES_ROW_BASED AS
  SELECT *
  FROM (
    -- Age
    SELECT
      PERIOD,
      'All' AS COHORT,
      AGE_GROUP_NAME AS DATA_VARIABLE,
      100 * cast(N_AGE AS real) / N_PERSONS AS VALUE,
      CASE
        WHEN N_AGE BETWEEN 1 AND 9 THEN 10
        ELSE N_AGE
      END AS TOOLTIP
    FROM ALL_AGGREGATES
    GROUP BY PERIOD, AGE_GROUP_NAME
  UNION ALL
    SELECT
      PERIOD,
      'Chronic' AS COHORT,
      AGE_GROUP_NAME AS DATA_VARIABLE,
      100 * cast(N_AGE_CHRONIC AS real) / N_PERSONS_CHRONIC AS VALUE,
      CASE
        WHEN N_AGE_CHRONIC BETWEEN 1 AND 9 THEN 10
        ELSE N_AGE_CHRONIC
      END AS TOOLTIP
    FROM ALL_AGGREGATES
    GROUP BY PERIOD, AGE_GROUP_NAME
  UNION ALL
    SELECT
      PERIOD,
      'Non-chronic' AS COHORT,
      AGE_GROUP_NAME AS DATA_VARIABLE,
      100 * cast(N_AGE_NON_CHRONIC AS real) / N_PERSONS_CHRONIC AS VALUE,
      CASE
        WHEN N_AGE_NON_CHRONIC BETWEEN 1 AND 9 THEN 10
        ELSE N_AGE_NON_CHRONIC
      END AS TOOLTIP
    FROM ALL_AGGREGATES
    GROUP BY PERIOD, AGE_GROUP_NAME
  UNION ALL
    -- Gender
    SELECT
      PERIOD,
      'All' AS COHORT,
      GENDER AS DATA_VARIABLE,
      100 * cast(N_GENDER AS real) / N_PERSONS AS VALUE,
      CASE
        WHEN N_GENDER BETWEEN 1 AND 9 THEN 10
        ELSE N_GENDER
      END AS TOOLTIP
    FROM ALL_AGGREGATES
    GROUP BY PERIOD, GENDER
  UNION ALL
    SELECT
      PERIOD,
      'Chronic' AS COHORT,
      GENDER AS DATA_VARIABLE,
      100 * cast(N_GENDER_CHRONIC AS real) / N_PERSONS_CHRONIC AS VALUE,
      CASE
        WHEN N_GENDER_CHRONIC BETWEEN 1 AND 9 THEN 10
        ELSE N_GENDER_CHRONIC
      END AS TOOLTIP
    FROM ALL_AGGREGATES
    GROUP BY PERIOD, GENDER
  UNION ALL
    SELECT
      PERIOD,
      'Non-chronic' AS COHORT,
      GENDER AS DATA_VARIABLE,
      100 * cast(N_GENDER_NON_CHRONIC AS real) / N_PERSONS_CHRONIC AS VALUE,
      CASE
        WHEN N_GENDER_NON_CHRONIC BETWEEN 1 AND 9 THEN 10
        ELSE N_GENDER_NON_CHRONIC
      END AS TOOLTIP
    FROM ALL_AGGREGATES
    GROUP BY PERIOD, GENDER
  UNION ALL
    -- Race
    SELECT
      PERIOD,
      'All' AS COHORT,
      RACE AS DATA_VARIABLE,
      100 * cast(N_RACE AS real) / N_PERSONS AS VALUE,
      CASE
        WHEN N_RACE BETWEEN 1 AND 9 THEN 10
        ELSE N_RACE
      END AS TOOLTIP
    FROM ALL_AGGREGATES
    GROUP BY PERIOD, RACE
  UNION ALL
    SELECT
      PERIOD,
      'Chronic' AS COHORT,
      RACE AS DATA_VARIABLE,
      100 * cast(N_RACE_CHRONIC AS real) / N_PERSONS_CHRONIC AS VALUE,
      CASE
        WHEN N_RACE_CHRONIC BETWEEN 1 AND 9 THEN 10
        ELSE N_RACE_CHRONIC
      END AS TOOLTIP
    FROM ALL_AGGREGATES
    GROUP BY PERIOD, RACE
  UNION ALL
    SELECT
      PERIOD,
      'Non-chronic' AS COHORT,
      RACE AS DATA_VARIABLE,
      100 * cast(N_RACE_NON_CHRONIC AS real) / N_PERSONS_CHRONIC AS VALUE,
      CASE
        WHEN N_RACE_NON_CHRONIC BETWEEN 1 AND 9 THEN 10
        ELSE N_RACE_NON_CHRONIC
      END AS TOOLTIP
    FROM ALL_AGGREGATES
    GROUP BY PERIOD, RACE
  )
  WHERE cast(strftime('%Y', PERIOD) AS integer) BETWEEN 2009 AND 2018
  ORDER BY DATA_VARIABLE, PERIOD;
