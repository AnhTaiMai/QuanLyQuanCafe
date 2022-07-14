CREATE DATABASE QuanLyQuanCafe
GO

USE QuanLyQuanCafe
GO

-- Food 
-- Table
-- FoodCategory
-- Account
-- Bill
-- BillInfo

CREATE TABLE TableFood
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) DEFAULT 'Bàn chưa có tên',
	status NVARCHAR(100) DEFAULT N'Trống'
	
)
GO

CREATE TABLE Account
(		
	UserName NVARCHAR(100) PRIMARY KEY,
	DisplayName NVARCHAR(100) DEFAULT N'XUÂN HỒNG',
	PassWord NVARCHAR(1000) DEFAULT 0,
	Type INT DEFAULT 0
)
GO

CREATE TABLE FoodCategory
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) DEFAULT N'chưa đặt tên',
)
GO

CREATE TABLE Food
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) DEFAULT N'chưa đặt tên',
	idCategory INT,
	price FLOAT NOT NULL DEFAULT 0,

	FOREIGN KEY (idCategory) REFERENCES dbo.FoodCategory(id)
)
GO

DROP TABLE IF EXISTS dbo.Bill
GO

CREATE TABLE Bill
(
	id INT IDENTITY PRIMARY KEY,
	DateCheckIn DATE NOT NULL DEFAULT GETDATE(),
	DateCheckOut DATE,
	idTable INT NOT NULL,
	status INT NOT NULL DEFAULT 0

	FOREIGN KEY (idTable) REFERENCES dbo.TableFood(id)
)
GO

DROP TABLE IF EXISTS dbo.BillInfo
GO

CREATE TABLE BillInfo
(
	id INT IDENTITY PRIMARY KEY,
	idBill INT NOT NULL,
	idFood INT NOT NULL,
	count INT NOT NULL DEFAULT 0,

	FOREIGN KEY (idBill) REFERENCES dbo.Bill,
	FOREIGN KEY (idFood) REFERENCES dbo.Food
)
GO


SELECT * FROM dbo.ACcount


CREATE PROC USP_GetAccountByUserName
@userName nvarchar(100)
AS 
BEGIN
	SELECT * FROM dbo.Account WHERE UserName = @userName
END
GO

EXEC dbo.USP_GetAccountByUserName @userName = N'K9' -- nvarchar(100)
GO

CREATE PROC USP_Login
@userName nvarchar(100), @passWord nvarchar(100)
AS
BEGIN
	SELECT * FROM dbo.Account WHERE UserName = '' AND PassWord = N'' OR 1=1--'
END
GO

CREATE PROC USP_GetTableList
AS SELECT * FROM dbo.TableFood
GO

EXEC dbo.USP_GetTableList
GO


SELECT * FROM dbo.FoodCategory
SELECT * FROM dbo.BillInfo 
SELECT * FROM dbo.Bill
SELECT * FROM dbo.Food
SELECT * FROM dbo.BillInfo 
SELECT * FROM dbo.FoodCategory
 
SELECT f.price*bi.count AS totalPrice  
FROM dbo.BillInfo AS bi, dbo.Bill AS b, dbo.Food AS f 
WHERE bi.idBill = b.id AND bi.idFood = f.id AND b.status = 1 AND b.idTable = 1

SELECT f.name, bi.count, f.price, f.price*bi.count AS totalPrice 
FROM dbo.BillInfo AS bi, dbo.Bill AS b, dbo.Food AS f 
WHERE bi.idBill = b.id AND bi.idFood = f.id AND b.status = 1 AND b.idTable = 1

-- ve 1 dung AND  

CREATE PROC USP_InsertBill
@idTable INT
AS
BEGIN
	INSERT dbo.Bill
	(
	    DateCheckIn,
	    DateCheckOut,
	    idTable,
	    status
	)
	VALUES
	(   GETDATE(), -- DateCheckIn - datetime
	    NULL, -- DateCheckOut - datetime
	    @idTable,         -- idTable - int
	    0          -- status - int
	    )
END
GO
        
CREATE PROC USP_InsertBillInfo
@idBill INT , @idFood INT, @count INT
AS
BEGIN

	DECLARE @isExitsBillInfo INT
	DECLARE @foodCount INT = 1

	SELECT @isExitsBillInfo	= id, @foodCount = count FROM dbo.BillInfo 
	WHERE idBill = @idBill AND idFood = @idFood

	IF (@isExitsBillInfo > 0)
	BEGIN
		DECLARE @newCount INT = @foodCount +@count
		IF (@newCount > 0)
			UPDATE dbo.BillInfo SET count = @foodCount + @count WHERE idFood = @idFood
		ELSE
			DELETE dbo.BillInfo WHERE idBill = @idBill AND idFood = @idFood
            
	END
	ELSE
    BEGIN
		INSERT dbo.BillInfo
		(idBill,idFood,count)
		VALUES
		(@idBill, @idFood, @count)
	END 
END
GO


 

 CREATE TRIGGER UTG_UpdateBillInfo
 ON dbo.BillInfo FOR INSERT, UPDATE
 AS
 BEGIN
	DECLARE @idBill INT

	SELECT @idBill = idBill FROM Inserted

	DECLARE @idTable INT

	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill AND status = 0

	UPDATE dbo.TableFood SET status = N'Đang tính......' WHERE id = @idTable
 END
 GO

 
CREATE TRIGGER UTG_UpdateBill
 ON dbo.Bill FOR INSERT, UPDATE
 AS
 BEGIN
	DECLARE @idBill INT
	SELECT @idBill = id FROM Inserted

	DECLARE @idTable INT
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill

	DECLARE @count INT = 0
	SELECT @count = COUNT(*) FROM dbo.Bill WHERE idTable = @idTable AND status = 0

	IF(@count = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
 END
 GO


SELECT * FROM dbo.BillInfo
SELECT * FROM dbo.Bill

ALTER TABLE dbo.Bill ADD totalPrice FLOAT 

DELETE dbo.BillInfo
DELETE dbo.Bill
GO


ALTER PROC USP_GetListBillByDate
@checkIn date, @checkOut date
AS
BEGIN
SELECT t.name AS [Hóa Đơn], b.totalPrice AS [Tổng tiền], DateCheckIn AS [Ngày mua], DateCheckOut as [Ngày tính tiền] 
	FROM dbo.Bill AS b , dbo.TableFood  AS t
	WHERE 
	t.id = b.idTable
	AND 
	b.DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
END
GO


 SELECT t.name, b.totalPrice, DateCheckIn, DateCheckOut 
 FROM dbo.Bill AS b , dbo.TableFood  AS t
 WHERE t.id = b.idTable
 AND 
 DateCheckIn >= '20220701' AND DateCheckOut <= '20220731' AND b.status = 1

 



ALTER TABLE dbo.Bill
DROP COLUMN totalPrice;