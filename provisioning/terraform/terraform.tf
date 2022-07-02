terraform {

  required_version = "~> 1.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.23"
    }
  }

  backend "s3" {
    bucket = "bas-terraform-remote-state-prod"
    key    = "v2/MAGIC-PRODUCTS-DISTRIBUTION/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "azuread" {
  # NERC Production AD
  tenant_id = "b311db95-32ad-438f-a101-7ba061712a4e"
}

resource "azuread_application" "magic-products-distribution" {
  display_name = "MAGIC Products Distribution Service"
  owners = [
    # Felix Fennell (Admin) [o365felnne@bas.ac.uk]
    "7aa5b9f2-25c1-4a88-8627-c0d7d1326b55"
  ]
  marketing_url                  = "https://gitlab.data.bas.ac.uk/MAGIC/products-distribution"
  sign_in_audience               = "AzureADMyOrg"
  group_membership_claims        = ["None"]
  fallback_public_client_enabled = true
  prevent_duplicate_names        = true

  feature_tags {
    hide = false
  }

  api {
    requested_access_token_version = 2
  }

  public_client {
    redirect_uris = [
      "https://login.microsoftonline.com/common/oauth2/nativeclient"
    ]
  }

  required_resource_access {
    # Microsoft graph
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      # 'offline_access' scope
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"
      type = "Scope"
    }
    resource_access {
      # 'openid' scope
      id   = "37f7f235-527c-4136-accd-4a02d197296e"
      type = "Scope"
    }
    resource_access {
      # 'email' scope
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"
      type = "Scope"
    }
    resource_access {
      # 'profile' scope
      id   = "14dad69e-099b-42c9-810b-d002981feec1"
      type = "Scope"
    }
    resource_access {
      # 'Files.ReadWrite.All' scope
      id   = "863451e7-0667-486c-a5d6-d135439485f0"
      type = "Scope"
    }
    resource_access {
      # 'User.Read' scope
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }

  optional_claims {
    id_token {
      name = "email"
    }
  }
}
