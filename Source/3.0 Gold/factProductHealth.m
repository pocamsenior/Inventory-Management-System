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
factProductHealth = Objects[deepClean_factTables][factProductHealth],

Functions = Objects[Functions],
reorderColumns = Functions[reorderColumns],
fillMissingData = Functions[fillMissingData],

#"Reorder Columns" = reorderColumns(factProductHealth,{1,3,null,2,null,null,null,null,null,null,0}),
#"Fill Missing Data" = fillMissingData(#"Reorder Columns",{{"Product","Hyperlink","Comment"},{"Id"}})

in

#"Fill Missing Data"