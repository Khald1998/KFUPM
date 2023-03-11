# data "aws_iam_policy_document" "assume_role_policy_cidp" {
#   statement {
#     sid     = ""
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     condition {
#       test     = "StringEquals"
#       variable = "sts:ExternalId"
#       values   = ["12345"]
#     }

#     principals {
#       type        = "Service"
#       identifiers = ["cognito-idp.amazonaws.com"]
#     }
#   }
# }
# data "aws_iam_policy_document" "assume_role_policy" {
#   statement {
#     sid       = ""
#     effect    = "Allow"
#     resources = ["*"]
#     actions   = ["sns:publish"]
#   }
# }
# resource "aws_iam_role" "role_for_cidp" {
#   name               = "cognito-idp"
#   path               = "/service-role/"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy_cidp.json

# }
# resource "aws_iam_role_policy" "role_policy_for_cidp" {
#   name   = "cognito-idp"
#   role   = aws_iam_role.role_for_cidp.id
#   policy = data.aws_iam_policy_document.assume_role_policy.json

# }


module "create_store_bucket" {
    source = "./s3_bucket_create"
    permissions_for_store_mail = true
    set_acl = "private"
    s3_bucket_name = var.s3_bucket_name
}
module "s3_logs" {
  source  = "./s3_bucket_logs"
  s3_bucket_name_for_logs = "${var.s3_bucket_name}-logs"
  default_allow = false
  versioning_status = "Suspended"
}
module SES_email {
    source = "./SES"
    domain = var.domain
    enable_verification = true
    mail_from_domain = "bounce.${var.domain}"
    enable_spf_record = true
    enable_incoming_email = true
    enable_dmarc = true
    dmarc_rua = "Admin@${var.domain}"
    dmarc_ruf = "Admin@${var.domain}"
    ses_rule_set = "primary-rules"
    from_addresses     = ["m1@${var.domain}","m2@${var.domain}"]

    receive_s3_bucket=module.create_store_bucket.aws_s3_bucket_id
    receive_s3_prefix="ses"
    enable_email_identity = true
    aws_ses_email_identity_email= "no-reply@${var.domain}"
}
module "Cognito_new" {
    source = "./cognito"
    user_pool_name = "my-user-pool"
    email_verification_message = "Your verification code is {####}"
    email_verification_subject = "Verification code"    
    username_configuration = {
        case_sensitive =true
    }
    admin_create_user_config = {
        allow_admin_create_user_only = false
        email_message = "Dear {username}, your verification code is {####}."
        email_subject = "Here, your verification code"
        sms_message   = "Your username is {username} and temporary password is {####}."        
    }
    temporary_password_validity_days = 30
    # alias_attributes = [/*"phone_number",*/ "email", "preferred_username"]
    username_attributes = [/*"phone_number",*/ "email"]

    auto_verified_attributes = ["email"/*, "phone_number"*/]
    # sms_configuration = {
    #     external_id="12345"
    #     sns_caller_arn=aws_iam_role.role_for_cidp.arn
    #     sns_region     = "us-east-1"
    # }
    # device_configuration = {
    # }
    # email_configuration_configuration_set = "config_one"
    email_configuration_reply_to_email_address = "no-reply@biqalati.com"
    email_configuration_source_arn = "arn:aws:ses:us-east-1:562579738540:identity/no-reply@biqalati.com"
    email_configuration_email_sending_account="DEVELOPER"#DEVELOPER or COGNITO_DEFAULT
    email_configuration_from_email_address="no-reply@biqalati.com"
    verification_message_template = {                                                                        #The verification message templates configuration	
        verification_message_template_default_email_option  = "CONFIRM_WITH_LINK"                                                          #The default email option. Must be either CONFIRM_WITH_CODE or CONFIRM_WITH_LINK. Defaults to CONFIRM_WITH_CODE	    
        verification_message_template_email_subject_by_link = "Verification link"                                                     #The subject line for the email message template for sending a confirmation link to the user	
        verification_message_template_email_message_by_link = "Click the link below to verify your email address. {##Verify Email##}" #The default email option. Must be either CONFIRM_WITH_CODE or CONFIRM_WITH_LINK. Defaults to CONFIRM_WITH_CODE	

    }    
    domain = replace(var.domain, ".", "-")
    client_allowed_oauth_flows = ["code"] 
    client_allowed_oauth_flows_user_pool_client = true
    client_allowed_oauth_scopes = [/*"phone",*/ "email", "openid", "profile", "aws.cognito.signin.user.admin","https://biqalati.info/cognito-scope-name"] #Choose one or more of the following OAuth scopes to specify the access privileges that can be requested for access tokens.
    client_callback_urls        = ["http://localhost:8080/LogIn.html"]                                     # (Optional) List of allowed callback URLs for the identity providers.
    client_default_redirect_uri = "http://localhost:8080/LogIn.html"
    client_logout_urls          = ["http://localhost:8080/LogOut.html"]                                    #- (Optional) List of allowed logout URLs for the identity providers. 
    client_explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"] # (Optional) List of authentication flows (ADMIN_NO_SRP_AUTH, CUSTOM_AUTH_FLOW_ONLY, USER_PASSWORD_AUTH, ALLOW_ADMIN_USER_PASSWORD_AUTH, ALLOW_CUSTOM_AUTH, ALLOW_USER_PASSWORD_AUTH, ALLOW_USER_SRP_AUTH, ALLOW_REFRESH_TOKEN_AUTH).
    client_generate_secret     = false #(Optional) Should an application secret be generated.
    client_name = "My userpool client"
    client_prevent_user_existence_errors        = "ENABLED"
    client_supported_identity_providers         = ["COGNITO"]
    client_access_token_validity                = 6
    client_id_token_validity                    = 6
    client_refresh_token_validity               = 6
    recovery_mechanisms = [
        {
        name     = "verified_email"
        priority = 1
    },
    {
        name     = "verified_phone_number"
        priority = 2
    }
    ]
    resource_server_name = "resource-server-name"
    resource_server_identifier = "https://biqalati.info"
    resource_server_scope_name = "cognito-scope-name"
    resource_server_scope_description="..."
}



