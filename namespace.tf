resource "aws_service_discovery_private_dns_namespace" "sbcntr-ecs-backend-private-dns-namespace" {
  name = "local"
  vpc = aws_vpc.sbcntr-vpc.id  
}

resource "aws_service_discovery_service" "sbcntr-ecs-backend-service" {
  name = "sbcntr-ecs-backend-service"
  health_check_custom_config {
    failure_threshold = 1
  }

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.sbcntr-ecs-backend-private-dns-namespace.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl = 60
      type = "A"
    }
  }

  
}