(import 'ceph-mixin/mixin.libsonnet') {
  _config+:: {
    showMultiCluster: true,
  },
} + (import 'default.libsonnet')
