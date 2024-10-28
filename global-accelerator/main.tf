resource "aws_globalaccelerator_accelerator" "example" {
  name               = "example-accelerator"
  enabled            = true
  ip_address_type    = "IPV4"
}

resource "aws_globalaccelerator_listener" "example" {
  accelerator_arn    = aws_globalaccelerator_accelerator.example.id
  protocol           = "TCP"
  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "eu-west-1" {
  listener_arn          = aws_globalaccelerator_listener.example.id
  endpoint_group_region = "eu-west-1"
  health_check_port     = 80
  health_check_path     = "/vote"
  
  endpoint_configuration {
    endpoint_id = "arn:aws:elasticloadbalancing:eu-west-1:495143188735:loadbalancer/net/k8s-olumokov-votingse-38a81a7fa8/28343b3322368cbe"
  }
  
  endpoint_configuration {
    endpoint_id = "arn:aws:elasticloadbalancing:eu-west-1:495143188735:loadbalancer/net/k8s-olumokov-resultse-6cb644a5cc/6bb11b6b19604bd6"
  }
}
