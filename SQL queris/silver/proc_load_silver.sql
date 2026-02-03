/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    Transforms and loads data from bronze to silver layer with:
    - Data quality checks and validation
    - Derived columns for analytics
    - Data cleaning and type conversions

Usage Example:
    EXEC silver.load_silver;
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @orphan_hosts INT, @orphan_rooms INT, @orphan_cities INT;
    
    BEGIN TRY
        SET @start_time = GETDATE();
        
        PRINT '================================================';
        PRINT 'Loading Silver Layer from Bronze';
        PRINT '================================================';
        PRINT '';


        -- ====================================================================
        -- STEP 2: CLEAR EXISTING DATA
        -- ====================================================================
        PRINT '------------------------------------------------';
        PRINT 'Step 2: Clearing Existing Data';
        PRINT '------------------------------------------------';

        DELETE FROM silver.Housing;
        DELETE FROM silver.RoomTypes;
        DELETE FROM silver.Hosts;
        DELETE FROM silver.Cities;
        PRINT '>> All tables cleared';
        PRINT '';

        -- ====================================================================
        -- STEP 3: LOAD REFERENCE TABLES
        -- ====================================================================
        PRINT '------------------------------------------------';
        PRINT 'Step 3: Loading Reference Tables';
        PRINT '------------------------------------------------';

        -- Load Cities (cleaned)
        INSERT INTO silver.Cities
        SELECT 
            LTRIM(RTRIM(City)) AS City,
            LTRIM(RTRIM(Country)) AS Country,
            Quality_life_index,
            Purchasing_index,
            Safety_index,
            Healthcare_index,
            Property_price_to_income_ratio,
            Traffic_time_index,
            Pollution_index,
            Climate_index,
            cost_living_index,
            Rent_index,
            Groceries_index,
            Restaurant_price_index,
            Local_purchasing_index
        FROM bronze.Cities_indicator
        WHERE City IS NOT NULL AND Country IS NOT NULL;
        PRINT '>> Cities loaded: ' + CAST(@@ROWCOUNT AS VARCHAR);

        -- Load Hosts (convert to boolean)
        INSERT INTO silver.Hosts
        SELECT 
            host_id,
            CASE WHEN LOWER(LTRIM(RTRIM(host_is_superhost))) = 'true' THEN 1 ELSE 0 END AS is_superhost,
            CASE WHEN LOWER(LTRIM(RTRIM(multi))) = 'yes' THEN 1 ELSE 0 END AS has_multiple
        FROM bronze.Hosts;
        PRINT '>> Hosts loaded: ' + CAST(@@ROWCOUNT AS VARCHAR);

        -- Load RoomTypes (convert to boolean)
        INSERT INTO silver.RoomTypes (room_id, room_type, is_shared, is_private)
        SELECT 
            room_id,
            LTRIM(RTRIM(room_type)) AS room_type,
            CASE WHEN LOWER(LTRIM(RTRIM(room_shared))) IN ('true', 'yes', '1') THEN 1 ELSE 0 END AS is_shared,
            CASE WHEN LOWER(LTRIM(RTRIM(room_private))) IN ('true', 'yes', '1') THEN 1 ELSE 0 END AS is_private
        FROM bronze.RoomTypes;
        PRINT '>> RoomTypes loaded: ' + CAST(@@ROWCOUNT AS VARCHAR);
        PRINT '';

        -- ====================================================================
        -- STEP 4: LOAD HOUSING WITH VALIDATION & DERIVED COLUMNS
        -- ====================================================================
        PRINT '------------------------------------------------';
        PRINT 'Step 4: Loading Housing (Main Table)';
        PRINT '------------------------------------------------';

        INSERT INTO silver.Housing
        SELECT 
            ID,
            -- Clean price data
            CASE 
                WHEN realSum < 0 THEN NULL 
                WHEN realSum > 100000 THEN NULL  -- Remove outliers
                ELSE realSum 
            END AS price,
            
            -- Validate capacity
            CASE 
                WHEN person_capacity < 0 THEN NULL
                WHEN person_capacity > 50 THEN NULL  -- Remove outliers
                ELSE person_capacity 
            END AS person_capacity,
            
            -- Validate bedrooms
            CASE 
                WHEN bedrooms < 0 THEN NULL
                WHEN bedrooms > 20 THEN NULL  -- Remove outliers
                ELSE bedrooms 
            END AS bedrooms,
            
            -- Validate ratings (should be 0-10 scale)
            CASE 
                WHEN cleanliness_rating < 0 OR cleanliness_rating > 10 THEN NULL
                ELSE cleanliness_rating 
            END AS cleanliness_rating,
            
            CASE 
                WHEN guest_satisfaction_overall < 0 OR guest_satisfaction_overall > 100 THEN NULL
                ELSE guest_satisfaction_overall 
            END AS guest_satisfaction,
            
            CASE WHEN LOWER(LTRIM(RTRIM(biz))) = 'yes' THEN 1 ELSE 0 END AS is_business,
            LTRIM(RTRIM(day_type)) AS day_type,
            host_id,
            room_type_id,
            
            -- Validate indexes (should be non-negative)
            CASE WHEN attr_index < 0 THEN NULL ELSE attr_index END AS attraction_index,
            CASE WHEN attr_index_norm < 0 THEN NULL ELSE attr_index_norm END AS attraction_index_norm,
            CASE WHEN rest_index < 0 THEN NULL ELSE rest_index END AS restaurant_index,
            CASE WHEN rest_index_norm < 0 THEN NULL ELSE rest_index_norm END AS restaurant_index_norm,
            
            LTRIM(RTRIM(city)) AS city,
            LTRIM(RTRIM(Country)) AS country,
            
            -- Clean coordinates (valid latitude: -90 to 90, longitude: -180 to 180)
            CASE 
                WHEN TRY_CAST(lat AS DECIMAL(10,6)) BETWEEN -90 AND 90 
                THEN TRY_CAST(lat AS DECIMAL(10,6))
                ELSE NULL
            END AS latitude,
            
            CASE 
                WHEN TRY_CAST(lng AS DECIMAL(10,6)) BETWEEN -180 AND 180 
                THEN TRY_CAST(lng AS DECIMAL(10,6))
                ELSE NULL
            END AS longitude,
            
            -- Validate distances (should be non-negative)
            CASE WHEN dist < 0 THEN NULL ELSE dist END AS city_center_dist,
            CASE WHEN metro_dist < 0 THEN NULL ELSE metro_dist END AS metro_dist
            
        FROM bronze.Housing
        WHERE 
            -- Only load records with valid data
            realSum IS NOT NULL 
            AND host_id IS NOT NULL 
            AND room_type_id IS NOT NULL
            AND city IS NOT NULL
            -- Exclude orphaned foreign keys
            AND room_type_id IN (SELECT room_id FROM bronze.RoomTypes WHERE room_id IS NOT NULL)
            AND host_id IN (SELECT host_id FROM bronze.Hosts WHERE host_id IS NOT NULL)
            AND city IN (SELECT City FROM bronze.Cities_indicator WHERE City IS NOT NULL);
            
        PRINT '>> Housing records loaded: ' + CAST(@@ROWCOUNT AS VARCHAR);
        PRINT '';

        -- ====================================================================
        -- STEP 5: DATA QUALITY SUMMARY
        -- ====================================================================
        PRINT '------------------------------------------------';
        PRINT 'Step 5: Final Data Quality Summary';
        PRINT '------------------------------------------------';

        DECLARE @null_prices INT, @null_coords INT, @null_ratings INT;

        SELECT @null_prices = COUNT(*) FROM silver.Housing WHERE price IS NULL;
        SELECT @null_coords = COUNT(*) FROM silver.Housing WHERE latitude IS NULL OR longitude IS NULL;
        SELECT @null_ratings = COUNT(*) FROM silver.Housing WHERE cleanliness_rating IS NULL OR guest_satisfaction IS NULL;

        PRINT '>> Records with NULL price: ' + CAST(@null_prices AS VARCHAR);
        PRINT '>> Records with NULL coordinates: ' + CAST(@null_coords AS VARCHAR);
        PRINT '>> Records with NULL ratings: ' + CAST(@null_ratings AS VARCHAR);
        PRINT '';

        SET @end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Silver Layer Load Completed Successfully';
        PRINT 'Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR: ' + ERROR_MESSAGE();
        PRINT 'Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT '==========================================';
        THROW;
    END CATCH
END
GO

