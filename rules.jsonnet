local mixins = (import 'mixins.libsonnet').mixins;
local mixin_rules = [mixins[mixinName].prometheusRules for mixinName in std.objectFields(mixins)];

local out = std.foldl(function(x, y) { groups: (x.groups + y.groups) }, mixin_rules, { groups: [] });
std.manifestYamlDoc(out, quote_keys=false)