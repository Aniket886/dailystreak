# GitHub Streak Maintainer for @Aniket886

This repository uses a GitHub Actions workflow to create automated daily commits on `main` and keep contribution activity moving.

## What It Does
- Creates a random number of commits each day between `10` and `200`
- Runs automatically every day at `00:05 IST`
- Uses only repo-local shell logic plus first-party GitHub Actions
- Supports manual runs from the Actions tab
- Supports an optional manual `commit_count` override from `10` to `800`

## Schedule
- Local time: `00:05 IST` every day
- GitHub Actions cron time: `18:35 UTC` on the previous UTC day

The workflow uses UTC internally because GitHub Actions cron expressions always run in UTC.
Commit timestamps are explicitly authored in `Asia/Kolkata` so the contribution graph lines up with the IST calendar day.

## Files
- Workflow: `.github/workflows/auto-streak-keeper.yml`
- Commit target file: `public/auto-streak/data.txt`

## GitHub Setup

### 1. Push the repository to your GitHub account
Make sure this repository exists under your account and the default branch is `main`.

### 2. Enable GitHub Actions
1. Open the repository on GitHub.
2. Go to `Settings` -> `Actions` -> `General`.
3. Make sure Actions are allowed for the repository.

### 3. Enable workflow write permissions
1. In `Settings` -> `Actions` -> `General`, scroll to **Workflow permissions**.
2. Select `Read and write permissions`.
3. Save the change.

This is required because the workflow commits and pushes back to `main`.

### 4. Add the required repository secret
1. Go to `Settings` -> `Secrets and variables` -> `Actions`.
2. Click `New repository secret`.
3. Create this secret:

| Secret | Value |
|--------|-------|
| `COMMIT_USER_EMAIL` | The email address you want on the automated commits |

Use the same email address that should appear in your GitHub commit history.

### 5. Enable the workflow
1. Open the `Actions` tab.
2. Open the `Maintain GitHub Streak` workflow.
3. If GitHub shows the workflow as disabled, enable it.

## Manual Test Run
Before relying on the daily schedule, run it once manually.

1. Open the `Actions` tab.
2. Select `Maintain GitHub Streak`.
3. Click `Run workflow`.
4. Optionally enter `commit_count` with a value from `10` to `800`.
5. Run the workflow on branch `main`.

## Expected Result
After a successful run:
- The workflow appends new lines to `public/auto-streak/data.txt`
- GitHub creates multiple commits on `main`
- The commit author is `Aniket886` with the email from `COMMIT_USER_EMAIL`
- Future scheduled runs happen automatically every day at `00:05 IST` with a random count from `10` to `200`

## Notes
- GitHub may delay scheduled workflows slightly during heavy load.
- The workflow stays self-contained and does not depend on third-party marketplace actions for the commit logic.
- Manual runs can use higher counts up to `800`, but automatic runs will never exceed `200`.
- The workflow sets explicit IST commit timestamps, so new runs should count toward the intended India date instead of the previous UTC day.
- If a manual run fails immediately, check that `COMMIT_USER_EMAIL` exists and workflow permissions are set to `Read and write`.
