package main
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import rl "vendor:raylib"


tile_registry: map[string]TileDef

TileDef :: struct {
	name:    string,
	texture: rl.Texture2D,
}

Tile :: struct {
	x:  i32,
	y:  i32,
	id: string,
	//meta: map[string]MetaType
}

load_tiles :: proc() {
	handle, err := os.open("assets/tiles")
	if err != os.ERROR_NONE do return
	defer os.close(handle)

	files, _ := os.read_dir(handle, -1, context.allocator)

	for f in files {
		if filepath.ext(f.name) != ".png" do continue

		name := filepath.short_stem(f.name)

		tex := rl.LoadTexture(strings.clone_to_cstring(f.fullpath))

		tile_registry[name] = TileDef{name, tex}
		fmt.printfln("loaded %s", name)
	}
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
