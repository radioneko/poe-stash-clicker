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


Func FindFractured(ByRef $arr)
	for $i = 0 to UBound($arr) - 1
		if StringRight($arr[$i], 11) == "(fractured)" then
			return $i
		endif
	next
	return -1
EndFunc

Func max($a, $b);{{{
	if $a > $b then
		return $a
	else
		return $b
	endif
EndFunc;}}}
Func min($a, $b);{{{
	if $a < $b then
		return $a
	else
		return $b
	endif
EndFunc;}}}
Func MakeArea($rows, $cols, $value);{{{
	Local $a[$rows][$cols]
	for $i = 0 to $rows - 1
		for $j = 0 to $cols - 1
			$a[$i][$j] = $value
		next
	next
	return $a
EndFunc;}}}

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; Grids ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
Enum $GRID_min = 0, $GRID_max = 1, $GRID_n = 2
Func Point($x, $y)
	local $r[2] = [$x, $y]
	return $r
EndFunc

; utility grid functions {{{
Func grid_divisor($dim)
	return max(0, $dim - 1)
EndFunc

Func grid_coord($min, $max, $n, $i)
	return $min + ($max - $min) * $i / $n
EndFunc
;}}}

Enum $GRID_tl = 0, $GRID_br, $GRID_w, $GRID_h
Func MakeGrid($tl, $br, $rows, $cols);{{{
	local $r[4] = [$tl, $br, grid_divisor($cols), grid_divisor($rows)]
	return $r
EndFunc;}}}
Func GridX($g, $col);{{{
	local $a = $g[$GRID_tl], $b = $g[$GRID_br]
	return grid_coord($a[0], $b[0], $g[$GRID_w], $col)
EndFunc;}}}
Func GridY($g, $row);{{{
	local $a = $g[$GRID_tl], $b = $g[$GRID_br]
	return grid_coord($a[1], $b[1], $g[$GRID_h], $row)
EndFunc;}}}
Func GridPoint($g, $row, $col);{{{
	return Point(GridX($g, $col), GridY($g, $row))
EndFunc;}}}

Func ToGrid($i, $g)
	Return $g[$GRID_Min] + ($g[$GRID_max] - $g[$GRID_min]) * $i / $g[$GRID_n]
EndFunc

; Scan grid by looking at individual cells
Func GridScan($g, ByRef $area)
EndFunc

Global _
	$grid_qstash = MakeGrid(Point(32, 195), Point(708, 867), 24, 24), _
	$grid_stash = MakeGrid(Point(46, 210), Point(692, 852), 12, 12), _
	$grid_inventory = MakeGrid(Point(908, 683), Point(1553, 917), 5, 12)
