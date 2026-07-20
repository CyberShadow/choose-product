# stores/

One directory per store or data source. Contents per directory:

- `package.d` — D access layer (`module stores.<name>;`): fetch pages, parse
  them into `Product` structs. Import from a purchase program as
  `import stores.<name>;`.
- `README.md` — knowledge about the store: stock-detection recipe, pricing
  reputation, shipping/payment restrictions, scraping quirks. Start new ones
  from `TEMPLATE.md`. Date findings (`(2026-07)`) — sites change, and a dated
  wrong note is easier to distrust than an undated one.

Either file may be absent: a store investigated by hand has only a README
(e.g. `prime_pc/`); a store that has never needed prose has only code.
Directory names are D-identifier-safe (underscores, no dashes).

Only places money is spent live here; informational sites used for
scoring/specs live in `../sources/` with the same conventions.

## Index

| Directory | Site | Sells | Notes |
|-----------|------|-------|-------|
| `prime_pc/` | prime-pc.md | PC hardware, laptops | docs only; stock + price parsing verified (2026-07) |
| `maximum/` | maximum.md | electronics, appliances | scraper from 2019 |
| `pandashop/` | pandashop.md | electronics, appliances | scraper from 2019 |
| `servermd/` | server.md + myserver.md | refurbished servers | one package for both (2026-04) |
| `amazon/` | amazon.com | everything | search + product scraper (2017); CAPTCHA backoff |
| `aliexpress/` | aliexpress.com | everything | search scraper, WIP (2017) |
| `lenovo/` | lenovo.com | laptops | catalog scraper (2017) |
| `hetzner/` | hetzner.com | server auction | JSON endpoint `live_data_sb_EUR.json` |

## Moldovan retailers — leads not yet investigated

Known or reputed Moldovan electronics/hardware retailers, from memory and
hearsay; **unverified** — confirm a store exists and is relevant before
relying on this list, and promote to a directory once investigated:

- darwin.md — large electronics chain
- enter.online — large electronics chain
- smart.md
- ultra.md — PC components
- bomba.md
- foxmart.md
- xstore.md
