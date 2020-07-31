# Help

## Visualization Interactions

All visualizations support two kinds of interaction: 
1) to select the time period viewed and 2) to select which data variables are visualized.

### Time Period

Time periods are selected, deselected, and changed using the bottom summary line visualization.

The following actions can be performed:

 - Select a time period

    1. Left click on the desired initial time
    2. While keeping the left mouse button pressed, move the mouse to the desired end time
    3. Release the mouse button to finish the selection

 - Deselect a time period

    1. Click outside the highlighted region but within the summary line visualization

 - Move the window of selected time

    1. Left click anywhere inside the highlighted region
    2. While keeping the left mouse button pressed, move the mouse left or right to move the region
    3. Release the mouse button when done

 - Expand and contract the selected time period

    1. Hover the mouse anywhere inside the highlighted region
    2. Turn the mouse wheel to expand and contract the selected time period

### Data Variables / Cohorts

Data variables and cohorts can be selected and deselected to show any combination of variables/cohorts using the legend.

The following actions can be performed:

- Double click a data variable/cohort to turn only that data variable on
- Double click a data variable/cohort while pressing the shift key to toggle that data variable on/off
- Double click anywhere to turn on **all** data variables and cohorts

## Save a Screenshot of a Visualization

To save a screenshot of one of the visualizations, simple press the action menu at the top right-hand side of the visualization and select `Save as PNG` or `Save as SVG`.

## Embed a Visualization in a Webpage

To embed one of the visualizations on another webpage, first download the vega or vega-lite specification (from the action menu at the top right-hand side of the visualization), then add the following HTML snippet to your webpage:

```html
<script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-lite@4"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>

<div id="visualization"></div>
<script type="text/javascript">
  var opts = { renderer: 'canvas', actions: true };
  vegaEmbed('visualization', 'path/to/vega/spec.json', opts);
</script>
```

Replace `'path/to/vega/spec.json'` with the actual url/path to the downloaded vega specification. Futher information on Vega-Embed can be found [here](https://github.com/vega/vega-embed).
