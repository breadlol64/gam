package main

import "core:fmt"
import "core:slice"
import rl "vendor:raylib"

tex_size :: 16
tex_scale :: 3.0
player_speed :: 200
zoom_speed :: 1.0

Player :: struct {
	x:         f32,
	y:         f32,
	camera:    rl.Camera2D,
	texture:   rl.Texture2D,
	inventory: [10]InventorySlot,
	hand:      int, // index to inventory
}

world: [2][dynamic]Tile
tile_map: [2]map[[2]int]int
player: Player

main :: proc() {
	rl.InitWindow(800, 600, "game")
	defer rl.CloseWindow()

	load_tiles()
	load_items()
	player.x = 0
	player.y = 0
	player.camera = rl.Camera2D{{400, 300}, {f32(player.x), f32(player.y)}, 0.0, 1.0}
	player.texture = rl.LoadTexture("assets/player.png")
	player.inventory = {}
	player.hand = 0

	add_item({"flint_axe"}, 1)
	fmt.println(player.inventory)

	seed := rl.GetRandomValue(0, 2000000000)
	gen_world(i64(seed))

	for !rl.WindowShouldClose() {
		fps := rl.GetFPS()
		dt := rl.GetFrameTime()
		w := rl.GetScreenWidth()
		h := rl.GetScreenHeight()

		input(dt)
		update()
		draw(fps, dt, w, h)
	}

}

input :: proc(dt: f32) {
	if rl.IsKeyDown(.W) {
		player.y -= player_speed * dt
	}
	if rl.IsKeyDown(.S) {
		player.y += player_speed * dt
	}
	if rl.IsKeyDown(.A) {
		player.x -= player_speed * dt
	}
	if rl.IsKeyDown(.D) {
		player.x += player_speed * dt
	}

	if rl.IsMouseButtonPressed(.LEFT) {
		m := rl.GetMousePosition()
		w := rl.GetScreenToWorld2D(m, player.camera)
		x, y := to_tile_coords(w.x, w.y)
		if idx, t_ok := tile_map[1][{x, y}]; t_ok {
			tile := world[1][idx]
			if def, d_ok := tile_registry[tile.id]; d_ok {
				if def.breakable &&
				   slice.contains(def.breakable_with, player.inventory[player.hand].item.id) {
					unordered_remove(&world[1], idx)
					delete_key(&tile_map[1], [2]int{int(tile.x), int(tile.y)})

					for drop, count in def.drops {
						add_item({drop}, count)
					}
				}
			}
		}
	}

	key := rl.GetKeyPressed()
	if key >= .ONE && key <= .NINE {
		player.hand = int(key) - int(rl.KeyboardKey.ONE)
	} else if key == .ZERO {
		player.hand = 9
	}

	if rl.IsKeyDown(.I) {
		player.camera.zoom += zoom_speed * dt
	}
	if rl.IsKeyDown(.O) {
		player.camera.zoom -= zoom_speed * dt
	}
}

update :: proc() {

	player.camera.target = {player.x, player.y}
}

draw :: proc(fps: i32, dt: f32, w: i32, h: i32) {
	rl.BeginDrawing()
	rl.BeginMode2D(player.camera)
	rl.ClearBackground(rl.BLACK)

	draw_tiles()

	rl.DrawTextureEx(player.texture, {f32(player.x), f32(player.y)}, 0.0, tex_scale, rl.WHITE)

	rl.EndMode2D()

	draw_inventory()

	rl.DrawText(fmt.ctprint("fps:", fps), 10, h - 30, 20, rl.RED)
	rl.DrawText(fmt.ctprint("dt:", dt), 10, h - 50, 20, rl.RED)
	rl.EndDrawing()
}

to_tile_coords :: proc(world_x: f32, world_y: f32) -> (int, int) {
	tile_size := f32(tex_size) * tex_scale
	return int(world_x / tile_size), int(world_y / tile_size)
}
