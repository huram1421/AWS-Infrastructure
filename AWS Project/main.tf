terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.45"
    }
  }
}


provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
} 

module "vpc" {
  source = "./VPC"
}

module "ec2" {
  source = "./EC2"

  # variables
  vpc_private_subnet = module.vpc.vpc_private_subnet
  vpc_public_subnet = module.vpc.vpc_public_subnet
  vpc = module.vpc.vpc
  
}

module "dynamodb" {
  source = "./DynamoDB"
}


module "lambda" {
  source = "./Lambda"
}

module "api" {
  source = "./API Gateway"

  # variables
  DriverLambdaArn = module.lambda.DriverLambdaArn
  DriverLambdaName = module.lambda.DriverLambdaName

  RiderLambdaArn = module.lambda.RiderLambdaArn
  RiderLambdaName = module.lambda.RiderLambdaName

}

output ec2_public_ip {
  value       = module.ec2.ec2_public_ip
  description = "ec2_public_ip"
}

output invoke_url {
  value       = module.api.invoke_url
  description = "invoke_url"
}





