import json

from mkdocs_macros import common, javascript as js


DEFAULT_VEGA_OPTIONS = { 'renderer': 'canvas', 'actions': True }


def options_to_javascript(opts):
    return js.to_js({ **DEFAULT_VEGA_OPTIONS, **(opts or {}) })

def create_vega_script(source, opts):
    elem_id = common.unique('vega-elem-')
    sopts = options_to_javascript(opts)
    content = common.indent(f'vegaEmbed("#{elem_id}", {source}, {sopts});', 2)
    return common.multiline(
        f'<div id="{elem_id}"></div>',
        js.start(),
        content,
        js.end()
    )


def header():
    return common.multiline(
        js.include('https://cdn.jsdelivr.net/npm/vega@5'),
        js.include('https://cdn.jsdelivr.net/npm/vega-lite@4'),
        js.include('https://cdn.jsdelivr.net/npm/vega-embed@6')
    )

def include(path, opts=None):
    return create_vega_script(f'"{path}"', opts)

def embed(path, opts=None):
    with open(path) as file:
        return create_vega_script(file.read(), opts)

def embedWithCSV(spec='vis.vl.json', csv=None, opts=None):
    sopts = options_to_javascript(opts)
    elem_id = common.unique('vega-elem-')
    csvData = 'spec.data.url' if not csv else f'"{csv}"'
    content = ('''  fetch("|vis.vl.json|").then((result) => result.json()).then((spec) => 
    fetch(|csvData|).then((result) => result.text()).then((csvData) => {
      delete spec.data.url;
      spec.data.name = 'data';
      spec.data.format = Object.assign(spec.data.format || {}, {type: 'csv'});
      spec.datasets = {data: csvData};
      return vegaEmbed("#|elem_id|", spec, |opts|);
    })
  ).then((results) => {
    console.log("Visualization successfully loaded");
  });'''
    .replace('|vis.vl.json|', spec)
    .replace('|opts|', sopts)
    .replace('|elem_id|', elem_id).replace('|csvData|', csvData))
    
    return common.multiline(
        f'<div id="{elem_id}"></div>',
        js.start(),
        content,
        js.end()
    )

def define_env(env):
    env.macro(header)
    env.macro(include)
    env.macro(embed)
    env.macro(embedWithCSV)
