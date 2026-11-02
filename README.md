# service-b

Dummy service for a CI/CD flow demo. Every workflow step is a placeholder that passes.

## Release flow

1. Merge to `main`: this deploys to dev.
2. Run "Cut release branch": this creates a `release/*` branch and deploys it to staging.
3. Run "Ship to production": this tags the release branch and deploys the tag to production.
4. Fixes go to `main` first, then get cherry-picked into the `release/*` branch.
