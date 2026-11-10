# AGENTS.md

Rtres Web Solutions: the public site (rtres.net, es/en/it), the client portal and
the admin back office, with a .NET API behind them. Every agent working in this
repo reads this file.

## Layout

- `src/api/`: .NET 10 solution `Rtres.slnx` (`Rtres.Api`, `Rtres.Domain`,
  `Rtres.Infrastructure`, `Rtres.Api.Tests` with xUnit and EF Core InMemory).
- `src/web/`: Angular 18 workspace with two projects, `site` (public site, SSR
  and prerender, i18n with `$localize`; translations in
  `projects/site/src/locale/messages.{en,it}.xlf`) and `portal`.
- `DESIGN.md`: the design system. `PLAN*.md`: plans per area. `scripts/`:
  deploy scripts (PowerShell); deploys are manual, never part of a change.

The repo is developed on Windows. Shell commands run in Git Bash.

## Setup of a fresh checkout

```bash
cd src/web && npm ci --prefer-offline --no-audit --no-fund
dotnet restore src/api/Rtres.slnx
```

No env file is needed to build or test. Running the API locally needs SQL
Server and `src/api/Rtres.Api/appsettings.Development.local.json` (gitignored);
agents don't run the API.

## Dev server

Public site on a given port (no API needed):

```bash
cd src/web && npx ng serve site --port <port>
```

The portal (`npx ng serve portal --port <port>`) needs the API at
`localhost:5010`, so don't use it to verify changes; read the code instead.

## Validation

`factory/checks.sh` runs exactly these, from the repo root:

```bash
dotnet build src/api/Rtres.slnx --nologo -v quiet
dotnet test src/api/Rtres.slnx --nologo --no-build -v quiet
cd src/web && npx ng build portal && npx ng build site
```

There is no linter. `ng build site` prerenders every route into
`src/web/dist/site/browser/<es|en|it>/`, the place to check titles, meta tags,
JSON-LD and copy.

## Conventions

- Public copy goes through `$localize`/`i18n` with es/en/it translations. After
  adding or changing a message, run `npx ng extract-i18n site --output-path
  projects/site/src/locale` in `src/web` and add the `<target>` in the en and it
  files.
- Portal amounts always show their currency through the money pipe; portal
  tables sort by header.
- Comments and docs are in Spanish, like the surrounding code.

## Software factory

`/factory run` builds every open GitHub issue labeled `factory` through
intake → spec → build → gate → review → approve, one PR per issue. State is in
`factory/jobs/` (gitignored); `factory/bin/job` is its only writer. Checks:
`factory/checks.sh`. Dashboard: `cd factory && python -m http.server`, then
open http://localhost:8000/dashboard.html.

Each job works in its own git worktree, a full checkout of the repo at
`.worktrees/<job-id>` (gitignored). A tool run from the repo root that doesn't
read `.gitignore` sees those copies too; exclude `.worktrees/` in its config.

This copy is adapted to Windows: the scripts run with `python` (not `python3`),
lock files with `msvcrt`, write paths with forward slashes, and agents stop dev
servers with `netstat`/`taskkill` instead of `lsof`.
