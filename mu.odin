package main
import "core:fmt"
import mu "vendor:microui"
import rl "vendor:raylib"

render_mu :: proc(ctx: ^mu.Context) {
	cmd: ^mu.Command
	for mu.next_command(ctx, &cmd) {
		#partial switch variant in cmd.variant {
		case ^mu.Command_Text:
			rl.DrawText(
				fmt.ctprint(variant.str),
				variant.pos.x,
				variant.pos.y,
				10,
				mu_to_rl_color(variant.color),
			)
		case ^mu.Command_Rect:
			rl.DrawRectangle(
				variant.rect.x,
				variant.rect.y,
				variant.rect.w,
				variant.rect.h,
				mu_to_rl_color(variant.color),
			)
		}
	}
}
