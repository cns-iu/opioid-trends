{{ vega_script_tags }}

<div id="visualization"></div>
<script type="text/javascript">
  var opt = { "renderer": "canvas", "actions": true };
  fetch("map.vl.json").then((result) => {
    return result.text();
  }).then((text) => {
    // Replace relative paths with absolute URLs
    var host = new URL(document.URL).origin;
    var spec = text.replace('../data/', host + '/data/');

    vegaEmbed("#visualization", JSON.parse(spec), opt).then(console.log);
  });
</script>

<style>
/* hack to turn off gray background in the readthedocs theme */
.wy-nav-content-wrap { background-color: #fcfcfc !important; }
</style>
