<div align="center">

# 📓 personal-notes

<p>Personal notes repository for <a href="https://github.com/Aniket886"><code>@Aniket886</code></a> — powered by an automated GitHub Actions workflow that writes factual journal entries and idea lines to this repo every day.</p>

![GitHub last commit](https://img.shields.io/github/last-commit/Aniket886/personal-notes?style=flat-square&color=6e40c9)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/Aniket886/personal-notes?style=flat-square&color=238636)
![Workflow](https://img.shields.io/badge/workflow-GitHub%20Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white)
![AI](https://img.shields.io/badge/AI-Groq%20%7C%20llama--3.3--70b-orange?style=flat-square&logo=lightning&logoColor=white)
![Timezone](https://img.shields.io/badge/timezone-IST%20%28Asia%2FKolkata%29-blue?style=flat-square)

</div>

---

> The project started as a simple auto-commit repo, but was intentionally reshaped into something that looks and behaves more like a real personal notes workspace. Instead of appending obvious counter lines, the workflow now writes short reflections, project notes, and quote-style ideas based on approved profile facts. The goal is to keep the repository activity looking like a believable personal workspace instead of a mechanical streak bot.

---

## 📋 Overview

This repository does four things:

| # | Action |
|---|--------|
| 1 | Schedules a daily workflow run at `00:05 IST` |
| 2 | Chooses how many commits to create for that run |
| 3 | Generates note content for each commit |
| 4 | Commits those note updates back to `main` |

---

## ⚙️ Current Behavior

### 🔄 Automatic daily run
- Runs every day at `00:05 IST`
- Uses GitHub cron `35 18 * * *` because GitHub Actions schedules are stored in UTC
- Chooses a random number of commits between `3` and `20`
- Uses Groq AI for the note text
- The lower cap keeps the workflow within the model's request-rate limits

### 🖐️ Manual run
- Triggered from the `Actions` tab
- Accepts an optional `commit_count`
- Manual range is `3` to `800`
- If you provide a value, that exact number is used
- Manual runs do not call Groq
- Manual runs use the local factual template generator only, so larger counts do not hit the AI API

### 📄 Content output

Each commit writes one new line into one of these files:

| File | Purpose |
|------|---------|
| `public/notes/journal.md` | Short work-log reflections, project thoughts, and learning notes |
| `public/notes/ideas.md` | Short quote-like lines, prompts, and project principles |

---

## 🗂️ Repository Structure

```
personal-notes/
├── .github/
│   ├── workflows/
│   │   └── update-personal-notes.yml   # Main GitHub Actions workflow
│   └── personal-notes-facts.sh         # Approved factual source
├── scripts/
│   ├── update_personal_notes.sh        # Main generator script
│   └── groq_generate_note.py           # Groq AI client
└── public/
    └── notes/
        ├── journal.md                  # Work-log reflections
        └── ideas.md                    # Quote-style ideas
```

### 🔧 Workflow — `.github/workflows/update-personal-notes.yml`

This is the main GitHub Actions workflow. It:

- checks out the repo
- loads the commit author email from secrets
- sets commit timestamps in `Asia/Kolkata`
- loops for the chosen commit count
- generates one note per commit
- commits and pushes each change

### 📚 Approved factual source — `.github/personal-notes-facts.sh`

This file contains the approved profile data used by the note generator. It includes:

- project summaries
- roles
- learning themes
- certifications
- achievements
- note prompt fragments
- fallback commit message patterns

> This file is the "truth source" for note generation. Sensitive details such as raw analytics, direct contact information, and unrelated private data are intentionally excluded from generated output.

### 🛠️ Main generator — `scripts/update_personal_notes.sh`

This shell script decides:

- whether the current commit writes to `journal.md` or `ideas.md`
- whether to use Groq AI generation or fallback local templates
- which factual context to include in prompts
- what commit message to use

### 🤖 Groq client — `scripts/groq_generate_note.py`

This Python script sends the request to Groq's OpenAI-compatible chat completions endpoint and returns a single plain-text note line.

---

## 🧠 How AI Is Used

AI is used only during content generation for scheduled runs. The workflow passes `GROQ_API_KEY` and `GROQ_MODEL` to the generator. The shell script builds a short prompt using approved facts and sends it to Groq. The returned one-line response is then appended to one of the notes files.

**Current default model:** `llama-3.3-70b-versatile`

> Manual runs do not use Groq at all. They use the local factual template generator only.

### AI generation flow

```
GitHub Actions triggers workflow
        │
        ▼
  Pick commit count
        │
        ▼
  For each commit:
    ├── Calculate IST-aligned timestamp
    ├── Decide target file (journal.md or ideas.md)
    ├── Build factual prompt
    ├── Send to groq_generate_note.py  ← scheduled runs only
    ├── Groq returns one short reflection or idea
    └── Append line → git commit
```

---

## 🛡️ Fallback Behavior

If Groq is unavailable, rejected, misconfigured, or returns invalid output, the workflow does **not** fail immediately.

Instead:

- the workflow logs the exact Groq failure reason to the Actions log
- the generator falls back to the local factual template system
- commits still complete

> This keeps scheduled runs reliable even if the AI provider has temporary issues.

---

## 🕐 Commit Timing and Contribution Dates

This repository uses explicit IST commit timestamps.

**Why this matters:**
- GitHub Actions runs on UTC infrastructure
- Without explicit author/committer dates, commits near midnight IST were being counted on the previous day in the contribution graph

The workflow now sets `GIT_AUTHOR_DATE` and `GIT_COMMITTER_DATE` using `Asia/Kolkata` timestamps so the contribution graph aligns with the intended India date.

---

## 🔑 GitHub Setup

### Required repository secrets

Go to `Settings` → `Secrets and variables` → `Actions` and add:

| Secret | Purpose |
|--------|---------|
| `COMMIT_USER_EMAIL` | Email used as the git author for automated commits |
| `GROQ_API_KEY` | Groq API key for AI note generation |

### Required Actions permission

Go to `Settings` → `Actions` → `General`

Under **Workflow permissions**, select `Read and write permissions`.

> Without that, the workflow cannot push commits back to `main`.

### Workflow state

In the `Actions` tab, make sure `Update Personal Notes` is enabled.

---

## 🧪 Manual Test Procedure

To test the workflow manually:

1. Open the `Actions` tab
2. Open `Update Personal Notes`
3. Click `Run workflow`
4. Choose branch `main`
5. Optionally enter `commit_count`
6. Start the run

**Recommended test count:** `3` to `10` — gives enough commits to check both `journal.md` and `ideas.md` without creating too much noise.

---

## ✅ Expected Result

After a successful run:

- the workflow creates multiple commits on `main`
- the commit author is `Aniket886` using the configured `COMMIT_USER_EMAIL`
- new entries appear in `journal.md` and/or `ideas.md`
- the Actions logs show whether Groq generation succeeded or whether fallback mode was used
- scheduled runs continue automatically at `00:05 IST`
- manual runs stay local-only and do not call Groq

---

## 🐛 Issues We Hit and How They Were Solved

<details>
<summary><strong>1. Generic spam lines looked fake</strong></summary>

**Original behavior:** the repo wrote lines like `2026-04-14T20:34:59Z commit-68 of 100`

**Problem:** looked obviously automated; didn't resemble a normal personal notes repository.

**Fix:** replaced the counter-line approach with `journal.md` and `ideas.md`; added a factual source file and content generator.

</details>

<details>
<summary><strong>2. Contribution graph counted commits on the wrong day</strong></summary>

**Original behavior:** runs around midnight IST were being counted on the previous date in GitHub contributions.

**Problem:** GitHub Actions runs on UTC-based infrastructure — commit dates were effectively landing on the previous UTC day.

**Fix:** explicitly set commit timestamps in `Asia/Kolkata`; used IST author and committer dates for each generated commit.

</details>

<details>
<summary><strong>3. GitHub secret naming issue</strong></summary>

**Original attempt:** a secret name starting with `GITHUB_`

**Problem:** GitHub blocks custom secret names beginning with `GITHUB_`.

**Fix:** renamed the secret to `COMMIT_USER_EMAIL`.

</details>

<details>
<summary><strong>4. Groq integration appeared to not work</strong></summary>

**Observed behavior:** workflow succeeded; notes were still being written; but the content looked like fallback templates, not AI output.

**Root cause:** Groq errors were being suppressed — the shell script redirected stderr away, so failures were invisible.

**Fix:** added explicit Groq error logging; made the workflow print success or failure per generation attempt.

</details>

<details>
<summary><strong>5. Groq returned HTTP 403 with error code 1010</strong></summary>

**What this indicated:** the key was being read and the request reached Groq, but it was rejected at the edge/API layer.

**Fix applied:**
- moved to `llama-3.3-70b-versatile`
- improved the Python client error handling
- added a more standard request shape: `Accept: application/json`, custom `User-Agent`, explicit `"stream": false`

**Result:** Groq generation started succeeding in the workflow logs.

</details>

<details>
<summary><strong>6. Manual runs hit Groq rate limits above roughly 20–25 commits</strong></summary>

**Observed behavior:** manual runs with larger commit counts started failing with `HTTP 429`.

**Why it happened:** the workflow was calling Groq once per commit; a 30-commit manual run could exceed the model's requests-per-minute limit.

**Fix:**
- split the workflow into two modes
- scheduled runs use Groq and are capped at `3–20` commits
- manual runs skip Groq and use only the local factual generator
- this keeps larger manual test runs reliable

</details>

---

## 📊 How to Confirm AI Is Working

Run the workflow manually and inspect the log lines inside the `Update Personal Notes` step.

```
✅ Success:
Groq generation succeeded for journal with model llama-3.3-70b-versatile.
Groq generation succeeded for ideas with model llama-3.3-70b-versatile.

⏭️ Manual run (expected):
Groq disabled for journal — using local template.
Groq disabled for ideas — using local template.

❌ Failure:
Groq generation failed for journal: ...
```

> If Groq fails, the workflow still writes entries using the local factual fallback generator.

---

## 📝 Notes About Content Quality

Generated content is intentionally constrained:

- it should stay grounded in approved profile facts
- it should avoid fake awards, fake jobs, or invented metrics
- it should avoid sensitive details like email or private contact information
- it should feel like short personal notes, project reflections, or idea lines

This keeps the repository more believable and easier to maintain over time.

---

<div align="center">

*Made with 🤖 + GitHub Actions by [@Aniket886](https://github.com/Aniket886)*

</div>
