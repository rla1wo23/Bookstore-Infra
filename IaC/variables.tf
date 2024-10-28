variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"  # 원하는 Kubernetes 버전으로 설정
}

variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2" 
}

variable "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

# RDS 변수
variable "db_name" {
  description = "데이터베이스 이름"
  type        = string
  default     = "book_db"
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
  default     = "db.t3.micro"
}

# EKS 변수
variable "eks_cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
  default     = "bookstore-eks"
}

variable "eks_cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "EKS 워커 노드 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "워커 노드의 원하는 개수"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "워커 노드의 최소 개수"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "워커 노드의 최대 개수"
  type        = number
  default     = 3
}

# S3 변수
variable "frontend_bucket_name" {
  description = "프론트엔드용 S3 버킷 이름"
  type        = string
  default     = ""
}
