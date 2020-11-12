
output mssql_managed_instances {
  value     = module.mssql_managed_instances
  sensitive = true
}

module "mssql_managed_instances" {
  source     = "./modules/databases/mssql_mi"
  for_each   = local.database.mssql_managed_instances
  depends_on = [module.routes]

  global_settings     = local.global_settings
  settings            = each.value
  resource_group_name = module.resource_groups[each.value.resource_group_key].name
  location            = lookup(each.value, "region", null) == null ? module.resource_groups[each.value.resource_group_key].location : local.global_settings.regions[each.value.region]
  subnet_id           = lookup(each.value, "lz_key", null) == null ? local.combined_objects_networking[local.client_config.landingzone_key][each.value.vnet_key].subnets[each.value.subnet_key].id : local.combined_objects_networking[each.value.lz_key][each.value.vnet_key].subnets[each.value.subnet_key].id
  primary_server_id   = try(each.value.primary_server.mi_server_key, null) == null ? "" : var.remote_objects.mssql_managed_instances[each.value.primary_server.lz_key][each.value.primary_server.mi_server_key].id
  base_tags           = try(local.global_settings.inherit_tags, false) ? module.resource_groups[each.value.resource_group_key].tags : {}
}