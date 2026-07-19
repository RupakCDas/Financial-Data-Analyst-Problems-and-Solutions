WITH velocity AS (
    SELECT
        account_id,
        txn_at,
        COUNT(*) OVER (
		              PARTITION BY account_id
		              ORDER BY UNIX_TIMESTAMP(txn_at)
		              RANGE BETWEEN 600 PRECEDING AND CURRENT ROW
		            ) AS txns_in_10min
			FROM transactions
),

velo AS (
     SELECT DISTINCT account_id, txn_at, MAX(txns_in_10min) AS max_txns
  FROM velocity
  WHERE txns_in_10min > 5
  GROUP BY account_id , txn_at
  ORDER BY max_txns DESC , txn_at DESC),

r1 AS (
SELECT account_id, 1 AS velocity_score FROM velo),

-- select * from r1;

mode_country AS (
		SELECT account_id, 
        merchant_country, 
        COUNT(merchant_country) AS txn_per_cntry,
		    RANK() OVER ( PARTITION BY account_id ORDER BY COUNT(merchant_country) DESC) AS rn
		FROM transactions
		GROUP BY account_id,  merchant_country
		ORDER BY account_id ASC ),

home_country AS (
    SELECT
        account_id,
		    merchant_country AS home_cntry,
        txn_per_cntry
    FROM mode_country
    WHERE rn = 1 AND  txn_per_cntry >= 5  -- (found a baseline transaction count from history)
    ),
    
geo AS (
    SELECT
        t.account_id as account_id,
        t.txn_id,
        t.merchant,
        t.merchant_country,
        t.amount,
        t.txn_at,
        hc.home_cntry
    FROM transactions t
    INNER JOIN home_country hc ON t.account_id = hc.account_id
    WHERE t.merchant_country <> hc.home_cntry
),

r2 AS ( SELECT account_id, 1 AS geo_anomaly FROM geo),

-- select * from r2;


stats AS (
    SELECT
        account_id,
        AVG(amount)    AS avg_amount,
        STDDEV(amount) AS std_amount
    FROM transactions
    GROUP BY account_id
    HAVING COUNT(*) >= 5 AND STDDEV(amount) > 0
),

z_sco AS (
 SELECT
    t.txn_id,
    t.account_id,
    t.amount,
    t.merchant,
    t.txn_at,
    ROUND((t.amount - s.avg_amount) / s.std_amount, 2) AS z_score,
    ROUND( s.avg_amount, 2) AS avg_amount,
    ROUND( s.std_amount, 2) AS std_dev
FROM transactions t
JOIN stats s ON t.account_id = s.account_id
WHERE (t.amount - s.avg_amount) / s.std_amount > 2
ORDER BY z_score DESC),

r3 AS (
    SELECT account_id, 1 AS z_score FROM z_sco),

-- select * from r3;


last_activity AS (
      SELECT
        account_id,
        txn_at,
		    LAG(txn_at) OVER (PARTITION BY account_id ORDER BY txn_at) AS prev_txn,
        ROW_NUMBER() OVER( PARTITION BY account_id ORDER BY txn_at DESC) AS rn
    FROM transactions
    GROUP BY account_id, txn_at 
  ),
  
gaps AS(
    SELECT
        account_id,
        txn_at AS last_txn,
        prev_txn, 
        DATEDIFF(
			        STR_TO_DATE(LEFT(txn_at, 19), '%Y-%m-%d %H:%i:%s') ,
			        STR_TO_DATE(LEFT(prev_txn, 19), '%Y-%m-%d %H:%i:%s')
				  ) AS gap_days
	FROM last_activity
  WHERE rn = 1 AND prev_txn IS NOT NULL 
	GROUP BY account_id, txn_at, prev_txn
),

dor_acc AS (
    SELECT account_id, 
    last_txn, 
    gap_days
FROM gaps
WHERE gap_days > 90
GROUP BY account_id, last_txn, gap_days
ORDER BY gap_days DESC),

r4 AS (
SELECT account_id, 1 AS dormant_acc FROM geo),

-- select * from r4;


round_num AS (SELECT
    account_id,
    COUNT(*) AS structured_txns,
    SUM(amount) AS total_amount,
    MIN(txn_at) AS first_seen,
    MAX(txn_at) AS last_seen
FROM transactions
WHERE amount BETWEEN 9000 AND 9999
AND txn_type IN ('deposit','transfer')
GROUP BY account_id
HAVING COUNT(*) >= 5
ORDER BY total_amount DESC ),

r5 AS ( 
SELECT account_id, 1 AS round_num_structure FROM round_num),

-- select * from r5;
 
all_accounts AS (
    SELECT account_id FROM r1
    UNION
    SELECT account_id FROM r2
    UNION
    SELECT account_id FROM r3
    UNION
    SELECT account_id FROM r4
    UNION
    SELECT account_id FROM r5
)

SELECT 
    a.account_id,
    COALESCE(r1.velocity_score, 0) AS velocity_flag,
    COALESCE(r2.geo_anomaly, 0) AS geo_anomaly_score,
    COALESCE(r3.z_score, 0) AS z_score,
    COALESCE(r4.dormant_acc, 0) AS dormant_acc_score,
    COALESCE(r5.round_num_structure, 0) AS round_num_structure_score,
    (   COALESCE(r1.velocity_score, 0) + 
        COALESCE(r2.geo_anomaly, 0) + 
        COALESCE(r3.z_score, 0) + 
        COALESCE(r4.dormant_acc, 0) + 
        COALESCE(r5.round_num_structure, 0)
            ) AS fraud_risk_score
FROM all_accounts a
 LEFT JOIN r1 ON a.account_id = r1.account_id
 LEFT JOIN r2 ON a.account_id = r2.account_id
 LEFT JOIN r3 ON a.account_id = r3.account_id
 LEFT JOIN r4 ON a.account_id = r4.account_id
 JOIN r5 ON a.account_id = r5.account_id
ORDER BY fraud_risk_score DESC; 
