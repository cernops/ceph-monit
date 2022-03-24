terraform {
  backend "s3" {
    endpoint                    = "https://s3.cern.ch"
    bucket                      = "ceph-monit-tf-state"
    key                         = "qa/terraform.tfstate"
    region                      = "cern"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

module "common" {
  source = "../../modules/common"
}
