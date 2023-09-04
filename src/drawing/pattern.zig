//! `cairo.Pattern` — Sources for drawing
//!
//! `cairo.Pattern` is the paint with which cairo draws. The primary use of
//! patterns is as the source for all cairo drawing operations, although they
//! can also be used as masks, that is, as the brush too.
//!
//! A cairo pattern is created by using one of the many constructors, of the
//! form `cairo.Pattern.create*Type*()` or implicitly through
//! `ctx.setSource*Type*()` functions.
//!
//! [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html)

const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const enums = @import("../enums.zig");
const safety = @import("../safety.zig");

const Content = enums.Content;
const Extend = enums.Extend;
const Filter = enums.Filter;
const PatternType = enums.PatternType;
const Status = enums.Status;
const CairoError = enums.CairoError;
const Surface = @import("../surface.zig").Surface;
const Path = @import("paths.zig").Path;

const RectangleInt = util.RectangleInt;
const Matrix = util.Matrix;
const UserDataKey = util.UserDataKey;
const DestroyFn = util.DestroyFn;
const Point = util.Point;

pub fn Mixin(comptime Self: type) type {
    return struct {
        /// Casts a pointer to the particular pattern into base
        /// `*cairo.Pattern` object.
        pub fn asPattern(self: *Self) *Pattern {
            return @ptrCast(self);
        }

        /// Sets the mode to be used for drawing outside the area of a pattern. See
        /// `cairo.Extend` for details on the semantics of each extend strategy.
        ///
        /// The default extend mode is `.None` for surface patterns and `.Pad` for
        /// gradient patterns.
        ///
        /// **Parameters**
        /// - `extend`: a `cairo.Extend` describing how the area outside of the
        /// pattern will be drawn
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-set-extend)
        pub fn setExtend(self: *Self, extend: Extend) void {
            cairo_pattern_set_extend(self, extend);
        }

        /// Gets the current extend mode for a pattern. See `cairo.Extend` for
        /// details on the semantics of each extend strategy.
        ///
        /// **Returns**
        ///
        /// the current extend strategy used for drawing the pattern.
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-extend)
        pub fn getExtend(self: *Self) Extend {
            return cairo_pattern_get_extend(self);
        }

        /// Sets the pattern's transformation matrix to `matrix`. This matrix is a
        /// transformation from user space to pattern space.
        ///
        /// When a pattern is first created it always has the identity matrix for
        /// its transformation matrix, which means that pattern space is initially
        /// identical to user space.
        ///
        /// Important: Please note that the direction of this transformation matrix
        /// is from user space to pattern space. This means that if you imagine the
        /// flow from a pattern to user space (and on to device space), then
        /// coordinates in that flow will be transformed by the inverse of the
        /// pattern matrix.
        ///
        /// For example, if you want to make a pattern appear twice as large as it
        /// does by default the correct code to use is:
        /// ```zig
        /// var matrix: cairo.Matrix = undefined;
        /// matrix.initScale(0.5, 0.5);
        /// pattern.setMatrix(&matrix);
        /// ```
        /// Meanwhile, using values of 2.0 rather than 0.5 in the code above would
        /// cause the pattern to appear at half of its default size.
        ///
        /// Also, please note the discussion of the user-space locking semantics of
        /// `cairo.Context.setSource()`.
        ///
        /// **Parameters**
        /// - `matrix`: a `cairo.Matrix`
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-set-matrix)
        pub fn setMatrix(self: *Self, matrix: *const Matrix) void {
            // TODO: check if undefined matrix cause problems
            cairo_pattern_set_matrix(self, matrix);
        }

        /// Stores the pattern's transformation matrix into `matrix`.
        ///
        /// **Parameters**
        /// - `matrix`: return value for the matrix
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-matrix)
        pub fn getMatrix(self: *Self, matrix: *Matrix) void {
            cairo_pattern_get_matrix(self, matrix);
        }

        /// Increases the reference count on pattern by one. This prevents pattern
        /// from being destroyed until a matching call to `pattern.destroy()` is
        /// made.
        ///
        /// Use `pattern.getReferenceCount()` to get the number of references to a
        /// `cairo.Pattern`.
        ///
        /// **Returns**
        ///
        /// the referenced `cairo.Pattern`.
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-reference)
        pub fn reference(self: *Self) *Self {
            if (safety.tracing) safety.reference(self);
            return @ptrCast(cairo_pattern_reference(self).?);
        }

        /// Decreases the reference count on pattern by one. If the result is zero,
        /// then pattern and all associated resources are freed. See
        /// `cairo.Pattern.reference()`.
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-destroy)
        pub fn destroy(self: *Self) void {
            if (safety.tracing) safety.destroy(self);
            return cairo_pattern_destroy(self);
        }

        /// Checks whether an error has previously occurred for this pattern.
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-status)
        pub fn status(self: *Self) Status {
            return cairo_pattern_status(self);
        }

        /// Get the pattern's type. See `cairo.PatternType` for available types.
        ///
        /// **Returns**
        ///
        /// the type of `self`.
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-type)
        pub fn getType(self: *Self) PatternType {
            return cairo_pattern_get_type(self);
        }

        /// Returns the current reference count of `pattern`.
        ///
        /// **Returns**
        ///
        /// the current reference count of `self`. If the object is a nil object, 0
        /// will be returned.
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-reference-count)
        pub fn getReferenceCount(self: *Self) usize {
            return @intCast(cairo_pattern_get_reference_count(self));
        }

        /// Attach user data to `pattern`. To remove user data from a surface, call
        /// this function with the key that was used to set it and `null` for
        /// `data`.
        ///
        /// **Parameters**
        /// - `key`: the address of a `cairo.UserDataKey` to attach the user data
        /// to
        /// - `userData`: the user data to attach to the `cairo.Pattern`
        /// - `destroyFn`: a `cairo.DestroyFn` which will be called when the
        /// `cairo.Context` is destroyed or when new user data is attached using
        /// the same key.
        ///
        /// Possible error is `error.OutOfMemory` if a slot could not be allocated
        /// for the user data.
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-set-user-data)
        pub fn setUserData(self: *Self, key: *const UserDataKey, userData: ?*anyopaque, destroyFn: DestroyFn) CairoError!void {
            return cairo_pattern_set_user_data(self, key, userData, destroyFn).toErr();
        }

        /// Return user data previously attached to `pattern` using the specified
        /// key. If no user data has been attached with the given key this function
        /// returns `null`.
        ///
        /// **Parameters**
        /// - `key`: the address of the `cairo.UserDataKey` the user data was
        /// attached to
        ///
        /// **Returns**
        ///
        /// the user data previously attached or `null`.
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-user-data)
        pub fn getUserData(self: *Self, key: *const UserDataKey) ?*anyopaque {
            return cairo_pattern_get_user_data(self, key);
        }
    };
}

/// A `cairo.Pattern` represents a source when drawing onto a surface. There
/// are different subtypes of `cairo.Pattern`, for different types of sources;
/// for example, `cairo.SolidPattern.createRGB()` creates a pattern for a solid
/// opaque color.
///
/// **IMPORTANT**: you should **NOT** create pointers to this type manually.
/// Use `.asPattern()` on a pattern created with
/// `cairo.*Something*Pattern.create()`. Casting `*cairo.Pattern` into anything
/// other than the type it had before `.asPattern()` is an **UNDEFINED
/// BEHAVIOR**.
///
/// Other than various `cairo.Pattern.create*Type*()` functions, some of the
/// pattern types can be implicitly created using various
/// `ctx.setSource*Type*()` functions; for example `ctx.setSourceRGB()`.
///
/// The type of a pattern can be queried with `pattern.getType()`.
///
/// Memory management of `cairo.Pattern` is done with `pattern.reference()` and
/// `pattern.destroy()`.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-t)
pub const Pattern = opaque {
    pub usingnamespace Mixin(@This());
};

pub const SolidPattern = opaque {
    pub usingnamespace Mixin(@This());

    /// Creates a new `cairo.SolidPattern` corresponding to an opaque color.
    /// The color components are floating point numbers in the range 0 to 1. If
    /// the values passed in are outside that range, they will be clamped.
    ///
    /// **Parameters**
    /// `red`: red component of the color
    /// `green`: green component of the color
    /// `blue`: blue component of the color
    ///
    /// **Returns**
    ///
    /// the newly created `cairo.SolidPattern` if successful, or an error in
    /// case of no memory.
    ///
    /// **NOTE**: The caller owns the returned object and should call
    /// `pattern.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const pattern = cairo.SolidPattern.createRGB(0.3, 0.6, 0.9);
    /// defer pattern.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-rgb)
    pub fn createRGB(red: f64, green: f64, blue: f64) CairoError!*SolidPattern {
        var pattern = cairo_pattern_create_rgb(red, green, blue).?;
        try pattern.status().toErr();
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), pattern);
        return pattern;
    }

    /// Creates a new `cairo.SolidPattern` corresponding to an translucent
    /// color. The color components are floating point numbers in the range 0
    /// to 1. If the values passed in are outside that range, they will be
    /// clamped.
    ///
    /// **Parameters**
    /// `red`: red component of the color
    /// `green`: green component of the color
    /// `blue`: blue component of the color
    /// `alpha`: alpha component of the color
    ///
    /// **Returns**
    ///
    /// the newly created `cairo.SolidPattern` if successful, or an error in
    /// case of no memory.
    ///
    /// **NOTE**: The caller owns the returned object and should call
    /// `pattern.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const pattern = cairo.SolidPattern.createRGBA(0.3, 0.6, 0.9, 0.5);
    /// defer pattern.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-rgba)
    pub fn createRGBA(red: f64, green: f64, blue: f64, alpha: f64) CairoError!*SolidPattern {
        var pattern = cairo_pattern_create_rgba(red, green, blue, alpha).?;
        try pattern.status().toErr();
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), pattern);
        return pattern;
    }

    /// Gets the solid color for a solid color pattern.
    ///
    /// **Parameters**
    /// - `red`: return value for red component of the color or `null`
    /// - `green`: return value for green component of the color or `null`
    /// - `blue`: return value for blue component of the color or `null`
    /// - `alpha`: return value for alpha component of the color or `null`
    ///
    /// The only possible error is `error.PatternTypeMismatch`, you don't have
    /// to worry about that unless you've casted a pointer from one pattern
    /// type into another, which you **SHOULDN'T**.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-rgba)
    pub fn getRGBA(self: *SolidPattern, red: ?*f64, green: ?*f64, blue: ?*f64, alpha: ?*f64) CairoError!void {
        try cairo_pattern_get_rgba(self, red, green, blue, alpha).toErr();
    }
};

pub const SurfacePattern = opaque {
    pub usingnamespace Mixin(@This());

    /// Create a new `cairo.SurfacePattern` for the given surface.
    ///
    /// **Parameters**
    ///
    /// - `surface`: the surface
    ///
    /// **Returns**
    ///
    /// the newly created `cairo.SurfacePattern` if successful, or an error in
    /// case of no memory.
    ///
    /// **NOTE**: The caller owns the returned object and should call
    /// `pattern.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const pattern = cairo.SurfacePattern.createFor(surface);
    /// defer pattern.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-for-surface)
    pub fn createFor(surface: *Surface) CairoError!*SurfacePattern {
        var pattern = cairo_pattern_create_for_surface(surface).?;
        try pattern.status().toErr();
        return pattern;
    }

    /// Gets the surface of a surface pattern. The reference returned in
    /// `surface` is owned by the pattern; the caller should call
    /// `surface.reference()` if the surface is to be retained.
    ///
    /// The only possible error is `error.PatternTypeMismatch`, you don't have
    /// to worry about that unless you've casted a pointer from one pattern
    /// type into another, which you **SHOULDN'T**.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-surface)
    pub fn getSurface(self: *SurfacePattern) CairoError!*Surface {
        var surface: ?*Surface = undefined;
        try cairo_pattern_get_surface(self, &surface).toErr();
        return surface.?;
    }

    /// Sets the filter to be used for resizing when using this pattern. See
    /// `cairo.Filter` for details on each filter.
    ///
    /// >Note that you might want to control filtering even when you do not
    /// have an explicit `cairo.Pattern` object, (for example when using
    /// `ctx.setSourceSurface()`). In these cases, it is convenient to use
    /// `ctx.getSource()` to get access to the pattern that cairo creates
    /// implicitly. For example:
    /// ```zig
    /// ctx.setSourceSurface(image, x, y);
    /// Pattern.setFilter(ctx.getSource(), .Nearest);
    /// ```
    ///
    /// **Parameters**
    /// - `filter`: a `cairo.Filter` describing the filter to use for resizing
    /// the pattern
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-set-filter)
    pub fn setFilter(self: *SurfacePattern, filter: Filter) void {
        cairo_pattern_set_filter(self, filter);
    }

    /// Gets the current filter for a pattern. See `cairo.Filter` for details
    /// on each filter.
    ///
    /// **Returns**
    ///
    /// the current filter used for resizing the pattern.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-filter)
    pub fn getFilter(self: *SurfacePattern) Filter {
        return cairo_pattern_get_filter(self);
    }
};

pub fn Gradient(comptime Self: type) type {
    return struct {
        pub usingnamespace Mixin(Self);

        /// Adds an opaque color stop to a gradient pattern. The offset
        /// specifies the location along the gradient's control vector. For
        /// example, a linear gradient's control vector is from (x0,y0) to
        /// (x1,y1) while a radial gradient's control vector is from any point
        /// on the start circle to the corresponding point on the end circle.
        ///
        /// The color is specified in the same way as in `ctx.setSourceRGB()`.
        ///
        /// If two (or more) stops are specified with identical offset values,
        /// they will be sorted according to the order in which the stops are
        /// added, (stops added earlier will compare less than stops added
        /// later). This can be useful for reliably making sharp color
        /// transitions instead of the typical blend.
        ///
        /// **Note:** If the pattern is not a gradient pattern, (eg. a linear
        /// or radial pattern), then the pattern will be put into an error
        /// status with a status of `cairo.Status.PatternTypeMismatch`, you
        /// don't have to worry about that unless you've casted a pointer from
        /// one pattern type into another, which you **SHOULDN'T**.
        ///
        /// **Parameters**
        /// - `offset`: an offset in the range [0.0 .. 1.0]
        /// - `red`: red component of color
        /// - `green`: green component of color
        /// - `blue`: blue component of color
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-add-color-stop-rgb)
        pub fn addColorStopRGB(self: *Self, offset: f64, red: f64, green: f64, blue: f64) void {
            cairo_pattern_add_color_stop_rgb(self, offset, red, green, blue);
        }

        /// Adds a translucent color stop to a gradient pattern. The offset
        /// specifies the location along the gradient's control vector. For
        /// example, a linear gradient's control vector is from (x0,y0) to
        /// (x1,y1) while a radial gradient's control vector is from any point
        /// on the start circle to the corresponding point on the end circle.
        ///
        /// The color is specified in the same way as in `ctx.setSourceRGBA()`.
        ///
        /// If two (or more) stops are specified with identical offset values,
        /// they will be sorted according to the order in which the stops are
        /// added, (stops added earlier will compare less than stops added
        /// later). This can be useful for reliably making sharp color
        /// transitions instead of the typical blend.
        ///
        /// **Note:** If the pattern is not a gradient pattern, (eg. a linear
        /// or radial pattern), then the pattern will be put into an error
        /// status with a status of `cairo.Status.PatternTypeMismatch`, you
        /// don't have to worry about that unless you've casted a pointer from
        /// one pattern type into another, which you **SHOULDN'T**.
        ///
        /// **Parameters**
        /// - `offset`: an offset in the range [0.0 .. 1.0]
        /// - `red`: red component of color
        /// - `green`: green component of color
        /// - `blue`: blue component of color
        /// - `alpha`: alpha component of color
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-add-color-stop-rgba)
        pub fn addColorStopRGBA(self: *Self, offset: f64, red: f64, green: f64, blue: f64, alpha: f64) void {
            cairo_pattern_add_color_stop_rgba(self, offset, red, green, blue, alpha);
        }

        /// A convenience function that gets all color stops and offsets for
        /// this `color.Gradient`. Don't forget to `.deinit()`.
        pub fn getColorStops(self: *Self, allocator: Allocator) CairoError!ArrayList(ColorStop) {
            const numStops = try self.getColorStopCount();
            var stops = try ArrayList(ColorStop).initCapacity(allocator, numStops);
            for (0..numStops) |n| {
                var stop: ColorStop = undefined;
                self.getColorStopRGBA(@intCast(n), &stop.offset, &stop.red, &stop.green, &stop.blue, &stop.alpha);
                stops.append(stop);
            }
            return stops;
        }

        /// Gets the number of color stops specified in the given gradient
        /// pattern.
        ///
        /// **Returns**
        ///
        /// value for the number of color stops or `error.PatternTypeMismatch`
        /// if `self` is not a gradient pattern, you don't have to worry about
        /// that unless you've casted a pointer from one pattern type into
        /// another, which you **SHOULDN'T**.
        ///
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-color-stop-count)
        pub fn getColorStopCount(self: *Self) CairoError!usize {
            var count: c_int = undefined;
            try cairo_pattern_get_color_stop_count(self, &count).toErr();
            return @intCast(count);
        }

        /// Gets the color and offset information at the given `index` for a
        /// gradient pattern. Values of `index` range from 0 to n-1 where n is the
        /// number returned by `pattern.getColorStopCount()`.
        ///
        /// **Parameters**
        /// - `index`: index of the stop to return data for
        /// - `offset`: return value for the offset of the stop, or `null`
        /// - `red`: return value for red component of color or `null`
        /// - `green`: return value for green component of color or `null`
        /// - `blue`: return value for blue component of color or `null`
        /// - `alpha`: return value for alpha component of color or `null`
        ///
        /// Possible errors are:
        /// - `InvalidIndex` if index is not valid for the given pattern.
        /// - `PatternTypeMismatch` (you don't have to worry about that unless
        /// you've casted a pointer from one pattern type into another, which
        /// you **SHOULDN'T**).
        ///
        /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-color-stop-rgba)
        pub fn getColorStopRGBA(self: *Self, index: c_int, offset: ?*f64, red: ?*f64, green: ?*f64, blue: ?*f64, alpha: ?*f64) CairoError!void {
            try cairo_pattern_get_color_stop_rgba(self, index, offset, red, green, blue, alpha).toErr();
        }
    };
}

pub const LinearGradientPattern = opaque {
    pub usingnamespace Gradient(@This());

    /// Create a new linear gradient `cairo.LinearGradientPattern` along the
    /// line defined by (x0, y0) and (x1, y1). Before using the gradient
    /// pattern, a number of color stops should be defined using
    /// `pattern.addColorStopRGB()` or `pattern.addColorStopRGBA()`.
    ///
    /// Note: The coordinates here are in pattern space. For a new pattern,
    /// pattern space is identical to user space, but the relationship between
    /// the spaces can be changed with `pattern.setMatrix()`.
    ///
    /// **Parameters**
    /// - `x0`: x coordinate of the start point
    /// - `y0`: y coordinate of the start point
    /// - `x1`: x coordinate of the end point
    /// - `y1`: y coordinate of the end point
    ///
    /// **Returns**
    ///
    /// the newly created `cairo.LinearGradientPattern` if successful, or an
    /// error in case of no memory.
    ///
    /// **NOTE**: The caller owns the returned object and should call
    /// `pattern.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const pattern = cairo.LinearGradientPattern.create(0, 0, 100, 100);
    /// defer pattern.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-linear)
    pub fn create(x0: f64, y0: f64, x1: f64, y1: f64) CairoError!*LinearGradientPattern {
        var pattern = cairo_pattern_create_linear(x0, y0, x1, y1).?;
        try pattern.status().toErr();
        return pattern;
    }

    /// Gets the gradient endpoints for a linear gradient.
    ///
    /// **Parameters**
    /// - `x0`: return value for the x coordinate of the first point, or `null`
    /// - `y0`: return value for the y coordinate of the first point, or `null`
    /// - `x1`: return value for the x coordinate of the second point, or
    /// `null`
    /// - `y1`: return value for the y coordinate of the second point, or
    /// `null`
    ///
    /// The only possible error is `error.PatternTypeMismatch`, you don't have
    /// to worry about that unless you've casted a pointer from one pattern
    /// type into another, which you **SHOULDN'T**.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-linear-points)
    pub fn getLinearPoints(self: *LinearGradientPattern, x0: ?*f64, y0: ?*f64, x1: ?*f64, y1: ?*f64) CairoError!void {
        try cairo_pattern_get_linear_points(self, x0, y0, x1, y1).toErr();
    }
};

pub const RadialGradientPattern = opaque {
    pub usingnamespace Gradient(@This());

    /// Creates a new radial gradient `cairo.RadialGradientPattern` between the
    /// two circles defined by (cx0, cy0, radius0) and (cx1, cy1, radius1).
    /// Before using the gradient pattern, a number of color stops should be
    /// defined using `pattern.addColorStopRGB()` or
    /// `pattern.addColorStopRGBA()`.
    ///
    /// Note: The coordinates here are in pattern space. For a new pattern,
    /// pattern space is identical to user space, but the relationship between
    /// the spaces can be changed with `pattern.setMatrix()`.
    ///
    /// **Parameters**
    /// - `cx0`: x coordinate for the center of the start circle
    /// - `cy0`: y coordinate for the center of the start circle
    /// - `radius0`: radius of the start circle
    /// - `cx1`: x coordinate for the center of the end circle
    /// - `cy1`: y coordinate for the center of the end circle
    /// - `radius1`: radius of the end circle
    ///
    /// **Returns**
    ///
    /// the newly created `cairo.RadialGradientPattern` if successful, or an
    /// error in case of no memory.
    ///
    /// **NOTE**: The caller owns the returned object and should call
    /// `pattern.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const pattern = cairo.RadialGradientPattern.create(0, 0, 10, 100, 100, 10);
    /// defer pattern.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-radial)
    pub fn create(cx0: f64, cy0: f64, radius0: f64, cx1: f64, cy1: f64, radius1: f64) CairoError!*RadialGradientPattern {
        var pattern = cairo_pattern_create_radial(cx0, cy0, radius0, cx1, cy1, radius1).?;
        try pattern.status().toErr();
        return pattern;
    }

    /// Gets the gradient endpoint circles for a radial gradient, each
    /// specified as a center coordinate and a radius.
    ///
    /// **Parameters**
    /// - `x0`: x coordinate for the center of the start circle
    /// - `y0`: y coordinate for the center of the start circle
    /// - `r0`: radius of the start circle
    /// - `x1`: x coordinate for the center of the end circle
    /// - `y1`: y coordinate for the center of the end circle
    /// - `r1`: radius of the end circle
    ///
    /// The only possible error is `error.PatternTypeMismatch`, you don't have
    /// to worry about that unless you've casted a pointer from one pattern
    /// type into another, which you **SHOULDN'T**.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-get-radial-circles)
    pub fn getRadialCircles(self: *RadialGradientPattern, x0: ?*f64, y0: ?*f64, r0: ?*f64, x1: ?*f64, y1: ?*f64, r1: ?*f64) CairoError!void {
        try cairo_pattern_get_radial_circles(self, x0, y0, r0, x1, y1, r1).toErr();
    }
};

/// Mesh patterns are tensor-product patch meshes (type 7 shadings in PDF).
/// Mesh patterns may also be used to create other types of shadings that
/// are special cases of tensor-product patch meshes such as Coons patch
/// meshes (type 6 shading in PDF) and Gouraud-shaded triangle meshes (type
/// 4 and 5 shadings in PDF).
///
/// Mesh patterns consist of one or more tensor-product patches, which
/// should be defined before using the mesh pattern. Using a mesh pattern
/// with a partially defined patch as source or mask will put the context
/// in an error status with a status of
/// `cairo.Status.InvalidMeshConstruction`.
///
/// A tensor-product patch is defined by 4 Bézier curves (side 0, 1, 2, 3)
/// and by 4 additional control points (P0, P1, P2, P3) that provide
/// further control over the patch and complete the definition of the
/// tensor-product patch. The corner C0 is the first point of the patch.
///
/// Degenerate sides are permitted so straight lines may be used. A zero
/// length line on one side may be used to create 3 sided patches.
/// ```code
///       C1     Side 1       C2
///        +---------------+
///        |               |
///        |  P1       P2  |
///        |               |
/// Side 0 |               | Side 2
///        |               |
///        |               |
///        |  P0       P3  |
///        |               |
///        +---------------+
///      C0     Side 3        C3
/// ```
/// Each patch is constructed by first calling `meshPattern.beginPatch()`, then
/// `meshPattern.moveTo()` to specify the first point in the patch (C0). Then
/// the sides are specified with calls to `meshPattern.curveTo()` and
/// `meshPattern.lineTo()`.
///
/// The four additional control points (P0, P1, P2, P3) in a patch can be
/// specified with `meshPattern.setControlPoint()`.
///
/// At each corner of the patch (C0, C1, C2, C3) a color may be specified with
/// `meshPattern.setCornerColorRGB()` or `meshPattern.setCornerColorRGBA()`.
/// Any corner whose color is not explicitly specified defaults to transparent
/// black.
///
/// A Coons patch is a special case of the tensor-product patch where the
/// control points are implicitly defined by the sides of the patch. The
/// default value for any control point not specified is the implicit value for
/// a Coons patch, i.e. if no control points are specified the patch is a Coons
/// patch.
///
/// A triangle is a special case of the tensor-product patch where the control
/// points are implicitly defined by the sides of the patch, all the sides are
/// lines and one of them has length 0, i.e. if the patch is specified using
/// just 3 lines, it is a triangle. If the corners connected by the 0-length
/// side have the same color, the patch is a Gouraud-shaded triangle.
///
/// Patches may be oriented differently to the above diagram. For example the
/// first point could be at the top left. The diagram only shows the
/// relationship between the sides, corners and control points. Regardless of
/// where the first point is located, when specifying colors, corner 0 will
/// always be the first point, corner 1 the point between side 0 and side 1
/// etc.
///
/// Calling `meshPattern.endPatch()` completes the current patch. If less than
/// 4 sides have been defined, the first missing side is defined as a line from
/// the current point to the first point of the patch (C0) and the other sides
/// are degenerate lines from C0 to C0. The corners between the added sides
/// will all be coincident with C0 of the patch and their color will be set to
/// be the same as the color of C0.
///
/// Additional patches may be added with additional calls to
/// `meshPattern.beginPatch()`/`meshPattern.endPatch().
/// ```zig
/// const meshPattern = cairo.MeshPattern.create();
///
/// // Add a Coons patch
/// meshPattern.beginPatch();
/// meshPattern.moveTo(0, 0);
/// meshPattern.curveTo(30, -30,  60,  30, 100, 0);
/// meshPattern.curveTo(60,  30, 130,  60, 100, 100);
/// meshPattern.curveTo(60,  70,  30, 130,   0, 100);
/// meshPattern.curveTo(30,  70, -30,  30,   0, 0);
/// meshPattern.setCornerColorRGB(0, 1, 0, 0);
/// meshPattern.setCornerColorRGB(1, 0, 1, 0);
/// meshPattern.setCornerColorRGB(2, 0, 0, 1);
/// meshPattern.setCornerColorRGB(3, 1, 1, 0);
/// meshPattern.endPatch();
///
/// // Add a Gouraud-shaded triangle
/// meshPattern.beginPatch();
/// meshPattern.moveTo(100, 100);
/// meshPattern.lineTo(130, 130);
/// meshPattern.lineTo(130,  70);
/// meshPattern.setCornerColorRGB(0, 1, 0, 0);
/// meshPattern.setCornerColorRGB(1, 0, 1, 0);
/// meshPattern.setCornerColorRGB(2, 0, 0, 1);
/// meshPattern.endPatch();
/// ```
///
/// When two patches overlap, the last one that has been added is drawn over
/// the first one.
///
/// When a patch folds over itself, points are sorted depending on their
/// parameter coordinates inside the patch. The v coordinate ranges from 0 to 1
/// when moving from side 3 to side 1; the u coordinate ranges from 0 to 1 when
/// going from side 0 to side 1. Points with higher v coordinate hide points
/// with lower v coordinate. When two points have the same v coordinate, the
/// one with higher u coordinate is above. This means that points nearer to
/// side 1 are above points nearer to side 3; when this is not sufficient to
/// decide which point is above (for example when both points belong to side 1
/// or side 3) points nearer to side 2 are above points nearer to side 0.
///
/// For a complete definition of tensor-product patches, see the PDF
/// specification (ISO32000), which describes the parametrization in detail.
///
/// Note: The coordinates are always in pattern space. For a new pattern,
/// pattern space is identical to user space, but the relationship between the
/// spaces can be changed with `pattern.setMatrix()`.
const MeshPattern = opaque {
    pub usingnamespace Mixin(@This());

    /// Create a new mesh pattern.
    ///
    /// **Returns**
    ///
    /// the newly created `cairo.MeshPattern` if successful, or an error in
    /// case of no memory.
    ///
    /// **NOTE**: The caller owns the returned object and should call
    /// `pattern.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const pattern = cairo.MeshPattern.create();
    /// defer pattern.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-mesh)
    pub fn create() CairoError!*MeshPattern {
        var pattern = cairo_pattern_create_mesh().?;
        try pattern.status().toErr();
        return pattern;
    }

    /// Begin a patch in a mesh pattern.
    ///
    /// After calling this function, the patch shape should be defined with
    /// `meshPattern.moveTo()`, `meshPattern.lineTo()` and
    /// `meshPattern.curveTo()`.
    ///
    /// After defining the patch, `meshPattern.endPatch()` must be called
    /// before using `pattern` as a source or mask.
    ///
    /// Note: If `self` is not a mesh pattern then `self` will be put into an
    /// error status with a status of `cairo.Status.PatternTypeMismatch`, you
    /// don't have to worry about that unless you've casted a pointer from one
    /// pattern type into another, which you **SHOULDN'T**. If `pattern`
    /// already has a current patch, it will be put into an error status with a
    /// status of `cairo.Status.InvalidMeshConstruction`.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-begin-patch)
    pub fn beginPatch(self: *MeshPattern) void {
        cairo_mesh_pattern_begin_patch(self);
    }

    // **Zig note**: you don't have to worry about that unless you cast pointers manually, which you **shouldn't**.

    /// Indicates the end of the current patch in a mesh pattern.
    ///
    /// If the current patch has less than 4 sides, it is closed with a
    /// straight line from the current point to the first point of the patch
    /// as if `meshPattern.lineTo()` was used.
    ///
    /// Note: If `self` is not a mesh pattern then `self` will be put into an
    /// error status with a status of `cairo.Status.PatternTypeMismatch`,
    /// you don't have to worry about that unless you've casted a pointer from
    /// one pattern type into another, which you **SHOULDN'T**. If `pattern`has
    /// no current patch or the current patch has no current point, `pattern`
    /// will be put into an error status with a status of
    /// `cairo.Status.InvalidMeshConstruction`.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-end-patch)
    pub fn endPatch(self: *MeshPattern) void {
        cairo_mesh_pattern_end_patch(self);
    }

    /// Define the first point of the current patch in a mesh pattern.
    ///
    /// After this call the current point will be `(x, y)`.
    ///
    /// Note: If `self` is not a mesh pattern then `self` will be put into an
    /// error status with a status of `cairo.Status.PatternTypeMismatch`, you
    /// don't have to worry about that unless you've casted a pointer from one
    /// pattern type into another, which you **SHOULDN'T**. If `pattern` has no
    /// current patch or the current patch already has at least one side,
    /// `pattern` will be put into an error status with a status of
    /// `cairo.Status.InvalidMeshConstruction`.
    ///
    /// **Parameters**
    /// - `x`: the X coordinate of the new position
    /// - `y`: the Y coordinate of the new position
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-move-to)
    pub fn moveTo(self: *MeshPattern, x: f64, y: f64) void {
        cairo_mesh_pattern_move_to(self, x, y);
    }

    /// Adds a line to the current patch from the current point to position
    /// `(x, y)` in pattern-space coordinates.
    ///
    /// If there is no current point before the call to `meshPattern.lineTo()`
    /// this function will behave as `meshPattern.moveTo(x, y)`.
    ///
    /// After this call the current point will be `(x, y)`.
    ///
    /// Note: If `self` is not a mesh pattern then `self` will be put into an
    /// error status with a status of `cairo.Status.PatternTypeMismatch`, you
    /// don't have to worry about that unless you've casted a pointer from one
    /// pattern type into another, which you **SHOULDN'T**. If `pattern` has no
    /// current patch or the current patch already has 4 sides, `pattern` will
    /// be put into an error status with a status of
    /// `cairo.Status.InvalidMeshConstruction`.
    ///
    /// **Parameters**
    /// - `x`: the X coordinate of the end of the new line
    /// - `y`: the Y coordinate of the end of the new line
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-line-to)
    pub fn lineTo(self: *MeshPattern, x: f64, y: f64) void {
        cairo_mesh_pattern_line_to(self, x, y);
    }

    /// Adds a cubic Bézier spline to the current patch from the current point
    /// to position `(x3, y3)` in pattern-space coordinates, using `(x1, y1)`
    /// and `(x2, y2)` as the control points.
    ///
    /// If the current patch has no current point before the call to
    /// `meshPattern.curveTo()`, this function will behave as if preceded by a
    /// call to `meshPattern.moveTo(x1, y1)`.
    ///
    /// After this call the current point will be `(x3, y3)`.
    ///
    /// Note: If `self` is not a mesh pattern then `self` will be put into an
    /// error status with a status of `cairo.Status.PatternTypeMismatch`, you
    /// don't have to worry about that unless you've casted a pointer from one
    /// pattern type into another, which you **SHOULDN'T**. If `pattern` has no
    /// current patch or the current patch already has 4 sides, `pattern` will
    /// be put into an error status with a status of
    /// `cairo.Status.InvalidMeshConstruction`.
    ///
    /// **Parameters**
    /// - `x1`: the X coordinate of the first control point
    /// - `y1`: the Y coordinate of the first control point
    /// - `x2`: the X coordinate of the second control point
    /// - `y2`: the Y coordinate of the second control point
    /// - `x3`: the X coordinate of the end of the curve
    /// - `y3`: the Y coordinate of the end of the curve
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-curve-to)
    pub fn curveTo(self: *MeshPattern, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) void {
        cairo_mesh_pattern_curve_to(self, x1, y1, x2, y2, x3, y3);
    }

    /// Set an internal control point of the current patch.
    ///
    /// Valid values for pointNum are from 0 to 3 and identify the control
    /// points as explained in documentation to `cairo.MeshPattern`.
    ///
    /// Note: If `self` is not a mesh pattern then `self` will be put into an
    /// error status with a status of `cairo.Status.PatternTypeMismatch`, you
    /// don't have to worry about that unless you've casted a pointer from one
    /// pattern type into another, which you **SHOULDN'T**. If `pattern` has no
    /// current patch, `pattern` will be put into an error status with a status
    /// of `cairo.Status.InvalidMeshConstruction`.
    ///
    /// **Parameters**
    /// - `pointNum`: the control point to set the position for
    /// - `point`: the control point
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-set-control-point)
    pub fn setControlPoint(self: *MeshPattern, pointNum: c_uint, point: Point) void {
        cairo_mesh_pattern_set_control_point(self, pointNum, point.x, point.y);
    }

    /// Sets the color of a corner of the current patch in a mesh pattern.
    ///
    /// The color is specified in the same way as in
    /// `cairo.Context.setSourceRGB()`.
    ///
    /// Valid values for cornerNum are from 0 to 3 and identify the corners as
    /// explained in documentation to `cairo.MeshPattern`.
    ///
    /// Note: If `self` is not a mesh pattern then `self` will be put into an
    /// error status with a status of `cairo.Status.PatternTypeMismatch`, you
    /// don't have to worry about that unless you've casted a pointer from one
    /// pattern type into another, which you **SHOULDN'T**. If `cornerNum` is
    /// not valid, pattern will be put into an error status with a status of
    /// `cairo.Status.InvalidIndex`. If pattern has no current patch, pattern
    /// will be put into an error status with a status of
    /// `cairo.Status.InvalidMeshConstruction`.
    ///
    /// **Parameters**
    /// - `cornerNum`: the corner to set the color for
    /// - `red`: red component of color
    /// - `green`: green component of color
    /// - `blue`: blue component of color
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-set-corner-color-rgb)
    pub fn setCornerColorRGB(self: *MeshPattern, cornerNum: c_uint, red: f64, green: f64, blue: f64) void {
        cairo_mesh_pattern_set_corner_color_rgb(self, cornerNum, red, green, blue);
    }

    /// Sets the color of a corner of the current patch in a mesh pattern.
    ///
    /// The color is specified in the same way as in
    /// `cairo.Context.setSourceRGBA()`.
    ///
    /// Valid values for cornerNum are from 0 to 3 and identify the corners as
    /// explained in documentation to `cairo.MeshPattern`.
    ///
    /// Note: If `self` is not a mesh pattern then `self` will be put into an
    /// error status with a status of `cairo.Status.PatternTypeMismatch`, you
    /// don't have to worry about that unless you've casted a pointer from one
    /// pattern type into another, which you **SHOULDN'T**. If `cornerNum` is
    /// not valid, pattern will be put into an error status with a status of
    /// `cairo.Status.InvalidIndex`. If pattern has no current patch, pattern
    /// will be put into an error status with a status of
    /// `cairo.Status.InvalidMeshConstruction`.
    ///
    /// **Parameters**
    /// - `cornerNum`: the corner to set the color for
    /// - `red`: red component of color
    /// - `green`: green component of color
    /// - `blue`: blue component of color
    /// - `alpha`: alpha component of color
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-set-corner-color-rgba)
    pub fn setCornerColorRGBA(self: *MeshPattern, corner_num: c_uint, red: f64, green: f64, blue: f64, alpha: f64) void {
        cairo_mesh_pattern_set_corner_color_rgba(self, corner_num, red, green, blue, alpha);
    }

    /// Gets the number of patches specified in the given mesh pattern.
    ///
    /// The number only includes patches which have been finished by calling
    /// `meshPattern.endPatch()`. For example it will be 0 during the
    /// definition of the first patch.
    ///
    /// **Returns**
    ///
    /// the number of patches.
    ///
    /// The only possible error is `error.PatternTypeMismatch`, you don't have
    /// to worry about that unless you've casted a pointer from one pattern
    /// type into another, which you **SHOULDN'T**.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-get-patch-count)
    pub fn getPatchCount(self: *MeshPattern) CairoError!usize {
        var count: c_uint = undefined;
        try cairo_mesh_pattern_get_patch_count(self, &count).toErr();
        return @intCast(count);
    }

    /// Gets path defining the patch `patchNum` for a mesh pattern.
    ///
    /// `patch_num` can range from 0 to n-1 where n is the number returned by
    /// `meshPattern.getPatchCount()`.
    ///
    /// **Parameters**
    /// - `patchNum`: the patch number to return data for
    ///
    /// **Returns**
    ///
    /// the path defining the patch, or a path with status
    /// `cairo.Status.InvalidIndex` if `patchNum` is not valid for `pattern`.
    /// If `pattern` is not a mesh pattern, a path with status
    /// `cairo.Status.PatternTypeMismatch` is returned, you don't have to worry
    /// about that unless you've casted a pointer from one pattern type into
    /// another, which you **SHOULDN'T**.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-get-path)
    pub fn getPath(self: *MeshPattern, patchNum: u32) *Path {
        return cairo_mesh_pattern_get_path(self, @intCast(patchNum)).?;
    }

    /// Gets the control point `pointNum` of patch `patchNum` for a mesh
    /// pattern.
    ///
    /// `patchNum` can range from 0 to n-1 where n is the number returned by
    /// `meshPattern.getPatchCount()`.
    ///
    /// Valid values for pointNum are from 0 to 3 and identify the control
    /// points as explained in documentation to `cairo.MeshPattern`.
    ///
    /// **Parameters**
    /// - `patchNum`: the patch number to return data for
    /// - `pointNum`: the control point number to return data for
    ///
    /// **Returns**
    ///
    /// coordinates of the control point.
    ///
    /// Possible errors are: `error.InvalidIndex` if `patchNum` or `pointNum`
    /// is not valid for `self` and `error.PatternTypeMismatch` (you don't have
    /// to worry about that unless you've casted a pointer from one pattern
    /// type into another, which you **SHOULDN'T**).
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-get-control-point)
    pub fn getControlPoint(self: *MeshPattern, patchNum: u32, pointNum: u32) CairoError!Point {
        // TODO: check if undefined is problematic here
        var point: Point = undefined;
        try cairo_mesh_pattern_get_control_point(self, @intCast(patchNum), @intCast(pointNum), &point.x, &point.y).toErr();
        return point;
    }

    /// Gets the color information in corner `cornerNum` of patch `patchNum`
    /// for a mesh pattern.
    ///
    /// `patchNum` can range from 0 to n-1 where n is the number returned by
    /// `meshPattern.getPatchCount()`.
    ///
    /// Valid values for pointNum are from 0 to 3 and identify the control
    /// points as explained in documentation to `cairo.MeshPattern`.
    ///
    /// **Parameters**
    /// - `patchNum`: the patch number to return data for
    /// - `cornerNum`: the corner number to return data for
    /// - `red`: return value for red component of color, or `null`
    /// - `green`: return value for green component of color, or `null`
    /// - `blue`: return value for blue component of color, or `null`
    /// - `alpha`: return value for alpha component of color, or `null`
    ///
    /// Possible errors are: `error.InvalidIndex` if `patchNum` or `cornerNum`
    /// is not valid for `self` and `error.PatternTypeMismatch` (you don't have
    /// to worry about that unless you've casted a pointer from one pattern
    /// type into another, which you **SHOULDN'T**).
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-mesh-pattern-get-corner-color-rgba)
    pub fn getCornerColorRGBA(self: *MeshPattern, patchNum: u32, cornerNum: u32, red: ?*f64, green: ?*f64, blue: ?*f64, alpha: ?*f64) CairoError!void {
        try cairo_mesh_pattern_get_corner_color_rgba(self, @intCast(patchNum), @intCast(cornerNum), red, green, blue, alpha).toErr();
    }
};

/// Raster Sources — Supplying arbitrary image data
///
/// The raster source provides the ability to supply arbitrary pixel data
/// whilst rendering. The pixels are queried at the time of rasterisation by
/// means of user callback functions, allowing for the ultimate flexibility.
/// For example, in handling compressed image sources, you may keep a MRU cache
/// of decompressed images and decompress sources on the fly and discard old
/// ones to conserve memory.
///
/// For the raster source to be effective, you must at least specify the
/// acquire and release callbacks which are used to retrieve the pixel data for
/// the region of interest and demark when it can be freed afterwards. Other
/// callbacks are provided for when the pattern is copied temporarily during
/// rasterisation, or more permanently as a snapshot in order to keep the pixel
/// data available for printing.
pub const RasterSourcePattern = opaque {
    pub usingnamespace Mixin(@This());

    /// Creates a new user pattern for providing pixel data.
    ///
    /// Use the setter functions to associate callbacks with the returned pattern.
    /// The only mandatory callback is acquire.
    ///
    /// **Parameters**
    /// - `userData`: the user data to be passed to all callbacks
    /// - `content`: content type for the pixel data that will be returned. Knowing
    /// the content type ahead of time is used for analysing the operation and
    /// picking the appropriate rendering path.
    /// - `width`: maximum size of the sample area
    /// - `height`: maximum size of the sample area
    ///
    /// **Returns**
    ///
    /// a newly created `cairo.RasterSourcePattern`.
    ///
    /// **NOTE**: The caller owns the returned object and should call
    /// `pattern.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const pattern = cairo.RasterSourcePattern.create(...);
    /// defer pattern.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-pattern-create-raster-source)
    pub fn create(userData: ?*anyopaque, content: Content, width: c_int, height: c_int) CairoError!*Pattern {
        // TODO: fix doc example
        const pattern = cairo_pattern_create_raster_source(userData, content, width, height).?;
        try pattern.status().toErr();
        return pattern;
    }

    /// Updates the user data that is provided to all callbacks.
    ///
    /// **Parameters**
    /// - `data`: the user data to be passed to all callbacks
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-pattern-set-callback-data)
    pub fn setFallbackData(self: *RasterSourcePattern, data: ?*anyopaque) void {
        cairo_raster_source_pattern_set_callback_data(self, data);
    }

    /// Queries the current user data.
    ///
    /// **Returns**
    ///
    /// the current user-data passed to each callback
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-pattern-get-callback-data)
    pub fn getFallbackData(self: *RasterSourcePattern) ?*anyopaque {
        return cairo_raster_source_pattern_get_callback_data(self);
    }

    /// Specifies the callbacks used to generate the image surface for a
    /// rendering operation (acquire) and the function used to cleanup that
    /// surface afterwards.
    ///
    /// The `acquire` callback should create a surface (preferably an image
    /// surface created to match the target using
    /// `cairo.Surface.createSimilarImage()`) that defines at least the region
    /// of interest specified by extents. The surface is allowed to be the
    /// entire sample area, but if it does contain a subsection of the sample
    /// area, the surface extents should be provided by setting the device
    /// offset (along with its width and height) using
    /// `cairo.Surface.setDeviceOffset()`.
    ///
    /// **Parameters**
    /// - `acquire`: the acquire callback
    /// - `release`: the release callback
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-pattern-set-acquire)
    pub fn setAcquire(self: *RasterSourcePattern, acquire: RasterSourcePattern.AcquireFn, release: RasterSourcePattern.ReleaseFn) void {
        cairo_raster_source_pattern_set_acquire(self, acquire, release);
    }

    /// Queries the current acquire and release callbacks.
    ///
    /// **Parameters**
    /// - `acquire`: return value for the current acquire callback
    /// - `release`: return value for the current release callback
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-pattern-get-acquire)
    pub fn getAcquire(self: *RasterSourcePattern, acquire: *RasterSourcePattern.AcquireFn, release: *RasterSourcePattern.ReleaseFn) void {
        cairo_raster_source_pattern_get_acquire(self, acquire, release);
    }

    /// Sets the callback that will be used whenever a snapshot is taken of the
    /// pattern, that is whenever the current contents of the pattern should be
    /// preserved for later use. This is typically invoked whilst printing.
    ///
    /// **Parameters**
    /// - `snapshot`: the snapshot callback
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-pattern-set-snapshot)
    pub fn setSnapshot(self: *RasterSourcePattern, snapshot: RasterSourcePattern.SnapshotFn) void {
        cairo_raster_source_pattern_set_snapshot(self, snapshot);
    }

    /// Queries the current snapshot callback.
    ///
    /// **Returns**
    ///
    /// the current snapshot callback.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-pattern-get-snapshot)
    pub fn getSnapshot(self: *RasterSourcePattern) RasterSourcePattern.SnapshotFn {
        return cairo_raster_source_pattern_get_snapshot(self);
    }

    /// Updates the copy callback which is used whenever a temporary copy of
    /// the pattern is taken.
    ///
    /// **Parameters**
    /// - `copy`: the copy callback
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-pattern-set-copy)
    pub fn setCopy(self: *RasterSourcePattern, copy: RasterSourcePattern.CopyFn) void {
        cairo_raster_source_pattern_set_copy(self, copy);
    }

    /// Queries the current copy callback.
    ///
    /// **Returns**
    ///
    /// the current copy callback.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-pattern-get-copy)
    pub fn getCopy(self: *RasterSourcePattern) RasterSourcePattern.CopyFn {
        return cairo_raster_source_pattern_get_copy(self);
    }

    /// Updates the finish callback which is used whenever a pattern (or a copy
    /// thereof) will no longer be used.
    ///
    /// **Parameters**
    /// - `copy`: the finish callback
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-pattern-set-finish)
    pub fn setFinish(self: *RasterSourcePattern, finish: RasterSourcePattern.FinishFn) void {
        cairo_raster_source_pattern_set_finish(self, finish);
    }

    /// Queries the current finish callback.
    ///
    /// **Returns**
    ///
    /// the current finish callback.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-pattern-get-finish)
    pub fn getFinish(self: *RasterSourcePattern) RasterSourcePattern.FinishFn {
        return cairo_raster_source_pattern_get_finish(self);
    }

    /// `cairo.RasterSourcePattern.AcquireFn` is the type of function which is
    /// called when a pattern is being rendered from. It should create a
    /// surface that provides the pixel data for the region of interest as
    /// defined by extents, though the surface itself does not have to be
    /// limited to that area. For convenience the surface should probably be of
    /// image type, created with `cairo.Surface.createSimilarImage()` for the
    /// target (which enables the number of copies to be reduced during
    /// transfer to the device). Another option, might be to return a similar
    /// surface to the target for explicit handling by the application of a set
    /// of cached sources on the device. The region of sample data provided
    /// should be defined using `cairo.Surface.setDeviceOffset()` to specify
    /// the top-left corner of the sample data (along with width and height of
    /// the surface).
    ///
    /// **Parameters**
    /// - `pattern`: the pattern being rendered from
    /// - `callbackData`: the user data supplied during creation
    /// - `target`: the rendering target surface
    /// - `extents`: rectangular region of interest in pixels in sample space
    ///
    /// **Returns**
    ///
    /// a `cairo.Surface`
    ///
    /// [Lnk to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-acquire-func-t)
    pub const AcquireFn = *const fn (pattern: ?*Pattern, callbackData: ?*anyopaque, target: ?*Surface, extents: ?*const RectangleInt) callconv(.C) ?*Surface;

    /// `cairo.RasterSourcePattern.ReleaseFn` is the type of function which is
    /// called when the pixel data is no longer being access by the pattern for
    /// the rendering operation. Typically this function will simply destroy
    /// the surface created during acquire.
    ///
    /// **Parameters**
    /// - `pattern`: the pattern being rendered from
    /// - `callbackData`: the user data supplied during creation
    /// - `surface`: the surface created during acquire
    ///
    /// [Lnk to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-release-func-t)
    pub const ReleaseFn = ?*const fn (pattern: ?*Pattern, callbackData: ?*anyopaque, surface: ?*Surface) callconv(.C) void;

    /// `cairo.RasterSourcePattern.SnapshotFn` is the type of function which is
    /// called when the pixel data needs to be preserved for later use during
    /// printing. This pattern will be accessed again later, and it is expected
    /// to provide the pixel data that was current at the time of snapshotting.
    ///
    /// **Parameters**
    /// - `pattern`: the pattern being rendered from
    /// - `callbackData`: the user data supplied during creation
    ///
    /// **Returns**
    ///
    /// `cairo.Status.Success` on success, or one of the `cairo.Status` error
    /// codes for failure.
    ///
    /// [Lnk to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-snapshot-func-t)
    pub const SnapshotFn = ?*const fn (pattern: ?*Pattern, callbackData: ?*anyopaque) callconv(.C) Status;

    /// `cairo.RasterSourcePattern.CopyFn` is the type of function which is
    /// called when the pattern gets copied as a normal part of rendering.
    ///
    /// **Parameters**
    /// - `pattern`: the `cairo.Pattern` that was copied to
    /// - `callbackData`: the user data supplied during creation
    /// - `other`: the `cairo.Pattern` being used as the source for the copy
    ///
    /// **Returns**
    ///
    /// `cairo.Status.Success` on success, or one of the `cairo.Status` error
    /// codes for failure.
    ///
    /// [Lnk to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-copy-func-t)
    pub const CopyFn = ?*const fn (pattern: ?*Pattern, callbackData: ?*anyopaque, other: ?*const Pattern) callconv(.C) Status;

    /// `cairo.RasterSourcePattern.SnapshotFn` is the type of function which is
    /// called when the pattern (or a copy thereof) is no longer required.
    ///
    /// **Parameters**
    /// - `pattern`: the pattern being rendered from
    /// - `callbackData`: the user data supplied during creation
    ///
    /// [Lnk to Cairo manual](https://www.cairographics.org/manual/cairo-Raster-Sources.html#cairo-raster-source-finish-func-t)
    pub const FinishFn = ?*const fn (pattern: ?*Pattern, callbackData: ?*anyopaque) callconv(.C) void;
};

/// Holds info about color stop for gradient patterns
pub const ColorStop = struct {
    offset: f64,
    red: f64,
    green: f64,
    blue: f64,
    alpha: f64,
};

extern fn cairo_pattern_add_color_stop_rgb(pattern: ?*anyopaque, offset: f64, red: f64, green: f64, blue: f64) void;
extern fn cairo_pattern_add_color_stop_rgba(pattern: ?*anyopaque, offset: f64, red: f64, green: f64, blue: f64, alpha: f64) void;
extern fn cairo_pattern_get_color_stop_count(pattern: ?*anyopaque, count: [*c]c_int) Status;
extern fn cairo_pattern_get_color_stop_rgba(pattern: ?*anyopaque, index: c_int, offset: [*c]f64, red: [*c]f64, green: [*c]f64, blue: [*c]f64, alpha: [*c]f64) Status;
extern fn cairo_pattern_create_rgb(red: f64, green: f64, blue: f64) ?*SolidPattern;
extern fn cairo_pattern_create_rgba(red: f64, green: f64, blue: f64, alpha: f64) ?*SolidPattern;
extern fn cairo_pattern_get_rgba(pattern: ?*SolidPattern, red: [*c]f64, green: [*c]f64, blue: [*c]f64, alpha: [*c]f64) Status;
extern fn cairo_pattern_create_for_surface(surface: ?*Surface) ?*SurfacePattern;
extern fn cairo_pattern_get_surface(pattern: ?*SurfacePattern, surface: [*c]?*Surface) Status;
extern fn cairo_pattern_create_linear(x0: f64, y0: f64, x1: f64, y1: f64) ?*LinearGradientPattern;
extern fn cairo_pattern_get_linear_points(pattern: ?*LinearGradientPattern, x0: [*c]f64, y0: [*c]f64, x1: [*c]f64, y1: [*c]f64) Status;
extern fn cairo_pattern_create_radial(cx0: f64, cy0: f64, radius0: f64, cx1: f64, cy1: f64, radius1: f64) ?*RadialGradientPattern;
extern fn cairo_pattern_get_radial_circles(pattern: ?*RadialGradientPattern, x0: [*c]f64, y0: [*c]f64, r0: [*c]f64, x1: [*c]f64, y1: [*c]f64, r1: [*c]f64) Status;
extern fn cairo_pattern_create_mesh() ?*MeshPattern;
extern fn cairo_mesh_pattern_begin_patch(pattern: ?*MeshPattern) void;
extern fn cairo_mesh_pattern_end_patch(pattern: ?*MeshPattern) void;
extern fn cairo_mesh_pattern_move_to(pattern: ?*MeshPattern, x: f64, y: f64) void;
extern fn cairo_mesh_pattern_line_to(pattern: ?*MeshPattern, x: f64, y: f64) void;
extern fn cairo_mesh_pattern_curve_to(pattern: ?*MeshPattern, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) void;
extern fn cairo_mesh_pattern_set_control_point(pattern: ?*MeshPattern, point_num: c_uint, x: f64, y: f64) void;
extern fn cairo_mesh_pattern_set_corner_color_rgb(pattern: ?*MeshPattern, corner_num: c_uint, red: f64, green: f64, blue: f64) void;
extern fn cairo_mesh_pattern_set_corner_color_rgba(pattern: ?*MeshPattern, corner_num: c_uint, red: f64, green: f64, blue: f64, alpha: f64) void;
extern fn cairo_mesh_pattern_get_patch_count(pattern: ?*MeshPattern, count: [*c]c_uint) Status;
extern fn cairo_mesh_pattern_get_path(pattern: ?*MeshPattern, patch_num: c_uint) [*c]Path;
extern fn cairo_mesh_pattern_get_control_point(pattern: ?*MeshPattern, patch_num: c_uint, point_num: c_uint, x: [*c]f64, y: [*c]f64) Status;
extern fn cairo_mesh_pattern_get_corner_color_rgba(pattern: ?*MeshPattern, patch_num: c_uint, corner_num: c_uint, red: [*c]f64, green: [*c]f64, blue: [*c]f64, alpha: [*c]f64) Status;
extern fn cairo_pattern_reference(pattern: ?*anyopaque) ?*anyopaque;
extern fn cairo_pattern_destroy(pattern: ?*anyopaque) void;
extern fn cairo_pattern_status(pattern: ?*anyopaque) Status;
extern fn cairo_pattern_set_extend(pattern: ?*anyopaque, extend: Extend) void;
extern fn cairo_pattern_get_extend(pattern: ?*anyopaque) Extend;
extern fn cairo_pattern_set_filter(pattern: ?*anyopaque, filter: Filter) void;
extern fn cairo_pattern_get_filter(pattern: ?*anyopaque) Filter;
extern fn cairo_pattern_set_matrix(pattern: ?*anyopaque, matrix: [*c]const Matrix) void;
extern fn cairo_pattern_get_matrix(pattern: ?*anyopaque, matrix: [*c]Matrix) void;
extern fn cairo_pattern_get_type(pattern: ?*anyopaque) PatternType;
extern fn cairo_pattern_get_reference_count(pattern: ?*anyopaque) c_uint;
extern fn cairo_pattern_set_user_data(pattern: ?*anyopaque, key: [*c]const UserDataKey, user_data: ?*anyopaque, destroy: DestroyFn) Status;
extern fn cairo_pattern_get_user_data(pattern: ?*anyopaque, key: [*c]const UserDataKey) ?*anyopaque;
extern fn cairo_pattern_create_raster_source(user_data: ?*anyopaque, content: Content, width: c_int, height: c_int) ?*Pattern;
extern fn cairo_raster_source_pattern_set_callback_data(pattern: ?*RasterSourcePattern, data: ?*anyopaque) void;
extern fn cairo_raster_source_pattern_get_callback_data(pattern: ?*RasterSourcePattern) ?*anyopaque;
extern fn cairo_raster_source_pattern_set_acquire(pattern: ?*RasterSourcePattern, acquire: RasterSourcePattern.AcquireFn, release: RasterSourcePattern.ReleaseFn) void;
extern fn cairo_raster_source_pattern_get_acquire(pattern: ?*RasterSourcePattern, acquire: [*c]RasterSourcePattern.AcquireFn, release: [*c]RasterSourcePattern.ReleaseFn) void;
extern fn cairo_raster_source_pattern_set_snapshot(pattern: ?*RasterSourcePattern, snapshot: RasterSourcePattern.SnapshotFn) void;
extern fn cairo_raster_source_pattern_get_snapshot(pattern: ?*RasterSourcePattern) RasterSourcePattern.SnapshotFn;
extern fn cairo_raster_source_pattern_set_copy(pattern: ?*RasterSourcePattern, copy: RasterSourcePattern.CopyFn) void;
extern fn cairo_raster_source_pattern_get_copy(pattern: ?*RasterSourcePattern) RasterSourcePattern.CopyFn;
extern fn cairo_raster_source_pattern_set_finish(pattern: ?*RasterSourcePattern, finish: RasterSourcePattern.FinishFn) void;
extern fn cairo_raster_source_pattern_get_finish(pattern: ?*RasterSourcePattern) RasterSourcePattern.FinishFn;
