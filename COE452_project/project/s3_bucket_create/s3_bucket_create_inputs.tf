variable "s3_bucket_name" {
  type        = string
  description = ""
}
variable "website_configuration" {
  type        = bool
  description = ""
  default = false
}
variable "set_acl" {
  type        = string
  description = ""
  default = "public-read"
}
variable "permissions_for_website_access" {
  type        = bool
  description = ""
  default = false
}
variable "permissions_for_store_mail" {
  type        = bool
  description = ""
  default = false
}
variable "delete_all" {
  type        = bool
  description = "A bool that indicates all objects (including any locked objects) should be deleted from the bucket so the bucket can be destroyed without error."
  default = true
}
variable "for_logs" {
  type        = bool
  description = ""
  default = false
}
