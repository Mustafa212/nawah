# Step 5 — The report

Contents: Build the page · Writing · Sections · Confidence · By audience · Existing-project mode · The data block · Bindings · Financial model · Go-to-market levers · Duration · Check, review and Gate 2

## Build the page
1. Copy `${CLAUDE_PLUGIN_ROOT}/skills/nawah/assets/report-template.html` to
   `ideas/<slug>/report.html`.
2. Replace the JSON inside `<script type="application/json" id="nawah-data">` with this idea's data
   block (below). Inside JSON strings write `<\/` instead of `</`.
3. Replace every `<!-- SLOT <id> -->` with that section's content in HTML: `<p>`, `<ul>`, `<ol>`,
   `<table>` with `<thead>`, `<h3>`, `<div class="callout">`. Leave the template's headings, charts
   and appendix tables alone; they fill themselves.
4. Set each section's `<span class="confidence" data-level="">` to `High`, `Medium` or `Low`.
5. Figures: a number the model computes appears only as a binding, `<span data-k="base.revenueY3"></span>`;
   a number from research is written out with its citation, `41 % of cafés<sup data-src="4"></sup>`
   (several: `data-src="4,7"`). Never type a computed figure.
6. Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/report.sh" check "<idea folder>/report.html"`. Fix every
   error it lists and run it again until it prints `ok`.

## Writing
- The report language from `state.md`, formal register: complete sentences, no chat tone, no emoji,
  no exclamation marks. Arabic: Modern Standard Arabic. Terms such as MVP or API may stay in English.
- Neutral voice, or "we" for the team behind the idea; never "I".
- Open each section with its conclusion in one or two sentences, then the evidence.
- Every claim from research carries its citation. A figure you derived is an Estimate: put it in the
  data block, and its basis in `assumptionNotes` without a source.
- Name what is uncertain. Low confidence is better than false precision.

## Sections
| Id | Content | Method |
|---|---|---|
| `exec-summary` | The idea in one sentence; the recommendation (`meta.recommendation`) with its two or three reasons; market, revenue in year 3, break-even, duration and build cost (bindings); the top three risks; for "Go with conditions", the conditions. One page. | — |
| `problem-customer` | The problem and how often it occurs; segments and the beachhead; the job to be done; pains and gains; current alternatives. | JTBD, Value Proposition Canvas |
| `solution-value` | What is built; MVP, v1 and v2 scope; how it does the job better than the alternatives; why now. | — |
| `market` | Target market first, then global: TAM, SAM, SOM with how each was derived (top-down and bottom-up) and their sources; growth and trends. | TAM/SAM/SOM |
| `competition` | A table of local competitors and one of global competitors (offer, price, strengths, weaknesses, customer sentiment); substitutes; the white space; the positioning statement; why the chart's two axes matter to buyers. | April Dunford positioning |
| `financials` | Revenue model options and the one recommended; pricing anchored to competitors' prices; unit economics; the three scenarios and what drives them; build and running costs; break-even. Management audience: ROI and payback. | Financial model below |
| `go-to-market` | The beachhead first; channels with their cost; a 90-day launch plan; the one-liner and an elevator pitch; the message per segment; the behavioural levers used and why. | Levers below |
| `delivery` | MVP, v1, v2 and what each contains; duration and team; assumptions behind the estimate; what would make it faster or slower. | Duration below |
| `validation` | The riskiest assumptions from the brief, ranked, and how to test each before building heavily: an interview script (5–8 open questions about past behaviour, never "would you buy"), a landing-page smoke test with a target conversion rate, the four price questions (too cheap, cheap, expensive, too expensive), success metrics and kill criteria. | Mom Test, Van Westendorp |
| `risks` | A table: risk, likelihood, impact, mitigation; market, technical, legal (data protection and sector rules of the target market), financial. Existing-project mode adds the risk to the current system and users. | — |
| `closing` | By audience (below). | — |
| `appendix` | Methodology in a few sentences: how research was done, what the model assumes, what wasn't verified. The assumptions table and source list follow automatically. | — |

## Confidence
**High:** primary sources, recent and consistent. **Medium:** secondary sources or partial data.
**Low:** one weak source, mostly Estimates, or a research gap.

## By audience
- **investor:** market and financials carry the weight; `closing` is The Ask: the amount, its use
  in percentages, and the milestones it reaches.
- **management:** ROI (`base.roi`), cost, strategic fit and the effect on current operations;
  `closing` compares building, buying and partnering, and states the decision requested.
- **client:** their benefit, scope, timeline and cost; `closing` is the proposal: what is delivered,
  when, for how much, and the next step.

## Existing-project mode
From `snapshot.md`: `solution-value` adds the current state, what changes, and the effect on current
users; `risks` adds the risk to the existing system; `delivery` names the modules touched.

## The data block
The template's own block is a complete example. Fields:

| Field | Meaning |
|---|---|
| `meta.title`, `meta.oneLiner` | From the brief. |
| `meta.lang` | `en` or `ar` (`Language` in state.md). |
| `meta.audience` | `investor`, `management` or `client`. |
| `meta.recommendation` | `Go`, `Go with conditions` or `No-Go`. |
| `meta.currency` | ISO code. When it isn't USD: `meta.usdRate` (USD per one unit) and `meta.usdRateSource` (source id). |
| `meta.date`, `meta.version`, `meta.preparedBy` | Today; 1, then +1 for every revised version shown; `Prepared by` from state.md. |
| `market.tam`, `market.sam`, `market.som`, `market.sources` | Yearly, in the currency, tam ≥ sam ≥ som; source ids. |
| `assumptions` | Base case: `arpu` (monthly revenue per customer), `grossMargin` (0–1), `churn` (monthly, 0–1), `cac`, `newCustomersMonth1`, `monthlyGrowth` (of new customers per month; 0.08 is 8 %), `fixedMonthlyCost`. |
| `scenarios.conservative`, `.base`, `.optimistic` | Overrides of `assumptions`; `base` is usually `{}`. |
| `team.developers`, `team.monthlyCost`, `team.velocity` | From intake. `velocity` only when the team has a real one: `[low, high]` points per two-week sprint for the whole team. |
| `capabilities` | `{name, release, size}`: one per capability in the brief's scope; release `MVP`, `v1` or `v2`; size `S`, `M` or `L` (an XL is split). |
| `backlog.pointsByRelease` | Only from step 6. |
| `competitors` | `{name, url, scope, x, y}`: scope `local` or `global`; x and y from 0 to 10 on the positioning axes. |
| `positioning` | `{x: "<axis label>", y: "<axis label>", us: {x, y}}`: the two dimensions buyers choose on, from research. |
| `assumptionNotes` | `{key, note, source}` per assumption shown in the appendix; no `source` means Estimate. `key` is an assumption name, `team.monthlyCost` or `team.developers`; a free row is `{label, value, note, source}`. |
| `sources` | `{id, title, url, accessed}` with the ids of `research.md`. |

## Bindings
| Key | Value |
|---|---|
| `tam`, `sam`, `som` | Market sizes. |
| `arpu`, `cac`, `ltv`, `ltvToCac`, `paybackMonths` | Unit economics, base case. `ltv` is "—" when churn is 0. |
| `<s>.revenueY<n>`, `<s>.netY<n>` | Revenue and net result in year n (1–3) of scenario s (`conservative`, `base`, `optimistic`). |
| `<s>.breakEvenMonth`, `<s>.roi` | Break-even month (or "not within 36 months") and 3-year ROI of scenario s. |
| `durationWeeks`, `weeks.<r>` | Duration in weeks, total and per release r present (`MVP`, `v1`, `v2`). |
| `buildCost` | Build cost range. |
| `sizedWeeks` | The duration from the report-time sizing (equal to `durationWeeks` before step 6). |
| `drift`, `backlogPoints` | After step 6 only: the change between sizing and backlog, and the backlog's points. |

Every money key also exists as `<key>.usd` when the currency isn't USD (for example
`base.revenueY3.usd`, `buildCost.usd`).

## Financial model
What the template computes, so the narrative can explain it:
- LTV = ARPU × gross margin ÷ churn; LTV:CAC; payback months = CAC ÷ (ARPU × gross margin).
- Each month: new customers = month-1 new customers × (1 + growth)^(month − 1); customers = last
  month's × (1 − churn) + new; revenue = customers × ARPU; costs = fixed + new × CAC + revenue ×
  (1 − gross margin).
- Cumulative net starts at minus the build cost's midpoint; break-even is the first month it reaches
  zero.
- 3-year ROI = (revenue − costs − build cost) ÷ (costs + build cost).
- Build cost = team monthly cost × duration (weeks ÷ 4.33).

## Go-to-market levers
Each lever is tied to a concrete product or marketing decision with the reason it fits this segment:
social proof (visible numbers of shops or users), anchoring (the competitor's price beside ours), loss
aversion (what customers lose by leaving), risk reversal (a free first month, cancel anytime),
friction (Fogg B=MAP: make the first action tiny and prompt it at the right moment). Never propose
dark patterns: fake scarcity, fake reviews, hidden costs, hard-to-cancel subscriptions.

## Duration
Size each capability: S = 1–2, M = 2–4, L = 4–8 ideal developer-weeks; split anything bigger. The
model turns sizes into weeks per release with a 0.6–0.8 focus factor and 15–25 % for design, QA
hardening and release. Step 6 replaces this with the backlog's points.

## Check, review and Gate 2
1. `report.sh check` prints `ok`.
2. `bash "${CLAUDE_PLUGIN_ROOT}/scripts/report.sh" values "<report.html>"` prints the computed values;
   use them for the summary below.
3. Unless `NAWAH_NO_OPEN` is set, open the page: Windows `start "" "<path>"`, macOS `open "<path>"`,
   Linux `xdg-open "<path>"`.
4. In chat: the recommendation; the six headline figures (year-3 revenue, break-even, LTV:CAC,
   payback, duration, build cost); the sections with Low confidence; the Estimates the user could
   replace with real figures, and what each would change.
5. Ask: "Approve report version <n>, or tell me what to change."
6. Changes: edit, raise `meta.version` by one, check, reopen, ask again.
7. Approved: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/report.sh" pdf "<report.html>" "<idea folder>/report-v<n>.pdf"`.
   Exit 2 (no browser): tell the user to open `report.html`, print it to PDF (A4, no headers and
   footers, background graphics on) and save it as `report-v<n>.pdf` in the idea folder. Then
   `Gates: … report v<n> <date>`, `Step: 6`.
8. A shareable link (Artifact) only when the user asks for one.
