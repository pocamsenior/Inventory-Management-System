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
slv_Clean = Objects[slv_Clean],
slv_PurchaseOrders = slv_Clean[PurchaseOrders],

Lists = [Objects][Lists],

Functions = Objects[Functions],
filterList = Functions[filterList],


Variables =
[
    lstColumns_PurchaseOrders = Table.ColumnNames(slv_PurchaseOrders),

    lstKeyColumns_dimProducts = filterList(lstColumns_PurchaseOrders,{{"Product"},{"Price","Quantity","Hyperlink"}}),
    txtIdColumn_dimProducts = "Product Id"

]
in
Variables