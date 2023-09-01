const util = @import("util.zig");

const Error = @import("std").builtin.Type.Error;
const FromToInt = util.FromToInt;

/// `cairo.Format` is used to identify the memory format of image data.
///
/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-format-t)
pub const Format = enum(c_int) {
    pub usingnamespace FromToInt(@This());

    /// no such format exists or is supported
    INVALID = -1,
    /// each pixel is a 32-bit quantity, with alpha in the
    /// upper8 bits, then red, then green, then blue. The
    /// 32-bit quantities are stored native-endian.
    /// Pre-multiplied alpha is used (That is, 50%
    /// transparent red is 0x80800000, not 0x80ff0000)
    ARGB32 = 0,
    /// each pixel is a 32-bit quantity, with the upper
    /// 8 bits unused. Red, Green, and Blue are stored
    /// in the remaining 24 bits in that order
    RGB24 = 1,
    /// each pixel is a 8-bit quantity holding an alpha value
    A8 = 2,
    /// each pixel is a 1-bit quantity holding an alpha
    /// value. Pixels are packed together into 32-bit
    /// quantities. The ordering of the bits matches the
    /// endianness of the platform. On a big-endian machine,
    /// the first pixel is in the uppermost bit, on a
    /// little-endian machine the first pixel is in the
    /// least-significant bit
    A1 = 3,
    /// each pixel is a 16-bit quantity with red in the upper
    /// 5 bits, then green in the middle 6 bits, and blue
    /// in the lower 5 bits
    RGB16_565 = 4,
    /// like RGB24 but with 10bpc
    RGB30 = 5,
    _,

    /// This function provides a stride value that will respect all alignment requirements
    /// of the accelerated image-rendering code within cairo.
    ///
    /// Typical usage will be of the form:
    /// ```
    /// const format = cairo.Format.ARGB32;
    /// const stride = try format.strideForWidth(width);
    /// const data = try allocator.alloc(u8, @as(usize, stride) * height);
    /// const surface = try cairo.ImageSurface.createForData(data.ptr, format, width, height, stride);
    /// defer surface.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-format-stride-for-width)
    pub fn strideForWidth(self: Format, width: c_int) !u18 {
        const stride = switch (self) {
            .ARGB32, .RGB24, .A8, .A1, .RGB16_565, .RGB30 => cairo_format_stride_for_width(self.toInt(), width),
            else => return error.InvalidFormat,
        };
        if (stride == -1) return error.WidthTooLarge;
        return @as(u18, @intCast(stride));
    }

    extern fn cairo_format_stride_for_width(format: Format.TagType, width: c_int) callconv(.C) c_int;
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
    /// `ctx.pushGroup() `
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
    /// input clusters do not represent the accompanying text
    /// and glyph array
    InvalidClusters,
    /// invalid value for an input cairo_font_slant_t // TODO
    InvalidSlant,
    /// invalid value for an input cairo_font_weight_t // TODO
    InvalidWeight,
    /// invalid value (typically too big) for the size of the
    /// input (surface, pattern, etc.)
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

    /// this is a special value indicating the number of status values
    /// defined in this enumeration. When using this value, note that
    /// the version of cairo at run-time may have additional status values
    /// defined than the value of this symbol at compile-time
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
