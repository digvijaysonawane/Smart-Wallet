CREATE TABLE smart_user (
userID int identity(1,1) PRIMARY KEY NOT NULL,
userFName VARCHAR(30) NOT NULL,
userLName VARCHAR(30) NOT NULL,
passwd VARCHAR(20) NOT NULL
);

INSERT INTO smart_user VALUES('Digvijay','Sonawane','djsonawa')
INSERT INTO smart_user VALUES('Saloni','Sharma','salonisds')
INSERT INTO smart_user VALUES('Shanaya','Sonawane','ds') 
INSERT INTO smart_user VALUES('bhavesh','awalkar','venom') 
INSERT INTO smart_user VALUES('Darshi','Sheth','rohanislove') 
INSERT INTO smart_user VALUES('Latika','Wadhwa','coolhai') 
INSERT INTO smart_user VALUES('Shubham','Shete','rsaforever') 
DELETE FROM smart_user WHERE smart_user.userFName = 'Latika'
SELECT * FROM smart_user
CREATE TABLE amt_description (
description_status VARCHAR(2) PRIMARY KEY  CHECK (description_status IN('OF','OG','OP','OU','OM','ES','OS','OB','FF','OC')),
detail_description VARCHAR(50),
);

INSERT INTO amt_description VALUES('OF','Family') 
INSERT INTO amt_description VALUES('OG','Groceries')
INSERT INTO amt_description VALUES('OP','Parties')
INSERT INTO amt_description VALUES('OU','Utility bills')
INSERT INTO amt_description VALUES('OM','Miscellaneous')
INSERT INTO amt_description VALUES('ES','Entertainment & Sports')
INSERT INTO amt_description VALUES('OS','Shopping')
INSERT INTO amt_description VALUES('OB','Bank transaction')
INSERT INTO amt_description VALUES('FF','Friends')
INSERT INTO amt_description VALUES('OC','Company')


SELECT * FROM amt_description
SELECT * FROM smart_user

CREATE TABLE account(
accountID int identity(1000,1) PRIMARY KEY NOT NULL,
userID int  FOREIGN KEY REFERENCES smart_user(userID) NOT NULL,
start_date  DATE DEFAULT getdate() NOT NULL,
balance NUMERIC(10,2) DEFAULT 0 NOT NULL,
Potent_savings NUMERIC(10,2) DEFAULT 0 NOT NULL,
);

INSERT INTO account VALUES('1','2018-11-20',DEFAULT,DEFAULT)
INSERT INTO account VALUES('2','2018-11-19',DEFAULT,DEFAULT)
INSERT INTO account VALUES('3','2018-11-21',DEFAULT,DEFAULT)
INSERT INTO account VALUES('4','2018-10-02',DEFAULT,DEFAULT)
INSERT INTO account VALUES('5','2018-09-05',DEFAULT,DEFAULT)

---- UPdate account trigger------

CREATE TRIGGER new_account
ON [smart_user]
FOR INSERT
AS
Begin
    Insert into account(userID) 
    Select Distinct i.userID
    from Inserted i
    Left Join account a
    on i.userID = a.userID
    where a.userID is null
End


CREATE TABLE income(
incomeID int identity(100,1) PRIMARY KEY NOT NULL,
accountID int FOREIGN KEY REFERENCES account(accountID) NOT NULL,
income_amt NUMERIC(10,2) DEFAULT(0) NOT NULL,
start_date  DATE DEFAULT getdate() NOT NULL,
description_status VARCHAR(2) FOREIGN KEY REFERENCES amt_description(description_status),
);

INSERT INTO income VALUES('1000',1000,DEFAULT,'OC')
INSERT INTO income VALUES('1001',10000,DEFAULT,'OC')
INSERT INTO income VALUES('1002',500,DEFAULT,'OF')
INSERT INTO income VALUES('1003',100,DEFAULT,'FF')
INSERT INTO income VALUES('1004',2200,DEFAULT,'OP')
INSERT INTO income VALUES('1003',3200,DEFAULT,'OC')
INSERT INTO income VALUES('1002',0,DEFAULT,'OG')
INSERT INTO income VALUES('1002',500,DEFAULT,'OF')
INSERT INTO income VALUES('1006',1000,DEFAULT,'OC')
INSERT INTO income VALUES('1001',1000,DEFAULT,'FF')
SELECT * FROM income
SELECT * FROM expense

CREATE TABLE expense(
expenseID int identity PRIMARY KEY NOT NULL,
accountID int  FOREIGN KEY REFERENCES account(accountID) NOT NULL,
expense_amt NUMERIC(10,2) DEFAULT(0) NOT NULL,
start_date  DATE DEFAULT getdate() NOT NULL,
description_status VARCHAR(2) FOREIGN KEY REFERENCES amt_description(description_status),
);

INSERT INTO expense VALUES('1000',100,DEFAULT,'OU')
INSERT INTO expense VALUES('1001',1000,DEFAULT,'OM')
INSERT INTO expense VALUES('1002',0,DEFAULT,'OF')
INSERT INTO expense VALUES('1003',100,DEFAULT,'OG')
INSERT INTO expense VALUES('1004',220,DEFAULT,'FF')
INSERT INTO expense VALUES('1003',320,DEFAULT,'OU')
INSERT INTO expense VALUES('1002',500,DEFAULT,'OG')
INSERT INTO expense VALUES('1002',0,DEFAULT,'OF')
INSERT INTO expense VALUES('1006',0,DEFAULT,'OM')
INSERT INTO expense VALUES('1001',0,DEFAULT,'OM')

SELECT * FROM expense

SELECT * FROM trans

CREATE TABLE trans(
transactionID int identity PRIMARY KEY NOT NULL,
accountID int  FOREIGN KEY REFERENCES account(accountID) NOT NULL,
expenseID int  FOREIGN KEY REFERENCES expense(expenseID) NOT NULL,
incomeID int  FOREIGN KEY REFERENCES income(incomeID) NOT NULL,
);


INSERT INTO trans VALUES('1000','1','100')
INSERT INTO trans VALUES('1001','2','101')
INSERT INTO trans VALUES('1002','3','102')
INSERT INTO trans VALUES('1003','4','103')
INSERT INTO trans VALUES('1004','5','104')
INSERT INTO trans VALUES('1003','6','105')
INSERT INTO trans VALUES('1002','7','106')
INSERT INTO trans VALUES('1002','8','107')
INSERT INTO trans VALUES('1006','9','108')
INSERT INTO trans VALUES('1001','10','109')

CREATE VIEW wallet AS
SELECT DISTINCT trans.transactionID, smart_user.userID,smart_user.userFName,smart_user.userLName, account.accountID,
account.balance,account.Potent_savings,account.start_date, income.income_amt,
expense.expense_amt 
FROM smart_user,account,income,expense,trans
WHERE smart_user.userID = account.userID AND account.accountID = trans.accountID AND trans.incomeID = income.incomeID
AND trans.expenseID = expense.expenseID

SELECT * FROM wallet

--view all my income transaction
CREATE FUNCTION all_my_income_trans(@accountID INT)
RETURNS TABLE
AS
RETURN(
SELECT income.start_date,income.income_amt, amt_description.detail_description 
FROM income
INNER JOIN amt_description ON
income.description_status = amt_description.description_status
WHERE income.accountID = @accountID
)
----------
SELECT * FROM income
SELECT * FROM all_my_income_trans(1000)
----------

--view all my expense transaction

CREATE FUNCTION all_my_expense_trans(@accountID INT)
RETURNS TABLE
AS
RETURN(
SELECT expense.start_date,expense.expense_amt, amt_description.detail_description 
FROM expense
INNER JOIN amt_description ON
expense.description_status = amt_description.description_status
WHERE expense.accountID = @accountID
)

SELECT * FROM expense
----------
SELECT * FROM all_my_expense_trans(1000)
----------

-- my total expenses 
CREATE FUNCTION my_total_expense()
RETURNS TABLE
AS
RETURN(
SELECT DISTINCT expense.accountID,SUM(expense_amt) AS TOTAL_EXPENSE
FROM expense
INNER JOIN account On
account.accountID = expense.accountID
GROUP BY expense.accountID
)

SELECT * FROM income
---------
SELECT * FROM my_total_income()
---------
-- my total incomes 
CREATE FUNCTION my_total_income()
RETURNS TABLE
AS
RETURN(
SELECT income.accountID,SUM(income_amt) AS TOTAL_INCOME
FROM income
INNER JOIN account On
account.accountID = income.accountID
--WHERE income.accountID = @accountID
GROUP BY income.accountID
)

CREATE FUNCTION my_total()
RETURNS TABLE
AS
RETURN(
SELECT my_total_income.accountID,my_total_income.TOTAL_INCOME,my_total_expense.TOTAL_EXPENSE
FROM my_total_income(),my_total_expense()
WHERE my_total_income.accountID = my_total_expense.accountID
)
SELECT * FROM my_total()



-- The distribution of income
CREATE FUNCTION dist_of_income(@accountID INT)
RETURNS TABLE
AS
RETURN(
SELECT amt_description.detail_description ,income.income_amt
FROM income
INNER JOIN amt_description ON
income.description_status = amt_description.description_status
WHERE income.accountID = @accountID
)
SELECT * FROM income
---------
SELECT * FROM dist_of_income(1000)

-- The distribution of expense
CREATE FUNCTION dist_of_expense(@accountID INT)
RETURNS TABLE
AS
RETURN(
SELECT amt_description.detail_description ,expense.expense_amt
FROM expense
INNER JOIN amt_description ON
expense.description_status = amt_description.description_status
WHERE expense.accountID = @accountID
)
SELECT * FROM dist_of_expense(1001)

-- Procedure for updated balance and potential savings 

CREATE PROCEDURE balance_pot
AS
BEGIN
	UPDATE account
	SET balance = balanceCount.balance,Potent_savings = balanceCount.potent_savings
	FROM
	(
 SELECT account.accountID,(TOTAL_INCOME - TOTAL_EXPENSE) AS 'balance' , ((TOTAL_INCOME - TOTAL_EXPENSE)/TOTAL_INCOME)*100 AS 'potent_savings'
   FROM my_total()
   INNER JOIN account ON
   account.accountID = my_total.accountID
 -- INNER JOIN trans ON
  --trans.accountID = account.accountID
 --GROUP BY account.accountID
   ) AS balanceCount
   WHERE account.accountID = balanceCount.accountID
END 

EXEC balance_pot

