// Copyright (c) 2020 John Namgung.

// SPDX-License-Identifier: MIT
// This file is part of the `termcon` project under the MIT license.

const std = @import("std");

const backend = @import("../backend.zig").backend;

const view = @import("../view.zig");
pub const Cell = view.Cell;
pub const Position = view.Position;
pub const Rune = view.Rune;
pub const Style = view.Style;
pub const Cursor = view.Cursor;

pub const Size = struct {
    rows: u16, cols: u16
};

pub const Screen = struct {
    // TODO: Implement mutex for screen
    // lock: std.Mutex
    allocator: *std.mem.Allocator,
    cursor: Cursor,
    default_style: Style,
    size: Size,
    buffer_size: Size,
    rune_buffer: std.ArrayList(Rune),
    style_buffer: std.ArrayList(Style),
    diff_buffer: std.PriorityQueue(Position),

    const Self = @This();

    fn positionLess(a: Position, b: Position) bool {
        return a.less(b);
    }

    fn addChecked(
        diff_buffer: *std.PriorityQueue(Position),
        elem: Position,
    ) !void {
        for (diff_buffer.items) |item| {
            if (elem.equal(item)) {
                return;
            }
        }
        return diff_buffer.add(elem);
    }

    pub fn init(allocator: *std.mem.Allocator, buffer_size: ?Size) !Screen {
        var result: Screen = Screen{
            .allocator = allocator,
            .cursor = Cursor{},
            .default_style = Style{
                .fg_color = view.Color{
                    .Default = view.ColorDefault.Foreground,
                },
                .bg_color = view.Color{
                    .Default = view.ColorDefault.Background,
                },
                .text_decorations = view.TextDecorations{
                    .italic = false,
                    .bold = false,
                    .underline = false,
                },
            },
            .size = Size{ .rows = 0, .cols = 0 },
            .buffer_size = buffer_size orelse Size{ .rows = 300, .cols = 100 },
            .rune_buffer = std.ArrayList(Rune).init(allocator),
            .style_buffer = std.ArrayList(Style).init(allocator),
            .diff_buffer = std.PriorityQueue(Position).init(allocator, positionLess),
        };
        try result.updateSize();

        try result.rune_buffer.ensureCapacity(
            result.buffer_size.rows * result.buffer_size.cols,
        );
        try result.style_buffer.ensureCapacity(
            result.buffer_size.rows * result.buffer_size.cols,
        );

        std.mem.set(
            Rune,
            result.rune_buffer.items,
            ' ',
        );
        std.mem.set(
            Style,
            result.style_buffer.items,
            result.default_style,
        );
        return result;
    }

    pub fn deinit(self: *Self) void {
        self.rune_buffer.deinit();
        self.style_buffer.deinit();
        self.diff_buffer.deinit();
    }

    pub fn clear(self: *Self) !void {
        try backend.screen.clearScreen();
    }

    pub fn draw(self: *Self) !void {
        const orig_cursor: Position = try self.cursor.getPosition();
        while (self.diff_buffer.count() > 0) {
            // Get row range to draw
            const diff_position = self.diff_buffer.remove();
            var final_col = u16;
            while (self.diff_buffer.peek()) |next| {
                if (next.row != diff_position.row)
                    break;

                final_col = next.col;
                _ = self.diff_buffer.remove();
            }

            // Move cursor and draw row
            try self.cursor.setPosition(diff_position);
            const range_start = diff_position.row *
                self.buffer_size.cols +
                diff_position.col;
            const range_end = diff_position.row *
                self.buffer_size.cols +
                final_col + 1;
            try backend.screen.write(
                self.rune_buffer.items[range_start..range_end],
                self.style_buffer.items[range_start..range_end],
            );
        }

        try self.cursor.setPosition(orig_cursor);
    }

    pub fn getSize(self: *const Self) Size {
        return self.size;
    }

    pub fn updateSize(self: *Self) !void {
        self.size = try backend.screen.getSize();
    }

    pub fn getBufferSize(self: *const Self) Size {
        return self.buffer_size;
    }

    /// Resize the buffer. This function call is expensive; try to minimize
    /// its use. During resize, all cells that are beyond the new row or
    /// column limit are ignored. Any new cells introduced from an expansion
    /// in rows or columns is filled with either the provided `fill_cell` or
    /// an empty default-style cell.
    pub fn setBufferSize(self: *Self, size: Size, fill_cell: ?Cell) !void {
        const b_rows = self.buffer_size.rows;
        const b_cols = self.buffer_size.cols;

        if (size.rows * size.cols != b_rows * b_cols) {
            try self.buffer.ensureCapacity(size.rows * size.cols);
        }

        if (size.cols < b_cols) {
            var row_index: @Type(b_rows) = 1;
            while (row_index < b_rows) : (row_index += 1) {
                const start_dest = row_index * b_cols;
                const end_dest = row_index * b_cols + size.cols;

                const start_source = row_index * size.cols;
                const end_source = (row_index + 1) * size.cols;

                std.mem.copy(
                    Rune,
                    self.rune_buffer.items[start_dest..end_dest],
                    self.rune_buffer.items[start_source..end_source],
                );
                std.mem.copy(
                    Style,
                    self.style_buffer.items[start_dest..end_dest],
                    self.style_buffer.items[start_source..end_source],
                );
            }
        } else if (size.cols > b_cols) {
            var row_index: @Type(b_rows) = b_rows;
            while (row_index > 0) : (row_index -= 1) {
                const r_i = row_index - 1;

                const start_dest = r_i * size.cols;
                const end_dest = r_i * size.cols + b_cols;

                const start_source = r_i * b_cols;
                const end_source = row_index * b_cols;

                const start_empty = r_i * size.cols + b_cols;
                const end_empty = row_index * size.cols;

                std.mem.copyBackwards(
                    Rune,
                    self.rune_buffer.items[start_dest..end_dest],
                    self.rune_buffer.items[start_source..end_source],
                );
                std.mem.set(
                    Rune,
                    self.rune_buffer.items[start_empty..end_empty],
                    fill_cell.rune orelse ' ',
                );

                std.mem.copyBackwards(
                    Style,
                    self.style_buffer.items[start_dest..end_dest],
                    self.style_buffer.items[start_source..end_source],
                );
                std.mem.set(
                    Style,
                    self.style_buffer.items[start_empty..end_empty],
                    fill_cell.style orelse self.default_style,
                );
                {
                    var index: u16 = start_empty;
                    while (index < end_empty) : (index += 1) {
                        if (self.default_style.equal(self.style_buffer[index])) {
                            try addChecked(&self.diff_buffer, Position{
                                .row = index / self.buffer_size.rows,
                                .col = index % self.buffer_size.cols,
                            });
                            self.style_buffer[index] = style;
                        }
                    }
                }
            }
        }

        if (size.rows > b_rows) {
            const start_empty = b_rows * size.cols;
            const end_empty = size.rows * size.cols;
            std.mem.set(
                Rune,
                self.rune_buffer.items[start_empty..end_empty],
                fill_cell.rune orelse ' ',
            );
            std.mem.set(
                Style,
                self.style_buffer.items[start_empty..end_empty],
                fill_cell.style orelse self.default_style,
            );
            {
                var index: u16 = start_empty;
                while (index < end_empty) : (index += 1) {
                    if (self.default_style.equal(self.style_buffer[index])) {
                        try addChecked(&self.diff_buffer, Position{
                            .row = index / self.buffer_size.rows,
                            .col = index % self.buffer_size.cols,
                        });
                        self.style_buffer[index] = style;
                    }
                }
            }
        }

        self.buffer_size.rows = size.rows;
        self.buffer_size.cols = size.cols;
    }

    pub fn getDefaultStyle(self: *const Self) Style {
        return self.default_style;
    }

    pub fn setDefaultStyle(self: *Self, style: Style) !void {
        if (self.default_style.equal(style)) return;
        {
            var index: u16 = 0;
            while (index < self.style_buffer.len) : (index += 1) {
                if (self.default_style.equal(self.style_buffer[index])) {
                    try addChecked(&self.diff_buffer, Position{
                        .row = index / self.buffer_size.rows,
                        .col = index % self.buffer_size.cols,
                    });
                    self.style_buffer[index] = style;
                }
            }
        }
        self.default_style = style;
    }

    pub fn getCell(self: *const Self, position: Position) !Cell {
        if (position.row >= self.buffer_size.rows or position.col >= self.buffer_size.cols)
            return error.OutOfRange;

        const index = position.row * self.buffer_size.cols + position.col;

        return Cell{
            .rune = self.rune_buffer.items[index],
            .style = self.style_buffer.items[index],
        };
    }

    pub fn setCell(
        self: *Self,
        position: Position,
        cell: Cell,
    ) !void {
        if (position.row >= self.buffer_size.rows or position.col >= self.buffer_size.cols)
            return error.OutOfRange;

        const index = position.row * self.buffer_size.cols + position.col;

        if (!self.rune_buffer.items[index].equal(cell.rune) or
            !self.style_buffer.items[index].equal(cell.style))
            addChecked(&self.diff_buffer, position);

        self.rune_buffer.items[index] = cell.rune;
        self.style_buffer.items[index] = cell.style;
    }
};
