--Display Male Employees with Net Salary >= 8000
SELECT 
    EMPLOYEE_NUMBER,(FIRST_NAME) AS FIRST_NAME,(LAST_NAME) AS LAST_NAME,FLOOR((CAST (GetDate() AS INTEGER) - CAST(BIRTH_DATE AS INTEGER)) / 365.25) AS Age
FROM  EMPLOYEES
WHERE 
    (SALARY + COALESCE(COMMISSION, 0)) >= 8000
    AND POSITION = 'Mr'  
ORDER BY POSITION DESC;

--Display Products Meeting Specific Criteria
SELECT 
    PRODUCT_REF,
    PRODUCT_NAME,
    SUPPLIER_NUMBER,
    UNITS_ON_ORDER,
    UNIT_PRICE
FROM 
    PRODUCTS
WHERE 
    QUANTITY = 'bottle(s)'
    AND (SUBSTRING(PRODUCT_NAME, 3, 1) = 't' OR SUBSTRING(PRODUCT_NAME, 3, 1) = 'T')
    AND SUPPLIER_NUMBER IN (1, 2, 3)
    AND UNIT_PRICE BETWEEN 70 AND 200
    AND UNITS_ON_ORDER IS NOT NULL;

--Display Customers Residing in the Same Region as Supplier 1
SELECT *
FROM CUSTOMERS
WHERE 
    COUNTRY = (SELECT COUNTRY FROM SUPPLIERS WHERE SUPPLIER_NUMBER = 1)
    AND CITY = (SELECT CITY FROM SUPPLIERS WHERE SUPPLIER_NUMBER = 1)
    AND RIGHT(POSTAL_CODE, 3) = (SELECT RIGHT(POSTAL_CODE, 3) FROM SUPPLIERS WHERE SUPPLIER_NUMBER = 1);

--Display New Discount Rate and Application Note for Orders
SELECT 
    ORDER_NUMBER,
    CASE 
        WHEN (SELECT SUM(UNIT_PRICE * QUANTITY) FROM ORDER_DETAILS WHERE ORDER_NUMBER = o.ORDER_NUMBER) BETWEEN 0 AND 2000 THEN 0
        WHEN (SELECT SUM(UNIT_PRICE * QUANTITY) FROM ORDER_DETAILS WHERE ORDER_NUMBER = o.ORDER_NUMBER) BETWEEN 2001 AND 10000 THEN 5
        WHEN (SELECT SUM(UNIT_PRICE * QUANTITY) FROM ORDER_DETAILS WHERE ORDER_NUMBER = o.ORDER_NUMBER) BETWEEN 10001 AND 40000 THEN 10
        WHEN (SELECT SUM(UNIT_PRICE * QUANTITY) FROM ORDER_DETAILS WHERE ORDER_NUMBER = o.ORDER_NUMBER) BETWEEN 40001 AND 80000 THEN 15
        ELSE 20
    END AS NEW_DISCOUNT_RATE,
    CASE 
        WHEN ORDER_NUMBER BETWEEN 10000 AND 10999 THEN 'apply old discount rate'
        ELSE 'apply new discount rate'
    END AS DISCOUNT_RATE_NOTE
FROM 
    ORDERS o
WHERE 
    ORDER_NUMBER BETWEEN 10998 AND 11003;

--5. Display Suppliers of Beverage Products
SELECT 
    SUPPLIER_NUMBER,
    COMPANY,
    ADDRESS,
    PHONE
FROM 
    SUPPLIERS s
WHERE 
    EXISTS (SELECT 1 FROM PRODUCTS p WHERE p.SUPPLIER_NUMBER = s.SUPPLIER_NUMBER AND p.CATEGORY_CODE IN (SELECT CATEGORY_CODE FROM CATEGORIES WHERE CATEGORY_NAME = 'Beverage'));
select*from SUPPLIERS

--Display Customers from Berlin Who Ordered at Most 1 Dessert Product
SELECT 
    c.CUSTOMER_CODE
FROM 
    CUSTOMERS c
LEFT JOIN 
    ORDERS o ON c.CUSTOMER_CODE = o.CUSTOMER_CODE
LEFT JOIN 
    ORDER_DETAILS od ON o.ORDER_NUMBER = od.ORDER_NUMBER
LEFT JOIN 
    PRODUCTS p ON od.PRODUCT_REF = p.PRODUCT_REF
WHERE 
    c.CITY = 'Berlin' 
    AND (p.CATEGORY_CODE IN (SELECT CATEGORY_CODE FROM CATEGORIES WHERE CATEGORY_NAME = 'Dessert'))
GROUP BY 
    c.CUSTOMER_CODE
HAVING 
    COUNT(od.PRODUCT_REF) <= 1;

--Display Customers in France and Total Orders in April 1998
SELECT 
    c.CUSTOMER_CODE,
    c.COMPANY,
    c.PHONE,
    COALESCE(SUM(od.UNIT_PRICE * od.QUANTITY), 0) AS TOTAL_AMOUNT,
    c.COUNTRY
FROM 
    CUSTOMERS c
LEFT JOIN 
    ORDERS o ON c.CUSTOMER_CODE = o.CUSTOMER_CODE
LEFT JOIN 
    ORDER_DETAILS od ON o.ORDER_NUMBER = od.ORDER_NUMBER
WHERE 
    c.COUNTRY = 'France' 
    AND (o.ORDER_DATE IS NULL OR MONTH(o.ORDER_DATE) = 4 AND YEAR(o.ORDER_DATE) = 1998)
GROUP BY 
    c.CUSTOMER_CODE


	select*from CUSTOMERS
	select*from EMPLOYEES

-- Display Customers Who Ordered All Products
SELECT 
    c.CUSTOMER_CODE,
    c.COMPANY,
    c.PHONE
FROM 
    CUSTOMERS c
WHERE 
    NOT EXISTS (
        SELECT 
            p.PRODUCT_REF 
        FROM 
            PRODUCTS p 
        WHERE 
            NOT EXISTS (
                SELECT 
                    od.ORDER_NUMBER 
                FROM 
                    ORDERS o 
                JOIN 
                    ORDER_DETAILS od ON o.ORDER_NUMBER = od.ORDER_NUMBER
                WHERE 
                    o.CUSTOMER_CODE = c.CUSTOMER_CODE 
                    AND od.PRODUCT_REF = p.PRODUCT_REF
            )
    );

--Display Number of Orders for Each Customer from France
SELECT 
    c.CUSTOMER_CODE,
    COUNT(o.ORDER_NUMBER) AS NUMBER_OF_ORDERS
FROM 
    CUSTOMERS c
LEFT JOIN 
    ORDERS o ON c.CUSTOMER_CODE = o.CUSTOMER_CODE
WHERE 
    c.COUNTRY = 'France'
GROUP BY 
    c.CUSTOMER_CODE;

--Display Number of Orders in 1996 and 1997
SELECT 
    (SELECT COUNT(*) FROM ORDERS WHERE YEAR(ORDER_DATE) = 1996) AS ORDERS_1996,
    (SELECT COUNT(*) FROM ORDERS WHERE YEAR(ORDER_DATE) = 1997) AS ORDERS_1997,
    (SELECT COUNT(*) FROM ORDERS WHERE YEAR(ORDER_DATE) = 1997) - (SELECT COUNT(*) FROM ORDERS WHERE YEAR(ORDER_DATE) = 1996) AS DIFFERENCE;