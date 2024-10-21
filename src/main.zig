const std = @import("std");
const rl = @import("raylib");
const card_color_off = rl.Color.init(1, 24, 147, 255);
const card_color_on = rl.Color.white;
const allocator = std.heap.page_allocator;
const screenWidth = 1280;
const screenHeight = 720;
const rect_width = 0.0470;
const rect_height = 0.112;

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "Roda a Roda");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var background_img = rl.Image.init("resources/painel_simples.png");
    background_img.resize(screenWidth, screenHeight);
    const background = rl.loadTextureFromImage(background_img);
    var last_letter: ?rl.KeyboardKey = null;

    var cards_line1 = try CardLine.init(0.2025, 0.391, 12);
    defer cards_line1.deinit();
    var cards_line2 = try CardLine.init(0.153, 0.506, 14);
    defer cards_line2.deinit();
    var cards_line3 = try CardLine.init(0.153, 0.623, 14);
    defer cards_line3.deinit();
    var cards_line4 = try CardLine.init(0.2025, 0.739, 12);
    defer cards_line4.deinit();

    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        last_letter = getLetterPressed() orelse last_letter;
        if (rl.isMouseButtonPressed(.mouse_button_left)) {
            const posX = @as(f32, @floatFromInt(rl.getMouseX())) / screenWidth;
            const posY = @as(f32, @floatFromInt(rl.getMouseY())) / screenHeight;
            var buf: [80:0]u8 = undefined;
            rl.traceLog(
                rl.TraceLogLevel.log_info,
                try std.fmt.bufPrintZ(&buf, "Mouse: {d:.3}, {d:.3}", .{ posX, posY }),
            );
        }

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawTexture(background, 0, 0, rl.Color.white);

        cards_line1.draw();
        cards_line2.draw();
        cards_line3.draw();
        cards_line4.draw();

        if (last_letter) |letter| {
            const letter_u8: u8 = @intCast(@intFromEnum(letter));
            rl.drawText(&[_:0]u8{letter_u8}, @intFromFloat(screenWidth * 0.27), @intFromFloat(screenHeight * 0.54), 40, rl.Color.black);
        }
    }
}

const Card = struct {
    color: rl.Color = card_color_off,
    x: f32, // normalized: 0 to 1
    y: f32, // normalized: 0 to 1
};

const CardLine = struct {
    cards: std.ArrayList(Card),

    pub fn init(x: f32, y: f32, count: usize) !CardLine {
        var res = CardLine{ .cards = std.ArrayList(Card).init(allocator) };
        try res.cards.resize(count);
        for (0..count) |i| {
            const fi: f32 = @floatFromInt(i);
            try res.cards.append(.{ .x = x + fi * 0.04956, .y = y });
        }
        return res;
    }

    pub fn deinit(self: *CardLine) void {
        self.cards.deinit();
    }

    pub fn draw(self: CardLine) void {
        for (self.cards.items) |card| {
            rl.drawRectangle(
                @intFromFloat(card.x * screenWidth),
                @intFromFloat(card.y * screenHeight),
                @intFromFloat(rect_width * screenWidth),
                @intFromFloat(rect_height * screenHeight),
                card.color,
            );
        }
    }
};

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
