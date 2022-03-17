(import 'node-mixin/mixin.libsonnet') {
  _config+:: {
    showMultiCluster: true,
    rateInterval: '1m',
  },
} + (import 'default.libsonnet')
