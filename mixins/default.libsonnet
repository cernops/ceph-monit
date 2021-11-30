{
  // - Dashboard UIDs are set to the md5 hash of their filename.
  // - Timezone are set to be "default" (ie local).
  // - Editable is set to false
  local grafanaDashboards = super.grafanaDashboards,

  grafanaDashboards:: {
    [filename]:
      local dashboard = grafanaDashboards[filename];
      dashboard {
        uid: std.md5(filename),
        timezone: '',
        editable: false,
      }
    for filename in std.objectFields(grafanaDashboards)
  },
  prometheusRules+:: {},
  prometheusAlerts+:: {},
}
