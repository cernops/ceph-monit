(import 'prometheus-mixin/mixin.libsonnet') {
  grafanaDashboards: std.mergePatch(super.grafanaDashboards, {
    'prometheus-remote-write.json': null,
  }),
} + (import 'default.libsonnet')
