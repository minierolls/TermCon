// Copyright (c) 2020 John Namgung, Luke I. Wilson.

// SPDX-License-Identifier: MIT
// This file is part of the `termcon` project under the MIT license.

//! This module handles provides functions to interface with the terminal
//! screen.

const view = @import("../../view.zig");
const root = @import("../windows.zig");

const std = @import("std");
const windows = std.os.windows;

pub const Size = view.Size;
pub const Rune = view.Rune;
pub const Style = view.Style;

/// Get the size of the screen in terms of rows and columns.
pub fn getSize() !Size {
    var csbi = try getScreenBufferInfo();

    var size = Size {
        .cols = @intCast(u16, csbi.srWindow.Right - csbi.srWindow.Left + 1),
        .rows = @intCast(u16, csbi.srWindow.Bottom - csbi.srWindow.Top + 1)
    };

    return size;
}

/// Write styled text to the screen at the cursor's position,
/// moving the cursor accordingly.
pub fn write(runes: []const Rune, styles: []const Style) !void {
    var csbi = try getScreenBufferInfo();
    var coord: windows.COORD = csbi.dwCursorPosition;
    var chars_written = @as(windows.DWORD, 0);

    var index: u32 = 0;
    while (index < runes.len) : (index += 1) {
        if (windows.kernel32.FillConsoleOutputCharacterA(root.hConsoleOutCurrent orelse return error.Handle, @intCast(windows.TCHAR, runes[index]), 1, coord, &chars_written) == 0)
            return error.FailToWriteChar;
        
        coord.X += 1; // TODO: handle newlines
    }

    // Set new cursor position
    if (windows.kernel32.SetConsoleCursorPosition(root.hConsoleOutCurrent orelse return error.Handle, coord) == 0) return error.SetCursorFailed;
}

/// Clear all runes and styles on the screen.
pub fn clearScreen() !void {
    // This function does the same as Microsoft recommends,
    // and is how the cls and clear commands are implemented
    // in Powershell and CMD: write an empty cell to every
    // visible cell on the screen.

    var csbi = try getScreenBufferInfo();
    var start_pos = windows.COORD { .X = 0, .Y = 0 };
    var chars_written: windows.DWORD = 0;

    // Get number of cells in the buffer
    // TODO: currently uses buffer size, later needs to use actual screen size for optimization
    var console_size: windows.DWORD = @intCast(u32, csbi.dwSize.X) * @intCast(u32, csbi.dwSize.Y);
    // var console_size = @intCast(u32, (csbi.srWindow.Right - csbi.srWindow.Left + 1) * (csbi.srWindow.Bottom - csbi.srWindow.Top + 1));

    // Fill screen with blanks
    if (windows.kernel32.FillConsoleOutputCharacterA(root.hConsoleOutCurrent orelse return error.Handle, @as(windows.TCHAR, ' '), console_size, start_pos, &chars_written) == 0) {
        return error.SomeDrawError; // TODO: seriously need real errors
    }

    // Get the current text attribute
    // csbi = try getScreenBufferInfo();

    if (windows.kernel32.FillConsoleOutputAttribute(root.hConsoleOutCurrent orelse return error.Handle, csbi.wAttributes, console_size, start_pos, &chars_written) == 0) {
        return error.SomeDrawError;
    }
}

pub fn getScreenBufferInfo() !windows.kernel32.CONSOLE_SCREEN_BUFFER_INFO {
    var csbi: windows.kernel32.CONSOLE_SCREEN_BUFFER_INFO = undefined;
    if (windows.kernel32.GetConsoleScreenBufferInfo(root.hConsoleOutCurrent orelse return error.Handle, &csbi) == 0) return error.FailedToGetBufferInfo;
    return csbi;
}
