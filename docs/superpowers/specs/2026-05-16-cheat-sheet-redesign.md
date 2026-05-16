# Cheat-Sheet Redesign — Implementation Spec

**Date:** 2026-05-16 (workshop: 2026-05-17)
**Owner:** Burak Can Polat
**Parent spec:** [text-to-sql-agent-workshop-design.md](./2026-05-16-text-to-sql-agent-workshop-design.md) (this spec narrows scope to the cheat-sheet artifact only)

---

## 1. Goal

Replace `speakers/burak-can-polat/presentation-cheat-sheet.html` from scratch with a single self-contained HTML document that serves **two simultaneous roles**:

1. **Live workshop deck** — projected on screen during Burak's 30-min talk, readable from the back of an İzmir conference room.
2. **Self-service reference** — published via GitHub Pages, opened on attendees' phones via QR code, used to copy every snippet they need.

The workshop format is now **build-from-scratch alongside the audience** — *no workflow imports*. The cheat sheet IS the workshop material. Every URL, every tool description, every `$fromAI` expression, every system-prompt line is visible and copyable. The current cheat sheet is being fully replaced (not edited).

---

## 2. Design system (locked: B — Terminal/Dark)

Burak picked Mockup B (`/tmp/cheat-mockup-B-terminal.html`) on 2026-05-16. This locks the visual system:

| Token | Value | Use |
|---|---|---|
| `--bg` | `#0A0E12` | Deep ink page background |
| `--bg-elev` | `#10151B` (~) | Cards, code blocks, elevated surfaces |
| `--text` | `#E6EDF3` (~) | Primary text |
| `--text-mute` | `#8B97A5` (~) | Secondary text, captions |
| `--accent` | `#A8E10C` | Primary CTA / terminal-green prompts, copy buttons, active nav, syntax tokens |
| `--accent-edge` | `#5EEBFF` | Secondary accent — used ONLY for "tool / edge" callouts in the architecture diagram |
| `--rule` | `rgba(255,255,255,0.08)` | Hairlines, dividers |
| **Primary font** | **JetBrains Mono** (400/500/600/700/800) | Headings, code, nav, badges |
| **Secondary font** | **Geist** (400/500/600/700) | Running prose (so paragraphs don't read like a terminal log) |
| **Background texture** | 32px grid + faint scanlines + green radial glow at top | Atmospheric depth |

Implementation reference: `/tmp/cheat-mockup-B-terminal.html` — reuse its CSS tokens, sticky topbar, copy-button JS, and SVG diagram aesthetic verbatim. Do NOT redesign these from scratch.

**Hard constraints (all sections):**
- Pure HTML + CSS. Vanilla JS only for click-to-copy (one small handler, "✓ copied" feedback).
- Google Fonts CDN only. No frameworks, no Tailwind, no external JS libs.
- Turkish characters must render perfectly — verified with `çğıöşüÇĞİÖŞÜ` string in a visible element.
- Every code block has an OBVIOUS copy button (not a tiny corner icon).
- Self-contained — opens via `file://` and works.
- Responsive — projector 1920×1080 AND phone 375px both look intentional. Sticky topbar collapses to hamburger on mobile.

---

## 3. Content structure (chronological build order)

The cheat sheet is read top-to-bottom in the same order Burak builds on screen. Section IDs are anchor targets for the sticky topbar nav.

### `#intro` — Hero / Title banner
- Title (TR): "Doğal Dilden SQL'e — n8n + Telegram + AI Agent"
- Subtitle: "30 dakikalık canlı workshop"
- Speaker line: "Burak Can Polat · 2026-05-17 · İzmir"
- 1-2 line value prop (TR): hint "sonunda kendi makinende çalışan bir bot olacak"
- Primary CTA: `Workshop'a Başla →` (anchor to `#what`)

### `#what` — "Bu Workshop Nedir?"
- 1-paragraph TR pitch: 30 dakika, canlı yapım, import yok, sonunda kendi botun.
- 3 info blocks:
  - **Sonunda elinde olacak:** Telegram'dan Türkçe SQL sorabilen, doğru cevap dönen kendi botun.
  - **Adımlar (yüksek seviye):** BotFather → n8n workflow → AI Agent + 2 araç → sistem promptu → test.
  - **Önkoşullar:** Telegram hesabı, n8n erişimi (self-hosted *veya* Cloud), OpenRouter API key.

### `#chinook` — "Chinook Veritabanı Nedir?"
- 1-paragraph TR explainer: dijital müzik mağazası örnek veritabanı, ~3500 parça, 2021-2025 sipariş geçmişi, standart SQL eğitim dataset'i, gerçekçi ama anlaşılır boyutta.
- Table list (11 tables): Artist, Album, Track, Genre, MediaType, Customer, Invoice, InvoiceLine, Employee, Playlist, PlaylistTrack — render as a compact 2-column grid with brief column-count hint per table.
- "Şema dosyası" link: `data/chinook-schema.mmd` (downloadable Mermaid source for those who want the full ERD).

### `#mimari` — Mimari Akış (inline SVG flow diagram)
- **Inline SVG** (NOT external Mermaid) showing the live request path:
  ```
  Telegram (kullanıcı)
      ↓ message
  n8n Telegram Trigger
      ↓ webhook
  AI Agent (Tools Agent)
      ↳ generate_and_test_sql (HTTP)  ──┐
      ↳ execute_sql (HTTP)             ──┴→ Cloudflare Worker → D1 (Chinook)
      ↳ Window Buffer Memory
      ↓ markdown response
  Telegram Send
      ↓ message
  Telegram (kullanıcı)
  ```
- Styled in Mockup B terminal aesthetic — sharp geometric lines, monospaced labels, `--accent` for the agent block, `--accent-edge` for the tool/edge callouts.

### `#worker` — "Cloudflare Worker arka planda ne yapıyor?"
- 1-paragraph TR explainer: neden bu mimari (n8n SQLite dosyasına direkt erişemez → sandbox API gerek), neden Cloudflare Worker + D1 (yönetilen SQLite, free tier, latency düşük).
- **Endpoint tablosu** (copyable URLs):
  | Endpoint | Ne yapar | Body | Dönüş |
  |---|---|---|---|
  | `POST /test` | SQL'i `LIMIT 5` ile sarar — güvenli önizleme | `{"sql": "..."}` | `{"rows": [...]}` veya `{"error": "..."}` |
  | `POST /execute` | SQL'i olduğu gibi çalıştırır | `{"sql": "..."}` | `{"rows": [...]}` veya `{"error": "..."}` |
- **Worker base URL** (copyable): `https://chinook-workshop.bitter-brook-7999.workers.dev`
- **Güvenlik notu** (TR): "Worker `src/security.ts` regex'i `INSERT/UPDATE/DELETE/DROP/ALTER/CREATE/REPLACE/ATTACH/DETACH/PRAGMA/VACUUM` kelimelerini engelliyor — sadece `SELECT` sorguları geçiyor. Salt-okunur garantisi prompt'a değil, Worker sınırına gömülü."
- **Health check** (copyable curl):
  ```bash
  curl -s -X POST -H "Content-Type: application/json" -H "User-Agent: curl/8.0.0" \
    -d '{"sql":"SELECT 1 AS health"}' \
    https://chinook-workshop.bitter-brook-7999.workers.dev/test
  ```

### `#checklist` — Uçuş Öncesi Kontroller
A 7-item visual checklist with terminal-green check icons. Each item links to where to fix it if not ready:
1. ☐ Telegram hesabın hazır (mobil veya web)
2. ☐ BotFather'dan yeni bot oluşturdun + token'ı kaydettin
3. ☐ n8n instance'a erişimin var (self-hosted veya Cloud — fark etmez)
4. ☐ OpenRouter hesabın var + bir API key oluşturdun
5. ☐ Worker `/test` endpoint sağlıklı (health check curl'ü 200 dönüyor)
6. ☐ Bu cheat sheet bir tarayıcı sekmesinde açık (kopyala-yapıştır için)
7. ☐ En az 30 dakika kesintisiz vaktin var

### Build Phase 1 — `#step-01` through `#step-06`

Each step is a card. Card structure:
- Step number badge (terminal-style "01", "02", ... in `--accent`)
- Title (TR)
- 1-2 sentence instruction (TR)
- 0-N copyable code blocks (each labeled in TR)
- "Beklenen sonuç" 1-line hint (TR)

**Steps:**
- **`#step-01`** — Telegram bot oluştur (BotFather): `/newbot` → token al → bot'a `/start` yaz (chat'i aç)
- **`#step-02`** — n8n credentials kur: Telegram Bot Token + OpenRouter API Key
- **`#step-03`** — Yeni workflow oluştur + Telegram Trigger node ekle (typeVersion 1.2, "On Message")
- **`#step-04`** — AI Agent node ekle (`@n8n/n8n-nodes-langchain.agent` typeVersion 3.1, "Tools Agent" mode). Prompt: `={{ $json.message.text }}`
- **`#step-05`** — OpenRouter Chat Model sub-node bağla. Default model (copyable): `anthropic/claude-haiku-4.5`
- **`#step-06`** — Window Buffer Memory sub-node bağla. Session key (copyable): `={{ $('Telegram Trigger').item.json.message.chat.id }}`

### Build Phase 2 — `#step-07` through `#step-11`

- **`#step-07`** — Tool 1: `generate_and_test_sql` (HTTP Request Tool — `n8n-nodes-base.httpRequestTool` v4.4, NOT the LangChain one)
  - Copyable: tool name (`generate_and_test_sql`)
  - Copyable: toolDescription (long form, exact text)
  - Copyable: method (POST), URL (`https://chinook-workshop.bitter-brook-7999.workers.dev/test`)
  - Copyable: body mode = `Using Fields Below`, parameter `name: sql`, value: `={{ $fromAI('sql', 'The SQL SELECT query to dry-run with LIMIT 5. SQLite syntax only.', 'string') }}`
  - Warning callout: "AI wand butonuna BASMA — kendi `parameters0_Value` ismini üretir. Manuel olarak `'sql'` yaz."

- **`#step-08`** — Tool 2: `execute_sql` (same node type, /execute endpoint)
  - Symmetrical structure to step 07 with /execute URL and the execute toolDescription/expression.

- **`#step-09`** — Sistem Promptu yapıştır
  - TR full text in a copyable `<pre>` block (38 lines, exact verbatim from `prompts/system-prompt-tr.md`)
  - EN version in a togglable expandable (`<details>`) below
  - Label: "AI Agent → Options → System Message alanına yapıştır"

- **`#step-10`** — Telegram Send node ekle
  - Copyable: chatId expression `={{ $('Telegram Trigger').item.json.message.chat.id }}`
  - Copyable: text expression `={{ $json.output }}`
  - Critical: `additionalFields.parse_mode: "Markdown"` (NOT MarkdownV2 — UI is a dropdown)
  - Critical: `additionalFields.appendAttribution: false`

- **`#step-11`** — Kaydet + Aktive et + `/start`
  - "Save" → "Active" toggle ON → Telegram'da bot'una `/start` yaz, "merhaba" tarzı bir cevap bekle.

### `#sorular` — Demo Soru Bankası (15 sorular)

Grouped sub-sections, each with copyable question cards. Each card has:
- Copyable TR question (click-to-copy button)
- Difficulty badge (Açılış / Trivial / Kolay / Orta / Zor / Wow / Trap)
- 1-line "Beklenen davranış" hint
- Wow + Trap cards have extra pedagogical annotation

**Sub-sections in order:**
- **🎯 Açılış (yeni!)** — Q0 SQL Önizleme
- **Trivial** — Q1
- **Kolay** — Q2, Q3, Q4
- **Orta** — Q5, Q6, Q7, Q8
- **Zor** — Q9, Q10, Q11
- **🚀 Wow** — Q12 (MoM growth)
- **🪤 Trap** — T1 (revenue per artist), T2 (this year)

### `#modeller` — OpenRouter Model Alternatifleri
- Embed the 8-row table from `/tmp/openrouter-models.md` (already produced by research subagent)
- Each model ID in a copyable code-pill
- TR picking guide (3-4 sentence paragraph)
- 1-line "Model değiştirme" instruction: "OpenRouter Chat Model node'da `Model` alanını yukarıdaki ID'lerden birine değiştir, workflow'u kaydet, yeni soru gönder."

### `#hata` — Hata Yakalandığında Ne Yapılır?
- Compact 4-row table:
  - "Bot tool çağırmıyor" → check `$fromAI` syntax + tool description net mi
  - "Worker 400 dönüyor" → SQL yasak kelime içeriyor (INSERT/UPDATE/...) veya syntax hatası
  - "Telegram 'Bad Request: can't parse entities'" → parse_mode `Markdown`'a düşür (MarkdownV2 değil)
  - "Bot Türkçe cevap vermiyor" → system prompt'un kopyalandığını + dil yönlendirmesinin son satırda olduğunu kontrol et
- Link: "Tam kılavuz → [`failure-recovery.md`](./failure-recovery.md)"

### `#sonra` — Workshop Sonrası
- "Code Tool ile aynı şeyi nasıl yaparsın?" → link to `bonus/dev-corner/README.md`
- "Bu workshop'u kendine adapte et" — repo URL + QR
- "İletişim" — Burak'ın LinkedIn / Twitter

### `#footer`
- Credits (Burak Can Polat · 2026-05-17 · n8n İzmir)
- License (MIT or inherit from repo)
- Updated timestamp (auto-set at build time, format `YYYY-MM-DD`)

---

## 4. File changes

### Modified
| File | Change |
|---|---|
| `speakers/burak-can-polat/presentation-cheat-sheet.html` | **Fully replaced** with the new structure above (~2000+ lines) |
| `speakers/burak-can-polat/data/demo-questions.md` | Add Q0 SQL-preview question at top (see §5 below) |
| `speakers/burak-can-polat/CLAUDE.md` | Remove `workflows/text-to-sql-agent.json` line; remove `WORKER_URL_HERE` replacement block (now baked); update "Files" list |
| `speakers/burak-can-polat/README.md` | Remove "skeleton import" instructions; update to "build from scratch" framing |

### Deleted
| File | Reason |
|---|---|
| `speakers/burak-can-polat/workflows/text-to-sql-agent.json` | Workshop is now build-from-scratch, no imports |
| `speakers/burak-can-polat/workflows/inject-credentials.sh` | Only existed to inject creds into the deleted skeleton |

### Stays as-is (referenced from cheat sheet, not modified)
- `workflows/text-to-sql-agent-finished.json` — recovery reference only, helper grabs it if someone falls behind
- `prompts/system-prompt-tr.md` + `prompts/system-prompt-en.md` — source of truth, embedded in `#step-09`
- `data/chinook-schema.mmd` — Mermaid ERD, linked from `#chinook` for those who want the full schema
- `failure-recovery.md` — linked from `#hata`
- `bonus/dev-corner/README.md` — linked from `#sonra`
- `cloudflare-worker/` — referenced but unchanged

---

## 5. New demo question: Q0 SQL Önizleme

To add to `speakers/burak-can-polat/data/demo-questions.md` at the very top (before the current "Wow question" section):

```markdown
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

**Pedagojik değer:** Audience bot'un altında ne ürettiğini görür (şeffaflık) + araç çağırmadan da SQL üretebildiğini fark eder. T1 trap'inden önce gelir — "bot ne yapıyor altında?" sorusunu cevaplar.
```

---

## 6. Out of scope

- n8n UI screenshots — would help but not feasible to capture cleanly before tomorrow morning; the cheat sheet uses text descriptions + the inline SVG architecture diagram
- Animated demo videos
- Multi-language toggle for the whole page (TR is primary throughout; EN system prompt is the only EN content, expandable)
- Automated deploy to GitHub Pages — that's Burak's existing manual Task 18
- Per-step thumbnail screenshots of the n8n canvas
- Workflow JSON changes (the finished workflow is already correct)
- System prompt changes — current TR prompt is left as-is even though Q0 partially tests "do you obey user override over system instruction?" — that's a deliberate test, not a prompt bug

---

## 7. Open questions

- **Q0 wording** — current spec uses `"Top 5 sanatçı için SQL sorgusu yaz, sadece SQL'i göster, ÇALIŞTIRMA."` Burak may want to adjust phrasing (e.g., add "lütfen" or "şu sorgu için").
- **Q0 placement** — current spec puts it BEFORE Q1 as the demo arc opener. Alternative: put it between Q1 and T1 to demonstrate transparency right before the traps. Default: opener.

Decision deadline: before spec approval. Will adopt Burak's preference inline.

---

## 8. Acceptance criteria

The redesign is "done" when:

- [ ] `presentation-cheat-sheet.html` opens cleanly in Chrome/Firefox/Safari via `file://`
- [ ] All Turkish characters render correctly (`çğıöşüÇĞİÖŞÜ` visible somewhere)
- [ ] Every code block has a working "Kopyala" → "✓ Kopyalandı" interaction
- [ ] Sticky topbar nav jumps to each major section smoothly
- [ ] Page is usable on 375px viewport without horizontal scroll (cards stack, nav collapses)
- [ ] All 15 demo questions (Q0 + Q1-12 + T1-T2) are present in copyable cards
- [ ] All 11 build steps are present in chronological order with all required snippets
- [ ] TR system prompt is embedded in full (38 lines, copyable in one click)
- [ ] EN system prompt is accessible via expandable toggle
- [ ] OpenRouter model table is present with all 8 models, IDs in copyable code-pills
- [ ] Architecture SVG diagram renders without external dependencies
- [ ] Worker base URL appears as copyable code in `#worker` section
- [ ] Skeleton workflow JSON file is deleted from repo
- [ ] `CLAUDE.md` + `README.md` no longer reference the skeleton
- [ ] Total file size < 500KB (sanity check on inline content)

---

**Spec status:** Draft 1 — ready for Burak's review. Next: spec approval → writing-plans → execution.
