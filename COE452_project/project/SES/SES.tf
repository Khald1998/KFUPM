terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
    }
  }
}
# A hosted zone is a container for records, and records contain information about how you want to route traffic for a specific domain, such as example.com, and its subdomains (acme.example.com, zenith.example.com). A hosted zone and the corresponding domain have the same name. There are two types of hosted zones:
data "cloudflare_zones" "domain" {
  filter {
    name = var.domain
  }
}


#
# SES Domain Verification
#

# This block tells SES that we'd like to register a domain for email sending and receiving
resource "aws_ses_domain_identity" "main" {
  domain = var.domain
}

# This block is a bit special, as Terraform resources go, as it is not creating anything on the AWS side. Instead, this is just going to wait until SES aknowledges the verification of the domain identity, i.e. until SES is able to witness the new DNS record we just created.
resource "aws_ses_domain_identity_verification" "main" {
  count = var.enable_verification ? 1 : 0
  domain     = aws_ses_domain_identity.main.id
  depends_on = [cloudflare_record.domain_verification]
}

# For email forwarding to work, we'll need two records in the DNS zone. First, we need to prove to our email provider (AWS SES) that we're really the owner of the domain, so it can feel good about sending emails in the name of that domain. So, to prove we own the DNS zone, we need to insert a special TXT record in the zone, which SES gives us. Fortunately, we don't have to copy-paste between two screens in the AWS console and can instead use an API for that. In Terraform terms: This block creates an appropriate record in the DNS zone
resource "cloudflare_record" "domain_verification" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "_amazonses.${aws_ses_domain_identity.main.id}"
  type    = "TXT"
  ttl     = "600"
  value   = aws_ses_domain_identity.main.verification_token
}

#
# SES DKIM Verification
#

# Unless you’re hosting your own mail server, you probably don’t need to worry about setting DKIM records as it would be set up by your mail vendor such as Google, Microsoft, etc. DKIM, is a lock and key Authentication process used to make sure that message is not altered in transit between the email sending server and the email receiving server.
# DomainKeys Identified Mail (DKIM) is an email security standard designed to make sure that an email that claims to have come from a specific domain was indeed authorized by the owner of that domain. It uses public-key cryptography to sign an email with a private key. Recipient servers can then use a public key published to a domain's DNS to verify that parts of the email have not been modified during the transit.

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "cloudflare_record" "dkim" {
  count   = 3
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name = format(
    "%s._domainkey.%s",
    element(aws_ses_domain_dkim.main.dkim_tokens, count.index),
    var.domain,
  )
  type  = "CNAME"
  value = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"
}

# SES MAIL FROM Domain
/*
  When an email is sent, 
  it has two addresses that indicate its source: a "From address" that's displayed to the message recipient,
  and a "MAIL FROM address" that indicates where the message originated. 
  The MAIL FROM address is sometimes called the envelope sender, 
  envelope from, bounce address, or Return Path address. 
  Mail servers use the MAIL FROM address to return bounce messages and other error notifications. 
  The MAIL FROM address is usually only viewable by recipients if they view the source code for the message.

  A bounce message or just "bounce" is an automated message from an email system,
  informing the sender of a previous message that the message has not been delivered (or some other delivery problem occurred).
  The original message is said to have "bounced"

  By default, messages that you send through Amazon SES use a subdomain of amazonses.com as the MAIL FROM domain. 
  Sender Policy Framework (SPF) authentication successfully validates these messages because the default MAIL
  FROM domain matches the application that sent the email— in this case, Amazon SES.

  While this level of authentication is sufficient for many senders, 
  other senders prefer to set the MAIL FROM domain to a domain that they own. 
  By setting up a custom MAIL FROM domain, your emails can comply with "Domain-based Message Authentication, 
  Reporting and Conformance" (DMARC). DMARC enables a sender's domain to indicate that emails sent from the domain are protected by one or more authentication systems.

  There are two ways to achieve DMARC validation: using Sender Policy Framework (SPF),
  and using DomainKeys Identified Mail (DKIM). 
  The only way to comply with DMARC through "SPF" is to use a custom "MAIL FROM domain", 
  because SPF validation requires the domain in the "From address" to match the "MAIL FROM" domain.
  By using your own "MAIL FROM" domain, you have the flexibility to use SPF, DKIM, or both to achieve DMARC validation.
*/

#
# SES MAIL FROM Domain
#

# Amazon SES sets the MAIL FROM domain for the messages that you send to a default value unless you specify your own domain.

resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain #(Required) Verified domain name or email identity to generate DKIM tokens for.
  mail_from_domain = var.mail_from_domain #(Required) Subdomain (of above domain) which is to be used as MAIL FROM address (Required for DMARC validation)
}

# SPF validaton record

resource "cloudflare_record" "spf_mail_from" {
  count = var.enable_spf_record ? 1 : 0
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name   = aws_ses_domain_mail_from.main.mail_from_domain
  type   = "TXT"
  ttl     = "600"  
  value  = "v=spf1 include:amazonses.com -all"
  /*
    #“v=spf1 +a +mx redirect=example.com -all”
    #"v = spf1" is a version number of the current record, and the rest are Mechanisms, Qualifiers, and Modifiers to specify different rules of SPF check. Here is what you can set up in your SPF record.

      https://mailtrap.io/blog/spf-records-explained/#:~:text=SPF%20record%20syntax,-First%2C%20let's%20anatomize&text=v%20%3D%20spf1%20is%20a%20version,up%20in%20your%20SPF%20record.&text=Defines%20the%20DNS%20MX%20record%20of%20the%20domain%20as%20authorized.
  */  
}

resource "cloudflare_record" "spf_domain" {
  count = var.enable_spf_record ? 1 : 0
  name   = aws_ses_domain_mail_from.main.domain   
  zone_id = data.cloudflare_zones.domain.zones[0].id
  type    = "TXT"
  value   = "v=spf1 include:amazonses.com -all"
}

# Sending MX Record


data "aws_region" "current" {}

# in order for emails to work with our domain, we need an MX record that tells other mail servers where to send their @ourdomain emails.

resource "cloudflare_record" "mx_send_mail_from" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name   = aws_ses_domain_mail_from.main.mail_from_domain
  type   = "MX"
  value = "feedback-smtp.${data.aws_region.current.name}.amazonses.com" 
  priority = 10
  proxied  = false
}

# Receiving MX Record

resource "cloudflare_record" "mx_receive" {
  count = var.enable_incoming_email ? 1 : 0
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name   = aws_ses_domain_mail_from.main.mail_from_domain
  priority = 10
  type   = "MX"
  value  = "inbound-smtp.${data.aws_region.current.name}.amazonaws.com"
}


#
# DMARC TXT Record
#

/*
  To get started with DMARC, you must have both your SPF and DKIM records set.

  DMARC record is a TXT record that defines what an email receiver should do 
  with mail sent on your domain behalf that is not aligned with your domain policy.

  The DMARC record is a TXT record that is added to your domain DNS; 
  It basically includes instructions for the receiving email server on how to handle mail sent under your domain 
  that does not align with your Policies.

  We can also specify inside our DMARC TXT record, an email address so that we can receive 2 very important reports:

  DMARC - Aggregate Report (RUA).

  DMARC - Forensic Report (RUA).


  A DMARC aggregate report contains information about the authentication status of messages sent on your domain behalf.
  Aggregate reports are free reports that are sent to you and contain information such as:

  Source that sent the message

  Domain that was used to send the message.

  Sending IP address.

  Number of messages sent on a specific date.

  DKIM/SPF sending domain.

  DKIM/SPF authentication result.

  DMARC results.



  A DMARC Forensic report are generated when the SPF or DKIM do not align with your DMARC.

  Forensic reports are free reports sent to you ONLY when an email sent by your domain fails DMARC authentication. It contains information such as:

  The email “to” field.

  The email “from” field. (From address, Mail from address, DKIM from address).

  IP address of the sender.

  The email “Subject” field.

  Authentication Result (SPF, DKIM, DMARC).

  Message ID.

  URLs.

  Delivery Result.

  ISP Information.

*/


resource "cloudflare_record" "txt_dmarc" {
  count = var.enable_dmarc ? 1 : 0
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    ="_dmarc.${var.domain}"
  type   = "TXT"
  ttl     = "600"  
  value = "v=DMARC1; p=${var.dmarc_p}; rua=mailto:${var.dmarc_rua}; ruf=mailto:${var.dmarc_ruf}; fo=1;"
  /*
    The syntax for DMARC record, is basically a combination of tags separated by a semicolon.

    “tag=value;tag=value;”

    At the bare minimum, your DMARC record will look like this: "v=DMARC1;p=reject;”.

    The “v” tag specifies the DMARC protocol version. There is only 1 DMARC version available which is DMARC1. This is a required field so you should always include it.

    The “p” tag allows you to specify how you want mail service providers to handle emails that are sent using your domain identity but are not aligned with your policy.

    You have 3 options. Do nothing, set p = 0. Or to quarantine or reject the email. I highly recommend you set it to reject the email to prevent anyone from sending emails using your domain name.

    Both the “v” and “p” tags are required. N ow we will cover all the optional tags.

    The “sp” tag is an optional tag. Like the “p” tag, it allows you to specific your policy but for subdomains. If you don’t include this, then the value to specified inside your “p” tag will be used.  
      
    The “pct” tag, is an optional tag. It allows you to specify the percentage of email messages in which your stated DMARC policy applies for. The values can be anywhere from 1 to 100. I always recommend you set it to 100%. This tells the email receiver to reject 100% of emails that fail DMARC authentication.

    The “rua” tag, is also an optional tag. It allows you to specify an email address or addresses to receive DMARC Aggregate Feedback reports too. I cannot emphasize how important it is to have this field set up. Even if your domain does not send emails, you should always set this record so you could get insights into domain spoofing or phishing attacks that impersonates your domain. You can specify multiple emails by separating them with a comma.  
      
  */
}

#
# SES Receipt Rule
#

/*
  Receipt rules tell Amazon SES how to handle incoming mail 
  by executing an ordered list of actions you specify. 
  This ordered list of actions can optionally be made dependant 
  on first matching a recipient condition; if not specified, 
  the actions will be applied to all identities that belong 
  to your verified domains.
*/
resource "aws_ses_receipt_rule" "main" {
  count = var.enable_incoming_email ? 1 : 0

  name          = format("%s-s3-rule", replace(var.domain, ".", "-"))
  rule_set_name = var.ses_rule_set
  recipients    = var.from_addresses
  enabled       = true
  scan_enabled  = true

  s3_action {
    position = 1

    bucket_name       = var.receive_s3_bucket
    object_key_prefix = var.receive_s3_prefix
    kms_key_arn       = var.receive_s3_kms_key_arn
  }
}





#
# SES Ruleset
#


# SES only allows one (just like Highlander and Lord of the Rings) rule set to
# be active at any point in time. So this will live in the app-global state file.


resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = var.ses_rule_set
}
resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
}



# # The final touch
# # We're almost done. The astute reader will have noted that, when we set up the Lambda function, we set the MailSender and MailRecipient values to aws_ses_email_identity.email.email, whereas we have not (yet) created an email resource of type aws_ses_email_identity. So we need to do that. It's a fairly simple-looking resource:
resource "aws_ses_email_identity" "main" {
  count = var.enable_email_identity ? 1 : 0
  email = var.aws_ses_email_identity_email
}
# # It's a bit special, though, like aws_ses_domain_identity_verification: while this one does create a record at the SES level, it will also wait for confirmation. The creation of this resource will trigger an email from AWS to the given email address, and the terraform apply command will wait until the link in said email has been clicked, validating that the owner of that address agrees to let SES send emails on their behalf.

