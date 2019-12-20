# Changelog

Changelog for Opioid Trends in Indiana.

## 0.1.0 - 2019-12-20

### Added in 0.1.0

- First release of the Opioid Trends in Indiana visualizations and website
- Created a documentation site populated with information about the data and visualizations
- Created automated scripts to download the IADC data from Box and generate schema level documentation via SchemaSpy
- Created automated scripts to extract data for the visualizations integrated
- Created an interactive line chart (Opioid Trends Over Time)
- Created an interactive geographic map (Opioid Trends on the Indiana Map)
- We now have a full workflow going from raw data to relational database to analytics and visualizations to documentation website

### Known Issues in 0.1.0

- On the `Opioid Trends on the Indiana Map` visualization, if a time period is selected that doesn't include any data for the selected data variables, then the whole visualization will disappear. If this happens, simply refresh the page to restart the visualization.
- On the `Opioid Trends Over Time` visualization, if you double click to show all data variables at once, all the value labels on the line chart will show. If you want to show all variables without all the labels, you must double click each variable one at a time.
- If the whole time period is selected, you have to refresh the page to deselect it.
- The 'Open in Vega Editor' action will not work properly until this site has become public.
