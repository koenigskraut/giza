const pango = @import("../pango.zig");
const c = pango.c;

/// A `pango.Matrix` specifies a transformation between user-space and device
/// coordinates.
///
/// The transformation is given by
/// ```zig
/// x_device = x_user * matrix.xx + y_user * matrix.xy + matrix.x0;
/// y_device = x_user * matrix.yx + y_user * matrix.yy + matrix.y0;
/// ```
pub const Matrix = extern struct {
    /// 1st component of the transformation matrix.
    xx: f64,
    /// 2nd component of the transformation matrix.
    xy: f64,
    /// 3rd component of the transformation matrix.
    yx: f64,
    /// 4th component of the transformation matrix.
    yy: f64,
    /// X translation.
    x0: f64,
    /// Y translation.
    y0: f64,
};
