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
PurchaseOrders = Objects[prelimClean][PurchaseOrders],

Variables = Objects[Variables],
lstColumns_PurchaseOrders = Variables[lstColumns_PurchaseOrders],
lstKeyColumns_dimProducts = Variables[lstKeyColumns_dimProducts],
txtIdColumn_dimProducts = Variables[txtIdColumn_dimProducts],

Functions = Objects[Functions],
filterList = Functions[filterList],
updateDataTypes = Functions[updateDataTypes],

// Tables
dimProducts =
[
    #"Aggregate Products" = 
        let
            lstColumns_Aggregations_PurchaseOrders = filterList(lstColumns_PurchaseOrders,{{"Hyperlink"},{null}}),
            lstColumns_AgregationNames_PurchaseOrders = List.Transform(lstColumns_Aggregations_PurchaseOrders, each "Latest Hyperlink"),
            lstFunctions_Agregations_PurchaseOrders = List.Transform(lstColumns_AgregationNames_PurchaseOrders, 
            (lstItem) => 
                let
                    posListItem = List.PositionOf(lstColumns_AgregationNames_PurchaseOrders,lstItem)
                in
                    each List.Last(List.RemoveNulls(Record.Field(_,lstColumns_Aggregations_PurchaseOrders{posListItem})))),
            nlstTransformations_Aggregations = List.Zip({lstColumns_AgregationNames_PurchaseOrders, lstFunctions_Agregations_PurchaseOrders})
        in
            Table.Group(PurchaseOrders, lstKeyColumns_dimProducts, nlstTransformations_Aggregations),

    #"Add Product Id" = Table.AddIndexColumn(#"Aggregate Products",txtIdColumn_dimProducts, 1,1, Int64.Type),
    #"Final Output" = #"Add Product Id"
]

in
    [
        dimProducts = dimProducts[Final Output]
    ]