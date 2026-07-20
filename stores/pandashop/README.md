# pandashop.md

<https://www.pandashop.md> — electronics and home appliances.

## Stock detection

TBD — not yet verified against ground truth.

## Prices

TBD. (The 2019 scraper never parsed prices.)

## Shipping

- Does not ship to the suburbs — usually a blocker, albeit not a hard one.

## Payment

TBD.

## Scraping notes

Scraper: `package.d` (2019 — may have rotted; re-verify selectors).

- Category listing (all items on one page):
  `https://www.pandashop.md/ru/catalog/<path>/default.aspx?sort_=ByView_Descending&all=1`
  where `<path>` is e.g. `appliances/home_appliances/freezing_chambers` —
  see `package.d:getCategory`.
- Russian locale under `/ru/`; ASP.NET site (`default.aspx`).
- Needed a `cookies/` directory for the cachedcurl cookie jar.

## History

- 2019-05: freezer research by dimensions (`purchases/p_2019_04_21_freezer/`).

## Open questions

- Everything above marked TBD; whether the 2019 selectors still work.
