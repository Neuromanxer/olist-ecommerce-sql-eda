SELECT name
FROM sqlite_master
WHERE type = 'table';

SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews;




/*JOIN CLASSIFICATION RULES

SAFE:
- max fanout = 1
- AND no semantic duplication risk

SAFE_AGG:
- max fanout > 1 AND <= threshold
- AND stable aggregation exists to collapse to parent grain

UNSAFE:
- max fanout > threshold
- OR temporal / identity instability exists*/

/*Determining the Grain
 * ---------------------------------------------------*/



SELECT * FROM orders LIMIT 2;

/* One Row Per Order Check*/
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
/*All Unique*/

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS distinct_orders
FROM orders;
/*Matching Row count*/


WITH item_summary AS (
    SELECT order_id,
           COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
)

SELECT o.order_id,
       o.order_purchase_timestamp,
       i.item_count
FROM orders o
LEFT JOIN item_summary i
  ON o.order_id = i.order_id;


/*mulitple counts at times*/
/*Checking for duplication*/
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
ORDER BY COUNT(*) DESC;

/*order_id is unique in the orders table, and each row contains order-level attributes (status, timestamps),
 *  therefore the grain is 1 row per order.*/

SELECT * FROM order_items LIMIT 2;


SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
/*Result: Completely unique*/

SELECT order_id, order_item_id, COUNT(*) AS cnt
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
/*We have a unique combination */
/*1 row = 1 item within an order*/

SELECT * FROM order_payments LIMIT 2;

SELECT order_id, COUNT(*) AS cnt
FROM order_payments
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_id,
       COUNT(*) AS payment_rows,
       SUM(payment_value) AS total_paid
FROM order_payments
GROUP BY order_id
ORDER BY payment_rows DESC;
/*multiple payments per order*/
/*1 row = 1 payment “slice” contributing to an order’s total paymentr */



-- orders baseline
SELECT COUNT(*) FROM orders;

-- join explosion test: payments
SELECT COUNT(*) 
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id;


SELECT 
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS distinct_orders
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id;



SELECT * FROM order_reviews LIMIT 2;

SELECT order_id, COUNT(*) AS cnt
FROM order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1;
/*Multiple reviews per order*/
/* 1 review_id = 1 review record */

SELECT
    review_id,
    COUNT(*) AS cnt,
    COUNT(DISTINCT review_score) AS score_variation,
    COUNT(DISTINCT review_comment_title) AS title_variation,
    COUNT(DISTINCT review_comment_message) AS message_variation
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;


SELECT * FROM customers LIMIT 2;
/*List of buyers and their location. The ID for each individual is 'customer_unique_id', not 'customer_id'."*/

SELECT customer_uniquSELECT name
FROM sqlite_master
WHERE type = 'table';

SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews;




/*JOIN CLASSIFICATION RULES

SAFE:
- max fanout = 1
- AND no semantic duplication risk

SAFE_AGG:
- max fanout > 1 AND <= threshold
- AND stable aggregation exists to collapse to parent grain

UNSAFE:
- max fanout > threshold
- OR temporal / identity instability exists*/

/*Determining the Grain
 * ---------------------------------------------------*/



SELECT * FROM orders LIMIT 2;

/* One Row Per Order Check*/
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
/*All Unique*/

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS distinct_orders
FROM orders;
/*Matching Row count*/


WITH item_summary AS (
    SELECT order_id,
           COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
)

SELECT o.order_id,
       o.order_purchase_timestamp,
       i.item_count
FROM orders o
LEFT JOIN item_summary i
  ON o.order_id = i.order_id;


/*mulitple counts at times*/
/*Checking for duplication*/
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
ORDER BY COUNT(*) DESC;

/*order_id is unique in the orders table, and each row contains order-level attributes (status, timestamps),
 *  therefore the grain is 1 row per order.*/

SELECT * FROM order_items LIMIT 2;


SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
/*Result: Completely unique*/

SELECT order_id, order_item_id, COUNT(*) AS cnt
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
/*We have a unique combination */
/*1 row = 1 item within an order*/

SELECT * FROM order_payments LIMIT 2;

SELECT order_id, COUNT(*) AS cnt
FROM order_payments
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_id,
       COUNT(*) AS payment_rows,
       SUM(payment_value) AS total_paid
FROM order_payments
GROUP BY order_id
ORDER BY payment_rows DESC;
/*multiple payments per order*/
/*1 row = 1 payment “slice” contributing to an order’s total paymentr */



-- orders baseline
SELECT COUNT(*) FROM orders;

-- join explosion test: payments
SELECT COUNT(*) 
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id;


SELECT 
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS distinct_orders
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id;



SELECT * FROM order_reviews LIMIT 2;

SELECT order_id, COUNT(*) AS cnt
FROM order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1;
/*Multiple reviews per order*/
/* 1 review_id = 1 review record */




SELECT * FROM customers LIMIT 2;
/*List of buyers and their location. The ID for each individual is 'customer_unique_id', not 'customer_id'."*/

SELECT customer_unique_id, COUNT(*) AS cnt
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC;
/*Is grain per customer? result -> no */

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
/* customer_id is unique per row -> Each row represents a single customer_id record in the system
 * customer_id represents a customer occurrence tied to a specific order event
 * customer_unique_id represents the real customer, and may appear multiple times across different customer_ids in the system
 * The grain of the customers table is 1 row per customer_id (system-level customer record)


/*“Does one real customer have multiple system IDs?”*/
SELECT customer_unique_id,
       COUNT(DISTINCT customer_id) AS num_customer_ids
FROM customers
GROUP BY customer_unique_id
ORDER BY num_customer_ids DESC;
/*yes, meaning that there are repeat custoemers*/


SELECT * FROM products LIMIT 2;
SELECT product_id, COUNT(*) AS cnt
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;
/*1 row = 1 product*/

/*Changing product_name to english translation*/
SELECT 
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;


SELECT * FROM sellers LIMIT 2;
SELECT seller_zip_code_prefix, COUNT(DISTINCT seller_id)
FROM sellers
GROUP BY seller_zip_code_prefix
HAVING COUNT(DISTINCT seller_id) > 1;
/*zip is NOT a unique identifier
*/

SELECT seller_id, COUNT(*) AS cnt
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT seller_zip_code_prefix, COUNT(DISTINCT seller_id)
FROM sellers
GROUP BY seller_zip_code_prefix
HAVING COUNT(DISTINCT seller_id) > 1;

/*Seller ID is unique 
 * 1 row = 1 seller
 * */



SELECT * FROM geolocation LIMIT 2;
/*Geographic location data for Brazilian state codes, cities and zip code prefixes.*/

SELECT geolocation_zip_code_prefix, COUNT(*)
FROM geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;
/*No uniqueness by prefix
 */
SELECT geolocation_zip_code_prefix,
       geolocation_lat,
       geolocation_lng,
       COUNT(*)
FROM geolocation
GROUP BY 1,2,3
HAVING COUNT(*) > 1;
/*1 row = 1 recorded geographic coordinate associated with a zip code prefix*/



SELECT * FROM leads_qualified LIMIT 2;
/*After a qualified lead fills in a form at a landing page he is contacted by a Sales Development Representative. 
 * At this step some information is checked and more information about the lead is gathered.
 */
SELECT mql_id, COUNT(*)
FROM leads_qualified
GROUP BY mql_id
HAVING COUNT(*) > 1;
/*1 row per marketing qualified lead (mql_id). */




SELECT * FROM leads_closed LIMIT 2;

SELECT mql_id, COUNT(*) AS cnt
FROM leads_closed
GROUP BY mql_id
HAVING COUNT(*) > 1;
/*mql_id is unique*/


SELECT seller_id, COUNT(*) AS cnt
FROM leads_closed
GROUP BY seller_id
HAVING COUNT(*) > 1;
/*seller_id is unique*/
/*1 row = 1 closed lead (conversion event)*/


-- GRAIN REGISTRY (SOURCE OF TRUTH)
-- orders:          1 row per order_id
-- order_items:     1 row per (order_id, order_item_id)
-- order_payments:  1 row per (order_id, payment_sequential)
-- order_reviews:   1 row per review_id
-- customers:       1 row per customer_id
-- products:        1 row per product_id
-- sellers:         1 row per seller_id
-- geolocation:     1 row per (zip_code_prefix, lat, lng)
-- leads_qualified: 1 row per mql_id
-- leads_closed:    1 row per mql_id
SELECT name
FROM sqlite_master
WHERE type = 'table';

SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews;




/*JOIN CLASSIFICATION RULES

SAFE:
- max fanout = 1
- AND no semantic duplication risk

SAFE_AGG:
- max fanout > 1 AND <= threshold
- AND stable aggregation exists to collapse to parent grain

UNSAFE:
- max fanout > threshold
- OR temporal / identity instability exists*/

/*Determining the Grain
 * ---------------------------------------------------*/



SELECT * FROM orders LIMIT 2;

/* One Row Per Order Check*/
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
/*All Unique*/

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS distinct_orders
FROM orders;
/*Matching Row count*/


WITH item_summary AS (
    SELECT order_id,
           COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
)

SELECT o.order_id,
       o.order_purchase_timestamp,
       i.item_count
FROM orders o
LEFT JOIN item_summary i
  ON o.order_id = i.order_id;


/*mulitple counts at times*/
/*Checking for duplication*/
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
ORDER BY COUNT(*) DESC;

/*order_id is unique in the orders table, and each row contains order-level attributes (status, timestamps),
 *  therefore the grain is 1 row per order.*/

SELECT * FROM order_items LIMIT 2;


SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
/*Result: Completely unique*/

SELECT order_id, order_item_id, COUNT(*) AS cnt
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
/*We have a unique combination */
/*1 row = 1 item within an order*/

SELECT * FROM order_payments LIMIT 2;

SELECT order_id, COUNT(*) AS cnt
FROM order_payments
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_id,
       COUNT(*) AS payment_rows,
       SUM(payment_value) AS total_paid
FROM order_payments
GROUP BY order_id
ORDER BY payment_rows DESC;
/*multiple payments per order*/
/*1 row = 1 payment “slice” contributing to an order’s total paymentr */



-- orders baseline
SELECT COUNT(*) FROM orders;

-- join explosion test: payments
SELECT COUNT(*) 
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id;


SELECT 
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS distinct_orders
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id;



SELECT * FROM order_reviews LIMIT 2;

SELECT order_id, COUNT(*) AS cnt
FROM order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1;
/*Multiple reviews per order*/
/* 1 review_id = 1 review record */




SELECT * FROM customers LIMIT 2;
/*List of buyers and their location. The ID for each individual is 'customer_unique_id', not 'customer_id'."*/

SELECT customer_unique_id, COUNT(*) AS cnt
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC;
/*Is grain per customer? result -> no */

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
/* customer_id is unique per row -> Each row represents a single customer_id record in the system
 * customer_id represents a customer occurrence tied to a specific order event
 * customer_unique_id represents the real customer, and may appear multiple times across different customer_ids in the system
 * The grain of the customers table is 1 row per customer_id (system-level customer record)


/*“Does one real customer have multiple system IDs?”*/
SELECT customer_unique_id,
       COUNT(DISTINCT customer_id) AS num_customer_ids
FROM customers
GROUP BY customer_unique_id
ORDER BY num_customer_ids DESC;
/*yes, meaning that there are repeat custoemers*/


SELECT * FROM products LIMIT 2;
SELECT product_id, COUNT(*) AS cnt
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;
/*1 row = 1 product*/

/*Changing product_name to english translation*/
SELECT 
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;


SELECT * FROM sellers LIMIT 2;
SELECT seller_zip_code_prefix, COUNT(DISTINCT seller_id)
FROM sellers
GROUP BY seller_zip_code_prefix
HAVING COUNT(DISTINCT seller_id) > 1;
/*zip is NOT a unique identifier
*/

SELECT seller_id, COUNT(*) AS cnt
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT seller_zip_code_prefix, COUNT(DISTINCT seller_id)
FROM sellers
GROUP BY seller_zip_code_prefix
HAVING COUNT(DISTINCT seller_id) > 1;

/*Seller ID is unique 
 * 1 row = 1 seller
 * */



SELECT * FROM geolocation LIMIT 2;
/*Geographic location data for Brazilian state codes, cities and zip code prefixes.*/

SELECT geolocation_zip_code_prefix, COUNT(*)
FROM geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;
/*No uniqueness by prefix
 */
SELECT geolocation_zip_code_prefix,
       geolocation_lat,
       geolocation_lng,
       COUNT(*)
FROM geolocation
GROUP BY 1,2,3
HAVING COUNT(*) > 1;
/*1 row = 1 recorded geographic coordinate associated with a zip code prefix*/



SELECT * FROM leads_qualified LIMIT 2;
/*After a qualified lead fills in a form at a landing page he is contacted by a Sales Development Representative. 
 * At this step some information is checked and more information about the lead is gathered.
 */
SELECT mql_id, COUNT(*)
FROM leads_qualified
GROUP BY mql_id
HAVING COUNT(*) > 1;
/*1 row per marketing qualified lead (mql_id). */




SELECT * FROM leads_closed LIMIT 2;

SELECT mql_id, COUNT(*) AS cnt
FROM leads_closed
GROUP BY mql_id
HAVING COUNT(*) > 1;
/*mql_id is unique*/


SELECT seller_id, COUNT(*) AS cnt
FROM leads_closed
GROUP BY seller_id
HAVING COUNT(*) > 1;
/*seller_id is unique*/
/*1 row = 1 closed lead (conversion event)*/


-- GRAIN REGISTRY (SOURCE OF TRUTH)
-- orders:          1 row per order_id
-- order_items:     1 row per (order_id, order_item_id)
-- order_payments:  1 row per (order_id, payment_sequential)
-- order_reviews:   1 row per review_id
-- customers:       1 row per customer_id
-- products:        1 row per product_id
-- sellers:         1 row per seller_id
-- geolocation:     1 row per (zip_code_prefix, lat, lng)
-- leads_qualified: 1 row per mql_id
-- leads_closed:    1 row per mql_id
/* ============================================================
   L1.5 — DATA COMPLETENESS (NULL + COVERAGE CHECK)
   PURPOSE: detect silent missingness and broken records
   ============================================================ */

/* NULL rate by critical order fields */
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_purchase_ts,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS missing_approved_ts,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery_ts
FROM orders;
/*total_orders	missing_purchase_ts	missing_approved_ts	missing_delivery_ts
 * 99441	0	160	2965
 */

/* Payment completeness per order */
SELECT
    COUNT(*) AS orders_with_payments,
    (SELECT COUNT(*) FROM orders) - COUNT(*) AS missing_payment_orders
FROM (
    SELECT DISTINCT order_id
    FROM order_payments
) t;
/*orders_with_payments	missing_payment_orders
 * 99440	1
 */

/* Item completeness per order */
SELECT
    COUNT(*) AS orders_with_items,
    (SELECT COUNT(*) FROM orders) - COUNT(*) AS missing_item_orders
FROM (
    SELECT DISTINCT order_id
    FROM order_items
) t;
/*orders_with_items	missing_item_orders98666	775
 * Orders and payments are nearly fully complete, but item-level coverage has ~0.8% missing orders and delivery timestamps are ~3% incomplete, 
 * making financial analysis reliable while fulfillment and lifecycle timing require missing-data awareness.
 */
/* ============================================================
   L2 — FANOUT BEHAVIOR (JOIN RISK ONLY)
   PURPOSE: measure multiplicity, NOT classify business logic
   ============================================================ */

/* Orders → Items */
SELECT AVG(cnt) AS avg_items_per_order,
       MAX(cnt) AS max_items_per_order
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_items
    GROUP BY order_id
) t;
/*avg_items_per_order	max_items_per_order1.1417306873695092	21

/* Orders → Payments */
SELECT AVG(cnt) AS avg_payments_per_order,
       MAX(cnt) AS max_payments_per_order
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_payments
    GROUP BY order_id
) t;
/*avg_payments_per_order	max_payments_per_order 1.0447103781174578	29 */

/* Orders → Reviews */
SELECT AVG(cnt) AS avg_reviews_per_order,
       MAX(cnt) AS max_reviews_per_order
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_reviews
    GROUP BY order_id
) t;
/*avg_reviews_per_order max_reviews_per_order 1.0055841010205426 3


/* Join explosion sanity check */
SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS distinct_orders
FROM orders o
JOIN order_payments p
  ON o.order_id = p.order_id;
---joined_rows	distinct_orders103886	99440

/*L2 — FANOUT BEHAVIOR NOTES

Orders → Items

Avg 1.14, max 21 → multi-item orders exist with mild tail skew
Requires aggregation to order_id before joins (SAFE_AGG)

Orders → Payments

Avg 1.04, max 29 → near 1:1 but heavy tail fragmentation
Payments are split transactions → must SUM by order_id (SAFE_AGG required)

Orders → Reviews

Avg 1.00, max 3 → mostly 1:1 with rare duplicates
Treat as conditional SAFE; aggregate (AVG or MAX) if used in metrics

Join Explosion (Orders × Payments)

~4.5% row inflation → confirms non-1:1 relationships impact joins
Raw joins are not safe for metric layers without aggregation*/

/* ============================================================
   L2.1 — REFERENTIAL INTEGRITY CHECKS (ORPHAN DETECTION)
   PURPOSE: detect broken foreign-key relationships
   ============================================================ */

/* order_items → orders */
SELECT COUNT(*) AS orphan_items
FROM order_items i
LEFT JOIN orders o ON i.order_id = o.order_id
WHERE o.order_id IS NULL;


/* order_payments → orders */
SELECT COUNT(*) AS orphan_payments
FROM order_payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


/* order_reviews → orders */
SELECT COUNT(*) AS orphan_reviews
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


/* customers → orders */
SELECT COUNT(*) AS orphan_customers
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

/*0 nulls for all*/
/* ============================================================
   L2.2 — FANOUT DISTRIBUTION SHAPE
   PURPOSE: understand skew beyond max/avg
   ============================================================ */

/* Orders → Items distribution */
SELECT
    MIN(cnt) AS min_items,
    AVG(cnt) AS avg_items,
    MAX(cnt) AS max_items
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_items
    GROUP BY order_id
) t;
/*min_items	avg_items	max_items 1	1.1417306873695092	21

/* percentile approximation (SQLite-friendly workaround) */
SELECT cnt
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_items
    GROUP BY order_id
)
ORDER BY cnt;
/*counts are all/mostly 1s*/

/* Orders → Payments distribution */
SELECT
    MIN(cnt) AS min_payments,
    AVG(cnt) AS avg_payments,
    MAX(cnt) AS max_payments
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_payments
    GROUP BY order_id
) t;
/*min_payments	avg_payments	max_payments 1	1.0447103781174578	29
 * Both items and payments are heavily concentrated near 1 per order, but exhibit long-tail skew (especially payments up to 29)
 * , meaning joins must always be pre-aggregated despite near 1:1 averages.
 * 
 */

/* ============================================================
   L2.3 — JOIN RULE VALIDATION (ENFORCEMENT LAYER)
   ============================================================ */

/* SAFE_AGG CHECK: order_items must reduce to 1 row per order */
SELECT
    COUNT(*) AS violating_orders
FROM (
    SELECT order_id
    FROM order_items
    GROUP BY order_id
    HAVING COUNT(*) > 1
);
--- violating_orders 9803

/* SAFE_AGG CHECK: payments must collapse cleanly */
SELECT order_id
FROM order_payments
GROUP BY order_id
HAVING SUM(payment_value) IS NULL;
---empty order_id

/* SAFE CHECK: customers must be 1:1 at customer_id level */
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
---empty count


/* ============================================================
   L2.3 — INTERPRETATION SUMMARY
   ============================================================

/* order_items fanout interpretation

~9,803 orders have multiple items.

This is NOT a data quality issue.
It confirms expected 1:M transactional structure.

Implication:
- order_items must always be aggregated to order_id
  before joining to order-level models.

Conclusion:
- SAFE_AGG relationship (valid fact table design)
- no integrity violations detected

- order_payments:
  clean aggregatable fact table; no null aggregation risk.
  split transactions but safely collapsible via SUM(payment_value).

- customers:
  strict 1:1 at customer_id level; safe dimension table.
  real-world identity fragmentation exists via customer_unique_id,
  but does not affect join integrity.

OVERALL:
- No integrity violations detected
- All multi-row relationships are structurally expected
- SAFE_AGG rules are correctly required for modeling layer
*/


/*============================================================
L2.4 — FANOUT → AGGREGATION ENFORCEMENT MAP (CRITICAL)
PURPOSE: convert observation into deterministic rules
============================================================*/
-- REQUIRED PRE-AGGREGATION LAYER
WITH item_agg AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(price) AS total_item_value
    FROM order_items
    GROUP BY order_id
)
SELECT * FROM item_agg;


WITH payment_agg AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment,
        COUNT(*) AS payment_slices
    FROM order_payments
    GROUP BY order_id
)
SELECT * FROM payment_agg;


WITH review_agg AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_score,
        COUNT(*) AS review_count
    FROM order_reviews
    GROUP BY order_id
)
SELECT * FROM review_agg;

/*============================================================
L2.5 — MULTI-JOIN COMPOSITION SAFETY (YOU ARE MISSING THIS)
============================================================*/
WITH item_agg AS (
    SELECT order_id,
           COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
),
payment_agg AS (
    SELECT order_id,
           SUM(payment_value) AS total_payment
    FROM order_payments
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    COALESCE(i.item_count, 0) AS item_count,
    COALESCE(p.total_payment, 0) AS total_payment
FROM orders o
LEFT JOIN item_agg i ON o.order_id = i.order_id
LEFT JOIN payment_agg p ON o.order_id = p.order_id;


/*L2.6 — CONTRACT VIOLATION DEFINITIONS (TURN YOUR COMMENTS INTO RULES)*/
SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS distinct_orders
FROM orders o
JOIN order_payments p
  ON o.order_id = p.order_id;

/*joined_rows	distinct_orders103886	99440
 */

SELECT
    order_id,
    SUM(price) AS raw_item_total
FROM order_items
GROUP BY order_id;



SELECT
    order_id,
    COUNT(*) AS fanout
FROM order_items
GROUP BY order_id;



/*============================================================
L2.7 — FANOUT SYSTEM CLASSIFIER (AUTO-CATEGORIZATION LAYER)
PURPOSE: classify relationship type instead of manually inspecting
============================================================*/

WITH fanout_dist AS (
    SELECT
        order_id,
        COUNT(*) AS fanout
    FROM order_items
    GROUP BY order_id
)
SELECT
    AVG(fanout) AS avg_fanout,
    MAX(fanout) AS max_fanout,
    MIN(fanout) AS min_fanout
FROM fanout_dist;
/*
avg_fanout	max_fanout	min_fanout
1.1417306873695092	21	1
*/

SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS distinct_orders,
    COUNT(*) * 1.0 / COUNT(DISTINCT o.order_id) AS explosion_ratio
FROM orders o
JOIN order_payments p
  ON o.order_id = p.order_id;
/* ============================================================
   L3 — SEMANTIC LAYER (BUSINESS MEANING ONLY)
   PURPOSE: define lifecycle + identity behavior
   ============================================================ */




/* Order lifecycle */
WITH order_states AS (
    SELECT *,
        CASE
            WHEN order_status IN ('canceled', 'unavailable') THEN 'failed'
            WHEN order_delivered_customer_date IS NOT NULL THEN 'completed'
            WHEN order_approved_at IS NOT NULL THEN 'in_progress'
            ELSE 'unknown'
        END AS lifecycle_state
    FROM orders
)
SELECT lifecycle_state,
       COUNT(*) AS order_count
FROM order_states
GROUP BY lifecycle_state;
/*lifecycle_state	order_count completed	96470
failed	1234
in_progress	1732
unknown	5
*/





/* Temporal integrity check */
WITH flagged AS (
    SELECT *,
        CASE
            WHEN order_approved_at < order_purchase_timestamp THEN 1
            WHEN order_delivered_carrier_date < order_approved_at THEN 1
            WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1
            ELSE 0
        END AS invalid
    FROM orders
)
SELECT
    COUNT(*) AS total_orders,
    SUM(invalid) AS invalid_orders,
    AVG(invalid * 1.0) AS invalid_rate
FROM flagged;
/*total_orders	invalid_orders	invalid_rate 99441	1382	0.013897688076346778*/
/*Order Lifecycle

~96.9% completed → dataset is heavily fulfillment-focused
~1.2% failed → low cancellation rate
~1.7% in-progress → small active pipeline
~0.005% unknown → negligible missing/ambiguous states
Overall: lifecycle is stable and dominated by completed orders

Temporal Integrity

~1.39% invalid timestamp ordering
Errors are low but non-zero → indicates minor logging/inconsistency issues
Overall: timestamps are directionally reliable but not strictly clean for event-order analysis*/
/* ============================================================
   L4 — BUSINESS METRICS (ONLY AFTER STRUCTURE IS UNDERSTOOD)
   PURPOSE: safe aggregation logic
   ============================================================ */

/* Revenue per order */
SELECT order_id,
       SUM(payment_value) AS total_paid
FROM order_payments
GROUP BY order_id;


/* Order size distribution */
SELECT COUNT(*) AS orders,
       AVG(item_count) AS avg_items_per_order
FROM (
    SELECT order_id,
           COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
) t;


/* Customer fragmentation impact */
SELECT
    COUNT(*) AS customers,
    SUM(CASE WHEN system_ids > 1 THEN 1 ELSE 0 END) AS fragmented_customers
FROM (
    SELECT customer_unique_id,
           COUNT(DISTINCT customer_id) AS system_ids
    FROM customers
    GROUP BY customer_unique_id
) t;







/* ============================================================
   L5 — CONTRACTED MODEL LAYER (PRODUCTION SAFE VIEWS)
   ============================================================ */


/* ============================================================
   1. FACT: ORDERS (CORE GRAIN = order_id)
   ============================================================ */


DROP VIEW IF EXISTS fct_orders;



CREATE VIEW fct_orders AS
WITH item_agg AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(price) AS total_item_value
    FROM order_items
    GROUP BY order_id
),

payment_agg AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_revenue,
        COUNT(*) AS payment_slices
    FROM order_payments
    GROUP BY order_id
),

review_agg AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score,
        COUNT(*) AS review_count
    FROM order_reviews
    GROUP BY order_id
)

SELECT
    /* GRAIN ANCHOR (DO NOT REMOVE) */
    o.order_id,

    /* DIMENSIONS */
    o.customer_id,
    o.order_status,

    /* TIMESTAMPS (TABLEAU TIME AXIS SAFE) */
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,

    /* METRICS */
    COALESCE(payment_agg.total_revenue, 0) AS total_revenue,
    COALESCE(item_agg.item_count, 0) AS item_count,
    COALESCE(item_agg.total_item_value, 0) AS total_item_value,
    COALESCE(review_agg.avg_review_score, NULL) AS avg_review_score,

    /* DEBUG FIELDS (CRITICAL FOR BI VALIDATION) */
    COALESCE(payment_agg.payment_slices, 0) AS payment_slices,
    COALESCE(review_agg.review_count, 0) AS review_count

FROM orders o
LEFT JOIN item_agg
    ON o.order_id = item_agg.order_id
LEFT JOIN payment_agg
    ON o.order_id = payment_agg.order_id
LEFT JOIN review_agg
    ON o.order_id = review_agg.order_id;






/* ============================================================
   2. FACT: Order items
   ============================================================ */
DROP VIEW IF EXISTS fct_order_items;




CREATE VIEW fct_order_items AS
SELECT
    /* GRAIN */
    oi.order_id,
    oi.order_item_id,

    /* KEYS */
    oi.product_id,
    oi.seller_id,

    /* METRICS */
    oi.price AS item_price,
    oi.freight_value,

    /* DERIVED */
    oi.price + oi.freight_value AS total_item_value

FROM order_items oi;



/* ============================================================
   3. FACT: DELIVERY (DERIVED TIME GRAIN = order_id)
   ============================================================ */
DROP VIEW IF EXISTS fct_delivery;




CREATE VIEW fct_delivery AS
SELECT
    order_id,

    /* SAFE DURATIONS */
    CASE 
        WHEN order_delivered_customer_date IS NOT NULL
        THEN JULIANDAY(order_delivered_customer_date) 
           - JULIANDAY(order_purchase_timestamp)
        ELSE NULL
    END AS total_days,

    CASE 
        WHEN order_approved_at IS NOT NULL
        THEN JULIANDAY(order_approved_at) 
           - JULIANDAY(order_purchase_timestamp)
    END AS approval_days,

    CASE 
        WHEN order_delivered_carrier_date IS NOT NULL
        THEN JULIANDAY(order_delivered_carrier_date) 
           - JULIANDAY(order_approved_at)
    END AS carrier_days,

    CASE 
        WHEN order_delivered_customer_date IS NOT NULL
        THEN JULIANDAY(order_delivered_customer_date) 
           - JULIANDAY(order_delivered_carrier_date)
    END AS last_mile_days,

    /* EXPLICIT FLAG */
    CASE
        WHEN order_delivered_customer_date IS NULL THEN 1
        ELSE 0
    END AS is_undelivered

FROM orders;




/* ============================================================
   4. FACT: REVIEWS (GRAIN = order_id)
   ============================================================ */
DROP VIEW IF EXISTS fct_reviews;





CREATE VIEW fct_reviews AS
SELECT
    order_id,

    AVG(review_score) AS avg_review_score,
    COUNT(*) AS review_count,
    MIN(review_score) AS min_score,
    MAX(review_score) AS max_score

FROM order_reviews
GROUP BY order_id;




/* ============================================================
    5. FACT: Payments
   ============================================================ */
DROP VIEW IF EXISTS fct_payments;




CREATE VIEW fct_payments AS
SELECT
    order_id,
    payment_type,
    SUM(payment_value) AS total_payment
FROM order_payments
GROUP BY order_id, payment_type;




/* ============================================================
   6.  FACT: Pipeline
   ============================================================ */
DROP VIEW IF EXISTS fct_pipeline;




CREATE VIEW fct_pipeline AS
SELECT
    lq.mql_id,
    lq.first_contact_date,
    lq.origin,
    lq.landing_page_id,
    lc.seller_id,
    lc.won_date,
    lc.business_segment,
    lc.lead_type,
    lc.lead_behaviour_profile,
    lc.has_company,
    lc.declared_monthly_revenue,
    CASE WHEN lc.mql_id IS NOT NULL THEN 1 ELSE 0 END AS is_converted,
    JULIANDAY(lc.won_date) - JULIANDAY(lq.first_contact_date) AS days_to_close
FROM leads_qualified lq
LEFT JOIN leads_closed lc ON lq.mql_id = lc.mql_id;


/* ============================================================
   7. FACT: Seller_Performance
   ============================================================ */
DROP VIEW IF EXISTS fct_seller_performance;



CREATE VIEW fct_seller_performance AS
SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id)   AS total_orders,
    COUNT(oi.order_item_id)       AS items_sold,
    SUM(oi.price)                 AS total_revenue,
    AVG(r.avg_review_score)       AS avg_review_score
FROM order_items oi
LEFT JOIN fct_reviews r ON oi.order_id = r.order_id
GROUP BY oi.seller_id;



/* ============================================================
   8. FACT: Customer Orders
   ============================================================ */
DROP VIEW IF EXISTS fct_customer_orders;





CREATE VIEW fct_customer_orders AS
SELECT
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    fo.total_revenue,
    fo.item_count,
    fo.avg_review_score
FROM customers c
JOIN fct_orders fo ON c.customer_id = fo.customer_id
JOIN orders o      ON fo.order_id   = o.order_id;



/* ============================================================
   9. FACT: Product Performance
   ============================================================ */
DROP VIEW IF EXISTS fct_product_performance;




CREATE VIEW fct_product_performance AS
SELECT
    oi.product_id,
    dp.product_category,
    dp.product_weight_g,
    COUNT(DISTINCT oi.order_id)  AS total_orders,
    SUM(oi.price)                AS total_revenue,
    AVG(oi.price)                AS avg_price,
    SUM(oi.freight_value)        AS total_freight,
    AVG(r.avg_review_score)      AS avg_review_score
FROM order_items oi
LEFT JOIN dim_products dp ON oi.product_id = dp.product_id
LEFT JOIN fct_reviews r   ON oi.order_id   = r.order_id
GROUP BY oi.product_id, dp.product_category, dp.product_weight_g;



/* ============================================================
   Dims
   ============================================================ */


/* ============================================================
   1. DIM: Sellers
   ============================================================ */
DROP VIEW IF EXISTS dim_sellers;



CREATE VIEW dim_sellers AS
SELECT
    seller_id,
    seller_city,
    seller_state,
    seller_zip_code_prefix
FROM sellers;



/* ============================================================
  2. DIM: Products
   ============================================================ */
DROP VIEW IF EXISTS dim_products;




CREATE VIEW dim_products AS
SELECT
    p.product_id,

    /* FIXED CATEGORY */
    COALESCE(t.product_category_name_english, p.product_category_name) 
        AS product_category,

    /* attributes */
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm

FROM products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;




/* ============================================================
  3. DIM: Customers
   ============================================================ */

DROP VIEW IF EXISTS dim_customers;



CREATE VIEW dim_customers AS
SELECT
    c.customer_unique_id,
    MIN(c.customer_id)              AS customer_id,
    MAX(c.customer_city)            AS customer_city,
    MAX(c.customer_state)           AS customer_state,
    MAX(c.customer_zip_code_prefix) AS customer_zip_code_prefix,  -- ADDED
    COUNT(DISTINCT o.order_id)      AS total_orders,
    MIN(o.order_purchase_timestamp) AS first_order_date,
    MAX(o.order_purchase_timestamp) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;




/* ============================================================
  4. DIM: Date
   ============================================================ */
DROP VIEW IF EXISTS dim_date;



CREATE VIEW dim_date AS
WITH RECURSIVE dates(date) AS (
    SELECT DATE('2016-01-01')
    UNION ALL
    SELECT DATE(date, '+1 day')
    FROM dates
    WHERE date < DATE('2018-12-31')
)
SELECT
    date,

    STRFTIME('%Y', date) AS year,
    STRFTIME('%m', date) AS month,
    STRFTIME('%d', date) AS day,

    STRFTIME('%Y-%m', date) AS year_month,

    CASE
        WHEN STRFTIME('%m', date) IN ('01','02','03') THEN 'Q1'
        WHEN STRFTIME('%m', date) IN ('04','05','06') THEN 'Q2'
        WHEN STRFTIME('%m', date) IN ('07','08','09') THEN 'Q3'
        ELSE 'Q4'
    END AS quarter

FROM dates;


/* ============================================================
  5. DIM: Geography
   ============================================================ */
DROP VIEW IF EXISTS dim_geography;



CREATE VIEW dim_geography AS
SELECT
    geolocation_zip_code_prefix,

    AVG(geolocation_lat) AS lat,
    AVG(geolocation_lng) AS lng,

    MAX(geolocation_city) AS city,
    MAX(geolocation_state) AS state

FROM geolocation
GROUP BY geolocation_zip_code_prefix;




/* ============================================================
   L5.1 — FACT TABLE VALIDATION GATES (TABLEAU SAFETY LAYER)
   ============================================================ */



DROP TABLE IF EXISTS join_contract;

CREATE TABLE join_contract (
    left_table TEXT NOT NULL,
    right_table TEXT NOT NULL,
    join_key TEXT NOT NULL,
    join_type TEXT NOT NULL,  -- SAFE | SAFE_AGG | UNSAFE
    requires_aggregation INTEGER NOT NULL, -- 0 or 1
    max_fanout REAL, -- tolerance threshold
    notes TEXT
);

INSERT INTO join_contract VALUES
('orders','order_items','order_id','SAFE_AGG',1,1.2,'Order items must be aggregated before join'),
('orders','order_payments','order_id','SAFE_AGG',1,1.1,'Payments are split transactions'),
('orders','order_reviews','order_id','SAFE',1,1.05,'Rare duplicates, safe after aggregation'),
('orders','customers','customer_id','SAFE',0,1.0,'True dimension join'),
('order_items','products','product_id','SAFE',0,1.0,'Dimension lookup'),
('order_items','sellers','seller_id','SAFE',0,1.0,'Dimension lookup');




---L1 — GRAIN ENFORCEMENT LAYER
DROP VIEW IF EXISTS v_grain_validation;



CREATE VIEW v_grain_validation AS

/* =========================
   ORDERS (TRUE FACT GRAIN)
   ========================= */
SELECT
    'orders' AS table_name,
    'order_id' AS grain_key,
    COUNT(*) AS rows,
    COUNT(DISTINCT order_id) AS distinct_keys,

    CASE
        WHEN COUNT(*) = COUNT(DISTINCT order_id)
        THEN 'TRUE_1_TO_1'
        ELSE 'BROKEN'
    END AS grain_status

FROM orders


UNION ALL


/* =========================
   ORDER ITEMS (EXPECTED 1:M)
   ========================= */
SELECT
    'order_items',
    'order_id,order_item_id',
    COUNT(*),
    COUNT(DISTINCT order_id || '-' || order_item_id),

    CASE
        WHEN COUNT(*) = COUNT(DISTINCT order_id || '-' || order_item_id)
        THEN 'UNIQUE_ROW_GRAIN'
        ELSE 'DUPLICATES_EXIST'
    END

FROM order_items


UNION ALL


/* =========================
   PAYMENTS (EXPECTED SPLIT FACT)
   ========================= */
SELECT
    'order_payments',
    'order_id,payment_sequential',
    COUNT(*),
    COUNT(DISTINCT order_id || '-' || payment_sequential),

    CASE
        WHEN COUNT(*) = COUNT(DISTINCT order_id || '-' || payment_sequential)
        THEN 'UNIQUE_ROW_GRAIN'
        ELSE 'DUPLICATES_EXIST'
    END

FROM order_payments


UNION ALL


/* =========================
   REVIEWS (KEY FIX HERE)
   ========================= */
SELECT
    'order_reviews',
    'review_id',
    COUNT(*),
    COUNT(DISTINCT review_id),

    CASE
        WHEN COUNT(*) = COUNT(DISTINCT review_id)
            AND COUNT(*) = COUNT(DISTINCT order_id)
        THEN 'TRUE_1_TO_1'

        WHEN COUNT(*) > COUNT(DISTINCT order_id)
        THEN 'SAFE_AGG_ORDER_LEVEL'

        ELSE 'UNEXPECTED_STRUCTURE'
    END

FROM order_reviews


UNION ALL


/* =========================
   CUSTOMERS (DIMENSION)
   ========================= */
SELECT
    'customers',
    'customer_id',
    COUNT(*),
    COUNT(DISTINCT customer_id),

    CASE
        WHEN COUNT(*) = COUNT(DISTINCT customer_id)
        THEN 'TRUE_1_TO_1'
        ELSE 'BROKEN'
    END

FROM customers


UNION ALL


/* =========================
   PRODUCTS (DIMENSION)
   ========================= */
SELECT
    'products',
    'product_id',
    COUNT(*),
    COUNT(DISTINCT product_id),

    CASE
        WHEN COUNT(*) = COUNT(DISTINCT product_id)
        THEN 'TRUE_1_TO_1'
        ELSE 'BROKEN'
    END

FROM products


UNION ALL


/* =========================
   SELLERS (DIMENSION)
   ========================= */
SELECT
    'sellers',
    'seller_id',
    COUNT(*),
    COUNT(DISTINCT seller_id),

    CASE
        WHEN COUNT(*) = COUNT(DISTINCT seller_id)
        THEN 'TRUE_1_TO_1'
        ELSE 'BROKEN'
    END

FROM sellers;






---Grain -> PASS
DROP VIEW IF EXISTS v_fanout_profile;

CREATE VIEW v_fanout_profile AS

WITH order_items_fanout AS (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_items
    GROUP BY order_id
),
payment_fanout AS (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_payments
    GROUP BY order_id
),
review_fanout AS (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_reviews
    GROUP BY order_id
)

SELECT
    'order_items' AS table_name,
    AVG(cnt) AS avg_fanout,
    MAX(cnt) AS max_fanout,
    CASE
        WHEN AVG(cnt) <= 1.05 THEN 'SAFE'
        WHEN AVG(cnt) <= 1.2 THEN 'SAFE_AGG'
        ELSE 'UNSAFE'
    END AS classification
FROM order_items_fanout

UNION ALL

SELECT
    'order_payments',
    AVG(cnt),
    MAX(cnt),
    CASE
        WHEN AVG(cnt) <= 1.05 THEN 'SAFE'
        WHEN AVG(cnt) <= 1.2 THEN 'SAFE_AGG'
        ELSE 'UNSAFE'
    END
FROM payment_fanout

UNION ALL

SELECT
    'order_reviews',
    AVG(cnt),
    MAX(cnt),
    CASE
        WHEN AVG(cnt) <= 1.05 THEN 'SAFE'
        WHEN AVG(cnt) <= 1.2 THEN 'SAFE_AGG'
        ELSE 'UNSAFE'
    END
FROM review_fanout;





DROP VIEW IF EXISTS v_join_safety_check;



CREATE VIEW v_join_safety_check AS

SELECT
    c.left_table,
    c.right_table,
    c.join_key,
    c.join_type,

    COUNT(oi.order_id) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS base_grain,

    COUNT(oi.order_id) * 1.0 /
    NULLIF(COUNT(DISTINCT o.order_id), 0) AS explosion_ratio,

    CASE
        WHEN COUNT(oi.order_id) * 1.0 /
             NULLIF(COUNT(DISTINCT o.order_id), 0)
             <= COALESCE(c.max_fanout, 1.0)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS safety_status

FROM join_contract c

JOIN orders o ON c.left_table = 'orders'

LEFT JOIN order_items oi
    ON (
        c.right_table = 'order_items'
        AND o.order_id = oi.order_id
    )

GROUP BY
    c.left_table,
    c.right_table,
    c.join_key,
    c.join_type;






DROP TABLE IF EXISTS metric_contract;



CREATE TABLE metric_contract (
    metric_name TEXT,
    source_view TEXT,
    aggregation_rule TEXT,
    grain TEXT
);


INSERT INTO metric_contract VALUES
('revenue','fct_orders','SUM(total_revenue)','order_id'),
('items_sold','fct_orders','SUM(item_count)','order_id'),
('avg_review','fct_reviews','AVG(avg_review_score)','order_id');




---Metric validation engine

DROP VIEW IF EXISTS v_metric_validation;

CREATE VIEW v_metric_validation AS

SELECT
    'revenue' AS metric,
    (SELECT SUM(total_revenue) FROM fct_orders) AS computed_value,
    (SELECT SUM(payment_value) FROM order_payments) AS source_value,
    CASE
        WHEN ABS(
            (SELECT SUM(total_revenue) FROM fct_orders)
            -
            (SELECT SUM(payment_value) FROM order_payments)
        ) < 0.01 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status

UNION ALL

SELECT
    'items',
    (SELECT SUM(item_count) FROM fct_orders),
    (SELECT COUNT(*) FROM order_items),
    CASE
        WHEN (SELECT SUM(item_count) FROM fct_orders)
           = (SELECT COUNT(*) FROM order_items)
        THEN 'PASS' ELSE 'FAIL'
    END

UNION ALL

SELECT
    'reviews',
    (SELECT SUM(review_count) FROM fct_orders),
    (SELECT COUNT(*) FROM order_reviews),
    CASE
        WHEN (SELECT SUM(review_count) FROM fct_orders)
           = (SELECT COUNT(*) FROM order_reviews)
        THEN 'PASS' ELSE 'FAIL'
    END;





---Grain preseveration test
DROP VIEW IF EXISTS v_grain_preservation_check;

CREATE VIEW v_grain_preservation_check AS
SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS expected_grain,
    COUNT(*) - COUNT(DISTINCT o.order_id) AS grain_violation
FROM fct_orders o
LEFT JOIN fct_reviews r
ON o.order_id = r.order_id;





DROP VIEW IF EXISTS v_orphan_orders;



CREATE VIEW v_orphan_orders AS

SELECT 'order_items->orders' AS check_name,
       COUNT(*) AS orphan_count
FROM order_items i
LEFT JOIN orders o ON i.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'order_payments->orders',
       COUNT(*)
FROM order_payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'order_reviews->orders',
       COUNT(*)
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

-- customers->orders (correct version)
SELECT 'customers->orders' AS check_name,
       COUNT(*) AS orphan_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL
UNION ALL

SELECT 'order_items->products',
       COUNT(*)
FROM order_items i
LEFT JOIN products p ON i.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 'order_items->sellers',
       COUNT(*)
FROM order_items i
LEFT JOIN sellers s ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL;




---DIMENSION INTEGRITY LAYER
DROP VIEW IF EXISTS v_dim_products_integrity;

CREATE VIEW v_dim_products_integrity AS
SELECT
    CASE
        WHEN SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) = 0
         AND COUNT(*) = COUNT(DISTINCT product_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS integrity_status,
    
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_keys,
    COUNT(*) - COUNT(DISTINCT product_id) AS duplicates
FROM dim_products;




---FULL SYSTEM HEALTH CHECK
DROP VIEW IF EXISTS v_system_health;

CREATE VIEW v_system_health AS

SELECT 'grain_check' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM v_grain_validation WHERE grain_status = 'FAIL'
       ) THEN 'FAIL' ELSE 'PASS' END AS status

UNION ALL

SELECT 'fanout_check',
       CASE WHEN EXISTS (
           SELECT 1 FROM v_fanout_profile WHERE classification = 'UNSAFE'
       ) THEN 'FAIL' ELSE 'PASS' END

UNION ALL

SELECT 'orphan_check',
       CASE WHEN EXISTS (
           SELECT 1 FROM v_orphan_orders WHERE orphan_count > 0
       ) THEN 'FAIL' ELSE 'PASS' END

UNION ALL

SELECT 'metric_check',
       CASE WHEN EXISTS (
           SELECT 1 FROM v_metric_validation WHERE validation_status = 'FAIL'
       ) THEN 'FAIL' ELSE 'PASS' END

UNION ALL

SELECT 'dim_integrity',
       CASE WHEN EXISTS (
           SELECT 1 FROM v_dim_products_integrity
           WHERE integrity_status = 'FAIL'
       ) THEN 'FAIL' ELSE 'PASS' END;





-- (extend with metric + orphan + join checks)
DROP VIEW IF EXISTS v_export_gate;


CREATE VIEW v_export_gate AS
WITH checks AS (

    SELECT 'grain' AS check_name,
           CASE WHEN EXISTS (
               SELECT 1 FROM v_grain_validation WHERE grain_status = 'FAIL'
           ) THEN 0 ELSE 1 END AS pass

    UNION ALL

    SELECT 'fanout',
           CASE WHEN EXISTS (
               SELECT 1 FROM v_fanout_profile WHERE classification = 'UNSAFE'
           ) THEN 0 ELSE 1 END

    UNION ALL

    SELECT 'orphan',
           CASE WHEN EXISTS (
               SELECT 1 FROM v_orphan_orders WHERE orphan_count > 0
           ) THEN 0 ELSE 1 END

    UNION ALL

    SELECT 'metrics',
           CASE WHEN EXISTS (
               SELECT 1 FROM v_metric_validation WHERE validation_status = 'FAIL'
           ) THEN 0 ELSE 1 END

    UNION ALL

    SELECT 'dim_integrity',
           CASE WHEN EXISTS (
               SELECT 1 FROM v_dim_products_integrity
               WHERE integrity_status = 'FAIL'
           ) THEN 0 ELSE 1 END
)

SELECT
    COUNT(*) AS total_checks,
    SUM(CAST(pass AS INTEGER)) AS passed_checks,
    CASE
        WHEN SUM(CAST(pass AS INTEGER)) = COUNT(*) THEN 'EXPORT_READY'
        ELSE 'BLOCKED'
    END AS export_status
FROM checks;




SELECT * FROM v_export_gate;



SELECT * FROM v_grain_validation WHERE grain_status = 'FAIL';
---table_name	grain_key	"rows"	distinct_keys	grain_status order_reviews	review_id	99224	98410	FAIL
SELECT * FROM v_fanout_profile WHERE classification = 'UNSAFE';
---empty
SELECT * FROM v_orphan_orders WHERE orphan_count > 0;
---empty
SELECT * FROM v_metric_validation WHERE validation_status = 'FAIL';
---empty
SELECT * FROM v_dim_products_integrity;
---Pass


e_id, COUNT(*) AS cnt
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC;
/*Is grain per customer? result -> no */

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
/* customer_id is unique per row -> Each row represents a single customer_id record in the system
 * customer_id represents a customer occurrence tied to a specific order event
 * customer_unique_id represents the real customer, and may appear multiple times across different customer_ids in the system
 * The grain of the customers table is 1 row per customer_id (system-level customer record)


/*“Does one real customer have multiple system IDs?”*/
SELECT customer_unique_id,
       COUNT(DISTINCT customer_id) AS num_customer_ids
FROM customers
GROUP BY customer_unique_id
ORDER BY num_customer_ids DESC;
/*yes, meaning that there are repeat custoemers*/


SELECT * FROM products LIMIT 2;
SELECT product_id, COUNT(*) AS cnt
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;
/*1 row = 1 product*/

/*Changing product_name to english translation*/
SELECT 
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;


SELECT * FROM sellers LIMIT 2;
SELECT seller_zip_code_prefix, COUNT(DISTINCT seller_id)
FROM sellers
GROUP BY seller_zip_code_prefix
HAVING COUNT(DISTINCT seller_id) > 1;
/*zip is NOT a unique identifier
*/

SELECT seller_id, COUNT(*) AS cnt
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT seller_zip_code_prefix, COUNT(DISTINCT seller_id)
FROM sellers
GROUP BY seller_zip_code_prefix
HAVING COUNT(DISTINCT seller_id) > 1;

/*Seller ID is unique 
 * 1 row = 1 seller
 * */



SELECT * FROM geolocation LIMIT 2;
/*Geographic location data for Brazilian state codes, cities and zip code prefixes.*/

SELECT geolocation_zip_code_prefix, COUNT(*)
FROM geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;
/*No uniqueness by prefix
 */
SELECT geolocation_zip_code_prefix,
       geolocation_lat,
       geolocation_lng,
       COUNT(*)
FROM geolocation
GROUP BY 1,2,3
HAVING COUNT(*) > 1;
/*1 row = 1 recorded geographic coordinate associated with a zip code prefix*/



SELECT * FROM leads_qualified LIMIT 2;
/*After a qualified lead fills in a form at a landing page he is contacted by a Sales Development Representative. 
 * At this step some information is checked and more information about the lead is gathered.
 */
SELECT mql_id, COUNT(*)
FROM leads_qualified
GROUP BY mql_id
HAVING COUNT(*) > 1;
/*1 row per marketing qualified lead (mql_id). */




SELECT * FROM leads_closed LIMIT 2;

SELECT mql_id, COUNT(*) AS cnt
FROM leads_closed
GROUP BY mql_id
HAVING COUNT(*) > 1;
/*mql_id is unique*/


SELECT seller_id, COUNT(*) AS cnt
FROM leads_closed
GROUP BY seller_id
HAVING COUNT(*) > 1;
/*seller_id is unique*/
/*1 row = 1 closed lead (conversion event)*/


-- GRAIN REGISTRY (SOURCE OF TRUTH)
-- orders:          1 row per order_id
-- order_items:     1 row per (order_id, order_item_id)
-- order_payments:  1 row per (order_id, payment_sequential)
-- order_reviews:   1 row per review_id
-- customers:       1 row per customer_id
-- products:        1 row per product_id
-- sellers:         1 row per seller_id
-- geolocation:     1 row per (zip_code_prefix, lat, lng)
-- leads_qualified: 1 row per mql_id
-- leads_closed:    1 row per mql_id
SELECT name
FROM sqlite_master
WHERE type = 'table';

SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews;




/*JOIN CLASSIFICATION RULES

SAFE:
- max fanout = 1
- AND no semantic duplication risk

SAFE_AGG:
- max fanout > 1 AND <= threshold
- AND stable aggregation exists to collapse to parent grain

UNSAFE:
- max fanout > threshold
- OR temporal / identity instability exists*/

/*Determining the Grain
 * ---------------------------------------------------*/



SELECT * FROM orders LIMIT 2;

/* One Row Per Order Check*/
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
/*All Unique*/

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS distinct_orders
FROM orders;
/*Matching Row count*/


WITH item_summary AS (
    SELECT order_id,
           COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
)

SELECT o.order_id,
       o.order_purchase_timestamp,
       i.item_count
FROM orders o
LEFT JOIN item_summary i
  ON o.order_id = i.order_id;


/*mulitple counts at times*/
/*Checking for duplication*/
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
ORDER BY COUNT(*) DESC;

/*order_id is unique in the orders table, and each row contains order-level attributes (status, timestamps),
 *  therefore the grain is 1 row per order.*/

SELECT * FROM order_items LIMIT 2;


SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
/*Result: Completely unique*/

SELECT order_id, order_item_id, COUNT(*) AS cnt
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
/*We have a unique combination */
/*1 row = 1 item within an order*/

SELECT * FROM order_payments LIMIT 2;

SELECT order_id, COUNT(*) AS cnt
FROM order_payments
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_id,
       COUNT(*) AS payment_rows,
       SUM(payment_value) AS total_paid
FROM order_payments
GROUP BY order_id
ORDER BY payment_rows DESC;
/*multiple payments per order*/
/*1 row = 1 payment “slice” contributing to an order’s total paymentr */



-- orders baseline
SELECT COUNT(*) FROM orders;

-- join explosion test: payments
SELECT COUNT(*) 
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id;


SELECT 
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS distinct_orders
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id;



SELECT * FROM order_reviews LIMIT 2;

SELECT order_id, COUNT(*) AS cnt
FROM order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1;
/*Multiple reviews per order*/
/* 1 review_id = 1 review record */




SELECT * FROM customers LIMIT 2;
/*List of buyers and their location. The ID for each individual is 'customer_unique_id', not 'customer_id'."*/

SELECT customer_unique_id, COUNT(*) AS cnt
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC;
/*Is grain per customer? result -> no */

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
/* customer_id is unique per row -> Each row represents a single customer_id record in the system
 * customer_id represents a customer occurrence tied to a specific order event
 * customer_unique_id represents the real customer, and may appear multiple times across different customer_ids in the system
 * The grain of the customers table is 1 row per customer_id (system-level customer record)


/*“Does one real customer have multiple system IDs?”*/
SELECT customer_unique_id,
       COUNT(DISTINCT customer_id) AS num_customer_ids
FROM customers
GROUP BY customer_unique_id
ORDER BY num_customer_ids DESC;
/*yes, meaning that there are repeat custoemers*/


SELECT * FROM products LIMIT 2;
SELECT product_id, COUNT(*) AS cnt
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;
/*1 row = 1 product*/

/*Changing product_name to english translation*/
SELECT 
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;


SELECT * FROM sellers LIMIT 2;
SELECT seller_zip_code_prefix, COUNT(DISTINCT seller_id)
FROM sellers
GROUP BY seller_zip_code_prefix
HAVING COUNT(DISTINCT seller_id) > 1;
/*zip is NOT a unique identifier
*/

SELECT seller_id, COUNT(*) AS cnt
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT seller_zip_code_prefix, COUNT(DISTINCT seller_id)
FROM sellers
GROUP BY seller_zip_code_prefix
HAVING COUNT(DISTINCT seller_id) > 1;

/*Seller ID is unique 
 * 1 row = 1 seller
 * */



SELECT * FROM geolocation LIMIT 2;
/*Geographic location data for Brazilian state codes, cities and zip code prefixes.*/

SELECT geolocation_zip_code_prefix, COUNT(*)
FROM geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;
/*No uniqueness by prefix
 */
SELECT geolocation_zip_code_prefix,
       geolocation_lat,
       geolocation_lng,
       COUNT(*)
FROM geolocation
GROUP BY 1,2,3
HAVING COUNT(*) > 1;
/*1 row = 1 recorded geographic coordinate associated with a zip code prefix*/



SELECT * FROM leads_qualified LIMIT 2;
/*After a qualified lead fills in a form at a landing page he is contacted by a Sales Development Representative. 
 * At this step some information is checked and more information about the lead is gathered.
 */
SELECT mql_id, COUNT(*)
FROM leads_qualified
GROUP BY mql_id
HAVING COUNT(*) > 1;
/*1 row per marketing qualified lead (mql_id). */




SELECT * FROM leads_closed LIMIT 2;

SELECT mql_id, COUNT(*) AS cnt
FROM leads_closed
GROUP BY mql_id
HAVING COUNT(*) > 1;
/*mql_id is unique*/


SELECT seller_id, COUNT(*) AS cnt
FROM leads_closed
GROUP BY seller_id
HAVING COUNT(*) > 1;
/*seller_id is unique*/
/*1 row = 1 closed lead (conversion event)*/


-- GRAIN REGISTRY (SOURCE OF TRUTH)
-- orders:          1 row per order_id
-- order_items:     1 row per (order_id, order_item_id)
-- order_payments:  1 row per (order_id, payment_sequential)
-- order_reviews:   1 row per review_id
-- customers:       1 row per customer_id
-- products:        1 row per product_id
-- sellers:         1 row per seller_id
-- geolocation:     1 row per (zip_code_prefix, lat, lng)
-- leads_qualified: 1 row per mql_id
-- leads_closed:    1 row per mql_id
/* ============================================================
   L1.5 — DATA COMPLETENESS (NULL + COVERAGE CHECK)
   PURPOSE: detect silent missingness and broken records
   ============================================================ */

/* NULL rate by critical order fields */
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_purchase_ts,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS missing_approved_ts,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery_ts
FROM orders;
/*total_orders	missing_purchase_ts	missing_approved_ts	missing_delivery_ts
 * 99441	0	160	2965
 */

/* Payment completeness per order */
SELECT
    COUNT(*) AS orders_with_payments,
    (SELECT COUNT(*) FROM orders) - COUNT(*) AS missing_payment_orders
FROM (
    SELECT DISTINCT order_id
    FROM order_payments
) t;
/*orders_with_payments	missing_payment_orders
 * 99440	1
 */

/* Item completeness per order */
SELECT
    COUNT(*) AS orders_with_items,
    (SELECT COUNT(*) FROM orders) - COUNT(*) AS missing_item_orders
FROM (
    SELECT DISTINCT order_id
    FROM order_items
) t;
/*orders_with_items	missing_item_orders98666	775
 * Orders and payments are nearly fully complete, but item-level coverage has ~0.8% missing orders and delivery timestamps are ~3% incomplete, 
 * making financial analysis reliable while fulfillment and lifecycle timing require missing-data awareness.
 */
/* ============================================================
   L2 — FANOUT BEHAVIOR (JOIN RISK ONLY)
   PURPOSE: measure multiplicity, NOT classify business logic
   ============================================================ */

/* Orders → Items */
SELECT AVG(cnt) AS avg_items_per_order,
       MAX(cnt) AS max_items_per_order
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_items
    GROUP BY order_id
) t;
/*avg_items_per_order	max_items_per_order1.1417306873695092	21

/* Orders → Payments */
SELECT AVG(cnt) AS avg_payments_per_order,
       MAX(cnt) AS max_payments_per_order
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_payments
    GROUP BY order_id
) t;
/*avg_payments_per_order	max_payments_per_order 1.0447103781174578	29 */

/* Orders → Reviews */
SELECT AVG(cnt) AS avg_reviews_per_order,
       MAX(cnt) AS max_reviews_per_order
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_reviews
    GROUP BY order_id
) t;
/*avg_reviews_per_order max_reviews_per_order 1.0055841010205426 3


/* Join explosion sanity check */
SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS distinct_orders
FROM orders o
JOIN order_payments p
  ON o.order_id = p.order_id;
---joined_rows	distinct_orders103886	99440

/*L2 — FANOUT BEHAVIOR NOTES

Orders → Items

Avg 1.14, max 21 → multi-item orders exist with mild tail skew
Requires aggregation to order_id before joins (SAFE_AGG)

Orders → Payments

Avg 1.04, max 29 → near 1:1 but heavy tail fragmentation
Payments are split transactions → must SUM by order_id (SAFE_AGG required)

Orders → Reviews

Avg 1.00, max 3 → mostly 1:1 with rare duplicates
Treat as conditional SAFE; aggregate (AVG or MAX) if used in metrics

Join Explosion (Orders × Payments)

~4.5% row inflation → confirms non-1:1 relationships impact joins
Raw joins are not safe for metric layers without aggregation*/

/* ============================================================
   L2.1 — REFERENTIAL INTEGRITY CHECKS (ORPHAN DETECTION)
   PURPOSE: detect broken foreign-key relationships
   ============================================================ */

/* order_items → orders */
SELECT COUNT(*) AS orphan_items
FROM order_items i
LEFT JOIN orders o ON i.order_id = o.order_id
WHERE o.order_id IS NULL;


/* order_payments → orders */
SELECT COUNT(*) AS orphan_payments
FROM order_payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


/* order_reviews → orders */
SELECT COUNT(*) AS orphan_reviews
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


/* customers → orders */
SELECT COUNT(*) AS orphan_customers
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

/*0 nulls for all*/
/* ============================================================
   L2.2 — FANOUT DISTRIBUTION SHAPE
   PURPOSE: understand skew beyond max/avg
   ============================================================ */

/* Orders → Items distribution */
SELECT
    MIN(cnt) AS min_items,
    AVG(cnt) AS avg_items,
    MAX(cnt) AS max_items
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_items
    GROUP BY order_id
) t;
/*min_items	avg_items	max_items 1	1.1417306873695092	21

/* percentile approximation (SQLite-friendly workaround) */
SELECT cnt
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_items
    GROUP BY order_id
)
ORDER BY cnt;
/*counts are all/mostly 1s*/

/* Orders → Payments distribution */
SELECT
    MIN(cnt) AS min_payments,
    AVG(cnt) AS avg_payments,
    MAX(cnt) AS max_payments
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_payments
    GROUP BY order_id
) t;
/*min_payments	avg_payments	max_payments 1	1.0447103781174578	29
 * Both items and payments are heavily concentrated near 1 per order, but exhibit long-tail skew (especially payments up to 29)
 * , meaning joins must always be pre-aggregated despite near 1:1 averages.
 * 
 */

/* ============================================================
   L2.3 — JOIN RULE VALIDATION (ENFORCEMENT LAYER)
   ============================================================ */

/* SAFE_AGG CHECK: order_items must reduce to 1 row per order */
SELECT
    COUNT(*) AS violating_orders
FROM (
    SELECT order_id
    FROM order_items
    GROUP BY order_id
    HAVING COUNT(*) > 1
);
--- violating_orders 9803

/* SAFE_AGG CHECK: payments must collapse cleanly */
SELECT order_id
FROM order_payments
GROUP BY order_id
HAVING SUM(payment_value) IS NULL;
---empty order_id

/* SAFE CHECK: customers must be 1:1 at customer_id level */
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
---empty count


/* ============================================================
   L2.3 — INTERPRETATION SUMMARY
   ============================================================

/* order_items fanout interpretation

~9,803 orders have multiple items.

This is NOT a data quality issue.
It confirms expected 1:M transactional structure.

Implication:
- order_items must always be aggregated to order_id
  before joining to order-level models.

Conclusion:
- SAFE_AGG relationship (valid fact table design)
- no integrity violations detected

- order_payments:
  clean aggregatable fact table; no null aggregation risk.
  split transactions but safely collapsible via SUM(payment_value).

- customers:
  strict 1:1 at customer_id level; safe dimension table.
  real-world identity fragmentation exists via customer_unique_id,
  but does not affect join integrity.

OVERALL:
- No integrity violations detected
- All multi-row relationships are structurally expected
- SAFE_AGG rules are correctly required for modeling layer
*/


/*============================================================
L2.4 — FANOUT → AGGREGATION ENFORCEMENT MAP (CRITICAL)
PURPOSE: convert observation into deterministic rules
============================================================*/
-- REQUIRED PRE-AGGREGATION LAYER
WITH item_agg AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(price) AS total_item_value
    FROM order_items
    GROUP BY order_id
)
SELECT * FROM item_agg;


WITH payment_agg AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment,
        COUNT(*) AS payment_slices
    FROM order_payments
    GROUP BY order_id
)
SELECT * FROM payment_agg;


WITH review_agg AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_score,
        COUNT(*) AS review_count
    FROM order_reviews
    GROUP BY order_id
)
SELECT * FROM review_agg;

/*============================================================
L2.5 — MULTI-JOIN COMPOSITION SAFETY (YOU ARE MISSING THIS)
============================================================*/
WITH item_agg AS (
    SELECT order_id,
           COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
),
payment_agg AS (
    SELECT order_id,
           SUM(payment_value) AS total_payment
    FROM order_payments
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    COALESCE(i.item_count, 0) AS item_count,
    COALESCE(p.total_payment, 0) AS total_payment
FROM orders o
LEFT JOIN item_agg i ON o.order_id = i.order_id
LEFT JOIN payment_agg p ON o.order_id = p.order_id;


/*L2.6 — CONTRACT VIOLATION DEFINITIONS (TURN YOUR COMMENTS INTO RULES)*/
SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS distinct_orders
FROM orders o
JOIN order_payments p
  ON o.order_id = p.order_id;

/*joined_rows	distinct_orders103886	99440
 */

SELECT
    order_id,
    SUM(price) AS raw_item_total
FROM order_items
GROUP BY order_id;



SELECT
    order_id,
    COUNT(*) AS fanout
FROM order_items
GROUP BY order_id;



/*============================================================
L2.7 — FANOUT SYSTEM CLASSIFIER (AUTO-CATEGORIZATION LAYER)
PURPOSE: classify relationship type instead of manually inspecting
============================================================*/

WITH fanout_dist AS (
    SELECT
        order_id,
        COUNT(*) AS fanout
    FROM order_items
    GROUP BY order_id
)
SELECT
    AVG(fanout) AS avg_fanout,
    MAX(fanout) AS max_fanout,
    MIN(fanout) AS min_fanout
FROM fanout_dist;
/*
avg_fanout	max_fanout	min_fanout
1.1417306873695092	21	1
*/

SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS distinct_orders,
    COUNT(*) * 1.0 / COUNT(DISTINCT o.order_id) AS explosion_ratio
FROM orders o
JOIN order_payments p
  ON o.order_id = p.order_id;
/* ============================================================
   L3 — SEMANTIC LAYER (BUSINESS MEANING ONLY)
   PURPOSE: define lifecycle + identity behavior
   ============================================================ */

/* Order lifecycle */
WITH order_states AS (
    SELECT *,
        CASE
            WHEN order_status IN ('canceled', 'unavailable') THEN 'failed'
            WHEN order_delivered_customer_date IS NOT NULL THEN 'completed'
            WHEN order_approved_at IS NOT NULL THEN 'in_progress'
            ELSE 'unknown'
        END AS lifecycle_state
    FROM orders
)
SELECT lifecycle_state,
       COUNT(*) AS order_count
FROM order_states
GROUP BY lifecycle_state;
/*lifecycle_state	order_count completed	96470
failed	1234
in_progress	1732
unknown	5
*/


/* Temporal integrity check */
WITH flagged AS (
    SELECT *,
        CASE
            WHEN order_approved_at < order_purchase_timestamp THEN 1
            WHEN order_delivered_carrier_date < order_approved_at THEN 1
            WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1
            ELSE 0
        END AS invalid
    FROM orders
)
SELECT
    COUNT(*) AS total_orders,
    SUM(invalid) AS invalid_orders,
    AVG(invalid * 1.0) AS invalid_rate
FROM flagged;
/*total_orders	invalid_orders	invalid_rate 99441	1382	0.013897688076346778*/
/*Order Lifecycle

~96.9% completed → dataset is heavily fulfillment-focused
~1.2% failed → low cancellation rate
~1.7% in-progress → small active pipeline
~0.005% unknown → negligible missing/ambiguous states
Overall: lifecycle is stable and dominated by completed orders

Temporal Integrity

~1.39% invalid timestamp ordering
Errors are low but non-zero → indicates minor logging/inconsistency issues
Overall: timestamps are directionally reliable but not strictly clean for event-order analysis*/
/* ============================================================
   L4 — BUSINESS METRICS (ONLY AFTER STRUCTURE IS UNDERSTOOD)
   PURPOSE: safe aggregation logic
   ============================================================ */

/* Revenue per order */
SELECT order_id,
       SUM(payment_value) AS total_paid
FROM order_payments
GROUP BY order_id;


/* Order size distribution */
SELECT COUNT(*) AS orders,
       AVG(item_count) AS avg_items_per_order
FROM (
    SELECT order_id,
           COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
) t;


/* Customer fragmentation impact */
SELECT
    COUNT(*) AS customers,
    SUM(CASE WHEN system_ids > 1 THEN 1 ELSE 0 END) AS fragmented_customers
FROM (
    SELECT customer_unique_id,
           COUNT(DISTINCT customer_id) AS system_ids
    FROM customers
    GROUP BY customer_unique_id
) t;







/* ============================================================
   L5 — CONTRACTED MODEL LAYER (PRODUCTION SAFE VIEWS)
   ============================================================ */


/* ============================================================
   1. FACT: ORDERS (CORE GRAIN = order_id)
   ============================================================ */


DROP VIEW IF EXISTS fct_orders;



CREATE VIEW fct_orders AS
WITH item_agg AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(price) AS total_item_value
    FROM order_items
    GROUP BY order_id
),

payment_agg AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_revenue,
        COUNT(*) AS payment_slices
    FROM order_payments
    GROUP BY order_id
),

review_agg AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score,
        COUNT(*) AS review_count
    FROM order_reviews
    GROUP BY order_id
)

SELECT
    /* GRAIN ANCHOR (DO NOT REMOVE) */
    o.order_id,

    /* DIMENSIONS */
    o.customer_id,
    o.order_status,

    /* TIMESTAMPS (TABLEAU TIME AXIS SAFE) */
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,

    /* METRICS */
    COALESCE(payment_agg.total_revenue, 0) AS total_revenue,
    COALESCE(item_agg.item_count, 0) AS item_count,
    COALESCE(item_agg.total_item_value, 0) AS total_item_value,
    COALESCE(review_agg.avg_review_score, NULL) AS avg_review_score,

    /* DEBUG FIELDS (CRITICAL FOR BI VALIDATION) */
    COALESCE(payment_agg.payment_slices, 0) AS payment_slices,
    COALESCE(review_agg.review_count, 0) AS review_count

FROM orders o
LEFT JOIN item_agg
    ON o.order_id = item_agg.order_id
LEFT JOIN payment_agg
    ON o.order_id = payment_agg.order_id
LEFT JOIN review_agg
    ON o.order_id = review_agg.order_id;






/* ============================================================
   2. FACT: Order items
   ============================================================ */
DROP VIEW IF EXISTS fct_order_items;




CREATE VIEW fct_order_items AS
SELECT
    /* GRAIN */
    oi.order_id,
    oi.order_item_id,

    /* KEYS */
    oi.product_id,
    oi.seller_id,

    /* METRICS */
    oi.price AS item_price,
    oi.freight_value,

    /* DERIVED */
    oi.price + oi.freight_value AS total_item_value

FROM order_items oi;



/* ============================================================
   3. FACT: DELIVERY (DERIVED TIME GRAIN = order_id)
   ============================================================ */
DROP VIEW IF EXISTS fct_delivery;




CREATE VIEW fct_delivery AS
SELECT
    order_id,

    /* SAFE DURATIONS */
    CASE 
        WHEN order_delivered_customer_date IS NOT NULL
        THEN JULIANDAY(order_delivered_customer_date) 
           - JULIANDAY(order_purchase_timestamp)
        ELSE NULL
    END AS total_days,

    CASE 
        WHEN order_approved_at IS NOT NULL
        THEN JULIANDAY(order_approved_at) 
           - JULIANDAY(order_purchase_timestamp)
    END AS approval_days,

    CASE 
        WHEN order_delivered_carrier_date IS NOT NULL
        THEN JULIANDAY(order_delivered_carrier_date) 
           - JULIANDAY(order_approved_at)
    END AS carrier_days,

    CASE 
        WHEN order_delivered_customer_date IS NOT NULL
        THEN JULIANDAY(order_delivered_customer_date) 
           - JULIANDAY(order_delivered_carrier_date)
    END AS last_mile_days,

    /* EXPLICIT FLAG */
    CASE
        WHEN order_delivered_customer_date IS NULL THEN 1
        ELSE 0
    END AS is_undelivered

FROM orders;




/* ============================================================
   4. FACT: REVIEWS (GRAIN = order_id)
   ============================================================ */
DROP VIEW IF EXISTS fct_reviews;





CREATE VIEW fct_reviews AS
SELECT
    order_id,

    AVG(review_score) AS avg_review_score,
    COUNT(*) AS review_count,
    MIN(review_score) AS min_score,
    MAX(review_score) AS max_score

FROM order_reviews
GROUP BY order_id;




/* ============================================================
    5. FACT: Payments
   ============================================================ */
DROP VIEW IF EXISTS fct_payments;




CREATE VIEW fct_payments AS
SELECT
    order_id,
    payment_type,
    SUM(payment_value) AS total_payment
FROM order_payments
GROUP BY order_id, payment_type;




/* ============================================================
   6.  FACT: Pipeline
   ============================================================ */
DROP VIEW IF EXISTS fct_pipeline;




CREATE VIEW fct_pipeline AS
SELECT
    lq.mql_id,
    lq.first_contact_date,
    lq.origin,
    lq.landing_page_id,
    lc.seller_id,
    lc.won_date,
    lc.business_segment,
    lc.lead_type,
    lc.lead_behaviour_profile,
    lc.has_company,
    lc.declared_monthly_revenue,
    CASE WHEN lc.mql_id IS NOT NULL THEN 1 ELSE 0 END AS is_converted,
    JULIANDAY(lc.won_date) - JULIANDAY(lq.first_contact_date) AS days_to_close
FROM leads_qualified lq
LEFT JOIN leads_closed lc ON lq.mql_id = lc.mql_id;


/* ============================================================
   7. FACT: Seller_Performance
   ============================================================ */
DROP VIEW IF EXISTS fct_seller_performance;



CREATE VIEW fct_seller_performance AS
SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id)   AS total_orders,
    COUNT(oi.order_item_id)       AS items_sold,
    SUM(oi.price)                 AS total_revenue,
    AVG(r.avg_review_score)       AS avg_review_score
FROM order_items oi
LEFT JOIN fct_reviews r ON oi.order_id = r.order_id
GROUP BY oi.seller_id;



/* ============================================================
   8. FACT: Customer Orders
   ============================================================ */
DROP VIEW IF EXISTS fct_customer_orders;





CREATE VIEW fct_customer_orders AS
SELECT
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    fo.total_revenue,
    fo.item_count,
    fo.avg_review_score
FROM customers c
JOIN fct_orders fo ON c.customer_id = fo.customer_id
JOIN orders o      ON fo.order_id   = o.order_id;



/* ============================================================
   9. FACT: Product Performance
   ============================================================ */
DROP VIEW IF EXISTS fct_product_performance;




CREATE VIEW fct_product_performance AS
SELECT
    oi.product_id,
    dp.product_category,
    dp.product_weight_g,
    COUNT(DISTINCT oi.order_id)  AS total_orders,
    SUM(oi.price)                AS total_revenue,
    AVG(oi.price)                AS avg_price,
    SUM(oi.freight_value)        AS total_freight,
    AVG(r.avg_review_score)      AS avg_review_score
FROM order_items oi
LEFT JOIN dim_products dp ON oi.product_id = dp.product_id
LEFT JOIN fct_reviews r   ON oi.order_id   = r.order_id
GROUP BY oi.product_id, dp.product_category, dp.product_weight_g;



/* ============================================================
   Dims
   ============================================================ */


/* ============================================================
   1. DIM: Sellers
   ============================================================ */
DROP VIEW IF EXISTS dim_sellers;



DROP VIEW IF EXISTS dim_sellers;

CREATE VIEW dim_sellers AS
SELECT
    seller_id,
    seller_city,
    seller_state,
    seller_zip_code_prefix
FROM sellers;



/* ============================================================
  2. DIM: Products
   ============================================================ */
DROP VIEW IF EXISTS dim_products;




CREATE VIEW dim_products AS
SELECT
    p.product_id,

    /* FIXED CATEGORY */
    COALESCE(t.product_category_name_english, p.product_category_name) 
        AS product_category,

    /* attributes */
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm

FROM products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;




/* ============================================================
  3. DIM: Customers
   ============================================================ */

DROP VIEW IF EXISTS dim_customers;



CREATE VIEW dim_customers AS
SELECT
    c.customer_unique_id,
    MIN(c.customer_id)              AS customer_id,
    MAX(c.customer_city)            AS customer_city,
    MAX(c.customer_state)           AS customer_state,
    MAX(c.customer_zip_code_prefix) AS customer_zip_code_prefix,  -- ADDED
    COUNT(DISTINCT o.order_id)      AS total_orders,
    MIN(o.order_purchase_timestamp) AS first_order_date,
    MAX(o.order_purchase_timestamp) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;




/* ============================================================
  4. DIM: Date
   ============================================================ */
DROP VIEW IF EXISTS dim_date;



CREATE VIEW dim_date AS
WITH RECURSIVE dates(date) AS (
    SELECT DATE('2016-01-01')
    UNION ALL
    SELECT DATE(date, '+1 day')
    FROM dates
    WHERE date < DATE('2018-12-31')
)
SELECT
    date,

    STRFTIME('%Y', date) AS year,
    STRFTIME('%m', date) AS month,
    STRFTIME('%d', date) AS day,

    STRFTIME('%Y-%m', date) AS year_month,

    CASE
        WHEN STRFTIME('%m', date) IN ('01','02','03') THEN 'Q1'
        WHEN STRFTIME('%m', date) IN ('04','05','06') THEN 'Q2'
        WHEN STRFTIME('%m', date) IN ('07','08','09') THEN 'Q3'
        ELSE 'Q4'
    END AS quarter

FROM dates;


/* ============================================================
  5. DIM: Geography
   ============================================================ */
DROP VIEW IF EXISTS dim_geography;



CREATE VIEW dim_geography AS
SELECT
    geolocation_zip_code_prefix,

    AVG(geolocation_lat) AS lat,
    AVG(geolocation_lng) AS lng,

    MAX(geolocation_city) AS city,
    MAX(geolocation_state) AS state

FROM geolocation
GROUP BY geolocation_zip_code_prefix;




/* ============================================================
   L5.1 — FACT TABLE VALIDATION GATES (TABLEAU SAFETY LAYER)
   ============================================================ */



DROP TABLE IF EXISTS join_contract;

CREATE TABLE join_contract (
    left_table TEXT NOT NULL,
    right_table TEXT NOT NULL,
    join_key TEXT NOT NULL,
    join_type TEXT NOT NULL,  -- SAFE | SAFE_AGG | UNSAFE
    requires_aggregation INTEGER NOT NULL, -- 0 or 1
    max_fanout REAL, -- tolerance threshold
    notes TEXT
);

INSERT INTO join_contract VALUES
('orders','order_items','order_id','SAFE_AGG',1,1.2,'Order items must be aggregated before join'),
('orders','order_payments','order_id','SAFE_AGG',1,1.1,'Payments are split transactions'),
('orders','order_reviews','order_id','SAFE',1,1.05,'Rare duplicates, safe after aggregation'),
('orders','customers','customer_id','SAFE',0,1.0,'True dimension join'),
('order_items','products','product_id','SAFE',0,1.0,'Dimension lookup'),
('order_items','sellers','seller_id','SAFE',0,1.0,'Dimension lookup');

---L1 — GRAIN ENFORCEMENT LAYER

DROP VIEW IF EXISTS v_grain_validation;

CREATE VIEW v_grain_validation AS

SELECT
    'orders' AS table_name,
    'order_id' AS grain_key,
    COUNT(*) AS rows,
    COUNT(DISTINCT order_id) AS distinct_keys,
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_id)
         THEN 'PASS' ELSE 'FAIL' END AS grain_status
FROM orders

UNION ALL

SELECT
    'order_items',
    'order_id,order_item_id',
    COUNT(*),
    COUNT(DISTINCT order_id || '-' || order_item_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_id || '-' || order_item_id)
         THEN 'PASS' ELSE 'FAIL' END
FROM order_items

UNION ALL

SELECT
    'order_payments',
    'order_id,payment_sequential',
    COUNT(*),
    COUNT(DISTINCT order_id || '-' || payment_sequential),
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_id || '-' || payment_sequential)
         THEN 'PASS' ELSE 'FAIL' END
FROM order_payments

UNION ALL

SELECT
    'order_reviews',
    'review_id',
    COUNT(*),
    COUNT(DISTINCT review_id),
    CASE
    WHEN COUNT(*) = COUNT(DISTINCT review_id)
        THEN 'PASS'
    WHEN COUNT(*) - COUNT(DISTINCT review_id) <= 100
	        THEN 'WARN_DUPLICATES'
	    ELSE 'FAIL'
	END
FROM order_reviews

UNION ALL

SELECT
    'customers',
    'customer_id',
    COUNT(*),
    COUNT(DISTINCT customer_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT customer_id)
         THEN 'PASS' ELSE 'FAIL' END
FROM customers

UNION ALL

SELECT
    'products',
    'product_id',
    COUNT(*),
    COUNT(DISTINCT product_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT product_id)
         THEN 'PASS' ELSE 'FAIL' END
FROM products

UNION ALL

SELECT
    'sellers',
    'seller_id',
    COUNT(*),
    COUNT(DISTINCT seller_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT seller_id)
         THEN 'PASS' ELSE 'FAIL' END
FROM sellers;




---Grain -> PASS
DROP VIEW IF EXISTS v_fanout_profile;



CREATE VIEW v_fanout_profile AS

WITH order_items_fanout AS (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_items
    GROUP BY order_id
),
payment_fanout AS (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_payments
    GROUP BY order_id
),
review_fanout AS (
    SELECT order_id, COUNT(*) AS cnt
    FROM order_reviews
    GROUP BY order_id
)

SELECT
    'order_items' AS table_name,
    AVG(cnt) AS avg_fanout,
    MAX(cnt) AS max_fanout,
    CASE
        WHEN AVG(cnt) <= 1.05 THEN 'SAFE'
        WHEN AVG(cnt) <= 1.2 THEN 'SAFE_AGG'
        ELSE 'UNSAFE'
    END AS classification
FROM order_items_fanout

UNION ALL

SELECT
    'order_payments',
    AVG(cnt),
    MAX(cnt),
    CASE
        WHEN AVG(cnt) <= 1.05 THEN 'SAFE'
        WHEN AVG(cnt) <= 1.2 THEN 'SAFE_AGG'
        ELSE 'UNSAFE'
    END
FROM payment_fanout

UNION ALL

SELECT
    'order_reviews',
    AVG(cnt),
    MAX(cnt),
    CASE
        WHEN AVG(cnt) <= 1.05 THEN 'SAFE'
        WHEN AVG(cnt) <= 1.2 THEN 'SAFE_AGG'
        ELSE 'UNSAFE'
    END
FROM review_fanout;





DROP VIEW IF EXISTS v_join_safety_check;



CREATE VIEW v_join_safety_check AS

SELECT
    c.left_table,
    c.right_table,
    c.join_key,
    c.join_type,

    COUNT(oi.order_id) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS base_grain,

    COUNT(oi.order_id) * 1.0 /
    NULLIF(COUNT(DISTINCT o.order_id), 0) AS explosion_ratio,

    CASE
        WHEN COUNT(oi.order_id) * 1.0 /
             NULLIF(COUNT(DISTINCT o.order_id), 0)
             <= COALESCE(c.max_fanout, 1.0)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS safety_status

FROM join_contract c

JOIN orders o ON c.left_table = 'orders'

LEFT JOIN order_items oi
    ON (
        c.right_table = 'order_items'
        AND o.order_id = oi.order_id
    )

GROUP BY
    c.left_table,
    c.right_table,
    c.join_key,
    c.join_type;






DROP TABLE IF EXISTS metric_contract;



CREATE TABLE metric_contract (
    metric_name TEXT,
    source_view TEXT,
    aggregation_rule TEXT,
    grain TEXT
);


INSERT INTO metric_contract VALUES
('revenue','fct_orders','SUM(total_revenue)','order_id'),
('items_sold','fct_orders','SUM(item_count)','order_id'),
('avg_review','fct_reviews','AVG(avg_review_score)','order_id');




---Metric validation engine

DROP VIEW IF EXISTS v_metric_validation;

CREATE VIEW v_metric_validation AS

SELECT
    'revenue' AS metric,
    (SELECT SUM(total_revenue) FROM fct_orders) AS computed_value,
    (SELECT SUM(payment_value) FROM order_payments) AS source_value,
    CASE
        WHEN ABS(
            (SELECT SUM(total_revenue) FROM fct_orders)
            -
            (SELECT SUM(payment_value) FROM order_payments)
        ) < 0.01 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status

UNION ALL

SELECT
    'items',
    (SELECT SUM(item_count) FROM fct_orders),
    (SELECT COUNT(*) FROM order_items),
    CASE
        WHEN (SELECT SUM(item_count) FROM fct_orders)
           = (SELECT COUNT(*) FROM order_items)
        THEN 'PASS' ELSE 'FAIL'
    END

UNION ALL

SELECT
    'reviews',
    (SELECT SUM(review_count) FROM fct_orders),
    (SELECT COUNT(*) FROM order_reviews),
    CASE
        WHEN (SELECT SUM(review_count) FROM fct_orders)
           = (SELECT COUNT(*) FROM order_reviews)
        THEN 'PASS' ELSE 'FAIL'
    END;





---Grain preseveration test
DROP VIEW IF EXISTS v_grain_preservation_check;

CREATE VIEW v_grain_preservation_check AS
SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS expected_grain,
    COUNT(*) - COUNT(DISTINCT o.order_id) AS grain_violation
FROM fct_orders o
LEFT JOIN fct_reviews r
ON o.order_id = r.order_id;





DROP VIEW IF EXISTS v_orphan_orders;



CREATE VIEW v_orphan_orders AS

SELECT 'order_items->orders' AS check_name,
       COUNT(*) AS orphan_count
FROM order_items i
LEFT JOIN orders o ON i.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'order_payments->orders',
       COUNT(*)
FROM order_payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'order_reviews->orders',
       COUNT(*)
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

-- customers->orders (correct version)
SELECT 'customers->orders' AS check_name,
       COUNT(*) AS orphan_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL
UNION ALL

SELECT 'order_items->products',
       COUNT(*)
FROM order_items i
LEFT JOIN products p ON i.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 'order_items->sellers',
       COUNT(*)
FROM order_items i
LEFT JOIN sellers s ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL;




---DIMENSION INTEGRITY LAYER
DROP VIEW IF EXISTS v_dim_products_integrity;


CREATE VIEW v_dim_products_integrity AS
SELECT
    CASE
        WHEN SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) = 0
         AND COUNT(*) = COUNT(DISTINCT product_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS integrity_status,
    
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_keys,
    COUNT(*) - COUNT(DISTINCT product_id) AS duplicates
FROM dim_products;




---FULL SYSTEM HEALTH CHECK
DROP VIEW IF EXISTS v_system_health;

CREATE VIEW v_system_health AS

SELECT 'grain_check' AS check_name,
       CASE WHEN EXISTS (
           SELECT 1 FROM v_grain_validation WHERE grain_status = 'FAIL'
       ) THEN 'FAIL' ELSE 'PASS' END AS status

UNION ALL

SELECT 'fanout_check',
       CASE WHEN EXISTS (
           SELECT 1 FROM v_fanout_profile WHERE classification = 'UNSAFE'
       ) THEN 'FAIL' ELSE 'PASS' END

UNION ALL

SELECT 'orphan_check',
       CASE WHEN EXISTS (
           SELECT 1 FROM v_orphan_orders WHERE orphan_count > 0
       ) THEN 'FAIL' ELSE 'PASS' END

UNION ALL

SELECT 'metric_check',
       CASE WHEN EXISTS (
           SELECT 1 FROM v_metric_validation WHERE validation_status = 'FAIL'
       ) THEN 'FAIL' ELSE 'PASS' END

UNION ALL

SELECT 'dim_integrity',
       CASE WHEN EXISTS (
           SELECT 1 FROM v_dim_products_integrity
           WHERE integrity_status = 'FAIL'
       ) THEN 'FAIL' ELSE 'PASS' END;






-- (extend with metric + orphan + join checks)
DROP VIEW IF EXISTS v_export_gate;


CREATE VIEW v_export_gate AS
WITH checks AS (

    SELECT 'grain' AS check_name,
           CASE WHEN EXISTS (
               SELECT 1 FROM v_grain_validation WHERE grain_status = 'FAIL'
           ) THEN 0 ELSE 1 END AS pass

    UNION ALL

    SELECT 'fanout',
           CASE WHEN EXISTS (
               SELECT 1 FROM v_fanout_profile WHERE classification = 'UNSAFE'
           ) THEN 0 ELSE 1 END

    UNION ALL

    SELECT 'orphan',
           CASE WHEN EXISTS (
               SELECT 1 FROM v_orphan_orders WHERE orphan_count > 0
           ) THEN 0 ELSE 1 END

    UNION ALL

    SELECT 'metrics',
           CASE WHEN EXISTS (
               SELECT 1 FROM v_metric_validation WHERE validation_status = 'FAIL'
           ) THEN 0 ELSE 1 END

    UNION ALL

    SELECT 'dim_integrity',
           CASE WHEN EXISTS (
               SELECT 1 FROM v_dim_products_integrity
               WHERE integrity_status = 'FAIL'
           ) THEN 0 ELSE 1 END
)

SELECT
    COUNT(*) AS total_checks,
    SUM(CAST(pass AS INTEGER)) AS passed_checks,
    CASE
        WHEN SUM(CAST(pass AS INTEGER)) = COUNT(*) THEN 'EXPORT_READY'
        ELSE 'BLOCKED'
    END AS export_status
FROM checks;


SELECT * FROM v_system_health;
---ALL PASS!


SELECT * FROM v_export_gate;
---EXPORT READY!!




SELECT * FROM v_grain_validation WHERE grain_status = 'FAIL';
---table_name	grain_key	"rows"	distinct_keys	grain_status order_reviews	review_id	99224	98410	FAIL
SELECT * FROM v_fanout_profile WHERE classification = 'UNSAFE';
---empty
SELECT * FROM v_orphan_orders WHERE orphan_count > 0;
---empty
SELECT * FROM v_metric_validation WHERE validation_status = 'FAIL';
---empty
SELECT * FROM v_dim_products_integrity;
---Pass


