const rl = @import("raylib");

const GameState = enum {
    waiting,
    arrows,
    caught,
    escaped,
};

const Direction = enum {
    up,
    down,
    left,
    right,
};

pub fn main() void {
    rl.initWindow(960, 540, "My Life Fishing Simulator");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var game_state: GameState = GameState.waiting;
    var wait_timer: f32 = 0.0;
    const wait_duration: f32 = 2.0;
    const max_misses: i32 = 3;

    const water = rl.Rectangle{
        .x = 0,
        .y = 220,
        .width = 960,
        .height = 320,
    };

    const directions = [_]Direction{
        Direction.left,
        Direction.up,
        Direction.right,
        Direction.down,
    };

    //  randomize arrow sequence
    var arrow_sequence: [4]Direction = undefined;
    for (&arrow_sequence) |*direction| {
        const random_index: usize = @intCast(rl.getRandomValue(0, 3));
        direction.* = directions[random_index];
    }

    var arrow_index: usize = 0;
    const arrow_duration: f32 = 3.0;
    var arrow_timer: f32 = 0.0;
    var misses: i32 = 0;
    const total_rounds: i32 = 3;
    var current_round: i32 = 1;

    while (!rl.windowShouldClose()) {
        // update game state
        switch (game_state) {
            GameState.waiting => {
                wait_timer += rl.getFrameTime();
                if (wait_timer >= wait_duration) {
                    game_state = GameState.arrows;
                    wait_timer = 0.0;
                    arrow_timer = 0.0;
                }
            },
            GameState.arrows => {
                arrow_timer += rl.getFrameTime();

                if (arrow_timer >= arrow_duration) {
                    misses += 1;
                    arrow_timer = 0.0;
                    arrow_index = 0;
                    game_state = .waiting;
                } else {
                    const expected_direction = arrow_sequence[arrow_index];

                    const expected_key: rl.KeyboardKey = switch (expected_direction) {
                        Direction.left => rl.KeyboardKey.left,
                        Direction.up => rl.KeyboardKey.up,
                        Direction.right => rl.KeyboardKey.right,
                        Direction.down => rl.KeyboardKey.down,
                    };

                    const pressed_key = rl.getKeyPressed();
                    switch (pressed_key) {
                        rl.KeyboardKey.left, rl.KeyboardKey.up, rl.KeyboardKey.right, rl.KeyboardKey.down => {
                            if (pressed_key == expected_key) {
                                arrow_index += 1;

                                if (arrow_index == arrow_sequence.len) {
                                    arrow_index = 0;
                                    arrow_timer = 0.0;
                                    if (current_round < total_rounds) {
                                        current_round += 1;
                                    } else {
                                        game_state = GameState.caught;
                                    }
                                }
                            } else {
                                misses += 1;
                            }
                        },
                        else => {},
                    }
                }
                if (misses >= max_misses) {
                    game_state = GameState.escaped;
                }
            },
            GameState.caught, GameState.escaped => {},
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);
        rl.drawRectangleRec(water, rl.Color.sky_blue);

        // draw game state
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

                for (arrow_sequence, 0..) |direction, index| {
                    const symbol: [:0]const u8 = switch (direction) {
                        Direction.left => "<",
                        Direction.up => "^",
                        Direction.right => ">",
                        Direction.down => "v",
                    };

                    const x: i32 = 365 + @as(i32, @intCast(index)) * 70;

                    rl.drawText(
                        symbol,
                        x,
                        140,
                        48,
                        .black,
                    );
                }

                rl.drawRectangle(280, 210, 400, 24, .light_gray);
                rl.drawRectangle(280, 210, bar_width, 24, .green);
                if (misses > 0) {
                    rl.drawText("Miss!", 30, 30, 24, .red);
                }
            },
            GameState.caught => rl.drawText("Fish caught!", 380, 80, 28, .gold),
            GameState.escaped => rl.drawText("Fish escaped!", 370, 80, 28, .red),
        }
    }
}
