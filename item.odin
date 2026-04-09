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

load_items :: proc() {
	handle, err := os.open("assets/items")
	if err != os.ERROR_NONE do return
	defer os.close(handle)

	files, _ := os.read_dir(handle, -1, context.allocator)

	for f in files {
		if filepath.ext(f.name) != ".png" do continue

		name := filepath.short_stem(f.name)

		tex := rl.LoadTexture(strings.clone_to_cstring(f.fullpath))

		item_registry[name] = ItemDef{name, tex}
		fmt.printfln("loaded %s", name)
	}
}
