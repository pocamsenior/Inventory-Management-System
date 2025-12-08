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
    csvFolder = "Data\1.0 CSV\",

    // Global
    GlobalFolder = "Source\0.0 Global\",

    // Data Layers
    BronzeLayerFolder ="Source\1.0 Bronze Layer\",
    SilverLayerFolder = "Source\2.0 Silver Layer\",
    GoldLayerFolder = "Source\3.0 Gold Layer\",

// Evaluation Formulas
    evalFolder = (folder) => Folder.Contents(folder),
    evalFile = (file) => Expression.Evaluate(Text.FromBinary(File.Contents(file)),#shared),

// Project Objects
    Objects = (path) =>
    [
        // *.csv Files
        csv_PurchaseOrders = evalFolder(Text.Combine({path, csvFolder,"Purchase Orders"})),

        // Global Files
        Lists = evalFile(Text.Combine({path,GlobalFolder,"0.2 Lists.m"})),
        Variables = evalFile(Text.Combine({path, GlobalFolder,"0.3 Variables.m"})),
        Functions = evalFile(Text.Combine({path, GlobalFolder,"0.4 Functions.m"}))
    ]
    
in 
    Objects(cloudMac)