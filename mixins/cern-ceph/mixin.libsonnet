{
  grafanaDashboards+:: {},
  prometheusAlerts+:: std.parseYaml(importstr 'alerts.yaml'),
  prometheusRules+:: std.parseYaml(importstr 'rules.yaml'),
}
