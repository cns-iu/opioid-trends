# Sources

## Indiana Addictions Data Commons (IADC) Dataset

Data for the visualizations was provided by the [Regenstrief Institute](https://www.regenstrief.org/).

### General Purpose

Create a visualization depicting conditions that were trending co-morbid to the rise of opioid related events in Indiana.  Working with the Regenstrief Institute Data Core, we will begin by creating a group of patients from the Indiana Network for Patient Care, with an index event defined as follows: presence of at least one opioid or related pain medication order/prescription beginning January 1, 2005 through April 30, 2019.

For analysis, we will further subdivide this cohort to those who (1) received 3+ opioid prescriptions (non-hospital) within 120 days or (2) received only 1 opioid non-hospital prescription in 12-month period (chronic vs. other). From there we will extract basic demographics on this cohort such as: age, race, gender, and geographic location (to be no smaller than census tract). Additionally, we will characterize the cohort by clinical events including: percentage with history of substance abuse disorder (defined by ICD code), those with positive toxicology screens, and health system utilization (EMS, ED visits, hospitalizations.

Additionally, we will merge in community variable data sources to identify community trends that may have also been changing during this time frame, such as reductions in socioeconomic status. We will also include the Washington Post opioid pill count data for these geographic regions.

To develop the phenotypes and visualizations, we will extract clinical variables of interest such as epidemic comorbid conditions (sexually transmitted diseases, Hepatitis C, HIV/AIDS) with the hypothesis that some of these conditions may be early warning signs to the epidemic. We will visualize the rates of increase for these comorbid conditions compared to the rise of opioid use and substance abuse disorder in the State.

### Data

 - Data extracted from Indiana Network for Patient Care (2005-2019):

    - Basic demographics on this cohort such as: age, race, gender, and geographic location (to be no smaller than county).    
    - Clinical events including substance abuse disorder, positive toxicology screens, sexually transmitted diseases, Hepatitis C, HIV/AIDS, mental health diagnosis/prescriptions
    - Health system utilization (ED, Inpatient).
    - Data extracted from DHS Emergency response
    - Counts of EMS runs for geographic region
    - Counts of EMS runs in which Naloxone was administered

 - Data extracted from the American Community Survey (2005-2019):

    - Total populations
    - Total Male
    - Total Female
    - Median Age
    - Income below poverty w/in 12 month
    - Cash assistance or snap
    - Not in labor force    
    - Income per year

  - Data extracted from the Washington Post pill data:

    - Pill counts by county

### Data Federation

Extracted data was recombined into an SQLite Database. Access to this data is restricted. For all access inquiries, please contact [danhood@regenstrief.org](mailto:danhood@regenstrief.org).

### Schema Documentation

Schema documentation for the IADC Dataset is available [here](../schema/index.html).
