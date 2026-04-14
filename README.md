# personal-notes

Personal notes repository for `@Aniket886` with an automated daily update workflow built around factual project reflections, learning logs, and ideas.

## What It Does
- Creates a random number of commits each day between `10` and `50`
- Runs automatically every day at `00:05 IST`
- Uses only repo-local shell logic plus first-party GitHub Actions
- Supports manual runs from the Actions tab
- Supports an optional manual `commit_count` override from `10` to `800`
- Uses Groq to write fresh quotes and project reflections when `GROQ_API_KEY` is configured
- Writes believable notes to a rolling journal and ideas file instead of generic counter lines
- Uses only approved factual details about projects, learning themes, roles, and achievements

## Schedule
- Local time: `00:05 IST` every day
- GitHub Actions cron time: `18:35 UTC` on the previous UTC day

GitHub Actions cron always runs in UTC.
Commit timestamps are explicitly authored in `Asia/Kolkata` so the contribution graph lines up with the IST calendar day.

## Files
- Workflow: `.github/workflows/update-personal-notes.yml`
- Facts source: `.github/personal-notes-facts.sh`
- Generator script: `scripts/update_personal_notes.sh`
- Journal: `public/notes/journal.md`
- Ideas: `public/notes/ideas.md`

## GitHub Setup

### 1. Push the repository to your GitHub account
Make sure this repository exists under your account as `personal-notes` and the default branch is `main`.

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
| `GROQ_API_KEY` | Groq API key used to generate fresh quotes and project reflections |

Use the same email address that should appear in your GitHub commit history.

### 5. Enable the workflow
1. Open the `Actions` tab.
2. Open the `Update Personal Notes` workflow.
3. If GitHub shows the workflow as disabled, enable it.

## Manual Test Run
1. Open the `Actions` tab.
2. Select `Update Personal Notes`.
3. Click `Run workflow`.
4. Optionally enter `commit_count` with a value from `10` to `800`.
5. Run the workflow on branch `main`.

## Expected Result
After a successful run:
- The workflow appends a fresh AI-written factual reflection to `public/notes/journal.md` or `public/notes/ideas.md`
- GitHub creates multiple commits on `main`
- The commit author is `Aniket886` with the email from `COMMIT_USER_EMAIL`
- Future scheduled runs happen automatically every day at `00:05 IST` with a random count from `10` to `50`

## Notes
- GitHub may delay scheduled workflows slightly during heavy load.
- The workflow stays self-contained and does not depend on third-party marketplace actions for the commit logic.
- Manual runs can use higher counts up to `800`, but automatic runs will never exceed `50`.
- The workflow sets explicit IST commit timestamps, so new runs should count toward the intended India date instead of the previous UTC day.
- Generated content is limited to approved facts and avoids sensitive details such as email, direct contact info, and raw analytics.
- If Groq is unavailable or the API call fails, the workflow falls back to the local factual template generator.
- If a manual run fails immediately, check that `COMMIT_USER_EMAIL` exists and workflow permissions are set to `Read and write`.
