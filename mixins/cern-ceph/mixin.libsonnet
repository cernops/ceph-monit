{
  prometheusAlerts+:: std.parseYaml(importstr 'alerts.yaml'),
  prometheusRules+:: std.parseYaml(importstr 'rules.yaml'),
  grafanaDashboards+:
    (import 'dashboards/top_rbd_tenants.libsonnet') +
    (import 'dashboards/rbd_tenant_view.libsonnet') +
    { _config:: $._config },
}
+ (import 'config.libsonnet')
