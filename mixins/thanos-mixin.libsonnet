(import 'github.com/thanos-io/thanos/mixin/mixin.libsonnet') {
  bucketReplicate:: null,
  queryFrontend:: null,
  receive:: null,
  rule:: null,
} + (import 'default.libsonnet')
