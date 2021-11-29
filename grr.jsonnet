local main = (import 'main.jsonnet');
local grizzly = (import 'grizzly/grizzly.libsonnet');

grizzly.fromPrometheusKsonnet(main)
