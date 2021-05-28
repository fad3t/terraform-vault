provider "vault" {
}

resource "vault_github_auth_backend" "github" {
  organization = "ktulu-networks"
}

resource "vault_github_team" "core" {
  backend  = vault_github_auth_backend.github.id
  team     = "core"
  policies = [vault_policy.rancher.name]
}

resource "vault_jwt_auth_backend" "gitlab" {
  jwks_url     = "https://bcgit.bc/-/jwks"
  bound_issuer = "bcgit.bc"
}

resource "vault_jwt_auth_backend_role" "project_216" {
  backend    = vault_jwt_auth_backend.gitlab.id
  role_name  = "rancher"
  user_claim = "user_email"
  bound_claims = {
    project_id = "216"
    ref        = "master"
    ref_type   = "branch"
  }
  token_policies = [vault_policy.rancher.name]
}

resource "vault_policy" "rancher" {
  name   = "rancher"
  policy = file("rancher.hcl")
}

resource "vault_generic_secret" "password" {
  path = "kv/rancher"
  data_json = "{\"password\": \"admin12345\"}"
}
