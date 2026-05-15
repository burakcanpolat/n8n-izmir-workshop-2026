# Workshop Failure-Recovery One-Pager

> Print this. Have it next to you on stage. Top 5 likely failures and
> their 30-second fixes. If something's not on this list, calmly say
> "let me reproduce that off-stage" and continue the demo.

---

## 1. Worker returns 5xx or times out

**Symptom:** Agent in n8n shows "tool failure" or "fetch error" in the
execution log. Telegram bot stops responding.

**Fix (30 sec):**
1. Open the workflow in n8n Cloud.
2. Click the `generate_and_test_sql` Tool node.
3. Change the URL from your primary Worker to the backup mirror:
   `https://chinook-workshop-backup.<vercel>.app/test`
4. Do the same for `execute_sql` (change to `/execute`).
5. Save. Send the previous failed query again from Telegram.

**Prevention:** Backup Vercel mirror was deployed in tonight's prep.
If you skipped it, the only recovery is `wrangler tail` to debug live —
not a good demo move. Deploy the mirror.

---

## 2. Gemini rate-limit (HTTP 429)

**Symptom:** Agent execution log shows "429 RESOURCE_EXHAUSTED".

**Fix (60 sec):**
1. Open aistudio.google.com on your phone or backup laptop.
2. "Get API key" → "Create API key in new project" (creates a fresh
   1500 req/day budget).
3. Copy the new key.
4. In n8n: click Gemini Chat Model → credentials → edit → paste new key → save.
5. Re-run.

**Prevention:** You have a backup Gemini key minted but not pasted into
n8n. Keep it on your phone notes app for fast swap.

---

## 3. Telegram bot doesn't respond

**Symptom:** You send a message to the bot, no reply, no execution
showing up in n8n's Executions tab.

**Fix (30 sec):**
1. Check workflow is "Active" (toggle top right of canvas).
2. If active, click Telegram Trigger → "Listen for Test Event" → send
   another message. If it lights up, the issue was activation race.
3. If still nothing, the webhook may have unregistered. Reissue the
   Telegram credential: BotFather → `/setdomain` → leave blank, then
   `/setprivacy` → Disable (re-grants group access). In n8n, re-save
   the Telegram credential to re-register the webhook.

**Prevention:** Workflow stays active in your account between testing
and the workshop. Don't toggle it off the night before.

---

## 4. Attendee can't "Import from URL"

**Symptom:** Attendee in the room says "I don't see Import from URL"
or "the import fails".

**Fix (60 sec, applies room-wide):**
1. Tell the room: "Use the fallback path — on the cheat sheet, scroll
   to section 02, expand 'Alternatif: JSON'u manuel yapıştır'. Copy the
   JSON text from the textarea. In n8n, click ⋯ → 'Import from File' →
   'Paste JSON' (it's the second option in the dialog)."
2. Designate a helper to walk to anyone visibly stuck.

**Prevention:** The cheat sheet has the textarea fallback for exactly
this. If you skipped it, recovery is harder — you can paste JSON in n8n
chat → IMPORT works but room-coordination is messy.

---

## 5. n8n Cloud free trial expired mid-workshop

**Symptom:** Attendee says "n8n is asking me to upgrade."

**Fix (45 sec):**
1. n8n Cloud free trials last 14 days. If theirs expired, they create a
   second one with a different email (real free-email).
2. They open n8n.cloud → sign up with the second email → start a new
   trial → re-import the workflow JSON (no creds carry over).
3. They re-paste the 2 credentials (Telegram bot token, Gemini key).
   This is 3 minutes lost. Don't pause the room for them — designate
   a helper.

**Prevention:** Pre-event message asks attendees to use a fresh trial
email and to confirm activation 1 day before the workshop.

---

## If multiple things break at once

Switch to "narrate from the finished workflow on YOUR machine and let
attendees observe." The cold-open finished workflow stays running on
your laptop the entire 30 min as a safety net — if the room build
collapses, you still deliver a working demo.

## Phone numbers / who to call

- Co-speaker (Kadir Zeyrek): ____________
- Event organizer: ____________
- Cloudflare status: https://www.cloudflarestatus.com (open on backup phone)
- n8n status: https://status.n8n.io
