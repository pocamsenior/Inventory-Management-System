/* 
=========================================================================================
Global - Objects
=========================================================================================
# Script Definition
This script allows for dynamic navigation by connecting the source folder *.m files and the excel file.

# User Actions
## In Script
Define your folder and file paths in this script.

## In Power Query
### Objects Query
Define the absolute path(s) you will be using to connect the *.m files to the excel file.
=========================================================================================
*/

let 
// Storage Definition - If you need to constantly change sources for this system, create a variable for the absolute path
cloudMac = "\\Mac\iCloud\Data Analysis\Projects\Inventory Management System\Inventory-Management-System\",

// Folder Definition
// *.csv
csv = "Data\1.0 CSV\",

// Global Layer
Global = "Source\0.0 Global\",

// Data Layers
Bronze ="Source\1.0 Bronze\",
Silver = "Source\2.0 Silver\",
Gold = "Source\3.0 Gold\",

// Evaluation Formulas
evalFolder = (folder) => Folder.Contents(folder),
evalFile = (file) => Expression.Evaluate(Text.FromBinary(File.Contents(file)),#shared),

Objects = (path) =>
[
    // *.csv Files
    csv_PurchaseOrders = evalFolder(Text.Combine({path, csv,"Purchase Orders"})),
    csv_InventoryChecks = evalFolder(Text.Combine({path, csv,"Inventory Checks"})),
    csv_PurchaseRequests = evalFolder(Text.Combine({path, csv,"Purchase Requests"})),

    // Global Files
    Variables = evalFile(Text.Combine({path, Global,"0.3 Variables.m"})),
    Functions = evalFile(Text.Combine({path, Global,"0.4 Functions.m"})),

    // Bronze Layer
    Import = evalFile(Text.Combine({path, Bronze,"1.1 Import.m"})),
    Extract = evalFile(Text.Combine({path, Bronze,"1.2 Extract.m"})),

    // Silver Layer
    prelimClean = evalFile(Text.Combine({path, Silver,"2.1 prelimClean.m"})),
    deepClean_dimTables = evalFile(Text.Combine({path, Silver,"2.2 deepClean_dimTables.m"})),
    deepClean_factTables = evalFile(Text.Combine({path, Silver,"2.2 deepClean_factTables.m"})),

    // Gold Layer
    dimProducts = evalFile(Text.Combine({path, Gold,"dimProducts.m"})),
    factOrders = evalFile(Text.Combine({path, Gold,"factOrders.m"})),
    factProductHealth = evalFile(Text.Combine({path, Gold,"factProductHealth.m"})),
    factPurchaseRequests = evalFile(Text.Combine({path, Gold,"factPurchaseRequests.m"}))

]
    
in 
    Objects(cloudMac)