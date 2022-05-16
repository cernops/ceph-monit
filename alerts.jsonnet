local mixins = (import 'mixins.libsonnet').mixins;
local mixin_alerts = [
  if 'prometheusAlerts' in mixins[mixinName] && 'groups' in mixins[mixinName].prometheusAlerts then
    mixins[mixinName].prometheusAlerts
  else
    { groups: [] }
  for mixinName in std.objectFields(mixins)
];

local out = std.foldl(function(x, y) { groups: (x.groups + y.groups) }, mixin_alerts, { groups: [] });
std.manifestYamlDoc(out, quote_keys=false)
