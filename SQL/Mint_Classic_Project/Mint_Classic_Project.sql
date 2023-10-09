-- MSPR stands for "manufacturer's suggested retail price"

-- Check the current storage of each warehouse
SELECT 
	p.warehouseCode,
	w.warehouseName,
	SUM(quantityInStock) AS total_in_stock
FROM products AS p
LEFT JOIN warehouses AS w
USING(warehouseCode)
GROUP BY p.warehouseCode
ORDER BY SUM(quantityInStock) DESC;


-- Find out which warehosue has the lowest sells
SELECT 
	w.warehouseCode, 
	w.warehouseName,
	COUNT(od.orderNumber) AS total_orders
FROM warehouses AS w
LEFT JOIN products AS p USING(warehouseCode)
LEFT JOIN orderdetails od USING(productCode)
GROUP BY 
	w.warehouseCode, 
	w.warehouseName
ORDER BY total_orders DESC;

-- Products with consistently high quantity levels but low orders
WITH TotalQuantity AS (
    SELECT 
	productCode, 
        productName, 
        SUM(quantityInStock) AS total_quantity
    FROM products
    GROUP BY 
	productCode, 
        productName
),
TotalOrders AS (
    SELECT 
	p.productCode, 
        p.productName, 
        SUM(od.quantityOrdered) AS total_orders
    FROM products AS p
    LEFT JOIN orderdetails od USING(productCode)
    LEFT JOIN orders AS o USING(orderNumber)
    WHERE o.status = "Shipped"
    GROUP BY 
	p.productCode, 
        p.productName
)
SELECT 
	tq.productCode, 
	tq.productName, 
	tq.total_quantity,
	ts.total_orders,
	ROUND((ts.total_orders / (tq.total_quantity+ts.total_orders))*100, 2)  AS sales_rate_pct
FROM TotalQuantity AS tq
LEFT JOIN TotalOrders ts USING(productCode)
ORDER BY sales_rate_pct DESC
LIMIT 5;

-- find the Utilization Rate
SELECT
    w.warehouseName,
    w.warehousePctCap,
    SUM(p.quantityInStock) AS total_quantity,
    ROUND((SUM(p.quantityInStock) / w.warehousePctCap) / 100, 2) AS utilization_rate_pct
FROM
    warehouses AS w
LEFT JOIN
    products AS p USING(warehouseCode)
GROUP BY
    w.warehouseName,
    w.warehousePctCap
ORDER BY
    utilization_rate_pct DESC;
