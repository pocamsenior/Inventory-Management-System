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
PurchaseOrders = Objects[prelimClean][PurchaseOrders],
InventoryChecks = Objects[prelimClean][InventoryChecks],
PurchaseRequests = Objects[prelimClean][PurchaseRequests],
dimTables = Objects[dimTables],
dimProducts = dimTables[dimProducts],

Lists = [Objects][Lists],

Variables = Objects[Variables],
lstKeyColumns_dimProducts = Variables[lstKeyColumns_dimProducts],
txtIdColumn_factOrders = Variables[txtIdColumn_factOrders],

Functions = Objects[Functions],
filterList = Functions[filterList],
updateDataTypes = Functions[updateDataTypes],

// Local Definitions
lstColumns_factOrders = filterList(Table.ColumnNames(factOrders[Add Order Id]), {{"Order","Id","Quantity"},{null}}),
lstColumns_factProductHealth = filterList(filterList(Table.ColumnNames(factProductHealth[Fill Missing Data]), {{"Date","Product","Health","Consumed","Comment","Type","Total","Discarded"},{"Hyperlink","Price","Id"}}),{{null},{"Product Quantity"}}),
txtColumn_EntryType = "Entry Type",

sortYearDateProductId = (tbl) => 
    let
        lstColumns = Table.ColumnNames(tbl),
        countTrue = List.Count(List.RemoveItems(List.Transform(lstColumns, each List.AnyTrue(List.Transform({"Partition","Product Id","Date"}, (value) => Text.Contains(_, value)))),{false}))
    in
        if countTrue > 2 then
        Table.Sort(tbl,{{"Partition Year",Order.Ascending},{"Date",Order.Ascending},{"Product Id", Order.Ascending}})
        else
        Table.Sort(tbl,{{"Partition Year",Order.Ascending},{"Date",Order.Ascending}}),

// Tables
factOrders =
[
    #"Join dimProducts" = Table.Join(PurchaseOrders, lstKeyColumns_dimProducts, dimProducts, lstKeyColumns_dimProducts, JoinKind.Inner),
    #"Sort by Partition Year, Date, Product Id" = sortYearDateProductId(#"Join dimProducts"),
    #"Add Order Id" = Table.AddIndexColumn(#"Sort by Partition Year, Date, Product Id",txtIdColumn_factOrders, 1,1, Int64.Type),
    #"Filter Columns" = Table.SelectColumns(#"Add Order Id",lstColumns_factOrders),
    #"Update Data Types" = updateDataTypes(#"Filter Columns"),
    #"Final Output" = #"Sort by Partition Year, Date, Product Id"
],

// =====================================================================================

factProductHealth =
[
    #"Create New Purchase Order Entry Table" =
        let
            lstColumns_Quantity = filterList(lstColumns_factOrders,{{"Quantity"},{null}}),
            lstColumns_Health = filterList(Table.ColumnNames(#"Add Excellent Health Quantity"),{{"Health Quantity"},{null}}),

            #"Base Table" = factOrders[Join dimProducts],
            #"Add Excellent Health Quantity" = Table.AddColumn(#"Base Table","Excellent Health Quantity", each List.Product(List.Transform(lstColumns_Quantity, (value) => Record.Field(_, value)))),
            #"Add Type Column" = Table.AddColumn(#"Add Excellent Health Quantity", txtColumn_EntryType, each "Purchase Order")
        in
            #"Add Type Column",

    #"Create New Inventory Check Entry Table" = Table.AddColumn(InventoryChecks, txtColumn_EntryType, each "Inventory Check"),

    #"Combine Purchase Orders and Inventory Checks" = Table.Combine({#"Create New Purchase Order Entry Table", #"Create New Inventory Check Entry Table"}),

    #"Fill Missing Data" = 
        let
            lstColumns = Table.ColumnNames(#"Combine Purchase Orders and Inventory Checks"),
            lstColumns_Health = filterList(lstColumns,{{"Health"},{null}}),
            lstColumns_Quantity = filterList(lstColumns,{{"Quantity"},{null}}),

            #"Excellent Health Quantity For Purchase Orders" = Table.ReplaceValue(#"Combine Purchase Orders and Inventory Checks", null, each if _[Entry Type] = "Purchase Order" then _[Total Entry Quantity] else null, Replacer.ReplaceValue, {lstColumns_Health{0}}),

            #"Other Quantities for Purchase Orders" = Table.ReplaceValue(#"Excellent Health Quantity For Purchase Orders", null, each if _[Entry Type] = "Purchase Order" then 0 else null, Replacer.ReplaceValue, lstColumns_Quantity),

            #"Consumed for Purchase Orders" = Table.ReplaceValue(#"Other Quantities for Purchase Orders", null, each if _[Entry Type] = "Purchase Order" then false else null, Replacer.ReplaceValue, {"Consumed"})
        in
            #"Consumed for Purchase Orders",
    
    #"Update Data Types" = updateDataTypes(#"Fill Missing Data"),

    #"Sort by Partition Year, Date, Product Id" = sortYearDateProductId(#"Update Data Types"),

    #"Filter Columns" = Table.SelectColumns(#"Sort by Partition Year, Date, Product Id",lstColumns_factProductHealth),

    #"Final Output" = #"Filter Columns"
],

// =====================================================================================

factPurchaseRequests =
[
    #"Update Data Types" = updateDataTypes(PurchaseRequests),
    #"Sort by Partition Year, Date" = sortYearDateProductId(#"Update Data Types"),
    #"Filter Column" = Table.SelectColumns(#"Sort by Partition Year, Date", filterList(Table.ColumnNames(#"Sort by Partition Year, Date"),{{null},{"Partition"}})),
    #"Final Output" = #"Filter Column"
]

in
    [
        factOrders = factOrders[Final Output],
        factProductHealth = factProductHealth[Final Output],
        factPurchaseRequests = factPurchaseRequests[Final Output]
    ]