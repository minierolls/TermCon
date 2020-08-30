// Copyright (c) 2020 John Namgung, Luke I. Wilson.

// SPDX-License-Identifier: MIT
// This file is part of the `termcon` project under the MIT license.

const root = @import("../windows.zig");
const std = @import("std");
const windows = std.os.windows;

// when hConsoleHandle param is an input handle:
const ENABLE_ECHO_INPUT: windows.DWORD = 0x0004;
const ENABLE_EXTENDED_FLAGS: windows.DWORD = 0x0080;
const ENABLE_INSERT_MODE: windows.DWORD = 0x0020;
const ENABLE_LINE_MODE: windows.DWORD = 0x0002;
const ENABLE_MOUSE_INPUT: windows.DWORD = 0x0010;
const ENABLE_PROCESSED_INPUT: windows.DWORD = 0x0001;
const ENABLE_QUICK_EDIT_MODE: windows.DWORD = 0x0040;
const ENABLE_WINDOW_INPUT: windows.DWORD = 0x0008;
const ENABLE_VIRTUAL_TERMINAL_INPUT: windows.DWORD = 0x0200;

// when hConsoleHandle param is a screen buffer handle:
const ENABLE_PROCESSED_OUTPUT: windows.DWORD = 0x0001;
const ENABLE_WRAP_AT_EOL_OUTPUT: windows.DWORD = 0x0002;
const ENABLE_VIRTUAL_TERMINAL_PROCESSING: windows.DWORD = 0x0004;
const DISABLE_NEWLINE_AUTO_RETURN: windows.DWORD = 0x0008;
const ENABLE_LVB_GRID_WORLDWIDE: windows.DWORD = 0x0010;

pub fn getRawMode() bool {
    @compileError("Unimplemented");
}

pub fn setRawMode(enabled: bool) !void {
    if (enabled) {
        if (root.SetConsoleMode(root.hConsoleIn, ENABLE_EXTENDED_FLAGS | ENABLE_MOUSE_INPUT | ENABLE_WINDOW_INPUT | ENABLE_VIRTUAL_TERMINAL_INPUT) == 0) return error.Failed;
        if (root.SetConsoleMode(root.hConsoleOut, ENABLE_VIRTUAL_TERMINAL_PROCESSING | DISABLE_NEWLINE_AUTO_RETURN) == 0) return error.Failed;
    } else {
        if (root.SetConsoleMode(root.hConsoleIn, ENABLE_ECHO_INPUT | ENABLE_EXTENDED_FLAGS | ENABLE_INSERT_MODE | ENABLE_LINE_MODE | ENABLE_MOUSE_INPUT |
            ENABLE_PROCESSED_INPUT | ENABLE_QUICK_EDIT_MODE | ENABLE_WINDOW_INPUT | ENABLE_VIRTUAL_TERMINAL_INPUT) == 0) return error.Failed;
        if (root.SetConsoleMode(root.hConsoleOut, ENABLE_PROCESSED_OUTPUT | ENABLE_WRAP_AT_EOL_OUTPUT | ENABLE_VIRTUAL_TERMINAL_PROCESSING) == 0) return error.Failed;
    }
}

pub fn getAlternateScreen() bool {
    // @compileError("Unimplemented");
}

pub fn setAlternateScreen(enabled: bool) !void {
    // @compileError("Unimplemented");
}
