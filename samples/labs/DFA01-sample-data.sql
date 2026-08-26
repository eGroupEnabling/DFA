-- DFA01 sample schema and seed data for spaceship-parts inventory + Fabric NLQ lab
-- Run this script against your deployed Azure SQL Database.

IF OBJECT_ID('dbo.SpaceshipPartsInventory', 'U') IS NOT NULL
    DROP TABLE dbo.SpaceshipPartsInventory;
GO

CREATE TABLE dbo.SpaceshipPartsInventory (
    PartID INT NOT NULL PRIMARY KEY,
    PartNumber NVARCHAR(20) NOT NULL,
    PartName NVARCHAR(100) NOT NULL,
    PartCategory NVARCHAR(50) NOT NULL,
    ShipClass NVARCHAR(50) NOT NULL,
    CompatiblePlatform NVARCHAR(60) NOT NULL,
    Manufacturer NVARCHAR(100) NOT NULL,
    SupplierRegion NVARCHAR(50) NOT NULL,
    Material NVARCHAR(50) NOT NULL,
    CertificationLevel NVARCHAR(30) NOT NULL,
    WarehouseLocation NVARCHAR(50) NOT NULL,
    MissionCriticality NVARCHAR(20) NOT NULL,
    InventoryStatus NVARCHAR(20) NOT NULL,
    StockQuantity INT NOT NULL,
    ReorderPoint INT NOT NULL,
    UnitCost DECIMAL(12,2) NOT NULL,
    LeadTimeDays INT NOT NULL,
    MassKg DECIMAL(10,2) NOT NULL,
    PowerDrawKw DECIMAL(10,2) NOT NULL,
    FailureRatePct DECIMAL(5,2) NOT NULL,
    LastInspectionDate DATE NOT NULL,
    VendorRating DECIMAL(3,1) NOT NULL
);
GO

;WITH numbers AS (
    SELECT TOP (1000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
base AS (
    SELECT
        200000 + n AS PartID,
        CONCAT('SP-', RIGHT('000000' + CAST(200000 + n AS VARCHAR(6)), 6)) AS PartNumber,
        CASE (n - 1) % 10
            WHEN 0 THEN CONCAT('Ion Thruster Nozzle ', CHAR(65 + (((n - 1) / 10) % 8)))
            WHEN 1 THEN CONCAT('Star Tracker Assembly ', CHAR(65 + (((n - 1) / 10) % 8)))
            WHEN 2 THEN CONCAT('Oxygen Recycler Pump ', CHAR(65 + (((n - 1) / 10) % 8)))
            WHEN 3 THEN CONCAT('Composite Hull Panel ', CHAR(65 + (((n - 1) / 10) % 8)))
            WHEN 4 THEN CONCAT('Manipulator Servo Kit ', CHAR(65 + (((n - 1) / 10) % 8)))
            WHEN 5 THEN CONCAT('Thermal Radiator Grid ', CHAR(65 + (((n - 1) / 10) % 8)))
            WHEN 6 THEN CONCAT('Fusion Cell Regulator ', CHAR(65 + (((n - 1) / 10) % 8)))
            WHEN 7 THEN CONCAT('Quantum Relay Transceiver ', CHAR(65 + (((n - 1) / 10) % 8)))
            WHEN 8 THEN CONCAT('Docking Clamp Actuator ', CHAR(65 + (((n - 1) / 10) % 8)))
            ELSE CONCAT('Long-Range Lidar Pod ', CHAR(65 + (((n - 1) / 10) % 8)))
        END AS PartName,
        CASE (n - 1) % 10
            WHEN 0 THEN 'Propulsion'
            WHEN 1 THEN 'Navigation'
            WHEN 2 THEN 'Life Support'
            WHEN 3 THEN 'Hull'
            WHEN 4 THEN 'Robotics'
            WHEN 5 THEN 'Thermal Control'
            WHEN 6 THEN 'Power Systems'
            WHEN 7 THEN 'Communications'
            WHEN 8 THEN 'Docking'
            ELSE 'Sensor Array'
        END AS PartCategory,
        CASE (n - 1) % 6
            WHEN 0 THEN 'Explorer'
            WHEN 1 THEN 'Freighter'
            WHEN 2 THEN 'Shuttle'
            WHEN 3 THEN 'Research'
            WHEN 4 THEN 'Colony'
            ELSE 'Interceptor'
        END AS ShipClass,
        CASE (n - 1) % 6
            WHEN 0 THEN 'Aurora Explorer'
            WHEN 1 THEN 'Atlas Freighter'
            WHEN 2 THEN 'Comet Shuttle'
            WHEN 3 THEN 'Horizon Research Vessel'
            WHEN 4 THEN 'Nebula Colony Carrier'
            ELSE 'Vanguard Interceptor'
        END AS CompatiblePlatform,
        CASE (n - 1) % 12
            WHEN 0 THEN 'NovaForge Industries'
            WHEN 1 THEN 'Helios Drive Works'
            WHEN 2 THEN 'Orbital Foundry'
            WHEN 3 THEN 'Pioneer Vacuum Systems'
            WHEN 4 THEN 'Quasar Dynamics'
            WHEN 5 THEN 'Redline Avionics'
            WHEN 6 THEN 'Starlift Manufacturing'
            WHEN 7 THEN 'Titan Habitat Systems'
            WHEN 8 THEN 'Umbra Signal Labs'
            WHEN 9 THEN 'Vector Alloy Works'
            WHEN 10 THEN 'Waypoint Robotics'
            ELSE 'Zenith Propulsion Group'
        END AS Manufacturer,
        CASE (n - 1) % 8
            WHEN 0 THEN 'Pacific Northwest'
            WHEN 1 THEN 'Gulf Coast'
            WHEN 2 THEN 'Western Europe'
            WHEN 3 THEN 'Central Europe'
            WHEN 4 THEN 'East Asia'
            WHEN 5 THEN 'Southeast Asia'
            WHEN 6 THEN 'Lunar Gateway'
            ELSE 'Mars Forward Ops'
        END AS SupplierRegion,
        CASE (n - 1) % 8
            WHEN 0 THEN 'Titanium Alloy'
            WHEN 1 THEN 'Carbon Composite'
            WHEN 2 THEN 'Aluminum-Lithium'
            WHEN 3 THEN 'Inconel'
            WHEN 4 THEN 'Graphene Mesh'
            WHEN 5 THEN 'CryoGlass'
            WHEN 6 THEN 'Ceramic Matrix'
            ELSE 'Copper-Nickel'
        END AS Material,
        CASE (n - 1) % 4
            WHEN 0 THEN 'Orbital Standard'
            WHEN 1 THEN 'Flight Ready'
            WHEN 2 THEN 'Mission Critical'
            ELSE 'Prototype Approved'
        END AS CertificationLevel,
        CASE (n - 1) % 6
            WHEN 0 THEN 'Seattle Hangar'
            WHEN 1 THEN 'Houston Depot'
            WHEN 2 THEN 'Rotterdam Yard'
            WHEN 3 THEN 'Singapore Dock'
            WHEN 4 THEN 'Lunar Gateway Bay'
            ELSE 'Mars Relay Cache'
        END AS WarehouseLocation,
        CASE (n - 1) % 10
            WHEN 0 THEN 'Critical'
            WHEN 1 THEN 'High'
            WHEN 2 THEN 'Critical'
            WHEN 3 THEN 'Medium'
            WHEN 4 THEN 'High'
            WHEN 5 THEN 'Medium'
            WHEN 6 THEN 'Critical'
            WHEN 7 THEN 'High'
            WHEN 8 THEN 'Critical'
            ELSE 'High'
        END AS MissionCriticality,
        6 + ((n * 13) % 240) AS StockQuantity,
        12 + ((n * 7) % 70) AS ReorderPoint,
        CAST(
            CASE (n - 1) % 10
                WHEN 0 THEN 18500
                WHEN 1 THEN 11200
                WHEN 2 THEN 9400
                WHEN 3 THEN 7200
                WHEN 4 THEN 8600
                WHEN 5 THEN 6800
                WHEN 6 THEN 15400
                WHEN 7 THEN 7900
                WHEN 8 THEN 12800
                ELSE 9800
            END + ((n * 37) % 2200) AS DECIMAL(12,2)
        ) AS UnitCost,
        6 + ((n * 11) % 120) AS LeadTimeDays,
        CAST(
            CASE (n - 1) % 10
                WHEN 0 THEN 44.0
                WHEN 1 THEN 18.5
                WHEN 2 THEN 26.0
                WHEN 3 THEN 65.0
                WHEN 4 THEN 22.0
                WHEN 5 THEN 31.0
                WHEN 6 THEN 28.0
                WHEN 7 THEN 14.0
                WHEN 8 THEN 38.0
                ELSE 12.5
            END + (((n * 5) % 14) / 10.0) AS DECIMAL(10,2)
        ) AS MassKg,
        CAST(
            CASE (n - 1) % 10
                WHEN 0 THEN 22.0
                WHEN 1 THEN 8.0
                WHEN 2 THEN 14.0
                WHEN 3 THEN 2.5
                WHEN 4 THEN 11.0
                WHEN 5 THEN 6.5
                WHEN 6 THEN 18.0
                WHEN 7 THEN 9.0
                WHEN 8 THEN 7.5
                ELSE 10.5
            END + (((n * 3) % 10) / 10.0) AS DECIMAL(10,2)
        ) AS PowerDrawKw,
        CAST(0.20 + (((n * 3) % 43) / 10.0) AS DECIMAL(5,2)) AS FailureRatePct,
        DATEADD(DAY, -((n * 5) % 180), CAST('2026-04-01' AS DATE)) AS LastInspectionDate,
        CAST(3.2 + (((n * 5) % 18) / 10.0) AS DECIMAL(3,1)) AS VendorRating
    FROM numbers
)
INSERT INTO dbo.SpaceshipPartsInventory (
    PartID,
    PartNumber,
    PartName,
    PartCategory,
    ShipClass,
    CompatiblePlatform,
    Manufacturer,
    SupplierRegion,
    Material,
    CertificationLevel,
    WarehouseLocation,
    MissionCriticality,
    InventoryStatus,
    StockQuantity,
    ReorderPoint,
    UnitCost,
    LeadTimeDays,
    MassKg,
    PowerDrawKw,
    FailureRatePct,
    LastInspectionDate,
    VendorRating
)
SELECT
    PartID,
    PartNumber,
    PartName,
    PartCategory,
    ShipClass,
    CompatiblePlatform,
    Manufacturer,
    SupplierRegion,
    Material,
    CertificationLevel,
    WarehouseLocation,
    MissionCriticality,
    CASE
        WHEN StockQuantity <= ReorderPoint THEN 'Reorder'
        WHEN StockQuantity <= ReorderPoint + 20 THEN 'Monitor'
        ELSE 'Healthy'
    END AS InventoryStatus,
    StockQuantity,
    ReorderPoint,
    UnitCost,
    LeadTimeDays,
    MassKg,
    PowerDrawKw,
    FailureRatePct,
    LastInspectionDate,
    VendorRating
FROM base;
GO

-- Validation query 1: Confirm row count.
SELECT COUNT(*) AS PartCount
FROM dbo.SpaceshipPartsInventory;
GO

-- Validation query 2: Inventory value by ship class.
SELECT
    ShipClass,
    SUM(StockQuantity * UnitCost) AS InventoryValue
FROM dbo.SpaceshipPartsInventory
GROUP BY ShipClass
ORDER BY InventoryValue DESC;
GO

-- Validation query 3: Parts that need attention first.
SELECT TOP 10
    PartNumber,
    PartName,
    PartCategory,
    WarehouseLocation,
    StockQuantity,
    ReorderPoint,
    LeadTimeDays,
    UnitCost
FROM dbo.SpaceshipPartsInventory
ORDER BY (StockQuantity - ReorderPoint) ASC, UnitCost DESC;
GO
