locals {
  organizational_units = {
    for val in distinct(flatten([
      for ou in [ for ou in var.organizational_units: split("/", ou)]: [ 
        for i in range(length(ou)): {
          name = element(ou, i)
          parent = coalesce(join("/", [ for j in range(0, i): element(ou, j) ]), "root")
          index = i
      }]
    ])): val.parent == "root" ? val.name : "${val.parent}/${val.name}" => val
  }

  ou_resources_merged = merge(
      aws_organizations_organizational_unit.root,
      aws_organizations_organizational_unit.index_1,
      aws_organizations_organizational_unit.index_2,
      aws_organizations_organizational_unit.index_3,
      aws_organizations_organizational_unit.index_4,
      aws_organizations_organizational_unit.index_5
  )
}

resource "aws_organizations_organization" "this" {
  feature_set = var.organization.feature_set
  aws_service_access_principals = var.organization.aws_service_access_principals
  enabled_policy_types = var.organization.enabled_policy_types

  # other aws services may change 'aws_service_access_principals' so ignore those changes
  lifecycle {
      ignore_changes = [aws_service_access_principals]
  }
}

resource "aws_organizations_organizational_unit" "root" {
  for_each = { for k,v in local.organizational_units: k => v if v.index == 0 }
  name      = each.value.name
  parent_id = aws_organizations_organization.this.roots[0].id
  tags = merge({ Name = each.value.name }, var.tags, var.organizational_unit_tags)
}

resource "aws_organizations_organizational_unit" "index_1" {
  for_each = { for k,v in local.organizational_units: k => v if v.index == 1 }
  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.root[each.value.parent].id
  tags = merge({ Name = each.value.name }, var.tags, var.organizational_unit_tags)
}

resource "aws_organizations_organizational_unit" "index_2" {
  for_each = { for k,v in local.organizational_units: k => v if v.index == 2 }
  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.index_1[each.value.parent].id
  tags = merge({ Name = each.value.name }, var.tags, var.organizational_unit_tags)
}

resource "aws_organizations_organizational_unit" "index_3" {
  for_each = { for k,v in local.organizational_units: k => v if v.index == 3 }
  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.index_2[each.value.parent].id
  tags = merge({ Name = each.value.name }, var.tags, var.organizational_unit_tags)
}

resource "aws_organizations_organizational_unit" "index_4" {
  for_each = { for k,v in local.organizational_units: k => v if v.index == 4 }
  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.index_3[each.value.parent].id
  tags = merge({ Name = each.value.name }, var.tags, var.organizational_unit_tags)
}

resource "aws_organizations_organizational_unit" "index_5" {
  for_each = { for k,v in local.organizational_units: k => v if v.index == 5 }
  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.index_4[each.value.parent].id
  tags = merge({ Name = each.value.name }, var.tags, var.organizational_unit_tags)
}

resource "aws_organizations_account" "this" {
  for_each = { for v in var.accounts: v.name => v }
  name  = each.value.name
  email = each.value.email
  role_name = each.value.role_name
  iam_user_access_to_billing = each.value.iam_user_access_to_billing
  parent_id = coalesce(
    each.value.parent_id,
    try(local.ou_resources_merged[each.value.organizational_unit_path].id, null),
    aws_organizations_organization.this.roots[0].id
  )
  tags = merge({ Name = each.value.name }, var.tags, var.account_tags, each.value.tags)
  lifecycle {
      ignore_changes = [role_name, iam_user_access_to_billing]
  }
}

resource "aws_vpc_ipam_organization_admin_account" "this" {
  count = var.ipam_delegated_admin_account_id == null ? 0 : 1
  delegated_admin_account_id = var.ipam_delegated_admin_account_id
}

resource "aws_ram_sharing_with_organization" "this" {
  count = var.enable_ram_sharing_with_organization ? 1 : 0
}
