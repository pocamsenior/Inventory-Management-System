/* 
===================================================
Gold Layer - factProductHealth
===================================================
# Script Definition
This script creates factProductHealth table that is production ready
===================================================
*/

let

// Global Definitions
Objects = #shared[Objects],
factTables = Objects[factTables],
factProductHealth = factTables[factProductHealth],

Functions = Objects[Functions],
filterList = Functions[filterList],
reorderColumns = Functions[reorderColumns],
fillMissingData = Functions[fillMissingData],

#"Reorder Columns" = reorderColumns(factProductHealth,{1,3,null,2}),
#"Fill Missing Data" = fillMissingData(#"Reorder Columns",{{"Product","Hyperlink","Comment"},{"Id"}})

in

#"Fill Missing Data"