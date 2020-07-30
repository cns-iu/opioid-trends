{{ vega.header() }}
{{ js.include('../reusable_charts/reusable_charts.js') }}

<a href="../help/index.html" class="icon fa fa-question-circle"> Help</a>

<div id="visualization"></div>
<script type="text/javascript">
  dvOverTimeChart('../data/demographics-data-row-based.csv')
</script>

<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
