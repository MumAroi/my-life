const rl = @import("raylib");

const GameState = enum {
    waiting,
    arrows,
    timing,
    result,
};

pub fn main() void {
    rl.initWindow(960, 540, "My Life Fishing Simulator");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var game_state: GameState = .waiting;
    var wait_timer: f32 = 0.0;
    const wait_duration: f32 = 2.0;

    const water = rl.Rectangle{
        .x = 0,
        .y = 220,
        .width = 960,
        .height = 320,
    };

    const arrow_sequence = [_]rl.KeyboardKey{
        rl.KeyboardKey.left,
        rl.KeyboardKey.up,
        rl.KeyboardKey.right,
        rl.KeyboardKey.down,
    };

    var arrow_index: usize = 0;
    const arrow_duration: f32 = 3.0;
    var arrow_timer: f32 = 0.0;
    var misses: u8 = 0;

    while (!rl.windowShouldClose()) {
        if (game_state == GameState.waiting) {
            wait_timer += rl.getFrameTime();
            if (wait_timer >= wait_duration) {
                game_state = GameState.arrows;
                wait_timer = 0.0;
                arrow_timer = 0.0;
            }
        }

        if (game_state == GameState.arrows) {
            arrow_timer += rl.getFrameTime();

            if (arrow_timer >= arrow_duration) {
                misses += 1;
                arrow_timer = 0.0;
                arrow_index = 0;
                game_state = .waiting;
            } else {
                const expected_key = arrow_sequence[arrow_index];

                if (rl.isKeyPressed(expected_key)) {
                    arrow_index += 1;

                    if (arrow_index == arrow_sequence.len) {
                        arrow_index = 0;
                        arrow_timer = 0.0;
                        game_state = .timing;
                    }
                }
            }
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);
        rl.drawRectangleRec(water, rl.Color.sky_blue);

        switch (game_state) {
            GameState.waiting => rl.drawText(
                "Waiting for a fish...",
                320,
                80,
                28,
                rl.Color.dark_gray,
            ),
            GameState.arrows => {
                const time_left = 1.0 - (arrow_timer / arrow_duration);
                const bar_width: i32 = @intFromFloat(400.0 * time_left);

                rl.drawText(
                    "Press the arrows in order!",
                    300,
                    80,
                    28,
                    .dark_green,
                );

                rl.drawText(
                    "<  ^  >  v",
                    365,
                    140,
                    48,
                    .black,
                );

                rl.drawRectangle(280, 210, 400, 24, .light_gray);
                rl.drawRectangle(280, 210, bar_width, 24, .green);
                if (misses > 0) {
                    rl.drawText("Miss!", 30, 30, 24, .red);
                }
            },
            GameState.timing => rl.drawText(
                "Press Space at the right time!",
                260,
                80,
                28,
                rl.Color.orange,
            ),
            GameState.result => rl.drawText(
                "Fish caught!",
                380,
                80,
                28,
                rl.Color.gold,
            ),
        }
    }
}
