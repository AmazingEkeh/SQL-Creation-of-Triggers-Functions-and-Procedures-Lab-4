use Ekeh_Amazing_lab3;
--  problem 1
DROP PROCEDURE IF EXISTS emp_info;


DELIMITER //
CREATE PROCEDURE emp_info(IN emp_number CHAR(7))
BEGIN
    DECLARE emp_name VARCHAR(50);
    DECLARE emp_salary DECIMAL(9,2);
    SELECT CONCAT(empFName, ' ', empLName) AS 'emp_name', salary INTO emp_name, emp_salary
    FROM employee
    WHERE empID = emp_number;
    SELECT CONCAT(emp_name) AS 'Employee Name',
     CONCAT('$', emp_salary) AS 'Salary';
END //

DELIMITER ;

call emp_info('3456789');


-- problem 2
DROP PROCEDURE IF EXISTS emp_orders;

DELIMITER //
CREATE PROCEDURE emp_orders(IN emp_number CHAR(7))
BEGIN
    SELECT CONCAT(empfname, ' ', emplname) AS 'Employee Name',
           CONCAT(fname, ' ', lname) AS 'Customer Name',
           o.amount AS 'Order Amount'
    FROM employee e
    INNER JOIN shoe_order o ON o.SempID = e.empID
    INNER JOIN customer c ON c.CID = o.SCID
    WHERE e.empID = emp_number;
END //

DELIMITER ;

call emp_orders('3456789');


-- problem 3
DELIMITER //
DROP FUNCTION IF EXISTS get_phone //
CREATE FUNCTION get_phone(fname VARCHAR(50), lname VARCHAR(50), branch_number INT) 
RETURNS VARCHAR(20)
deterministic
BEGIN
    DECLARE br_phone VARCHAR(10);
    
    SELECT B_Phone
    INTO br_phone
    FROM branch, customer
    WHERE customer.fname = fname AND
    customer.lname = lname AND
    branch.bcid = customer.cid AND
    BrNo = branch_number;
    
    RETURN br_phone;
END //
DELIMITER ;

SELECT get_phone('Amanda', 'Joshua', '7774589');


-- problem 4
DELIMITER //
DROP TRIGGER IF EXISTS max_types //
CREATE TRIGGER max_types
BEFORE INSERT ON order_item
FOR EACH ROW
BEGIN
    DECLARE type_count INT;
    SELECT COUNT(DISTINCT typeID)
    INTO type_count
    FROM order_item
    WHERE orderno = NEW.orderno AND suborderno = NEW.suborderno;
    IF type_count >= 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A suborder can include at most two shoe types.';
    END IF;
END //
DELIMITER ;


INSERT INTO Order_item values ('2134567', '1556669', '4449456', 10);
INSERT INTO Order_item values ('2134567', '1556669', '4449125', 10);

-- problem 5
DELIMITER //
DROP TRIGGER IF EXISTS date_inconsistency //
CREATE TRIGGER date_inconsistency
BEFORE INSERT ON suborder
FOR EACH ROW
BEGIN
    DECLARE order_date DATE;
    
    SELECT reqshipdate
    INTO order_date
    FROM suborder
    WHERE sorderno = NEW.sorderno AND suborderno = new.suborderno;
	IF NEW.ReqShipDate < order_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The required shipping date of a suborder cannot be earlier than the order date of the order to which the suborder belongs.';
    END IF;
END //

DELIMITER ;

INSERT INTO suborder VALUES('2134567', '2556669', '2015-03-18', '2023-03-20', '1007468', '7778889');
INSERT INTO suborder VALUES('2134567', '2556669', '2023-03-18', '2023-03-20', '1007468', '7778889');