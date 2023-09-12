/// `pango.Alignment` describes how to align the lines of a `pango.Layout`
/// within the available space.
///
/// If the `pango.Layout` is set to justify using `pango.Layout.setJustify()`,
/// this only affects partial lines.
///
/// See `pango.Layout.setAutoDir()` for how text direction affects the
/// interpretation of `pango.Alignment` values.
pub const Alignment = enum(c_uint) {
    /// Put all available space on the right.
    Left,
    /// Center the line within the available space.
    Center,
    /// Put all available space on the left.
    Right,
};

/// `pango.Direction` represents a direction in the Unicode bidirectional
/// algorithm.
///
/// Not every value in this enumeration makes sense for every usage of
/// `pango.Direction`; for example, the return value of
/// `pango_unichar_direction()` and `pango_find_base_dir()` cannot be
/// `.WeakLtr` or `.WeakRtl`, since every character is either neutral or has a
/// strong direction; on the other hand `.Neutral` doesn’t make sense to pass
/// to `pango_itemize_with_base_dir()`.
///
/// The `.TtbLtr`, `.TtbRtl` values come from an earlier interpretation of this
/// enumeration as the writing direction of a block of text and are no longer
/// used. See `pango.Gravity` for how vertical text is handled in Pango.
///
/// If you are interested in text direction, you should really use fribidi
/// directly. `pango.Direction` is only retained because it is used in some
/// public apis.
pub const Direction = enum(c_uint) {
    // TODO: fix desc
    ///A strong left-to-right direction.
    Ltr,
    /// A strong right-to-left direction.
    Rtl,
    /// Deprecated value; treated the same as `.Rtl`.
    TtbLtr,
    /// Deprecated value; treated the same as `.Ltr`.
    TtbRtl,
    /// A weak left-to-right direction.
    WeakLtr,
    /// A weak right-to-left direction.
    WeakRtl,
    /// No direction specified.
    Neutral,
};

/// `pango.EllipsizeMode` describes what sort of ellipsization should be
/// applied to text.
///
/// In the ellipsization process characters are removed from the text in order
/// to make it fit to a given width and replaced with an ellipsis.
pub const EllipsizeMode = enum(c_uint) {
    /// No ellipsization.
    None,
    /// Omit characters at the start of the text.
    Start,
    /// Omit characters in the middle of the text.
    Middle,
    /// Omit characters at the end of the text.
    End,
};

/// `pango.WrapMode` describes how to wrap the lines of a `pango.Layout` to the
/// desired width.
///
/// For `pango.WrapMode.Word`, Pango uses break opportunities that are
/// determined by the Unicode line breaking algorithm. For `.Char`, Pango
/// allows breaking at grapheme boundaries that are determined by the Unicode
/// text segmentation algorithm.
pub const WrapMode = enum(c_uint) {
    /// Wrap lines at word boundaries.
    Word,
    /// Wrap lines at character boundaries.
    Char,
    /// Wrap lines at word boundaries, but fall back to character boundaries if
    /// there is not enough space for a full word.
    WordChar,
};
