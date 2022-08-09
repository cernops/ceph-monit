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
  overwrite   = true
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "CephPrometheus"
  url        = "http://cephthanos-qry-62f8776bc7.cern.ch:19192"
  is_default = true

  json_data {
    http_method = "POST"
  }
}

resource "grafana_data_source" "prometheusqa" {
  type = "prometheus"
  name = "CephPrometheusQA"
  url  = "http://cephthanos-qry-qa.cern.ch:19192"

  json_data {
    http_method = "POST"
  }
}

resource "grafana_data_source" "loki" {
  type                = "loki"
  name                = "Loki Ceph"
  url                 = "https://sdloki.cern.ch"
  basic_auth_enabled  = true
  basic_auth_username = "ceph"
  basic_auth_password = var.loki_auth_password
}

resource "grafana_data_source" "elasticsearch" {
  type                = "elasticsearch"
  name                = "Ceph ES Access"
  url                 = "https://es-ceph.cern.ch/es"
  basic_auth_enabled  = true
  basic_auth_username = "ceph_ro"
  basic_auth_password = var.ES_CEPH_RO_PW
  database_name       = "[ceph_s3_access-]YYYY.MM.DD"


  json_data {
    es_version    = "7.10.0"
    interval      = "Daily"
    time_field    = "@timestamp"
    time_interval = "10s"
    tls_auth      = false
  }
}

resource "grafana_data_source" "graphite" {
  type = "graphite"
  name = "filercarbon"
  url  = "https://filer-carbon.cern.ch"
  http_headers = {
    x-org-id = "1"
  }

  json_data {
    graphite_version = "7.10.0"
  }
}
