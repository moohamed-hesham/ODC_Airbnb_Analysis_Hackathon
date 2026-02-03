/*
===============================================================================
DDL Script: Create Silver Tables for Housing Database
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema with cleaned and 
    transformed data from the bronze layer.
    Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

-- Check if silver schema exists, if not create it
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
    PRINT 'Schema "silver" created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema "silver" already exists.';
END
GO

-- Drop tables in correct order (child first)
IF OBJECT_ID('silver.Housing', 'U') IS NOT NULL
    DROP TABLE silver.Housing;
GO

IF OBJECT_ID('silver.RoomTypes', 'U') IS NOT NULL
    DROP TABLE silver.RoomTypes;
GO

IF OBJECT_ID('silver.Hosts', 'U') IS NOT NULL
    DROP TABLE silver.Hosts;
GO

IF OBJECT_ID('silver.Cities', 'U') IS NOT NULL
    DROP TABLE silver.Cities;
GO

/*
===============================================================================
Table: silver.Cities (Reference Table)
===============================================================================
Purpose: Cleaned city indicators with validated data
*/
CREATE TABLE silver.Cities (
    City                            VARCHAR(100) PRIMARY KEY,
    Country                         VARCHAR(100) NOT NULL,
    Quality_life_index              DECIMAL(5,2),
    Purchasing_index                DECIMAL(5,2),
    Safety_index                    DECIMAL(5,2),
    Healthcare_index                DECIMAL(5,2),
    Property_price_to_income_ratio  DECIMAL(5,2),
    Traffic_time_index              DECIMAL(5,2),
    Pollution_index                 DECIMAL(5,2),
    Climate_index                   DECIMAL(5,2),
    Cost_living_index               DECIMAL(5,2),
    Rent_index                      DECIMAL(5,2),
    Groceries_index                 DECIMAL(5,2),
    Restaurant_price_index          DECIMAL(5,2),
    Local_purchasing_index          DECIMAL(5,2)
);
GO

/*
===============================================================================
Table: silver.Hosts (Reference Table)
===============================================================================
Purpose: Cleaned host information with boolean conversions
*/
CREATE TABLE silver.Hosts (
    host_id             INT PRIMARY KEY,
    is_superhost        BIT NOT NULL,           -- Converted to boolean
    has_multiple        BIT NOT NULL            -- Converted to boolean
);
GO

/*
===============================================================================
Table: silver.RoomTypes (Reference Table)
===============================================================================
Purpose: Cleaned room type information
*/
CREATE TABLE silver.RoomTypes (
    room_id         INT PRIMARY KEY,
    room_type       VARCHAR(50) NOT NULL,
    is_shared       VARCHAR(50) NOT NULL,
    is_private      VARCHAR(50) NOT NULL
);
GO

/*
===============================================================================
Table: silver.Housing (Main Fact Table)
===============================================================================
Purpose: Cleaned housing data with validated metrics
*/
CREATE TABLE silver.Housing (
    ID                          INT PRIMARY KEY,
    price                       DECIMAL(10,2) NOT NULL,
    person_capacity             INT,
    bedrooms                    INT,
    cleanliness_rating          DECIMAL(4,2),
    guest_satisfaction          DECIMAL(6,2),
    is_business                 BIT,
    day_type                    VARCHAR(20),
    host_id                     INT NOT NULL,
    room_type_id                INT NOT NULL,
    attraction_index            DECIMAL(10,6),
    attraction_index_norm       DECIMAL(10,6),
    restaurant_index            DECIMAL(10,6),
    restaurant_index_norm       DECIMAL(10,6),
    city                        VARCHAR(100) NOT NULL,
    country                     VARCHAR(100) NOT NULL,
    latitude                    DECIMAL(10,6),
    longitude                   DECIMAL(10,6),
    city_center_dist            DECIMAL(8,2),
    metro_dist                  DECIMAL(8,2),
    
    -- Foreign Key Constraints
    CONSTRAINT FK_Housing_Host FOREIGN KEY (host_id) REFERENCES silver.Hosts(host_id),
    CONSTRAINT FK_Housing_RoomType FOREIGN KEY (room_type_id) REFERENCES silver.RoomTypes(room_id),
    CONSTRAINT FK_Housing_City FOREIGN KEY (city) REFERENCES silver.Cities(City)
);
GO

PRINT '==========================================';
PRINT 'Silver Layer Tables Created Successfully';
PRINT '==========================================';
GO
