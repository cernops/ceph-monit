(import 'node-mixin/mixin.libsonnet') {
  _config+:: {
    showMultiCluster: true,
  },
} + (import 'default.libsonnet')
