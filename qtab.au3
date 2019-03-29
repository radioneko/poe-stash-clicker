; Convenience wrapper to probe item in quad stash tab
Func QtabProbe($row, $col);{{{
	Return ProbeItem(QtabX($col) + 8, QtabY($row) + 8)
EndFunc;}}}

; Convenience wrapper to move items between stash and Qtab
Func Inventory2Qtab($iRow, $iCol, $qRow, $qCol, $h, $w);{{{
	ConsoleWrite("Move " & $iRow & "," & $iCol & " -> " & $qRow & "," & $qCol & "(" & $h & "x" & $w & @LF)
	ItemMove((InventoryX($iCol) + InventoryX($iCol + $w)) / 2, (InventoryY($iRow) + InventoryY($iRow + $h)) / 2, (QtabX($qCol) + QtabX($qCol + $w)) / 2, (QtabY($qRow) + QtabY($qRow + $h)) / 2)
EndFunc;}}}

Func Qtab_new()
	Return MakeArea(24, 24, '?')
EndFunc

; Look at quad tab cell with memoization
Func Qtab_look(ByRef $qtab, $row, $col);{{{
	Local $item = $qtab[$row][$col]
	if not IsArray($item) then
		$item = QtabProbe($row, $col)
		MarkInv($qtab, $row, $col, $item[$II_HEIGHT], $item[$II_WIDTH], $item)
	endif
	return $item
EndFunc;}}}

; Update cached qtab state
Func Qtab_update(ByRef $qtab, $row, $col, $item);{{{
	MarkInv($qtab, $row, $col, $item[$II_HEIGHT], $item[$II_WIDTH], $item)
EndFunc;}}}
