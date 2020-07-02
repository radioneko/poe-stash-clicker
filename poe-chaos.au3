#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include "config.au3"
#include "util.au3"
#include <GUIConstantsEx.au3>

$wcl = "[TITLE:Path of Exile; CLASS:POEWindowClass]"
$gui_title = "P4th 0f Tr4d1ng"
$gui_class = "[TITLE:" & $gui_title & "; CLASS:AutoIt v3 GUI]"
WinClose($gui_class)
WinActivate($wcl)
WinWaitActive($wcl)

;Sleep(2000)


;Global $inventory_top_x = 880, $inventory_top_y = 653, $cell_size = 58

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     "STRUCTURES"     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

Func SplitNL($text) ;{{{
	Return StringSplit(StringReplace($text, Chr(13), ""), Chr(10))
EndFunc ;}}}

Func InventoryX($col) ;{{{
	Return $col / 12 * ($inventory_bottom_x - $inventory_top_x) + $inventory_top_x
	;Return $inventory_top_x + $cell_size * $col
EndFunc ;}}}

Func InventoryY($row) ;{{{
	Return $row / 5 * ($inventory_bottom_y - $inventory_top_y) + $inventory_top_y
	;Return $inventory_top_y + $cell_size * $row
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
	Sleep($delay_basic)
	MouseClick("left")
	Sleep($delay_basic)
	;MouseClick("left", $dstX, $dstY)
	MouseMove($dstX, $dstY, 0)
	Sleep($delay_basic)
	MouseClick("left")
	Sleep($delay_basic)
EndFunc;}}}

Func CtrlClick($x, $y) ;{{{
	Send("{CTRLDOWN}")
	Sleep($delay_ctrl)
	if $x >= 0 and $y >= 0 then
		MouseMove($x, $y, 0)
	endif
	Sleep(20)
	MouseClick("left")
	Sleep($delay_ctrl)
	Send("{CTRLUP}")
	Sleep($delay_ctrl)
EndFunc ;}}}

Func InventoryCtrlClick($row, $col);{{{
	CtrlClick(InventoryX($col) + 8, InventoryY($row) + 8)
EndFunc;}}}

Func OpenTab($no) ;{{{
	MouseMove($tablist_button_x, $tablist_button_y, 0)
	Sleep($delay_basic)
	MouseClick("left")
	Sleep($delay_basic * 2)
	Send("{UP}")
	Sleep($delay_basic)
	MouseMove($tablist_menu_x, $tablist_button_y + $no * $tablist_item_height, 8)
	Sleep(80)
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
	If StringRegExp($base, ".* Oil$") == 1 Then
		Return Tuple3($I_OIL, 1, 1)
	EndIf
	; Metamorph league
	if StringRegexp($base, ".*Catalyst$") == 1 Then
		Return Tuple3($I_METAMORPH, 1, 1)
	EndIf
	; Delirium league
	if $base == "Simulacrum Splinter" Then
		Return Tuple3($I_DELIRIUM, 1, 1)
	EndIf
	; Harvest league
	if StringRegExp($base, ".*Seed$") == 1 or StringRegExp($base, ".*Grain$") == 1 _
			or StringRegExp($base, ".*Bulb$") == 1 or StringRegExp($base, ".*Blisterfruit") == 1 _
			or $base == "Storage Tank" or $base == "Pylon" _
		Then
		Return Tuple3($I_OTHER, 1, 1)
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

; Get raw item description by moving mouse pointer and issuing "Ctrl-C".
; Returns II_ (aka TItemInfo)
Func ProbeItem($x, $y) ;{{{
	ClipPut("")
	MouseMove($x, $y, 1)
	Sleep($delay_probe)
	Send("^c")
	Sleep($delay_probe)
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

#include "storage.au3"

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
	Local $bizha_max = 22
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
	Local $chaosItems, $currencyItems, $mapItems, $divinationItems, $fragmentItems, _
			$fossils, $resonators, $essenses, $gems, $oils, $delirium, $metamorph
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
			PushIfClass($oils, $iref, $I_OIL)
			PushIfClass($delirium, $iref, $I_DELIRIUM)
			PushIfClass($metamorph, $iref, $I_METAMORPH)
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
	MassCtrlClick($oils, $TAB_OIL, 500, 50)
	MassCtrlClick($delirium, $TAB_DELIRIUM, 500, 50)
	MassCtrlClick($metamorph, $TAB_METAMORPH, 500, 50)
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

Func SwapFn($x1, $y1, $x2, $y2)
	Local $dly = 100
	Local $spd = 0
	MouseMove($x1, $y1, $spd)
	Sleep($dly)
	MouseClick("left")
	Sleep($dly)
	MouseMove($x2, $y2, $spd)
	Sleep($dly)
	MouseClick("left")
	Sleep($dly)
	MouseMove($x1, $y1, $spd)
	Sleep($dly)
	MouseClick("left")
	Sleep($dly)
EndFunc

Func SwapGemSkills()
	Local $path[5][2] = [[0, 1], [0, 0], [1, 0], [2, 0], [2, 1]]
	Local $base_row = 0
	Local $base_col = 10
	Local $ammu_left = 1200
	Local $ammu_top = 280
	Local $ammu_right = 1260
	Local $ammu_bot = 400
	Local $ammu_w = 2 - 1
	Local $ammu_h = 3 - 1
	Sleep(250)
	Send("{CTRLUP}")
	Sleep(100)
	For $i = 0 to UBound($path) - 1
		Local $x1 = InventoryX($base_col + $path[$i][1])
		Local $y1 = InventoryY($base_row + $path[$i][0])
		Local $x2 = $ammu_left + ($ammu_right - $ammu_left) * $path[$i][1] / $ammu_w
		Local $y2 = $ammu_top + ($ammu_bot - $ammu_top) * $path[$i][0] / $ammu_h
		SwapFn($x1, $y1, $x2, $y2)
	Next
EndFunc

Func ArrPrint($a)
	for $i = 0 to UBound($a) - 1
		ConsoleWrite("[ " & $i & "] => <" & $a[$i] & ">" & @LF)
	next
EndFunc

Func GetAffixes($desc);{{{
	local $sec = StringSplit($desc, @CR & @LF & "--------" & @CR & @LF, 1)
	local $affixes
	; Affixes are after item level (i think)
	for $i = 0 to UBound($sec) - 1
		if StringLeft($sec[$i], 11) == "Item Level:" then
			$affixes = SplitNL($sec[$i + 1])
			ExitLoop
		endif
	next
	local $j = 0
	for $i = 1 to UBound($affixes) - 1
		if $affixes[$i] <> "" then
			$affixes[$j] = $affixes[$i]
			$j = $j + 1
		endif
	next
	ReDim $affixes[$j]
	return $affixes
EndFunc;}}}


Func BenchApply($loc)
	local $bench[2] = [379, 582]
	MouseClick("right", $loc[0], $loc[1], 1, 3)
	Sleep(100)
	MouseClick("left", $bench[0], $bench[1], 1, 3)
	Sleep(100)
EndFunc


; Apply alteration or augmentation orb based
; on how many affixes item already have
Func AltOrAug();{{{
	local $alt[2] = [130, 374]
	local $aug[2] = [261, 431]
	local $bench[2] = [379, 582]
	local $dly = 25
	MouseMove($bench[0], $bench[1], 0)
	Sleep($dly)
	Send("^c")
	Sleep($dly)

	local $desc = StringSplit(ClipGet(), @CR & @LF, 1)
	local $pos = FindFractured($desc)
	if $pos == -1 then
		return
	endif
	;ArrPrint($desc)
	;ConsoleWrite("POS = " & $pos & @CR)
	local $naffixes
	if StringLeft($desc[$pos + 1], 2) == "--" then
		$naffixes = 1
	else
		$naffixes = 2
	endif
;	local $affixes = GetAffixes(ClipGet())
;	local $naffixes = UBound($affixes)
;		ConsoleWrite("naffix = " & $naffixes & @LF)
;		for $i = 0 to $naffixes - 1
;			ConsoleWrite("<" & $affixes[$i] & ">" & @LF)
;		next
	if $naffixes == 1 then
		BenchApply($aug)
		ConsoleWrite("AUG" & @LF)
	elseif $naffixes == 2 then
		BenchApply($alt)
		ConsoleWrite("alt" & @LF)
	endif
EndFunc;}}}

Func ApplyAlt();{{{
	if WinActive($wcl) then
		local $alt[2] = [126, 321]
		BenchApply($alt)
	endif
EndFunc;}}}

Func ApplyAug();{{{
	if WinActive($wcl) then
		local $aug[2] = [252, 389]
		BenchApply($aug)
	endif
EndFunc;}}}

Func DoOneAura($row, $col);{{{
	local $grid_x[3] = [1074, 1224, 2]
	local $grid_y[3] = [640,  1000, 5]
	local $panel[2] = [1314, 1162]
	local $dly = 150
	
	MouseClick("left", $panel[0], $panel[1], 1, 5)
	Sleep($dly)
	MouseClick("left", ToGrid($col, $grid_x), ToGrid($row, $grid_y), 1, 5)
	Sleep($dly)
	Send("w")
	Sleep($dly)
EndFunc;}}}

; Cast auras on my ll nearly-always-dead character
Func EnableAuras();{{{
	DoOneAura(0, 1)
	DoOneAura(1, 1)
	DoOneAura(2, 0)
	DoOneAura(2, 2)
	DoOneAura(3, 1)
	DoOneAura(5, 0)
	; Clear slot
	DoOneAura(5, 2)
EndFunc;}}}


; Scan tab for gems
Func DoGems()
	local $grid = $grid_stash
	local $seen = MakeArea(12, 12, False)
	local $count = 0
	for $row = 0 to 11
		for $col = 0 to 11
			if $seen[$row][$col] then
				ContinueLoop
			endif

			$item = ProbeItem(GridX($grid, $col), GridY($grid, $row))
			if $item[$II_CLASS] == $I_NONE then
				ContinueLoop
			endif
			MarkInv($seen, $row, $col, $item[$II_HEIGHT], $item[$II_WIDTH], True)
			if $item[$II_CLASS] <> $I_GEM then
				ContinueLoop
			endif

			if $item[$II_QUALITY] < 15 and $item[$II_QUALITY] > 0 then
				CtrlClick(-1, -1)
				$count = $count + 1
				if $count >= 5 * 8 then
					ExitLoop 2
				endif
			endif
		next
	next

EndFunc

Func StopScript()
	WinActivate("[CLASS:Vim]")
	Exit(0)
EndFunc

ConsoleWrite("OTHER => " & $I_OTHER & @LF)

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
	HotKeySet("^{NUMPAD2}", "DoGems")
	;HotKeySet("^{NUMPAD5}", "AltOrAug")
	HotKeySet("^{NUMPAD4}", "ApplyAlt")
	HotKeySet("^{NUMPAD5}", "ApplyAug")
	HotKeySet("^{NUMPAD9}", "EnableAuras")

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
