resource "aws_cloudfront_origin_access_identity" "site_identity" {}

resource "aws_cloudfront_distribution" "site_distro" {
  provider = "aws.site"

  origin {
    domain_name = "${var.source_bucket}"
    origin_id   = "site_bucket"
  }

  aliases             = ["${var.site_aliases}"]
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "site_bucket"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    default_ttl = 3000
    max_ttl     = 86400
    min_ttl     = 0

    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.cert_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}
