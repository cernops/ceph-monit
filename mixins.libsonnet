{
  mixins+:: {
    'alertmanager-mixin': (import 'mixins/alertmanager-mixin.libsonnet'),
    'cern-ceph': (import 'mixins/cern-ceph-mixin.libsonnet'),
    'node-mixin': (import 'mixins/node-mixin.libsonnet'),
    'prometheus-mixin': (import 'mixins/prometheus-mixin.libsonnet'),
    'thanos-mixin': (import 'mixins/thanos-mixin.libsonnet'),
  },
}
