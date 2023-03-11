//                          old


  output "id" {
    value       = join("", aws_api_gateway_rest_api.default.*.id)
    description = "The ID of the REST API."
  }
  output "root_resource_id" {
    value       = join("", aws_api_gateway_rest_api.default.*.root_resource_id)
    description = "The root_resource_id of the REST API."
  }
  output "execution_arn" {
    value       = join("", aws_api_gateway_rest_api.default.*.execution_arn)
    description = "The Execution ARN of the REST API."
  }

  output "tags" {
    value       = module.labels.tags
    description = "A mapping of tags to assign to the resource."
  }

//                          old
