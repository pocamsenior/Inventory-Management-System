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

    // Global Files
    Lists = evalFile(Text.Combine({path,Global,"0.2 Lists.m"})),
    Variables = evalFile(Text.Combine({path, Global,"0.3 Variables.m"})),
    Functions = evalFile(Text.Combine({path, Global,"0.4 Functions.m"})),

    // Bronze Layer
    brz_Import = evalFile(Text.Combine({path, Bronze,"1.1 brz_Import.m"})),
    brz_Extract = evalFile(Text.Combine({path, Bronze,"1.2 brz_Extract.m"})),

    // Silver Layer
    slv_Clean = evalFile(Text.Combine({path, Silver,"2.1 slv_Clean.m"})),
    slv_dimTables = evalFile(Text.Combine({path, Silver,"2.2 slv_dimTables.m"})),
    slv_factTables = evalFile(Text.Combine({path, Silver,"2.3 slv_factTables.m"}))

]
    
in 
    Objects(cloudMac)