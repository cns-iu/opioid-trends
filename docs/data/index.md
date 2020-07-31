# Generated Data

Data was extracted from an IADC Database provided by the [Regenstrief Institute](https://www.regenstrief.org/). See [Sources](../sources/index.md) for details.

## Opioid Trends Over Time, Opioid Trends on the Indiana Map

### Data Variables

From the raw data, we compiled a number of data variables to visualize. This metadata can be found [here](data-variables.csv).

DATA_VARIABLE | LABEL | TYPE | SCALE
--------------|-------|------|-------
N_OPIOID_PRESCRIPTIONS | # of opioid prescriptions | Opioid related events | Events
N_OPIOID_PRESCRIBERS | # who had opioid prescriptions | Opioid related events | Persons
N_OPIOID_OVERDOSES | # of opioid overdoses | Opioid related events | Events
N_OPIOID_OVERDOSERS | # who had opioid overdoses | Opioid related events | Persons
N_OPIOID_DX | # of opioid misuse diagnoses | Opioid related events | Events
N_OPIOID_DIAGNOSED | # who had opioid misuse diagnosed | Opioid related events | Persons
N_PILLS_ISSUED | # of pills issued | Opioid related events | Pills
N_NARCAN_RUNS | # of times narcan was used during an EMS run | Opioid related events | Events
N_NARCAN_INCIDENTS | # incidents where narcan was used during an EMS run | Opioid related events | Events
N_STD_DX | # of STDs diagnosed | Comorbid events | Events
N_STD_DIAGNOSED | # who had an STD diagnoses | Comorbid events | Persons
N_HEPC_DX | # of Hepatitus C diagnoses | Comorbid events | Events
N_HEPC_DIAGNOSED | # who had a Hepatitus C diagnosis | Comorbid events | Persons
N_HIV_DX | # of HIV/AIDS diagnoses | Comorbid events | Events
N_HIV_DIAGNOSED | # who had an HIV/AIDS diagnosis | Comorbid events | Persons
N_MENTAL_DX | # of mental health diagnoses | Comorbid events | Events
N_MENTAL_DIAGNOSED | # who had a mental health diagnosis | Comorbid events | Persons
N_SUD_DX | # of substance use disorder diagnoses | Comorbid events | Events
N_SUD_DIAGNOSED | # who had a substance use disorder diagnosis | Comorbid events | Persons
TOTAL_POPULATION | # who were residents | Demographic data | Persons
TOTAL_MALE | # who were male residents | Demographic data | Persons
TOTAL_FEMALE | # who were female residents | Demographic data | Persons
MEDIAN_AGE | Median age of residents | Demographic data | Age
INCOME_BELOW_POVERTY_12MONTH | # who had income below poverty level within 12 months | Demographic data | Persons
CASH_ASSISTANCE_OR_SNAP | # who had cash asistance or SNAP | Demographic data | Persons
NOT_IN_LABOR_FORCE | # who were not in the labor force | Demographic data | Persons

### Chart Data (Opioid Trends Over Time)

For the chart data, we computed the data variable values by grouping by the minimum periodicity (currently quarterly intervals) and computed the values of the data variables in each period. The chart data exists in both [column](chart-data.csv) and [row](chart-data-row-based.csv) based formats.

The SQL commands that compiled the data are [here](https://github.com/cns-iu/opioid-trends/blob/master/src/create-chart-db.sql) and the script to extract the data to CSV is [here](https://github.com/cns-iu/opioid-trends/blob/master/scripts/10-extract-chart-data.sh).

### Map Data (Opioid Trends on the Indiana Map)

For the geographic map of indiana, we further grouped by county (TRACT_5) so that we can see how the data variables play out at the county level. The map data exists in both [column](geomap-data.csv) and [row](geomap-data-row-based.csv) based formats. A topojson file for the state of Indiana is available [here](indiana.topojson).

The SQL commands that compiled the data are [here](https://github.com/cns-iu/opioid-trends/blob/master/src/create-geomap-db.sql) and the script to extract the data to CSV is [here](https://github.com/cns-iu/opioid-trends/blob/master/scripts/10-extract-geomap-data.sh).

## Cohort Visualizations (Demographics, Diagnosis, Fills, Encounters, Labs)

For each of these visualizations, patient data from January 1, 2005 through April 30, 2019 was grouped into three different cohorts:

* All: All patients in the time period
* Chronic Opioid Use: Received 3+ opioid prescriptions (non-hospital) within 120 days
* Non-chronic (Other Opioid Use): Received only 1 opioid non-hospital prescription in a 12-month period

Data variable values were grouped and calculated according to the minimum periodicity (quarterly intervals). Percentage values were determined by the number of unique patients fitting the criteria out of the set of unique patients for each cohort.

### Demographics

The goal of this visualization is to provide information on the gender, ethnicity, and age distributions across each cohort.

DATA_VARIABLE | TYPE
--------------|------
Gender Unspecified | Gender
Female | Gender
Male | Gender
AMERICAN INDIAN AND ALASKA NATIVE | Race/ethnicity
ASIAN | Race/ethnicity
BLACK OR AFRICAN AMERICAN | Race/ethnicity
HISPANIC OR LATINO | Race/ethnicity
MULTIRACIAL | Race/ethnicity
NATIVE HAWAIIAN AND OTHER PACIFIC ISLANDER | Race/ethnicity
WHITE | Race/ethnicity
Other Race | Race/ethnicity
1-4 --> 90+ | Age (5-year intervals)

[Column-based data](demographics-data.csv)  
[Row-based data](demographics-data-row-based.csv)  
[SQL](https://github.com/cns-iu/opioid-trends/blob/master/src/create-demographics-db.sql)  
[Script](https://github.com/cns-iu/opioid-trends/blob/master/scripts/10-extract-demographics-data.sh)  

### Diagnosis

The goal of this visualization is to show the percent of individuals across each cohort who have had 1 or more of the following diagnoses.

DATA_VARIABLE | Description
--------------|------------
Alcohol poisoning | (%)Alcohol poisoning
Benzo poisoning | (%)Benzo poisoning
Mental Health | (%)Mental Health
HIV | (%)HIV
Drug poisoning | (%)Illicit drug poisoning
Opioid poisoning | (%)Opioid poisoning
Opioid use | (%)Opioid use
Other poisoning | (%)Other poisoning
Overdose| (%)Overdose (any kind, not opioid specific)
STD | (%)Sexually transmitted disease
Stimulant poisoning | (%)Stimulant poisoning
Substance use disorder | (%)Substance use disorder

[Column-based data](diagnosis-data.csv)  
[Row-based data](diagnosis-data-row-based.csv)  
[SQL](https://github.com/cns-iu/opioid-trends/blob/master/src/create-diagnosis-db.sql)  
[Script](https://github.com/cns-iu/opioid-trends/blob/master/scripts/10-extract-diagnosis-data.sh)  

### Fills

The goal of this visualization is to show the distribution of prescribed medication types across each cohort.

DATA_VARIABLE | Description
--------------|------------
Anti-Anxiety | (%) Anti-Anxiety
Anti-depressant | (%) Anti-depressant
Neuro | (%) Neurological agent

[Column-based data](fills-data.csv)  
[Row-based data](fills-data-row-based.csv)  
[SQL](https://github.com/cns-iu/opioid-trends/blob/master/src/create-fills-db.sql)  
[Script](https://github.com/cns-iu/opioid-trends/blob/master/scripts/10-extract-fills-data.sh)  

### Encounters

The goal of this visualization is to show the distribution of encounter types (Emergency or Inpatient) across each cohort, along with the average number of encounters within the different encounter types. We also analyzed the distribution of insurance data in each cohort.

DATA_VARIABLE |
--------------|
Avg. # Emergency Encounters |
% with Emergency Encounters |
Avg. # Inpatient Encounters |
% with Inpatient Encounters |
% Charity Insurance |
% Commercial Insurance | 
% Institutionalized Insurance |
% Medicaid Insurance |
% Medicare Insurance |
% No Insurance Data |
% Other Gov. Insurance |
% Self Pay |
% Workers Comp. Insurance |

[Row-based data](encounters-data.csv)  
[SQL](https://github.com/cns-iu/opioid-trends/blob/master/src/create-encounters-db.sql)  
[Script](https://github.com/cns-iu/opioid-trends/blob/master/scripts/10-extract-encounters-data.sh)  

### Labs

The goal of this visualization is to show a breakdown of the availability of select lab data across each cohort, by representing the percentage of individuals who have had a lab test performed.

DATA_VARIABLE |
--------------|
% HIV Lab Completed |
% Hepatitus Lab Completed |
% Tox Screen Lab Completed |

[Row-based data](labs-all-agg-data.csv)  
[SQL](https://github.com/cns-iu/opioid-trends/blob/master/src/create-labs-db.sql)  
[Script](https://github.com/cns-iu/opioid-trends/blob/master/scripts/10-extract-labs-data.sh)  
