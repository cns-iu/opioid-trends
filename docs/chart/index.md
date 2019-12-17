{{ vega_script_tags }}

<div id="visualization"></div>
<script type="text/javascript">
  var opt = { "renderer": "canvas", "actions": true };
  fetch("chart.vl.json").then((result) => {
    return result.text();
  }).then((text) => {
    // Replace relative paths with absolute URLs
    var baseUrl = document.URL.replace('/chart/index.html', '/data/');
    var spec = JSON.parse(text.replace(/\.\.\/data\//gi, baseUrl));
    return vegaEmbed("#visualization", spec, opt);
  }).then((results) => {
    console.log("Visualization successfully loaded");
  });
</script>

<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
