#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include "util.au3"
#include <GUIConstantsEx.au3>

$wcl = "[TITLE:Path of Exile; CLASS:POEWindowClass]"
$gui_title = "P4th 0f Tr4d1ng"
$gui_class = "[TITLE:" & $gui_title & "; CLASS:AutoIt v3 GUI]"
WinClose($gui_class)
WinActivate($wcl)
WinWaitActive($wcl)

;Sleep(2000)


Global $inventory_top_x = 880, $inventory_top_y = 653, $cell_size = 58
Global _
	$tablist_button_x = 710, _
	$tablist_button_y = 162, _
	$tablist_menu_x = 770, _
	$tablist_item_height = 24

Global _
	$stash_top_x = 19, _
	$stash_top_y = 180, _
	$stash_bottom_x = 724, _
	$stash_bottom_y = 884, _
	$stash_qcell = 29, _
	$stash_cell = $stash_qcell * 2

Enum $TAB_CURRENCY = 0, _
	$TAB_MAPS = 1, _
	$TAB_DIVINATION = 2, _
	$TAB_CHAOS = 3, _
	$TAB_ESSENCE = 5, _
	$TAB_FRAGMENTS = 16, _
	$TAB_RESONATORS = 23 - 2, _
	$TAB_FOSSILS = 12, _
	$TAB_GEMS = 11

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     "STRUCTURES"     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

Func SplitNL($text) ;{{{
	Return StringSplit(StringReplace($text, Chr(13), ""), Chr(10))
EndFunc ;}}}

Func InventoryX($col) ;{{{
	Return $inventory_top_x + $cell_size * $col
EndFunc ;}}}

Func InventoryY($row) ;{{{
	Return $inventory_top_y + $cell_size * $row
EndFunc ;}}}

; Calculate position in quad tab
Func QtabX($col) ;{{{
	return $col / 24 * ($stash_bottom_x - $stash_top_x) + $stash_top_x
EndFunc ;}}}

Func QtabY($row) ;{{{
	return $row / 24 * ($stash_bottom_y - $stash_top_y) + $stash_top_y
EndFunc ;}}}

#include "items.au3"
#include "qtab.au3"

; Move item from one location to another
Func ItemMove($srcX, $srcY, $dstX, $dstY);{{{
	;MouseClick("left", $srcX, $srcY)
	MouseMove($srcX, $srcY, 0)
	Sleep(50)
	MouseClick("left")
	Sleep(50)
	;MouseClick("left", $dstX, $dstY)
	MouseMove($dstX, $dstY, 0)
	Sleep(50)
	MouseClick("left")
	Sleep(50)
EndFunc;}}}

Func CtrlClick($x, $y) ;{{{
	Send("{CTRLDOWN}")
	Sleep(10)
	MouseMove($x, $y, 0)
	Sleep(20)
	MouseClick("left")
	Sleep(10)
	Send("{CTRLUP}")
	Sleep(10)
EndFunc ;}}}

Func InventoryCtrlClick($row, $col);{{{
	CtrlClick(InventoryX($col) + 8, InventoryY($row) + 8)
EndFunc;}}}

Func OpenTab($no) ;{{{
	MouseMove($tablist_button_x, $tablist_button_y, 0)
	Sleep(50)
	MouseClick("left")
	Sleep(50)
	MouseMove($tablist_menu_x, $tablist_button_y + $no * $tablist_item_height, 0)
	Sleep(50)
	MouseClick("left")
	Sleep(300)
EndFunc ;}}};}}}

Func Tuple3($a1, $a2, $a3) ;{{{
	Local $r[3] = [$a1, $a2, $a3]
	Return $r
EndFunc ;}}}


; Looks up for string in specified array
Func Lookup($needle, ByRef $haystack) ;{{{
	Local $i
	For $i = 0 to UBound($haystack) - 1
		If $needle == $haystack[$i] Then
			Return True
		EndIf
	Next
	Return False
EndFunc ;}}}


Func ClassifyCurrency(ByRef $info, $base, $words);{{{
	ConsoleWrite(">>> " & $base & StringRegExp($base, ".*Essence of.*") & @LF)
	If UBound($words) > 1 and (StringRegExp($base, "Essence of") == 1 or $base == "Remnant of Corruption") Then
		Return Tuple3($I_ESSENCE, 1, 1)
	EndIf
	Return Tuple3($I_CURRENCY, 1, 1)
EndFunc;}}}

; Mark rectangular area in inventory map
Func MarkInv(ByRef $map, $row, $col, $h, $w, $value) ;{{{
	Local $i, $j
	For $i = $row to $row + $h - 1
		For $j = $col to $col + $w - 1
			$map[$i][$j] = $value
		Next
	Next
EndFunc ;}}}

Func MakeArea($rows, $cols, $value);{{{
	Local $a[$rows][$cols]
	for $i = 0 to $rows - 1
		for $j = 0 to $cols - 1
			$a[$i][$j] = $value
		next
	next
	return $a
EndFunc;}}}


; Get raw item description by moving mouse pointer and issuing "Ctrl-C".
; Returns II_ (aka TItemInfo)
Func ProbeItem($x, $y) ;{{{
	ClipPut("")
	MouseMove($x, $y, 1)
	Sleep(20)
	Send("^c")
	Sleep(20)
	$text = ClipGet()
	;ConsoleWrite("'" & $text & "'" & @LF)	
	If $text == "" Then
		Return TItemInfo($I_NONE, 1, 1, 0, 0, False, 0)
	EndIf
	; Now parse description
	$info = ParseItemInfo($text)
	If $info[$ITEM_is_valid] == False Then
		Return TItemInfo($I_NONE, 1, 1, 0, 0, False, 0)
	EndIf
	; Interpret base class to know dimension and other shit
	Local $item = DescribeBaseItem($info)
	;ConsoleWrite("'" & $info[$ITEM_base] & "' => " & $item[$ICLASS_class] & ", sockets = " & $info[$ITEM_sockets] & "rarity = " & $info[$ITEM_rarity] & @LF)
	Return TItemInfo($item[$ICLASS_class], $item[$ICLASS_height], $item[$ICLASS_width], _
		$info[$ITEM_sockets], 60, $info[$ITEM_is_undefined] and $info[$ITEM_rarity] == "Rare", _
		$info[$ITEM_quality], $info[$ITEM_base])
EndFunc ;}}}


; Convenience wrapper to probe item in inventory
Func InventoryProbe($row, $col);{{{
	Return ProbeItem(InventoryX($col) + 8, InventoryY($row) + 8)
EndFunc;}}}

Func PartOfChaosSet(ByRef $item) ;{{{
	ConsoleWrite("item: " & $item[1] & "; " & $item[2] & "; " & $item[3] & @LF)
	Return $item[1] == "Rare" and $item[3] <> 6 and $item[2] == True
EndFunc ;}}}

Global $invMap[5][12]
For $i = 0 to 4
	For $j = 0 to 11
		$invMap[$i][$j] = '-'
	Next
Next


Func Pair($a, $b);{{{
	Local $r[2] = [$a, $b]
	Return $r
EndFunc;}}}

Func Offset1($row, $col);{{{
	Local $r[1] = [Pair($row, $col)]
	Return $r
EndFunc;}}}

Func Offset2($row1, $col1, $row2, $col2);{{{
	Local $r[2] = [Pair($row1, $col1), Pair($row2, $col2)]
	return $r
EndFunc;}}}

; Generate all possible global points for item based on relative offset inside chaos set
Func MakeOffsets($rel);{{{
	Local $result
	For $set = 0 To 15
		Local $i
		Local $base_row = Floor($set / 4) * 5
		Local $base_col = Mod($set, 4) * 6
		For $i = 0 To UBound($rel) - 1
			Local $pos = $rel[$i]
			Local $val[2] = [$pos[0] + $base_row, $pos[1] + $base_col]
			Array_Push($result, $val)
		Next
	Next
	Return $result
EndFunc;}}}

; Return array of possible relative offsets (rowOff, colOff for this item inside chaos set)
Func CalcOffset($iclass, $h, $w);{{{
	Local $bizha_max = 20
	If $iclass == $I_HELMET Then
		Return MakeOffsets(Offset1(0, 0))
	ElseIf $iclass == $I_GLOVES Then
		Return MakeOffsets(Offset1(2, 0))
	ElseIf $iclass == $I_BELT Then
		Return MakeOffsets(Offset1(4, 0))
	ElseIf $iclass == $I_BODY Then
		Return MakeOffsets(Offset1(0, 2))
	ElseIf $iclass == $I_BOOTS Then
		Return MakeOffsets(Offset1(3, 2))
	ElseIf $iclass == $I_WEAPON_2H Then
		Return MakeOffsets(Offset1(0, 4))
	ElseIf $iclass == $I_WEAPON_1H and $h == 3 and $w == 1 Then
		Return MakeOffsets(Offset2(0, 4, 0, 5))
	ElseIf $iclass == $I_WEAPON_1H and $h == 2 and $w == 2 Then
		Return MakeOffsets(Offset2(0, 4, 2, 4))
	ElseIf $iclass == $I_AMULET Then
		Local $pos[$bizha_max]
		For $i = 1 To $bizha_max
			$pos[$i - 1] = Pair(21, 24 - $i)
		Next
		Return $pos
	ElseIf $iclass == $I_RING Then
		Local $pos[$bizha_max * 2]
		For $i = 1 To $bizha_max
			$pos[($i - 1) * 2] = Pair(22, 24 - $i)
			$pos[($i - 1) * 2 + 1] = Pair(23, 24 - $i)
		Next
		Return $pos
	EndIf
	Local $r
	Return $r
EndFunc;}}}


; Move chaos set item to unoccupied cell of inventory
Func MoveChaosSetItem(ByRef $qtab, $irow, $icol, $coff, $info); {{{
	Local $mark, $w, $h, $i, $base_col, $base_row
	$h = $info[$II_HEIGHT]
	$w = $info[$II_WIDTH]
	$mark = Item2a($info)
	For $i = 0 To UBound($coff) - 1
		Local $pos = $coff[$i]
		Local $row = $pos[0], $col = $pos[1]
		Local $what = Qtab_look($qtab, $row, $col)
		If $what[$II_CLASS] == $I_NONE Then
			ConsoleWrite("   -> " & $row & "," & $col & @LF)
			Qtab_update($qtab, $row, $col, $info)
			Inventory2Qtab($irow, $icol, $row, $col, $h, $w)
			;MouseMove(InventoryX($icol), InventoryY($irow), 0)
			;MouseMove(QtabX($col), QtabY($row), 10)
			;Sleep(200)
			ExitLoop
		EndIf
	Next
EndFunc;}}}

; Issue large number of ctrl-clicks
Func MassCtrlClick(ByRef $items, $tab, $tab_sleep, $click_sleep);{{{
	If IsArray($items) Then
		ConsoleWrite("Processing " & UBound($items) & " entries..." & @LF)
		OpenTab($tab)
		Sleep($tab_sleep)
		;ConsoleWrite("total " & UBound($items) & " currency items found" & @LF)
		For $i = 0 to UBound($items) - 1
			$row = TItemRef_row($items[$i])
			$col = TItemRef_col($items[$i])
			InventoryCtrlClick($row, $col)
			Sleep($click_sleep)
		Next
	EndIf
EndFunc;}}}

Func PushIfClass(ByRef $items, $iref, $iclass, $min_quality = 0)
	Local $item = $iref[2]
	If $item[$II_CLASS] == $iclass and $item[$II_QUALITY] >= $min_quality Then
		ConsoleWrite("Saving..." & @LF)
		TItemRef_PushRef($items, $iref)
	EndIf
EndFunc

Func ProcessInventory();{{{
	Local $chaosItems, $currencyItems, $mapItems, $divinationItems, $fragmentItems, $fossils, $resonators, $essenses, $gems
	Local $seen = MakeArea(5, 12, False) ; what cells we're aware about
	Local $qtab = Qtab_new()
	Local $i, $item, $row, $col
	
	; Look throught inventory for currency, maps, chaos items etc
	for $row = 0 to 4
		for $col = 0 to 9 ; Keep last two rows for my stuff
			if $seen[$row][$col] then
				ContinueLoop
			endif
			$item = InventoryProbe($row, $col)
			;ConsoleWrite("See " & $item[$II_CLASS] & " at " & $row & "," & $col & @LF)
			if $item[$II_CLASS] == $I_NONE then
				ContinueLoop
			endif
			MarkInv($seen, $row, $col, $item[$II_HEIGHT], $item[$II_WIDTH], True)
			Local $item_class_dbg = $item[$II_CLASS]
			Switch $item[$II_CLASS]
				Case $I_NONE
					$item_class_dbg = "EMPTY"
				Case $I_OTHER
					$item_class_dbg = "???"
			EndSwitch
			ConsoleWrite("Seen '" & $item[$II_BASE] & "' as " & $item_class_dbg & " @ " & $row & "," & $col & ", " & $item[$II_HEIGHT] & "x" & $item[$II_WIDTH]  & _
				" is_chaos = " & $item[$II_CHAOS] & @LF)
			Local $iref = TItemRef($row, $col, $item)
			If $item[$II_CHAOS] Then
				TItemRef_Push($chaosItems, $row, $col, $item)
			EndIf
			PushIfClass($currencyItems, $iref, $I_CURRENCY)
			PushIfClass($divinationItems, $iref, $I_DIVINATION)
			PushIfClass($mapItems, $iref, $I_MAP)
			PushIfClass($fragmentItems, $iref, $I_FRAGMENT)
			PushIfClass($fossils, $iref, $I_FOSSIL)
			PushIfClass($resonators, $iref, $I_RESONATOR)
			PushIfClass($essenses, $iref, $I_ESSENCE)
			PushIfClass($gems, $iref, $I_GEM, 1)
		next
	next

	; Process seeen items
	If IsArray($chaosItems) Then
		OpenTab($TAB_CHAOS)
		Sleep(500)
		ConsoleWrite("total " & UBound($chaosItems) & " chaos items found" & @LF)
		For $i = 0 to UBound($chaosItems) - 1
			$row = TItemRef_row($chaosItems[$i])
			$col = TItemRef_col($chaosItems[$i])
			$item = TItemRef_item($chaosItems[$i])
			Local $off = CalcOffset($item[$II_CLASS], $item[$II_HEIGHT], $item[$II_WIDTH])
			If IsArray($off) Then
				MoveChaosSetItem($qtab, $row, $col, $off, $item)
			EndIf
		Next
	EndIf

	; Currency
	MassCtrlClick($currencyItems, $TAB_CURRENCY, 500, 50)
	MassCtrlClick($divinationItems, $TAB_DIVINATION, 500, 100)
	MassCtrlClick($mapItems, $TAB_MAPS, 500, 800)
	MassCtrlClick($fragmentItems, $TAB_FRAGMENTS, 500, 100)
	MassCtrlClick($fossils, $TAB_FOSSILS, 500, 50)
	MassCtrlClick($resonators, $TAB_RESONATORS, 500, 50)
	MassCtrlClick($essenses, $TAB_ESSENCE, 500, 50)
	MassCtrlClick($gems, $TAB_GEMS, 500, 50)
EndFunc;}}}

;OpenTab(3)
;$txt = ClipGet()
;$item = ParseItemInfo($txt)
;$klass = DescribeBaseItem($item[4])
;ConsoleWrite($item[$ITEM_base] & ": " & $klass[$ICLASS_class] & " -> " & $klass[$ICLASS_height] & "x" & $klass[$ICLASS_width] & @LF)

;$i = QtabProbe(5, 1)

;$row = Floor((MouseGetPos(1) - $inventory_top_y) / $cell_size)
;$col = Floor((MouseGetPos(0) - $inventory_top_x) / $cell_size)
;$col = 4
;$row = 0
;ConsoleWrite("(" & $row & "," & $col & ")" & @LF)
;if $row >= 0 and $row < 5 and $col >= 0 and $col < 12 Then
;	$i = InventoryProbe($row, $col)
;	$o = CalcOffset($i[$II_CLASS], $i[$II_HEIGHT], $i[$II_WIDTH])
;	if IsArray($o) Then
;		MouseMove(QtabX($o[0][1]), QtabY($o[0][0]), 5)
;	EndIf
;	ConsoleWrite($i[$II_CLASS] & " => " & $i[$II_CHAOS] & @LF)
;	ConsoleWrite(Floor(5 / 4) & @LF)
;EndIf

Func StopScript()
	WinActivate("[CLASS:Vim]")
	Exit(0)
EndFunc

ConsoleWrite("OTHER => " & $I_OTHER & @LF)
ProcessInventory()
Exit(0)

Func RestartScript()
	Local $editor = "[CLASS:SciTEWindow]"
	WinActivate($editor)
	Exit(5)
EndFunc

Func hk_ProcessInventory()
	If WinActivate($wcl) Then
		ProcessInventory()
	EndIf
EndFunc

Func Daemonize()
	HotKeySet("^{NUMPAD1}", "hk_ProcessInventory")
	HotKeySet("^{NUMPAD0}", "StopScript")
	HotKeySet("^{NUMPADDOT}", "RestartScript")

	GUICreate($gui_title, 200, 100)
	GUISetState(@SW_HIDE)
	Do
		$msg = GUIGetMsg()
	Until $msg = $GUI_EVENT_CLOSE
EndFunc

Daemonize()
;_ArrayAdd($x, 1)
;ArrayDisplay($x)

;MouseClick("left", 1263, 676, 1, 0)
;Sleep(500)

; Sell everything (cell size = 32)
;$cells = 2
;For $i = 1 to 1
;For $x = 665 To 665 + 12 * 32 + 64 Step $cells * 32
;	For $y = 705 To 705 + 8 * 32 Step $cells * 32
;		MouseClick("right", $x, $y, 1, 0)
;		Sleep(25)
;	Next
;Next
;Next
