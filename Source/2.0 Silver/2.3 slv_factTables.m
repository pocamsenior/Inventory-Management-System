/* 
===================================================
Silver Layer - factTables
===================================================
# Script Definition
This script creates all of the fact tables 
===================================================
*/

let

// Global Definitions
Objects = #shared[Objects],
slv_Clean = Objects[slv_Clean],
slv_PurchaseOrders = slv_Clean[PurchaseOrders],
slv_dimTables = Objects[slv_dimTables],
slv_dimProducts = slv_dimTables[dimProducts],

Lists = [Objects][Lists],

Variables = Objects[Variables],
lstKeyColumns_dimProducts = Variables[lstKeyColumns_dimProducts],
txtIdColumn_dimProducts = Variables[txtIdColumn_dimProducts],
txtIdColumn_factOrders = Variables[txtIdColumn_factOrders],

Functions = Objects[Functions],
filterList = Functions[filterList],

// Local Definitions
lstColumns_factOrders = filterList(Table.ColumnNames(slv_factOrders[Add Order Id]), {{"Order","Id","Quantity"},{null}}),

// Tables
slv_factOrders =
[
    #"Join dimProducts" = Table.Join(slv_PurchaseOrders, lstKeyColumns_dimProducts, slv_dimProducts, lstKeyColumns_dimProducts, JoinKind.Inner),
    #"Sort by Partition Year, Order Date, Product Id" = Table.Sort(#"Join dimProducts",{{"Partition Year",Order.Ascending},{"Order Date",Order.Ascending},{"Product Id", Order.Ascending}}),
    #"Add Order Id" = Table.AddIndexColumn(#"Sort by Partition Year, Order Date, Product Id",txtIdColumn_factOrders, 1,1, Int64.Type),
    #"Filter Columns" = Table.SelectColumns(#"Add Order Id",lstColumns_factOrders),
    #"Final Output" = #"Filter Columns"
]

in
    [
        factOrders = slv_factOrders[Final Output]
    ]