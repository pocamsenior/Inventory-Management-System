/* 
===================================================
Bronze Layer - Extract Tables
===================================================
# Script Definition
This script creates a combined record for all csv files in the data folder as tables
===================================================
*/

let
// Global Definitions
Objects = #shared[Objects],
Lists = [Objects][Lists],
Variables = Objects[Variables],
Functions = Objects[Functions],

brz_Import = Objects[brz_Import],

// Local Definitions
combineTables = (tbl as table) => Table.Combine(tbl[Content]),

extractTables = (files as record) => 
let
    // Variables
    lstRecordFields = Record.FieldNames(files),
    lstFiles = Record.ToList(files),

    // Queries
    #"Combine Tables" = List.Transform(lstFiles, each combineTables(_)),
    #"Transform List to Record" = Record.FromList(#"Combine Tables",lstRecordFields)
in
    #"Transform List to Record"

in
extractTables(brz_Import)