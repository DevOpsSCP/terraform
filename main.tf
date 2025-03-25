module "vpc" {
  source = "./modules/vpc"
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_id_01 = module.vpc.public_subnet_id_01
  public_subnet_id_02 = module.vpc.public_subnet_id_02
  alb_security_group_id = module.sg.alb_security_group_id
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
  ecs_container_port = module.ecs.ecs_container_port
}

module "ecr" {
  source = "./modules/ecr"
}

module "ecs" {
  source = "./modules/ecs"
  ecr_repository_url = module.ecr.ecr_repository_url
  private_subnet_id_01 = module.vpc.private_subnet_id_01
  private_subnet_id_02 = module.vpc.private_subnet_id_02
  ecs_security_group_id = module.sg.ecs_security_group_id
  alb_target_group_arn = module.alb.alb_target_group_arn
  cloudmap_service_arn = module.cloudmap.cloudmap_service_arn
}

module "cloudmap" {
  source = "./modules/cloudmap"
  vpc_id = module.vpc.vpc_id
}

module "dast" {
  source = "./modules/dast"
  codebuild_role_arn = module.codebuild.codebuild_role_arn
  dast_ecr_repository_url = module.ecr.dast_ecr_repository_url
  ecs_task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  cloudmap_service_name = module.cloudmap.cloudmap_service_name
  cloudmap_namespace_name = module.cloudmap.cloudmap_namespace_name
  ecs_container_port = module.ecs.ecs_container_port
  dast_result_s3_name = module.s3.dast_result_s3_name
}

module "codebuild" {
  source = "./modules/codebuild"
  sast_result_s3_name = module.s3.sast_result_s3_name
  codebuild_s3_name = module.s3.codebuild_s3_name
  ecr_repository_url = module.ecr.ecr_repository_url
  snyk_token_arn = module.secretsmanager.snyk_token_arn
  semgrep_token_arn = module.secretsmanager.semgrep_token_arn
}

module "s3" {
  source = "./modules/s3"
}

module "secretsmanager" {
  source = "./modules/secretsmanager"
}

module "lambda" {
  source = "./modules/lambda"
  ecs_cluster_name = module.ecs.ecs_cluster_name
  dast_ecs_task_definition_family = module.dast.dast_ecs_task_definition_family
  private_subnet_id_01 = module.vpc.private_subnet_id_01
  private_subnet_id_02 = module.vpc.private_subnet_id_02
  ecs_security_group_id = module.sg.ecs_security_group_id
  ecs_task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}

module "codepipeline" {
  source = "./modules/codepipeline"
  codebuild_s3_name = module.s3.codebuild_s3_name
  codebuild_name = module.codebuild.codebuild_name
  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
  lambda_function_name = module.lambda.lambda_function_name
  ecs_task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}
