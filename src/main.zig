const std = @import("std");
const rl = @import("raylib");
const allocator = std.heap.page_allocator;
const screenWidth = 1920;
const screenHeight = 1120;
var sound_error: rl.Sound = undefined;
var font: rl.Font = undefined;

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "Show do Cristão");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var background_img = rl.Image.init("resources/painel_simples.png");
    background_img.resize(screenWidth, screenHeight);
    const background = rl.loadTextureFromImage(background_img);
    var last_letter: ?rl.KeyboardKey = null;

    rl.initAudioDevice();
    defer rl.closeAudioDevice();
    sound_error = rl.loadSound("resources/error.wav");
    rl.setSoundVolume(sound_error, 5);

    font = rl.loadFontEx("resources/fradm.ttf", 60, null);
    defer font.unload();

    const term = getRandomTerm();
    var msg: [80:0]u8 = undefined;
    rl.traceLog(rl.TraceLogLevel.log_info, try std.fmt.bufPrintZ(&msg, "Dica: {s}", .{term.tip}));

    var panel = try Panel.init();

    try panel.setSecretWord(term.word);

    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        const letter_pressed = getLetterPressed();
        if (letter_pressed != last_letter) {
            if (letter_pressed) |l| panel.testLetter(l);
            last_letter = letter_pressed;
        }

        if (rl.isKeyPressed(.key_enter)) {
            panel.resetFailedLetters();
            const myterm = getRandomTerm();
            var mymsg: [80:0]u8 = undefined;
            rl.traceLog(rl.TraceLogLevel.log_info, try std.fmt.bufPrintZ(&mymsg, "Dica: {s}", .{myterm.tip}));
            try panel.setSecretWord(myterm.word);
        }

        if (rl.isKeyPressed(.key_f11))
            rl.toggleFullscreen();

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
    last_failed_letter: usize = 0,
    failed_letters: [26]u8 = [_]u8{0} ** 26,

    const failed_letters_postions: []const [2]f32 = &[_][2]f32{
        [2]f32{ 0.441, 0.086 },
        [2]f32{ 0.480, 0.086 },
        [2]f32{ 0.518, 0.086 },
        [2]f32{ 0.553, 0.086 },
        [2]f32{ 0.401, 0.143 },
        [2]f32{ 0.425, 0.143 },
        [2]f32{ 0.446, 0.143 },
        [2]f32{ 0.470, 0.143 },
        [2]f32{ 0.499, 0.143 },
        [2]f32{ 0.524, 0.143 },
        [2]f32{ 0.554, 0.143 },
        [2]f32{ 0.574, 0.143 },
        [2]f32{ 0.595, 0.143 },
        [2]f32{ 0.414, 0.188 },
        [2]f32{ 0.440, 0.188 },
        [2]f32{ 0.468, 0.188 },
        [2]f32{ 0.500, 0.188 },
        [2]f32{ 0.525, 0.188 },
        [2]f32{ 0.554, 0.188 },
        [2]f32{ 0.582, 0.188 },
        [2]f32{ 0.463, 0.235 },
        [2]f32{ 0.497, 0.235 },
        [2]f32{ 0.528, 0.235 },
    };

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

        for (0..self.last_failed_letter) |i| {
            if (self.failed_letters[i] == 0) @panic("failed_letters[i] == 0");
            rl.drawTextEx(
                font,
                &[_:0]u8{self.failed_letters[i]},
                .{
                    .x = failed_letters_postions[i][0] * screenWidth,
                    .y = failed_letters_postions[i][1] * screenHeight,
                },
                45,
                3.0,
                rl.Color.white,
            );
        }
    }

    pub fn resetFailedLetters(self: *Panel) void {
        for (0..self.failed_letters.len) |i| {
            self.failed_letters[i] = 0;
        }
        self.last_failed_letter = 0;
    }

    pub fn setSecretWord(self: *Panel, word: []const u8) !void {
        for (0..self.cards_line2.len) |i| {
            self.cards_line2.cards[i].revealed = false;
        }

        var buf: [15]u8 = undefined;
        const upper_case_word = std.ascii.upperString(&buf, word);
        if (upper_case_word.len > self.cards_line2.len) return error.PalavraMuitoGrande;
        for (0..upper_case_word.len) |i| {
            if (upper_case_word[i] == ' ') {
                self.cards_line2.cards[i].color = Card.color_off;
                self.cards_line2.cards[i].secret_letter = ' ';
            }
            self.cards_line2.cards[i].color = Card.color_on;
            self.cards_line2.cards[i].secret_letter = upper_case_word[i];
        }
        for (upper_case_word.len..self.cards_line2.len) |i| {
            self.cards_line2.cards[i].color = Card.color_off;
            self.cards_line2.cards[i].secret_letter = null;
        }
    }

    pub fn testLetter(self: *Panel, letter: rl.KeyboardKey) void {
        const letter_u8 = @as(u8, @intCast(@intFromEnum(letter)));
        var found = false;
        for (&self.cards_line2.cards) |*card| {
            if (card.secret_letter != null and card.secret_letter.? == letter_u8) {
                card.revealed = true;
                found = true;
            }
        }
        block: {
            if (!found) {
                rl.playSound(sound_error);
                for (self.failed_letters) |l| {
                    if (l == letter_u8) break :block;
                }
                self.failed_letters[self.last_failed_letter] = letter_u8;
                self.last_failed_letter += 1;
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
                    rl.drawTextEx(
                        font,
                        &[_:0]u8{letter_u8},
                        .{
                            .x = screenWidth * (card.x + Card.width * 0.3),
                            .y = screenHeight * (card.y + Card.height * 0.3),
                        },
                        60,
                        3.0,
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

fn getRandomTerm() struct { tip: []const u8, word: []const u8 } {
    const file_content = @embedFile("biblical_terms.csv");
    const line_count = std.mem.count(u8, file_content, "\n");
    var rand = std.rand.DefaultPrng.init(@intCast(std.time.milliTimestamp()));
    const lottery = @rem(rand.next(), line_count);
    var lines = std.mem.splitAny(u8, file_content, "\r\n");
    for (0..lottery) |_|
        _ = lines.next();
    var line = std.mem.splitAny(u8, lines.next().?, ",");
    const term = line.next().?;
    const tip = line.next().?;
    return .{ .tip = tip, .word = term };
}
