terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "1.20.1"
    }
  }
}

resource "grafana_dashboard" "dashboards" {
  for_each    = fileset(path.module, "../../../dashboards_out/*.json")
  config_json = file(each.key)
}
