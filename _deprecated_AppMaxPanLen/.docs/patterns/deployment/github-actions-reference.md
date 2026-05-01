# GitHub Actions CI/CD Patterns

**Pattern Type:** Continuous Integration / Continuous Deployment  
**Best For:** Automated builds, container registry publishing  
**Source:** Enterprise application  
**Complexity:** ⭐⭐⭐☆☆

---

## Overview

GitHub Actions workflows for building Docker images and publishing to GitHub Container Registry (GHCR). Covers trigger patterns, multi-platform builds, caching strategies, and automated deployment workflows.

**Key Characteristics:**
- Triggered by code changes (push, PR, manual)
- Builds Docker images automatically
- Publishes to private/public GHCR
- Supports multi-platform builds (amd64, arm64)
- Uses GitHub secrets for credentials

---

## When to Use

### ✅ Use GitHub Actions For:
- **Automated Docker builds** (on every push to main)
- **CI testing** (run tests before merge)
- **Container registry publishing** (GHCR, Docker Hub)
- **Multi-service applications** (separate workflow per service)
- **Branch-based deployments** (main → production, dev → staging)

### ❌ Consider Alternatives When:
- Self-hosted GitLab (use GitLab CI)
- Complex orchestration (may need dedicated CI server)
- Large private repos (GitHub Actions minutes limits)

---

## Key Workflow Patterns

### 1. Basic Docker Build & Push (Single Service)

**File:** `.github/workflows/build-auth.yml`

```yaml
name: Build and publish Auth image

on:
  push:
    branches: [ main ]
    paths:
      - 'auth/**'                        # Only trigger on auth changes
      - '.github/workflows/build-auth.yml'
  workflow_dispatch: {}                  # Manual trigger

permissions:
  contents: read
  packages: write                        # Required for GHCR push

jobs:
  build-auth:
    name: Build Auth image
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata (tags, labels)
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository_owner }}/myapp/auth
          tags: |
            type=ref,event=branch      # main, dev, etc.
            type=sha                    # git commit sha
            type=raw,value=latest       # latest tag

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: ./auth
          push: true
          provenance: false              # Avoid attestation warnings
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

**What this does:**
1. Triggers on push to `main` (only if `auth/` files changed)
2. Logs into GHCR using `GITHUB_TOKEN` (automatic, no setup needed)
3. Generates tags: `main`, `sha-abc123`, `latest`
4. Builds Docker image from `auth/Dockerfile`
5. Pushes to `ghcr.io/yourorg/myapp/auth:main`, `auth:latest`, etc.

**Key decisions:**
- **`paths` filter**: Only rebuild auth when auth code changes (saves CI minutes)
- **`workflow_dispatch`**: Allows manual triggering from GitHub UI
- **`provenance: false`**: Avoids Docker attestation warnings on some platforms

---

### 2. Multi-Platform Builds (amd64 + arm64)

**For deploying to multiple architectures (Intel/AMD + ARM)**

```yaml
jobs:
  build-api:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3  # Required for multi-platform

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

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
          platforms: linux/amd64,linux/arm64  # Multi-platform
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/myapp/api:main
```

**When to use:**
- Deploying to ARM-based servers (Raspberry Pi, AWS Graviton)
- Supporting Mac M1/M2 users for local development
- Future-proofing for ARM adoption

**Trade-off:** Builds take ~2x longer (each platform built separately)

---

### 3. Path-Based Triggers (Separate Workflows)

**Pattern:** One workflow per service (only rebuild what changed)

**Folder structure:**
```
.github/workflows/
├── build-auth.yml       # Triggers on auth/** changes
├── build-api.yml        # Triggers on api/** changes
└── build-webui.yml      # Triggers on webui/** changes
```

**build-api.yml:**
```yaml
on:
  push:
    branches: [ main ]
    paths:
      - 'api/**'
      - '.github/workflows/build-api.yml'
```

**build-webui.yml:**
```yaml
on:
  push:
    branches: [ main ]
    paths:
      - 'webui/**'
      - '.github/workflows/build-webui.yml'
```

**Benefit:** Push to `auth/` only rebuilds auth (saves 5-10 min per push)

**Common paths patterns:**
```yaml
paths:
  - 'api/**'                  # All files under api/
  - '!api/**/*.md'            # Exclude markdown (docs don't need rebuild)
  - 'api/requirements.txt'    # Specific file
  - '.github/workflows/build-api.yml'  # Workflow itself
```

---

### 4. Build Summary (GitHub Step Summary)

**Pattern:** Show build results in GitHub Actions UI

```yaml
- name: Build and push
  id: build
  uses: docker/build-push-action@v6
  with:
    context: ./api
    push: true
    tags: ghcr.io/myorg/myapp/api:main

- name: Publish build summary
  if: always()  # Run even if build fails
  run: |
    {
      echo "### API image published";
      echo "";
      echo "Repository: ghcr.io/myorg/myapp/api";
      echo "";
      echo "Tags:";
      echo "${{ steps.meta.outputs.tags }}" | sed 's/^/- /';
      echo "";
      echo "Digest: \`${{ steps.build.outputs.digest }}\`";
    } >> "$GITHUB_STEP_SUMMARY"
```

**Output in GitHub UI:**
```
### API image published

Repository: ghcr.io/myorg/myapp/api

Tags:
- ghcr.io/myorg/myapp/api:main
- ghcr.io/myorg/myapp/api:sha-abc123

Digest: `sha256:abc123...`
```

---

### 5. Conditional Builds (Draft PRs, Specific Branches)

**Skip builds for draft PRs:**
```yaml
on:
  pull_request:
    types: [ opened, synchronize, reopened, ready_for_review ]

jobs:
  build:
    if: github.event.pull_request.draft == false
    runs-on: ubuntu-latest
    # ...
```

**Branch-specific builds:**
```yaml
on:
  push:
    branches:
      - main        # Production
      - develop     # Staging
      - 'release/*' # Release branches

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Determine environment
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "ENV=production" >> $GITHUB_ENV
          elif [[ "${{ github.ref }}" == "refs/heads/develop" ]]; then
            echo "ENV=staging" >> $GITHUB_ENV
          fi
```

---

## Advanced Patterns

### 1. Docker Layer Caching

**Pattern:** Cache Docker layers between builds (faster builds)

```yaml
- name: Build and push
  uses: docker/build-push-action@v6
  with:
    context: ./api
    push: true
    cache-from: type=registry,ref=ghcr.io/myorg/myapp/api:buildcache
    cache-to: type=registry,ref=ghcr.io/myorg/myapp/api:buildcache,mode=max
    tags: ghcr.io/myorg/myapp/api:main
```

**Benefit:** Re-use cached layers (pip install, npm install) → 50% faster builds

**Trade-off:** Uses additional registry storage for cache

---

### 2. Build Matrix (Multiple Versions)

**Build multiple Python versions:**
```yaml
jobs:
  build:
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']
    runs-on: ubuntu-latest
    steps:
      - name: Build
        uses: docker/build-push-action@v6
        with:
          context: .
          build-args: |
            PYTHON_VERSION=${{ matrix.python-version }}
          tags: ghcr.io/myorg/myapp:py${{ matrix.python-version }}
```

**Dockerfile:**
```dockerfile
ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim
```

---

### 3. Secrets Management

**Using GitHub Secrets:**

1. **Add secret:** GitHub repo → Settings → Secrets → Actions → New secret
2. **Use in workflow:**

```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  JWT_SECRET: ${{ secrets.JWT_SECRET }}

- name: Build with secrets
  uses: docker/build-push-action@v6
  with:
    context: .
    secret-files: |
      DATABASE_URL=${{ secrets.DATABASE_URL }}
```

**Never:**
- ❌ Commit secrets to `.github/workflows/*.yml`
- ❌ Echo secrets in logs: `echo ${{ secrets.JWT_SECRET }}`

**Always:**
- ✅ Use GitHub Secrets
- ✅ Mask secrets in logs (automatic with `secrets.*`)

---

### 4. Workflow Dependencies (Sequential Builds)

**Pattern:** Build services in order (auth → API → webui)

```yaml
# .github/workflows/build-all.yml
jobs:
  build-auth:
    runs-on: ubuntu-latest
    steps:
      # Build auth...

  build-api:
    needs: build-auth  # Wait for auth to finish
    runs-on: ubuntu-latest
    steps:
      # Build API...

  build-webui:
    needs: [build-auth, build-api]  # Wait for both
    runs-on: ubuntu-latest
    steps:
      # Build webui...
```

**When to use:** WebUI depends on auth + API being published first

---

## Testing Workflows

### 1. Test Before Build

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          cd api
          pip install -r requirements.txt
          pip install pytest pytest-asyncio

      - name: Run tests
        run: |
          cd api
          pytest tests/ -v

  build:
    needs: test  # Only build if tests pass
    runs-on: ubuntu-latest
    steps:
      # Build and push...
```

**Benefit:** Prevent broken images from being published

---

### 2. Local Testing with `act`

**Install `act`:**
```bash
# macOS
brew install act

# Windows
choco install act-cli
```

**Run workflows locally:**
```bash
# Run workflow
act -W .github/workflows/build-auth.yml

# Dry run (list jobs)
act -l

# Run specific job
act -j build-auth
```

**Note:** Some GitHub Actions features not fully supported (e.g., GHCR push)

---

## GHCR Authentication & Permissions

### 1. Workflow Permissions

**Required in workflow:**
```yaml
permissions:
  contents: read   # Read code
  packages: write  # Push to GHCR
```

### 2. Make GHCR Image Public

After first push:
1. Go to: https://github.com/users/{username}/packages/container/{package}/settings
2. Under "Package visibility" → Click "Change visibility"
3. Select "Public"

### 3. Pull Private Images (Deployment)

**On VPS/server:**
```bash
# Create Personal Access Token (PAT) with read:packages scope
# https://github.com/settings/tokens/new

# Login to GHCR
docker login ghcr.io -u yourusername
# Password: paste PAT

# Pull image
docker pull ghcr.io/yourorg/myapp/auth:main
```

---

## Common Workflow Triggers

```yaml
on:
  # Push to specific branches
  push:
    branches: [ main, develop ]
    tags: [ 'v*' ]  # Version tags (v1.0.0)

  # Pull requests
  pull_request:
    branches: [ main ]

  # Manual trigger (GitHub UI button)
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'staging'

  # Schedule (cron)
  schedule:
    - cron: '0 2 * * 0'  # Sundays at 2 AM UTC

  # On release published
  release:
    types: [ published ]
```

---

## Workflow File Structure

**Minimal workflow:**
```yaml
name: Build Auth

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/build-push-action@v6
        with:
          context: ./auth
          push: false  # Set true for production
```

**Production-ready workflow:**
```yaml
name: Build Auth

on:
  push:
    branches: [ main ]
    paths: [ 'auth/**' ]
  workflow_dispatch: {}

permissions:
  contents: read
  packages: write

jobs:
  build-auth:
    name: Build Auth Service
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up QEMU (multi-platform)
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository_owner }}/myapp/auth
          tags: |
            type=ref,event=branch
            type=sha
            type=raw,value=latest

      - name: Build and push
        id: build
        uses: docker/build-push-action@v6
        with:
          context: ./auth
          push: true
          provenance: false
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=registry,ref=ghcr.io/${{ github.repository_owner }}/myapp/auth:buildcache
          cache-to: type=registry,ref=ghcr.io/${{ github.repository_owner }}/myapp/auth:buildcache,mode=max

      - name: Build summary
        if: always()
        run: |
          {
            echo "### Auth image published"
            echo "Tags: ${{ steps.meta.outputs.tags }}"
            echo "Digest: ${{ steps.build.outputs.digest }}"
          } >> "$GITHUB_STEP_SUMMARY"
```

---

## Common Pitfalls

### ❌ Don't:
- **Rebuild all services on every push** (use path filters)
- **Hardcode usernames** (use `${{ github.repository_owner }}`)
- **Forget `provenance: false`** (causes warnings on some platforms)
- **Use `latest` tag in production** (hard to rollback)
- **Commit secrets** to workflow files

### ✅ Do:
- **Use path-based triggers** (separate workflows per service)
- **Tag images with SHA + branch** (traceable)
- **Cache Docker layers** (faster builds)
- **Run tests before build** (prevent broken images)
- **Use GitHub Secrets** for credentials

---

## Source References

**Extracted from:**
- AI Workflow: `.github/workflows/build-auth.yml` (basic pattern)
- AI Workflow: `.github/workflows/build-api.yml` (path filters, metadata)
- AI Workflow: `.github/workflows/build-webui.yml` (multi-stage builds)

**Related Patterns:**
- 📎 [Docker Patterns](docker-patterns.md) - Dockerfile optimization
- 📎 [VPS Deployment Patterns](vps-deployment-patterns.md) - Pulling images to production
- 📎 [Environment Config Patterns](environment-config-patterns.md) - Managing secrets

---

**Pattern Version:** 1.0.0  
**Last Updated:** March 7, 2026  
**Source Project:** Enterprise application v0.2.11/v0.5.5
