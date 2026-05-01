# GitHub Actions CI/CD - Overview

**Pattern Type:** Continuous Integration / Continuous Deployment  
**Complexity:** Intermediate  
**Read Time:** ~3 minutes  
**Best For:** Automated Docker builds, container registry publishing

---

## When to Use GitHub Actions

### ✅ Use GitHub Actions For

- **Automated Docker builds** - Build on every push to main
- **Container registry publishing** - Push to GHCR, Docker Hub
- **CI testing** - Run tests before merge
- **Multi-service applications** - Separate workflow per service
- **Branch-based deployments** - main → prod, dev → staging

### ❌ Consider Alternatives When

- **Self-hosted GitLab** - Use GitLab CI instead
- **Very large repos** - GitHub Actions minutes limits
- **Complex multi-stage pipelines** - May need Jenkins/CircleCI
- **Non-GitHub hosting** - Can't use GitHub Actions

### vs. Alternatives

| CI/CD Tool | Pros | Cons |
|------------|------|------|
| **GitHub Actions** | Integrated, free for public, easy | Minutes limits for private repos |
| **GitLab CI** | More features, self-hostable | Requires GitLab |
| **Jenkins** | Self-hosted, unlimited | Complex setup, maintenance |
| **CircleCI** | Fast, good UI | Costs add up |

**Key insight:** GitHub Actions perfect for GitHub-hosted projects. Free tier generous for most projects.

---

## Essential Configuration

### Enable GHCR (GitHub Container Registry)

**One-time setup:**
1. GitHub Settings → Developer settings → Personal access tokens
2. Create token with `write:packages` permission
3. **Not needed for workflows** - `GITHUB_TOKEN` has permission automatically

**Public vs Private images:**
- Public: Anyone can pull (free)
- Private: Only authenticated users (counts against storage quota)

### Workflow File Structure

**Location:** `.github/workflows/<name>.yml`

**Basic structure:**
```yaml
name: Workflow Name

on:                    # Trigger conditions
  push:
    branches: [main]

jobs:
  job-name:
    runs-on: ubuntu-latest
    steps:
      - name: Step 1
        uses: actions/checkout@v4
      - name: Step 2
        run: echo "Hello"
```

---

## Minimal Working Examples

### 1. Basic Docker Build & Push

**.github/workflows/build-api.yml:**
```yaml
name: Build API image

on:
  push:
    branches: [main]
    paths:
      - 'api/**'                          # Only trigger on api changes
      - '.github/workflows/build-api.yml'
  workflow_dispatch: {}                   # Manual trigger button

permissions:
  contents: read
  packages: write                         # Required for GHCR push

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: ./api
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/myapp/api:main
```

**What this does:**
1. Triggers when `api/` files change
2. Logs into GHCR (automatic with `GITHUB_TOKEN`)
3. Builds `api/Dockerfile`
4. Pushes to `ghcr.io/yourorg/myapp/api:main`

**Manual trigger:** GitHub → Actions → Build API → Run workflow

### 2. Multi-Tag Strategy

**Generate multiple tags (main, latest, git sha):**

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository_owner }}/myapp/api
          tags: |
            type=ref,event=branch         # main, dev, etc.
            type=sha,prefix={{branch}}-   # main-abc123
            type=raw,value=latest         # latest

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: ./api
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

**Generated tags:**
- `ghcr.io/yourorg/myapp/api:main`
- `ghcr.io/yourorg/myapp/api:main-abc1234`
- `ghcr.io/yourorg/myapp/api:latest`

**Use case:** `latest` for demo environments, `main-sha` for rollback.

### 3. PR Testing Workflow

**Run tests on pull requests (don't push image):**

**.github/workflows/test-api.yml:**
```yaml
name: Test API

on:
  pull_request:
    branches: [main]
    paths:
      - 'api/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          cd api
          pip install -r requirements.txt

      - name: Run tests
        run: |
          cd api
          pytest --cov=app tests/

      - name: Build Docker image (test only)
        run: |
          docker build -t api-test ./api
```

**Blocks merge if tests fail.**

### 4. Multi-Service Workflow

**Build multiple services in parallel:**

```yaml
name: Build All Services

on:
  push:
    branches: [main]

jobs:
  build-auth:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: ./auth
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/myapp/auth:main

  build-api:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: ./api
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/myapp/api:main
```

**Jobs run in parallel (faster).**

**Better approach:** Separate workflow per service (only build changed service).

### 5. Environment-Specific Deployments

**Deploy to staging on dev branch, production on main:**

```yaml
name: Deploy

on:
  push:
    branches: [main, dev]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.ref_name == 'main' && 'production' || 'staging' }}
    steps:
      - name: Deploy to ${{ github.ref_name }}
        run: |
          echo "Deploying to ${{ github.ref_name }} environment"
          # SSH to VPS and pull latest images
```

**GitHub Environments:** Settings → Environments → Add protection rules

---

## Common Operations

### Trigger Conditions

```yaml
# On push to main only
on:
  push:
    branches: [main]

# On push to any branch
on: [push]

# On pull request
on:
  pull_request:
    branches: [main]

# On specific paths
on:
  push:
    paths:
      - 'api/**'
      - 'Dockerfile'

# Manual trigger
on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to deploy'
        required: true
```

### Using Secrets

**Add secrets:** Settings → Secrets → Actions → New repository secret

**Use in workflow:**
```yaml
jobs:
  deploy:
    steps:
      - name: Use secret
        env:
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          echo "API_KEY is set"
```

**Available automatic secrets:**
- `${{ secrets.GITHUB_TOKEN }}` - Auto-generated, used for GHCR
- `${{ github.actor }}` - Username who triggered workflow
- `${{ github.sha }}` - Git commit SHA

### Caching Dependencies

**Speed up builds with caching:**
```yaml
- name: Cache pip packages
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}

- name: Install dependencies
  run: pip install -r requirements.txt
```

---

## Top 5 Gotchas

### 1. Missing Package Write Permission ⚠️

```yaml
# ❌ Wrong: No permissions declared
jobs:
  build:
    steps:
      - uses: docker/login-action@v3  # Will fail!

# ✅ Correct: Add packages permission
permissions:
  contents: read
  packages: write

jobs:
  build: ...
```

**Impact:** "denied: permission_denied" error when pushing to GHCR.

### 2. Workflow Triggers on Every Commit (Wasted CI Minutes)

```yaml
# ❌ Wrong: Rebuilds all services on any change
on:
  push:
    branches: [main]

# ✅ Correct: Only rebuild changed service
on:
  push:
    branches: [main]
    paths:
      - 'api/**'
      - '.github/workflows/build-api.yml'
```

**Impact:** 5 services × 5 min = 25 CI minutes per commit (wasteful).

### 3. Hardcoded Repository Owner

```yaml
# ❌ Wrong: Breaks when forked
tags: ghcr.io/myusername/myapp/api:main

# ✅ Correct: Use github.repository_owner
tags: ghcr.io/${{ github.repository_owner }}/myapp/api:main
```

**Impact:** Forks can't push to GHCR (permission denied).

### 4. Docker Attestation Warnings

```yaml
# ❌ Wrong: Generates attestation warnings on older Docker
- uses: docker/build-push-action@v6
  with:
    push: true

# ✅ Correct: Disable provenance
- uses: docker/build-push-action@v6
  with:
    push: true
    provenance: false
```

**Impact:** Warning messages, potential compatibility issues.

### 5. No Manual Trigger Option

```yaml
# ❌ Wrong: Can only trigger via push
on:
  push:
    branches: [main]

# ✅ Better: Add manual trigger
on:
  push:
    branches: [main]
  workflow_dispatch: {}  # Adds "Run workflow" button
```

**Impact:** Can't trigger build manually (hotfix, rollback).

---

## Quick Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Permission denied (GHCR) | No packages permission | Add `permissions: packages: write` |
| Workflow doesn't trigger | Wrong path filter | Check `paths:` matches changed files |
| Can't manual trigger | No workflow_dispatch | Add `workflow_dispatch: {}` |
| Build every commit | No path filter | Add paths to only build changed services |
| Attestation warnings | Provenance enabled | Add `provenance: false` |

---

## References

📎 **Reference**: [github-actions-reference.md](github-actions-reference.md)  
**When to load**: Multi-platform builds, advanced caching, matrix builds, deployment workflows, environments, OIDC authentication (~510 lines)

📎 **Related patterns**:
- [docker-overview.md](docker-overview.md) - Building Docker images
- [vps-deployment-overview.md](vps-deployment-overview.md) - Deploying from GHCR
- [environment-config-overview.md](environment-config-overview.md) - Managing secrets

---

**Pattern Type:** CI/CD  
**Last Updated:** 2026-03-07  
**Complexity:** Intermediate ⭐⭐⭐☆☆
