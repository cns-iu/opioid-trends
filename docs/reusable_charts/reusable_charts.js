
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
  const numColumns = window.innerWidth < 768 ? Math.floor(window.innerWidth / 375) : Math.floor((window.innerWidth - 300) / 375)
  const title = document.title.replace("— Opioid Trends in Indiana", "") + "By Cohort"
  const scrubWidth = 225*numColumns + 75*(numColumns - 1)

  options = Object.assign({
    divId: '#visualization',
    embedOpts: {},
    specUrl: '../reusable_charts/dv-over-time.vl.json',
    title: title,
    columns: numColumns,
    rowHeight: 200,
    columnWidth: 225,
    scrubberWidth: scrubWidth,
    scrubberHeight: 150

  }, options);

  return fetch(options.specUrl).then((result) => result.json()).then((spec) => 
    fetch(csvUrl || spec.data.url).then((result) => result.text()).then((csvData) => {
      spec.data.values = csvData
      spec.name = options.title
      spec.title.text = options.title
      spec.vconcat[1].columns = options.columns
      spec.vconcat[1].spec.width = options.columnWidth
      spec.vconcat[1].spec.height = options.rowHeight
      spec.vconcat[0].width = options.scrubberWidth
      spec.vconcat[0].height = options.scrubberHeight

      return vegaEmbed(options.divId, spec, options.embedOpts);
    })
  ).then((results) => {
    console.log("Visualization successfully loaded");
  });
}
