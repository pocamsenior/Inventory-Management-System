/* 
===================================================
Silver Layer - Preliminary Cleaning
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
Extract = Objects[Extract],

Lists = [Objects][Lists],

Variables = Objects[Variables],

Functions = Objects[Functions],
filterList = Functions[filterList],
updateDataTypes = Functions[updateDataTypes],

// Local Definitions
cleanTable = (tbl as table) =>
    let
        // Variables
        lstColumns = Table.ColumnNames(tbl),
        txtColumn_Date = List.First(filterList(lstColumns,{{"Date"},{null}})),
        lstFunctions_Trim = List.Transform(lstColumns, (value) => each Text.Trim(_)),
        nlstTransformations_Trim = List.Zip({lstColumns,lstFunctions_Trim}),

        // Queries
        #"Sort by Partition Year, Order Date" = Table.Sort(tbl,{{"Partition Year",Order.Ascending},{txtColumn_Date,Order.Ascending}}),
        #"Transform Blanks to Nulls" = Table.ReplaceValue(#"Sort by Partition Year, Order Date","",null,Replacer.ReplaceValue,lstColumns),
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
    cleanRecords(Extract)