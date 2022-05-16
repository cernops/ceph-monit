local mixins = (import 'mixins.libsonnet').mixins;
local mixin_rules = [
  if 'prometheusRules' in mixins[mixinName] && 'groups' in mixins[mixinName].prometheusRules then
    mixins[mixinName].prometheusRules
  else
    { groups: [] }
  for mixinName in std.objectFields(mixins)
];

local out = std.foldl(function(x, y) { groups: (x.groups + y.groups) }, mixin_rules, { groups: [] });
std.manifestYamlDoc(out, quote_keys=false)
