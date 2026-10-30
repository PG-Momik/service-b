# Demo repository settings

These JSON files describe the branch and tag rules for this service. Committing them does not apply them to the repository.

- `trunk.json`: protect `main`, require one approval, squash merges, and the four named CI checks.
- `release-create.json`: let the Actions integration or repository admin create and delete `release/*` branches.
- `release.json`: require release PRs, one approval, the four CI checks, and `check-release-fix`. The live design calls for two approvals, but this two-account demo has only one reviewer for a developer's PR.
- `tag.json`: limit creation, updates, and deletion of `v*` tags to the Actions integration or repository admin.

Create `release-cut` and `release-tag` environments with the repository admin as required reviewer. Limit `staging` to `release/*` branches and `production` to `v*` tags. Those deploy environments need no second approval.
