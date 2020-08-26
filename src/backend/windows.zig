// Copyright (c) 2020 John Namgung.

// SPDX-License-Identifier: MIT
// This file is part of the `termcon` project under the MIT license.

pub const config = @import("unimplemented/config.zig");
pub const cursor = @import("unimplemented/cursor.zig");
pub const screen = @import("unimplemented/screen.zig");
pub const event = @import("unimplemented/event.zig");

const termcon = @import("../termcon.zig");
pub const SupportedFeatures = termcon.SupportedFeatures;

pub fn init() !SupportedFeatures {
    @compileError("Unimplemented Windows backend");
}

pub fn deinit() void {
    @compileError("Unimplemented");
}
