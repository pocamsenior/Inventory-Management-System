/* 
===================================================
Silver Layer - dimTables
===================================================
# Script Definition
This script creates all of the dimension tables 
===================================================
*/

let

// Global Definitions
Objects = #shared[Objects],
slv_Clean = Objects[slv_Clean],
slv_PurchaseOrders = slv_Clean[PurchaseOrders],

Lists = [Objects][Lists],

Variables = Objects[Variables],
lstColumns_PurchaseOrders = Variables[lstColumns_PurchaseOrders],
lstKeyColumns_dimProducts = Variables[lstKeyColumns_dimProducts],
txtIdColumn_dimProducts = Variables[txtIdColumn_dimProducts],

Functions = Objects[Functions],
filterList = Functions[filterList],

// Local Definitions
// Aggregations
lstColumns_Aggregated_PurchaseOrders = filterList(lstColumns_PurchaseOrders,{{"Hyperlink"},{null}}),
lstRenameColumns_Agregated_PurchaseOrders = List.Transform(lstColumns_Aggregated_PurchaseOrders, each "Latest Hyperlink"),
lstFunctions_AggregatedHyperlink = List.Transform(lstRenameColumns_Agregated_PurchaseOrders, 
    (lstItem) => 
    let
        posListItem = List.PositionOf(lstRenameColumns_Agregated_PurchaseOrders,lstItem)
    in
        each List.Last(List.RemoveNulls(Record.Field(_,lstColumns_Aggregated_PurchaseOrders{posListItem})))),
nlstTransformations_Aggregations = List.Zip({lstRenameColumns_Agregated_PurchaseOrders, lstFunctions_AggregatedHyperlink}),

dimProducts =
[
    #"Aggregate Products" = Table.Group(slv_PurchaseOrders, lstKeyColumns_dimProducts, nlstTransformations_Aggregations),
    #"Add Product Id" = Table.AddIndexColumn(#"Aggregate Products",txtIdColumn_dimProducts, 1,1, Int64.Type),
    #"Final Output" = #"Add Product Id"
]

in
[
    dimProducts = dimProducts[Final Output]
]