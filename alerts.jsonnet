local mixins = (import 'mixins.libsonnet').mixins;
local mixin_alerts = [mixins[mixinName].prometheusAlerts for mixinName in std.objectFields(mixins)];

local out = std.foldl(function(x, y) { groups: (x.groups + y.groups) }, mixin_alerts, { groups: [] });
std.manifestYamlDoc(out, quote_keys=false)
