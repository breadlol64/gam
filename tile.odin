package main
import "core:fmt"
import "core:slice"
import rl "vendor:raylib"


tile_registry: map[string]TileDef

TileDef :: struct {
	name:           string,
	breakable:      bool,
	breakable_with: []string,
	drops:          map[string]int,
	texture:        rl.Texture2D,
}

Tile :: struct {
	x:  i32,
	y:  i32,
	id: string,
	//meta: map[string]MetaType
}

register_tile :: proc(
	id: string,
	drops: map[string]int,
	breakable: bool,
	breakable_with: []string,
) {
	tile_registry[id] = {
		id,
		breakable,
		slice.clone(breakable_with),
		drops,
		rl.LoadTexture(fmt.ctprintf("assets/tiles/%s.png", id)),
	}
}

load_tiles :: proc() {
	register_tile("grass", {}, false, {})
	register_tile("planks", {}, true, {})
	register_tile("sand", {}, false, {})
	tree_drops: map[string]int
	tree_drops["wood"] = 5
	register_tile("tree", tree_drops, true, []string{"flint_axe"})
	register_tile("water", {}, false, {})
}

draw_tiles :: proc() {
	for layer in world {
		for tile in layer {
			if def, ok := tile_registry[tile.id]; ok {

				rl.DrawTextureEx(
					def.texture,
					{f32(tile.x * tex_size * tex_scale), f32(tile.y * tex_size * tex_scale)},
					0.0,
					tex_scale,
					rl.WHITE,
				)
			}
		}
	}
}
