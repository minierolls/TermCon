// Copyright (c) 2020 John Namgung, Luke I. Wilson.

// SPDX-License-Identifier: MIT
// This file is part of the `termcon` project under the MIT license.

// WINAPI defines not made in standard library as of Zig commit 84d50c892
pub extern "kernel32" fn SetConsoleMode(hConsoleHandle: windows.HANDLE, dwMode: windows.DWORD) callconv(.Stdcall) windows.BOOL;
// pub extern "kernel32" fn WriteConsoleOutputCharacter(hConsoleOutput: windows.HANDLE, lpCharacter: windows.LPCTSTR, nLength: windows.DWORD, dwWriteCoord: windows.COORD, lpNumberOfCharsWritten: windows.LPDWORD) callconv(.Stdcall) windows.BOOL;

pub const config = @import("windows/config.zig");
pub const cursor = @import("windows/cursor.zig");
pub const screen = @import("windows/screen.zig");
pub const event = @import("windows/event.zig");

const std = @import("std");
const windows = std.os.windows;

const termcon = @import("../termcon.zig");
pub const SupportedFeatures = termcon.SupportedFeatures;

pub var hConsoleOut: std.os.windows.HANDLE = undefined;
pub var hConsoleIn: std.os.windows.HANDLE = undefined;

pub fn init() !SupportedFeatures {
    hConsoleOut = try std.os.windows.GetStdHandle(std.os.windows.STD_OUTPUT_HANDLE);
    hConsoleIn = try std.os.windows.GetStdHandle(std.os.windows.STD_INPUT_HANDLE);

    var size = try screen.getSize(); // Use Windows.h to print the console window size
    std.debug.warn("{} {}\n", .{ size.cols, size.rows });

    return SupportedFeatures{ .mouse_events = true };
}

pub fn deinit() void {
    config.setRawMode(false) catch return;
}

pub fn setAlternateScreen(value: bool) !void {
    return; // TODO: implement
}
