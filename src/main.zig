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

const Modifier = enum {
    normal,
    hidden,
    forbidden,
    reverse,
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

    //  randomize arrow sequence
    var arrow_sequence = randomArrowSequence();

    var arrow_index: usize = 0;
    const arrow_duration: f32 = 3.0;
    var arrow_timer: f32 = 0.0;
    var misses: i32 = 0;
    const total_rounds: i32 = 3;
    var current_round: i32 = 1;
    const hidden_chance_percent: i32 = 25;
    const forbidden_chance_percent: i32 = 25;
    const reverse_chance_percent: i32 = 25;
    var hidden_positions = randomMarkedPositions();
    var forbidden_positions = randomMarkedPositions();
    var reverse_positions = randomMarkedPositions();

    var round_modifier = chooseModifier(hidden_chance_percent, forbidden_chance_percent, reverse_chance_percent);

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
                var missed_this_frame = false;
                var start_new_sequence = false;

                if (arrow_timer >= arrow_duration) {
                    missed_this_frame = true;
                    game_state = GameState.waiting;
                } else {
                    while (round_modifier == Modifier.forbidden and
                        arrow_index < arrow_sequence.len and
                        forbidden_positions[arrow_index])
                    {
                        arrow_index += 1;
                    }

                    if (arrow_index < arrow_sequence.len) {
                        const expected_direction = arrow_sequence[arrow_index];

                        const is_reversed = round_modifier == Modifier.reverse and reverse_positions[arrow_index];

                        const expected_key: rl.KeyboardKey =
                            if (is_reversed)
                                switch (expected_direction) {
                                    Direction.left => rl.KeyboardKey.right,
                                    Direction.right => rl.KeyboardKey.left,
                                    Direction.up => rl.KeyboardKey.down,
                                    Direction.down => rl.KeyboardKey.up,
                                }
                            else switch (expected_direction) {
                                Direction.left => rl.KeyboardKey.left,
                                Direction.right => rl.KeyboardKey.right,
                                Direction.up => rl.KeyboardKey.up,
                                Direction.down => rl.KeyboardKey.down,
                            };

                        const pressed_key = rl.getKeyPressed();
                        switch (pressed_key) {
                            rl.KeyboardKey.left, rl.KeyboardKey.up, rl.KeyboardKey.right, rl.KeyboardKey.down => {
                                if (pressed_key == expected_key) {
                                    arrow_index += 1;
                                } else {
                                    missed_this_frame = true;
                                }
                            },
                            else => {},
                        }
                    }

                    if (arrow_index == arrow_sequence.len) {
                        if (current_round < total_rounds) {
                            current_round += 1;
                            round_modifier = chooseModifier(hidden_chance_percent, forbidden_chance_percent, reverse_chance_percent);
                            start_new_sequence = true;
                        } else {
                            game_state = GameState.caught;
                        }
                    }
                }

                if (missed_this_frame) {
                    misses += 1;
                    if (misses >= max_misses) {
                        game_state = GameState.escaped;
                    } else {
                        start_new_sequence = true;
                    }
                }

                if (start_new_sequence) {
                    arrow_index = 0;
                    arrow_timer = 0.0;
                    arrow_sequence = randomArrowSequence();
                    hidden_positions = randomMarkedPositions();
                    forbidden_positions = randomMarkedPositions();
                    reverse_positions = randomMarkedPositions();
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
                    const hide_arrow =
                        round_modifier == Modifier.hidden and
                        arrow_timer >= 1.0 and
                        hidden_positions[index];

                    const forbid_arrow =
                        round_modifier == Modifier.forbidden and
                        forbidden_positions[index];

                    const reverse_arrow =
                        round_modifier == Modifier.reverse and
                        reverse_positions[index];

                    const symbol: [:0]const u8 =
                        if (forbid_arrow)
                            "X"
                        else if (hide_arrow)
                            "?"
                        else if (reverse_arrow)
                            switch (direction) {
                                Direction.left => "<!",
                                Direction.up => "^!",
                                Direction.right => ">!",
                                Direction.down => "v!",
                            }
                        else switch (direction) {
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

fn chooseModifier(hidden_chance: i32, forbidden_chance: i32, reverse_chance: i32) Modifier {
    const roll = rl.getRandomValue(1, 100);

    if (roll <= hidden_chance) return Modifier.hidden;
    if (roll <= hidden_chance + forbidden_chance) return Modifier.forbidden;
    if (roll <= hidden_chance + forbidden_chance + reverse_chance) return Modifier.reverse;
    return Modifier.normal;
}

fn randomArrowSequence() [4]Direction {
    var sequence = [_]Direction{ Direction.left, Direction.up, Direction.right, Direction.down };

    for (0..sequence.len) |index| {
        const random_index: usize = @intCast(
            rl.getRandomValue(@intCast(index), 3),
        );
        const temp = sequence[index];
        sequence[index] = sequence[random_index];
        sequence[random_index] = temp;
    }

    return sequence;
}

fn randomMarkedPositions() [4]bool {
    var positions = [_]bool{false} ** 4;
    const count = rl.getRandomValue(1, 2);
    var selected: i32 = 0;

    while (selected < count) {
        const index: usize = @intCast(rl.getRandomValue(0, 3));

        if (!positions[index]) {
            positions[index] = true;
            selected += 1;
        }
    }

    return positions;
}
