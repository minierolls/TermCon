// Copyright (c) 2020 John Namgung.

// SPDX-License-Identifier: MIT
// This file is part of the `termcon` project under the MIT license.

pub const Style = struct {
    fg_color: Color,
    bg_color: Color,
    text_decorations: TextDecorations,
};

pub const TextDecorations = struct {
    italic: bool,
    bold: bool,
    underline: bool,
};

pub const Color = union(ColorType) {
    Default: ColorDefault,
    Named: ColorNamed,
    Bit24: ColorBit24,
    True: ColorTrue,
    // TODO: Provide conversion functions
};

pub const ColorType = enum {
    Default,
    Named,
    Bit24,
    True,
};

pub const ColorDefault = enum {
    Background,
    Foreground,
    Highlight,
    Cursor,
    _, // TODO
};

pub const ColorNamed; // TODO

pub const ColorBit24 = struct {
    hex: u24,

    pub fn initHex(hex: u24) ColorBit24 {
        return ColorBit24{ .hex = hex };
    }

    pub fn initRGB(red: u8, green: u8, blue: u8) ColorBit24 {
        var hex: u32 = 0;
        hex |= blue;
        hex |= @as(u16, green) << 8;
        hex |= @as(u24, red) << 16;
        return ColorBit24{ .hex = hex };
    }
};

pub const ColorTrue; // TODO
