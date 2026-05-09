output "db_instance_endpoint" {
  value = module.db.db_instance_endpoint
}
output "db_instance_name" {
  value = module.db.db_instance_name
}
output "db_instance_username" {
  value     = module.db.db_instance_username
  sensitive = true
}
output "db_instance_password" {
  value     = random_password.master.result
  sensitive = true
}
