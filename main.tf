module "databases" {
  for_each = var.databases
  source   = "./modules/component"

  component     = each.key
  dns_domain    = var.dns_domain
  env           = var.env
  instance_type = each.value["instance_type"]
  ports         = each.value["ports"]
}

module "apps" {
  depends_on = [module.databases]
  for_each   = var.apps
  source     = "./modules/component-with-alb"

  component     = each.key
  dns_domain    = var.dns_domain
  env           = var.env
  instance_type = each.value["instance_type"]
  ports         = each.value["ports"]
}

