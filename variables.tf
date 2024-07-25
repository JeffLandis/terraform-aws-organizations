variable "organization" {
  description = "Create an organization."
  type        = object({
    # feature_set (Optional) Specify 'ALL' (default) or 'CONSOLIDATED_BILLING'.
    feature_set = optional(string, "ALL")
    # aws_service_access_principals (Optional) List of AWS service principal names for which you want to enable integration with your organization.
    aws_service_access_principals = optional(list(string), [])
    # enabled_policy_types (Optional) List of Organizations policy types to enable in the Organization Root.
    enabled_policy_types = optional(list(string), [])
  })
  default = {}
}

# path-like string of parent ou names ending with the ou's name
# all parents in the path will be created along with the ou
# example: parent1/parent2/child
# root ous just need the ou's name, do not include a path
# example: production
# do not include leading and trailing slashes
variable "organizational_units" {
  description = "A list of path-like strings of parent ou names ending with the ou's name."
  type = list(string)
  default = []
}

variable "organizational_unit_tags" {
  description = "Additional tags to add to all organizational units."
  type        = map(string)
  default     = {}
}

variable "accounts" {
  description = "A list of objects defining the organization's accounts."
  type        = list(object({
    # name (Required) Friendly name for the member account.
    name = string
    # email (Required) Email address of the owner to assign to the new member account.
    email = string
    # parent_id (Optional) Parent Organizational Unit ID or Root ID for the account.
    # organizational_unit_path (Optional) Parent Organizational Unit path as provided in 'organizational_units' variable.
    # INFO: 'parent_id' has priority and will be used if both are provided.
    parent_id = optional(string, null)
    organizational_unit_path = optional(string, null)
    # role_name (Optional) The name of an IAM role that Organizations automatically preconfigures in the new member account.
    role_name = optional(string, "OrganizationAccountAccessRole")
    # iam_user_access_to_billing (Optional) If set to ALLOW (default), permits IAM users & roles to access account billing information. 
    # If set to DENY, then only the root user can access account billing information.
    # WARN: If this is changed after account creation then it will try to recreate the account.
    iam_user_access_to_billing = optional(string, "ALLOW")
    # close_on_deletion (Optional) If true, a deletion event will close the account. If false (default) then it will only remove from the organization.
    close_on_deletion = optional(bool, false)
    # create_govcloud (Optional) If true, creates a GovCloud account.
    create_govcloud = optional(bool, false)
    # (Optional) Key-value map of resource tags. 
    tags = optional(map(string), {})
  }))
  default     = []
}

variable "account_tags" {
  description = "Additional tags to add to all accounts."
  type        = map(string)
  default     = {}
}

variable "ipam_delegated_admin_account_id" {
  description = "Enables the IPAM Service and promotes a delegated administrator account."
  type        = string
  default     = null
}

variable "enable_ram_sharing_with_organization" {
  description = "Enables Resource Access Manager (RAM) Resource Sharing with AWS Organizations."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
