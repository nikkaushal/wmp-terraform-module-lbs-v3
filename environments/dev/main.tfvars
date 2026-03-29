dns_domain = "tek-nik.com."
env        = "dev"

databases = {
  postgres = {
    instance_type = "t3.small"
    ports = {
      ssh        = 22
      postgresql = 5432
    }
  }
}

apps = {

  frontend = {
    instance_type = "t3.small"
    ports = {
      frontend = 80
    }
    lb = {
      lb_internal = false
      port = 80
    }
  }

  auth-service = {
    instance_type = "t3.small"
    ports = {
      auth-service = 8081
    }
    lb = {
      lb_internal = true
      port = 8081
    }    
  }

  portfolio-service = {
    instance_type = "t3.small"
    ports = {
      portfolio-service = 8080
    }
    lb = {
      lb_internal = true
      port = 8080
    }
  }

  analytics-service = {
    instance_type = "t3.small"
    ports = {
      analytics-service = 8000
    }
    lb = {
      lb_internal = true
      port = 8080
    }
  }

}