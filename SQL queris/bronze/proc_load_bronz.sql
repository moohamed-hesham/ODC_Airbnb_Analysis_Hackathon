/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Deletes existing data from tables in the correct order (child first, then parents).
    - Uses the `BULK INSERT` command to load data from CSV files to bronze tables.
    - Tracks loading time for each table and provides total execution time.

Parameters:
    None. 
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';
        PRINT '';

        -- ====================================================================
        -- STEP 1: DELETE EXISTING DATA (Child First, Then Parents)
        -- ====================================================================
        PRINT '------------------------------------------------';
        PRINT 'Step 1: Deleting Existing Data';
        PRINT '------------------------------------------------';

        PRINT '>> Deleting Data From: bronze.Housing (Child Table)';
        DELETE FROM bronze.Housing;
        PRINT '>> Deleted Successfully';

        PRINT '>> Deleting Data From: bronze.RoomTypes (Parent Table)';
        DELETE FROM bronze.RoomTypes;
        PRINT '>> Deleted Successfully';

        PRINT '>> Deleting Data From: bronze.Hosts (Parent Table)';
        DELETE FROM bronze.Hosts;
        PRINT '>> Deleted Successfully';

        PRINT '>> Deleting Data From: bronze.Cities_indicator (Parent Table)';
        DELETE FROM bronze.Cities_indicator;
        PRINT '>> Deleted Successfully';
        PRINT '';

        -- ====================================================================
        -- STEP 2: LOAD PARENT/REFERENCE TABLES
        -- ====================================================================
        PRINT '------------------------------------------------';
        PRINT 'Step 2: Loading Parent/Reference Tables';
        PRINT '------------------------------------------------';
        PRINT '';

        -- Load Cities_indicator (MUST be first - Housing references it)
        SET @start_time = GETDATE();
        PRINT '>> Inserting Data Into: bronze.Cities_indicator';
        BULK INSERT bronze.Cities_indicator
        FROM 'C:\Users\mh309\OneDrive\سطح المكتب\Hackthon\city.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '';

        -- Load Hosts
        SET @start_time = GETDATE();
        PRINT '>> Inserting Data Into: bronze.Hosts';
        BULK INSERT bronze.Hosts
        FROM 'C:\Users\mh309\OneDrive\سطح المكتب\Hackthon\hosts.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '';

        -- Load RoomTypes
        SET @start_time = GETDATE();
        PRINT '>> Inserting Data Into: bronze.RoomTypes';
        BULK INSERT bronze.RoomTypes
        FROM 'C:\Users\mh309\OneDrive\سطح المكتب\Hackthon\room_types.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '';

        -- ====================================================================
        -- STEP 3: LOAD CHILD/MAIN TABLE
        -- ====================================================================
        PRINT '------------------------------------------------';
        PRINT 'Step 3: Loading Child/Main Table';
        PRINT '------------------------------------------------';
        PRINT '';

        SET @start_time = GETDATE();
        PRINT '>> Inserting Data Into: bronze.Housing';
        BULK INSERT bronze.Housing
        FROM 'C:\Users\mh309\OneDrive\سطح المكتب\Hackthon\Housing.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '';

        -- ====================================================================
  

        SET @batch_end_time = GETDATE();
        PRINT '';
        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END
GO

