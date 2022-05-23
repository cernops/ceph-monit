(import 'grafana-builder/grafana.libsonnet') {

  _config:: error 'must provide _config',

  row(title)::
    super.row(title) + {
      addPanelIf(condition, panel)::
        if condition
        then self.addPanel(panel)
        else self,
    },

  dashboard(title)::
    super.dashboard(
      title=title,
      datasource=$._config.dataSource,
    ) + { tags: $._config.tags } + {
      addRowIf(condition, row)::
        if condition
        then self.addRow(row)
        else self,

      addRowsIf(condition, rows)::
        if condition
        then
          local reduceRows(dashboard, remainingRows) =
            if (std.length(remainingRows) == 0)
            then dashboard
            else
              reduceRows(
                dashboard.addRow(remainingRows[0]),
                std.slice(remainingRows, 1, std.length(remainingRows), 1)
              )
          ;
          reduceRows(self, rows)
        else self,

      addRows(rows)::
        self.addRowsIf(true, rows),

      addQueryTemplate(name, query, regex='', hide=0, refresh=1, includeAll=true, isQuery=true)::
        local _query = if isQuery then 'query_result(%s)' % query else 'label_values(%s)' % query;
        self {
          templating+: {
            list+: [{
              datasource: $._config.dataSource,
              hide: hide,
              includeAll: includeAll,
              label: name,
              multi: true,
              name: name,
              options: [],
              query: _query,
              refresh: refresh,
              regex: regex,
              sort: 2,
              tagValuesQuery: '',
              tags: [],
              tagsQuery: '',
              type: 'query',
              useTags: false,
            }],
          },
        },

      addCustomTemplate(name, values, defaultIndex=0, type='custom'):: self {
        templating+: {
          list+: [
            {
              name: name,
              options: [
                {
                  selected: v == values[defaultIndex],
                  text: v,
                  value: v,
                }
                for v in values
              ],
              current: {
                selected: true,
                text: values[defaultIndex],
                value: values[defaultIndex],
              },
              type: type,
              hide: 0,
              includeAll: false,
              multi: false,
              query: std.toString(values),
            },
          ],
        },
      },
    },

  queryPanel(queries, legends, legendLink=null, unit=null)::
    super.queryPanel(queries, legends, legendLink) +
    {
      legend: { show: false },
      fill: 0,
      tooltip: { sort: 2 },
      type: 'timeseries',
      fieldConfig: { defaults: { unit: unit }, custom: { spanNulls: true } },
      options: { legend: { calcs: ['mean'] } },
      reduceOptions: { calcs: ['mean'] },
    },

  piePanel(queries, legends, unit=null)::
    super.queryPanel(queries, legends) + {
      targets: [
        target {
          interval: '15s',
        }
        for target in super.targets
      ],
      type: 'piechart',
      fieldConfig: { defaults: { unit: unit } },
      options: { legend: { values: ['percent'] }, reduceOptions: { calcs: ['mean'] } },
    },


  panelDescription(title, description):: {
    description: |||
      ### %s
      %s
    ||| % [title, description],
  },
}
