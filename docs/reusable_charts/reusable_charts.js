
function embedWithCSV(specUrl, csvUrl, divId, embedOpts) {
  return fetch(specUrl || 'vis.vl.json').then((result) => result.json()).then((spec) => 
    fetch(csvUrl || spec.data.url).then((result) => result.text()).then((csvData) => {
      delete spec.data.url;
      spec.data.name = 'data';
      spec.data.format = Object.assign(spec.data.format || {}, {type: 'csv'});
      spec.datasets = {data: csvData};
      return vegaEmbed(divId || '#visualization', spec, embedOpts || {});
    })
  ).then((results) => {
    console.log("Visualization successfully loaded");
  });
}

function dvOverTimeChart(csvUrl, options) {
  // Assign default options
  options = Object.assign({
    divId: '#visualization',
    embedOpts: {},
    specUrl: '../reusable_charts/dv-over-time.vl.json'
    // TODO: Edward fills in the blanks
    // title
    // columns
    // rowHeight
    // columnWidth
  }, options);

  return fetch(options.specUrl).then((result) => result.json()).then((spec) => 
    fetch(csvUrl || spec.data.url).then((result) => result.text()).then((csvData) => {
      spec.data.values = csvData
      return vegaEmbed(options.divId, spec, options.embedOpts);
    })
  ).then((results) => {
    console.log("Visualization successfully loaded");
  });
}
