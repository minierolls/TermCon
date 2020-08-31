// Copyright (c) 2020 John Namgung, Luke I. Wilson.

// SPDX-License-Identifier: MIT
// This file is part of the `termcon` project under the MIT license.

const root = @import("../windows.zig");
const std = @import("std");
const windows = std.os.windows;

pub const CONSOLE_TEXTMODE_BUFFER: windows.DWORD = 1;

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
    std.debug.assert(root.hConsoleOutCurrent != null);
    if (enabled) {
        if (root.SetConsoleMode(root.hConsoleIn orelse return error.Handle, ENABLE_EXTENDED_FLAGS | ENABLE_MOUSE_INPUT | ENABLE_WINDOW_INPUT | ENABLE_VIRTUAL_TERMINAL_INPUT) == 0) return error.Failed;
        if (root.SetConsoleMode(root.hConsoleOutCurrent orelse return error.Handle, ENABLE_VIRTUAL_TERMINAL_PROCESSING | DISABLE_NEWLINE_AUTO_RETURN) == 0) return error.Failed;
    } else {
        if (root.SetConsoleMode(root.hConsoleIn orelse return error.Handle, ENABLE_ECHO_INPUT | ENABLE_EXTENDED_FLAGS | ENABLE_INSERT_MODE | ENABLE_LINE_MODE | ENABLE_MOUSE_INPUT |
            ENABLE_PROCESSED_INPUT | ENABLE_QUICK_EDIT_MODE | ENABLE_WINDOW_INPUT | ENABLE_VIRTUAL_TERMINAL_INPUT) == 0) return error.Failed;
        if (root.SetConsoleMode(root.hConsoleOutCurrent orelse return error.Handle, ENABLE_PROCESSED_OUTPUT | ENABLE_WRAP_AT_EOL_OUTPUT | ENABLE_VIRTUAL_TERMINAL_PROCESSING) == 0) return error.Failed;
    }
}

pub fn getAlternateScreen() bool {
    if (root.hConsoleOutAlt == null) return false;
    return root.hConsoleOutAlt == root.hConsoleOutCurrent;
}

pub fn setAlternateScreen(enabled: bool) !void {
    if (enabled) {
        if (root.hConsoleOutAlt == null) { // The alternate screen has not yet been created...
            root.hConsoleOutAlt = root.CreateConsoleScreenBuffer(windows.GENERIC_READ | windows.GENERIC_WRITE,
                windows.FILE_SHARE_READ | windows.FILE_SHARE_WRITE, null, CONSOLE_TEXTMODE_BUFFER, null);
            if (root.hConsoleOutAlt == windows.INVALID_HANDLE_VALUE) return error.SetScreenFailed;
        }
        if (root.SetConsoleActiveScreenBuffer(root.hConsoleOutAlt orelse return error.Handle) == 0) return error.SetScreenFailed;
        root.hConsoleOutCurrent = root.hConsoleOutAlt;
    } else {
        if (root.SetConsoleActiveScreenBuffer(root.hConsoleOutMain orelse return error.Handle) == 0) return error.SetScreenFailed;
        root.hConsoleOutCurrent = root.hConsoleOutMain;
    }
}
