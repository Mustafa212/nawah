# Step 4 — Research

Contents: Dispatch · The four topics · Rerun · Merge · research.md format

## Dispatch
Send four `nawah:researcher` agents in parallel (one message, four Agent calls), one per topic below.
Each brief:

```
Topic: <topic id>
Target market: <Market from state.md>    Currency: <Currency>    Date: <today>
<brief>
<the full brief.md>
</brief>
```

## The four topics
1. **market**: size of the market for this problem in the target market and globally, its growth,
   trends; inputs for TAM/SAM/SOM top-down (industry reports, official statistics) and bottom-up
   (number of potential customers × price). Also the currency's USD exchange rate from a central bank
   or another reputable source, when the currency isn't USD.
2. **local-competitors**: products and substitutes serving this problem in the target market: link,
   offer, price, target customer, strengths, weaknesses, customer sentiment (reviews, app-store
   ratings, posts) with links.
3. **global-competitors**: the leading global players, the same fields, and whether they serve the
   target market.
4. **pricing-regulation**: prices and pricing models in this category (target market first),
   willingness-to-pay signals, CAC and churn benchmarks for the category, developer monthly cost in
   the target market (only when the team's cost is unknown), and legal constraints in the target
   market: data protection, licensing, payments, sector rules.

## Rerun
A researcher that fails, returns a malformed report, or has fewer than 3 findings: send it back once,
saying what's missing. Still thin: continue, record the gap in `research.md`, and give the report
sections that depend on it Low confidence.

## Merge
- Keep each finding as returned, grouped by topic.
- Number every source once, `[1]`, `[2]`…, across all topics. The report's `sources[].id` reuse
  these numbers.
- Duplicates (same claim, same source): keep one.
- Conflicting figures for the same thing: list them side by side under Conflicts with their
  sources, and say which one the report uses and why.
- Competitors from both competitor topics go in one table.

## research.md format

```
# Research — <idea title>
Date: <YYYY-MM-DD>    Target market: <…>

## Sources
| Id | Title | URL | Accessed |
|---|---|---|---|

## Market
| Claim | Value | Source | Confidence |
|---|---|---|---|

## Pricing and regulation
| Claim | Value | Source | Confidence |
|---|---|---|---|

## Competitors
| Name | URL | Scope | Offer | Price | Strengths | Weaknesses | Sentiment | Source |
|---|---|---|---|---|---|---|---|---|

## Conflicts
## Gaps
## Notes from the researchers
```

Source cells hold the ids, `[3]` or `[3, 7]`. Then `Step: 5`.
