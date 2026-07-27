USE master;
GO

IF DB_ID('CafePOS') IS NOT NULL
BEGIN
    ALTER DATABASE CafePOS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CafePOS;
END
GO

CREATE DATABASE CafePOS;
GO

USE CafePOS;
GO
-- STAFF
CREATE TABLE staff
(
    id VARCHAR(10) PRIMARY KEY,

    name NVARCHAR(100) NOT NULL,

    username VARCHAR(50) NOT NULL UNIQUE,

    password VARCHAR(255) NOT NULL,

    role VARCHAR(30) NOT NULL
    CHECK(role IN
    (
        'QUAN_LY',
        'NHAN_VIEN',
        'THU_NGAN',
        'BAR_TENDER',
        'BEP_TRUONG'
    )),

    phone VARCHAR(20),

    salary DECIMAL(18,2)
    CHECK(salary>=0),

    active BIT NOT NULL
    DEFAULT 1
);
GO
-- CAFE TABLE
CREATE TABLE cafe_table
(
    table_number INT PRIMARY KEY,

    capacity INT NOT NULL
    CHECK(capacity>0),

    status VARCHAR(20)
    NOT NULL
    DEFAULT 'TRONG'
    CHECK(status IN
    (
        'TRONG',
        'CO_NGUOI',
        'DA_DAT'
    ))
);
GO
-- MENU ITEM
CREATE TABLE menu_item
(
    id VARCHAR(10) PRIMARY KEY,

    name NVARCHAR(150) NOT NULL,

    category NVARCHAR(100) NOT NULL,

    price DECIMAL(18,2)
    NOT NULL
    CHECK(price>=0),

    description NVARCHAR(500),

    available_shifts VARCHAR(100)
    NOT NULL
);
GO
-- INDEX
CREATE INDEX IX_STAFF_USERNAME
ON staff(username);
GO

CREATE INDEX IX_MENU_CATEGORY
ON menu_item(category);
GO

CREATE INDEX IX_MENU_NAME
ON menu_item(name);
GO
-- SAMPLE STAFF
INSERT INTO staff
VALUES
('NV001',
 N'Quản trị viên',
 'admin',
 '123',
 'QUAN_LY',
 '0900000001',
 15000000,
 1),

('NV002',
 N'Thu ngân',
 'cashier',
 '123',
 'THU_NGAN',
 '0900000002',
 8000000,
 1),

('NV003',
 N'Nhân viên',
 'staff',
 '123',
 'NHAN_VIEN',
 '0900000003',
 7000000,
 1),

('NV004',
 N'Pha chế',
 'bar',
 '123',
 'BAR_TENDER',
 '0900000004',
 9000000,
 1),

('NV005',
 N'Bếp trưởng',
 'chef',
 '123',
 'BEP_TRUONG',
 '0900000005',
 12000000,
 1);
GO
-- SAMPLE TABLE
INSERT INTO cafe_table
VALUES
(1,2,'TRONG'),
(2,2,'TRONG'),
(3,4,'TRONG'),
(4,4,'TRONG'),
(5,6,'TRONG'),
(6,6,'TRONG'),
(7,8,'TRONG'),
(8,8,'TRONG'),
(9,10,'TRONG'),
(10,10,'TRONG');
GO
-- SAMPLE MENU
INSERT INTO menu_item
VALUES

('CF001',
N'Cà phê đen',
N'Cà phê',
25000,
N'Cà phê đen truyền thống',
'CA_SANG,CA_CHIEU,CA_TOI'),

('CF002',
N'Cà phê sữa',
N'Cà phê',
30000,
N'Cà phê sữa đá',
'CA_SANG,CA_CHIEU,CA_TOI'),

('TS001',
N'Trà sữa truyền thống',
N'Trà sữa',
45000,
N'Trà sữa',
'CA_CHIEU,CA_TOI'),

('TS002',
N'Trà đào',
N'Trà',
40000,
N'Trà đào cam sả',
'CA_CHIEU,CA_TOI'),

('DA001',
N'Nước suối',
N'Đồ uống',
15000,
N'Nước suối Aquafina',
'CA_SANG,CA_CHIEU,CA_TOI');
GO
-- BẢNG NGUYÊN LIỆU
CREATE TABLE ingredient
(
    id VARCHAR(10) PRIMARY KEY,

    name NVARCHAR(100) NOT NULL,

    unit NVARCHAR(20) NOT NULL,

    stock_quantity DECIMAL(18,2) NOT NULL
        DEFAULT 0
        CHECK(stock_quantity >= 0),

    min_stock DECIMAL(18,2) NOT NULL
        DEFAULT 0
        CHECK(min_stock >= 0),

    unit_price DECIMAL(18,2) NOT NULL
        DEFAULT 0
        CHECK(unit_price >= 0)
);
GO
-- BẢNG CÔNG THỨC PHA CHẾ
CREATE TABLE recipe
(
    menu_item_id VARCHAR(10) NOT NULL,

    ingredient_id VARCHAR(10) NOT NULL,

    quantity DECIMAL(18,2) NOT NULL
        CHECK(quantity > 0),

    CONSTRAINT PK_recipe
        PRIMARY KEY(menu_item_id, ingredient_id),

    CONSTRAINT FK_recipe_menu
        FOREIGN KEY(menu_item_id)
        REFERENCES menu_item(id),

    CONSTRAINT FK_recipe_ingredient
        FOREIGN KEY(ingredient_id)
        REFERENCES ingredient(id)
);
GO
-- INDEX
CREATE INDEX IX_ingredient_name
ON ingredient(name);
GO

CREATE INDEX IX_recipe_menu
ON recipe(menu_item_id);
GO

CREATE INDEX IX_recipe_ingredient
ON recipe(ingredient_id);
GO
-- DỮ LIỆU MẪU NGUYÊN LIỆU
INSERT INTO ingredient
(id,name,unit,stock_quantity,min_stock,unit_price)
VALUES
('NL001',N'Cà phê hạt','kg',25,5,280000),

('NL002',N'Sữa đặc','lon',80,20,28000),

('NL003',N'Đường','kg',40,10,22000),

('NL004',N'Trà đen','kg',15,5,180000),

('NL005',N'Sữa tươi','lít',35,8,42000),

('NL006',N'Đào ngâm','hộp',20,5,65000),

('NL007',N'Siro đào','chai',12,3,95000),

('NL008',N'Đá viên','kg',200,50,2500),

('NL009',N'Nước lọc','chai',120,20,5000);
GO
-- CÔNG THỨC PHA CHẾ
INSERT INTO recipe
(menu_item_id,ingredient_id,quantity)
VALUES
-- Cà phê đen
('CF001','NL001',0.02),
('CF001','NL003',0.01),
('CF001','NL008',0.25),
-- Cà phê sữa
('CF002','NL001',0.02),
('CF002','NL002',0.03),
('CF002','NL008',0.25),
-- Trà sữa
('TS001','NL004',0.02),
('TS001','NL005',0.12),
('TS001','NL003',0.02),
('TS001','NL008',0.20),
-- Trà đào
('TS002','NL004',0.02),
('TS002','NL006',0.05),
('TS002','NL007',0.01),
('TS002','NL008',0.20),
-- Nước suối
('DA001','NL009',1);
GO
--           TABLE: orders
CREATE TABLE orders
(
    order_id VARCHAR(20) PRIMARY KEY,

    table_number INT NOT NULL,

    staff_name NVARCHAR(100) NOT NULL,

    shift VARCHAR(20) NOT NULL
    CHECK
    (
        shift IN
        (
            'CA_SANG',
            'CA_CHIEU',
            'CA_TOI'
        )
    ),

    order_time DATETIME NOT NULL
    DEFAULT GETDATE(),

    status VARCHAR(30) NOT NULL
    DEFAULT 'DANG_PHUC_VU'
    CHECK
    (
        status IN
        (
            'DANG_PHUC_VU',
            'DA_THANH_TOAN',
            'HUY'
        )
    ),

    payment_method NVARCHAR(50),

    discount_pct DECIMAL(5,2)
    DEFAULT 0
    CHECK(discount_pct>=0 AND discount_pct<=100),

    total_amount DECIMAL(18,2)
    DEFAULT 0
    CHECK(total_amount>=0),

    CONSTRAINT FK_orders_table
        FOREIGN KEY(table_number)
        REFERENCES cafe_table(table_number)
);
GO


--            TABLE: order_items

CREATE TABLE order_items
(
    order_id VARCHAR(20) NOT NULL,

    menu_item_id VARCHAR(10) NOT NULL,

    quantity INT NOT NULL
    CHECK(quantity>0),

    unit_price DECIMAL(18,2) NOT NULL
    CHECK(unit_price>=0),

    note NVARCHAR(255),

    CONSTRAINT PK_order_items
        PRIMARY KEY(order_id,menu_item_id),

    CONSTRAINT FK_order_items_orders
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_order_items_menu
        FOREIGN KEY(menu_item_id)
        REFERENCES menu_item(id)
);
GO



--             INDEX


CREATE INDEX IX_orders_status
ON orders(status);
GO

CREATE INDEX IX_orders_table
ON orders(table_number);
GO

CREATE INDEX IX_orders_time
ON orders(order_time);
GO

CREATE INDEX IX_order_items_menu
ON order_items(menu_item_id);
GO



--             SAMPLE DATA


INSERT INTO orders
(
    order_id,
    table_number,
    staff_name,
    shift,
    order_time,
    status,
    payment_method,
    discount_pct,
    total_amount
)
VALUES
(
    'HD0001',
    1,
    N'Quản trị viên',
    'CA_SANG',
    GETDATE(),
    'DANG_PHUC_VU',
    N'',
    0,
    85000
);
GO


INSERT INTO order_items
VALUES
(
    'HD0001',
    'CF001',
    2,
    25000,
    N'Ít đá'
),
(
    'HD0001',
    'TS001',
    1,
    35000,
    N''
);
GO

--            TABLE: work_schedule

CREATE TABLE work_schedule
(
    id INT IDENTITY(1,1) PRIMARY KEY,

    staff_id VARCHAR(10) NOT NULL,

    staff_name NVARCHAR(100) NOT NULL,

    work_date DATE NOT NULL,

    shift VARCHAR(20) NOT NULL
    CHECK
    (
        shift IN
        (
            'CA_SANG',
            'CA_CHIEU',
            'CA_TOI'
        )
    ),

    checked_in BIT NOT NULL DEFAULT 0,

    checked_out BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_work_schedule_staff
        FOREIGN KEY(staff_id)
        REFERENCES staff(id)
);
GO

--             TABLE: finance_transaction

CREATE TABLE finance_transaction
(
    id INT IDENTITY(1,1) PRIMARY KEY,

    type VARCHAR(10) NOT NULL
    CHECK(type IN('THU','CHI')),

    category NVARCHAR(100) NOT NULL,

    amount DECIMAL(18,2) NOT NULL
    CHECK(amount>=0),

    description NVARCHAR(500),

    created_by NVARCHAR(100),

    created_date DATETIME NOT NULL
    DEFAULT GETDATE()
);
GO

--             INDEX

CREATE INDEX IX_work_schedule_date
ON work_schedule(work_date);
GO

CREATE INDEX IX_work_schedule_staff
ON work_schedule(staff_id);
GO

CREATE INDEX IX_finance_transaction_date
ON finance_transaction(created_date);
GO

CREATE INDEX IX_finance_transaction_type
ON finance_transaction(type);
GO

--          SAMPLE WORK SCHEDULE
INSERT INTO work_schedule
(
    staff_id,
    staff_name,
    work_date,
    shift,
    checked_in,
    checked_out
)
VALUES
('NV001',N'Quản trị viên',GETDATE(),'CA_SANG',1,0),
('NV002',N'Thu ngân',GETDATE(),'CA_SANG',1,0),
('NV003',N'Nhân viên',GETDATE(),'CA_CHIEU',0,0),
('NV004',N'Pha chế',GETDATE(),'CA_CHIEU',0,0),
('NV005',N'Bếp trưởng',GETDATE(),'CA_TOI',0,0);
GO

--             SAMPLE FINANCE

INSERT INTO finance_transaction
(
    type,
    category,
    amount,
    description,
    created_by,
    created_date
)
VALUES
('THU',N'Bán hàng',85000,N'Hóa đơn HD0001',N'admin',GETDATE()),

('CHI',N'Nhập nguyên liệu',2500000,N'Nhập cà phê và sữa',N'admin',GETDATE()),

('CHI',N'Điện nước',1200000,N'Tiền điện tháng',N'admin',GETDATE());
GO



--     Cập nhật tổng tiền hóa đơn

CREATE TRIGGER TRG_UpdateTotalAmount
ON order_items
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE o
    SET total_amount =
    (
        SELECT ISNULL(SUM(quantity * unit_price),0)
        FROM order_items oi
        WHERE oi.order_id = o.order_id
    )
    * (1 - discount_pct/100.0)

    FROM orders o
    WHERE o.order_id IN
    (
        SELECT order_id FROM inserted
        UNION
        SELECT order_id FROM deleted
    );
END;
GO



--       Khi tạo hóa đơn -> bàn có khách

CREATE TRIGGER TRG_TableOccupied
ON orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE cafe_table
    SET status='CO_NGUOI'
    WHERE table_number IN
    (
        SELECT table_number
        FROM inserted
    );
END;
GO

--      Thanh toán -> bàn trống

CREATE TRIGGER TRG_TableEmpty
ON orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE cafe_table
    SET status='TRONG'
    WHERE table_number IN
    (
        SELECT table_number
        FROM inserted
        WHERE status='DA_THANH_TOAN'
    );
END;
GO
--       Trừ tồn kho sau khi bán
CREATE TRIGGER TRG_DeductIngredient
ON order_items
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ingredient
    SET stock_quantity =
        stock_quantity -
        (
            r.quantity * i.quantity
        )

    FROM ingredient
    INNER JOIN recipe r
        ON ingredient.id=r.ingredient_id

    INNER JOIN inserted i
        ON r.menu_item_id=i.menu_item_id;
END;
GO

--      Ghi doanh thu khi thanh toán

CREATE TRIGGER TRG_SaveRevenue
ON orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO finance_transaction
    (
        type,
        category,
        amount,
        description,
        created_by,
        created_date
    )

    SELECT
        'THU',
        N'Bán hàng',
        total_amount,
        N'Hóa đơn ' + order_id,
        staff_name,
        GETDATE()

    FROM inserted

    WHERE status='DA_THANH_TOAN';
END;
GO
--             VIEW NHÂN VIÊN
CREATE VIEW vw_staff
AS
SELECT
    id,
    name,
    username,
    role,
    phone,
    salary,
    active
FROM staff;
GO

--           VIEW MENU

CREATE VIEW vw_menu
AS
SELECT
    id,
    name,
    category,
    price,
    description,
    available_shifts
FROM menu_item;
GO

--            VIEW TỒN KHO

CREATE VIEW vw_inventory
AS
SELECT
    id,
    name,
    unit,
    stock_quantity,
    min_stock,
    unit_price,

    stock_quantity * unit_price AS inventory_value,

    CASE
        WHEN stock_quantity<=0
            THEN N'Hết hàng'

        WHEN stock_quantity<=min_stock
            THEN N'Sắp hết'

        ELSE N'Đủ hàng'
    END AS stock_status

FROM ingredient;
GO

--              VIEW HÓA ĐƠN

CREATE VIEW vw_orders
AS
SELECT

    o.order_id,

    o.table_number,

    o.staff_name,

    o.shift,

    o.order_time,

    o.status,

    o.payment_method,

    o.discount_pct,

    o.total_amount

FROM orders o;
GO

--             VIEW CHI TIẾT HÓA ĐƠN


CREATE VIEW vw_order_detail
AS
SELECT

    oi.order_id,

    m.name AS menu_name,

    oi.quantity,

    oi.unit_price,

    oi.quantity * oi.unit_price AS subtotal,

    oi.note

FROM order_items oi

INNER JOIN menu_item m
ON oi.menu_item_id=m.id;
GO
--           VIEW DOANH THU

CREATE VIEW vw_revenue
AS
SELECT

    CAST(order_time AS DATE) AS revenue_date,

    COUNT(order_id) AS total_orders,

    SUM(total_amount) AS revenue

FROM orders

WHERE status='DA_THANH_TOAN'

GROUP BY CAST(order_time AS DATE);
GO
--         VIEW LỊCH LÀM VIỆC

CREATE VIEW vw_work_schedule
AS
SELECT

    ws.id,

    ws.staff_id,

    ws.staff_name,

    ws.work_date,

    ws.shift,

    ws.checked_in,

    ws.checked_out,

    CASE

        WHEN checked_in=1
        AND checked_out=1

            THEN N'Đã Check-out'

        WHEN checked_in=1

            THEN N'Đã Check-in'

        ELSE N'Chưa Check-in'

    END AS work_status

FROM work_schedule ws;
GO
--            VIEW GIAO DỊCH THU CHI

CREATE VIEW vw_finance
AS
SELECT

    id,

    type,

    category,

    amount,

    description,

    created_by,

    created_date

FROM finance_transaction;
GO
--         PROC ĐĂNG NHẬP

CREATE PROC sp_Login
    @username VARCHAR(50),
    @password VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM staff
    WHERE username=@username
      AND password=@password
      AND active=1;
END;
GO

--            PROC DOANH THU THEO NGÀY

CREATE PROC sp_RevenueByDate
    @date DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(order_id) AS total_orders,
        ISNULL(SUM(total_amount),0) AS revenue
    FROM orders
    WHERE CAST(order_time AS DATE)=@date
      AND status='DA_THANH_TOAN';
END;
GO
--            PROC DOANH THU THEO THÁNG

CREATE PROC sp_RevenueByMonth
    @month INT,
    @year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(order_id) AS total_orders,
        ISNULL(SUM(total_amount),0) AS revenue
    FROM orders
    WHERE MONTH(order_time)=@month
      AND YEAR(order_time)=@year
      AND status='DA_THANH_TOAN';
END;
GO
--           PROC TOP MÓN BÁN CHẠY

CREATE PROC sp_TopSellingMenu
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.id,
        m.name,
        SUM(oi.quantity) AS total_sold
    FROM order_items oi
    INNER JOIN menu_item m
        ON oi.menu_item_id=m.id
    GROUP BY
        m.id,
        m.name
    ORDER BY total_sold DESC;
END;
GO
--       PROC NGUYÊN LIỆU SẮP HẾT
CREATE PROC sp_LowStock
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM ingredient
    WHERE stock_quantity<=min_stock;
END;
GO
--           PROC LỊCH LÀM VIỆC

CREATE PROC sp_WorkSchedule
    @date DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM work_schedule
    WHERE work_date=@date
    ORDER BY shift;
END;
GO
--             PROC DOANH THU NHÂN VIÊN

CREATE PROC sp_StaffRevenue
AS
BEGIN
    SET NOCOUNT ON;

    SELECT

        staff_name,

        COUNT(order_id) AS total_orders,

        SUM(total_amount) AS revenue

    FROM orders

    WHERE status='DA_THANH_TOAN'

    GROUP BY staff_name

    ORDER BY revenue DESC;
END;
GO
--            PROC THU CHI

CREATE PROC sp_FinanceReport
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        type,
        SUM(amount) AS total_amount
    FROM finance_transaction
    GROUP BY type;
END;
GO
--           PROC DANH SÁCH BÀN TRỐNG

CREATE PROC sp_EmptyTables
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM cafe_table
    WHERE status='TRONG'
    ORDER BY table_number;
END;
GO
--             PROC DANH SÁCH BÀN CÓ KHÁCH

CREATE PROC sp_BusyTables
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM cafe_table
    WHERE status='CO_NGUOI'
    ORDER BY table_number;
END;
GO
--           STAFF


INSERT INTO staff VALUES
('NV006',N'Nguyễn Văn A','nva','123','NHAN_VIEN','0901111111',7000000,1),

('NV007',N'Trần Thị B','ttb','123','THU_NGAN','0902222222',8500000,1),

('NV008',N'Lê Văn C','lvc','123','BAR_TENDER','0903333333',9000000,1);
GO
--           CAFE TABLE


INSERT INTO cafe_table VALUES
(11,2,'TRONG'),
(12,2,'TRONG'),
(13,4,'TRONG'),
(14,4,'TRONG'),
(15,6,'TRONG');
GO
--            MENU

INSERT INTO menu_item VALUES

('CF003',N'Bạc xỉu',N'Cà phê',35000,N'Bạc xỉu nóng','CA_SANG,CA_CHIEU'),

('CF004',N'Latte',N'Cà phê',45000,N'Latte Ý','CA_SANG,CA_CHIEU'),

('TS003',N'Hồng trà',N'Trà',35000,N'Hồng trà','CA_CHIEU,CA_TOI'),

('TS004',N'Trà chanh',N'Trà',30000,N'Trà chanh','CA_CHIEU,CA_TOI'),

('DA002',N'Coca Cola',N'Nước ngọt',20000,N'Coca','CA_SANG,CA_CHIEU,CA_TOI');
GO
--        INGREDIENT

INSERT INTO ingredient VALUES

('NL010',N'Sữa béo','Lít',30,5,58000),

('NL011',N'Bột Matcha','Kg',10,2,650000),

('NL012',N'Socola','Kg',12,3,350000);
GO
--           RECIPE

INSERT INTO recipe VALUES

('CF003','NL001',0.02),
('CF003','NL002',0.05),

('CF004','NL001',0.02),
('CF004','NL003',0.08),

('DA002','NL009',1);
GO
--             WORK SCHEDULE

INSERT INTO work_schedule
(
staff_id,
staff_name,
work_date,
shift,
checked_in,
checked_out
)

VALUES

('NV006',N'Nguyễn Văn A',GETDATE(),'CA_SANG',1,1),

('NV007',N'Trần Thị B',GETDATE(),'CA_CHIEU',1,0),

('NV008',N'Lê Văn C',GETDATE(),'CA_TOI',0,0);
GO
--           ORDER


INSERT INTO orders
(
order_id,
table_number,
staff_name,
shift,
order_time,
status,
payment_method,
discount_pct,
total_amount
)

VALUES

(
'HD0002',
2,
N'Thu ngân',
'CA_CHIEU',
GETDATE(),
'DA_THANH_TOAN',
N'Tiền mặt',
5,
90000
),

(
'HD0003',
3,
N'Nhân viên',
'CA_TOI',
GETDATE(),
'DANG_PHUC_VU',
N'',
0,
65000
);
GO
--             ORDER ITEMS

INSERT INTO order_items VALUES

('HD0002','CF002',2,30000,N''),

('HD0002','TS002',1,40000,N'Ít đá'),

('HD0003','CF001',1,25000,N''),

('HD0003','DA001',2,20000,N'');
GO
--            FINANCE

INSERT INTO finance_transaction
(
type,
category,
amount,
description,
created_by,
created_date
)

VALUES

(
'THU',
N'Bán hàng',
90000,
N'Hóa đơn HD0002',
N'admin',
GETDATE()
),

(
'CHI',
N'Tiền điện',
1800000,
N'Điện tháng',
N'admin',
GETDATE()
),

(
'CHI',
N'Tiền nước',
450000,
N'Nước tháng',
N'admin',
GETDATE()
);
GO