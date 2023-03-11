//Create Lambda
provider "archive" {}

data "archive_file" "lambda-functions" {
    type = "zip"
    source_dir  = "./Lambda-Functions"
    output_path = "./Lambda-Functions.zip"
}

data "aws_iam_policy_document" "policy" {

  statement{
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }

}

data "aws_iam_policy_document" "policy2" {


  statement {
      sid       = ""
      effect    = "Allow"
      resources = ["*"]

      actions = [
        "dynamodb:*",
        "dax:*",
        "application-autoscaling:DeleteScalingPolicy",
        "application-autoscaling:DeregisterScalableTarget",
        "application-autoscaling:DescribeScalableTargets",
        "application-autoscaling:DescribeScalingActivities",
        "application-autoscaling:DescribeScalingPolicies",
        "application-autoscaling:PutScalingPolicy",
        "application-autoscaling:RegisterScalableTarget",
        "cloudwatch:DeleteAlarms",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:DescribeAlarmsForMetric",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:GetMetricData",
        "datapipeline:ActivatePipeline",
        "datapipeline:CreatePipeline",
        "datapipeline:DeletePipeline",
        "datapipeline:DescribeObjects",
        "datapipeline:DescribePipelines",
        "datapipeline:GetPipelineDefinition",
        "datapipeline:ListPipelines",
        "datapipeline:PutPipelineDefinition",
        "datapipeline:QueryObjects",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "iam:GetRole",
        "iam:ListRoles",
        "kms:DescribeKey",
        "kms:ListAliases",
        "sns:CreateTopic",
        "sns:DeleteTopic",
        "sns:ListSubscriptions",
        "sns:ListSubscriptionsByTopic",
        "sns:ListTopics",
        "sns:Subscribe",
        "sns:Unsubscribe",
        "sns:SetTopicAttributes",
        "lambda:CreateFunction",
        "lambda:ListFunctions",
        "lambda:ListEventSourceMappings",
        "lambda:CreateEventSourceMapping",
        "lambda:DeleteEventSourceMapping",
        "lambda:GetFunctionConfiguration",
        "lambda:DeleteFunction",
        "resource-groups:ListGroups",
        "resource-groups:ListGroupResources",
        "resource-groups:GetGroup",
        "resource-groups:GetGroupQuery",
        "resource-groups:DeleteGroup",
        "resource-groups:CreateGroup",
        "tag:GetResources",
        "kinesis:ListStreams",
        "kinesis:DescribeStream",
        "kinesis:DescribeStreamSummary",
      ]
    }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:cloudwatch:::insight-rule/DynamoDBContributorInsights*"]
    actions   = ["cloudwatch:GetInsightRuleReport"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["iam:PassRole"]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"

      values = [
        "application-autoscaling.amazonaws.com",
        "application-autoscaling.amazonaws.com.cn",
        "dax.amazonaws.com",
      ]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"

      values = [
        "replication.dynamodb.amazonaws.com",
        "dax.amazonaws.com",
        "dynamodb.application-autoscaling.amazonaws.com",
        "contributorinsights.dynamodb.amazonaws.com",
        "kinesisreplication.dynamodb.amazonaws.com",
      ]
    }
  } 
 
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "Our_lambda_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = data.aws_iam_policy_document.policy2.json
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "Our_iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}


resource "aws_lambda_function" "lambda-scan" {
  function_name = "scan"
  filename         = data.archive_file.lambda-functions.output_path
  source_code_hash = data.archive_file.lambda-functions.output_base64sha256
  role    = aws_iam_role.iam_for_lambda.arn
  handler = "scan.lambda_handler"
  runtime = "python3.9"
}

resource "aws_lambda_function" "lambda-search" {
  function_name = "search"
  filename         = data.archive_file.lambda-functions.output_path
  source_code_hash = data.archive_file.lambda-functions.output_base64sha256
  role    = aws_iam_role.iam_for_lambda.arn
  handler = "search.lambda_handler"
  runtime = "python3.9"
}

resource "aws_lambda_function" "lambda-order" {
  function_name = "order"
  filename         = data.archive_file.lambda-functions.output_path
  source_code_hash = data.archive_file.lambda-functions.output_base64sha256
  role    = aws_iam_role.iam_for_lambda.arn
  handler = "order.lambda_handler"
  runtime = "python3.9"
}

resource "aws_lambda_function" "lambda-fitch" {
  function_name = "fitch"
  filename         = data.archive_file.lambda-functions.output_path
  source_code_hash = data.archive_file.lambda-functions.output_base64sha256
  role    = aws_iam_role.iam_for_lambda.arn
  handler = "fitch.lambda_handler"
  runtime = "python3.9"
}



//Create API rest

  module "api-gateway" {
      source        = "./API_REST"

      name        = "serverless_lambda_gw_two"
      environment = "dev"
      label_order = ["name", "environment"]
      enabled     = true

    # Api Gateway Resource
      path_parts = ["lambda-scan","lambda-search","lambda-order"]

    # Api Gateway Method
      method_enabled = true
      http_methods   = ["GET","GET","GET"]

    # Api Gateway Integration
      integration_types        = ["AWS_PROXY","AWS_PROXY","AWS_PROXY"]
      integration_http_methods = ["POST","POST","POST"]
      uri                      = [
      "${aws_lambda_function.lambda-scan.invoke_arn}",
      "${aws_lambda_function.lambda-search.invoke_arn}",
      "${aws_lambda_function.lambda-order.invoke_arn}"]
      integration_request_parameters = [{},{},{}]
      request_templates = [{}, {}, {}]
      content_handlings        = ["CONVERT_TO_TEXT","CONVERT_TO_TEXT","CONVERT_TO_TEXT"]
      passthrough_behaviors    = ["WHEN_NO_MATCH","WHEN_NO_MATCH","WHEN_NO_MATCH"]


    # Api Gateway Method Response
      status_codes = [200, 200]
      response_models = [{}, {}, {}]
      response_parameters = [{},{}, {}]

    # Api Gateway Deployment
      deployment_enabled = true
      stage_name         = "deploy"
    # Api Gateway Stage
      stage_enabled = true
      stage_names   = [ "dev"]
    # Api Gateway Authorizer
    # authorizer_count                = 3
    # authorizer_types                = ["COGNITO_USER_POOLS","COGNITO_USER_POOLS", "COGNITO_USER_POOLS"]
    # authorizations =                ["COGNITO_USER_POOLS","COGNITO_USER_POOLS","COGNITO_USER_POOLS"]
    # enable_authorizer_id =  true
    # authorization_scopes = ["${module.Cognito_new.resource_servers_scope_identifiers}","${module.Cognito_new.resource_servers_scope_identifiers}","${module.Cognito_new.resource_servers_scope_identifiers}"]
    # provider_arns         = ["${module.Cognito_new.arn}","${module.Cognito_new.arn}","${module.Cognito_new.arn}"]

  }


  resource "aws_api_gateway_method" "proxy_root" {
    rest_api_id   = module.api-gateway.id
    resource_id   = module.api-gateway.root_resource_id
    http_method   = "GET"
    authorization = "NONE"
  }
  resource "aws_api_gateway_integration" "lambda_root_scan" {
    rest_api_id = module.api-gateway.id
    resource_id = module.api-gateway.root_resource_id
    http_method = "${aws_api_gateway_method.proxy_root.http_method}"

    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = "${aws_lambda_function.lambda-scan.invoke_arn}"
  }



  resource "aws_api_gateway_integration" "lambda_root_search" {
    rest_api_id = module.api-gateway.id
    resource_id = module.api-gateway.root_resource_id
    http_method = "${aws_api_gateway_method.proxy_root.http_method}"

    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = "${aws_lambda_function.lambda-search.invoke_arn}"
  }


  resource "aws_api_gateway_integration" "lambda_root_order" {
    rest_api_id = module.api-gateway.id
    resource_id = module.api-gateway.root_resource_id
    http_method = "${aws_api_gateway_method.proxy_root.http_method}"

    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = "${aws_lambda_function.lambda-order.invoke_arn}"
  }

//

//--------------------------------------------------------------------------------------

  # resource "aws_api_gateway_rest_api" "api" {
  #   name        = "serverless_lambda_gw_two"
  #   description = "Redundant description of the API Gateway resource."
  # }

  # resource "aws_api_gateway_deployment" "production" {
  #   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  #   stage_name  = "production"

  #   depends_on = [aws_api_gateway_integration.hello_world]
  # }

  # resource "aws_api_gateway_authorizer" "authorizer" {
  #   name          = "serverless_lambda_gw_two"
  #   type          = "COGNITO_USER_POOLS"
  #   rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  #   provider_arns = ["${module.Cognito_new.arn}"]
  # }

  # # /hello_world endpoint
  # resource "aws_api_gateway_resource" "hello_world" {
  #   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  #   parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  #   path_part   = "lambda"
  # }

  # resource "aws_api_gateway_method" "hello_world" {
  #   rest_api_id          = "${aws_api_gateway_rest_api.api.id}"
  #   resource_id          = "${aws_api_gateway_resource.hello_world.id}"
  #   http_method          = "GET"
  #   authorization        = "COGNITO_USER_POOLS"
  #   authorizer_id        = "${aws_api_gateway_authorizer.authorizer.id}"
  #   authorization_scopes = "${module.Cognito_new.resource_servers_scope_identifiers}"
  # }

  # resource "aws_api_gateway_integration" "hello_world" {
  #   rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  #   resource_id             = "${aws_api_gateway_resource.hello_world.id}"
  #   http_method             = "${aws_api_gateway_method.hello_world.http_method}"
  #   content_handling        = "CONVERT_TO_TEXT"
  #   integration_http_method = "GET"
  #   passthrough_behavior    = "WHEN_NO_MATCH"
  #   type                    = "AWS_PROXY"
  #   uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda-scan.arn}/invocations"
  # }

//--------------------------------------------------------------------------------------


//Create API http
  resource "aws_apigatewayv2_api" "api" {
    name          = "serverless_lambda_gw"
    protocol_type = "HTTP"
  }

  resource "aws_apigatewayv2_stage" "api_stage" {
    api_id = aws_apigatewayv2_api.api.id

    name        = "serverless_lambda_stage"
    auto_deploy = true
  }


  //Create Integration
  resource "aws_apigatewayv2_integration" "scan" {
    api_id = aws_apigatewayv2_api.api.id

    integration_uri    = aws_lambda_function.lambda-scan.invoke_arn
    integration_type   = "AWS_PROXY"
    integration_method = "POST"    # REST API communication between API Gateway and Lambda
  }

  resource "aws_apigatewayv2_route" "scan" {
    api_id = aws_apigatewayv2_api.api.id

    route_key = "GET /lambda/scan"
    target    = "integrations/${aws_apigatewayv2_integration.scan.id}"
  }


  resource "aws_apigatewayv2_integration" "search" {
    api_id = aws_apigatewayv2_api.api.id

    integration_uri    = aws_lambda_function.lambda-search.invoke_arn
    integration_type   = "AWS_PROXY"
    integration_method = "POST"    # REST API communication between API Gateway and Lambda
  }

  resource "aws_apigatewayv2_route" "search" {
    api_id = aws_apigatewayv2_api.api.id

    route_key = "GET /lambda/search"
    target    = "integrations/${aws_apigatewayv2_integration.search.id}"
  }


  resource "aws_apigatewayv2_integration" "order" {
    api_id = aws_apigatewayv2_api.api.id

    integration_uri    = aws_lambda_function.lambda-order.invoke_arn
    integration_type   = "AWS_PROXY"
    integration_method = "POST"    # REST API communication between API Gateway and Lambda
  }

  resource "aws_apigatewayv2_route" "order" {
    api_id = aws_apigatewayv2_api.api.id

    route_key = "GET /lambda/order"
    target    = "integrations/${aws_apigatewayv2_integration.order.id}"
  }
//

//lambda_permission_rest
  resource "aws_lambda_permission" "api_gw_scan_rest_alt" {
  statement_id  = "AllowAPIGatewayInvoke_alt"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-scan.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${module.api-gateway.execution_arn}/*/*"
  }
  resource "aws_lambda_permission" "api_gw_search_rest_alt" {
  statement_id  = "AllowAPIGatewayInvoke_alt"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-search.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${module.api-gateway.execution_arn}/*/*"
  }
  resource "aws_lambda_permission" "api_gw_order_rest_alt" {
  statement_id  = "AllowAPIGatewayInvoke_alt"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-order.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${module.api-gateway.execution_arn}/*/*"
  }
  resource "aws_lambda_permission" "api_gw_scan_rest" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-scan.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${module.api-gateway.execution_arn}/*/*/*"
  }
  resource "aws_lambda_permission" "api_gw_search_rest" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-search.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${module.api-gateway.execution_arn}/*/*/*"
  }
  resource "aws_lambda_permission" "api_gw_order_rest" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-order.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${module.api-gateway.execution_arn}/*/*/*"
  }
//

//lambda_permission_http
  resource "aws_lambda_permission" "api_gw_scan" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-scan.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
  }

  resource "aws_lambda_permission" "api_gw_search" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-search.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
  }

  resource "aws_lambda_permission" "api_gw_order" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-order.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
  }
//

// Create VPC
  resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    
    enable_dns_support = "true"
    enable_dns_hostnames = "true"

    tags = {
        Name = "vpc"
    }
  }
//

// Create Security Group
  resource "aws_security_group" "ssh_allowed" {
      vpc_id = aws_vpc.vpc.id
      
      egress {
          from_port = 0
          to_port = 0
          protocol = -1
          cidr_blocks = ["0.0.0.0/0"]
      }
      ingress {
          from_port = 22
          to_port = 22
          protocol = "tcp"
          // Do not use this in production, should be limited to your own IP
          cidr_blocks = ["0.0.0.0/0"]
      }
      ingress {
          from_port = 80
          to_port = 80
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
      }
      tags = {
          Name = "ssh-allowed"
      }
  }
//

// Create Public subnet
  resource "aws_subnet" "public_1" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.0.0/24"

    map_public_ip_on_launch = "true" # This is what makes it a public subnet

    tags = {
      Name = "public-subnet-groceries-admin"
    }
  }
//

//Create Private subnet
  resource "aws_subnet" "private_1" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
      Name = "private-subnet-managingStoreInventory"
    }
  }

  resource "aws_subnet" "private_2" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.2.0/24"

    tags = {
      Name = "private-subnet-database-main"
    }
  }

  resource "aws_subnet" "private_3" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.3.0/24"

    tags = {
      Name = "private-subnet-database-Backup"
    }
  }

  resource "aws_subnet" "private_4" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.4.0/24"

    tags = {
      Name = "private-subnet-nearestGroceries"
    }
  }

  resource "aws_subnet" "private_5" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.5.0/24"

    tags = {
      Name = "private-subnet-sorting"
    }
  }
//

//Create Internet gateway
  resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
      Name = "main-internet-gateway"
    }
  }


  //Create Elastic IP for NAT gateway 
  resource "aws_eip" "nat_eip" {
    vpc      = true
    depends_on = [aws_internet_gateway.gw]
    tags = {
      Name = "NAT Gateway EIP"
    }
  }

  //Create Main NAT Gateway for VPC
  resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_1.id

    tags = {
      Name = "Main Nat Gateway"
    }

    # To ensure proper ordering, it is recommended to add an explicit dependency
    # on the Internet Gateway for the VPC.
    depends_on = [aws_internet_gateway.gw]
  }


  //Create Route Table for Public Subnet
  resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
      Name = "Public Route Table"
    }
  }

  //Make Association between Public Subnet and Public Route Table
  resource "aws_route_table_association" "public" {
    subnet_id      = aws_subnet.public_1.id
    route_table_id = aws_route_table.public.id
  }


  //Create Route Table for Private Subnet
  resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
      Name = "Private Route Table"
    }
  }

  //Association between Private Subnet and Private Route Table
  resource "aws_route_table_association" "private1" {
    subnet_id      = aws_subnet.private_1.id
    route_table_id = aws_route_table.private.id
  }

  resource "aws_route_table_association" "private2" {
    subnet_id      = aws_subnet.private_2.id
    route_table_id = aws_route_table.private.id
  }

  resource "aws_route_table_association" "private3" {
    subnet_id      = aws_subnet.private_3.id
    route_table_id = aws_route_table.private.id
  }

  resource "aws_route_table_association" "private4" {
    subnet_id      = aws_subnet.private_4.id
    route_table_id = aws_route_table.private.id
  }

  resource "aws_route_table_association" "private5" {
    subnet_id      = aws_subnet.private_5.id
    route_table_id = aws_route_table.private.id
  }
//

//Create EC2 
  resource "aws_instance" "private1" {
    ami           = "ami-0b0dcb5067f052a63" 
    instance_type = "t2.micro"

    subnet_id = aws_subnet.private_1.id
    vpc_security_group_ids = [aws_security_group.ssh_allowed.id]

    tags = {
      Name = "EC2 - Managing Store Inventory"
    }
  }

  resource "aws_instance" "private4" {
    ami           = "ami-0b0dcb5067f052a63" 
    instance_type = "t2.micro"

    subnet_id = aws_subnet.private_4.id
    vpc_security_group_ids = [aws_security_group.ssh_allowed.id]

    tags = {
      Name = "EC2 - Nearest Groceries"
    }
  }

  resource "aws_instance" "private5" {
    ami           = "ami-0b0dcb5067f052a63" 
    instance_type = "t2.micro"

    subnet_id = aws_subnet.private_5.id
    vpc_security_group_ids = [aws_security_group.ssh_allowed.id]

    tags = {
      Name = "EC2 - Sorting"
    }
  }
//