#네임스페이스 생성
resource "aws_service_discovery_private_dns_namespace" "cloudmap_namespace" {
  name        = "cloud_map.local" #네임스페이스 이름
  description = "Private task access namespace"
  vpc         = var.vpc_id #vpc 지정
}

#서비스 생성
resource "aws_service_discovery_service" "cloudmap_service" {
  name = "${var.project_name}-service" #서비스 이름

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cloudmap_namespace.id #네임스페이스 지정

    dns_records {
      ttl  = 60 #dns recursive resolver가 레코드의 설정을 캐싱하는 시간
      type = "A" #레코드 유형
    }

    routing_policy = "WEIGHTED" #라우팅 정책 => 가중치 기반 라우팅
  }
}
