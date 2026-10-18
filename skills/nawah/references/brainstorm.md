# Step 3 — Brainstorm and the Idea Brief

Goal: an idea the user recognises as theirs, sharp enough to research. Nothing is researched before
Gate 1.

## How to ask
- Ask in rounds. A round holds every question you can ask now, the ones whose answer doesn't hang
  on another question still open; a question that does waits for a later round. Number them, give
  each your recommended answer on its own `➡️` line, and word it so "yes" accepts that answer. Ask
  an open question, with no recommendation, when one would put words in the user's mouth. The
  user answers by number; work out the next round from those answers.
- Start from what the request already says; never ask what it answers.
- Existing-project mode: start from `snapshot.md`: which current users the idea serves, what it
  changes, what it must not break.
- A question about how something should look or feel can't be settled by talking. Once the MVP
  scope it shows is settled, make a quick throwaway HTML mockup in the idea's folder
  (`mockup-<n>.html`), give its path, and ask about it in one line.
- Stop when every brief section below, and every question its answers opened, has an answer the
  user gave or confirmed.

## What to find out
1. **Customer and problem:** who has the problem, how often, how they cope today. The current
   alternative is the real competitor: spreadsheets, WhatsApp groups, an agency, doing nothing.
2. **Job to be done:** "When <situation>, I want to <motivation>, so I can <outcome>."
3. **Beachhead:** one first segment, small enough to win and big enough to matter.
4. **Solution and MVP scope:** the smallest thing that does the job for the beachhead, and what is
   explicitly out.
5. **Why now:** what changed (technology, regulation, behaviour, cost) that makes it possible or
   urgent.
6. **Riskiest assumptions:** the beliefs that would kill the idea if false, ranked; each typed as
   desirability (do they want it), viability (will they pay enough), or feasibility (can it be built).
7. **Success metric:** one number with a target and a date.

## Angles
Before the brief, offer 2–3 angles that differ in one real dimension (segment, business model or
scope), each in 2–3 lines with its trade-off, your recommendation first. The user picks or merges.

## brief.md
Written in the report's language, formal register, one page:

```
# Idea Brief — <title>
Date: <YYYY-MM-DD>    Mode: <new | existing: <project>>    Audience: <audience>

**One-liner:** For <customer> who <problem>, <product> is a <category> that <key benefit>; unlike <current alternative>, it <difference>.

## Problem
## Customer segments and beachhead
## Jobs to be done
## Current alternatives
## Solution
## MVP scope
In: <items, separated by semicolons>
Out: <items>
## Why now
## Riskiest assumptions (ranked)
| # | Assumption | Type | Why it's risky |
## Success metric
## Fit with the existing project      (existing mode only)
```

## Gate 1
Show the brief in full and ask: "Approve this brief, or tell me what to change." On approval: `Gates:
brief <date>`, `Step: 4`. Later steps may not widen the MVP scope without asking.

If the conversation shows the idea isn't worth pursuing (no real problem, nobody who would pay, a
dominant free alternative), say so with the reason and offer to stop. The user decides.
