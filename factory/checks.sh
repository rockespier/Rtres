#!/usr/bin/env bash
# The repo's checks. Exit 0 only when the branch is fit to review.
#
# The gate runs this script from the main checkout with the job's worktree as
# the working directory. Keep it fast, deterministic and non-interactive: no
# watch modes, no prompts, nothing that rewrites files.
#
# Rtres: .NET 10 API (build + xUnit tests, EF InMemory, no database needed) and the
# Angular 18 workspace (site with SSR/prerender in es/en/it, and the client portal).
# The repo has no lint or separate typecheck step: `ng build` type-checks.
set -euo pipefail

# --- API ---
dotnet build src/api/Rtres.slnx --nologo -v quiet
dotnet test src/api/Rtres.slnx --nologo --no-build -v quiet

# --- Web ---
cd src/web
# A fresh worktree has no node_modules.
if [ ! -d node_modules ]; then
  npm ci --prefer-offline --no-audit --no-fund
fi
npx ng build portal
npx ng build site
