//! SVG Surfaces — Rendering SVG documents
//!
//! The SVG surface is used to render cairo graphics to SVG files and is a
//! multi-page vector surface backend.
//!
//! [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html)

const std = @import("std");
const testing = std.testing;
const util = @import("../util.zig");
const safety = @import("../safety.zig");

const base = @import("base.zig");

const Mixin = base.Base;
const Status = @import("../enums.zig").Status;
const CairoError = @import("../enums.zig").CairoError;
const WriteFn = util.WriteFn;

/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html)
pub const SvgSurface = opaque {
    pub usingnamespace Mixin(SvgSurface);

    /// Creates a SVG surface of the specified size in points to be written to
    /// `filename`.
    ///
    /// The SVG surface backend recognizes the following MIME types
    /// (`cairo.Surface.MimeType`) for the data attached to a surface (see
    /// `cairo.Surface.setMimeData()`) when it is used as a source pattern for
    /// drawing on this surface: `.Jpeg`, `.Png`, `.Uri` If any of them is
    /// specified, the SVG backend emits a href with the content of MIME data
    /// instead of a surface snapshot (PNG, Base64-encoded) in the
    /// corresponding image tag.
    ///
    /// The unofficial MIME type `.Uri` is examined first. If
    /// present, the URI is emitted as is: assuring the correctness of URI is
    /// left to the client code.
    ///
    /// If `cairo.Surface.MimeType.Uri` is not present, but `.Jpeg` or `.Png`
    /// is specified, the corresponding data is Base64-encoded and emitted.
    ///
    /// If `cairo.Surface.MimeType.UniqueID` is present, all surfaces with the
    /// same unique identifier will only be embedded once.
    ///
    /// **Parameters**
    /// - `filename`: a filename for the SVG output (must be writable), `null`
    /// may be used to specify no output. This will generate a SVG surface that
    /// may be queried and used as a source, without generating a temporary
    /// file.
    /// - `width_in_points`: width of the surface, in points (1 point == 1/72.0
    /// inch)
    /// - `height_in_points`: height of the surface, in points (1 point ==
    /// 1/72.0 inch)
    ///
    /// **Returns**
    ///
    /// a pointer to the newly created surface.
    /// **NOTE**: The caller owns the created surface and should call
    /// `surface.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const surface = cairo.SvgSurface.create("file.svg", 100.0, 100.0);
    /// defer surface.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-create)
    pub fn create(filename: [:0]const u8, width: f64, height: f64) CairoError!*SvgSurface {
        const svg = cairo_svg_surface_create(filename.ptr, width, height).?;
        try svg.status().toErr();
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), svg);
        return svg;
    }

    /// Creates a SVG surface of the specified size in points to be written
    /// incrementally to the `writer` stream.
    ///
    /// **Parameters**
    /// - `writer`: pointer to a writeable object, e.g. `std.io.Writer` or
    /// `std.fs.File` (it should have a `.writeAll()` function)
    /// - `width`: width of the surface, in points (1 point == 1/72.0 inch)
    /// - `height`: height of the surface, in points (1 point == 1/72.0 inch)
    ///
    /// **Returns**
    ///
    /// a pointer to the newly created surface.
    /// **NOTE**: The caller owns the surface and should call
    /// `surface.destroy()` when done with it.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-create-for-stream)
    pub fn createForStream(writer: anytype, width: f64, height: f64) CairoError!*SvgSurface {
        const writeFn = util.createWriteFn(@TypeOf(writer));
        const svg = cairo_svg_surface_create_for_stream(writeFn, writer, width, height) orelse return error.SvgSurfaceNull;
        try svg.status().toErr();
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), svg);
        return svg;
    }

    /// Get the unit of the SVG surface.
    ///
    /// If the surface passed as an argument is not a SVG surface, the function
    /// sets the error status to `cairo.Status.SURFACE_TYPE_MISMATCH` and
    /// returns `cairo.SvgUnit.user`
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-get-document-unit)
    pub fn getDocumentUnit(self: *SvgSurface) SvgUnit {
        return cairo_svg_surface_get_document_unit(self);
    }

    /// Use the specified unit for the width and height of the generated SVG
    /// file. See `cairo.SvgUnit` for a list of available unit values that can
    /// be used here.
    ///
    /// This function can be called at any time before generating the SVG file.
    ///
    /// However **to minimize the risk of ambiguities it's recommended to call
    /// it before any drawing operations have been performed on the given
    /// surface**, to make it clearer what the unit used in the drawing
    /// operations is.
    ///
    /// The simplest way to do this is to call this function immediately after
    /// creating the SVG surface.
    ///
    /// Note if this function is never called, the default unit for SVG
    /// documents generated by cairo will be "pt". This is for historical
    /// reasons.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-set-document-unit)
    pub fn setDocumentUnit(self: *SvgSurface, unit: SvgUnit) void {
        cairo_svg_surface_set_document_unit(self, unit);
    }

    /// Restricts the generated SVG file to `version`. See
    /// `cairo.getSvgVersions()` for a list of available version values that
    /// can be used here.
    ///
    /// **This function should only be called before any drawing operations
    /// have been performed on the given surface.** The simplest way to do this
    /// is to call this function immediately after creating the surface.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-restrict-to-version)
    pub fn restrictToVersion(self: *SvgSurface, version: SvgVersion) void {
        cairo_svg_surface_restrict_to_version(self, version);
    }
};

/// `cairo.SvgUnit` is used to describe the units valid for coordinates and
/// lengths in the SVG specification.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-unit-t)
pub const SvgUnit = enum(c_uint) {
    /// User unit, a value in the current coordinate system. If used in the
    /// root element for the initial coordinate systems it corresponds to
    /// pixels.
    user = 0,
    /// The size of the element's font.
    em,
    /// The x-height of the element’s font
    ex,
    /// Pixels (1px = 1/96th of 1in).
    px,
    /// Inches (1in = 2.54cm = 96px).
    in,
    /// Centimeters (1cm = 96px/2.54).
    cm,
    /// Millimeters (1mm = 1/10th of 1cm).
    mm,
    /// Points (1pt = 1/72th of 1in).
    pt,
    /// Picas (1pc = 1/6th of 1in).
    pc,
    /// Percent, a value that is some fraction of another reference value.
    percent,
};

/// Used to retrieve the list of supported SVG versions. See
/// `cairo.SvgSurface.restrictToVersion()`
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-get-versions)
pub fn getSvgVersions() []const SvgVersion {
    var ptr: [*c]SvgVersion = undefined;
    var numVersions: c_int = undefined;
    cairo_svg_get_versions(@ptrCast(&ptr), &numVersions);
    return ptr[0..@as(usize, @intCast(numVersions))];
    // TODO
}

/// `cairo.SvgVersion` is used to describe the version number of the SVG
/// specification that a generated SVG file will conform to.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-version-t)
pub const SvgVersion = enum(c_uint) {
    @"1.1",
    @"1.2",

    /// Get the string representation of the given version id. See
    /// `cairo.getSvgVersions()` for a way to get the list of valid versions
    /// ids.
    ///
    /// **Zig binding's author here**, nevermind previous comment, and maybe
    /// these two functions at all, you have solid Zig enums.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-version-to-string)
    pub fn versionToString(self: SvgVersion) []const u8 {
        const str = cairo_svg_version_to_string(self);
        return std.mem.span(str);
    }
};

test "versions" {
    const versions = getSvgVersions();
    try testing.expectEqualSlices(SvgVersion, &.{ .@"1.1", .@"1.2" }, versions);
    try testing.expectEqualStrings("SVG 1.1", SvgVersion.versionToString(.@"1.1"));
    try testing.expectEqualStrings("SVG 1.2", SvgVersion.versionToString(.@"1.2"));
}

extern fn cairo_svg_surface_create(filename: [*c]const u8, width_in_points: f64, height_in_points: f64) ?*SvgSurface;
extern fn cairo_svg_surface_create_for_stream(write_func: WriteFn, closure: ?*const anyopaque, width_in_points: f64, height_in_points: f64) ?*SvgSurface;
extern fn cairo_svg_surface_get_document_unit(surface: ?*SvgSurface) SvgUnit;
extern fn cairo_svg_surface_set_document_unit(surface: ?*SvgSurface, SvgUnit) void;
extern fn cairo_svg_surface_restrict_to_version(surface: ?*SvgSurface, version: SvgVersion) void;
extern fn cairo_svg_get_versions(versions: [*c][*c]const SvgVersion, num_versions: [*c]c_int) void;
extern fn cairo_svg_version_to_string(version: SvgVersion) [*c]const u8;
