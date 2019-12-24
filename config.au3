
Global $REG_ROOT = "HKEY_CURRENT_USER\Software\POE-clicker"

Func reg_get($param, $dfl)
	local $r = RegRead($REG_ROOT, $param)
	if @error <> 0 then
		RegWrite($REG_ROOT, $param, "REG_DWORD", $dfl)
		return $dfl
	else
		return $r
	endif
EndFunc

Global _
	$tablist_button_x = reg_get("tablist_button_x", 710), _
	$tablist_button_y = reg_get("tablist_button_y", 162), _
	$tablist_menu_x = reg_get("tablist_menu_x", 770), _
	$tablist_item_height = reg_get("tablist_item_height", 24)

Global _
	$stash_top_x = reg_get("stash_top_x", 19), _
	$stash_top_y = reg_get("stash_top_y", 180), _
	$stash_bottom_x = reg_get("stash_bottom_x", 724), _
	$stash_bottom_y = reg_get("stash_bottom_y", 884), _
	$stash_qcell = reg_get("stash_qcell", 29), _
	$stash_cell = reg_get("stash_cell", $stash_qcell * 2)

Global _
	$inventory_top_x = reg_get("inventory_top_x", 881), _
	$inventory_top_y = reg_get("inventory_top_y", 654), _
	$inventory_bottom_x = reg_get("inventory_bottom_x", 1585), _
	$inventory_bottom_y = reg_get("inventory_bottom_y", 950)

Global _
	$TAB_CURRENCY = reg_get("TAB_CURRENCY", 0), _
	$TAB_MAPS = reg_get("TAB_MAPS", 1), _
	$TAB_DIVINATION = reg_get("TAB_DIVINATION", 2), _
	$TAB_CHAOS = reg_get("TAB_CHAOS", 3), _
	$TAB_ESSENCE = reg_get("TAB_ESSENCE", 4), _
	$TAB_FRAGMENTS = reg_get("TAB_FRAGMENTS", 30), _
	$TAB_RESONATORS = reg_get("TAB_RESONATORS", 5), _
	$TAB_FOSSILS = reg_get("TAB_FOSSILS", 5), _
	$TAB_GEMS = reg_get("TAB_GEMS", 15), _
	$TAB_OIL = reg_get("TAB_OILS", 13)

Global _
	$delay_basic = reg_get("delay_basic", 50), _
	$delay_ctrl = reg_get("delay_ctrl", 10), _
	$delay_probe = reg_get("delay_probe", 20)
