/* 
===================================================
Gold Layer - factOrders
===================================================
# Script Definition
This script creates factOrders table that is production ready
===================================================
*/

let

// Global Definitions
Objects = #shared[Objects],
factTables = Objects[factTables],
factOrders = factTables[factOrders],

Functions = Objects[Functions],
filterList = Functions[filterList],
reorderColumns = Functions[reorderColumns],
fillMissingData = Functions[fillMissingData],

#"Reorder Columns" = reorderColumns(factOrders,{1,2,3,4,0}),
#"Fill Mising Data" = fillMissingData(#"Reorder Columns",{{"Supplier"},{null}})

in

#"Fill Mising Data"