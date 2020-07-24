{{ vega.header() }}

<a href="../help/index.html" class="icon fa-question-circle"> Help</a>

{{ vega.embed('./docs/encounters/vis.vl.json') }}
<!--
<br />
<span style="font-weight: bold">
    Encounter Insurance Types
</span>
{{ vega.embed('./docs/encounters/all-vis.vl.json') }}
 {{ vega.embed('./docs/encounters/chronic-vis.vl.json') }}
<br />
{{ vega.embed('./docs/encounters/other-vis.vl.json') }} -->


<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
