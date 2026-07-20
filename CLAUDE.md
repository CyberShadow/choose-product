# choose-product

Tools and knowledge for online-shopping research: given a purchase with
several (occasionally conflicting) requirements, find the relevant stores,
then filter and score the available products to pick the best one.

## Layout

- `stores/<name>/` — one directory per store or data source:
  - `package.d` — access layer (`module stores.<name>;`): fetch, parse into
    `Product` structs.
  - `README.md` — knowledge about the store: stock-detection recipe, pricing
    reputation, shipping/payment restrictions, scraping quirks.
  - Either file may be absent. See `stores/README.md` for the index, the
    leads list of uninvestigated Moldovan retailers, and `stores/TEMPLATE.md`.
- `sources/<name>/` — same shape as `stores/`, but for informational sites
  used for scoring/specs rather than buying (cpubenchmark.net PassMark
  scores, sammobile.com spec DB). Rule of thumb: if you can check out there,
  it's a store.
- `lib/` — code shared between packages (`module lib.<name>;`), e.g.
  `lib/net.d:getFileAsFirefox`. Only genuinely shared code goes here — a
  helper migrates from a package when a second user appears, not before.
- `purchases/p_YYYY_MM_DD_<topic>/` — one directory per purchase/research
  task, kept forever as history:
  - `choose.d` — the task program: hard filters, then scoring, then a printed
    ranking. Imports store packages (`import stores.maximum;`).
  - Inputs (`urls.txt`), outputs (`results.org`, saved run output), and the
    purchase's own HTTP `cache/` — the cache doubles as the dated data
    snapshot for that purchase, so old sessions stay re-runnable.
  - `README.md` where the program doesn't tell the whole story.

## Tech and building

- Language: D. Libraries: ae (`~/work/ae`) and arsd (`~/work/extern/arsd`),
  used straight from checkouts — no dub.
- Build and run from inside the purchase directory, so relative paths
  (`cache/`, `cookies/`, `urls.txt`) resolve there:

      cd purchases/p_.../ && rdmd -I../.. -I~/work -I~/work/extern choose.d

- HTTP: `ae.sys.net.cachedcurl` — every response is cached in `./cache/`
  indefinitely, making iterative re-runs free. Delete `cache/` to refresh.
  Some sites need a browser User-Agent (`getFileAsFirefox` in
  `stores/servermd/package.d`).
- HTML parsing: `arsd.dom` and `querySelector`. When data is embedded as JSON
  in a `<script>` (e.g. myserver.md), slice it out and use `ae.utils.json`.

## Shopping-session flow

1. Search the web for the product; for local shopping add "chisinau",
   "moldova", or `site:.md` (or equivalent) to the query.
2. Note which stores appear in the listings.
3. For known stores, read `stores/<name>/README.md` first — especially how to
   determine stock reliably, and any pricing reputation for the category.
4. Where it pays off, use or write a `choose.d` (see below), implementing
   `stores/` packages for any missing sites.
5. Present findings: compare total outcomes (price + shipping + payment
   constraints + risk), not sticker prices.
6. When the user corrects a fact about a site, record it in that store's
   README (and/or fix its package). New durable knowledge from any session —
   quirks, verified recipes, purchase outcomes — goes there too.

## Approach: score, don't browse

The working pattern inside a `choose.d`:

1. Extend the store package until it yields clean `Product` data.
2. Hard filters first, each rejection printed with its reason (see `nope()`
   in `purchases/p_2017_12_18_laptop_battery/choose.d`); then a numeric score
   combining the desiderata (weighted terms:
   `purchases/p_2026_02_19_server_h2/choose.d`; value-per-price:
   `purchases/p_2026_04_11_server_local/choose.d`); print a ranked table.
3. Iterate on filters and weights while re-running — cheap thanks to the
   cache.

Cross-store comparisons put multiple sources behind one `Product[]`
(`stores/servermd` merges server.md and myserver.md); external scoring data
gets its own source directory (`sources/cpubenchmark` maps CPU names to
PassMark scores — note the name-normalization pain in
`stores/servermd/package.d:normalizeCPU`).

## Scraping lessons

- **Verify stock and price signals against ground truth before trusting
  them.** Raw HTML routinely contains invisible elements: "notify me when
  available" modals present on *every* product page, commented-out price
  blocks, `display:none` buttons. What a text search finds is not what the
  user sees. When in doubt, compare several product pages known to differ in
  stock, or try an actual add-to-cart. (Case study:
  `stores/prime_pc/README.md`.)
- Prices may live only in attributes (`data-price` on prime-pc.md) and be
  rendered client-side; the element's text can be empty.
