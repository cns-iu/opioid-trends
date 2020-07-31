{{ vega.header() }}
{{ js.include('../reusable_charts/reusable_charts.js') }}

<a href="../help/index.html" class="icon fa fa-question-circle"> Help</a>

<div id="visualization"></div>
<script type="text/javascript">
  dvOverTimeChart(
    '../data/encounters-data.csv', 
    {
      selectedDataVariables: [
        '% Charity Insurance', 
        '% Commercial Insurance', 
        '% Institutionalized Insurance',
        '% Medicaid Insurance',
        '% Medicare Insurance',
        '% No Insurance Data',
        '% Other Gov. Insurance',
        '% Self Pay',
        '% Workers Comp. Insurance',
        '% with Emergency Encounters',
        '% with Inpatient Encounters',
        'Avg. # Emergency Encounters',
        'Avg. # Inpatient Encounters'
      ],
      initVariables: [
        '% Commercial Insurance', 
        '% Medicare Insurance',
        'Avg. # Emergency Encounters'
      ]
    }
  )
</script>

<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
