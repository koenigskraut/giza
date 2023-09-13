const safety = @import("safety");
const c = @import("../pango.zig").c;

/// The `pango.Rectangle` structure represents a rectangle.
///
/// `pango.Rectangle` is frequently used to represent the logical or ink
/// extents of a single glyph or section of text. (See, for instance,
/// `pango.Font.getGlyphExtents()`.)
pub const Rectangle = extern struct {
    /// X coordinate of the left side of the rectangle.
    x: c_int,
    /// Y coordinate of the the top side of the rectangle.
    y: c_int,
    /// Width of the rectangle.
    width: c_int,
    /// Height of the rectangle.
    height: c_int,
};

pub fn free(memory: anytype) void {
    const info = @typeInfo(@TypeOf(memory));
    switch (info) {
        .Pointer => c.g_free(@ptrCast(memory)),
        else => @compileError("wrong type"),
    }
    if (safety.tracing) safety.destroy(@ptrCast(memory));
}
