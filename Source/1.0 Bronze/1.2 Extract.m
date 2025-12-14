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
Import = Objects[Import],

Lists = [Objects][Lists],

Variables = Objects[Variables],

Functions = Objects[Functions],
posText_List = Functions[posText_List],

// Local Definitions
extractTables = (files as record) => 
    let
        // Variables
        lstRecordFields = Record.FieldNames(files),
        lstFiles = Record.ToList(files),

        // Queries
        #"Partition by Year" = List.Transform(lstFiles, each 
        let
            lstTables = _[Content],
            lstYears = List.Transform(_[Name], each Text.BeforeDelimiter(_,"_"))
        in
            List.Transform(lstTables, (item) => 
            let
                position = List.PositionOf(lstTables,item)
            in
                Table.AddColumn(item,"Partition Year", each lstYears{position})) 
        ),
        #"Combine Tables" = List.Transform(#"Partition by Year", each Table.Combine(_)),
        #"Transform List to Record" = Record.FromList(#"Combine Tables",lstRecordFields)
    in
        #"Transform List to Record"

in
    extractTables(Import)