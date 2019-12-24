;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Storage = grid + area ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Enum $STORAGE_grid = 0, $STORAGE_contents
Func MakeStorage($grid, $rows, $cols)
	local $r[2] = [$grid, MakeArea($rows, $cols, "?")]
	return $r
EndFunc

Func Storage_Scan($stg, $max_rows = 99, $max_cols = 99)
	local $grid = $stg[$STORAGE_grid], $area = $stg[$STORAGE_contents]
	local $seen = MakeArea(99, 99, False)
	for $row = 0 to min($grid[$GRID_h] + 1, $max_rows) - 1
		for $col = 0 to min($grid[$GRID_w] + 1, $max_cols) - 1
			if $seen[$row][$col] then
				ContinueLoop
			endif

			$item = ProbeItem(GridX($grid, $col), GridY($grid, $row))
			$area[$row][$col] = $item
		next
	next
EndFunc
