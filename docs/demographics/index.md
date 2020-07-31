{{ vega.header() }}
{{ js.include('../reusable_charts/reusable_charts.js') }}

<a href="../help/index.html" class="icon fa fa-question-circle"> Help</a>

<div id="visualization"></div>
<script type="text/javascript">
  dvOverTimeChart(
    '../data/demographics-data-row-based.csv',
    {
      selectedDataVariables: [
        'Gender Unspecified',
        'Female',
        'Male',
        'AMERICAN INDIAN AND ALASKA NATIVE',
        'ASIAN ',
        'BLACK OR AFRICAN AMERICAN',
        'HISPANIC OR LATINO',
        'MULTIRACIAL',
        'NATIVE HAWAIIAN AND OTHER PACIFIC ISLANDER',
        'WHITE',
        'Other Race',
        '1-4',
        '5-9',
        '10-14',
        '15-19',
        '20-24',
        '25-29',
        '30-34',
        '35-39',
        '40-44',
        '45-49',
        '50-54',
        '55-59',
        '60-64',
        '65-69',
        '70-74',
        '75-79',
        '80-84',
        '85-89',
        '90+'
      ],
      initVariables: [
        'Gender Unspecified',
        'Female',
        'Male'
      ]
    }
  )
</script>

<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
