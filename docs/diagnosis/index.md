{{ vega.header() }}

<a href="../help/index.html" class="icon fa fa-question-circle"> Help</a>

{{ vega.embedWithCSV('vis.vl.json', '../data/diagnosis-data-row-based.csv') }}

<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
