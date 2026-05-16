# Cheat-Sheet Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `speakers/burak-can-polat/presentation-cheat-sheet.html` from scratch with a build-along-with-audience workshop deck that doubles as a self-service mobile reference, using design direction B (Terminal/Dark) from the approved mockups.

**Architecture:** Single self-contained HTML file. Starting baseline is Mockup B (`/tmp/cheat-mockup-B-terminal.html`, also archived at `speakers/burak-can-polat/.design-reference/mockup-B-terminal.html`). Sections are replaced/added in-place, then surrounding repo files cleaned up.

**Tech Stack:** Pure HTML + CSS, vanilla JS (click-to-copy only), Google Fonts (JetBrains Mono + Geist). No frameworks. Deployed via GitHub Pages.

**Spec:** [2026-05-16-cheat-sheet-redesign.md](../specs/2026-05-16-cheat-sheet-redesign.md)

---

## File Structure

| File | Responsibility | Change type |
|---|---|---|
| `speakers/burak-can-polat/presentation-cheat-sheet.html` | The cheat sheet itself — every section, every snippet, every diagram | **Fully replaced** |
| `speakers/burak-can-polat/data/demo-questions.md` | Source of truth for demo Q bank — add Q0 SQL preview at top | Modified (insert Q0) |
| `speakers/burak-can-polat/CLAUDE.md` | Speaker AI-context — remove skeleton refs + stale Worker-URL-replacement block | Modified |
| `speakers/burak-can-polat/README.md` | Speaker overview — update from "import skeleton" to "build from scratch" framing | Modified |
| `speakers/burak-can-polat/workflows/text-to-sql-agent.json` | Skeleton workflow (no longer needed) | **Deleted** |
| `speakers/burak-can-polat/workflows/inject-credentials.sh` | Helper for the deleted skeleton | **Deleted** |

**Stays unchanged (referenced from cheat sheet):**
- `workflows/text-to-sql-agent-finished.json` — kept as helper/recovery reference
- `prompts/system-prompt-tr.md` + `prompts/system-prompt-en.md` — source of truth, embedded in cheat sheet Step 9
- `data/chinook-schema.mmd` — linked from Chinook section
- `failure-recovery.md` — linked from Errors section
- `bonus/dev-corner/README.md` — linked from After-Workshop section
- `cloudflare-worker/` — referenced but not modified

---

## Conventions

- After every code change in `presentation-cheat-sheet.html`, verify in browser by reloading `file:///home/burakcanpolat/repos/n8n-workshop/speakers/burak-can-polat/presentation-cheat-sheet.html`
- Turkish characters (`çğıöşüÇĞİÖŞÜ`) MUST render at every checkpoint
- Commit after each task with a clear message; never bundle multiple unrelated tasks in one commit
- Reference the spec section IDs (e.g. `#step-07`) when navigating between plan + spec

---

## Task 1: Baseline — Copy Mockup B as starting point

**Files:**
- Read: `speakers/burak-can-polat/.design-reference/mockup-B-terminal.html`
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (overwrite)

- [ ] **Step 1: Backup existing cheat sheet via git stash**

Run: `cd /home/burakcanpolat/repos/n8n-workshop && git stash push -m "pre-redesign-cheat-sheet" speakers/burak-can-polat/presentation-cheat-sheet.html`

Expected: stash created. (Note: existing cheat-sheet modifications are about to be discarded — the redesign is from scratch. We stash for safety; the stash can be dropped after redesign is committed.)

- [ ] **Step 2: Copy mockup B to the real path**

```bash
cp /home/burakcanpolat/repos/n8n-workshop/speakers/burak-can-polat/.design-reference/mockup-B-terminal.html \
   /home/burakcanpolat/repos/n8n-workshop/speakers/burak-can-polat/presentation-cheat-sheet.html
```

- [ ] **Step 3: Open in browser and verify it loads**

Open: `file:///home/burakcanpolat/repos/n8n-workshop/speakers/burak-can-polat/presentation-cheat-sheet.html`

Expected: Terminal-dark cheat sheet loads, Google Fonts (JetBrains Mono + Geist) render, click-to-copy works on the example code blocks, Turkish test string `çğıöşüÇĞİÖŞÜ` is visible somewhere.

- [ ] **Step 4: Read the file to understand structure**

Use Read on `speakers/burak-can-polat/presentation-cheat-sheet.html`. Identify:
- The `:root` CSS variable block (design tokens)
- The sticky topbar markup
- The hero section
- The 5 mockup sections (Hero, "Bu Workshop Nedir?", "Chinook + Mimari", "Build Step", "Demo Question")
- The click-to-copy JS at the bottom

Take note of section anchor IDs the mockup uses — we may rename them to match the spec's `#intro`, `#what`, `#chinook`, `#mimari`, `#worker`, `#checklist`, `#step-NN`, `#sorular`, `#modeller`, `#hata`, `#sonra`.

- [ ] **Step 5: Commit baseline**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "$(cat <<'EOF'
Replace cheat sheet with terminal-dark mockup baseline (B)

Starting point for the workshop-format redesign. The next commits
update each section in place with final content per the spec.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Update sticky topbar nav + section anchor IDs

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html`

- [ ] **Step 1: Identify current topbar nav structure**

Read the topbar block. Note the current nav item labels and the href targets.

- [ ] **Step 2: Rewrite topbar nav to match spec section list**

Replace nav items so they match spec section order. Target labels (in Turkish, using terminal `$` prompt aesthetic from mockup B):

| Label | Anchor |
|---|---|
| `intro` | `#intro` |
| `nedir` | `#what` |
| `chinook` | `#chinook` |
| `mimari` | `#mimari` |
| `worker` | `#worker` |
| `kontrol` | `#checklist` |
| `kurulum` | `#step-01` |
| `sorular` | `#sorular` |
| `modeller` | `#modeller` |
| `hata` | `#hata` |
| `sonra` | `#sonra` |

- [ ] **Step 3: Add IDs to all major sections currently in the file**

For every `<section>` tag, set `id="..."` to one of the above anchors. The mockup B has 5 sections — rename their IDs to the first 5 anchors above. Empty placeholders for the remaining 6 sections will be added in later tasks; for now just verify the existing 5 are correctly tagged.

- [ ] **Step 4: Verify smooth scroll + active nav highlight**

Open in browser, click each nav item, confirm smooth scroll. If active-nav highlight on scroll is in the mockup JS, confirm it works.

- [ ] **Step 5: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Sync sticky topbar nav with spec section IDs"
```

---

## Task 3: Finalize Hero section (#intro)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (hero section)

**Reference:** spec §3 `#intro`

- [ ] **Step 1: Replace hero content**

Locate the hero `<section id="intro">` and replace its content so it contains:

- Title: `Doğal Dilden SQL'e — n8n + Telegram + AI Agent`
- Subtitle: `30 dakikalık canlı workshop`
- Speaker line: `Burak Can Polat · 2026-05-17 · İzmir`
- Value-prop sentence (TR): `Sıfırdan, canlı, kendi makinende. 30 dakika sonra Telegram'dan Türkçe SQL sorabilen bir botun olacak.`
- Primary CTA: `Workshop'a Başla →` linking to `#what`

Keep the mockup B styling (terminal-green prompt prefix, large mono title, etc).

- [ ] **Step 2: Verify in browser**

Reload, check hero renders correctly, CTA jumps to next section.

- [ ] **Step 3: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Hero: final TR title + speaker line + CTA"
```

---

## Task 4: Finalize "Bu Workshop Nedir?" section (#what)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (#what section)

**Reference:** spec §3 `#what`

- [ ] **Step 1: Replace section content**

Section heading: `Bu Workshop Nedir?`

Intro paragraph (TR):
> 30 dakika boyunca canlı, beraber, sıfırdan bir Telegram bot kuracağız. Import yok — her node'u kendin oluşturacaksın. Sonunda kendi n8n instance'ında Türkçe SQL sorabilen bir botun olacak.

Three info blocks (terminal-card style, three columns on desktop, stacked on mobile):

1. **Sonunda elinde olacak:**
   `Telegram'dan "en çok satan 5 müzik türü" yazınca Markdown tablo dönen kendi botun. Chat geçmişi hatırlanan, hatadan kendini düzelten, salt-okunur SQL üreten bir agent.`

2. **Adımlar (yüksek seviye):**
   `BotFather → n8n credentials → Telegram Trigger → AI Agent → 2 HTTP Tool → System Prompt → Telegram Send → Test.`

3. **Önkoşullar:**
   `Telegram hesabı · n8n erişimi (self-hosted veya Cloud) · OpenRouter API key (free tier yeterli).`

- [ ] **Step 2: Verify in browser + Turkish chars render correctly**

- [ ] **Step 3: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Bu Workshop Nedir: final TR copy + 3 info blocks"
```

---

## Task 5: Build "Chinook Veritabanı Nedir?" section (#chinook)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (#chinook section)

**Reference:** spec §3 `#chinook`

- [ ] **Step 1: Section heading + intro paragraph**

Heading: `Chinook Veritabanı Nedir?`

Paragraph (TR):
> Chinook, dijital bir müzik mağazasını modelleyen örnek bir SQLite veritabanıdır. Workshop için 2021-2025 arası sipariş geçmişi yüklendi — ~3500 parça, 11 tablo, gerçekçi ama anlaşılır boyut. Sıfırdan SQL öğrenirken kullanılan standart dataset'lerden biri.

- [ ] **Step 2: 11-table grid**

Render the 11 tables as a 2- or 3-column grid (terminal-card style) where each cell has the table name in `--accent` mono and a 1-line role description in `--text-mute` Geist:

- **Artist** — Sanatçı kayıtları (Iron Maiden, Metallica, ...)
- **Album** — Albümler, her biri bir sanatçıya bağlı
- **Track** — Parçalar (album, genre, süre, fiyat)
- **Genre** — Müzik türleri (Rock, Latin, Metal, ...)
- **MediaType** — Format (MP3, AAC, Protected MPEG-4, ...)
- **Customer** — Müşteri kayıtları, ülke + email
- **Invoice** — Fatura başlıkları (toplam tutar, tarih, ülke)
- **InvoiceLine** — Fatura kalemleri (parça + adet + birim fiyat)
- **Employee** — Çalışanlar (manager hiyerarşili)
- **Playlist** — Çalma listeleri
- **PlaylistTrack** — Liste-parça eşlemesi (many-to-many)

- [ ] **Step 3: Footer note linking to full schema**

Below the grid, a small Turkish note:
> Tam ER diyagramı: [`data/chinook-schema.mmd`](./data/chinook-schema.mmd) (Mermaid kaynak — VS Code/Mermaid Live'da aç)

- [ ] **Step 4: Verify in browser**

- [ ] **Step 5: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Chinook section: 11-table grid + schema link"
```

---

## Task 6: Refine architecture SVG diagram (#mimari)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (#mimari section)

**Reference:** spec §3 `#mimari`

The mockup B already includes an architecture diagram. This task refines it to match the final spec flow.

- [ ] **Step 1: Locate existing SVG in mockup**

Find the inline `<svg>` in the current #mimari section.

- [ ] **Step 2: Update SVG to show full flow**

Required nodes (top-to-bottom or left-to-right):

```
[Telegram (kullanıcı)]
    │ message
    ▼
[n8n Telegram Trigger]
    │
    ▼
[AI Agent (Tools Agent)]  ───┬── [OpenRouter Chat Model]
    │                        ├── [Window Buffer Memory]
    │                        ├── [generate_and_test_sql] ─┐
    │                        └── [execute_sql] ──────────┤
    │                                                    ▼
    │                               [Cloudflare Worker (/test, /execute)]
    │                                                    │
    │                                                    ▼
    │                                          [D1 (Chinook SQLite)]
    ▼
[Telegram Send]
    │
    ▼
[Telegram (kullanıcı)]
```

Styling:
- Agent block in `--accent` (terminal green)
- The 2 tools + Worker + D1 in `--accent-edge` (cyan)
- Memory + Model sub-nodes in `--text-mute` (subtle)
- All labels in JetBrains Mono
- Lines sharp + geometric, no rounded curves

- [ ] **Step 3: Below diagram, add 3-line TR caption**

> Telegram'dan gelen mesaj n8n'e webhook olur, AI Agent çağırılır. Agent önce `generate_and_test_sql` ile dry-run yapar, başarılıysa `execute_sql` çağırır. Sonuç markdown tablo olarak Telegram'a döner.

- [ ] **Step 4: Verify in browser — diagram readable on both projector + phone**

- [ ] **Step 5: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Mimari diagram: add Memory + Model sub-nodes + caption"
```

---

## Task 7: Build "Cloudflare Worker arka planda" section (#worker)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert new #worker section after #mimari)

**Reference:** spec §3 `#worker`

- [ ] **Step 1: Insert new section after #mimari**

Heading: `Cloudflare Worker arka planda ne yapıyor?`

Intro paragraph (TR):
> n8n bir SQLite dosyasına direkt erişemez — araya bir HTTP API koymamız lazım. Bu işi Cloudflare Worker yapıyor: dünya çapında düşük latency, free tier'a sığar, D1 (yönetilen SQLite) ile entegre. Worker iki endpoint sunuyor — biri güvenli önizleme için, diğeri tam sonuç için.

- [ ] **Step 2: Endpoint table (2 rows, terminal-card style)**

| Endpoint | Ne yapar | Body | Dönüş |
|---|---|---|---|
| `POST /test` | SQL'i `LIMIT 5` ile sarar — güvenli önizleme | `{"sql": "..."}` | `{"rows": [...]}` veya `{"error": "..."}` |
| `POST /execute` | SQL'i olduğu gibi çalıştırır | `{"sql": "..."}` | `{"rows": [...]}` veya `{"error": "..."}` |

- [ ] **Step 3: Copyable Worker base URL**

Label: `Worker base URL`
Content (in a copyable code-pill):
```
https://chinook-workshop.bitter-brook-7999.workers.dev
```

- [ ] **Step 4: Security note**

Render as a callout (terminal-amber or muted variant of `--accent`):
> **Güvenlik:** Worker `src/security.ts` regex'i `INSERT/UPDATE/DELETE/DROP/ALTER/CREATE/REPLACE/ATTACH/DETACH/PRAGMA/VACUUM` kelimelerini engelliyor. Sadece `SELECT` geçer. Salt-okunur garanti prompt'ta değil, Worker sınırına gömülü.

- [ ] **Step 5: Health-check curl block (copyable)**

Label: `Worker sağlık testi (terminalde çalıştır)`
Content:
```bash
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "User-Agent: curl/8.0.0" \
  -d '{"sql":"SELECT 1 AS health"}' \
  https://chinook-workshop.bitter-brook-7999.workers.dev/test
```
Expected output line below: `Beklenen: {"rows":[{"health":1}],"count":1}`

- [ ] **Step 6: Verify in browser**

- [ ] **Step 7: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Worker explainer section: endpoints + URL + security + health check"
```

---

## Task 8: Build "Uçuş Öncesi Kontroller" section (#checklist)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert new #checklist section after #worker)

**Reference:** spec §3 `#checklist`

- [ ] **Step 1: Insert section after #worker**

Heading: `Uçuş Öncesi Kontroller`

Sub-heading hint (TR, smaller font):
> Workshop'a girmeden 5 dakika önce hepsini tıkla. Eksik varsa yerine git, tamamla, dön.

- [ ] **Step 2: 7-item interactive checklist**

Each item is a row with a `<label>` + `<input type="checkbox">` (purely visual — no persistence needed) and a terminal-green check icon when checked. JetBrains Mono labels in `--text`, optional `--text-mute` 1-line help under each.

1. ☐ **Telegram hesabın hazır** — mobil app veya web — telegram.org
2. ☐ **BotFather'dan yeni bot oluşturdun + token'ı kaydettin** — `@BotFather` → `/newbot`
3. ☐ **n8n instance'a erişimin var** — self-hosted (Docker / Hetzner / vs) veya Cloud (n8n.cloud). Yeni workflow oluşturabiliyor olman lazım.
4. ☐ **OpenRouter hesabın var + bir API key oluşturdun** — openrouter.ai/keys
5. ☐ **Worker `/test` endpoint sağlıklı** — yukarıdaki health-check curl'ü `{"rows":[{"health":1}]}` dönüyor
6. ☐ **Bu cheat sheet bir tarayıcı sekmesinde açık** — kopyala-yapıştır için lazım olacak
7. ☐ **En az 30 dakika kesintisiz vaktin var** — telefon sessize, kahve dolu

- [ ] **Step 3: Verify checkboxes are clickable + visual feedback works**

- [ ] **Step 4: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Flight checklist: 7-item pre-workshop sanity check"
```

---

## Task 9: Build Phase 1 — Steps 1-3 (BotFather, n8n creds, Telegram Trigger)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert #step-01, #step-02, #step-03 sections)

**Reference:** spec §3 "Build Phase 1"

- [ ] **Step 1: Add section group heading "Kurulum — Faz 1: Temel"**

Above the 3 cards, a small section divider heading: `Faz 1 — Temel (≈8 dk)`

- [ ] **Step 2: Step 01 card — BotFather**

Card structure (use mockup B's "Build Step" card pattern from the existing step-04 example):
- Badge: `01`
- Title (TR): `Telegram Bot oluştur (BotFather)`
- Instruction (TR): `Telegram'da @BotFather ile sohbete başla. /newbot komutuyla yeni bot oluştur. İstediği bot adı + kullanıcı adını ver (kullanıcı adı _bot ile bitmeli). Sonunda HTTP API token'ı verir — bunu güvenli bir yere kopyala.`
- Copyable: `BotFather komutu (Telegram'a yapıştır)` → `/newbot`
- Beklenen sonuç: `BotFather sana "Use this token to access the HTTP API:" diye başlayan bir mesaj döner — token bu satırın altındadır.`

- [ ] **Step 3: Step 02 card — n8n credentials**

- Badge: `02`
- Title (TR): `n8n credentials kur`
- Instruction (TR): `n8n UI → Credentials → New. İki credential ekleyeceğiz: Telegram Bot Token + OpenRouter API Key.`
- Two sub-blocks:
  - **Telegram credential:** type seç → `Telegram API` → "Access Token" alanına BotFather'dan aldığın token'ı yapıştır → Save.
  - **OpenRouter credential:** type seç → `OpenRouter API` → "API Key" alanına openrouter.ai/keys'den aldığın key'i yapıştır → Save.
- Beklenen sonuç: `Credentials listesinde iki kayıt — yeşil tick (✓) işaretli.`

- [ ] **Step 4: Step 03 card — Telegram Trigger**

- Badge: `03`
- Title (TR): `Yeni workflow + Telegram Trigger ekle`
- Instruction (TR): `Yeni boş workflow aç. Sol panelden Telegram Trigger node'unu canvas'a sürükle. Az önce oluşturduğun Telegram credential'ı seç. Updates listesinden "Message" işaretle. Kaydet.`
- Copyable: yok (UI tıklama bazlı adım)
- Beklenen sonuç: `Canvas'ta yalnız bir Telegram Trigger node'u, webhook URL'i n8n tarafından üretilmiş halde.`

- [ ] **Step 5: Verify all 3 cards render with badge styling intact**

- [ ] **Step 6: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Build Phase 1: steps 01-03 (BotFather, n8n creds, Telegram Trigger)"
```

---

## Task 10: Build Phase 1 — Steps 4-6 (AI Agent, OpenRouter Model, Memory)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert #step-04, #step-05, #step-06 sections)

**Reference:** spec §3 "Build Phase 1"

- [ ] **Step 1: Step 04 card — AI Agent**

- Badge: `04`
- Title (TR): `AI Agent node ekle (Tools Agent mode)`
- Instruction (TR): `Telegram Trigger'ın yanına AI Agent node ekle (sol panelden "AI Agent" ara, sürükle). Aşağıdaki ayarları yap:`
- 3 copyable rows:
  - Label: `Agent type` → Content: `Tools Agent` (UI dropdown — tıkla seç)
  - Label: `Prompt Type` → Content: `Define`
  - Label: `Prompt (text alanı)` → Content (copyable): `={{ $json.message.text }}`
- Beklenen sonuç: `AI Agent canvas'ta, Trigger'a bağlı, kırmızı uyarı yok (System Message + tools sonra eklenecek).`

- [ ] **Step 2: Step 05 card — OpenRouter Chat Model**

- Badge: `05`
- Title (TR): `OpenRouter Chat Model sub-node bağla`
- Instruction (TR): `AI Agent'ın altındaki "+" işaretine tıkla → "Chat Model" → "OpenRouter Chat Model" seç. Az önce oluşturduğun OpenRouter credential'ı seç. Model alanına şunu yapıştır:`
- Copyable: `anthropic/claude-haiku-4.5` (label: `Model — default (kararlı + hızlı + ucuz)`)
- Hint (TR, küçük font): `Alternatif modeller aşağıdaki "Model Alternatifleri" bölümünde — istediğin zaman değiştir.`
- Beklenen sonuç: `OpenRouter Chat Model sub-node AI Agent'a bağlı, model adı görünür.`

- [ ] **Step 3: Step 06 card — Window Buffer Memory**

- Badge: `06`
- Title (TR): `Window Buffer Memory sub-node bağla`
- Instruction (TR): `Yine "+" → "Memory" → "Window Buffer Memory" seç. Session ID type'ı "Custom Key" yap. Session Key alanına şunu yapıştır:`
- Copyable: `={{ $('Telegram Trigger').item.json.message.chat.id }}` (label: `Session Key — her Telegram chat'i ayrı geçmiş`)
- Hint: `Bu sayede aynı chat'teki önceki sorular hatırlanır, farklı chat'ler izole kalır.`
- Beklenen sonuç: `Memory sub-node AI Agent'a bağlı, custom session key set.`

- [ ] **Step 4: Verify all 3 cards render**

- [ ] **Step 5: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Build Phase 1: steps 04-06 (AI Agent, OpenRouter Model, Memory)"
```

---

## Task 11: Build Phase 2 — Step 7 (generate_and_test_sql tool)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert #step-07 section)

**Reference:** spec §3 `#step-07`

- [ ] **Step 1: Add section group heading "Faz 2: Araçlar + Beyin"**

Above the next 5 cards, a divider heading: `Faz 2 — Araçlar + Beyin (≈15 dk)`

- [ ] **Step 2: Step 07 card — generate_and_test_sql**

- Badge: `07`
- Title (TR): `Tool 1: generate_and_test_sql ekle (HTTP Request Tool)`
- Instruction (TR): `AI Agent altındaki "+" → "Tool" → "HTTP Request Tool" seç. ÖNEMLİ: "HTTP Request Tool" — "Tool" suffix'i olan, normal HTTP Request değil. (Node type: n8n-nodes-base.httpRequestTool v4.4.) Aşağıdaki alanları doldur:`

- 5 copyable rows:

  **Row 1:** Label: `Tool Name (Name alanı)`
  Content: `generate_and_test_sql`

  **Row 2:** Label: `Tool Description (Description alanı — tam metni yapıştır)`
  Content:
  ```
  Validates a SQL query by running it with LIMIT 5 against the Chinook SQLite backend. Returns {rows:[...]} on success, {error:'...'} on failure. ALWAYS call this before execute_sql.
  ```

  **Row 3:** Label: `Method`
  Content: `POST`

  **Row 4:** Label: `URL`
  Content: `https://chinook-workshop.bitter-brook-7999.workers.dev/test`

  **Row 5:** Label: `Body — "Using Fields Below" seç → Add Field → name: sql, value:`
  Content: `={{ $fromAI('sql', 'The SQL SELECT query to dry-run with LIMIT 5. SQLite syntax only.', 'string') }}`

- Warning callout (terminal-amber):
> ⚠️ **AI wand butonuna BASMA.** Otomatik doldurma `parameters0_Value` gibi anlamsız isimler üretir, LLM bunu tool schema'da göremez. Manuel olarak `'sql'` yaz.

- Beklenen sonuç: `Tool sub-node AI Agent'a bağlı, "Tool loaded" durumu görünür.`

- [ ] **Step 3: Verify card renders, warning callout is prominent**

- [ ] **Step 4: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Build Phase 2: step 07 (generate_and_test_sql tool)"
```

---

## Task 12: Build Phase 2 — Step 8 (execute_sql tool)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert #step-08 section)

**Reference:** spec §3 `#step-08`

- [ ] **Step 1: Step 08 card — execute_sql**

- Badge: `08`
- Title (TR): `Tool 2: execute_sql ekle (HTTP Request Tool)`
- Instruction (TR): `Aynı yapıyla bir tool daha ekle. URL'i ve tool description'ı değişiyor — geri kalan her şey aynı.`

- 5 copyable rows:

  **Row 1:** Label: `Tool Name`
  Content: `execute_sql`

  **Row 2:** Label: `Tool Description`
  Content:
  ```
  Executes a previously-validated SQL query against the Chinook SQLite backend and returns the full result set. Only call after generate_and_test_sql succeeded.
  ```

  **Row 3:** Label: `Method`
  Content: `POST`

  **Row 4:** Label: `URL`
  Content: `https://chinook-workshop.bitter-brook-7999.workers.dev/execute`

  **Row 5:** Label: `Body — Using Fields Below → name: sql, value:`
  Content: `={{ $fromAI('sql', 'The validated SQL SELECT query to run. SQLite syntax only. Pass the EXACT string that succeeded in generate_and_test_sql.', 'string') }}`

- Beklenen sonuç: `İki tool sub-node yan yana AI Agent altında. "Tool loaded" × 2.`

- [ ] **Step 2: Verify**

- [ ] **Step 3: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Build Phase 2: step 08 (execute_sql tool)"
```

---

## Task 13: Build Phase 2 — Step 9 (System Prompt with TR + EN toggle)

**Files:**
- Read: `speakers/burak-can-polat/prompts/system-prompt-tr.md`
- Read: `speakers/burak-can-polat/prompts/system-prompt-en.md`
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert #step-09 section)

**Reference:** spec §3 `#step-09`

- [ ] **Step 1: Read both prompt files for verbatim content**

Use Read on both `prompts/system-prompt-tr.md` and `prompts/system-prompt-en.md`. Capture exact text including newlines.

- [ ] **Step 2: Step 09 card — System Prompt**

- Badge: `09`
- Title (TR): `Sistem Promptu yapıştır`
- Instruction (TR): `AI Agent node'unu aç → Options → "System Message" alanına aşağıdaki TR promptun tamamını yapıştır. EN versiyon altta toggle ile mevcut — istersen onu kullanabilirsin (workshop boyunca TR önerilir).`

- Copyable `<pre>` block #1: TR system prompt FULL text (~38 lines, exact verbatim from `prompts/system-prompt-tr.md`).
  Label above: `Türkçe sistem promptu (default — yapıştır)`
  Copy button label: `Kopyala`

- Below, an HTML `<details>` element:
  Summary: `English version (göster)`
  Inside: copyable `<pre>` block with EN system prompt full text.

- Warning callout below (terminal-amber):
> ⚠️ Sistem promptunu doğrudan System Message alanına yapıştır — Code node veya expression olarak değil. n8n'in "fx" toggle'ına basma.

- Beklenen sonuç: `AI Agent → Options → System Message alanında ~38 satırlık TR prompt görünür.`

- [ ] **Step 3: Verify both pre blocks render full text (no truncation), Turkish chars correct in TR block**

- [ ] **Step 4: Verify click-to-copy copies the ENTIRE prompt (not just visible text)**

- [ ] **Step 5: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Build Phase 2: step 09 (System Prompt full TR + EN toggle)"
```

---

## Task 14: Build Phase 2 — Steps 10-11 (Telegram Send + Save/Activate)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert #step-10, #step-11 sections)

**Reference:** spec §3 `#step-10`, `#step-11`

- [ ] **Step 1: Step 10 card — Telegram Send**

- Badge: `10`
- Title (TR): `Telegram Send node ekle (cevap döner)`
- Instruction (TR): `AI Agent'ın main çıkışına bir Telegram Send node bağla. Aşağıdaki ayarları yap:`

- Copyable rows:

  **Row 1:** Label: `Resource` → Content: `Message` (dropdown)
  **Row 2:** Label: `Operation` → Content: `Send a Text Message` (dropdown)
  **Row 3:** Label: `Chat ID` (copyable expression)
  Content: `={{ $('Telegram Trigger').item.json.message.chat.id }}`
  **Row 4:** Label: `Text` (copyable expression)
  Content: `={{ $json.output }}`
  **Row 5:** Label: `Additional Fields → Parse Mode`
  Content: `Markdown` (dropdown — **NOT MarkdownV2**)
  **Row 6:** Label: `Additional Fields → Append n8n Attribution`
  Content: `false` (toggle OFF)

- Warning callout:
> ⚠️ `Parse Mode = Markdown` (legacy/lenient). MarkdownV2 seçersen bot Telegram'a yanıt gönderemez — özel karakterler escape gerektirir.

- Beklenen sonuç: `Telegram Send node AI Agent çıkışına bağlı, credentials Telegram (Workshop Bot) seçili.`

- [ ] **Step 2: Step 11 card — Save + Activate + /start**

- Badge: `11`
- Title (TR): `Kaydet + Aktive et + Bot'una merhaba de`
- Instruction (TR): `Workflow'u kaydet (Save). Sağ üstteki "Active" toggle'ını AÇ. Sonra Telegram'da bot'unu aç, /start yaz veya direkt "merhaba" gönder. Bot cevaplamalı.`

- Copyable: yok (Telegram'da elle yazılacak)
- Beklenen sonuç: `Bot Türkçe bir karşılama döner. Eğer dönmezse → "Hata Yakalandığında" bölümüne bak.`

- [ ] **Step 3: Verify both cards render**

- [ ] **Step 4: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Build Phase 2: steps 10-11 (Telegram Send + Save/Activate)"
```

---

## Task 15: Build "Demo Soru Bankası" section (#sorular — 15 questions)

**Files:**
- Read: `speakers/burak-can-polat/data/demo-questions.md` (for current Q1-Q12 + T1-T2 text)
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert #sorular section)

**Reference:** spec §3 `#sorular`

- [ ] **Step 1: Read demo-questions.md to capture exact Q1-Q12 + T1-T2 wording**

Use Read on `data/demo-questions.md`. Extract:
- Each question text (Turkish, copyable form)
- Each reference SQL (for the "Beklenen davranış" hint)
- T1 + T2 trap descriptions

- [ ] **Step 2: Insert section heading + intro**

Heading: `Demo Soru Bankası`
Intro (TR, smaller): `15 sorudan oluşan canlı demo seti. Bot'a kopyala-yapıştır şeklinde gönder. Trap soruları (T1, T2) özellikle eğitici — bot ne yaparsa onu izle.`

- [ ] **Step 3: Sub-header + Q0 card (NEW — Açılış)**

Sub-header: `🎯 Açılış — SQL Önizleme (yeni)`

Q0 card:
- Difficulty badge: `Açılış`
- Copyable question: `Top 5 sanatçı için SQL sorgusu yaz, sadece SQL'i göster, ÇALIŞTIRMA.`
- Beklenen davranış: `Bot tool çağırmaz (generate_and_test_sql/execute_sql atlanır), sadece markdown SQL bloğu döker. Audience şeffaflığı görür.`
- Pedagojik not: `Bot, system prompt'taki "önce generate_and_test_sql çağır" direktifini user'ın "ÇALIŞTIRMA" emriyle override eder. İyi agent kullanıcıyı dinler.`

- [ ] **Step 4: Sub-header + Q1 card (Trivial)**

Sub-header: `Trivial — 1 soru`

Q1 card:
- Difficulty: `Trivial`
- Question: `Müşterilerimiz hangi ülkelerden geliyor?`
- Beklenen davranış: `Bot Invoice tablosundan DISTINCT BillingCountry çeker, 24 ülke listeler.`

- [ ] **Step 5: Sub-header + Q2-Q4 cards (Kolay)**

Sub-header: `Kolay — 3 soru`

Q2 — `En çok satan ilk 5 müzik türü?` (Beklenen: InvoiceLine + Track + Genre JOIN, Rock 835 / Latin 386 / Metal 264 / Alt&Punk 244 / Jazz 80)

Q3 — `Harcamaya göre ilk 10 müşterimiz kim?` (Beklenen: Customer + Invoice JOIN, Helena Holý $49.62 en üstte)

Q4 — `Yıllara göre toplam ciro?` (Beklenen: strftime('%Y') + SUM, 2021-2025 arası 5 satır)

- [ ] **Step 6: Sub-header + Q5-Q8 cards (Orta)**

Sub-header: `Orta — 4 soru`

Q5 — `Hangi destek temsilcisi en çok geliri sağlıyor?` (Beklenen: Employee → Customer → Invoice 3'lü JOIN, Jane Peacock $833.04 en üstte)

Q6 — `En az 5 faturası olan ülkeler için ortalama sipariş tutarı?` (Beklenen: HAVING COUNT(*)>=5)

Q7 — `$10'dan fazla gelir getiren albümler?` (Beklenen: 4-tablo JOIN, ~64 albüm)

Q8 — `2024 aylık ciro (sıfır aylar dahil)` (Beklenen: WITH months VALUES + LEFT JOIN — D1 compound SELECT limit aşmasın diye VALUES syntax)

- [ ] **Step 7: Sub-header + Q9-Q11 cards (Zor)**

Sub-header: `Zor — 3 soru`

Q9 — `Çalışanları gelir bazında RANK() ile sırala` (Beklenen: Window function)
Q10 — `Hiç satılmamış parçalar?` (Beklenen: anti-join, 1519 parça)
Q11 — `Her türün toplam cirodaki yüzdesi?` (Beklenen: correlated subquery, Rock %35.5)

- [ ] **Step 8: Sub-header + Q12 card (Wow)**

Sub-header: `🚀 Wow — 1 soru (kullanım: 26:00 civarı)`

Q12 — `Aylık ciro büyüme oranı (MoM)?`
Beklenen: `CTE chain + LAG window function. Bot 3 logical hop'u <3 sn'de kurar, insan Excel'de 15 dk uğraşır. En büyük düşüş Kasım 2023 −36.84%.`
Pedagojik: `Workshop'un finale doğru "vay be" anı. Window function + CTE'nin gücünü gösterir.`

- [ ] **Step 9: Sub-header + T1, T2 cards (Trap)**

Sub-header: `🪤 Trap — 2 soru (kullanım: 22:00-26:00 arası)`

T1 — `Sanatçı başına gelir? (top 10)`
Trap: `Bot Track.UnitPrice (liste fiyatı) kullanmaya meyilli, ama gerçek gelir InvoiceLine.UnitPrice × Quantity. test step trap'i ortaya çıkarmaz — bot doğru tabloya bakıyor mu önemli. Doğru cevap: Iron Maiden $138.60, U2 $105.93, Metallica $90.09.`

T2 — `Bu yıl en aktif müşteriler kim?`
Trap: `"Bu yıl" muğlak — 2026 (gerçek "bu yıl") veri yok (latest 2025). İyi agent "2025 mi kastettiniz?" diye sorar. "Aktif" de muğlak — sipariş sayısı mı, ciro mu, son tarih mi? İyi agent her iki belirsizliği de sorar.`

- [ ] **Step 10: Verify all 15 cards render, each question is copyable, badges + sub-headers visible**

- [ ] **Step 11: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Demo soru bankası: 15 questions (Q0 new + Q1-12 + T1-T2)"
```

---

## Task 16: Build "Model Alternatifleri" section (#modeller)

**Files:**
- Read: `/tmp/openrouter-models.md` (already produced by research subagent)
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert #modeller section)

**Reference:** spec §3 `#modeller`

- [ ] **Step 1: Read the OpenRouter research output**

Use Read on `/tmp/openrouter-models.md`. Extract the 8-row table + the picking guide paragraph.

- [ ] **Step 2: Insert section**

Heading: `Model Alternatifleri (OpenRouter)`
Intro (TR): `Workshop'a haiku-4.5 ile başladık ama OpenRouter'da 8 farklı model var — bütçen, hızın, dil tercihin neyse seç. Hepsi tool calling destekliyor.`

- [ ] **Step 3: Render the 8-row table**

Use the existing terminal-card table styling from mockup B. Columns:
- Model (display name)
- Model ID (copyable code-pill — each row has its own copy button)
- Tier (Ücretsiz / Ucuz / Standart / Premium)
- Tool calling (⭐⭐⭐ / ⭐⭐ / ⭐ + justification)
- Türkçe (⭐⭐⭐ / ⭐⭐ / ⭐)
- Not (TR sentence)

Order: Ücretsiz → Ucuz → Standart → Premium (matches research output).

The 8 model rows (verbatim from research):

| Model | Model ID | Tier | Tool | TR | Not |
|---|---|---|---|---|---|
| Gemini 2.0 Flash Exp | `google/gemini-2.0-flash-exp:free` | Ücretsiz | ⭐⭐ hızlı ama deneysel | ⭐⭐⭐ | Free denemelerin için; rate limit nedeniyle workshop ortamında yavaşlayabilir. |
| Llama 3.3 70B Instruct | `meta-llama/llama-3.3-70b-instruct:free` | Ücretsiz | ⭐⭐ yeterli | ⭐⭐ | Ücretsiz en güvenilir araç çağırma seçeneği; Türkçe kabul edilebilir. |
| Claude Haiku 4.5 | `anthropic/claude-haiku-4.5` | Ucuz | ⭐⭐⭐ Doğrulandı ✅ | ⭐⭐⭐ | 14 sorudan 11'ini doğru yanıtladı; default. |
| DeepSeek V3 | `deepseek/deepseek-chat` | Ucuz | ⭐⭐⭐ tutarlı | ⭐⭐⭐ | GPT-4 seviyesi kaliteyi düşük maliyetle. |
| GPT-4o Mini | `openai/gpt-4o-mini` | Ucuz | ⭐⭐⭐ güvenilir | ⭐⭐⭐ | OpenAI'a aşina katılımcılar için tanıdık. |
| Qwen 2.5 72B | `qwen/qwen-2.5-72b-instruct` | Standart | ⭐⭐ iyi | ⭐⭐⭐ | Çok dilli güçlü model; veri analizi öne çıkar. |
| Gemini 2.5 Flash | `google/gemini-2.5-flash` | Standart | ⭐⭐⭐ hızlı+güçlü | ⭐⭐⭐ | n8n workshop önerilen LLM; free bittiyse buraya geç. |
| Claude Sonnet 4.6 | `anthropic/claude-sonnet-4.6` | Premium | ⭐⭐⭐ en güvenilir | ⭐⭐⭐ | En iyi kalite gerektiğinde; en pahalı seçenek. |

- [ ] **Step 4: Picking guide paragraph (TR — verbatim from research)**

> İlk denemen için `anthropic/claude-haiku-4.5` ile başla — workshop boyunca test edildi ve kararlı çalışıyor. Ücretsiz tier istiyorsan `meta-llama/llama-3.3-70b-instruct:free` tercih et; `google/gemini-2.0-flash-exp:free` hız testleri için iyi ama rate limit nedeniyle grup kullanımında yavaşlayabilir. Uygun fiyat ve yüksek doğruluk istiyorsan `deepseek/deepseek-chat` veya `google/gemini-2.5-flash` harika bir denge sunuyor. En iyi Türkçe ve SQL kalitesini istiyorsan `anthropic/claude-sonnet-4.6` ile devam et.

- [ ] **Step 5: "Model değiştirme" 1-liner**

> Model değiştirme: `OpenRouter Chat Model` node'unu aç → `Model` alanını yukarıdaki ID'lerden biriyle değiştir → Save → bot'a yeni soru gönder.

- [ ] **Step 6: Verify table + copy-pills work**

- [ ] **Step 7: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Model alternatifleri: 8-row OpenRouter table + picking guide"
```

---

## Task 17: Build closing sections — Errors (#hata) + After (#sonra) + Footer (#footer)

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (insert 3 sections at end)

**Reference:** spec §3 `#hata`, `#sonra`, `#footer`

- [ ] **Step 1: #hata — Hata Yakalandığında Ne Yapılır?**

Heading: `Hata Yakalandığında Ne Yapılır?`

Compact 4-row table (terminal-card):

| Belirti | Ne kontrol et |
|---|---|
| Bot tool çağırmıyor | `$fromAI` ifadesinin yazımı doğru mu (`'sql'` first arg, type=`'string'`). Tool Description'da "ALWAYS call this..." gibi net direktif var mı. |
| Worker 400 dönüyor | SQL'de yasak kelime mi var (`INSERT/UPDATE/DELETE/DROP/...`) veya SQLite syntax hatası mı (ISNULL yerine COALESCE; tarihler için strftime). |
| Telegram "Bad Request: can't parse entities" | Parse Mode `Markdown` olmalı, `MarkdownV2` değil. AI Agent → output'unda escape edilmemiş özel karakter var. |
| Bot Türkçe cevap vermiyor | System Message'ın AI Agent → Options altına yapıştırıldığını + son satırdaki dil yönlendirmesinin koptarılmadığını kontrol et. |

Footer link:
> Detaylı kılavuz: [`failure-recovery.md`](./failure-recovery.md)

- [ ] **Step 2: #sonra — Workshop Sonrası**

Heading: `Workshop Sonrası`

3 sub-blocks:

1. **Code Tool ile aynı şeyi nasıl yaparsın?**
   `HTTP Tool yerine n8n'in Code node'unu kullanarak SQL'i n8n içinden çalıştıran bir varyant da var. Devs için ekstra örnek:` → [`bonus/dev-corner/README.md`](./bonus/dev-corner/README.md)

2. **Bu workshop'u kendine adapte et**
   `Tüm kaynak: github.com/onurpolat05/n8n-izmir-workshop-2026 (speakers/burak-can-polat/ altında)`
   QR code (mevcut PNG'yi göm — `qr-codes/` altında varsa kullan, yoksa metin link)

3. **İletişim**
   - LinkedIn: linkedin.com/in/burakcanpolat
   - Web: burakcanpolat.dev
   (Burak'ın confirm etmesi lazım — bu üç satır placeholder, gerçek profil URL'leriyle değiştirilebilir)

- [ ] **Step 3: #footer**

Heading: yok (sade footer)
Content:
- Sol: `Burak Can Polat · 2026-05-17 · n8n İzmir Workshop`
- Sağ: `Updated: 2026-05-16` (hard-coded; we don't need runtime date)
- License: `MIT` veya repo'nun lisansı (sabit metin)
- Küçük print: `Made with terminal vibes ✦`

- [ ] **Step 4: Verify all 3 sections render**

- [ ] **Step 5: Commit**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Closing sections: #hata + #sonra + #footer"
```

---

## Task 18: Polish — Click-to-copy + Mobile responsive + Turkish chars QA

**Files:**
- Modify: `speakers/burak-can-polat/presentation-cheat-sheet.html` (small fixes as needed)

- [ ] **Step 1: Click-to-copy QA**

Open the cheat sheet in browser. Click EVERY copy button (every code block, every URL pill, every demo question). Verify:
- Copy works (paste somewhere to confirm content)
- "✓ Kopyalandı" feedback shows for 2s then reverts
- No JS errors in console

If any code block lacks a copy button, add one using the existing JS handler pattern.

- [ ] **Step 2: Mobile responsive QA (375px viewport)**

Chrome DevTools → toggle device → iPhone SE (375px). Scroll through all sections. Verify:
- No horizontal scroll
- Sticky topbar collapses to hamburger or scales down readably
- Cards stack vertically (no overlapping)
- Tables scroll horizontally if too wide (with subtle scroll indicator)
- Code blocks remain readable + copyable
- SVG architecture diagram scales

Fix any breakage inline. Common fixes: add `max-width: 100%` to nav, add `overflow-x: auto` to wide tables, reduce hero title font-size at smaller breakpoints.

- [ ] **Step 3: Projector QA (1920x1080)**

Set viewport to 1920x1080. Verify:
- Hero is large, readable from "back of room" (font scales up)
- Code blocks aren't washed out (high contrast)
- Section spacing isn't cramped

- [ ] **Step 4: Turkish chars QA**

Verify the string `çğıöşüÇĞİÖŞÜ` renders correctly everywhere it appears:
- Hero
- Section headings
- Body text
- Code labels
- Demo questions

Also verify the TR system prompt's Turkish characters render (the embedded 38-line prompt has many: `Türkçe`, `çalıştırır`, `başarılı`, `kullanıcının`, `sözdizimi`, `şemada`, `uydurma`, `muğlaksa`).

- [ ] **Step 5: Cross-browser smoke test**

Open in at least 2 browsers (Chrome + Firefox if available). Verify rendering parity.

- [ ] **Step 6: Commit any fixes**

```bash
git add speakers/burak-can-polat/presentation-cheat-sheet.html
git commit -m "Polish: copy/mobile/projector/Türkçe QA fixes"
```

If no fixes needed, skip the commit.

---

## Task 19: Add Q0 SQL preview to demo-questions.md

**Files:**
- Modify: `speakers/burak-can-polat/data/demo-questions.md`

**Reference:** spec §5 (full Q0 markdown block)

- [ ] **Step 1: Read current demo-questions.md to find insertion point**

Q0 goes at the very top, BEFORE the current "Wow question" section that starts with `## ⭐ Wow question`.

- [ ] **Step 2: Insert Q0 block**

Use Edit to insert this block right after the `---` separator following the title block (after line 9 in current file), before the `## ⭐ Wow question` heading:

```markdown

---

## 🎯 Açılış Sorusu — SQL Önizleme (use as opener, before Q1)

**Q0. Top 5 sanatçı için SQL sorgusu yaz, sadece SQL'i göster, ÇALIŞTIRMA.**

Trap: Sistem promptu "HERHANGİ bir veri sorusu için ÖNCE generate_and_test_sql çağır" diyor — bot, user'ın açık `ÇALIŞTIRMA` emrini bu yönergeyi override eden bir sinyal olarak yorumlamalı. İyi agent hiç tool çağırmaz, sadece SQL'i markdown code block içinde döker.

```sql
-- Beklenen SQL (bot şuna yakın bir şey üretmeli):
SELECT ar.Name AS Sanatçı, COUNT(*) AS SatışSayısı
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.ArtistId
ORDER BY SatışSayısı DESC
LIMIT 5;
```

**Pedagojik değer:** Audience bot'un altında ne ürettiğini görür (şeffaflık) + araç çağırmadan da SQL üretebildiğini fark eder. T1 trap'inden önce gelir.

```

- [ ] **Step 3: Verify markdown renders correctly**

Open in a markdown previewer (or just visually inspect). Confirm:
- Heading hierarchy is right
- SQL code block has language hint (`sql`)
- Turkish chars OK

- [ ] **Step 4: Commit**

```bash
git add speakers/burak-can-polat/data/demo-questions.md
git commit -m "Add Q0 SQL preview question to demo bank"
```

---

## Task 20: Delete skeleton workflow JSON + inject-credentials.sh

**Files:**
- Delete: `speakers/burak-can-polat/workflows/text-to-sql-agent.json`
- Delete: `speakers/burak-can-polat/workflows/inject-credentials.sh`

- [ ] **Step 1: Confirm files exist before deletion**

```bash
ls -la speakers/burak-can-polat/workflows/text-to-sql-agent.json speakers/burak-can-polat/workflows/inject-credentials.sh
```

Expected: both files exist.

- [ ] **Step 2: Delete both files**

```bash
git rm speakers/burak-can-polat/workflows/text-to-sql-agent.json
git rm speakers/burak-can-polat/workflows/inject-credentials.sh
```

- [ ] **Step 3: Confirm only finished workflow remains**

```bash
ls -la speakers/burak-can-polat/workflows/
```

Expected: only `text-to-sql-agent-finished.json` remains.

- [ ] **Step 4: Commit**

```bash
git commit -m "$(cat <<'EOF'
Delete skeleton workflow JSON + inject-credentials.sh

Workshop format changed to build-from-scratch alongside audience —
attendees no longer import a skeleton. Finished workflow stays as
helper/recovery reference for anyone who falls behind.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

## Task 21: Update speaker CLAUDE.md (remove skeleton refs + stale Worker-URL block)

**Files:**
- Modify: `speakers/burak-can-polat/CLAUDE.md`

- [ ] **Step 1: Read current CLAUDE.md**

Read `speakers/burak-can-polat/CLAUDE.md`. Identify:
- The "Files" list that mentions `workflows/text-to-sql-agent.json` and `workflows/inject-credentials.sh`
- The "Worker URL replacement" block (now stale — URL is baked in committed files)
- Any other skeleton references

- [ ] **Step 2: Update "Files" list**

Remove these lines from the Files section:
- `- workflows/text-to-sql-agent.json           — skeleton (attendee version)`
- `- workflows/inject-credentials.sh            — local-only credential injector`

The remaining Files list should mention only `text-to-sql-agent-finished.json` as the workflow JSON.

- [ ] **Step 3: Remove "Worker URL replacement" section**

Delete the entire `## Worker URL replacement (before pushing for the workshop)` heading + its content block (the bash snippet replacing WORKER_URL_HERE). This is obsolete — URL is baked in committed files now.

- [ ] **Step 4: Update header description**

Change the opening blurb from "30-min follow-along: ..." to reflect build-from-scratch format. Specifically replace `LLM: Google Gemini 2.0 Flash via per-attendee free keys.` with `LLM: OpenRouter (default: anthropic/claude-haiku-4.5).`

- [ ] **Step 5: Verify edits with a quick re-read**

- [ ] **Step 6: Commit**

```bash
git add speakers/burak-can-polat/CLAUDE.md
git commit -m "CLAUDE.md: remove skeleton refs + stale Worker URL block"
```

---

## Task 22: Update speaker README.md (build-from-scratch framing)

**Files:**
- Modify: `speakers/burak-can-polat/README.md`

- [ ] **Step 1: Read current README.md**

Find every reference to "skeleton" / "import" / "text-to-sql-agent.json" (the skeleton, not the finished one).

- [ ] **Step 2: Reframe workshop description**

Wherever the README says "attendees import the skeleton workflow" or similar, change to "attendees build the workflow from scratch following the cheat sheet". The cheat sheet (`presentation-cheat-sheet.html`) is now the primary attendee-facing artifact.

- [ ] **Step 3: Update file list (if present)**

If the README lists files, remove the skeleton and inject-credentials.sh entries, keep the finished workflow.

- [ ] **Step 4: Verify edits**

- [ ] **Step 5: Commit**

```bash
git add speakers/burak-can-polat/README.md
git commit -m "README: build-from-scratch framing (skeleton no longer the path)"
```

---

## Task 23: Final QA + drop pre-redesign stash

**Files:**
- (none — cleanup only)

- [ ] **Step 1: Final visual QA of cheat sheet end-to-end**

Open `presentation-cheat-sheet.html` one more time. Scroll top-to-bottom. Confirm:
- All 13 sections present (intro / what / chinook / mimari / worker / checklist / steps 01-11 / sorular / modeller / hata / sonra / footer)
- All 15 demo questions visible (Q0 + Q1-12 + T1-T2)
- All 11 build steps numbered correctly
- All copy buttons work on a 3-sample test
- TR system prompt fully embedded (38 lines copyable in one click)
- EN system prompt expandable
- OpenRouter table has all 8 rows
- Architecture SVG renders with all sub-nodes
- Worker health-check curl is copyable

- [ ] **Step 2: Check final file size**

```bash
ls -la speakers/burak-can-polat/presentation-cheat-sheet.html
```

Expected: under 500KB (sanity check on inline content size).

- [ ] **Step 3: Run git log on the redesign branch**

```bash
git log --oneline -25
```

Expected: ~20+ commits since the spec commit, each scoped to one task.

- [ ] **Step 4: Drop the pre-redesign stash**

```bash
git stash list
```

If the `pre-redesign-cheat-sheet` stash from Task 1 is still there, drop it:

```bash
git stash drop stash@{0}
```

(Only drop if the new redesign is confirmed working — this is a destructive cleanup.)

- [ ] **Step 5: Final sanity check git status**

```bash
git status
```

Expected: clean working tree (or only untracked files unrelated to redesign — e.g., wrangler.toml, package-lock.json which are gitignored / not committed yet).

- [ ] **Step 6: Done**

The redesign is complete. Burak's pending user-actions remain (Task 18 push branch + enable GitHub Pages, Task 29 solo dry-run).

---

## Out of plan scope (user actions still pending — NOT in this plan)

- **Task 18** from parent workshop plan: push branch + enable GitHub Pages — so the cheat sheet QR code resolves
- **Task 29** from parent workshop plan: solo 30-min dry-run with timer
- (Optional) Burak's Q8 + Q11 demo tests through the live bot
