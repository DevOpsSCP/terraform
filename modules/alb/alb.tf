# ALB 생성
resource "aws_lb" "Application_Load_Balancer" {
  name               = "${var.project_name}-alb" #alb 이름
  internal           = false #체계 : 인터넷 경계 (내부X)
  load_balancer_type = "application" #application load balancer 선택
  security_groups    = [var.alb_security_group_id] #alb용 보안 그룹 선택
  subnets            = [var.public_subnet_id_01, var.public_subnet_id_02] #퍼블릭 서브넷에 위치

  enable_deletion_protection = true #AWS API, Terraform으로 로드밸런서 삭제 금지
}

#대상 그룹 생성
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.project_name}-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true #health 체크 활성화
    protocol            = "HTTP"
    path                = "/health"  #상태 검사 경로
    port                = "traffic-port"  #상태 검사 포트 => 대상 그룹과 같은 포트
    healthy_threshold   = 5  #정상 임계값(연속 성공 횟수)
    unhealthy_threshold = 2  #비정상 임계값(연속 실패 횟수)
    timeout             = 6  #timeout
    interval            = 30  #상태 검사 간격
    matcher             = "200-299"  #정상 응답 코드
  }
}

#리스너 생성
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.Application_Load_Balancer.arn #로드밸런서 arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward" #받은 요청을 대상 그룹으로 전달
    target_group_arn = aws_lb_target_group.alb_target_group.arn #대상 그룹 arn
  }
}
