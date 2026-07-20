# server.md and myserver.md

Two Moldovan refurbished-server retailers, covered by one package
(`stores.servermd`) since they sell the same kind of product and are always
compared together.

## server.md

<https://server.md> — refurbished rack/tower servers and parts.

- **Stock**: TBD — the scraper assumes listed products are orderable.
- **Prices**: listing shows `5 300,00 lei` format (space thousands separator,
  comma decimals). Discounted items have `.us-module-price-new` alongside the
  old price; otherwise `.us-module-price-actual`. Reputation: TBD.
- **Scraping** (working 2026-04): listing
  `https://server.md/server?limit=100&page=N` (N from 1), stop when a page has
  no `.product-layout` items. Requires a browser User-Agent
  (`getFileAsFirefox`). Tile: name/link in `.us-module-title a`; specs as
  label/value `<span>` pairs in `.us-category-attr-item`, Romanian labels
  (`Model procesor`, `Numărul de socluri`, `Numărul nuclee`,
  `Memorie RAM instalată`).

## myserver.md

<https://myserver.md> — refurbished servers, HP ProLiant and Dell PowerEdge.

- **Stock**: the embedded product JSON has a per-product `product_stock`
  integer — likely the actual stock count, but not verified against ground
  truth.
- **Prices**: `product_price` (lei, numeric) in the same JSON. Reputation: TBD.
- **Scraping** (working 2026-04): category pages
  (`https://myserver.md/categorie/<slug>`, e.g.
  `servere-hp-proliant-refurb-moldova`,
  `servere-dell-poweredge-refurb-moldova`) embed the full product list as
  JavaScript: `var products = [...];` — slice out the array and parse as JSON
  (`product_name`, `product_price`, `product_stock`,
  `product_specifications` — an HTML `<th>/<td>` table with Romanian labels —
  `product_slug`). Product URLs: `https://myserver.md/produs/<slug>`.
  Requires a browser User-Agent.

## Shared notes

- CPU names need normalization to match cpubenchmark.net — `normalizeCPU` in
  `package.d` carries store-specific fixups.

## Shipping / payment

TBD for both.

## History

- 2026-04: server purchase research, scored by PassMark-per-leu
  (`purchases/p_2026_04_11_server_local/`).

## Open questions

- Stock semantics of server.md listings; does myserver.md `product_stock`
  reflect real availability?
- Shipping and payment for both; myserver.md categories beyond the two
  hard-coded ones.
