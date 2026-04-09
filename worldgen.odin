package main
import "core:math/noise"

gen_world :: proc(seed: i64) {
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
			}

			append(&world[0], Tile{i32(x), i32(y), t})
		}
	}
}
