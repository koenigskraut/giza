//! `cairo.FontOptions` — How a font should be rendered
//!
//! The font options specify how fonts should be rendered. Most of the time the
//! font options implied by a surface are just right and do not need any
//! changes, but for pixel-based targets tweaking font options may result in
//! superior output on a particular display.

const std = @import("std");
const cairo = @import("../cairo.zig");
const safety = @import("../safety.zig");

const Antialias = cairo.Antialias;
const CairoError = cairo.CairoError;
const HintMetrics = cairo.HintMetrics;
const HintStyle = cairo.HintStyle;
const Status = cairo.Status;
const SubpixelOrder = cairo.SubpixelOrder;

pub const FontOptions = opaque {
    /// Allocates a new font options object with all options initialized to default values.
    ///
    /// **Returns**
    ///
    /// a newly allocated `cairo.FontOptions`. If memory cannot be allocated,
    /// an `error.OutOfMemory` will be raised.
    ///
    /// **NOTE**: The caller owns the created object and should call
    /// `.destroy()` on it when done with. You can use idiomatic Zig pattern
    /// with `defer`:
    /// ```zig
    /// const font_options = cairo.FontOptions.create();
    /// defer font_options.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-create)
    pub fn create() CairoError!*FontOptions {
        const font_options = cairo_font_options_create().?;
        try font_options.status().toErr();
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), font_options);
        return font_options;
    }

    /// Allocates a new font options object copying the option values from
    /// `self`.
    ///
    /// **Returns**
    ///
    /// a newly allocated `cairo.FontOptions`. If memory cannot be allocated,
    /// an `error.OutOfMemory` will be raised.
    ///
    /// **NOTE**: The caller owns the created object and should call
    /// `.destroy()` on it when done with. You can use idiomatic Zig pattern
    /// with `defer`:
    /// ```zig
    /// // font_options is cairo.FontOptions
    /// const fopts_copy = font_options.copy();
    /// defer fopts_copy.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-copy)
    pub fn copy(self: *const FontOptions) CairoError!*FontOptions {
        const font_options = cairo_font_options_copy(self).?;
        try font_options.status().toErr();
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), font_options);
        return font_options;
    }

    /// Destroys a `cairo.FontOptions` object created with
    /// `cairo.FontOptions.create()` or `cairo.FontOptions.copy()`.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-destroy)
    pub fn destroy(self: *FontOptions) void {
        cairo_font_options_destroy(self);
        if (safety.tracing) safety.destroy(self);
    }

    /// Checks whether an error has previously occurred for this font options
    /// object
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-status)
    pub fn status(self: *FontOptions) Status {
        return cairo_font_options_status(self);
    }

    /// Merges non-default options from `other` into `self`, replacing existing
    /// values. This operation can be thought of as somewhat similar to
    /// compositing other onto options with the operation of
    /// `cairo.Operator.Over`.
    ///
    /// **Parameters**
    /// - `other`: another `cairo.FontOptions`
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-merge)
    pub fn merge(self: *FontOptions, other: *const FontOptions) void {
        cairo_font_options_merge(self, other);
    }

    /// Compute a hash for the font options object; this value will be useful
    /// when storing an object containing a `cairo.FontOptions in a hash table.
    ///
    /// **Returns**
    ///
    /// the hash value for the font options object. The return value can be
    /// cast to a 32-bit type if a 32-bit hash value is needed.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-hash)
    pub fn hash(self: *const FontOptions) u64 {
        return @intCast(cairo_font_options_hash(self));
    }

    /// Compares two font options objects for equality.
    ///
    /// **Parameters**
    /// - `other`: another `cairo.FontOptions`
    ///
    /// **Returns**
    ///
    /// `true` if all fields of the two font options objects match. Note that
    /// this function will return `false` if either object is in error.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-equal)
    pub fn equal(self: *const FontOptions, other: *const FontOptions) bool {
        return cairo_font_options_equal(self, other) != 0;
    }

    /// Sets the antialiasing mode for the font options object. This specifies
    /// the type of antialiasing to do when rendering text.
    ///
    /// **Parameters**
    /// - `antialias`: the new antialiasing mode
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-set-antialias)
    pub fn setAntialias(self: *FontOptions, antialias: Antialias) void {
        cairo_font_options_set_antialias(self, antialias);
    }

    /// Gets the antialiasing mode for the font options object.
    ///
    /// **Returns**
    ///
    /// the antialiasing mode.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-get-antialias)
    pub fn getAntialias(self: *const FontOptions) Antialias {
        return cairo_font_options_get_antialias(self);
    }

    /// Sets the subpixel order for the font options object. The subpixel order
    /// specifies the order of color elements within each pixel on the display
    /// device when rendering with an antialiasing mode of
    /// `cairo.Antialias.Subpixel`. See the documentation for
    /// `cairo.SubpixelOrder` for full details.
    ///
    /// **Parameters**
    /// - `subpixel_order`: the new subpixel order
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-set-subpixel-order)
    pub fn setSubpixelOrder(self: *FontOptions, subpixel_order: SubpixelOrder) void {
        cairo_font_options_set_subpixel_order(self, subpixel_order);
    }

    /// Gets the subpixel order for the font options object. See the
    /// documentation for `cairo.SubpixelOrder` for full details.
    ///
    /// **Returns**
    ///
    /// the subpixel order for the font options object.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-get-subpixel-order)
    pub fn getSubpixelOrder(self: *const FontOptions) SubpixelOrder {
        return cairo_font_options_get_subpixel_order(self);
    }

    /// Sets the hint style for font outlines for the font options object.
    /// This controls whether to fit font outlines to the pixel grid, and if
    /// so, whether to optimize for fidelity or contrast. See the documentation
    /// for `cairo.HintStyle` for full details.
    ///
    /// **Parameters**
    /// - `hint_style`: the new hint style
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-set-hint-style)
    pub fn setHintStyle(self: *FontOptions, hint_style: HintStyle) void {
        cairo_font_options_set_hint_style(self, hint_style);
    }

    /// Gets the hint style for font outlines for the font options object. See
    /// the documentation for `cairo.HintStyle` for full details.
    ///
    /// **Returns**
    ///
    /// the hint style for the font options object.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-get-hint-style)
    pub fn getHintStyle(self: *const FontOptions) HintStyle {
        return cairo_font_options_get_hint_style(self);
    }

    /// Sets the metrics hinting mode for the font options object. This
    /// controls whether metrics are quantized to integer values in device
    /// units. See the documentation for `cairo.HintMetrics` for full details.
    ///
    ///
    /// **Parameters**
    /// - `hint_metrics`: the new metrics hinting mode
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-set-hint-metrics)
    pub fn setHintMetrics(self: *FontOptions, hint_metrics: HintMetrics) void {
        cairo_font_options_set_hint_metrics(self, hint_metrics);
    }

    /// Gets the metrics hinting mode for the font options object. See the
    /// documentation for `cairo.HintMetrics` for full details.
    ///
    /// **Returns**
    ///
    /// the metrics hinting mode for the font options object.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-get-hint-metrics)
    pub fn getHintMetrics(self: *const FontOptions) HintMetrics {
        return cairo_font_options_get_hint_metrics(self);
    }

    /// Gets the OpenType font variations for the font options object. See
    /// `cairo.FontOptions.setVariations()` for details about the string
    /// format.
    ///
    /// **Returns**
    ///
    /// the font variations for the font options object. The returned string
    /// belongs to the `self` and must not be modified. It is valid until
    /// either the font options object is destroyed or the font variations in
    /// this object is modified with `cairo.FontOptions.setVariations()`.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-get-variations)
    pub fn getVariations(self: *FontOptions) []const u8 {
        const variations: [*c]const u8 = cairo_font_options_get_variations(self) orelse "";
        return std.mem.span(variations);
    }

    /// Sets the OpenType font variations for the font options object. Font
    /// variations are specified as a string with a format that is similar to
    /// the CSS font-variation-settings. The string contains a comma-separated
    /// list of axis assignments, which each assignment consists of a 4-
    /// character axis name and a value, separated by whitespace and optional
    /// equals sign.
    ///
    /// Examples:
    ///
    /// wght=200,wdth=140.5
    ///
    /// wght 200 , wdth 140.5
    ///
    /// **Parameters**
    ///
    /// - `variations`: the new font variations, or `null`
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-font-options-t.html#cairo-font-options-set-variations)
    pub fn setVariations(self: *FontOptions, variations: ?[:0]const u8) void {
        cairo_font_options_set_variations(self, variations orelse null);
    }
};

const expect = std.testing.expect;
const expectEqualStrings = std.testing.expectEqualStrings;

test "FontOptions" {
    const font_options = try FontOptions.create();
    defer font_options.destroy();

    try expect(font_options.getAntialias() == .Default);
    try expect(font_options.getSubpixelOrder() == .Default);
    try expect(font_options.getHintStyle() == .Default);
    try expect(font_options.getHintMetrics() == .Default);

    try expectEqualStrings("", font_options.getVariations());
    const variations = "wght=200,wdth=140.5";
    font_options.setVariations(variations);
    try expectEqualStrings(variations, font_options.getVariations());
}

extern fn cairo_font_options_create() ?*FontOptions;
extern fn cairo_font_options_copy(original: ?*const FontOptions) ?*FontOptions;
extern fn cairo_font_options_destroy(options: ?*FontOptions) void;
extern fn cairo_font_options_status(options: ?*FontOptions) Status;
extern fn cairo_font_options_merge(options: ?*FontOptions, other: ?*const FontOptions) void;
extern fn cairo_font_options_equal(options: ?*const FontOptions, other: ?*const FontOptions) c_int; // bool
extern fn cairo_font_options_hash(options: ?*const FontOptions) c_ulong;
extern fn cairo_font_options_set_antialias(options: ?*FontOptions, antialias: Antialias) void;
extern fn cairo_font_options_get_antialias(options: ?*const FontOptions) Antialias;
extern fn cairo_font_options_set_subpixel_order(options: ?*FontOptions, subpixel_order: SubpixelOrder) void;
extern fn cairo_font_options_get_subpixel_order(options: ?*const FontOptions) SubpixelOrder;
extern fn cairo_font_options_set_hint_style(options: ?*FontOptions, hint_style: HintStyle) void;
extern fn cairo_font_options_get_hint_style(options: ?*const FontOptions) HintStyle;
extern fn cairo_font_options_set_hint_metrics(options: ?*FontOptions, hint_metrics: HintMetrics) void;
extern fn cairo_font_options_get_hint_metrics(options: ?*const FontOptions) HintMetrics;
extern fn cairo_font_options_set_variations(options: ?*FontOptions, variations: [*c]const u8) void;
extern fn cairo_font_options_get_variations(options: ?*FontOptions) [*c]const u8;
