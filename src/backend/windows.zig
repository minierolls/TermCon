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

pub var hConsoleOutCurrent: ?windows.HANDLE = null; // This variable should be used by functions.
pub var hConsoleOutMain:    ?windows.HANDLE = null; // hConsoleOutMain and hConsoleOutAlt are specific handles for
pub var hConsoleOutAlt:     ?windows.HANDLE = null; // the primary and secondary consoles.
pub var hConsoleIn:         ?windows.HANDLE = null;

pub fn init() !SupportedFeatures {
    hConsoleOutMain = try std.os.windows.GetStdHandle(std.os.windows.STD_OUTPUT_HANDLE);
    hConsoleOutCurrent = hConsoleOutMain;
    hConsoleIn = try std.os.windows.GetStdHandle(std.os.windows.STD_INPUT_HANDLE);

    return SupportedFeatures{ .mouse_events = true };
}

pub fn deinit() void {
    config.setAlternateScreen(false) catch return;
    if (hConsoleOutAlt != undefined) {
        if (hConsoleOutAlt) |handle| {
            _ = windows.kernel32.CloseHandle(handle);
        }
    }
    config.setRawMode(false) catch return;
}

pub fn setAlternateScreen(value: bool) !void {
    return; // TODO: implement
}
