const rl = @import("raylib");

const GameState = enum {
    idle,
    casting,
    waiting,
    bite,
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

const Behavior = enum {
    calm,
    burst,
    heavy,
    erratic,
};

const Rarity = enum {
    common,
    uncommon,
    rare,
    epic,
    legendary,
};

const Fish = struct {
    name: [:0]const u8,
    rarity: Rarity,
    behavior: Behavior,
    rounds: i32,
    time_limit: f32,
    arrow_count: usize,
    hidden_chance_percent: i32,
    forbidden_chance_percent: i32 = 0,
    reverse_chance_percent: i32 = 0,
};

const bluegill = Fish{
    .name = "Bluegill",
    .rarity = Rarity.common,
    .behavior = Behavior.calm,
    .rounds = 2,
    .arrow_count = 3,
    .time_limit = 3.0,
    .hidden_chance_percent = 0,
};

const carp = Fish{
    .name = "Carp",
    .rarity = Rarity.uncommon,
    .behavior = Behavior.burst,
    .rounds = 3,
    .arrow_count = 4,
    .time_limit = 3.0,
    .hidden_chance_percent = 30,
};

const catfish = Fish{
    .name = "Catfish",
    .rarity = Rarity.uncommon,
    .behavior = Behavior.heavy,
    .rounds = 5,
    .arrow_count = 4,
    .time_limit = 3.5,
    .hidden_chance_percent = 0,
};

pub fn main() !void {
    rl.initWindow(960, 540, "My Life Fishing Simulator");
    defer rl.closeWindow();

    const player_texture = try rl.loadTexture("assets/sprites/angler-walk.png");
    defer rl.unloadTexture(player_texture);

    rl.setTargetFPS(60);

    const water = rl.Rectangle{
        .x = 0,
        .y = 220,
        .width = 960,
        .height = 320,
    };

    var player = rl.Rectangle{
        .x = 480,
        .y = 150,
        .width = 24,
        .height = 32,
    };

    var camera = rl.Camera2D{
        .offset = .{ .x = 480, .y = 270 },
        .target = .{ .x = player.x, .y = player.y },
        .rotation = 0,
        .zoom = 1,
    };

    const player_speed: f32 = 180.0;
    var facing: Direction = .down;
    var walk_frame: usize = 0;
    var walk_timer: f32 = 0.0;

    //  randomize arrow sequence
    var arrow_sequence = randomArrowSequence();

    var game_state: GameState = GameState.idle;
    var wait_timer: f32 = 0.0;
    var wait_duration: f32 = 2.0;
    var bite_timer: f32 = 0.0;
    const bite_duration: f32 = 0.8;
    const max_misses: i32 = 3;
    var arrow_index: usize = 0;
    var arrow_timer: f32 = 0.0;
    var misses: i32 = 0;
    var current_round: i32 = 1;
    var cast_timer: f32 = 0.0;
    const cast_duration: f32 = 0.5;
    var hidden_positions = randomMarkedPositions();
    var forbidden_positions = randomMarkedPositions();
    var reverse_positions = randomMarkedPositions();

    const fish = catfish;
    var arrow_duration: f32 = fish.time_limit;
    const total_rounds: i32 = fish.rounds;
    const hidden_chance_percent: i32 = fish.hidden_chance_percent;
    const forbidden_chance_percent: i32 = fish.forbidden_chance_percent;
    const reverse_chance_percent: i32 = fish.reverse_chance_percent;
    var round_modifier = chooseModifier(hidden_chance_percent, forbidden_chance_percent, reverse_chance_percent);

    while (!rl.windowShouldClose()) {
        var walking = false;

        // update game state
        switch (game_state) {
            GameState.idle => {
                const distance = player_speed * rl.getFrameTime();
                walking =
                    rl.isKeyDown(rl.KeyboardKey.w) or
                    rl.isKeyDown(rl.KeyboardKey.s) or
                    rl.isKeyDown(rl.KeyboardKey.a) or
                    rl.isKeyDown(rl.KeyboardKey.d);

                if (rl.isKeyDown(rl.KeyboardKey.w)) {
                    player.y -= distance;
                    facing = .up;
                }
                if (rl.isKeyDown(rl.KeyboardKey.s)) {
                    player.y += distance;
                    facing = .down;
                }
                if (rl.isKeyDown(rl.KeyboardKey.a)) {
                    player.x -= distance;
                    facing = .left;
                }
                if (rl.isKeyDown(rl.KeyboardKey.d)) {
                    player.x += distance;
                    facing = .right;
                }

                if (rl.isKeyPressed(rl.KeyboardKey.space)) {
                    game_state = GameState.casting;
                    cast_timer = 0.0;
                }
            },
            GameState.casting => {
                cast_timer += rl.getFrameTime();
                if (cast_timer >= cast_duration) {
                    wait_duration = @floatFromInt(rl.getRandomValue(2, 4));
                    wait_timer = 0.0;
                    game_state = GameState.waiting;
                }
            },
            GameState.waiting => {
                wait_timer += rl.getFrameTime();
                if (wait_timer >= wait_duration) {
                    game_state = GameState.bite;
                    bite_timer = 0.0;
                }
            },
            GameState.bite => {
                bite_timer += rl.getFrameTime();
                if (bite_timer >= bite_duration) {
                    current_round = 1;
                    misses = 0;
                    arrow_index = 0;
                    arrow_timer = 0.0;
                    arrow_duration = fish.time_limit;

                    arrow_sequence = randomArrowSequence();
                    hidden_positions = randomMarkedPositions();
                    forbidden_positions = randomMarkedPositions();
                    reverse_positions = randomMarkedPositions();
                    round_modifier = chooseModifier(
                        hidden_chance_percent,
                        forbidden_chance_percent,
                        reverse_chance_percent,
                    );

                    game_state = GameState.arrows;
                }
            },
            GameState.arrows => {
                arrow_timer += rl.getFrameTime();
                var missed_this_frame = false;
                var start_new_sequence = false;

                if (arrow_timer >= arrow_duration) {
                    missed_this_frame = true;
                } else {
                    while (round_modifier == Modifier.forbidden and
                        arrow_index < fish.arrow_count and
                        forbidden_positions[arrow_index])
                    {
                        arrow_index += 1;
                    }

                    if (arrow_index < fish.arrow_count) {
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

                    if (arrow_index == fish.arrow_count) {
                        if (current_round < total_rounds) {
                            current_round += 1;
                            if (fish.behavior == Behavior.burst) {
                                arrow_duration = if (current_round == 2)
                                    fish.time_limit * 0.7
                                else
                                    fish.time_limit * 1.3;
                            }
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
            GameState.caught => {
                if (rl.isKeyPressed(rl.KeyboardKey.space)) {
                    game_state = GameState.idle;
                }
            },
            GameState.escaped => {
                if (rl.isKeyPressed(rl.KeyboardKey.space)) {
                    game_state = GameState.idle;
                }
            },
        }

        if (walking) {
            if (walk_frame == 0) walk_frame = 1;
            walk_timer += rl.getFrameTime();
            if (walk_timer >= 0.15) {
                walk_timer -= 0.15;
                walk_frame = if (walk_frame == 8) 1 else walk_frame + 1;
            }
        } else {
            walk_timer = 0.0;
            walk_frame = 0;
        }

        camera.target = .{
            .x = player.x + player.width / 2,
            .y = player.y + player.height / 2,
        };

        rl.beginDrawing();
        rl.clearBackground(rl.Color.ray_white);

        rl.beginMode2D(camera);
        rl.drawRectangleRec(water, rl.Color.sky_blue);

        const column: f32 = switch (facing) {
            Direction.down => 0,
            Direction.left => 1,
            Direction.right => 2,
            Direction.up => 3,
        };

        const frame_width: f32 = 64.0;
        const frame_height: f32 = 64.0;

        const source = rl.Rectangle{
            .x = column * frame_width,
            .y = @as(f32, @floatFromInt(walk_frame)) * frame_height,
            .width = frame_width,
            .height = frame_height,
        };

        const destination = rl.Rectangle{
            .x = @round(player.x - 24),
            .y = @round(player.y - 58),
            .width = 72,
            .height = 96,
        };

        rl.drawTexturePro(
            player_texture,
            source,
            destination,
            .{ .x = 0, .y = 0 },
            0,
            .white,
        );

        rl.endMode2D();

        // draw game state
        switch (game_state) {
            GameState.idle => rl.drawText(
                "Press Space to fish",
                320,
                80,
                28,
                .dark_gray,
            ),
            GameState.casting => rl.drawText(
                "Casting...",
                390,
                80,
                28,
                .dark_gray,
            ),
            GameState.bite => rl.drawText(
                "BITE!",
                420,
                80,
                36,
                .red,
            ),
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
                for (arrow_sequence[0..fish.arrow_count], 0..) |direction, index| {
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
                rl.drawText(fish.name, 30, 70, 24, .dark_gray);
                if (misses > 0) {
                    rl.drawText("Miss!", 30, 30, 24, .red);
                }
            },
            GameState.caught => {
                rl.drawText("Fish caught!", 380, 80, 28, .gold);
                rl.drawText(fish.name, 380, 120, 24, .dark_gray);
                rl.drawText("Press Space to fish again", 300, 170, 24, .dark_gray);
            },
            GameState.escaped => {
                rl.drawText("Fish escaped!", 370, 80, 28, .red);
                rl.drawText("Press Space to fish again", 300, 140, 24, .dark_gray);
            },
        }

        rl.endDrawing();
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
