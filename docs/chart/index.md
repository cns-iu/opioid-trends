{{ vega_script_tags }}
{{ include_vega_ext('chart.vl.json', { 'actions': True, 'tooltip': False }) }}

<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
