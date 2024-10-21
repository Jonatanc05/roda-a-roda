const std = @import("std");
const rl = @import("raylib");
const allocator = std.heap.page_allocator;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1800;
    const screenHeight = 900;

    rl.initWindow(screenWidth, screenHeight, "Roda a Roda");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var background_img = rl.Image.init("resources/painel_simples_9letras.png");
    background_img.resize(screenWidth, screenHeight);
    const background = rl.loadTextureFromImage(background_img);
    var last_letter: ?rl.KeyboardKey = null;

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        last_letter = getLetterPressed() orelse last_letter;
        if (rl.isMouseButtonPressed(.mouse_button_left)) {
            var msg: [80:0]u8 = undefined;

            rl.traceLog(
                .log_info,
                try std.fmt.bufPrintZ(&msg, "Coords are {d:.3}, {d:.3}", .{
                    @as(f32, @floatFromInt(rl.getMouseX())) / screenWidth,
                    @as(f32, @floatFromInt(rl.getMouseY())) / screenHeight,
                }),
            );
        }

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawTexture(background, 0, 0, rl.Color.white);

        rl.drawRectangle(
            @intFromFloat(0.200 * screenWidth),
            @intFromFloat(0.388 * screenHeight),
            @intFromFloat(0.048 * screenWidth),
            @intFromFloat(0.113 * screenHeight),
            rl.Color.white,
        );

        if (last_letter) |letter| {
            const letter_u8: u8 = @intCast(@intFromEnum(letter));
            rl.drawText(&[_:0]u8{letter_u8}, @intFromFloat(screenWidth * 0.27), @intFromFloat(screenHeight * 0.54), 40, rl.Color.black);
        }
    }
}

fn getLetterPressed() ?rl.KeyboardKey {
    if (rl.isKeyPressed(.key_a)) return .key_a;
    if (rl.isKeyPressed(.key_b)) return .key_b;
    if (rl.isKeyPressed(.key_c)) return .key_c;
    if (rl.isKeyPressed(.key_d)) return .key_d;
    if (rl.isKeyPressed(.key_e)) return .key_e;
    if (rl.isKeyPressed(.key_f)) return .key_f;
    if (rl.isKeyPressed(.key_g)) return .key_g;
    if (rl.isKeyPressed(.key_h)) return .key_h;
    if (rl.isKeyPressed(.key_i)) return .key_i;
    if (rl.isKeyPressed(.key_j)) return .key_j;
    if (rl.isKeyPressed(.key_k)) return .key_k;
    if (rl.isKeyPressed(.key_l)) return .key_l;
    if (rl.isKeyPressed(.key_m)) return .key_m;
    if (rl.isKeyPressed(.key_n)) return .key_n;
    if (rl.isKeyPressed(.key_o)) return .key_o;
    if (rl.isKeyPressed(.key_p)) return .key_p;
    if (rl.isKeyPressed(.key_q)) return .key_q;
    if (rl.isKeyPressed(.key_r)) return .key_r;
    if (rl.isKeyPressed(.key_s)) return .key_s;
    if (rl.isKeyPressed(.key_t)) return .key_t;
    if (rl.isKeyPressed(.key_u)) return .key_u;
    if (rl.isKeyPressed(.key_v)) return .key_v;
    if (rl.isKeyPressed(.key_w)) return .key_w;
    if (rl.isKeyPressed(.key_x)) return .key_x;
    if (rl.isKeyPressed(.key_y)) return .key_y;
    if (rl.isKeyPressed(.key_z)) return .key_z;
    return null;
}
