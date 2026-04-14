#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/.github/personal-notes-facts.sh"

NOTE_FILE="${NOTE_FILE:?}"
IDEA_FILE="${IDEA_FILE:?}"
COMMIT_TIME="${COMMIT_TIME:?}"
COMMIT_TIMEZONE="${COMMIT_TIMEZONE:?}"
COMMIT_INDEX="${COMMIT_INDEX:?}"
RUN_SEED="${RUN_SEED:?}"
GROQ_API_KEY="${GROQ_API_KEY:-}"
GROQ_MODEL="${GROQ_MODEL:-llama-3.1-8b-instant}"

pick() {
  local name="$1"
  local bias="${2:-0}"
  declare -n ref="$name"
  local len="${#ref[@]}"
  local idx=$(( (RUN_SEED + COMMIT_INDEX + bias + RANDOM) % len ))
  printf '%s' "${ref[$idx]}"
}

ensure_heading() {
  local file_path="$1"
  local day_label="$2"
  if [ ! -f "$file_path" ]; then
    printf '# %s\n' "$(basename "$file_path" .md | tr '-' ' ')" > "$file_path"
  fi

  if ! grep -Fqx "## $day_label" "$file_path"; then
    printf '\n## %s\n' "$day_label" >> "$file_path"
  fi
}

build_journal_prompt() {
  local project role theme cert achievement opener angle next_step learning
  project="$(pick PROJECTS 1)"
  role="$(pick ROLES 3)"
  theme="$(pick LEARNING_THEMES 5)"
  cert="$(pick CERTIFICATIONS 7)"
  achievement="$(pick ACHIEVEMENTS 9)"
  opener="$(pick JOURNAL_OPENERS 11)"
  angle="$(pick JOURNAL_ANGLES 13)"
  next_step="$(pick JOURNAL_NEXT_STEPS 15)"
  learning="$(pick LEARNING_NOTES 17)"

  cat <<EOF
Write one short personal work-log reflection in first person for Aniket Tegginamath.
Keep it factual, natural, and concise.
Use these approved facts only:
- Mission: $MISSION_LINE
- Role context: $role
- Project context: $project
- Learning theme: $theme
- Certification context: $cert
- Achievement context: $achievement
- Preferred opener idea: $opener
- Reflection angle: $angle
- Next-step idea: $next_step
- Learning note: $learning
Avoid email, raw analytics, follower counts, contact details, and exaggerated claims.
EOF
}

build_idea_prompt() {
  local idea prompt theme project
  idea="$(pick IDEA_LINES 19)"
  prompt="$(pick IDEA_PROMPTS 21)"
  theme="$(pick LEARNING_THEMES 23)"
  project="$(pick PROJECTS 25)"

  cat <<EOF
Write one short quote-like project reflection or idea line for Aniket Tegginamath.
Keep it factual, crisp, and personal-notes friendly.
Use these approved facts only:
- Core idea: $idea
- Prompt seed: $prompt
- Theme: $theme
- Project anchor: $project
- Mission: $MISSION_LINE
Avoid email, raw analytics, follower counts, contact details, and exaggerated claims.
EOF
}

generate_ai_line() {
  local target="$1"
  local prompt

  if [ -z "$GROQ_API_KEY" ]; then
    return 1
  fi

  if [ "$target" = "journal" ]; then
    prompt="$(build_journal_prompt)"
  else
    prompt="$(build_idea_prompt)"
  fi

  printf '%s\n' "$prompt" | GROQ_API_KEY="$GROQ_API_KEY" GROQ_MODEL="$GROQ_MODEL" python3 "$ROOT_DIR/scripts/groq_generate_note.py" 2>/dev/null
}

append_journal_entry() {
  local day_label time_label project role theme cert achievement opener angle next_step learning entry_type generated_line
  day_label="$(TZ="$COMMIT_TIMEZONE" date -d "$COMMIT_TIME" '+%Y-%m-%d')"
  time_label="$(TZ="$COMMIT_TIMEZONE" date -d "$COMMIT_TIME" '+%I:%M %p IST')"
  ensure_heading "$NOTE_FILE" "$day_label"

  generated_line="$(generate_ai_line journal || true)"
  if [ -n "$generated_line" ]; then
    printf -- "- %s: %s\n" "$time_label" "$generated_line" >> "$NOTE_FILE"
    return
  fi

  project="$(pick PROJECTS 1)"
  role="$(pick ROLES 3)"
  theme="$(pick LEARNING_THEMES 5)"
  cert="$(pick CERTIFICATIONS 7)"
  achievement="$(pick ACHIEVEMENTS 9)"
  opener="$(pick JOURNAL_OPENERS 11)"
  angle="$(pick JOURNAL_ANGLES 13)"
  next_step="$(pick JOURNAL_NEXT_STEPS 15)"
  learning="$(pick LEARNING_NOTES 17)"
  entry_type=$(( (RUN_SEED + COMMIT_INDEX) % 4 ))

  case "$entry_type" in
    0)
      printf -- "- %s: %s %s %s Next note: %s\n" "$time_label" "$opener" "$project" "$angle" "$next_step" >> "$NOTE_FILE"
      ;;
    1)
      printf -- "- %s: %s The current learning thread is %s, and %s\n" "$time_label" "$role" "$theme" "$learning" >> "$NOTE_FILE"
      ;;
    2)
      printf -- "- %s: %s keeps standing out. It connects well with %s and the way I think about %s\n" "$time_label" "$achievement" "$project" "$theme" >> "$NOTE_FILE"
      ;;
    *)
      printf -- "- %s: Revisited %s after thinking about %s. %s A good reference point is %s.\n" "$time_label" "$project" "$cert" "$angle" "$next_step" >> "$NOTE_FILE"
      ;;
  esac
}

append_idea_entry() {
  local day_label time_label idea prompt theme project line_type generated_line
  day_label="$(TZ="$COMMIT_TIMEZONE" date -d "$COMMIT_TIME" '+%Y-%m-%d')"
  time_label="$(TZ="$COMMIT_TIMEZONE" date -d "$COMMIT_TIME" '+%I:%M %p IST')"
  ensure_heading "$IDEA_FILE" "$day_label"

  generated_line="$(generate_ai_line ideas || true)"
  if [ -n "$generated_line" ]; then
    printf -- "- %s: %s\n" "$time_label" "$generated_line" >> "$IDEA_FILE"
    return
  fi

  idea="$(pick IDEA_LINES 19)"
  prompt="$(pick IDEA_PROMPTS 21)"
  theme="$(pick LEARNING_THEMES 23)"
  project="$(pick PROJECTS 25)"
  line_type=$(( (RUN_SEED + COMMIT_INDEX) % 3 ))

  case "$line_type" in
    0)
      printf -- "- %s: %s\n" "$time_label" "$idea" >> "$IDEA_FILE"
      ;;
    1)
      printf -- "- %s: Idea to revisit: %s Related thread: %s\n" "$time_label" "$prompt" "$theme" >> "$IDEA_FILE"
      ;;
    *)
      printf -- "- %s: Working line: %s Project anchor: %s\n" "$time_label" "$idea" "$project" >> "$IDEA_FILE"
      ;;
  esac
}

pick_commit_message() {
  local target="$1"
  if [ "$target" = "journal" ]; then
    pick COMMIT_MESSAGES_NOTES 27
  else
    pick COMMIT_MESSAGES_IDEAS 29
  fi
}

target="journal"
if (( (RUN_SEED + COMMIT_INDEX) % 4 == 0 )); then
  target="ideas"
fi

mkdir -p "$(dirname "$NOTE_FILE")"
touch "$NOTE_FILE" "$IDEA_FILE"

if [ "$target" = "journal" ]; then
  append_journal_entry
else
  append_idea_entry
fi

pick_commit_message "$target"
