{
  mixins+:: {
    'node-mixin': (import 'mixins/node-mixin.libsonnet'),
    'cern-ceph': (import 'mixins/cern-ceph/mixin.libsonnet'),
  },
}
