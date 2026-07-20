# maximum.md

<https://maximum.md> — big-box electronics and home-appliance chain.

## Stock detection

TBD — not yet verified against ground truth.

## Prices

- When a product is discounted, the displayed "original price" is often
  entirely fictional — never an actual price point. Don't treat discount
  size as meaningful; compare the final price against other stores.
- Otherwise TBD. (The 2019 scraper never parsed prices.)

## Shipping

TBD.

## Payment

TBD.

## Scraping notes

Scraper: `package.d` (2019 — may have rotted; re-verify selectors).

- Product URLs: `https://maximum.md/ro/<id>/` (Romanian locale).
- Title: `.product-view__title`.
- Properties: `.product-view-description` alternates bare text nodes
  (property name, `▪`-prefixed) with `<b>` elements (value) —
  see `package.d:getProduct`.
- Input in the 2019 purchase: `urls.txt`, product URLs one per line, id = last path
  segment.

## History

- 2019-04: microwave research (`purchases/p_2019_04_21_microwave/`, results in
  its `results.org`).

## Open questions

- Everything above marked TBD; whether the 2019 selectors still work.
