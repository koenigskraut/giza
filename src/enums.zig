const util = @import("util.zig");

const Error = @import("std").builtin.Type.Error;
const FromToInt = util.FromToInt;

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

/// `cairo.Content` is used to describe the content that a surface will
/// contain, whether color information, alpha information (translucence vs.
/// opacity), or both.
///
/// **Note:** The large values here are designed to keep `cairo.Content` values
/// distinct from `cairo.Format` values so that the implementation can detect
/// the error if users confuse the two types.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-content-t)
pub const Content = enum(c_uint) {
    pub usingnamespace util.FromToInt(@This());

    /// The surface will hold color content only
    Color = 4096,
    /// The surface will hold alpha content only
    Alpha = 8192,
    /// The surface will hold color and alpha content
    ColorAlpha = 12288,
};

/// `cairo.DeviceType` is used to describe the type of a given device. The
/// devices types are also known as "backends" within cairo.
///
/// The device type can be queried with `cairo.Device.getType()`.
///
/// The various `cairo.Device` functions can be used with devices of any type,
/// but some backends also provide type-specific functions that must only be
/// called with a device of the appropriate type. These functions are methids
/// of specific `cairo.Device` instances such as
/// `cairo.ScriptDevice.writeComment()`.
///
/// The behavior of calling a type-specific function with a device of the wrong
/// type is undefined, that is — **DO NOT** cast pointers into `cairo.Device`
/// manually, use `.asDevice()` on a specific type and **DO NOT** keep the
/// result.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-type-t)
pub const DeviceType = enum(c_int) {
    Drm = 0,
    Gl,
    Script,
    Xcb,
    Xlib,
    Xml,
    Cogl,
    Wn32,
    Invalid = -1,
};

/// `cairo.Extend` is used to describe how pattern color/alpha will be
/// determined for areas "outside" the pattern's natural area, (for example,
/// outside the surface bounds or outside the gradient geometry).
///
/// Mesh patterns are not affected by the extend mode.
///
/// The default extend mode is `.None` for surface patterns and `.Pad` for
/// gradient patterns.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-extend-t)
pub const Extend = enum(c_uint) {
    /// pixels outside of the source pattern are fully transparent
    None,
    /// the pattern is tiled by repeating
    Repeat,
    /// the pattern is tiled by reflecting at the edges
    Reflect,
    /// pixels outside of the pattern copy the closest pixel from the source
    Pad,
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

/// `cairo.Filter` is used to indicate what filtering should be applied when
/// reading pixel values from patterns. See `cairo.Pattern.setFilter()` for
/// indicating the desired filter to be used with a particular pattern.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-filter-t)
pub const Filter = enum(c_uint) {
    /// A high-performance filter, with quality similar to `.Nearest`
    Fast,
    /// A reasonable-performance filter, with quality similar to `.Bilinear`
    Good,
    /// The highest-quality available, performance may not be suitable for
    /// interactive use
    Best,
    /// Nearest-neighbor filtering
    Nearest,
    /// Linear interpolation in two dimensions
    Bilinear,
    /// This filter value is currently unimplemented, and should not be used in
    /// current code
    Gaussian,
};

/// Specifies variants of a font face based on their slant.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-text.html#cairo-font-slant-t)
pub const FontSlant = enum(c_uint) {
    /// Upright font style
    Normal,
    /// Italic font style
    Italic,
    /// Oblique font style
    Oblique,
};

/// `cairo.FontType` is used to describe the type of a given font face or
/// scaled font. The font types are also known as "font backends" within cairo.
///
/// The type of a font face is determined by the function used to create it,
/// which will generally be of the form `cairo_type_font_face_create`. The font
/// face type can be queried with `fontFace.getType()`.
///
/// The various `cairo.FontFace` functions can be used with a font face of any
/// type.
///
/// The type of a scaled font is determined by the type of the font face passed
/// to `cairo_scaled_font_create()`. The scaled font type can be queried with
/// `cairo_scaled_font_get_type()`.
///
/// The various `cairo.ScaledFont` functions can be used with scaled fonts of
/// any type, but some font backends also provide type-specific functions that
/// must only be called with a scaled font of the appropriate type. These
/// functions have names that begin with `cairo_type_scaled_font()` such as
/// `cairo_ft_scaled_font_lock_face()`.
///
/// The behavior of calling a type-specific function with a scaled font of the
/// wrong type is undefined.
///
/// New entries may be added in future versions.
pub const FontType = enum(c_uint) {
    // TODO: fix desc
    /// The font was created using cairo's toy font api
    Toy,
    /// The font is of type FreeType
    Ft,
    /// The font is of type Win32
    Win32,
    /// The font is of type Quartz
    Quartz,
    /// The font was create using cairo's user font api
    User,
};

/// Specifies variants of a font face based on their weight.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-text.html#cairo-font-weight-t)
pub const FontWeight = enum(c_uint) {
    /// Normal font weight
    Normal,
    /// Bold font weight
    Bold,
};

/// `cairo.Format` is used to identify the memory format of image data.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-format-t)
pub const Format = enum(c_int) {
    pub usingnamespace FromToInt(@This());

    /// no such format exists or is supported
    INVALID = -1,
    /// each pixel is a 32-bit quantity, with alpha in the upper8 bits, then
    /// red, then green, then blue. The 32-bit quantities are stored
    /// native-endian. Pre-multiplied alpha is used (That is, 50% transparent
    /// red is 0x80800000, not 0x80ff0000)
    ARGB32,
    /// each pixel is a 32-bit quantity, with the upper 8 bits unused. Red,
    /// Green, and Blue are stored in the remaining 24 bits in that order
    RGB24,
    /// each pixel is a 8-bit quantity holding an alpha value
    A8,
    /// each pixel is a 1-bit quantity holding an alpha value. Pixels are
    /// packed together into 32-bit quantities. The ordering of the bits
    /// matches the endianness of the platform. On a big-endian machine, the
    /// first pixel is in the uppermost bit, on a little-endian machine the
    /// first pixel is in the least-significant bit
    A1,
    /// each pixel is a 16-bit quantity with red in the upper 5 bits, then
    /// green in the middle 6 bits, and blue in the lower 5 bits
    RGB16_565,
    /// like RGB24 but with 10bpc
    RGB30,
    _,

    /// This function provides a stride value that will respect all alignment
    /// requirements of the accelerated image-rendering code within cairo.
    ///
    /// Typical usage will be of the form:
    /// ```zig
    /// const format = cairo.Format.ARGB32;
    /// const stride = try format.strideForWidth(width);
    /// const data = try allocator.alloc(u8, @as(usize, stride) * height);
    /// const surface = try cairo.ImageSurface.createForData(data.ptr, format, width, height, stride);
    /// defer surface.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-format-stride-for-width)
    pub fn strideForWidth(self: Format, width: c_int) !u18 {
        // TODO: check example, rework it? work on createForData func?
        const stride = switch (self) {
            .ARGB32, .RGB24, .A8, .A1, .RGB16_565, .RGB30 => cairo_format_stride_for_width(self.toInt(), width),
            else => return error.InvalidFormat,
        };
        if (stride == -1) return error.WidthTooLarge;
        return @as(u18, @intCast(stride));
    }

    extern fn cairo_format_stride_for_width(format: Format.TagType, width: c_int) c_int;
};

/// Specifies whether to hint font metrics; hinting font metrics means
/// quantizing them so that they are integer values in device space. Doing this
/// improves the consistency of letter and line spacing, however it also means
/// that text will be laid out differently at different zoom factors.
pub const HintMetrics = enum(c_uint) {
    /// Hint metrics in the default manner for the font backend and target
    /// device
    Default,
    /// Do not hint font metrics
    Off,
    /// Hint font metrics
    On,
};

/// Specifies the type of hinting to do on font outlines. Hinting is the
/// process of fitting outlines to the pixel grid in order to improve the
/// appearance of the result. Since hinting outlines involves distorting them,
/// it also reduces the faithfulness to the original outline shapes. Not all of
/// the outline hinting styles are supported by all font backends.
pub const HintStyle = enum(c_uint) {
    /// Use the default hint style for font backend and target device
    Default,
    /// Do not hint outlines
    None,
    /// Hint outlines slightly to improve contrast while retaining good
    /// fidelity to the original shapes
    Slight,
    /// Hint outlines with medium strength giving a compromise between fidelity
    /// to the original shapes and contrast
    Medium,
    /// Hint outlines to maximize contrast
    Full,
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

pub const MimeType = enum {
    /// Group 3 or Group 4 CCITT facsimile encoding (International
    /// Telecommunication Union, Recommendations T.4 and T.6.)
    CcittFax,
    /// Decode parameters for Group 3 or Group 4 CCITT facsimile encoding.
    /// See [CCITT Fax Images](https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#ccitt).
    CcittFaxParams,
    /// Encapsulated PostScript file.
    /// [Encapsulated PostScript File Format Specification](http://wwwimages.adobe.com/content/dam/Adobe/endevnet/postscript/pdfs/5002.EPSF_Spec.pdf)
    Eps,
    /// Embedding parameters Encapsulated PostScript data. See
    /// [Embedding EPS files](https://www.cairographics.org/manual/cairo-PostScript-Surfaces.html#eps).
    EpsParams,
    /// Joint Bi-level Image Experts Group image coding standard (ISO/IEC
    /// 11544).
    Jbig2,
    /// Joint Bi-level Image Experts Group image coding standard (ISO/IEC
    /// 11544) global segment.
    Jbig2Global,
    /// An unique identifier shared by a JBIG2 global segment and all JBIG2
    /// images that depend on the global segment.
    Jbig2GlobalId,
    /// The Joint Photographic Experts Group (JPEG) 2000 image coding standard
    ///  (ISO/IEC 15444-1).
    Jp2,
    /// The Joint Photographic Experts Group (JPEG) image coding standard
    /// (ISO/IEC 10918-1).
    Jpeg,
    /// The Portable Network Graphics image file format (ISO/IEC 15948).
    Png,
    /// URI for an image file (unofficial MIME type).
    Uri,
    /// Unique identifier for a surface (cairo specific MIME type). All
    /// surfaces with the same unique identifier will only be embedded once.
    UniqueId,

    pub fn toString(self: MimeType) []const u8 {
        return switch (self) {
            .CcittFax => "image/g3fax",
            .CcittFaxParams => "application/x-cairo.ccitt.params",
            .Eps => "application/postscript",
            .EpsParams => "application/x-cairo.eps.params",
            .Jbig2 => "application/x-cairo.jbig2",
            .Jbig2Global => "application/x-cairo.jbig2-global",
            .Jbig2GlobalId => "application/x-cairo.jbig2-global-id",
            .Jp2 => "image/jp2",
            .Jpeg => "image/jpeg",
            .Png => "image/png",
            .Uri => "text/x-uri",
            .UniqueId => "application/x-cairo.uuid",
        };
    }
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

/// `PathDataType` is used to describe the type of one portion of a path when
/// represented as a `Path`. See `PathData` for details.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Paths.html#cairo-path-data-type-t)
pub const PathDataType = enum(c_uint) {
    /// A move-to operation
    MoveTo,
    /// A line-to operation
    LineTo,
    /// A curve-to operation
    CurveTo,
    /// A close-path operation
    ClosePath,
};

/// `cairo.PatternType` is used to describe the type of a given pattern.
///
/// The type of a pattern is determined by the function used to create it. The
/// `cairo.Pattern.createRGB()` and `cairo.Pattern.createRGBA()` functions
/// create SOLID patterns. The remaining cairo.Pattern.create functions map to
/// pattern types in obvious ways.
///
/// The pattern type can be queried with `pattern.getType()`
///
/// Most `cairo.Pattern` functions can be called with a pattern of any type,
/// (though trying to change the extend or filter for a solid pattern will have
/// no effect). A notable exception is `pattern.addColorStopRGB()` and
/// `pattern.addColorStopRGBA()` which must only be called with gradient
/// patterns (either `.Linear` or `.Radial`). Otherwise the pattern will be
/// shutdown and put into an error state.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-type-t)
pub const PatternType = enum(c_uint) {
    /// The pattern is a solid (uniform) color. It may be opaque or
    /// translucent.
    Solid,
    /// The pattern is a based on a surface (an image).
    Surface,
    /// The pattern is a linear gradient.
    Linear,
    /// The pattern is a radial gradient.
    Radial,
    /// The pattern is a mesh.
    Mesh,
    /// The pattern is a user pattern providing raster data.
    RasterSource,
};

/// The subpixel order specifies the order of color elements within each pixel
/// on the display device when rendering with an antialiasing mode of
/// `cairo.Antialias.Subpixel`.
pub const SubpixelOrder = enum(c_uint) {
    /// Use the default subpixel order for for the target device
    Default,
    /// Subpixel elements are arranged horizontally with red at the left
    Rgb,
    /// Subpixel elements are arranged horizontally with blue at the left
    Bgr,
    /// Subpixel elements are arranged vertically with red at the top
    Vrgb,
    /// Subpixel elements are arranged vertically with blue at the top
    Vbgr,
};

/// Used as the return value for `cairo.Region.containsRectangle()`.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Regions.html#cairo-region-overlap-t)
pub const RegionOverlap = enum(c_uint) {
    /// The contents are entirely inside the region
    In,
    /// The contents are entirely outside the region
    Out,
    /// The contents are partially inside and partially outside the region
    Part,
};

pub const CairoError = error{
    OutOfMemory,
    InvalidRestore,
    InvalidPopGroup,
    NoCurrentPoint,
    InvalidMatrix,
    InvalidStatus,
    NullPointer,
    InvalidString,
    InvalidPathData,
    ReadError,
    WriteError,
    SurfaceFinished,
    SurfaceTypeMismatch,
    PatternTypeMismatch,
    InvalidContent,
    InvalidFormat,
    InvalidVisual,
    FileNotFound,
    InvalidDash,
    InvalidDscComment,
    InvalidIndex,
    ClipNotRepresentable,
    TempFileError,
    InvalidStride,
    FontTypeMismatch,
    UserFontImmutable,
    UserFontError,
    NegativeCount,
    InvalidClusters,
    InvalidSlant,
    InvalidWeight,
    InvalidSize,
    UserFontNotImplemented,
    DeviceTypeMismatch,
    DeviceError,
    InvalidMeshConstruction,
    DeviceFinished,
    Jbig2GlobalMissing,
    PngError,
    FreetypeError,
    Win32GdiError,
    TagError,

    UnknownStatus,
};

/// A set of script output variants.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-mode-t)
pub const ScriptMode = enum(c_uint) {
    // the output will be in readable text (default).
    Ascii,
    /// the output will use byte codes.
    Binary,
};

/// `cairo.Status` is used to indicate errors that can occur when using Cairo.
/// In some cases it is returned directly by functions, but when using
/// `cairo.Context`, the last error, if any, is stored in the context
/// and can be retrieved with `ctx.status()`.
///
/// Use `status.toString()` to get a human-readable representation of an error
/// message.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Error-handling.html#cairo-status-t)
pub const Status = enum(c_uint) {
    pub usingnamespace FromToInt(@This());

    /// no error has occurred
    Success = 0,

    /// out of memory
    NoMemory,
    /// `ctx.restore()` called without matching `ctx.save()`
    InvalidRestore,
    /// no saved group to pop, i.e. `ctx.popGroup()` without matching
    /// `ctx.pushGroup()`
    InvalidPopGroup,
    /// no current point defined
    NoCurrentPoint,
    /// invalid matrix (not invertible)
    InvalidMatrix,
    /// invalid value for an input `cairo.Status`
    InvalidStatus,
    /// `null` pointer
    NullPointer,
    /// input string not valid UTF-8
    InvalidString,
    /// input path data not valid
    InvalidPathData,
    /// error while reading from input stream
    ReadError,
    /// error while writing to output stream
    WriteError,
    /// target surface has been finished
    SurfaceFinished,
    /// the surface type is not appropriate for the operation
    SurfaceTypeMismatch,
    /// the pattern type is not appropriate for the operation
    PatternTypeMismatch,
    /// invalid value for an input `cairo.Content`
    InvalidContent,
    /// invalid value for an input `cairo.Format`
    InvalidFormat,
    /// invalid value for an input Visual*
    InvalidVisual,
    /// file not found
    FileNotFound,
    /// invalid value for a dash setting
    InvalidDash,
    /// invalid value for a DSC comment
    InvalidDscComment,
    /// invalid index passed to getter
    InvalidIndex,
    /// clip region not representable in desired format
    ClipNotRepresentable,
    /// error creating or writing to a temporary file
    TempFileError,
    /// invalid value for stride
    InvalidStride,
    /// the font type is not appropriate for the operation
    FontTypeMismatch,
    /// the user-font is immutable
    UserFontImmutable,
    /// error occurred in a user-font callback function
    UserFontError,
    /// negative number used where it is not allowed
    NegativeCount,
    /// input clusters do not represent the accompanying text and glyph array
    InvalidClusters,
    /// invalid value for an input `cairo.FontSlant`
    InvalidSlant,
    /// invalid value for an input `cairo.FontWeight`
    InvalidWeight,
    /// invalid value (typically too big) for the size of the input (surface,
    /// pattern, etc.)
    InvalidSize,
    /// user-font method not implemented
    UserFontNotImplemented,
    /// the device type is not appropriate for the operation
    DeviceTypeMismatch,
    /// an operation to the device caused an unspecified error
    DeviceError,
    /// a mesh pattern construction operation was used outside
    /// of a cairo_mesh_pattern_begin_patch()/cairo_mesh_pattern_end_patch() pair // TODO
    InvalidMeshConstruction,
    /// target device has been finished
    DeviceFinished,
    /// CAIRO_MIME_TYPE_JBIG2_GLOBAL_ID has been used on at least one image but no image provided CAIRO_MIME_TYPE_JBIG2_GLOBAL
    /// // TODO
    Jbig2GlobalMissing,
    /// error occurred in libpng while reading from or writing
    /// to a PNG file
    PngError,
    /// error occurred in libfreetype
    FreetypeError,
    /// error occurred in the Windows Graphics Device Interface
    Win32GdiError,
    /// invalid tag name, attributes, or nesting
    TagError,

    /// this is a special value indicating the number of status values defined
    /// in this enumeration. When using this value, note that the version of
    /// cairo at run-time may have additional status values defined than the
    /// value of this symbol at compile-time
    LastStatus,
    _,

    pub fn toErr(self: Status) CairoError!void {
        return switch (self) {
            .Success => {},
            .NoMemory => CairoError.OutOfMemory,
            .InvalidRestore => CairoError.InvalidRestore,
            .InvalidPopGroup => CairoError.InvalidPopGroup,
            .NoCurrentPoint => CairoError.NoCurrentPoint,
            .InvalidMatrix => CairoError.InvalidMatrix,
            .InvalidStatus => CairoError.InvalidStatus,
            .NullPointer => CairoError.NullPointer,
            .InvalidString => CairoError.InvalidString,
            .InvalidPathData => CairoError.InvalidPathData,
            .ReadError => CairoError.ReadError,
            .WriteError => CairoError.WriteError,
            .SurfaceFinished => CairoError.SurfaceFinished,
            .SurfaceTypeMismatch => CairoError.SurfaceTypeMismatch,
            .PatternTypeMismatch => CairoError.PatternTypeMismatch,
            .InvalidContent => CairoError.InvalidContent,
            .InvalidFormat => CairoError.InvalidFormat,
            .InvalidVisual => CairoError.InvalidVisual,
            .FileNotFound => CairoError.FileNotFound,
            .InvalidDash => CairoError.InvalidDash,
            .InvalidDscComment => CairoError.InvalidDscComment,
            .InvalidIndex => CairoError.InvalidIndex,
            .ClipNotRepresentable => CairoError.ClipNotRepresentable,
            .TempFileError => CairoError.TempFileError,
            .InvalidStride => CairoError.InvalidStride,
            .FontTypeMismatch => CairoError.FontTypeMismatch,
            .UserFontImmutable => CairoError.UserFontImmutable,
            .UserFontError => CairoError.UserFontError,
            .NegativeCount => CairoError.NegativeCount,
            .InvalidClusters => CairoError.InvalidClusters,
            .InvalidSlant => CairoError.InvalidSlant,
            .InvalidWeight => CairoError.InvalidWeight,
            .InvalidSize => CairoError.InvalidSize,
            .UserFontNotImplemented => CairoError.UserFontNotImplemented,
            .DeviceTypeMismatch => CairoError.DeviceTypeMismatch,
            .DeviceError => CairoError.DeviceError,
            .InvalidMeshConstruction => CairoError.InvalidMeshConstruction,
            .DeviceFinished => CairoError.DeviceFinished,
            .Jbig2GlobalMissing => CairoError.Jbig2GlobalMissing,
            .PngError => CairoError.PngError,
            .FreetypeError => CairoError.FreetypeError,
            .Win32GdiError => CairoError.Win32GdiError,
            .TagError => CairoError.TagError,

            else => CairoError.UnknownStatus,
        };
    }
};

/// `cairo.SurfaceType` is used to describe the type of a given surface. The
/// surface types are also known as "backends" or "surface backends" within
/// cairo.
///
/// The type of a surface is determined by the function used to create it,
/// which will generally be a struct method of specific type (though see
/// `surface.createSimilar()` as well).
///
/// The surface type can be queried with `surface.getType()`. The behavior of
/// calling a type-specific function with a surface of the wrong type is
/// undefined.
///
/// **Zig note:** you shouldn't be worried about that if you're not casting
/// surfaces manually, which you shouldn't
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-type-t)
pub const SurfaceType = enum(c_uint) {
    pub usingnamespace util.FromToInt(@This());

    /// The surface is of type image
    Image,
    /// The surface is of type pdf
    PDF,
    /// The surface is of type ps
    PS,
    /// The surface is of type xlib
    XLib,
    /// The surface is of type xcb
    XCB,
    /// The surface is of type glitz
    Glitz,
    /// The surface is of type quartz
    Quartz,
    /// The surface is of type win32
    Win32,
    /// The surface is of type beos
    BeOS,
    /// The surface is of type directfb
    DirectFB,
    /// The surface is of type svg
    SVG,
    /// The surface is of type os2
    OS2,
    /// The surface is a win32 printing surface
    Win32Printing,
    /// The surface is of type quartz_image
    QuartzImage,
    /// The surface is of type script
    Script,
    /// The surface is of type Qt
    Qt,
    /// The surface is of type recording
    Recording,
    /// The surface is a OpenVG surface
    VG,
    /// The surface is of type OpenGL
    GL,
    /// The surface is of type Direct Render Manager
    DRM,
    /// The surface is of type 'tee' (a multiplexing surface)
    Tee, // ?
    /// The surface is of type XML (for debugging)
    XML,
    /// The surface is of type Skia
    Skia,
    /// The surface is a subsurface created with
    /// `surface.createForRectangle()`
    Subsurface,
    /// The surface is of type Cogl
    Cogl,
};

/// Specifies properties of a text cluster mapping.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-text.html#cairo-text-cluster-flags-t)
pub const TextClusterFlags = enum(c_uint) {
    None,
    /// The clusters in the cluster array map to glyphs in the glyph array from
    /// end to start.
    Backward = 1,
};

/// Specifies whether operations should be recorded.
pub const SurfaceObserverMode = enum(c_uint) {
    // Do not record operations
    Normal,
    // Record operations
    RecordOperations,
};
