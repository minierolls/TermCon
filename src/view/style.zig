// Copyright (c) 2020 John Namgung.

// SPDX-License-Identifier: MIT
// This file is part of the `termcon` project under the MIT license.

pub const ColorDefault = enum {
    Highlight,
    Background,
    Foreground,
};

pub const ColorTrue; // TODO
pub const ColorNamed; // TODO

pub const Color24Bit = struct {
    hex: u24,

    pub fn initHex(hex: u24) CustomColor {
        return CustomColor{ .hex = hex };
    }

    pub fn initRGB(red: u8, green: u8, blue: u8) CustomColor {
        var hex: u32 = 0;
        hex |= blue;
        hex |= @as(u16, green) << 8;
        hex |= @as(u24, red) << 16;
        return CustomColor{ .hex = hex };
    }
};

pub const ColorType = enum {
    Default,
    Custom,
    True,
    Named,
};

pub const Color = union(ColorType) {
    Custom: Color24Bit,
    True: ColorTrue,
    Named: ColorNamed,
    Default: ColorDefault,
};

pub const TextDecorations = struct {
    italic: bool,
    bold: bool,
    underline: bool,
};

pub const Style = struct {
    fg_color: Color,
    bg_color: Color,
    text_decorations: TextDecorations,
};
