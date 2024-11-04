variable "db_name" {
  description = "데이터베이스 이름"
  type        = string
}

variable "db_username" {
  description = "데이터베이스 사용자 이름"
  type        = string
}

variable "db_password" {
  description = "데이터베이스 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS 인스턴스 클래스"
  type        = string
}

variable "vpc_security_group_id" {
  description = "VPC 보안 그룹 ID"
  type        = string
}

variable "subnet_ids" {
  description = "RDS를 위한 서브넷 ID 목록"
  type        = list(string)
}
