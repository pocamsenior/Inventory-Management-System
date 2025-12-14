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
slv_InventoryChecks = slv_Clean[InventoryChecks],
slv_PurchaseRequests = slv_Clean[PurchaseRequests],
slv_dimTables = Objects[slv_dimTables],
slv_dimProducts = slv_dimTables[dimProducts],

Lists = [Objects][Lists],

Variables = Objects[Variables],
lstKeyColumns_dimProducts = Variables[lstKeyColumns_dimProducts],
txtIdColumn_factOrders = Variables[txtIdColumn_factOrders],

Functions = Objects[Functions],
filterList = Functions[filterList],
updateDataTypes = Functions[updateDataTypes],

// Local Definitions
lstColumns_factOrders = filterList(Table.ColumnNames(slv_factOrders[Add Order Id]), {{"Order","Id","Quantity"},{null}}),
lstColumns_factProductHealth = filterList(filterList(Table.ColumnNames(slv_factProductHealth[Fill Missing Data]), {{"Date","Product","Health","Consumed","Comment","Type","Total","Discarded"},{"Hyperlink","Price","Id"}}),{{null},{"Product Quantity"}}),
txtColumn_EntryType = "Entry Type",

sortYearDateProductId = (tbl) => Table.Sort(tbl,{{"Partition Year",Order.Ascending},{"Date",Order.Ascending},{"Product Id", Order.Ascending}}),

// Tables
slv_factOrders =
[
    #"Join dimProducts" = Table.Join(slv_PurchaseOrders, lstKeyColumns_dimProducts, slv_dimProducts, lstKeyColumns_dimProducts, JoinKind.Inner),
    #"Sort by Partition Year, Order Date, Product Id" = sortYearDateProductId(#"Join dimProducts"),
    #"Add Order Id" = Table.AddIndexColumn(#"Sort by Partition Year, Order Date, Product Id",txtIdColumn_factOrders, 1,1, Int64.Type),
    #"Filter Columns" = Table.SelectColumns(#"Add Order Id",lstColumns_factOrders),
    #"Update Data Types" = updateDataTypes(#"Filter Columns"),
    #"Final Output" = #"Update Data Types"
],

slv_factProductHealth =
[
    #"Create New Purchase Order Entry Table" =
        let
            lstColumns_Quantity = filterList(lstColumns_factOrders,{{"Quantity"},{null}}),
            lstColumns_Health = filterList(Table.ColumnNames(#"Add Excellent Health Quantity"),{{"Health Quantity"},{null}}),
        
            // rename `order date` column
            nlstTransformations_NewPurchaseOrderEntry =
                let
                    lstColumns = filterList(lstColumns_factOrders,{{"Date"},{null}}),
                    lstFunctions = List.Transform(lstColumns, each "Date")
                in
                    List.Zip({lstColumns, lstFunctions}),

            #"Base Table" = slv_factOrders[Join dimProducts],
            #"Add Excellent Health Quantity" = Table.AddColumn(#"Base Table","Excellent Health Quantity", each List.Product(List.Transform(lstColumns_Quantity, (value) => Record.Field(_, value)))),
            #"Add Type Column" = Table.AddColumn(#"Add Excellent Health Quantity", txtColumn_EntryType, each "Purchase Order")
        in
            #"Add Type Column",

    #"Create New Inventory Check Entry Table" = Table.AddColumn(slv_InventoryChecks, txtColumn_EntryType, each "Inventory Check"),
    #"Combine" = Table.Combine({#"Create New Purchase Order Entry Table", #"Create New Inventory Check Entry Table"}),
    #"Fill Missing Data" = 
        let
            lstColumns = Table.ColumnNames(#"Combine"),
            lstColumns_Health = filterList(lstColumns,{{"Health"},{null}}),
            lstColumns_Quantity = filterList(lstColumns,{{"Quantity"},{null}}),

            #"Excellent Health Quantity For Purchase Orders" = Table.ReplaceValue(#"Combine", null, each if _[Entry Type] = "Purchase Order" then _[Total Entry Quantity] else null, Replacer.ReplaceValue, {lstColumns_Health{0}}),

            #"Other Quantities for Purchase Orders" = Table.ReplaceValue(#"Excellent Health Quantity For Purchase Orders", null, each if _[Entry Type] = "Purchase Order" then 0 else null, Replacer.ReplaceValue, lstColumns_Quantity),

            #"Consumed for Purchase Orders" = Table.ReplaceValue(#"Other Quantities for Purchase Orders", null, each if _[Entry Type] = "Purchase Order" then false else null, Replacer.ReplaceValue, {"Consumed"})
        in
            #"Consumed for Purchase Orders",
    
    #"Update Data Types" = updateDataTypes(#"Fill Missing Data"),

    #"Sort by Partition Year, Order Date, Product Id" = sortYearDateProductId(#"Update Data Types"),

    #"Filter Columns" = Table.SelectColumns(#"Sort by Partition Year, Order Date, Product Id",lstColumns_factProductHealth),

    #"Final Output" = #"Filter Columns"
],

slv_factPurchaseRequests =
[
    #"Final Output" = slv_PurchaseRequests
]


in
    [
        factOrders = slv_factOrders[Final Output],
        factProductHealth = slv_factProductHealth[Final Output],
        factPurchaseRequests = slv_factPurchaseRequests[Final Output]
    ]