#
# == Manifest: Project: Security Groups: licensify-frontend
#
# The licensify-frontend needs to be accessible on ports:
#   - 443 from the other VMs
#
# === Variables:
# stackname - string
#
# === Outputs:
# sg_licensify-frontend_id
# sg_licensify-frontend_elb_id

resource "aws_security_group" "licensify-frontend" {
  name        = "${var.stackname}_licensify-frontend_access"
  vpc_id      = "${data.terraform_remote_state.infra_vpc.vpc_id}"
  description = "Access to the licensify-frontend host from its public ELB"

  tags {
    Name = "${var.stackname}_licensify-frontend_access"
  }
}

resource "aws_security_group_rule" "licensify-frontend_ingress_licensify-frontend-elb_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = "${aws_security_group.licensify-frontend.id}"

  # Which security group can use this rule
  source_security_group_id = "${aws_security_group.licensify-frontend_external_elb.id}"
}

resource "aws_security_group" "licensify-frontend_external_elb" {
  name        = "${var.stackname}_licensify-frontend_external_elb_access"
  vpc_id      = "${data.terraform_remote_state.infra_vpc.vpc_id}"
  description = "Access the public licensify-frontend ELB"

  tags {
    Name = "${var.stackname}_licensify-frontend_elb_access"
  }
}

resource "aws_security_group_rule" "licensify-frontend-elb_ingress_office_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = "${aws_security_group.licensify-frontend_external_elb.id}"
  cidr_blocks       = ["${var.office_ips}"]
}

resource "aws_security_group_rule" "licensify-frontend-elb_ingress_office_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id = "${aws_security_group.licensify-frontend_external_elb.id}"
  cidr_blocks       = ["${var.office_ips}"]
}

resource "aws_security_group_rule" "licensify-frontend-elb_egress_any_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.licensify-frontend_external_elb.id}"
}