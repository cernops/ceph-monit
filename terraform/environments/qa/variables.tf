variable "ES_CEPH_RO_PW" {
  type      = string
  nullable  = false
  sensitive = true
}
variable "loki_auth_password" {
  type      = string
  nullable  = false
  sensitive = true
}
