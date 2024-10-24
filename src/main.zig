const std = @import("std");
const rl = @import("raylib");
const allocator = std.heap.page_allocator;
const screenWidth = 1280;
const screenHeight = 720;

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "Roda a Roda");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var background_img = rl.Image.init("resources/painel_simples.png");
    background_img.resize(screenWidth, screenHeight);
    const background = rl.loadTextureFromImage(background_img);
    var last_letter: ?rl.KeyboardKey = null;

    var panel = try Panel.init();

    try panel.setSecretWord("rei davi");

    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        const letter_pressed = getLetterPressed();
        if (letter_pressed != last_letter) {
            if (letter_pressed) |l| panel.revealLetter(l);
            last_letter = letter_pressed;
        }

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

        panel.draw();
    }
}

const Panel = struct {
    cards_line1: CardLine,
    cards_line2: CardLine,
    cards_line3: CardLine,
    cards_line4: CardLine,

    pub fn init() !Panel {
        return .{
            .cards_line1 = try CardLine.init(0.2025, 0.391, 12),
            .cards_line2 = try CardLine.init(0.153, 0.506, 14),
            .cards_line3 = try CardLine.init(0.153, 0.623, 14),
            .cards_line4 = try CardLine.init(0.2025, 0.739, 12),
        };
    }

    pub fn draw(self: *Panel) void {
        self.cards_line1.draw();
        self.cards_line2.draw();
        self.cards_line3.draw();
        self.cards_line4.draw();
    }

    pub fn setSecretWord(self: *Panel, word: []const u8) !void {
        var buf: [15]u8 = undefined;
        const upper_case_word = std.ascii.upperString(&buf, word);
        if (upper_case_word.len > self.cards_line2.len) return error.PalavraMuitoGrande;
        for (0..upper_case_word.len) |i| {
            if (upper_case_word[i] == ' ') continue;
            self.cards_line2.cards[i].color = Card.color_on;
            self.cards_line2.cards[i].secret_letter = upper_case_word[i];
        }
    }

    pub fn revealLetter(self: *Panel, letter: rl.KeyboardKey) void {
        for (&self.cards_line2.cards) |*card| {
            if (card.secret_letter != null and card.secret_letter.? == @intFromEnum(letter)) {
                card.revealed = true;
            }
        }
    }

    const Card = struct {
        revealed: bool = false,
        secret_letter: ?u8 = null,
        color: rl.Color,
        x: f32, // normalized: 0 to 1
        y: f32, // normalized: 0 to 1

        const color_off = rl.Color.init(1, 24, 147, 255);
        const color_on = rl.Color.white;
        const width = 0.0470;
        const height = 0.112;
    };

    const CardLine = struct {
        cards: [14]Card,
        len: usize = 0,

        pub fn init(x: f32, y: f32, count: usize) !CardLine {
            var res = CardLine{ .cards = [1]Card{.{ .x = 0, .y = 0, .color = rl.Color.red }} ** 14, .len = count };
            for (0..count) |i| {
                const fi: f32 = @floatFromInt(i);
                res.cards[i] = .{ .x = x + fi * 0.04956, .y = y, .color = Card.color_off };
            }
            return res;
        }

        pub fn draw(self: CardLine) void {
            for (0..self.len) |i| {
                const card = self.cards[i];
                rl.drawRectangle(
                    @intFromFloat(card.x * screenWidth),
                    @intFromFloat(card.y * screenHeight),
                    @intFromFloat(Card.width * screenWidth),
                    @intFromFloat(Card.height * screenHeight),
                    card.color,
                );
                if (card.revealed) {
                    const letter_u8 = self.cards[i].secret_letter.?;
                    rl.drawText(
                        &[_:0]u8{letter_u8},
                        @intFromFloat(screenWidth * (card.x + Card.width * 0.3)),
                        @intFromFloat(screenHeight * (card.y + Card.height * 0.3)),
                        40,
                        rl.Color.black,
                    );
                }
            }
        }
    };
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
