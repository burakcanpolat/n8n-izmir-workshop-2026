# Text-to-SQL Agent — n8n İzmir 2026
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
| [`data/demo-questions.md`](data/demo-questions.md) | 12 örnek soru + referans SQL |
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

Full design and implementation specs in
[`docs/superpowers/`](../../docs/superpowers/) at the repo root.
