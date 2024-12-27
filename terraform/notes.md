#Terraform notes


```t
provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "gab_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "gab-vpc"
  }
}

resource "aws_subnet" "gab_subnet" {
  count = 2
  vpc_id                  = aws_vpc.gab_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.gab_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["eu-west-2a", "eu-west-2c"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "gab-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "gab_igw" {
  vpc_id = aws_vpc.devopsshack_vpc.id

  tags = {
    Name = "gab-igw"
  }
}

resource "aws_route_table" "gab_route_table" {
  vpc_id = aws_vpc.gab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gab_igw.id
  }

  tags = {
    Name = "gab-route-table"
  }
}

resource "aws_route_table_association" "a" {
  count          = 2
  subnet_id      = aws_subnet.gab_subnet[count.index].id
  route_table_id = aws_route_table.gab_route_table.id
}

resource "aws_security_group" "gab_cluster_sg" {
  vpc_id = aws_vpc.gab_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gab-cluster-sg"
  }
}

resource "aws_security_group" "gab_node_sg" {
  vpc_id = aws_vpc.gab_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gab-node-sg"
  }
}

resource "aws_eks_cluster" "gab" {
  name     = "gab-cluster"
  role_arn = aws_iam_role.devopsshack_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.gab_subnet[*].id
    security_group_ids = [aws_security_group.gab_cluster_sg.id]
  }
}

resource "aws_eks_node_group" "gab" {
  cluster_name    = aws_eks_cluster.gab.name
  node_group_name = "gab-node-group"
  node_role_arn   = aws_iam_role.gab_node_group_role.arn
  subnet_ids      = aws_subnet.gab_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.large"]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = [aws_security_group.gab_node_sg.id]
  }
}

resource "aws_iam_role" "gab_cluster_role" {
  name = "gab-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "gab_cluster_role_policy" {
  role       = aws_iam_role.gab_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "gab_node_group_role" {
  name = "gab-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "gab_node_group_role_policy" {
  role       = aws_iam_role.gab_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "gab_node_group_cni_policy" {
  role       = aws_iam_role.gab_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "gab_node_group_registry_policy" {
  role       = aws_iam_role.gab_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
```t