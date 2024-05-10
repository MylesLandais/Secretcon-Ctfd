variable "ECS_CLUSTER" {
  type = string
}
variable "SERVICE_NAME" {
  type = string
}
variable "CIDR" {
  type = string
}
variable "SUBCIDR" {
  type = string
}
variable "SECGROUP" {
  type = string
}
variable "CTFD_PORT" {
  type = number
}
variable "az_count" {
  description = "Describes how many availability zones are used"
  default     = 2
  type        = number
}
