/* 
=========================================================================================
Global - Functions
=========================================================================================
# Script Definition
This script contains functions that can be used throughout the source folder.
=========================================================================================
*/

let
Functions =
[
    createList_DataTypes = (columns as list) =>
        List.Transform(columns, each
        if List.AnyTrue(List.Transform({"Id","Quantity"}, (value) => Text.Contains(_, value))) then Int64.Type
        else if List.AnyTrue(List.Transform({"Price"}, (value) => Text.Contains(_, value))) then Decimal.Type
        else if List.AnyTrue(List.Transform({"Date"}, (value) => Text.Contains(_, value))) then Date.Type
        else if List.AnyTrue(List.Transform({"Consumed"}, (value) => Text.Contains(_, value))) then Logical.Type
        else Text.Type
    ),

    updateDataTypes = (tbl as table) => 
        let
            lstColumns = Table.ColumnNames(tbl),
            lstDataTypes = createList_DataTypes(lstColumns),
            nlstTransformations_DataTypes = List.Zip({lstColumns, lstDataTypes})
        in
            Table.TransformColumnTypes(tbl, nlstTransformations_DataTypes),

    filterList = (lst as list, nlst_Contains_Remove as list) =>
        let
            lstContains = nlst_Contains_Remove{0},
            lstRemove = nlst_Contains_Remove{1}
        in
            // only list contains parameter is entered
            if List.Contains(lstRemove, null) and not(List.Contains(lstContains, null)) then 
                (
                    List.RemoveNulls(List.Transform(lst, each if List.AnyTrue(List.Transform(lstContains, (value) => Text.Contains(_, value, Comparer.OrdinalIgnoreCase))) then _ else null)) 
                )

            // only list remove parameter is entered
            else if List.Contains(lstContains, null) and not(List.Contains(lstRemove, null)) then 
                (
                    let
                        lstFilteredRemove = List.RemoveNulls(List.Transform(lst, each if List.AnyTrue(List.Transform(lstRemove, (value) => Text.Contains(_, value, Comparer.OrdinalIgnoreCase))) then _ else null))
                    in
                        List.RemoveItems(lst, lstFilteredRemove)
                )
        
            // both parameters are entered
            else 
                let
                    lstFilteredContains = List.RemoveNulls(List.Transform(lst, each if List.AnyTrue(List.Transform(lstContains, (value) => Text.Contains(_, value, Comparer.OrdinalIgnoreCase))) then _ else null)),
                    lstFilteredRemove = List.RemoveNulls(List.Transform(lst, each if List.AnyTrue(List.Transform(lstRemove, (value) => Text.Contains(_, value, Comparer.OrdinalIgnoreCase))) then _ else null))
                in
                    List.RemoveItems(lstFilteredContains, lstFilteredRemove),

    posText_List = (lst as list, item as text) =>
        let
            #"List of Booleans" = List.Transform(lst, each Text.Contains(_,item,Comparer.OrdinalIgnoreCase))
            
        in
            List.PositionOf(#"List of Booleans",true),

    reorderColumns = (tbl as table, order as list) =>
        let
            lstColumns = Table.ColumnNames(tbl),
            lstColumns_TableFromList = List.Transform(lstColumns, each 
                let 
                    position = posText_List(lstColumns,_),
                    position_Initial = Text.From(position),
                    position_Final = Text.From(try if order{position} = null then List.Count(lstColumns) else order{position} otherwise List.Count(lstColumns))
                in
                    Text.Combine ({_,position_Initial,position_Final},",")),

            lstHelperColumns = {"Column Name","Initial Position","Final Position"},
            lstHelperColumns_DataTypes = {Text.Type, Int64.Type, Number.Type},
            nlstTransformations_HelperColumns = List.Zip({lstHelperColumns,lstHelperColumns_DataTypes}),

            tblColumnOrder = Table.FromList(lstColumns_TableFromList,null,lstHelperColumns),
            tblColumnOrder_DataTypes = Table.TransformColumnTypes(tblColumnOrder,nlstTransformations_HelperColumns),

            #"Sort Table" = Table.Sort(tblColumnOrder_DataTypes,{{lstHelperColumns{2},Order.Ascending},{lstHelperColumns{1},Order.Ascending}})
        in
            Table.ReorderColumns(tbl,#"Sort Table"[Column Name]),

    fillMissingData = (tbl as table, nlstFilter as list) =>
        let
            lstColumns_Null = filterList(Table.ColumnNames(tbl), nlstFilter),
            lstFunctions_Null = List.Transform(
                List.Transform(lstColumns_Null, each
                    if List.AnyTrue(List.Transform({"Variant","Model","Size"}, (value) => Text.Contains(_, value))) then "Not Applicable"
                    else if List.AnyTrue(List.Transform({"Brand"}, (value) => Text.Contains(_, value))) then "Not Available" 
                    else if List.AnyTrue(List.Transform({"Hyperlink","Supplier","Comment"}, (value) => Text.Contains(_, value))) then "Not Provided" 
                    else null), 
                each (value) => value ?? _),
            nlstTransformations = List.Zip({lstColumns_Null,lstFunctions_Null})
        in
            updateDataTypes(Table.TransformColumns(tbl, nlstTransformations))
]
in
    Functions