{
  prometheusAlerts+::
    (import 'alerts/cern-alerts.libsonnet'),
  prometheusRules+::
    (import 'alerts/cern-rules.libsonnet'),
  grafanaDashboards+:
    (import 'dashboards/top_rbd_tenants.libsonnet') +
    (import 'dashboards/rbd_tenant_view.libsonnet') +
    { _config:: $._config },
}
+ (import 'config.libsonnet')
