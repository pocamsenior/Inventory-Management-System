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
        Table.TransformColumnTypes(tbl, nlstTransformations_DataTypes)
]
in
Functions