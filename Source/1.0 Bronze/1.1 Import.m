/* 
===================================================
Bronze Layer - Import CSV Files
===================================================
# Script Definition
This script creates a combined record for all csv files in the data folder
===================================================
*/

let
// Global Definitions
Objects = #shared[Objects],
csv_PurchaseOrders = Objects[csv_PurchaseOrders],
csv_InventoryChecks = Objects[csv_InventoryChecks],
csv_PurchaseRequests = Objects[csv_PurchaseRequests],

Variables = Objects[Variables],
Functions = Objects[Functions],

// Local Definitions
createTables = (tbl as table) =>
    let
        #"Filter Hidden Files" = Table.SelectRows(tbl, each not Text.StartsWith([Name],".")),
        #"Transform Binary Column to Tables" = Table.TransformColumns(#"Filter Hidden Files",{"Content", each Csv.Document(_)}),
        #"Add Refresh Timestamp Column" = Table.AddColumn(#"Transform Binary Column to Tables","Refresh Timestamp",each DateTime.LocalNow()),
        #"Sort Table by Name" = Table.Sort(#"Add Refresh Timestamp Column",{"Name",Order.Ascending}),
        #"Promote CSV Headers" = Table.TransformColumns(#"Sort Table by Name", {"Content", each Table.PromoteHeaders(_)})
    in
        #"Promote CSV Headers",

importTables = (files as record) => 
    let
        // Variables
        lstRecordFields = Record.FieldNames(files),
        lstFiles = Record.ToList(files),
        
        // Queries
        #"Create Binary Files" = List.Transform(lstFiles, each createTables(_)),
        #"Transform List to Record" = Record.FromList(#"Create Binary Files",lstRecordFields)
    in
        #"Transform List to Record",

Import =
[
    PurchaseOrders = csv_PurchaseOrders,
    InventoryChecks = csv_InventoryChecks,
    PurchaseRequests = csv_PurchaseRequests
]

in
    importTables(Import)