output vpc_private_subnet {
  value       = aws_subnet.vpc_private_subnet.id
}

output vpc_public_subnet {
  value       = aws_subnet.vpc_public_subnet.id
}

output vpc {
  value       = aws_vpc.vpc.id
}