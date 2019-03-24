#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

;WinActivate("[#] RF Online [#]")
$wcl = "[TITLE:Path of Exile; CLASS:POEWindowClass]"
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

Func CtrlClick() ;{{{
	Send("{CTRLDOWN}")
	Sleep(10)
	MouseClick("left")
	Sleep(10)
	Send("{CTRLUP}")
EndFunc ;}}}

Func OpenTab($no) ;{{{
	MouseMove($tablist_button_x, $tablist_button_y, 0)
	Sleep(50)
	MouseClick("left")
	Sleep(50)
	MouseMove($tablist_menu_x, $tablist_button_y + $no * $tablist_item_height, 0)
	Sleep(50)
	MouseClick("left")
	Sleep(500)
EndFunc ;}}};}}}

Global Enum $I_NONE, $I_HELMET, $I_BODY, $I_GLOVES, $I_BELT, $I_BOOTS, $I_WEAPON_2H, $I_WEAPON_1H, $I_RING, $I_AMULET, $I_OTHER

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

Enum $ICLASS_class = 0, $ICLASS_height = 1, $ICLASS_width = 2
; Item info from base type
; 0 => item class
; 1 => item height
; 2 => item width
Func DescribeBaseItem($desc) ;{{{
	Local $text
	If StringLeft($desc, 9) == "Superior " Then
		$text = StringMid($desc, 10)
	Else
		$text = $desc
	EndIf
	Local $words = StringSplit($text, " ")
	Local $w = $words[$words[0]]
	ConsoleWrite("Checking '" & $text & "'..." & @LF)

	; Helmets
	Local $all_helmets[15] = [ "Hat", "Helmet", "Burgonet" _
	, "Cap", "Tricorne", "Hood", "Pelt" _
	, "Circlet", "Cage" _
	, "Helm", "Sallet", "Bascinet" _
	, "Coif", "Crown" _
	, "Mask"]
	If Lookup($w, $all_helmets) == True Then
		Return Tuple3($I_HELMET, 2, 2)
	EndIf
	
	; Body armor
	Local $all_bodies[24] = [ _
		"Vest", "Chestplate", "Plate", _
		"Jerkin", "Leather", "Tunic", "Garb", _
		"Robe", "Vestment", "Regalia", "Wrap", "Silks", _
		"Brigandine", "Doublet", "Armour", "Lamellar", "Wyrmscale", "Dragonscale", _
		"Coat", "Ringmail", "Chainmail", "Hauberk", _
		"Jacket", "Raiment"]
	If Lookup($w, $all_bodies) == True Then
		Return Tuple3($I_BODY, 3, 2)
	EndIf
	
	; Gloves
	Local $all_gloves[3] = [ "Gauntlets", "Gloves", "Mitts"]
	If Lookup($w, $all_gloves) == True Then
		Return Tuple3($I_GLOVES, 2, 2)
	EndIf
	
	; Belts
	Local $belts[3] = ["Belt", "Vise", "Sash"]
	If Lookup($w, $belts) == True Then
		Return Tuple3($I_BELT, 1, 2)
	EndIf

	; Boots
	Local $all_boots[4] = ["Greaves", "Boots", "Shoes", "Slippers"]
	If Lookup($w, $all_boots) == True Then
		Return Tuple3($I_BOOTS, 2, 2)
	EndIf
	
	; Rings
	Local $rings[2] = ["Ring", "Hoop"]
	If Lookup($w, $rings) == True Then
		Return Tuple3($I_RING, 1, 1)
	EndIf
	
	; Amultes
	Local $amulets[1] = ["Amulet"]
	If Lookup($w, $amulets) == True Then
		Return Tuple3($I_AMULET, 1, 1)
	EndIf

	; Cool one-handed 3x1 weapons
	Local $w1h_3x1[51] = [ "Glass Shank", "Skinning Knife", _ ;{{{
		"Carving Knife", "Stiletto", "Boot Knife", "Copper Kris", _
		"Skean", "Imp Dagger", "Flaying Knife", "Prong Dagger", _
		"Butcher Knife", "Poignard", "Boot Blade", "Golden Kris", _
		"Royal Skean", "Fiend Dagger", "Trisula", "Gutting Knife", _
		"Slaughter Knife", "Ambusher", "Ezomyte Dagger", "Platinum Kris", _
		"Imperial Skean", "Demon Dagger", "Sai", _ ;}}}
		"Driftwood Wand", "Goat's Horn", "Carved Wand", "Quartz Wand", _ ;{{{
		"Spiraled Wand", "Sage Wand", "Pagan Wand", "Faun's Horn", _
		"Engraved Wand", "Crystal Wand", "Serpent Wand", "Omen Wand", _
		"Heathen Wand", "Demon's Horn", "Imbued Wand", "Opal Wand", _
		"Tornado Wand", "Prophecy Wand", "Profane Wand", _;}}}
		"Sabre", "Copper Sword", "Variscite Blade", "Cutlass", _;{{{
		"Gemstone Sword", "Corsair Sword", _
		"Driftwood Club", "Tribal Club", "Spiked Club", "Petrified Club", _ ; Handmade list of 3x1 maces
		"Barbed Club", "Ancestral Club", "Tenderizer"] ;}}}
	If Lookup($text, $w1h_3x1) == True Then
		Return Tuple3($I_WEAPON_1H, 3, 1)
	EndIf
	; One-handed 2x2 stuff which is viable for trading purposes (claws, some shields)
	Local $w1h_2x2[70] = [ "Nailed Fist", "Sharktooth Claw", "Awl", _ ;{{{
		"Cat's Paw", "Blinder", "Timeworn Claw", "Sparkling Claw", _
		"Fright Claw", "Double Claw", "Thresher Claw", "Gouger", _
		"Tiger's Paw", "Gut Ripper", "Prehistoric Claw", "Noble Claw", _
		"Eagle Claw", "Twin Claw", "Great White Claw", "Throat Stabber", _
		"Hellion's Paw", "Eye Gouger", "Vaal Claw", "Imperial Claw", _
		"Terror Claw", "Gemini Claw", _;}}}
		"Goathide Buckler", "Pine Buckler", "Painted Buckler", "Hammered Buckler", _;{{{
		"War Buckler", "Gilded Buckler", "Oak Buckler", "Enameled Buckler", _
		"Corrugated Buckler", "Battle Buckler", "Golden Buckler", "Ironwood Buckler", _
		"Lacquered Buckler", "Vaal Buckler", "Crusader Buckler", "Imperial Buckler", _
		"Twig Spirit Shield", "Yew Spirit Shield", "Bone Spirit Shield", "Tarnished Spirit Shield", _
		"Jingling Spirit Shield", "Brass Spirit Shield", "Walnut Spirit Shield", "Ivory Spirit Shield", _
		"Ancient Spirit Shield", "Chiming Spirit Shield", "Thorium Spirit Shield", "Lacewood Spirit Shield", _
		"Fossilised Spirit Shield", "Vaal Spirit Shield", "Harmonic Spirit Shield", "Titanium Spirit Shield", _
		"Spiked Bundle", "Driftwood Spiked Shield", "Alloyed Spiked Shield", "Burnished Spiked Shield", _
		"Ornate Spiked Shield", "Redwood Spiked Shield", "Compound Spiked Shield", "Polished Spiked Shield", _
		"Sovereign Spiked Shield", "Alder Spiked Shield", "Ezomyte Spiked Shield", "Mirrored Spiked Shield", _
		"Supreme Spiked Shield"] ;}}}
	If Lookup($text, $w1h_2x2) == True Then
		Return Tuple3($I_WEAPON_1H, 2, 2)
	EndIf

	; Two-handed weapons
	Local $w2h_4x2[109] = [ "Stone Axe", "Jade Chopper", "Woodsplitter", "Poleaxe", "Double Axe", _ ;{{{
		"Gilded Axe", "Shadow Axe", "Dagger Axe", "Jasper Chopper", "Timber Axe", _
		"Headsman Axe", "Labrys", "Noble Axe", "Abyssal Axe", "Karui Chopper", _
		"Talon Axe", "Sundering Axe", "Ezomyte Axe", "Vaal Axe", "Despot Axe", _
		"Void Axe", "Fleshripper", _;}}}
		"Corroded Blade", "Longsword", "Bastard Sword", "Two-Handed Sword", _ ; {{{
		"Etched Greatsword", "Ornate Sword", "Spectral Sword", "Curved Blade", _
		"Butcher Sword", "Footman Sword", "Highland Blade", "Engraved Greatsword", _
		"Tiger Sword", "Wraith Sword", "Lithe Blade", "Headman's Sword", _
		"Reaver Sword", "Ezomyte Blade", "Vaal Greatsword", "Lion Sword", _
		"Infernal Sword", "Exquisite Blade", _ ;}}}
		"Driftwood Maul", "Tribal Maul", "Mallet", "Sledgehammer", _ ;{{{
		"Jagged Maul", "Brass Maul", "Fright Maul", "Morning Star", _
		"Totemic Maul", "Great Mallet", "Steelhead", "Spiny Maul", _
		"Plated Maul", "Dread Maul", "Solar Maul", "Karui Maul", _
		"Colossus Mallet", "Piledriver", "Meatgrinder", "Imperial Maul", _
		"Terror Maul", "Coronal Maul", _ ;}}}
		"Gnarled Branch", "Primitive Staff", "Long Staff", "Iron Staff", _ ;{{{
		"Coiled Staff", "Royal Staff", "Vile Staff", "Crescent Staff", _
		"Woodful Staff", "Quarterstaff", "Military Staff", "Serpentine Staff", _
		"Highborn Staff", "Foul Staff", "Moon Staff", "Primordial Staff", _
		"Lathi", "Ezomyte Staff", "Maelstrom Staff", "Imperial Staff", _
		"Judgement Staff", "Eclipse Staff", _ ;}}}
		"Long Bow", "Composite Bow", "Recurve Bow", "Bone Bow", _ ;{{{
		"Royal Bow", "Death Bow", "Reflex Bow", "Decurve Bow", _
		"Compound Bow", "Sniper Bow", "Ivory Bow", "Highborn Bow", _
		"Decimation Bow", "Steelwood Bow", "Citadel Bow", "Ranger Bow", _
		"Assassin Bow", "Spine Bow", "Imperial Bow", "Harbinger Bow", _
		"Maraketh Bow"];}}}
	If Lookup($text, $w2h_4x2) == True Then
		Return Tuple3($I_WEAPON_2H, 4, 2)
	EndIf

	Local $w2h_3x2[4] = [ "Crude Bow", "Short Bow", "Grove Bow", "Thicket Bow" ]
	If Lookup($text, $w2h_3x2) == True Then
		Return Tuple3($I_WEAPON_2H, 3, 2)
	EndIf

	Return Tuple3($I_OTHER, 1, 1)
EndFunc ;}}}

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


Func GetItemDescI($row, $col) ;{{{
	MouseMove(InventoryX($col), InventoryY($row), 0)
	ClipPut("")
	Sleep(15)
	Send("^c")
	Sleep(15)
	Return ClipGet()
EndFunc ;}}}

Enum $ITEM_is_valid = 0, $ITEM_rarity = 1, $ITEM_is_undefined = 2, $ITEM_sockets = 3, $ITEM_base = 4
; Try to parse item info into array
; 0 => is_valid
; 1 => rarity
; 2 => is_unidentified
; 3 => sockets
; 4 => item_base)
Func ParseItemInfo($desc) ;{{{
	Local $s = SplitNL($desc)
	
	If $s[0] < 2 Then
		Local $r[1] = [False]
		Return $r
	EndIf
	
	Local $i = 1, $rty = "", $item = "", $is_unidentified = False, $sockets = 0
	For $i = 1 to $s[0]
		If StringLeft($s[$i], 8) == "Rarity: " Then
			$rty = StringMid($s[$i], 9)
		EndIf
		; Track unidentified flag
		If $s[$i] == "Unidentified" Then
			$is_unidentified = True
		EndIf
		; Analyze sockets,
		If StringLeft($s[$i], 9) == "Sockets: " Then
			Local $skt = StringMid($s[$i], 10)
			$sockets = StringLen($skt) / 2
		EndIf
		; Line before first separator is item base name
		If $s[$i] == "--------" and $item == "" Then
			$item = $s[$i - 1]
		EndIf
	Next
	
	Local $r[5] = [True, $rty, $is_unidentified, $sockets, $item]
	Return $r
EndFunc ;}}}

Enum $II_CLASS = 0, $II_HEIGHT = 1, $II_WIDTH = 2, $II_SOCKETS = 3, $II_LVL = 4, $II_CHAOS = 5
Func TItemInfo($iclass, $height, $width, $sockets, $ilvl, $chaos);{{{
	Local $r[6] = [$iclass, $height, $width, $sockets, $ilvl, $chaos]
	return $r
EndFunc;}}}

; Get raw item description by moving mouse pointer and issuing "Ctrl-C".
; Item description is parsed
Func ProbeItem($x, $y) ;{{{
	ClipPut("")
	MouseMove($x, $y, 1)
	Sleep(15)
	Send("^c")
	Sleep(15)
	$text = ClipGet()
	;ConsoleWrite("'" & $text & "'" & @LF)	
	If $text == "" Then
		Return TItemInfo($I_NONE, 1, 1, 0, 0, False)
	EndIf
	; Now parse description
	$info = ParseItemInfo($text)
	If $info[$ITEM_is_valid] == False Then
		Return TItemInfo($I_NONE, 1, 1, 0, 0, False)
	EndIf
	; Interpret base class to know dimension and other shit
	Local $item = DescribeBaseItem($info[$ITEM_base])
	ConsoleWrite("'" & $info[$ITEM_base] & "' => " & $item[$ICLASS_class] & ", sockets = " & $info[$ITEM_sockets] & "rarity = " & $info[$ITEM_rarity] & @LF)
	Return TItemInfo($item[$ICLASS_class], $item[$ICLASS_height], $item[$ICLASS_width], _
		$info[$ITEM_sockets], 60, $info[$ITEM_is_undefined] and $info[$ITEM_rarity] == "Rare")
EndFunc ;}}}


; Convenience wrapper to probe item in inventory
Func InventoryProbe($row, $col);{{{
	Return ProbeItem(InventoryX($col) + 8, InventoryY($row) + 8)
EndFunc;}}}

; Convenience wrapper to probe item in quad stash tab
Func QtabProbe($row, $col);{{{
	Return ProbeItem(QtabX($col) + 8, QtabY($row) + 8)
EndFunc;}}}

; Convenience wrapper to move items between stash and Qtab
Func Inventory2Qtab($iRow, $iCol, $qRow, $qCol, $h, $w);{{{
	ConsoleWrite("Move " & $iRow & "," & $iCol & " -> " & $qRow & "," & $qCol & "(" & $h & "x" & $w & @LF)
	ItemMove((InventoryX($iCol) + InventoryX($iCol + $w)) / 2, (InventoryY($iRow) + InventoryY($iRow + $h)) / 2, (QtabX($qCol) + QtabX($qCol + $w)) / 2, (QtabY($qRow) + QtabY($qRow + $h)) / 2)
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

;MouseMove(907, 681, 0)
;Send("^c")


Func Main() ;{{{
	Sleep(25)
	For $row = 0 to 4
		For $col = 0 to 11
			if $invMap[$row][$col] <> '-' Then
				ContinueLoop
			EndIf
			$d = ParseItemInfo(GetItemDescI($row, $col))
			If $d[0] == True Then
				Local $item = DescribeBaseItem($d[4])
				if $item[0] <> $I_OTHER and PartOfChaosSet($d) Then
					ConsoleWrite("item = " & $item[0] & @LF)
					MarkInv($invMap, $row, $col, $item[1], $item[2], '+')
				EndIf
				;$invMap[$row][$col] = '+'
				;ConsoleWrite("(" & $row & "," & $col & ") -> " & $d[4] & Chr(10))
				If $d[4] == "1Lunaris Circlet" Then
				EndIf
			EndIf
		Next
	Next

	For $i = 0 to 4
		For $j = 0 to 11
			ConsoleWrite($invMap[$i][$j])
			;If $invMap[$i][$j] == True Then
			;	ConsoleWrite('*')
			;Else
			;	ConsoleWrite('-')
			;EndIf
		Next
		ConsoleWrite(Chr(10))
	Next
EndFunc ;}}}

Func Offset1($row, $col);{{{
	Local $r[1][2] = [[$row, $col]]
	Return $r
EndFunc;}}}

Func Offset2($row1, $col1, $row2, $col2);{{{
	Local $r[2][2] = [[$row1, $col1], [$row2, $col2]]
	return $r
EndFunc;}}}

; Return array of possible relative offsets (rowOff, colOff for this item inside chaos set)
Func CalcOffset($iclass, $h, $w);{{{
	If $iclass == $I_HELMET Then
		Return Offset1(0, 0)
	ElseIf $iclass == $I_GLOVES Then
		Return Offset1(2, 0)
	ElseIf $iclass == $I_BELT Then
		Return Offset1(4, 0)
	ElseIf $iclass == $I_BODY Then
		Return Offset1(0, 2)
	ElseIf $iclass == $I_BOOTS Then
		Return Offset1(3, 2)
	ElseIf $iclass == $I_WEAPON_2H Then
		Return Offset1(0, 4)
	ElseIf $iclass == $I_WEAPON_1H and $h == 3 and $w == 1 Then
		Return Offset2(0, 4, 0, 5)
	ElseIf $iclass == $I_WEAPON_1H and $h == 2 and $w == 2 Then
		Return Offset2(0, 4, 2, 4)
	EndIf
	Local $r
	Return $r
EndFunc;}}}


Global $qtab = MakeArea(24, 24, "?")

Func Item2a($info)
	return $info[$II_CLASS] & ":" & $info[$II_HEIGHT] & "x" & $info[$II_WIDTH]
EndFunc

Func QLook($row, $col, $mark)
	Local $what = $qtab[$row][$col]
	if $what == "?" then
		Local $info = QtabProbe($row, $col)
		if $info[$II_CLASS] <> $I_NONE then
			$what = Item2a($info)
			MarkInv($qtab, $row, $col, $info[$II_HEIGHT], $info[$II_WIDTH], $mark)
		else
			$what = ""
			MarkInv($qtab, $row, $col, 1, 1, "")
		endif
	endif
	return $what
EndFunc

; Move chaos set item to unoccupied cell of inventory
Func MoveChaosSetItem($irow, $icol, $coff, $info); {{{
	Local $mark, $w, $h, $i, $base_col, $base_row
	$h = $info[$II_HEIGHT]
	$w = $info[$II_WIDTH]
	$mark = Item2a($info)
	for $set = 0 to 15
		Local $i, $what
		$base_row = Floor($set / 4) * 5
		$base_col = Mod($set, 4) * 6
		; look at first position
		$row = $base_row + $coff[0][0]
		$col = $base_col + $coff[0][1]
		$what = QLook($row, $col, $mark)
		; try to fallback to second position
		if $what <> "" and $what == $mark and UBound($coff) > 1 then
			ConsoleWrite("Trying next index " & UBound($coff) & @LF)
			$row = $base_row + $coff[1][0]
			$col = $base_col + $coff[1][1]
			$what = QLook($row, $col, $mark)
		endif
		if $what == "" then
			ConsoleWrite("   -> " & $row & "," & $col & @LF)
			MarkInv($qtab, $row, $col, $h, $w, $mark)
			Inventory2Qtab($irow, $icol, $row, $col, $h, $w)
			;MouseMove(InventoryX($icol), InventoryY($irow), 0)
			;MouseMove(QtabX($col), QtabY($row), 10)
			;Sleep(200)
			ExitLoop
		endif
	next
	;MouseMove(QtabX($coff[0][1]), QtabY($coff[0][0]))
	;;Sleep(200)
EndFunc;}}}


Func ProcessInventory();{{{
	Local $seen = MakeArea(5, 12, False)
	for $row = 0 to 4
		for $col = 0 to 9 ; Keep last two rows for my stuff
			if $seen[$row][$col] then
				ContinueLoop
			endif
			$item = InventoryProbe($row, $col)
			if $item[$II_CLASS] == $I_NONE then
				ContinueLoop
			endif
			MarkInv($seen, $row, $col, $item[$II_HEIGHT], $item[$II_WIDTH], True)
			ConsoleWrite("Seen " & $item[$II_CLASS] & " @ " & $row & "," & $col & ", " & $item[$II_HEIGHT] & "x" & $item[$II_WIDTH] & @LF)
			If $item[$II_CHAOS] Then
				$off = CalcOffset($item[$II_CLASS], $item[$II_HEIGHT], $item[$II_WIDTH])
				If IsArray($off) Then
					MoveChaosSetItem($row, $col, $off, $item)
				EndIf
			EndIf
		next
	next
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

OpenTab(3)
ProcessInventory()

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
