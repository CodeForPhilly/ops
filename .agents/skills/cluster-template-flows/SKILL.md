---
name: cluster-template-flows
description: >-
  Manage GitOps propagation across the cluster-template → civic-cloud → downstream-cluster
  chain: cutting releases, bumping hologit holosource pins, running projection QA, and
  validating that a change actually lands on a downstream cluster. Use this whenever you're
  bumping a `.holo/sources/*.toml` pin, releasing cluster-template or civic-cloud, propagating
  a change down the blueprint chain, projecting a holobranch (`git holo project`), diffing a
  projection against a deploy branch, or answering "why didn't my change show up downstream".
  Also use when the user mentions cluster-template, civic-cloud, the k8s-blueprint,
  holosources, holomappings, `git holo`, projection, or a downstream cluster picking up an
  upstream change.
---

# Cluster-template propagation flows

CodeForPhilly / Jarvus clusters are built by projecting a chain of hologit sources. A change
made upstream reaches a running cluster only by traveling that chain, one release and one pin
bump at a time. This skill is the runbook for driving that chain and proving a change arrived.

## The chain

```
JarvusInnovations/cluster-template   (the template: k8s-common, k8s-lke, docs)
        │  released develop→main, tagged vX.Y.Z
        ▼
civic-cloud/cluster-template         (pins cluster-template; projects the k8s-blueprint)
        │  released develop→main, tagged vX.Y.Z
        ▼
<downstream cluster repo>            (e.g. cfp-sandbox-cluster, cfp-live-cluster)
   pins civic-cloud; projects k8s-manifests(-github); GitOps-deploys to the cluster
```

Each arrow is a **holosource pin** (`.holo/sources/<name>.toml`) plus, for the two template
repos, a **release**. A change in cluster-template is invisible downstream until: it's
released, civic-cloud bumps its pin and releases, and the downstream repo bumps its
civic-cloud pin and deploys.

## Releasing cluster-template or civic-cloud

Both use the **develop→main Release-PR flow** (release-prepare / release-validate /
release-publish actions). Do not hand-roll this — **load the `release-flow` skill** and follow
it for: finding the `Release: v*` PR, pulling the bot `## Changelog`, sorting notes, choosing
the version bump, and merging to publish.

Two things this chain gets wrong by default, worth holding in mind while you're in
`release-flow`:

- **The bot titles every release as last-tag + patch.** A dependency bump that *delivers a
  new capability downstream* is a feature at the point of delivery — recompute to a minor.
  (Example: civic-cloud bumping cluster-template to pull in cert alerting is a minor for
  civic-cloud, even though its one commit is a `chore(deps)`.)
- **Write real release notes.** A civic-cloud release whose only commit is
  `chore(deps): bump cluster-template to vX` should describe *what that bump delivers* to
  downstream clusters, not just echo the commit.

## Bumping a holosource pin

The core operation. Four steps, and the order of the middle two is not optional.

```bash
# 1. Edit the ref (a tag for releases, a commit SHA to pin exactly, a branch to track).
#    Prefer a tag or SHA over a branch — tracking a branch means the source can change
#    under you and break a build the moment upstream merges.
$EDITOR .holo/sources/<name>.toml        # ref = "refs/tags/vX.Y.Z"

# 2. Fetch it. NEVER `git fetch <url> <refspec>` — that pollutes local refs/tags/ with
#    upstream's whole tag namespace.
git holo source fetch <name>

# 3. COMMIT THE PIN. `git holo project` reads the COMMITTED .holo config, not your working
#    tree — an uncommitted pin edit is silently invisible and you will project the OLD
#    content and think the change didn't propagate. (Alternatively `git holo project
#    --working`, but committing first is simpler and is what the QA below assumes.)
git add .holo/sources/<name>.toml && git commit -m "chore(deps): bump <name> to vX.Y.Z"

# 4. Project + diff (the QA — see below).
```

The commit-before-project rule is the single most common way this goes wrong: the projection
succeeds, produces stale output, and it looks like the upstream release is broken when in
fact the pin edit just never reached the projector.

## Projection QA

Never merge a pin bump (or any change) without projecting it and reading the diff against
what's deployed. The diff is the definitive preview — admission-webhook defaults and helm
side-effects surface here, not in the source.

```bash
git fetch origin
# downstream cluster repos:
SHA=$(git holo project k8s-manifests-github 2>&1 | tail -1)   # or k8s-manifests
# civic-cloud:
SHA=$(git holo project k8s-blueprint 2>&1 | tail -1)

git diff --name-status origin/deploys/k8s-manifests "$SHA"    # what changes on deploy
git show "$SHA":<path>                                        # spot-check content
```

Confirm three things:

1. **The intended change is present** — grep the projected tree for a marker of it
   (`git show "$SHA":<file> | grep <thing>`). If it's absent, suspect an uncommitted pin
   (step 3 above) before suspecting the upstream release.
2. **Nothing unexpected moved.** A pin bump should touch only what the upstream diff touched.
   Be aware the deploy diff also carries any *other* commits already on the branch but not yet
   deployed — those aren't from your bump.
3. **It still builds.** A projection that errors (helm/kustomize lens failure) prints an error
   instead of a tree SHA on the last line.

See the `hologit` skill for holosource / holomapping / lens mechanics.

## Propagating a change end to end

To get a cluster-template change onto a downstream cluster:

1. **cluster-template**: land the change on `develop`, then release (develop→main) via
   `release-flow`. → new `vX.Y.Z` tag.
2. **civic-cloud**: bump the cluster-template pin (steps above), projection-QA the
   `k8s-blueprint` (grep for the change), push `develop`, release via `release-flow`.
   → new civic-cloud `vX.Y.Z`.
3. **downstream cluster**: bump the civic-cloud pin on a branch, projection-QA
   `k8s-manifests-github`, open a PR, merge → the `Build → Deploy PR → deploy` pipeline
   applies it. Supply any per-cluster piece the change requires (e.g. a SealedSecret the new
   config references).
4. **Verify on the cluster** — `kubectl` for the actual deployed object, not just the
   projection.

Steps 1–2 are releases; if the user only owns some repos, hand those releases back to them
and drive the parts you can.

## Validating a change landed downstream — the whole point

Two levels, do both:

- **Projection level**: after the downstream pin bump, `git show "$SHA":<file> | grep <thing>`
  proves the upstream change is now *in the blueprint the cluster consumes*. This is the real
  proof the chain works — the change arrived by propagation, not by a local override.
- **Cluster level**: after deploy, verify the running object
  (`kubectl -n <ns> get <kind> ...`) and, when the change is user-facing, exercise it (fire the
  alert, hit the endpoint) rather than trusting that rendered config behaves.

Resist the temptation to "validate" by hand-applying the change directly to the downstream
cluster or dropping it into the cluster's own release-values. That tests the *content*
(already tested upstream) but not *propagation*, which is the thing in question. Let it flow
down.

## Gotchas

- **Commit the pin before projecting** (or `--project --working`). The #1 cause of "my change
  didn't propagate."
- **`git holo source fetch <name>`, never `git fetch <url> <ref>`** — the raw fetch pulls
  upstream tags into local `refs/tags/` and pollutes the namespace.
- **Bot release title is always last-tag + patch.** Recompute; a delivered feature is a minor.
- **hologit shallow-clone race** — `Build k8s-manifests` intermittently fails with
  `fatal: shallow file has changed since we read it`. It's flaky, not your change; rerun. Retry
  count scales with the number of upstream sources a repo pulls.
- **A deploy carries everything on the branch**, not just your bump — other undeployed commits
  ride along. Read the full projection diff so nothing unreviewed ships by surprise.
- **Pin to tags or SHAs, not branches.** A branch ref can change under a build; a `refs/heads/*`
  pin has broken a downstream build the moment upstream merged an incompatible change.
