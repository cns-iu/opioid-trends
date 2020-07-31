{{ vega.header() }}
{{ js.include('../reusable_charts/reusable_charts.js') }}

<a href="../help/index.html" class="icon fa fa-question-circle"> Help</a>

<div id="visualization"></div>
<script type="text/javascript">
  dvOverTimeChart('../data/labs-all-agg-data.csv', 
    {
      selectedDataVariables: ['% HIV Lab Completed', '% Hepatitus Lab Completed', '% Tox Screen Lab Completed'],
      initVariables: ['% HIV Lab Completed', '% Hepatitus Lab Completed', '% Tox Screen Lab Completed']
    }
  )
</script>

<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
