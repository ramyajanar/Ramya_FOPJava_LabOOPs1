use ecommerce;
    
/*Display the total number of customers based on gender who have placed orders of worth at least Rs.3000.*/
SELECT 
    COUNT(cus_id) AS NoOfCustomers,cus_gender
FROM
    customer
WHERE
    cus_id IN (SELECT DISTINCT
            cus_id
        FROM
            `order`
        WHERE
            ORD_AMOUNT >= 3000)
GROUP BY cus_gender;

/*Display all the orders along with product name ordered by a customer having Customer_Id=2*/
SELECT 
    product.pro_name, `order`.*
FROM
    `order`,
    supplier_pricing,
    product
WHERE
    `order`.cus_id = 2
        AND `order`.pricing_id = supplier_pricing.pricing_id
        AND supplier_pricing.pro_id = product.pro_id;
        
/*Display the Supplier details who can supply more than one product.*/
SELECT 
    supplier.*
FROM
    supplier
WHERE
    supplier.supp_id IN (SELECT 
            supp_id
        FROM
            supplier_pricing
        GROUP BY supp_id
        HAVING COUNT(supp_id) > 1)
GROUP BY supplier.supp_id;

/*Find the least expensive product from each category and print the table with category id, name, product name and price of the product*/
SELECT 
    category.cat_id,
    category.cat_name,
    MIN(t3.min_price) AS Min_Price
FROM
    category
        INNER JOIN
    (SELECT 
        product.cat_id, product.pro_name, t2.*
    FROM
        product
    INNER JOIN (SELECT 
        pro_id, MIN(supp_price) AS Min_Price
    FROM
        supplier_pricing
    GROUP BY pro_id) AS t2
    WHERE
        t2.pro_id = product.pro_id) AS t3
WHERE
    t3.cat_id = category.cat_id
GROUP BY t3.cat_id;

/*Display the Id and Name of the Product ordered after “2021-10-05”.*/
SELECT 
    product.pro_id, product.pro_name
FROM
    `order`
        INNER JOIN
    supplier_pricing ON supplier_pricing.pricing_id = `order`.pricing_id
        INNER JOIN
    product ON product.pro_id = supplier_pricing.pro_id
WHERE
    `order`.ord_date > '2021-10-05';
    
/*Display customer name and gender whose names start or end with character 'A'.*/

SELECT 
    customer.cus_name, customer.cus_gender
FROM
    customer
WHERE
    customer.cus_name LIKE 'A%'
        OR customer.cus_name LIKE '%A';
        
/*
Create a stored procedure to display supplier id, name, rating and Type_of_Service. For Type_of_Service, If rating =5, print “Excellent
Service”,If rating >4 print “Good Service”, If rating >2 print “Average Service” else print “Poor Service”.
*/
SELECT 
    report.supp_id,
    report.supp_name,
    report.Average,
    CASE
        WHEN report.Average = 5 THEN 'Excellent Service'
        WHEN report.Average > 4 THEN 'Good Service'
        WHEN report.Average > 2 THEN 'Average Service'
        ELSE 'Poor Service'
    END AS Type_of_Service
FROM
    (SELECT 
        final.supp_id, supplier.supp_name, final.Average
    FROM
        (SELECT 
        test2.supp_id,
            SUM(test2.rat_ratstars) / COUNT(test2.rat_ratstars) AS Average
    FROM
        (SELECT 
        supplier_pricing.supp_id, test.ORD_ID, test.RAT_RATSTARS
    FROM
        supplier_pricing
    INNER JOIN (SELECT 
        `order`.pricing_id, rating.ORD_ID, rating.RAT_RATSTARS
    FROM
        `order`
    INNER JOIN rating ON rating.`ord_id` = `order`.ord_id) AS test ON test.pricing_id = supplier_pricing.pricing_id) AS test2
    GROUP BY supplier_pricing.supp_id) AS final
    INNER JOIN supplier
    WHERE
        final.supp_id = supplier.supp_id) AS report
