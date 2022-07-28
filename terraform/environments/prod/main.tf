terraform {
  backend "http" {
  }
}
module "common" {
  source        = "../../modules/common"
  ES_CEPH_RO_PW = var.ES_CEPH_RO_PW
}
