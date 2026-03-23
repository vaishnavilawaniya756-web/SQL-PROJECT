CREATE DATABASE InsuranceDB;
USE InsuranceDB;
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY identity,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address VARCHAR(255),
    date_of_birth DATE);


CREATE TABLE Agents (
    agent_id INT PRIMARY KEY identity,
    agent_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15),
    commission_rate DECIMAL(5,2)
);
CREATE TABLE Policies (
    policy_id INT PRIMARY KEY identity,
    policy_name VARCHAR(100),
    policy_type VARCHAR(50),
    premium_amount DECIMAL(10,2),
    start_date DATE,
    end_date DATE,
    customer_id INT,
    agent_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (agent_id) REFERENCES Agents(agent_id));

CREATE TABLE Claims (
    claim_id INT PRIMARY KEY identity,
    claim_date DATE,
    claim_amount DECIMAL(10,2),
    claim_status VARCHAR(50),
    policy_id INT,
    FOREIGN KEY (policy_id) REFERENCES Policies(policy_id)
);
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY identity,
    payment_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    policy_id INT,
    FOREIGN KEY (policy_id) REFERENCES Policies(policy_id)
);

INSERT INTO Customers (full_name, email, phone, address, date_of_birth)
VALUES
('Rahul Sharma', 'rahul.sharma@gmail.com', '9876543210', 'Delhi, India', '1990-05-15'),
('Priya Verma', 'priya.verma@gmail.com', '9123456780', 'Mumbai, India', '1988-09-22'),
('Amit Singh', 'amit.singh@gmail.com', '9988776655', 'Bangalore, India', '1992-12-05'),
('Sneha Rao', 'sneha.rao@gmail.com', '9112233445', 'Chennai, India', '1995-07-18');

INSERT INTO Agents (agent_name, email, phone, commission_rate)
VALUES
('Anil Kapoor', 'anil.agent@gmail.com', '9001122334', 5.5),
('Sunita Mehta', 'sunita.agent@gmail.com', '9012233445', 4.5),
('Rohit Jain', 'rohit.agent@gmail.com', '9023344556', 6.0);

INSERT INTO Policies (policy_name, policy_type, premium_amount, start_date, end_date, customer_id, agent_id)
VALUES
('Life Secure Plan', 'Life', 15000, '2025-01-01', '2035-01-01', 1, 1),
('Health Protect Plan', 'Health', 12000, '2024-03-01', '2025-03-01', 2, 2),
('Car Insurance Plan', 'Vehicle', 8000, '2024-01-01', '2024-12-31', 3, 3),
('Home Safe Plan', 'Property', 10000, '2023-05-01', '2024-05-01', 4, 1);

INSERT INTO Claims (claim_date, claim_amount, claim_status, policy_id)
VALUES
('2025-02-15', 5000, 'Approved', 1),
('2024-06-10', 2000, 'Pending', 2),
('2024-08-20', 3000, 'Rejected', 3),
('2024-02-05', 1000, 'Approved', 1);

INSERT INTO Payments (payment_date, amount, payment_method, policy_id)
VALUES
('2025-01-01 10:00:00', 15000, 'Credit Card', 1),
('2024-03-01 11:30:00', 12000, 'Bank Transfer', 2);

SELECT * FROM customers
SELECT * FROM agents
SELECT * FROM policies
SELECT *  FROM claims
SELECT * FROM payments



--CUSTOMER AND POLICY NAME
SELECT c.full_name, p.policy_name
FROM Customers c
JOIN Policies p ON c.customer_id = p.customer_id;



--TOTAL CUSTOMERS
SELECT COUNT(*) AS total_customers FROM Customers;



--CUSTOMER NAME ,POLICY NAME, AGENT NAME AND PREMIUM AMOUNT
SELECT  c.full_name AS customer_name, a.agent_name, p.policy_name,
   p.premium_amount
FROM Customers c
JOIN Policies p ON c.customer_id = p.customer_id
JOIN Agents a ON p.agent_id = a.agent_id;



--CLIENTS WITH NO POLICIES
SELECT c.full_name
FROM Customers c
LEFT JOIN Policies p ON c.customer_id = p.customer_id
WHERE p.policy_id IS NULL;



--CUSTOMERS, POLICY  AND THEIR CLAIMS
SELECT c.full_name, p.policy_name,  cl.claim_amount, cl.claim_status
FROM Customers c
JOIN Policies p ON c.customer_id = p.customer_id
LEFT JOIN Claims cl ON p.policy_id = cl.policy_id;


--TOTAL POLICIES PER CUSTOMER
SELECT c.full_name,
    COUNT(p.policy_id) AS total_policies
FROM Customers c
LEFT JOIN Policies p ON c.customer_id = p.customer_id
GROUP BY c.full_name;



--TOTAL PREMIUM AMOUNT
SELECT SUM(premium_amount) AS total_revenue FROM Policies;



--CLAIM COUNT PER POLICY
SELECT policy_id,
    COUNT(*) AS total_claims
FROM Claims
GROUP BY policy_id;


--PREVENT INSERTING ALREADY EXPIRED POLICIES
CREATE TRIGGER trg_no_expired_policy_insert
ON Policies
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE end_date < CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR ('Cannot insert an already expired policy', 16, 1);
        RETURN;
    END;

    INSERT INTO Policies (policy_name, policy_type, premium_amount, start_date, end_date, customer_id, agent_id)
    SELECT policy_name, policy_type, premium_amount, start_date, end_date, customer_id, agent_id
    FROM inserted;
END;
INSERT INTO Policies (policy_name, policy_type, premium_amount, start_date, end_date, customer_id, agent_id)
VALUES ('Old Policy', 'Life', 5000, '2020-01-01', '2021-01-01', 1, 1); --BECAUSE THE POLICY HAS EXPIRED


--PREVENT INVALID PAYMENT
CREATE TRIGGER trg_payment_validation
ON Payments
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE amount <= 0)
    BEGIN
        RAISERROR ('Payment amount must be greater than zero', 16, 1);
        RETURN;
    END

    INSERT INTO Payments (payment_date, amount, payment_method, policy_id)
    SELECT payment_date, amount, payment_method, policy_id
    FROM inserted;
END;
INSERT INTO Payments (payment_date, amount, payment_method, policy_id)
VALUES ('2026-03-23', 5000, 'Cash', 1);










  









