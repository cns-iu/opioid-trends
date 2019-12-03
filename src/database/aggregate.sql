CREATE TEMP TABLE FILLS_AGG AS SELECT
  date(FILL_DATE, 'start of month') AS period,
  count(*) AS n_prescriptions, -- # opioid prescriptions
  count(DISTINCT STUDY_ID) AS n_individuals -- # individuals with opioid prescriptions
FROM FILLS
GROUP BY period;

CREATE TEMP TABLE ENCOUNTERS_AGG AS SELECT
  date(ADMIT_TIME, 'start of month') AS period,
  sum(OPIOID_OD == 1) AS n_overdoses -- # opioid overdoses
FROM ENCOUNTERS
GROUP BY period;

CREATE TEMP TABLE DIAGNOSES_AGG AS SELECT
  date(DX_DATE, 'start of month') AS period,
  sum(DX_CODE_TYPE == 'OPIOID_USE_DX') AS n_opioid, -- # opioid abuse disorder diagnoses
  sum(DX_CODE_TYPE == 'STD_DX') AS n_std, -- # std diagnoses
  sum(DX_CODE_TYPE == 'STD_DX' AND LAB_CODE_TYPE == 'HEP C LAB'), -- # hep-c std diagnoses
  sum(DX_CODE_TYPE == 'STD_DX' AND LAB_CODE_TYPE == 'HIV LAB'), -- # hiv std diagnoses
  sum(DX_CODE_TYPE == 'ENCOUNTER_MENTAL_DX') AS n_mental, -- # mental diagnoses
  sum(DX_CODE_TYPE == 'SUBSTANCE_USE_DISORDER') AS n_substance -- # substance disorders
FROM DIAGNOSES INNER JOIN LABS USING (STUDY_ID)
GROUP BY period;

CREATE TEMP TABLE PILL_IN_AGG AS SELECT
  -- What is the date field? TRANSACTION_DATE?
  sum(QUANTITY) AS quantity
FROM PILL_IN;

CREATE TEMP TABLE EMS_AGG AS SELECT
  date(INC_INCIDENTDATE, 'start of month') AS period,
  sum(NARCANRUN == 'Y') AS n_narcan_runs -- # ems run with Narcan
FROM EMS
GROUP BY period;

-- Aggregate view
CREATE TEMP VIEW ALL_AGGREGATES AS SELECT
FROM FILLS_AGG; -- FIXME: left join all *_AGG tables using period

SELECT * FROM ALL_AGGREGATES ORDER BY period;
