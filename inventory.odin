package main

import "core:fmt"
import rl "vendor:raylib"

InventorySlot :: struct {
	item:  Item,
	count: int,
}

add_item :: proc(item: Item, count: int) {
	for &slot in player.inventory {
		if slot.item == item {
			slot.count += count
			return
		}
	}

	for &slot in player.inventory {
		if slot.count == 0 {
			slot.item = item
			slot.count = count
			return
		}
	}
}

draw_inventory :: proc() {
	i := 0
	for slot in player.inventory {
		if def, ok := item_registry[slot.item.id]; ok {
			rl.DrawTextureEx(
				def.texture,
				{10, f32(30 + i * 16 * tex_scale)},
				0.0,
				tex_scale,
				rl.WHITE,
			)
			rl.DrawText(fmt.ctprint(slot.count), 10, i32(30 + i * 16 * tex_scale), 16, rl.RAYWHITE)
			i += 1
		}
	}

	rl.DrawRectangleLines(
		10,
		i32(30 + player.hand * 16 * tex_scale),
		16 * tex_scale,
		16 * tex_scale,
		rl.GRAY,
	)
}
