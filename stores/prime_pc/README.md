# prime-pc.md

<https://prime-pc.md> — PC hardware, laptops, monitors, networking gear.
Site served in Russian; custom shop engine (theme "MegaPrime"). Scrapes fine
without JS using a browser User-Agent (verified 2026-07-20).

## Stock detection

The reliable static signal (verified 2026-07-20) is a colored dot on the
product page:

    <span style="… background-color: #4CB200; …" title="много"
          class="own_stock_tooltip">&nbsp;</span>

Read the `title` attribute of `span.own_stock_tooltip`. Observed values:

| `title`      | dot color         | meaning        |
|--------------|-------------------|----------------|
| `много`      | green (`#4CB200`) | many in stock  |
| `очень мало` | red (`#E51900`)   | very few left  |

Presumably an intermediate "мало" level exists; not yet observed. Whether a
distinct out-of-stock state exists on product pages, or such products are
simply delisted, is unknown (see Open questions).

**Traps — do NOT infer stock from these:**

- Every product page contains a *hidden* modal `#check_availability` with the
  text «Как только запрашиваемый товар появится на нашем складе, мы вам
  сообщим» ("we'll notify you when it arrives at our warehouse"). It is
  present regardless of stock status. Incident 2026-07: a session concluded
  from this text that a ThinkPad E14 Gen7 was out of stock; it was in fact
  in stock (green «много» dot, add-to-cart worked).
- The buy-button block `.product_button_group` is identical on high-stock and
  low-stock products (`<button class="in_cart btn_blue add_to_cart"
  style="display:inline-block;">в корзину</button>` — note the `.in_cart` CSS
  class is `display:none` by default and overridden inline). Not a stock
  differentiator, at least among sampled in-stock pages.

## Prices

The price element's text is *empty*; the value lives in an attribute and is
rendered client-side:

    <div class="productPrice"> <span>Цена:</span> <b data-price='29811'></b><span>Lei</span></div>

Read `div.productPrice b[data-price]`. Directly after it, a
`div.enterprisePrice` block («Цена для юр. лиц», same figure) is **commented
out** in the served HTML — visible to text searches, not to users. Don't
mistake it for "only a business price is shown".

Pricing reputation: TBD.

## Shipping

TBD.

## Payment

TBD.

## Scraping notes

- Product URLs: `https://prime-pc.md/products/<slug>`.
- The homepage embeds links to a very large number of products (~800 KB of
  HTML) — possibly useful as a crude catalog listing.
- Internal product ID: `input.add_to_cart_number[data-product_id]` on the
  product page.
- Plain `curl` with a Firefox User-Agent works; no bot wall encountered
  (2026-07-20).

## History

- 2026-07: ThinkPad E14 Gen7 21U20034GX (Ultra 7 256V / 32 GB / 1 TB) listed
  at 29 811 lei, in stock («много»); user added it to cart successfully.

## Open questions

- What does the stock dot look like for an out-of-stock product — distinct
  title/color, or is the product delisted? Find a known out-of-stock item
  and record it.
- Is there an intermediate «мало» level?
- Do listing/category pages carry the stock dot, or product pages only?
- Shipping and payment options.
