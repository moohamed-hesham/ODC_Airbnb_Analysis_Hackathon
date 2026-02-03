/*
===============================================================================
DDL Script: Create Bronze Tables for Housing Database
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- Check if bronze schema exists, if not create it
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
    PRINT 'Schema "bronze" created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema "bronze" already exists.';
END
GO

-- Drop tables in correct order (child first)
IF OBJECT_ID('bronze.Housing', 'U') IS NOT NULL
    DROP TABLE bronze.Housing;
GO

IF OBJECT_ID('bronze.RoomTypes', 'U') IS NOT NULL
    DROP TABLE bronze.RoomTypes;
GO

IF OBJECT_ID('bronze.Hosts', 'U') IS NOT NULL
    DROP TABLE bronze.Hosts;
GO

IF OBJECT_ID('bronze.Cities_indicator', 'U') IS NOT NULL
    DROP TABLE bronze.Cities_indicator;
GO

/*
===============================================================================
Table: bronze.Cities_indicator (Reference Table)
===============================================================================
*/
CREATE TABLE bronze.Cities_indicator (
    City                            VARCHAR(100) PRIMARY KEY,  -- Increased size for consistency
    Country                         VARCHAR(100),              -- Increased size
    Quality_life_index              DECIMAL(5,2),
    Purchasing_index                DECIMAL(5,2),
    Safety_index                    DECIMAL(5,2),
    Healthcare_index                DECIMAL(5,2),
    Property_price_to_income_ratio  DECIMAL(5,2),
    Traffic_time_index              DECIMAL(5,2),
    Pollution_index                 DECIMAL(5,2),
    Climate_index                   DECIMAL(5,2),
    cost_living_index               DECIMAL(5,2),
    Rent_index                      DECIMAL(5,2),
    Groceries_index                 DECIMAL(5,2),
    Restaurant_price_index          DECIMAL(5,2),
    Local_purchasing_index          DECIMAL(5,2)
);
GO

/*
===============================================================================
Table: bronze.Hosts (Reference Table)
===============================================================================
*/
CREATE TABLE bronze.Hosts (
    host_id             INT PRIMARY KEY,
    host_is_superhost   VARCHAR(10),         
    multi               VARCHAR(10)         
);
GO

/*
===============================================================================
Table: bronze.RoomTypes (Reference Table)
===============================================================================
*/
CREATE TABLE bronze.RoomTypes (
    room_id         INT PRIMARY KEY IDENTITY(1,1),
    room_type       VARCHAR(50) NOT NULL,
    room_shared     VARCHAR(50),
    room_private    VARCHAR(50)
);
GO

/*
===============================================================================
Table: bronze.Housing (Main Fact Table)
===============================================================================
*/
CREATE TABLE bronze.Housing (
    ID                          INT PRIMARY KEY,
    realSum                     DECIMAL(10,2),
    person_capacity             INT,
    bedrooms                    INT,
    cleanliness_rating          DECIMAL(4,2),
    guest_satisfaction_overall  DECIMAL(6,2),
    biz                         VARCHAR(10),           
    day_type                    VARCHAR(20),
    host_id                     INT,
    room_type_id                INT,
    attr_index                  DECIMAL(10,6),
    attr_index_norm             DECIMAL(10,6),
    rest_index                  DECIMAL(10,6),
    rest_index_norm             DECIMAL(10,6),
    city                        VARCHAR(100),          
    Country                     VARCHAR(100),          
    lat                         VARCHAR(50),
    lng                         VARCHAR(50),
    dist                        DECIMAL(8,2),
    metro_dist                  DECIMAL(8,2),
    
    -- Foreign Key Constraints
    FOREIGN KEY (host_id) REFERENCES bronze.Hosts(host_id),
    FOREIGN KEY (room_type_id) REFERENCES bronze.RoomTypes(room_id),
    FOREIGN KEY (city) REFERENCES bronze.Cities_indicator(City)  
);
GO

PRINT '==========================================';
PRINT 'Bronze Layer Tables Created Successfully';
PRINT '==========================================';
GO
