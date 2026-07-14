# tofu

Code for Philly infrastructure managed with [OpenTofu](https://opentofu.org).

## Layout

One directory per **stack**. A stack is an independently-planned, independently-applied
unit with its own state:

| Stack | What it manages |
|---|---|
| [`dns/`](./dns) | Cloud DNS zones in the `openphl-1177` GCP project |

New stacks (Linode, GitHub org config, …) go in as sibling directories. Keep them
separate so a mistake in one can't destroy another — a single mega-state means every
apply risks everything.

## State

All stacks share one bucket, `gs://codeforphilly-tfstate`, separated by prefix:

```hcl
backend "gcs" {
  bucket = "codeforphilly-tfstate"
  prefix = "<stack-name>"   # dns, linode, ...
}
```

The bucket has **object versioning enabled**, so a corrupted or truncated state file
can be rolled back to a previous generation.

## Running

Applies are human-run. There is no CI apply, by design — nobody wants a DNS change
landing because a workflow re-ran.

```bash
cd tofu/<stack>
tofu init
tofu plan -concise      # always read this
tofu apply -concise
```

You need `gcloud auth application-default login` with an account that has access to
`openphl-1177`.

## Toolchain

`opentofu` is pinned in `.tool-versions` at the repo root. Run `asdf install` once.
