locals {
  # Derive a deterministic challenge from cluster metadata so it cannot be guessed in advance.
  pow_challenge_source = format("%s-%s", data.tfe_outputs.cluster.values.project_id, data.tfe_outputs.cluster.values.host)
  pow_challenge        = sha256(local.pow_challenge_source)
  pow_digest           = sha256(format("%s:%s", local.pow_challenge, var.pow_nonce))
  pow_pattern          = format("^0{%d}", var.pow_difficulty)
}

resource "terraform_data" "pow_guard" {
  triggers_replace = {
    digest = nonsensitive(local.pow_digest)
  }

  lifecycle {
    precondition {
      condition     = length(trimspace(var.pow_nonce)) > 0
      error_message = "Provide pow_nonce to continue."
    }

    precondition {
      condition = can(regex(local.pow_pattern, local.pow_digest))
      error_message = format(
        "Proof-of-work failed. sha256('%s:<nonce>') must start with %d leading zeros.",
        local.pow_challenge,
        var.pow_difficulty
      )
    }
  }
}

output "pow_challenge" {
  description = "Deterministic challenge string that must be combined with the nonce."
  value       = local.pow_challenge
}

output "pow_difficulty" {
  description = "Number of leading hexadecimal zeros required in the digest."
  value       = var.pow_difficulty
}
