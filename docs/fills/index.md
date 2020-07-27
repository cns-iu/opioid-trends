{{ vega.header() }}

<a href="../help/index.html" class="icon fa-question-circle"> Help</a>

{{ vega.embed('./docs/fills/vis1.vl.json') }}
{{ vega.embed('./docs/fills/vis2.vl.json') }}

<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
