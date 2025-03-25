###########################################################################################
######################################## CodeBuild Role ###################################
###########################################################################################

#codebuild 역할
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}CodebuildRole" #역할 이름

  assume_role_policy = jsonencode({ #ecs에서 사용 가능
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

#고객관리형 정책 생성
resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  description = "Codebuild, Cloudwatch, S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = [
          "arn:aws:logs:ap-northeast-2:${local.account_id}:log-group:/aws/codebuild/*"
        ]
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect   = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.codebuild_s3_name}", 
          "arn:aws:s3:::${var.codebuild_s3_name}/*",
          "arn:aws:s3:::sast-result-s3/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:UpdateService",
          "iam:PassRole"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage", 
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [
          "arn:aws:ecr:${var.aws_region}:${local.account_id}:repository/${var.project_name}_repo",
          "arn:aws:ecr:ap-northeast-2:711387094022:repository/owasp_zap_repo"
        ]
      },
      {
        Effect   = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = [
          "arn:aws:codebuild:${var.aws_region}:${local.account_id}:report-group/${var.project_name}-main-codebuild-*"
        ]
      }
    ]
  })
}

#위에서 생성한 정책을 Codebuild 역할에 연결
resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

###########################################################################################
######################################## Main CodeBuild ###################################
###########################################################################################

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

#파이프라인에 포함될 codebuild
resource "aws_codebuild_project" "main_codebuild" {
  name          = "${var.project_name}-codebuild"
  description   = "Codebuild included in the pipeline"
  service_role  = aws_iam_role.codebuild_role.arn #위에서 생성한 역할 설정

  artifacts {
    type = "NO_ARTIFACTS" #빌드 후 아티팩트 저장 X -> codepipeline에서 설정되기 때문
  }

  cache {
    type     = "NO_CACHE"
  }

  environment {
    compute_type   = "BUILD_GENERAL1_SMALL" #실행 컴퓨터 크기 -> 3GB, 2vCPU
    image          = "aws/codebuild/standard:5.0" 
    type           = "LINUX_CONTAINER" #리눅스 컨테이너
    image_pull_credentials_type = "CODEBUILD" #codebuild의 기본 이미지 사용
    privileged_mode = true #루트 권한 활성화 -> 빌드를 위해

    environment_variable {
      name  = "S3_BUCKET_NAME"
      value = var.sast_result_s3_name
    }

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "AWS_ID"
      value = local.account_id
    }

    environment_variable {
      name  = "SNYK_TOKEN"
      type  = "SECRETS_MANAGER"
      value = var.snyk_token_arn
    }

    environment_variable {
      name  = "SEMGREP_APP_TOKEN"
      type  = "SECRETS_MANAGER"
      value = var.semgrep_token_arn
    }

    environment_variable {
      name  = "ECR_REPO_URL"
      value = var.ecr_repository_url
    }
  }

    source { #코드를 가져올 곳
    type      = "GITHUB" #git 선택
    location  = var.git_repo_url #git url
    buildspec = <<EOF
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ID.dkr.ecr.$AWS_REGION.amazonaws.com
      - echo Successfully logged in to Amazon ECR.
      
      - echo Installing Snyk CLI...
      - curl -Lo /usr/local/bin/snyk https://static.snyk.io/cli/latest/snyk-linux
      - chmod +x /usr/local/bin/snyk
      - snyk --version
      - echo Snyk CLI installed successfully.
      
      - echo Installing semgrep..
      - pip install semgrep

  build:
    commands:
      - echo Building the Docker image...
      - docker build -t $PROJECT_NAME .
      - echo Docker image built successfully.
      
      - echo Authenticating with Snyk...
      - SNYK_TOKEN=$(echo $SNYK_TOKEN | jq -r '.SNYK_TOKEN')
      - snyk auth --token=$SNYK_TOKEN
      - echo Snyk authentication successful.
      
      - echo Generaging timestamp...
      - export TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
      
      - echo Running Semgrep scan...
      - SEMGREP_APP_TOKEN=$(echo $SEMGREP_APP_TOKEN | jq -r '.SEMGREP_APP_TOKEN')
      - semgrep ci --json > semgrep_results_$TIMESTAMP.json
      - echo Uploading Semgrep results to S3...
      - aws s3 cp semgrep_results_$TIMESTAMP.json s3://$S3_BUCKET_NAME/semgrep_results_$TIMESTAMP.json

      - echo Running Snyk container vulnerability scan...
      - snyk container test $PROJECT_NAME --file=Dockerfile --severity-threshold=high --token=$SNYK_TOKEN || echo "Container scan completed with issues"

  post_build:
    commands:
      - echo Uploading Snyk scan results to the Snyk dashboard...
      - snyk container monitor $PROJECT_NAME --file=Dockerfile || echo "Snyk monitor completed with issues"
      - echo Snyk results uploaded successfully.

      - echo Tagging the Docker image...
      - docker tag $PROJECT_NAME:latest $ECR_REPO_URL:latest
      - echo Docker image tagged successfully.

      - echo Pushing the Docker image to Amazon ECR...
      - docker push $ECR_REPO_URL:latest
      - echo Docker image pushed successfully.

      - echo Creating imagedefinitions.json file for ECS deployment...
      - echo "[{\"name\":\"$PROJECT_NAME\",\"imageUri\":\"$ECR_REPO_URL:latest\"}]" > imagedefinitions.json
      - echo imagedefinitions.json created successfully.

artifacts:
  files:
    - imagedefinitions.json
EOF
  }
}
