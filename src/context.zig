const std = @import("std");
const testing = std.testing;

const cairo = @import("cairo.zig");
const safety = @import("safety.zig");

const text = @import("drawing/text.zig");

const Status = cairo.Status;

/// A `cairo.Context` contains the current state of the rendering device,
/// including coordinates of yet to be drawn shapes.
///
/// Cairo contexts, are central to cairo and all drawing with cairo is always
/// done to a `cairo.Context` object.
///
/// Memory management of `cairo.Context` is done with `ctx.reference()` and
/// `ctx.destroy()`.
///
/// [Link to Cairo Manual](https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-t)
pub const Context = opaque {
    pub usingnamespace @import("drawing/basic.zig").Mixin;
    pub usingnamespace @import("drawing/paths.zig").Mixin;
    pub usingnamespace @import("drawing/text.zig").Mixin;
    pub usingnamespace @import("drawing/tags_and_links.zig");
};

pub const Glyph = text.Glyph;
pub const TextCluster = text.TextCluster;

/// A data structure for holding a rectangle.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-rectangle-t)
pub const Rectangle = extern struct {
    /// X coordinate of the left side of the rectangle
    x: f64,
    /// Y coordinate of the the top side of the rectangle
    y: f64,
    /// width of the rectangle
    width: f64,
    /// height of the rectangle
    height: f64,

    /// Init `cairo.Rectangle` from [4]c_int array. Values are
    /// `.{x, y, width, height}`
    pub fn init(arr: [4]f64) Rectangle {
        return @bitCast(arr);
    }
};

/// A data structure for holding a dynamically allocated array of rectangles.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-rectangle-list-t)
pub const RectangleList = extern struct {
    /// Error status of the rectangle list
    status: Status,
    /// Array containing the rectangles
    rectangles: [*c]Rectangle,
    /// Number of rectangles in this list
    num_rectangles: c_int,

    /// Unconditionally frees `self` and all associated references. After this
    /// call, the `self` pointer must not be dereferenced.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-rectangle-list-destroy)
    pub fn destroy(self: *RectangleList) void {
        cairo_rectangle_list_destroy(self);
        if (safety.tracing) safety.destroy(self);
    }

    /// Converts C-style structure `cairo.RectangleList` into a friendly Zig
    /// slice. **Note**: the caller owns the memory and should call
    /// `.destroy()` on the **original** `cairo.RectangleList`.
    pub fn asSlice(self: *RectangleList) []Rectangle {
        const end: usize = @intCast(self.num_rectangles);
        return self.rectangles[0..end];
    }
};

test "RectangleList" {
    const surface = try cairo.ImageSurface.create(.ARGB32, 10, 10);
    defer surface.destroy();
    const context = try cairo.Context.create(surface.asSurface());
    defer context.destroy();
    context.lineTo(0, 5);
    context.lineTo(5, 5);
    context.lineTo(5, 0);
    context.lineTo(0, 0);
    context.clip();

    const rects = try context.copyClipRectangleList();
    defer rects.destroy();

    const expectRect = Rectangle{ .x = 0, .y = 0, .width = 5, .height = 5 };
    try testing.expect(rects.num_rectangles == 1);
    try testing.expectEqual(expectRect, rects.rectangles[0]);
    try testing.expectEqualSlices(Rectangle, &.{expectRect}, rects.asSlice());
}

extern fn cairo_rectangle_list_destroy(rectangle_list: [*c]RectangleList) void;
