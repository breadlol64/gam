package main
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import rl "vendor:raylib"

item_registry: map[string]ItemDef

ItemDef :: struct {
	name:    string,
	texture: rl.Texture2D,
}

// MetaType :: union {
// 	string,
// 	int,
// }

Item :: struct {
	id: string,
	//meta: map[string]MetaType,
}

register_item :: proc(id: string) {
	item_registry[id] = {id, rl.LoadTexture(fmt.ctprintf("assets/items/%s.png", id))}
}

load_items :: proc() {
	register_item("wood")
	register_item("flint_axe")
}
