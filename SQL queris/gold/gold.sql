/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)
    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.
    
Usage:
    - These views can be queried directly for analytics and reporting.
    - Run this script after the Silver layer has been loaded
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_cities
-- =============================================================================
IF OBJECT_ID('gold.dim_cities', 'V') IS NOT NULL
    DROP VIEW gold.dim_cities;
GO

CREATE VIEW gold.dim_cities AS
SELECT
    ROW_NUMBER() OVER (ORDER BY City, Country) AS city_key,        -- Surrogate key
    City                                       AS city_name,
    Country                                    AS country_name,
    Quality_life_index                         AS quality_of_life_index,
    Purchasing_index                           AS purchasing_power_index,
    Safety_index                               AS safety_index,
    Healthcare_index                           AS healthcare_index,
    Property_price_to_income_ratio             AS property_price_ratio,
    Traffic_time_index                         AS traffic_index,
    Pollution_index                            AS pollution_index,
    Climate_index                              AS climate_index,
    cost_living_index                          AS cost_of_living_index,
    Rent_index                                 AS rent_index,
    Groceries_index                            AS groceries_index,
    Restaurant_price_index                     AS restaurant_price_index,
    Local_purchasing_index                     AS local_purchasing_power_index,
    -- Derived columns for analytics
    CASE 
        WHEN Quality_life_index >= 150 THEN 'Excellent'
        WHEN Quality_life_index >= 100 THEN 'Good'
        WHEN Quality_life_index >= 50 THEN 'Average'
        ELSE 'Below Average'
    END                                        AS quality_of_life_category,
    CASE 
        WHEN Safety_index >= 70 THEN 'Very Safe'
        WHEN Safety_index >= 50 THEN 'Safe'
        WHEN Safety_index >= 30 THEN 'Moderate'
        ELSE 'Low Safety'
    END                                        AS safety_category
FROM silver.Cities;
GO

-- =============================================================================
-- Create Dimension: gold.dim_hosts
-- =============================================================================
IF OBJECT_ID('gold.dim_hosts', 'V') IS NOT NULL
    DROP VIEW gold.dim_hosts;
GO

CREATE VIEW gold.dim_hosts AS
SELECT
    ROW_NUMBER() OVER (ORDER BY host_id)       AS host_key,        -- Surrogate key
    host_id                                    AS host_id,
    is_superhost                               AS is_superhost,
    has_multiple                               AS has_multiple_properties,
    -- Derived columns
    CASE 
        WHEN is_superhost = 1 AND has_multiple = 1 THEN 'Premium Multi-Property Host'
        WHEN is_superhost = 1 AND has_multiple = 0 THEN 'Superhost'
        WHEN is_superhost = 0 AND has_multiple = 1 THEN 'Multi-Property Host'
        ELSE 'Standard Host'
    END                                        AS host_category
FROM silver.Hosts;
GO

-- =============================================================================
-- Create Dimension: gold.dim_room_types
-- =============================================================================
IF OBJECT_ID('gold.dim_room_types', 'V') IS NOT NULL
    DROP VIEW gold.dim_room_types;
GO

CREATE VIEW gold.dim_room_types AS
SELECT
    ROW_NUMBER() OVER (ORDER BY room_id)       AS room_type_key,   -- Surrogate key
    room_id                                    AS room_type_id,
    room_type                                  AS room_type_name,
    is_shared                                  AS is_shared_room,
    is_private                                 AS is_private_room
	
	FROM silver.RoomTypes;
GO

-- =============================================================================
-- Create Fact Table: gold.fact_housing_rentals
-- =============================================================================
IF OBJECT_ID('gold.fact_housing_rentals', 'V') IS NOT NULL
    DROP VIEW gold.fact_housing_rentals;
GO

CREATE VIEW gold.fact_housing_rentals AS
SELECT
    h.ID                                       AS rental_id,
    
    -- Foreign Keys (Dimension Keys)
    c.city_key                                 AS city_key,
    ho.host_key                                AS host_key,
    rt.room_type_key                           AS room_type_key,
    
    -- Measures (Numeric Facts)
    h.price                                    AS price_per_night,
    h.person_capacity                          AS capacity,
    h.bedrooms                                 AS bedroom_count,
    h.cleanliness_rating                       AS cleanliness_rating,
    h.guest_satisfaction                       AS guest_satisfaction_score,
    h.attraction_index                         AS attraction_index,
    h.attraction_index_norm                    AS attraction_index_normalized,
    h.restaurant_index                         AS restaurant_index,
    h.restaurant_index_norm                    AS restaurant_index_normalized,
    h.city_center_dist                         AS distance_to_city_center,
    h.metro_dist                               AS distance_to_metro,
    h.latitude                                 AS latitude,
    h.longitude                                AS longitude,
    
    -- Degenerate Dimensions (Attributes stored in fact table)
    h.is_business                              AS is_business_rental,
    h.day_type                                 AS day_type,
    
    -- Derived Measures for Analytics
    CASE 
        WHEN h.bedrooms > 0 THEN h.price / h.bedrooms
        ELSE h.price
    END                                        AS price_per_bedroom,
    
    CASE 
        WHEN h.person_capacity > 0 THEN h.price / h.person_capacity
        ELSE h.price
    END                                        AS price_per_person,
    
    CASE 
        WHEN h.guest_satisfaction >= 90 THEN 'Excellent'
        WHEN h.guest_satisfaction >= 75 THEN 'Very Good'
        WHEN h.guest_satisfaction >= 60 THEN 'Good'
        WHEN h.guest_satisfaction >= 40 THEN 'Average'
        ELSE 'Below Average'
    END                                        AS satisfaction_category,
    
    CASE 
        WHEN h.price < 50 THEN 'Budget'
        WHEN h.price < 100 THEN 'Economy'
        WHEN h.price < 200 THEN 'Standard'
        WHEN h.price < 400 THEN 'Premium'
        ELSE 'Luxury'
    END                                        AS price_category,
    
    CASE 
        WHEN h.city_center_dist < 2 THEN 'City Center'
        WHEN h.city_center_dist < 5 THEN 'Near Center'
        WHEN h.city_center_dist < 10 THEN 'Moderate Distance'
        ELSE 'Far from Center'
    END                                        AS location_category

FROM silver.Housing h

-- Join with dimension views to get surrogate keys
LEFT JOIN gold.dim_cities c
    ON h.city = c.city_name AND h.country = c.country_name

LEFT JOIN gold.dim_hosts ho
    ON h.host_id = ho.host_id

LEFT JOIN gold.dim_room_types rt
    ON h.room_type_id = rt.room_type_id


WHERE h.price IS NOT NULL;  -- Ensure we only include valid rental records
GO

