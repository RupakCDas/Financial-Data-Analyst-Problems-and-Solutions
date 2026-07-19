# Financial-Data-Analyst-Problems-Solutions
-- PROBLEM 1: Transaction Fraud Detection
-- PROBLEM 2:  Customer Churn & Revenue Retention Analysis
## PROBLEM 1: Transaction Fraud Detection

Fraud Detection is used daily by every bank and FinTech. Data analysts collect transactional data from credit card records, account history, user behavior, and device information to build fraud detection systems. 
The SQL covers 5 distinct rule types: velocity attacks (bots test cards in rapid bursts), geographic anomalies, statistical outliers via Z-score, dormant account reactivation, and AML structuring. 

Real-world context: Banks & FinTechs (Wells Fargo, Stripe, PayPal) lose billions annually to fraudulent transactions.

### Task to Solution: Identify suspicious patterns from raw transaction data.

#### PATTERN 1: Velocity check — 5+ transactions within 10 minutes.
Real-world use: Card testing attacks; bots run small transactions quickly. Assuming 5+ transactions in 10 minutes.

#### PATTERN 2: Geographic anomaly — transaction outside home country. 
Real-world case: Account always transacts in US, suddenly appears in other country. 

#### PATTERN 3: Amount Z-score > 2 . Standard Deviation above average.
Real-world: Single large unauthorized transaction after account compromise. Assuming Z score > 2 are suspicious.

#### PATTERN 4: Dormant account suddenly active.
Real-world: Stolen credentials. Assuming account dormant 90+ days, then big purchase.

#### PATTERN 5: Non round-number structuring.
Real-world: Deposits just below $10K to avoid bank reporting threshold. And assuming transaction type 'deposit' or'transfer'.

#### FRAUD MEASURING SCORE: Combine all rules.
Approach: union all rule flags into a risk score per account or transaction.


## PROBLEM 2:  Customer Churn & Revenue Retention Analysis
The SQL builds cohort retention tables, MRR movement (new/expansion/contraction/churn), and a churn early-warning system. 

#### TASK 1: MRR Movement — New / Expansion / Contraction / Churn 
Real-world: Company tracks this every month to understand revenue health




