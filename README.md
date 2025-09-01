# Bash + Ansible GitHub Actions Starter

This package sets up opinionated, low-maintenance GitHub Actions for a repository comprised of Bash scripts and Ansible playbooks. It includes CI, security checks, release automation, and a production-friendly deployment workflow.

## What’s inside
- CI: linting (shellcheck, shfmt, yamllint), Ansible syntax and ansible-lint, optional Molecule, optional Bats tests.
- Security: secret scanning with Gitleaks (plus commented stubs for Trivy and Checkov).
- Release: semantic-release for automated versioning and changelogs.
- Deploy: manual, environment-gated Ansible deploys with optional check-mode (plan) and vault support.
- Dependabot: weekly updates for Actions and pip.
- Linter configs: `.ansible-lint`, `.yamllint.yml`.
- Example repo layout scaffolding to keep conventions tidy.

## Repo layout (suggested)
```
.
├─ playbooks/
│  ├─ site.yml
│  └─ app.yml
├─ inventories/
│  └─ example/
│     ├─ hosts.ini
│     └─ group_vars/
├─ roles/
│  └─ my_role/
│     ├─ tasks/ handlers/ templates/ vars/ defaults/
│     └─ molecule/
│        └─ default/
│           ├─ molecule.yml
│           └─ converge.yml
├─ scripts/
│  ├─ bootstrap.sh
│  └─ deploy.sh
├─ test/
│  └─ scripts.bats
├─ .github/workflows/
│  ├─ ci.yml
│  ├─ security.yml
│  ├─ release.yml
│  └─ deploy.yml
├─ .ansible-lint
├─ .yamllint.yml
├─ .releaserc
├─ .github/dependabot.yml
└─ requirements.txt
```

> The directories above are pre-created with `.gitkeep` files for convenience.

---

## How to wire it (one-off setup)

### 1) Create the repo and push these files
- Copy all contents to the root of your new GitHub repository.
- Commit to a feature branch and open a pull request.

### 2) Branch protection
- In **Settings → Branches**, protect `main`:
  - Require pull requests before merging.
  - Require status checks to pass: select **CI / Lint & Test**.
  - (Optional) Require signed commits and dismiss stale approvals.

### 3) Secrets and variables
Add the following under **Settings → Secrets and variables → Actions**. Scope globally or to environments as needed.
- `SSH_PRIVATE_KEY` – private key for the deploy user on your target hosts.
- `SSH_KNOWN_HOSTS` – output from `ssh-keyscan <your-hosts>` (recommended).
- `ANSIBLE_VAULT_PASSWORD` – if you use Ansible Vault.

### 4) Environments (approvals and scoping)
- In **Settings → Environments**, create `staging` and `production` (or equivalents).
- For **production**, add required reviewers to enforce a manual approval gate.
- Store environment-specific secrets within each environment.

### 5) Ansible dependencies
- If you use Galaxy roles/collections, add:
  - `collections/requirements.yml`
  - `roles/requirements.yml`
- The pipelines will auto-install them if present.

### 6) Conventional Commits for releases
- Commit messages like `feat:`, `fix:`, `chore:`, etc. will drive semantic-release to bump versions and generate changelogs.
- Releases are created on pushes to `main`.

### 7) Try a CI run
- Open a PR and confirm CI runs linting, tests, and (optionally) Molecule.

### 8) Try a deployment
- Go to **Actions → Deploy → Run workflow**.
- Inputs:
  - **environment**: pick an existing GitHub Environment (e.g. `staging` or `production`).
  - **inventory**: path to your Ansible inventory (e.g. `inventories/staging/hosts.ini`).
  - **playbook**: e.g. `playbooks/site.yml`.
  - **limit**: optional host pattern (e.g. `web01` or `web:db`).
  - **tags**: optional comma-separated tags.
  - **extra_vars_json**: optional JSON for `--extra-vars`, e.g. `{ "version": "1.2.3" }`.
  - **check_mode**: default is true; the job plans first, then deploys.

---

## Nice-to-haves (optional but recommended)

1. **Nightly plan on staging**  
   Add a scheduled job to run `--check` against staging to surface drift early. Example (append to `deploy.yml` or create a separate `plan-schedule.yml`):
   ```yaml
   on:
     schedule:
       - cron: "30 20 * * *"  # 8:30am NZT approx (adjust for DST)
   jobs:
     nightly-plan:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-python@v5
           with: { python-version: "3.12" }
         - run: |
             python -m pip install --upgrade pip
             pip install -r requirements.txt || pip install ansible ansible-lint yamllint
         - run: |
             ansible-playbook playbooks/site.yml -i inventories/staging/hosts.ini --check -vv
   ```

2. **Pre-deploy sanity script**  
   Insert a step before `ansible-playbook` to run Bash checks (e.g. verifying required files, pinging hosts).

3. **Pin runner images**  
   Replace `ubuntu-latest` with `ubuntu-24.04` (or a pinned image) for deterministic builds.

4. **Extend security**  
   Uncomment Trivy and Checkov in `security.yml` to scan file system and IaC policies.

5. **Pre-commit hooks**  
   Add `.pre-commit-config.yaml` to run local linting before commits. (Shellcheck, shfmt, yamllint, ansible-lint).

6. **Artifacts and logs retention**  
   Tune artifact retention and log verbosity for long-lived audit trails.

7. **Reusable deployment workflow**  
   Extract `deploy.yml` into a reusable workflow using `workflow_call` so multiple repositories can standardise deploys across teams.

---

## Troubleshooting

- **SSH host key issues**: Prefer using `SSH_KNOWN_HOSTS`. As a last resort the deploy job will relax host key checking for missing known hosts (not recommended for production).
- **Vault errors**: Ensure `ANSIBLE_VAULT_PASSWORD` is set and the command includes the `--vault-password-file` path constructed in the workflow.
- **Molecule not running**: Ensure scenarios exist at `roles/**/molecule/*/molecule.yml`.
- **Semantic-release not tagging**: Confirm commits on `main` follow Conventional Commits and the workflow has `contents: write` permission.

---

## Licence
MIT (or your standard org licence).
