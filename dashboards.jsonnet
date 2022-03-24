local mixins = (import 'mixins.libsonnet').mixins;

{
  [dashboardName]: mixins[mixinName].grafanaDashboards[dashboardName]
  for mixinName in std.objectFields(mixins)
  for dashboardName in std.objectFields(mixins[mixinName].grafanaDashboards)
}
