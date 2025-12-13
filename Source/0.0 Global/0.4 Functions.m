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

    posInList = (lst as list, item as text) =>
    let
        #"List of Booleans" = List.Transform(lst, each Text.Contains(_,item,Comparer.OrdinalIgnoreCase))
        
    in
        List.PositionOf(#"List of Booleans",true),

    reorderColumns = (tbl as table, order as list) =>
    let
        lstColumns = Table.ColumnNames(tbl),
        lstColumnPosition_Initial = List.Numbers(0,List.Count(lstColumns),1),
        lstColumns_Table = List.Transform(lstColumns, each 
            let 
                position = posInList(lstColumns,_),
                initialPosition = Text.From(position),
                finalPosition = Text.From(try if order{position} = null then List.Count(lstColumns) else order{position} otherwise List.Count(lstColumns))
            in
                Text.Combine ({_,initialPosition,finalPosition},",")),

        lstHelperColumns_Tables = {"Column Name","Initial Position","Final Position"},
        lstHelperColumns_DataTypes = {Text.Type, Int64.Type, Number.Type},
        nlstTransformations_HelperColumns = List.Zip({lstHelperColumns_Tables,lstHelperColumns_DataTypes}),

        tblColumns = Table.FromList(lstColumns_Table,null,lstHelperColumns_Tables),
        tblColumns_UpdatedDataTypes = Table.TransformColumnTypes(tblColumns,nlstTransformations_HelperColumns),

        #"Sort Table" = Table.Sort(tblColumns_UpdatedDataTypes,{{lstHelperColumns_Tables{2},Order.Ascending},{lstHelperColumns_Tables{1},Order.Ascending}})
    in
        Table.ReorderColumns(tbl,#"Sort Table"[Column Name])
]
in
Functions