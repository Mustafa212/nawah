# Backlog — Qahwa Points
Report version: 2    Total points: 15    Duration: 2 – 4 weeks
Reference: S1.1.1 = 3 points
Stories for: mvp

## Traceability
| Brief MVP item | Stories |
|---|---|
| Shop sign-up | S1.1.1 |
| QR stamps at the counter | S1.1.2, S1.2.1 |
| Customer points and rewards | S2.1.1 |

## E1 — Shop onboarding and stamping
Goal: A shop joins and stamps its first visit in under ten minutes.
Success metric: 30 shops stamping at least 100 visits a week by the end of month 3.
Release: MVP
Parent: none

### F1.1 — Shop sign-up
Description: A shop owner creates an account and the shop's profile.
Release: MVP

#### S1.1.1 — Sign up a shop with a phone number
Story: As a shop owner, I want to sign up with my phone number, so that I can start stamping visits the same day.
Value: Removes the largest onboarding drop-off: owners without an e-mail address.
Priority: Must
Release: MVP
Points: 3
Depends on: none
Acceptance criteria:
1. Given a valid Egyptian mobile number When the owner requests a code Then a 6-digit code arrives by SMS within 60 seconds
2. Given a wrong code entered 3 times When the owner tries a 4th time Then sign-up is blocked for 15 minutes with a message saying so
3. Given a number that is already registered When the owner signs up Then they are told to log in instead and no second account is created
Out of scope: E-mail sign-up; social login
NFR: The code endpoint is rate-limited per phone number and per IP address
Open questions: none

#### S1.1.2 — Print the shop's QR code
Story: As a shop owner, I want to print my shop's QR code, so that customers can scan it at the counter.
Value: The code at the counter is what turns a visit into a stamp.
Priority: Must
Release: MVP
Points: 2
Depends on: S1.1.1
Acceptance criteria:
1. Given a signed-up shop When the owner opens Print code Then an A5 PDF with the code and the shop's name downloads
2. Given a printed code When it is scanned by the customer app Then the app shows the shop's name
3. Given an owner who reports a code as stolen When they generate a new one Then the old code stops working within 1 minute
Out of scope: Printing service; stickers
NFR: The code holds no personal data
Open questions: none

### F1.2 — Stamping
Description: A customer collects a stamp by scanning the shop's code.
Release: MVP

#### S1.2.1 — Stamp a visit by scanning the shop's code
Story: As a regular customer, I want to scan the shop's code when I pay, so that my visit counts towards a reward.
Value: The core loop: every stamp is a reason to come back.
Priority: Must
Release: MVP
Points: 5
Depends on: S1.1.2
Acceptance criteria:
1. Given a customer at a member shop When they scan its code Then one stamp is added and shown within 2 seconds
2. Given a customer who scanned the same shop less than 4 hours ago When they scan again Then no stamp is added and the app says when the next one is possible
3. Given no internet connection When the customer scans Then the stamp is queued and added within 1 minute of reconnecting
Out of scope: Stamps for amounts spent
NFR: Works on Android 9+ and iOS 15+
Open questions: none

## E2 — Customer rewards
Goal: Customers see and use their rewards across member shops.
Success metric: 20 % of stamping customers redeem a reward by month 3.
Release: MVP
Parent: none

### F2.1 — Points wallet
Description: The customer's points, per shop and across the network.
Release: MVP

#### S2.1.1 — See my points across shops
Story: As a regular customer, I want to see my points at every member shop, so that I know where I'm close to a reward.
Value: Visible progress is what brings the customer back.
Priority: Must
Release: MVP
Points: 5
Depends on: S1.2.1
Acceptance criteria:
1. Given a customer with stamps at 2 shops When they open the wallet Then both shops show with their stamp counts
2. Given a shop where the customer needs 1 more stamp When they open the wallet Then that shop is listed first and marked "1 to go"
3. Given a customer with no stamps When they open the wallet Then the wallet shows the 5 nearest member shops instead
Out of scope: Points transfer between customers
NFR: The wallet loads within 2 seconds on a 3G connection
Open questions: none

### F2.2 — Network rewards
Description: Rewards earned at one shop can be used at another.
Release: v1
Size: L
Open questions: Will shops accept a reward another shop issued? The MVP's riskiest assumption tests whether customers come back for one shop's card first.
