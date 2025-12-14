/* 
===================================================
Gold Layer - factPurchaseRequests
===================================================
# Script Definition
This script creates factPurchaseRequests table that is production ready
===================================================
*/

let

// Global Definitions
Objects = #shared[Objects],
factTables = Objects[factTables],
factPurchaseRequests = factTables[factPurchaseRequests],

Functions = Objects[Functions],
filterList = Functions[filterList],
reorderColumns = Functions[reorderColumns],
fillMissingData = Functions[fillMissingData],

#"Reorder Columns" = reorderColumns(factPurchaseRequests,{}),
#"Fill Missing Data" =  Table.ReplaceValue(#"Reorder Columns",null,"Not Provided",Replacer.ReplaceValue,filterList(Table.ColumnNames(#"Reorder Columns"),{{null},{"Price","Date","Quantity"}}))

in

#"Fill Missing Data"
