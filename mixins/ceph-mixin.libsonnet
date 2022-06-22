(import 'ceph-mixin/mixin.libsonnet') {
  _config+:: {
    showMultiCluster: true,
  },
  prometheusAlerts:: {},
} + (import 'default.libsonnet')
