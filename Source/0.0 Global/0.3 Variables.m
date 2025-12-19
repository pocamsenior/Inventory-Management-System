/* 
=========================================================================================
Global - Variables
=========================================================================================
# Script Definition
This script contains variables that can be used throughout the source folder.
=========================================================================================
*/

let
// Global Definitions
Objects = #shared[Objects],
PurchaseOrders = Objects[prelimClean][PurchaseOrders],
dimTables = Objects[dimTables],
dimProducts = dimTables[dimProducts],
factTables = Objects[slv_factTables],

slv_factOrders = factTables[factOrders],

Functions = Objects[Functions],
filterList = Functions[filterList],

Variables =
[
    lstColumns_PurchaseOrders = Table.ColumnNames(PurchaseOrders),

    lstKeyColumns_dimProducts = filterList(lstColumns_PurchaseOrders,{{"Product"},{"Price","Quantity","Hyperlink"}}),
    txtIdColumn_dimProducts = "Product Id",

    txtIdColumn_factOrders = "Order Id"
]
in
    Variables