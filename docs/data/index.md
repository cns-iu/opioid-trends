## Data

Data was extracted from an IADC Database provided by Regenstrief. See [Sources](../sources/index.md) for details.

## Data Variables

From the raw data, we compiled a number of data variables to visualize.

DATA_VARIABLE | Label | Type | Scale
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

## Chart Data

For the chart data, we computed the data variable values by grouping by the minimum periodicity (currently one month intervals) and computed the values of the data variables in each period.

## Map Data

For the geographic map of indiana, we further grouped by county (TRACT_5) so that we can see how the data variables play out at the county level.