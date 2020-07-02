; item flags as parsed from description
Enum $ITEM_is_valid = 0, $ITEM_rarity = 1, $ITEM_is_undefined = 2, $ITEM_sockets = 3, $ITEM_base = 4, $ITEM_quality = 5

; item classes
Enum $I_NONE, $I_HELMET, $I_BODY, $I_GLOVES, $I_BELT, $I_BOOTS, $I_WEAPON_2H, $I_WEAPON_1H, $I_RING, $I_AMULET, _
	$I_CURRENCY, $I_MAP, $I_DIVINATION, $I_FRAGMENT, $I_FOSSIL, $I_RESONATOR, $I_ESSENCE, $I_GEM, $I_OIL, _
	$I_DELIRIUM, $I_METAMORPH, $I_OTHER

; ItemInfo "structure"
Enum $II_CLASS = 0, $II_HEIGHT = 1, $II_WIDTH = 2, $II_SOCKETS = 3, $II_LVL = 4, $II_CHAOS = 5, $II_QUALITY = 6, $II_BASE = 7

; Item class with properties
Enum $ICLASS_class = 0, $ICLASS_height = 1, $ICLASS_width = 2

; II_ => String
Func Item2a($info);{{{
	return $info[$II_CLASS] & ":" & $info[$II_HEIGHT] & "x" & $info[$II_WIDTH]
EndFunc;}}}

Func IsMetamorphPart($w) ;{{{
	If $w == "Brain" or $w == "Eye" or $w == "Lung" or $w == "Heart" or $w == "Liver" Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc;}}}

; Determine item class and dimensions from ITEM_xx structure
; ITEM_ => ICLASS_
; 0 => item class
; 1 => item height
; 2 => item width
Func DescribeBaseItem(ByRef $info) ;{{{
	Local $desc = $info[$ITEM_base]
	Local $text

	; TEMP (Harvest League)
	;if StringRight($desc,

	If StringLeft($desc, 9) == "Superior " Then
		$text = StringMid($desc, 10)
	Else
		$text = $desc
	EndIf
	Local $words = StringSplit($text, " ")
	Local $w = $words[$words[0]]
	;ConsoleWrite("Checking '" & $text & "'..." & @LF)

	; Fragments: atziri etc {{{
	; Fragments MUST be checked before currency because splinters have rarity currency
	If StringLeft($text, 13) == "Sacrifice at " or _
	   StringLeft($text, 12) == "Splinter of " or _
	   (StringLeft($text, 9) == "Timeless " and StringRight($text, 9) == " Splinter") or _
	   StringRight($text, 7) == " Scarab" or _
	   $text == "Offering to the Goddess" _
	Then
		Return Tuple3($I_FRAGMENT, 1, 1)
	EndIf
	If $text == "Divine Vessel" Then
		Return Tuple3($I_FRAGMENT, 1, 1)
	EndIf
	; }}}
	; Delve stuff {{{
	If $w == "Resonator" Then
		If $words[1] == "Primitive" Then
			Return Tuple3($I_RESONATOR, 1, 1)
		ElseIf $words[1] == "Potent" Then
			Return Tuple3($I_RESONATOR, 2, 1)
		Else
			Return Tuple3($I_RESONATOR, 2, 2)
		EndIf
	EndIf
	If $w == "Fossil" Then
		Return Tuple3($I_FOSSIL, 1, 1)
	EndIf
	;}}}

	If $w == "Map" or ($words[0] >= 2 and $words[2] == "Map") Then
		; Dirty hack for blight tab
		if StringRegExp($desc, ".*Blighted.*") == 1 Then
			Return Tuple3($I_OIL, 1, 1)
		Else
			Return Tuple3($I_MAP, 1, 1)
		EndIf
	EndIf
	If $info[$ITEM_rarity] == "Currency" Then
		Return ClassifyCurrency($info, $text, $words)
	EndIf
	If $info[$ITEM_rarity] == "Divination Card" Then
		Return Tuple3($I_DIVINATION, 1, 1)
	EndIf
	if $info[$ITEM_rarity] == "Gem" Then
		Return Tuple3($I_GEM, 1, 1)
	EndIf

	; Metamorph
	If $info[$ITEM_rarity] == "Unique" and IsMetamorphPart($w) == 1 Then
		Return Tuple3($I_METAMORPH, 1, 1)
	EndIf

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
	Local $w1h_3x1[57] = [ "Glass Shank", "Skinning Knife", _ ;{{{
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

; Extract basic info from PoE item format
; 0 => is_valid
; 1 => rarity
; 2 => is_unidentified
; 3 => sockets
; 4 => item_base
; 5 => quality
Func ParseItemInfo($desc) ;{{{
	Local $s = SplitNL($desc)
	
	If $s[0] < 2 Then
		Local $r[1] = [False]
		Return $r
	EndIf
	
	Local $i = 1, $rty = "", $item = "", $is_unidentified = False, $sockets = 0, $quality = 0
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
		ElseIf StringLeft($s[$i], 9) == "Quality: " Then
			$quality = Int(StringMid($s[$i], 10))
		EndIf
		; Line before first separator is item base name
		If $s[$i] == "--------" and $item == "" Then
			$item = $s[$i - 1]
		EndIf
	Next
	
	Local $r[6] = [True, $rty, $is_unidentified, $sockets, $item, $quality]
	Return $r
EndFunc ;}}}

Func TItemInfo($iclass, $height, $width, $sockets, $ilvl, $chaos, $quality, $base = "--");{{{
	Local $r[8] = [$iclass, $height, $width, $sockets, $ilvl, $chaos, $quality, $base]
	return $r
EndFunc;}}}
