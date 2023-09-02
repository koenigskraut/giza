const std = @import("std");

const Status = @import("enums.zig").Status;

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
};

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
    }
};

extern fn cairo_rectangle_list_destroy(rectangle_list: [*c]RectangleList) void;
