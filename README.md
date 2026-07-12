# Financial-Data-Analyst-Problems-Solutions
## PROBLEM 1: Transaction Fraud Detection

Fraud Detection is used daily by every bank and FinTech. Data analysts collect transactional data from credit card records, account history, user behavior, and device information to build fraud detection systems. 
The SQL covers 5 distinct rule types: velocity attacks (bots test cards in rapid bursts), geographic anomalies, statistical outliers via Z-score, dormant account reactivation, and AML structuring. 
The Python adds a risk scorecard that combines all signals.
Real-world context: Banks & FinTechs (Wells Fargo, Stripe, PayPal) lose billions annually to fraudulent transactions.

### Task to Solution: Identify suspicious patterns from raw transaction data.

#### FRAUD RULE 1: Velocity check — 5+ transactions within 10 minutes.
Real-world use: Card testing attacks; bots run small transactions quickly.

#### FRAUD RULE 2: Geographic anomaly — transaction outside home country. 
Real-world case: Account always transacts in US, suddenly appears in Romania.

