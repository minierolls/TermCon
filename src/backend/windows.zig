// Copyright (c) 2020 John Namgung, Luke I. Wilson.

// SPDX-License-Identifier: MIT
// This file is part of the `termcon` project under the MIT license.

// WINAPI defines not made in standard library as of Zig commit 84d50c892
pub extern "kernel32" fn SetConsoleMode(hConsoleHandle: windows.HANDLE, dwMode: windows.DWORD) callconv(.Stdcall) windows.BOOL;
pub extern "kernel32" fn SetConsoleActiveScreenBuffer(hConsoleOutput: windows.HANDLE) callconv(.Stdcall) windows.BOOL;
pub extern "kernel32" fn CreateConsoleScreenBuffer(dwDesiredAccess: windows.DWORD, dwShareMode: windows.DWORD, lpSecurityAttributes: ?*const windows.SECURITY_ATTRIBUTES, dwFlags: windows.DWORD, lpScrenBufferData: ?windows.LPVOID) callconv(.Stdcall) windows.HANDLE;
// pub extern "kernel32" fn WriteConsoleOutputCharacter(hConsoleOutput: windows.HANDLE, lpCharacter: windows.LPCTSTR, nLength: windows.DWORD, dwWriteCoord: windows.COORD, lpNumberOfCharsWritten: windows.LPDWORD) callconv(.Stdcall) windows.BOOL;

pub const config = @import("windows/config.zig");
pub const cursor = @import("windows/cursor.zig");
pub const screen = @import("windows/screen.zig");
pub const event = @import("windows/event.zig");

const std = @import("std");
const windows = std.os.windows;

const termcon = @import("../termcon.zig");
pub const SupportedFeatures = termcon.SupportedFeatures;

pub var hConsoleOutCurrent: ?windows.HANDLE = null; // hConsoleOutCurrent is to be used publicly.
pub var hConsoleOutMain:    ?windows.HANDLE = null; // hConsoleOutMain and hConsoleOutAlt are specific handles for
pub var hConsoleOutAlt:     ?windows.HANDLE = null; // the primary and secondary console screen buffers.
pub var hConsoleIn:         ?windows.HANDLE = null;

var restore_console_mode: windows.DWORD = undefined; // To restore the state of the console on exit

pub fn init() !SupportedFeatures {
    hConsoleOutMain = try std.os.windows.GetStdHandle(std.os.windows.STD_OUTPUT_HANDLE);
    hConsoleOutCurrent = hConsoleOutMain;
    hConsoleIn = try std.os.windows.GetStdHandle(std.os.windows.STD_INPUT_HANDLE);
    restore_console_mode = windows.kernel32.GetConsoleMode(hConsoleOutMain, &restore_console_mode);

    return SupportedFeatures{ .mouse_events = true };
}

pub fn deinit() void {
    try config.setAlternateScreen(false) catch {};
    if (hConsoleOutAlt != null) {
        if (hConsoleOutAlt) |handle| {
            _ = windows.kernel32.CloseHandle(handle);
        }
    }
    if (SetConsoleMode(hConsoleOutMain orelse return, restore_console_mode) == 0) return;
}
