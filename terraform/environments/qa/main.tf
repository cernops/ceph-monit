terraform {
  backend "http" {
  }
}

module "common" {
  source             = "../../modules/common"
  ES_CEPH_RO_PW      = var.ES_CEPH_RO_PW
  loki_auth_password = var.loki_auth_password
}
