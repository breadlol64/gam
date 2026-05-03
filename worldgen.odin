package main
import "core:math/noise"

gen_world :: proc(seed: i64) {
	for layer in 0..<2 {
		tile_map[layer] = make(map[[2]int]int)
	}

	for y in 0 ..= 64 {
		for x in 0 ..= 64 {
			scale := 0.05
			value := noise.noise_2d(seed, {f64(x) * scale, f64(y) * scale})

			t: string
			if value < -0.4 {
				t = "water"
			} else if value < 0.0 {
				t = "sand"
			} else if value < 0.8 {
				t = "grass"
			} else {
				t = "grass"
				append(&world[1], Tile{i32(x), i32(y), "tree"})
				tile_map[1][{x, y}] = len(world[1]) - 1
			}

			append(&world[0], Tile{i32(x), i32(y), t})
			tile_map[0][{x, y}] = len(world[0]) - 1
		}
	}
}

get_tile :: proc(layer: int, x: int, y: int) -> (^Tile, bool) {
    if idx, ok := tile_map[layer][{x, y}]; ok {
        return &world[layer][idx], true
    }
    return nil, false
}
