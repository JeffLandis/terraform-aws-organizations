output "organization" {
    value = aws_organizations_organization.this
}

output "organizational_units" {
    value = local.ou_resources_merged
}

output "accounts" {
    value = aws_organizations_account.this
}

output "ipam_organization_admin_account" {
    value = one(aws_vpc_ipam_organization_admin_account.this)
}

output "ram_sharing_with_organization" {
    value = one(aws_ram_sharing_with_organization.this)
}
