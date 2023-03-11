variable "domain" {
  type        = string
  description = "The domain name to use for the static site"
  default     = "biqalati.com"
}
variable "s3_bucket_name" {
  type        = string
  default     = "ses-storage-one"

}
variable "region" {
  type = string
  default = "us-east-1"
}
