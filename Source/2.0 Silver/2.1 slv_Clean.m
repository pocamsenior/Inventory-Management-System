/* 
===================================================
Bronze Layer - Preliminary Cleaning
===================================================
# Script Definition
This script performs a general preliminary cleaning of all tables from the bronze extract record
1. Transform Blanks to Nulls
2. Trim all data fields
3. Update Data Types
===================================================
*/

let

// Global Definitions
Objects = #shared[Objects],
Lists = [Objects][Lists],
Variables = Objects[Variables],
Functions = Objects[Functions],

updateDataTypes = Functions[updateDataTypes],

brz_Extract = Objects[brz_Extract],

// Local Definitions
cleanTable = (tbl as table) =>
let
    // Variables
    lstColumns = Table.ColumnNames(tbl),
    lstFunctions_Trim = List.Transform(lstColumns, (value) => each Text.Trim(_)),
    nlstTransformations_Trim = List.Zip({lstColumns,lstFunctions_Trim}),

    // Queries
    #"Transform Blanks to Nulls" = Table.ReplaceValue(tbl,"",null,Replacer.ReplaceValue,lstColumns),
    #"Trim Words" = Table.TransformColumns(#"Transform Blanks to Nulls",nlstTransformations_Trim),
    #"Update Data Types" =  updateDataTypes(#"Trim Words")
in
    #"Update Data Types",

cleanRecords = (rec as record) =>
let
    // Variables
    lstRecordFieldNames = Record.FieldNames(rec),
    lstTables = Record.ToList(rec),

    // Queries
    #"Clean Tables" = List.Transform(lstTables, each cleanTable(_)),
    #"Transform List to Record" = Record.FromList(#"Clean Tables", lstRecordFieldNames)
in
    #"Transform List to Record"

in
cleanRecords(brz_Extract)