# Learn Terraform Pipelines - Vault

This repo is a companion repo to the [Deploy Consul and Vault on Kubernetes with Run Triggers](https://learn.hashicorp.com/tutorials/terraform/kubernetes-consul-vault-pipeline?in=terraform/kubernetes), containing Terraform configuration files to provision Vault that uses Consul as a backend on a GKE cluster.

## Proof-of-Work Gate

Sensitive environments often need a speed bump before provisioning changes. This configuration now enforces a lightweight proof-of-work (PoW) requirement:

1. Retrieve the `project_id` and `host` outputs from the cluster workspace (the same values that populate `data.tfe_outputs.cluster`).
2. Compute the challenge string: `challenge = sha256("${project_id}-${host}")`.
3. Find a nonce such that `sha256("${challenge}:${nonce}")` starts with `pow_difficulty` leading zeroes (default is four).
4. Pass the nonce via `-var="pow_nonce=<nonce>"` (and optionally override `pow_difficulty`).

Terraform will halt planning/apply if the nonce is missing or invalid. The helper resource defined in `pow.tf` validates the PoW locally, and the same digest is exposed to policy checks so remote runs can verify it without re-computing hashes.

### Sample Solver (Python)

```python
import hashlib

challenge = "paste-challenge-from-step-2"
difficulty = 4  # matches pow_difficulty
prefix = "0" * difficulty
nonce = 0

while True:
    digest = hashlib.sha256(f"{challenge}:{nonce}".encode()).hexdigest()
    if digest.startswith(prefix):
        print(f"Found nonce: {nonce}")
        print(f"Digest    : {digest}")
        break
    nonce += 1
```

## Sentinel Policy

Terraform Cloud/Enterprise users can enforce the same PoW guardrail with Sentinel. The file `sentinel/pow_protection.sentinel` ensures that:

- the `terraform_data.pow_guard` resource is present in the plan,
- a `pow_nonce` value was supplied, and
- the digest recorded by the plan satisfies the configured difficulty.

Upload that policy to your TFC/TFE organization (typically as a soft mandatory policy) to block remote runs that skip or short-circuit the challenge. Remember to keep the PoW policy in sync with any future adjustments to `pow.tf`.
