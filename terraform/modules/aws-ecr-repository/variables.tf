variable "default_repository_tags" {
  default     = {}
  type        = map(any)
  description = "Default tags associated with the repository."
}

variable "extra_repository_tags" {
  default     = {}
  type        = map(any)
  description = "Extra tags associated with the repository."
}

variable "repository_name" {
  default     = "default-repository"
  type        = string
  description = "Name of the image repository."
}

variable "force_delete" {
  default     = false
  type        = bool
  description = "Enabled force delete which deletes the repository even if it holds images."
}

variable "image_tag_mutability" {
  default     = "MUTABLE"
  type        = string
  description = "Enabled force delete which deletes the repository even if it holds images."
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Accepted values for image_tag_mutability are MUTABLE or IMMUTABLE"
  }
}
