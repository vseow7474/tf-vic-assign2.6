resource "aws_dynamodb_table" "vic-dynamo" {
  name         = "${var.name_prefix}-bookinventory"
  billing_mode = "PAY_PER_REQUEST" # Choose between "PAY_PER_REQUEST" or "PROVISIONED"

  # Define the primary key
  hash_key  = "ISBN"  # Partition key
  range_key = "Genre" # Sort key

  # Attributes definitions
  attribute {
    name = "ISBN"
    type = "S" # String type
  }

  attribute {
    name = "Genre"
    type = "S" # String type
  }

  provisioner "local-exec" {
    command = <<EOT
    aws dynamodb put-item --table-name ${var.name_prefix}-bookinventory --item '{"ISBN": {"S": "978-0134685991"}, "Genre": {"S": "Technology"}, "Title": {"S": "Effective Java"}, "Author": {"S": "Joshua Bloch"}, "Stock": {"N": "1"}}'
    aws dynamodb put-item --table-name ${var.name_prefix}-bookinventory --item '{"ISBN": {"S": "978-0134685009"}, "Genre": {"S": "Technology"}, "Title": {"S": "Learning Python"}, "Author": {"S": "Mark Lutz"}, "Stock": {"N": "2"}}'
    aws dynamodb put-item --table-name ${var.name_prefix}-bookinventory --item '{"ISBN": {"S": "974-0134789698"}, "Genre": {"S": "Fiction"}, "Title": {"S": "The Hitchhiker"}, "Author": {"S": "Douglas Adams"}, "Stock": {"N": "10"}}'
    EOT
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.name_prefix}-dynamoDB-policy"
  path        = "/"
  description = "My dynamoDB policy"

  # Attach data block policy document
  policy = data.aws_iam_policy_document.dynamoDB_policy.json
}

resource "aws_iam_role" "test_role" {
  name = "${var.name_prefix}-read-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "${var.name_prefix}-test-profile"
  role = aws_iam_role.test_role.name
}

resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazon2023.id     #"ami-04c913012f8977029"
  instance_type               = var.instance_type              # "t2.micro"
  subnet_id                   = data.aws_subnets.public.ids[0] #Public Subnet ID, e.g. subnet-xxxxxxxxxxx "subnet-0caaf48818e0596cc"
  associate_public_ip_address = true
  # key_name                    = "victor-terraform-pair" #Change to your keyname, e.g. jazeel-key-pair
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name

  tags = {
    Name = "${var.name_prefix}-ec2" # Prefix your own name, e.g. jazeel-ec2
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "${var.name_prefix}-dynamoDB-securitygroup" #Security group name, e.g. jazeel-terraform-security-group
  description = "Allow SSH inbound"
  vpc_id      = data.aws_vpc.selected.id #VPC ID (Same VPC as your EC2 subnet above), E.g. vpc-xxxxxxx
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_https" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
