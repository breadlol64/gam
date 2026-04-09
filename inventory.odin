package main

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
