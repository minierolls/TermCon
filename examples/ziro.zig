// Copyright (c) 2020 John Namgung.

// SPDX-License-Identifier: MIT
// This file is part of the `termcon` project under the MIT license.

//! Ziro is a super-simple terminal text editor written in Zig.
//! Ziro is inspired by [kilo](https://github.com/antirez/kilo),
//! and is intended to provide an example of using the `termcon`
//! library.
//!
//! BUILDING
//! From the examples directory: zig build-exe ziro.zig --main-pkg-path ../

const std = @import("std");

const termcon = @import("../src/termcon.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const options = termcon.Options{
        .raw_mode = true,
        .alternate_screen = true,
        .use_handler = true,
    };

    var tcon = try termcon.TermCon.init(&gpa.allocator, options);
    defer _ = tcon.deinit();

    // var cpos = try tcon.screen.cursor.getPosition();
    // std.debug.warn("cpos: x:{} y:{}", .{cpos.col, cpos.row});

    try tcon.screen.setCell(termcon.view.Position{ .row = 0, .col = 0 }, termcon.view.Cell { .rune = 'X', .style = tcon.screen.getDefaultStyle() });
}
