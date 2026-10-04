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

const Facing = enum {
    down,
    down_right,
    right,
    up_right,
    up,
    up_left,
    left,
    down_left,
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
    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(1280, 720, "My Life Fishing Simulator");
    defer rl.closeWindow();

    const player_texture = try rl.loadTexture("assets/sprites/angler-ayutthaya-actions.png");
    defer rl.unloadTexture(player_texture);
    rl.setTextureFilter(player_texture, .point);

    const walk_texture = try rl.loadTexture("assets/sprites/angler-walk-arm-swing-rigid.png");
    defer rl.unloadTexture(walk_texture);
    rl.setTextureFilter(walk_texture, .point);

    const map_texture = try rl.loadTexture("assets/maps/grass-pier-style.png");
    defer rl.unloadTexture(map_texture);
    rl.setTextureFilter(map_texture, .point);
    const map_width: f32 = @as(f32, @floatFromInt(map_texture.width));
    const map_height: f32 = @as(f32, @floatFromInt(map_texture.height));

    rl.setTargetFPS(60);

    var player = rl.Rectangle{
        .x = 480,
        .y = 150,
        .width = 24,
        .height = 32,
    };

    var camera = rl.Camera2D{
        .offset = .{ .x = 640, .y = 360 },
        .target = .{ .x = player.x, .y = player.y },
        .rotation = 0,
        .zoom = 2,
    };

    var ui_camera = rl.Camera2D{
        .offset = .{ .x = 0, .y = 0 },
        .target = .{ .x = 0, .y = 0 },
        .rotation = 0,
        .zoom = 4.0 / 3.0,
    };

    const player_speed: f32 = 180.0;
    var facing: Facing = .down;
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
                var move_x: f32 = 0;
                var move_y: f32 = 0;
                if (rl.isKeyDown(.a)) move_x -= 1;
                if (rl.isKeyDown(.d)) move_x += 1;
                if (rl.isKeyDown(.w)) move_y -= 1;
                if (rl.isKeyDown(.s)) move_y += 1;

                walking = move_x != 0 or move_y != 0;
                if (walking) {
                    facing = if (move_y < 0)
                        (if (move_x < 0) .up_left else if (move_x > 0) .up_right else .up)
                    else if (move_y > 0)
                        (if (move_x < 0) .down_left else if (move_x > 0) .down_right else .down)
                    else if (move_x < 0) .left else .right;

                    const speed_scale: f32 = if (move_x != 0 and move_y != 0) 0.70710677 else 1;
                    player.x += move_x * distance * speed_scale;
                    player.y += move_y * distance * speed_scale;
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

        player.x = @max(0, @min(player.x, map_width - player.width));
        player.y = @max(0, @min(player.y, map_height - player.height));

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

        const screen_width: f32 = @floatFromInt(rl.getScreenWidth());
        const screen_height: f32 = @floatFromInt(rl.getScreenHeight());
        const half_view_width = screen_width / (2 * camera.zoom);
        const half_view_height = screen_height / (2 * camera.zoom);
        camera.offset = .{ .x = screen_width / 2, .y = screen_height / 2 };
        camera.target = .{
            .x = @max(half_view_width, @min(player.x + player.width / 2, map_width - half_view_width)),
            .y = @max(half_view_height, @min(player.y + player.height / 2, map_height - half_view_height)),
        };
        ui_camera.zoom = @min(screen_width / 960, screen_height / 540);

        rl.beginDrawing();
        rl.clearBackground(rl.Color.ray_white);

        rl.beginMode2D(camera);
        rl.drawTextureEx(map_texture, .{ .x = 0, .y = 0 }, 0, 1, .white);

        const column: f32 = switch (facing) {
            .down, .down_left, .down_right => 0,
            .left => 1,
            .right => 2,
            .up, .up_left, .up_right => 3,
        };

        const frame_width: f32 = 256.0;
        const frame_height: f32 = 256.0;

        const sprite_row: f32 = switch (game_state) {
            .idle => 0,
            .casting => 1,
            .waiting => 2,
            .bite, .arrows => 3,
            .caught => 4,
            .escaped => 0,
        };

        const is_walk_sprite = game_state == .idle and walking;
        const source = rl.Rectangle{
            .x = if (is_walk_sprite) @as(f32, @floatFromInt(walk_frame - 1)) * frame_width else column * frame_width,
            .y = if (is_walk_sprite) @as(f32, @floatFromInt(@intFromEnum(facing))) * frame_height else sprite_row * frame_height,
            .width = frame_width,
            .height = frame_height,
        };

        const destination = rl.Rectangle{
            .x = @round(player.x - 34),
            .y = @round(player.y - 42),
            .width = 92,
            .height = 92,
        };

        rl.drawTexturePro(
            if (is_walk_sprite) walk_texture else player_texture,
            source,
            destination,
            .{ .x = 0, .y = 0 },
            0,
            .white,
        );

        rl.endMode2D();

        // draw game state
        rl.beginMode2D(ui_camera);
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
        rl.endMode2D();

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
