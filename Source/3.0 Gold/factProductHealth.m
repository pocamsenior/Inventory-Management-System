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

#"Reorder Columns" = reorderColumns(factProductHealth,{0,1.1,1.2,1.3,1.4,1.5,2.1,0.1,2.2,2.3,2.4,3.1,3.2,3.3}),
#"Fill Missing Data" = fillMissingData(#"Reorder Columns",{{"Product","Hyperlink","Comment"},{null}})

in

#"Fill Missing Data"