# Event Repo Push Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Push a snapshot of `burakcanpolat/n8n-izmir-workshop-2026/speakers/burak-can-polat/` into `onurpolat05/n8n-izmir-workshop-2026/speakers/burak-can-polat/` via a PR with 3 logical commits.

**Architecture:** Clone event repo to a separate working directory, copy tracked files from the Burak repo with 3 explicit exclusions (CLAUDE.md, SETUP_CLAUDE.md, .design-reference/ — wrangler.toml auto-excluded since gitignored), rewrite the speaker README for snapshot context, add a 1-line discoverability link in the main event README, push, open PR.

**Tech Stack:** git, gh CLI (authenticated as `burakcanpolat`, write access on event repo), rsync with `--files-from`, bash.

**Spec:** `/home/burakcanpolat/repos/n8n-workshop/docs/superpowers/specs/2026-05-18-event-repo-push-design.md`

---

## File Structure

**Source (read-only):** `/home/burakcanpolat/repos/n8n-workshop/speakers/burak-can-polat/`

**Working directory (created in Task 1):** `/home/burakcanpolat/repos/n8n-event-repo/`

**Files modified in event repo:**

| Path | Action |
|---|---|
| `speakers/burak-can-polat/` (entire subtree, minus 3 exclusions) | Created via copy |
| `speakers/burak-can-polat/README.md` | Created by copy in Task 2, then overwritten in Task 3 |
| `README.md` (event repo root) | One-line modification |

**Exclusions from copy:**
- `CLAUDE.md` — Claude Code assistant config
- `SETUP_CLAUDE.md` — Claude Code local-dev guide
- `.design-reference/mockup-B-terminal.html` — design mockup
- `cloudflare-worker/wrangler.toml` — already gitignored (auto-excluded by `git ls-files`)

---

## Task 1: Clone event repo and create feature branch

**Files:**
- Create: `/home/burakcanpolat/repos/n8n-event-repo/` (entire clone)

- [ ] **Step 1: Verify the target working directory does not exist yet**

```bash
ls -d /home/burakcanpolat/repos/n8n-event-repo 2>&1
```

Expected: `ls: cannot access '/home/burakcanpolat/repos/n8n-event-repo': No such file or directory`

If the directory exists, stop and ask the user whether to delete it or pick a different name.

- [ ] **Step 2: Clone event repo via gh CLI**

```bash
cd /home/burakcanpolat/repos
gh repo clone onurpolat05/n8n-izmir-workshop-2026 n8n-event-repo
```

Expected: clone completes, `Cloning into 'n8n-event-repo'...` and `Resolving deltas: 100%`.

- [ ] **Step 3: Verify remote + branch state**

```bash
cd /home/burakcanpolat/repos/n8n-event-repo
git remote -v
git branch --show-current
git log --oneline -3
```

Expected: remote `origin` points to `https://github.com/onurpolat05/n8n-izmir-workshop-2026`, current branch is `main`, log shows 3 most recent commits (last commit SHA starts with `33c718f`).

- [ ] **Step 4: Create and check out feature branch**

```bash
cd /home/burakcanpolat/repos/n8n-event-repo
git checkout -b add-burak-can-polat-text-to-sql
git branch --show-current
```

Expected: branch shown is `add-burak-can-polat-text-to-sql`.

- [ ] **Step 5: Verify `speakers/` directory state**

```bash
ls -la /home/burakcanpolat/repos/n8n-event-repo/speakers/
```

Expected: contains only `.gitkeep`. This confirms we're the first speaker subfolder.

---

## Task 2: Copy speaker subfolder contents (with exclusions) + Commit 1

**Files:**
- Source: `/home/burakcanpolat/repos/n8n-workshop/speakers/burak-can-polat/` (read tracked files via git ls-files)
- Create: `/home/burakcanpolat/repos/n8n-event-repo/speakers/burak-can-polat/` (entire subtree)

- [ ] **Step 1: Generate the list of files to copy (tracked files minus exclusions)**

```bash
cd /home/burakcanpolat/repos/n8n-workshop
git ls-files speakers/burak-can-polat/ | \
  grep -v -E "^speakers/burak-can-polat/(CLAUDE\.md$|SETUP_CLAUDE\.md$|\.design-reference/)" | \
  sed 's|^speakers/burak-can-polat/||' > /tmp/files-to-copy.txt
wc -l /tmp/files-to-copy.txt
head -20 /tmp/files-to-copy.txt
```

Expected: line count > 20 (the speaker folder has many files including cloudflare-worker subtree). `head` shows files like `README.md`, `failure-recovery.md`, `presentation-cheat-sheet.html`, `cloudflare-worker/...`.

- [ ] **Step 2: Verify exclusions are absent from the list**

```bash
grep -E "(CLAUDE\.md$|SETUP_CLAUDE\.md$|\.design-reference)" /tmp/files-to-copy.txt
```

Expected: no output (exit code 1). If anything matches, the grep filter in Step 1 is broken — fix before continuing.

- [ ] **Step 3: Copy files via rsync with --files-from**

```bash
rsync -av --files-from=/tmp/files-to-copy.txt \
  /home/burakcanpolat/repos/n8n-workshop/speakers/burak-can-polat/ \
  /home/burakcanpolat/repos/n8n-event-repo/speakers/burak-can-polat/
```

Expected: rsync prints each file as it's copied, ends with `sent X bytes ... total size is Y`.

- [ ] **Step 4: Verify exclusions are absent from target**

```bash
for item in "CLAUDE.md" "SETUP_CLAUDE.md" ".design-reference" "cloudflare-worker/wrangler.toml"; do
  path="/home/burakcanpolat/repos/n8n-event-repo/speakers/burak-can-polat/$item"
  if [ -e "$path" ]; then
    echo "FAIL: $path exists"
  else
    echo "OK: $path absent"
  fi
done
```

Expected: all 4 lines say `OK: ... absent`. If any FAIL, delete the offender manually and re-verify.

- [ ] **Step 5: Verify key files are present**

```bash
for item in \
  "README.md" \
  "presentation-cheat-sheet.html" \
  "failure-recovery.md" \
  "workflows/text-to-sql-agent-finished.json" \
  "prompts/system-prompt-tr.md" \
  "prompts/system-prompt-en.md" \
  "data/chinook-schema.mmd" \
  "data/demo-questions.md" \
  "data/pre-event-message.md" \
  "cloudflare-worker/src" \
  "cloudflare-worker/test" \
  "cloudflare-worker/package.json" \
  "cloudflare-worker/wrangler.toml.example" \
  "bonus/dev-corner" \
; do
  path="/home/burakcanpolat/repos/n8n-event-repo/speakers/burak-can-polat/$item"
  if [ -e "$path" ]; then
    echo "OK: $path"
  else
    echo "FAIL: $path missing"
  fi
done
```

Expected: all 14 lines say `OK`. Any FAIL means the rsync missed something — investigate.

- [ ] **Step 6: Stage and commit (Commit 1 of 3)**

```bash
cd /home/burakcanpolat/repos/n8n-event-repo
git add speakers/burak-can-polat/
git status
```

Expected: `git status` shows many new files under `speakers/burak-can-polat/`, all staged.

```bash
git commit -m "$(cat <<'EOF'
Add speakers/burak-can-polat/ folder with text-to-sql workshop materials

Burak Can Polat'ın 2026-05-17 İzmir workshop'unun replikasyon paketi.
Telegram bot + n8n AI Agent + Cloudflare Worker + D1 (Chinook) zinciri.
LLM: OpenRouter (default: anthropic/claude-haiku-4.5).

Hariç tutulanlar:
- CLAUDE.md, SETUP_CLAUDE.md (Claude Code asistan config)
- .design-reference/ (tasarım mockup)
- cloudflare-worker/wrangler.toml (live D1 binding, gitignored)

Bu commit dosyaları olduğu gibi (Burak repo'sundaki halleriyle) ekliyor.
Sonraki commit speaker README'sini snapshot bağlamı için yeniden yazıyor.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Expected: `[add-burak-can-polat-text-to-sql <sha>] Add speakers/burak-can-polat/...` with file count and insertions.

---

## Task 3: Rewrite speaker README for snapshot context + Commit 2

**Files:**
- Modify: `/home/burakcanpolat/repos/n8n-event-repo/speakers/burak-can-polat/README.md`

- [ ] **Step 1: Overwrite the speaker README with the snapshot version**

Use Write tool on `/home/burakcanpolat/repos/n8n-event-repo/speakers/burak-can-polat/README.md` with this exact content:

```markdown
# Text-to-SQL Agent — Burak Can Polat

> 📍 **Bu klasör bir snapshot.** Canlı, sürekli güncel kaynak:
> - Repo: [burakcanpolat/n8n-izmir-workshop-2026](https://github.com/burakcanpolat/n8n-izmir-workshop-2026)
> - Cheat sheet (live, mobile-friendly): [burakcanpolat.github.io/n8n-izmir-workshop-2026](https://burakcanpolat.github.io/n8n-izmir-workshop-2026/)
>
> Workshop tarihi: 2026-05-17 · İzmir

## Burak Can Polat ile 30 dakikada doğal dilde SQL ajanı

**Ne yapacağız:** Telegram üzerinden Türkçe veya İngilizce sorulara
SQL üretip, sınayıp ve çalıştıran bir n8n yapay zekâ ajanı.

**Veri:** Chinook (klasik müzik mağazası örnek veritabanı) — Cloudflare D1'de
çalışan gerçek SQLite.

**LLM:** OpenRouter (varsayılan: `anthropic/claude-haiku-4.5`; 8 model alternatifi cheat sheet'te).

**Mimari:** Telegram → n8n AI Agent → 2 HTTP Request Tool → Cloudflare
Worker (`/test`, `/execute`) → D1 SQLite.

## ⚡ Hızlı başlangıç

[Atölye cheat sheet'ini aç →](./presentation-cheat-sheet.html)

Cheat sheet'te şunlar var:
1. Uçuş öncesi kontrol listesi (n8n, OpenRouter, Telegram)
2. Workflow'u sıfırdan node-by-node kurma adımları
3. Sistem promptunu kopyalama düğmeleri (TR/EN)

## 📂 Workshop kit

| Dosya | Ne için |
|---|---|
| [`presentation-cheat-sheet.html`](./presentation-cheat-sheet.html) | Atölyede takip edeceğiniz birincil rehber (sıfırdan kurulum adımları) |
| [`workflows/text-to-sql-agent-finished.json`](workflows/text-to-sql-agent-finished.json) | Geri kalırsanız içe aktarabileceğiniz tamamlanmış versiyon (recovery) |
| [`prompts/system-prompt-tr.md`](prompts/system-prompt-tr.md) | AI Agent sistem mesajı (Türkçe) |
| [`prompts/system-prompt-en.md`](prompts/system-prompt-en.md) | AI Agent sistem mesajı (İngilizce) |
| [`data/demo-questions.md`](data/demo-questions.md) | Örnek soru bankası + referans SQL |
| [`data/chinook-schema.mmd`](data/chinook-schema.mmd) | Chinook şema ER diyagramı (mermaid kaynak) |
| [`bonus/dev-corner/`](bonus/dev-corner/) | Geliştiriciler için Code Tool versiyonu |
| [`cloudflare-worker/`](cloudflare-worker/) | SQL backend altyapısı (kendi kopyanız için) |

## 🆘 Atölye günü sıkışırsanız

[`failure-recovery.md`](failure-recovery.md) — yazıcıdan çıktı al, yanında bulundur.

---

## English summary

A 30-min follow-along workshop building a Telegram bot that answers
data questions in natural language. The bot is an n8n AI Agent
(Tools Agent mode, OpenRouter `anthropic/claude-haiku-4.5` by default) with two HTTP tools —
`generate_and_test_sql` (dry-run with LIMIT 5) and `execute_sql` —
both hitting a Cloudflare Worker backed by D1 (libSQL/SQLite) preloaded
with the Chinook dataset.

Audience: corporate data professionals + developers. n8n (self-hosted or
Cloud) + OpenRouter API key + own Telegram bot from BotFather.

To follow along: open the [cheat sheet](./presentation-cheat-sheet.html)
on the day.

For the full design + implementation history, see the canonical repo
linked at the top of this README.
```

- [ ] **Step 2: Verify snapshot callout is present and content is correct**

```bash
head -10 /home/burakcanpolat/repos/n8n-event-repo/speakers/burak-can-polat/README.md
```

Expected: First 10 lines include `# Text-to-SQL Agent — Burak Can Polat`, the `📍 **Bu klasör bir snapshot.**` line, both link bullets, and the workshop date.

- [ ] **Step 3: Verify removed content is gone**

```bash
grep -E "(docs/superpowers|Text-to-SQL Agent — n8n İzmir 2026)" /home/burakcanpolat/repos/n8n-event-repo/speakers/burak-can-polat/README.md
```

Expected: no output. The old `Full design and implementation specs` line referenced `../../docs/superpowers/` (broken in event repo context) and the old H1 included "n8n İzmir 2026" (now replaced with author-focused H1).

- [ ] **Step 4: Verify key replication sections are present**

```bash
for marker in \
  "Hızlı başlangıç" \
  "Workshop kit" \
  "Atölye günü sıkışırsanız" \
  "English summary" \
  "failure-recovery.md" \
; do
  if grep -q "$marker" /home/burakcanpolat/repos/n8n-event-repo/speakers/burak-can-polat/README.md; then
    echo "OK: $marker"
  else
    echo "FAIL: $marker missing"
  fi
done
```

Expected: all 5 lines say `OK`.

- [ ] **Step 5: Stage and commit (Commit 2 of 3)**

```bash
cd /home/burakcanpolat/repos/n8n-event-repo
git add speakers/burak-can-polat/README.md
git status
git diff --cached --stat
```

Expected: `git status` shows `modified: speakers/burak-can-polat/README.md`. Diff stat shows the file with insertions+deletions.

```bash
git commit -m "$(cat <<'EOF'
Rewrite speakers/burak-can-polat/README.md for snapshot context

- Üst kısma 'snapshot' callout: canonical kaynak (Burak repo + Pages URL)
  açıkça belirtildi
- H1 author-focused: 'Text-to-SQL Agent — Burak Can Polat'
- Replikasyon odaklı bölümler korundu (workshop kit, hızlı başlangıç,
  failure recovery link, English summary)
- Event repo'da geçersiz olan ../../docs/superpowers/ referansı kaldırıldı
- 'kendi cihazından takip et' tarzı snapshot-için-anlamsız notlar yok

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Expected: `[add-burak-can-polat-text-to-sql <sha>] Rewrite speakers/burak-can-polat/README.md...` with insertions and deletions count.

---

## Task 4: Update event repo main README agenda + Commit 3

**Files:**
- Modify: `/home/burakcanpolat/repos/n8n-event-repo/README.md` (line containing agenda step 5)

- [ ] **Step 1: Confirm the exact target line exists uniquely**

```bash
grep -c "5\. 🎤 Konuşmacı: Burak Can Polat" /home/burakcanpolat/repos/n8n-event-repo/README.md
```

Expected: `1`. If 0, the agenda format changed — investigate. If >1, the Edit tool will need more context — use surrounding lines in the old_string.

- [ ] **Step 2: Apply the single-line edit**

Use Edit tool on `/home/burakcanpolat/repos/n8n-event-repo/README.md`:

- `old_string`: `5. 🎤 Konuşmacı: Burak Can Polat`
- `new_string`: `5. 🎤 Konuşmacı: [Burak Can Polat](./speakers/burak-can-polat/) — Text-to-SQL Agent`

- [ ] **Step 3: Verify diff is a single line change**

```bash
cd /home/burakcanpolat/repos/n8n-event-repo
git diff README.md
```

Expected: one removed line `- 5. 🎤 Konuşmacı: Burak Can Polat`, one added line `+ 5. 🎤 Konuşmacı: [Burak Can Polat](./speakers/burak-can-polat/) — Text-to-SQL Agent`. No other changes.

- [ ] **Step 4: Stage and commit (Commit 3 of 3)**

```bash
git add README.md
git commit -m "$(cat <<'EOF'
README: link Burak's speaker materials in agenda

Agenda step 5'teki konuşmacı adı artık ./speakers/burak-can-polat/
klasörüne link. Ana sayfadan tek tıkla erişim, içerik keşfedilebilir
oluyor. Minimal değişiklik — agenda format değişmedi.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Expected: `[add-burak-can-polat-text-to-sql <sha>] README: link Burak's speaker materials in agenda` with 1 insertion, 1 deletion.

- [ ] **Step 5: Verify all 3 commits are on the branch**

```bash
git log --oneline main..HEAD
```

Expected: exactly 3 lines, in this order (top to bottom):
1. `README: link Burak's speaker materials in agenda`
2. `Rewrite speakers/burak-can-polat/README.md for snapshot context`
3. `Add speakers/burak-can-polat/ folder with text-to-sql workshop materials`

---

## Task 5: Push branch and open PR

**Files:**
- No file changes. Remote branch + GitHub PR.

- [ ] **Step 1: Push the feature branch to origin**

```bash
cd /home/burakcanpolat/repos/n8n-event-repo
git push -u origin add-burak-can-polat-text-to-sql 2>&1 | tail -10
```

Expected: `To https://github.com/onurpolat05/n8n-izmir-workshop-2026.git` followed by `* [new branch] add-burak-can-polat-text-to-sql -> add-burak-can-polat-text-to-sql` and `Branch 'add-burak-can-polat-text-to-sql' set up to track 'origin/add-burak-can-polat-text-to-sql'`.

If push fails with permission error: verify `gh auth status` shows `burakcanpolat` user with `repo` scope, and that the event repo collaborator role is still `write`.

- [ ] **Step 2: Open the PR via gh CLI**

```bash
gh pr create \
  --repo onurpolat05/n8n-izmir-workshop-2026 \
  --base main \
  --head add-burak-can-polat-text-to-sql \
  --title "Add speaker materials: Burak Can Polat — Text-to-SQL Agent" \
  --body "$(cat <<'EOF'
## Ne ekliyor

`speakers/burak-can-polat/` altına 2026-05-17 İzmir workshop'umun
replikasyon paketi. Telegram bot + n8n AI Agent + Cloudflare Worker
+ D1 (Chinook) zinciri. Canlı OpenRouter (claude-haiku-4.5).

## İçerik

- Cheat sheet HTML (live: burakcanpolat.github.io/n8n-izmir-workshop-2026/)
- Workflow JSON (n8n Cloud uyumlu)
- TR + EN system prompts
- Cloudflare Worker (src + tests + wrangler example)
- Chinook ER diagram + demo soru bankası
- Failure recovery one-pager
- Bonus: dev-corner Code Tool variant

## Canonical kaynak

burakcanpolat/n8n-izmir-workshop-2026 — bu klasör onun snapshot'ı.
Future updates orada yapılır, gerekirse manuel re-sync.

## Hariç tutulan

- CLAUDE.md, SETUP_CLAUDE.md (Claude Code asistan config)
- .design-reference/ (tasarım mockup)
- wrangler.toml (live D1 binding, gitignored)

## Onay
- [ ] speakers/burak-can-polat/ struct doğru
- [ ] Ana README agenda link'i uygun
- [ ] Merge

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Expected: gh prints the PR URL, e.g. `https://github.com/onurpolat05/n8n-izmir-workshop-2026/pull/1`.

- [ ] **Step 3: Verify PR opened with correct metadata**

```bash
gh pr view --repo onurpolat05/n8n-izmir-workshop-2026 add-burak-can-polat-text-to-sql --json number,title,baseRefName,headRefName,state,url
```

Expected: JSON shows `state: OPEN`, `baseRefName: main`, `headRefName: add-burak-can-polat-text-to-sql`, the title matches Step 2, and a valid PR URL.

- [ ] **Step 4: Final verification — list files in the PR**

```bash
gh pr diff --repo onurpolat05/n8n-izmir-workshop-2026 add-burak-can-polat-text-to-sql --name-only | head -40
```

Expected: shows `README.md` (event repo root, 1 line changed) and a long list of files under `speakers/burak-can-polat/...`. None of the 4 exclusions appear.

```bash
gh pr diff --repo onurpolat05/n8n-izmir-workshop-2026 add-burak-can-polat-text-to-sql --name-only | grep -E "(CLAUDE\.md|SETUP_CLAUDE\.md|\.design-reference|wrangler\.toml$)"
```

Expected: no output. If any of those names match, the PR contains content that should not be there — close the PR, delete the branch, fix the source, redo.

- [ ] **Step 5: Report PR URL to user**

Print the PR URL and a short summary:
- 3 commits
- Files added: X (from Step 4 count)
- Ready for Onur's review

---

## Self-review checklist (run after writing the plan)

1. **Spec coverage:** All 4 decisions from spec covered:
   - Scope (replikasyon paketi) → Task 2 file filter
   - Canonical = Burak repo → Speaker README in Task 3 keeps URLs as-is via no rewriting
   - Lifecycle = one-shot → no CI/automation tasks
   - Push flow = PR + Onur review → Task 5

2. **Placeholder scan:** No TBD/TODO. All commands have exact paths and expected outputs.

3. **Type consistency:** Branch name `add-burak-can-polat-text-to-sql` used identically in Tasks 1, 5. PR title exact match in Step 2 + Step 3 verify.
