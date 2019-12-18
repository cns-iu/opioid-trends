
## Visualization Interactions
Both the chart and map visualizations support two different interactions.
One to select the time period viewed and one to select which data variables are visualized.

### Time period
Time periods are selected, deselected, and changed using the bottom summary line visualization. Following are actions that can be performed on the time period:

- Select a time period by 
    1. Left click on the desired initial time.
    2. While keeping the left mouse button pressed move the mouse to the desired end time.
    3. Release the mouse button to finish the selection.
- Deselect a time period by clicking outside the highligthed region.
- Move the window of selected time by
    1. Left click anywhere inside the highlighted region.
    2. While keeping the left mouse button pressed move the mose left or right to move the region.
    3. Release the mouse button when done.
- Expand and contract the selected time period by
    1. Hover the mouse anywhere inside the highlighted region.
    2. Use the mouse wheel to expand and contract the selected time period.


### Data Variables
Data variables can be selected and deselected to show any combination. The following actions can be performed:

- Double click a data variable to turn it on and all other data variables off.
- Double click a data variable while pressing the shift key to toggle the data variable on/off.

## How to Embed a Visualization in a Webpage
To embed one of the visualizations on another webpage first download the vega or vega-lite specification (from the action menu on the visualization), then add the following HTML snippet to the webpage:

```html
<script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-lite@4"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>

<div id="visualization"></div>
<script type="text/javascript">
  var opts = { renderer: 'canvas', actions: true };
  vegaEmbed('visualization', 'path/to/vega/spec', opts);
</script>
```
With `'path/to/vega/spec'` replaced with the actual path to the downloaded vega specification.  
Futher information on Vega-Embed can be found [here](https://github.com/vega/vega-embed).
