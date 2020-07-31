{{ vega.header() }}
{{ js.include('../reusable_charts/reusable_charts.js') }}

<a href="../help/index.html" class="icon fa fa-question-circle"> Help</a>

<div id="visualization"></div>
<script type="text/javascript">
  dvOverTimeChart(
    '../data/diagnosis-data-row-based.csv',
    {
      selectedDataVariables: [
        'Alcohol Poisoning',
        'Benzo Poisoning',
        'Drug Poisoning',
        'HIV',
        'Mental Health',
        'Opioid Poisoning',
        'Opioid Use',
        'Other Poisoning',
        'Overdose',
        'STD',
        'Stimulant Poisoning',
        'Substance Abuse Disorder'
      ],
      initVariables: [
        'Opioid Use',
        'Overdose',
        'Substance Abuse Disorder'
      ]
    }
  )
</script>

<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
