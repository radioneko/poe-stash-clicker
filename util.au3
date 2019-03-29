;Push element into array
Func Array_Push(ByRef $arr, $elt);{{{
	Local $i, $n
	If IsArray($arr) Then
		Local $n = UBound($arr)
		ReDim $arr[$n + 1]
	Else
		Dim $arr[1]
		$n = 0
	EndIf
	$arr[$n] = $elt
EndFunc;}}}



Func TItemRef($row, $col, $item);{{{
	Local $r[3] = [$row, $col, $item]
	Return $r
EndFunc;}}}

Func TItemRef_PushRef(ByRef $arr, $iref)
	Array_Push($arr, $iref)
EndFunc

Func TItemRef_Push(ByRef $arr, $row, $col, $item)
	TItemRef_PushRef($arr, TItemRef($row, $col, $item))
EndFunc

Func TItemRef_col($item)
	Return $item[1]
EndFunc

Func TItemRef_row($item)
	Return $item[0]
EndFunc

Func TItemRef_item($item)
	Return $item[2]
EndFunc
