--******************************************************************************************************************************--
--********   SQL SCHEMA **********************************************************************************************************************--

Create table If Not Exists Transactions (id int, country varchar(4), state enum('approved', 'declined'), amount int, trans_date date)
Truncate table Transactions
insert into Transactions (id, country, state, amount, trans_date) values ('121', 'US', 'approved', '1000', '2018-12-18')
insert into Transactions (id, country, state, amount, trans_date) values ('122', 'US', 'declined', '2000', '2018-12-19')
insert into Transactions (id, country, state, amount, trans_date) values ('123', 'US', 'approved', '2000', '2019-01-01')
insert into Transactions (id, country, state, amount, trans_date) values ('124', 'DE', 'approved', '2000', '2019-01-07')

--************DESCRIPTION OF THE PROBLEM ******************************************************************************************************************-- 
Table: Transactions

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| country       | varchar |
| state         | enum    |
| amount        | int     |
| trans_date    | date    |
+---------------+---------+
id is the primary key of this table.
The table has information about incoming transactions.
The state column is an enum of type ["approved", "declined"].
 

Write an SQL query to find for each month and country, the number of transactions and their total amount, the number of approved transactions and their total amount.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Transactions table:
+------+---------+----------+--------+------------+
| id   | country | state    | amount | trans_date |
+------+---------+----------+--------+------------+
| 121  | US      | approved | 1000   | 2018-12-18 |
| 122  | US      | declined | 2000   | 2018-12-19 |
| 123  | US      | approved | 2000   | 2019-01-01 |
| 124  | DE      | approved | 2000   | 2019-01-07 |
+------+---------+----------+--------+------------+
Output: 
+----------+---------+-------------+----------------+--------------------+-----------------------+
| month    | country | trans_count | approved_count | trans_total_amount | approved_total_amount |
+----------+---------+-------------+----------------+--------------------+-----------------------+
| 2018-12  | US      | 2           | 1              | 3000               | 1000                  |
| 2019-01  | US      | 1           | 1              | 2000               | 2000                  |
| 2019-01  | DE      | 1           | 1              | 2000               | 2000                  |
+----------+---------+-------------+----------------+--------------------+-----------------------+


--******************************************************************************************************************************-- 

--****************** SOLUTION 1 :  Using Conditional Aggregation   ************************************************************************************************************-- 

SELECT 
    DATE_FORMAT(trans_date, '%Y-%m') AS month,
    country,
    COUNT(*) AS trans_count,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM 
    Transactions
GROUP BY 
    DATE_FORMAT(trans_date, '%Y-%m'), country;


--****************** SOLUTION 2 :  Using Subqueries  ************************************************************************************************************-- 
SELECT 
    DATE_FORMAT(t.trans_date, '%Y-%m') AS month,
    t.country,
    COUNT(*) AS trans_count,
    (SELECT COUNT(*) FROM Transactions t2 WHERE t2.country = t.country AND DATE_FORMAT(t2.trans_date, '%Y-%m') = DATE_FORMAT(t.trans_date, '%Y-%m') AND t2.state = 'approved') AS approved_count,
    SUM(t.amount) AS trans_total_amount,
    (SELECT SUM(t2.amount) FROM Transactions t2 WHERE t2.country = t.country AND DATE_FORMAT(t2.trans_date, '%Y-%m') = DATE_FORMAT(t.trans_date, '%Y-%m') AND t2.state = 'approved') AS approved_total_amount
FROM 
    Transactions t
GROUP BY 
    DATE_FORMAT(t.trans_date, '%Y-%m'), t.country;


--****************** SOLUTION 3  : Using Common Table Expressions (CTEs) ************************************************************************************************************-- 
WITH TransCounts AS (
    SELECT 
        DATE_FORMAT(trans_date, '%Y-%m') AS month,
        country,
        COUNT(*) AS trans_count,
        SUM(amount) AS trans_total_amount
    FROM 
        Transactions
    GROUP BY 
        DATE_FORMAT(trans_date, '%Y-%m'), country
),
ApprovedCounts AS (
    SELECT 
        DATE_FORMAT(trans_date, '%Y-%m') AS month,
        country,
        COUNT(*) AS approved_count,
        SUM(amount) AS approved_total_amount
    FROM 
        Transactions
    WHERE 
        state = 'approved'
    GROUP BY 
        DATE_FORMAT(trans_date, '%Y-%m'), country
)
SELECT 
    t.month,
    t.country,
    t.trans_count,
    IFNULL(a.approved_count, 0) AS approved_count,
    t.trans_total_amount,
    IFNULL(a.approved_total_amount, 0) AS approved_total_amount
FROM 
    TransCounts t
LEFT JOIN 
    ApprovedCounts a ON t.month = a.month AND t.country = a.country;



--******************************************************************************************************************************-- 

