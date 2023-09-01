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
};

/// Specifies the type of antialiasing to do when rendering text or shapes.
///
/// As it is not necessarily clear from the above what advantages a particular
/// antialias method provides, there is also a set of hints:
/// - `.Fast`: Allow the backend to degrade raster quality for speed
/// - `.Good`: A balance between speed and quality
/// - `.Best`: A high-fidelity, but potentially slow, raster mode
///
/// These make no guarantee on how the backend will perform its rasterisation
/// (if it even rasterises!), nor that they have any differing effect other
/// than to enable some form of antialiasing. In the case of glyph rendering,
/// `.Fast` and `.Good` will be mapped to `.Gray` , with `.Best` being
/// equivalent to `.Subpixel`.
///
/// The interpretation of `.Default` is left entirely up to the backend,
/// typically this will be similar to `.Good`.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-antialias-t)
pub const Antialias = enum(c_uint) {
    /// Use the default antialiasing for the subsystem and target device
    Default,
    /// Use a bilevel alpha mask
    None,
    /// Perform single-color antialiasing (using shades of gray for black text
    /// on a white background, for example)
    Gray,
    /// Perform antialiasing by taking advantage of the order of subpixel
    /// elements on devices such as LCD panels
    Subpixel,
    /// Hint that the backend should perform some antialiasing but prefer speed
    /// over quality
    Fast,
    /// The backend should balance quality against performance
    Good,
    /// Hint that the backend should render at the highest quality, sacrificing
    /// speed if necessary
    Best,
};

/// `cairo.FillRule` is used to select how paths are filled. For both fill
/// rules, whether or not a point is included in the fill is determined by
/// taking a ray from that point to infinity and looking at intersections with
/// the path. The ray can be in any direction, as long as it doesn't pass
/// through the end point of a segment or have a tricky intersection such as
/// intersecting tangent to the path. (Note that filling is not actually
/// implemented in this way. This is just a description of the rule that is
/// applied.)
///
/// The default fill rule is `.Winding`.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-fill-rule-t)
pub const FillRule = enum(c_uint) {
    Winding,
    EvenOdd,
};

/// Specifies how to render the endpoints of the path when stroking.
///
/// The default line cap style is `.Butt`.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-line-cap-t)
pub const LineCap = enum(c_uint) {
    /// start(stop) the line exactly at the start(end) point (
    Butt,
    /// use a round ending, the center of the circle is the end point
    Round,
    /// use squared ending, the center of the square is the end point
    Square,
};

/// Specifies how to render the junction of two lines when stroking.
///
/// The default line join style is `.Miter`.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-line-join-t)
pub const LineJoin = enum(c_uint) {
    /// use a sharp (angled) corner, see ctx.setMiterLimit()
    Miter,
    /// use a rounded join, the center of the circle is the joint point
    Round,
    /// use a cut-off join, the join is cut off at half the line width from the
    /// joint point
    Bevel,
};

/// `cairo.Operator` is used to set the compositing operator for all cairo
/// drawing operations.
///
/// The default operator is `.Over`.
///
/// The operators marked as *unbounded* modify their destination even outside
/// of the mask layer (that is, their effect is not bound by the mask layer).
/// However, their effect can still be limited by way of clipping.
///
/// To keep things simple, the operator descriptions here document the behavior
/// for when both source and destination are either fully transparent or fully
/// opaque. The actual implementation works for translucent layers too. For a
/// more detailed explanation of the effects of each operator, including the
/// mathematical definitions, see [link](https://cairographics.org/operators/).
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-operator-t)
pub const Operator = enum(c_uint) {
    /// clear destination layer (bounded)
    Clear,
    /// replace destination layer (bounded)
    Source,
    /// draw source layer on top of destination layer (bounded)
    Over,
    /// draw source where there was destination content (unbounded)
    In,
    /// draw source where there was no destination content (unbounded)
    Out,
    /// draw source on top of destination content and only there
    Atop,
    /// ignore the source
    Dest,
    /// draw destination on top of source
    DestOver,
    /// leave destination only where there was source content (unbounded)
    DestIn,
    /// leave destination only where there was no source content
    DestOut,
    /// leave destination on top of source content and only there (unbounded)
    DestAtop,
    /// source and destination are shown where there is only one of them
    Xor,
    /// source and destination layers are accumulated
    Add,
    /// like over, but assuming source and dest are disjoint geometries
    Saturate,
    /// source and destination layers are multiplied. This causes the result to
    /// be at least as dark as the darker inputs.
    Multiply,
    /// source and destination are complemented and multiplied. This causes the
    /// result to be at least as light as the lighter inputs.
    Screen,
    /// multiplies or screens, depending on the lightness of the destination
    /// color.
    Overlay,
    /// replaces the destination with the source if it is darker, otherwise
    /// keeps the source.
    Darken,
    /// replaces the destination with the source if it is lighter, otherwise
    /// keeps the source.
    Lighten,
    /// brightens the destination color to reflect the source color.
    ColorDodge,
    /// darkens the destination color to reflect the source color.
    ColorBurn,
    /// Multiplies or screens, dependent on source color.
    HardLight,
    /// Darkens or lightens, dependent on source color.
    SoftLight,
    /// Takes the difference of the source and destination color.
    Difference,
    /// Produces an effect similar to difference, but with lower contrast.
    Exclusion,
    /// Creates a color with the hue of the source and the saturation and
    /// luminosity of the target.
    HslHue,
    /// Creates a color with the saturation of the source and the hue and
    /// luminosity of the target. Painting with this mode onto a gray area
    /// produces no change.
    HslSaturation,
    /// Creates a color with the hue and saturation of the source and the
    /// luminosity of the target. This preserves the gray levels of the target
    /// and is useful for coloring monochrome images or tinting color images.
    HslColor,
    /// Creates a color with the luminosity of the source and the hue and
    /// saturation of the target. This produces an inverse effect to
    /// `.HslColor`.
    HslLuminosity,
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
