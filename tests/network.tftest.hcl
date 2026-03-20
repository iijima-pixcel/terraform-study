run "network_test" {
  command = plan

  module {
    source = "../modules/network"
  }

  variables {
    name_prefix            = "Awsstudy"
    vpc_cidr               = "10.0.0.0/16"
    public_subnet_1a_cidr  = "10.0.1.0/24"
    public_subnet_1c_cidr  = "10.0.2.0/24"
    private_subnet_1a_cidr = "10.0.11.0/24"
    private_subnet_1c_cidr = "10.0.12.0/24"
  }

  assert {
    condition     = output.vpc_cidr == "10.0.0.0/16"
    error_message = "VPC の CIDR が仕様書どおりではありません。"
  }

  assert {
    condition     = output.public_subnet_1a_cidr == "10.0.1.0/24"
    error_message = "Public Subnet 1a の CIDR が仕様書どおりではありません。"
  }

  assert {
    condition     = output.public_subnet_1c_cidr == "10.0.2.0/24"
    error_message = "Public Subnet 1c の CIDR が仕様書どおりではありません。"
  }

  assert {
    condition     = output.private_subnet_1a_cidr == "10.0.11.0/24"
    error_message = "Private Subnet 1a の CIDR が仕様書どおりではありません。"
  }

  assert {
    condition     = output.private_subnet_1c_cidr == "10.0.12.0/24"
    error_message = "Private Subnet 1c の CIDR が仕様書どおりではありません。"
  }

  assert {
    condition     = startswith(output.vpc_name, "Awsstudy")
    error_message = "VPC の Name タグが命名規則を満たしていません。"
  }
}
