# Backlog — broken on purpose
Report version: 1    Total points: 0    Duration: -
Reference: S1.1.1 = 3 points

## Traceability
| Brief MVP item | Stories |
|---|---|
| Sign-up | S1.1.1, S7.7.7 |

## E1 — Onboarding
Goal: Shops join.
Success metric: 30 shops.
Release: MVP
Parent: none

### F1.1 — Sign-up
Description: Sign-up.
Release: MVP

#### S1.1.1 — Sign up
Story: As a shop owner, I want to sign up, so that I can stamp visits.
Value: Onboarding.
Priority: Must
Release: MVP
Points: 3
Depends on: none
Acceptance criteria:
1. Given a valid number When the owner requests a code Then a code arrives within 60 seconds
2. Given a wrong code 3 times When the owner tries again Then sign-up is blocked for 15 minutes
Out of scope: none
NFR: none
Open questions: none

#### S1.1.2 — Print the code
Story: As a shop owner, I want to print my code, so that customers can scan it.
Value: Stamps.
Priority: Must
Release: MVP
Points: 13
Depends on: S1.1.1
Acceptance criteria:
1. The code prints nicely
2. Given a printed code When it is scanned Then the shop's name shows
3. Given a stolen code When a new one is made Then the old one stops working within 1 minute
Out of scope: none
NFR: none
Open questions: none

### F1.2 — Stamping
Description: Stamps.
Release: MVP

#### S1.2.1 — Stamp a visit
Story: As a customer, I want to scan the code, so that my visit counts.
Value: Core loop.
Priority: Must
Release: MVP
Points: 5
Depends on: S9.9.9, S2.1.1
Acceptance criteria:
1. Given a member shop When the customer scans Then a stamp is added within 2 seconds
2. Given a scan less than 4 hours ago When the customer scans again Then no stamp is added
3. Given no connection When the customer scans Then the stamp is queued
Out of scope: none
NFR: none
Open questions: none

#### S1.2.1 — Stamp a visit again
Story: As a customer, I want to scan the code again, so that my second visit counts.
Value: Repeat visits.
Priority: Should
Release: MVP
Points: 2
Depends on: none
Acceptance criteria:
1. Given a scan 5 hours ago When the customer scans Then a second stamp is added
2. Given 2 stamps today When the customer scans again Then no stamp is added
3. Given a closed shop When the customer scans Then "shop closed" shows
Out of scope: none
NFR: none
Open questions: none

## E2 — Rewards
Goal: Rewards.
Success metric: 20 % redeem.
Release: v2
Parent: none

### F2.1 — Wallet
Description: Points.
Release: v2

#### S2.1.1 — See points
Story: As a customer, I want to see my points, so that I know where I'm close.
Value: Progress.
Priority: Must
Release: v2
Points: 5
Depends on: S2.1.2
Acceptance criteria:
1. Given stamps at 2 shops When the wallet opens Then both shops show
2. Given 1 stamp to go When the wallet opens Then that shop is first
3. Given no stamps When the wallet opens Then the 5 nearest shops show
Out of scope: none
NFR: none
Open questions: none

#### S2.1.2 — Points history
Story: Show the history of points.
Value: Trust.
Priority: Should
Release: MVP
Points: 3
Depends on: S2.1.1
Acceptance criteria:
1. Given a customer When they open the history Then their last 50 stamps show
2. Given no stamps When the history opens Then it says "no stamps yet"
3. Given a stamp removed by a shop When the history opens Then it shows as removed
Out of scope: none
Open questions: none

#### S3.1.1 — Misplaced story
Story: As a customer, I want something, so that it works.
Value: None.
Priority: Could
Release: v2
Points: 1
Depends on: none
Acceptance criteria:
1. Given a when When a then Then it passes
2. Given a when When a then Then it passes
3. Given a when When a then Then it passes
Out of scope: none
NFR: none
Open questions: none
