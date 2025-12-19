/* 
===================================================
Gold Layer - dimProducts
===================================================
# Script Definition
This script creates dimProducts table that is production ready
===================================================
*/

let

// Global Definitions
Objects = #shared[Objects],
dimProducts = Objects[deepClean_dimTables][dimProducts],

Functions = Objects[Functions],
reorderColumns = Functions[reorderColumns],
fillMissingData = Functions[fillMissingData],

#"Reorder Columns" = reorderColumns(dimProducts,{1,2,3,4,5,6,0}),
#"Fill Missing Data" = fillMissingData(#"Reorder Columns",{{"Product","Hyperlink"},{"Id"}})

in

#"Fill Missing Data"