package main

import "core:fmt"
import "core:math/noise"
import mu "vendor:microui"
import rl "vendor:raylib"

tex_size :: 16
tex_scale :: 3.0
player_speed :: 200
zoom_speed :: 1.0

ctx: ^mu.Context

Player :: struct {
	x:         f32,
	y:         f32,
	camera:    rl.Camera2D,
	texture:   rl.Texture2D,
	inventory: [10]InventorySlot,
}

world: [2][dynamic]Tile
tile_map: [2]map[[2]int]int
player: Player

main :: proc() {
	rl.InitWindow(800, 600, "game")
	defer rl.CloseWindow()

	ctx = new(mu.Context)
	mu.init(ctx)
	ctx.text_width = proc(font: mu.Font, str: string) -> i32 {
		return rl.MeasureText(fmt.ctprint(str), 16)
	}
	ctx.text_height = proc(_font: mu.Font) -> i32 {
		return 16
	}

	load_tiles()
	load_items()
	player.x = 0
	player.y = 0
	player.camera = rl.Camera2D{{400, 300}, {f32(player.x), f32(player.y)}, 0.0, 1.0}
	player.texture = rl.LoadTexture("assets/player.png")
	player.inventory = {}

	add_item(Item{"wood"}, 35)
	add_item(Item{"wood"}, 5)
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

	if rl.IsKeyDown(.I) {
		player.camera.zoom += zoom_speed * dt
	}
	if rl.IsKeyDown(.O) {
		player.camera.zoom -= zoom_speed * dt
	}
}

update :: proc() {
	mx := rl.GetMouseX()
	my := rl.GetMouseY()
	mu.input_mouse_move(ctx, mx, my)
	if rl.IsMouseButtonDown(.LEFT) do mu.input_mouse_down(ctx, mx, my, .LEFT)
	if rl.IsMouseButtonUp(.LEFT) do mu.input_mouse_up(ctx, mx, my, .LEFT)

	player.camera.target = {player.x, player.y}
}

draw :: proc(fps: i32, dt: f32, w: i32, h: i32) {
	rl.BeginDrawing()
	rl.BeginMode2D(player.camera)
	rl.ClearBackground(rl.BLACK)

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

	rl.DrawTextureEx(player.texture, {f32(player.x), f32(player.y)}, 0.0, tex_scale, rl.WHITE)

	rl.EndMode2D()

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

	rl.DrawText(fmt.ctprint("fps:", fps), 10, h - 30, 20, rl.RED)
	rl.DrawText(fmt.ctprint("dt:", dt), 10, h - 50, 20, rl.RED)

	// mu.begin(ctx)
	// if mu.begin_window(ctx, " ", mu.Rect{10, 10, 200, 300}) {
	// 	if .SUBMIT in mu.button(ctx, "Asd") {
	// 		fmt.println("a")
	// 	}
	// 	mu.end_window(ctx)
	// }
	// mu.end(ctx)

	// render_mu(ctx)
	rl.EndDrawing()
}

mu_to_rl_color :: proc(c: mu.Color) -> rl.Color {
	return rl.Color{c.r, c.g, c.b, c.a}
}

to_tile_coords :: proc(world_x: f32, world_y: f32) -> (int, int) {
	tile_size := f32(tex_size) * tex_scale
	return int(world_x / tile_size), int(world_y / tile_size)
}
